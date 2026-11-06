# django__django-11551 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 96s 120 lines cost=0.006075 in=314410 cached=282624 out=10612 calls=26`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

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
8e4845c868 SWE-bench
7991111af1 Fixed #30621 -- Fixed crash of __contains lookup for Date/DateTimeRangeField when the right hand side is the same type.
ee6e93ec87 Fixed #30628 -- Adjusted expression identity to differentiate bound fields.
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

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"E108\\|E109\\|list_display\" tests/admin_checks/tests.py | head -60"
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
  "command": "grep -rn \"E108\\|E109\" tests/ | head -40"
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
  "command": "sed -n '440,520p' tests/modeladmin/test_checks.py && grep -n \"class.*ListDisplay\\|list_display\" tests/modeladmin/test_checks.py | head -40"
}
```

**tool result**

```
            prepopulated_fields = {'users': ('name',)}

        self.assertIsInvalid(
            TestModelAdmin, ValidationTestModel,
            "The value of 'prepopulated_fields' refers to 'users', which must not be "
            "a DateTimeField, a ForeignKey, a OneToOneField, or a ManyToManyField.",
            'admin.E028'
        )

    def test_valid_case(self):
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
467:class ListDisplayTests(CheckTestCase):
471:            list_display = 10
475:            "The value of 'list_display' must be a list or tuple.",
481:            list_display = ('non_existent_field',)
485:            "The value of 'list_display[0]' refers to 'non_existent_field', "
493:            list_display = ('users',)
497:            "The value of 'list_display[0]' must not be a ManyToManyField.",
508:            list_display = ('name', 'decade_published_in', 'a_method', a_callable)
513:class ListDisplayLinksCheckTests(CheckTestCase):
517:            list_display_links = 10
521:            "The value of 'list_display_links' must be a list, a tuple, or None.",
527:            list_display_links = ('non_existent_field',)
531:                "The value of 'list_display_links[0]' refers to "
532:                "'non_existent_field', which is not defined in 'list_display'."
536:    def test_missing_in_list_display(self):
538:            list_display_links = ('name',)
542:            "The value of 'list_display_links[0]' refers to 'name', which is not defined in 'list_display'.",
553:            list_display = ('name', 'decade_published_in', 'a_method', a_callable)
554:            list_display_links = ('name', 'decade_published_in', 'a_method', a_callable)
560:            list_display_links = None
564:    def test_list_display_links_check_skipped_if_get_list_display_overridden(self):
566:        list_display_links check is skipped if get_list_display() is overridden.
569:            list_display_links = ['name', 'subtitle']
571:            def get_list_display(self, request):
576:    def test_list_display_link_checked_for_list_tuple_if_get_list_display_overridden(self):
578:        list_display_links is checked for list/tuple/None even if
579:        get_list_display() is overridden.
582:            list_display_links = 'non-list/tuple'
584:            def get_list_display(self, request):
589:            "The value of 'list_display_links' must be a list, a tuple, or None.",
1222:class ListDisplayEditableTests(CheckTestCase):
1223:    def test_list_display_links_is_none(self):
1225:        list_display and list_editable can contain the same values
1226:        when list_display_links is None
1229:            list_display = ['name', 'slug', 'pub_date']
1230:            list_editable = list_display
1231:            list_display_links = None
1234:    def test_list_display_first_item_same_as_list_editable_first_item(self):
1236:        The first item in list_display can be the same as the first in
1240:            list_display = ['name', 'slug', 'pub_date']
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/contrib/admin/checks.py\n@@\n     def _check_list_display_item(self, obj, item, label):\n         if callable(item):\n             return []\n         elif hasattr(obj, item):\n             return []\n-        elif hasattr(obj.model, item):\n-            try:\n-                field = obj.model._meta.get_field(item)\n-            except FieldDoesNotExist:\n-                return []\n-            else:\n-                if isinstance(field, models.ManyToManyField):\n-                    return [\n-                        checks.Error(\n-                            \"The value of '%s' must not be a ManyToManyField.\" % label,\n-                            obj=obj.__class__,\n-                            id='admin.E109',\n-                        )\n-                    ]\n-                return []\n-        else:\n-            return [\n-                checks.Error(\n-                    \"The value of '%s' refers to '%s', which is not a callable, \"\n-                    \"an attribute of '%s', or an attribute or method on '%s.%s'.\" % (\n-                        label, item, obj.__class__.__name__,\n-                        obj.model._meta.app_label, obj.model._meta.object_name,\n-                    ),\n-                    obj=obj.__class__,\n-                    id='admin.E108',\n-                )\n-            ]\n+        try:\n+            field = obj.model._meta.get_field(item)\n+        except FieldDoesNotExist:\n+            try:\n+                field = getattr(obj.model, item)\n+            except AttributeError:\n+                return [\n+                    checks.Error(\n+                        \"The value of '%s' refers to '%s', which is not a callable, \"\n+                        \"an attribute of '%s', or an attribute or method on '%s.%s'.\" % (\n+                            label, item, obj.__class__.__name__,\n+                            obj.model._meta.app_label, obj.model._meta.object_name,\n+                        ),\n+                        obj=obj.__class__,\n+                        id='admin.E108',\n+                    )\n+                ]\n+        if isinstance(field, models.ManyToManyField):\n+            return [\n+                checks.Error(\n+                    \"The value of '%s' must not be a ManyToManyField.\" % label,\n+                    obj=obj.__class__,\n+                    id='admin.E109',\n+                )\n+            ]\n+        return []\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/contrib/admin/checks.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/contrib/admin/checks.py now (1115 lines), around the change:
720:            return []
721:        elif hasattr(obj, item):
722:            return []
723:        try:
724:            field = obj.model._meta.get_field(item)
725:        except FieldDoesNotExist:
726:            try:
727:                field = getattr(obj.model, item)
728:            except AttributeError:
729:                return [
730:                    checks.Error(
731:                        "The value of '%s' refers to '%s', which is not a callable, "
732:                        "an attribute of '%s', or an attribute or method on '%s.%s'." % (
733:                            label, item, obj.__class__.__name__,
734:                            obj.model._meta.app_label, obj.model._meta.object_name,
735:                        ),
736:                        obj=obj.__class__,
737:                        id='admin.E108',
738:                    )
739:                ]
740:        if isinstance(field, models.ManyToManyField):
741:            return [
742:                checks.Error(
743:                    "The value of '%s' must not be a ManyToManyField." % label,
744:                    obj=obj.__class__,
745:                    id='admin.E109',
746:                )
747:            ]
748:        return []
749:
750:    def _check_list_display_links(self, obj):
751:        """ Check that list_display_links is a unique subset of list_display.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,60p' tests/modeladmin/test_checks.py && grep -n \"class ValidationTestModel\" -A60 tests/modeladmin/models.py"
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
            admin_site = AdminSite()
        admin_obj = model_admin(model, admin_site)
        self.assertEqual(admin_obj.check(), [])


class RawIdCheckTests(CheckTestCase):

    def test_not_iterable(self):
        class TestModelAdmin(ModelAdmin):
            raw_id_fields = 10

        self.assertIsInvalid(
            TestModelAdmin, ValidationTestModel,
            "The value of 'raw_id_fields' must be a list or tuple.",
            'admin.E001'
        )

    def test_missing_field(self):
        class TestModelAdmin(ModelAdmin):
            raw_id_fields = ('non_existent_field',)
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

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' tests/modeladmin/models.py"
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
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/models.py\n@@\n class ValidationTestModel(models.Model):\n@@\n     def decade_published_in(self):\n         return self.pub_date.strftime('%Y')[:3] + \"0's\"\n+\n+    class NoneReturningDescriptor:\n+        def __get__(self, instance, owner):\n+            return None\n+\n+    none_returning_descriptor = NoneReturningDescriptor()\n+\n+    class AttributeErrorRaisingDescriptor:\n+        def __get__(self, instance, owner):\n+            raise AttributeError\n+\n+    attribute_error_raising_descriptor = AttributeErrorRaisingDescriptor()\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/models.py now (66 lines), around the change:
49:    def decade_published_in(self):
50:        return self.pub_date.strftime('%Y')[:3] + "0's"
51:
52:    class NoneReturningDescriptor:
53:        def __get__(self, instance, owner):
54:            return None
55:
56:    none_returning_descriptor = NoneReturningDescriptor()
57:
58:    class AttributeErrorRaisingDescriptor:
59:        def __get__(self, instance, owner):
60:            raise AttributeError
61:
62:    attribute_error_raising_descriptor = AttributeErrorRaisingDescriptor()
63:
64:
65:class ValidationTestInlineModel(models.Model):
66:    parent = models.ForeignKey(ValidationTestModel, models.CASCADE)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/models.py\n@@\n from django.contrib.auth.models import User\n from django.db import models\n \n \n+class AttributeErrorRaisingDescriptor:\n+    def __get__(self, instance, owner):\n+        if instance is None:\n+            raise AttributeError\n+        return None\n+\n+\n+class AttributeErrorRaisingField(models.Field):\n+    def contribute_to_class(self, cls, name, **kwargs):\n+        super().contribute_to_class(cls, name, **kwargs)\n+        setattr(cls, self.name, AttributeErrorRaisingDescriptor())\n+\n+\n class Band(models.Model):\n@@\n-    class AttributeErrorRaisingDescriptor:\n-        def __get__(self, instance, owner):\n-            raise AttributeError\n-\n-    attribute_error_raising_descriptor = AttributeErrorRaisingDescriptor()\n+    attribute_error_raising_field = AttributeErrorRaisingField()\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/models.py now (75 lines), around the change:
1:from django.contrib.auth.models import User
2:from django.db import models
3:
4:
5:class AttributeErrorRaisingDescriptor:
6:    def __get__(self, instance, owner):
7:        if instance is None:
8:            raise AttributeError
9:        return None
10:
11:
12:class AttributeErrorRaisingField(models.Field):
13:    def contribute_to_class(self, cls, name, **kwargs):
14:        super().contribute_to_class(cls, name, **kwargs)
15:        setattr(cls, self.name, AttributeErrorRaisingDescriptor())
16:
17:
18:class Band(models.Model):
…
68:
69:    none_returning_descriptor = NoneReturningDescriptor()
70:
71:    attribute_error_raising_field = AttributeErrorRaisingField()
72:
73:
74:class ValidationTestInlineModel(models.Model):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/test_checks.py\n@@\n     def test_invalid_field_type(self):\n         class TestModelAdmin(ModelAdmin):\n             list_display = ('users',)\n \n         self.assertIsInvalid(\n             TestModelAdmin, ValidationTestModel,\n             \"The value of 'list_display[0]' must not be a ManyToManyField.\",\n             'admin.E109'\n         )\n \n+    def test_none_returning_descriptor(self):\n+        class TestModelAdmin(ModelAdmin):\n+            list_display = ('none_returning_descriptor',)\n+\n+        self.assertIsValid(TestModelAdmin, ValidationTestModel)\n+\n+    def test_attribute_error_raising_descriptor(self):\n+        class TestModelAdmin(ModelAdmin):\n+            list_display = ('attribute_error_raising_field',)\n+\n+        self.assertIsValid(TestModelAdmin, ValidationTestModel)\n+\n     def test_valid_case(self):\n         def a_callable(obj):\n             pass\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/test_checks.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/test_checks.py now (1453 lines), around the change:
498:            'admin.E109'
499:        )
500:
501:    def test_none_returning_descriptor(self):
502:        class TestModelAdmin(ModelAdmin):
503:            list_display = ('none_returning_descriptor',)
504:
505:        self.assertIsValid(TestModelAdmin, ValidationTestModel)
506:
507:    def test_attribute_error_raising_descriptor(self):
508:        class TestModelAdmin(ModelAdmin):
509:            list_display = ('attribute_error_raising_field',)
510:
511:        self.assertIsValid(TestModelAdmin, ValidationTestModel)
512:
513:    def test_valid_case(self):
514:        def a_callable(obj):
515:            pass
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest tests/modeladmin/test_checks.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py modeladmin.test_checks -v1 2>&1 | tail -30"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
.........................................................................................................................
----------------------------------------------------------------------
Ran 121 tests in 0.132s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py modeladmin -v1 2>&1 | tail -10 && git diff --stat"
}
```

**tool result**

```
FAILED (errors=2)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
 django/contrib/admin/checks.py  | 41 ++++++++++++++++++++---------------------
 tests/modeladmin/models.py      | 21 +++++++++++++++++++++
 tests/modeladmin/test_checks.py | 12 ++++++++++++
 3 files changed, 53 insertions(+), 21 deletions(-)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py modeladmin -v1 2>&1 | grep -A20 \"ERROR\\|FAIL:\" | head -60"
}
```

**tool result**

```
ERROR: test_get_deleted_objects (modeladmin.tests.ModelAdminTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/testbed/django/db/backends/utils.py", line 86, in _execute
    return self.cursor.execute(sql, params)
  File "/testbed/django/db/backends/sqlite3/base.py", line 394, in execute
    return Database.Cursor.execute(self, query, params)
sqlite3.OperationalError: no such column: modeladmin_validationtestmodel.attribute_error_raising_field

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/tests/modeladmin/tests.py", line 696, in test_get_deleted_objects
    deletable_objects, model_count, perms_needed, protected = ma.get_deleted_objects([self.band], request)
  File "/testbed/django/contrib/admin/options.py", line 1813, in get_deleted_objects
    return get_deleted_objects(objs, request, self.admin_site)
  File "/testbed/django/contrib/admin/utils.py", line 118, in get_deleted_objects
--
ERROR: test_get_deleted_objects_with_custom_has_delete_permission (modeladmin.tests.ModelAdminTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/testbed/django/db/backends/utils.py", line 86, in _execute
    return self.cursor.execute(sql, params)
  File "/testbed/django/db/backends/sqlite3/base.py", line 394, in execute
    return Database.Cursor.execute(self, query, params)
sqlite3.OperationalError: no such column: modeladmin_validationtestmodel.attribute_error_raising_field

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/tests/modeladmin/tests.py", line 716, in test_get_deleted_objects_with_custom_has_delete_permission
    deletable_objects, model_count, perms_needed, protected = ma.get_deleted_objects([self.band], request)
  File "/testbed/django/contrib/admin/options.py", line 1813, in get_deleted_objects
    return get_deleted_objects(objs, request, self.admin_site)
  File "/testbed/django/contrib/admin/utils.py", line 118, in get_deleted_objects
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n \"self.concrete\\|concrete =\" django/db/models/fields/__init__.py | head -20 && grep -n \"def get_field\" -A30 django/db/models/options.py | head -50"
}
```

**tool result**

```
722:        self.concrete = self.column is not None
560:    def get_field(self, field_name):
561-        """
562-        Return a field instance given the name of a forward or reverse field.
563-        """
564-        try:
565-            # In order to avoid premature loading of the relation tree
566-            # (expensive) we prefer checking if the field is a forward field.
567-            return self._forward_fields_map[field_name]
568-        except KeyError:
569-            # If the app registry is not ready, reverse fields are
570-            # unavailable, therefore we throw a FieldDoesNotExist exception.
571-            if not self.apps.models_ready:
572-                raise FieldDoesNotExist(
573-                    "%s has no field named '%s'. The app cache isn't ready yet, "
574-                    "so if this is an auto-created related field, it won't "
575-                    "be available yet." % (self.object_name, field_name)
576-                )
577-
578-        try:
579-            # Retrieve field instance by name from cached or just-computed
580-            # field map.
581-            return self.fields_map[field_name]
582-        except KeyError:
583-            raise FieldDoesNotExist("%s has no field named '%s'" % (self.object_name, field_name))
584-
585-    def get_base_chain(self, model):
586-        """
587-        Return a list of parent classes leading to `model` (ordered from
588-        closest to most distant ancestor). This has to handle the case where
589-        `model` is a grandparent or even more distant relation.
590-        """
--
738:    def get_fields(self, include_parents=True, include_hidden=False):
739-        """
740-        Return a list of fields associated to the model. By default, include
741-        forward and reverse fields, fields derived from inheritance, but not
742-        hidden fields. The returned fields can be changed using the parameters:
743-
744-        - include_parents: include fields derived from inheritance
745-        - include_hidden:  include fields that have a related_name that
746-                           starts with a "+"
747-        """
748-        if include_parents is False:
749-            include_parents = PROXY_PARENTS
750-        return self._get_fields(include_parents=include_parents, include_hidden=include_hidden)
751-
752-    def _get_fields(self, forward=True, reverse=True, include_parents=True, include_hidden=False,
753-                    seen_models=None):
754-        """
755-        Internal helper function to return fields of the model.
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/models.py\n@@\n class AttributeErrorRaisingField(models.Field):\n+    def __init__(self, *args, **kwargs):\n+        super().__init__(*args, **kwargs)\n+        self.column = None\n+        self.concrete = False\n+\n     def contribute_to_class(self, cls, name, **kwargs):\n         super().contribute_to_class(cls, name, **kwargs)\n         setattr(cls, self.name, AttributeErrorRaisingDescriptor())\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/models.py now (80 lines), around the change:
10:
11:
12:class AttributeErrorRaisingField(models.Field):
13:    def __init__(self, *args, **kwargs):
14:        super().__init__(*args, **kwargs)
15:        self.column = None
16:        self.concrete = False
17:
18:    def contribute_to_class(self, cls, name, **kwargs):
19:        super().contribute_to_class(cls, name, **kwargs)
20:        setattr(cls, self.name, AttributeErrorRaisingDescriptor())
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py modeladmin -v1 2>&1 | tail -8"
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
  "command": "cd /testbed && python tests/runtests.py modeladmin -v1 2>&1 | grep -E \"^(OK|FAILED|Ran)\" "
}
```

**tool result**

```
Ran 157 tests in 0.348s
FAILED (errors=2)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py modeladmin -v1 2>&1 | grep -B2 -A15 \"ERROR:\" | head -50"
}
```

**tool result**

```
................................................................................................................................................EE...........
======================================================================
ERROR: test_get_deleted_objects (modeladmin.tests.ModelAdminTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/testbed/django/db/backends/utils.py", line 86, in _execute
    return self.cursor.execute(sql, params)
  File "/testbed/django/db/backends/sqlite3/base.py", line 394, in execute
    return Database.Cursor.execute(self, query, params)
sqlite3.OperationalError: no such column: modeladmin_validationtestmodel.attribute_error_raising_field

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
--

======================================================================
ERROR: test_get_deleted_objects_with_custom_has_delete_permission (modeladmin.tests.ModelAdminTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/testbed/django/db/backends/utils.py", line 86, in _execute
    return self.cursor.execute(sql, params)
  File "/testbed/django/db/backends/sqlite3/base.py", line 394, in execute
    return Database.Cursor.execute(self, query, params)
sqlite3.OperationalError: no such column: modeladmin_validationtestmodel.attribute_error_raising_field

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/modeladmin/models.py\n@@\n-class AttributeErrorRaisingField(models.Field):\n-    def __init__(self, *args, **kwargs):\n-        super().__init__(*args, **kwargs)\n-        self.column = None\n-        self.concrete = False\n-\n+class AttributeErrorRaisingField(models.IntegerField):\n     def contribute_to_class(self, cls, name, **kwargs):\n         super().contribute_to_class(cls, name, **kwargs)\n         setattr(cls, self.name, AttributeErrorRaisingDescriptor())\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/modeladmin/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/modeladmin/models.py now (75 lines), around the change:
9:        return None
10:
11:
12:class AttributeErrorRaisingField(models.IntegerField):
13:    def contribute_to_class(self, cls, name, **kwargs):
14:        super().contribute_to_class(cls, name, **kwargs)
15:        setattr(cls, self.name, AttributeErrorRaisingDescriptor())
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py modeladmin -v1 2>&1 | grep -E \"^(OK|FAILED|Ran)\""
}
```

**tool result**

```
Ran 157 tests in 0.233s
OK
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py admin_checks modeladmin -v1 2>&1 | grep -E \"^(OK|FAILED|Ran)\" && git diff -- django/contrib/admin/checks.py"
}
```

**tool result**

```
Ran 211 tests in 0.227s
OK
diff --git a/django/contrib/admin/checks.py b/django/contrib/admin/checks.py
index f82c20c2f1..ccebbbb900 100644
--- a/django/contrib/admin/checks.py
+++ b/django/contrib/admin/checks.py
@@ -720,33 +720,32 @@ class ModelAdminChecks(BaseModelAdminChecks):
             return []
         elif hasattr(obj, item):
             return []
