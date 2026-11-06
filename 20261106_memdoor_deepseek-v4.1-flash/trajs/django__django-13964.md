# django__django-13964 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 38s 13 lines cost=0.001916 in=110781 cached=78848 out=2246 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Saving parent object after setting on child leads to data loss for parents with non-numeric primary key.
Description
	 
		(last modified by Charlie DeTar)
	 
Given a model with a foreign key relation to another model that has a non-auto CharField as its primary key:
class Product(models.Model):
	sku = models.CharField(primary_key=True, max_length=50)
class Order(models.Model):
	product = models.ForeignKey(Product, on_delete=models.CASCADE)
If the relation is initialized on the parent with an empty instance that does not yet specify its primary key, and the primary key is subsequently defined, the parent does not "see" the primary key's change:
with transaction.atomic():
	order = Order()
	order.product = Product()
	order.product.sku = "foo"
	order.product.save()
	order.save()
	assert Order.objects.filter(product_id="").exists() # Succeeds, but shouldn't
	assert Order.objects.filter(product=order.product).exists() # Fails
Instead of product_id being populated with product.sku, it is set to emptystring. The foreign key constraint which would enforce the existence of a product with sku="" is deferred until the transaction commits. The transaction does correctly fail on commit with a ForeignKeyViolation due to the non-existence of a product with emptystring as its primary key.
On the other hand, if the related unsaved instance is initialized with its primary key before assignment to the parent, it is persisted correctly:
with transaction.atomic():
	order = Order()
	order.product = Product(sku="foo")
	order.product.save()
	order.save()
	assert Order.objects.filter(product=order.product).exists() # succeeds
