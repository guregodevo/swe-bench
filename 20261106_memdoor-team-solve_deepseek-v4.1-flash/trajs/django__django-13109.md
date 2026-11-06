# django__django-13109 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 68s 13 lines cost=0.004272 in=189332 cached=132608 out=6235 calls=21`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

ForeignKey.validate() should validate using the base manager.
Description
	
ForeignKey.validate() should validate using the base manager instead of the default manager.
Consider the models:
class ArticleManager(models.Manage):
	def get_queryset(self):
		qs = super().get_queryset()
		return qs.filter(archived=False)
class Article(models.Model):
	title = models.CharField(max_length=100)
	archived = models.BooleanField(default=False)
	# Don't include archived articles by default.
	objects = ArticleManager()
class FavoriteAricles(models.Model):
	article = models.ForeignKey(Article, on_delete=models.CASCADE)
In the example, now consider a form that allows users to pick a favorite article including archived articles.
class FavoriteAriclesForm(forms.ModelForm):
	class Meta:
		model = FavoriteArticle
		fields = '__all__'
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		# Use the base manager instead of the default manager to allow archived articles.
		self.fields['article'].queryset = Article._base_manager.all()
The above form will never validate as True when a user selects an archived article. This is because the ForeignKey validation always uses _default_manager instead of _base_manager. The user facing error message is "article instance with id 123 does not exist." (quite confusing to typical users). The code for this validation is here:
​https://github.com/django/django/blob/94f63b926fd32d7a7b6e2591ef72aa8f040f25cc/django/db/models/fields/related.py#L917-L919
The FavoriteAriclesForm is specifically designed to use a different manager, but the ForeignKey validation makes this difficult.
In this example scenario, it is not acceptable to change the model's default manager as the default should avoid archived articles in other typical scenarios.
Suggested solution: the ForeignKey validation should use the _base_manager instead which does not include the default filters.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --short && git log -1 --oneline"
}
```

**assistant → tool `locate`**

```json
{
  "query": "ForeignKey.validate uses _default_manager to check existence"
}
```

**tool result**

```
/testbed
?? .memdoor/
c5005f4eaa SWE-bench
```

**tool result**

```
Where "ForeignKey.validate uses _default_manager to check existence" lives (judged: 5 of 40 sections kept), most relevant first:
1. docs/topics/db/managers.txt:179-215  p=0.54
2. tests/multiple_database/tests.py:573-604  p=0.53
3. django/core/serializers/base.py:301-322  p=0.52
4. django/core/serializers/xml_serializer.py:250-283  p=0.51
5. tests/admin_widgets/models.py:54-65  p=0.51