-        elif hasattr(obj.model, item):
+        try:
+            field = obj.model._meta.get_field(item)
+        except FieldDoesNotExist:
             try:
-                field = obj.model._meta.get_field(item)
-            except FieldDoesNotExist:
-                return []
-            else:
-                if isinstance(field, models.ManyToManyField):
-                    return [
-                        checks.Error(
-                            "The value of '%s' must not be a ManyToManyField." % label,
-                            obj=obj.__class__,
-                            id='admin.E109',
-                        )
-                    ]
-                return []
-        else:
+                field = getattr(obj.model, item)
+            except AttributeError:
+                return [
+                    checks.Error(
+                        "The value of '%s' refers to '%s', which is not a callable, "
+                        "an attribute of '%s', or an attribute or method on '%s.%s'." % (
+                            label, item, obj.__class__.__name__,
+                            obj.model._meta.app_label, obj.model._meta.object_name,
+                        ),
+                        obj=obj.__class__,
+                        id='admin.E108',
+                    )
+                ]
+        if isinstance(field, models.ManyToManyField):
             return [
                 checks.Error(
-                    "The value of '%s' refers to '%s', which is not a callable, "
-                    "an attribute of '%s', or an attribute or method on '%s.%s'." % (
-                        label, item, obj.__class__.__name__,
-                        obj.model._meta.app_label, obj.model._meta.object_name,
-                    ),
+                    "The value of '%s' must not be a ManyToManyField." % label,
                     obj=obj.__class__,
-                    id='admin.E108',
+                    id='admin.E109',
                 )
             ]
