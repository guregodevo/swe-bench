# django__django-13417 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 35s 34 lines cost=0.001088 in=88083 cached=80384 out=1493 calls=12`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

QuerySet.ordered property is incorrect for GROUP BY queries on models with Meta.ordering.
Description
	
Using the annotate function on a queryset doesn't keep the default ordering set in model's meta class.
A property should say whether the queryset will be ordered or not. I wanted to use the qs.ordered property for this but it seems to stay truthy, even if the resulting SQL query will not have an ORDER BY clause.
Example: 
qs = Foo.objects.all()
​
# SQL => 'SELECT "foo_foo"."uuid", "foo_foo"."name" FROM "foo_foo" ORDER BY "foo_foo"."name" ASC'
​
qs.ordered # => True
qs.query.default_ordering # => True
​
############################################
​
qs2 = Foo.objects.annotate(Count("pk")).all()
​
# SQL => 'SELECT "foo_foo"."uuid", "foo_foo"."name", COUNT("foo_foo"."uuid") AS "pk__count" FROM "foo_foo" GROUP BY "foo_foo"."uuid"'
​
qs2.ordered # => True
qs2.query.default_ordering # => True
If it can help : I'm using PostgreSQL

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
13490e36ff SWE-bench
71ae1ab012 Removed hardcoded paths to SpatialRefSys models in tests.
a7a4ff1026 Refs #26697 -- Removed empty gis_tests.maps.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def ordered\" -n django/db/models/query.py && grep -n \"def ordered\" django/db/models/sql/query.py"
}
```

**tool result**

```
1218:    def ordered(self):

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1200,1240p' django/db/models/query.py; grep -n \"group_by\" django/db/models/sql/query.py | head -30"
}
```

**tool result**

```
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
177:        # The group_by attribute can have one of the following forms:
182:        # See compiler.get_group_by() for details.
183:        self.group_by = None
438:        if (isinstance(self.group_by, tuple) or self.is_sliced or existing_annotations or
462:                    inner_query.group_by = (self.model._meta.pk.get_col(inner_query.get_initial_alias()),)
528:            if q.group_by is True:
532:                q.set_group_by(allow_aliases=False)
846:        if isinstance(self.group_by, tuple):
847:            self.group_by = tuple([col.relabeled_clone(change_map) for col in self.group_by])
1997:    def set_group_by(self, allow_aliases=True):
2019:        group_by = list(self.select)
2022:                signature = inspect.signature(annotation.get_group_by_cols)
2027:                        '%s.%s.get_group_by_cols().'
2030:                    group_by_cols = annotation.get_group_by_cols()
2034:                    group_by_cols = annotation.get_group_by_cols(alias=alias)
2035:                group_by.extend(group_by_cols)
2036:        self.group_by = tuple(group_by)
2208:        if self.group_by is True:
2212:            self.set_group_by(allow_aliases=False)
2214:        elif self.group_by:
2217:            group_by = []
2218:            for expr in self.group_by:
2221:                group_by.append(expr)
2222:            self.group_by = tuple(group_by)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"ordered\" tests/queries/test_qs_combinators.py tests/ordering/tests.py tests/aggregation/tests.py 2>/dev/null | head -40; grep -rn \"\\.ordered\" tests | head -40"
}
```

**tool result**

```
tests/queries/test_qs_combinators.py:16:    def assertNumbersEqual(self, queryset, expected_numbers, ordered=True):
tests/queries/test_qs_combinators.py:17:        self.assertQuerysetEqual(queryset, expected_numbers, operator.attrgetter('num'), ordered)
tests/queries/test_qs_combinators.py:23:        self.assertNumbersEqual(qs1.union(qs2, qs3), [0, 1, 5, 8, 9], ordered=False)
tests/queries/test_qs_combinators.py:30:        self.assertNumbersEqual(qs1.intersection(qs2, qs3), [5], ordered=False)
tests/queries/test_qs_combinators.py:46:        self.assertNumbersEqual(qs1.difference(qs2), [5], ordered=False)
tests/queries/test_qs_combinators.py:59:        self.assertNumbersEqual(qs3, [0, 1, 8, 9], ordered=False)
tests/generic_relations/test_forms.py:128:        self.assertIs(formset.get_queryset().ordered, True)
tests/forms_tests/tests/test_formsets.py:588:            [form.cleaned_data for form in formset.ordered_forms],
tests/forms_tests/tests/test_formsets.py:648:            [form.cleaned_data for form in formset.ordered_forms],
tests/forms_tests/tests/test_formsets.py:668:        self.assertEqual(formset.ordered_forms, [])
tests/forms_tests/tests/test_formsets.py:724:            [form.cleaned_data for form in formset.ordered_forms],
tests/forms_tests/tests/test_formsets.py:750:        self.assertEqual(formset.ordered_forms, [])
tests/queries/tests.py:2063:    Tests for the Queryset.ordered attribute.
tests/queries/tests.py:2067:        self.assertIs(Annotation.objects.all().ordered, False)
tests/queries/tests.py:2070:        self.assertIs(Tag.objects.all().ordered, True)
tests/queries/tests.py:2071:        self.assertIs(Tag.objects.all().order_by().ordered, False)
tests/queries/tests.py:2074:        self.assertIs(Annotation.objects.all().order_by('id').ordered, True)
tests/queries/tests.py:2077:        self.assertIs(Annotation.objects.none().ordered, True)
tests/queries/tests.py:2080:        self.assertIs(Annotation.objects.all().extra(order_by=['id']).ordered, True)
tests/queries/tests.py:2084:        self.assertIs(qs.ordered, False)
tests/queries/tests.py:2085:        self.assertIs(qs.order_by('num_notes').ordered, True)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '2055,2095p' tests/queries/tests.py; grep -n \"class Annotation\\|class Tag\" tests/queries/tests.py | head"
}
```

**tool result**

```
        Article.objects.create(name='two', created=datetime.datetime.now())
        self.assertTrue(Article.objects.distinct('name').exists())
        self.assertTrue(Article.objects.distinct('name')[1:2].exists())
        self.assertFalse(Article.objects.distinct('name')[2:3].exists())


