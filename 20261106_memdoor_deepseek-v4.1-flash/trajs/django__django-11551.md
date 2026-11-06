# django__django-11551 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 48s 108 lines cost=0.002255 in=154507 cached=141824 out=3521 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

admin.E108 is raised on fields accessible only via instance.
Description
	 
		(last modified by ajcsimons)
	 
As part of startup django validates the ModelAdmin's list_display list/tuple for correctness (django.admin.contrib.checks._check_list_display). Having upgraded django from 2.07 to 2.2.1 I found that a ModelAdmin with a list display that used to pass the checks and work fine in admin now fails validation, preventing django from starting. A PositionField from the django-positions library triggers this bug, explanation why follows.
from django.db import models
from position.Fields import PositionField
class Thing(models.Model)
 number = models.IntegerField(default=0)
 order = PositionField()
from django.contrib import admin
from .models import Thing
@admin.register(Thing)
class ThingAdmin(admin.ModelAdmin)
 list_display = ['number', 'order']
Under 2.2.1 this raises an incorrect admin.E108 message saying "The value of list_display[1] refers to 'order' which is not a callable...".
Under 2.0.7 django starts up successfully.
If you change 'number' to 'no_number' or 'order' to 'no_order' then the validation correctly complains about those.
The reason for this bug is commit ​https://github.com/django/django/commit/47016adbf54b54143d4cf052eeb29fc72d27e6b1 which was proposed and accepted as a fix for bug https://code.djangoproject.com/ticket/28490. The problem is while it fixed that bug it broke the functionality of _check_list_display_item in other cases. The rationale for that change was that after field=getattr(model, item) field could be None if item was a descriptor returning None, but subsequent code incorrectly interpreted field being None as meaning getattr raised an AttributeError. As this was done after trying field = model._meta.get_field(item) and that failing that meant the validation error should be returned. However, after the above change if hasattr(model, item) is false then we no longer even try field = model._meta.get_field(item) before returning an error. The reason hasattr(model, item) is false in the case of a PositionField is its get method throws an exception if called on an instance of the PositionField class on the Thing model class, rather than a Thing instance.
For clarity, here are the various logical tests that _check_list_display_item needs to deal with and the behaviour before the above change, after it, and the correct behaviour (which my suggested patch exhibits). Note this is assuming the first 2 tests callable(item) and hasattr(obj, item) are both false (corresponding to item is an actual function/lambda rather than string or an attribute of ThingAdmin).
hasattr(model, item) returns True or False (which is the same as seeing if getattr(model, item) raises AttributeError)
model._meta.get_field(item) returns a field or raises FieldDoesNotExist
Get a field from somewhere, could either be from getattr(model,item) if hasattr was True or from get_field.
Is that field an instance of ManyToManyField?
Is that field None? (True in case of bug 28490)
 hasattr get_field field is None? field ManyToMany? 2.0 returns 2.2 returns Correct behaviour Comments 
 True ok False False [] [] [] - 
 True ok False True E109 E109 E109 - 
 True ok True False E108 [] [] good bit of 28490 fix, 2.0 was wrong 
 True raises False False [] [] [] - 
 True raises False True E109 [] E109 Another bug introduced by 28490 fix, fails to check if ManyToMany in get_field raise case 
 True raises True False E108 [] [] good bit of 28490 fix, 2.0 was wrong 
 False ok False False [] E108 [] bad bit of 28490 fix, bug hit with PositionField 
 False ok False True [] E108 E109 both 2.0 and 2.2 wrong 
 False ok True False [] E108 [] bad 28490 fix 
 False raises False False E108 E108 E108 - 
 False raises False True E108 E108 E108 impossible condition, we got no field assigned to be a ManyToMany 
 False raises True False E108 E108 E108 impossible condition, we got no field assigned to be None 
