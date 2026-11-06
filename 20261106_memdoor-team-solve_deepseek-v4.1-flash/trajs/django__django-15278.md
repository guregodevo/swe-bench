# django__django-15278 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 90s 73 lines cost=0.005818 in=214269 cached=137216 out=8934 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Adding nullable OneToOneField crashes on SQLite.
Description
	
This new sqlite3 error has cropped up between building django-oauth-toolkit between Django 4.0 and main branch for migrations.AddField of a OneToOneField (see ​https://github.com/jazzband/django-oauth-toolkit/issues/1064):
self = <django.db.backends.sqlite3.base.SQLiteCursorWrapper object at 0x10b8038b0>
query = 'ALTER TABLE "oauth2_provider_accesstoken" ADD COLUMN "source_refresh_token_id" bigint NULL UNIQUE REFERENCES "oauth2_provider_refreshtoken" ("id") DEFERRABLE INITIALLY DEFERRED'
params = []
	def execute(self, query, params=None):
		if params is None:
			return Database.Cursor.execute(self, query)
		query = self.convert_query(query)
>	 return Database.Cursor.execute(self, query, params)
E	 django.db.utils.OperationalError: Cannot add a UNIQUE column
Here's the relevant migration snippet: 
		migrations.AddField(
			model_name='AccessToken',
			name='source_refresh_token',
			field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=oauth2_settings.REFRESH_TOKEN_MODEL, related_name="refreshed_access_token"),
		),
I see there have been a lot of sqlite3 changes in #33355 since the 4.0 release....


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git log --oneline -3 && git status --short | head"
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
pyproject.toml
scripts
setup.cfg
setup.py
tests
tox.ini
d87e54e739 SWE-bench
0ab58c1209 Refs #29026 -- Allowed customizing InteractiveMigrationQuestioner's prompt destination.
03a6488116 Refs #31026 -- Changed @jinja2_tests imports to be relative.
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Cannot add a UNIQUE\\|_remake_table\\|add_field\" django/db/backends/sqlite3/schema.py | head -60"
}
```

**tool result**

```
145:    def _remake_table(self, model, create_field=None, delete_field=None, alter_field=None):
325:    def add_field(self, model, field):
331:            self._remake_table(model, create_field=field)
333:            super().add_field(model, field)
351:            self._remake_table(model, delete_field=field)
365:        self._remake_table(model, alter_field=(old_field, new_field))
387:                self._remake_table(related_model)
393:            self._remake_table(
433:            self._remake_table(model)
444:            self._remake_table(model)
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/backends/sqlite3/schema.py",
  "offset": 1,
  "limit": 360
}
```

**tool result**

```
import copy
from decimal import Decimal

from django.apps.registry import Apps
from django.db import NotSupportedError
from django.db.backends.base.schema import BaseDatabaseSchemaEditor
from django.db.backends.ddl_references import Statement
from django.db.backends.utils import strip_quotes
from django.db.models import UniqueConstraint
from django.db.transaction import atomic


