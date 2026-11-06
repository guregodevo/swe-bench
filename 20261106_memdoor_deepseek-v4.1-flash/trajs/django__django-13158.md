# django__django-13158 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 77s 28 lines cost=0.003861 in=240335 cached=203264 out=5580 calls=21`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
17:18:01 weboff: chief: web_fetch,web_search
17:18:01 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

QuerySet.none() on combined queries returns all results.
Description
	
I came across this issue on Stack Overflow. I'm not 100% sure it's a bug, but it does seem strange. With this code (excuse the bizarre example filtering):
class Publication(models.Model):
	pass
class Article(models.Model):
	publications = models.ManyToManyField(to=Publication, blank=True, null=True)
class ArticleForm(forms.ModelForm):
	publications = forms.ModelMultipleChoiceField(
		Publication.objects.filter(id__lt=2) | Publication.objects.filter(id__gt=5),
		required=False,
	)
	class Meta:
		model = Article
		fields = ["publications"]
class ArticleAdmin(admin.ModelAdmin):
	form = ArticleForm
This works well. However, changing the ModelMultipleChoiceField queryset to use union() breaks things.
publications = forms.ModelMultipleChoiceField(
	Publication.objects.filter(id__lt=2).union(
		Publication.objects.filter(id__gt=5)
	),
	required=False,
)
The form correctly shows only the matching objects. However, if you submit this form while empty (i.e. you didn't select any publications), ALL objects matching the queryset will be added. Using the OR query, NO objects are added, as I'd expect.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain | head -50"
}
```

**tool result**

```
/testbed
AUTHORS
CONTRIBUTING.rst
Django.egg-info
Gruntfile.js
INSTALL
LICENSE
LICENSE.python
MANIFEST.in
README.rst
django
docs
extras
js_tests
package.json
scripts
setup.cfg
setup.py
tests
tox.ini
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -R \"def none\" -n django/db/models/query.py && grep -R \"class EmptyQuerySet\\|class EmptyResultSet\" -n django/db/models"
}
```

**tool result**

```
919:    def none(self):
django/db/models/query.py:1390:class EmptyQuerySet(metaclass=InstanceCheckMeta):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '880,960p' django/db/models/query.py && sed -n '1370,1420p' django/db/models/query.py"
}
```

**tool result**

```
        """
        assert kind in ('year', 'month', 'week', 'day'), \
            "'kind' must be one of 'year', 'month', 'week', or 'day'."
        assert order in ('ASC', 'DESC'), \
            "'order' must be either 'ASC' or 'DESC'."
        return self.annotate(
            datefield=Trunc(field_name, kind, output_field=DateField()),
            plain_field=F(field_name)
        ).values_list(
            'datefield', flat=True
        ).distinct().filter(plain_field__isnull=False).order_by(('-' if order == 'DESC' else '') + 'datefield')

    def datetimes(self, field_name, kind, order='ASC', tzinfo=None, is_dst=None):
        """
        Return a list of datetime objects representing all available
        datetimes for the given field_name, scoped to 'kind'.
        """
        assert kind in ('year', 'month', 'week', 'day', 'hour', 'minute', 'second'), \
            "'kind' must be one of 'year', 'month', 'week', 'day', 'hour', 'minute', or 'second'."
        assert order in ('ASC', 'DESC'), \
            "'order' must be either 'ASC' or 'DESC'."
        if settings.USE_TZ:
            if tzinfo is None:
                tzinfo = timezone.get_current_timezone()
        else:
            tzinfo = None
        return self.annotate(
            datetimefield=Trunc(
                field_name,
                kind,
                output_field=DateTimeField(),
                tzinfo=tzinfo,
                is_dst=is_dst,
            ),
            plain_field=F(field_name)
        ).values_list(
            'datetimefield', flat=True
        ).distinct().filter(plain_field__isnull=False).order_by(('-' if order == 'DESC' else '') + 'datetimefield')

    def none(self):
        """Return an empty QuerySet."""
        clone = self._chain()
        clone.query.set_empty()
        return clone

    ##################################################################
    # PUBLIC METHODS THAT ALTER ATTRIBUTES AND RETURN A NEW QUERYSET #
    ##################################################################

    def all(self):
        """
        Return a new QuerySet that is a copy of the current one. This allows a
        QuerySet to proxy for a model manager in some cases.
        """
        return self._chain()

    def filter(self, *args, **kwargs):
        """
        Return a new QuerySet instance with the args ANDed to the existing
        set.
        """
        self._not_support_combined_queries('filter')
        return self._filter_or_exclude(False, *args, **kwargs)

    def exclude(self, *args, **kwargs):
        """
        Return a new QuerySet instance with NOT (args) ANDed to the existing
        set.
        """
        self._not_support_combined_queries('exclude')
        return self._filter_or_exclude(True, *args, **kwargs)

    def _filter_or_exclude(self, negate, *args, **kwargs):
        if args or kwargs:
            assert not self.query.is_sliced, \
                "Cannot filter a query once a slice has been taken."

        clone = self._chain()
        if self._defer_next_filter:
            self._defer_next_filter = False
            clone._deferred_filter = negate, args, kwargs
            raise TypeError(
                'QuerySet.%s() received non-expression(s): %s.' % (
                    method_name,
                    ', '.join(invalid_args),
                )
            )

    def _not_support_combined_queries(self, operation_name):
        if self.query.combinator:
            raise NotSupportedError(
                'Calling QuerySet.%s() after %s() is not supported.'
                % (operation_name, self.query.combinator)
            )


class InstanceCheckMeta(type):
    def __instancecheck__(self, instance):
        return isinstance(instance, QuerySet) and instance.query.is_empty()


class EmptyQuerySet(metaclass=InstanceCheckMeta):
    """
    Marker class to checking if a queryset is empty by .none():
        isinstance(qs.none(), EmptyQuerySet) -> True
    """

    def __init__(self, *args, **kwargs):
        raise TypeError("EmptyQuerySet can't be instantiated")


class RawQuerySet:
    """
    Provide an iterator which converts the results of raw SQL queries into
    annotated model instances.
    """
    def __init__(self, raw_query, model=None, query=None, params=None,
                 translations=None, using=None, hints=None):
        self.raw_query = raw_query
        self.model = model
        self._db = using
        self._hints = hints or {}
        self.query = query or sql.RawQuery(sql=raw_query, using=self.db, params=params)
        self.params = params or ()
        self.translations = translations or {}
        self._result_cache = None
        self._prefetch_related_lookups = ()
        self._prefetch_done = False

    def resolve_model_init_order(self):
        """Resolve the init field names and value positions."""
        converter = connections[self.db].introspection.identifier_converter
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def set_empty\\|is_empty\\|combinator\" django/db/models/sql/query.py | head -50"
}
```

**tool result**

```
208:        self.combinator = None
209:        self.combinator_all = False
438:                self.distinct or self.combinator):
1778:    def set_empty(self):
1781:    def is_empty(self):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1770,1790p' django/db/models/sql/query.py && grep -n \"def union\\|def intersection\\|def difference\\|def _combinator_query\" django/db/models/query.py"
}
```

**tool result**

```
            # Note that the end result will be:
            # (outercol NOT IN innerq AND outercol IS NOT NULL) OR outercol IS NULL.
            # This might look crazy but due to how IN works, this seems to be
            # correct. If the IS NOT NULL check is removed then outercol NOT
            # IN will return UNKNOWN. If the IS NULL check is removed, then if
            # outercol IS NULL we will not match the row.
        return condition, needed_inner

    def set_empty(self):
        self.where.add(NothingNode(), AND)

    def is_empty(self):
        return any(isinstance(c, NothingNode) for c in self.where.children)

    def set_limits(self, low=None, high=None):
        """
        Adjust the limits on the rows retrieved. Use low/high to set these,
        as it makes it more Pythonic to read and write. When the SQL query is
        created, convert them to the appropriate offset and limit values.

        Apply any limits passed in here to the existing constraints. Add low