== docs/topics/db/managers.txt:179-215 (p=0.54)
  179  If you use custom ``Manager`` objects, take note that the first ``Manager``
  180  Django encounters (in the order in which they're defined in the model) has a
  181  special status. Django interprets the first ``Manager`` defined in a class as
  182  the "default" ``Manager``, and several parts of Django (including
  183  :djadmin:`dumpdata`) will use that ``Manager`` exclusively for that model. As a
  184  result, it's a good idea to be careful in your choice of default manager in
  185  order to avoid a situation where overriding ``get_queryset()`` results in an
  186  inability to retrieve objects you'd like to work with.
  187  
  188  You can specify a custom default manager using :attr:`Meta.default_manager_name
  189  <django.db.models.Options.default_manager_name>`.
  190  
  191  If you're writing some code that must handle an unknown model, for example, in
  192  a third-party app that implements a generic view, use this manager (or
  193  :attr:`~Model._base_manager`) rather than assuming the model has an ``objects``
  194  manager.
  195  
  196  Base managers
  197  -------------
  198  
  199  .. attribute:: Model._base_manager
  200  
  201  .. _managers-for-related-objects:
  202  
  203  Using managers for related object access
  204  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  205  
  206  By default, Django uses an instance of the ``Model._base_manager`` manager
  207  class when accessing related objects (i.e. ``choice.question``), not the
  208  ``_default_manager`` on the related object. This is because Django needs to be
  209  able to retrieve the related object, even if it would otherwise be filtered out
  210  (and hence be inaccessible) by the default manager.
  211  
  212  If the normal base manager class (:class:`django.db.models.Manager`) isn't
  213  appropriate for your circumstances, you can tell Django which class to use by
  214  setting :attr:`Meta.base_manager_name
  215  <django.db.models.Options.base_manager_name>`.

== tests/multiple_database/tests.py:573-604 (p=0.53)
  573          # Add to a foreign key set with an object from a different database
  574          with self.assertRaisesMessage(ValueError, msg):
  575              with transaction.atomic(using='default'):
  576                  marty.edited.add(dive)
  577  
  578      def test_foreign_key_deletion(self):
  579          "Cascaded deletions of Foreign Key relations issue queries on the right database"
  580          mark = Person.objects.using('other').create(name="Mark Pilgrim")
  581          Pet.objects.using('other').create(name="Fido", owner=mark)
  582  
  583          # Check the initial state
  584          self.assertEqual(Person.objects.using('default').count(), 0)
  585          self.assertEqual(Pet.objects.using('default').count(), 0)
  586  
  587          self.assertEqual(Person.objects.using('other').count(), 1)
  588          self.assertEqual(Pet.objects.using('other').count(), 1)
  589  
  590          # Delete the person object, which will cascade onto the pet
  591          mark.delete(using='other')
  592  
  593          self.assertEqual(Person.objects.using('default').count(), 0)
  594          self.assertEqual(Pet.objects.using('default').count(), 0)
  595  
  596          # Both the pet and the person have been deleted from the right database
  597          self.assertEqual(Person.objects.using('other').count(), 0)
  598          self.assertEqual(Pet.objects.using('other').count(), 0)
  599  
  600      def test_foreign_key_validation(self):
  601          "ForeignKey.validate() uses the correct database"
  602          mickey = Person.objects.using('other').create(name="Mickey")
  603          pluto = Pet.objects.using('other').create(name="Pluto", owner=mickey)
  604          self.assertIsNone(pluto.full_clean())

== django/core/serializers/base.py:301-322 (p=0.52)
  301  def deserialize_fk_value(field, field_value, using, handle_forward_references):
  302      if field_value is None:
  303          return None
  304      model = field.remote_field.model
  305      default_manager = model._default_manager
  306      field_name = field.remote_field.field_name
  307      if (hasattr(default_manager, 'get_by_natural_key') and
  308              hasattr(field_value, '__iter__') and not isinstance(field_value, str)):
  309          try:
  310              obj = default_manager.db_manager(using).get_by_natural_key(*field_value)
  311          except ObjectDoesNotExist:
  312              if handle_forward_references:
  313                  return DEFER_FIELD
  314              else:
  315                  raise
  316          value = getattr(obj, field_name)
  317          # If this is a natural foreign key to an object that has a FK/O2O as
  318          # the foreign key, use the FK value.
  319          if model._meta.pk.remote_field:
  320              value = value.pk
  321          return value
  322      return model._meta.get_field(field_name).to_python(field_value)

read_file or jread a file to see more; locate again with file set to rank one file's sections.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"_default_manager\\|def validate\" django/db/models/fields/related.py | head -50"
}
```

**tool result**

```
909:    def validate(self, value, model_instance):
917:        qs = self.remote_field.model._default_manager.using(using).filter(
987:            'queryset': self.remote_field.model._default_manager.using(using),
1671:            'queryset': self.remote_field.model._default_manager.using(using),
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/fields/related.py",
  "offset": 895,
  "limit": 45
}
```

**tool result**

```
    def get_reverse_path_info(self, filtered_relation=None):
        """Get path from the related model to this field's model."""
        opts = self.model._meta
        from_opts = self.remote_field.model._meta
        return [PathInfo(
            from_opts=from_opts,
            to_opts=opts,
            target_fields=(opts.pk,),
            join_field=self.remote_field,
            m2m=not self.unique,
            direct=False,
            filtered_relation=filtered_relation,
        )]

    def validate(self, value, model_instance):
        if self.remote_field.parent_link:
            return
        super().validate(value, model_instance)
        if value is None:
            return

        using = router.db_for_read(self.remote_field.model, instance=model_instance)
        qs = self.remote_field.model._default_manager.using(using).filter(
            **{self.remote_field.field_name: value}
        )
        qs = qs.complex_filter(self.get_limit_choices_to())
        if not qs.exists():
            raise exceptions.ValidationError(
                self.error_messages['invalid'],
                code='invalid',
                params={
                    'model': self.remote_field.model._meta.verbose_name, 'pk': value,
                    'field': self.remote_field.field_name, 'value': value,
                },  # 'pk' is included for backwards compatibility
            )

    def resolve_related_fields(self):
        related_fields = super().resolve_related_fields()
        for from_field, to_field in related_fields:
            if to_field and to_field.model != self.remote_field.model._meta.concrete_model:
                raise exceptions.FieldError(
                    "'%s.%s' refers to field '%s' which is not local to model "
                    "'%s'." % (
                        self.model._meta.label,
                        self.name,

[753 more lines in /testbed/django/db/models/fields/related.py (1692 in all). read_file with offset: 940 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"base_manager\\|default_manager\\|validate\" tests/model_fields/tests.py | head -50; grep -rn \"does not exist\\|_base_manager\" tests/foreign_object tests/model_forms tests/model_fields 2>/dev/null | head -30"
}
```

**tool result**

```
132:        self.no_choices.validate(0, model_instance)
135:            self.empty_choices.validate(99, model_instance)
137:            self.with_choices.validate(99, model_instance)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rln \"invalid.*does not exist\\|full_clean.*ForeignKey\\|test_foreign_key_validation\\|test_validate\" tests/model_fields tests/invalid_models_tests tests/forms_tests tests/model_forms | head -30"
}
```

**tool result**

```
tests/forms_tests/tests/test_formsets.py
tests/model_forms/tests.py
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/db/models/fields/related.py\n@@\n-        qs = self.remote_field.model._default_manager.using(using).filter(\n+        qs = self.remote_field.model._base_manager.using(using).filter(\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/db/models/fields/related.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/db/models/fields/related.py now (1692 lines), around the change:
914:            return
915:
916:        using = router.db_for_read(self.remote_field.model, instance=model_instance)
917:        qs = self.remote_field.model._base_manager.using(using).filter(
918:            **{self.remote_field.field_name: value}
919:        )
920:        qs = qs.complex_filter(self.get_limit_choices_to())
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"class .*Tests\\|def test_.*manager\\|_default_manager\" tests/model_fields/tests.py | head -60"
}
```

**tool result**

```
20:class BasicFieldTests(SimpleTestCase):
106:class ChoicesTests(SimpleTestCase):
151:class GetFieldDisplayTests(SimpleTestCase):
213:class GetChoicesTests(SimpleTestCase):
244:class GetChoicesOrderingTests(TestCase):
294:class GetChoicesLimitChoicesToTests(TestCase):
```

**assistant → tool `bash`**

```json
{
  "command": "ls tests/model_fields/; grep -rn \"default_manager\\|base_manager\\|full_clean\\|validate\" tests/model_fields/test_foreignkey.py | head -50"
}
```

**tool result**

```
4x8.png
8x4.png
__init__.py
models.py
test_autofield.py
test_binaryfield.py
test_booleanfield.py
test_charfield.py
test_datetimefield.py
test_decimalfield.py
test_durationfield.py
test_field_flags.py
test_filefield.py
test_filepathfield.py
test_floatfield.py
test_foreignkey.py
test_genericipaddressfield.py
test_imagefield.py
test_integerfield.py
test_jsonfield.py
test_manytomanyfield.py
test_promises.py
test_slugfield.py
test_textfield.py
test_uuid.py
tests.py
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,80p' tests/model_fields/test_foreignkey.py; grep -n \"class\\|def test\" tests/model_fields/test_foreignkey.py | tail -60"
}
```

**tool result**

```
from decimal import Decimal

from django.apps import apps
from django.core import checks
from django.core.exceptions import FieldError
from django.db import models
from django.test import TestCase, skipIfDBFeature
from django.test.utils import isolate_apps

from .models import Bar, FkToChar, Foo, PrimaryKeyCharModel


class ForeignKeyTests(TestCase):

    def test_callable_default(self):
        """A lazy callable may be used for ForeignKey.default."""
        a = Foo.objects.create(id=1, a='abc', d=Decimal('12.34'))
        b = Bar.objects.create(b='bcd')
        self.assertEqual(b.a, a)

    @skipIfDBFeature('interprets_empty_strings_as_nulls')
    def test_empty_string_fk(self):
        """
        Empty strings foreign key values don't get converted to None (#19299).
        """
        char_model_empty = PrimaryKeyCharModel.objects.create(string='')
        fk_model_empty = FkToChar.objects.create(out=char_model_empty)
        fk_model_empty = FkToChar.objects.select_related('out').get(id=fk_model_empty.pk)
        self.assertEqual(fk_model_empty.out, char_model_empty)

    @isolate_apps('model_fields')
    def test_warning_when_unique_true_on_fk(self):
        class Foo(models.Model):
            pass

        class FKUniqueTrue(models.Model):
            fk_field = models.ForeignKey(Foo, models.CASCADE, unique=True)

        model = FKUniqueTrue()
        expected_warnings = [
            checks.Warning(
                'Setting unique=True on a ForeignKey has the same effect as using a OneToOneField.',
                hint='ForeignKey(unique=True) is usually better served by a OneToOneField.',
                obj=FKUniqueTrue.fk_field.field,
                id='fields.W342',
            )
        ]
        warnings = model.check()
        self.assertEqual(warnings, expected_warnings)

    def test_related_name_converted_to_text(self):
        rel_name = Bar._meta.get_field('a').remote_field.related_name
        self.assertIsInstance(rel_name, str)

    def test_abstract_model_pending_operations(self):
        """
        Foreign key fields declared on abstract models should not add lazy
        relations to resolve relationship declared as string (#24215).
        """
        pending_ops_before = list(apps._pending_operations.items())

        class AbstractForeignKeyModel(models.Model):
            fk = models.ForeignKey('missing.FK', models.CASCADE)

            class Meta:
                abstract = True

        self.assertIs(AbstractForeignKeyModel._meta.apps, apps)
        self.assertEqual(
            pending_ops_before,
            list(apps._pending_operations.items()),
            'Pending lookup added for a foreign key on an abstract model'
        )

    @isolate_apps('model_fields', 'model_fields.tests')
    def test_abstract_model_app_relative_foreign_key(self):
        class AbstractReferent(models.Model):
            reference = models.ForeignKey('Referred', on_delete=models.CASCADE)

            class Meta:
13:class ForeignKeyTests(TestCase):
15:    def test_callable_default(self):
22:    def test_empty_string_fk(self):
32:    def test_warning_when_unique_true_on_fk(self):
33:        class Foo(models.Model):
36:        class FKUniqueTrue(models.Model):
51:    def test_related_name_converted_to_text(self):
55:    def test_abstract_model_pending_operations(self):
62:        class AbstractForeignKeyModel(models.Model):
65:            class Meta:
76:    def test_abstract_model_app_relative_foreign_key(self):
77:        class AbstractReferent(models.Model):
80:            class Meta:
85:            class Referred(models.Model):
86:                class Meta:
89:            class ConcreteReferent(AbstractReferent):
90:                class Meta:
99:    def test_to_python(self):
100:        class Foo(models.Model):
103:        class Bar(models.Model):
109:    def test_fk_to_fk_get_col_output_field(self):
110:        class Foo(models.Model):
113:        class Bar(models.Model):
116:        class Baz(models.Model):
123:    def test_recursive_fks_get_col(self):
124:        class Foo(models.Model):
127:        class Bar(models.Model):
134:    def test_non_local_to_field(self):
135:        class Parent(models.Model):
138:        class Child(Parent):
141:        class Related(models.Model):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"base_manager\" tests/model_fields tests/model_forms tests/forms_tests | head -20; grep -rn \"schema_editor.create_model\" tests/model_fields tests/model_forms | head"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '80,260p' tests/model_fields/test_foreignkey.py"
}
```

**tool result**

```
            class Meta:
                app_label = 'model_fields'
                abstract = True

        def assert_app_model_resolved(label):
            class Referred(models.Model):
                class Meta:
                    app_label = label

            class ConcreteReferent(AbstractReferent):
                class Meta:
                    app_label = label

            self.assertEqual(ConcreteReferent._meta.get_field('reference').related_model, Referred)

        assert_app_model_resolved('model_fields')
        assert_app_model_resolved('tests')

    @isolate_apps('model_fields')
    def test_to_python(self):
        class Foo(models.Model):
            pass

        class Bar(models.Model):
            fk = models.ForeignKey(Foo, models.CASCADE)

        self.assertEqual(Bar._meta.get_field('fk').to_python('1'), 1)

    @isolate_apps('model_fields')
    def test_fk_to_fk_get_col_output_field(self):
        class Foo(models.Model):
            pass

        class Bar(models.Model):
            foo = models.ForeignKey(Foo, models.CASCADE, primary_key=True)

        class Baz(models.Model):
            bar = models.ForeignKey(Bar, models.CASCADE, primary_key=True)

        col = Baz._meta.get_field('bar').get_col('alias')
        self.assertIs(col.output_field, Foo._meta.pk)

    @isolate_apps('model_fields')
    def test_recursive_fks_get_col(self):
        class Foo(models.Model):
            bar = models.ForeignKey('Bar', models.CASCADE, primary_key=True)

        class Bar(models.Model):
            foo = models.ForeignKey(Foo, models.CASCADE, primary_key=True)

        with self.assertRaisesMessage(ValueError, 'Cannot resolve output_field'):
            Foo._meta.get_field('bar').get_col('alias')

    @isolate_apps('model_fields')
    def test_non_local_to_field(self):
        class Parent(models.Model):
            key = models.IntegerField(unique=True)

        class Child(Parent):
            pass

        class Related(models.Model):
            child = models.ForeignKey(Child, on_delete=models.CASCADE, to_field='key')

        msg = (
            "'model_fields.Related.child' refers to field 'key' which is not "
            "local to model 'model_fields.Child'."
        )
        with self.assertRaisesMessage(FieldError, msg):
            Related._meta.get_field('child').related_fields
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"schema_editor\" tests/model_fields tests/model_forms | head -20"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"with connection.schema_editor() as editor\" tests/model_fields tests/model_forms tests/foreign_object | head -20"
}
```

**tool result**

```


(you have run bash 3 times this turn and got THIS EXACT result every time, with different commands. The answer is not going to change — stop verifying it and do the next real step)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Manager\\|_base_manager\\|_default_manager\" tests/model_forms/models.py tests/model_fields/models.py | head -30"
}
```

**tool result**

```


(you have run bash 4 times this turn and got THIS EXACT result every time, with different commands. The answer is not going to change — stop verifying it and do the next real step)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rln \"schema_editor.create_model\" tests | head -5"
}
```

**tool result**

```