class QuerysetOrderedTests(unittest.TestCase):
    """
    Tests for the Queryset.ordered attribute.
    """

    def test_no_default_or_explicit_ordering(self):
        self.assertIs(Annotation.objects.all().ordered, False)

    def test_cleared_default_ordering(self):
        self.assertIs(Tag.objects.all().ordered, True)
        self.assertIs(Tag.objects.all().order_by().ordered, False)

    def test_explicit_ordering(self):
        self.assertIs(Annotation.objects.all().order_by('id').ordered, True)

    def test_empty_queryset(self):
        self.assertIs(Annotation.objects.none().ordered, True)

    def test_order_by_extra(self):
        self.assertIs(Annotation.objects.all().extra(order_by=['id']).ordered, True)

    def test_annotated_ordering(self):
        qs = Annotation.objects.annotate(num_notes=Count('notes'))
        self.assertIs(qs.ordered, False)
        self.assertIs(qs.order_by('num_notes').ordered, True)


@skipUnlessDBFeature('allow_sliced_subqueries_with_in')
class SubqueryTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        NamedCategory.objects.create(id=1, name='first')
        NamedCategory.objects.create(id=2, name='second')
        NamedCategory.objects.create(id=3, name='third')
        NamedCategory.objects.create(id=4, name='fourth')
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/query.py\n@@\n-        elif self.query.default_ordering and self.query.get_meta().ordering:\n+        elif (\n+            self.query.default_ordering and\n+            self.query.get_meta().ordering and\n+            # A default ordering doesn't affect GROUP BY queries.\n+            not self.query.group_by\n+        ):\n             return True\n*** Update File: tests/queries/tests.py\n@@\n     def test_annotated_ordering(self):\n         qs = Annotation.objects.annotate(num_notes=Count('notes'))\n         self.assertIs(qs.ordered, False)\n         self.assertIs(qs.order_by('num_notes').ordered, True)\n+\n+    def test_annotated_default_ordering(self):\n+        qs = Tag.objects.annotate(num_notes=Count('notes'))\n+        self.assertIs(qs.ordered, False)\n+        self.assertIs(qs.order_by('name').ordered, True)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/query.py tests/queries/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/query.py now (1986 lines), around the change:
1224:            return True
1225:        if self.query.extra_order_by or self.query.order_by:
1226:            return True
1227:        elif (
1228:            self.query.default_ordering and
1229:            self.query.get_meta().ordering and
1230:            # A default ordering doesn't affect GROUP BY queries.
1231:            not self.query.group_by
1232:        ):
1233:            return True
1234:        else:
1235:            return False

tests/queries/tests.py now (4009 lines), around the change:
2083:        qs = Annotation.objects.annotate(num_notes=Count('notes'))
2084:        self.assertIs(qs.ordered, False)
2085:        self.assertIs(qs.order_by('num_notes').ordered, True)
2086:
2087:    def test_annotated_default_ordering(self):
2088:        qs = Tag.objects.annotate(num_notes=Count('notes'))
2089:        self.assertIs(qs.ordered, False)
2090:        self.assertIs(qs.order_by('name').ordered, True)
2091:
2092:
2093:@skipUnlessDBFeature('allow_sliced_subqueries_with_in')
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.QuerysetOrderedTests --settings=test_sqlite 2>&1 | tail -30"
}
```

**tool result**

```
E
======================================================================
ERROR: QuerysetOrderedTests (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: QuerysetOrderedTests
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'queries.QuerysetOrderedTests'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.tests.QuerysetOrderedTests --settings=test_sqlite 2>&1 | tail -30"
}
```

**tool result**

```
  File "/testbed/tests/queries/tests.py", line 2088, in test_annotated_default_ordering
    qs = Tag.objects.annotate(num_notes=Count('notes'))
  File "/testbed/django/db/models/manager.py", line 85, in manager_method
    return getattr(self.get_queryset(), name)(*args, **kwargs)
  File "/testbed/django/db/models/query.py", line 1079, in annotate
    return self._annotate(args, kwargs, select=True)
  File "/testbed/django/db/models/query.py", line 1119, in _annotate
    annotation, alias, is_summary=False, select=select,
  File "/testbed/django/db/models/sql/query.py", line 1027, in add_annotation
    summarize=is_summary)
  File "/testbed/django/db/models/aggregates.py", line 47, in resolve_expression
    c = super().resolve_expression(query, allow_joins, reuse, summarize)
  File "/testbed/django/db/models/expressions.py", line 676, in resolve_expression
    c.source_expressions[pos] = arg.resolve_expression(query, allow_joins, reuse, summarize, for_save)
  File "/testbed/django/db/models/expressions.py", line 576, in resolve_expression
    return query.resolve_ref(self.name, allow_joins, reuse, summarize)
  File "/testbed/django/db/models/sql/query.py", line 1729, in resolve_ref
    join_info = self.setup_joins(field_list, self.get_meta(), self.get_initial_alias(), can_reuse=reuse)
  File "/testbed/django/db/models/sql/query.py", line 1607, in setup_joins
    names[:pivot], opts, allow_many, fail_on_missing=True,
  File "/testbed/django/db/models/sql/query.py", line 1523, in names_to_path
    "Choices are: %s" % (name, ", ".join(available)))
