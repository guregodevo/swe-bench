# django__django-14559 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 59s 72 lines cost=0.003004 in=76279 cached=53760 out=5735 calls=9`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Include number of rows matched in bulk_update() return value
Description
	
Currently, bulk_update() returns None, unlike update(), which returns ​the number of rows matched.
It looks like it would be easy to add the same functionality to bulk_update() since bulk_update() simply calls update() repeatedly:
​https://github.com/django/django/blob/2b4b6c8af0aae8785bc1347cf1be2e8e70fd5ff3/django/db/models/query.py#L568
I.e. the return values could simply be added and returned.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --short && git log -1 --oneline"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def bulk_update\" -A 60 django/db/models/query.py"
}
```

**tool result**

```
/testbed
?? .memdoor/
5d31c7b7ca SWE-bench
```

**tool result**

```
527:    def bulk_update(self, objs, fields, batch_size=None):
528-        """
529-        Update the given fields in each of the given objects in the database.
530-        """
531-        if batch_size is not None and batch_size < 0:
532-            raise ValueError('Batch size must be a positive integer.')
533-        if not fields:
534-            raise ValueError('Field names must be given to bulk_update().')
535-        objs = tuple(objs)
536-        if any(obj.pk is None for obj in objs):
537-            raise ValueError('All bulk_update() objects must have a primary key set.')
538-        fields = [self.model._meta.get_field(name) for name in fields]
539-        if any(not f.concrete or f.many_to_many for f in fields):
540-            raise ValueError('bulk_update() can only be used with concrete fields.')
541-        if any(f.primary_key for f in fields):
542-            raise ValueError('bulk_update() cannot be used with primary key fields.')
543-        if not objs:
544-            return
545-        # PK is used twice in the resulting update query, once in the filter
546-        # and once in the WHEN. Each field will also have one CAST.
547-        max_batch_size = connections[self.db].ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
548-        batch_size = min(batch_size, max_batch_size) if batch_size else max_batch_size
549-        requires_casting = connections[self.db].features.requires_casted_case_in_updates
550-        batches = (objs[i:i + batch_size] for i in range(0, len(objs), batch_size))
551-        updates = []
552-        for batch_objs in batches:
553-            update_kwargs = {}
554-            for field in fields:
555-                when_statements = []
556-                for obj in batch_objs:
557-                    attr = getattr(obj, field.attname)
558-                    if not isinstance(attr, Expression):
559-                        attr = Value(attr, output_field=field)
560-                    when_statements.append(When(pk=obj.pk, then=attr))
561-                case_statement = Case(*when_statements, output_field=field)
562-                if requires_casting:
563-                    case_statement = Cast(case_statement, output_field=field)
564-                update_kwargs[field.attname] = case_statement
565-            updates.append(([obj.pk for obj in batch_objs], update_kwargs))
566-        with transaction.atomic(using=self.db, savepoint=False):
567-            for pks, update_kwargs in updates:
568-                self.filter(pk__in=pks).update(**update_kwargs)
569-    bulk_update.alters_data = True
570-
571-    def get_or_create(self, defaults=None, **kwargs):
572-        """
573-        Look up an object with the given kwargs, creating one if necessary.
574-        Return a tuple of (object, created), where created is a boolean
575-        specifying whether an object was created.
576-        """
577-        # The get() needs to be targeted at the write database in order
578-        # to avoid potential transaction consistency problems.
579-        self._for_write = True
580-        try:
581-            return self.get(**kwargs), False
582-        except self.model.DoesNotExist:
583-            params = self._extract_model_params(defaults, **kwargs)
584-            # Try to create an object using passed params.
585-            try:
586-                with transaction.atomic(using=self.db):
587-                    params = dict(resolve_callables(params))
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"bulk_update\" tests/ | head -50"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"bulk_update\" docs/ | head -30"
}
```

**tool result**

```
tests/basic/tests.py:580:        'bulk_update',
tests/queries/test_bulk_update.py:32:            Note.objects.bulk_update(self.notes, ['note'])
tests/queries/test_bulk_update.py:43:            Note.objects.bulk_update(self.notes, ['note', 'misc'])
tests/queries/test_bulk_update.py:55:            Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)
tests/queries/test_bulk_update.py:59:        msg = 'All bulk_update() objects must have a primary key set.'
tests/queries/test_bulk_update.py:61:            Note.objects.bulk_update(objs, fields=['note'])
tests/queries/test_bulk_update.py:68:            Note.objects.bulk_update(self.notes, ['tag'])
tests/queries/test_bulk_update.py:76:        Note.objects.bulk_update(self.notes, ['tag'])
tests/queries/test_bulk_update.py:87:        Note.objects.bulk_update(self.notes, ['tag'])
tests/queries/test_bulk_update.py:95:        Note.objects.bulk_update(self.notes, ['note'])
tests/queries/test_bulk_update.py:103:        msg = 'Field names must be given to bulk_update().'
tests/queries/test_bulk_update.py:105:            Note.objects.bulk_update([], fields=[])
tests/queries/test_bulk_update.py:110:            Note.objects.bulk_update([], fields=['note'], batch_size=-1)
tests/queries/test_bulk_update.py:114:            Note.objects.bulk_update([], ['nonexistent'])
tests/queries/test_bulk_update.py:116:    pk_fields_error = 'bulk_update() cannot be used with primary key fields.'
tests/queries/test_bulk_update.py:120:            Note.objects.bulk_update([], ['id'])
tests/queries/test_bulk_update.py:124:            CustomPk.objects.bulk_update([], ['name'])
tests/queries/test_bulk_update.py:128:            Note.objects.bulk_update([], ['note'])
tests/queries/test_bulk_update.py:136:        Note.objects.bulk_update(notes, ['note'])
tests/queries/test_bulk_update.py:143:        msg = 'bulk_update() can only be used with concrete fields.'
tests/queries/test_bulk_update.py:145:            Detail.objects.bulk_update([detail], fields=['member'])
tests/queries/test_bulk_update.py:147:            Paragraph.objects.bulk_update([paragraph], fields=['page'])
tests/queries/test_bulk_update.py:149:            Valid.objects.bulk_update([obj], fields=['parent'])
tests/queries/test_bulk_update.py:154:        CustomDbColumn.objects.bulk_update([model], fields=['custom_column'])
tests/queries/test_bulk_update.py:165:        CustomPk.objects.bulk_update(custom_pks, ['extra'])
tests/queries/test_bulk_update.py:174:        Order.objects.bulk_update([order], ['name'])
tests/queries/test_bulk_update.py:186:        SpecialCategory.objects.bulk_update(special_categories, ['name', 'special_name'])
tests/queries/test_bulk_update.py:200:        Number.objects.bulk_update(numbers, ['num'])
tests/queries/test_bulk_update.py:207:        Individual.objects.bulk_update(individuals, ['alive'])
tests/queries/test_bulk_update.py:219:                CustomDbColumn.objects.bulk_update(models, ['ip_address'])
tests/queries/test_bulk_update.py:230:        Article.objects.bulk_update(articles, ['created'])
tests/queries/test_bulk_update.py:241:        JSONFieldNullable.objects.bulk_update(objs, ['json_field'])
tests/migrations/test_state.py:310:    def test_apps_bulk_update(self):
tests/migrations/test_state.py:312:        StateApps.bulk_update() should update apps.ready to False and reset
tests/migrations/test_state.py:317:        with apps.bulk_update():
tests/migrations/test_state.py:321:            with apps.bulk_update():
tests/postgres_tests/test_bulk_update.py:16:    def test_bulk_update(self):
tests/postgres_tests/test_bulk_update.py:32:                Model.objects.bulk_update(instances, [field])
```

**tool result**

```
docs/ref/models/querysets.txt:2218:``bulk_update()``
docs/ref/models/querysets.txt:2221:.. method:: bulk_update(objs, fields, batch_size=None)
docs/ref/models/querysets.txt:2232:    >>> Entry.objects.bulk_update(objs, ['headline'])
docs/topics/db/optimization.txt:370::meth:`~django.db.models.query.QuerySet.bulk_update()` method to reduce the
docs/topics/db/optimization.txt:382:    Entry.objects.bulk_update(entries, ['headline'])
docs/topics/db/optimization.txt:392:<django.db.models.query.QuerySet.bulk_update>`, so make sure it's appropriate
docs/releases/2.2.txt:172:* The new :meth:`.QuerySet.bulk_update` method allows efficiently updating
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '2210,2250p' docs/ref/models/querysets.txt"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,260p' tests/queries/test_bulk_update.py"
}
```

**tool result**

```

.. _MySQL documentation: https://dev.mysql.com/doc/refman/en/sql-mode.html#ignore-strict-comparison
.. _MariaDB documentation: https://mariadb.com/kb/en/ignore/

.. versionchanged:: 4.0

    Support for the fetching primary key attributes on SQLite 3.35+ was added.

``bulk_update()``
~~~~~~~~~~~~~~~~~

.. method:: bulk_update(objs, fields, batch_size=None)

This method efficiently updates the given fields on the provided model
instances, generally with one query::

    >>> objs = [
    ...    Entry.objects.create(headline='Entry 1'),
    ...    Entry.objects.create(headline='Entry 2'),
    ... ]
    >>> objs[0].headline = 'This is entry 1'
    >>> objs[1].headline = 'This is entry 2'
    >>> Entry.objects.bulk_update(objs, ['headline'])

:meth:`.QuerySet.update` is used to save the changes, so this is more efficient
than iterating through the list of models and calling ``save()`` on each of
them, but it has a few caveats:

* You cannot update the model's primary key.
* Each model's ``save()`` method isn't called, and the
  :attr:`~django.db.models.signals.pre_save` and
  :attr:`~django.db.models.signals.post_save` signals aren't sent.
* If updating a large number of columns in a large number of rows, the SQL
  generated can be very large. Avoid this by specifying a suitable
  ``batch_size``.
* Updating fields defined on multi-table inheritance ancestors will incur an
  extra query per ancestor.
* When an individual batch contains duplicates, only the first instance in that
  batch will result in an update.

The ``batch_size`` parameter controls how many objects are saved in a single
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
    Member, Note, Number, Order, Paragraph, SpecialCategory, Tag, Valid,
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
            note.note = 'test-%s' % note.id
        with self.assertNumQueries(1):
            Note.objects.bulk_update(self.notes, ['note'])
        self.assertCountEqual(
            Note.objects.values_list('note', flat=True),
            [cat.note for cat in self.notes]
        )

    def test_multiple_fields(self):
        for note in self.notes:
            note.note = 'test-%s' % note.id
            note.misc = 'misc-%s' % note.id
        with self.assertNumQueries(1):
            Note.objects.bulk_update(self.notes, ['note', 'misc'])
        self.assertCountEqual(
            Note.objects.values_list('note', flat=True),
            [cat.note for cat in self.notes]
        )
        self.assertCountEqual(
            Note.objects.values_list('misc', flat=True),
            [cat.misc for cat in self.notes]
        )

    def test_batch_size(self):
        with self.assertNumQueries(len(self.notes)):
            Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)

    def test_unsaved_models(self):
        objs = self.notes + [Note(note='test', misc='test')]
        msg = 'All bulk_update() objects must have a primary key set.'
        with self.assertRaisesMessage(ValueError, msg):
            Note.objects.bulk_update(objs, fields=['note'])

    def test_foreign_keys_do_not_lookup(self):
        self.create_tags()
        for note, tag in zip(self.notes, self.tags):
            note.tag = tag
        with self.assertNumQueries(1):
            Note.objects.bulk_update(self.notes, ['tag'])
        self.assertSequenceEqual(Note.objects.filter(tag__isnull=False), self.notes)

    def test_set_field_to_null(self):
        self.create_tags()
        Note.objects.update(tag=self.tags[0])
        for note in self.notes:
            note.tag = None
        Note.objects.bulk_update(self.notes, ['tag'])
        self.assertCountEqual(Note.objects.filter(tag__isnull=True), self.notes)

    def test_set_mixed_fields_to_null(self):
        self.create_tags()
        midpoint = len(self.notes) // 2
        top, bottom = self.notes[:midpoint], self.notes[midpoint:]
        for note in top:
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


class BulkUpdateTests(TestCase):
    def test_no_fields(self):
        msg = 'Field names must be given to bulk_update().'
        with self.assertRaisesMessage(ValueError, msg):
            Note.objects.bulk_update([], fields=[])

    def test_invalid_batch_size(self):
        msg = 'Batch size must be a positive integer.'
        with self.assertRaisesMessage(ValueError, msg):
            Note.objects.bulk_update([], fields=['note'], batch_size=-1)

    def test_nonexistent_field(self):
        with self.assertRaisesMessage(FieldDoesNotExist, "Note has no field named 'nonexistent'"):
            Note.objects.bulk_update([], ['nonexistent'])

    pk_fields_error = 'bulk_update() cannot be used with primary key fields.'

    def test_update_primary_key(self):
        with self.assertRaisesMessage(ValueError, self.pk_fields_error):
            Note.objects.bulk_update([], ['id'])

    def test_update_custom_primary_key(self):
        with self.assertRaisesMessage(ValueError, self.pk_fields_error):
            CustomPk.objects.bulk_update([], ['name'])

    def test_empty_objects(self):
        with self.assertNumQueries(0):
            Note.objects.bulk_update([], ['note'])

    def test_large_batch(self):
        Note.objects.bulk_create([
            Note(note=str(i), misc=str(i))
            for i in range(0, 2000)
        ])
        notes = list(Note.objects.all())
        Note.objects.bulk_update(notes, ['note'])

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
                    for _ in range(10)
                ]
                for model in models:
                    model.ip_address = ip
                CustomDbColumn.objects.bulk_update(models, ['ip_address'])
                self.assertCountEqual(CustomDbColumn.objects.filter(ip_address=ip), models)

    def test_datetime_field(self):
        articles = [
            Article.objects.create(name=str(i), created=datetime.datetime.today())
            for i in range(10)
        ]
        point_in_time = datetime.datetime(1991, 10, 31)
        for article in articles:
            article.created = point_in_time
        Article.objects.bulk_update(articles, ['created'])
        self.assertCountEqual(Article.objects.filter(created=point_in_time), articles)

    @skipUnlessDBFeature('supports_json_field')
    def test_json_field(self):
        JSONFieldNullable.objects.bulk_create([
            JSONFieldNullable(json_field={'a': i}) for i in range(10)
        ])
        objs = JSONFieldNullable.objects.all()
        for obj in objs:
            obj.json_field = {'c': obj.json_field['a'] + 1}
        JSONFieldNullable.objects.bulk_update(objs, ['json_field'])
        self.assertCountEqual(JSONFieldNullable.objects.filter(json_field__has_key='c'), objs)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/db/models/query.py\n@@\n         if any(f.primary_key for f in fields):\n             raise ValueError('bulk_update() cannot be used with primary key fields.')\n         if not objs:\n-            return\n+            return 0\n@@\n         with transaction.atomic(using=self.db, savepoint=False):\n+            rows_updated = 0\n             for pks, update_kwargs in updates:\n-                self.filter(pk__in=pks).update(**update_kwargs)\n+                rows_updated += self.filter(pk__in=pks).update(**update_kwargs)\n+        return rows_updated\n*** Update File: /testbed/docs/ref/models/querysets.txt\n@@\n     >>> objs[1].headline = 'This is entry 2'\n     >>> Entry.objects.bulk_update(objs, ['headline'])\n \n+Returns the number of rows matched by the update query.\n+\n :meth:`.QuerySet.update` is used to save the changes, so this is more efficient\n*** Update File: /testbed/tests/queries/test_bulk_update.py\n@@\n     def test_simple(self):\n         for note in self.notes:\n             note.note = 'test-%s' % note.id\n         with self.assertNumQueries(1):\n-            Note.objects.bulk_update(self.notes, ['note'])\n+            rows_updated = Note.objects.bulk_update(self.notes, ['note'])\n+        self.assertEqual(rows_updated, len(self.notes))\n         self.assertCountEqual(\n             Note.objects.values_list('note', flat=True),\n             [cat.note for cat in self.notes]\n         )\n@@\n     def test_batch_size(self):\n         with self.assertNumQueries(len(self.notes)):\n-            Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)\n+            rows_updated = Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)\n+        self.assertEqual(rows_updated, len(self.notes))\n@@\n     def test_empty_objects(self):\n         with self.assertNumQueries(0):\n-            Note.objects.bulk_update([], ['note'])\n+            rows_updated = Note.objects.bulk_update([], ['note'])\n+        self.assertEqual(rows_updated, 0)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/db/models/query.py /testbed/docs/ref/models/querysets.txt /testbed/tests/queries/test_bulk_update.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/db/models/query.py now (2035 lines), around the change:
541:        if any(f.primary_key for f in fields):
542:            raise ValueError('bulk_update() cannot be used with primary key fields.')
543:        if not objs:
544:            return 0
545:        # PK is used twice in the resulting update query, once in the filter
546:        # and once in the WHEN. Each field will also have one CAST.
547:        max_batch_size = connections[self.db].ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
…
564:                update_kwargs[field.attname] = case_statement
565:            updates.append(([obj.pk for obj in batch_objs], update_kwargs))
566:        with transaction.atomic(using=self.db, savepoint=False):
567:            rows_updated = 0
568:            for pks, update_kwargs in updates:
569:                rows_updated += self.filter(pk__in=pks).update(**update_kwargs)
570:        return rows_updated
571:    bulk_update.alters_data = True
572:
573:    def get_or_create(self, defaults=None, **kwargs):

/testbed/docs/ref/models/querysets.txt now (3817 lines), around the change:
2231:    >>> objs[1].headline = 'This is entry 2'
2232:    >>> Entry.objects.bulk_update(objs, ['headline'])
2233:
2234:Returns the number of rows matched by the update query.
2235:
2236::meth:`.QuerySet.update` is used to save the changes, so this is more efficient
2237:than iterating through the list of models and calling ``save()`` on each of
2238:them, but it has a few caveats:

/testbed/tests/queries/test_bulk_update.py now (245 lines), around the change:
29:        for note in self.notes:
30:            note.note = 'test-%s' % note.id
31:        with self.assertNumQueries(1):
32:            rows_updated = Note.objects.bulk_update(self.notes, ['note'])
33:        self.assertEqual(rows_updated, len(self.notes))
34:        self.assertCountEqual(
35:            Note.objects.values_list('note', flat=True),
36:            [cat.note for cat in self.notes]
…
53:
54:    def test_batch_size(self):
55:        with self.assertNumQueries(len(self.notes)):
56:            rows_updated = Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)
57:        self.assertEqual(rows_updated, len(self.notes))
58:
59:    def test_unsaved_models(self):
60:        objs = self.notes + [Note(note='test', misc='test')]
…
127:
128:    def test_empty_objects(self):
129:        with self.assertNumQueries(0):
130:            rows_updated = Note.objects.bulk_update([], ['note'])
131:        self.assertEqual(rows_updated, 0)
132:
133:    def test_large_batch(self):
134:        Note.objects.bulk_create([
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py queries.test_bulk_update --verbosity 1 2>&1 | tail -30"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 25 test(s).
Creating test database for alias 'default'...
System check identified no issues (1 silenced).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
.........................
----------------------------------------------------------------------
Ran 25 tests in 0.483s

OK
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
  "command": "git diff --stat && git diff django/db/models/query.py"
}
```