class DatabaseSchemaEditor(BaseDatabaseSchemaEditor):

    sql_delete_table = "DROP TABLE %(table)s"
    sql_create_fk = None
    sql_create_inline_fk = "REFERENCES %(to_table)s (%(to_column)s) DEFERRABLE INITIALLY DEFERRED"
    sql_create_column_inline_fk = sql_create_inline_fk
    sql_create_unique = "CREATE UNIQUE INDEX %(name)s ON %(table)s (%(columns)s)"
    sql_delete_unique = "DROP INDEX %(name)s"

    def __enter__(self):
        # Some SQLite schema alterations need foreign key constraints to be
        # disabled. Enforce it here for the duration of the schema edition.
        if not self.connection.disable_constraint_checking():
            raise NotSupportedError(
                'SQLite schema editor cannot be used while foreign key '
                'constraint checks are enabled. Make sure to disable them '
                'before entering a transaction.atomic() context because '
                'SQLite does not support disabling them in the middle of '
                'a multi-statement transaction.'
            )
        return super().__enter__()

    def __exit__(self, exc_type, exc_value, traceback):
        self.connection.check_constraints()
        super().__exit__(exc_type, exc_value, traceback)
        self.connection.enable_constraint_checking()

    def quote_value(self, value):
        # The backend "mostly works" without this function and there are use
        # cases for compiling Python without the sqlite3 libraries (e.g.
        # security hardening).
        try:
            import sqlite3
            value = sqlite3.adapt(value)
        except ImportError:
            pass
        except sqlite3.ProgrammingError:
            pass
        # Manual emulation of SQLite parameter quoting
        if isinstance(value, bool):
            return str(int(value))
        elif isinstance(value, (Decimal, float, int)):
            return str(value)
        elif isinstance(value, str):
            return "'%s'" % value.replace("\'", "\'\'")
        elif value is None:
            return "NULL"
        elif isinstance(value, (bytes, bytearray, memoryview)):
            # Bytes are only allowed for BLOB fields, encoded as string
            # literals containing hexadecimal data and preceded by a single "X"
            # character.
            return "X'%s'" % value.hex()
        else:
            raise ValueError("Cannot quote parameter value %r of type %s" % (value, type(value)))

    def prepare_default(self, value):
        return self.quote_value(value)

    def _is_referenced_by_fk_constraint(self, table_name, column_name=None, ignore_self=False):
        """
        Return whether or not the provided table name is referenced by another
        one. If `column_name` is specified, only references pointing to that
        column are considered. If `ignore_self` is True, self-referential
        constraints are ignored.
        """
        with self.connection.cursor() as cursor:
            for other_table in self.connection.introspection.get_table_list(cursor):
                if ignore_self and other_table.name == table_name:
                    continue
                relations = self.connection.introspection.get_relations(cursor, other_table.name)
                for constraint_column, constraint_table in relations.values():
                    if (constraint_table == table_name and
                            (column_name is None or constraint_column == column_name)):
                        return True
        return False

    def alter_db_table(self, model, old_db_table, new_db_table, disable_constraints=True):
        if (not self.connection.features.supports_atomic_references_rename and
                disable_constraints and self._is_referenced_by_fk_constraint(old_db_table)):
            if self.connection.in_atomic_block:
                raise NotSupportedError((
                    'Renaming the %r table while in a transaction is not '
                    'supported on SQLite < 3.26 because it would break referential '
                    'integrity. Try adding `atomic = False` to the Migration class.'
                ) % old_db_table)
            self.connection.enable_constraint_checking()
            super().alter_db_table(model, old_db_table, new_db_table)
            self.connection.disable_constraint_checking()
        else:
            super().alter_db_table(model, old_db_table, new_db_table)

    def alter_field(self, model, old_field, new_field, strict=False):
        if not self._field_should_be_altered(old_field, new_field):
            return
        old_field_name = old_field.name
        table_name = model._meta.db_table
        _, old_column_name = old_field.get_attname_column()
        if (new_field.name != old_field_name and
                not self.connection.features.supports_atomic_references_rename and
                self._is_referenced_by_fk_constraint(table_name, old_column_name, ignore_self=True)):
            if self.connection.in_atomic_block:
                raise NotSupportedError((
                    'Renaming the %r.%r column while in a transaction is not '
                    'supported on SQLite < 3.26 because it would break referential '
                    'integrity. Try adding `atomic = False` to the Migration class.'
                ) % (model._meta.db_table, old_field_name))
            with atomic(self.connection.alias):
                super().alter_field(model, old_field, new_field, strict=strict)
                # Follow SQLite's documented procedure for performing changes
                # that don't affect the on-disk content.
                # https://sqlite.org/lang_altertable.html#otheralter
                with self.connection.cursor() as cursor:
                    schema_version = cursor.execute('PRAGMA schema_version').fetchone()[0]
                    cursor.execute('PRAGMA writable_schema = 1')
                    references_template = ' REFERENCES "%s" ("%%s") ' % table_name
                    new_column_name = new_field.get_attname_column()[1]
                    search = references_template % old_column_name
                    replacement = references_template % new_column_name
                    cursor.execute('UPDATE sqlite_master SET sql = replace(sql, %s, %s)', (search, replacement))
                    cursor.execute('PRAGMA schema_version = %d' % (schema_version + 1))
                    cursor.execute('PRAGMA writable_schema = 0')
                    # The integrity check will raise an exception and rollback
                    # the transaction if the sqlite_master updates corrupt the
                    # database.
                    cursor.execute('PRAGMA integrity_check')
            # Perform a VACUUM to refresh the database representation from
            # the sqlite_master table.
            with self.connection.cursor() as cursor:
                cursor.execute('VACUUM')
        else:
            super().alter_field(model, old_field, new_field, strict=strict)

    def _remake_table(self, model, create_field=None, delete_field=None, alter_field=None):
        """
        Shortcut to transform a model from old_model into new_model

        This follows the correct procedure to perform non-rename or column
        addition operations based on SQLite's documentation

        https://www.sqlite.org/lang_altertable.html#caution

        The essential steps are:
          1. Create a table with the updated definition called "new__app_model"
          2. Copy the data from the existing "app_model" table to the new table
          3. Drop the "app_model" table
          4. Rename the "new__app_model" table to "app_model"
          5. Restore any index of the previous "app_model" table.
        """
        # Self-referential fields must be recreated rather than copied from
        # the old model to ensure their remote_field.field_name doesn't refer
        # to an altered field.
        def is_self_referential(f):
            return f.is_relation and f.remote_field.model is model
        # Work out the new fields dict / mapping
        body = {
            f.name: f.clone() if is_self_referential(f) else f
            for f in model._meta.local_concrete_fields
        }
        # Since mapping might mix column names and default values,
        # its values must be already quoted.
        mapping = {f.column: self.quote_name(f.column) for f in model._meta.local_concrete_fields}
        # This maps field names (not columns) for things like unique_together
        rename_mapping = {}
        # If any of the new or altered fields is introducing a new PK,
        # remove the old one
        restore_pk_field = None
        if getattr(create_field, 'primary_key', False) or (
                alter_field and getattr(alter_field[1], 'primary_key', False)):
            for name, field in list(body.items()):
                if field.primary_key:
                    field.primary_key = False
                    restore_pk_field = field
                    if field.auto_created:
                        del body[name]
                        del mapping[field.column]
        # Add in any created fields
        if create_field:
            body[create_field.name] = create_field
            # Choose a default and insert it into the copy map
            if not create_field.many_to_many and create_field.concrete:
                mapping[create_field.column] = self.prepare_default(
                    self.effective_default(create_field),
                )
        # Add in any altered fields
        if alter_field:
            old_field, new_field = alter_field
            body.pop(old_field.name, None)
            mapping.pop(old_field.column, None)
            body[new_field.name] = new_field
            if old_field.null and not new_field.null:
                case_sql = "coalesce(%(col)s, %(default)s)" % {
                    'col': self.quote_name(old_field.column),
                    'default': self.prepare_default(self.effective_default(new_field)),
                }
                mapping[new_field.column] = case_sql
            else:
                mapping[new_field.column] = self.quote_name(old_field.column)
            rename_mapping[old_field.name] = new_field.name
        # Remove any deleted fields
        if delete_field:
            del body[delete_field.name]
            del mapping[delete_field.column]
            # Remove any implicit M2M tables
            if delete_field.many_to_many and delete_field.remote_field.through._meta.auto_created:
                return self.delete_model(delete_field.remote_field.through)
        # Work inside a new app registry
        apps = Apps()

        # Work out the new value of unique_together, taking renames into
        # account
        unique_together = [
            [rename_mapping.get(n, n) for n in unique]
            for unique in model._meta.unique_together
        ]

        # Work out the new value for index_together, taking renames into
        # account
        index_together = [
            [rename_mapping.get(n, n) for n in index]
            for index in model._meta.index_together
        ]

        indexes = model._meta.indexes
        if delete_field:
            indexes = [
                index for index in indexes
                if delete_field.name not in index.fields
            ]

        constraints = list(model._meta.constraints)

        # Provide isolated instances of the fields to the new model body so
        # that the existing model's internals aren't interfered with when
        # the dummy model is constructed.
        body_copy = copy.deepcopy(body)

        # Construct a new model with the new fields to allow self referential
        # primary key to resolve to. This model won't ever be materialized as a
        # table and solely exists for foreign key reference resolution purposes.
        # This wouldn't be required if the schema editor was operating on model
        # states instead of rendered models.
        meta_contents = {
            'app_label': model._meta.app_label,
            'db_table': model._meta.db_table,
            'unique_together': unique_together,
            'index_together': index_together,
            'indexes': indexes,
            'constraints': constraints,
            'apps': apps,
        }
        meta = type("Meta", (), meta_contents)
        body_copy['Meta'] = meta
        body_copy['__module__'] = model.__module__
        type(model._meta.object_name, model.__bases__, body_copy)

        # Construct a model with a renamed table name.
        body_copy = copy.deepcopy(body)
        meta_contents = {
            'app_label': model._meta.app_label,
            'db_table': 'new__%s' % strip_quotes(model._meta.db_table),
            'unique_together': unique_together,
            'index_together': index_together,
            'indexes': indexes,
            'constraints': constraints,
            'apps': apps,
        }
        meta = type("Meta", (), meta_contents)
        body_copy['Meta'] = meta
        body_copy['__module__'] = model.__module__
        new_model = type('New%s' % model._meta.object_name, model.__bases__, body_copy)

        # Create a new table with the updated schema.
        self.create_model(new_model)

        # Copy data from the old table into the new table
        self.execute("INSERT INTO %s (%s) SELECT %s FROM %s" % (
            self.quote_name(new_model._meta.db_table),
            ', '.join(self.quote_name(x) for x in mapping),
            ', '.join(mapping.values()),
            self.quote_name(model._meta.db_table),
        ))

        # Delete the old table to make way for the new
        self.delete_model(model, handle_autom2m=False)

        # Rename the new table to take way for the old
        self.alter_db_table(
            new_model, new_model._meta.db_table, model._meta.db_table,
            disable_constraints=False,
        )

        # Run deferred SQL on correct table
        for sql in self.deferred_sql:
            self.execute(sql)
        self.deferred_sql = []
        # Fix any PK-removed field
        if restore_pk_field:
            restore_pk_field.primary_key = True

    def delete_model(self, model, handle_autom2m=True):
        if handle_autom2m:
            super().delete_model(model)
        else:
            # Delete the table (and only that)
            self.execute(self.sql_delete_table % {
                "table": self.quote_name(model._meta.db_table),
            })
            # Remove all deferred statements referencing the deleted table.
            for sql in list(self.deferred_sql):
                if isinstance(sql, Statement) and sql.references_table(model._meta.db_table):
                    self.deferred_sql.remove(sql)

    def add_field(self, model, field):
        """Create a field on a model."""
        # Fields with default values cannot by handled by ALTER TABLE ADD
        # COLUMN statement because DROP DEFAULT is not supported in
        # ALTER TABLE.
        if not field.null or self.effective_default(field) is not None:
            self._remake_table(model, create_field=field)
        else:
            super().add_field(model, field)

    def remove_field(self, model, field):
        """
        Remove a field from a model. Usually involves deleting a column,
        but for M2Ms may involve deleting a table.
        """
        # M2M fields are a special case
        if field.many_to_many:
            # For implicit M2M tables, delete the auto-created table
            if field.remote_field.through._meta.auto_created:
                self.delete_model(field.remote_field.through)
            # For explicit "through" M2M fields, do nothing
        # For everything else, remake.
        else:
            # It might not actually have a column behind it
            if field.db_parameters(connection=self.connection)['type'] is None:
                return
            self._remake_table(model, delete_field=field)

    def _alter_field(self, model, old_field, new_field, old_type, new_type,
                     old_db_params, new_db_params, strict=False):
        """Perform a "physical" (non-ManyToMany) field update."""
        # Use "ALTER TABLE ... RENAME COLUMN" if only the column name
        # changed and there aren't any constraints.
        if (self.connection.features.can_alter_table_rename_column and
            old_field.column != new_field.column and
            self.column_sql(model, old_field) == self.column_sql(model, new_field) and

[87 more lines in /testbed/django/db/backends/sqlite3/schema.py (447 in all). read_file with offset: 361 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"add_field\\|Cannot add a UNIQUE\\|unique.*add\" tests/schema/tests.py | grep -i \"unique\\|null\" | head -30; grep -rn \"OneToOne\" tests/schema/tests.py | head"
}
```

**tool result**

```
764:        # Redundant unique constraint is not added.
3423:    def test_add_field_default_nullable(self):
16:    Index, IntegerField, JSONField, ManyToManyField, Model, OneToOneField,
1149:        #24163 - Tests altering of OneToOneField to ForeignKey
1165:        # Alter the OneToOneField to ForeignKey
1181:        #24163 - Tests altering of ForeignKey to OneToOneField
1196:        # Alter the ForeignKey to OneToOneField
1198:        new_field = OneToOneField(Author, CASCADE)
1229:        new_field = OneToOneField(Author, CASCADE)
1239:        # The index on ForeignKey is replaced with a unique constraint for OneToOneField.
1303:        # The unique constraint on OneToOneField is replaced with an index for ForeignKey.
1322:        new_field = OneToOneField(Author, PROTECT)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '3400,3450p' tests/schema/tests.py; grep -n \"def test_add_field\" tests/schema/tests.py"
}
```

**tool result**

```
        # Ensure there's no surname field
        columns = self.column_classes(Author)
        self.assertNotIn("surname", columns)
        # Create a row
        Author.objects.create(name='Anonymous1')
        # Add new CharField with a default
        new_field = CharField(max_length=15, blank=True, default='surname default')
        new_field.set_attributes_from_name("surname")
        with connection.schema_editor() as editor:
            editor.add_field(Author, new_field)
        # Ensure field was added with the right default
        with connection.cursor() as cursor:
            cursor.execute("SELECT surname FROM schema_author;")
            item = cursor.fetchall()[0]
            self.assertEqual(item[0], 'surname default')
            # And that the default is no longer set in the database.
            field = next(
                f for f in connection.introspection.get_table_description(cursor, "schema_author")
                if f.name == "surname"
            )
            if connection.features.can_introspect_default:
                self.assertIsNone(field.default)

    def test_add_field_default_nullable(self):
        with connection.schema_editor() as editor:
            editor.create_model(Author)
        # Add new nullable CharField with a default.
        new_field = CharField(max_length=15, blank=True, null=True, default='surname')
        new_field.set_attributes_from_name('surname')
        with connection.schema_editor() as editor:
            editor.add_field(Author, new_field)
        Author.objects.create(name='Anonymous1')
        with connection.cursor() as cursor:
            cursor.execute('SELECT surname FROM schema_author;')
            item = cursor.fetchall()[0]
            self.assertIsNone(item[0])
            field = next(
                f
                for f in connection.introspection.get_table_description(
                    cursor,
                    'schema_author',
                )
                if f.name == 'surname'
            )
            # Field is still nullable.
            self.assertTrue(field.null_ok)
            # The database default is no longer set.
            if connection.features.can_introspect_default:
                self.assertIn(field.default, ['NULL', None])

    def test_add_textfield_default_nullable(self):
