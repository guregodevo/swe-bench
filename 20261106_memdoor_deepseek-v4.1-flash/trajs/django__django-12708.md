# django__django-12708 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 119s 68 lines cost=0.005835 in=241161 cached=162816 out=8651 calls=20`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
17:16:41 weboff: chief: web_fetch,web_search
17:16:41 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Migration crashes deleting an index_together if there is a unique_together on the same fields
Description
	
Happens with Django 1.11.10
Steps to reproduce:
1) Create models with 2 fields, add 2 same fields to unique_together and to index_together
2) Delete index_together -> Fail
It will fail at django/db/backends/base/schema.py, line 378, in _delete_composed_index(), ValueError: Found wrong number (2) of constraints for as this one will find two constraints, the _uniq and the _idx one. No way to get out of this...
The worst in my case is that happened as I wanted to refactor my code to use the "new" (Dj 1.11) Options.indexes feature. I am actually not deleting the index, just the way it is declared in my code.
I think there are 2 different points here:
1) The deletion of index_together should be possible alone or made coherent (migrations side?) with unique_together
2) Moving the declaration of an index should not result in an index re-creation

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain | head -50 && git log --oneline -3"
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
d2c549d04a SWE-bench
447980e72a Fixed #31500 -- Fixed detecting of unique fields in QuerySet.in_bulk() when using Meta.constraints.
67f9d076cf Avoided unnecessary recompilation of ordering clause regex in SQLCompiler.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"_delete_composed_index\\|_create_composed_index\\|_constraint_names\" django/db/backends/base/schema.py django/db/backends/*/schema.py | head -80"
}
```

**tool result**

```
django/db/backends/base/schema.py:380:            self._delete_composed_index(model, fields, {'unique': True}, self.sql_delete_unique)
django/db/backends/base/schema.py:396:            self._delete_composed_index(model, fields, {'index': True}, self.sql_delete_index)
django/db/backends/base/schema.py:402:    def _delete_composed_index(self, model, fields, constraint_kwargs, sql):
django/db/backends/base/schema.py:403:        meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
django/db/backends/base/schema.py:406:        constraint_names = self._constraint_names(
django/db/backends/base/schema.py:407:            model, columns, exclude=meta_constraint_names | meta_index_names,
django/db/backends/base/schema.py:509:            fk_names = self._constraint_names(model, [field.column], foreign_key=True)
django/db/backends/base/schema.py:577:            fk_names = self._constraint_names(model, [old_field.column], foreign_key=True)
django/db/backends/base/schema.py:590:            meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
django/db/backends/base/schema.py:591:            constraint_names = self._constraint_names(
django/db/backends/base/schema.py:593:                exclude=meta_constraint_names,
django/db/backends/base/schema.py:615:                rel_fk_names = self._constraint_names(
django/db/backends/base/schema.py:635:            index_names = self._constraint_names(
django/db/backends/base/schema.py:646:            meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
django/db/backends/base/schema.py:647:            constraint_names = self._constraint_names(
django/db/backends/base/schema.py:649:                exclude=meta_constraint_names,
django/db/backends/base/schema.py:1142:    def _constraint_names(self, model, column_names=None, unique=None,
django/db/backends/base/schema.py:1173:        constraint_names = self._constraint_names(model, primary_key=True)
django/db/backends/base/schema.py:380:            self._delete_composed_index(model, fields, {'unique': True}, self.sql_delete_unique)
django/db/backends/base/schema.py:396:            self._delete_composed_index(model, fields, {'index': True}, self.sql_delete_index)
django/db/backends/base/schema.py:402:    def _delete_composed_index(self, model, fields, constraint_kwargs, sql):
django/db/backends/base/schema.py:403:        meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
django/db/backends/base/schema.py:406:        constraint_names = self._constraint_names(
django/db/backends/base/schema.py:407:            model, columns, exclude=meta_constraint_names | meta_index_names,
django/db/backends/base/schema.py:509:            fk_names = self._constraint_names(model, [field.column], foreign_key=True)
django/db/backends/base/schema.py:577:            fk_names = self._constraint_names(model, [old_field.column], foreign_key=True)
django/db/backends/base/schema.py:590:            meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
django/db/backends/base/schema.py:591:            constraint_names = self._constraint_names(
django/db/backends/base/schema.py:593:                exclude=meta_constraint_names,
django/db/backends/base/schema.py:615:                rel_fk_names = self._constraint_names(
django/db/backends/base/schema.py:635:            index_names = self._constraint_names(
django/db/backends/base/schema.py:646:            meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
django/db/backends/base/schema.py:647:            constraint_names = self._constraint_names(
django/db/backends/base/schema.py:649:                exclude=meta_constraint_names,
django/db/backends/base/schema.py:1142:    def _constraint_names(self, model, column_names=None, unique=None,
django/db/backends/base/schema.py:1173:        constraint_names = self._constraint_names(model, primary_key=True)
django/db/backends/mysql/schema.py:115:    def _delete_composed_index(self, model, fields, *args):
django/db/backends/mysql/schema.py:126:            constraint_names = self._constraint_names(model, [first_field.column], index=True)
django/db/backends/mysql/schema.py:129:        return super()._delete_composed_index(model, fields, *args)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '360,430p' django/db/backends/base/schema.py; sed -n '1130,1175p' django/db/backends/base/schema.py"
}
```

**tool result**

```
        sql = constraint.create_sql(model, self)
        if sql:
            self.execute(sql)

    def remove_constraint(self, model, constraint):
        """Remove a constraint from a model."""
        sql = constraint.remove_sql(model, self)
        if sql:
            self.execute(sql)

    def alter_unique_together(self, model, old_unique_together, new_unique_together):
        """
        Deal with a model changing its unique_together. The input
        unique_togethers must be doubly-nested, not the single-nested
        ["foo", "bar"] format.
        """
        olds = {tuple(fields) for fields in old_unique_together}
        news = {tuple(fields) for fields in new_unique_together}
        # Deleted uniques
        for fields in olds.difference(news):
            self._delete_composed_index(model, fields, {'unique': True}, self.sql_delete_unique)
        # Created uniques
        for fields in news.difference(olds):
            columns = [model._meta.get_field(field).column for field in fields]
            self.execute(self._create_unique_sql(model, columns))

    def alter_index_together(self, model, old_index_together, new_index_together):
        """
        Deal with a model changing its index_together. The input
        index_togethers must be doubly-nested, not the single-nested
        ["foo", "bar"] format.
        """
        olds = {tuple(fields) for fields in old_index_together}
        news = {tuple(fields) for fields in new_index_together}
        # Deleted indexes
        for fields in olds.difference(news):
            self._delete_composed_index(model, fields, {'index': True}, self.sql_delete_index)
        # Created indexes
        for field_names in news.difference(olds):
            fields = [model._meta.get_field(field) for field in field_names]
            self.execute(self._create_index_sql(model, fields, suffix="_idx"))

    def _delete_composed_index(self, model, fields, constraint_kwargs, sql):
        meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
        meta_index_names = {constraint.name for constraint in model._meta.indexes}
        columns = [model._meta.get_field(field).column for field in fields]
        constraint_names = self._constraint_names(
            model, columns, exclude=meta_constraint_names | meta_index_names,
            **constraint_kwargs
        )
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
        )

    def _delete_check_sql(self, model, name):
        return self._delete_constraint_sql(self.sql_delete_check, model, name)

    def _delete_constraint_sql(self, template, model, name):
        return Statement(
            template,
            table=Table(model._meta.db_table, self.quote_name),
            name=self.quote_name(name),
        )

    def _constraint_names(self, model, column_names=None, unique=None,
                          primary_key=None, index=None, foreign_key=None,
                          check=None, type_=None, exclude=None):
        """Return all constraint names matching the columns and conditions."""
        if column_names is not None:
            column_names = [
                self.connection.introspection.identifier_converter(name)
                for name in column_names
            ]
        with self.connection.cursor() as cursor:
            constraints = self.connection.introspection.get_constraints(cursor, model._meta.db_table)
        result = []
        for name, infodict in constraints.items():
            if column_names is None or column_names == infodict['columns']:
                if unique is not None and infodict['unique'] != unique:
                    continue
                if primary_key is not None and infodict['primary_key'] != primary_key:
                    continue
                if index is not None and infodict['index'] != index:
                    continue
                if check is not None and infodict['check'] != check:
                    continue
                if foreign_key is not None and not infodict['foreign_key']:
                    continue
                if type_ is not None and infodict['type'] != type_:
                    continue
                if not exclude or name not in exclude:
                    result.append(name)
        return result

    def _delete_primary_key(self, model, strict=False):
        constraint_names = self._constraint_names(model, primary_key=True)
        if strict and len(constraint_names) != 1:
            raise ValueError('Found wrong number (%s) of PK constraints for %s' % (
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"wrong number\\|index_together\\|alter_index_together\" tests/schema/tests.py | head -80"
}
```

**tool result**

```
2126:    def test_index_together(self):
2128:        Tests removing and adding index_together constraints on a model.
2144:            editor.alter_index_together(Tag, [], [("slug", "title")])
2158:            editor.alter_index_together(Tag, [("slug", "title")], [])
2169:    def test_index_together_with_fk(self):
2171:        Tests removing and adding index_together constraints that include
2179:        self.assertEqual(Book._meta.index_together, ())
2182:            editor.alter_index_together(Book, [], [['author', 'title']])
2185:            editor.alter_index_together(Book, [['author', 'title']], [])
2187:    def test_create_index_together(self):
2189:        Tests creating models with index_together already defined
2205:    def test_remove_index_together_does_not_remove_meta_indexes(self):
2223:        index_together = AuthorWithIndexedNameAndBirthday._meta.index_together
2225:            editor.alter_index_together(AuthorWithIndexedNameAndBirthday, index_together, [])
2235:            editor.alter_index_together(AuthorWithIndexedNameAndBirthday, [], index_together)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '2120,2245p' tests/schema/tests.py"
}
```

**tool result**

```
        self.assertEqual(len(other_constraints), 1)
        # Drop the unique constraint
        with connection.schema_editor() as editor:
            AuthorWithUniqueNameAndBirthday._meta.constraints = []
            editor.remove_constraint(AuthorWithUniqueNameAndBirthday, constraint)

    def test_index_together(self):
        """
        Tests removing and adding index_together constraints on a model.
        """
        # Create the table
        with connection.schema_editor() as editor:
            editor.create_model(Tag)
        # Ensure there's no index on the year/slug columns first
        self.assertIs(
            any(
                c["index"]
                for c in self.get_constraints("schema_tag").values()
                if c['columns'] == ["slug", "title"]
            ),
            False,
        )
        # Alter the model to add an index
        with connection.schema_editor() as editor:
            editor.alter_index_together(Tag, [], [("slug", "title")])
        # Ensure there is now an index
        self.assertIs(
            any(
                c["index"]
                for c in self.get_constraints("schema_tag").values()
                if c['columns'] == ["slug", "title"]
            ),
            True,
        )
        # Alter it back
        new_field2 = SlugField(unique=True)
        new_field2.set_attributes_from_name("slug")
        with connection.schema_editor() as editor:
            editor.alter_index_together(Tag, [("slug", "title")], [])
        # Ensure there's no index
        self.assertIs(
            any(
                c["index"]
                for c in self.get_constraints("schema_tag").values()
                if c['columns'] == ["slug", "title"]
            ),
            False,
        )

    def test_index_together_with_fk(self):
        """
        Tests removing and adding index_together constraints that include
        a foreign key.
        """
        # Create the table
        with connection.schema_editor() as editor:
            editor.create_model(Author)
            editor.create_model(Book)
        # Ensure the fields are unique to begin with
        self.assertEqual(Book._meta.index_together, ())
        # Add the unique_together constraint
        with connection.schema_editor() as editor:
            editor.alter_index_together(Book, [], [['author', 'title']])
        # Alter it back
        with connection.schema_editor() as editor:
            editor.alter_index_together(Book, [['author', 'title']], [])

    def test_create_index_together(self):
        """
        Tests creating models with index_together already defined
        """
        # Create the table
        with connection.schema_editor() as editor:
            editor.create_model(TagIndexed)
        # Ensure there is an index
        self.assertIs(
            any(
                c["index"]
                for c in self.get_constraints("schema_tagindexed").values()
                if c['columns'] == ["slug", "title"]
            ),
            True,
        )

    @skipUnlessDBFeature('allows_multiple_constraints_on_same_fields')
    def test_remove_index_together_does_not_remove_meta_indexes(self):
        with connection.schema_editor() as editor:
            editor.create_model(AuthorWithIndexedNameAndBirthday)
        # Add the custom index
        index = Index(fields=['name', 'birthday'], name='author_name_birthday_idx')
        custom_index_name = index.name
        AuthorWithIndexedNameAndBirthday._meta.indexes = [index]
        with connection.schema_editor() as editor:
            editor.add_index(AuthorWithIndexedNameAndBirthday, index)
        # Ensure the indexes exist
        constraints = self.get_constraints(AuthorWithIndexedNameAndBirthday._meta.db_table)
        self.assertIn(custom_index_name, constraints)
        other_constraints = [
            name for name, details in constraints.items()
            if details['columns'] == ['name', 'birthday'] and details['index'] and name != custom_index_name
        ]
        self.assertEqual(len(other_constraints), 1)
        # Remove index together
        index_together = AuthorWithIndexedNameAndBirthday._meta.index_together
        with connection.schema_editor() as editor:
            editor.alter_index_together(AuthorWithIndexedNameAndBirthday, index_together, [])
        constraints = self.get_constraints(AuthorWithIndexedNameAndBirthday._meta.db_table)
        self.assertIn(custom_index_name, constraints)
        other_constraints = [
            name for name, details in constraints.items()
            if details['columns'] == ['name', 'birthday'] and details['index'] and name != custom_index_name
        ]
        self.assertEqual(len(other_constraints), 0)
        # Re-add index together
        with connection.schema_editor() as editor:
            editor.alter_index_together(AuthorWithIndexedNameAndBirthday, [], index_together)
        constraints = self.get_constraints(AuthorWithIndexedNameAndBirthday._meta.db_table)
        self.assertIn(custom_index_name, constraints)
        other_constraints = [
            name for name, details in constraints.items()
            if details['columns'] == ['name', 'birthday'] and details['index'] and name != custom_index_name
        ]
        self.assertEqual(len(other_constraints), 1)
        # Drop the index
        with connection.schema_editor() as editor:
            AuthorWithIndexedNameAndBirthday._meta.indexes = []
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '100,135p' django/db/backends/mysql/schema.py; grep -rn \"allows_multiple_constraints_on_same_fields\" django/db/backends | head"
}
```

**tool result**

```
    def _field_should_be_indexed(self, model, field):
        create_index = super()._field_should_be_indexed(model, field)
        storage = self.connection.introspection.get_storage_engine(
            self.connection.cursor(), model._meta.db_table
        )
        # No need to create an index for ForeignKey fields except if
        # db_constraint=False because the index from that constraint won't be
        # created.
        if (storage == "InnoDB" and
                create_index and
                field.get_internal_type() == 'ForeignKey' and
                field.db_constraint):
            return False
        return not self._is_limited_data_type(field) and create_index

    def _delete_composed_index(self, model, fields, *args):
        """
        MySQL can remove an implicit FK index on a field when that field is
        covered by another index like a unique_together. "covered" here means
        that the more complex index starts like the simpler one.
        http://bugs.mysql.com/bug.php?id=37910 / Django ticket #24757
        We check here before removing the [unique|index]_together if we have to
        recreate a FK index.
        """
        first_field = model._meta.get_field(fields[0])
        if first_field.get_internal_type() == 'ForeignKey':
            constraint_names = self._constraint_names(model, [first_field.column], index=True)
            if not constraint_names:
                self.execute(self._create_index_sql(model, [first_field], suffix=""))
        return super()._delete_composed_index(model, fields, *args)

    def _set_field_new_type_null_status(self, field, new_type):
        """
        Keep the null property of the old field. If it has changed, it will be
        handled separately.
        """
django/db/backends/oracle/features.py:60:    allows_multiple_constraints_on_same_fields = False
django/db/backends/base/features.py:296:    allows_multiple_constraints_on_same_fields = True
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"unique_together\\|constraint_kwargs\\|index_together\" tests/schema/tests.py | grep -i \"same\\|unique\" | head -30; grep -rn \"def _delete_composed_index\" -A15 django/db/backends/*/schema.py"
}
```

**tool result**

```
1888:                editor.alter_unique_together(TagUniqueRename, [], (('title', 'slug2'),))
2010:    def test_unique_together(self):
2012:        Tests removing and adding unique_together constraints on a model.
2026:            editor.alter_unique_together(UniqueTest, UniqueTest._meta.unique_together, [])
2035:            editor.alter_unique_together(UniqueTest, [], UniqueTest._meta.unique_together)
2042:    def test_unique_together_with_fk(self):
2044:        Tests removing and adding unique_together constraints that include
2052:        self.assertEqual(Book._meta.unique_together, ())
2053:        # Add the unique_together constraint
2055:            editor.alter_unique_together(Book, [], [['author', 'title']])
2058:            editor.alter_unique_together(Book, [['author', 'title']], [])
2060:    def test_unique_together_with_fk_with_existing_index(self):
2062:        Tests removing and adding unique_together constraints that include
2074:        self.assertEqual(Book._meta.unique_together, ())
2075:        # Add the unique_together constraint
2077:            editor.alter_unique_together(Book, [], [['author', 'title']])
2080:            editor.alter_unique_together(Book, [['author', 'title']], [])
2083:    def test_remove_unique_together_does_not_remove_meta_constraints(self):
2101:        unique_together = AuthorWithUniqueNameAndBirthday._meta.unique_together
2103:            editor.alter_unique_together(AuthorWithUniqueNameAndBirthday, unique_together, [])
2113:            editor.alter_unique_together(AuthorWithUniqueNameAndBirthday, [], unique_together)
2180:        # Add the unique_together constraint
django/db/backends/base/schema.py:402:    def _delete_composed_index(self, model, fields, constraint_kwargs, sql):
django/db/backends/base/schema.py-403-        meta_constraint_names = {constraint.name for constraint in model._meta.constraints}
django/db/backends/base/schema.py-404-        meta_index_names = {constraint.name for constraint in model._meta.indexes}
django/db/backends/base/schema.py-405-        columns = [model._meta.get_field(field).column for field in fields]
django/db/backends/base/schema.py-406-        constraint_names = self._constraint_names(
django/db/backends/base/schema.py-407-            model, columns, exclude=meta_constraint_names | meta_index_names,
django/db/backends/base/schema.py-408-            **constraint_kwargs
django/db/backends/base/schema.py-409-        )
django/db/backends/base/schema.py-410-        if len(constraint_names) != 1:
django/db/backends/base/schema.py-411-            raise ValueError("Found wrong number (%s) of constraints for %s(%s)" % (
django/db/backends/base/schema.py-412-                len(constraint_names),
django/db/backends/base/schema.py-413-                model._meta.db_table,
django/db/backends/base/schema.py-414-                ", ".join(columns),
django/db/backends/base/schema.py-415-            ))
django/db/backends/base/schema.py-416-        self.execute(self._delete_constraint_sql(sql, model, constraint_names[0]))
django/db/backends/base/schema.py-417-
--
django/db/backends/mysql/schema.py:115:    def _delete_composed_index(self, model, fields, *args):
django/db/backends/mysql/schema.py-116-        """
django/db/backends/mysql/schema.py-117-        MySQL can remove an implicit FK index on a field when that field is
django/db/backends/mysql/schema.py-118-        covered by another index like a unique_together. "covered" here means
django/db/backends/mysql/schema.py-119-        that the more complex index starts like the simpler one.
django/db/backends/mysql/schema.py-120-        http://bugs.mysql.com/bug.php?id=37910 / Django ticket #24757
django/db/backends/mysql/schema.py-121-        We check here before removing the [unique|index]_together if we have to
django/db/backends/mysql/schema.py-122-        recreate a FK index.
django/db/backends/mysql/schema.py-123-        """
django/db/backends/mysql/schema.py-124-        first_field = model._meta.get_field(fields[0])
django/db/backends/mysql/schema.py-125-        if first_field.get_internal_type() == 'ForeignKey':
django/db/backends/mysql/schema.py-126-            constraint_names = self._constraint_names(model, [first_field.column], index=True)
django/db/backends/mysql/schema.py-127-            if not constraint_names:
django/db/backends/mysql/schema.py-128-                self.execute(self._create_index_sql(model, [first_field], suffix=""))
django/db/backends/mysql/schema.py-129-        return super()._delete_composed_index(model, fields, *args)
django/db/backends/mysql/schema.py-130-
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Tag\\|class UniqueTest\\|class AuthorWithUniqueNameAndBirthday\\|class AuthorWithIndexedNameAndBirthday\" tests/schema/models.py; sed -n '1,80p' tests/schema/models.py"
}
```

**tool result**

```
65:class AuthorWithIndexedNameAndBirthday(models.Model):
74:class AuthorWithUniqueNameAndBirthday(models.Model):
174:class Tag(models.Model):
182:class TagIndexed(models.Model):
191:class TagM2MTest(models.Model):
199:class TagUniqueRename(models.Model):
220:class UniqueTest(models.Model):
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

    class Meta:
        apps = new_apps


class AuthorWithIndexedNameAndBirthday(models.Model):
    name = models.CharField(max_length=255)
    birthday = models.DateField()

    class Meta:
        apps = new_apps
        index_together = [['name', 'birthday']]


class AuthorWithUniqueNameAndBirthday(models.Model):
    name = models.CharField(max_length=255)
    birthday = models.DateField()

    class Meta:
        apps = new_apps
        unique_together = [['name', 'birthday']]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '165,235p' tests/schema/models.py; sed -n '1,60p' tests/schema/tests.py"
}
```

**tool result**

```

class NoteRename(models.Model):
    detail_info = models.TextField()

    class Meta:
        apps = new_apps
        db_table = "schema_note"


class Tag(models.Model):
    title = models.CharField(max_length=255)
    slug = models.SlugField(unique=True)

    class Meta:
        apps = new_apps


class TagIndexed(models.Model):
    title = models.CharField(max_length=255)
    slug = models.SlugField(unique=True)

    class Meta:
        apps = new_apps
        index_together = [["slug", "title"]]


class TagM2MTest(models.Model):
    title = models.CharField(max_length=255)
    slug = models.SlugField(unique=True)

    class Meta:
        apps = new_apps


class TagUniqueRename(models.Model):
    title = models.CharField(max_length=255)
    slug2 = models.SlugField(unique=True)

    class Meta:
        apps = new_apps
        db_table = "schema_tag"


# Based on tests/reserved_names/models.py
class Thing(models.Model):
    when = models.CharField(max_length=1, primary_key=True)

    class Meta:
        apps = new_apps
        db_table = 'drop'

    def __str__(self):
        return self.when


class UniqueTest(models.Model):
    year = models.IntegerField()
    slug = models.SlugField(unique=False)

    class Meta:
        apps = new_apps
        unique_together = ["year", "slug"]


class Node(models.Model):
    node_id = models.AutoField(primary_key=True)
    parent = models.ForeignKey('self', models.CASCADE, null=True, blank=True)

    class Meta:
        apps = new_apps
import datetime
import itertools
import unittest
from copy import copy
from unittest import mock

from django.core.management.color import no_style
from django.db import (
    DatabaseError, DataError, IntegrityError, OperationalError, connection,
)
from django.db.models import (
    CASCADE, PROTECT, AutoField, BigAutoField, BigIntegerField, BinaryField,
    BooleanField, CharField, CheckConstraint, DateField, DateTimeField,
    ForeignKey, ForeignObject, Index, IntegerField, ManyToManyField, Model,
    OneToOneField, PositiveIntegerField, Q, SlugField, SmallAutoField,
    SmallIntegerField, TextField, TimeField, UniqueConstraint, UUIDField,
)
from django.db.transaction import TransactionManagementError, atomic
from django.test import (
    TransactionTestCase, skipIfDBFeature, skipUnlessDBFeature,
)
from django.test.utils import CaptureQueriesContext, isolate_apps
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
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"unique_together =.*\\n.*index_together\\|index_together\" tests/schema/models.py"
}
```

**tool result**

```
71:        index_together = [['name', 'birthday']]
188:        index_together = [["slug", "title"]]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/backends/base/schema.py\n@@\n         news = {tuple(fields) for fields in new_index_together}\n         # Deleted indexes\n         for fields in olds.difference(news):\n-            self._delete_composed_index(model, fields, {'index': True}, self.sql_delete_index)\n+            self._delete_composed_index(\n+                model,\n+                fields,\n+                {'index': True, 'unique': False},\n+                self.sql_delete_index,\n+            )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/backends/base/schema.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/backends/base/schema.py now (1205 lines), around the change:
393:        news = {tuple(fields) for fields in new_index_together}
394:        # Deleted indexes
395:        for fields in olds.difference(news):
396:            self._delete_composed_index(
397:                model,
398:                fields,
399:                {'index': True, 'unique': False},
400:                self.sql_delete_index,
401:            )
402:        # Created indexes
403:        for field_names in news.difference(olds):
404:            fields = [model._meta.get_field(field) for field in field_names]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '60,130p' tests/schema/tests.py"
}
```

**tool result**

```
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
        if 'schema' in new_apps.all_models:
            for model in self.local_models:
                for many_to_many in model._meta.many_to_many:
                    through = many_to_many.remote_field.through
                    if through and through._meta.auto_created:
                        del new_apps.all_models['schema'][through._meta.model_name]
                del new_apps.all_models['schema'][model._meta.model_name]
        if self.isolated_local_models:
            with connection.schema_editor() as editor:
                for model in self.isolated_local_models:
                    editor.delete_model(model)

    def delete_tables(self):
        "Deletes all model tables for our models for a clean test environment"
        converter = connection.introspection.identifier_converter
        with connection.schema_editor() as editor:
            connection.disable_constraint_checking()
            table_names = connection.introspection.table_names()
            for model in itertools.chain(SchemaTests.models, self.local_models):
                tbl = converter(model._meta.db_table)
                if tbl in table_names:
                    editor.delete_model(model)
                    table_names.remove(tbl)
            connection.enable_constraint_checking()

    def column_classes(self, model):
        with connection.cursor() as cursor:
            columns = {
                d[0]: (connection.introspection.get_field_type(d[1], d), d)
                for d in connection.introspection.get_table_description(
                    cursor,
                    model._meta.db_table,
                )
            }
        # SQLite has a different format for field_type
        for name, (type, desc) in columns.items():
            if isinstance(type, tuple):
                columns[name] = (type[0], desc)
        # SQLite also doesn't error properly
        if not columns:
            raise DatabaseError("Table does not exist (empty pragma)")
        return columns

    def get_primary_key(self, table):
        with connection.cursor() as cursor:
            return connection.introspection.get_primary_key_column(cursor, table)

    def get_indexes(self, table):
        """
        Get the indexes on the table using a new cursor.
        """
        with connection.cursor() as cursor:
            return [
                c['columns'][0]
                for c in connection.introspection.get_constraints(cursor, table).values()
                if c['index'] and len(c['columns']) == 1
            ]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/schema/tests.py\n@@\n     def test_index_together_with_fk(self):\n         \"\"\"\n         Tests removing and adding index_together constraints that include\n         a foreign key.\n         \"\"\"\n@@\n         with connection.schema_editor() as editor:\n             editor.alter_index_together(Book, [['author', 'title']], [])\n \n+    def test_remove_index_together_does_not_remove_unique_together(self):\n+        \"\"\"\n+        Removing an index_together constraint doesn't remove a unique_together\n+        constraint on the same fields.\n+        \"\"\"\n+        with connection.schema_editor() as editor:\n+            editor.create_model(AuthorWithUniqueNameAndBirthday)\n+        with connection.schema_editor() as editor:\n+            editor.alter_index_together(\n+                AuthorWithUniqueNameAndBirthday,\n+                [],\n+                [['name', 'birthday']],\n+            )\n+        constraints = self.get_constraints(\n+            AuthorWithUniqueNameAndBirthday._meta.db_table\n+        )\n+        self.assertEqual(\n+            len([\n+                name for name, details in constraints.items()\n+                if details['columns'] == ['name', 'birthday'] and details['index']\n+            ]),\n+            2,\n+        )\n+        with connection.schema_editor() as editor:\n+            editor.alter_index_together(\n+                AuthorWithUniqueNameAndBirthday,\n+                [['name', 'birthday']],\n+                [],\n+            )\n+        constraints = self.get_constraints(\n+            AuthorWithUniqueNameAndBirthday._meta.db_table\n+        )\n+        unique_constraints = [\n+            name for name, details in constraints.items()\n+            if details['columns'] == ['name', 'birthday'] and details['unique']\n+        ]\n+        self.assertEqual(len(unique_constraints), 1)\n+\n     def test_create_index_together(self):\n         \"\"\"\n         Tests creating models with index_together already defined\n         \"\"\"\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/schema/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/schema/tests.py now (3185 lines), around the change:
2183:        # Alter it back
2184:        with connection.schema_editor() as editor:
2185:            editor.alter_index_together(Book, [['author', 'title']], [])
2186:
2187:    def test_remove_index_together_does_not_remove_unique_together(self):
2188:        """
2189:        Removing an index_together constraint doesn't remove a unique_together
2190:        constraint on the same fields.
2191:        """
2192:        with connection.schema_editor() as editor:
2193:            editor.create_model(AuthorWithUniqueNameAndBirthday)
2194:        with connection.schema_editor() as editor:
2195:            editor.alter_index_together(
2196:                AuthorWithUniqueNameAndBirthday,
2197:                [],
2198:                [['name', 'birthday']],
2199:            )
2200:        constraints = self.get_constraints(
2201:            AuthorWithUniqueNameAndBirthday._meta.db_table
2202:        )
2203:        self.assertEqual(
2204:            len([
2205:                name for name, details in constraints.items()
2206:                if details['columns'] == ['name', 'birthday'] and details['index']
2207:            ]),
2208:            2,
2209:        )
2210:        with connection.schema_editor() as editor:
2211:            editor.alter_index_together(
2212:                AuthorWithUniqueNameAndBirthday,
2213:                [['name', 'birthday']],
2214:                [],
2215:            )
2216:        constraints = self.get_constraints(
2217:            AuthorWithUniqueNameAndBirthday._meta.db_table
2218:        )
2219:        unique_constraints = [
2220:            name for name, details in constraints.items()
2221:            if details['columns'] == ['name', 'birthday'] and details['unique']
2222:        ]
2223:        self.assertEqual(len(unique_constraints), 1)
2224:
2225:    def test_create_index_together(self):
2226:        """
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py schema.tests.SchemaTests.test_remove_index_together_does_not_remove_unique_together schema.tests.SchemaTests.test_index_together schema.tests.SchemaTests.test_remove_index_together_does_not_remove_meta_indexes --verbosity 2 2>&1 | tail -40"
}
```

**tool result**

```
Creating test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
test_remove_index_together_does_not_remove_unique_together (schema.tests.SchemaTests) ... ok
test_index_together (schema.tests.SchemaTests) ... ok
test_remove_index_together_does_not_remove_meta_indexes (schema.tests.SchemaTests) ... ok

----------------------------------------------------------------------
Ran 3 tests in 0.044s

OK
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Testing against Django installed in '/testbed/django' with up to 8 processes
Importing application schema
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
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py schema --verbosity 1 2>&1 | tail -20"
}
```

**tool result**

```
    return self._execute_with_wrappers(sql, params, many=False, executor=self._execute)
  File "/testbed/django/db/backends/utils.py", line 75, in _execute_with_wrappers
    return executor(sql, params, many, context)
  File "/testbed/django/db/backends/utils.py", line 84, in _execute
    return self.cursor.execute(sql, params)
  File "/testbed/django/db/utils.py", line 90, in __exit__
    raise dj_exc_value.with_traceback(traceback) from exc_value
  File "/testbed/django/db/backends/utils.py", line 82, in _execute
    return self.cursor.execute(sql)
  File "/testbed/django/db/backends/sqlite3/base.py", line 409, in execute
    return Database.Cursor.execute(self, query)
django.db.utils.OperationalError: table "schema_authorwithuniquenameandbirthday" already exists

----------------------------------------------------------------------
Ran 132 tests in 1.031s

FAILED (errors=1, skipped=24)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/schema/tests.py\n@@\n         Removing an index_together constraint doesn't remove a unique_together\n         constraint on the same fields.\n         \"\"\"\n+        self.local_models.append(AuthorWithUniqueNameAndBirthday)\n         with connection.schema_editor() as editor:\n             editor.create_model(AuthorWithUniqueNameAndBirthday)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/schema/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/schema/tests.py now (3186 lines), around the change:
2189:        Removing an index_together constraint doesn't remove a unique_together
2190:        constraint on the same fields.
2191:        """
2192:        self.local_models.append(AuthorWithUniqueNameAndBirthday)
2193:        with connection.schema_editor() as editor:
2194:            editor.create_model(AuthorWithUniqueNameAndBirthday)
2195:        with connection.schema_editor() as editor:
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py schema --verbosity 1 2>&1 | tail -8"
}
```

**tool result**

```
.s............sss..s.ss.....s..ss.ssss.....sss.........s...................s........s.................................s......s.s...s
----------------------------------------------------------------------
Ran 132 tests in 1.446s

OK (skipped=24)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && git diff --stat && git status --porcelain -- . ':(exclude).memdoor' | wc -l && git diff django/db/backends/base/schema.py"
}
```

**tool result**

```
 django/db/backends/base/schema.py |  7 ++++++-
 tests/schema/tests.py             | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 1 deletion(-)
2
diff --git a/django/db/backends/base/schema.py b/django/db/backends/base/schema.py
index 61f88401ab..2e2d7bbb60 100755
--- a/django/db/backends/base/schema.py
+++ b/django/db/backends/base/schema.py
@@ -393,7 +393,12 @@ class BaseDatabaseSchemaEditor:
         news = {tuple(fields) for fields in new_index_together}
         # Deleted indexes
         for fields in olds.difference(news):
-            self._delete_composed_index(model, fields, {'index': True}, self.sql_delete_index)
+            self._delete_composed_index(
+                model,
+                fields,
+                {'index': True, 'unique': False},
+                self.sql_delete_index,
+            )
         # Created indexes
         for field_names in news.difference(olds):
             fields = [model._meta.get_field(field) for field in field_names]
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS"
}
```

**tool result**

```
PASS
```

**assistant**

```
Fixed the migration crash.

**Root cause:** `alter_index_together()` deleted the old index by matching only `{'index': True}`. A `unique_together` on the same columns also reports `index=True`, so `_delete_composed_index()` found two matching constraints and raised `ValueError: Found wrong number (2) of constraints`.

**Change:** In `django/db/backends/base/schema.py`, index-together deletion now filters with `{'index': True, 'unique': False}`, so it only targets the non-unique index and leaves the unique constraint intact.

**Test added:** `test_remove_index_together_does_not_remove_unique_together` in `tests/schema/tests.py` creates a model with a `unique_together`, adds then removes an `index_together` on the same fields, and asserts the unique constraint survives.

Full `schema` suite passes (132 tests, 24 skipped), and the required `git status` check exits 0.
```

## Run folder `single-2026-11-06T171642`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Migration crashes deleting an index_together if there is a unique_together on the same fields
Description
	
Happens with Django 1.11.10
Steps to reproduce:
1) Create models with 2 fields, add 2 same fields to unique_together and to index_together
2) Delete index_together -> Fail
It will fail at django/db/backends/base/schema.py, line 378, in _delete_composed_index(), ValueError: Found wrong number (2) of constraints for as this one will find two constraints, the _uniq and the _idx one. No way to get out of this...
The worst in my case is that happened as I wanted to refactor my code to use the "new" (Dj 1.11) Options.indexes feature. I am actually not deleting the index, just the way it is declared in my code.
I think there are 2 different points here:
1) The deletion of index_together should be possible alone or made coherent (migrations side?) with unique_together
2) Moving the declaration of an index should not result in an index re-creation
```