The following code exhibits the correct behaviour in all cases. The key changes are there is no longer a check for hasattr(model, item), as that being false should not prevent us form attempting to get the field via get_field, and only return an E108 in the case both of them fail. If either of those means or procuring it are successful then we need to check if it's a ManyToMany. Whether or not the field is None is irrelevant, and behaviour is contained within the exception catching blocks that should cause it instead of signalled through a variable being set to None which is a source of conflation of different cases.
def _check_list_display_item(self, obj, item, label):
	if callable(item):
		return []
	elif hasattr(obj, item):
		return []
	else:
		try:
			field = obj.model._meta.get_field(item)
		except FieldDoesNotExist:
			try:
				field = getattr(obj.model, item)
			except AttributeError:
				return [
					checks.Error(
						"The value of '%s' refers to '%s', which is not a callable, "
						"an attribute of '%s', or an attribute or method on '%s.%s'." % (
							label, item, obj.__class__.__name__,
							obj.model._meta.app_label, obj.model._meta.object_name,
						),
						obj=obj.__class__,
						id='admin.E108',
					)
				]
		if isinstance(field, models.ManyToManyField):
			return [
				checks.Error(
					"The value of '%s' must not be a ManyToManyField." % label,
					obj=obj.__class__,
					id='admin.E109',
				)
			]
		return []

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
FUNDING.yml
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
  "command": "grep -n \"_check_list_display_item\" -A45 django/contrib/admin/checks.py"
}
```

**tool result**

```
714:                self._check_list_display_item(obj, item, "list_display[%d]" % index)
715-                for index, item in enumerate(obj.list_display)
716-            ))
717-
718:    def _check_list_display_item(self, obj, item, label):
719-        if callable(item):
720-            return []
721-        elif hasattr(obj, item):
722-            return []
723-        elif hasattr(obj.model, item):
724-            try:
725-                field = obj.model._meta.get_field(item)
726-            except FieldDoesNotExist:
727-                return []
728-            else:
729-                if isinstance(field, models.ManyToManyField):
730-                    return [
731-                        checks.Error(
732-                            "The value of '%s' must not be a ManyToManyField." % label,
733-                            obj=obj.__class__,
734-                            id='admin.E109',
735-                        )
736-                    ]
737-                return []
738-        else:
739-            return [
740-                checks.Error(
741-                    "The value of '%s' refers to '%s', which is not a callable, "
742-                    "an attribute of '%s', or an attribute or method on '%s.%s'." % (
743-                        label, item, obj.__class__.__name__,
744-                        obj.model._meta.app_label, obj.model._meta.object_name,
745-                    ),
746-                    obj=obj.__class__,
747-                    id='admin.E108',
748-                )
749-            ]
750-
751-    def _check_list_display_links(self, obj):
752-        """ Check that list_display_links is a unique subset of list_display.
753-        """
754-        from django.contrib.admin.options import ModelAdmin
755-
756-        if obj.list_display_links is None:
757-            return []
758-        elif not isinstance(obj.list_display_links, (list, tuple)):
759-            return must_be('a list, a tuple, or None', option='list_display_links', obj=obj, id='admin.E110')
760-        # Check only if ModelAdmin.get_list_display() isn't overridden.
761-        elif obj.get_list_display.__func__ is ModelAdmin.get_list_display:
762-            return list(chain.from_iterable(
763-                self._check_list_display_links_item(obj, field_name, "list_display_links[%d]" % index)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/contrib/admin/checks.py\n@@\n     def _check_list_display_item(self, obj, item, label):\n         if callable(item):\n             return []\n         elif hasattr(obj, item):\n             return []\n-        elif hasattr(obj.model, item):\n-            try:\n-                field = obj.model._meta.get_field(item)\n-            except FieldDoesNotExist:\n-                return []\n-            else:\n-                if isinstance(field, models.ManyToManyField):\n-                    return [\n-                        checks.Error(\n-                            \"The value of '%s' must not be a ManyToManyField.\" % label,\n-                            obj=obj.__class__,\n-                            id='admin.E109',\n-                        )\n-                    ]\n-                return []\n         else:\n-            return [\n-                checks.Error(\n-                    \"The value of '%s' refers to '%s', which is not a callable, \"\n-                    \"an attribute of '%s', or an attribute or method on '%s.%s'.\" % (\n-                        label, item, obj.__class__.__name__,\n-                        obj.model._meta.app_label, obj.model._meta.object_name,\n-                    ),\n-                    obj=obj.__class__,\n-                    id='admin.E108',\n-                )\n-            ]\n+            try:\n+                field = obj.model._meta.get_field(item)\n+            except FieldDoesNotExist:\n+                try:\n+                    field = getattr(obj.model, item)\n+                except AttributeError:\n+                    return [\n+                        checks.Error(\n+                            \"The value of '%s' refers to '%s', which is not a callable, \"\n+                            \"an attribute of '%s', or an attribute or method on '%s.%s'.\" % (\n+                                label, item, obj.__class__.__name__,\n+                                obj.model._meta.app_label, obj.model._meta.object_name,\n+                            ),\n+                            obj=obj.__class__,\n+                            id='admin.E108',\n+                        )\n+                    ]\n+            if isinstance(field, models.ManyToManyField):\n+                return [\n+                    checks.Error(\n+                        \"The value of '%s' must not be a ManyToManyField.\" % label,\n+                        obj=obj.__class__,\n+                        id='admin.E109',\n+                    )\n+                ]\n+            return []\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/contrib/admin/checks.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/contrib/admin/checks.py now (1116 lines), around the change:
720:            return []
721:        elif hasattr(obj, item):
722:            return []
723:        else:
724:            try:
725:                field = obj.model._meta.get_field(item)
726:            except FieldDoesNotExist:
727:                try:
728:                    field = getattr(obj.model, item)
729:                except AttributeError:
730:                    return [
731:                        checks.Error(
732:                            "The value of '%s' refers to '%s', which is not a callable, "
733:                            "an attribute of '%s', or an attribute or method on '%s.%s'." % (
734:                                label, item, obj.__class__.__name__,
735:                                obj.model._meta.app_label, obj.model._meta.object_name,
736:                            ),
737:                            obj=obj.__class__,
738:                            id='admin.E108',
739:                        )
740:                    ]
741:            if isinstance(field, models.ManyToManyField):
742:                return [
743:                    checks.Error(
744:                        "The value of '%s' must not be a ManyToManyField." % label,
745:                        obj=obj.__class__,
746:                        id='admin.E109',
747:                    )
748:                ]
749:            return []
750:
751:    def _check_list_display_links(self, obj):
752:        """ Check that list_display_links is a unique subset of list_display.
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/admin_checks/ -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py admin_checks 2>&1 | tail -20"
}
```

**tool result**

```
......................................................
----------------------------------------------------------------------
Ran 54 tests in 0.070s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"list_display\" tests/admin_checks/tests.py | head -40"
}
```

**tool result**

```
262:    def test_field_name_not_in_list_display(self):
270:                "which is not contained in 'list_display'.",
305:            list_display = ["pk", "original_release"]
325:            list_display = ["pk", "title"]
356:            list_display = ["pk", "title"]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"E108\\|E109\\|list_display\" tests/admin_checks/tests.py | head -60"
}
```

**tool result**

```
262:    def test_field_name_not_in_list_display(self):
270:                "which is not contained in 'list_display'.",
305:            list_display = ["pk", "original_release"]
325:            list_display = ["pk", "title"]
356:            list_display = ["pk", "title"]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"admin.E108\\|admin.E109\" tests/ | head -30"
}
```

**tool result**

```
tests/modeladmin/test_checks.py:488:            'admin.E108'
tests/modeladmin/test_checks.py:498:            'admin.E109'
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '450,520p' tests/modeladmin/test_checks.py"
}
```

**tool result**

```
        class TestModelAdmin(ModelAdmin):
            prepopulated_fields = {'slug': ('name',)}

        self.assertIsValid(TestModelAdmin, ValidationTestModel)

    def test_one_to_one_field(self):
        class TestModelAdmin(ModelAdmin):
            prepopulated_fields = {'best_friend': ('name',)}

        self.assertIsInvalid(
            TestModelAdmin, ValidationTestModel,
            "The value of 'prepopulated_fields' refers to 'best_friend', which must not be "
            "a DateTimeField, a ForeignKey, a OneToOneField, or a ManyToManyField.",
            'admin.E028'
        )


class ListDisplayTests(CheckTestCase):

    def test_not_iterable(self):
        class TestModelAdmin(ModelAdmin):
            list_display = 10

        self.assertIsInvalid(
            TestModelAdmin, ValidationTestModel,
            "The value of 'list_display' must be a list or tuple.",
            'admin.E107'
        )

    def test_missing_field(self):
        class TestModelAdmin(ModelAdmin):
            list_display = ('non_existent_field',)

        self.assertIsInvalid(
            TestModelAdmin, ValidationTestModel,
            "The value of 'list_display[0]' refers to 'non_existent_field', "
            "which is not a callable, an attribute of 'TestModelAdmin', "
            "or an attribute or method on 'modeladmin.ValidationTestModel'.",
            'admin.E108'
        )

    def test_invalid_field_type(self):
        class TestModelAdmin(ModelAdmin):
            list_display = ('users',)

        self.assertIsInvalid(
            TestModelAdmin, ValidationTestModel,
            "The value of 'list_display[0]' must not be a ManyToManyField.",
            'admin.E109'
        )

    def test_valid_case(self):
        def a_callable(obj):
            pass

        class TestModelAdmin(ModelAdmin):
            def a_method(self, obj):
                pass
            list_display = ('name', 'decade_published_in', 'a_method', a_callable)

        self.assertIsValid(TestModelAdmin, ValidationTestModel)


class ListDisplayLinksCheckTests(CheckTestCase):

    def test_not_iterable(self):
        class TestModelAdmin(ModelAdmin):
            list_display_links = 10

        self.assertIsInvalid(
            TestModelAdmin, ValidationTestModel,
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' tests/modeladmin/test_checks.py && grep -n \"class ValidationTestModel\" -A40 tests/modeladmin/models.py"
}
```

**tool result**

```
from django import forms
from django.contrib.admin import BooleanFieldListFilter, SimpleListFilter
from django.contrib.admin.options import VERTICAL, ModelAdmin, TabularInline
from django.contrib.admin.sites import AdminSite
from django.core.checks import Error
from django.db.models import F
from django.db.models.functions import Upper
from django.forms.models import BaseModelFormSet
from django.test import SimpleTestCase

from .models import (
    Band, Song, User, ValidationTestInlineModel, ValidationTestModel,
)


class CheckTestCase(SimpleTestCase):

    def assertIsInvalid(self, model_admin, model, msg, id=None, hint=None, invalid_obj=None, admin_site=None):
        if admin_site is None:
            admin_site = AdminSite()
        invalid_obj = invalid_obj or model_admin
        admin_obj = model_admin(model, admin_site)
        self.assertEqual(admin_obj.check(), [Error(msg, hint=hint, obj=invalid_obj, id=id)])

    def assertIsInvalidRegexp(self, model_admin, model, msg, id=None, hint=None, invalid_obj=None):
        """
        Same as assertIsInvalid but treats the given msg as a regexp.
        """
        invalid_obj = invalid_obj or model_admin
        admin_obj = model_admin(model, AdminSite())
        errors = admin_obj.check()
        self.assertEqual(len(errors), 1)
        error = errors[0]
        self.assertEqual(error.hint, hint)
        self.assertEqual(error.obj, invalid_obj)
        self.assertEqual(error.id, id)
        self.assertRegex(error.msg, msg)

    def assertIsValid(self, model_admin, model, admin_site=None):
        if admin_site is None:
37:class ValidationTestModel(models.Model):
38-    name = models.CharField(max_length=100)
39-    slug = models.SlugField()
40-    users = models.ManyToManyField(User)
41-    state = models.CharField(max_length=2, choices=(("CO", "Colorado"), ("WA", "Washington")))
42-    is_active = models.BooleanField(default=False)
43-    pub_date = models.DateTimeField()
44-    band = models.ForeignKey(Band, models.CASCADE)
45-    best_friend = models.OneToOneField(User, models.CASCADE, related_name='best_friend')
46-    # This field is intentionally 2 characters long (#16080).
47-    no = models.IntegerField(verbose_name="Number", blank=True, null=True)
48-
49-    def decade_published_in(self):
50-        return self.pub_date.strftime('%Y')[:3] + "0's"
51-
52-
53-class ValidationTestInlineModel(models.Model):
54-    parent = models.ForeignKey(ValidationTestModel, models.CASCADE)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/test_checks.py\n@@\n     def test_invalid_field_type(self):\n         class TestModelAdmin(ModelAdmin):\n             list_display = ('users',)\n \n         self.assertIsInvalid(\n@@\n             'admin.E109'\n         )\n \n+    def test_descriptor_raises_on_class_access(self):\n+        class Descriptor:\n+            def __get__(self, instance, owner):\n+                if instance is None:\n+                    raise ValueError('Cannot be accessed on the class.')\n+                return None\n+\n+        class TestModelAdmin(ModelAdmin):\n+            list_display = ('name', 'descriptor_field')\n+\n+        ValidationTestModel.descriptor_field = Descriptor()\n+        try:\n+            self.assertIsValid(TestModelAdmin, ValidationTestModel)\n+        finally:\n+            del ValidationTestModel.descriptor_field\n+\n     def test_valid_case(self):\n         def a_callable(obj):\n             pass\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/test_checks.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/test_checks.py now (1457 lines), around the change:
498:            'admin.E109'
499:        )
500:
501:    def test_descriptor_raises_on_class_access(self):
502:        class Descriptor:
503:            def __get__(self, instance, owner):
504:                if instance is None:
505:                    raise ValueError('Cannot be accessed on the class.')
506:                return None
507:
508:        class TestModelAdmin(ModelAdmin):
509:            list_display = ('name', 'descriptor_field')
510:
511:        ValidationTestModel.descriptor_field = Descriptor()
512:        try:
513:            self.assertIsValid(TestModelAdmin, ValidationTestModel)
514:        finally:
515:            del ValidationTestModel.descriptor_field
516:
517:    def test_valid_case(self):
518:        def a_callable(obj):
519:            pass
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,60p' tests/modeladmin/models.py"
}
```

**tool result**

```
from django.contrib.auth.models import User
from django.db import models


class Band(models.Model):
    name = models.CharField(max_length=100)
    bio = models.TextField()
    sign_date = models.DateField()

    class Meta:
        ordering = ('name',)

    def __str__(self):
        return self.name


class Song(models.Model):
    name = models.CharField(max_length=100)
    band = models.ForeignKey(Band, models.CASCADE)
    featuring = models.ManyToManyField(Band, related_name='featured')

    def __str__(self):
        return self.name


class Concert(models.Model):
    main_band = models.ForeignKey(Band, models.CASCADE, related_name='main_concerts')
    opening_band = models.ForeignKey(Band, models.CASCADE, related_name='opening_concerts', blank=True)
    day = models.CharField(max_length=3, choices=((1, 'Fri'), (2, 'Sat')))
    transport = models.CharField(max_length=100, choices=(
        (1, 'Plane'),
        (2, 'Train'),
        (3, 'Bus')
    ), blank=True)


class ValidationTestModel(models.Model):
    name = models.CharField(max_length=100)
    slug = models.SlugField()
    users = models.ManyToManyField(User)
    state = models.CharField(max_length=2, choices=(("CO", "Colorado"), ("WA", "Washington")))
    is_active = models.BooleanField(default=False)
    pub_date = models.DateTimeField()
    band = models.ForeignKey(Band, models.CASCADE)
    best_friend = models.OneToOneField(User, models.CASCADE, related_name='best_friend')
    # This field is intentionally 2 characters long (#16080).
    no = models.IntegerField(verbose_name="Number", blank=True, null=True)

    def decade_published_in(self):
        return self.pub_date.strftime('%Y')[:3] + "0's"


class ValidationTestInlineModel(models.Model):
    parent = models.ForeignKey(ValidationTestModel, models.CASCADE)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/models.py\n@@\n class ValidationTestModel(models.Model):\n@@\n     def decade_published_in(self):\n         return self.pub_date.strftime('%Y')[:3] + \"0's\"\n \n \n+class DescriptorRaisingOnClassAccess:\n+    def __get__(self, instance, owner):\n+        if instance is None:\n+            raise ValueError('Cannot be accessed on the class.')\n+        return None\n+\n+\n+class DescriptorRaisingField(models.Field):\n+    descriptor_class = DescriptorRaisingOnClassAccess\n+\n+\n+class ValidationTestModelWithDescriptor(models.Model):\n+    name = models.CharField(max_length=100)\n+    descriptor_field = DescriptorRaisingField()\n+\n+\n class ValidationTestInlineModel(models.Model):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/models.py now (70 lines), around the change:
50:        return self.pub_date.strftime('%Y')[:3] + "0's"
51:
52:
53:class DescriptorRaisingOnClassAccess:
54:    def __get__(self, instance, owner):
55:        if instance is None:
56:            raise ValueError('Cannot be accessed on the class.')
57:        return None
58:
59:
60:class DescriptorRaisingField(models.Field):
61:    descriptor_class = DescriptorRaisingOnClassAccess
62:
63:
64:class ValidationTestModelWithDescriptor(models.Model):
65:    name = models.CharField(max_length=100)
66:    descriptor_field = DescriptorRaisingField()
67:
68:
69:class ValidationTestInlineModel(models.Model):
70:    parent = models.ForeignKey(ValidationTestModel, models.CASCADE)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/test_checks.py\n@@\n from .models import (\n-    Band, Song, User, ValidationTestInlineModel, ValidationTestModel,\n+    Band, Song, User, ValidationTestInlineModel, ValidationTestModel,\n+    ValidationTestModelWithDescriptor,\n )\n@@\n     def test_descriptor_raises_on_class_access(self):\n-        class Descriptor:\n-            def __get__(self, instance, owner):\n-                if instance is None:\n-                    raise ValueError('Cannot be accessed on the class.')\n-                return None\n-\n         class TestModelAdmin(ModelAdmin):\n-            list_display = ('name', 'descriptor_field')\n+            list_display = ('name', 'descriptor_field')\n \n-        ValidationTestModel.descriptor_field = Descriptor()\n-        try:\n-            self.assertIsValid(TestModelAdmin, ValidationTestModel)\n-        finally:\n-            del ValidationTestModel.descriptor_field\n+        self.assertIsValid(TestModelAdmin, ValidationTestModelWithDescriptor)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/test_checks.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/test_checks.py now (1448 lines), around the change:
10:
11:from .models import (
12:    Band, Song, User, ValidationTestInlineModel, ValidationTestModel,
13:    ValidationTestModelWithDescriptor,
14:)
15:
16:
…
500:        )
501:
502:    def test_descriptor_raises_on_class_access(self):
503:        class TestModelAdmin(ModelAdmin):
504:            list_display = ('name', 'descriptor_field')
505:
506:        self.assertIsValid(TestModelAdmin, ValidationTestModelWithDescriptor)
507:
508:    def test_valid_case(self):
509:        def a_callable(obj):
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py modeladmin admin_checks 2>&1 | tail -20"
}
```

**tool result**

```
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
..................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 210 tests in 0.228s

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
  "command": "git diff --stat && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```
 django/contrib/admin/checks.py  | 38 +++++++++++++++++++-------------------
 tests/modeladmin/models.py      | 16 ++++++++++++++++
 tests/modeladmin/test_checks.py |  7 +++++++
 3 files changed, 42 insertions(+), 19 deletions(-)
TASK_OK
```

**assistant**

```
Fixed `_check_list_display_item` in `django/contrib/admin/checks.py`:

- Removed the `hasattr(obj.model, item)` gate that prevented `get_field()` from being tried when a descriptor raises on class access (the `PositionField` case).
- Now tries `_meta.get_field(item)` first, falls back to `getattr(obj.model, item)`, and only raises `admin.E108` if both fail.
- Checks `ManyToManyField` (E109) whenever a field is obtained, including the `get_field`-raises path.

Added regression tests using a custom field whose descriptor raises on class access. `modeladmin` and `admin_checks` suites pass (210 tests), and the completion command exits 0.
```

## Run folder `single-2026-11-06T105143`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
admin.E108 is raised on fields accessible only via instance.
Description
	 
		(last modified by ajcsimons)
	 
As part of startup django validates the ModelAdmin's list_display list/tuple for correctness (django.admin.contrib.checks._check_list_display). Having upgraded django from 2.07 to 2.2.1 I found that a ModelAdmin with a list display that used to pass the checks and work fine in admin now fails validation, preventing django from starting. A PositionField from the django-positions library triggers this bug, explanation why follows.
from django.db import models
from position.Fields import PositionField
class Thing(models.Model)
 number = models.IntegerField(default=0)
 order = PositionField()
from django.contrib import admin
from .models import Thing
@admin.register(Thing)
class ThingAdmin(admin.ModelAdmin)
 list_display = ['number', 'order']
Under 2.2.1 this raises an incorrect admin.E108 message saying "The value of list_display[1] refers to 'order' which is not a callable...".
Under 2.0.7 django starts up successfully.
If you change 'number' to 'no_number' or 'order' to 'no_order' then the validation correctly complains about those.
The reason for this bug is commit ​https://github.com/django/django/commit/47016adbf54b54143d4cf052eeb29fc72d27e6b1 which was proposed and accepted as a fix for bug https://code.djangoproject.com/ticket/28490. The problem is while it fixed that bug it broke the functionality of _check_list_display_item in other cases. The rationale for that change was that after field=getattr(model, item) field could be None if item was a descriptor returning None, but subsequent code incorrectly interpreted field being None as meaning getattr raised an AttributeError. As this was done after trying field = model._meta.get_field(item) and that failing that meant the validation error should be returned. However, after the above change if hasattr(model, item) is false then we no longer even try field = model._meta.get_field(item) before returning an error. The reason hasattr(model, item) is false in the case of a PositionField is its get method throws an exception if called on an instance of the PositionField class on the Thing model class, rather than a Thing instance.
For clarity, here are the various logical tests that _check_list_display_item needs to deal with and the behaviour before the above change, after it, and the correct behaviour (which my suggested patch exhibits). Note this is assuming the first 2 tests callable(item) and hasattr(obj, item) are both false (corresponding to item is an actual function/lambda rather than string or an attribute of ThingAdmin).
hasattr(model, item) returns True or False (which is the same as seeing if getattr(model, item) raises AttributeError)
model._meta.get_field(item) returns a field or raises FieldDoesNotExist
Get a field from somewhere, could either be from getattr(model,item) if hasattr was True or from get_field.
Is that field an instance of ManyToManyField?
Is that field None? (True in case of bug 28490)
 hasattr get_field field is None? field ManyToMany? 2.0 returns 2.2 returns Correct behaviour Comments 
 True ok False False [] [] [] - 
 True ok False True E109 E109 E109 - 
 True ok True False E108 [] [] good bit of 28490 fix, 2.0 was wrong 
 True raises False False [] [] [] - 
 True raises False True E109 [] E109 Another bug introduced by 28490 fix, fails to check if ManyToMany in get_field raise case 
 True raises True False E108 [] [] good bit of 28490 fix, 2.0 was wrong 
 False ok False False [] E108 [] bad bit of 28490 fix, bug hit with PositionField 
 False ok False True [] E108 E109 both 2.0 and 2.2 wrong 
 False ok True False [] E108 [] bad 28490 fix 
 False raises False False E108 E108 E108 - 
 False raises False True E108 E108 E108 impossible condition, we got no field assigned to be a ManyToMany 
 False raises True False E108 E108 E108 impossible condition, we got no field assigned to be None 
The following code exhibits the correct behaviour in all cases. The key changes are there is no longer a check for hasattr(model, item), as that being false should not prevent us form attempting to get the field via get_field, and only return an E108 in the case both of them fail. If either of those means or procuring it are successful then we need to check if it's a ManyToMany. Whether or not the field is None is irrelevant, and behaviour is contained within the exception catching blocks that should cause it instead of signalled through a variable being set to None which is a source of conflation of different cases.
def _check_list_display_item(self, obj, item, label):
	if callable(item):
		return []
	elif hasattr(obj, item):
		return []
	else:
		try:
			field = obj.model._meta.get_field(item)
		except FieldDoesNotExist:
			try:
				field = getattr(obj.model, item)
			except AttributeError:
				return [
					checks.Error(
						"The value of '%s' refers to '%s', which is not a callable, "
						"an attribute of '%s', or an attribute or method on '%s.%s'." % (
							label, item, obj.__class__.__name__,
							obj.model._meta.app_label, obj.model._meta.object_name,
						),
						obj=obj.__class__,
						id='admin.E108',
					)
				]
		if isinstance(field, models.ManyToManyField):
			return [
				checks.Error(
					"The value of '%s' must not be a ManyToManyField." % label,
					obj=obj.__class__,
					id='admin.E109',
				)
			]
		return []
```
