# django__django-15368 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 48s 40 lines cost=0.001457 in=109850 cached=87040 out=1517 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

bulk_update() does not work with plain F('...') expressions.
Description
	
Repro:
assign plain F(...) to some model instance field
save with bulk_update
Example:
Code highlighting:
>>> from exampleapp.models import SelfRef
>>> o = SelfRef.objects.all().first()
>>> o.c8 = F('name')	# model has char fields 'c8' and 'name'
>>> SelfRef.objects.bulk_update([o], ['c8'])
1
>>> o.refresh_from_db()
>>> o.c8
'F(name)'
>>> from django.db import connection
>>> connection.queries[-2]
{'sql': 'UPDATE "exampleapp_selfref" SET "c8" = CASE WHEN ("exampleapp_selfref"."id" = 1290012) THEN \'F(name)\' ELSE NULL END WHERE "exampleapp_selfref"."id" IN (1290012)', 'time': '0.001'}
The created SQL contains the string repr of F(), instead of resolving to the column name. Looking at the source code, the culprit seems to be a too narrow type check in ​https://github.com/django/django/blob/2eed554c3fd75dae1beade79f357ffd18d3c4fdf/django/db/models/query.py#L673.
It works, if the type check gets replaced by one of these:
Code highlighting:
# either do duck type testing
if not hasattr(attr, 'resolve_expression'):
	...
# or test for F explicitly:
if not isinstance(attr, (Expression, F)):
	...

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --porcelain && git log --oneline -3"
}
```

**tool result**

```
/testbed
?? .memdoor/
53cba4823a SWE-bench
e972620ada Fixed #33462 -- Fixed migration crash when altering type of primary key with MTI and foreign key.
2eed554c3f Fixed wrapping of long messages in the admin.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '630,710p' django/db/models/query.py"
}
```

**tool result**

```
                    assert len(returned_columns) == len(objs_without_pk)
                for obj_without_pk, results in zip(objs_without_pk, returned_columns):
                    for result, field in zip(results, opts.db_returning_fields):
                        setattr(obj_without_pk, field.attname, result)
                    obj_without_pk._state.adding = False
                    obj_without_pk._state.db = self.db

        return objs

    def bulk_update(self, objs, fields, batch_size=None):
        """
        Update the given fields in each of the given objects in the database.
        """
        if batch_size is not None and batch_size < 0:
            raise ValueError('Batch size must be a positive integer.')
        if not fields:
            raise ValueError('Field names must be given to bulk_update().')
        objs = tuple(objs)
        if any(obj.pk is None for obj in objs):
            raise ValueError('All bulk_update() objects must have a primary key set.')
        fields = [self.model._meta.get_field(name) for name in fields]
        if any(not f.concrete or f.many_to_many for f in fields):
            raise ValueError('bulk_update() can only be used with concrete fields.')
        if any(f.primary_key for f in fields):
            raise ValueError('bulk_update() cannot be used with primary key fields.')
        if not objs:
            return 0
        for obj in objs:
            obj._prepare_related_fields_for_save(operation_name='bulk_update', fields=fields)
        # PK is used twice in the resulting update query, once in the filter
        # and once in the WHEN. Each field will also have one CAST.
        connection = connections[self.db]
        max_batch_size = connection.ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
        batch_size = min(batch_size, max_batch_size) if batch_size else max_batch_size
        requires_casting = connection.features.requires_casted_case_in_updates
        batches = (objs[i:i + batch_size] for i in range(0, len(objs), batch_size))
        updates = []
        for batch_objs in batches:
            update_kwargs = {}
            for field in fields:
                when_statements = []
                for obj in batch_objs:
                    attr = getattr(obj, field.attname)
                    if not isinstance(attr, Expression):
                        attr = Value(attr, output_field=field)
                    when_statements.append(When(pk=obj.pk, then=attr))
                case_statement = Case(*when_statements, output_field=field)
                if requires_casting:
                    case_statement = Cast(case_statement, output_field=field)
                update_kwargs[field.attname] = case_statement
            updates.append(([obj.pk for obj in batch_objs], update_kwargs))
        rows_updated = 0
        with transaction.atomic(using=self.db, savepoint=False):
            for pks, update_kwargs in updates:
                rows_updated += self.filter(pk__in=pks).update(**update_kwargs)
        return rows_updated
    bulk_update.alters_data = True

    def get_or_create(self, defaults=None, **kwargs):
        """
        Look up an object with the given kwargs, creating one if necessary.
        Return a tuple of (object, created), where created is a boolean
        specifying whether an object was created.
        """
        # The get() needs to be targeted at the write database in order
        # to avoid potential transaction consistency problems.
        self._for_write = True
        try:
            return self.get(**kwargs), False
        except self.model.DoesNotExist:
            params = self._extract_model_params(defaults, **kwargs)
            # Try to create an object using passed params.
            try:
                with transaction.atomic(using=self.db):
                    params = dict(resolve_callables(params))
                    return self.create(**params), True
            except IntegrityError:
                try:
                    return self.get(**kwargs), False
                except self.model.DoesNotExist:
                    pass
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,50p' django/db/models/query.py && grep -n '^class F' -A5 django/db/models/expressions.py && grep -rn \"bulk_update\" tests | head -20"
}
```

**tool result**

```
"""
The main QuerySet implementation. This provides the public API for the ORM.
"""