502:    def test_add_field(self):
534:    def test_add_field_remove_field(self):
545:    def test_add_field_temp_default(self):
568:    def test_add_field_temp_default_boolean(self):
592:    def test_add_field_default_transform(self):
627:    def test_add_field_binary(self):
644:    def test_add_field_durationfield_with_default(self):
3372:    def test_add_field_use_effective_default(self):
3396:    def test_add_field_default_dropped(self):
3423:    def test_add_field_default_nullable(self):
4060:    def test_add_field_db_collation(self):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '500,570p' tests/schema/tests.py; python -c \"import sqlite3; print(sqlite3.sqlite_version)\""
}
```

**tool result**

```
        self._test_m2m_db_constraint(InheritedManyToManyField)

    def test_add_field(self):
        """
        Tests adding fields to models
        """
        # Create the table
        with connection.schema_editor() as editor:
            editor.create_model(Author)
        # Ensure there's no age field
        columns = self.column_classes(Author)
        self.assertNotIn("age", columns)
        # Add the new field
        new_field = IntegerField(null=True)
        new_field.set_attributes_from_name("age")
        with CaptureQueriesContext(connection) as ctx, connection.schema_editor() as editor:
            editor.add_field(Author, new_field)
        drop_default_sql = editor.sql_alter_column_no_default % {
            'column': editor.quote_name(new_field.name),
        }
        self.assertFalse(any(drop_default_sql in query['sql'] for query in ctx.captured_queries))
        # Table is not rebuilt.
        self.assertIs(any(
            'CREATE TABLE' in query['sql']
            for query in ctx.captured_queries
        ), False)
        self.assertIs(any(
            'DROP TABLE' in query['sql']
            for query in ctx.captured_queries
        ), False)
        columns = self.column_classes(Author)
        self.assertEqual(columns['age'][0], connection.features.introspected_field_types['IntegerField'])
        self.assertTrue(columns['age'][1][6])

    def test_add_field_remove_field(self):
        """
        Adding a field and removing it removes all deferred sql referring to it.
        """
        with connection.schema_editor() as editor:
            # Create a table with a unique constraint on the slug field.
            editor.create_model(Tag)
            # Remove the slug column.
            editor.remove_field(Tag, Tag._meta.get_field('slug'))
        self.assertEqual(editor.deferred_sql, [])

    def test_add_field_temp_default(self):
        """
        Tests adding fields to models with a temporary default
        """
        # Create the table
        with connection.schema_editor() as editor:
            editor.create_model(Author)
        # Ensure there's no age field
        columns = self.column_classes(Author)
        self.assertNotIn("age", columns)
        # Add some rows of data
        Author.objects.create(name="Andrew", height=30)
        Author.objects.create(name="Andrea")
        # Add a not-null field
        new_field = CharField(max_length=30, default="Godwin")
        new_field.set_attributes_from_name("surname")
        with connection.schema_editor() as editor:
            editor.add_field(Author, new_field)
        columns = self.column_classes(Author)
        self.assertEqual(columns['surname'][0], connection.features.introspected_field_types['CharField'])
        self.assertEqual(columns['surname'][1][6],
                         connection.features.interprets_empty_strings_as_nulls)

    def test_add_field_temp_default_boolean(self):
        """
        Tests adding fields to models with a temporary default where
3.45.3
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def column_sql\\|def add_field\\|unique\" django/db/backends/base/schema.py | head -40; sed -n '460,560p' django/db/backends/base/schema.py"
}
```

**tool result**

```
77:    sql_unique_constraint = "UNIQUE (%(columns)s)%(deferrable)s"
85:    sql_create_unique = "ALTER TABLE %(table)s ADD CONSTRAINT %(name)s UNIQUE (%(columns)s)%(deferrable)s"
86:    sql_delete_unique = sql_delete_constraint
97:    sql_create_unique_index = "CREATE UNIQUE INDEX %(name)s ON %(table)s (%(columns)s)%(include)s%(condition)s"
158:        # Add any unique_togethers (always deferred, as some fields might be
160:        for field_names in model._meta.unique_together:
162:            self.deferred_sql.append(self._create_unique_sql(model, fields))
254:        elif field.unique:
258:        if tablespace and self.connection.features.supports_tablespaces and field.unique:
261:    def column_sql(self, model, field, include_default=False):
350:        Create a table and any accompanying indexes or unique constraints for
415:    def alter_unique_together(self, model, old_unique_together, new_unique_together):
417:        Deal with a model changing its unique_together. The input
418:        unique_togethers must be doubly-nested, not the single-nested
421:        olds = {tuple(fields) for fields in old_unique_together}
422:        news = {tuple(fields) for fields in new_unique_together}
423:        # Deleted uniques
425:            self._delete_composed_index(model, fields, {'unique': True}, self.sql_delete_unique)
426:        # Created uniques
429:            self.execute(self._create_unique_sql(model, fields))
444:                {'index': True, 'unique': False},
491:    def add_field(self, model, field):
580:        Allow a field's type, uniqueness, nullability, default, column,
641:        # Has unique been removed?
642:        if old_field.unique and (not new_field.unique or self._field_became_primary_key(old_field, new_field)):
643:            # Find the unique constraint for this field
646:                model, [old_field.column], unique=True, primary_key=False,
650:                raise ValueError("Found wrong number (%s) of unique constraints for %s.%s" % (
656:                self.execute(self._delete_unique_sql(model, constraint_name))
657:        # Drop incoming FK constraints if the field is a primary key or unique,
662:                (old_field.unique and new_field.unique)
675:        # Remove indexes if db_index switched to False or a unique constraint
679:        # old_field.db_index | old_field.unique | new_field.db_index | new_field.unique
684:        if old_field.db_index and not old_field.unique and (not new_field.db_index or new_field.unique):
808:        # Added a unique?
809:        if self._unique_should_be_added(old_field, new_field):
810:            self.execute(self._create_unique_sql(model, [new_field]))
811:        # Added an index? Add an index if db_index switched to True or a unique
815:        # old_field.db_index | old_field.unique | new_field.db_index | new_field.unique
820:        if (not old_field.db_index or old_field.unique) and new_field.db_index and not new_field.unique:
        if len(constraint_names) != 1:
            raise ValueError("Found wrong number (%s) of constraints for %s(%s)" % (
                len(constraint_names),
                model._meta.db_table,
                ", ".join(columns),
            ))
        self.execute(self._delete_constraint_sql(sql, model, constraint_names[0]))

    def alter_db_table(self, model, old_db_table, new_db_table):
        """Rename the table a model points to."""
        if (old_db_table == new_db_table or
            (self.connection.features.ignores_table_name_case and
                old_db_table.lower() == new_db_table.lower())):
            return
        self.execute(self.sql_rename_table % {
            "old_table": self.quote_name(old_db_table),
            "new_table": self.quote_name(new_db_table),
        })
        # Rename all references to the old table name.
        for sql in self.deferred_sql:
            if isinstance(sql, Statement):
                sql.rename_table_references(old_db_table, new_db_table)

    def alter_db_tablespace(self, model, old_db_tablespace, new_db_tablespace):
        """Move a model's table between tablespaces."""
        self.execute(self.sql_retablespace_table % {
            "table": self.quote_name(model._meta.db_table),
            "old_tablespace": self.quote_name(old_db_tablespace),
            "new_tablespace": self.quote_name(new_db_tablespace),
        })

    def add_field(self, model, field):
        """
        Create a field on a model. Usually involves adding a column, but may
        involve adding a table instead (for M2M fields).
        """
        # Special-case implicit M2M tables
        if field.many_to_many and field.remote_field.through._meta.auto_created:
            return self.create_model(field.remote_field.through)
        # Get the column's definition
        definition, params = self.column_sql(model, field, include_default=True)
        # It might not actually have a column behind it
        if definition is None:
            return
        # Check constraints can go on the column SQL here
        db_params = field.db_parameters(connection=self.connection)
        if db_params['check']:
            definition += " " + self.sql_check_constraint % db_params
        if field.remote_field and self.connection.features.supports_foreign_keys and field.db_constraint:
            constraint_suffix = '_fk_%(to_table)s_%(to_column)s'
            # Add FK constraint inline, if supported.
            if self.sql_create_column_inline_fk:
                to_table = field.remote_field.model._meta.db_table
                to_column = field.remote_field.model._meta.get_field(field.remote_field.field_name).column
                namespace, _ = split_identifier(model._meta.db_table)
                definition += " " + self.sql_create_column_inline_fk % {
                    'name': self._fk_constraint_name(model, field, constraint_suffix),
                    'namespace': '%s.' % self.quote_name(namespace) if namespace else '',
                    'column': self.quote_name(field.column),
                    'to_table': self.quote_name(to_table),
                    'to_column': self.quote_name(to_column),
                    'deferrable': self.connection.ops.deferrable_sql()
                }
            # Otherwise, add FK constraints later.
            else:
                self.deferred_sql.append(self._create_fk_sql(model, field, constraint_suffix))
        # Build the SQL and run it
        sql = self.sql_create_column % {
            "table": self.quote_name(model._meta.db_table),
            "column": self.quote_name(field.column),
            "definition": definition,
        }
        self.execute(sql, params)
        # Drop the default if we need to
        # (Django usually does not use in-database defaults)
        if not self.skip_default_on_alter(field) and self.effective_default(field) is not None:
            changes_sql, params = self._alter_column_default_sql(model, None, field, drop=True)
            sql = self.sql_alter_column % {
                "table": self.quote_name(model._meta.db_table),
                "changes": changes_sql,
            }
            self.execute(sql, params)
        # Add an index, if required
        self.deferred_sql.extend(self._field_indexes_sql(model, field))
        # Reset connection if required
        if self.connection.features.connection_persists_old_columns:
            self.connection.close()

    def remove_field(self, model, field):
        """
        Remove a field from a model. Usually involves deleting a column,
        but for M2Ms may involve deleting a table.
        """
        # Special-case implicit M2M tables
        if field.many_to_many and field.remote_field.through._meta.auto_created:
            return self.delete_model(field.remote_field.through)
        # It might not actually have a column behind it
        if field.db_parameters(connection=self.connection)['type'] is None:
            return
        # Drop any FK constraints, MySQL requires explicit deletion
        if field.remote_field:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"unique=True\\|Unique\" tests/schema/tests.py | sed -n '1,80p'"
}
```

**tool result**

```
18:    SmallIntegerField, TextField, TimeField, UniqueConstraint, UUIDField,
39:    AuthorWithIndexedNameAndBirthday, AuthorWithUniqueName,
40:    AuthorWithUniqueNameAndBirthday, Book, BookForeignObj, BookWeak,
42:    Node, Note, NoteRename, Tag, TagIndexed, TagM2MTest, TagUniqueRename,
43:    Thing, UniqueTest, new_apps,
62:        Tag, TagIndexed, TagM2MTest, TagUniqueRename, Thing, UniqueTest,
919:            editor.create_model(UniqueTest)
921:            UniqueTest.objects.create(year=None, slug='aaa')
922:        old_field = UniqueTest._meta.get_field("year")
926:            editor.alter_field(UniqueTest, old_field, new_field, strict=True)
928:            UniqueTest.objects.create(year=None, slug='bbb')
1427:            j = IntegerField(unique=True)
1457:            j = IntegerField(unique=True)
1493:        IntegerField(unique=True).
1499:        new_field = IntegerField(unique=True)
1513:            i = IntegerField(unique=True)
1514:            j = IntegerField(unique=True)
1531:        class IntegerUnique(Model):
1532:            i = IntegerField(unique=True)
1541:        IntegerUnique.objects.create(i=1, j=1)
1543:            IntegerUnique.objects.create(i=1, j=2)
1569:            name = CharField(max_length=255, unique=True)
1583:        new_field = CharField(max_length=255, unique=True)
1805:            editor.create_model(UniqueTest)
1815:        new_field = M2MFieldClass(UniqueTest)
1826:        # Ensure the new M2M exists and points to UniqueTest
1998:        new_field2 = SlugField(unique=True)
2008:        new_field3 = SlugField(unique=True)
2013:        TagUniqueRename.objects.create(title="foo", slug2="foo")
2015:            TagUniqueRename.objects.create(title="bar", slug2="foo")
2019:        old_table_name = TagUniqueRename._meta.db_table
2022:                editor.create_model(TagUniqueRename)
2023:                editor.alter_db_table(TagUniqueRename, old_table_name, 'unique-table')
2024:                TagUniqueRename._meta.db_table = 'unique-table'
2026:                editor.alter_unique_together(TagUniqueRename, [], (('title', 'slug2'),))
2028:            TagUniqueRename._meta.db_table = old_table_name
2040:            name = CharField(max_length=254, unique=True)
2054:        new_field = CharField(max_length=255, unique=True)
2071:            slug = SlugField(unique=True)
2086:        new_field = SlugField(max_length=75, unique=True)
2102:            editor.create_model(AuthorWithUniqueName)
2104:        constraint = UniqueConstraint(fields=['name'], name='author_name_uniq')
2106:        AuthorWithUniqueName._meta.constraints = [constraint]
2108:            editor.add_constraint(AuthorWithUniqueName, constraint)
2110:        constraints = self.get_constraints(AuthorWithUniqueName._meta.db_table)
2118:        old_field = AuthorWithUniqueName._meta.get_field('name')
2122:            editor.alter_field(AuthorWithUniqueName, old_field, new_field, strict=True)
2123:        constraints = self.get_constraints(AuthorWithUniqueName._meta.db_table)
2131:        new_field2 = AuthorWithUniqueName._meta.get_field('name')
2133:            editor.alter_field(AuthorWithUniqueName, new_field, new_field2, strict=True)
2134:        constraints = self.get_constraints(AuthorWithUniqueName._meta.db_table)
2143:            AuthorWithUniqueName._meta.constraints = []
2144:            editor.remove_constraint(AuthorWithUniqueName, constraint)
2152:            editor.create_model(UniqueTest)
2154:        UniqueTest.objects.create(year=2012, slug="foo")
2155:        UniqueTest.objects.create(year=2011, slug="foo")
2156:        UniqueTest.objects.create(year=2011, slug="bar")
2158:            UniqueTest.objects.create(year=2012, slug="foo")
2159:        UniqueTest.objects.all().delete()
2162:            editor.alter_unique_together(UniqueTest, UniqueTest._meta.unique_together, [])
2164:        UniqueTest.objects.create(year=2012, slug="foo")
2165:        UniqueTest.objects.create(year=2012, slug="foo")
2166:        UniqueTest.objects.all().delete()
2168:        new_field2 = SlugField(unique=True)
2171:            editor.alter_unique_together(UniqueTest, [], UniqueTest._meta.unique_together)
2173:        UniqueTest.objects.create(year=2012, slug="foo")
2175:            UniqueTest.objects.create(year=2012, slug="foo")
2176:        UniqueTest.objects.all().delete()
2221:            editor.create_model(AuthorWithUniqueNameAndBirthday)
2223:        constraint = UniqueConstraint(fields=['name', 'birthday'], name='author_name_birthday_uniq')
2225:        AuthorWithUniqueNameAndBirthday._meta.constraints = [constraint]
2227:            editor.add_constraint(AuthorWithUniqueNameAndBirthday, constraint)
2229:        constraints = self.get_constraints(AuthorWithUniqueNameAndBirthday._meta.db_table)
2237:        unique_together = AuthorWithUniqueNameAndBirthday._meta.unique_together
2239:            editor.alter_unique_together(AuthorWithUniqueNameAndBirthday, unique_together, [])
2240:        constraints = self.get_constraints(AuthorWithUniqueNameAndBirthday._meta.db_table)
2249:            editor.alter_unique_together(AuthorWithUniqueNameAndBirthday, [], unique_together)
2250:        constraints = self.get_constraints(AuthorWithUniqueNameAndBirthday._meta.db_table)
2259:            AuthorWithUniqueNameAndBirthday._meta.constraints = []
2260:            editor.remove_constraint(AuthorWithUniqueNameAndBirthday, constraint)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1480,1545p' tests/schema/tests.py; sed -n '240,270p' django/db/backends/base/schema.py"
}
```

**tool result**

```
        with connection.schema_editor() as editor:
            editor.create_model(SmallIntegerPK)
        self.isolated_local_models = [SmallIntegerPK]
        old_field = SmallIntegerPK._meta.get_field('i')
        new_field = SmallAutoField(primary_key=True)
        new_field.model = SmallIntegerPK
        new_field.set_attributes_from_name('i')
        with connection.schema_editor() as editor:
            editor.alter_field(SmallIntegerPK, old_field, new_field, strict=True)

    def test_alter_int_pk_to_int_unique(self):
        """
        Should be able to rename an IntegerField(primary_key=True) to
        IntegerField(unique=True).
        """
        with connection.schema_editor() as editor:
            editor.create_model(IntegerPK)
        # Delete the old PK
        old_field = IntegerPK._meta.get_field('i')
        new_field = IntegerField(unique=True)
        new_field.model = IntegerPK
        new_field.set_attributes_from_name('i')
        with connection.schema_editor() as editor:
            editor.alter_field(IntegerPK, old_field, new_field, strict=True)
        # The primary key constraint is gone. Result depends on database:
        # 'id' for SQLite, None for others (must not be 'i').
        self.assertIn(self.get_primary_key(IntegerPK._meta.db_table), ('id', None))

        # Set up a model class as it currently stands. The original IntegerPK
        # class is now out of date and some backends make use of the whole
        # model class when modifying a field (such as sqlite3 when remaking a
        # table) so an outdated model class leads to incorrect results.
        class Transitional(Model):
            i = IntegerField(unique=True)
            j = IntegerField(unique=True)

            class Meta:
                app_label = 'schema'
                apps = new_apps
                db_table = 'INTEGERPK'

        # model requires a new PK
        old_field = Transitional._meta.get_field('j')
        new_field = IntegerField(primary_key=True)
        new_field.model = Transitional
        new_field.set_attributes_from_name('j')

        with connection.schema_editor() as editor:
            editor.alter_field(Transitional, old_field, new_field, strict=True)

        # Create a model class representing the updated model.
        class IntegerUnique(Model):
            i = IntegerField(unique=True)
            j = IntegerField(primary_key=True)

            class Meta:
                app_label = 'schema'
                apps = new_apps
                db_table = 'INTEGERPK'

        # Ensure unique constraint works.
        IntegerUnique.objects.create(i=1, j=1)
        with self.assertRaises(IntegrityError):
            IntegerUnique.objects.create(i=1, j=2)

    def test_rename(self):
                else:
                    yield column_default
                    params.append(default_value)
        # Oracle treats the empty string ('') as null, so coerce the null
        # option whenever '' is a possible value.
        if (field.empty_strings_allowed and not field.primary_key and
                self.connection.features.interprets_empty_strings_as_nulls):
            null = True
        if not null:
            yield 'NOT NULL'
        elif not self.connection.features.implied_column_null:
            yield 'NULL'
        if field.primary_key:
            yield 'PRIMARY KEY'
        elif field.unique:
            yield 'UNIQUE'
        # Optionally add the tablespace if it's an implicitly indexed column.
        tablespace = field.db_tablespace or model._meta.db_tablespace
        if tablespace and self.connection.features.supports_tablespaces and field.unique:
            yield self.connection.ops.tablespace_sql(tablespace, inline=True)

    def column_sql(self, model, field, include_default=False):
        """
        Return the column definition for a field. The field must already have
        had set_attributes_from_name() called.
        """
        # Get the column's type and use that as the basis of the SQL.
        db_params = field.db_parameters(connection=self.connection)
        column_db_type = db_params['type']
        # Check for fields that aren't actually columns (e.g. M2M).
        if column_db_type is None:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/db/backends/sqlite3/schema.py\n@@\n     def add_field(self, model, field):\n         \"\"\"Create a field on a model.\"\"\"\n-        # Fields with default values cannot by handled by ALTER TABLE ADD\n-        # COLUMN statement because DROP DEFAULT is not supported in\n-        # ALTER TABLE.\n-        if not field.null or self.effective_default(field) is not None:\n+        if (\n+            # Fields with default values cannot by handled by ALTER TABLE ADD\n+            # COLUMN statement because DROP DEFAULT is not supported in\n+            # ALTER TABLE.\n+            not field.null or\n+            self.effective_default(field) is not None or\n+            # Adding a unique column is not supported by ALTER TABLE ADD\n+            # COLUMN.\n+            field.unique\n+        ):\n             self._remake_table(model, create_field=field)\n         else:\n             super().add_field(model, field)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/db/backends/sqlite3/schema.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/db/backends/sqlite3/schema.py now (453 lines), around the change:
324:
325:    def add_field(self, model, field):
326:        """Create a field on a model."""
327:        if (
328:            # Fields with default values cannot by handled by ALTER TABLE ADD
329:            # COLUMN statement because DROP DEFAULT is not supported in
330:            # ALTER TABLE.
331:            not field.null or
332:            self.effective_default(field) is not None or
333:            # Adding a unique column is not supported by ALTER TABLE ADD
334:            # COLUMN.
335:            field.unique
336:        ):
337:            self._remake_table(model, create_field=field)
338:        else:
339:            super().add_field(model, field)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,80p' tests/schema/tests.py; grep -n \"class Author\\b\\|class Author(\" tests/schema/models.py; sed -n '1,60p' tests/schema/models.py"
}
```

**tool result**

```
import datetime
import itertools
import unittest
from copy import copy
from unittest import mock

from django.core.exceptions import FieldError
from django.core.management.color import no_style
from django.db import (
    DatabaseError, DataError, IntegrityError, OperationalError, connection,
)
from django.db.models import (
    CASCADE, PROTECT, AutoField, BigAutoField, BigIntegerField, BinaryField,
    BooleanField, CharField, CheckConstraint, DateField, DateTimeField,
    DecimalField, DurationField, F, FloatField, ForeignKey, ForeignObject,
    Index, IntegerField, JSONField, ManyToManyField, Model, OneToOneField,
    OrderBy, PositiveIntegerField, Q, SlugField, SmallAutoField,
    SmallIntegerField, TextField, TimeField, UniqueConstraint, UUIDField,
    Value,
)
from django.db.models.fields.json import KeyTextTransform
from django.db.models.functions import Abs, Cast, Collate, Lower, Random, Upper
from django.db.models.indexes import IndexExpression
from django.db.transaction import TransactionManagementError, atomic
from django.test import (
    TransactionTestCase, skipIfDBFeature, skipUnlessDBFeature,
)
from django.test.utils import (
    CaptureQueriesContext, isolate_apps, register_lookup,
)
from django.utils import timezone

from .fields import (
    CustomManyToManyField, InheritedManyToManyField, MediumBlobField,
)
from .models import (
    Author, AuthorCharFieldWithIndex, AuthorTextFieldWithIndex,
    AuthorWithDefaultHeight, AuthorWithEvenLongerName, AuthorWithIndexedName,
    AuthorWithIndexedNameAndBirthday, AuthorWithUniqueName,
    AuthorWithUniqueNameAndBirthday, Book, BookForeignObj, BookWeak,
    BookWithLongName, BookWithO2O, BookWithoutAuthor, BookWithSlug, IntegerPK,
    Node, Note, NoteRename, Tag, TagIndexed, TagM2MTest, TagUniqueRename,
    Thing, UniqueTest, new_apps,
)


class SchemaTests(TransactionTestCase):
    """
    Tests for the schema-alteration code.

    Be aware that these tests are more liable than most to false results,
    as sometimes the code to check if a test has worked is almost as complex
    as the code it is testing.
    """

    available_apps = []

    models = [
        Author, AuthorCharFieldWithIndex, AuthorTextFieldWithIndex,
        AuthorWithDefaultHeight, AuthorWithEvenLongerName, Book, BookWeak,
        BookWithLongName, BookWithO2O, BookWithSlug, IntegerPK, Node, Note,
        Tag, TagIndexed, TagM2MTest, TagUniqueRename, Thing, UniqueTest,
    ]

    # Utility functions

    def setUp(self):
        # local_models should contain test dependent model classes that will be
        # automatically removed from the app cache on test tear down.
        self.local_models = []
        # isolated_local_models contains models that are in test methods
        # decorated with @isolate_apps.
        self.isolated_local_models = []

    def tearDown(self):
        # Delete any tables made for our models
        self.delete_tables()
        new_apps.clear_cache()
        for model in new_apps.get_models():
            model._meta._expire_cache()