Committing the transaction also succeeds.
This may have something to do with how the Order.product_id field is handled at assignment, together with something about handling fetching of auto vs non-auto primary keys from the related instance.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain -- . ':(exclude).memdoor' | head"
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
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"class ForwardManyToOneDescriptor\" django/db/models/fields/related_descriptors.py"
}
```

**tool result**

```
82:class ForwardManyToOneDescriptor:
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/fields/related_descriptors.py",
  "offset": 82,
  "limit": 280
}
```

**tool result**

```
class ForwardManyToOneDescriptor:
    """
    Accessor to the related object on the forward side of a many-to-one or
    one-to-one (via ForwardOneToOneDescriptor subclass) relation.

    In the example::

        class Child(Model):
            parent = ForeignKey(Parent, related_name='children')

    ``Child.parent`` is a ``ForwardManyToOneDescriptor`` instance.
    """

    def __init__(self, field_with_rel):
        self.field = field_with_rel

    @cached_property
    def RelatedObjectDoesNotExist(self):
        # The exception can't be created at initialization time since the
        # related model might not be resolved yet; `self.field.model` might
        # still be a string model reference.
        return type(
            'RelatedObjectDoesNotExist',
            (self.field.remote_field.model.DoesNotExist, AttributeError), {
                '__module__': self.field.model.__module__,
                '__qualname__': '%s.%s.RelatedObjectDoesNotExist' % (
                    self.field.model.__qualname__,
                    self.field.name,
                ),
            }
        )

    def is_cached(self, instance):
        return self.field.is_cached(instance)

    def get_queryset(self, **hints):
        return self.field.remote_field.model._base_manager.db_manager(hints=hints).all()

    def get_prefetch_queryset(self, instances, queryset=None):
        if queryset is None:
            queryset = self.get_queryset()
        queryset._add_hints(instance=instances[0])

        rel_obj_attr = self.field.get_foreign_related_value
        instance_attr = self.field.get_local_related_value
        instances_dict = {instance_attr(inst): inst for inst in instances}
        related_field = self.field.foreign_related_fields[0]
        remote_field = self.field.remote_field

        # FIXME: This will need to be revisited when we introduce support for
        # composite fields. In the meantime we take this practical approach to
        # solve a regression on 1.6 when the reverse manager in hidden
        # (related_name ends with a '+'). Refs #21410.
        # The check for len(...) == 1 is a special case that allows the query
        # to be join-less and smaller. Refs #21760.
        if remote_field.is_hidden() or len(self.field.foreign_related_fields) == 1:
            query = {'%s__in' % related_field.name: {instance_attr(inst)[0] for inst in instances}}
        else:
            query = {'%s__in' % self.field.related_query_name(): instances}
        queryset = queryset.filter(**query)

        # Since we're going to assign directly in the cache,
        # we must manage the reverse relation cache manually.
        if not remote_field.multiple:
            for rel_obj in queryset:
                instance = instances_dict[rel_obj_attr(rel_obj)]
                remote_field.set_cached_value(rel_obj, instance)
        return queryset, rel_obj_attr, instance_attr, True, self.field.get_cache_name(), False

    def get_object(self, instance):
        qs = self.get_queryset(instance=instance)
        # Assuming the database enforces foreign keys, this won't fail.
        return qs.get(self.field.get_reverse_related_filter(instance))

    def __get__(self, instance, cls=None):
        """
        Get the related instance through the forward relation.

        With the example above, when getting ``child.parent``:

        - ``self`` is the descriptor managing the ``parent`` attribute
        - ``instance`` is the ``child`` instance
        - ``cls`` is the ``Child`` class (we don't need it)
        """
        if instance is None:
            return self

        # The related instance is loaded from the database and then cached
        # by the field on the model instance state. It can also be pre-cached
        # by the reverse accessor (ReverseOneToOneDescriptor).
        try:
            rel_obj = self.field.get_cached_value(instance)
        except KeyError:
            has_value = None not in self.field.get_local_related_value(instance)
            ancestor_link = instance._meta.get_ancestor_link(self.field.model) if has_value else None
            if ancestor_link and ancestor_link.is_cached(instance):
                # An ancestor link will exist if this field is defined on a
                # multi-table inheritance parent of the instance's class.
                ancestor = ancestor_link.get_cached_value(instance)
                # The value might be cached on an ancestor if the instance
                # originated from walking down the inheritance chain.
                rel_obj = self.field.get_cached_value(ancestor, default=None)
            else:
                rel_obj = None
            if rel_obj is None and has_value:
                rel_obj = self.get_object(instance)
                remote_field = self.field.remote_field
                # If this is a one-to-one relation, set the reverse accessor
                # cache on the related object to the current instance to avoid
                # an extra SQL query if it's accessed later on.
                if not remote_field.multiple:
                    remote_field.set_cached_value(rel_obj, instance)
            self.field.set_cached_value(instance, rel_obj)

        if rel_obj is None and not self.field.null:
            raise self.RelatedObjectDoesNotExist(
                "%s has no %s." % (self.field.model.__name__, self.field.name)
            )
        else:
            return rel_obj

    def __set__(self, instance, value):
        """
        Set the related instance through the forward relation.

        With the example above, when setting ``child.parent = parent``:

        - ``self`` is the descriptor managing the ``parent`` attribute
        - ``instance`` is the ``child`` instance
        - ``value`` is the ``parent`` instance on the right of the equal sign
        """
        # An object must be an instance of the related class.
        if value is not None and not isinstance(value, self.field.remote_field.model._meta.concrete_model):
            raise ValueError(
                'Cannot assign "%r": "%s.%s" must be a "%s" instance.' % (
                    value,
                    instance._meta.object_name,
                    self.field.name,
                    self.field.remote_field.model._meta.object_name,
                )
            )
        elif value is not None:
            if instance._state.db is None:
                instance._state.db = router.db_for_write(instance.__class__, instance=value)
            if value._state.db is None:
                value._state.db = router.db_for_write(value.__class__, instance=instance)
            if not router.allow_relation(value, instance):
                raise ValueError('Cannot assign "%r": the current database router prevents this relation.' % value)

        remote_field = self.field.remote_field
        # If we're setting the value of a OneToOneField to None, we need to clear
        # out the cache on any old related object. Otherwise, deleting the
        # previously-related object will also cause this object to be deleted,
        # which is wrong.
        if value is None:
            # Look up the previously-related object, which may still be available
            # since we've not yet cleared out the related field.
            # Use the cache directly, instead of the accessor; if we haven't
            # populated the cache, then we don't care - we're only accessing
            # the object to invalidate the accessor cache, so there's no
            # need to populate the cache just to expire it again.
            related = self.field.get_cached_value(instance, default=None)

            # If we've got an old related object, we need to clear out its
            # cache. This cache also might not exist if the related object
            # hasn't been accessed yet.
            if related is not None:
                remote_field.set_cached_value(related, None)

            for lh_field, rh_field in self.field.related_fields:
                setattr(instance, lh_field.attname, None)

        # Set the values of the related field.
        else:
            for lh_field, rh_field in self.field.related_fields:
                setattr(instance, lh_field.attname, getattr(value, rh_field.attname))

        # Set the related instance cache used by __get__ to avoid an SQL query
        # when accessing the attribute we just set.
        self.field.set_cached_value(instance, value)

        # If this is a one-to-one relation, set the reverse accessor cache on
        # the related object to the current instance to avoid an extra SQL
        # query if it's accessed later on.
        if value is not None and not remote_field.multiple:
            remote_field.set_cached_value(value, instance)

    def __reduce__(self):
        """
        Pickling should return the instance attached by self.field on the
        model, not a new copy of that descriptor. Use getattr() to retrieve
        the instance directly from the model.
        """
        return getattr, (self.field.model, self.field.name)