import copy
import operator
import warnings
from itertools import chain, islice

import django
from django.conf import settings
from django.core import exceptions
from django.db import (
    DJANGO_VERSION_PICKLE_KEY, IntegrityError, NotSupportedError, connections,
    router, transaction,
)
from django.db.models import AutoField, DateField, DateTimeField, sql
from django.db.models.constants import LOOKUP_SEP, OnConflict
from django.db.models.deletion import Collector
from django.db.models.expressions import Case, Expression, F, Ref, Value, When
from django.db.models.functions import Cast, Trunc
from django.db.models.query_utils import FilteredRelation, Q
from django.db.models.sql.constants import CURSOR, GET_ITERATOR_CHUNK_SIZE
from django.db.models.utils import create_namedtuple_class, resolve_callables
from django.utils import timezone
from django.utils.deprecation import RemovedInDjango50Warning
from django.utils.functional import cached_property, partition

# The maximum number of results to fetch in a get() query.
MAX_GET_RESULTS = 21

# The maximum number of items to display in a QuerySet.__repr__
REPR_OUTPUT_SIZE = 20


class BaseIterable:
    def __init__(self, queryset, chunked_fetch=False, chunk_size=GET_ITERATOR_CHUNK_SIZE):
        self.queryset = queryset
        self.chunked_fetch = chunked_fetch
        self.chunk_size = chunk_size


class ModelIterable(BaseIterable):
    """Iterable that yields a model instance for each row."""

    def __iter__(self):
        queryset = self.queryset
        db = queryset.db
        compiler = queryset.query.get_compiler(using=db)
        # Execute the query. This will also fill compiler.select, klass_info,