(you have run bash 5 times this turn and got THIS EXACT result every time, with different commands. The answer is not going to change — stop verifying it and do the next real step)
```

**user**

```
⚠ The same tool call keeps failing the same way. Do not repeat it. Change your approach, or tell the person what is blocking you and end your turn.
```

**assistant → tool `grep`**

```json
{
  "pattern": "base_manager",
  "path": "tests/model_fields",
  "output_mode": "content",
  "head_limit": 20
}
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/model_fields/models.py"
}
```

**tool result**

```

```

**tool result**

```
import json
import os
import tempfile
import uuid

from django.contrib.contenttypes.fields import (
    GenericForeignKey, GenericRelation,
)
from django.contrib.contenttypes.models import ContentType
from django.core.files.storage import FileSystemStorage
from django.core.serializers.json import DjangoJSONEncoder
from django.db import models
from django.db.models.fields.files import ImageFieldFile
from django.utils.translation import gettext_lazy as _

try:
    from PIL import Image
except ImportError:
    Image = None


class Foo(models.Model):
    a = models.CharField(max_length=10)
    d = models.DecimalField(max_digits=5, decimal_places=3)


def get_foo():
    return Foo.objects.get(id=1).pk


class Bar(models.Model):
    b = models.CharField(max_length=10)
    a = models.ForeignKey(Foo, models.CASCADE, default=get_foo, related_name='bars')


class Whiz(models.Model):
    CHOICES = (
        ('Group 1', (
            (1, 'First'),
            (2, 'Second'),
        )
        ),
        ('Group 2', (
            (3, 'Third'),
            (4, 'Fourth'),
        )
        ),
        (0, 'Other'),
        (5, _('translated')),
    )
    c = models.IntegerField(choices=CHOICES, null=True)


class WhizDelayed(models.Model):
    c = models.IntegerField(choices=(), null=True)


# Contrived way of adding choices later.
WhizDelayed._meta.get_field('c').choices = Whiz.CHOICES


class WhizIter(models.Model):
    c = models.IntegerField(choices=iter(Whiz.CHOICES), null=True)


class WhizIterEmpty(models.Model):
    c = models.CharField(choices=iter(()), blank=True, max_length=1)


class Choiceful(models.Model):
    no_choices = models.IntegerField(null=True)
    empty_choices = models.IntegerField(choices=(), null=True)
    with_choices = models.IntegerField(choices=[(1, 'A')], null=True)
    empty_choices_bool = models.BooleanField(choices=())
    empty_choices_text = models.TextField(choices=())


class BigD(models.Model):
    d = models.DecimalField(max_digits=32, decimal_places=30)


class FloatModel(models.Model):
    size = models.FloatField()


class BigS(models.Model):
    s = models.SlugField(max_length=255)


class UnicodeSlugField(models.Model):
    s = models.SlugField(max_length=255, allow_unicode=True)


class AutoModel(models.Model):
    value = models.AutoField(primary_key=True)


class BigAutoModel(models.Model):
    value = models.BigAutoField(primary_key=True)


class SmallAutoModel(models.Model):
    value = models.SmallAutoField(primary_key=True)


class SmallIntegerModel(models.Model):
    value = models.SmallIntegerField()


class IntegerModel(models.Model):
    value = models.IntegerField()


class BigIntegerModel(models.Model):
    value = models.BigIntegerField()
    null_value = models.BigIntegerField(null=True, blank=True)


class PositiveBigIntegerModel(models.Model):
    value = models.PositiveBigIntegerField()


class PositiveSmallIntegerModel(models.Model):
    value = models.PositiveSmallIntegerField()


class PositiveIntegerModel(models.Model):
    value = models.PositiveIntegerField()


class Post(models.Model):
    title = models.CharField(max_length=100)
    body = models.TextField()


class NullBooleanModel(models.Model):
    nbfield = models.BooleanField(null=True, blank=True)
    nbfield_old = models.NullBooleanField()


class BooleanModel(models.Model):
    bfield = models.BooleanField()
    string = models.CharField(max_length=10, default='abc')


class DateTimeModel(models.Model):
    d = models.DateField()
    dt = models.DateTimeField()
    t = models.TimeField()


class DurationModel(models.Model):
    field = models.DurationField()


class NullDurationModel(models.Model):
    field = models.DurationField(null=True)


class PrimaryKeyCharModel(models.Model):
    string = models.CharField(max_length=10, primary_key=True)


class FksToBooleans(models.Model):
    """Model with FKs to models with {Null,}BooleanField's, #15040"""
    bf = models.ForeignKey(BooleanModel, models.CASCADE)
    nbf = models.ForeignKey(NullBooleanModel, models.CASCADE)


class FkToChar(models.Model):
    """Model with FK to a model with a CharField primary key, #19299"""
    out = models.ForeignKey(PrimaryKeyCharModel, models.CASCADE)


class RenamedField(models.Model):
    modelname = models.IntegerField(name="fieldname", choices=((1, 'One'),))


class VerboseNameField(models.Model):
    id = models.AutoField("verbose pk", primary_key=True)
    field1 = models.BigIntegerField("verbose field1")
    field2 = models.BooleanField("verbose field2", default=False)
    field3 = models.CharField("verbose field3", max_length=10)
    field4 = models.DateField("verbose field4")
    field5 = models.DateTimeField("verbose field5")
    field6 = models.DecimalField("verbose field6", max_digits=6, decimal_places=1)
    field7 = models.EmailField("verbose field7")
    field8 = models.FileField("verbose field8", upload_to="unused")
    field9 = models.FilePathField("verbose field9")
    field10 = models.FloatField("verbose field10")
    # Don't want to depend on Pillow in this test
    # field_image = models.ImageField("verbose field")
    field11 = models.IntegerField("verbose field11")
    field12 = models.GenericIPAddressField("verbose field12", protocol="ipv4")
    field13 = models.NullBooleanField("verbose field13")
    field14 = models.PositiveIntegerField("verbose field14")
    field15 = models.PositiveSmallIntegerField("verbose field15")
    field16 = models.SlugField("verbose field16")
    field17 = models.SmallIntegerField("verbose field17")
    field18 = models.TextField("verbose field18")
    field19 = models.TimeField("verbose field19")
    field20 = models.URLField("verbose field20")
    field21 = models.UUIDField("verbose field21")
    field22 = models.DurationField("verbose field22")


class GenericIPAddress(models.Model):
    ip = models.GenericIPAddressField(null=True, protocol='ipv4')


###############################################################################
# These models aren't used in any test, just here to ensure they validate
# successfully.

# See ticket #16570.
class DecimalLessThanOne(models.Model):
    d = models.DecimalField(max_digits=3, decimal_places=3)


# See ticket #18389.
class FieldClassAttributeModel(models.Model):
    field_class = models.CharField

###############################################################################


class DataModel(models.Model):
    short_data = models.BinaryField(max_length=10, default=b'\x08')
    data = models.BinaryField()

###############################################################################
# FileField


class Document(models.Model):
    myfile = models.FileField(upload_to='unused', unique=True)


###############################################################################
# ImageField

# If Pillow available, do these tests.
if Image:
    class TestImageFieldFile(ImageFieldFile):
        """
        Custom Field File class that records whether or not the underlying file
        was opened.
        """
        def __init__(self, *args, **kwargs):
            self.was_opened = False
            super().__init__(*args, **kwargs)

        def open(self):
            self.was_opened = True
            super().open()

    class TestImageField(models.ImageField):
        attr_class = TestImageFieldFile

    # Set up a temp directory for file storage.
    temp_storage_dir = tempfile.mkdtemp()
    temp_storage = FileSystemStorage(temp_storage_dir)
    temp_upload_to_dir = os.path.join(temp_storage.location, 'tests')

    class Person(models.Model):
        """
        Model that defines an ImageField with no dimension fields.
        """
        name = models.CharField(max_length=50)
        mugshot = TestImageField(storage=temp_storage, upload_to='tests')

    class AbstractPersonWithHeight(models.Model):
        """
        Abstract model that defines an ImageField with only one dimension field
        to make sure the dimension update is correctly run on concrete subclass
        instance post-initialization.
        """
        mugshot = TestImageField(storage=temp_storage, upload_to='tests',
                                 height_field='mugshot_height')
        mugshot_height = models.PositiveSmallIntegerField()

        class Meta:
            abstract = True

    class PersonWithHeight(AbstractPersonWithHeight):
        """
        Concrete model that subclass an abstract one with only on dimension
        field.
        """
        name = models.CharField(max_length=50)

    class PersonWithHeightAndWidth(models.Model):
        """
        Model that defines height and width fields after the ImageField.
        """
        name = models.CharField(max_length=50)
        mugshot = TestImageField(storage=temp_storage, upload_to='tests',
                                 height_field='mugshot_height',
                                 width_field='mugshot_width')
        mugshot_height = models.PositiveSmallIntegerField()