+        return []
 
     def _check_list_display_links(self, obj):
         """ Check that list_display_links is a unique subset of list_display.
```

**assistant**

````
Implemented the fix.

## Changes

**`django/contrib/admin/checks.py`** — rewrote `_check_list_display_item` so it no longer gates field lookup on `hasattr(obj.model, item)`:

- Tries `obj.model._meta.get_field(item)` first.
- If that raises `FieldDoesNotExist`, falls back to `getattr(obj.model, item)`.
- Only returns `admin.E108` when **both** lookups fail.
- Checks `isinstance(field, models.ManyToManyField)` for `admin.E109` regardless of which lookup produced the field.
- No longer conflates a `None` field value with a failed lookup.

This fixes the `PositionField` case (where `getattr(model, item)` raises but `get_field()` succeeds) while preserving the original #28490 fix (descriptors returning `None` are valid) and correctly reporting E109 for M2M fields found via `get_field()`.

**`tests/modeladmin/models.py`** — added test fixtures:
- `none_returning_descriptor` (descriptor returning `None`)
- `attribute_error_raising_field` (a real field whose class-level descriptor raises `AttributeError`, mimicking `PositionField`)

**`tests/modeladmin/test_checks.py`** — added regression tests for both cases.

## Verification

```
python tests/runtests.py admin_checks modeladmin -v1
Ran 211 tests ... OK
```

No commits, checkouts, resets, or stashes were performed; `.memdoor/` was left untouched.
````

## Run folder `team-solve-2026-11-06T105200`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
8e4845c868cbdf33a63e5e804b30d8dabb7964f3
```

### `baseline-check.log`

```
check: ./tests/runtests.py admin_checks
......................................................
----------------------------------------------------------------------
Ran 54 tests in 0.059s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/django/contrib/admin/checks.py b/django/contrib/admin/checks.py
index f82c20c2f1..ccebbbb900 100644
--- a/django/contrib/admin/checks.py
+++ b/django/contrib/admin/checks.py
@@ -720,33 +720,32 @@ class ModelAdminChecks(BaseModelAdminChecks):
             return []
         elif hasattr(obj, item):
             return []
-        elif hasattr(obj.model, item):
+        try:
+            field = obj.model._meta.get_field(item)
+        except FieldDoesNotExist:
             try:
-                field = obj.model._meta.get_field(item)
-            except FieldDoesNotExist:
-                return []
-            else:
-                if isinstance(field, models.ManyToManyField):
-                    return [
-                        checks.Error(
-                            "The value of '%s' must not be a ManyToManyField." % label,
-                            obj=obj.__class__,
-                            id='admin.E109',
-                        )
-                    ]
-                return []
-        else:
+                field = getattr(obj.model, item)
+            except AttributeError:
+                return [
+                    checks.Error(
+                        "The value of '%s' refers to '%s', which is not a callable, "
+                        "an attribute of '%s', or an attribute or method on '%s.%s'." % (
+                            label, item, obj.__class__.__name__,
+                            obj.model._meta.app_label, obj.model._meta.object_name,
+                        ),
+                        obj=obj.__class__,
+                        id='admin.E108',
+                    )
+                ]
+        if isinstance(field, models.ManyToManyField):
             return [
                 checks.Error(
-                    "The value of '%s' refers to '%s', which is not a callable, "
-                    "an attribute of '%s', or an attribute or method on '%s.%s'." % (
-                        label, item, obj.__class__.__name__,
-                        obj.model._meta.app_label, obj.model._meta.object_name,
-                    ),
+                    "The value of '%s' must not be a ManyToManyField." % label,
                     obj=obj.__class__,
-                    id='admin.E108',
+                    id='admin.E109',
                 )
             ]
+        return []
 
     def _check_list_display_links(self, obj):
         """ Check that list_display_links is a unique subset of list_display.
diff --git a/tests/modeladmin/models.py b/tests/modeladmin/models.py
index c0d3c772c9..07cb928f44 100644
--- a/tests/modeladmin/models.py
+++ b/tests/modeladmin/models.py
@@ -2,6 +2,19 @@ from django.contrib.auth.models import User
 from django.db import models
 
 
+class AttributeErrorRaisingDescriptor:
+    def __get__(self, instance, owner):
+        if instance is None:
+            raise AttributeError
+        return None
+
+
+class AttributeErrorRaisingField(models.IntegerField):
+    def contribute_to_class(self, cls, name, **kwargs):
+        super().contribute_to_class(cls, name, **kwargs)
+        setattr(cls, self.name, AttributeErrorRaisingDescriptor())
+
+
 class Band(models.Model):
     name = models.CharField(max_length=100)
     bio = models.TextField()
@@ -49,6 +62,14 @@ class ValidationTestModel(models.Model):
     def decade_published_in(self):
         return self.pub_date.strftime('%Y')[:3] + "0's"
 
+    class NoneReturningDescriptor:
+        def __get__(self, instance, owner):
+            return None
+
+    none_returning_descriptor = NoneReturningDescriptor()
+
+    attribute_error_raising_field = AttributeErrorRaisingField()
+
 
 class ValidationTestInlineModel(models.Model):
     parent = models.ForeignKey(ValidationTestModel, models.CASCADE)
