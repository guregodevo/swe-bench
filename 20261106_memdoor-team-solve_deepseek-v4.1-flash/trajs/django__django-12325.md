# django__django-12325 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 213s 63 lines cost=0.013645 in=359271 cached=269824 out=24166 calls=27`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
17:16:42 weboff: chief: web_fetch,web_search
17:16:42 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

pk setup for MTI to parent get confused by multiple OneToOne references.
Description
	
class Document(models.Model):
	pass
class Picking(Document):
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
produces django.core.exceptions.ImproperlyConfigured: Add parent_link=True to appname.Picking.origin.
class Picking(Document):
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
Works
First issue is that order seems to matter?
Even if ordering is required "by design"(It shouldn't be we have explicit parent_link marker) shouldn't it look from top to bottom like it does with managers and other things?


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls -la && git log --oneline -5 2>/dev/null && git status --short 2>/dev/null | head -50"
}
```

**tool result**

```
/testbed
total 184
drwxrwxrwx   1 root root  4096 Nov  6 17:16 .
drwxr-xr-x   1 root root  4096 Nov  6 17:16 ..
-rw-r--r--   1 root root   782 Aug 13 01:07 .editorconfig
-rw-r--r--   1 root root    86 Aug 13 01:07 .eslintignore
-rw-r--r--   1 root root  1165 Aug 13 01:07 .eslintrc
drwxrwxrwx   1 root root  4096 Nov  6 17:16 .git
-rw-r--r--   1 root root   297 Aug 13 01:07 .gitattributes
-rw-r--r--   1 root root   353 Aug 13 01:07 .gitignore
-rw-r--r--   1 root root   164 Aug 13 01:07 .hgignore
drwxr-xr-x   4 root root  4096 Nov  6 17:16 .memdoor
drwxrwxrwx   2 root root  4096 Aug 13 01:07 .tx
-rw-r--r--   1 root root 37001 Aug 13 01:07 AUTHORS
-rw-r--r--   1 root root  1115 Aug 13 01:07 CONTRIBUTING.rst
drwxr-xr-x   2 root root  4096 Aug 13 01:08 Django.egg-info
-rw-r--r--   1 root root    51 Aug 13 01:07 FUNDING.yml
-rw-r--r--   1 root root   353 Aug 13 01:07 Gruntfile.js
-rw-r--r--   1 root root   236 Aug 13 01:07 INSTALL
-rw-r--r--   1 root root  1552 Aug 13 01:07 LICENSE
-rw-r--r--   1 root root 13221 Aug 13 01:07 LICENSE.python
-rw-r--r--   1 root root   307 Aug 13 01:07 MANIFEST.in
-rw-r--r--   1 root root  1900 Aug 13 01:07 README.rst
drwxrwxrwx  19 root root  4096 Aug 13 01:08 django
drwxrwxrwx  13 root root  4096 Aug 13 01:07 docs
drwxrwxrwx   2 root root  4096 Aug 13 01:07 extras
drwxrwxrwx   5 root root  4096 Aug 13 01:07 js_tests
-rw-r--r--   1 root root   347 Aug 13 01:07 package.json
drwxrwxrwx   2 root root  4096 Aug 13 01:07 scripts
-rw-r--r--   1 root root  2121 Aug 13 01:07 setup.cfg
-rw-r--r--   1 root root  2368 Aug 13 01:07 setup.py
drwxrwxrwx 212 root root 12288 Aug 13 01:07 tests
-rw-r--r--   1 root root  1535 Aug 13 01:07 tox.ini
a4207d7dd3 SWE-bench
29c126bb34 Fixed #31124 -- Fixed setting of get_FOO_display() when overriding inherited choices.
d202846ced Refs #29998 -- Corrected auto-created OneToOneField parent_link in MTI docs.
c5e373d48c Fixed obsolete comment in django.utils.crypto.salted_hmac().
b5a62bd17d Refs #27468 -- Added explicit tests for django.utils.crypto.salted_hmac()
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"parent_link=True\" django/db/models/base.py django/db/models/fields/related.py | head -50"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Add parent_link=True\" django/ | head -20"
}
```

**tool result**

```
django/db/models/base.py:248:                        parent_link=True,
```

**tool result**

```
django/db/models/options.py:256:                        'Add parent_link=True to %s.' % field,
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n 180,290p django/db/models/options.py && echo ---- && grep -n \"parent_link\\|parents\\|_meta\" django/db/models/base.py | head -80"
}
```

**tool result**

```

            self.unique_together = normalize_together(self.unique_together)
            self.index_together = normalize_together(self.index_together)
            # App label/class name interpolation for names of constraints and
            # indexes.
            if not getattr(cls._meta, 'abstract', False):
                for attr_name in {'constraints', 'indexes'}:
                    objs = getattr(self, attr_name, [])
                    setattr(self, attr_name, self._format_names_with_class(cls, objs))

            # verbose_name_plural is a special case because it uses a 's'
            # by default.
            if self.verbose_name_plural is None:
                self.verbose_name_plural = format_lazy('{}s', self.verbose_name)

            # order_with_respect_and ordering are mutually exclusive.
            self._ordering_clash = bool(self.ordering and self.order_with_respect_to)

            # Any leftover attributes must be invalid.
            if meta_attrs != {}:
                raise TypeError("'class Meta' got invalid attribute(s): %s" % ','.join(meta_attrs))
        else:
            self.verbose_name_plural = format_lazy('{}s', self.verbose_name)
        del self.meta

        # If the db_table wasn't provided, use the app_label + model_name.
        if not self.db_table:
            self.db_table = "%s_%s" % (self.app_label, self.model_name)
            self.db_table = truncate_name(self.db_table, connection.ops.max_name_length())

    def _format_names_with_class(self, cls, objs):
        """App label/class name interpolation for object names."""
        new_objs = []
        for obj in objs:
            obj = obj.clone()
            obj.name = obj.name % {
                'app_label': cls._meta.app_label.lower(),
                'class': cls.__name__.lower(),
            }
            new_objs.append(obj)
        return new_objs

    def _prepare(self, model):
        if self.order_with_respect_to:
            # The app registry will not be ready at this point, so we cannot
            # use get_field().
            query = self.order_with_respect_to
            try:
                self.order_with_respect_to = next(
                    f for f in self._get_fields(reverse=False)
                    if f.name == query or f.attname == query
                )
            except StopIteration:
                raise FieldDoesNotExist("%s has no field named '%s'" % (self.object_name, query))

            self.ordering = ('_order',)
            if not any(isinstance(field, OrderWrt) for field in model._meta.local_fields):
                model.add_to_class('_order', OrderWrt())
        else:
            self.order_with_respect_to = None

        if self.pk is None:
            if self.parents:
                # Promote the first parent link in lieu of adding yet another
                # field.
                field = next(iter(self.parents.values()))
                # Look for a local field with the same name as the
                # first parent link. If a local field has already been
                # created, use it instead of promoting the parent
                already_created = [fld for fld in self.local_fields if fld.name == field.name]
                if already_created:
                    field = already_created[0]
                field.primary_key = True
                self.setup_pk(field)
                if not field.remote_field.parent_link:
                    raise ImproperlyConfigured(
                        'Add parent_link=True to %s.' % field,
                    )
            else:
                auto = AutoField(verbose_name='ID', primary_key=True, auto_created=True)
                model.add_to_class('id', auto)

    def add_manager(self, manager):
        self.local_managers.append(manager)
        self._expire_cache()

    def add_field(self, field, private=False):
        # Insert the given field in the order in which it was created, using
        # the "creation_counter" attribute of the field.
        # Move many-to-many related fields from self.fields into
        # self.many_to_many.
        if private:
            self.private_fields.append(field)
        elif field.is_relation and field.many_to_many:
            bisect.insort(self.local_many_to_many, field)
        else:
            bisect.insort(self.local_fields, field)
            self.setup_pk(field)

        # If the field being added is a relation to another known field,
        # expire the cache on this field and the forward cache on the field
        # being referenced, because there will be new relationships in the
        # cache. Otherwise, expire the cache of references *to* this field.
        # The mechanism for getting at the related model is slightly odd -
        # ideally, we'd just ask for field.related_model. However, related_model
        # is a cached property, and all the models haven't been loaded yet, so
        # we need to make sure we don't cache a string reference.
        if field.is_relation and hasattr(field.remote_field, 'model') and field.remote_field.model:
            try:
                field.remote_field.model._meta._expire_cache(forward=False)
            except AttributeError:
----
79:        parents = [b for b in bases if isinstance(b, ModelBase)]
80:        if not parents:
89:        attr_meta = attrs.pop('Meta', None)
101:        abstract = getattr(attr_meta, 'abstract', False)
102:        meta = attr_meta or getattr(new_class, 'Meta', None)
103:        base_meta = getattr(new_class, '_meta', None)
122:        new_class.add_to_class('_meta', Options(meta, app_label))
129:                        x.DoesNotExist for x in parents if hasattr(x, '_meta') and not x._meta.abstract
138:                        x.MultipleObjectsReturned for x in parents if hasattr(x, '_meta') and not x._meta.abstract
142:            if base_meta and not base_meta.abstract:
147:                    new_class._meta.ordering = base_meta.ordering
149:                    new_class._meta.get_latest_by = base_meta.get_latest_by
151:        is_proxy = new_class._meta.proxy
155:        if is_proxy and base_meta and base_meta.swapped:
156:            raise TypeError("%s cannot proxy the swapped model '%s'." % (name, base_meta.swapped))
165:            new_class._meta.local_fields,
166:            new_class._meta.local_many_to_many,
167:            new_class._meta.private_fields
174:            for parent in [kls for kls in parents if hasattr(kls, '_meta')]:
175:                if parent._meta.abstract:
176:                    if parent._meta.fields:
185:                elif parent._meta.concrete_model is not base._meta.concrete_model:
189:            new_class._meta.setup_proxy(base)
190:            new_class._meta.concrete_model = base._meta.concrete_model
192:            new_class._meta.concrete_model = new_class
195:        parent_links = {}
196:        for base in reversed([new_class] + parents):
198:            if not hasattr(base, '_meta'):
201:            if base != new_class and not base._meta.abstract:
204:            for field in base._meta.local_fields:
207:                    parent_links[make_model_tuple(related)] = field
211:        # Do the appropriate setup for any model parents.
213:            if base not in parents or not hasattr(base, '_meta'):
214:                # Things without _meta aren't functional models, so they're
215:                # uninteresting parents.
219:            parent_fields = base._meta.local_fields + base._meta.local_many_to_many
220:            if not base._meta.abstract:
237:                base = base._meta.concrete_model
239:                if base_key in parent_links:
240:                    field = parent_links[base_key]
242:                    attr_name = '%s_ptr' % base._meta.model_name
248:                        parent_link=True,
254:                            "parent_link to base class %r clashes with "
268:                new_class._meta.parents[base] = field
270:                base_parents = base._meta.parents.copy()
282:                            for parent, parent_link in base_parents.items():
283:                                if field == parent_link:
284:                                    base_parents[parent] = new_field
287:                new_class._meta.parents.update(base_parents)
291:            for field in base._meta.private_fields:
293:                    if not base._meta.abstract:
304:                    if not base._meta.abstract:
310:        new_class._meta.indexes = [copy.deepcopy(idx) for idx in new_class._meta.indexes]
316:            attr_meta.abstract = False
317:            new_class.Meta = attr_meta
321:        new_class._meta.apps.register_model(new_class._meta.app_label, new_class)
331:        """Create some methods once self._meta has been populated."""
332:        opts = cls._meta
367:        # Set the name of _meta.indexes. This can't be done in
370:        for index in cls._meta.indexes:
378:        return cls._meta.base_manager
382:        return cls._meta.default_manager
409:        opts = self._meta
507:        if len(values) != len(cls._meta.concrete_fields):
511:                for f in cls._meta.concrete_fields
527:        if self._meta.concrete_model != other._meta.concrete_model:
542:        class_id = self._meta.app_label, self._meta.object_name
568:        meta = meta or self._meta
572:        for parent_link in self._meta.parents.values():
573:            if parent_link and parent_link != self._meta.pk:
574:                setattr(self, parent_link.target_field.attname, value)
575:        return setattr(self, self._meta.pk.attname, value)
584:            f.attname for f in self._meta.concrete_fields
627:            fields = [f.attname for f in self._meta.concrete_fields
633:        for field in self._meta.concrete_fields:
643:        for field in self._meta.related_objects:
661:            field = self._meta.get_field(field_name)
679:        for field in self._meta.concrete_fields:
724:            for field in self._meta.fields:
742:            for field in self._meta.concrete_fields:
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n 190,300p django/db/models/base.py"
}
```

**tool result**

```
            new_class._meta.concrete_model = base._meta.concrete_model
        else:
            new_class._meta.concrete_model = new_class

        # Collect the parent links for multi-table inheritance.
        parent_links = {}
        for base in reversed([new_class] + parents):
            # Conceptually equivalent to `if base is Model`.
            if not hasattr(base, '_meta'):
                continue
            # Skip concrete parent classes.
            if base != new_class and not base._meta.abstract:
                continue
            # Locate OneToOneField instances.
            for field in base._meta.local_fields:
                if isinstance(field, OneToOneField):
                    related = resolve_relation(new_class, field.remote_field.model)
                    parent_links[make_model_tuple(related)] = field

        # Track fields inherited from base models.
        inherited_attributes = set()
        # Do the appropriate setup for any model parents.
        for base in new_class.mro():
            if base not in parents or not hasattr(base, '_meta'):
                # Things without _meta aren't functional models, so they're
                # uninteresting parents.
                inherited_attributes.update(base.__dict__)
                continue

            parent_fields = base._meta.local_fields + base._meta.local_many_to_many
            if not base._meta.abstract:
                # Check for clashes between locally declared fields and those
                # on the base classes.
                for field in parent_fields:
                    if field.name in field_names:
                        raise FieldError(
                            'Local field %r in class %r clashes with field of '
                            'the same name from base class %r.' % (
                                field.name,
                                name,
                                base.__name__,
                            )
                        )
                    else:
                        inherited_attributes.add(field.name)

                # Concrete classes...
                base = base._meta.concrete_model
                base_key = make_model_tuple(base)
                if base_key in parent_links:
                    field = parent_links[base_key]
                elif not is_proxy:
                    attr_name = '%s_ptr' % base._meta.model_name
                    field = OneToOneField(
                        base,
                        on_delete=CASCADE,
                        name=attr_name,
                        auto_created=True,
                        parent_link=True,
                    )

                    if attr_name in field_names:
                        raise FieldError(
                            "Auto-generated field '%s' in class %r for "
                            "parent_link to base class %r clashes with "
                            "declared field of the same name." % (
                                attr_name,
                                name,
                                base.__name__,
                            )
                        )

                    # Only add the ptr field if it's not already present;
                    # e.g. migrations will already have it specified
                    if not hasattr(new_class, attr_name):
                        new_class.add_to_class(attr_name, field)
                else:
                    field = None
                new_class._meta.parents[base] = field
            else:
                base_parents = base._meta.parents.copy()

                # Add fields from abstract base class if it wasn't overridden.
                for field in parent_fields:
                    if (field.name not in field_names and
                            field.name not in new_class.__dict__ and
                            field.name not in inherited_attributes):
                        new_field = copy.deepcopy(field)
                        new_class.add_to_class(field.name, new_field)
                        # Replace parent links defined on this base by the new
                        # field. It will be appropriately resolved if required.
                        if field.one_to_one:
                            for parent, parent_link in base_parents.items():
                                if field == parent_link:
                                    base_parents[parent] = new_field

                # Pass any non-abstract parent classes onto child.
                new_class._meta.parents.update(base_parents)

            # Inherit private fields (like GenericForeignKey) from the parent
            # class
            for field in base._meta.private_fields:
                if field.name in field_names:
                    if not base._meta.abstract:
                        raise FieldError(
                            'Local field %r in class %r clashes with field of '
                            'the same name from base class %r.' % (
                                field.name,
                                name,
                                base.__name__,
                            )
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && cat > /tmp/repro.py <<'EOF'\nimport django\nfrom django.conf import settings\nsettings.configure(INSTALLED_APPS=['django.contrib.contenttypes','django.contrib.auth'],DATABASES={'default':{'ENGINE':'django.db.backends.sqlite3','NAME':':memory:'}})\ndjango.setup()\nfrom django.db import models\ntry:\n    class Document(models.Model):\n        class Meta: app_label='x'\n    class Picking(Document):\n        document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')\n        origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)\n        class Meta: app_label='x'\n    print(\"order1 ok\", Picking._meta.pk)\nexcept Exception as e:\n    print(\"order1 fail\", type(e), e)\ntry:\n    class Document2(models.Model):\n        class Meta: app_label='x'\n    class Picking2(Document2):\n        origin = models.OneToOneField(Document2, related_name='picking', on_delete=models.PROTECT)\n        document_ptr = models.OneToOneField(Document2, on_delete=models.CASCADE, parent_link=True, related_name='+')\n        class Meta: app_label='x'\n    print(\"order2 ok\", Picking2._meta.pk)\nexcept Exception as e:\n    print(\"order2 fail\", type(e), e)\nEOF\npython /tmp/repro.py"
}
```

**tool result**

```
order1 fail <class 'django.core.exceptions.ImproperlyConfigured'> Add parent_link=True to x.Picking.origin.
order2 ok x.Picking2.document_ptr
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -rn \"parent_link\" tests/ | head -60"
}
```

**tool result**

```
tests/model_formsets/models.py:150:    the_restaurant = models.OneToOneField(MexicanRestaurant, models.CASCADE, parent_link=True, primary_key=True)
tests/admin_utils/models.py:73:        parent_link=True,
tests/prefetch_related/models.py:26:    author = models.OneToOneField(Author, models.CASCADE, parent_link=True)
tests/prefetch_related/models.py:61:    book = models.OneToOneField(Book, models.CASCADE, parent_link=True)
tests/prefetch_related/tests.py:1069:    def test_parent_link_prefetch(self):
tests/model_inheritance/models.py:131:    parent = models.OneToOneField(Place, models.CASCADE, primary_key=True, parent_link=True)
tests/model_inheritance/tests.py:162:    def test_abstract_parent_link(self):
tests/model_inheritance/tests.py:167:            a = models.OneToOneField('A', parent_link=True, on_delete=models.CASCADE)
tests/model_inheritance/test_abstract_inheritance.py:290:            "for parent_link to base class 'ConcreteParent' clashes with "
tests/serializers/models/data.py:310:    parent = models.OneToOneField(BaseModel, models.CASCADE, parent_link=True)
tests/model_meta/models.py:150:    first_ancestor = models.OneToOneField(CommonAncestor, models.CASCADE, primary_key=True, parent_link=True)
tests/model_meta/models.py:154:    second_ancestor = models.OneToOneField(CommonAncestor, models.CASCADE, primary_key=True, parent_link=True)
tests/model_inheritance_regress/models.py:34:    parent = models.OneToOneField(Place, models.CASCADE, primary_key=True, parent_link=True)
tests/model_inheritance_regress/models.py:42:    # The parent_link connector need not be the pk on the model.
tests/model_inheritance_regress/models.py:44:    parent = models.OneToOneField(Place, models.CASCADE, parent_link=True)
tests/model_inheritance_regress/models.py:48:    # Test parent_link connector can be discovered in abstract classes.
tests/model_inheritance_regress/models.py:49:    parent = models.OneToOneField(Place, models.CASCADE, parent_link=True)
tests/admin_views/models.py:322:    media = models.OneToOneField(Media, models.CASCADE, primary_key=True, parent_link=True)
tests/model_forms/models.py:70:    article = models.OneToOneField(Article, models.CASCADE, parent_link=True)
tests/migrations/test_base.py:250:                        parent_link=True,
tests/invalid_models_tests/test_models.py:1009:    def test_missing_parent_link(self):
tests/invalid_models_tests/test_models.py:1010:        msg = 'Add parent_link=True to invalid_models_tests.ParkingLot.parent.'
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n 980,1050p tests/invalid_models_tests/test_models.py && sed -n 140,175p tests/model_inheritance/tests.py"
}
```

**tool result**

```
                "The model has two identical many-to-many relations through "
                "the intermediate model 'invalid_models_tests.Membership'.",
                obj=Group,
                id='models.E003',
            )
        ])

    def test_two_m2m_through_same_model_with_different_through_fields(self):
        class Country(models.Model):
            pass

        class ShippingMethod(models.Model):
            to_countries = models.ManyToManyField(
                Country, through='ShippingMethodPrice',
                through_fields=('method', 'to_country'),
            )
            from_countries = models.ManyToManyField(
                Country, through='ShippingMethodPrice',
                through_fields=('method', 'from_country'),
                related_name='+',
            )

        class ShippingMethodPrice(models.Model):
            method = models.ForeignKey(ShippingMethod, models.CASCADE)
            to_country = models.ForeignKey(Country, models.CASCADE)
            from_country = models.ForeignKey(Country, models.CASCADE)

        self.assertEqual(ShippingMethod.check(), [])

    def test_missing_parent_link(self):
        msg = 'Add parent_link=True to invalid_models_tests.ParkingLot.parent.'
        with self.assertRaisesMessage(ImproperlyConfigured, msg):
            class Place(models.Model):
                pass

            class ParkingLot(Place):
                parent = models.OneToOneField(Place, models.CASCADE)

    def test_m2m_table_name_clash(self):
        class Foo(models.Model):
            bar = models.ManyToManyField('Bar', db_table='myapp_bar')

            class Meta:
                db_table = 'myapp_foo'

        class Bar(models.Model):
            class Meta:
                db_table = 'myapp_bar'

        self.assertEqual(Foo.check(), [
            Error(
                "The field's intermediary table 'myapp_bar' clashes with the "
                "table name of 'invalid_models_tests.Bar'.",
                obj=Foo._meta.get_field('bar'),
                id='fields.E340',
            )
        ])

    def test_m2m_field_table_name_clash(self):
        class Foo(models.Model):
            pass

        class Bar(models.Model):
            foos = models.ManyToManyField(Foo, db_table='clash')

        class Baz(models.Model):
            foos = models.ManyToManyField(Foo, db_table='clash')

        self.assertEqual(Bar.check() + Baz.check(), [
            Error(
                "The field's intermediary table 'clash' clashes with the "
                last_name='parent',
            )

        def b():
            GrandChild().save()
        for i, test in enumerate([a, b]):
            with self.subTest(i=i), self.assertNumQueries(4), CaptureQueriesContext(connection) as queries:
                test()
                for query in queries:
                    sql = query['sql']
                    self.assertIn('INSERT INTO', sql, sql)

    def test_eq(self):
        # Equality doesn't transfer in multitable inheritance.
        self.assertNotEqual(Place(id=1), Restaurant(id=1))
        self.assertNotEqual(Restaurant(id=1), Place(id=1))

    def test_mixin_init(self):
        m = MixinModel()
        self.assertEqual(m.other_attr, 1)

    @isolate_apps('model_inheritance')
    def test_abstract_parent_link(self):
        class A(models.Model):
            pass

        class B(A):
            a = models.OneToOneField('A', parent_link=True, on_delete=models.CASCADE)

            class Meta:
                abstract = True

        class C(B):
            pass

        self.assertIs(C._meta.parents[A], C._meta.get_field('a'))
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/base.py\n@@\n             # Locate OneToOneField instances.\n             for field in base._meta.local_fields:\n                 if isinstance(field, OneToOneField):\n                     related = resolve_relation(new_class, field.remote_field.model)\n-                    parent_links[make_model_tuple(related)] = field\n+                    related = make_model_tuple(related)\n+                    # Use the field explicitly marked as the parent link,\n+                    # regardless of its position relative to other\n+                    # OneToOneFields pointing to the same model.\n+                    if related not in parent_links or field.remote_field.parent_link:\n+                        parent_links[related] = field\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/base.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/base.py now (1920 lines), around the change:
204:            for field in base._meta.local_fields:
205:                if isinstance(field, OneToOneField):
206:                    related = resolve_relation(new_class, field.remote_field.model)
207:                    related = make_model_tuple(related)
208:                    # Use the field explicitly marked as the parent link,
209:                    # regardless of its position relative to other
210:                    # OneToOneFields pointing to the same model.
211:                    if related not in parent_links or field.remote_field.parent_link:
212:                        parent_links[related] = field
213:
214:        # Track fields inherited from base models.
215:        inherited_attributes = set()
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python /tmp/repro.py"
}
```

**tool result**

```
order1 ok x.Picking.document_ptr
order2 ok x.Picking2.document_ptr
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n 1,60p tests/model_inheritance/tests.py && sed -n 1,60p tests/model_inheritance/models.py && grep -n \"class .*Place\\|class .*Restaurant\" tests/model_inheritance/models.py | head"
}
```

**tool result**

```
from operator import attrgetter