[139 more lines in /testbed/tests/model_fields/models.py (439 in all). read_file with offset: 301 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"isolate_apps\" tests/model_fields/*.py | head; grep -rn \"schema_editor.create_model\" tests | head -10"
}
```

**tool result**

```
tests/model_fields/test_foreignkey.py:8:from django.test.utils import isolate_apps
tests/model_fields/test_foreignkey.py:31:    @isolate_apps('model_fields')
tests/model_fields/test_foreignkey.py:75:    @isolate_apps('model_fields', 'model_fields.tests')
tests/model_fields/test_foreignkey.py:98:    @isolate_apps('model_fields')
tests/model_fields/test_foreignkey.py:108:    @isolate_apps('model_fields')
tests/model_fields/test_foreignkey.py:122:    @isolate_apps('model_fields')
tests/model_fields/test_foreignkey.py:133:    @isolate_apps('model_fields')
tests/model_fields/test_manytomanyfield.py:4:from django.test.utils import isolate_apps
tests/model_fields/test_manytomanyfield.py:31:    @isolate_apps('model_fields', 'model_fields.tests')
```

**assistant → tool `grep`**

```json
{
  "pattern": "with connection\\.schema_editor\\(\\) as editor",
  "path": "tests",
  "output_mode": "files_with_matches",
  "head_limit": 10
}
```

**tool result**

```
/testbed/tests/auth_tests/test_migrations.py
/testbed/tests/backends/oracle/test_introspection.py
/testbed/tests/backends/test_utils.py
/testbed/tests/gis_tests/geoapp/test_indexes.py
/testbed/tests/gis_tests/gis_migrations/test_operations.py
/testbed/tests/indexes/tests.py
/testbed/tests/introspection/tests.py
/testbed/tests/migrations/test_base.py
/testbed/tests/migrations/test_executor.py
/testbed/tests/migrations/test_multidb.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"schema_editor.create_model\" tests/model_forms/tests.py tests/foreign_object/tests.py tests/many_to_one/tests.py 2>/dev/null | head"
}
```

## Run folder `team-solve-2026-11-06T105849`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
c5005f4eaa9c32b4008b1fdb70751ed2ad59343e
```

### `baseline-check.log`

```
check: python tests/runtests.py foreign_keys
E
======================================================================
ERROR: foreign_keys (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: foreign_keys
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'foreign_keys'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/django/db/models/fields/related.py b/django/db/models/fields/related.py
index d517d7269b..c2aea9c730 100644
--- a/django/db/models/fields/related.py
+++ b/django/db/models/fields/related.py
@@ -914,7 +914,7 @@ class ForeignKey(ForeignObject):
             return
 
         using = router.db_for_read(self.remote_field.model, instance=model_instance)
-        qs = self.remote_field.model._default_manager.using(using).filter(
+        qs = self.remote_field.model._base_manager.using(using).filter(
             **{self.remote_field.field_name: value}
         )
         qs = qs.complex_filter(self.get_limit_choices_to())
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

ForeignKey.validate() should validate using the base manager.
Description
	
ForeignKey.validate() should validate using the base manager instead of the default manager.
Consider the models:
class ArticleManager(models.Manage):
	def get_queryset(self):
		qs = super().get_queryset()
		return qs.filter(archived=False)
class Article(models.Model):
	title = models.CharField(max_length=100)
	archived = models.BooleanField(default=False)
	# Don't include archived articles by default.
	objects = ArticleManager()
class FavoriteAricles(models.Model):
	article = models.ForeignKey(Article, on_delete=models.CASCADE)
In the example, now consider a form that allows users to pick a favorite article including archived articles.
class FavoriteAriclesForm(forms.ModelForm):
	class Meta:
		model = FavoriteArticle
		fields = '__all__'
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		# Use the base manager instead of the default manager to allow archived articles.
		self.fields['article'].queryset = Article._base_manager.all()
The above form will never validate as True when a user selects an archived article. This is because the ForeignKey validation always uses _default_manager instead of _base_manager. The user facing error message is "article instance with id 123 does not exist." (quite confusing to typical users). The code for this validation is here:
​https://github.com/django/django/blob/94f63b926fd32d7a7b6e2591ef72aa8f040f25cc/django/db/models/fields/related.py#L917-L919
The FavoriteAriclesForm is specifically designed to use a different manager, but the ForeignKey validation makes this difficult.
In this example scenario, it is not acceptable to change the model's default manager as the default should avoid archived articles in other typical scenarios.
Suggested solution: the ForeignKey validation should use the _base_manager instead which does not include the default filters.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py foreign_keys`

## Scope

`django/db/models/fields/related.py`
`tests/foreign_keys/`

## Done when

- `ForeignKey.validate()` checks target existence through `_base_manager` instead of `_default_manager`, preserving `using(using)`.
- A form field whose queryset is `Article._base_manager.all()` validates an archived `Article` instead of raising “does not exist”.
- Existing missing-target validation still rejects IDs with no row in the target table.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py foreign_keys`

## Scope
`django/db/models/fields/related.py`
`tests/foreign_keys/`

## Done when
- `ForeignKey.validate()` checks target existence through `_base_manager` instead of `_default_manager`, preserving `using(using)`.
- A form field whose queryset is `Article._base_manager.all()` validates an archived `Article` instead of raising “does not exist”.
- Existing missing-target validation still rejects IDs with no row in the target table.

## Approach
Decompose into the validation path and its regression coverage: locate the existence query in `ForeignKey.validate()`, switch that query from `_default_manager` to `_base_manager`, and add tests under `tests/foreign_keys/` using a custom default manager that filters rows while the FK validation should still see them.

Candidate approaches:
- Minimal one-line manager swap in `ForeignKey.validate()`: narrowest fix, preserves the existing API and `using()` behavior; preferred.
- Add a manager/queryset parameter to validation or the form field: more flexible, but changes public API and is not requested.
- Keep `_default_manager` and special-case form querysets: does not fix validation generally and couples field validation to forms; reject.


# django/db/models/fields/related.py

```
import functools
import inspect
from functools import partial

from django import forms
from django.apps import apps
from django.conf import SettingsReference, settings
from django.core import checks, exceptions
from django.db import connection, router
from django.db.backends import utils
from django.db.models import Q
from django.db.models.constants import LOOKUP_SEP
from django.db.models.deletion import CASCADE, SET_DEFAULT, SET_NULL
from django.db.models.query_utils import PathInfo
from django.db.models.utils import make_model_tuple
from django.utils.functional import cached_property
from django.utils.translation import gettext_lazy as _

from . import Field
from .mixins import FieldCacheMixin
from .related_descriptors import (
    ForeignKeyDeferredAttribute, ForwardManyToOneDescriptor,
    ForwardOneToOneDescriptor, ManyToManyDescriptor,
    ReverseManyToOneDescriptor, ReverseOneToOneDescriptor,
)
from .related_lookups import (
    RelatedExact, RelatedGreaterThan, RelatedGreaterThanOrEqual, RelatedIn,
    RelatedIsNull, RelatedLessThan, RelatedLessThanOrEqual,
)
from .reverse_related import (
    ForeignObjectRel, ManyToManyRel, ManyToOneRel, OneToOneRel,
)

RECURSIVE_RELATIONSHIP_CONSTANT = 'self'


def resolve_relation(scope_model, relation):
    """
    Transform relation into a model or fully-qualified model string of the form
    "app_label.ModelName", relative to scope_model.

    The relation argument can be:
      * RECURSIVE_RELATIONSHIP_CONSTANT, i.e. the string "self", in which case
        the model argument will be returned.
      * A bare model name without an app_label, in which case scope_model's
        app_label will be prepended.
      * An "app_label.ModelName" string.
      * A model class, which will be returned unchanged.
    """
    # Check for recursive relations
    if relation == RECURSIVE_RELATIONSHIP_CONSTANT:
        relation = scope_model

    # Look for an "app.Model" relation
    if isinstance(relation, str):
        if "." not in relation:
            relation = "%s.%s" % (scope_model._meta.app_label, relation)

    return relation


def lazy_related_operation(function, model, *related_models, **kwargs):
    """
    Schedule `function` to be called once `model` and all `related_models`
    have been imported and registered with the app registry. `function` will
    be called with the newly-loaded model classes as its positional arguments,
    plus any optional keyword arguments.

    The `model` argument must be a model class. Each subsequent positional
    argument is another model, or a reference to another model - see
    `resolve_relation()` for the various forms these may take. Any relative
    references will be resolved relative to `model`.

    This is a convenience wrapper for `Apps.lazy_model_operation` - the app
    registry model used is the one found in `model._meta.apps`.
    """
    models = [model] + [resolve_relation(model, rel) for rel in related_models]
    model_keys = (make_model_tuple(m) for m in models)
    apps = model._meta.apps
    return apps.lazy_model_operation(partial(function, **kwargs), *model_keys)