diff --git a/tests/modeladmin/test_checks.py b/tests/modeladmin/test_checks.py
index a1b7001f68..ffb8e30745 100644
--- a/tests/modeladmin/test_checks.py
+++ b/tests/modeladmin/test_checks.py
@@ -498,6 +498,18 @@ class ListDisplayTests(CheckTestCase):
             'admin.E109'
         )
 
+    def test_none_returning_descriptor(self):
+        class TestModelAdmin(ModelAdmin):
+            list_display = ('none_returning_descriptor',)
+
+        self.assertIsValid(TestModelAdmin, ValidationTestModel)
+
+    def test_attribute_error_raising_descriptor(self):
+        class TestModelAdmin(ModelAdmin):
+            list_display = ('attribute_error_raising_field',)
+
+        self.assertIsValid(TestModelAdmin, ValidationTestModel)
+
     def test_valid_case(self):
         def a_callable(obj):
             pass
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

## Deliverable

changes to this tree

## Check

`./tests/runtests.py admin_checks`

## Scope

`django/contrib/admin/checks.py`
`tests/admin_checks/`

## Done when

- `_check_list_display_item` returns no error when `obj.model._meta.get_field(item)` resolves the item even if `hasattr(obj.model, item)` is false.
- `admin.E108` is returned only when both `obj.model._meta.get_field(item)` raises `FieldDoesNotExist` and `getattr(obj.model, item)` raises `AttributeError`.
- `admin.E109` is returned when the resolved field is a `models.ManyToManyField`, including when it was resolved through `get_field` after `hasattr` was false.
- A resolved field value of `None` is not treated as a missing field and does not produce `admin.E108`.
- Callable `list_display` items and attributes of the `ModelAdmin` still pass without error.



# plan.md

## Deliverable
changes to this tree

## Check
`./tests/runtests.py admin_checks`

## Scope
`django/contrib/admin/checks.py`
`tests/admin_checks/`

## Done when
- `_check_list_display_item` returns no error when `obj.model._meta.get_field(item)` resolves the item even if `hasattr(obj.model, item)` is false.
- `admin.E108` is returned only when both `obj.model._meta.get_field(item)` raises `FieldDoesNotExist` and `getattr(obj.model, item)` raises `AttributeError`.
- `admin.E109` is returned when the resolved field is a `models.ManyToManyField`, including when it was resolved through `get_field` after `hasattr` was false.
- A resolved field value of `None` is not treated as a missing field and does not produce `admin.E108`.
- Callable `list_display` items and attributes of the `ModelAdmin` still pass without error.

## Approach
Decompose into one behavior change in `django/contrib/admin/checks.py` and regression coverage under `tests/admin_checks/`. In `_check_list_display_item`, keep the early `callable(item)` and `hasattr(obj, item)` returns, remove the `hasattr(obj.model, item)` gate, try `obj.model._meta.get_field(item)` first, fall back to `getattr(obj.model, item)` only on `FieldDoesNotExist`, return `admin.E108` only if that fallback raises `AttributeError`, then check the resolved field for `models.ManyToManyField` and return `admin.E109` if so.

Candidate approaches:
- Use the prompt’s try/except ordering: `get_field` first, `getattr` fallback, no `None` sentinel. This is the most direct and avoids conflating a descriptor returning `None` with a missing attribute.
- Keep the `hasattr(obj.model, item)` check but still attempt `get_field` when it is false. This is behaviorally equivalent but leaves two paths for the same decision and is easier to get wrong.
- Use a sentinel default with `getattr(obj.model, item, sentinel)`. This avoids `None` conflation but still needs `get_field` first and adds more branching than the try/except form.


# django/contrib/admin/checks.py