class ForwardOneToOneDescriptor(ForwardManyToOneDescriptor):
    """
    Accessor to the related object on the forward side of a one-to-one relation.

    In the example::

        class Restaurant(Model):
            place = OneToOneField(Place, related_name='restaurant')

    ``Restaurant.place`` is a ``ForwardOneToOneDescriptor`` instance.
    """

    def get_object(self, instance):
        if self.field.remote_field.parent_link:
            deferred = instance.get_deferred_fields()
            # Because it's a parent link, all the data is available in the
            # instance, so populate the parent model with this data.
            rel_model = self.field.remote_field.model
            fields = [field.attname for field in rel_model._meta.concrete_fields]

            # If any of the related model's fields are deferred, fallback to
            # fetching all fields from the related model. This avoids a query
            # on the related model for every deferred field.
            if not any(field in fields for field in deferred):
                kwargs = {field: getattr(instance, field) for field in fields}
                obj = rel_model(**kwargs)
                obj._state.adding = instance._state.adding
                obj._state.db = instance._state.db
                return obj
        return super().get_object(instance)

    def __set__(self, instance, value):
        super().__set__(instance, value)
        # If the primary key is a link to a parent model and a parent instance
        # is being set, update the value of the inherited pk(s).
        if self.field.primary_key and self.field.remote_field.parent_link:
            opts = instance._meta
            # Inherited primary key fields from this object's base classes.
            inherited_pk_fields = [
                field for field in opts.concrete_fields
                if field.primary_key and field.remote_field
            ]
            for field in inherited_pk_fields:
                rel_model_pk_name = field.remote_field.model._meta.pk.attname
                raw_value = getattr(value, rel_model_pk_name) if value is not None else None
                setattr(instance, rel_model_pk_name, raw_value)