988:    def _combinator_query(self, combinator, *other_qs, all=False):
999:    def union(self, *other_qs, all=False):
1006:    def intersection(self, *other_qs):
1015:    def difference(self, *other_qs):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '980,1030p' django/db/models/query.py && grep -n \"def as_sql\" django/db/models/sql/query.py | head"
}
```

**tool result**

```
        """
        if isinstance(filter_obj, Q):
            clone = self._chain()
            clone.query.add_q(filter_obj)
            return clone
        else:
            return self._filter_or_exclude(False, **filter_obj)

    def _combinator_query(self, combinator, *other_qs, all=False):
        # Clone the query to inherit the select list and everything
        clone = self._chain()
        # Clear limits and ordering so they can be reapplied
        clone.query.clear_ordering(True)
        clone.query.clear_limits()
        clone.query.combined_queries = (self.query,) + tuple(qs.query for qs in other_qs)
        clone.query.combinator = combinator
        clone.query.combinator_all = all
        return clone

    def union(self, *other_qs, all=False):
        # If the query is an EmptyQuerySet, combine all nonempty querysets.
        if isinstance(self, EmptyQuerySet):
            qs = [q for q in other_qs if not isinstance(q, EmptyQuerySet)]
            return qs[0]._combinator_query('union', *qs[1:], all=all) if qs else self
        return self._combinator_query('union', *other_qs, all=all)

    def intersection(self, *other_qs):
        # If any query is an EmptyQuerySet, return it.
        if isinstance(self, EmptyQuerySet):
            return self
        for other in other_qs:
            if isinstance(other, EmptyQuerySet):
                return other
        return self._combinator_query('intersection', *other_qs)

    def difference(self, *other_qs):
        # If the query is an EmptyQuerySet, return it.
        if isinstance(self, EmptyQuerySet):
            return self
        return self._combinator_query('difference', *other_qs)

    def select_for_update(self, nowait=False, skip_locked=False, of=(), no_key=False):
        """
        Return a new QuerySet instance that will select objects with a
        FOR UPDATE lock.
        """
        if nowait and skip_locked:
            raise ValueError('The nowait option cannot be used with skip_locked.')
        obj = self._chain()
        obj._for_write = True
        obj.query.select_for_update = True
1056:    def as_sql(self, compiler, connection):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1056,1140p' django/db/models/sql/query.py"
}
```

**tool result**

```
    def as_sql(self, compiler, connection):
        sql, params = self.get_compiler(connection=connection).as_sql()
        if self.subquery:
            sql = '(%s)' % sql
        return sql, params

    def resolve_lookup_value(self, value, can_reuse, allow_joins):
        if hasattr(value, 'resolve_expression'):
            value = value.resolve_expression(
                self, reuse=can_reuse, allow_joins=allow_joins,
            )
        elif isinstance(value, (list, tuple)):
            # The items of the iterable may be expressions and therefore need
            # to be resolved independently.
            return type(value)(
                self.resolve_lookup_value(sub_value, can_reuse, allow_joins)
                for sub_value in value
            )
        return value

    def solve_lookup_type(self, lookup):
        """
        Solve the lookup type from the lookup (e.g.: 'foobar__id__icontains').
        """
        lookup_splitted = lookup.split(LOOKUP_SEP)
        if self.annotations:
            expression, expression_lookups = refs_expression(lookup_splitted, self.annotations)
            if expression:
                return expression_lookups, (), expression
        _, field, _, lookup_parts = self.names_to_path(lookup_splitted, self.get_meta())
        field_parts = lookup_splitted[0:len(lookup_splitted) - len(lookup_parts)]
        if len(lookup_parts) > 1 and not field_parts:
            raise FieldError(
                'Invalid lookup "%s" for model %s".' %
                (lookup, self.get_meta().model.__name__)
            )
        return lookup_parts, field_parts, False

    def check_query_object_type(self, value, opts, field):
        """
        Check whether the object passed while querying is of the correct type.
        If not, raise a ValueError specifying the wrong object.
        """
        if hasattr(value, '_meta'):
            if not check_rel_lookup_compatibility(value._meta.model, opts, field):
                raise ValueError(
                    'Cannot query "%s": Must be "%s" instance.' %
                    (value, opts.object_name))

    def check_related_objects(self, field, value, opts):
        """Check the type of object passed to query relations."""
        if field.is_relation:
            # Check that the field and the queryset use the same model in a
            # query like .filter(author=Author.objects.all()). For example, the
            # opts would be Author's (from the author field) and value.model
            # would be Author.objects.all() queryset's .model (Author also).
            # The field is the related field on the lhs side.
            if (isinstance(value, Query) and not value.has_select_fields and
                    not check_rel_lookup_compatibility(value.model, opts, field)):
                raise ValueError(
                    'Cannot use QuerySet for "%s": Use a QuerySet for "%s".' %
                    (value.model._meta.object_name, opts.object_name)
                )
            elif hasattr(value, '_meta'):
                self.check_query_object_type(value, opts, field)
            elif hasattr(value, '__iter__'):
                for v in value:
                    self.check_query_object_type(v, opts, field)

    def check_filterable(self, expression):
        """Raise an error if expression cannot be used in a WHERE clause."""
        if (
            hasattr(expression, 'resolve_expression') and
            not getattr(expression, 'filterable', True)
        ):
            raise NotSupportedError(
                expression.__class__.__name__ + ' is disallowed in the filter '
                'clause.'
            )
        if hasattr(expression, 'get_source_expressions'):
            for expr in expression.get_source_expressions():
                self.check_filterable(expr)

    def build_lookup(self, lookups, lhs, rhs):
        """
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"combinator\" django/db/models/sql/compiler.py"
}
```

**tool result**

```
362:            if self.query.combinator:
433:    def get_combinator_sql(self, combinator, all):
459:                if compiler.query.combinator:
472:                if combinator == 'union' or (combinator == 'difference' and parts):
477:        combinator_sql = self.connection.ops.set_operators[combinator]
478:        if all and combinator == 'union':
479:            combinator_sql += ' ALL'
482:        result = [' {} '.format(combinator_sql).join(sql_parts)]
502:            combinator = self.query.combinator
504:            if combinator:
505:                if not getattr(features, 'supports_select_{}'.format(combinator)):
506:                    raise NotSupportedError('{} is not supported on this database backend.'.format(combinator))
507:                result, params = self.get_combinator_sql(combinator, self.query.combinator_all)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '330,520p' django/db/models/sql/compiler.py"
}
```

**tool result**

```
                continue

            if '.' in field:
                # This came in through an extra(order_by=...) addition. Pass it
                # on verbatim.
                table, col = col.split('.', 1)
                order_by.append((
                    OrderBy(
                        RawSQL('%s.%s' % (self.quote_name_unless_alias(table), col), []),
                        descending=descending
                    ), False))
                continue

            if not self.query.extra or col not in self.query.extra:
                # 'col' is of the form 'field' or 'field1__field2' or
                # '-field1__field2__field', etc.
                order_by.extend(self.find_ordering_name(
                    field, self.query.get_meta(), default_order=asc))
            else:
                if col not in self.query.extra_select:
                    order_by.append((
                        OrderBy(RawSQL(*self.query.extra[col]), descending=descending),
                        False))
                else:
                    order_by.append((
                        OrderBy(Ref(col, RawSQL(*self.query.extra[col])), descending=descending),
                        True))
        result = []
        seen = set()

        for expr, is_ref in order_by:
            resolved = expr.resolve_expression(self.query, allow_joins=True, reuse=None)
            if self.query.combinator:
                src = resolved.get_source_expressions()[0]
                expr_src = expr.get_source_expressions()[0]
                # Relabel order by columns to raw numbers if this is a combined
                # query; necessary since the columns can't be referenced by the
                # fully qualified name and the simple column names may collide.
                for idx, (sel_expr, _, col_alias) in enumerate(self.select):
                    if is_ref and col_alias == src.refs:
                        src = src.source
                    elif col_alias and not (
                        isinstance(expr_src, F) and col_alias == expr_src.name
                    ):
                        continue
                    if src == sel_expr:
                        resolved.set_source_expressions([RawSQL('%d' % (idx + 1), ())])
                        break
                else:
                    if col_alias:
                        raise DatabaseError('ORDER BY term does not match any column in the result set.')
                    # Add column used in ORDER BY clause without an alias to
                    # the selected columns.
                    self.query.add_select_col(src)
                    resolved.set_source_expressions([RawSQL('%d' % len(self.query.select), ())])
            sql, params = self.compile(resolved)
            # Don't add the same column twice, but the order direction is
            # not taken into account so we strip it. When this entire method
            # is refactored into expressions, then we can check each part as we
            # generate it.
            without_ordering = self.ordering_parts.search(sql)[1]
            params_hash = make_hashable(params)
            if (without_ordering, params_hash) in seen:
                continue
            seen.add((without_ordering, params_hash))
            result.append((resolved, (sql, params, is_ref)))
        return result

    def get_extra_select(self, order_by, select):
        extra_select = []
        if self.query.distinct and not self.query.distinct_fields:
            select_sql = [t[1] for t in select]
            for expr, (sql, params, is_ref) in order_by:
                without_ordering = self.ordering_parts.search(sql)[1]
                if not is_ref and (without_ordering, params) not in select_sql:
                    extra_select.append((expr, (without_ordering, params), None))
        return extra_select

    def quote_name_unless_alias(self, name):
        """
        A wrapper around connection.ops.quote_name that doesn't quote aliases
        for table names. This avoids problems with some SQL dialects that treat
        quoted strings specially (e.g. PostgreSQL).
        """
        if name in self.quote_cache:
            return self.quote_cache[name]
        if ((name in self.query.alias_map and name not in self.query.table_map) or
                name in self.query.extra_select or (
                    self.query.external_aliases.get(name) and name not in self.query.table_map)):
            self.quote_cache[name] = name
            return name
        r = self.connection.ops.quote_name(name)
        self.quote_cache[name] = r
        return r

    def compile(self, node):
        vendor_impl = getattr(node, 'as_' + self.connection.vendor, None)
        if vendor_impl:
            sql, params = vendor_impl(self, self.connection)
        else:
            sql, params = node.as_sql(self, self.connection)
        return sql, params

    def get_combinator_sql(self, combinator, all):
        features = self.connection.features
        compilers = [
            query.get_compiler(self.using, self.connection)
            for query in self.query.combined_queries if not query.is_empty()
        ]
        if not features.supports_slicing_ordering_in_compound:
            for query, compiler in zip(self.query.combined_queries, compilers):
                if query.low_mark or query.high_mark:
                    raise DatabaseError('LIMIT/OFFSET not allowed in subqueries of compound statements.')
                if compiler.get_order_by():
                    raise DatabaseError('ORDER BY not allowed in subqueries of compound statements.')
        parts = ()
        for compiler in compilers:
            try:
                # If the columns list is limited, then all combined queries
                # must have the same columns list. Set the selects defined on
                # the query on all combined queries, if not already set.
                if not compiler.query.values_select and self.query.values_select:
                    compiler.query = compiler.query.clone()
                    compiler.query.set_values((
                        *self.query.extra_select,
                        *self.query.values_select,
                        *self.query.annotation_select,
                    ))
                part_sql, part_args = compiler.as_sql()
                if compiler.query.combinator:
                    # Wrap in a subquery if wrapping in parentheses isn't
                    # supported.
                    if not features.supports_parentheses_in_compound:
                        part_sql = 'SELECT * FROM ({})'.format(part_sql)
                    # Add parentheses when combining with compound query if not
                    # already added for all compound queries.
                    elif not features.supports_slicing_ordering_in_compound:
                        part_sql = '({})'.format(part_sql)
                parts += ((part_sql, part_args),)
            except EmptyResultSet:
                # Omit the empty queryset with UNION and with DIFFERENCE if the
                # first queryset is nonempty.
                if combinator == 'union' or (combinator == 'difference' and parts):
                    continue
                raise
        if not parts:
            raise EmptyResultSet
        combinator_sql = self.connection.ops.set_operators[combinator]
        if all and combinator == 'union':
            combinator_sql += ' ALL'
        braces = '({})' if features.supports_slicing_ordering_in_compound else '{}'
        sql_parts, args_parts = zip(*((braces.format(sql), args) for sql, args in parts))
        result = [' {} '.format(combinator_sql).join(sql_parts)]
        params = []
        for part in args_parts:
            params.extend(part)
        return result, params

    def as_sql(self, with_limits=True, with_col_aliases=False):
        """
        Create the SQL for this query. Return the SQL string and list of
        parameters.

        If 'with_limits' is False, any limit/offset information is not included
        in the query.
        """
        refcounts_before = self.query.alias_refcount.copy()
        try:
            extra_select, order_by, group_by = self.pre_sql_setup()
            for_update_part = None
            # Is a LIMIT/OFFSET clause needed?
            with_limit_offset = with_limits and (self.query.high_mark is not None or self.query.low_mark)
            combinator = self.query.combinator
            features = self.connection.features
            if combinator:
                if not getattr(features, 'supports_select_{}'.format(combinator)):
                    raise NotSupportedError('{} is not supported on this database backend.'.format(combinator))
                result, params = self.get_combinator_sql(combinator, self.query.combinator_all)
            else:
                distinct_fields, distinct_params = self.get_distinct()
                # This must come after 'select', 'ordering', and 'distinct'
                # (see docstring of get_from_clause() for details).
                from_, f_params = self.get_from_clause()
                where, w_params = self.compile(self.where) if self.where is not None else ("", [])
                having, h_params = self.compile(self.having) if self.having is not None else ("", [])
                result = ['SELECT']
                params = []

                if self.query.distinct:
                    distinct_result, distinct_params = self.connection.ops.distinct_sql(
                        distinct_fields,
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -5 && grep -R \"none() on combined\\|combined.*none\\|none.*combinator\" -n tests django | head -30"
}
```

**tool result**

```
40c9706b35 SWE-bench
7af8f41273 Refs #26445 -- Allowed using UserManager.create_user()/create_superuser() in migrations.
d1409f51ff Fixed #31732 -- Cached callables signatures in django.utils.inspect methods.
512da9d585 Fixed #23797 -- Fixed QuerySet.exclude() when rhs is a nullable column.
b7b7df5fbc Fixed #31530 -- Added system checks for invalid model field names in CheckConstraint.check and UniqueConstraint.condition.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -R \"\\.none()\" -n tests/queries tests/queryset_pickle tests/forms_tests 2>/dev/null | head -40; grep -R \"union(.*none\\|none().*union\\|combined\" -n tests/queries | head -40"
}
```

**tool result**

```
tests/queries/test_qs_combinators.py:57:        qs2 = Number.objects.none()
tests/queries/test_qs_combinators.py:69:        qs2 = Number.objects.none()
tests/queries/test_qs_combinators.py:82:        qs2 = ReservedName.objects.none()
tests/queries/test_qs_combinators.py:91:        qs2 = Number.objects.none()
tests/queries/tests.py:722:        q = Eaten.objects.none()
tests/queries/tests.py:842:            Note.objects.none() | Note.objects.all(),
tests/queries/tests.py:846:            Note.objects.all() | Note.objects.none(),
tests/queries/tests.py:849:        self.assertQuerysetEqual(Note.objects.none() & Note.objects.all(), [])
tests/queries/tests.py:850:        self.assertQuerysetEqual(Note.objects.all() & Note.objects.none(), [])
tests/queries/tests.py:2070:        self.assertIs(Annotation.objects.none().ordered, True)
tests/queries/tests.py:2257:        self.assertCountEqual(Number.objects.none().values('num').order_by('num'), [])
tests/queries/tests.py:2260:        self.assertCountEqual(Number.objects.filter(pk__in=Number.objects.none().values('pk')), [])
tests/queries/tests.py:2261:        self.assertCountEqual(Number.objects.filter(pk__in=Number.objects.none().values_list('pk')), [])
tests/queries/tests.py:2266:        q = Author.objects.none()
tests/queryset_pickle/tests.py:283:            reloaded_events = Event.objects.none()
tests/queryset_pickle/tests.py:296:            reloaded_events = Event.objects.none()
tests/queries/test_qs_combinators.py:289:    def test_unsupported_operations_on_combined_qs(self):
tests/queries/tests.py:278:        combined_query = (q1 & q2).order_by('name').query
tests/queries/tests.py:280:            t for t in combined_query.alias_map if combined_query.alias_refcount[t]
tests/queries/tests.py:1088:        # Querying with combined q-objects should also strip the left outer join
tests/queries/tests.py:1425:        combined = q1 | q2
tests/queries/tests.py:1426:        self.assertEqual(str(combined.query).count('JOIN'), 2)
tests/queries/tests.py:1427:        self.assertEqual(len(combined), 1)
tests/queries/tests.py:1428:        self.assertEqual(combined[0].name, 'a1')
tests/queries/tests.py:2390:        qs = Number.objects.annotate(combinedexpression1=expr).values_list(expr, 'combinedexpression1', named=True)
tests/queries/tests.py:2392:        self.assertEqual(values._fields, ('combinedexpression2', 'combinedexpression1'))
```

**assistant → tool `bash`**

```json
{
  "command": "grep -R \"none.*combined\\|combined.*none\" -n docs/releases docs | head -20"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,130p' tests/queries/test_qs_combinators.py && sed -n '260,340p' tests/queries/test_qs_combinators.py"
}
```

**tool result**

```
import operator