```
from itertools import chain

from django.apps import apps
from django.conf import settings
from django.contrib.admin.utils import (
    NotRelationField, flatten, get_fields_from_path,
)
from django.core import checks
from django.core.exceptions import FieldDoesNotExist
from django.db import models
from django.db.models.constants import LOOKUP_SEP
from django.db.models.expressions import Combinable, F, OrderBy
from django.forms.models import (
    BaseModelForm, BaseModelFormSet, _get_foreign_key,
)
from django.template import engines
from django.template.backends.django import DjangoTemplates
from django.utils.module_loading import import_string


def _issubclass(cls, classinfo):
    """
    issubclass() variant that doesn't raise an exception if cls isn't a
    class.
    """
    try:
        return issubclass(cls, classinfo)
    except TypeError:
        return False


def _contains_subclass(class_path, candidate_paths):
    """
    Return whether or not a dotted class path (or a subclass of that class) is
    found in a list of candidate paths.
    """
    cls = import_string(class_path)
    for path in candidate_paths:
        try:
            candidate_cls = import_string(path)
        except ImportError:
            # ImportErrors are raised elsewhere.
            continue
        if _issubclass(candidate_cls, cls):
            return True
    return False


def check_admin_app(app_configs, **kwargs):
    from django.contrib.admin.sites import all_sites
    errors = []
    for site in all_sites:
        errors.extend(site.check(app_configs))
    return errors


def check_dependencies(**kwargs):
    """
    Check that the admin's dependencies are correctly installed.
    """
    if not apps.is_installed('django.contrib.admin'):
        return []
    errors = []
    app_dependencies = (
        ('django.contrib.contenttypes', 401),
        ('django.contrib.auth', 405),
        ('django.contrib.messages', 406),
    )
    for app_name, error_code in app_dependencies:
        if not apps.is_installed(app_name):
            errors.append(checks.Error(
                "'%s' must be in INSTALLED_APPS in order to use the admin "
                "application." % app_name,
                id='admin.E%d' % error_code,
            ))
    for engine in engines.all():
        if isinstance(engine, DjangoTemplates):
            django_templates_instance = engine.engine
            break
    else:
        django_templates_instance = None
    if not django_templates_instance:
        errors.append(checks.Error(
            "A 'django.template.backends.django.DjangoTemplates' instance "
            "must be configured in TEMPLATES in order to use the admin "
            "application.",
            id='admin.E403',
        ))
    else:
        if ('django.contrib.auth.context_processors.auth'
                not in django_templates_instance.context_processors and
                _contains_subclass('django.contrib.auth.backends.ModelBackend', settings.AUTHENTICATION_BACKENDS)):
            errors.append(checks.Error(
                "'django.contrib.auth.context_processors.auth' must be "
                "enabled in DjangoTemplates (TEMPLATES) if using the default "
                "auth backend in order to use the admin application.",
                id='admin.E402',
            ))
        if ('django.contrib.messages.context_processors.messages'
                not in django_templates_instance.context_processors):
            errors.append(checks.Error(
                "'django.contrib.messages.context_processors.messages' must "
                "be enabled in DjangoTemplates (TEMPLATES) in order to use "
                "the admin application.",
                id='admin.E404',
            ))

    if not _contains_subclass('django.contrib.auth.middleware.AuthenticationMiddleware', settings.MIDDLEWARE):
        errors.append(checks.Error(
            "'django.contrib.auth.middleware.AuthenticationMiddleware' must "
            "be in MIDDLEWARE in order to use the admin application.",
            id='admin.E408',
        ))
    if not _contains_subclass('django.contrib.messages.middleware.MessageMiddleware', settings.MIDDLEWARE):
        errors.append(checks.Error(
            "'django.contrib.messages.middleware.MessageMiddleware' must "
            "be in MIDDLEWARE in order to use the admin application.",
            id='admin.E409',
        ))
    if not _contains_subclass('django.contrib.sessions.middleware.SessionMiddleware', settings.MIDDLEWARE):
        errors.append(checks.Error(
            "'django.contrib.sessions.middleware.SessionMiddleware' must "
            "be in MIDDLEWARE in order to use the admin application.",
            id='admin.E410',
        ))
    return errors


class BaseModelAdminChecks:

    def check(self, admin_obj, **kwargs):
        return [
            *self._check_autocomplete_fields(admin_obj),
            *self._check_raw_id_fields(admin_obj),
            *self._check_fields(admin_obj),
            *self._check_fieldsets(admin_obj),
            *self._check_exclude(admin_obj),
            *self._check_form(admin_obj),
            *self._check_filter_vertical(admin_obj),
            *self._check_filter_horizontal(admin_obj),
            *self._check_radio_fields(admin_obj),
            *self._check_prepopulated_fields(admin_obj),
            *self._check_view_on_site_url(admin_obj),
            *self._check_ordering(admin_obj),
            *self._check_readonly_fields(admin_obj),
        ]

    def _check_autocomplete_fields(self, obj):
        """
        Check that `autocomplete_fields` is a list or tuple of model fields.
        """
        if not isinstance(obj.autocomplete_fields, (list, tuple)):
            return must_be('a list or tuple', option='autocomplete_fields', obj=obj, id='admin.E036')
        else:
            return list(chain.from_iterable([
                self._check_autocomplete_fields_item(obj, field_name, 'autocomplete_fields[%d]' % index)
                for index, field_name in enumerate(obj.autocomplete_fields)
            ]))

    def _check_autocomplete_fields_item(self, obj, field_name, label):
        """
        Check that an item in `autocomplete_fields` is a ForeignKey or a
        ManyToManyField and that the item has a related ModelAdmin with
        search_fields defined.
        """
        try:
            field = obj.model._meta.get_field(field_name)
        except FieldDoesNotExist:
            return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E037')
        else:
            if not field.many_to_many and not isinstance(field, models.ForeignKey):
                return must_be(
                    'a foreign key or a many-to-many field',
                    option=label, obj=obj, id='admin.E038'
                )
            related_admin = obj.admin_site._registry.get(field.remote_field.model)
            if related_admin is None:
                return [
                    checks.Error(
                        'An admin for model "%s" has to be registered '
                        'to be referenced by %s.autocomplete_fields.' % (
                            field.remote_field.model.__name__,
                            type(obj).__name__,
                        ),
                        obj=obj.__class__,
                        id='admin.E039',
                    )
                ]
            elif not related_admin.search_fields:
                return [
                    checks.Error(
                        '%s must define "search_fields", because it\'s '
                        'referenced by %s.autocomplete_fields.' % (
                            related_admin.__class__.__name__,
                            type(obj).__name__,
                        ),
                        obj=obj.__class__,
                        id='admin.E040',
                    )
                ]
            return []

    def _check_raw_id_fields(self, obj):
        """ Check that `raw_id_fields` only contains field names that are listed
        on the model. """

        if not isinstance(obj.raw_id_fields, (list, tuple)):
            return must_be('a list or tuple', option='raw_id_fields', obj=obj, id='admin.E001')
        else:
            return list(chain.from_iterable(
                self._check_raw_id_fields_item(obj, field_name, 'raw_id_fields[%d]' % index)
                for index, field_name in enumerate(obj.raw_id_fields)
            ))

    def _check_raw_id_fields_item(self, obj, field_name, label):
        """ Check an item of `raw_id_fields`, i.e. check that field named
        `field_name` exists in model `model` and is a ForeignKey or a
        ManyToManyField. """

        try:
            field = obj.model._meta.get_field(field_name)
        except FieldDoesNotExist:
            return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E002')
        else:
            if not field.many_to_many and not isinstance(field, models.ForeignKey):
                return must_be('a foreign key or a many-to-many field', option=label, obj=obj, id='admin.E003')
            else:
                return []

    def _check_fields(self, obj):
        """ Check that `fields` only refer to existing fields, doesn't contain
        duplicates. Check if at most one of `fields` and `fieldsets` is defined.
        """

        if obj.fields is None:
            return []
        elif not isinstance(obj.fields, (list, tuple)):
            return must_be('a list or tuple', option='fields', obj=obj, id='admin.E004')
        elif obj.fieldsets:
            return [
                checks.Error(
                    "Both 'fieldsets' and 'fields' are specified.",
                    obj=obj.__class__,
                    id='admin.E005',
                )
            ]
        fields = flatten(obj.fields)
        if len(fields) != len(set(fields)):
            return [
                checks.Error(
                    "The value of 'fields' contains duplicate field(s).",
                    obj=obj.__class__,
                    id='admin.E006',
                )
            ]

        return list(chain.from_iterable(
            self._check_field_spec(obj, field_name, 'fields')
            for field_name in obj.fields
        ))

    def _check_fieldsets(self, obj):
        """ Check that fieldsets is properly formatted and doesn't contain
        duplicates. """

        if obj.fieldsets is None:
            return []
        elif not isinstance(obj.fieldsets, (list, tuple)):
            return must_be('a list or tuple', option='fieldsets', obj=obj, id='admin.E007')
        else:
            seen_fields = []
            return list(chain.from_iterable(
                self._check_fieldsets_item(obj, fieldset, 'fieldsets[%d]' % index, seen_fields)
                for index, fieldset in enumerate(obj.fieldsets)
            ))

    def _check_fieldsets_item(self, obj, fieldset, label, seen_fields):
        """ Check an item of `fieldsets`, i.e. check that this is a pair of a
        set name and a dictionary containing "fields" key. """

        if not isinstance(fieldset, (list, tuple)):
            return must_be('a list or tuple', option=label, obj=obj, id='admin.E008')
        elif len(fieldset) != 2:
            return must_be('of length 2', option=label, obj=obj, id='admin.E009')
        elif not isinstance(fieldset[1], dict):
            return must_be('a dictionary', option='%s[1]' % label, obj=obj, id='admin.E010')
        elif 'fields' not in fieldset[1]:
            return [
                checks.Error(
                    "The value of '%s[1]' must contain the key 'fields'." % label,
                    obj=obj.__class__,
                    id='admin.E011',
                )
            ]
        elif not isinstance(fieldset[1]['fields'], (list, tuple)):
            return must_be('a list or tuple', option="%s[1]['fields']" % label, obj=obj, id='admin.E008')

        seen_fields.extend(flatten(fieldset[1]['fields']))
        if len(seen_fields) != len(set(seen_fields)):
            return [
                checks.Error(
                    "There are duplicate field(s) in '%s[1]'." % label,
                    obj=obj.__class__,
                    id='admin.E012',
                )
            ]
        return list(chain.from_iterable(
            self._check_field_spec(obj, fieldset_fields, '%s[1]["fields"]' % label)
            for fieldset_fields in fieldset[1]['fields']
        ))

    def _check_field_spec(self, obj, fields, label):
        """ `fields` should be an item of `fields` or an item of
        fieldset[1]['fields'] for any `fieldset` in `fieldsets`. It should be a
        field name or a tuple of field names. """

        if isinstance(fields, tuple):
            return list(chain.from_iterable(
                self._check_field_spec_item(obj, field_name, "%s[%d]" % (label, index))
                for index, field_name in enumerate(fields)
            ))
        else:
            return self._check_field_spec_item(obj, fields, label)

    def _check_field_spec_item(self, obj, field_name, label):
        if field_name in obj.readonly_fields:
            # Stuff can be put in fields that isn't actually a model field if
            # it's in readonly_fields, readonly_fields will handle the
            # validation of such things.
            return []
        else:
            try:
                field = obj.model._meta.get_field(field_name)
            except FieldDoesNotExist:
                # If we can't find a field on the model that matches, it could
                # be an extra field on the form.
                return []
            else:
                if (isinstance(field, models.ManyToManyField) and
                        not field.remote_field.through._meta.auto_created):
                    return [
                        checks.Error(
                            "The value of '%s' cannot include the ManyToManyField '%s', "
                            "because that field manually specifies a relationship model."
                            % (label, field_name),
                            obj=obj.__class__,
                            id='admin.E013',
                        )
                    ]
                else:
                    return []

    def _check_exclude(self, obj):
        """ Check that exclude is a sequence without duplicates. """

        if obj.exclude is None:  # default value is None
            return []
        elif not isinstance(obj.exclude, (list, tuple)):
            return must_be('a list or tuple', option='exclude', obj=obj, id='admin.E014')
        elif len(obj.exclude) > len(set(obj.exclude)):
            return [
                checks.Error(
                    "The value of 'exclude' contains duplicate field(s).",
                    obj=obj.__class__,
                    id='admin.E015',
                )
            ]
        else:
            return []

    def _check_form(self, obj):
        """ Check that form subclasses BaseModelForm. """
        if not _issubclass(obj.form, BaseModelForm):
            return must_inherit_from(parent='BaseModelForm', option='form',
                                     obj=obj, id='admin.E016')
        else:
            return []

    def _check_filter_vertical(self, obj):
        """ Check that filter_vertical is a sequence of field names. """
        if not isinstance(obj.filter_vertical, (list, tuple)):
            return must_be('a list or tuple', option='filter_vertical', obj=obj, id='admin.E017')
        else:
            return list(chain.from_iterable(
                self._check_filter_item(obj, field_name, "filter_vertical[%d]" % index)
                for index, field_name in enumerate(obj.filter_vertical)
            ))

    def _check_filter_horizontal(self, obj):
        """ Check that filter_horizontal is a sequence of field names. """
        if not isinstance(obj.filter_horizontal, (list, tuple)):
            return must_be('a list or tuple', option='filter_horizontal', obj=obj, id='admin.E018')
        else:
            return list(chain.from_iterable(
                self._check_filter_item(obj, field_name, "filter_horizontal[%d]" % index)
                for index, field_name in enumerate(obj.filter_horizontal)
            ))

    def _check_filter_item(self, obj, field_name, label):
        """ Check one item of `filter_vertical` or `filter_horizontal`, i.e.
        check that given field exists and is a ManyToManyField. """

        try:
            field = obj.model._meta.get_field(field_name)
        except FieldDoesNotExist:
            return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E019')
        else:
            if not field.many_to_many:
                return must_be('a many-to-many field', option=label, obj=obj, id='admin.E020')
            else:
                return []

    def _check_radio_fields(self, obj):
        """ Check that `radio_fields` is a dictionary. """
        if not isinstance(obj.radio_fields, dict):
            return must_be('a dictionary', option='radio_fields', obj=obj, id='admin.E021')
        else:
            return list(chain.from_iterable(
                self._check_radio_fields_key(obj, field_name, 'radio_fields') +
                self._check_radio_fields_value(obj, val, 'radio_fields["%s"]' % field_name)
                for field_name, val in obj.radio_fields.items()
            ))

    def _check_radio_fields_key(self, obj, field_name, label):
        """ Check that a key of `radio_fields` dictionary is name of existing
        field and that the field is a ForeignKey or has `choices` defined. """

        try:
            field = obj.model._meta.get_field(field_name)
        except FieldDoesNotExist:
            return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E022')
        else:
            if not (isinstance(field, models.ForeignKey) or field.choices):
                return [
                    checks.Error(
                        "The value of '%s' refers to '%s', which is not an "
                        "instance of ForeignKey, and does not have a 'choices' definition." % (
                            label, field_name
                        ),
                        obj=obj.__class__,
                        id='admin.E023',
                    )
                ]
            else:
                return []

    def _check_radio_fields_value(self, obj, val, label):
        """ Check type of a value of `radio_fields` dictionary. """

        from django.contrib.admin.options import HORIZONTAL, VERTICAL

        if val not in (HORIZONTAL, VERTICAL):
            return [
                checks.Error(
                    "The value of '%s' must be either admin.HORIZONTAL or admin.VERTICAL." % label,
                    obj=obj.__class__,
                    id='admin.E024',
                )
            ]
        else:
            return []

    def _check_view_on_site_url(self, obj):
        if not callable(obj.view_on_site) and not isinstance(obj.view_on_site, bool):
            return [
                checks.Error(
                    "The value of 'view_on_site' must be a callable or a boolean value.",
                    obj=obj.__class__,
                    id='admin.E025',
                )
            ]
        else:
            return []

    def _check_prepopulated_fields(self, obj):
        """ Check that `prepopulated_fields` is a dictionary containing allowed
        field types. """
        if not isinstance(obj.prepopulated_fields, dict):
            return must_be('a dictionary', option='prepopulated_fields', obj=obj, id='admin.E026')
        else:
            return list(chain.from_iterable(
                self._check_prepopulated_fields_key(obj, field_name, 'prepopulated_fields') +
                self._check_prepopulated_fields_value(obj, val, 'prepopulated_fields["%s"]' % field_name)
                for field_name, val in obj.prepopulated_fields.items()
            ))

    def _check_prepopulated_fields_key(self, obj, field_name, label):
        """ Check a key of `prepopulated_fields` dictionary, i.e. check that it
        is a name of existing field and the field is one of the allowed types.
        """

        try:
            field = obj.model._meta.get_field(field_name)
        except FieldDoesNotExist:
            return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E027')
        else:
            if isinstance(field, (models.DateTimeField, models.ForeignKey, models.ManyToManyField)):
                return [
                    checks.Error(
                        "The value of '%s' refers to '%s', which must not be a DateTimeField, "
                        "a ForeignKey, a OneToOneField, or a ManyToManyField." % (label, field_name),
                        obj=obj.__class__,
                        id='admin.E028',
                    )
                ]
            else:
                return []

    def _check_prepopulated_fields_value(self, obj, val, label):
        """ Check a value of `prepopulated_fields` dictionary, i.e. it's an
        iterable of existing fields. """

        if not isinstance(val, (list, tuple)):
            return must_be('a list or tuple', option=label, obj=obj, id='admin.E029')
        else:
            return list(chain.from_iterable(
                self._check_prepopulated_fields_value_item(obj, subfield_name, "%s[%r]" % (label, index))
                for index, subfield_name in enumerate(val)
            ))

    def _check_prepopulated_fields_value_item(self, obj, field_name, label):
        """ For `prepopulated_fields` equal to {"slug": ("title",)},
        `field_name` is "title". """

        try:
            obj.model._meta.get_field(field_name)
        except FieldDoesNotExist:
            return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E030')
        else:
            return []

    def _check_ordering(self, obj):
        """ Check that ordering refers to existing fields or is random. """

        # ordering = None
        if obj.ordering is None:  # The default value is None
            return []
        elif not isinstance(obj.ordering, (list, tuple)):
            return must_be('a list or tuple', option='ordering', obj=obj, id='admin.E031')
        else:
            return list(chain.from_iterable(
                self._check_ordering_item(obj, field_name, 'ordering[%d]' % index)
                for index, field_name in enumerate(obj.ordering)
            ))

    def _check_ordering_item(self, obj, field_name, label):
        """ Check that `ordering` refers to existing fields. """
        if isinstance(field_name, (Combinable, OrderBy)):
            if not isinstance(field_name, OrderBy):
                field_name = field_name.asc()
            if isinstance(field_name.expression, F):
                field_name = field_name.expression.name
            else:
                return []
        if field_name == '?' and len(obj.ordering) != 1:
            return [
                checks.Error(
                    "The value of 'ordering' has the random ordering marker '?', "
                    "but contains other fields as well.",
                    hint='Either remove the "?", or remove the other fields.',
                    obj=obj.__class__,
                    id='admin.E032',
                )
            ]
        elif field_name == '?':
            return []
        elif LOOKUP_SEP in field_name:
            # Skip ordering in the format field1__field2 (FIXME: checking
            # this format would be nice, but it's a little fiddly).
            return []
        else:
            if field_name.startswith('-'):
                field_name = field_name[1:]
            if field_name == 'pk':
                return []
            try:
                obj.model._meta.get_field(field_name)
            except FieldDoesNotExist:
                return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E033')
            else:
                return []

    def _check_readonly_fields(self, obj):
        """ Check that readonly_fields refers to proper attribute or field. """

        if obj.readonly_fields == ():
            return []
        elif not isinstance(obj.readonly_fields, (list, tuple)):
            return must_be('a list or tuple', option='readonly_fields', obj=obj, id='admin.E034')
        else:
            return list(chain.from_iterable(
                self._check_readonly_fields_item(obj, field_name, "readonly_fields[%d]" % index)
                for index, field_name in enumerate(obj.readonly_fields)
            ))

    def _check_readonly_fields_item(self, obj, field_name, label):
        if callable(field_name):
            return []
        elif hasattr(obj, field_name):
            return []
        elif hasattr(obj.model, field_name):
            return []
        else:
            try:
                obj.model._meta.get_field(field_name)
            except FieldDoesNotExist:
                return [
                    checks.Error(
                        "The value of '%s' is not a callable, an attribute of '%s', or an attribute of '%s.%s'." % (
                            label, obj.__class__.__name__, obj.model._meta.app_label, obj.model._meta.object_name
                        ),
                        obj=obj.__class__,
                        id='admin.E035',
                    )
                ]
            else:
                return []


class ModelAdminChecks(BaseModelAdminChecks):

    def check(self, admin_obj, **kwargs):
        return [
            *super().check(admin_obj),
            *self._check_save_as(admin_obj),
            *self._check_save_on_top(admin_obj),
            *self._check_inlines(admin_obj),
            *self._check_list_display(admin_obj),
            *self._check_list_display_links(admin_obj),
            *self._check_list_filter(admin_obj),
            *self._check_list_select_related(admin_obj),
            *self._check_list_per_page(admin_obj),
            *self._check_list_max_show_all(admin_obj),
            *self._check_list_editable(admin_obj),
            *self._check_search_fields(admin_obj),
            *self._check_date_hierarchy(admin_obj),
            *self._check_action_permission_methods(admin_obj),
            *self._check_actions_uniqueness(admin_obj),
        ]

    def _check_save_as(self, obj):
        """ Check save_as is a boolean. """

        if not isinstance(obj.save_as, bool):
            return must_be('a boolean', option='save_as',
                           obj=obj, id='admin.E101')
        else:
            return []

    def _check_save_on_top(self, obj):
        """ Check save_on_top is a boolean. """

        if not isinstance(obj.save_on_top, bool):
            return must_be('a boolean', option='save_on_top',
                           obj=obj, id='admin.E102')
        else:
            return []

    def _check_inlines(self, obj):
        """ Check all inline model admin classes. """

        if not isinstance(obj.inlines, (list, tuple)):
            return must_be('a list or tuple', option='inlines', obj=obj, id='admin.E103')
        else:
            return list(chain.from_iterable(
                self._check_inlines_item(obj, item, "inlines[%d]" % index)
                for index, item in enumerate(obj.inlines)
            ))

    def _check_inlines_item(self, obj, inline, label):
        """ Check one inline model admin. """
        try:
            inline_label = inline.__module__ + '.' + inline.__name__
        except AttributeError:
            return [
                checks.Error(
                    "'%s' must inherit from 'InlineModelAdmin'." % obj,
                    obj=obj.__class__,
                    id='admin.E104',
                )
            ]

        from django.contrib.admin.options import InlineModelAdmin

        if not _issubclass(inline, InlineModelAdmin):
            return [
                checks.Error(
                    "'%s' must inherit from 'InlineModelAdmin'." % inline_label,
                    obj=obj.__class__,
                    id='admin.E104',
                )
            ]
        elif not inline.model:
            return [
                checks.Error(
                    "'%s' must have a 'model' attribute." % inline_label,
                    obj=obj.__class__,
                    id='admin.E105',
                )
            ]
        elif not _issubclass(inline.model, models.Model):
            return must_be('a Model', option='%s.model' % inline_label, obj=obj, id='admin.E106')
        else:
            return inline(obj.model, obj.admin_site).check()

    def _check_list_display(self, obj):
        """ Check that list_display only contains fields or usable attributes.
        """

        if not isinstance(obj.list_display, (list, tuple)):
            return must_be('a list or tuple', option='list_display', obj=obj, id='admin.E107')
        else:
            return list(chain.from_iterable(
                self._check_list_display_item(obj, item, "list_display[%d]" % index)
                for index, item in enumerate(obj.list_display)
            ))

    def _check_list_display_item(self, obj, item, label):
        if callable(item):
            return []
        elif hasattr(obj, item):
            return []
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

    def _check_list_display_links(self, obj):
        """ Check that list_display_links is a unique subset of list_display.
        """
        from django.contrib.admin.options import ModelAdmin

        if obj.list_display_links is None:
            return []
        elif not isinstance(obj.list_display_links, (list, tuple)):
            return must_be('a list, a tuple, or None', option='list_display_links', obj=obj, id='admin.E110')
        # Check only if ModelAdmin.get_list_display() isn't overridden.
        elif obj.get_list_display.__func__ is ModelAdmin.get_list_display:
            return list(chain.from_iterable(
                self._check_list_display_links_item(obj, field_name, "list_display_links[%d]" % index)
                for index, field_name in enumerate(obj.list_display_links)
            ))
        return []

    def _check_list_display_links_item(self, obj, field_name, label):
        if field_name not in obj.list_display:
            return [
                checks.Error(
                    "The value of '%s' refers to '%s', which is not defined in 'list_display'." % (
                        label, field_name
                    ),
                    obj=obj.__class__,
                    id='admin.E111',
                )
            ]
        else:
            return []

    def _check_list_filter(self, obj):
        if not isinstance(obj.list_filter, (list, tuple)):
            return must_be('a list or tuple', option='list_filter', obj=obj, id='admin.E112')
        else:
            return list(chain.from_iterable(
                self._check_list_filter_item(obj, item, "list_filter[%d]" % index)
                for index, item in enumerate(obj.list_filter)
            ))

    def _check_list_filter_item(self, obj, item, label):
        """
        Check one item of `list_filter`, i.e. check if it is one of three options:
        1. 'field' -- a basic field filter, possibly w/ relationships (e.g.
           'field__rel')
        2. ('field', SomeFieldListFilter) - a field-based list filter class
        3. SomeListFilter - a non-field list filter class
        """

        from django.contrib.admin import ListFilter, FieldListFilter

        if callable(item) and not isinstance(item, models.Field):
            # If item is option 3, it should be a ListFilter...
            if not _issubclass(item, ListFilter):
                return must_inherit_from(parent='ListFilter', option=label,
                                         obj=obj, id='admin.E113')
            # ...  but not a FieldListFilter.
            elif issubclass(item, FieldListFilter):
                return [
                    checks.Error(
                        "The value of '%s' must not inherit from 'FieldListFilter'." % label,
                        obj=obj.__class__,
                        id='admin.E114',
                    )
                ]
            else:
                return []
        elif isinstance(item, (tuple, list)):
            # item is option #2
            field, list_filter_class = item
            if not _issubclass(list_filter_class, FieldListFilter):
                return must_inherit_from(parent='FieldListFilter', option='%s[1]' % label, obj=obj, id='admin.E115')
            else:
                return []
        else:
            # item is option #1
            field = item

            # Validate the field string
            try:
                get_fields_from_path(obj.model, field)
            except (NotRelationField, FieldDoesNotExist):
                return [
                    checks.Error(
                        "The value of '%s' refers to '%s', which does not refer to a Field." % (label, field),
                        obj=obj.__class__,
                        id='admin.E116',
                    )
                ]
            else:
                return []

    def _check_list_select_related(self, obj):
        """ Check that list_select_related is a boolean, a list or a tuple. """

        if not isinstance(obj.list_select_related, (bool, list, tuple)):
            return must_be('a boolean, tuple or list', option='list_select_related', obj=obj, id='admin.E117')
        else:
            return []

    def _check_list_per_page(self, obj):
        """ Check that list_per_page is an integer. """

        if not isinstance(obj.list_per_page, int):
            return must_be('an integer', option='list_per_page', obj=obj, id='admin.E118')
        else:
            return []

    def _check_list_max_show_all(self, obj):
        """ Check that list_max_show_all is an integer. """

        if not isinstance(obj.list_max_show_all, int):
            return must_be('an integer', option='list_max_show_all', obj=obj, id='admin.E119')
        else:
            return []

    def _check_list_editable(self, obj):
        """ Check that list_editable is a sequence of editable fields from
        list_display without first element. """

        if not isinstance(obj.list_editable, (list, tuple)):
            return must_be('a list or tuple', option='list_editable', obj=obj, id='admin.E120')
        else:
            return list(chain.from_iterable(
                self._check_list_editable_item(obj, item, "list_editable[%d]" % index)
                for index, item in enumerate(obj.list_editable)
            ))

    def _check_list_editable_item(self, obj, field_name, label):
        try:
            field = obj.model._meta.get_field(field_name)
        except FieldDoesNotExist:
            return refer_to_missing_field(field=field_name, option=label, obj=obj, id='admin.E121')
        else:
            if field_name not in obj.list_display:
                return [
                    checks.Error(
                        "The value of '%s' refers to '%s', which is not "
                        "contained in 'list_display'." % (label, field_name),
                        obj=obj.__class__,
                        id='admin.E122',
                    )
                ]
            elif obj.list_display_links and field_name in obj.list_display_links:
                return [
                    checks.Error(
                        "The value of '%s' cannot be in both 'list_editable' and 'list_display_links'." % field_name,
                        obj=obj.__class__,
                        id='admin.E123',
                    )
                ]
            # If list_display[0] is in list_editable, check that
            # list_display_links is set. See #22792 and #26229 for use cases.
            elif (obj.list_display[0] == field_name and not obj.list_display_links and
                    obj.list_display_links is not None):
                return [
                    checks.Error(
                        "The value of '%s' refers to the first field in 'list_display' ('%s'), "
                        "which cannot be used unless 'list_display_links' is set." % (
                            label, obj.list_display[0]
                        ),
                        obj=obj.__class__,
                        id='admin.E124',
                    )
                ]
            elif not field.editable:
                return [
                    checks.Error(
                        "The value of '%s' refers to '%s', which is not editable through the admin." % (
                            label, field_name
                        ),
                        obj=obj.__class__,
                        id='admin.E125',
                    )
                ]
            else:
                return []

    def _check_search_fields(self, obj):
        """ Check search_fields is a sequence. """

        if not isinstance(obj.search_fields, (list, tuple)):
            return must_be('a list or tuple', option='search_fields', obj=obj, id='admin.E126')
        else:
            return []

    def _check_date_hierarchy(self, obj):
        """ Check that date_hierarchy refers to DateField or DateTimeField. """

        if obj.date_hierarchy is None:
            return []
        else:
            try:
                field = get_fields_from_path(obj.model, obj.date_hierarchy)[-1]
            except (NotRelationField, FieldDoesNotExist):
                return [
                    checks.Error(
                        "The value of 'date_hierarchy' refers to '%s', which "
                        "does not refer to a Field." % obj.date_hierarchy,
                        obj=obj.__class__,
                        id='admin.E127',
                    )
                ]
            else:
                if not isinstance(field, (models.DateField, models.DateTimeField)):
                    return must_be('a DateField or DateTimeField', option='date_hierarchy', obj=obj, id='admin.E128')
                else:
                    return []

    def _check_action_permission_methods(self, obj):
        """
        Actions with an allowed_permission attribute require the ModelAdmin to
        implement a has_<perm>_permission() method for each permission.
        """
        actions = obj._get_base_actions()
        errors = []
        for func, name, _ in actions:
            if not hasattr(func, 'allowed_permissions'):
                continue
            for permission in func.allowed_permissions:
                method_name = 'has_%s_permission' % permission
                if not has
```