from django.core.exceptions import FieldError, ValidationError
from django.db import connection, models
from django.test import SimpleTestCase, TestCase
from django.test.utils import CaptureQueriesContext, isolate_apps

from .models import (
    Base, Chef, CommonInfo, GrandChild, GrandParent, ItalianRestaurant,
    MixinModel, ParkingLot, Place, Post, Restaurant, Student, SubBase,
    Supplier, Title, Worker,
)


class ModelInheritanceTests(TestCase):
    def test_abstract(self):
        # The Student and Worker models both have 'name' and 'age' fields on
        # them and inherit the __str__() method, just as with normal Python
        # subclassing. This is useful if you want to factor out common
        # information for programming purposes, but still completely
        # independent separate models at the database level.
        w1 = Worker.objects.create(name="Fred", age=35, job="Quarry worker")
        Worker.objects.create(name="Barney", age=34, job="Quarry worker")

        s = Student.objects.create(name="Pebbles", age=5, school_class="1B")

        self.assertEqual(str(w1), "Worker Fred")
        self.assertEqual(str(s), "Student Pebbles")

        # The children inherit the Meta class of their parents (if they don't
        # specify their own).
        self.assertSequenceEqual(
            Worker.objects.values("name"), [
                {"name": "Barney"},
                {"name": "Fred"},
            ],
        )

        # Since Student does not subclass CommonInfo's Meta, it has the effect
        # of completely overriding it. So ordering by name doesn't take place
        # for Students.
        self.assertEqual(Student._meta.ordering, [])

        # However, the CommonInfo class cannot be used as a normal model (it
        # doesn't exist as a model).
        with self.assertRaisesMessage(AttributeError, "'CommonInfo' has no attribute 'objects'"):
            CommonInfo.objects.all()

    def test_reverse_relation_for_different_hierarchy_tree(self):
        # Even though p.supplier for a Place 'p' (a parent of a Supplier), a
        # Restaurant object cannot access that reverse relation, since it's not
        # part of the Place-Supplier Hierarchy.
        self.assertQuerysetEqual(Place.objects.filter(supplier__name="foo"), [])
        msg = (
            "Cannot resolve keyword 'supplier' into field. Choices are: "
            "address, chef, chef_id, id, italianrestaurant, lot, name, "
            "place_ptr, place_ptr_id, provider, rating, serves_hot_dogs, serves_pizza"
        )
        with self.assertRaisesMessage(FieldError, msg):
            Restaurant.objects.filter(supplier__name="foo")