11:class Author(models.Model):
from django.apps.registry import Apps
from django.db import models

# Because we want to test creation and deletion of these as separate things,
# these models are all inserted into a separate Apps so the main test
# runner doesn't migrate them.

new_apps = Apps()


class Author(models.Model):
    name = models.CharField(max_length=255)
    height = models.PositiveIntegerField(null=True, blank=True)
    weight = models.IntegerField(null=True, blank=True)
    uuid = models.UUIDField(null=True)

    class Meta:
        apps = new_apps


class AuthorCharFieldWithIndex(models.Model):
    char_field = models.CharField(max_length=31, db_index=True)

    class Meta:
        apps = new_apps


class AuthorTextFieldWithIndex(models.Model):
    text_field = models.TextField(db_index=True)

    class Meta:
        apps = new_apps


class AuthorWithDefaultHeight(models.Model):
    name = models.CharField(max_length=255)
    height = models.PositiveIntegerField(null=True, blank=True, default=42)

    class Meta:
        apps = new_apps


class AuthorWithEvenLongerName(models.Model):
    name = models.CharField(max_length=255)
    height = models.PositiveIntegerField(null=True, blank=True)

    class Meta:
        apps = new_apps


class AuthorWithIndexedName(models.Model):
    name = models.CharField(max_length=255, db_index=True)

    class Meta:
        apps = new_apps


class AuthorWithUniqueName(models.Model):
    name = models.CharField(max_length=255, unique=True)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/schema/tests.py\n@@\n     def test_add_field(self):\n         \"\"\"\n         Tests adding fields to models\n         \"\"\"\n@@\n         self.assertEqual(columns['age'][0], connection.features.introspected_field_types['IntegerField'])\n         self.assertTrue(columns['age'][1][6])\n \n+    def test_add_field_unique_nullable(self):\n+        with connection.schema_editor() as editor:\n+            editor.create_model(Author)\n+        new_field = CharField(max_length=15, null=True, unique=True)\n+        new_field.set_attributes_from_name('surname')\n+        with connection.schema_editor() as editor:\n+            editor.add_field(Author, new_field)\n+        columns = self.column_classes(Author)\n+        self.assertEqual(\n+            columns['surname'][0],\n+            connection.features.introspected_field_types['CharField'],\n+        )\n+        self.assertTrue(columns['surname'][1][6])\n+        constraints = self.get_constraints(Author._meta.db_table)\n+        self.assertTrue(any(\n+            constraint['unique'] and constraint['columns'] == ['surname']\n+            for constraint in constraints.values()\n+        ))\n+\n+    def test_add_field_one_to_one_nullable(self):\n+        with connection.schema_editor() as editor:\n+            editor.create_model(Author)\n+        new_field = OneToOneField(\n+            Author, null=True, on_delete=CASCADE, related_name='+',\n+        )\n+        new_field.set_attributes_from_name('author')\n+        with connection.schema_editor() as editor:\n+            editor.add_field(Author, new_field)\n+        columns = self.column_classes(Author)\n+        self.assertIn('author_id', columns)\n+        self.assertTrue(columns['author_id'][1][6])\n+        constraints = self.get_constraints(Author._meta.db_table)\n+        self.assertTrue(any(\n+            constraint['unique'] and constraint['columns'] == ['author_id']\n+            for constraint in constraints.values()\n+        ))\n+\n     def test_add_field_remove_field(self):\n         \"\"\"\n         Adding a field and removing it removes all deferred sql referring to it.\n         \"\"\"\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/schema/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/schema/tests.py now (4207 lines), around the change:
530:        columns = self.column_classes(Author)
531:        self.assertEqual(columns['age'][0], connection.features.introspected_field_types['IntegerField'])
532:        self.assertTrue(columns['age'][1][6])
533:
534:    def test_add_field_unique_nullable(self):
535:        with connection.schema_editor() as editor:
536:            editor.create_model(Author)
537:        new_field = CharField(max_length=15, null=True, unique=True)
538:        new_field.set_attributes_from_name('surname')
539:        with connection.schema_editor() as editor:
540:            editor.add_field(Author, new_field)
541:        columns = self.column_classes(Author)
542:        self.assertEqual(
543:            columns['surname'][0],
544:            connection.features.introspected_field_types['CharField'],
545:        )
546:        self.assertTrue(columns['surname'][1][6])
547:        constraints = self.get_constraints(Author._meta.db_table)
548:        self.assertTrue(any(
549:            constraint['unique'] and constraint['columns'] == ['surname']
550:            for constraint in constraints.values()
551:        ))
552:
553:    def test_add_field_one_to_one_nullable(self):
554:        with connection.schema_editor() as editor:
555:            editor.create_model(Author)
556:        new_field = OneToOneField(
557:            Author, null=True, on_delete=CASCADE, related_name='+',
558:        )
559:        new_field.set_attributes_from_name('author')
560:        with connection.schema_editor() as editor:
561:            editor.add_field(Author, new_field)
562:        columns = self.column_classes(Author)
563:        self.assertIn('author_id', columns)
564:        self.assertTrue(columns['author_id'][1][6])
565:        constraints = self.get_constraints(Author._meta.db_table)
566:        self.assertTrue(any(
567:            constraint['unique'] and constraint['columns'] == ['author_id']
568:            for constraint in constraints.values()
569:        ))
570:
571:    def test_add_field_remove_field(self):
572:        """
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py schema.tests.SchemaTests.test_add_field_unique_nullable schema.tests.SchemaTests.test_add_field_one_to_one_nullable schema.tests.SchemaTests.test_add_field --verbosity=2 2>&1 | tail -40"
}
```

**tool result**

```
Creating test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Testing against Django installed in '/testbed/django' with up to 8 processes
Importing application schema
Found 3 test(s).
Skipping setup of unused database(s): other.
Operations to perform:
  Synchronize unmigrated apps: auth, contenttypes, messages, schema, sessions, staticfiles
  Apply all migrations: admin, sites
Synchronizing apps without migrations:
  Creating tables...
    Creating table django_content_type
    Creating table auth_permission
    Creating table auth_group
    Creating table auth_user
    Creating table django_session
    Running deferred SQL...
Running migrations:
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying sites.0001_initial... OK
  Applying sites.0002_alter_domain_unique... OK
System check identified no issues (0 silenced).
test_add_field_unique_nullable (schema.tests.SchemaTests) ... ok
test_add_field_one_to_one_nullable (schema.tests.SchemaTests) ... ok
test_add_field (schema.tests.SchemaTests)
Tests adding fields to models ... ok

----------------------------------------------------------------------
Ran 3 tests in 0.054s

OK
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py schema --verbosity=1 2>&1 | tail -25"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 175 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.s.................sss...s.ss.....s..ss.sss.s......ss.s......................s.............s.....................s..s....s...s....................s............s......s...s...s
----------------------------------------------------------------------
Ran 175 tests in 1.590s

OK (skipped=28)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant**

```
Implemented the fix.

**Root cause:** SQLite's `ALTER TABLE ... ADD COLUMN` cannot add a `UNIQUE` column. `DatabaseSchemaEditor.add_field()` only remade the table for non-nullable fields or fields with defaults, so a nullable `OneToOneField`/`unique=True` field fell through to the plain `ADD COLUMN` path and raised `OperationalError: Cannot add a UNIQUE column`.

**Change** — `django/db/backends/sqlite3/schema.py`, `add_field()`:
- Also route `field.unique` fields through `_remake_table()`, which rebuilds the table with the full schema (including the unique constraint) and copies the data. This matches the existing handling of defaults/not-null fields and works for the nullable `OneToOneField` from django-oauth-toolkit.

**Tests added** — `tests/schema/tests.py`:
- `test_add_field_unique_nullable`: adds a nullable `CharField(unique=True)` and verifies the column is nullable and has a unique constraint.
- `test_add_field_one_to_one_nullable`: adds a nullable self-referential `OneToOneField` and verifies the `*_id` column, nullability, and unique constraint.

Verification: the three targeted tests pass, and the full `schema` suite passes (175 tests, 28 skipped). No commits or tree changes beyond the patch; `.memdoor/` untouched.
```

## Run folder `team-solve-2026-11-06T111729`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
d87e54e73965c30f7f8196b7ca1bb717c97879d2
```

### `baseline-check.log`

```
check: ./tests/runtests.py schema
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 173 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.s...............sss...s.ss.....s..ss.sss.s......ss.s......................s.............s.....................s..s....s...s....................s............s......s...s...s
----------------------------------------------------------------------
Ran 173 tests in 2.358s

OK (skipped=28)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/django/db/backends/sqlite3/schema.py b/django/db/backends/sqlite3/schema.py
index 6752a8e3c0..510430ddd3 100644
--- a/django/db/backends/sqlite3/schema.py
+++ b/django/db/backends/sqlite3/schema.py
@@ -324,10 +324,16 @@ class DatabaseSchemaEditor(BaseDatabaseSchemaEditor):
 
     def add_field(self, model, field):
         """Create a field on a model."""
-        # Fields with default values cannot by handled by ALTER TABLE ADD
-        # COLUMN statement because DROP DEFAULT is not supported in
-        # ALTER TABLE.
-        if not field.null or self.effective_default(field) is not None:
+        if (
+            # Fields with default values cannot by handled by ALTER TABLE ADD
+            # COLUMN statement because DROP DEFAULT is not supported in
+            # ALTER TABLE.
+            not field.null or
+            self.effective_default(field) is not None or
+            # Adding a unique column is not supported by ALTER TABLE ADD
+            # COLUMN.
+            field.unique
+        ):
             self._remake_table(model, create_field=field)
         else:
             super().add_field(model, field)
diff --git a/tests/schema/tests.py b/tests/schema/tests.py
index cd6a52f6af..15714090c4 100644
--- a/tests/schema/tests.py
+++ b/tests/schema/tests.py
@@ -531,6 +531,43 @@ class SchemaTests(TransactionTestCase):
         self.assertEqual(columns['age'][0], connection.features.introspected_field_types['IntegerField'])
         self.assertTrue(columns['age'][1][6])
 
+    def test_add_field_unique_nullable(self):
+        with connection.schema_editor() as editor:
+            editor.create_model(Author)
+        new_field = CharField(max_length=15, null=True, unique=True)
+        new_field.set_attributes_from_name('surname')
+        with connection.schema_editor() as editor:
+            editor.add_field(Author, new_field)
+        columns = self.column_classes(Author)
+        self.assertEqual(
+            columns['surname'][0],
+            connection.features.introspected_field_types['CharField'],
+        )
+        self.assertTrue(columns['surname'][1][6])
+        constraints = self.get_constraints(Author._meta.db_table)
+        self.assertTrue(any(
+            constraint['unique'] and constraint['columns'] == ['surname']
+            for constraint in constraints.values()
+        ))
+
+    def test_add_field_one_to_one_nullable(self):
+        with connection.schema_editor() as editor:
+            editor.create_model(Author)
+        new_field = OneToOneField(
+            Author, null=True, on_delete=CASCADE, related_name='+',
+        )
+        new_field.set_attributes_from_name('author')
+        with connection.schema_editor() as editor:
+            editor.add_field(Author, new_field)
+        columns = self.column_classes(Author)
+        self.assertIn('author_id', columns)
+        self.assertTrue(columns['author_id'][1][6])
+        constraints = self.get_constraints(Author._meta.db_table)
+        self.assertTrue(any(
+            constraint['unique'] and constraint['columns'] == ['author_id']
+            for constraint in constraints.values()
+        ))
+
     def test_add_field_remove_field(self):
         """
         Adding a field and removing it removes all deferred sql referring to it.
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