django.core.exceptions.FieldError: Cannot resolve keyword 'notes' into field. Choices are: annotation, category, category_id, children, id, item, managedmodel, name, note, parent, parent_id

----------------------------------------------------------------------
Ran 7 tests in 0.004s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && sed -i \"s/qs = Tag.objects.annotate(num_notes=Count('notes'))/qs = Tag.objects.annotate(num_notes=Count('note'))/\" queries/tests.py && python runtests.py queries.tests.QuerysetOrderedTests --settings=test_sqlite 2>&1 | tail -10"
}
```

**tool result**

```
.......
----------------------------------------------------------------------
Ran 7 tests in 0.002s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (1 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries --settings=test_sqlite 2>&1 | tail -8; cd .. && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TARGET_OK"
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
TARGET_OK
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries --settings=test_sqlite 2>&1 | grep -E \"^(OK|FAILED|Ran )\" | tail -5"
}
```

**tool result**

```
Ran 391 tests in 0.841s
OK (skipped=13, expected failures=2)
```

**assistant**

```
Fixed `QuerySet.ordered` so a model's default ordering no longer counts when the query has a `GROUP BY` (e.g. after `annotate()`), since Django omits the `ORDER BY` clause in that case.

- `django/db/models/query.py`: default ordering now only makes `ordered` true when `query.group_by` is empty.
- `tests/queries/tests.py`: added `test_annotated_default_ordering` covering a model with `Meta.ordering` plus an aggregate annotation.

Verified: `queries` suite passes (391 tests, OK), and the target command exits 0.
```

## Run folder `single-2026-11-06T110926`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
QuerySet.ordered property is incorrect for GROUP BY queries on models with Meta.ordering.
Description
	
Using the annotate function on a queryset doesn't keep the default ordering set in model's meta class.
A property should say whether the queryset will be ordered or not. I wanted to use the qs.ordered property for this but it seems to stay truthy, even if the resulting SQL query will not have an ORDER BY clause.
Example: 
qs = Foo.objects.all()
​
# SQL => 'SELECT "foo_foo"."uuid", "foo_foo"."name" FROM "foo_foo" ORDER BY "foo_foo"."name" ASC'
​
qs.ordered # => True
qs.query.default_ordering # => True
​
############################################
​
qs2 = Foo.objects.annotate(Count("pk")).all()
​
# SQL => 'SELECT "foo_foo"."uuid", "foo_foo"."name", COUNT("foo_foo"."uuid") AS "pk__count" FROM "foo_foo" GROUP BY "foo_foo"."uuid"'
​
qs2.ordered # => True
qs2.query.default_ordering # => True
If it can help : I'm using PostgreSQL
```