# tests/admin_checks (the files in it)

tests/admin_checks/__init__.py
tests/admin_checks/models.py
tests/admin_checks/tests.py


# The last commit

```
8e4845c868 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: ./tests/runtests.py admin_checks
......................................................
----------------------------------------------------------------------
Ran 54 tests in 0.083s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
scope: django/contrib/admin/checks.py tests/admin_checks
changed: django/contrib/admin/checks.py +20 -21
OUTSIDE THE SCOPE: tests/modeladmin/models.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/modeladmin/test_checks.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/contrib/admin/checks.py b/django/contrib/admin/checks.py
index f82c20c2f1..ccebbbb900 100644
--- a/django/contrib/admin/checks.py
+++ b/django/contrib/admin/checks.py
@@ -720,33 +720,32 @@ class ModelAdminChecks(BaseModelAdminChecks):
             return []
         elif hasattr(obj, item):
             return []
-        elif hasattr(obj.model, item):
+        try:
+            field = obj.model._meta.get_field(item)
+        except FieldDoesNotExist:
             try:
-                field = obj.model._meta.get_field(item)
-            except FieldDoesNotExist:
-                return []
-            else:
-                if isinstance(field, models.ManyToManyField):
-                    return [
-                        checks.Error(
-                            "The value of '%s' must not be a ManyToManyField." % label,
-                            obj=obj.__class__,
-                            id='admin.E109',
-                        )
-                    ]
-                return []
-        else:
+                field = getattr(obj.model, item)
+            except AttributeError:
+                return [
+                    checks.Error(
+                        "The value of '%s' refers to '%s', which is not a callable, "
+                        "an attribute of '%s', or an attribute or method on '%s.%s'." % (
+                            label, item, obj.__class__.__name__,
+                            obj.model._meta.app_label, obj.model._meta.object_name,
+                        ),
+                        obj=obj.__class__,
+                        id='admin.E108',
+                    )
+                ]
+        if isinstance(field, models.ManyToManyField):
             return [
                 checks.Error(
-                    "The value of '%s' refers to '%s', which is not a callable, "
-                    "an attribute of '%s', or an attribute or method on '%s.%s'." % (
-                        label, item, obj.__class__.__name__,
-                        obj.model._meta.app_label, obj.model._meta.object_name,
-                    ),
+                    "The value of '%s' must not be a ManyToManyField." % label,
                     obj=obj.__class__,
-                    id='admin.E108',
+                    id='admin.E109',
                 )
             ]
+        return []
 
     def _check_list_display_links(self, obj):
         """ Check that list_display_links is a unique subset of list_display.
diff --git a/tests/modeladmin/models.py b/tests/modeladmin/models.py
index c0d3c772c9..07cb928f44 100644
--- a/tests/modeladmin/models.py
+++ b/tests/modeladmin/models.py
@@ -2,6 +2,19 @@ from django.contrib.auth.models import User
 from django.db import models
 
 
+class AttributeErrorRaisingDescriptor:
+    def __get__(self, instance, owner):
+        if instance is None:
+            raise AttributeError
+        return None
+
+
+class AttributeErrorRaisingField(models.IntegerField):
+    def contribute_to_class(self, cls, name, **kwargs):
+        super().contribute_to_class(cls, name, **kwargs)
+        setattr(cls, self.name, AttributeErrorRaisingDescriptor())
+
+
 class Band(models.Model):
     name = models.CharField(max_length=100)
     bio = models.TextField()
@@ -49,6 +62,14 @@ class ValidationTestModel(models.Model):
     def decade_published_in(self):
         return self.pub_date.strftime('%Y')[:3] + "0's"
 
+    class NoneReturningDescriptor:
+        def __get__(self, instance, owner):
+            return None
+
+    none_returning_descriptor = NoneReturningDescriptor()
+
+    attribute_error_raising_field = AttributeErrorRaisingField()
+
 
 class ValidationTestInlineModel(models.Model):
     parent = models.ForeignKey(ValidationTestModel, models.CASCADE)
diff --git a/tests/modeladmin/test_checks.py b/tests/modeladmin/test_checks.py
index a1b7001f68..ffb8e30745 100644
--- a/tests/modeladmin/test_checks.py
+++ b/tests/modeladmin/test_checks.py
@@ -498,6 +498,18 @@ class ListDisplayTests(CheckTestCase):
             'admin.E109'
         )
 
+    def test_none_returning_descriptor(self):
+        class TestModelAdmin(ModelAdmin):
+            list_display = ('none_returning_descriptor',)
+
+        self.assertIsValid(TestModelAdmin, ValidationTestModel)
+
+    def test_attribute_error_raising_descriptor(self):
+        class TestModelAdmin(ModelAdmin):
+            list_display = ('attribute_error_raising_field',)
+
+        self.assertIsValid(TestModelAdmin, ValidationTestModel)
+
     def test_valid_case(self):
         def a_callable(obj):
             pass
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
check: ./tests/runtests.py admin_checks
......................................................
----------------------------------------------------------------------
Ran 54 tests in 0.062s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
scope: django/contrib/admin/checks.py tests/admin_checks
changed: django/contrib/admin/checks.py +20 -21
OUTSIDE THE SCOPE: tests/modeladmin/models.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/modeladmin/test_checks.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
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
# Notes, run 2026-11-06T105200

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

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
django/contrib/admin/locale/mk/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/mk/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ml/LC_MESSAGES/django.mo
django/contrib/admin/locale/ml/LC_MESSAGES/django.po
django/contrib/admin/locale/ml/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ml/LC_MESSAGES/djangojs.po
```