Adding nullable OneToOneField crashes on SQLite.
Description
	
This new sqlite3 error has cropped up between building django-oauth-toolkit between Django 4.0 and main branch for migrations.AddField of a OneToOneField (see ​https://github.com/jazzband/django-oauth-toolkit/issues/1064):
self = <django.db.backends.sqlite3.base.SQLiteCursorWrapper object at 0x10b8038b0>
query = 'ALTER TABLE "oauth2_provider_accesstoken" ADD COLUMN "source_refresh_token_id" bigint NULL UNIQUE REFERENCES "oauth2_provider_refreshtoken" ("id") DEFERRABLE INITIALLY DEFERRED'
params = []
	def execute(self, query, params=None):
		if params is None:
			return Database.Cursor.execute(self, query)
		query = self.convert_query(query)
>	 return Database.Cursor.execute(self, query, params)
E	 django.db.utils.OperationalError: Cannot add a UNIQUE column
Here's the relevant migration snippet: 
		migrations.AddField(
			model_name='AccessToken',
			name='source_refresh_token',
			field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=oauth2_settings.REFRESH_TOKEN_MODEL, related_name="refreshed_access_token"),
		),
I see there have been a lot of sqlite3 changes in #33355 since the 4.0 release....

## Deliverable

changes to this tree

## Check

`./tests/runtests.py schema`

## Scope

`django/db/backends/sqlite3/schema.py`
`tests/schema/`

## Done when

- Adding a nullable `OneToOneField` to an existing model on SQLite no longer raises `OperationalError: Cannot add a UNIQUE column`.
- The added field is present after the migration and its unique constraint is enforced.
- The change is confined to SQLite schema editing and leaves other database backends unchanged.
- A regression test in `tests/schema/` covers adding a nullable unique/`OneToOneField` on SQLite.



# plan.md

## Deliverable
changes to this tree

## Check
`./tests/runtests.py schema`

## Scope
`django/db/backends/sqlite3/schema.py`
`tests/schema/`

## Done when
- Adding a nullable `OneToOneField` to an existing model on SQLite no longer raises `OperationalError: Cannot add a UNIQUE column`.
- The added field is present after the migration and its unique constraint is enforced.
- The change is confined to SQLite schema editing and leaves other database backends unchanged.
- A regression test in `tests/schema/` covers adding a nullable unique/`OneToOneField` on SQLite.

## Approach
Reproduce the failure with a schema-editor test that adds a nullable `OneToOneField` to an existing model, then adjust `SQLiteSchemaEditor.add_field()` so fields that cannot be added by `ALTER TABLE ADD COLUMN` are handled by `_remake_table()`, and run the schema test suite.

Candidate approaches:
1. Route `field.primary_key or field.unique` through `_remake_table(model, create_field=field)`, matching the existing handling for non-null/default fields. Tradeoff: correct and already supported, but rebuilds the table.
2. Add the column without `UNIQUE`, then create a separate unique index. Tradeoff: avoids a table rebuild, but requires more complex constraint naming, rollback, and null-handling logic.
3. Catch the `OperationalError` and fall back to `_remake_table()`. Tradeoff: smallest diff, but brittle and can mask unrelated SQLite errors.


# django/db/backends/sqlite3/schema.py