"""
XX. Model inheritance

Model inheritance exists in two varieties:
    - abstract base classes which are a way of specifying common
      information inherited by the subclasses. They don't exist as a separate
      model.
    - non-abstract base classes (the default), which are models in their own
      right with their own database tables and everything. Their subclasses
      have references back to them, created automatically.

Both styles are demonstrated here.
"""
from django.db import models

#
# Abstract base classes
#


class CommonInfo(models.Model):
    name = models.CharField(max_length=50)
    age = models.PositiveIntegerField()

    class Meta:
        abstract = True
        ordering = ['name']

    def __str__(self):
        return '%s %s' % (self.__class__.__name__, self.name)


class Worker(CommonInfo):
    job = models.CharField(max_length=50)


class Student(CommonInfo):
    school_class = models.CharField(max_length=10)

    class Meta:
        pass


#
# Abstract base classes with related models
#

class Post(models.Model):
    title = models.CharField(max_length=50)


class Attachment(models.Model):
    post = models.ForeignKey(
        Post,
        models.CASCADE,
        related_name='attached_%(class)s_set',
        related_query_name='attached_%(app_label)s_%(class)ss',
    )
    content = models.TextField()

87:class Place(models.Model):
103:class Restaurant(Place, Rating):
115:class ItalianRestaurant(Restaurant):
122:class Supplier(Place):
129:class ParkingLot(Place):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/model_inheritance/tests.py\n@@\n     @isolate_apps('model_inheritance')\n     def test_abstract_parent_link(self):\n         class A(models.Model):\n             pass\n \n         class B(A):\n             a = models.OneToOneField('A', parent_link=True, on_delete=models.CASCADE)\n \n             class Meta:\n                 abstract = True\n \n         class C(B):\n             pass\n \n         self.assertIs(C._meta.parents[A], C._meta.get_field('a'))\n+\n+    @isolate_apps('model_inheritance')\n+    def test_parent_link_with_other_one_to_one_field(self):\n+        class A(models.Model):\n+            pass\n+\n+        class B(A):\n+            a = models.OneToOneField(\n+                A,\n+                on_delete=models.CASCADE,\n+                parent_link=True,\n+                related_name='+',\n+            )\n+            other = models.OneToOneField(\n+                A,\n+                on_delete=models.CASCADE,\n+                related_name='other_b',\n+            )\n+\n+        self.assertIs(B._meta.parents[A], B._meta.get_field('a'))\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/model_inheritance/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/model_inheritance/tests.py now (544 lines), around the change:
173:            pass
174:
175:        self.assertIs(C._meta.parents[A], C._meta.get_field('a'))
176:
177:    @isolate_apps('model_inheritance')
178:    def test_parent_link_with_other_one_to_one_field(self):
179:        class A(models.Model):
180:            pass
181:
182:        class B(A):
183:            a = models.OneToOneField(
184:                A,
185:                on_delete=models.CASCADE,
186:                parent_link=True,
187:                related_name='+',
188:            )
189:            other = models.OneToOneField(
190:                A,
191:                on_delete=models.CASCADE,
192:                related_name='other_b',
193:            )
194:
195:        self.assertIs(B._meta.parents[A], B._meta.get_field('a'))
196:
197:    @isolate_apps('model_inheritance')
198:    def test_init_subclass(self):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/model_inheritance/tests.py\n@@\n     @isolate_apps('model_inheritance')\n     def test_parent_link_with_other_one_to_one_field(self):\n-        class A(models.Model):\n-            pass\n-\n-        class B(A):\n-            a = models.OneToOneField(\n-                A,\n-                on_delete=models.CASCADE,\n-                parent_link=True,\n-                related_name='+',\n-            )\n-            other = models.OneToOneField(\n-                A,\n-                on_delete=models.CASCADE,\n-                related_name='other_b',\n-            )\n-\n-        self.assertIs(B._meta.parents[A], B._meta.get_field('a'))\n+        class A(models.Model):\n+            pass\n+\n+        for parent_link_first in (True, False):\n+            with self.subTest(parent_link_first=parent_link_first):\n+                fields = {\n+                    'a': models.OneToOneField(\n+                        A,\n+                        on_delete=models.CASCADE,\n+                        parent_link=True,\n+                        related_name='+',\n+                    ),\n+                    'other': models.OneToOneField(\n+                        A,\n+                        on_delete=models.CASCADE,\n+                        related_name='+',\n+                    ),\n+                }\n+                if not parent_link_first:\n+                    fields = dict(reversed(list(fields.items())))\n+                B = type('B', (A,), {'Meta': type('Meta', (), {'app_label': 'model_inheritance'}), **fields})\n+                self.assertIs(B._meta.parents[A], B._meta.get_field('a'))\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/model_inheritance/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/model_inheritance/tests.py now (549 lines), around the change:
179:        class A(models.Model):
180:            pass
181:
182:        for parent_link_first in (True, False):
183:            with self.subTest(parent_link_first=parent_link_first):
184:                fields = {
185:                    'a': models.OneToOneField(
186:                        A,
187:                        on_delete=models.CASCADE,
188:                        parent_link=True,
189:                        related_name='+',
190:                    ),
191:                    'other': models.OneToOneField(
192:                        A,
193:                        on_delete=models.CASCADE,
194:                        related_name='+',
195:                    ),
196:                }
197:                if not parent_link_first:
198:                    fields = dict(reversed(list(fields.items())))
199:                B = type('B', (A,), {'Meta': type('Meta', (), {'app_label': 'model_inheritance'}), **fields})
200:                self.assertIs(B._meta.parents[A], B._meta.get_field('a'))
201:
202:    @isolate_apps('model_inheritance')
203:    def test_init_subclass(self):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/model_inheritance/tests.py\n@@\n     @isolate_apps('model_inheritance')\n     def test_parent_link_with_other_one_to_one_field(self):\n         class A(models.Model):\n             pass\n \n-        for parent_link_first in (True, False):\n-            with self.subTest(parent_link_first=parent_link_first):\n-                fields = {\n-                    'a': models.OneToOneField(\n-                        A,\n-                        on_delete=models.CASCADE,\n-                        parent_link=True,\n-                        related_name='+',\n-                    ),\n-                    'other': models.OneToOneField(\n-                        A,\n-                        on_delete=models.CASCADE,\n-                        related_name='+',\n-                    ),\n-                }\n-                if not parent_link_first:\n-                    fields = dict(reversed(list(fields.items())))\n-                B = type('B', (A,), {'Meta': type('Meta', (), {'app_label': 'model_inheritance'}), **fields})\n-                self.assertIs(B._meta.parents[A], B._meta.get_field('a'))\n+        class ParentLinkFirst(A):\n+            a = models.OneToOneField(\n+                A,\n+                on_delete=models.CASCADE,\n+                parent_link=True,\n+                related_name='+',\n+            )\n+            other = models.OneToOneField(\n+                A,\n+                on_delete=models.CASCADE,\n+                related_name='+',\n+            )\n+\n+        class ParentLinkLast(A):\n+            other = models.OneToOneField(\n+                A,\n+                on_delete=models.CASCADE,\n+                related_name='+',\n+            )\n+            a = models.OneToOneField(\n+                A,\n+                on_delete=models.CASCADE,\n+                parent_link=True,\n+                related_name='+',\n+            )\n+\n+        self.assertIs(ParentLinkFirst._meta.parents[A], ParentLinkFirst._meta.get_field('a'))\n+        self.assertIs(ParentLinkLast._meta.parents[A], ParentLinkLast._meta.get_field('a'))\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/model_inheritance/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/model_inheritance/tests.py now (558 lines), around the change:
179:        class A(models.Model):
180:            pass
181:
182:        class ParentLinkFirst(A):
183:            a = models.OneToOneField(
184:                A,
185:                on_delete=models.CASCADE,
186:                parent_link=True,
187:                related_name='+',
188:            )
189:            other = models.OneToOneField(
190:                A,
191:                on_delete=models.CASCADE,
192:                related_name='+',
193:            )
194:
195:        class ParentLinkLast(A):
196:            other = models.OneToOneField(
197:                A,
198:                on_delete=models.CASCADE,
199:                related_name='+',
200:            )
201:            a = models.OneToOneField(
202:                A,
203:                on_delete=models.CASCADE,
204:                parent_link=True,
205:                related_name='+',
206:            )
207:
208:        self.assertIs(ParentLinkFirst._meta.parents[A], ParentLinkFirst._meta.get_field('a'))
209:        self.assertIs(ParentLinkLast._meta.parents[A], ParentLinkLast._meta.get_field('a'))
210:
211:    @isolate_apps('model_inheritance')
212:    def test_init_subclass(self):
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py model_inheritance.tests.ModelInheritanceTests.test_parent_link_with_other_one_to_one_field model_inheritance.tests.ModelInheritanceTests.test_abstract_parent_link invalid_models_tests.test_models.InvalidModelTest.test_missing_parent_link -v2 2>&1 | tail -30"
}
```

**tool result**

```
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying sites.0001_initial... OK
  Applying sites.0002_alter_domain_unique... OK