from django.db import DatabaseError, NotSupportedError, connection
from django.db.models import Exists, F, IntegerField, OuterRef, Value
from django.test import TestCase, skipIfDBFeature, skipUnlessDBFeature

from .models import Number, ReservedName


@skipUnlessDBFeature('supports_select_union')
class QuerySetSetOperationTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        Number.objects.bulk_create(Number(num=i, other_num=10 - i) for i in range(10))

    def assertNumbersEqual(self, queryset, expected_numbers, ordered=True):
        self.assertQuerysetEqual(queryset, expected_numbers, operator.attrgetter('num'), ordered)

    def test_simple_union(self):
        qs1 = Number.objects.filter(num__lte=1)
        qs2 = Number.objects.filter(num__gte=8)
        qs3 = Number.objects.filter(num=5)
        self.assertNumbersEqual(qs1.union(qs2, qs3), [0, 1, 5, 8, 9], ordered=False)

    @skipUnlessDBFeature('supports_select_intersection')
    def test_simple_intersection(self):
        qs1 = Number.objects.filter(num__lte=5)
        qs2 = Number.objects.filter(num__gte=5)
        qs3 = Number.objects.filter(num__gte=4, num__lte=6)
        self.assertNumbersEqual(qs1.intersection(qs2, qs3), [5], ordered=False)

    @skipUnlessDBFeature('supports_select_intersection')
    def test_intersection_with_values(self):
        ReservedName.objects.create(name='a', order=2)
        qs1 = ReservedName.objects.all()
        reserved_name = qs1.intersection(qs1).values('name', 'order', 'id').get()
        self.assertEqual(reserved_name['name'], 'a')
        self.assertEqual(reserved_name['order'], 2)
        reserved_name = qs1.intersection(qs1).values_list('name', 'order', 'id').get()
        self.assertEqual(reserved_name[:2], ('a', 2))

    @skipUnlessDBFeature('supports_select_difference')
    def test_simple_difference(self):
        qs1 = Number.objects.filter(num__lte=5)
        qs2 = Number.objects.filter(num__lte=4)
        self.assertNumbersEqual(qs1.difference(qs2), [5], ordered=False)

    def test_union_distinct(self):
        qs1 = Number.objects.all()
        qs2 = Number.objects.all()
        self.assertEqual(len(list(qs1.union(qs2, all=True))), 20)
        self.assertEqual(len(list(qs1.union(qs2))), 10)

    @skipUnlessDBFeature('supports_select_intersection')
    def test_intersection_with_empty_qs(self):
        qs1 = Number.objects.all()
        qs2 = Number.objects.none()
        qs3 = Number.objects.filter(pk__in=[])
        self.assertEqual(len(qs1.intersection(qs2)), 0)
        self.assertEqual(len(qs1.intersection(qs3)), 0)
        self.assertEqual(len(qs2.intersection(qs1)), 0)
        self.assertEqual(len(qs3.intersection(qs1)), 0)
        self.assertEqual(len(qs2.intersection(qs2)), 0)
        self.assertEqual(len(qs3.intersection(qs3)), 0)

    @skipUnlessDBFeature('supports_select_difference')
    def test_difference_with_empty_qs(self):
        qs1 = Number.objects.all()
        qs2 = Number.objects.none()
        qs3 = Number.objects.filter(pk__in=[])
        self.assertEqual(len(qs1.difference(qs2)), 10)
        self.assertEqual(len(qs1.difference(qs3)), 10)
        self.assertEqual(len(qs2.difference(qs1)), 0)
        self.assertEqual(len(qs3.difference(qs1)), 0)
        self.assertEqual(len(qs2.difference(qs2)), 0)
        self.assertEqual(len(qs3.difference(qs3)), 0)

    @skipUnlessDBFeature('supports_select_difference')
    def test_difference_with_values(self):
        ReservedName.objects.create(name='a', order=2)
        qs1 = ReservedName.objects.all()
        qs2 = ReservedName.objects.none()
        reserved_name = qs1.difference(qs2).values('name', 'order', 'id').get()
        self.assertEqual(reserved_name['name'], 'a')
        self.assertEqual(reserved_name['order'], 2)
        reserved_name = qs1.difference(qs2).values_list('name', 'order', 'id').get()
        self.assertEqual(reserved_name[:2], ('a', 2))

    def test_union_with_empty_qs(self):
        qs1 = Number.objects.all()
        qs2 = Number.objects.none()
        qs3 = Number.objects.filter(pk__in=[])
        self.assertEqual(len(qs1.union(qs2)), 10)
        self.assertEqual(len(qs2.union(qs1)), 10)
        self.assertEqual(len(qs1.union(qs3)), 10)
        self.assertEqual(len(qs3.union(qs1)), 10)
        self.assertEqual(len(qs2.union(qs1, qs1, qs1)), 10)
        self.assertEqual(len(qs2.union(qs1, qs1, all=True)), 20)
        self.assertEqual(len(qs2.union(qs2)), 0)
        self.assertEqual(len(qs3.union(qs3)), 0)

    def test_limits(self):
        qs1 = Number.objects.all()
        qs2 = Number.objects.all()
        self.assertEqual(len(list(qs1.union(qs2)[:2])), 2)

    def test_ordering(self):
        qs1 = Number.objects.filter(num__lte=1)
        qs2 = Number.objects.filter(num__gte=2, num__lte=3)
        self.assertNumbersEqual(qs1.union(qs2).order_by('-num'), [3, 2, 1, 0])

    def test_ordering_by_alias(self):
        qs1 = Number.objects.filter(num__lte=1).values(alias=F('num'))
        qs2 = Number.objects.filter(num__gte=2, num__lte=3).values(alias=F('num'))
        self.assertQuerysetEqual(
            qs1.union(qs2).order_by('-alias'),
            [3, 2, 1, 0],
            operator.itemgetter('alias'),
        )

    def test_ordering_by_f_expression(self):
        qs1 = Number.objects.filter(num__lte=1)
        qs2 = Number.objects.filter(num__gte=2, num__lte=3)
        self.assertNumbersEqual(qs1.union(qs2).order_by(F('num').desc()), [3, 2, 1, 0])

    def test_ordering_by_f_expression_and_alias(self):
        qs1 = Number.objects.filter(num__lte=1).values(alias=F('other_num'))
        qs2 = Number.objects.filter(num__gte=2, num__lte=3).values(alias=F('other_num'))
        self.assertQuerysetEqual(
            qs1.union(qs2).order_by(F('alias').desc()),
        list(qs1.union(qs2).order_by('annotation'))
        list(qs1.union(qs2).order_by('num2'))
        msg = 'ORDER BY term does not match any column in the result set'
        # 'id' is not part of the select
        with self.assertRaisesMessage(DatabaseError, msg):
            list(qs1.union(qs2).order_by('id'))
        # 'num' got realiased to num2
        with self.assertRaisesMessage(DatabaseError, msg):
            list(qs1.union(qs2).order_by('num'))
        with self.assertRaisesMessage(DatabaseError, msg):
            list(qs1.union(qs2).order_by(F('num')))
        with self.assertRaisesMessage(DatabaseError, msg):
            list(qs1.union(qs2).order_by(F('num').desc()))
        # switched order, now 'exists' again:
        list(qs2.union(qs1).order_by('num'))

    @skipUnlessDBFeature('supports_select_difference', 'supports_select_intersection')
    def test_qs_with_subcompound_qs(self):
        qs1 = Number.objects.all()
        qs2 = Number.objects.intersection(Number.objects.filter(num__gt=1))
        self.assertEqual(qs1.difference(qs2).count(), 2)

    def test_order_by_same_type(self):
        qs = Number.objects.all()
        union = qs.union(qs)
        numbers = list(range(10))
        self.assertNumbersEqual(union.order_by('num'), numbers)
        self.assertNumbersEqual(union.order_by('other_num'), reversed(numbers))

    def test_unsupported_operations_on_combined_qs(self):
        qs = Number.objects.all()
        msg = 'Calling QuerySet.%s() after %s() is not supported.'
        combinators = ['union']
        if connection.features.supports_select_difference:
            combinators.append('difference')
        if connection.features.supports_select_intersection:
            combinators.append('intersection')
        for combinator in combinators:
            for operation in (
                'annotate',
                'defer',
                'delete',
                'distinct',
                'exclude',
                'extra',
                'filter',
                'only',
                'prefetch_related',
                'select_related',
                'update',
            ):
                with self.subTest(combinator=combinator, operation=operation):
                    with self.assertRaisesMessage(
                        NotSupportedError,
                        msg % (operation, combinator),
                    ):
                        getattr(getattr(qs, combinator)(qs), operation)()
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"combined_queries\" django/db/models/sql/query.py | head -20"
}
```

**tool result**

```
210:        self.combined_queries = ()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/sql/query.py\n@@\n     def set_empty(self):\n         self.where.add(NothingNode(), AND)\n+        for query in self.combined_queries:\n+            query.set_empty()\n*** Update File: tests/queries/test_qs_combinators.py\n@@\n     def test_union_with_empty_qs(self):\n         qs1 = Number.objects.all()\n         qs2 = Number.objects.none()\n         qs3 = Number.objects.filter(pk__in=[])\n         self.assertEqual(len(qs1.union(qs2)), 10)\n@@\n         self.assertEqual(len(qs2.union(qs2)), 0)\n         self.assertEqual(len(qs3.union(qs3)), 0)\n \n+    def test_none(self):\n+        qs = Number.objects.all()\n+        self.assertNumbersEqual(qs.union(qs).none(), [])\n+\n     def test_limits(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/sql/query.py tests/queries/test_qs_combinators.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/sql/query.py now (2426 lines), around the change:
1777:
1778:    def set_empty(self):
1779:        self.where.add(NothingNode(), AND)
1780:        for query in self.combined_queries:
1781:            query.set_empty()
1782:
1783:    def is_empty(self):
1784:        return any(isinstance(c, NothingNode) for c in self.where.children)

tests/queries/test_qs_combinators.py now (320 lines), around the change:
98:        self.assertEqual(len(qs2.union(qs1, qs1, all=True)), 20)
99:        self.assertEqual(len(qs2.union(qs2)), 0)
100:        self.assertEqual(len(qs3.union(qs3)), 0)
101:
102:    def test_none(self):
103:        qs = Number.objects.all()
104:        self.assertNumbersEqual(qs.union(qs).none(), [])
105:
106:    def test_limits(self):
107:        qs1 = Number.objects.all()
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.test_qs_combinators -v 2 2>&1 | tail -40"
}
```

**tool result**

```
    Creating table queries_program
    Creating table queries_channel
    Creating table queries_book
    Creating table queries_chapter
    Creating table queries_paragraph
    Creating table queries_page
    Creating table queries_myobject
    Creating table queries_order
    Creating table queries_orderitem
    Creating table queries_baseuser
    Creating table queries_task
    Creating table queries_staff
    Creating table queries_staffuser
    Creating table queries_ticket21203parent
    Creating table queries_ticket21203child
    Creating table queries_person
    Creating table queries_company
    Creating table queries_employment
    Creating table queries_school
    Creating table queries_student
    Creating table queries_classroom
    Creating table queries_teacher
    Creating table queries_ticket23605aparent
    Creating table queries_ticket23605a
    Creating table queries_ticket23605b
    Creating table queries_ticket23605c
    Creating table Individual
    Creating table RelatedIndividual
    Creating table queries_customdbcolumn
    Creating table queries_returningmodel
    Creating table queries_nonintegerpkreturningmodel
    Creating table queries_jsonfieldnullable
    Running deferred SQL...