```
import copy
from decimal import Decimal

from django.apps.registry import Apps
from django.db import NotSupportedError
from django.db.backends.base.schema import BaseDatabaseSchemaEditor
from django.db.backends.ddl_references import Statement
from django.db.backends.utils import strip_quotes
from django.db.models import UniqueConstraint
from django.db.transaction import atomic


class DatabaseSchemaEditor(BaseDatabaseSchemaEditor):

    sql_delete_table = "DROP TABLE %(table)s"
    sql_create_fk = None
    sql_create_inline_fk = "REFERENCES %(to_table)s (%(to_column)s) DEFERRABLE INITIALLY DEFERRED"
    sql_create_column_inline_fk = sql_create_inline_fk
    sql_create_unique = "CREATE UNIQUE INDEX %(name)s ON %(table)s (%(columns)s)"
    sql_delete_unique = "DROP INDEX %(name)s"

    def __enter__(self):
        # Some SQLite schema alterations need foreign key constraints to be
        # disabled. Enforce it here for the duration of the schema edition.
        if not self.connection.disable_constraint_checking():
            raise NotSupportedError(
                'SQLite schema editor cannot be used while foreign key '
                'constraint checks are enabled. Make sure to disable them '
                'before entering a transaction.atomic() context because '
                'SQLite does not support disabling them in the middle of '
                'a multi-statement transaction.'
            )
        return super().__enter__()

    def __exit__(self, exc_type, exc_value, traceback):
        self.connection.check_constraints()
        super().__exit__(exc_type, exc_value, traceback)
        self.connection.enable_constraint_checking()

    def quote_value(self, value):
        # The backend "mostly works" without this function and there are use
        # cases for compiling Python without the sqlite3 libraries (e.g.
        # security hardening).
        try:
            import sqlite3
            value = sqlite3.adapt(value)
        except ImportError:
            pass
        except sqlite3.ProgrammingError:
            pass
        # Manual emulation of SQLite parameter quoting
        if isinstance(value, bool):
            return str(int(value))
        elif isinstance(value, (Decimal, float, int)):
            return str(value)
        elif isinstance(value, str):
            return "'%s'" % value.replace("\'", "\'\'")
        elif value is None:
            return "NULL"
        elif isinstance(value, (bytes, bytearray, memoryview)):
            # Bytes are only allowed for BLOB fields, encoded as string
            # literals containing hexadecimal data and preceded by a single "X"
            # character.
            return "X'%s'" % value.hex()
        else:
            raise ValueError("Cannot quote parameter value %r of type %s" % (value, type(value)))

    def prepare_default(self, value):
        return self.quote_value(value)

    def _is_referenced_by_fk_constraint(self, table_name, column_name=None, ignore_self=False):
        """
        Return whether or not the provided table name is referenced by another
        one. If `column_name` is specified, only references pointing to that
        column are considered. If `ignore_self` is True, self-referential
        constraints are ignored.
        """
        with self.connection.cursor() as cursor:
            for other_table in self.connection.introspection.get_table_list(cursor):
                if ignore_self and other_table.name == table_name:
                    continue
                relations = self.connection.introspection.get_relations(cursor, other_table.name)
                for constraint_column, constraint_table in relations.values():
                    if (constraint_table == table_name and
                            (column_name is None or constraint_column == column_name)):
                        return True
        return False

    def alter_db_table(self, model, old_db_table, new_db_table, disable_constraints=True):
        if (not self.connection.features.supports_atomic_references_rename and
                disable_constraints and self._is_referenced_by_fk_constraint(old_db_table)):
            if self.connection.in_atomic_block:
                raise NotSupportedError((
                    'Renaming the %r table while in a transaction is not '
                    'supported on SQLite < 3.26 because it would break referential '
                    'integrity. Try adding `atomic = False` to the Migration class.'
                ) % old_db_table)
            self.connection.enable_constraint_checking()
            super().alter_db_table(model, old_db_table, new_db_table)
            self.connection.disable_constraint_checking()
        else:
            super().alter_db_table(model, old_db_table, new_db_table)

    def alter_field(self, model, old_field, new_field, strict=False):
        if not self._field_should_be_altered(old_field, new_field):
            return
        old_field_name = old_field.name
        table_name = model._meta.db_table
        _, old_column_name = old_field.get_attname_column()
        if (new_field.name != old_field_name and
                not self.connection.features.supports_atomic_references_rename and
                self._is_referenced_by_fk_constraint(table_name, old_column_name, ignore_self=True)):
            if self.connection.in_atomic_block:
                raise NotSupportedError((
                    'Renaming the %r.%r column while in a transaction is not '
                    'supported on SQLite < 3.26 because it would break referential '
                    'integrity. Try adding `atomic = False` to the Migration class.'
                ) % (model._meta.db_table, old_field_name))
            with atomic(self.connection.alias):
                super().alter_field(model, old_field, new_field, strict=strict)
                # Follow SQLite's documented procedure for performing changes
                # that don't affect the on-disk content.
                # https://sqlite.org/lang_altertable.html#otheralter
                with self.connection.cursor() as cursor:
                    schema_version = cursor.execute('PRAGMA schema_version').fetchone()[0]
                    cursor.execute('PRAGMA writable_schema = 1')
                    references_template = ' REFERENCES "%s" ("%%s") ' % table_name
                    new_column_name = new_field.get_attname_column()[1]
                    search = references_template % old_column_name
                    replacement = references_template % new_column_name
                    cursor.execute('UPDATE sqlite_master SET sql = replace(sql, %s, %s)', (search, replacement))
                    cursor.execute('PRAGMA schema_version = %d' % (schema_version + 1))
                    cursor.execute('PRAGMA writable_schema = 0')
                    # The integrity check will raise an exception and rollback
                    # the transaction if the sqlite_master updates corrupt the
                    # database.
                    cursor.execute('PRAGMA integrity_check')
            # Perform a VACUUM to refresh the database representation from
            # the sqlite_master table.
            with self.connection.cursor() as cursor:
                cursor.execute('VACUUM')
        else:
            super().alter_field(model, old_field, new_field, strict=strict)

    def _remake_table(self, model, create_field=None, delete_field=None, alter_field=None):
        """
        Shortcut to transform a model from old_model into new_model

        This follows the correct procedure to perform non-rename or column
        addition operations based on SQLite's documentation

        https://www.sqlite.org/lang_altertable.html#caution

        The essential steps are:
          1. Create a table with the updated definition called "new__app_model"
          2. Copy the data from the existing "app_model" table to the new table
          3. Drop the "app_model" table
          4. Rename the "new__app_model" table to "app_model"
          5. Restore any index of the previous "app_model" table.
        """
        # Self-referential fields must be recreated rather than copied from
        # the old model to ensure their remote_field.field_name doesn't refer
        # to an altered field.
        def is_self_referential(f):
            return f.is_relation and f.remote_field.model is model
        # Work out the new fields dict / mapping
        body = {
            f.name: f.clone() if is_self_referential(f) else f
            for f in model._meta.local_concrete_fields
        }
        # Since mapping might mix column names and default values,
        # its values must be already quoted.
        mapping = {f.column: self.quote_name(f.column) for f in model._meta.local_concrete_fields}
        # This maps field names (not columns) for things like unique_together
        rename_mapping = {}
        # If any of the new or altered fields is introducing a new PK,
        # remove the old one
        restore_pk_field = None
        if getattr(create_field, 'primary_key', False) or (
                alter_field and getattr(alter_field[1], 'primary_key', False)):
            for name, field in list(body.items()):
                if field.primary_key:
                    field.primary_key = False
                    restore_pk_field = field
                    if field.auto_created:
                        del body[name]
                        del mapping[field.column]
        # Add in any created fields
        if create_field:
            body[create_field.name] = create_field
            # Choose a default and insert it into the copy map
            if not create_field.many_to_many and create_field.concrete:
                mapping[create_field.column] = self.prepare_default(
                    self.effective_default(create_field),
                )
        # Add in any altered fields
        if alter_field:
            old_field, new_field = alter_field
            body.pop(old_field.name, None)
            mapping.pop(old_field.column, None)
            body[new_field.name] = new_field
            if old_field.null and not new_field.null:
                case_sql = "coalesce(%(col)s, %(default)s)" % {
                    'col': self.quote_name(old_field.column),
                    'default': self.prepare_default(self.effective_default(new_field)),
                }
                mapping[new_field.column] = case_sql
            else:
                mapping[new_field.column] = self.quote_name(old_field.column)
            rename_mapping[old_field.name] = new_field.name
        # Remove any deleted fields
        if delete_field:
            del body[delete_field.name]
            del mapping[delete_field.column]
            # Remove any implicit M2M tables
            if delete_field.many_to_many and delete_field.remote_field.through._meta.auto_created:
                return self.delete_model(delete_field.remote_field.through)
        # Work inside a new app registry
        apps = Apps()

        # Work out the new value of unique_together, taking renames into
        # account
        unique_together = [
            [rename_mapping.get(n, n) for n in unique]
            for unique in model._meta.unique_together
        ]

        # Work out the new value for index_together, taking renames into
        # account
        index_together = [
            [rename_mapping.get(n, n) for n in index]
            for index in model._meta.index_together
        ]

        indexes = model._meta.indexes
        if delete_field:
            indexes = [
                index for index in indexes
                if delete_field.name not in index.fields
            ]

        constraints = list(model._meta.constraints)

        # Provide isolated instances of the fields to the new model body so
        # that the existing model's internals aren't interfered with when
        # the dummy model is constructed.
        body_copy = copy.deepcopy(body)

        # Construct a new model with the new fields to allow self referential
        # primary key to resolve to. This model won't ever be materialized as a
        # table and solely exists for foreign key reference resolution purposes.
        # This wouldn't be required if the schema editor was operating on model
        # states instead of rendered models.
        meta_contents = {
            'app_label': model._meta.app_label,
            'db_table': model._meta.db_table,
            'unique_together': unique_together,
            'index_together': index_together,
            'indexes': indexes,
            'constraints': constraints,
            'apps': apps,
        }
        meta = type("Meta", (), meta_contents)
        body_copy['Meta'] = meta
        body_copy['__module__'] = model.__module__
        type(model._meta.object_name, model.__bases__, body_copy)

        # Construct a model with a renamed table name.
        body_copy = copy.deepcopy(body)
        meta_contents = {
            'app_label': model._meta.app_label,
            'db_table': 'new__%s' % strip_quotes(model._meta.db_table),
            'unique_together': unique_together,
            'index_together': index_together,
            'indexes': indexes,
            'constraints': constraints,
            'apps': apps,
        }
        meta = type("Meta", (), meta_contents)
        body_copy['Meta'] = meta
        body_copy['__module__'] = model.__module__
        new_model = type('New%s' % model._meta.object_name, model.__bases__, body_copy)

        # Create a new table with the updated schema.
        self.create_model(new_model)

        # Copy data from the old table into the new table
        self.execute("INSERT INTO %s (%s) SELECT %s FROM %s" % (
            self.quote_name(new_model._meta.db_table),
            ', '.join(self.quote_name(x) for x in mapping),
            ', '.join(mapping.values()),
            self.quote_name(model._meta.db_table),
        ))

        # Delete the old table to make way for the new
        self.delete_model(model, handle_autom2m=False)

        # Rename the new table to take way for the old
        self.alter_db_table(
            new_model, new_model._meta.db_table, model._meta.db_table,
            disable_constraints=False,
        )

        # Run deferred SQL on correct table
        for sql in self.deferred_sql:
            self.execute(sql)
        self.deferred_sql = []
        # Fix any PK-removed field
        if restore_pk_field:
            restore_pk_field.primary_key = True

    def delete_model(self, model, handle_autom2m=True):
        if handle_autom2m:
            super().delete_model(model)
        else:
            # Delete the table (and only that)
            self.execute(self.sql_delete_table % {
                "table": self.quote_name(model._meta.db_table),
            })
            # Remove all deferred statements referencing the deleted table.
            for sql in list(self.deferred_sql):
                if isinstance(sql, Statement) and sql.references_table(model._meta.db_table):
                    self.deferred_sql.remove(sql)

    def add_field(self, model, field):
        """Create a field on a model."""
        # Fields with default values cannot by handled by ALTER TABLE ADD
        # COLUMN statement because DROP DEFAULT is not supported in
        # ALTER TABLE.
        if not field.null or self.effective_default(field) is not None:
            self._remake_table(model, create_field=field)
        else:
            super().add_field(model, field)

    def remove_field(self, model, field):
        """
        Remove a field from a model. Usually involves deleting a column,
        but for M2Ms may involve deleting a table.
        """
        # M2M fields are a special case
        if field.many_to_many:
            # For implicit M2M tables, delete the auto-created table
            if field.remote_field.through._meta.auto_created:
                self.delete_model(field.remote_field.through)
            # For explicit "through" M2M fields, do nothing
        # For everything else, remake.
        else:
            # It might not actually have a column behind it
            if field.db_parameters(connection=self.connection)['type'] is None:
                return
            self._remake_table(model, delete_field=field)

    def _alter_field(self, model, old_field, new_field, old_type, new_type,
                     old_db_params, new_db_params, strict=False):
        """Perform a "physical" (non-ManyToMany) field update."""
        # Use "ALTER TABLE ... RENAME COLUMN" if only the column name
        # changed and there aren't any constraints.
        if (self.connection.features.can_alter_table_rename_column and
            old_field.column != new_field.column and
            self.column_sql(model, old_field) == self.column_sql(model, new_field) and
            not (old_field.remote_field and old_field.db_constraint or
                 new_field.remote_field and new_field.db_constraint)):
            return self.execute(self._rename_field_sql(model._meta.db_table, old_field, new_field, new_type))
        # Alter by remaking table
        self._remake_table(model, alter_field=(old_field, new_field))
        # Rebuild tables with FKs pointing to this field.
        if new_field.unique and old_type != new_type:
            related_models = set()
            opts = new_field.model._meta
            for remote_field in opts.related_objects:
                # Ignore self-relationship since the table was already rebuilt.
                if remote_field.related_model == model:
                    continue
                if not remote_field.many_to_many:
                    if remote_field.field_name == new_field.name:
                        related_models.add(remote_field.related_model)
                elif new_field.primary_key and remote_field.through._meta.auto_created:
                    related_models.add(remote_field.through)
            if new_field.primary_key:
                for many_to_many in opts.many_to_many:
                    # Ignore self-relationship since the table was already rebuilt.
                    if many_to_many.related_model == model:
                        continue
                    if many_to_many.remote_field.through._meta.auto_created:
                        related_models.add(many_to_many.remote_field.through)
            for related_model in related_models:
                self._remake_table(related_model)

    def _alter_many_to_many(self, model, old_field, new_field, strict):
        """Alter M2Ms to repoint their to= endpoints."""
        if old_field.remote_field.through._meta.db_table == new_field.remote_field.through._meta.db_table:
            # The field name didn't change, but some options did; we have to propagate this altering.
            self._remake_table(
                old_field.remote_field.through,
                alter_field=(
                    # We need the field that points to the target model, so we can tell alter_field to change it -
                    # this is m2m_reverse_field_name() (as opposed to m2m_field_name, which points to our model)
                    old_field.remote_field.through._meta.get_field(old_field.m2m_reverse_field_name()),
                    new_field.remote_field.through._meta.get_field(new_field.m2m_reverse_field_name()),
                ),
            )
            return

        # Make a new through table
        self.create_model(new_field.remote_field.through)
        # Copy the data across
        self.execute("INSERT INTO %s (%s) SELECT %s FROM %s" % (
            self.quote_name(new_field.remote_field.through._meta.db_table),
            ', '.join([
                "id",
                new_field.m2m_column_name(),
                new_field.m2m_reverse_name(),
            ]),
            ', '.join([
                "id",
                old_field.m2m_column_name(),
                old_field.m2m_reverse_name(),
            ]),
            self.quote_name(old_field.remote_field.through._meta.db_table),
        ))
        # Delete the old through table
        self.delete_model(old_field.remote_field.through)

    def add_constraint(self, model, constraint):
        if isinstance(constraint, UniqueConstraint) and (
            constraint.condition or
            constraint.contains_expressions or
            constraint.include or
            constraint.deferrable
        ):
            super().add_constraint(model, constraint)
        else:
            self._remake_table(model)

    def remove_constraint(self, model, constraint):
        if isinstance(constraint, UniqueConstraint) and (
            constraint.condition or
            constraint.contains_expressions or
            constraint.include or
            constraint.deferrable
        ):
            super().remove_constraint(model, constraint)
        else:
            self._remake_table(model)

    def _collate_sql(self, collation):
        return 'COLLATE ' + collation

```


# tests/schema (the files in it)

tests/schema/__init__.py
tests/schema/fields.py
tests/schema/models.py
tests/schema/test_logging.py
tests/schema/tests.py


# The last commit