class RelatedField(FieldCacheMixin, Field):
    """Base class that all relational fields inherit from."""

    # Field flags
    one_to_many = False
    one_to_one = False
    many_to_many = False
    many_to_one = False

    @cached_property
    def related_model(self):
        # Can't cache this property until all the models are loaded.
        apps.check_models_ready()
        return self.remote_field.model

    def check(self, **kwargs):
        return [
            *super().check(**kwargs),
            *self._check_related_name_is_valid(),
            *self._check_related_query_name_is_valid(),
            *self._check_relation_model_exists(),
            *self._check_referencing_to_swapped_model(),
            *self._check_clashes(),
        ]

    def _check_related_name_is_valid(self):
        import keyword
        related_name = self.remote_field.related_name
        if related_name is None:
            return []
        is_valid_id = not keyword.iskeyword(related_name) and related_name.isidentifier()
        if not (is_valid_id or related_name.endswith('+')):
            return [
                checks.Error(
                    "The name '%s' is invalid related_name for field %s.%s" %
                    (self.remote_field.related_name, self.model._meta.object_name,
                     self.name),
                    hint="Related name must be a valid Python identifier or end with a '+'",
                    obj=self,
                    id='fields.E306',
                )
            ]
        return []

    def _check_related_query_name_is_valid(self):
        if self.remote_field.is_hidden():
            return []
        rel_query_name = self.related_query_name()
        errors = []
        if rel_query_name.endswith('_'):
            errors.append(
                checks.Error(
                    "Reverse query name '%s' must not end with an underscore."
                    % rel_query_name,
                    hint=("Add or change a related_name or related_query_name "
                          "argument for this field."),
                    obj=self,
                    id='fields.E308',
                )
            )
        if LOOKUP_SEP in rel_query_name:
            errors.append(
                checks.Error(
                    "Reverse query name '%s' must not contain '%s'."
                    % (rel_query_name, LOOKUP_SEP),
                    hint=("Add or change a related_name or related_query_name "
                          "argument for this field."),
                    obj=self,
                    id='fields.E309',
                )
            )
        return errors

    def _check_relation_model_exists(self):
        rel_is_missing = self.remote_field.model not in self.opts.apps.get_models()
        rel_is_string = isinstance(self.remote_field.model, str)
        model_name = self.remote_field.model if rel_is_string else self.remote_field.model._meta.object_name
        if rel_is_missing and (rel_is_string or not self.remote_field.model._meta.swapped):
            return [
                checks.Error(
                    "Field defines a relation with model '%s', which is either "
                    "not installed, or is abstract." % model_name,
                    obj=self,
                    id='fields.E300',
                )
            ]
        return []

    def _check_referencing_to_swapped_model(self):
        if (self.remote_field.model not in self.opts.apps.get_models() and
                not isinstance(self.remote_field.model, str) and
                self.remote_field.model._meta.swapped):
            model = "%s.%s" % (
                self.remote_field.model._meta.app_label,
                self.remote_field.model._meta.object_name
            )
            return [
                checks.Error(
                    "Field defines a relation with the model '%s', which has "
                    "been swapped out." % model,
                    hint="Update the relation to point at 'settings.%s'." % self.remote_field.model._meta.swappable,
                    obj=self,
                    id='fields.E301',
                )
            ]
        return []

    def _check_clashes(self):
        """Check accessor and reverse query name clashes."""
        from django.db.models.base import ModelBase

        errors = []
        opts = self.model._meta

        # `f.remote_field.model` may be a string instead of a model. Skip if model name is
        # not resolved.
        if not isinstance(self.remote_field.model, ModelBase):
            return []

        # Consider that we are checking field `Model.foreign` and the models
        # are:
        #
        #     class Target(models.Model):
        #         model = models.IntegerField()
        #         model_set = models.IntegerField()
        #
        #     class Model(models.Model):
        #         foreign = models.ForeignKey(Target)
        #         m2m = models.ManyToManyField(Target)

        # rel_opts.object_name == "Target"
        rel_opts = self.remote_field.model._meta
        # If the field doesn't install a backward relation on the target model
        # (so `is_hidden` returns True), then there are no clashes to check
        # and we can skip these fields.
        rel_is_hidden = self.remote_field.is_hidden()
        rel_name = self.remote_field.get_accessor_name()  # i. e. "model_set"
        rel_query_name = self.related_query_name()  # i. e. "model"
        field_name = "%s.%s" % (opts.object_name, self.name)  # i. e. "Model.field"

        # Check clashes between accessor or reverse query name of `field`
        # and any other field name -- i.e. accessor for Model.foreign is
        # model_set and it clashes with Target.model_set.
        potential_clashes = rel_opts.fields + rel_opts.many_to_many
        for clash_field in potential_clashes:
            clash_name = "%s.%s" % (rel_opts.object_name, clash_field.name)  # i.e. "Target.model_set"
            if not rel_is_hidden and clash_field.name == rel_name:
                errors.append(
                    checks.Error(
                        "Reverse accessor for '%s' clashes with field name '%s'." % (field_name, clash_name),
                        hint=("Rename field '%s', or add/change a related_name "
                              "argument to the definition for field '%s'.") % (clash_name, field_name),
                        obj=self,
                        id='fields.E302',
                    )
                )

            if clash_field.name == rel_query_name:
                errors.append(
                    checks.Error(
                        "Reverse query name for '%s' clashes with field name '%s'." % (field_name, clash_name),
                        hint=("Rename field '%s', or add/change a related_name "
                              "argument to the definition for field '%s'.") % (clash_name, field_name),
                        obj=self,
                        id='fields.E303',
                    )
                )

        # Check clashes between accessors/reverse query names of `field` and
        # any other field accessor -- i. e. Model.foreign accessor clashes with
        # Model.m2m accessor.
        potential_clashes = (r for r in rel_opts.related_objects if r.field is not self)
        for clash_field in potential_clashes:
            clash_name = "%s.%s" % (  # i. e. "Model.m2m"
                clash_field.related_model._meta.object_name,
                clash_field.field.name)
            if not rel_is_hidden and clash_field.get_accessor_name() == rel_name:
                errors.append(
                    checks.Error(
                        "Reverse accessor for '%s' clashes with reverse accessor for '%s'." % (field_name, clash_name),
                        hint=("Add or change a related_name argument "
                              "to the definition for '%s' or '%s'.") % (field_name, clash_name),
                        obj=self,
                        id='fields.E304',
                    )
                )

            if clash_field.get_accessor_name() == rel_query_name:
                errors.append(
                    checks.Error(
                        "Reverse query name for '%s' clashes with reverse query name for '%s'."
                        % (field_name, clash_name),
                        hint=("Add or change a related_name argument "
                              "to the definition for '%s' or '%s'.") % (field_name, clash_name),
                        obj=self,
                        id='fields.E305',
                    )
                )

        return errors

    def db_type(self, connection):
        # By default related field will not have a column as it relates to
        # columns from another table.
        return None

    def contribute_to_class(self, cls, name, private_only=False, **kwargs):

        super().contribute_to_class(cls, name, private_only=private_only, **kwargs)

        self.opts = cls._meta

        if not cls._meta.abstract:
            if self.remote_field.related_name:
                related_name = self.remote_field.related_name
            else:
                related_name = self.opts.default_related_name
            if related_name:
                related_name = related_name % {
                    'class': cls.__name__.lower(),
                    'model_name': cls._meta.model_name.lower(),
                    'app_label': cls._meta.app_label.lower()
                }
                self.remote_field.related_name = related_name

            if self.remote_field.related_query_name:
                related_query_name = self.remote_field.related_query_name % {
                    'class': cls.__name__.lower(),
                    'app_label': cls._meta.app_label.lower(),
                }
                self.remote_field.related_query_name = related_query_name

            def resolve_related_class(model, related, field):
                field.remote_field.model = related
                field.do_related_class(related, model)
            lazy_related_operation(resolve_related_class, cls, self.remote_field.model, field=self)

    def deconstruct(self):
        name, path, args, kwargs = super().deconstruct()
        if self.remote_field.limit_choices_to:
            kwargs['limit_choices_to'] = self.remote_field.limit_choices_to
        if self.remote_field.related_name is not None:
            kwargs['related_name'] = self.remote_field.related_name
        if self.remote_field.related_query_name is not None:
            kwargs['related_query_name'] = self.remote_field.related_query_name
        return name, path, args, kwargs

    def get_forward_related_filter(self, obj):
        """
        Return the keyword arguments that when supplied to
        self.model.object.filter(), would select all instances related through
        this field to the remote obj. This is used to build the querysets
        returned by related descriptors. obj is an instance of
        self.related_field.model.
        """
        return {
            '%s__%s' % (self.name, rh_field.name): getattr(obj, rh_field.attname)
            for _, rh_field in self.related_fields
        }

    def get_reverse_related_filter(self, obj):
        """
        Complement to get_forward_related_filter(). Return the keyword
        arguments that when passed to self.related_field.model.object.filter()
        select all instances of self.related_field.model related through
        this field to obj. obj is an instance of self.model.
        """
        base_filter = {
            rh_field.attname: getattr(obj, lh_field.attname)
            for lh_field, rh_field in self.related_fields
        }
        descriptor_filter = self.get_extra_descriptor_filter(obj)
        base_q = Q(**base_filter)
        if isinstance(descriptor_filter, dict):
            return base_q & Q(**descriptor_filter)
        elif descriptor_filter:
            return base_q & descriptor_filter
        return base_q

    @property
    def swappable_setting(self):
        """
        Get the setting that this is powered from for swapping, or None
        if it's not swapped in / marked with swappable=False.
        """
        if self.swappable:
            # Work out string form of "to"
            if isinstance(self.remote_field.model, str):
                to_string = self.remote_field.model
            else:
                to_string = self.remote_field.model._meta.label
            return apps.get_swappable_settings_name(to_string)
        return None

    def set_attributes_from_rel(self):
        self.name = (
            self.name or
            (self.remote_field.model._meta.model_name + '_' + self.remote_field.model._meta.pk.name)
        )
        if self.verbose_name is None:
            self.verbose_name = self.remote_field.model._meta.verbose_name
        self.remote_field.set_field_name()

    def do_related_class(self, other, cls):
        self.set_attributes_from_rel()
        self.contribute_to_related_class(other, self.remote_field)

    def get_limit_choices_to(self):
        """
        Return ``limit_choices_to`` for this model field.

        If it is a callable, it will be invoked and the result will be
        returned.
        """
        if callable(self.remote_field.limit_choices_to):
            return self.remote_field.limit_choices_to()
        return self.remote_field.limit_choices_to

    def formfield(self, **kwargs):
        """
        Pass ``limit_choices_to`` to the field being constructed.

        Only passes it if there is a type that supports related fields.
        This is a similar strategy used to pass the ``queryset`` to the field
        being constructed.
        """
        defaults = {}
        if hasattr(self.remote_field, 'get_related_field'):
            # If this is a callable, do not invoke it here. Just pass
            # it in the defaults for when the form class will later be
            # instantiated.
            limit_choices_to = self.remote_field.limit_choices_to
            defaults.update({
                'limit_choices_to': limit_choices_to,
            })
        defaults.update(kwargs)
        return super().formfield(**defaults)

    def related_query_name(self):
        """
        Define the name that can be used to identify this related object in a
        table-spanning query.
        """
        return self.remote_field.related_query_name or self.remote_field.related_name or self.opts.model_name

    @property
    def target_field(self):
        """
        When filtering against this relation, return the field on the remote
        model against which the filtering should happen.
        """
        target_fields = self.get_path_info()[-1].target_fields
        if len(target_fields) > 1:
            raise exceptions.FieldError(
                "The relation has multiple target fields, but only single target field was asked for")
        return target_fields[0]

    def get_cache_name(self):
        return self.name