Running migrations:
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying sites.0001_initial... OK
  Applying sites.0002_alter_domain_unique... OK
System check identified no issues (1 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.test_qs_combinators 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
.................s...........s..
----------------------------------------------------------------------
Ran 32 tests in 0.069s

OK (skipped=2)
Destroying test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries 2>&1 | tail -15"
}
```

**tool result**

```
Cloning test database for alias 'default'...
sssss.......sss................s..s...................x.........x...................................................................................s.........................................................................................................................s...........s..........................................................................................................
----------------------------------------------------------------------
Ran 389 tests in 0.759s

OK (skipped=13, expected failures=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def clean\" -A 30 django/forms/models.py | grep -n \"none\\|def clean\" | head; grep -n \"class ModelMultipleChoiceField\" -A 80 django/forms/models.py | grep -n \"none\\|clean\""
}
```

**tool result**

```
1:351:    def clean(self):
33:677:    def clean(self):
65:1116:    def clean(self, value):
97:1321:    def clean(self, value):
102:1326-            return self.queryset.none()
27:1321-    def clean(self, value):
32:1326-            return self.queryset.none()
39:1333-        # Since this overrides the inherited ModelChoiceField.clean
```

**assistant → tool `bash`**

```json
{
  "command": "git diff --stat && git status --porcelain -- . ':(exclude).memdoor' && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS"
}
```

**tool result**

```
 django/db/models/sql/query.py        | 2 ++
 tests/queries/test_qs_combinators.py | 4 ++++
 2 files changed, 6 insertions(+)
 M django/db/models/sql/query.py
 M tests/queries/test_qs_combinators.py