System check identified no issues (0 silenced).
Creating test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Cloning test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Cloning test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
InvalidModelTest (unittest.loader._FailedTest) ... ERROR
test_parent_link_with_other_one_to_one_field (model_inheritance.tests.ModelInheritanceTests) ... ok
test_abstract_parent_link (model_inheritance.tests.ModelInheritanceTests) ... ok

======================================================================
ERROR: InvalidModelTest (unittest.loader._FailedTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 34, in testFailure
    raise self._exception
AttributeError: module 'invalid_models_tests.test_models' has no attribute 'InvalidModelTest'

----------------------------------------------------------------------
Ran 3 tests in 0.127s

FAILED (errors=1)
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n \"class .*Test\" tests/invalid_models_tests/test_models.py | head && python tests/runtests.py invalid_models_tests.test_models.ModelInheritanceTests -v1 2>&1 | tail -15"
}
```

**tool result**

```
30:class IndexTogetherTests(SimpleTestCase):
136:class UniqueTogetherTests(SimpleTestCase):
235:class IndexesTests(SimpleTestCase):
334:class FieldNamesTests(SimpleTestCase):
514:class ShadowingFieldsTests(SimpleTestCase):
623:class OtherModelTests(SimpleTestCase):
898:        class Test__Model(models.Model):
1206:class ConstraintsTests(SimpleTestCase):
E
======================================================================
ERROR: ModelInheritanceTests (unittest.loader._FailedTest)
----------------------------------------------------------------------
AttributeError: module 'invalid_models_tests.test_models' has no attribute 'ModelInheritanceTests'

