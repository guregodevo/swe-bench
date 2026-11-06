# django__django-11490 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 48s 29 lines cost=0.001895 in=144377 cached=132096 out=2740 calls=15`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Composed queries cannot change the list of columns with values()/values_list().
Description
	
Composed queries cannot change the list of columns when values()/values_list() is evaluated multiple times, e.g.
>>> ReservedName.objects.create(name='a', order=2)
>>> qs1 = ReservedName.objects.all()
>>> print(qs1.union(qs1).values_list('name', 'order').get())
('a', 2)
>>> print(qs1.union(qs1).values_list('order').get())
('a', 2)
(see ​compiler.py#L428-L433).

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && git log --oneline -3"
}
```

**tool result**

```
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
1fb7f8c059 SWE-bench
a7038adbd0 Fixed typos in signals and custom management commands docs.
036362e0cf Fixed typos and example in signals.pre_init docs.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '380,470p' django/db/models/sql/compiler.py"
}
```

**tool result**

```
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
                    name in self.query.external_aliases and name not in self.query.table_map)):
            self.quote_cache[name] = name
            return name
        r = self.connection.ops.quote_name(name)
        self.quote_cache[name] = r
        return r

    def compile(self, node, select_format=False):
        vendor_impl = getattr(node, 'as_' + self.connection.vendor, None)
        if vendor_impl:
            sql, params = vendor_impl(self, self.connection)
        else:
            sql, params = node.as_sql(self, self.connection)
        if select_format is FORCE or (select_format and not self.query.subquery):
            return node.output_field.select_format(self, sql, params)
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
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"values_list.*union\\|union.*values_list\\|combinator\" tests/queries/test_qs_combinators.py | head -50"
}
```

**tool result**

```
124:        reserved_name = qs1.union(qs1).values_list('name', 'order', 'id').get()
127:    def test_union_with_two_annotated_values_list(self):
138:    def test_union_with_extra_and_values_list(self):
145:    def test_union_with_values_list_on_annotated_and_unannotated(self):
151:        self.assertCountEqual(qs1.union(qs2).values_list('num', flat=True), [1, 9])
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,180p' tests/queries/test_qs_combinators.py"
}
```

**tool result**

```
from django.db.models import Exists, F, IntegerField, OuterRef, Value
from django.db.utils import DatabaseError, NotSupportedError
from django.test import TestCase, skipIfDBFeature, skipUnlessDBFeature

from .models import Number, ReservedName