# The last commit

```
8e4845c868 SWE-bench


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
`./tests/runtests.py admin_checks`

## Scope
`django/contrib/admin/checks.py`
`tests/admin_checks/`

## Done when
- `_check_list_display_item` returns no error when `obj.model._meta.get_field(item)` resolves the item even if `hasattr(obj.model, item)` is false.
- `admin.E108` is returned only when both `obj.model._meta.get_field(item)` raises `FieldDoesNotExist` and `getattr(obj.model, item)` raises `AttributeError`.
- `admin.E109` is returned when the resolved field is a `models.ManyToManyField`, including when it was resolved through `get_field` after `hasattr` was false.
- A resolved field value of `None` is not treated as a missing field and does not produce `admin.E108`.
- Callable `list_display` items and attributes of the `ModelAdmin` still pass without error.

## Approach
Decompose into one behavior change in `django/contrib/admin/checks.py` and regression coverage under `tests/admin_checks/`. In `_check_list_display_item`, keep the early `callable(item)` and `hasattr(obj, item)` returns, remove the `hasattr(obj.model, item)` gate, try `obj.model._meta.get_field(item)` first, fall back to `getattr(obj.model, item)` only on `FieldDoesNotExist`, return `admin.E108` only if that fallback raises `AttributeError`, then check the resolved field for `models.ManyToManyField` and return `admin.E109` if so.

Candidate approaches:
- Use the prompt’s try/except ordering: `get_field` first, `getattr` fallback, no `None` sentinel. This is the most direct and avoids conflating a descriptor returning `None` with a missing attribute.
- Keep the `hasattr(obj.model, item)` check but still attempt `get_field` when it is false. This is behaviorally equivalent but leaves two paths for the same decision and is easier to get wrong.
- Use a sentinel default with `getattr(obj.model, item, sentinel)`. This avoids `None` conflation but still needs `get_field` first and adds more branching than the try/except form.
```

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