----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py invalid_models_tests.test_models.OtherModelTests.test_missing_parent_link model_inheritance -v1 2>&1 | tail -15"
}
```

**tool result**

```
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
................................................
----------------------------------------------------------------------
Ran 48 tests in 0.126s

OK
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
  "command": "cd /testbed && python tests/runtests.py model_inheritance model_inheritance_regress invalid_models_tests model_meta -v1 2>&1 | tail -12"
}
```

**tool result**

```
Ran 297 tests in 0.228s

OK (skipped=4, expected failures=1)
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
  "command": "find / -path /testbed -prune -o -name base.py -path \"*db/models*\" -print 2>/dev/null | head"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py model_forms model_formsets serializers migrations -v1 2>&1 | tail -8"
}
```

**tool result**

```
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py model_forms model_formsets serializers migrations -v1 2>&1 | grep -E \"^(Ran|OK|FAILED|ERROR)\" "
}
```

**tool result**

```
Ran 874 tests in 4.156s
OK
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && git diff -- django/db/models/base.py tests/model_inheritance/tests.py"
}
```

**tool result**

```
diff --git a/django/db/models/base.py b/django/db/models/base.py
index 8ea6c05ef9..24a811b824 100644
--- a/django/db/models/base.py
+++ b/django/db/models/base.py
@@ -204,7 +204,12 @@ class ModelBase(type):
             for field in base._meta.local_fields:
                 if isinstance(field, OneToOneField):
                     related = resolve_relation(new_class, field.remote_field.model)
-                    parent_links[make_model_tuple(related)] = field
+                    related = make_model_tuple(related)
+                    # Use the field explicitly marked as the parent link,
+                    # regardless of its position relative to other
+                    # OneToOneFields pointing to the same model.
+                    if related not in parent_links or field.remote_field.parent_link:
+                        parent_links[related] = field
 
         # Track fields inherited from base models.
         inherited_attributes = set()
diff --git a/tests/model_inheritance/tests.py b/tests/model_inheritance/tests.py
index 5eef0f5bfa..d584a53f4e 100644
--- a/tests/model_inheritance/tests.py
+++ b/tests/model_inheritance/tests.py
@@ -174,6 +174,40 @@ class ModelInheritanceTests(TestCase):
 
         self.assertIs(C._meta.parents[A], C._meta.get_field('a'))
 
+    @isolate_apps('model_inheritance')
+    def test_parent_link_with_other_one_to_one_field(self):
+        class A(models.Model):
+            pass
+
+        class ParentLinkFirst(A):
+            a = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                parent_link=True,
+                related_name='+',
+            )
+            other = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                related_name='+',
+            )
+
+        class ParentLinkLast(A):
+            other = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                related_name='+',
+            )
+            a = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                parent_link=True,
+                related_name='+',
+            )
+
+        self.assertIs(ParentLinkFirst._meta.parents[A], ParentLinkFirst._meta.get_field('a'))
+        self.assertIs(ParentLinkLast._meta.parents[A], ParentLinkLast._meta.get_field('a'))
+
     @isolate_apps('model_inheritance')
     def test_init_subclass(self):
         saved_kwargs = {}
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n \"max-line-length\" setup.cfg tox.ini && python -m flake8 django/db/models/base.py tests/model_inheritance/tests.py 2>&1 | head"
}
```

**tool result**

```
setup.cfg:61:max-line-length = 119
/opt/miniconda3/envs/testbed/bin/python: No module named flake8
```

**assistant**

````
Implemented the fix.

## Root cause

In `ModelBase.__new__` (`django/db/models/base.py`), parent links were collected into a dict keyed by the related model:

```python
parent_links[make_model_tuple(related)] = field
```

When a model declared multiple `OneToOneField`s to the same parent model, the **last one in declaration order silently overwrote the earlier ones** — even if an earlier field was explicitly marked `parent_link=True`. `Options._prepare()` then promoted whichever field happened to survive and raised `ImproperlyConfigured` if that field wasn't the parent link.

## Fix

The collection now prefers a field explicitly marked `parent_link=True`, independent of declaration order:

```python
related = make_model_tuple(related)
# Use the field explicitly marked as the parent link,
# regardless of its position relative to other
# OneToOneFields pointing to the same model.
if related not in parent_links or field.remote_field.parent_link:
    parent_links[related] = field
```

This also fixes the related case where a concrete subclass's ordinary `OneToOneField` could shadow a parent link inherited from an abstract base.

## Test

Added `test_parent_link_with_other_one_to_one_field` in `tests/model_inheritance/tests.py`, covering both declaration orders (`parent_link` first and last) and asserting `_meta.parents[A]` resolves to the marked field.

## Verification

- Original repro now works in both field orders.
- `model_inheritance`, `model_inheritance_regress`, `invalid_models_tests`, `model_meta`: 297 tests OK.
- `model_forms`, `model_formsets`, `serializers`, `migrations`: 874 tests OK.

No commits, checkouts, resets, or stashes were performed; `.memdoor/` was left untouched.
````

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py model_inheritance model_inheritance_regress invalid_models_tests model_meta model_forms model_formsets serializers migrations admin_utils -v1 2>&1 | grep -E \"^(Ran|OK|FAILED|ERROR|FAIL:)\""
}
```

**tool result**

```
Ran 1205 tests in 4.661s
OK (skipped=4, expected failures=1)
```

**assistant**

```
Final combined run: **1205 tests OK** (4 skipped, 1 expected failure) across `model_inheritance`, `model_inheritance_regress`, `invalid_models_tests`, `model_meta`, `model_forms`, `model_formsets`, `serializers`, `migrations`, and `admin_utils`.

The change is complete: parent-link selection no longer depends on field declaration order, and the regression test covers both orderings.
```

## Run folder `team-solve-2026-11-06T171642`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
a4207d7dd3e204621b099c424bc18f5979fa330e
```

### `baseline-check.log`

```
check: python tests/runtests.py model_inheritance
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
..............................................
----------------------------------------------------------------------
Ran 46 tests in 0.512s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
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
diff --git a/django/db/models/base.py b/django/db/models/base.py
index 8ea6c05ef9..24a811b824 100644
--- a/django/db/models/base.py
+++ b/django/db/models/base.py
@@ -204,7 +204,12 @@ class ModelBase(type):
             for field in base._meta.local_fields:
                 if isinstance(field, OneToOneField):
                     related = resolve_relation(new_class, field.remote_field.model)
-                    parent_links[make_model_tuple(related)] = field
+                    related = make_model_tuple(related)
+                    # Use the field explicitly marked as the parent link,
+                    # regardless of its position relative to other
+                    # OneToOneFields pointing to the same model.
+                    if related not in parent_links or field.remote_field.parent_link:
+                        parent_links[related] = field
 
         # Track fields inherited from base models.
         inherited_attributes = set()