class ReverseOneToOneDescriptor:
    """
    Accessor to the related object on the reverse side of a one-to-one
    relation.

    In the example::

        class Restaurant(Model):
            place = OneToOneField(Place, related_name='restaurant')

    ``Place.restaurant`` is a ``ReverseOneToOneDescriptor`` instance.
    """

    def __init__(self, related):
        # Following the example above, `related` is an instance of OneToOneRel
        # which represents the reverse restaurant field (place.restaurant).
        self.related = related

    @cached_property
    def RelatedObjectDoesNotExist(self):
        # The exception isn't created at initialization time for the sake of
        # consistency with `ForwardManyToOneDescriptor`.
        return type(
            'RelatedObjectDoesNotExist',
            (self.related.related_model.DoesNotExist, AttributeError), {
                '__module__': self.related.model.__module__,
                '__qualname__': '%s.%s.RelatedObjectDoesNotExist' % (
                    self.related.model.__qualname__,
                    self.related.name,
                )
            },
        )

    def is_cached(self, instance):
        return self.related.is_cached(instance)


[844 more lines in /testbed/django/db/models/fields/related_descriptors.py (1205 in all). read_file with offset: 362 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"VERSION =\" django/__init__.py; grep -n \"def save\\|def _save_table\\|def save_base\" django/db/models/base.py | head -30; git log --oneline -3"
}
```

**tool result**

```
3:VERSION = (4, 0, 0, 'alpha', 0)
672:    def save(self, force_insert=False, force_update=False, using=None,
730:    def save_base(self, raw=False, force_insert=False,
809:    def _save_table(self, raw=False, cls=None, force_insert=False,
b74cd5f880 SWE-bench
f39634ff22 Refs #32390 -- Bumped required cx_Oracle to 7.0.
84283ab9cd Fixed #32390 -- Dropped support for Oracle 12.2 and 18c.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"non-auto\\|non_auto\\|unsaved.*primary\\|primary.*unsaved\\|sku\" tests/ | grep -i \"foreign\\|parent\\|primary\" | head -30"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"_prepare_related_fields_for_save\\|prepare_related\" django/db/models/"
}
```

**tool result**

```
django/db/models/base.py:682:        self._prepare_related_fields_for_save(operation_name='save')
django/db/models/base.py:911:    def _prepare_related_fields_for_save(self, operation_name):
django/db/models/query.py:461:            obj._prepare_related_fields_for_save(operation_name='bulk_create')
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/base.py",
  "offset": 900,
  "limit": 50
}
```

**tool result**

```

    def _do_insert(self, manager, using, fields, returning_fields, raw):
        """
        Do an INSERT. If returning_fields is defined then this method should
        return the newly created data for the model.
        """
        return manager._insert(
            [self], fields=fields, returning_fields=returning_fields,
            using=using, raw=raw,
        )

    def _prepare_related_fields_for_save(self, operation_name):
        # Ensure that a model instance without a PK hasn't been assigned to
        # a ForeignKey or OneToOneField on this model. If the field is
        # nullable, allowing the save would result in silent data loss.
        for field in self._meta.concrete_fields:
            # If the related field isn't cached, then an instance hasn't been
            # assigned and there's no need to worry about this check.
            if field.is_relation and field.is_cached(self):
                obj = getattr(self, field.name, None)
                if not obj:
                    continue
                # A pk may have been assigned manually to a model instance not
                # saved to the database (or auto-generated in a case like
                # UUIDField), but we allow the save to proceed and rely on the
                # database to raise an IntegrityError if applicable. If
                # constraints aren't supported by the database, there's the
                # unavoidable risk of data corruption.
                if obj.pk is None:
                    # Remove the object from a related instance cache.
                    if not field.remote_field.multiple:
                        field.remote_field.delete_cached_value(obj)
                    raise ValueError(
                        "%s() prohibited to prevent data loss due to unsaved "
                        "related object '%s'." % (operation_name, field.name)
                    )
                elif getattr(self, field.attname) is None:
                    # Use pk from related object if it has been saved after
                    # an assignment.
                    setattr(self, field.attname, obj.pk)
                # If the relationship's pk/to_field was changed, clear the
                # cached relationship.
                if getattr(obj, field.target_field.attname) != getattr(self, field.attname):
                    field.delete_cached_value(self)

    def delete(self, using=None, keep_parents=False):
        using = using or router.db_for_write(self.__class__, instance=self)
        assert self.pk is not None, (
            "%s object can't be deleted because its %s attribute is set to None." %
            (self._meta.object_name, self._meta.pk.attname)

[1195 more lines in /testbed/django/db/models/base.py (2144 in all). read_file with offset: 950 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/db/models/base.py\n@@\n-                elif getattr(self, field.attname) is None:\n+                elif getattr(self, field.attname) in field.empty_values:\n                     # Use pk from related object if it has been saved after\n                     # an assignment.\n                     setattr(self, field.attname, obj.pk)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/db/models/base.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/db/models/base.py now (2144 lines), around the change:
933:                        "%s() prohibited to prevent data loss due to unsaved "
934:                        "related object '%s'." % (operation_name, field.name)
935:                    )
936:                elif getattr(self, field.attname) in field.empty_values:
937:                    # Use pk from related object if it has been saved after
938:                    # an assignment.
939:                    setattr(self, field.attname, obj.pk)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"prohibited to prevent data loss\\|assigned to a.*unsaved\\|_prepare_related\" tests/ | head -20"
}
```

**tool result**

```
tests/one_to_one/tests.py:132:        msg = "save() prohibited to prevent data loss due to unsaved related object 'place'."
tests/one_to_one/tests.py:417:        msg = "save() prohibited to prevent data loss due to unsaved related object 'place'."
tests/bulk_create/tests.py:345:            "bulk_create() prohibited to prevent data loss due to unsaved "
tests/many_to_one/tests.py:520:        msg = "save() prohibited to prevent data loss due to unsaved related object 'parent'."
tests/many_to_one/tests.py:524:        msg = "save() prohibited to prevent data loss due to unsaved related object 'parent'."
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py many_to_one one_to_one bulk_create --verbosity 1 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
................................................................................s...........s.sss...s
----------------------------------------------------------------------
Ran 101 tests in 0.295s

OK (skipped=6)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class .*models.Model\\|primary_key\\|CharField\" tests/many_to_one/models.py | head -50; sed -n '500,540p' tests/many_to_one/tests.py"
}
```

**tool result**

```
9:class Reporter(models.Model):
10:    first_name = models.CharField(max_length=30)
11:    last_name = models.CharField(max_length=30)
18:class Article(models.Model):
19:    headline = models.CharField(max_length=100)
30:class Country(models.Model):
31:    id = models.SmallAutoField(primary_key=True)
32:    name = models.CharField(max_length=50)
35:class City(models.Model):
36:    id = models.BigAutoField(primary_key=True)
38:    name = models.CharField(max_length=50)
41:class District(models.Model):
43:    name = models.CharField(max_length=50)
52:class First(models.Model):
56:class Second(models.Model):
61:class Third(models.Model):
62:    name = models.CharField(max_length=20)
66:class Parent(models.Model):
67:    name = models.CharField(max_length=20, unique=True)
71:class Child(models.Model):
72:    name = models.CharField(max_length=20)
76:class ChildNullableParent(models.Model):
80:class ToFieldChild(models.Model):
85:class Category(models.Model):
86:    name = models.CharField(max_length=20)
92:class Record(models.Model):
96:class Relation(models.Model):
110:class School(models.Model):
115:class Student(models.Model):
            'be a "Parent" instance.'
        )
        with self.assertRaisesMessage(ValueError, msg):
            setattr(c, "parent", First(id=1, second=1))

        # You can assign None to Child.parent during object creation.
        Child(name='xyzzy', parent=None)

        # But when trying to save a Child with parent=None, the database will
        # raise IntegrityError.
        with self.assertRaises(IntegrityError), transaction.atomic():
            Child.objects.create(name='xyzzy', parent=None)

        # Creation using keyword argument should cache the related object.
        p = Parent.objects.get(name="Parent")
        c = Child(parent=p)
        self.assertIs(c.parent, p)

        # Creation using keyword argument and unsaved related instance (#8070).
        p = Parent()
        msg = "save() prohibited to prevent data loss due to unsaved related object 'parent'."
        with self.assertRaisesMessage(ValueError, msg):
            Child.objects.create(parent=p)

        msg = "save() prohibited to prevent data loss due to unsaved related object 'parent'."
        with self.assertRaisesMessage(ValueError, msg):
            ToFieldChild.objects.create(parent=p)

        # Creation using attname keyword argument and an id will cause the
        # related object to be fetched.
        p = Parent.objects.get(name="Parent")
        c = Child(parent_id=p.id)
        self.assertIsNot(c.parent, p)
        self.assertEqual(c.parent, p)

    def test_save_nullable_fk_after_parent(self):
        parent = Parent()
        child = ChildNullableParent(parent=parent)
        parent.save()
        child.save()
        child.refresh_from_db()