class ForeignObject(RelatedField):
    """
    Abstraction of the ForeignKey relation to support multi-column relations.
    """

    # Field flags
    many_to_many = False
    many_to_one = True
    one_to_many = False
    one_to_one = False

    requires_unique_target = True
    related_accessor_class = ReverseManyToOneDescriptor
    forward_related_accessor_class = ForwardManyToOneDescriptor
    rel_class = ForeignObjectRel

    def __init__(self, to, on_delete, from_fields, to_fields, rel=None, related_name=None,
                 related_query_name=None, limit_choices_to=None, parent_link=False,
                 swappable=True, **kwargs):

        if rel is None:
            rel = self.rel_class(
                self, to,
                related_name=related_name,
                related_query_name=related_query_name,
                limit_choices_to=limit_choices_to,
                parent_link=parent_link,
                on_delete=on_delete,
            )

        super().__init__(rel=rel, **kwargs)

        self.from_fields = from_fields
        self.to_fields = to_fields
        self.swappable = swappable

    def check(self, **kwargs):
        return [
            *super().check(**kwargs),
            *self._check_to_fields_exist(),
            *self._check_unique_target(),
        ]

    def _check_to_fields_exist(self):
        # Skip nonexistent models.
        if isinstance(self.remote_field.model, str):
            return []

        errors = []
        for to_field in self.to_fields:
            if to_field:
                try:
                    self.remote_field.model._meta.get_field(to_field)
                except exceptions.FieldDoesNotExist:
                    errors.append(
                        checks.Error(
                            "The to_field '%s' doesn't exist on the related "
                            "model '%s'."
                            % (to_field, self.remote_field.model._meta.label),
                            obj=self,
                            id='fields.E312',
                        )
                    )
        return errors

    def _check_unique_target(self):
        rel_is_string = isinstance(self.remote_field.model, str)
        if rel_is_string or not self.requires_unique_target:
            return []

        try:
            self.foreign_related_fields
        except exceptions.FieldDoesNotExist:
            return []

        if not self.foreign_related_fields:
            return []

        unique_foreign_fields = {
            frozenset([f.name])
            for f in self.remote_field.model._meta.get_fields()
            if getattr(f, 'unique', False)
        }
        unique_foreign_fields.update({
            frozenset(ut)
            for ut in self.remote_field.model._meta.unique_together
        })
        unique_foreign_fields.update({
            frozenset(uc.fields)
            for uc in self.remote_field.model._meta.total_unique_constraints
        })
        foreign_fields = {f.name for f in self.foreign_related_fields}
        has_unique_constraint = any(u <= foreign_fields for u in unique_foreign_fields)

        if not has_unique_constraint and len(self.foreign_related_fields) > 1:
            field_combination = ', '.join(
                "'%s'" % rel_field.name for rel_field in self.foreign_related_fields
            )
            model_name = self.remote_field.model.__name__
            return [
                checks.Error(
                    "No subset of the fields %s on model '%s' is unique."
                    % (field_combination, model_name),
                    hint=(
                        'Mark a single field as unique=True or add a set of '
                        'fields to a unique constraint (via unique_together '
                        'or a UniqueConstraint (without condition) in the '
                        'model Meta.constraints).'
                    ),
                    obj=self,
                    id='fields.E310',
                )
            ]
        elif not has_unique_constraint:
            field_name = self.foreign_related_fields[0].name
            model_name = self.remote_field.model.__name__
            return [
                checks.Error(
                    "'%s.%s' must be unique because it is referenced by "
                    "a foreign key." % (model_name, field_name),
                    hint=(
                        'Add unique=True to this field or add a '
                        'UniqueConstraint (without condition) in the model '
                        'Meta.constraints.'
                    ),
                    obj=self,
                    id='fields.E311',
                )
            ]
        else:
            return []

    def deconstruct(self):
        name, path, args, kwargs = super().deconstruct()
        kwargs['on_delete'] = self.remote_field.on_delete
        kwargs['from_fields'] = self.from_fields
        kwargs['to_fields'] = self.to_fields

        if self.remote_field.parent_link:
            kwargs['parent_link'] = self.remote_field.parent_link
        if isinstance(self.remote_field.model, str):
            kwargs['to'] = self.remote_field.model.lower()
        else:
            kwargs['to'] = self.remote_field.model._meta.label_lower
        # If swappable is True, then see if we're actually pointing to the target
        # of a swap.
        swappable_setting = self.swappable_setting
        if swappable_setting is not None:
            # If it's already a settings reference, error
            if hasattr(kwargs['to'], "setting_name"):
                if kwargs['to'].setting_name != swappable_setting:
                    raise ValueError(
                        "Cannot deconstruct a ForeignKey pointing to a model "
                        "that is swapped in place of more than one model (%s and %s)"
                        % (kwargs['to'].setting_name, swappable_setting)
                    )
            # Set it
            kwargs['to'] = SettingsReference(
                kwargs['to'],
                swappable_setting,
            )
        return name, path, args, kwargs

    def resolve_related_fields(self):
        if not self.from_fields or len(self.from_fields) != len(self.to_fields):
            raise ValueError('Foreign Object from and to fields must be the same non-zero length')
        if isinstance(self.remote_field.model, str):
            raise ValueError('Related model %r cannot be resolved' % self.remote_field.model)
        related_fields = []
        for index in range(len(self.from_fields)):
            from_field_name = self.from_fields[index]
            to_field_name = self.to_fields[index]
            from_field = (
                self
                if from_field_name == RECURSIVE_RELATIONSHIP_CONSTANT
                else self.opts.get_field(from_field_name)
            )
            to_field = (self.remote_field.model._meta.pk if to_field_name is None
                        else self.remote_field.model._meta.get_field(to_field_name))
            related_fields.append((from_field, to_field))
        return related_fields

    @cached_property
    def related_fields(self):
        return self.resolve_related_fields()

    @cached_property
    def reverse_related_fields(self):
        return [(rhs_field, lhs_field) for lhs_field, rhs_field in self.related_fields]

    @cached_property
    def local_related_fields(self):
        return tuple(lhs_field for lhs_field, rhs_field in self.related_fields)

    @cached_property
    def foreign_related_fields(self):
        return tuple(rhs_field for lhs_field, rhs_field in self.related_fields if rhs_field)

    def get_local_related_value(self, instance):
        return self.get_instance_value_for_fields(instance, self.local_related_fields)

    def get_foreign_related_value(self, instance):
        return self.get_instance_value_for_fields(instance, self.foreign_related_fields)

    @staticmethod
    def get_instance_value_for_fields(instance, fields):
        ret = []
        opts = instance._meta
        for field in fields:
            # Gotcha: in some cases (like fixture loading) a model can have
            # different values in parent_ptr_id and parent's id. So, use
            # instance.pk (that is, parent_ptr_id) when asked for instance.id.
            if field.primary_key:
                possible_parent_link = opts.get_ancestor_link(field.model)
                if (not possible_parent_link or
                        possible_parent_link.primary_key or
                        possible_parent_link.model._meta.abstract):
                    ret.append(instance.pk)
                    continue
            ret.append(getattr(instance, field.attname))
        return tuple(ret)

    def get_attname_column(self):
        attname, column = super().get_attname_column()
        return attname, None

    def get_joining_columns(self, reverse_join=False):
        source = self.reverse_related_fields if reverse_join else self.related_fields
        return tuple((lhs_field.column, rhs_field.column) for lhs_field, rhs_field in source)

    def get_reverse_joining_columns(self):
        return self.get_joining_columns(reverse_join=True)

    def get_extra_descriptor_filter(self, instance):
        """
        Return an extra filter condition for related object fetching when
        user does 'instance.fieldname', that is the extra filter is used in
        the descriptor of the field.

        The filter should be either a dict usable in .filter(**kwargs) call or
        a Q-object. The condition will be ANDed together with the relation's
        joining columns.

        A parallel method is get_extra_restriction() which is used in
        JOIN and subquery conditions.
        """
        return {}

    def get_extra_restriction(self, where_class, alias, related_alias):
        """
        Return a pair condition used for joining and subquery pushdown. The
        condition is something that responds to as_sql(compiler, connection)
        method.

        Note that currently referring both the 'alias' and 'related_alias'
        will not work in some conditions, like subquery pushdown.

        A parallel method is get_extra_descriptor_filter() which is used in
        instance.fieldname related object fetching.
        """
        return None

    def get_path_info(self, filtered_relation=None):
        """Get path from this field to the related model."""
        opts = self.remote_field.model._meta
        from_opts = self.model._meta
        return [PathInfo(
            from_opts=from_opts,
            to_opts=opts,
            target_fields=self.foreign_related_fields,
            join_field=self,
            m2m=False,
            direct=True,
            filtered_relation=filtered_relation,
        )]

    def get_reverse_path_info(self, filtered_relation=None):
        """Get path from the related model to this field's model."""
        opts = self.model._meta
        from_opts = self.remote_field.model._meta
        return [PathInfo(
            from_opts=from_opts,
            to_opts=opts,
            target_fields=(opts.pk,),
            join_field=self.remote_field,
            m2m=not self.unique,
            direct=False,
            filtered_relation=filtered_relation,
        )]

    @classmethod
    @functools.lru_cache(maxsize=None)
    def get_lookups(cls):
        bases = inspect.getmro(cls)
        bases = bases[:bases.index(ForeignObject) + 1]
        class_lookups = [parent.__dict__.get('class_lookups', {}) for parent in bases]
        return cls.merge_dicts(class_lookups)

    def contribute_to_class(self, cls, name, private_only=False, **kwargs):
        super().contribute_to_class(cls, name, private_only=private_only, **kwargs)
        setattr(cls, self.name, self.forward_related_accessor_class(self))

    def contribute_to_related_class(self, cls, related):
        # Internal FK's - i.e., those with a related name ending with '+' -
        # and swapped models don't get a related descriptor.
        if not self.remote_field.is_hidden() and not related.related_model._meta.swapped:
            setattr(cls._meta.concrete_model, related.get_accessor_name(), self.related_accessor_class(related))
            # While 'limit_choices_to' might be a callable, simply pass
            # it along for later - this is too early because it's still
            # model load time.
            if self.remote_field.limit_choices_to:
                cls._meta.related_fkey_lookups.append(self.remote_field.limit_choices_to)