**tool result**

```
 django/db/models/query.py         | 6 ++++--
 docs/ref/models/querysets.txt     | 2 ++
 tests/queries/test_bulk_update.py | 9 ++++++---
 3 files changed, 12 insertions(+), 5 deletions(-)
diff --git a/django/db/models/query.py b/django/db/models/query.py
index 387deca527..7fce385d30 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -541,7 +541,7 @@ class QuerySet:
         if any(f.primary_key for f in fields):
             raise ValueError('bulk_update() cannot be used with primary key fields.')
         if not objs:
-            return
+            return 0
         # PK is used twice in the resulting update query, once in the filter
         # and once in the WHEN. Each field will also have one CAST.
         max_batch_size = connections[self.db].ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
@@ -564,8 +564,10 @@ class QuerySet:
                 update_kwargs[field.attname] = case_statement
             updates.append(([obj.pk for obj in batch_objs], update_kwargs))
         with transaction.atomic(using=self.db, savepoint=False):
+            rows_updated = 0
             for pks, update_kwargs in updates:
-                self.filter(pk__in=pks).update(**update_kwargs)
+                rows_updated += self.filter(pk__in=pks).update(**update_kwargs)
+        return rows_updated
     bulk_update.alters_data = True
 
     def get_or_create(self, defaults=None, **kwargs):
```

**assistant**

```
Implemented `bulk_update()` returning the number of rows matched.

Changes:
- `django/db/models/query.py`: accumulates each batch's `update()` return value and returns the total; returns `0` for an empty object list.
- `docs/ref/models/querysets.txt`: documents the return value.
- `tests/queries/test_bulk_update.py`: asserts the return value for single-batch, batched, and empty updates.

Verification: `python tests/runtests.py queries.test_bulk_update` — 25 tests passed.
```

## Run folder `team-solve-2026-11-06T110916`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
5d31c7b7ca29eea0454a6aacf5d8a356bd78a850
```

### `baseline-check.log`

```
check: python tests/runtests.py bulk_update
E
======================================================================
ERROR: bulk_update (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: bulk_update
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/loader.py", line 154, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'bulk_update'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 1 test(s).
System check identified no issues (0 silenced).
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/django/db/models/query.py b/django/db/models/query.py
index 387deca527..7fce385d30 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -541,7 +541,7 @@ class QuerySet:
         if any(f.primary_key for f in fields):
             raise ValueError('bulk_update() cannot be used with primary key fields.')
         if not objs:
-            return
+            return 0
         # PK is used twice in the resulting update query, once in the filter
         # and once in the WHEN. Each field will also have one CAST.
         max_batch_size = connections[self.db].ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
@@ -564,8 +564,10 @@ class QuerySet:
                 update_kwargs[field.attname] = case_statement
             updates.append(([obj.pk for obj in batch_objs], update_kwargs))
         with transaction.atomic(using=self.db, savepoint=False):
+            rows_updated = 0
             for pks, update_kwargs in updates:
-                self.filter(pk__in=pks).update(**update_kwargs)
+                rows_updated += self.filter(pk__in=pks).update(**update_kwargs)
+        return rows_updated
     bulk_update.alters_data = True
 
     def get_or_create(self, defaults=None, **kwargs):
diff --git a/docs/ref/models/querysets.txt b/docs/ref/models/querysets.txt
index 5dc7a6b5bc..080eabba2c 100644
--- a/docs/ref/models/querysets.txt
+++ b/docs/ref/models/querysets.txt
@@ -2231,6 +2231,8 @@ instances, generally with one query::
     >>> objs[1].headline = 'This is entry 2'
     >>> Entry.objects.bulk_update(objs, ['headline'])
 
+Returns the number of rows matched by the update query.
+
 :meth:`.QuerySet.update` is used to save the changes, so this is more efficient
 than iterating through the list of models and calling ``save()`` on each of
 them, but it has a few caveats:
diff --git a/tests/queries/test_bulk_update.py b/tests/queries/test_bulk_update.py
index be794df718..80b7499bd9 100644
--- a/tests/queries/test_bulk_update.py
+++ b/tests/queries/test_bulk_update.py
@@ -29,7 +29,8 @@ class BulkUpdateNoteTests(TestCase):
         for note in self.notes:
             note.note = 'test-%s' % note.id
         with self.assertNumQueries(1):
-            Note.objects.bulk_update(self.notes, ['note'])
+            rows_updated = Note.objects.bulk_update(self.notes, ['note'])
+        self.assertEqual(rows_updated, len(self.notes))
         self.assertCountEqual(
             Note.objects.values_list('note', flat=True),
             [cat.note for cat in self.notes]
@@ -52,7 +53,8 @@ class BulkUpdateNoteTests(TestCase):
 
     def test_batch_size(self):
         with self.assertNumQueries(len(self.notes)):
-            Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)
+            rows_updated = Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)
+        self.assertEqual(rows_updated, len(self.notes))
 
     def test_unsaved_models(self):
         objs = self.notes + [Note(note='test', misc='test')]
@@ -125,7 +127,8 @@ class BulkUpdateTests(TestCase):
 
     def test_empty_objects(self):
         with self.assertNumQueries(0):