```

**assistant → tool `bash`**

```json
{
  "command": "git diff; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo DONE"
}
```

**tool result**

```
diff --git a/django/db/models/base.py b/django/db/models/base.py
index 2428218696..fd8e0806b1 100755
--- a/django/db/models/base.py
+++ b/django/db/models/base.py
@@ -933,7 +933,7 @@ class Model(metaclass=ModelBase):
                         "%s() prohibited to prevent data loss due to unsaved "
                         "related object '%s'." % (operation_name, field.name)
                     )
-                elif getattr(self, field.attname) is None:
+                elif getattr(self, field.attname) in field.empty_values:
                     # Use pk from related object if it has been saved after
                     # an assignment.
                     setattr(self, field.attname, obj.pk)
DONE
```

**assistant**

```
Fixed the data-loss bug in `Model._prepare_related_fields_for_save()` (`django/db/models/base.py`).

Previously it only copied the related object's primary key into the foreign-key attname when the local value was `None`. For non-auto `CharField` primary keys, the unsaved related instance contributes an empty string (`""`) instead, so the check missed it and the FK was saved as `""`.

The check now uses `field.empty_values` (which includes `None`, `""`, and empty containers), ensuring the related object's newly assigned PK is propagated before save.

Verified with the `many_to_one`, `one_to_one`, and `bulk_create` test suites — all 101 tests pass. The required `git status` command exits 0.
```

## Run folder `single-2026-11-06T110452`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Saving parent object after setting on child leads to data loss for parents with non-numeric primary key.
Description
	 
		(last modified by Charlie DeTar)
	 
Given a model with a foreign key relation to another model that has a non-auto CharField as its primary key:
class Product(models.Model):
	sku = models.CharField(primary_key=True, max_length=50)
class Order(models.Model):
	product = models.ForeignKey(Product, on_delete=models.CASCADE)
If the relation is initialized on the parent with an empty instance that does not yet specify its primary key, and the primary key is subsequently defined, the parent does not "see" the primary key's change:
with transaction.atomic():
	order = Order()
	order.product = Product()
	order.product.sku = "foo"
	order.product.save()
	order.save()
	assert Order.objects.filter(product_id="").exists() # Succeeds, but shouldn't
	assert Order.objects.filter(product=order.product).exists() # Fails
Instead of product_id being populated with product.sku, it is set to emptystring. The foreign key constraint which would enforce the existence of a product with sku="" is deferred until the transaction commits. The transaction does correctly fail on commit with a ForeignKeyViolation due to the non-existence of a product with emptystring as its primary key.
On the other hand, if the related unsaved instance is initialized with its primary key before assignment to the parent, it is persisted correctly:
with transaction.atomic():
	order = Order()
	order.product = Product(sku="foo")
	order.product.save()
	order.save()
	assert Order.objects.filter(product=order.product).exists() # succeeds
Committing the transaction also succeeds.
This may have something to do with how the Order.product_id field is handled at assignment, together with something about handling fetching of auto vs non-auto primary keys from the related instance.
```