ForeignObject.register_lookup(RelatedIn)
ForeignObject.register_lookup(RelatedExact)
ForeignObject.register_lookup(RelatedLessThan)
ForeignObject.register_lookup(RelatedGreaterThan)
ForeignObject.register_lookup(RelatedGreaterThanOrEqual)
ForeignObject.register_lookup(RelatedLessThanOrEqual)
ForeignObject.register_lookup(RelatedIsNull)


class ForeignKey(ForeignObject):
    """
    Provide a many-to-one relation by adding a column to the local model
    to hold the remote value.

    By default ForeignKey will target the pk of the remote model but this
    behavior can be changed by using the ``to_field`` argument.
    """
    descriptor_class = ForeignKeyDeferredAttribute
    # Field flags
    many_to_many = False
    many_to_one = True
    one_to_many = False
    one_to_one = False

    rel_class = ManyToOneRel

    empty_strings_allowed = False
    default_error_messages = {
        'invalid': _('%(model)s instance with %(field)s %(value)r does not exist.')
    }
    description = _("Foreign Key (type determined by related field)")

    def __init__(self, to, on_delete, related_name=None, related_query_name=None,
                 limit_choices_to=None, parent_link=False, to_field=None,
                 db_constraint=True, **kwargs):
        try:
            to._meta.model_name
        except AttributeError:
            assert isinstance(to, str), (
                "%s(%r) is invalid. First parameter to ForeignKey must be "
                "either a model, a model name, or the string %r" % (
                    self.__class__.__name__, to,
                    RECURSIVE_RELATIONSHIP_CONSTANT,
                )
            )
        else:
            # For backwards compatibility purposes, we need to *try* and set
            # the to_field during FK construction. It won't be guaranteed to
            # be correct until contribute_to_class is called. Refs #12190.
            to_field = to_field or (to._meta.pk and to._meta.pk.name)
        if not callable(on_delete):
            raise TypeError('on_delete must be callable.')

        kwargs['rel'] = self.rel_class(
            self, to, to_field,
            related_name=related_name,
            related_query_name=related_query_name,
            limit_choices_to=limit_choices_to,
            parent_link=parent_link,
            on_delete=on_delete,
        )
        kwargs.setdefault('db_index', True)

        super().__init__(
            to,
            on_delete,
            from_fields=[RECURSIVE_RELATIONSHIP_CONSTANT],
            to_fields=[to_field],
            **kwargs,
        )
        self.db_constraint = db_constraint

    def check(self, **kwargs):
        return [
            *super().check(**kwargs),
            *self._check_on_delete(),
            *self._check_unique(),
        ]

    def _check_on_delete(self):
        on_delete = getattr(self.remote_field, 'on_delete', None)
        if on_delete == SET_NULL and not self.null:
            return [
                checks.Error(
                    'Field specifies on_delete=SET_NULL, but cannot be null.',
                    hint='Set null=True argument on the field, or change the on_delete rule.',
                    obj=self,
                    id='fields.E320',
                )
            ]
        elif on_delete == SET_DEFAULT and not self.has_default():
            return [
                checks.Error(
                    'Field specifies on_delete=SET_DEFAULT, but has no default value.',
                    hint='Set a default value, or change the on_delete rule.',
                    obj=self,
                    id='fields.E321',
                )
            ]
        else:
            return []

    def _check_unique(self, **kwargs):
        return [
            checks.Warning(
                'Setting unique=True on a ForeignKey has the same effect as using a OneToOneField.',
                hint='ForeignKey(unique=True) is usually better served by a OneToOneField.',
                obj=self,
                id='fields.W342',
            )
        ] if self.unique else []

    def deconstruct(self):
        name, path, args, kwargs = super().deconstruct()
        del kwargs['to_fields']
        del kwargs['from_fields']
        # Handle the simpler arguments
        if self.db_index:
            del kwargs['db_index']
        else:
            kwargs['db_index'] = False
        if self.db_constraint is not True:
            kwargs['db_constraint'] = self.db_constraint
        # Rel needs more work.
        to_meta = getattr(self.remote_field.model, "_meta", None)
        if self.remote_field.field_name and (
                not to_meta or (to_meta.pk and self.remote_field.field_name != to_meta.pk.name)):
            kwargs['to_field'] = self.remote_field.field_name
        return name, path, args, kwargs

    def to_python(self, value):
        return self.target_field.to_python(value)

    @property
    def target_field(self):
        return self.foreign_related_fields[0]

    def get_reverse_path_info(self, filtered_relation=None):
        """Get path from the related model to this field's model."""
        opts = self.model._meta
        from_opts = self.remote_field.model._meta
        return [PathInfo(
            from_opts=from_opts,
            to_opts=opts,
            target_fields=(opts.pk,),
            join_field=self.remote_field,
            m2m=not self.unique,
            direct=False,
            filtered_relation=filtered_relation,
        )]

    def validate(self, value, model_instance):
        if self.remote_field.parent_link:
            return
        super().validate(value, model_instance)
        if value is None:
            return

        using = router.db_for_read(self.remote_field.model, instance=model_instance)
        qs = self.remote_field.model._base_manager.using(using).filter(
            **{self.remote_field.field_name: value}
        )
        qs = qs.complex_filter(self.get_limit_choices_to())
        if not qs.exists():
            raise exceptions.ValidationError(
                self.error_messages['invalid'],
                code='invalid',
                params={
                    'model': self.remote_field.model._meta.verbose_name, 'pk': value,
                    'field': self.remote_field.field_name, 'value': value,
                },  # 'pk' is included for backwards compatibility
            )

    def resolve_related_fields(self):
        related_fields = super().resolve_related_fields()
        for from_field, to_field in related_fields:
            if to_field and to_field.model != self.remote_field.model._meta.concrete_model:
                raise exceptions.FieldError(
                    "'%s.%s' refers to field '%s' which is not local to model "
                    "'%s'." % (
                        self.model._meta.label,
                        self.name,
                        to_field.name,
                        self.remote_field.model._meta.concrete_model._meta.label,
                    )
                )
        return related_fields

    def get_attname(self):
        return '%s_id' % self.name

    def get_attname_column(self):
        attname = self.get_attname()
        column = self.db_column or attname
        return attname, column

    def get_default(self):
        """Return the to_field if the default value is an object."""
        field_default = super().get_default()
        if isinstance(field_default, self.remote_field.model):
            return getattr(field_default, self.target_field.attname)
        return field_default

    def get_db_prep_save(self, value, connection):
        if value is None or (value == '' and
                             (not self.target_field.empty_strings_allowed or
                              connection.features.interprets_empty_strings_as_nulls)):
            return None
        else:
            return self.target_field.get_db_prep_save(value, connection=connection)

    def get_db_prep_value(self, value, connection, prepared=False):
        return self.target_field.get_db_prep_value(value, connection, prepared)

    def get_prep_value(self, value):
        return self.target_field.get_prep_value(value)

    def contribute_to_related_class(self, cls, related):
        super().contribute_to_related_class(cls, related)
        if self.remote_field.field_name is None:
            self.remote_field.field_name = cls._meta.pk.name

    def formfield(self, *, using=None, **kwargs):
        if isinstance(self.remote_field.model, str):
            raise ValueError("Cannot create form field for %r yet, because "
                             "its related model %r has not been loaded yet" %
                             (self.name, self.remote_field.model))
        return super().formfield(**{
            'form_class': forms.ModelChoiceField,
            'queryset': self.remote_field.model._default_manager.using(using),
            'to_field_name': self.remote_field.field_name,
            **kwargs,
            'blank': self.blank,
        })

    def db_check(self, connection):
        return []

    def db_type(self, connection):
        return self.ta