### `review.md`

```
verdict: PASS

- `django/contrib/admin/checks.py` now tries `obj.model._meta.get_field(item)` first, so a field resolvable via `_meta` passes even when `hasattr(obj.model, item)` is false (the PositionField case). Matches Done when item 1.
- `admin.E108` is emitted only inside the `except FieldDoesNotExist` → `except AttributeError` path, i.e. only when both lookups fail. Matches item 2.
- The `isinstance(field, models.ManyToManyField)` check runs after either resolution path, so `admin.E109` is raised for M2M fields found via `get_field` even when `hasattr` was false. Matches item 3.
- There is no `field is None` sentinel; a `None`-returning descriptor resolves to `None` and falls through to `return []`. Matches item 4.
- The `callable(item)` and `hasattr(obj, item)` early returns are preserved. Matches item 5.
- The added tests in `tests/modeladmin/` are outside the planner's stated Scope (`tests/admin_checks/`), but they are the fixtures the fix needs and the existing `ListDisplayTests` live there; per the review rules a needed test fixture outside a guessed Scope is not a failure. The `admin_checks` run passed (54 tests, OK).
- No content was removed beyond the replaced branch logic, and no unrelated module was touched.
```

### `scope.txt`

```
scope: django/contrib/admin/checks.py tests/admin_checks
changed: django/contrib/admin/checks.py +20 -21
OUTSIDE THE SCOPE: tests/modeladmin/models.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/modeladmin/test_checks.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
```

### `task.md`

```
# Task

## Prompt

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

## Deliverable

changes to this tree

## Check

`./tests/runtests.py admin_checks`

## Scope

`django/contrib/admin/checks.py`
`tests/admin_checks/`

## Done when

- `_check_list_display_item` returns no error when `obj.model._meta.get_field(item)` resolves the item even if `hasattr(obj.model, item)` is false.
- `admin.E108` is returned only when both `obj.model._meta.get_field(item)` raises `FieldDoesNotExist` and `getattr(obj.model, item)` raises `AttributeError`.
- `admin.E109` is returned when the resolved field is a `models.ManyToManyField`, including when it was resolved through `get_field` after `hasattr` was false.
- A resolved field value of `None` is not treated as a missing field and does not produce `admin.E108`.
- Callable `list_display` items and attributes of the `ModelAdmin` still pass without error.
```

### `test-output.log`

```
check: ./tests/runtests.py admin_checks
......................................................
----------------------------------------------------------------------
Ran 54 tests in 0.082s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
scope: django/contrib/admin/checks.py tests/admin_checks
changed: django/contrib/admin/checks.py +20 -21
OUTSIDE THE SCOPE: tests/modeladmin/models.py +21 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: tests/modeladmin/test_checks.py +12 -0 (undo it: git checkout the file, or delete it when the run made it)
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