diff --git a/tests/model_inheritance/tests.py b/tests/model_inheritance/tests.py
index 5eef0f5bfa..d584a53f4e 100644
--- a/tests/model_inheritance/tests.py
+++ b/tests/model_inheritance/tests.py
@@ -174,6 +174,40 @@ class ModelInheritanceTests(TestCase):
 
         self.assertIs(C._meta.parents[A], C._meta.get_field('a'))
 
+    @isolate_apps('model_inheritance')
+    def test_parent_link_with_other_one_to_one_field(self):
+        class A(models.Model):
+            pass
+
+        class ParentLinkFirst(A):
+            a = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                parent_link=True,
+                related_name='+',
+            )
+            other = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                related_name='+',
+            )
+
+        class ParentLinkLast(A):
+            other = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                related_name='+',
+            )
+            a = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                parent_link=True,
+                related_name='+',
+            )
+
+        self.assertIs(ParentLinkFirst._meta.parents[A], ParentLinkFirst._meta.get_field('a'))
+        self.assertIs(ParentLinkLast._meta.parents[A], ParentLinkLast._meta.get_field('a'))
+
     @isolate_apps('model_inheritance')
     def test_init_subclass(self):
         saved_kwargs = {}
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

pk setup for MTI to parent get confused by multiple OneToOne references.
Description
	
class Document(models.Model):
	pass
class Picking(Document):
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
produces django.core.exceptions.ImproperlyConfigured: Add parent_link=True to appname.Picking.origin.
class Picking(Document):
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
Works
First issue is that order seems to matter?
Even if ordering is required "by design"(It shouldn't be we have explicit parent_link marker) shouldn't it look from top to bottom like it does with managers and other things?

## Deliverable

changes to this tree

## Check

`python tests/runtests.py model_inheritance`

## Scope

`django/db/models/`
`tests/model_inheritance/`

## Done when

- A `Picking(Document)` model that declares a plain `OneToOneField(Document)` before the `OneToOneField(Document, parent_link=True)` field no longer raises `ImproperlyConfigured: Add parent_link=True to appname.Picking.origin`.
- The field explicitly marked `parent_link=True` is selected as the parent link regardless of its declaration order relative to other `OneToOneField`s to the same parent.
- Existing `model_inheritance` tests continue to pass.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py model_inheritance`

## Scope
`django/db/models/`
`tests/model_inheritance/`

## Done when
- A `Picking(Document)` model that declares a plain `OneToOneField(Document)` before the `OneToOneField(Document, parent_link=True)` field no longer raises `ImproperlyConfigured: Add parent_link=True to appname.Picking.origin`.
- The field explicitly marked `parent_link=True` is selected as the parent link regardless of its declaration order relative to other `OneToOneField`s to the same parent.
- Existing `model_inheritance` tests continue to pass.

## Approach
Find the parent-link selection logic in Django's model metaclass / options preparation (`django/db/models/base.py` and/or `django/db/models/options.py`) that currently takes the first eligible parent reference, and make it prefer fields whose `remote_field.parent_link` is true before falling back to declaration order.

Candidate approaches:
1. Minimal: where the first parent link is promoted (`next(iter(...))` or equivalent), first scan fields for an explicit `parent_link=True` matching the parent; use it if found, otherwise keep the existing order-based fallback. Lowest risk, but only corrects the single-promotion path.
2. Two-pass in `ModelBase.__new__`: build a mapping of parent model to explicit parent-link field first, then process implicit parent references. Fixes multiple-inheritance cases too, but touches more of the class-construction path.
3. Reorder `_meta.parents` population so explicit parent links are inserted before implicit ones. Makes the existing "first parent" logic naturally correct, but changes parent ordering visible to `get_parent_list()`/field cloning, so it is the riskiest.

If the first attempt fails, add a regression test in `tests/model_inheritance/` that defines the prompt's models in both field orders using `isolate_apps`, then rerun `python tests/runtests.py model_inheritance`.


# django/db/models (the files in it)

django/db/models/__init__.py
django/db/models/aggregates.py
django/db/models/base.py
django/db/models/constants.py
django/db/models/constraints.py
django/db/models/deletion.py
django/db/models/enums.py
django/db/models/expressions.py
django/db/models/fields/__init__.py
django/db/models/fields/files.py
django/db/models/fields/mixins.py
django/db/models/fields/proxy.py
django/db/models/fields/related.py
django/db/models/fields/related_descriptors.py
django/db/models/fields/related_lookups.py
django/db/models/fields/reverse_related.py
django/db/models/functions/__init__.py
django/db/models/functions/comparison.py
django/db/models/functions/datetime.py
django/db/models/functions/math.py
django/db/models/functions/mixins.py
django/db/models/functions/text.py
django/db/models/functions/window.py
django/db/models/indexes.py
django/db/models/lookups.py
django/db/models/manager.py
django/db/models/options.py
django/db/models/query.py
django/db/models/query_utils.py
django/db/models/signals.py
django/db/models/sql/__init__.py
django/db/models/sql/compiler.py
django/db/models/sql/constants.py
django/db/models/sql/datastructures.py
django/db/models/sql/query.py
django/db/models/sql/subqueries.py
django/db/models/sql/where.py
django/db/models/utils.py


# tests/model_inheritance (the files in it)

tests/model_inheritance/__init__.py
tests/model_inheritance/models.py
tests/model_inheritance/test_abstract_inheritance.py
tests/model_inheritance/tests.py


# The last commit

```
a4207d7dd3 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py model_inheritance
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
...............................................
----------------------------------------------------------------------
Ran 47 tests in 0.126s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/models tests/model_inheritance
changed: django/db/models/base.py +6 -1
changed: tests/model_inheritance/tests.py +34 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/db/models/base.py b/django/db/models/base.py
index 8ea6c05ef9..24a811b824 100644
--- a/django/db/models/base.py
+++ b/django/db/models/base.py
@@ -204,7 +204,12 @@ class ModelBase(type):
             for field in base._meta.local_fields:
                 if isinstance(field, OneToOneField):
                     related = resolve_relation(new_class, field.remote_field.model)
-                    parent_links[make_model_tuple(related)] = field
+                    related = make_model_tuple(related)
+                    # Use the field explicitly marked as the parent link,
+                    # regardless of its position relative to other
+                    # OneToOneFields pointing to the same model.
+                    if related not in parent_links or field.remote_field.parent_link:
+                        parent_links[related] = field
 
         # Track fields inherited from base models.
         inherited_attributes = set()
diff --git a/tests/model_inheritance/tests.py b/tests/model_inheritance/tests.py
index 5eef0f5bfa..d584a53f4e 100644
--- a/tests/model_inheritance/tests.py
+++ b/tests/model_inheritance/tests.py
@@ -174,6 +174,40 @@ class ModelInheritanceTests(TestCase):
 
         self.assertIs(C._meta.parents[A], C._meta.get_field('a'))
 
+    @isolate_apps('model_inheritance')
+    def test_parent_link_with_other_one_to_one_field(self):
+        class A(models.Model):
+            pass
+
+        class ParentLinkFirst(A):
+            a = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                parent_link=True,
+                related_name='+',
+            )
+            other = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                related_name='+',
+            )
+
+        class ParentLinkLast(A):
+            other = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                related_name='+',
+            )
+            a = models.OneToOneField(
+                A,
+                on_delete=models.CASCADE,
+                parent_link=True,
+                related_name='+',
+            )
+
+        self.assertIs(ParentLinkFirst._meta.parents[A], ParentLinkFirst._meta.get_field('a'))
+        self.assertIs(ParentLinkLast._meta.parents[A], ParentLinkLast._meta.get_field('a'))
+
     @isolate_apps('model_inheritance')
     def test_init_subclass(self):
         saved_kwargs = {}
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
check: python tests/runtests.py model_inheritance
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
...............................................
----------------------------------------------------------------------
Ran 47 tests in 0.247s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/models tests/model_inheritance
changed: django/db/models/base.py +6 -1
changed: tests/model_inheritance/tests.py +34 -0
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
# Notes, run 2026-11-06T171642

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