582:class F(Combinable):
583-    """An object capable of resolving references to existing query objects."""
584-
585-    def __init__(self, name):
586-        """
587-        Arguments:
--
655:class Func(SQLiteNumericMixin, Expression):
656-    """An SQL function call."""
657-    function = None
658-    template = '%(function)s(%(expressions)s)'
659-    arg_joiner = ', '
660-    arity = None  # The number of arguments the function accepts.
tests/basic/tests.py:590:        'bulk_update',
tests/queries/test_bulk_update.py:33:            Note.objects.bulk_update(self.notes, ['note'])
tests/queries/test_bulk_update.py:44:            Note.objects.bulk_update(self.notes, ['note', 'misc'])
tests/queries/test_bulk_update.py:56:            Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)
tests/queries/test_bulk_update.py:60:        msg = 'All bulk_update() objects must have a primary key set.'
tests/queries/test_bulk_update.py:62:            Note.objects.bulk_update(objs, fields=['note'])
tests/queries/test_bulk_update.py:69:            Note.objects.bulk_update(self.notes, ['tag'])
tests/queries/test_bulk_update.py:77:        Note.objects.bulk_update(self.notes, ['tag'])
tests/queries/test_bulk_update.py:88:        Note.objects.bulk_update(self.notes, ['tag'])
tests/queries/test_bulk_update.py:96:        Note.objects.bulk_update(self.notes, ['note'])
tests/queries/test_bulk_update.py:104:        msg = 'Field names must be given to bulk_update().'
tests/queries/test_bulk_update.py:106:            Note.objects.bulk_update([], fields=[])
tests/queries/test_bulk_update.py:111:            Note.objects.bulk_update([], fields=['note'], batch_size=-1)
tests/queries/test_bulk_update.py:115:            Note.objects.bulk_update([], ['nonexistent'])
tests/queries/test_bulk_update.py:117:    pk_fields_error = 'bulk_update() cannot be used with primary key fields.'
tests/queries/test_bulk_update.py:121:            Note.objects.bulk_update([], ['id'])
tests/queries/test_bulk_update.py:125:            CustomPk.objects.bulk_update([], ['name'])
tests/queries/test_bulk_update.py:129:            rows_updated = Note.objects.bulk_update([], ['note'])
tests/queries/test_bulk_update.py:138:        rows_updated = Note.objects.bulk_update(notes, ['note'])
tests/queries/test_bulk_update.py:143:        rows_updated = Note.objects.bulk_update([note, note], ['note'])
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,30p' tests/queries/test_bulk_update.py && sed -n '125,200p' tests/queries/test_bulk_update.py"
}
```

**tool result**

```
import datetime

from django.core.exceptions import FieldDoesNotExist
from django.db.models import F
from django.db.models.functions import Lower
from django.test import TestCase, skipUnlessDBFeature

from .models import (
    Article, CustomDbColumn, CustomPk, Detail, Individual, JSONFieldNullable,
    Member, Note, Number, Order, Paragraph, RelatedObject, SingleObject,
    SpecialCategory, Tag, Valid,
)


class BulkUpdateNoteTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.notes = [
            Note.objects.create(note=str(i), misc=str(i))
            for i in range(10)
        ]

    def create_tags(self):
        self.tags = [
            Tag.objects.create(name=str(i))
            for i in range(10)
        ]

    def test_simple(self):
        for note in self.notes:
            CustomPk.objects.bulk_update([], ['name'])

    def test_empty_objects(self):
        with self.assertNumQueries(0):
            rows_updated = Note.objects.bulk_update([], ['note'])
        self.assertEqual(rows_updated, 0)

    def test_large_batch(self):
        Note.objects.bulk_create([
            Note(note=str(i), misc=str(i))
            for i in range(0, 2000)
        ])
        notes = list(Note.objects.all())
        rows_updated = Note.objects.bulk_update(notes, ['note'])
        self.assertEqual(rows_updated, 2000)

    def test_updated_rows_when_passing_duplicates(self):
        note = Note.objects.create(note='test-note', misc='test')
        rows_updated = Note.objects.bulk_update([note, note], ['note'])
        self.assertEqual(rows_updated, 1)
        # Duplicates in different batches.
        rows_updated = Note.objects.bulk_update([note, note], ['note'], batch_size=1)
        self.assertEqual(rows_updated, 2)

    def test_only_concrete_fields_allowed(self):
        obj = Valid.objects.create(valid='test')
        detail = Detail.objects.create(data='test')
        paragraph = Paragraph.objects.create(text='test')
        Member.objects.create(name='test', details=detail)
        msg = 'bulk_update() can only be used with concrete fields.'
        with self.assertRaisesMessage(ValueError, msg):
            Detail.objects.bulk_update([detail], fields=['member'])
        with self.assertRaisesMessage(ValueError, msg):
            Paragraph.objects.bulk_update([paragraph], fields=['page'])
        with self.assertRaisesMessage(ValueError, msg):
            Valid.objects.bulk_update([obj], fields=['parent'])

    def test_custom_db_columns(self):
        model = CustomDbColumn.objects.create(custom_column=1)
        model.custom_column = 2
        CustomDbColumn.objects.bulk_update([model], fields=['custom_column'])
        model.refresh_from_db()
        self.assertEqual(model.custom_column, 2)

    def test_custom_pk(self):
        custom_pks = [
            CustomPk.objects.create(name='pk-%s' % i, extra='')
            for i in range(10)
        ]
        for model in custom_pks:
            model.extra = 'extra-%s' % model.pk
        CustomPk.objects.bulk_update(custom_pks, ['extra'])
        self.assertCountEqual(
            CustomPk.objects.values_list('extra', flat=True),
            [cat.extra for cat in custom_pks]
        )

    def test_falsey_pk_value(self):
        order = Order.objects.create(pk=0, name='test')
        order.name = 'updated'
        Order.objects.bulk_update([order], ['name'])
        order.refresh_from_db()
        self.assertEqual(order.name, 'updated')

    def test_inherited_fields(self):
        special_categories = [
            SpecialCategory.objects.create(name=str(i), special_name=str(i))
            for i in range(10)
        ]
        for category in special_categories:
            category.name = 'test-%s' % category.id
            category.special_name = 'special-test-%s' % category.special_name
        SpecialCategory.objects.bulk_update(special_categories, ['name', 'special_name'])
        self.assertCountEqual(
            SpecialCategory.objects.values_list('name', flat=True),
            [cat.name for cat in special_categories]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"F(\\|expression\\|Lower\" tests/queries/test_bulk_update.py"
}
```

**tool result**

```
5:from django.db.models.functions import Lower
95:            note.note = Lower('note')
210:            number.num = F('num') + 1
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '85,100p' tests/queries/test_bulk_update.py && sed -n '200,225p' tests/queries/test_bulk_update.py"
}
```

**tool result**

```
            note.tag = None
        for note in bottom:
            note.tag = self.tags[0]
        Note.objects.bulk_update(self.notes, ['tag'])
        self.assertCountEqual(Note.objects.filter(tag__isnull=True), top)
        self.assertCountEqual(Note.objects.filter(tag__isnull=False), bottom)

    def test_functions(self):
        Note.objects.update(note='TEST')
        for note in self.notes:
            note.note = Lower('note')
        Note.objects.bulk_update(self.notes, ['note'])
        self.assertEqual(set(Note.objects.values_list('note', flat=True)), {'test'})

    # Tests that use self.notes go here, otherwise put them in another class.

            [cat.name for cat in special_categories]
        )
        self.assertCountEqual(
            SpecialCategory.objects.values_list('special_name', flat=True),
            [cat.special_name for cat in special_categories]
        )

    def test_field_references(self):
        numbers = [Number.objects.create(num=0) for _ in range(10)]
        for number in numbers:
            number.num = F('num') + 1
        Number.objects.bulk_update(numbers, ['num'])
        self.assertCountEqual(Number.objects.filter(num=1), numbers)

    def test_booleanfield(self):
        individuals = [Individual.objects.create(alive=False) for _ in range(10)]
        for individual in individuals:
            individual.alive = True
        Individual.objects.bulk_update(individuals, ['alive'])
        self.assertCountEqual(Individual.objects.filter(alive=True), individuals)

    def test_ipaddressfield(self):
        for ip in ('2001::1', '1.2.3.4'):
            with self.subTest(ip=ip):
                models = [
                    CustomDbColumn.objects.create(ip_address='0.0.0.0')
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/query.py\n@@\n-                    if not isinstance(attr, Expression):\n+                    if not hasattr(attr, 'resolve_expression'):\n                         attr = Value(attr, output_field=field)\n*** Update File: tests/queries/test_bulk_update.py\n@@\n     def test_field_references(self):\n         numbers = [Number.objects.create(num=0) for _ in range(10)]\n         for number in numbers:\n             number.num = F('num') + 1\n         Number.objects.bulk_update(numbers, ['num'])\n         self.assertCountEqual(Number.objects.filter(num=1), numbers)\n \n+    def test_plain_field_reference(self):\n+        numbers = [Number.objects.create(num=0) for _ in range(10)]\n+        for number in numbers:\n+            number.num = F('num')\n+        Number.objects.bulk_update(numbers, ['num'])\n+        self.assertCountEqual(Number.objects.filter(num=0), numbers)\n+\n     def test_booleanfield(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/query.py tests/queries/test_bulk_update.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/query.py now (2172 lines), around the change:
670:                when_statements = []
671:                for obj in batch_objs:
672:                    attr = getattr(obj, field.attname)
673:                    if not hasattr(attr, 'resolve_expression'):
674:                        attr = Value(attr, output_field=field)
675:                    when_statements.append(When(pk=obj.pk, then=attr))
676:                case_statement = Case(*when_statements, output_field=field)

tests/queries/test_bulk_update.py now (289 lines), around the change:
211:        Number.objects.bulk_update(numbers, ['num'])
212:        self.assertCountEqual(Number.objects.filter(num=1), numbers)
213:
214:    def test_plain_field_reference(self):
215:        numbers = [Number.objects.create(num=0) for _ in range(10)]
216:        for number in numbers:
217:            number.num = F('num')
218:        Number.objects.bulk_update(numbers, ['num'])
219:        self.assertCountEqual(Number.objects.filter(num=0), numbers)
220:
221:    def test_booleanfield(self):
222:        individuals = [Individual.objects.create(alive=False) for _ in range(10)]
223:        for individual in individuals:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n '\\bExpression\\b' django/db/models/query.py | head; python -m pytest tests/queries/test_bulk_update.py -q 2>&1 | tail -20"
}
```

**tool result**

```
20:from django.db.models.expressions import Case, Expression, F, Ref, Value, When
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.test_bulk_update 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 30 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (1 silenced).
..............................
----------------------------------------------------------------------
Ran 30 tests in 0.506s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n '\\bExpression\\b' django/db/models/query.py"
}
```

**tool result**

```
20:from django.db.models.expressions import Case, Expression, F, Ref, Value, When
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/query.py\n@@\n-from django.db.models.expressions import Case, Expression, F, Ref, Value, When\n+from django.db.models.expressions import Case, F, Ref, Value, When\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/query.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/query.py now (2172 lines), around the change:
17:from django.db.models import AutoField, DateField, DateTimeField, sql
18:from django.db.models.constants import LOOKUP_SEP, OnConflict
19:from django.db.models.deletion import Collector
20:from django.db.models.expressions import Case, F, Ref, Value, When
21:from django.db.models.functions import Cast, Trunc
22:from django.db.models.query_utils import FilteredRelation, Q
23:from django.db.models.sql.constants import CURSOR, GET_ITERATOR_CHUNK_SIZE
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py queries.test_bulk_update 2>&1 | tail -8 && cd .. && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo COMMAND_OK"
}
```

**tool result**

```
..............................
----------------------------------------------------------------------
Ran 30 tests in 0.436s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
COMMAND_OK
```

**assistant**

```
Implemented the fix. Changes:

- `django/db/models/query.py`: `bulk_update()` now uses duck typing (`hasattr(attr, 'resolve_expression')`) so plain `F(...)` expressions are resolved rather than wrapped as `Value`, fixing the SQL to reference the column. Removed the now-unused `Expression` import.
- `tests/queries/test_bulk_update.py`: added `test_plain_field_reference` covering plain `F('num')` in `bulk_update()`.

All 30 bulk-update tests pass, and the required git-status command exits 0.
```

## Run folder `single-2026-11-06T111204`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
bulk_update() does not work with plain F('...') expressions.
Description
	
Repro:
assign plain F(...) to some model instance field
save with bulk_update
Example:
Code highlighting:
>>> from exampleapp.models import SelfRef
>>> o = SelfRef.objects.all().first()
>>> o.c8 = F('name')	# model has char fields 'c8' and 'name'
>>> SelfRef.objects.bulk_update([o], ['c8'])
1
>>> o.refresh_from_db()
>>> o.c8
'F(name)'
>>> from django.db import connection
>>> connection.queries[-2]
{'sql': 'UPDATE "exampleapp_selfref" SET "c8" = CASE WHEN ("exampleapp_selfref"."id" = 1290012) THEN \'F(name)\' ELSE NULL END WHERE "exampleapp_selfref"."id" IN (1290012)', 'time': '0.001'}
The created SQL contains the string repr of F(), instead of resolving to the column name. Looking at the source code, the culprit seems to be a too narrow type check in ​https://github.com/django/django/blob/2eed554c3fd75dae1beade79f357ffd18d3c4fdf/django/db/models/query.py#L673.
It works, if the type check gets replaced by one of these:
Code highlighting:
# either do duck type testing
if not hasattr(attr, 'resolve_expression'):
	...
# or test for F explicitly:
if not isinstance(attr, (Expression, F)):
	...
```