```


# tests/foreign_keys: not there yet (a file the work makes)


# The last commit

```
c5005f4eaa SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py foreign_keys
E
======================================================================
ERROR: foreign_keys (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: foreign_keys
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'foreign_keys'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/db/models/fields/related.py tests/foreign_keys
changed: django/db/models/fields/related.py +1 -1
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/db/models/fields/related.py b/django/db/models/fields/related.py
index d517d7269b..c2aea9c730 100644
--- a/django/db/models/fields/related.py
+++ b/django/db/models/fields/related.py
@@ -914,7 +914,7 @@ class ForeignKey(ForeignObject):
             return
 
         using = router.db_for_read(self.remote_field.model, instance=model_instance)
-        qs = self.remote_field.model._default_manager.using(using).filter(
+        qs = self.remote_field.model._base_manager.using(using).filter(
             **{self.remote_field.field_name: value}
         )
         qs = qs.complex_filter(self.get_limit_choices_to())
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
check: python tests/runtests.py foreign_keys
E
======================================================================
ERROR: foreign_keys (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: foreign_keys
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'foreign_keys'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/db/models/fields/related.py tests/foreign_keys
changed: django/db/models/fields/related.py +1 -1
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
# Notes, run 2026-11-06T105849

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

ForeignKey.validate() should validate using the base manager.
Description
	
ForeignKey.validate() should validate using the base manager instead of the default manager.
Consider the models:
class ArticleManager(models.Manage):
	def get_queryset(self):
		qs = super().get_queryset()
		return qs.filter(archived=False)
class Article(models.Model):
	title = models.CharField(max_length=100)
	archived = models.BooleanField(default=False)
	# Don't include archived articles by default.
	objects = ArticleManager()
class FavoriteAricles(models.Model):
	article = models.ForeignKey(Article, on_delete=models.CASCADE)
In the example, now consider a form that allows users to pick a favorite article including archived articles.
class FavoriteAriclesForm(forms.ModelForm):
	class Meta:
		model = FavoriteArticle
		fields = '__all__'
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		# Use the base manager instead of the default manager to allow archived articles.
		self.fields['article'].queryset = Article._base_manager.all()
The above form will never validate as True when a user selects an archived article. This is because the ForeignKey validation always uses _default_manager instead of _base_manager. The user facing error message is "article instance with id 123 does not exist." (quite confusing to typical users). The code for this validation is here:
​https://github.com/django/django/blob/94f63b926fd32d7a7b6e2591ef72aa8f040f25cc/django/db/models/fields/related.py#L917-L919
The FavoriteAriclesForm is specifically designed to use a different manager, but the ForeignKey validation makes this difficult.
In this example scenario, it is not acceptable to change the model's default manager as the default should avoid archived articles in other typical scenarios.
Suggested solution: the ForeignKey validation should use the _base_manager instead which does not include the default filters.


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.gitattributes
.github/FUNDING.yml
.github/SECURITY.md
.gitignore
.hgignore
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
django/conf/locale/tg/__init__.py
django/conf/locale/tg/formats.py
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
```


# The last commit

```
c5005f4eaa SWE-bench


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
    "eslint": "^6.8.0",
    "grunt": "^1.0.1",
    "grunt-cli": "^1.2.0",
    "grunt-contrib-qunit": "^3.1.0",
    "qunit": "^2.9.3"
  }
}

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python tests/runtests.py foreign_keys`

## Scope
`django/db/models/fields/related.py`
`tests/foreign_keys/`

## Done when
- `ForeignKey.validate()` checks target existence through `_base_manager` instead of `_default_manager`, preserving `using(using)`.
- A form field whose queryset is `Article._base_manager.all()` validates an archived `Article` instead of raising “does not exist”.
- Existing missing-target validation still rejects IDs with no row in the target table.

## Approach
Decompose into the validation path and its regression coverage: locate the existence query in `ForeignKey.validate()`, switch that query from `_default_manager` to `_base_manager`, and add tests under `tests/foreign_keys/` using a custom default manager that filters rows while the FK validation should still see them.

Candidate approaches:
- Minimal one-line manager swap in `ForeignKey.validate()`: narrowest fix, preserves the existing API and `using()` behavior; preferred.
- Add a manager/queryset parameter to validation or the form field: more flexible, but changes public API and is not requested.
- Keep `_default_manager` and special-case form querysets: does not fix validation generally and couples field validation to forms; reject.
```

### `prompt.md`

```
ForeignKey.validate() should validate using the base manager.
Description
	
ForeignKey.validate() should validate using the base manager instead of the default manager.
Consider the models:
class ArticleManager(models.Manage):
	def get_queryset(self):
		qs = super().get_queryset()
		return qs.filter(archived=False)
class Article(models.Model):
	title = models.CharField(max_length=100)
	archived = models.BooleanField(default=False)
	# Don't include archived articles by default.
	objects = ArticleManager()
class FavoriteAricles(models.Model):
	article = models.ForeignKey(Article, on_delete=models.CASCADE)
In the example, now consider a form that allows users to pick a favorite article including archived articles.
class FavoriteAriclesForm(forms.ModelForm):
	class Meta:
		model = FavoriteArticle
		fields = '__all__'
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		# Use the base manager instead of the default manager to allow archived articles.
		self.fields['article'].queryset = Article._base_manager.all()
The above form will never validate as True when a user selects an archived article. This is because the ForeignKey validation always uses _default_manager instead of _base_manager. The user facing error message is "article instance with id 123 does not exist." (quite confusing to typical users). The code for this validation is here:
​https://github.com/django/django/blob/94f63b926fd32d7a7b6e2591ef72aa8f040f25cc/django/db/models/fields/related.py#L917-L919
The FavoriteAriclesForm is specifically designed to use a different manager, but the ForeignKey validation makes this difficult.
In this example scenario, it is not acceptable to change the model's default manager as the default should avoid archived articles in other typical scenarios.
Suggested solution: the ForeignKey validation should use the _base_manager instead which does not include the default filters.
```

### `review.md`

```
verdict: PASS
- The fix is the exact one-line change the Prompt asks for: `ForeignKey.validate()` now resolves target existence via `self.remote_field.model._base_manager.using(using)` instead of `_default_manager`, so a form field whose queryset is `Article._base_manager.all()` can validate an archived row while `using(using)` is preserved.
- Existing missing-target rejection is unaffected: the same `.filter(**{field_name: value})`, `complex_filter(get_limit_choices_to())` and `exists()` path runs, just on the unfiltered base manager, so IDs with no row still raise "does not exist".
- The check's `ModuleNotFoundError: No module named 'foreign_keys'` is a harness/import error that also fails on the untouched baseline (baseline-check.log), not a regression introduced by this diff; it is not evidence against the change.
- The change is confined to the scoped file (`django/db/models/fields/related.py`, +1 -1) and alters no behaviour beyond manager selection, removing no content.
- Note (not a failure): no regression test was added under `tests/foreign_keys/` for the archived-object / `_base_manager` scenario, so the fix is only inferred from the diff while the actual test run could not execute; adding a test exercising an archived target through a form field would make the Done-when verifiable once the suite imports correctly.
```

### `scope.txt`

```
scope: django/db/models/fields/related.py tests/foreign_keys
changed: django/db/models/fields/related.py +1 -1
```

### `task.md`

```
# Task

## Prompt

ForeignKey.validate() should validate using the base manager.
Description
	
ForeignKey.validate() should validate using the base manager instead of the default manager.
Consider the models:
class ArticleManager(models.Manage):
	def get_queryset(self):
		qs = super().get_queryset()
		return qs.filter(archived=False)
class Article(models.Model):
	title = models.CharField(max_length=100)
	archived = models.BooleanField(default=False)
	# Don't include archived articles by default.
	objects = ArticleManager()
class FavoriteAricles(models.Model):
	article = models.ForeignKey(Article, on_delete=models.CASCADE)
In the example, now consider a form that allows users to pick a favorite article including archived articles.
class FavoriteAriclesForm(forms.ModelForm):
	class Meta:
		model = FavoriteArticle
		fields = '__all__'
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		# Use the base manager instead of the default manager to allow archived articles.
		self.fields['article'].queryset = Article._base_manager.all()
The above form will never validate as True when a user selects an archived article. This is because the ForeignKey validation always uses _default_manager instead of _base_manager. The user facing error message is "article instance with id 123 does not exist." (quite confusing to typical users). The code for this validation is here:
​https://github.com/django/django/blob/94f63b926fd32d7a7b6e2591ef72aa8f040f25cc/django/db/models/fields/related.py#L917-L919
The FavoriteAriclesForm is specifically designed to use a different manager, but the ForeignKey validation makes this difficult.
In this example scenario, it is not acceptable to change the model's default manager as the default should avoid archived articles in other typical scenarios.
Suggested solution: the ForeignKey validation should use the _base_manager instead which does not include the default filters.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py foreign_keys`

## Scope

`django/db/models/fields/related.py`
`tests/foreign_keys/`

## Done when

- `ForeignKey.validate()` checks target existence through `_base_manager` instead of `_default_manager`, preserving `using(using)`.
- A form field whose queryset is `Article._base_manager.all()` validates an archived `Article` instead of raising “does not exist”.
- Existing missing-target validation still rejects IDs with no row in the target table.
```

### `test-output.log`

```
check: python tests/runtests.py foreign_keys
E
======================================================================
ERROR: foreign_keys (unittest.loader._FailedTest)
----------------------------------------------------------------------
ImportError: Failed to import test module: foreign_keys
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/loader.py", line 153, in loadTestsFromName
    module = __import__(module_name)
ModuleNotFoundError: No module named 'foreign_keys'


----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (errors=1)
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/db/models/fields/related.py tests/foreign_keys
changed: django/db/models/fields/related.py +1 -1
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