PASS
```

**assistant**

```
Fixed. `Query.set_empty()` now propagates emptiness to all combined queries, so `QuerySet.none()` on a `union()`/`intersection()`/`difference()` result correctly yields no rows instead of falling back to the combined query's results.

Added a regression test (`test_none` in `tests/queries/test_qs_combinators.py`). The full `queries` test suite passes (389 tests, 13 skipped, 2 expected failures), and the completion command exits 0.
```

## Run folder `single-2026-11-06T171801`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
QuerySet.none() on combined queries returns all results.
Description
	
I came across this issue on Stack Overflow. I'm not 100% sure it's a bug, but it does seem strange. With this code (excuse the bizarre example filtering):
class Publication(models.Model):
	pass
class Article(models.Model):
	publications = models.ManyToManyField(to=Publication, blank=True, null=True)
class ArticleForm(forms.ModelForm):
	publications = forms.ModelMultipleChoiceField(
		Publication.objects.filter(id__lt=2) | Publication.objects.filter(id__gt=5),
		required=False,
	)
	class Meta:
		model = Article
		fields = ["publications"]
class ArticleAdmin(admin.ModelAdmin):
	form = ArticleForm
This works well. However, changing the ModelMultipleChoiceField queryset to use union() breaks things.
publications = forms.ModelMultipleChoiceField(
	Publication.objects.filter(id__lt=2).union(
		Publication.objects.filter(id__gt=5)
	),
	required=False,
)
The form correctly shows only the matching objects. However, if you submit this form while empty (i.e. you didn't select any publications), ALL objects matching the queryset will be added. Using the OR query, NO objects are added, as I'd expect.
```