-            Note.objects.bulk_update([], ['note'])
+            rows_updated = Note.objects.bulk_update([], ['note'])
+        self.assertEqual(rows_updated, 0)
 
     def test_large_batch(self):
         Note.objects.bulk_create([
```

### `check-kind.txt`

```
command
```

### `context.md`

````
# task.md

# Task

## Prompt

Include number of rows matched in bulk_update() return value
Description
	
Currently, bulk_update() returns None, unlike update(), which returns ​the number of rows matched.
It looks like it would be easy to add the same functionality to bulk_update() since bulk_update() simply calls update() repeatedly:
​https://github.com/django/django/blob/2b4b6c8af0aae8785bc1347cf1be2e8e70fd5ff3/django/db/models/query.py#L568
I.e. the return values could simply be added and returned.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py bulk_update`

## Scope

`django/db/models/query.py`
`tests/bulk_update/`
`docs/ref/models/querysets.txt`

## Done when

`bulk_update()` returns the total number of rows matched by the `update()` calls it performs.
`bulk_update()` returns `0` when given an empty iterable of objects.
The returned count is the number of rows matched, not simply the number of objects passed to `bulk_update()`.
Existing `bulk_update()` validation and batching behavior is unchanged.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py bulk_update`

## Scope
`django/db/models/query.py`
`tests/bulk_update/`
`docs/ref/models/querysets.txt`

## Done when
`bulk_update()` returns the total number of rows matched by the `update()` calls it performs.
`bulk_update()` returns `0` when given an empty iterable of objects.
The returned count is the number of rows matched, not simply the number of objects passed to `bulk_update()`.
Existing `bulk_update()` validation and batching behavior is unchanged.

## Approach
Decompose into: locate `QuerySet.bulk_update()` in `django/db/models/query.py`; initialize a counter; return `0` for empty `objs`; add each batch’s `update()` return value to the counter; return the counter. Add regression coverage under `tests/bulk_update/` for empty input, one batch, multiple batches, and matched-row semantics. Update the `bulk_update()` documentation to state the return value.

Candidate approaches:
1. Accumulate in the existing batch loop with `rows_updated += self.filter(...).update(...)` and return `rows_updated`. Preferred: minimal change, preserves batching, no extra memory.
2. Collect each batch result in a list and `sum()` it. Clear but unnecessary memory; a generator expression avoids that but is less explicit.
3. Return `len(objs)` after the loop. Reject: `update()` returns rows matched, and duplicate or missing primary keys can make that differ from the number of objects supplied.

If the first attempt fails, check the empty-input early return, ensure every path returns an integer, and verify the counter is outside the batch loop.


# django/db/models/query.py

```
"""
The main QuerySet implementation. This provides the public API for the ORM.
"""

import copy
import operator
import warnings
from itertools import chain

import django
from django.conf import settings
from django.core import exceptions
from django.db import (
    DJANGO_VERSION_PICKLE_KEY, IntegrityError, NotSupportedError, connections,
    router, transaction,
)
from django.db.models import AutoField, DateField, DateTimeField, sql
from django.db.models.constants import LOOKUP_SEP
from django.db.models.deletion import Collector
from django.db.models.expressions import Case, Expression, F, Ref, Value, When
from django.db.models.functions import Cast, Trunc
from django.db.models.query_utils import FilteredRelation, Q
from django.db.models.sql.constants import CURSOR, GET_ITERATOR_CHUNK_SIZE
from django.db.models.utils import create_namedtuple_class, resolve_callables
from django.utils import timezone
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
        # and annotations.
        results = compiler.execute_sql(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size)
        select, klass_info, annotation_col_map = (compiler.select, compiler.klass_info,
                                                  compiler.annotation_col_map)
        model_cls = klass_info['model']
        select_fields = klass_info['select_fields']
        model_fields_start, model_fields_end = select_fields[0], select_fields[-1] + 1
        init_list = [f[0].target.attname
                     for f in select[model_fields_start:model_fields_end]]
        related_populators = get_related_populators(klass_info, select, db)
        known_related_objects = [
            (field, related_objs, operator.attrgetter(*[
                field.attname
                if from_field == 'self' else
                queryset.model._meta.get_field(from_field).attname
                for from_field in field.from_fields
            ])) for field, related_objs in queryset._known_related_objects.items()
        ]
        for row in compiler.results_iter(results):
            obj = model_cls.from_db(db, init_list, row[model_fields_start:model_fields_end])
            for rel_populator in related_populators:
                rel_populator.populate(row, obj)
            if annotation_col_map:
                for attr_name, col_pos in annotation_col_map.items():
                    setattr(obj, attr_name, row[col_pos])

            # Add the known related objects to the model.
            for field, rel_objs, rel_getter in known_related_objects:
                # Avoid overwriting objects loaded by, e.g., select_related().
                if field.is_cached(obj):
                    continue
                rel_obj_id = rel_getter(obj)
                try:
                    rel_obj = rel_objs[rel_obj_id]
                except KeyError:
                    pass  # May happen in qs1 | qs2 scenarios.
                else:
                    setattr(obj, field.name, rel_obj)

            yield obj


class ValuesIterable(BaseIterable):
    """
    Iterable returned by QuerySet.values() that yields a dict for each row.
    """

    def __iter__(self):
        queryset = self.queryset
        query = queryset.query
        compiler = query.get_compiler(queryset.db)

        # extra(select=...) cols are always at the start of the row.
        names = [
            *query.extra_select,
            *query.values_select,
            *query.annotation_select,
        ]
        indexes = range(len(names))
        for row in compiler.results_iter(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size):
            yield {names[i]: row[i] for i in indexes}


class ValuesListIterable(BaseIterable):
    """
    Iterable returned by QuerySet.values_list(flat=False) that yields a tuple
    for each row.
    """

    def __iter__(self):
        queryset = self.queryset
        query = queryset.query
        compiler = query.get_compiler(queryset.db)

        if queryset._fields:
            # extra(select=...) cols are always at the start of the row.
            names = [
                *query.extra_select,
                *query.values_select,
                *query.annotation_select,
            ]
            fields = [*queryset._fields, *(f for f in query.annotation_select if f not in queryset._fields)]
            if fields != names:
                # Reorder according to fields.
                index_map = {name: idx for idx, name in enumerate(names)}
                rowfactory = operator.itemgetter(*[index_map[f] for f in fields])
                return map(
                    rowfactory,
                    compiler.results_iter(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size)
                )
        return compiler.results_iter(tuple_expected=True, chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size)


class NamedValuesListIterable(ValuesListIterable):
    """
    Iterable returned by QuerySet.values_list(named=True) that yields a
    namedtuple for each row.
    """

    def __iter__(self):
        queryset = self.queryset
        if queryset._fields:
            names = queryset._fields
        else:
            query = queryset.query
            names = [*query.extra_select, *query.values_select, *query.annotation_select]
        tuple_class = create_namedtuple_class(*names)
        new = tuple.__new__
        for row in super().__iter__():
            yield new(tuple_class, row)


class FlatValuesListIterable(BaseIterable):
    """
    Iterable returned by QuerySet.values_list(flat=True) that yields single
    values.
    """

    def __iter__(self):
        queryset = self.queryset
        compiler = queryset.query.get_compiler(queryset.db)
        for row in compiler.results_iter(chunked_fetch=self.chunked_fetch, chunk_size=self.chunk_size):
            yield row[0]


class QuerySet:
    """Represent a lazy database lookup for a set of objects."""

    def __init__(self, model=None, query=None, using=None, hints=None):
        self.model = model
        self._db = using
        self._hints = hints or {}
        self._query = query or sql.Query(self.model)
        self._result_cache = None
        self._sticky_filter = False
        self._for_write = False
        self._prefetch_related_lookups = ()
        self._prefetch_done = False
        self._known_related_objects = {}  # {rel_field: {pk: rel_obj}}
        self._iterable_class = ModelIterable
        self._fields = None
        self._defer_next_filter = False
        self._deferred_filter = None

    @property
    def query(self):
        if self._deferred_filter:
            negate, args, kwargs = self._deferred_filter
            self._filter_or_exclude_inplace(negate, args, kwargs)
            self._deferred_filter = None
        return self._query

    @query.setter
    def query(self, value):
        if value.values_select:
            self._iterable_class = ValuesIterable
        self._query = value

    def as_manager(cls):
        # Address the circular dependency between `Queryset` and `Manager`.
        from django.db.models.manager import Manager
        manager = Manager.from_queryset(cls)()
        manager._built_with_as_manager = True
        return manager
    as_manager.queryset_only = True
    as_manager = classmethod(as_manager)

    ########################
    # PYTHON MAGIC METHODS #
    ########################

    def __deepcopy__(self, memo):
        """Don't populate the QuerySet's cache."""
        obj = self.__class__()
        for k, v in self.__dict__.items():
            if k == '_result_cache':
                obj.__dict__[k] = None
            else:
                obj.__dict__[k] = copy.deepcopy(v, memo)
        return obj

    def __getstate__(self):
        # Force the cache to be fully populated.
        self._fetch_all()
        return {**self.__dict__, DJANGO_VERSION_PICKLE_KEY: django.__version__}

    def __setstate__(self, state):
        pickled_version = state.get(DJANGO_VERSION_PICKLE_KEY)
        if pickled_version:
            if pickled_version != django.__version__:
                warnings.warn(
                    "Pickled queryset instance's Django version %s does not "
                    "match the current version %s."
                    % (pickled_version, django.__version__),
                    RuntimeWarning,
                    stacklevel=2,
                )
        else:
            warnings.warn(
                "Pickled queryset instance's Django version is not specified.",
                RuntimeWarning,
                stacklevel=2,
            )
        self.__dict__.update(state)

    def __repr__(self):
        data = list(self[:REPR_OUTPUT_SIZE + 1])
        if len(data) > REPR_OUTPUT_SIZE:
            data[-1] = "...(remaining elements truncated)..."
        return '<%s %r>' % (self.__class__.__name__, data)

    def __len__(self):
        self._fetch_all()
        return len(self._result_cache)

    def __iter__(self):
        """
        The queryset iterator protocol uses three nested iterators in the
        default case:
            1. sql.compiler.execute_sql()
               - Returns 100 rows at time (constants.GET_ITERATOR_CHUNK_SIZE)
                 using cursor.fetchmany(). This part is responsible for
                 doing some column masking, and returning the rows in chunks.
            2. sql.compiler.results_iter()
               - Returns one row at time. At this point the rows are still just
                 tuples. In some cases the return values are converted to
                 Python values at this location.
            3. self.iterator()
               - Responsible for turning the rows into model objects.
        """
        self._fetch_all()
        return iter(self._result_cache)

    def __bool__(self):
        self._fetch_all()
        return bool(self._result_cache)

    def __getitem__(self, k):
        """Retrieve an item or slice from the set of results."""
        if not isinstance(k, (int, slice)):
            raise TypeError(
                'QuerySet indices must be integers or slices, not %s.'
                % type(k).__name__
            )
        assert ((not isinstance(k, slice) and (k >= 0)) or
                (isinstance(k, slice) and (k.start is None or k.start >= 0) and
                 (k.stop is None or k.stop >= 0))), \
            "Negative indexing is not supported."

        if self._result_cache is not None:
            return self._result_cache[k]

        if isinstance(k, slice):
            qs = self._chain()
            if k.start is not None:
                start = int(k.start)
            else:
                start = None
            if k.stop is not None:
                stop = int(k.stop)
            else:
                stop = None
            qs.query.set_limits(start, stop)
            return list(qs)[::k.step] if k.step else qs

        qs = self._chain()
        qs.query.set_limits(k, k + 1)
        qs._fetch_all()
        return qs._result_cache[0]

    def __class_getitem__(cls, *args, **kwargs):
        return cls

    def __and__(self, other):
        self._merge_sanity_check(other)
        if isinstance(other, EmptyQuerySet):
            return other
        if isinstance(self, EmptyQuerySet):
            return self
        combined = self._chain()
        combined._merge_known_related_objects(other)
        combined.query.combine(other.query, sql.AND)
        return combined

    def __or__(self, other):
        self._merge_sanity_check(other)
        if isinstance(self, EmptyQuerySet):
            return other
        if isinstance(other, EmptyQuerySet):
            return self
        query = self if self.query.can_filter() else self.model._base_manager.filter(pk__in=self.values('pk'))
        combined = query._chain()
        combined._merge_known_related_objects(other)
        if not other.query.can_filter():
            other = other.model._base_manager.filter(pk__in=other.values('pk'))
        combined.query.combine(other.query, sql.OR)
        return combined

    ####################################
    # METHODS THAT DO DATABASE QUERIES #
    ####################################

    def _iterator(self, use_chunked_fetch, chunk_size):
        yield from self._iterable_class(self, chunked_fetch=use_chunked_fetch, chunk_size=chunk_size)

    def iterator(self, chunk_size=2000):
        """
        An iterator over the results from applying this QuerySet to the
        database.
        """
        if chunk_size <= 0:
            raise ValueError('Chunk size must be strictly positive.')
        use_chunked_fetch = not connections[self.db].settings_dict.get('DISABLE_SERVER_SIDE_CURSORS')
        return self._iterator(use_chunked_fetch, chunk_size)

    def aggregate(self, *args, **kwargs):
        """
        Return a dictionary containing the calculations (aggregation)
        over the current queryset.

        If args is present the expression is passed as a kwarg using
        the Aggregate object's default alias.
        """
        if self.query.distinct_fields:
            raise NotImplementedError("aggregate() + distinct(fields) not implemented.")
        self._validate_values_are_expressions((*args, *kwargs.values()), method_name='aggregate')
        for arg in args:
            # The default_alias property raises TypeError if default_alias
            # can't be set automatically or AttributeError if it isn't an
            # attribute.
            try:
                arg.default_alias
            except (AttributeError, TypeError):
                raise TypeError("Complex aggregates require an alias")
            kwargs[arg.default_alias] = arg

        query = self.query.chain()
        for (alias, aggregate_expr) in kwargs.items():
            query.add_annotation(aggregate_expr, alias, is_summary=True)
            annotation = query.annotations[alias]
            if not annotation.contains_aggregate:
                raise TypeError("%s is not an aggregate expression" % alias)
            for expr in annotation.get_source_expressions():
                if expr.contains_aggregate and isinstance(expr, Ref) and expr.refs in kwargs:
                    name = expr.refs
                    raise exceptions.FieldError(
                        "Cannot compute %s('%s'): '%s' is an aggregate"
                        % (annotation.name, name, name)
                    )
        return query.get_aggregation(self.db, kwargs)

    def count(self):
        """
        Perform a SELECT COUNT() and return the number of records as an
        integer.

        If the QuerySet is already fully cached, return the length of the
        cached results set to avoid multiple SELECT COUNT(*) calls.
        """
        if self._result_cache is not None:
            return len(self._result_cache)

        return self.query.get_count(using=self.db)

    def get(self, *args, **kwargs):
        """
        Perform the query and return a single object matching the given
        keyword arguments.
        """
        if self.query.combinator and (args or kwargs):
            raise NotSupportedError(
                'Calling QuerySet.get(...) with filters after %s() is not '
                'supported.' % self.query.combinator
            )
        clone = self._chain() if self.query.combinator else self.filter(*args, **kwargs)
        if self.query.can_filter() and not self.query.distinct_fields:
            clone = clone.order_by()
        limit = None
        if not clone.query.select_for_update or connections[clone.db].features.supports_select_for_update_with_limit:
            limit = MAX_GET_RESULTS
            clone.query.set_limits(high=limit)
        num = len(clone)
        if num == 1:
            return clone._result_cache[0]
        if not num:
            raise self.model.DoesNotExist(
                "%s matching query does not exist." %
                self.model._meta.object_name
            )
        raise self.model.MultipleObjectsReturned(
            'get() returned more than one %s -- it returned %s!' % (
                self.model._meta.object_name,
                num if not limit or num < limit else 'more than %s' % (limit - 1),
            )
        )

    def create(self, **kwargs):
        """
        Create a new object with the given kwargs, saving it to the database
        and returning the created object.
        """
        obj = self.model(**kwargs)
        self._for_write = True
        obj.save(force_insert=True, using=self.db)
        return obj

    def _prepare_for_bulk_create(self, objs):
        for obj in objs:
            if obj.pk is None:
                # Populate new PK values.
                obj.pk = obj._meta.pk.get_pk_value_on_save(obj)
            obj._prepare_related_fields_for_save(operation_name='bulk_create')

    def bulk_create(self, objs, batch_size=None, ignore_conflicts=False):
        """
        Insert each of the instances into the database. Do *not* call
        save() on each of the instances, do not send any pre/post_save
        signals, and do not set the primary key attribute if it is an
        autoincrement field (except if features.can_return_rows_from_bulk_insert=True).
        Multi-table models are not supported.
        """
        # When you bulk insert you don't get the primary keys back (if it's an
        # autoincrement, except if can_return_rows_from_bulk_insert=True), so
        # you can't insert into the child tables which references this. There
        # are two workarounds:
        # 1) This could be implemented if you didn't have an autoincrement pk
        # 2) You could do it by doing O(n) normal inserts into the parent
        #    tables to get the primary keys back and then doing a single bulk
        #    insert into the childmost table.
        # We currently set the primary keys on the objects when using
        # PostgreSQL via the RETURNING ID clause. It should be possible for
        # Oracle as well, but the semantics for extracting the primary keys is
        # trickier so it's not done yet.
        assert batch_size is None or batch_size > 0
        # Check that the parents share the same concrete model with the our
        # model to detect the inheritance pattern ConcreteGrandParent ->
        # MultiTableParent -> ProxyChild. Simply checking self.model._meta.proxy
        # would not identify that case as involving multiple tables.
        for parent in self.model._meta.get_parent_list():
            if parent._meta.concrete_model is not self.model._meta.concrete_model:
                raise ValueError("Can't bulk create a multi-table inherited model")
        if not objs:
            return objs
        self._for_write = True
        connection = connections[self.db]
        opts = self.model._meta
        fields = opts.concrete_fields
        objs = list(objs)
        self._prepare_for_bulk_create(objs)
        with transaction.atomic(using=self.db, savepoint=False):
            objs_with_pk, objs_without_pk = partition(lambda o: o.pk is None, objs)
            if objs_with_pk:
                returned_columns = self._batched_insert(
                    objs_with_pk, fields, batch_size, ignore_conflicts=ignore_conflicts,
                )
                for obj_with_pk, results in zip(objs_with_pk, returned_columns):
                    for result, field in zip(results, opts.db_returning_fields):
                        if field != opts.pk:
                            setattr(obj_with_pk, field.attname, result)
                for obj_with_pk in objs_with_pk:
                    obj_with_pk._state.adding = False
                    obj_with_pk._state.db = self.db
            if objs_without_pk:
                fields = [f for f in fields if not isinstance(f, AutoField)]
                returned_columns = self._batched_insert(
                    objs_without_pk, fields, batch_size, ignore_conflicts=ignore_conflicts,
                )
                if connection.features.can_return_rows_from_bulk_insert and not ignore_conflicts:
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
        # PK is used twice in the resulting update query, once in the filter
        # and once in the WHEN. Each field will also have one CAST.
        max_batch_size = connections[self.db].ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
        batch_size = min(batch_size, max_batch_size) if batch_size else max_batch_size
        requires_casting = connections[self.db].features.requires_casted_case_in_updates
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
        with transaction.atomic(using=self.db, savepoint=False):
            rows_updated = 0
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
                raise

    def update_or_create(self, defaults=None, **kwargs):
        """
        Look up an object with the given kwargs, updating one with defaults
        if it exists, otherwise create a new one.
        Return a tuple (object, created), where created is a boolean
        specifying whether an object was created.
        """
        defaults = defaults or {}
        self._for_write = True
        with transaction.atomic(using=self.db):
            # Lock the row so that a concurrent update is blocked until
            # update_or_create() has performed its save.
            obj, created = self.select_for_update().get_or_create(defaults, **kwargs)
            if created:
                return obj, created
            for k, v in resolve_callables(defaults):
                setattr(obj, k, v)
            obj.save(using=self.db)
        return obj, False

    def _extract_model_params(self, defaults, **kwargs):
        """
        Prepare `params` for creating a model instance based on the given
        kwargs; for use by get_or_create().
        """
        defaults = defaults or {}
        params = {k: v for k, v in kwargs.items() if LOOKUP_SEP not in k}
        params.update(defaults)
        property_names = self.model._meta._property_names
        invalid_params = []
        for param in params:
            try:
                self.model._meta.get_field(param)
            except exceptions.FieldDoesNotExist:
                # It's okay to use a model's property if it has a setter.
                if not (param in property_names and getattr(self.model, param).fset):
                    invalid_params.append(param)
        if invalid_params:
            raise exceptions.FieldError(
                "Invalid field name(s) for model %s: '%s'." % (
                    self.model._meta.object_name,
                    "', '".join(sorted(invalid_params)),
                ))
        return params

    def _earliest(self, *fields):
        """
        Return the earliest object according to fields (if given) or by the
        model's Meta.get_latest_by.
        """
        if fields:
            order_by = fields
        else:
            order_by = getattr(self.model._meta, 'get_latest_by')
            if order_by and not isinstance(order_by, (tuple, list)):
                order_by = (order_by,)
        if order_by is None:
            raise ValueError(
                "earliest() and latest() require either fields as positional "
                "arguments or 'get_latest_by' in the model's Meta."
            )
        obj = self._chain()
        obj.query.set_limits(high=1)
        obj.query.clear_ordering(force_empty=True)
        obj.query.add_ordering(*order_by)
        return obj.get()

    def earliest(self, *fields):
        if self.query.is_sliced:
            raise TypeError('Cannot change a query once a slice has been taken.')
        return self._earliest(*fields)

    def latest(self, *fields):
        if self.query.is_sliced:
            raise TypeError('Cannot change a query once a slice has been taken.')
        return self.reverse()._earliest(*fields)

    def first(self):
        """Return the first object of a query or None if no match is found."""
        for obj in (self if self.ordered else self.order_by('pk'))[:1]:
            return obj

    def last(self):
        """Return the last object of a query or None if no match is found."""
        for obj in (self.reverse() if self.ordered else self.order_by('-pk'))[:1]:
            return obj

    def in_bulk(self, id_list=None, *, field_name='pk'):
        """
        Return a dictionary mapping each of the given IDs to the object with
        that ID. If `id_list` isn't provided, evaluate the entire QuerySet.
        """
        if self.query.is_sliced:
            raise TypeError("Cannot use 'limit' or 'offset' with in_bulk().")
        opts = self.model._meta
        unique_fields = [
            constraint.fields[0]
            for constraint in opts.total_unique_constraints
            if len(constraint.fields) == 1
        ]
        if (
            field_name != 'pk' and
            not opts.get_field(field_name).unique and
            field_name not in unique_fields and
            self.query.distinct_fields != (field_name,)
        ):
            raise ValueError("in_bulk()'s field_name must be a unique field but %r isn't." % field_name)
        if id_list is not None:
            if not id_list:
                return {}
            filter_key = '{}__in'.format(field_name)
            batch_size = connections[self.db].features.max_query_params
            id_list = tuple(id_list)
            # If the database has a limit on the number of query parameters
            # (e.g. SQLite), retrieve objects in batches if necessary.
            if batch_size and batch_size < len(id_list):
                qs = ()
                for offset in range(0, len(id_list), batch_size):
                    batch = id_list[offset:offset + batch_size]
                    qs += tuple(self.filter(**{filter_key: batch}).order_by())
            else:
                qs = self.filter(**{filter_key: id_list}).order_by()
        else:
            qs = self._chain()
        return {getattr(obj, field_name): obj for obj in qs}

    def delete(self):
        """Delete the records in the current QuerySet."""
        self._not_support_combined_queries('delete')
        if self.query.is_sliced:
            raise TypeError("Cannot use 'limit' or 'offset' with delete().")
        if self.query.distinct or self.query.distinct_fields:
            raise TypeError('Cannot call delete() after .distinct().')
        if self._fields is not None:
            raise TypeError("Cannot call delete() after .values() or .values_list()")

        del_query = self._chain()

        # The delete is actually 2 queries - one to find related objects,
        # and one to delete. Make sure that the discovery of related
        # objects is performed on the same database as the deletion.
        del_query._for_write = True

        # Disable non-supported fields.
        del_query.query.select_for_update = False
        del_query.query.select_related = False
        del_query.query.clear_ordering(force_empty=True)

        collector = Collector(using=del_query.db)
        collector.collect(del_query)
        deleted, _rows_count = collector.delete()

        # Clear the result cache, in case this QuerySet gets reused.
        self._result_cache = None
        return deleted, _rows_count

    delete.alters_data = True
    delete.queryset_only = True

    def _raw_delete(self, using):
        """
        Delete objects found from the given queryset in single direct SQL
        query. No signals are sent and there is no protection for cascades.
        """
        query = self.query.clone()
        query.__class__ = sql.DeleteQuery
        cursor = query.get_compiler(using).execute_sql(CURSOR)
        if cursor:
            with cursor:
                return cursor.rowcount
        return 0
    _raw_delete.alters_data = True

    def update(self, **kwargs):
        """
        Update all elements in the current QuerySet, setting all the given
        fields to the appropriate values.
        """
        self._not_support_combined_queries('update')
        if self.query.is_sliced:
            raise TypeError('Cannot update a query once a slice has been taken.')
        self._for_write = True
        query = self.query.chain(sql.UpdateQuery)
        query.add_update_values(kwargs)
        # Clear any annotations so that they won't be present in subqueries.
        query.annotations = {}
        with transaction.mark_for_rollback_on_error(using=self.db):
            rows = query.get_compiler(self.db).execute_sql(CURSOR)
        self._result_cache = None
        return rows
    update.alters_data = True

    def _update(self, values):
        """
        A version of update() that accepts field objects instead of field names.
        Used primarily for model saving and not intended for use by general
        code (it requires too much poking around at model internals to be
        useful at that level).
        """
        if self.query.is_sliced:
            raise TypeError('Cannot update a query once a slice has been taken.')
        query = self.query.chain(sql.UpdateQuery)
        query.add_update_fields(values)
        # Clear any annotations so that they won't be present in subqueries.
        query.annotations = {}
        self._result_cache = None
        return query.get_compiler(self.db).execute_sql(CURSOR)
    _update.alters_data = True
    _update.queryset_only = False

    def exists(self):
        if self._result_cache is None:
            return self.query.has_results(using=self.db)
        return bool(self._result_cache)

    def contains(self, obj):
        """Return True if the queryset contains an object."""
        self._not_support_combined_queries('contains')
        if self._fields is not None:
            raise TypeError(
                'Cannot call QuerySet.contains() after .values() or '
                '.values_list().'
            )
        try:
            if obj._meta.concrete_model != self.model._meta.concrete_model:
                return False
        except AttributeError:
            raise TypeError("'obj' must be a model instance.")
        if obj.pk is None:
            raise ValueError(
                'QuerySet.contains() cannot be used on unsaved objects.'
            )
        if self._result_cache is not None:
            return obj in self._result_cache
        return self.filter(pk=obj.pk).exists()

    def _prefetch_related_objects(self):
        # This method can only be called once the result cache has been filled.
        prefetch_related_objects(self._result_cache, *self._prefetch_related_lookups)
        self._prefetch_done = True

    def explain(self, *, format=None, **options):
        return self.query.explain(using=self.db, format=format, **options)

    ##################################################
    # PUBLIC METHODS THAT RETURN A QUERYSET SUBCLASS #
    ##################################################

    def raw(self, raw_query, params=(), translations=None, using=None):
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
        return self._filter_or_exclude(False, args, kwargs)

    def exclude(self, *args, **kwargs):
        """
        Return a new QuerySet instance with NOT (args) ANDed to the existing
        set.
        """
        self._not_support_combined_queries('exclude')
        return self._filter_or_exclude(True, args, kwargs)

    def _filter_or
```


# tests/bulk_update: not there yet (a file the work makes)


# docs/ref/models/querysets.txt

```
==========================
``QuerySet`` API reference
==========================

.. currentmodule:: django.db.models.query

This document describes the details of the ``QuerySet`` API. It builds on the
material presented in the :doc:`model </topics/db/models>` and :doc:`database
query </topics/db/queries>` guides, so you'll probably want to read and
understand those documents before reading this one.

Throughout this reference we'll use the :ref:`example Weblog models
<queryset-model-example>` presented in the :doc:`database query guide
</topics/db/queries>`.

.. _when-querysets-are-evaluated:

When ``QuerySet``\s are evaluated
=================================

Internally, a ``QuerySet`` can be constructed, filtered, sliced, and generally
passed around without actually hitting the database. No database activity
actually occurs until you do something to evaluate the queryset.

You can evaluate a ``QuerySet`` in the following ways:

* **Iteration.** A ``QuerySet`` is iterable, and it executes its database
  query the first time you iterate over it. For example, this will print
  the headline of all entries in the database::

      for e in Entry.objects.all():
          print(e.headline)

  Note: Don't use this if all you want to do is determine if at least one
  result exists. It's more efficient to use :meth:`~QuerySet.exists`.

* **Slicing.** As explained in :ref:`limiting-querysets`, a ``QuerySet`` can
  be sliced, using Python's array-slicing syntax. Slicing an unevaluated
  ``QuerySet`` usually returns another unevaluated ``QuerySet``, but Django
  will execute the database query if you use the "step" parameter of slice
  syntax, and will return a list. Slicing a ``QuerySet`` that has been
  evaluated also returns a list.

  Also note that even though slicing an unevaluated ``QuerySet`` returns
  another unevaluated ``QuerySet``, modifying it further (e.g., adding
  more filters, or modifying ordering) is not allowed, since that does not
  translate well into SQL and it would not have a clear meaning either.

* **Pickling/Caching.** See the following section for details of what
  is involved when `pickling QuerySets`_. The important thing for the
  purposes of this section is that the results are read from the database.

* **repr().** A ``QuerySet`` is evaluated when you call ``repr()`` on it.
  This is for convenience in the Python interactive interpreter, so you can
  immediately see your results when using the API interactively.

* **len().** A ``QuerySet`` is evaluated when you call ``len()`` on it.
  This, as you might expect, returns the length of the result list.

  Note: If you only need to determine the number of records in the set (and
  don't need the actual objects), it's much more efficient to handle a count
  at the database level using SQL's ``SELECT COUNT(*)``. Django provides a
  :meth:`~QuerySet.count` method for precisely this reason.

* **list().** Force evaluation of a ``QuerySet`` by calling ``list()`` on
  it. For example::

      entry_list = list(Entry.objects.all())

* **bool().** Testing a ``QuerySet`` in a boolean context, such as using
  ``bool()``, ``or``, ``and`` or an ``if`` statement, will cause the query
  to be executed. If there is at least one result, the ``QuerySet`` is
  ``True``, otherwise ``False``. For example::

      if Entry.objects.filter(headline="Test"):
         print("There is at least one Entry with the headline Test")

  Note: If you only want to determine if at least one result exists (and don't
  need the actual objects), it's more efficient to use :meth:`~QuerySet.exists`.

.. _pickling QuerySets:

Pickling ``QuerySet``\s
-----------------------

If you :mod:`pickle` a ``QuerySet``, this will force all the results to be loaded
into memory prior to pickling. Pickling is usually used as a precursor to
caching and when the cached queryset is reloaded, you want the results to
already be present and ready for use (reading from the database can take some
time, defeating the purpose of caching). This means that when you unpickle a
``QuerySet``, it contains the results at the moment it was pickled, rather
than the results that are currently in the database.

If you only want to pickle the necessary information to recreate the
``QuerySet`` from the database at a later time, pickle the ``query`` attribute
of the ``QuerySet``. You can then recreate the original ``QuerySet`` (without
any results loaded) using some code like this::

    >>> import pickle
    >>> query = pickle.loads(s)     # Assuming 's' is the pickled string.
    >>> qs = MyModel.objects.all()
    >>> qs.query = query            # Restore the original 'query'.

The ``query`` attribute is an opaque object. It represents the internals of
the query construction and is not part of the public API. However, it is safe
(and fully supported) to pickle and unpickle the attribute's contents as
described here.

.. admonition:: Restrictions on ``QuerySet.values_list()``

    If you recreate :meth:`QuerySet.values_list` using the pickled ``query``
    attribute, it will be converted to :meth:`QuerySet.values`::

        >>> import pickle
        >>> qs = Blog.objects.values_list('id', 'name')
        >>> qs
        <QuerySet [(1, 'Beatles Blog')]>
        >>> reloaded_qs = Blog.objects.all()
        >>> reloaded_qs.query = pickle.loads(pickle.dumps(qs.query))
        >>> reloaded_qs
        <QuerySet [{'id': 1, 'name': 'Beatles Blog'}]>

.. admonition:: You can't share pickles between versions

    Pickles of ``QuerySets`` are only valid for the version of Django that
    was used to generate them. If you generate a pickle using Django
    version N, there is no guarantee that pickle will be readable with
    Django version N+1. Pickles should not be used as part of a long-term
    archival strategy.

    Since pickle compatibility errors can be difficult to diagnose, such as
    silently corrupted objects, a ``RuntimeWarning`` is raised when you try to
    unpickle a queryset in a Django version that is different than the one in
    which it was pickled.

.. _queryset-api:

``QuerySet`` API
================

Here's the formal declaration of a ``QuerySet``:

.. class:: QuerySet(model=None, query=None, using=None, hints=None)

    Usually when you'll interact with a ``QuerySet`` you'll use it by
    :ref:`chaining filters <chaining-filters>`. To make this work, most
    ``QuerySet`` methods return new querysets. These methods are covered in
    detail later in this section.

    The ``QuerySet`` class has two public attributes you can use for
    introspection:

    .. attribute:: ordered

        ``True`` if the ``QuerySet`` is ordered — i.e. has an
        :meth:`order_by()` clause or a default ordering on the model.
        ``False`` otherwise.

    .. attribute:: db

        The database that will be used if this query is executed now.

    .. note::

        The ``query`` parameter to :class:`QuerySet` exists so that specialized
        query subclasses can reconstruct internal query state. The value of the
        parameter is an opaque representation of that query state and is not
        part of a public API.

.. currentmodule:: django.db.models.query.QuerySet

Methods that return new ``QuerySet``\s
--------------------------------------

Django provides a range of ``QuerySet`` refinement methods that modify either
the types of results returned by the ``QuerySet`` or the way its SQL query is
executed.

``filter()``
~~~~~~~~~~~~

.. method:: filter(**kwargs)

Returns a new ``QuerySet`` containing objects that match the given lookup
parameters.

The lookup parameters (``**kwargs``) should be in the format described in
`Field lookups`_ below. Multiple parameters are joined via ``AND`` in the
underlying SQL statement.

If you need to execute more complex queries (for example, queries with ``OR`` statements),
you can use :class:`Q objects <django.db.models.Q>`.

``exclude()``
~~~~~~~~~~~~~

.. method:: exclude(**kwargs)

Returns a new ``QuerySet`` containing objects that do *not* match the given
lookup parameters.

The lookup parameters (``**kwargs``) should be in the format described in
`Field lookups`_ below. Multiple parameters are joined via ``AND`` in the
underlying SQL statement, and the whole thing is enclosed in a ``NOT()``.

This example excludes all entries whose ``pub_date`` is later than 2005-1-3
AND whose ``headline`` is "Hello"::

    Entry.objects.exclude(pub_date__gt=datetime.date(2005, 1, 3), headline='Hello')

In SQL terms, that evaluates to:

.. code-block:: sql

    SELECT ...
    WHERE NOT (pub_date > '2005-1-3' AND headline = 'Hello')

This example excludes all entries whose ``pub_date`` is later than 2005-1-3
OR whose headline is "Hello"::

    Entry.objects.exclude(pub_date__gt=datetime.date(2005, 1, 3)).exclude(headline='Hello')

In SQL terms, that evaluates to:

.. code-block:: sql

    SELECT ...
    WHERE NOT pub_date > '2005-1-3'
    AND NOT headline = 'Hello'

Note the second example is more restrictive.

If you need to execute more complex queries (for example, queries with ``OR`` statements),
you can use :class:`Q objects <django.db.models.Q>`.

``annotate()``
~~~~~~~~~~~~~~

.. method:: annotate(*args, **kwargs)

Annotates each object in the ``QuerySet`` with the provided list of :doc:`query
expressions </ref/models/expressions>`. An expression may be a simple value, a
reference to a field on the model (or any related models), or an aggregate
expression (averages, sums, etc.) that has been computed over the objects that
are related to the objects in the ``QuerySet``.

Each argument to ``annotate()`` is an annotation that will be added
to each object in the ``QuerySet`` that is returned.

The aggregation functions that are provided by Django are described
in `Aggregation Functions`_ below.

Annotations specified using keyword arguments will use the keyword as
the alias for the annotation. Anonymous arguments will have an alias
generated for them based upon the name of the aggregate function and
the model field that is being aggregated. Only aggregate expressions
that reference a single field can be anonymous arguments. Everything
else must be a keyword argument.

For example, if you were manipulating a list of blogs, you may want
to determine how many entries have been made in each blog::

    >>> from django.db.models import Count
    >>> q = Blog.objects.annotate(Count('entry'))
    # The name of the first blog
    >>> q[0].name
    'Blogasaurus'
    # The number of entries on the first blog
    >>> q[0].entry__count
    42

The ``Blog`` model doesn't define an ``entry__count`` attribute by itself,
but by using a keyword argument to specify the aggregate function, you can
control the name of the annotation::

    >>> q = Blog.objects.annotate(number_of_entries=Count('entry'))
    # The number of entries on the first blog, using the name provided
    >>> q[0].number_of_entries
    42

For an in-depth discussion of aggregation, see :doc:`the topic guide on
Aggregation </topics/db/aggregation>`.

``alias()``
~~~~~~~~~~~

.. method:: alias(*args, **kwargs)

.. versionadded:: 3.2

Same as :meth:`annotate`, but instead of annotating objects in the
``QuerySet``, saves the expression for later reuse with other ``QuerySet``
methods. This is useful when the result of the expression itself is not needed
but it is used for filtering, ordering, or as a part of a complex expression.
Not selecting the unused value removes redundant work from the database which
should result in better performance.

For example, if you want to find blogs with more than 5 entries, but are not
interested in the exact number of entries, you could do this::

    >>> from django.db.models import Count
    >>> blogs = Blog.objects.alias(entries=Count('entry')).filter(entries__gt=5)

``alias()`` can be used in conjunction with :meth:`annotate`, :meth:`exclude`,
:meth:`filter`, :meth:`order_by`, and :meth:`update`. To use aliased expression
with other methods (e.g. :meth:`aggregate`), you must promote it to an
annotation::

    Blog.objects.alias(entries=Count('entry')).annotate(
        entries=F('entries'),
    ).aggregate(Sum('entries'))

:meth:`filter` and :meth:`order_by` can take expressions directly, but
expression construction and usage often does not happen in the same place (for
example, ``QuerySet`` method creates expressions, for later use in views).
``alias()`` allows building complex expressions incrementally, possibly
spanning multiple methods and modules, refer to the expression parts by their
aliases and only use :meth:`annotate` for the final result.

``order_by()``
~~~~~~~~~~~~~~

.. method:: order_by(*fields)

By default, results returned by a ``QuerySet`` are ordered by the ordering
tuple given by the ``ordering`` option in the model's ``Meta``. You can
override this on a per-``QuerySet`` basis by using the ``order_by`` method.

Example::

    Entry.objects.filter(pub_date__year=2005).order_by('-pub_date', 'headline')

The result above will be ordered by ``pub_date`` descending, then by
``headline`` ascending. The negative sign in front of ``"-pub_date"`` indicates
*descending* order. Ascending order is implied. To order randomly, use ``"?"``,
like so::

    Entry.objects.order_by('?')

Note: ``order_by('?')`` queries may be expensive and slow, depending on the
database backend you're using.

To order by a field in a different model, use the same syntax as when you are
querying across model relations. That is, the name of the field, followed by a
double underscore (``__``), followed by the name of the field in the new model,
and so on for as many models as you want to join. For example::

    Entry.objects.order_by('blog__name', 'headline')

If you try to order by a field that is a relation to another model, Django will
use the default ordering on the related model, or order by the related model's
primary key if there is no :attr:`Meta.ordering
<django.db.models.Options.ordering>` specified. For example, since the ``Blog``
model has no default ordering specified::

    Entry.objects.order_by('blog')

...is identical to::

    Entry.objects.order_by('blog__id')

If ``Blog`` had ``ordering = ['name']``, then the first queryset would be
identical to::

    Entry.objects.order_by('blog__name')

You can also order by :doc:`query expressions </ref/models/expressions>` by
calling :meth:`~.Expression.asc` or :meth:`~.Expression.desc` on the
expression::

    Entry.objects.order_by(Coalesce('summary', 'headline').desc())

:meth:`~.Expression.asc` and :meth:`~.Expression.desc` have arguments
(``nulls_first`` and ``nulls_last``) that control how null values are sorted.

Be cautious when ordering by fields in related models if you are also using
:meth:`distinct()`. See the note in :meth:`distinct` for an explanation of how
related model ordering can change the expected results.

.. note::
    It is permissible to specify a multi-valued field to order the results by
    (for example, a :class:`~django.db.models.ManyToManyField` field, or the
    reverse relation of a :class:`~django.db.models.ForeignKey` field).

    Consider this case::

         class Event(Model):
            parent = models.ForeignKey(
                'self',
                on_delete=models.CASCADE,
                related_name='children',
            )
            date = models.DateField()

         Event.objects.order_by('children__date')

    Here, there could potentially be multiple ordering data for each ``Event``;
    each ``Event`` with multiple ``children`` will be returned multiple times
    into the new ``QuerySet`` that ``order_by()`` creates. In other words,
    using ``order_by()`` on the ``QuerySet`` could return more items than you
    were working on to begin with - which is probably neither expected nor
    useful.

    Thus, take care when using multi-valued field to order the results. **If**
    you can be sure that there will only be one ordering piece of data for each
    of the items you're ordering, this approach should not present problems. If
    not, make sure the results are what you expect.

There's no way to specify whether ordering should be case sensitive. With
respect to case-sensitivity, Django will order results however your database
backend normally orders them.

You can order by a field converted to lowercase with
:class:`~django.db.models.functions.Lower` which will achieve case-consistent
ordering::

    Entry.objects.order_by(Lower('headline').desc())

If you don't want any ordering to be applied to a query, not even the default
ordering, call :meth:`order_by()` with no parameters.

You can tell if a query is ordered or not by checking the
:attr:`.QuerySet.ordered` attribute, which will be ``True`` if the
``QuerySet`` has been ordered in any way.

Each ``order_by()`` call will clear any previous ordering. For example, this
query will be ordered by ``pub_date`` and not ``headline``::

    Entry.objects.order_by('headline').order_by('pub_date')

.. warning::

    Ordering is not a free operation. Each field you add to the ordering
    incurs a cost to your database. Each foreign key you add will
    implicitly include all of its default orderings as well.

    If a query doesn't have an ordering specified, results are returned from
    the database in an unspecified order. A particular ordering is guaranteed
    only when ordering by a set of fields that uniquely identify each object in
    the results. For example, if a ``name`` field isn't unique, ordering by it
    won't guarantee objects with the same name always appear in the same order.

``reverse()``
~~~~~~~~~~~~~

.. method:: reverse()

Use the ``reverse()`` method to reverse the order in which a queryset's
elements are returned. Calling ``reverse()`` a second time restores the
ordering back to the normal direction.

To retrieve the "last" five items in a queryset, you could do this::

    my_queryset.reverse()[:5]

Note that this is not quite the same as slicing from the end of a sequence in
Python. The above example will return the last item first, then the
penultimate item and so on. If we had a Python sequence and looked at
``seq[-5:]``, we would see the fifth-last item first. Django doesn't support
that mode of access (slicing from the end), because it's not possible to do it
efficiently in SQL.

Also, note that ``reverse()`` should generally only be called on a ``QuerySet``
which has a defined ordering (e.g., when querying against a model which defines
a default ordering, or when using :meth:`order_by()`). If no such ordering is
defined for a given ``QuerySet``, calling ``reverse()`` on it has no real
effect (the ordering was undefined prior to calling ``reverse()``, and will
remain undefined afterward).

``distinct()``
~~~~~~~~~~~~~~

.. method:: distinct(*fields)

Returns a new ``QuerySet`` that uses ``SELECT DISTINCT`` in its SQL query. This
eliminates duplicate rows from the query results.

By default, a ``QuerySet`` will not eliminate duplicate rows. In practice, this
is rarely a problem, because simple queries such as ``Blog.objects.all()``
don't introduce the possibility of duplicate result rows. However, if your
query spans multiple tables, it's possible to get duplicate results when a
``QuerySet`` is evaluated. That's when you'd use ``distinct()``.

.. note::
    Any fields used in an :meth:`order_by` call are included in the SQL
    ``SELECT`` columns. This can sometimes lead to unexpected results when used
    in conjunction with ``distinct()``. If you order by fields from a related
    model, those fields will be added to the selected columns and they may make
    otherwise duplicate rows appear to be distinct. Since the extra columns
    don't appear in the returned results (they are only there to support
    ordering), it sometimes looks like non-distinct results are being returned.

    Similarly, if you use a :meth:`values()` query to restrict the columns
    selected, the columns used in any :meth:`order_by()` (or default model
    ordering) will still be involved and may affect uniqueness of the results.

    The moral here is that if you are using ``distinct()`` be careful about
    ordering by related models. Similarly, when using ``distinct()`` and
    :meth:`values()` together, be careful when ordering by fields not in the
    :meth:`values()` call.

On PostgreSQL only, you can pass positional arguments (``*fields``) in order to
specify the names of fields to which the ``DISTINCT`` should apply. This
translates to a ``SELECT DISTINCT ON`` SQL query. Here's the difference. For a
normal ``distinct()`` call, the database compares *each* field in each row when
determining which rows are distinct. For a ``distinct()`` call with specified
field names, the database will only compare the specified field names.

.. note::
    When you specify field names, you *must* provide an ``order_by()`` in the
    ``QuerySet``, and the fields in ``order_by()`` must start with the fields in
    ``distinct()``, in the same order.

    For example, ``SELECT DISTINCT ON (a)`` gives you the first row for each
    value in column ``a``. If you don't specify an order, you'll get some
    arbitrary row.

Examples (those after the first will only work on PostgreSQL)::

    >>> Author.objects.distinct()
    [...]

    >>> Entry.objects.order_by('pub_date').distinct('pub_date')
    [...]

    >>> Entry.objects.order_by('blog').distinct('blog')
    [...]

    >>> Entry.objects.order_by('author', 'pub_date').distinct('author', 'pub_date')
    [...]

    >>> Entry.objects.order_by('blog__name', 'mod_date').distinct('blog__name', 'mod_date')
    [...]

    >>> Entry.objects.order_by('author', 'pub_date').distinct('author')
    [...]

.. note::
    Keep in mind that :meth:`order_by` uses any default related model ordering
    that has been defined. You might have to explicitly order by the relation
    ``_id`` or referenced field to make sure the ``DISTINCT ON`` expressions
    match those at the beginning of the ``ORDER BY`` clause. For example, if
    the ``Blog`` model defined an :attr:`~django.db.models.Options.ordering` by
    ``name``::

        Entry.objects.order_by('blog').distinct('blog')

    ...wouldn't work because the query would be ordered by ``blog__name`` thus
    mismatching the ``DISTINCT ON`` expression. You'd have to explicitly order
    by the relation ``_id`` field (``blog_id`` in this case) or the referenced
    one (``blog__pk``) to make sure both expressions match.

``values()``
~~~~~~~~~~~~

.. method:: values(*fields, **expressions)

Returns a ``QuerySet`` that returns dictionaries, rather than model instances,
when used as an iterable.

Each of those dictionaries represents an object, with the keys corresponding to
the attribute names of model objects.

This example compares the dictionaries of ``values()`` with the normal model
objects::

    # This list contains a Blog object.
    >>> Blog.objects.filter(name__startswith='Beatles')
    <QuerySet [<Blog: Beatles Blog>]>

    # This list contains a dictionary.
    >>> Blog.objects.filter(name__startswith='Beatles').values()
    <QuerySet [{'id': 1, 'name': 'Beatles Blog', 'tagline': 'All the latest Beatles news.'}]>

The ``values()`` method takes optional positional arguments, ``*fields``, which
specify field names to which the ``SELECT`` should be limited. If you specify
the fields, each dictionary will contain only the field keys/values for the
fields you specify. If you don't specify the fields, each dictionary will
contain a key and value for every field in the database table.

Example::

    >>> Blog.objects.values()
    <QuerySet [{'id': 1, 'name': 'Beatles Blog', 'tagline': 'All the latest Beatles news.'}]>
    >>> Blog.objects.values('id', 'name')
    <QuerySet [{'id': 1, 'name': 'Beatles Blog'}]>

The ``values()`` method also takes optional keyword arguments,
``**expressions``, which are passed through to :meth:`annotate`::

    >>> from django.db.models.functions import Lower
    >>> Blog.objects.values(lower_name=Lower('name'))
    <QuerySet [{'lower_name': 'beatles blog'}]>

You can use built-in and :doc:`custom lookups </howto/custom-lookups>` in
ordering. For example::

    >>> from django.db.models import CharField
    >>> from django.db.models.functions import Lower
    >>> CharField.register_lookup(Lower)
    >>> Blog.objects.values('name__lower')
    <QuerySet [{'name__lower': 'beatles blog'}]>

An aggregate within a ``values()`` clause is applied before other arguments
within the same ``values()`` clause. If you need to group by another value,
add it to an earlier ``values()`` clause instead. For example::

    >>> from django.db.models import Count
    >>> Blog.objects.values('entry__authors', entries=Count('entry'))
    <QuerySet [{'entry__authors': 1, 'entries': 20}, {'entry__authors': 1, 'entries': 13}]>
    >>> Blog.objects.values('entry__authors').annotate(entries=Count('entry'))
    <QuerySet [{'entry__authors': 1, 'entries': 33}]>

A few subtleties that are worth mentioning:

* If you have a field called ``foo`` that is a
  :class:`~django.db.models.ForeignKey`, the default ``values()`` call
  will return a dictionary key called ``foo_id``, since this is the name
  of the hidden model attribute that stores the actual value (the ``foo``
  attribute refers to the related model). When you are calling
  ``values()`` and passing in field names, you can pass in either ``foo``
  or ``foo_id`` and you will get back the same thing (the dictionary key
  will match the field name you passed in).

  For example::

    >>> Entry.objects.values()
    <QuerySet [{'blog_id': 1, 'headline': 'First Entry', ...}, ...]>

    >>> Entry.objects.values('blog')
    <QuerySet [{'blog': 1}, ...]>

    >>> Entry.objects.values('blog_id')
    <QuerySet [{'blog_id': 1}, ...]>

* When using ``values()`` together with :meth:`distinct()`, be aware that
  ordering can affect the results. See the note in :meth:`distinct` for
  details.

* If you use a ``values()`` clause after an :meth:`extra()` call,
  any fields defined by a ``select`` argument in the :meth:`extra()` must
  be explicitly included in the ``values()`` call. Any :meth:`extra()` call
  made after a ``values()`` call will have its extra selected fields
  ignored.

* Calling :meth:`only()` and :meth:`defer()` after ``values()`` doesn't make
  sense, so doing so will raise a ``TypeError``.

* Combining transforms and aggregates requires the use of two :meth:`annotate`
  calls, either explicitly or as keyword arguments to :meth:`values`. As above,
  if the transform has been registered on the relevant field type the first
  :meth:`annotate` can be omitted, thus the following examples are equivalent::

    >>> from django.db.models import CharField, Count
    >>> from django.db.models.functions import Lower
    >>> CharField.register_lookup(Lower)
    >>> Blog.objects.values('entry__authors__name__lower').annotate(entries=Count('entry'))
    <QuerySet [{'entry__authors__name__lower': 'test author', 'entries': 33}]>
    >>> Blog.objects.values(
    ...     entry__authors__name__lower=Lower('entry__authors__name')
    ... ).annotate(entries=Count('entry'))
    <QuerySet [{'entry__authors__name__lower': 'test author', 'entries': 33}]>
    >>> Blog.objects.annotate(
    ...     entry__authors__name__lower=Lower('entry__authors__name')
    ... ).values('entry__authors__name__lower').annotate(entries=Count('entry'))
    <QuerySet [{'entry__authors__name__lower': 'test author', 'entries': 33}]>

It is useful when you know you're only going to need values from a small number
of the available fields and you won't need the functionality of a model
instance object. It's more efficient to select only the fields you need to use.

Finally, note that you can call ``filter()``, ``order_by()``, etc. after the
``values()`` call, that means that these two calls are identical::

    Blog.objects.values().order_by('id')
    Blog.objects.order_by('id').values()

The people who made Django prefer to put all the SQL-affecting methods first,
followed (optionally) by any output-affecting methods (such as ``values()``),
but it doesn't really matter. This is your chance to really flaunt your
individualism.

You can also refer to fields on related models with reverse relations through
``OneToOneField``, ``ForeignKey`` and ``ManyToManyField`` attributes::

    >>> Blog.objects.values('name', 'entry__headline')
    <QuerySet [{'name': 'My blog', 'entry__headline': 'An entry'},
         {'name': 'My blog', 'entry__headline': 'Another entry'}, ...]>

.. warning::

   Because :class:`~django.db.models.ManyToManyField` attributes and reverse
   relations can have multiple related rows, including these can have a
   multiplier effect on the size of your result set. This will be especially
   pronounced if you include multiple such fields in your ``values()`` query,
   in which case all possible combinations will be returned.

``values_list()``
~~~~~~~~~~~~~~~~~

.. method:: values_list(*fields, flat=False, named=False)

This is similar to ``values()`` except that instead of returning dictionaries,
it returns tuples when iterated over. Each tuple contains the value from the
respective field or expression passed into the ``values_list()`` call — so the
first item is the first field, etc. For example::

    >>> Entry.objects.values_list('id', 'headline')
    <QuerySet [(1, 'First entry'), ...]>
    >>> from django.db.models.functions import Lower
    >>> Entry.objects.values_list('id', Lower('headline'))
    <QuerySet [(1, 'first entry'), ...]>

If you only pass in a single field, you can also pass in the ``flat``
parameter. If ``True``, this will mean the returned results are single values,
rather than one-tuples. An example should make the difference clearer::

    >>> Entry.objects.values_list('id').order_by('id')
    <QuerySet[(1,), (2,), (3,), ...]>

    >>> Entry.objects.values_list('id', flat=True).order_by('id')
    <QuerySet [1, 2, 3, ...]>

It is an error to pass in ``flat`` when there is more than one field.

You can pass ``named=True`` to get results as a
:func:`~python:collections.namedtuple`::

    >>> Entry.objects.values_list('id', 'headline', named=True)
    <QuerySet [Row(id=1, headline='First entry'), ...]>

Using a named tuple may make use of the results more readable, at the expense
of a small performance penalty for transforming the results into a named tuple.

If you don't pass any values to ``values_list()``, it will return all the
fields in the model, in the order they were declared.

A common need is to get a specific field value of a certain model instance. To
achieve that, use ``values_list()`` followed by a ``get()`` call::

    >>> Entry.objects.values_list('headline', flat=True).get(pk=1)
    'First entry'

``values()`` and ``values_list()`` are both intended as optimizations for a
specific use case: retrieving a subset of data without the overhead of creating
a model instance. This metaphor falls apart when dealing with many-to-many and
other multivalued relations (such as the one-to-many relation of a reverse
foreign key) because the "one row, one object" assumption doesn't hold.

For example, notice the behavior when querying across a
:class:`~django.db.models.ManyToManyField`::

    >>> Author.objects.values_list('name', 'entry__headline')
    <QuerySet [('Noam Chomsky', 'Impressions of Gaza'),
     ('George Orwell', 'Why Socialists Do Not Believe in Fun'),
     ('George Orwell', 'In Defence of English Cooking'),
     ('Don Quixote', None)]>

Authors with multiple entries appear multiple times and authors without any
entries have ``None`` for the entry headline.

Similarly, when querying a reverse foreign key, ``None`` appears for entries
not having any author::

    >>> Entry.objects.values_list('authors')
    <QuerySet [('Noam Chomsky',), ('George Orwell',), (None,)]>

``dates()``
~~~~~~~~~~~

.. method:: dates(field, kind, order='ASC')

Returns a ``QuerySet`` that evaluates to a list of :class:`datetime.date`
objects representing all available dates of a particular kind within the
contents of the ``QuerySet``.

``field`` should be the name of a ``DateField`` of your model.
``kind`` should be either ``"year"``, ``"month"``, ``"week"``, or ``"day"``.
Each :class:`datetime.date` object in the result list is "truncated" to the
given ``type``.

* ``"year"`` returns a list of all distinct year values for the field.
* ``"month"`` returns a list of all distinct year/month values for the
  field.
* ``"week"`` returns a list of all distinct year/week values for the field. All
  dates will be a Monday.
* ``"day"`` returns a list of all distinct year/month/day values for the
  field.

``order``, which defaults to ``'ASC'``, should be either ``'ASC'`` or
``'DESC'``. This specifies how to order the results.

Examples::

    >>> Entry.objects.dates('pub_date', 'year')
    [datetime.date(2005, 1, 1)]
    >>> Entry.objects.dates('pub_date', 'month')
    [datetime.date(2005, 2, 1), datetime.date(2005, 3, 1)]
    >>> Entry.objects.dates('pub_date', 'week')
    [datetime.date(2005, 2, 14), datetime.date(2005, 3, 14)]
    >>> Entry.objects.dates('pub_date', 'day')
    [datetime.date(2005, 2, 20), datetime.date(2005, 3, 20)]
    >>> Entry.objects.dates('pub_date', 'day', order='DESC')
    [datetime.date(2005, 3, 20), datetime.date(2005, 2, 20)]
    >>> Entry.objects.filter(headline__contains='Lennon').dates('pub_date', 'day')
    [datetime.date(2005, 3, 20)]

``datetimes()``
~~~~~~~~~~~~~~~

.. method:: datetimes(field_name, kind, order='ASC', tzinfo=None, is_dst=None)

Returns a ``QuerySet`` that evaluates to a list of :class:`datetime.datetime`
objects representing all available dates of a particular kind within the
contents of the ``QuerySet``.

``field_name`` should be the name of a ``DateTimeField`` of your model.

``kind`` should be either ``"year"``, ``"month"``, ``"week"``, ``"day"``,
``"hour"``, ``"minute"``, or ``"second"``. Each :class:`datetime.datetime`
object in the result list is "truncated" to the given ``type``.

``order``, which defaults to ``'ASC'``, should be either ``'ASC'`` or
``'DESC'``. This specifies how to order the results.

``tzinfo`` defines the time zone to which datetimes are converted prior to
truncation. Indeed, a given datetime has different representations depending
on the time zone in use. This parameter must be a :class:`datetime.tzinfo`
object. If it's ``None``, Django uses the :ref:`current time zone
<default-current-time-zone>`. It has no effect when :setting:`USE_TZ` is
``False``.

``is_dst`` indicates whether or not ``pytz`` should interpret nonexistent and
ambiguous datetimes in daylight saving time. By default (when ``is_dst=None``),
``pytz`` raises an exception for such datetimes.

.. _database-time-zone-definitions:

.. note::

    This function performs time zone conversions directly in the database.
    As a consequence, your database must be able to interpret the value of
    ``tzinfo.tzname(None)``. This translates into the following requirements:

    - SQLite: no requirements. Conversions are performed in Python with pytz_
      (installed when you install Django).
    - PostgreSQL: no requirements (see `Time Zones`_).
    - Oracle: no requirements (see `Choosing a Time Zone File`_).
    - MySQL: load the time zone tables with `mysql_tzinfo_to_sql`_.

    .. _pytz: http://pytz.sourceforge.net/
    .. _Time Zones: https://www.postgresql.org/docs/current/datatype-datetime.html#DATATYPE-TIMEZONES
    .. _Choosing a Time Zone File: https://docs.oracle.com/en/database/oracle/
       oracle-database/18/nlspg/datetime-data-types-and-time-zone-support.html
       #GUID-805AB986-DE12-4FEA-AF56-5AABCD2132DF
    .. _mysql_tzinfo_to_sql: https://dev.mysql.com/doc/refman/en/mysql-tzinfo-to-sql.html

``none()``
~~~~~~~~~~

.. method:: none()

Calling ``none()`` will create a queryset that never returns any objects and no
query will be executed when accessing the results. A ``qs.none()`` queryset
is an instance of ``EmptyQuerySet``.

Examples::

    >>> Entry.objects.none()
    <QuerySet []>
    >>> from django.db.models.query import EmptyQuerySet
    >>> isinstance(Entry.objects.none(), EmptyQuerySet)
    True

``all()``
~~~~~~~~~

.. method:: all()

Returns a *copy* of the current ``QuerySet`` (or ``QuerySet`` subclass).  This
can be useful in situations where you might want to pass in either a model
manager or a ``QuerySet`` and do further filtering on the result. After calling
``all()`` on either object, you'll definitely have a ``QuerySet`` to work with.

When a ``QuerySet`` is :ref:`evaluated <when-querysets-are-evaluated>`, it
typically caches its results. If the data in the database might have changed
since a ``QuerySet`` was evaluated, you can get updated results for the same
query by calling ``all()`` on a previously evaluated ``QuerySet``.

``union()``
~~~~~~~~~~~

.. method:: union(*other_qs, all=False)

Uses SQL's ``UNION`` operator to combine the results of two or more
``QuerySet``\s. For example:

    >>> qs1.union(qs2, qs3)

The ``UNION`` operator selects only distinct values by default. To allow
duplicate values, use the ``all=True`` argument.

``union()``, ``intersection()``, and ``difference()`` return model instances
of the type of the first ``QuerySet`` even if the arguments are ``QuerySet``\s
of other models. Passing different models works as long as the ``SELECT`` list
is the same in all ``QuerySet``\s (at least the types, the names don't matter
as long as the types are in the same order). In such cases, you must use the
column names from the first ``QuerySet`` in ``QuerySet`` methods applied to the
resulting ``QuerySet``. For example::

    >>> qs1 = Author.objects.values_list('name')
    >>> qs2 = Entry.objects.values_list('headline')
    >>> qs1.union(qs2).order_by('name')

In addition, only ``LIMIT``, ``OFFSET``, ``COUNT(*)``, ``ORDER BY``, and
specifying columns (i.e. slicing, :meth:`count`, :meth:`exists`,
:meth:`order_by`, and :meth:`values()`/:meth:`values_list()`) are allowed
on the resulting ``QuerySet``. Further, databases place restrictions on
what operations are allowed in the combined queries. For example, most
databases don't allow ``LIMIT`` or ``OFFSET`` in the combined queries.

``intersection()``
~~~~~~~~~~~~~~~~~~

.. method:: intersection(*other_qs)

Uses SQL's ``INTERSECT`` operator to return the shared elements of two or more
``QuerySet``\s. For example:

    >>> qs1.intersection(qs2, qs3)

See :meth:`union` for some restrictions.

``difference()``
~~~~~~~~~~~~~~~~

.. method:: difference(*other_qs)

Uses SQL's ``EXCEPT`` operator to keep only elements present in the
``QuerySet`` but not in some other ``QuerySet``\s. For example::

    >>> qs1.difference(qs2, qs3)

See :meth:`union` for some restrictions.

``select_related()``
~~~~~~~~~~~~~~~~~~~~

.. method:: select_related(*fields)

Returns a ``QuerySet`` that will "follow" foreign-key relationships, selecting
additional related-object data when it executes its query. This is a
performance booster which results in a single more complex query but means
later use of foreign-key relationships won't require database queries.

The following examples illustrate the difference between plain lookups and
``select_related()`` lookups. Here's standard lookup::

    # Hits the database.
    e = Entry.objects.get(id=5)

    # Hits the database again to get the related Blog object.
    b = e.blog

And here's ``select_related`` lookup::

    # Hits the database.
    e = Entry.objects.select_related('blog').get(id=5)

    # Doesn't hit the database, because e.blog has been prepopulated
    # in the previous query.
    b = e.blog

You can use ``select_related()`` with any queryset of objects::

    from django.utils import timezone

    # Find all the blogs with entries scheduled to be published in the future.
    blogs = set()

    for e in Entry.objects.filter(pub_date__gt=timezone.now()).select_related('blog'):
        # Without
```


# The last commit

```
5d31c7b7ca SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py bulk_update
E
======================================================================
ERROR: bulk_update (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: bulk_update
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/loader.py", line 154, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'bulk_update'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 1 test(s).
System check identified no issues (0 silenced).

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/db/models/query.py tests/bulk_update docs/ref/models/querysets.txt
changed: django/db/models/query.py +4 -2
changed: docs/ref/models/querysets.txt +2 -0
OUTSIDE THE SCOPE: tests/queries/test_bulk_update.py +6 -3 (undo it: git checkout the file, or delete it when the run made it)
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/db/models/query.py b/django/db/models/query.py
index 387deca527..7fce385d30 100644
--- a/django/db/models/query.py
+++ b/django/db/models/query.py
@@ -541,7 +541,7 @@ class QuerySet:
         if any(f.primary_key for f in fields):
             raise ValueError('bulk_update() cannot be used with primary key fields.')
         if not objs:
-            return
+            return 0
         # PK is used twice in the resulting update query, once in the filter
         # and once in the WHEN. Each field will also have one CAST.
         max_batch_size = connections[self.db].ops.bulk_batch_size(['pk', 'pk'] + fields, objs)
@@ -564,8 +564,10 @@ class QuerySet:
                 update_kwargs[field.attname] = case_statement
             updates.append(([obj.pk for obj in batch_objs], update_kwargs))
         with transaction.atomic(using=self.db, savepoint=False):
+            rows_updated = 0
             for pks, update_kwargs in updates:
-                self.filter(pk__in=pks).update(**update_kwargs)
+                rows_updated += self.filter(pk__in=pks).update(**update_kwargs)
+        return rows_updated
     bulk_update.alters_data = True
 
     def get_or_create(self, defaults=None, **kwargs):
diff --git a/docs/ref/models/querysets.txt b/docs/ref/models/querysets.txt
index 5dc7a6b5bc..080eabba2c 100644
--- a/docs/ref/models/querysets.txt
+++ b/docs/ref/models/querysets.txt
@@ -2231,6 +2231,8 @@ instances, generally with one query::
     >>> objs[1].headline = 'This is entry 2'
     >>> Entry.objects.bulk_update(objs, ['headline'])
 
+Returns the number of rows matched by the update query.
+
 :meth:`.QuerySet.update` is used to save the changes, so this is more efficient
 than iterating through the list of models and calling ``save()`` on each of
 them, but it has a few caveats:
diff --git a/tests/queries/test_bulk_update.py b/tests/queries/test_bulk_update.py
index be794df718..80b7499bd9 100644
--- a/tests/queries/test_bulk_update.py
+++ b/tests/queries/test_bulk_update.py
@@ -29,7 +29,8 @@ class BulkUpdateNoteTests(TestCase):
         for note in self.notes:
             note.note = 'test-%s' % note.id
         with self.assertNumQueries(1):
-            Note.objects.bulk_update(self.notes, ['note'])
+            rows_updated = Note.objects.bulk_update(self.notes, ['note'])
+        self.assertEqual(rows_updated, len(self.notes))
         self.assertCountEqual(
             Note.objects.values_list('note', flat=True),
             [cat.note for cat in self.notes]
@@ -52,7 +53,8 @@ class BulkUpdateNoteTests(TestCase):
 
     def test_batch_size(self):
         with self.assertNumQueries(len(self.notes)):
-            Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)
+            rows_updated = Note.objects.bulk_update(self.notes, fields=['note'], batch_size=1)
+        self.assertEqual(rows_updated, len(self.notes))
 
     def test_unsaved_models(self):
         objs = self.notes + [Note(note='test', misc='test')]
@@ -125,7 +127,8 @@ class BulkUpdateTests(TestCase):
 
     def test_empty_objects(self):
         with self.assertNumQueries(0):
-            Note.objects.bulk_update([], ['note'])
+            rows_updated = Note.objects.bulk_update([], ['note'])
+        self.assertEqual(rows_updated, 0)
 
     def test_large_batch(self):
         Note.objects.bulk_create([
```

### `done.sh`

```
#!/usr/bin/env bash
# done.sh <step> <run dir>: whether an agent step did its part, the step's
# target. Exit 0 when it did; otherwise exit 1 and say what is missing. The
# problem step copies it into the run's folder; a task cannot edit its own
# target (gateway/target_guard.go).
set -u
step="$1"; r="$2"; miss=0
w=.memdoor/workflows/team-solve; [ -d "$w" ] || w="$HOME/.memdoor/workflows/team-solve"
no() { printf 'not done: %s\n' "$1"; miss=1; }
# section <file> <heading>: the lines under "## <heading>", comments and blanks dropped.
section() { sed -n "/^## $2\$/,/^## /p" "$1" | sed '1d;/^## /d;/^<!--.*-->$/d;/^[[:space:]]*$/d'; }
verdict() { [ -s "$1" ] && head -1 "$1" | grep -qE '^verdict: (PASS|FAIL)$'; }

case "$step" in
plan)
  t="$r/task.md"
  for s in Deliverable Check Scope "Done when"; do
    [ -n "$(section "$t" "$s")" ] || no "task.md: the $s section is not filled in"
  done
  { section "$t" Check | grep -q '`[^`]*`' || section "$t" Check | grep -qwE 'samples|judge'; } \
    || no 'task.md: Check names no command in backticks, nor samples, nor judge'
  section "$t" Scope | grep -q '`[^`]*`' || no 'task.md: Scope names no file or directory in backticks'
  first=$(grep -m1 '[^[:space:]]' "$r/prompt.md")
  grep -qF -- "$first" "$t" || no 'task.md: the Prompt section was changed; put it back as prompt.md has it'
  grep -q '[^[:space:]]' "$r/plan.md" 2>/dev/null || no 'plan.md is missing or empty'
  [ -f "$r/notes.md" ] || no 'notes.md is missing' ;;
solve)
  bash "$w/changes.sh" "$r" > /dev/null
  [ -s "$r/changes.diff" ] || no 'nothing in the project changed yet: do the task as the Deliverable says' ;;
review)
  verdict "$r/review.md" || no 'review.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
repair)
  head -1 "$r/review.md" 2>/dev/null | grep -qx 'verdict: PASS' && exit 0
  grep -q '[^[:space:]]' "$r/repair.md" 2>/dev/null || no 'repair.md is missing: what you changed and what the Check printed' ;;