```
d87e54e739 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: ./tests/runtests.py schema
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 175 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.s.................sss...s.ss.....s..ss.sss.s......ss.s......................s.............s.....................s..s....s...s....................s............s......s...s...s
----------------------------------------------------------------------
Ran 175 tests in 1.660s

OK (skipped=28)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/backends/sqlite3/schema.py tests/schema
changed: django/db/backends/sqlite3/schema.py +10 -4
changed: tests/schema/tests.py +37 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/db/backends/sqlite3/schema.py b/django/db/backends/sqlite3/schema.py
index 6752a8e3c0..510430ddd3 100644
--- a/django/db/backends/sqlite3/schema.py
+++ b/django/db/backends/sqlite3/schema.py
@@ -324,10 +324,16 @@ class DatabaseSchemaEditor(BaseDatabaseSchemaEditor):
 
     def add_field(self, model, field):
         """Create a field on a model."""
-        # Fields with default values cannot by handled by ALTER TABLE ADD
-        # COLUMN statement because DROP DEFAULT is not supported in
-        # ALTER TABLE.
-        if not field.null or self.effective_default(field) is not None:
+        if (
+            # Fields with default values cannot by handled by ALTER TABLE ADD
+            # COLUMN statement because DROP DEFAULT is not supported in
+            # ALTER TABLE.
+            not field.null or
+            self.effective_default(field) is not None or
+            # Adding a unique column is not supported by ALTER TABLE ADD
+            # COLUMN.
+            field.unique
+        ):
             self._remake_table(model, create_field=field)
         else:
             super().add_field(model, field)
diff --git a/tests/schema/tests.py b/tests/schema/tests.py
index cd6a52f6af..15714090c4 100644
--- a/tests/schema/tests.py
+++ b/tests/schema/tests.py
@@ -531,6 +531,43 @@ class SchemaTests(TransactionTestCase):
         self.assertEqual(columns['age'][0], connection.features.introspected_field_types['IntegerField'])
         self.assertTrue(columns['age'][1][6])
 
+    def test_add_field_unique_nullable(self):
+        with connection.schema_editor() as editor:
+            editor.create_model(Author)
+        new_field = CharField(max_length=15, null=True, unique=True)
+        new_field.set_attributes_from_name('surname')
+        with connection.schema_editor() as editor:
+            editor.add_field(Author, new_field)
+        columns = self.column_classes(Author)
+        self.assertEqual(
+            columns['surname'][0],
+            connection.features.introspected_field_types['CharField'],
+        )
+        self.assertTrue(columns['surname'][1][6])
+        constraints = self.get_constraints(Author._meta.db_table)
+        self.assertTrue(any(
+            constraint['unique'] and constraint['columns'] == ['surname']
+            for constraint in constraints.values()
+        ))
+
+    def test_add_field_one_to_one_nullable(self):
+        with connection.schema_editor() as editor:
+            editor.create_model(Author)
+        new_field = OneToOneField(
+            Author, null=True, on_delete=CASCADE, related_name='+',
+        )
+        new_field.set_attributes_from_name('author')
+        with connection.schema_editor() as editor:
+            editor.add_field(Author, new_field)
+        columns = self.column_classes(Author)
+        self.assertIn('author_id', columns)
+        self.assertTrue(columns['author_id'][1][6])
+        constraints = self.get_constraints(Author._meta.db_table)
+        self.assertTrue(any(
+            constraint['unique'] and constraint['columns'] == ['author_id']
+            for constraint in constraints.values()
+        ))
+
     def test_add_field_remove_field(self):
         """
         Adding a field and removing it removes all deferred sql referring to it.
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
check: ./tests/runtests.py schema
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 175 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.s.................sss...s.ss.....s..ss.sss.s......ss.s......................s.............s.....................s..s....s...s....................s............s......s...s...s
----------------------------------------------------------------------
Ran 175 tests in 1.706s

OK (skipped=28)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/backends/sqlite3/schema.py tests/schema
changed: django/db/backends/sqlite3/schema.py +10 -4
changed: tests/schema/tests.py +37 -0
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
# Notes, run 2026-11-06T111729

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Adding nullable OneToOneField crashes on SQLite.
Description
	
This new sqlite3 error has cropped up between building django-oauth-toolkit between Django 4.0 and main branch for migrations.AddField of a OneToOneField (see ​https://github.com/jazzband/django-oauth-toolkit/issues/1064):
self = <django.db.backends.sqlite3.base.SQLiteCursorWrapper object at 0x10b8038b0>
query = 'ALTER TABLE "oauth2_provider_accesstoken" ADD COLUMN "source_refresh_token_id" bigint NULL UNIQUE REFERENCES "oauth2_provider_refreshtoken" ("id") DEFERRABLE INITIALLY DEFERRED'
params = []
	def execute(self, query, params=None):
		if params is None:
			return Database.Cursor.execute(self, query)
		query = self.convert_query(query)
>	 return Database.Cursor.execute(self, query, params)
E	 django.db.utils.OperationalError: Cannot add a UNIQUE column
Here's the relevant migration snippet: 
		migrations.AddField(
			model_name='AccessToken',
			name='source_refresh_token',
			field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=oauth2_settings.REFRESH_TOKEN_MODEL, related_name="refreshed_access_token"),
		),
I see there have been a lot of sqlite3 changes in #33355 since the 4.0 release....


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.gitattributes
.github/CODE_OF_CONDUCT.md
.github/FUNDING.yml
.github/SECURITY.md
.github/workflows/docs.yml
.github/workflows/linters.yml
.github/workflows/new_contributor_pr.yml
.github/workflows/tests.yml
.gitignore
.pre-commit-config.yaml
.readthedocs.yml
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
django/conf/locale/ms/LC_MESSAGES/django.mo
django/conf/locale/ms/LC_MESSAGES/django.po
django/conf/locale/ms/__init__.py
django/conf/locale/ms/formats.py
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
```


# The last commit

```
d87e54e739 SWE-bench


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
    "eslint": "^7.32.0",
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
`./tests/runtests.py schema`

## Scope
`django/db/backends/sqlite3/schema.py`
`tests/schema/`

## Done when
- Adding a nullable `OneToOneField` to an existing model on SQLite no longer raises `OperationalError: Cannot add a UNIQUE column`.
- The added field is present after the migration and its unique constraint is enforced.
- The change is confined to SQLite schema editing and leaves other database backends unchanged.
- A regression test in `tests/schema/` covers adding a nullable unique/`OneToOneField` on SQLite.

## Approach
Reproduce the failure with a schema-editor test that adds a nullable `OneToOneField` to an existing model, then adjust `SQLiteSchemaEditor.add_field()` so fields that cannot be added by `ALTER TABLE ADD COLUMN` are handled by `_remake_table()`, and run the schema test suite.

Candidate approaches:
1. Route `field.primary_key or field.unique` through `_remake_table(model, create_field=field)`, matching the existing handling for non-null/default fields. Tradeoff: correct and already supported, but rebuilds the table.
2. Add the column without `UNIQUE`, then create a separate unique index. Tradeoff: avoids a table rebuild, but requires more complex constraint naming, rollback, and null-handling logic.
3. Catch the `OperationalError` and fall back to `_remake_table()`. Tradeoff: smallest diff, but brittle and can mask unrelated SQLite errors.
```

### `prompt.md`

```
Adding nullable OneToOneField crashes on SQLite.
Description
	
This new sqlite3 error has cropped up between building django-oauth-toolkit between Django 4.0 and main branch for migrations.AddField of a OneToOneField (see ​https://github.com/jazzband/django-oauth-toolkit/issues/1064):
self = <django.db.backends.sqlite3.base.SQLiteCursorWrapper object at 0x10b8038b0>
query = 'ALTER TABLE "oauth2_provider_accesstoken" ADD COLUMN "source_refresh_token_id" bigint NULL UNIQUE REFERENCES "oauth2_provider_refreshtoken" ("id") DEFERRABLE INITIALLY DEFERRED'
params = []
	def execute(self, query, params=None):
		if params is None:
			return Database.Cursor.execute(self, query)
		query = self.convert_query(query)
>	 return Database.Cursor.execute(self, query, params)
E	 django.db.utils.OperationalError: Cannot add a UNIQUE column
Here's the relevant migration snippet: 
		migrations.AddField(
			model_name='AccessToken',
			name='source_refresh_token',
			field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=oauth2_settings.REFRESH_TOKEN_MODEL, related_name="refreshed_access_token"),
		),
I see there have been a lot of sqlite3 changes in #33355 since the 4.0 release....
```

### `review.md`

```
verdict: PASS
- `./tests/runtests.py schema` ran 175 tests and reported OK, with 28 skipped; the check status is 0.
- The SQLite schema editor now remakes the table when adding a unique field, which covers nullable `unique` and `OneToOneField` additions and avoids the unsupported `ALTER TABLE ... ADD COLUMN ... UNIQUE`.
- Regression tests in `tests/schema/tests.py` cover both nullable unique field and nullable one-to-one field additions and verify the unique constraints.
- The change is confined to SQLite schema editing and `tests/schema/`; no other database backend is changed.
- No requested behavior is missed.
```

### `scope.txt`

```
scope: django/db/backends/sqlite3/schema.py tests/schema
changed: django/db/backends/sqlite3/schema.py +10 -4
changed: tests/schema/tests.py +37 -0
```

### `task.md`

```
# Task

## Prompt

Adding nullable OneToOneField crashes on SQLite.
Description
	
This new sqlite3 error has cropped up between building django-oauth-toolkit between Django 4.0 and main branch for migrations.AddField of a OneToOneField (see ​https://github.com/jazzband/django-oauth-toolkit/issues/1064):
self = <django.db.backends.sqlite3.base.SQLiteCursorWrapper object at 0x10b8038b0>
query = 'ALTER TABLE "oauth2_provider_accesstoken" ADD COLUMN "source_refresh_token_id" bigint NULL UNIQUE REFERENCES "oauth2_provider_refreshtoken" ("id") DEFERRABLE INITIALLY DEFERRED'
params = []
	def execute(self, query, params=None):
		if params is None:
			return Database.Cursor.execute(self, query)
		query = self.convert_query(query)
>	 return Database.Cursor.execute(self, query, params)
E	 django.db.utils.OperationalError: Cannot add a UNIQUE column
Here's the relevant migration snippet: 
		migrations.AddField(
			model_name='AccessToken',
			name='source_refresh_token',
			field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=oauth2_settings.REFRESH_TOKEN_MODEL, related_name="refreshed_access_token"),
		),
I see there have been a lot of sqlite3 changes in #33355 since the 4.0 release....

## Deliverable

changes to this tree

## Check

`./tests/runtests.py schema`

## Scope

`django/db/backends/sqlite3/schema.py`
`tests/schema/`

## Done when

- Adding a nullable `OneToOneField` to an existing model on SQLite no longer raises `OperationalError: Cannot add a UNIQUE column`.
- The added field is present after the migration and its unique constraint is enforced.
- The change is confined to SQLite schema editing and leaves other database backends unchanged.
- A regression test in `tests/schema/` covers adding a nullable unique/`OneToOneField` on SQLite.
```

### `test-output.log`

```
check: ./tests/runtests.py schema
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 175 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.s.................sss...s.ss.....s..ss.sss.s......ss.s......................s.............s.....................s..s....s...s....................s............s......s...s...s
----------------------------------------------------------------------
Ran 175 tests in 1.605s

OK (skipped=28)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/backends/sqlite3/schema.py tests/schema
changed: django/db/backends/sqlite3/schema.py +10 -4
changed: tests/schema/tests.py +37 -0
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