pk setup for MTI to parent get confused by multiple OneToOne references.
Description
	
class Document(models.Model):
	pass
class Picking(Document):
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
produces django.core.exceptions.ImproperlyConfigured: Add parent_link=True to appname.Picking.origin.
class Picking(Document):
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
Works
First issue is that order seems to matter?
Even if ordering is required "by design"(It shouldn't be we have explicit parent_link marker) shouldn't it look from top to bottom like it does with managers and other things?


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.gitattributes
.gitignore
.hgignore
.tx/config
AUTHORS
CONTRIBUTING.rst
FUNDING.yml
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
django/bin/django-admin.py
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
django/conf/locale/th/LC_MESSAGES/django.mo
django/conf/locale/th/LC_MESSAGES/django.po
django/conf/locale/th/__init__.py
django/conf/locale/th/formats.py
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
django/contrib/admin/bin/compress.py
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
django/contrib/admin/locale/km/LC_MESSAGES/django.po
django/contrib/admin/locale/km/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/km/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/kn/LC_MESSAGES/django.mo
django/contrib/admin/locale/kn/LC_MESSAGES/django.po
django/contrib/admin/locale/kn/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/kn/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ko/LC_MESSAGES/django.mo
django/contrib/admin/locale/ko/LC_MESSAGES/django.po
django/contrib/admin/locale/ko/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ko/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lb/LC_MESSAGES/django.mo
django/contrib/admin/locale/lb/LC_MESSAGES/django.po
django/contrib/admin/locale/lb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lb/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lt/LC_MESSAGES/django.mo
django/contrib/admin/locale/lt/LC_MESSAGES/django.po
django/contrib/admin/locale/lt/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lt/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lv/LC_MESSAGES/django.mo
django/contrib/admin/locale/lv/LC_MESSAGES/django.po
django/contrib/admin/locale/lv/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lv/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/mk/LC_MESSAGES/django.mo
django/contrib/admin/locale/mk/LC_MESSAGES/django.po
```


# The last commit

```
a4207d7dd3 SWE-bench


```

```diff

```


# package.json (the start)

```
{
  "name": "Django",
  "private": true,
  "scripts": {
    "pretest": "eslint django/ js_tests/admin/ js_tests/gis/",
    "test": "grunt test --verbose"
  },
  "engines": {
    "npm": ">=1.3.0 <3.0.0"
  },
  "devDependencies": {
    "eslint": "^4.18.2",
    "grunt": "^1.0.1",
    "grunt-cli": "^1.2.0",
    "grunt-contrib-qunit": "^1.2.0"
  }
}

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python tests/runtests.py model_inheritance`

## Scope
`django/db/models/`
`tests/model_inheritance/`

## Done when
- A `Picking(Document)` model that declares a plain `OneToOneField(Document)` before the `OneToOneField(Document, parent_link=True)` field no longer raises `ImproperlyConfigured: Add parent_link=True to appname.Picking.origin`.
- The field explicitly marked `parent_link=True` is selected as the parent link regardless of its declaration order relative to other `OneToOneField`s to the same parent.
- Existing `model_inheritance` tests continue to pass.

## Approach
Find the parent-link selection logic in Django's model metaclass / options preparation (`django/db/models/base.py` and/or `django/db/models/options.py`) that currently takes the first eligible parent reference, and make it prefer fields whose `remote_field.parent_link` is true before falling back to declaration order.

Candidate approaches:
1. Minimal: where the first parent link is promoted (`next(iter(...))` or equivalent), first scan fields for an explicit `parent_link=True` matching the parent; use it if found, otherwise keep the existing order-based fallback. Lowest risk, but only corrects the single-promotion path.
2. Two-pass in `ModelBase.__new__`: build a mapping of parent model to explicit parent-link field first, then process implicit parent references. Fixes multiple-inheritance cases too, but touches more of the class-construction path.
3. Reorder `_meta.parents` population so explicit parent links are inserted before implicit ones. Makes the existing "first parent" logic naturally correct, but changes parent ordering visible to `get_parent_list()`/field cloning, so it is the riskiest.

If the first attempt fails, add a regression test in `tests/model_inheritance/` that defines the prompt's models in both field orders using `isolate_apps`, then rerun `python tests/runtests.py model_inheritance`.
```

### `prompt.md`

```
pk setup for MTI to parent get confused by multiple OneToOne references.
Description
	
class Document(models.Model):
	pass
class Picking(Document):
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
produces django.core.exceptions.ImproperlyConfigured: Add parent_link=True to appname.Picking.origin.
class Picking(Document):
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
Works
First issue is that order seems to matter?
Even if ordering is required "by design"(It shouldn't be we have explicit parent_link marker) shouldn't it look from top to bottom like it does with managers and other things?
```

### `review.md`

```
verdict: PASS
- The check command `python tests/runtests.py model_inheritance` completed with status 0 and all 47 tests passed.
- The fix in `django/db/models/base.py` ensures an explicitly marked `parent_link=True` field is selected regardless of declaration order relative to other `OneToOneField`s to the same parent.
- The added test covers both orders: parent link declared first and parent link declared last.
- Changes are limited to the scoped files `django/db/models/base.py` and `tests/model_inheritance/tests.py`; no unrelated content was removed.
```

### `scope.txt`

```
scope: django/db/models tests/model_inheritance
changed: django/db/models/base.py +6 -1
changed: tests/model_inheritance/tests.py +34 -0
```

### `task.md`

```
# Task

## Prompt

pk setup for MTI to parent get confused by multiple OneToOne references.
Description
	
class Document(models.Model):
	pass
class Picking(Document):
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
produces django.core.exceptions.ImproperlyConfigured: Add parent_link=True to appname.Picking.origin.
class Picking(Document):
	origin = models.OneToOneField(Document, related_name='picking', on_delete=models.PROTECT)
	document_ptr = models.OneToOneField(Document, on_delete=models.CASCADE, parent_link=True, related_name='+')
Works
First issue is that order seems to matter?
Even if ordering is required "by design"(It shouldn't be we have explicit parent_link marker) shouldn't it look from top to bottom like it does with managers and other things?

## Deliverable

changes to this tree

## Check

`python tests/runtests.py model_inheritance`

## Scope

`django/db/models/`
`tests/model_inheritance/`

## Done when

- A `Picking(Document)` model that declares a plain `OneToOneField(Document)` before the `OneToOneField(Document, parent_link=True)` field no longer raises `ImproperlyConfigured: Add parent_link=True to appname.Picking.origin`.
- The field explicitly marked `parent_link=True` is selected as the parent link regardless of its declaration order relative to other `OneToOneField`s to the same parent.
- Existing `model_inheritance` tests continue to pass.
```

### `test-output.log`

```
check: python tests/runtests.py model_inheritance
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
...............................................
----------------------------------------------------------------------
Ran 47 tests in 0.126s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/db/models tests/model_inheritance
changed: django/db/models/base.py +6 -1
changed: tests/model_inheritance/tests.py +34 -0
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