judge)
  verdict "$r/verdict.md" || no 'verdict.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
*) echo "done.sh: unknown step $step"; exit 2 ;;
esac
[ "$miss" = 0 ] && printf '%s: done\n' "$step"
exit "$miss"
```

### `final-check.log`

```
check: python tests/runtests.py bulk_update
E
======================================================================
ERROR: bulk_update (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: bulk_update
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/loader.py", line 154, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'bulk_update'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 1 test(s).
System check identified no issues (0 silenced).

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/db/models/query.py tests/bulk_update docs/ref/models/querysets.txt
changed: django/db/models/query.py +4 -2
changed: docs/ref/models/querysets.txt +2 -0
OUTSIDE THE SCOPE: tests/queries/test_bulk_update.py +6 -3 (undo it: git checkout the file, or delete it when the run made it)
```

### `final-status.txt`

```
0
```

### `head.txt`

```
main
```

### `keep.txt`

```
kept: the direct attempt, untouched
```

### `notes.md`

```
# Notes, run 2026-11-06T110916

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Include number of rows matched in bulk_update() return value
Description
	
Currently, bulk_update() returns None, unlike update(), which returns ​the number of rows matched.
It looks like it would be easy to add the same functionality to bulk_update() since bulk_update() simply calls update() repeatedly:
​https://github.com/django/django/blob/2b4b6c8af0aae8785bc1347cf1be2e8e70fd5ff3/django/db/models/query.py#L568
I.e. the return values could simply be added and returned.


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.gitattributes
.github/FUNDING.yml
.github/SECURITY.md
.github/workflows/docs.yml
.github/workflows/linters.yml
.github/workflows/new_contributor_pr.yml
.github/workflows/tests.yml
.gitignore
.pre-commit-config.yaml
.tx/config
AUTHORS
CONTRIBUTING.rst
Gruntfile.js
INSTALL
LICENSE
LICENSE.python
MANIFEST.in
README.rst
django/__init__.py
django/__main__.py
django/apps/__init__.py
django/apps/config.py
django/apps/registry.py
django/conf/__init__.py
django/conf/app_template/__init__.py-tpl
django/conf/app_template/admin.py-tpl
django/conf/app_template/apps.py-tpl
django/conf/app_template/migrations/__init__.py-tpl
django/conf/app_template/models.py-tpl
django/conf/app_template/tests.py-tpl
django/conf/app_template/views.py-tpl
django/conf/global_settings.py
django/conf/locale/__init__.py
django/conf/locale/af/LC_MESSAGES/django.mo
django/conf/locale/af/LC_MESSAGES/django.po
django/conf/locale/ar/LC_MESSAGES/django.mo
django/conf/locale/ar/LC_MESSAGES/django.po
django/conf/locale/ar/__init__.py
django/conf/locale/ar/formats.py
django/conf/locale/ar_DZ/LC_MESSAGES/django.mo
django/conf/locale/ar_DZ/LC_MESSAGES/django.po
django/conf/locale/ar_DZ/__init__.py
django/conf/locale/ar_DZ/formats.py
django/conf/locale/ast/LC_MESSAGES/django.mo
django/conf/locale/ast/LC_MESSAGES/django.po
django/conf/locale/az/LC_MESSAGES/django.mo
django/conf/locale/az/LC_MESSAGES/django.po
django/conf/locale/az/__init__.py
django/conf/locale/az/formats.py
django/conf/locale/be/LC_MESSAGES/django.mo
django/conf/locale/be/LC_MESSAGES/django.po
django/conf/locale/bg/LC_MESSAGES/django.mo
django/conf/locale/bg/LC_MESSAGES/django.po
django/conf/locale/bg/__init__.py
django/conf/locale/bg/formats.py
django/conf/locale/bn/LC_MESSAGES/django.mo
django/conf/locale/bn/LC_MESSAGES/django.po
django/conf/locale/bn/__init__.py
django/conf/locale/bn/formats.py
django/conf/locale/br/LC_MESSAGES/django.mo
django/conf/locale/br/LC_MESSAGES/django.po
django/conf/locale/bs/LC_MESSAGES/django.mo
django/conf/locale/bs/LC_MESSAGES/django.po
django/conf/locale/bs/__init__.py
django/conf/locale/bs/formats.py
django/conf/locale/ca/LC_MESSAGES/django.mo
django/conf/locale/ca/LC_MESSAGES/django.po
django/conf/locale/ca/__init__.py
django/conf/locale/ca/formats.py
django/conf/locale/cs/LC_MESSAGES/django.mo
django/conf/locale/cs/LC_MESSAGES/django.po
django/conf/locale/cs/__init__.py
django/conf/locale/cs/formats.py
django/conf/locale/cy/LC_MESSAGES/django.mo
django/conf/locale/cy/LC_MESSAGES/django.po
django/conf/locale/cy/__init__.py
django/conf/locale/cy/formats.py
django/conf/locale/da/LC_MESSAGES/django.mo
django/conf/locale/da/LC_MESSAGES/django.po
django/conf/locale/da/__init__.py
django/conf/locale/da/formats.py
django/conf/locale/de/LC_MESSAGES/django.mo
django/conf/locale/de/LC_MESSAGES/django.po
django/conf/locale/de/__init__.py
django/conf/locale/de/formats.py
django/conf/locale/de_CH/__init__.py
django/conf/locale/de_CH/formats.py
django/conf/locale/dsb/LC_MESSAGES/django.mo
django/conf/locale/dsb/LC_MESSAGES/django.po
django/conf/locale/el/LC_MESSAGES/django.mo
django/conf/locale/el/LC_MESSAGES/django.po
django/conf/locale/el/__init__.py
django/conf/locale/el/formats.py
django/conf/locale/en/LC_MESSAGES/django.mo
django/conf/locale/en/LC_MESSAGES/django.po
django/conf/locale/en/__init__.py
django/conf/locale/en/formats.py
django/conf/locale/en_AU/LC_MESSAGES/django.mo
django/conf/locale/en_AU/LC_MESSAGES/django.po
django/conf/locale/en_AU/__init__.py
django/conf/locale/en_AU/formats.py
django/conf/locale/en_GB/LC_MESSAGES/django.mo
django/conf/locale/en_GB/LC_MESSAGES/django.po
django/conf/locale/en_GB/__init__.py
django/conf/locale/en_GB/formats.py
django/conf/locale/eo/LC_MESSAGES/django.mo
django/conf/locale/eo/LC_MESSAGES/django.po
django/conf/locale/eo/__init__.py
django/conf/locale/eo/formats.py
django/conf/locale/es/LC_MESSAGES/django.mo
django/conf/locale/es/LC_MESSAGES/django.po
django/conf/locale/es/__init__.py
django/conf/locale/es/formats.py
django/conf/locale/es_AR/LC_MESSAGES/django.mo
django/conf/locale/es_AR/LC_MESSAGES/django.po
django/conf/locale/es_AR/__init__.py
django/conf/locale/es_AR/formats.py
django/conf/locale/es_CO/LC_MESSAGES/django.mo
django/conf/locale/es_CO/LC_MESSAGES/django.po
django/conf/locale/es_CO/__init__.py
django/conf/locale/es_CO/formats.py
django/conf/locale/es_MX/LC_MESSAGES/django.mo
django/conf/locale/es_MX/LC_MESSAGES/django.po
django/conf/locale/es_MX/__init__.py
django/conf/locale/es_MX/formats.py
django/conf/locale/es_NI/__init__.py
django/conf/locale/es_NI/formats.py
django/conf/locale/es_PR/__init__.py
django/conf/locale/es_PR/formats.py
django/conf/locale/es_VE/LC_MESSAGES/django.mo
django/conf/locale/es_VE/LC_MESSAGES/django.po
django/conf/locale/et/LC_MESSAGES/django.mo
django/conf/locale/et/LC_MESSAGES/django.po
django/conf/locale/et/__init__.py
django/conf/locale/et/formats.py
django/conf/locale/eu/LC_MESSAGES/django.mo
django/conf/locale/eu/LC_MESSAGES/django.po
django/conf/locale/eu/__init__.py
django/conf/locale/eu/formats.py
django/conf/locale/fa/LC_MESSAGES/django.mo
django/conf/locale/fa/LC_MESSAGES/django.po
django/conf/locale/fa/__init__.py
django/conf/locale/fa/formats.py
django/conf/locale/fi/LC_MESSAGES/django.mo
django/conf/locale/fi/LC_MESSAGES/django.po
django/conf/locale/fi/__init__.py
django/conf/locale/fi/formats.py
django/conf/locale/fr/LC_MESSAGES/django.mo
django/conf/locale/fr/LC_MESSAGES/django.po
django/conf/locale/fr/__init__.py
django/conf/locale/fr/formats.py
django/conf/locale/fy/LC_MESSAGES/django.mo
django/conf/locale/fy/LC_MESSAGES/django.po
django/conf/locale/fy/__init__.py
django/conf/locale/fy/formats.py
django/conf/locale/ga/LC_MESSAGES/django.mo
django/conf/locale/ga/LC_MESSAGES/django.po
django/conf/locale/ga/__init__.py
django/conf/locale/ga/formats.py
django/conf/locale/gd/LC_MESSAGES/django.mo
django/conf/locale/gd/LC_MESSAGES/django.po
django/conf/locale/gd/__init__.py
django/conf/locale/gd/formats.py
django/conf/locale/gl/LC_MESSAGES/django.mo
django/conf/locale/gl/LC_MESSAGES/django.po
django/conf/locale/gl/__init__.py
django/conf/locale/gl/formats.py
django/conf/locale/he/LC_MESSAGES/django.mo
django/conf/locale/he/LC_MESSAGES/django.po
django/conf/locale/he/__init__.py
django/conf/locale/he/formats.py
django/conf/locale/hi/LC_MESSAGES/django.mo
django/conf/locale/hi/LC_MESSAGES/django.po
django/conf/locale/hi/__init__.py
django/conf/locale/hi/formats.py
django/conf/locale/hr/LC_MESSAGES/django.mo
django/conf/locale/hr/LC_MESSAGES/django.po
django/conf/locale/hr/__init__.py
django/conf/locale/hr/formats.py
django/conf/locale/hsb/LC_MESSAGES/django.mo
django/conf/locale/hsb/LC_MESSAGES/django.po
django/conf/locale/hu/LC_MESSAGES/django.mo
django/conf/locale/hu/LC_MESSAGES/django.po
django/conf/locale/hu/__init__.py
django/conf/locale/hu/formats.py
django/conf/locale/hy/LC_MESSAGES/django.mo
django/conf/locale/hy/LC_MESSAGES/django.po
django/conf/locale/ia/LC_MESSAGES/django.mo
django/conf/locale/ia/LC_MESSAGES/django.po
django/conf/locale/id/LC_MESSAGES/django.mo
django/conf/locale/id/LC_MESSAGES/django.po
django/conf/locale/id/__init__.py
django/conf/locale/id/formats.py
django/conf/locale/ig/LC_MESSAGES/django.mo
django/conf/locale/ig/LC_MESSAGES/django.po
django/conf/locale/ig/__init__.py
django/conf/locale/ig/formats.py
django/conf/locale/io/LC_MESSAGES/django.mo
django/conf/locale/io/LC_MESSAGES/django.po
django/conf/locale/is/LC_MESSAGES/django.mo
django/conf/locale/is/LC_MESSAGES/django.po
django/conf/locale/is/__init__.py
django/conf/locale/is/formats.py
django/conf/locale/it/LC_MESSAGES/django.mo
django/conf/locale/it/LC_MESSAGES/django.po
django/conf/locale/it/__init__.py
django/conf/locale/it/formats.py
django/conf/locale/ja/LC_MESSAGES/django.mo
django/conf/locale/ja/LC_MESSAGES/django.po
django/conf/locale/ja/__init__.py
django/conf/locale/ja/formats.py
django/conf/locale/ka/LC_MESSAGES/django.mo
django/conf/locale/ka/LC_MESSAGES/django.po
django/conf/locale/ka/__init__.py
django/conf/locale/ka/formats.py
django/conf/locale/kab/LC_MESSAGES/django.mo
django/conf/locale/kab/LC_MESSAGES/django.po
django/conf/locale/kk/LC_MESSAGES/django.mo
django/conf/locale/kk/LC_MESSAGES/django.po
django/conf/locale/km/LC_MESSAGES/django.mo
django/conf/locale/km/LC_MESSAGES/django.po
django/conf/locale/km/__init__.py
django/conf/locale/km/formats.py
django/conf/locale/kn/LC_MESSAGES/django.mo
django/conf/locale/kn/LC_MESSAGES/django.po
django/conf/locale/kn/__init__.py
django/conf/locale/kn/formats.py
django/conf/locale/ko/LC_MESSAGES/django.mo
django/conf/locale/ko/LC_MESSAGES/django.po
django/conf/locale/ko/__init__.py
django/conf/locale/ko/formats.py
django/conf/locale/ky/LC_MESSAGES/django.mo
django/conf/locale/ky/LC_MESSAGES/django.po
django/conf/locale/ky/__init__.py
django/conf/locale/ky/formats.py
django/conf/locale/lb/LC_MESSAGES/django.mo
django/conf/locale/lb/LC_MESSAGES/django.po
django/conf/locale/lt/LC_MESSAGES/django.mo
django/conf/locale/lt/LC_MESSAGES/django.po
django/conf/locale/lt/__init__.py
django/conf/locale/lt/formats.py
django/conf/locale/lv/LC_MESSAGES/django.mo
django/conf/locale/lv/LC_MESSAGES/django.po
django/conf/locale/lv/__init__.py
django/conf/locale/lv/formats.py
django/conf/locale/mk/LC_MESSAGES/django.mo
django/conf/locale/mk/LC_MESSAGES/django.po
django/conf/locale/mk/__init__.py
django/conf/locale/mk/formats.py
django/conf/locale/ml/LC_MESSAGES/django.mo
django/conf/locale/ml/LC_MESSAGES/django.po
django/conf/locale/ml/__init__.py
django/conf/locale/ml/formats.py
django/conf/locale/mn/LC_MESSAGES/django.mo
django/conf/locale/mn/LC_MESSAGES/django.po
django/conf/locale/mn/__init__.py
django/conf/locale/mn/formats.py
django/conf/locale/mr/LC_MESSAGES/django.mo
django/conf/locale/mr/LC_MESSAGES/django.po
django/conf/locale/my/LC_MESSAGES/django.mo
django/conf/locale/my/LC_MESSAGES/django.po
django/conf/locale/nb/LC_MESSAGES/django.mo
django/conf/locale/nb/LC_MESSAGES/django.po
django/conf/locale/nb/__init__.py
django/conf/locale/nb/formats.py
django/conf/locale/ne/LC_MESSAGES/django.mo
django/conf/locale/ne/LC_MESSAGES/django.po
django/conf/locale/nl/LC_MESSAGES/django.mo
django/conf/locale/nl/LC_MESSAGES/django.po
django/conf/locale/nl/__init__.py
django/conf/locale/nl/formats.py
django/conf/locale/nn/LC_MESSAGES/django.mo
django/conf/locale/nn/LC_MESSAGES/django.po
django/conf/locale/nn/__init__.py
django/conf/locale/nn/formats.py
django/conf/locale/os/LC_MESSAGES/django.mo
django/conf/locale/os/LC_MESSAGES/django.po
django/conf/locale/pa/LC_MESSAGES/django.mo
django/conf/locale/pa/LC_MESSAGES/django.po
django/conf/locale/pl/LC_MESSAGES/django.mo
django/conf/locale/pl/LC_MESSAGES/django.po
django/conf/locale/pl/__init__.py
django/conf/locale/pl/formats.py
django/conf/locale/pt/LC_MESSAGES/django.mo
django/conf/locale/pt/LC_MESSAGES/django.po
django/conf/locale/pt/__init__.py
django/conf/locale/pt/formats.py
django/conf/locale/pt_BR/LC_MESSAGES/django.mo
django/conf/locale/pt_BR/LC_MESSAGES/django.po
django/conf/locale/pt_BR/__init__.py
django/conf/locale/pt_BR/formats.py
django/conf/locale/ro/LC_MESSAGES/django.mo
django/conf/locale/ro/LC_MESSAGES/django.po
django/conf/locale/ro/__init__.py
django/conf/locale/ro/formats.py
django/conf/locale/ru/LC_MESSAGES/django.mo
django/conf/locale/ru/LC_MESSAGES/django.po
django/conf/locale/ru/__init__.py
django/conf/locale/ru/formats.py
django/conf/locale/sk/LC_MESSAGES/django.mo
django/conf/locale/sk/LC_MESSAGES/django.po
django/conf/locale/sk/__init__.py
django/conf/locale/sk/formats.py
django/conf/locale/sl/LC_MESSAGES/django.mo
django/conf/locale/sl/LC_MESSAGES/django.po
django/conf/locale/sl/__init__.py
django/conf/locale/sl/formats.py
django/conf/locale/sq/LC_MESSAGES/django.mo
django/conf/locale/sq/LC_MESSAGES/django.po
django/conf/locale/sq/__init__.py
django/conf/locale/sq/formats.py
django/conf/locale/sr/LC_MESSAGES/django.mo
django/conf/locale/sr/LC_MESSAGES/django.po
django/conf/locale/sr/__init__.py
django/conf/locale/sr/formats.py
django/conf/locale/sr_Latn/LC_MESSAGES/django.mo
django/conf/locale/sr_Latn/LC_MESSAGES/django.po
django/conf/locale/sr_Latn/__init__.py
django/conf/locale/sr_Latn/formats.py
django/conf/locale/sv/LC_MESSAGES/django.mo
django/conf/locale/sv/LC_MESSAGES/django.po
django/conf/locale/sv/__init__.py
django/conf/locale/sv/formats.py
django/conf/locale/sw/LC_MESSAGES/django.mo
django/conf/locale/sw/LC_MESSAGES/django.po
django/conf/locale/ta/LC_MESSAGES/django.mo
django/conf/locale/ta/LC_MESSAGES/django.po
django/conf/locale/ta/__init__.py
django/conf/locale/ta/formats.py
django/conf/locale/te/LC_MESSAGES/django.mo
django/conf/locale/te/LC_MESSAGES/django.po
django/conf/locale/te/__init__.py
django/conf/locale/te/formats.py
django/conf/locale/tg/LC_MESSAGES/django.mo
django/conf/locale/tg/LC_MESSAGES/django.po
django/conf/locale/tg/__init__.py
django/conf/locale/tg/formats.py
django/conf/locale/th/LC_MESSAGES/django.mo
django/conf/locale/th/LC_MESSAGES/django.po
django/conf/locale/th/__init__.py
django/conf/locale/th/formats.py
django/conf/locale/tk/LC_MESSAGES/django.mo
django/conf/locale/tk/LC_MESSAGES/django.po
django/conf/locale/tk/__init__.py
django/conf/locale/tk/formats.py
django/conf/locale/tr/LC_MESSAGES/django.mo
django/conf/locale/tr/LC_MESSAGES/django.po
django/conf/locale/tr/__init__.py
django/conf/locale/tr/formats.py
django/conf/locale/tt/LC_MESSAGES/django.mo
django/conf/locale/tt/LC_MESSAGES/django.po
django/conf/locale/udm/LC_MESSAGES/django.mo
django/conf/locale/udm/LC_MESSAGES/django.po
django/conf/locale/uk/LC_MESSAGES/django.mo
django/conf/locale/uk/LC_MESSAGES/django.po
django/conf/locale/uk/__init__.py
django/conf/locale/uk/formats.py
django/conf/locale/ur/LC_MESSAGES/django.mo
django/conf/locale/ur/LC_MESSAGES/django.po
django/conf/locale/uz/LC_MESSAGES/django.mo
django/conf/locale/uz/LC_MESSAGES/django.po
django/conf/locale/uz/__init__.py
django/conf/locale/uz/formats.py
django/conf/locale/vi/LC_MESSAGES/django.mo
django/conf/locale/vi/LC_MESSAGES/django.po
django/conf/locale/vi/__init__.py
django/conf/locale/vi/formats.py
django/conf/locale/zh_Hans/LC_MESSAGES/django.mo
django/conf/locale/zh_Hans/LC_MESSAGES/django.po
django/conf/locale/zh_Hans/__init__.py
django/conf/locale/zh_Hans/formats.py
django/conf/locale/zh_Hant/LC_MESSAGES/django.mo
django/conf/locale/zh_Hant/LC_MESSAGES/django.po
django/conf/locale/zh_Hant/__init__.py
django/conf/locale/zh_Hant/formats.py
django/conf/project_template/manage.py-tpl
django/conf/project_template/project_name/__init__.py-tpl
django/conf/project_template/project_name/asgi.py-tpl
django/conf/project_template/project_name/settings.py-tpl
django/conf/project_template/project_name/urls.py-tpl
django/conf/project_template/project_name/wsgi.py-tpl
django/conf/urls/__init__.py
django/conf/urls/i18n.py
django/conf/urls/static.py
django/contrib/__init__.py
django/contrib/admin/__init__.py
django/contrib/admin/actions.py
django/contrib/admin/apps.py
django/contrib/admin/checks.py
django/contrib/admin/decorators.py
django/contrib/admin/exceptions.py
django/contrib/admin/filters.py
django/contrib/admin/forms.py
django/contrib/admin/helpers.py
django/contrib/admin/locale/af/LC_MESSAGES/django.mo
django/contrib/admin/locale/af/LC_MESSAGES/django.po
django/contrib/admin/locale/af/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/af/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/am/LC_MESSAGES/django.mo
django/contrib/admin/locale/am/LC_MESSAGES/django.po
django/contrib/admin/locale/ar/LC_MESSAGES/django.mo
django/contrib/admin/locale/ar/LC_MESSAGES/django.po
django/contrib/admin/locale/ar/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ar/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/django.mo
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/django.po
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ar_DZ/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ast/LC_MESSAGES/django.mo
django/contrib/admin/locale/ast/LC_MESSAGES/django.po
django/contrib/admin/locale/ast/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ast/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/az/LC_MESSAGES/django.mo
django/contrib/admin/locale/az/LC_MESSAGES/django.po
django/contrib/admin/locale/az/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/az/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/be/LC_MESSAGES/django.mo
django/contrib/admin/locale/be/LC_MESSAGES/django.po
django/contrib/admin/locale/be/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/be/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/bg/LC_MESSAGES/django.mo
django/contrib/admin/locale/bg/LC_MESSAGES/django.po
django/contrib/admin/locale/bg/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/bg/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/bn/LC_MESSAGES/django.mo
django/contrib/admin/locale/bn/LC_MESSAGES/django.po
django/contrib/admin/locale/bn/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/bn/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/br/LC_MESSAGES/django.mo
django/contrib/admin/locale/br/LC_MESSAGES/django.po
django/contrib/admin/locale/br/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/br/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/bs/LC_MESSAGES/django.mo
django/contrib/admin/locale/bs/LC_MESSAGES/django.po
django/contrib/admin/locale/bs/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/bs/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ca/LC_MESSAGES/django.mo
django/contrib/admin/locale/ca/LC_MESSAGES/django.po
django/contrib/admin/locale/ca/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ca/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/cs/LC_MESSAGES/django.mo
django/contrib/admin/locale/cs/LC_MESSAGES/django.po
django/contrib/admin/locale/cs/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/cs/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/cy/LC_MESSAGES/django.mo
django/contrib/admin/locale/cy/LC_MESSAGES/django.po
django/contrib/admin/locale/cy/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/cy/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/da/LC_MESSAGES/django.mo
django/contrib/admin/locale/da/LC_MESSAGES/django.po
django/contrib/admin/locale/da/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/da/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/de/LC_MESSAGES/django.mo
django/contrib/admin/locale/de/LC_MESSAGES/django.po
django/contrib/admin/locale/de/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/de/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/dsb/LC_MESSAGES/django.mo
django/contrib/admin/locale/dsb/LC_MESSAGES/django.po
django/contrib/admin/locale/dsb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/dsb/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/el/LC_MESSAGES/django.mo
django/contrib/admin/locale/el/LC_MESSAGES/django.po
django/contrib/admin/locale/el/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/el/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/en/LC_MESSAGES/django.mo
django/contrib/admin/locale/en/LC_MESSAGES/django.po
django/contrib/admin/locale/en/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/en/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/en_AU/LC_MESSAGES/django.mo
django/contrib/admin/locale/en_AU/LC_MESSAGES/django.po
django/contrib/admin/locale/en_AU/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/en_AU/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/en_GB/LC_MESSAGES/django.mo
django/contrib/admin/locale/en_GB/LC_MESSAGES/django.po
django/contrib/admin/locale/en_GB/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/en_GB/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/eo/LC_MESSAGES/django.mo
django/contrib/admin/locale/eo/LC_MESSAGES/django.po
django/contrib/admin/locale/eo/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/eo/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es/LC_MESSAGES/django.mo
django/contrib/admin/locale/es/LC_MESSAGES/django.po
django/contrib/admin/locale/es/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_AR/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_AR/LC_MESSAGES/django.po
django/contrib/admin/locale/es_AR/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_AR/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_CO/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_CO/LC_MESSAGES/django.po
django/contrib/admin/locale/es_CO/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_CO/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_MX/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_MX/LC_MESSAGES/django.po
django/contrib/admin/locale/es_MX/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_MX/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/es_VE/LC_MESSAGES/django.mo
django/contrib/admin/locale/es_VE/LC_MESSAGES/django.po
django/contrib/admin/locale/es_VE/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/es_VE/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/et/LC_MESSAGES/django.mo
django/contrib/admin/locale/et/LC_MESSAGES/django.po
django/contrib/admin/locale/et/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/et/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/eu/LC_MESSAGES/django.mo
django/contrib/admin/locale/eu/LC_MESSAGES/django.po
django/contrib/admin/locale/eu/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/eu/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fa/LC_MESSAGES/django.mo
django/contrib/admin/locale/fa/LC_MESSAGES/django.po
django/contrib/admin/locale/fa/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fa/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fi/LC_MESSAGES/django.mo
django/contrib/admin/locale/fi/LC_MESSAGES/django.po
django/contrib/admin/locale/fi/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fi/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fr/LC_MESSAGES/django.mo
django/contrib/admin/locale/fr/LC_MESSAGES/django.po
django/contrib/admin/locale/fr/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fr/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/fy/LC_MESSAGES/django.mo
django/contrib/admin/locale/fy/LC_MESSAGES/django.po
django/contrib/admin/locale/fy/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/fy/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ga/LC_MESSAGES/django.mo
django/contrib/admin/locale/ga/LC_MESSAGES/django.po
django/contrib/admin/locale/ga/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ga/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/gd/LC_MESSAGES/django.mo
django/contrib/admin/locale/gd/LC_MESSAGES/django.po
django/contrib/admin/locale/gd/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/gd/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/gl/LC_MESSAGES/django.mo
django/contrib/admin/locale/gl/LC_MESSAGES/django.po
django/contrib/admin/locale/gl/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/gl/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/he/LC_MESSAGES/django.mo
django/contrib/admin/locale/he/LC_MESSAGES/django.po
django/contrib/admin/locale/he/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/he/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hi/LC_MESSAGES/django.mo
django/contrib/admin/locale/hi/LC_MESSAGES/django.po
django/contrib/admin/locale/hi/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hi/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hr/LC_MESSAGES/django.mo
django/contrib/admin/locale/hr/LC_MESSAGES/django.po
django/contrib/admin/locale/hr/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hr/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hsb/LC_MESSAGES/django.mo
django/contrib/admin/locale/hsb/LC_MESSAGES/django.po
django/contrib/admin/locale/hsb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hsb/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hu/LC_MESSAGES/django.mo
django/contrib/admin/locale/hu/LC_MESSAGES/django.po
django/contrib/admin/locale/hu/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hu/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/hy/LC_MESSAGES/django.mo
django/contrib/admin/locale/hy/LC_MESSAGES/django.po
django/contrib/admin/locale/hy/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/hy/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ia/LC_MESSAGES/django.mo
django/contrib/admin/locale/ia/LC_MESSAGES/django.po
django/contrib/admin/locale/ia/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ia/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/id/LC_MESSAGES/django.mo
django/contrib/admin/locale/id/LC_MESSAGES/django.po
django/contrib/admin/locale/id/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/id/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/io/LC_MESSAGES/django.mo
django/contrib/admin/locale/io/LC_MESSAGES/django.po
django/contrib/admin/locale/io/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/io/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/is/LC_MESSAGES/django.mo
django/contrib/admin/locale/is/LC_MESSAGES/django.po
django/contrib/admin/locale/is/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/is/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/it/LC_MESSAGES/django.mo
django/contrib/admin/locale/it/LC_MESSAGES/django.po
django/contrib/admin/locale/it/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/it/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ja/LC_MESSAGES/django.mo
django/contrib/admin/locale/ja/LC_MESSAGES/django.po
django/contrib/admin/locale/ja/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ja/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ka/LC_MESSAGES/django.mo
django/contrib/admin/locale/ka/LC_MESSAGES/django.po
django/contrib/admin/locale/ka/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ka/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/kab/LC_MESSAGES/django.mo
django/contrib/admin/locale/kab/LC_MESSAGES/django.po
django/contrib/admin/locale/kab/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/kab/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/kk/LC_MESSAGES/django.mo
django/contrib/admin/locale/kk/LC_MESSAGES/django.po
django/contrib/admin/locale/kk/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/kk/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/km/LC_MESSAGES/django.mo
```


# The last commit

```
5d31c7b7ca SWE-bench


```

```diff

```


# package.json (the start)

```
{
  "name": "Django",
  "private": true,
  "scripts": {
    "pretest": "eslint .",
    "test": "grunt test --verbose"
  },
  "engines": {
    "npm": ">=1.3.0 <3.0.0"
  },
  "devDependencies": {
    "eslint": "^7.16.0",
    "grunt": "^1.0.1",
    "grunt-cli": "^1.2.0",
    "grunt-contrib-qunit": "^4.0.0",
    "qunit": "^2.9.3"
  }
}

```


# pyproject.toml (the start)

```
[build-system]
requires = ['setuptools>=40.8.0', 'wheel']
build-backend = 'setuptools.build_meta:__legacy__'

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python tests/runtests.py bulk_update`

## Scope
`django/db/models/query.py`
`tests/bulk_update/`
`docs/ref/models/querysets.txt`

## Done when
`bulk_update()` returns the total number of rows matched by the `update()` calls it performs.
`bulk_update()` returns `0` when given an empty iterable of objects.
The returned count is the number of rows matched, not simply the number of objects passed to `bulk_update()`.
Existing `bulk_update()` validation and batching behavior is unchanged.

## Approach
Decompose into: locate `QuerySet.bulk_update()` in `django/db/models/query.py`; initialize a counter; return `0` for empty `objs`; add each batch’s `update()` return value to the counter; return the counter. Add regression coverage under `tests/bulk_update/` for empty input, one batch, multiple batches, and matched-row semantics. Update the `bulk_update()` documentation to state the return value.

Candidate approaches:
1. Accumulate in the existing batch loop with `rows_updated += self.filter(...).update(...)` and return `rows_updated`. Preferred: minimal change, preserves batching, no extra memory.
2. Collect each batch result in a list and `sum()` it. Clear but unnecessary memory; a generator expression avoids that but is less explicit.
3. Return `len(objs)` after the loop. Reject: `update()` returns rows matched, and duplicate or missing primary keys can make that differ from the number of objects supplied.

If the first attempt fails, check the empty-input early return, ensure every path returns an integer, and verify the counter is outside the batch loop.
```

### `prompt.md`

```
Include number of rows matched in bulk_update() return value
Description
	
Currently, bulk_update() returns None, unlike update(), which returns ​the number of rows matched.
It looks like it would be easy to add the same functionality to bulk_update() since bulk_update() simply calls update() repeatedly:
​https://github.com/django/django/blob/2b4b6c8af0aae8785bc1347cf1be2e8e70fd5ff3/django/db/models/query.py#L568
I.e. the return values could simply be added and returned.
```

### `review.md`

```
verdict: PASS
The implementation returns the sum of `update()` return values, which is the number of rows matched, and returns `0` for an empty iterable.
Validation and batching logic are unchanged; only the return value and empty-input return were modified.
The docs update accurately states that `bulk_update()` returns the number of rows matched.
The test changes in `tests/queries/test_bulk_update.py` are outside the listed scope but are the actual existing `bulk_update` test module and directly cover the requested behavior, so they are not a reason to fail.
The check failure is a baseline issue: `python tests/runtests.py bulk_update` tries to import a nonexistent `bulk_update` module, and the report confirms the same failure exists before this change.
```

### `scope.txt`

```
scope: django/db/models/query.py tests/bulk_update docs/ref/models/querysets.txt
changed: django/db/models/query.py +4 -2
changed: docs/ref/models/querysets.txt +2 -0
OUTSIDE THE SCOPE: tests/queries/test_bulk_update.py +6 -3 (undo it: git checkout the file, or delete it when the run made it)
```

### `task.md`

```
# Task

## Prompt

Include number of rows matched in bulk_update() return value
Description
	
Currently, bulk_update() returns None, unlike update(), which returns ​the number of rows matched.
It looks like it would be easy to add the same functionality to bulk_update() since bulk_update() simply calls update() repeatedly:
​https://github.com/django/django/blob/2b4b6c8af0aae8785bc1347cf1be2e8e70fd5ff3/django/db/models/query.py#L568
I.e. the return values could simply be added and returned.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py bulk_update`

## Scope

`django/db/models/query.py`
`tests/bulk_update/`
`docs/ref/models/querysets.txt`

## Done when

`bulk_update()` returns the total number of rows matched by the `update()` calls it performs.
`bulk_update()` returns `0` when given an empty iterable of objects.
The returned count is the number of rows matched, not simply the number of objects passed to `bulk_update()`.
Existing `bulk_update()` validation and batching behavior is unchanged.
```

### `test-output.log`

```
check: python tests/runtests.py bulk_update
E
======================================================================
ERROR: bulk_update (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: bulk_update
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/loader.py", line 154, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'bulk_update'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 1 test(s).
System check identified no issues (0 silenced).

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/db/models/query.py tests/bulk_update docs/ref/models/querysets.txt
changed: django/db/models/query.py +4 -2
changed: docs/ref/models/querysets.txt +2 -0
OUTSIDE THE SCOPE: tests/queries/test_bulk_update.py +6 -3 (undo it: git checkout the file, or delete it when the run made it)
```

### `test-status.txt`

```
0
```

### `untracked-before.txt`

```
.memdoor/.gitignore
.memdoor/workflows/single/README.md
.memdoor/workflows/single/steps/do.yaml
.memdoor/workflows/team-solve/README.md
.memdoor/workflows/team-solve/changes.sh
.memdoor/workflows/team-solve/check-samples.sh
.memdoor/workflows/team-solve/check.sh
.memdoor/workflows/team-solve/done.sh
.memdoor/workflows/team-solve/failures.sh
.memdoor/workflows/team-solve/sample/task.md
.memdoor/workflows/team-solve/sample/tests/1.in
.memdoor/workflows/team-solve/sample/tests/1.out
.memdoor/workflows/team-solve/sample/tests/2.in
.memdoor/workflows/team-solve/sample/tests/2.out
.memdoor/workflows/team-solve/sample/tests/3.in
.memdoor/workflows/team-solve/sample/tests/3.out
.memdoor/workflows/team-solve/sample/tests/4.in
.memdoor/workflows/team-solve/sample/tests/4.out
.memdoor/workflows/team-solve/sample/tests/5.in
.memdoor/workflows/team-solve/sample/tests/5.out
.memdoor/workflows/team-solve/scope.sh
.memdoor/workflows/team-solve/settle.sh
.memdoor/workflows/team-solve/snapshot.sh
.memdoor/workflows/team-solve/steps/baseline.yaml
.memdoor/workflows/team-solve/steps/context.yaml
.memdoor/workflows/team-solve/steps/direct.yaml
.memdoor/workflows/team-solve/steps/ideate.yaml
.memdoor/workflows/team-solve/steps/judge.yaml
.memdoor/workflows/team-solve/steps/keep.yaml
.memdoor/workflows/team-solve/steps/outline.yaml
.memdoor/workflows/team-solve/steps/plan.yaml
.memdoor/workflows/team-solve/steps/problem.yaml
.memdoor/workflows/team-solve/steps/recheck.yaml
.memdoor/workflows/team-solve/steps/repair.yaml
.memdoor/workflows/team-solve/steps/review.yaml
.memdoor/workflows/team-solve/steps/settle.yaml
.memdoor/workflows/team-solve/steps/solve.yaml
.memdoor/workflows/team-solve/steps/test-0.yaml
.memdoor/workflows/team-solve/steps/test.yaml
.memdoor/workflows/team-solve/steps/verify.yaml
.memdoor/workflows/team-solve/task.sh
.memdoor/workflows/team-solve/task.template.md
.memdoor/workflows/team-solve/verdict.sh
```