@skipUnlessDBFeature('supports_select_union')
class QuerySetSetOperationTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        Number.objects.bulk_create(Number(num=i) for i in range(10))

    def number_transform(self, value):
        return value.num

    def assertNumbersEqual(self, queryset, expected_numbers, ordered=True):
        self.assertQuerysetEqual(queryset, expected_numbers, self.number_transform, ordered)

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

    def test_ordering_by_f_expression(self):
        qs1 = Number.objects.filter(num__lte=1)
        qs2 = Number.objects.filter(num__gte=2, num__lte=3)
        self.assertNumbersEqual(qs1.union(qs2).order_by(F('num').desc()), [3, 2, 1, 0])

    def test_union_with_values(self):
        ReservedName.objects.create(name='a', order=2)
        qs1 = ReservedName.objects.all()
        reserved_name = qs1.union(qs1).values('name', 'order', 'id').get()
        self.assertEqual(reserved_name['name'], 'a')
        self.assertEqual(reserved_name['order'], 2)
        reserved_name = qs1.union(qs1).values_list('name', 'order', 'id').get()
        self.assertEqual(reserved_name[:2], ('a', 2))

    def test_union_with_two_annotated_values_list(self):
        qs1 = Number.objects.filter(num=1).annotate(
            count=Value(0, IntegerField()),
        ).values_list('num', 'count')
        qs2 = Number.objects.filter(num=2).values('pk').annotate(
            count=F('num'),
        ).annotate(
            num=Value(1, IntegerField()),
        ).values_list('num', 'count')
        self.assertCountEqual(qs1.union(qs2), [(1, 0), (2, 1)])

    def test_union_with_extra_and_values_list(self):
        qs1 = Number.objects.filter(num=1).extra(
            select={'count': 0},
        ).values_list('num', 'count')
        qs2 = Number.objects.filter(num=2).extra(select={'count': 1})
        self.assertCountEqual(qs1.union(qs2), [(1, 0), (2, 1)])

    def test_union_with_values_list_on_annotated_and_unannotated(self):
        ReservedName.objects.create(name='rn1', order=1)
        qs1 = Number.objects.annotate(
            has_reserved_name=Exists(ReservedName.objects.filter(order=OuterRef('num')))
        ).filter(has_reserved_name=True)
        qs2 = Number.objects.filter(num=9)
        self.assertCountEqual(qs1.union(qs2).values_list('num', flat=True), [1, 9])

    def test_count_union(self):
        qs1 = Number.objects.filter(num__lte=1).values('num')
        qs2 = Number.objects.filter(num__gte=2, num__lte=3).values('num')
        self.assertEqual(qs1.union(qs2).count(), 4)

    def test_count_union_empty_result(self):
        qs = Number.objects.filter(pk__in=[])
        self.assertEqual(qs.union(qs).count(), 0)

    @skipUnlessDBFeature('supports_select_difference')
    def test_count_difference(self):
        qs1 = Number.objects.filter(num__lt=10)
        qs2 = Number.objects.filter(num__lt=9)
        self.assertEqual(qs1.difference(qs2).count(), 1)

    @skipUnlessDBFeature('supports_select_intersection')
    def test_count_intersection(self):
        qs1 = Number.objects.filter(num__gte=5)
        qs2 = Number.objects.filter(num__lte=5)
        self.assertEqual(qs1.intersection(qs2).count(), 1)

    @skipUnlessDBFeature('supports_slicing_ordering_in_compound')
    def test_ordering_subqueries(self):
        qs1 = Number.objects.order_by('num')[:2]
        qs2 = Number.objects.order_by('-num')[:2]
        self.assertNumbersEqual(qs1.union(qs2).order_by('-num')[:4], [9, 8, 1, 0])

    @skipIfDBFeature('supports_slicing_ordering_in_compound')
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def set_values\\|def clone\" django/db/models/sql/query.py | head"
}
```

**tool result**

```
95:    def clone(self, using):
292:    def clone(self):
2030:    def set_values(self, fields):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '2030,2090p' django/db/models/sql/query.py; grep -n \"def values\\|def values_list\\|_values\" django/db/models/query.py | head -30"
}
```

**tool result**

```
    def set_values(self, fields):
        self.select_related = False
        self.clear_deferred_loading()
        self.clear_select_fields()

        if self.group_by is True:
            self.add_fields((f.attname for f in self.model._meta.concrete_fields), False)
            self.set_group_by()
            self.clear_select_fields()

        if fields:
            field_names = []
            extra_names = []
            annotation_names = []
            if not self.extra and not self.annotations:
                # Shortcut - if there are no extra or annotations, then
                # the values() clause must be just field names.
                field_names = list(fields)
            else:
                self.default_cols = False
                for f in fields:
                    if f in self.extra_select:
                        extra_names.append(f)
                    elif f in self.annotation_select:
                        annotation_names.append(f)
                    else:
                        field_names.append(f)
            self.set_extra_mask(extra_names)
            self.set_annotation_mask(annotation_names)
        else:
            field_names = [f.attname for f in self.model._meta.concrete_fields]

        self.values_select = tuple(field_names)
        self.add_fields(field_names, True)

    @property
    def annotation_select(self):
        """
        Return the dictionary of aggregate columns that are not masked and
        should be used in the SELECT clause. Cache this result for performance.
        """
        if self._annotation_select_cache is not None:
            return self._annotation_select_cache
        elif not self.annotations:
            return {}
        elif self.annotation_select_mask is not None:
            self._annotation_select_cache = {
                k: v for k, v in self.annotations.items()
                if k in self.annotation_select_mask
            }
            return self._annotation_select_cache
        else:
            return self.annotations

    @property
    def extra_select(self):
        if self._extra_select_cache is not None:
            return self._extra_select_cache
        if not self.extra:
            return {}
        elif self.extra_select_mask is not None:
365:        self._validate_values_are_expressions((*args, *kwargs.values()), method_name='aggregate')
433:    def _populate_pk_values(self, objs):
472:        self._populate_pk_values(objs)
735:        query.add_update_values(kwargs)
786:    def _values(self, *fields, **expressions):
791:        clone.query.set_values(fields)
794:    def values(self, *fields, **expressions):
796:        clone = self._values(*fields, **expressions)
800:    def values_list(self, *fields, flat=False, named=False):
823:        clone = self._values(*_fields, **expressions)
1025:        self._validate_values_are_expressions(args + tuple(kwargs.values()), method_name='annotate')
1183:        query.insert_values(fields, objs, raw=raw)
1302:    def _validate_values_are_expressions(values, method_name):
1418:                model_init_values = [values[pos] for pos in model_init_pos]
1419:                instance = model_cls.from_db(db, model_init_names, model_init_values)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def _combinator_query\\|def union\\|combined_queries\" django/db/models/query.py | head -20; sed -n '1120,1180p' django/db/models/query.py"
}
```

**tool result**

```
928:    def _combinator_query(self, combinator, *other_qs, all=False):
934:        clone.query.combined_queries = (self.query,) + tuple(qs.query for qs in other_qs)
939:    def union(self, *other_qs, all=False):
        Essentially, the opposite of defer(). Only the fields passed into this
        method and that are not already specified as deferred are loaded
        immediately when the queryset is evaluated.
        """
        if self._fields is not None:
            raise TypeError("Cannot call only() after .values() or .values_list()")
        if fields == (None,):
            # Can only pass None to defer(), not only(), as the rest option.
            # That won't stop people trying to do this, so let's be explicit.
            raise TypeError("Cannot pass None as an argument to only().")
        for field in fields:
            field = field.split(LOOKUP_SEP, 1)[0]
            if field in self.query._filtered_relations:
                raise ValueError('only() is not supported with FilteredRelation.')
        clone = self._chain()
        clone.query.add_immediate_loading(fields)
        return clone

    def using(self, alias):
        """Select which database this QuerySet should execute against."""
        clone = self._chain()
        clone._db = alias
        return clone

    ###################################
    # PUBLIC INTROSPECTION ATTRIBUTES #
    ###################################

    @property
    def ordered(self):
        """
        Return True if the QuerySet is ordered -- i.e. has an order_by()
        clause or a default ordering on the model (or is empty).
        """
        if isinstance(self, EmptyQuerySet):
            return True
        if self.query.extra_order_by or self.query.order_by:
            return True
        elif self.query.default_ordering and self.query.get_meta().ordering:
            return True
        else:
            return False

    @property
    def db(self):
        """Return the database used if this query is executed now."""
        if self._for_write:
            return self._db or router.db_for_write(self.model, **self._hints)
        return self._db or router.db_for_read(self.model, **self._hints)

    ###################
    # PRIVATE METHODS #
    ###################

    def _insert(self, objs, fields, return_id=False, raw=False, using=None, ignore_conflicts=False):
        """
        Insert a new record for the given model. This provides an interface to
        the InsertQuery class and is how Model.save() is implemented.
        """
        self._for_write = True
        if using is None:
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '920,945p' django/db/models/query.py; sed -n '780,835p' django/db/models/query.py"
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
            return self._filter_or_exclude(None, **filter_obj)

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

        if using is None:
            using = self.db
        qs = RawQuerySet(raw_query, model=self.model, params=params, translations=translations, using=using)
        qs._prefetch_related_lookups = self._prefetch_related_lookups[:]
        return qs

    def _values(self, *fields, **expressions):
        clone = self._chain()
        if expressions:
            clone = clone.annotate(**expressions)
        clone._fields = fields
        clone.query.set_values(fields)
        return clone

    def values(self, *fields, **expressions):
        fields += tuple(expressions)
        clone = self._values(*fields, **expressions)
        clone._iterable_class = ValuesIterable
        return clone

    def values_list(self, *fields, flat=False, named=False):
        if flat and named:
            raise TypeError("'flat' and 'named' can't be used together.")
        if flat and len(fields) > 1:
            raise TypeError("'flat' is not valid when values_list is called with more than one field.")

        field_names = {f for f in fields if not hasattr(f, 'resolve_expression')}
        _fields = []
        expressions = {}
        counter = 1
        for field in fields:
            if hasattr(field, 'resolve_expression'):
                field_id_prefix = getattr(field, 'default_alias', field.__class__.__name__.lower())
                while True:
                    field_id = field_id_prefix + str(counter)
                    counter += 1
                    if field_id not in field_names:
                        break
                expressions[field_id] = field
                _fields.append(field_id)
            else:
                _fields.append(field)

        clone = self._values(*_fields, **expressions)
        clone._iterable_class = (
            NamedValuesListIterable if named
            else FlatValuesListIterable if flat
            else ValuesListIterable
        )
        return clone

    def dates(self, field_name, kind, order='ASC'):
        """
        Return a list of date objects representing all available dates for
        the given field_name, scoped to 'kind'.
        """
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/sql/compiler.py\n@@\n                 # If the columns list is limited, then all combined queries\n                 # must have the same columns list. Set the selects defined on\n                 # the query on all combined queries, if not already set.\n                 if not compiler.query.values_select and self.query.values_select:\n+                    compiler.query = compiler.query.clone()\n                     compiler.query.set_values((\n                         *self.query.extra_select,\n                         *self.query.values_select,\n                         *self.query.annotation_select,\n                     ))\n*** Update File: tests/queries/test_qs_combinators.py\n@@\n     def test_union_with_values(self):\n         ReservedName.objects.create(name='a', order=2)\n         qs1 = ReservedName.objects.all()\n         reserved_name = qs1.union(qs1).values('name', 'order', 'id').get()\n         self.assertEqual(reserved_name['name'], 'a')\n         self.assertEqual(reserved_name['order'], 2)\n         reserved_name = qs1.union(qs1).values_list('name', 'order', 'id').get()\n         self.assertEqual(reserved_name[:2], ('a', 2))\n \n+    def test_union_with_values_list_and_order(self):\n+        ReservedName.objects.create(name='a', order=2)\n+        qs1 = ReservedName.objects.all()\n+        self.assertEqual(qs1.union(qs1).values_list('name', 'order').get(), ('a', 2))\n+        self.assertEqual(qs1.union(qs1).values_list('order').get(), (2,))\n+\n     def test_union_with_two_annotated_values_list(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/sql/compiler.py tests/queries/test_qs_combinators.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/sql/compiler.py now (1517 lines), around the change:
426:                # must have the same columns list. Set the selects defined on
427:                # the query on all combined queries, if not already set.
428:                if not compiler.query.values_select and self.query.values_select:
429:                    compiler.query = compiler.query.clone()
430:                    compiler.query.set_values((
431:                        *self.query.extra_select,
432:                        *self.query.values_select,

tests/queries/test_qs_combinators.py now (233 lines), around the change:
124:        reserved_name = qs1.union(qs1).values_list('name', 'order', 'id').get()
125:        self.assertEqual(reserved_name[:2], ('a', 2))
126:
127:    def test_union_with_values_list_and_order(self):
128:        ReservedName.objects.create(name='a', order=2)
129:        qs1 = ReservedName.objects.all()
130:        self.assertEqual(qs1.union(qs1).values_list('name', 'order').get(), ('a', 2))
131:        self.assertEqual(qs1.union(qs1).values_list('order').get(), (2,))
132:
133:    def test_union_with_two_annotated_values_list(self):
134:        qs1 = Number.objects.filter(num=1).annotate(
135:            count=Value(0, IntegerField()),
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.test_qs_combinators --settings=test_sqlite 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
.............s...........s.
----------------------------------------------------------------------
Ran 27 tests in 0.059s

OK (skipped=2)
Destroying test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.test_qs_combinators queries.test_values --settings=test_sqlite 2>&1 | tail -8; cd .. && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TARGET_OK"
}
```

**tool result**

```

----------------------------------------------------------------------
Ran 28 tests in 0.143s

FAILED (errors=1, skipped=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
TARGET_OK
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.test_qs_combinators queries.test_values --settings=test_sqlite 2>&1 | grep -A20 \"ERROR\\|FAIL:\" | head -40"
}
```

**tool result**

```
ERROR: test_values (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
ImportError: Failed to import test module: test_values
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'queries.test_values'


----------------------------------------------------------------------
Ran 28 tests in 0.146s

FAILED (errors=1, skipped=2)
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries --settings=test_sqlite 2>&1 | tail -8"
}
```

**tool result**

```
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
  "command": "cd tests && python runtests.py queries --settings=test_sqlite 2>&1 | grep -E \"^(Ran|OK|FAILED)\" | tail -5"
}
```

**tool result**

```
Ran 365 tests in 1.772s
OK (skipped=9, expected failures=2)
```

**assistant**

```
Fixed. The bug was in `SQLCompiler.get_combinator_sql()`: when applying the outer query's `values_select` to each combined query, it mutated the original combined query in place. Since `union()` stores references to the original query objects, a second `values_list()` call on the same union reused the already-mutated query and kept the old column list.

The fix clones the combined query before calling `set_values()`, so each compilation starts from the original query state. Added a regression test covering repeated `values_list()` calls with different fields.

Verification:
- `queries.test_qs_combinators`: 27 tests OK
- Full `queries` suite: 365 tests OK
- Target command exits 0 (`TARGET_OK`)
```

## Run folder `single-2026-11-06T105238`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Composed queries cannot change the list of columns with values()/values_list().
Description
	
Composed queries cannot change the list of columns when values()/values_list() is evaluated multiple times, e.g.
>>> ReservedName.objects.create(name='a', order=2)
>>> qs1 = ReservedName.objects.all()
>>> print(qs1.union(qs1).values_list('name', 'order').get())
('a', 2)
>>> print(qs1.union(qs1).values_list('order').get())
('a', 2)
(see ​compiler.py#L428-L433).
```
