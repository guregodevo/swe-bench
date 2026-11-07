# Survey: union queryset ordering breaks on ordering with derived querysets

Issue #29834. A `union()` queryset ordered by a column that is not in the
select list of a derived `values_list()` produces `ORDER BY position N is not
in select list`, and evaluating the derived queryset mutates the shared
combined queries so the original queryset breaks on re-evaluation.

## Public APIs named or shown in the issue

- `django/db/models/query.py:QuerySet.values_list` — the derived-queryset call shown in the issue; it builds a clone via `_values()` and swaps in a values-list iterable, so the ordering/select mismatch is only discovered at evaluation.
- `django/db/models/query.py:QuerySet._values` — the shared implementation behind `values()`/`values_list()`; it calls `clone.query.set_values(fields)`, replacing the select list on the derived query while the ordering is left intact.
- `django/db/models/query.py:QuerySet.union` — the public combinator shown in the issue; it delegates to `_combinator_query('union', ...)`.
- `django/db/models/query.py:QuerySet._combinator_query` — stores `(self.query,) + tuple(qs.query ...)` in `combined_queries` as references to the original `Query` objects, which is what lets a derived queryset's compilation reach back into the originals.
- `django/db/models/query.py:QuerySet.order_by` — the public ordering call shown in the issue; it clones the queryset, clears ordering and re-adds the requested fields, leaving the combined-query select list untouched.
- `django/db/models/query.py:QuerySet.filter` — the public filtering call shown (`filter(pk__in=[...])`); it clones and adds a `Q`, producing the base querysets that are later combined.
- `django/db/models/query.py:QuerySet.__repr__` — the re-evaluation shown as `[breaks]`; it slices and iterates the queryset, triggering a fresh compile of the corrupted combined query.
- `django/db/models/query.py:QuerySet.__iter__` — the iteration path in the traceback; it calls `_fetch_all()` and materialises the result cache.
- `django/db/models/query.py:QuerySet._fetch_all` — the traceback's `_fetch_all`; it runs `list(self._iterable_class(self))`, which compiles and executes the query.

## Where the behaviour happens

- `django/db/models/sql/compiler.py:SQLCompiler.get_order_by` — the core of the bug: for a combined query it relabels each ORDER BY expression to a positional `RawSQL('%d' % (idx + 1))` by matching it against `self.select`, and when the ordered column is not selected it falls through to `raise DatabaseError('ORDER BY term does not match any column in the result set.')` (the `ORDER BY position N is not in select list` failure).
- `django/db/models/sql/compiler.py:SQLCompiler.get_combinator_sql` — compiles each combined query and, when the outer query has a `values_select`, forces that select list onto the inner queries; in this revision it clones before `set_values()` (the #30572 guard), but the sibling path is where the shared combined queries would otherwise be mutated.
- `django/db/models/sql/compiler.py:SQLCompiler.as_sql` — assembles the final SQL, appending the `ORDER BY` produced by `get_order_by()` after the combinator SQL, which is where the invalid positional ordering is emitted.
- `django/db/models/sql/compiler.py:SQLCompiler.execute_sql` — executes the generated SQL and is where the backend raises `ProgrammingError: ORDER BY position 4 is not in select list`.
- `django/db/models/sql/compiler.py:SQLCompiler.results_iter` — iterates the executed rows and maps them to the selected fields, the step that fails once the select list and ordering disagree.
- `django/db/models/query.py:ModelIterable.__iter__` — the default iterable in the traceback; it obtains the compiler and calls `execute_sql()`, so a plain model queryset hits the failure here.
- `django/db/models/query.py:ValuesListIterable.__iter__` — the iterable used by the derived `values_list()`; it reorders rows by `queryset._fields` against `query.values_select`, so a mutated select list also corrupts the returned column order.
- `django/db/models/query.py:FlatValuesListIterable.__iter__` — the `flat=True` variant shown in the issue; it yields `row[0]` from the compiled results, so it inherits the same ordering/select mismatch.
- `django/db/models/sql/query.py:Query.set_values` — clears the select fields and rebuilds `values_select`/`select` for the derived query, the state change that leaves ordering pointing at a now-unselected column.
- `django/db/models/sql/query.py:Query.clear_select_fields` — resets `select` and `values_select` to empty, the first half of the mutation performed by `set_values()`.
- `django/db/models/sql/query.py:Query.add_fields` — resolves the requested field names into select columns, rebuilding the select list that the ORDER BY positions are matched against.
- `django/db/models/sql/query.py:Query.add_ordering` — appends the `order_by` entries that `get_order_by()` later tries to map onto the select list.
- `django/db/models/sql/query.py:Query.clear_ordering` — clears `order_by`/`extra_order_by` (and optionally default ordering), used by `_combinator_query()` and `order_by()`.
- `django/db/models/sql/query.py:Query.clone` — shallow-copies `__dict__`, so `combined_queries` keeps pointing at the same inner `Query` objects; this sharing is what makes derived-queryset compilation able to affect the original.
- `django/db/models/sql/query.py:Query.chain` — the per-operation copy used by `QuerySet._chain()`; it clones the query but preserves the shared `combined_queries` references.
- `django/db/models/query.py:QuerySet._clone` — builds the new queryset with `self.query.chain()`, the clone step that still shares the combined inner queries.
- `django/db/models/query.py:QuerySet._chain` — the copy helper used by `order_by()`, `values_list()`, `filter()` and the combinators; it is the common entry to the shared-query clone path.

## Siblings that do the same thing the same way

- `django/db/models/query.py:QuerySet.intersection` — a parallel combinator that also routes through `_combinator_query()`, so it shares the same combined-query ordering/select behaviour.
- `django/db/models/query.py:QuerySet.difference` — the other parallel combinator using `_combinator_query()`, with the same ordering/select and shared-query exposure.
- `django/db/models/query.py:QuerySet.values` — the dict-returning sibling of `values_list()`; it uses the same `_values()`/`set_values()` path and can trigger the same ordering/select mismatch.
- `django/db/models/query.py:QuerySet.__getitem__` — the slicing path used by `__repr__` and by `qs[:N]`; it clones and sets limits, then evaluates, so it reaches the same failing compile.
- `django/db/models/sql/compiler.py:SQLCompiler.get_extra_select` — a second place that inspects the ORDER BY expressions against the select list for combined/distinct queries, sharing the same positional-ordering assumptions.
