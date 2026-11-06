# django__django-11400 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 104s 116 lines cost=0.004413 in=204434 cached=186880 out=8197 calls=18`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Ordering problem in admin.RelatedFieldListFilter and admin.RelatedOnlyFieldListFilter
Description
	
RelatedFieldListFilter doesn't fall back to the ordering defined in Model._meta.ordering. 
Ordering gets set to an empty tuple in ​https://github.com/django/django/blob/2.2.1/django/contrib/admin/filters.py#L196 and unless ordering is defined on the related model's ModelAdmin class it stays an empty tuple. IMHO it should fall back to the ordering defined in the related model's Meta.ordering field.
RelatedOnlyFieldListFilter doesn't order the related model at all, even if ordering is defined on the related model's ModelAdmin class.
That's because the call to field.get_choices ​https://github.com/django/django/blob/2.2.1/django/contrib/admin/filters.py#L422 omits the ordering kwarg entirely.

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
  "command": "sed -n '150,230p' django/contrib/admin/filters.py && sed -n '390,440p' django/contrib/admin/filters.py"
}
```

**tool result**

```
                cls._take_priority_index, (test, list_filter_class))
            cls._take_priority_index += 1
        else:
            cls._field_list_filters.append((test, list_filter_class))

    @classmethod
    def create(cls, field, request, params, model, model_admin, field_path):
        for test, list_filter_class in cls._field_list_filters:
            if test(field):
                return list_filter_class(field, request, params, model, model_admin, field_path=field_path)


class RelatedFieldListFilter(FieldListFilter):
    def __init__(self, field, request, params, model, model_admin, field_path):
        other_model = get_model_from_relation(field)
        self.lookup_kwarg = '%s__%s__exact' % (field_path, field.target_field.name)
        self.lookup_kwarg_isnull = '%s__isnull' % field_path
        self.lookup_val = params.get(self.lookup_kwarg)
        self.lookup_val_isnull = params.get(self.lookup_kwarg_isnull)
        super().__init__(field, request, params, model, model_admin, field_path)
        self.lookup_choices = self.field_choices(field, request, model_admin)
        if hasattr(field, 'verbose_name'):
            self.lookup_title = field.verbose_name
        else:
            self.lookup_title = other_model._meta.verbose_name
        self.title = self.lookup_title
        self.empty_value_display = model_admin.get_empty_value_display()

    @property
    def include_empty_choice(self):
        """
        Return True if a "(None)" choice should be included, which filters
        out everything except empty relationships.
        """
        return self.field.null or (self.field.is_relation and self.field.many_to_many)

    def has_output(self):
        if self.include_empty_choice:
            extra = 1
        else:
            extra = 0
        return len(self.lookup_choices) + extra > 1

    def expected_parameters(self):
        return [self.lookup_kwarg, self.lookup_kwarg_isnull]

    def field_choices(self, field, request, model_admin):
        ordering = ()
        related_admin = model_admin.admin_site._registry.get(field.remote_field.model)
        if related_admin is not None:
            ordering = related_admin.get_ordering(request)
        return field.get_choices(include_blank=False, ordering=ordering)

    def choices(self, changelist):
        yield {
            'selected': self.lookup_val is None and not self.lookup_val_isnull,
            'query_string': changelist.get_query_string(remove=[self.lookup_kwarg, self.lookup_kwarg_isnull]),
            'display': _('All'),
        }
        for pk_val, val in self.lookup_choices:
            yield {
                'selected': self.lookup_val == str(pk_val),
                'query_string': changelist.get_query_string({self.lookup_kwarg: pk_val}, [self.lookup_kwarg_isnull]),
                'display': val,
            }
        if self.include_empty_choice:
            yield {
                'selected': bool(self.lookup_val_isnull),
                'query_string': changelist.get_query_string({self.lookup_kwarg_isnull: 'True'}, [self.lookup_kwarg]),
                'display': self.empty_value_display,
            }


FieldListFilter.register(lambda f: f.remote_field, RelatedFieldListFilter)


class BooleanFieldListFilter(FieldListFilter):
    def __init__(self, field, request, params, model, model_admin, field_path):
        self.lookup_kwarg = '%s__exact' % field_path
        self.lookup_kwarg2 = '%s__isnull' % field_path
        self.lookup_val = params.get(self.lookup_kwarg)

    def choices(self, changelist):
        yield {
            'selected': self.lookup_val is None and self.lookup_val_isnull is None,
            'query_string': changelist.get_query_string(remove=[self.lookup_kwarg, self.lookup_kwarg_isnull]),
            'display': _('All'),
        }
        include_none = False
        for val in self.lookup_choices:
            if val is None:
                include_none = True
                continue
            val = str(val)
            yield {
                'selected': self.lookup_val == val,
                'query_string': changelist.get_query_string({self.lookup_kwarg: val}, [self.lookup_kwarg_isnull]),
                'display': val,
            }
        if include_none:
            yield {
                'selected': bool(self.lookup_val_isnull),
                'query_string': changelist.get_query_string({self.lookup_kwarg_isnull: 'True'}, [self.lookup_kwarg]),
                'display': self.empty_value_display,
            }


FieldListFilter.register(lambda f: True, AllValuesFieldListFilter)


class RelatedOnlyFieldListFilter(RelatedFieldListFilter):
    def field_choices(self, field, request, model_admin):
        pk_qs = model_admin.get_queryset(request).distinct().values_list('%s__pk' % self.field_path, flat=True)
        return field.get_choices(include_blank=False, limit_choices_to={'pk__in': pk_qs})
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"RelatedFieldListFilter\\|RelatedOnlyFieldListFilter\\|field_choices\\|field_admin_ordering\" tests/admin_filters tests 2>/dev/null | head -60"
}
```

**tool result**

```
tests/admin_filters/tests.py:7:    RelatedOnlyFieldListFilter, SimpleListFilter, site,
tests/admin_filters/tests.py:186:        ('author', RelatedOnlyFieldListFilter),
tests/admin_filters/tests.py:187:        ('contributors', RelatedOnlyFieldListFilter),
tests/admin_filters/tests.py:188:        ('employee__department', RelatedOnlyFieldListFilter),
tests/admin_filters/tests.py:558:        """RelatedFieldListFilter ordering respects ModelAdmin.ordering."""
tests/admin_filters/tests.py:7:    RelatedOnlyFieldListFilter, SimpleListFilter, site,
tests/admin_filters/tests.py:186:        ('author', RelatedOnlyFieldListFilter),
tests/admin_filters/tests.py:187:        ('contributors', RelatedOnlyFieldListFilter),
tests/admin_filters/tests.py:188:        ('employee__department', RelatedOnlyFieldListFilter),
tests/admin_filters/tests.py:558:        """RelatedFieldListFilter ordering respects ModelAdmin.ordering."""
tests/forms_tests/field_tests/test_choicefield.py:55:    def test_choicefield_choices_default(self):
tests/field_deconstruction/tests.py:91:    def test_char_field_choices(self):
tests/model_fields/test_booleanfield.py:41:    def test_booleanfield_choices_blank(self):
tests/admin_views/tests.py:689:    def test_named_group_field_choices_change_list(self):
tests/admin_views/tests.py:705:    def test_named_group_field_choices_filter(self):
tests/admin_ordering/tests.py:142:    def check_ordering_of_field_choices(self, correct_ordering):
tests/admin_ordering/tests.py:150:        self.check_ordering_of_field_choices([self.b2, self.b1])
tests/admin_ordering/tests.py:158:        self.check_ordering_of_field_choices([self.b2, self.b1])
tests/admin_ordering/tests.py:166:        self.check_ordering_of_field_choices([self.b1, self.b2])
tests/admin_ordering/tests.py:189:        self.check_ordering_of_field_choices([self.b2])
tests/postgres_tests/test_array.py:812:    def test_model_field_choices(self):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '520,600p' tests/admin_filters/tests.py && sed -n '1,60p' tests/admin_filters/tests.py && grep -n \"class.*Admin\\|ordering\" tests/admin_filters/tests.py | head -60"
}
```

**tool result**

```

        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)

        # Make sure that all users are present in the author's list filter
        filterspec = changelist.get_filters(request)[0][1]
        expected = [(self.alfred.pk, 'alfred'), (self.bob.pk, 'bob'), (self.lisa.pk, 'lisa')]
        self.assertEqual(sorted(filterspec.lookup_choices), sorted(expected))

        request = self.request_factory.get('/', {'author__isnull': 'True'})
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)

        # Make sure the correct queryset is returned
        queryset = changelist.get_queryset(request)
        self.assertEqual(list(queryset), [self.guitar_book])

        # Make sure the last choice is None and is selected
        filterspec = changelist.get_filters(request)[0][1]
        self.assertEqual(filterspec.title, 'Verbose Author')
        choices = list(filterspec.choices(changelist))
        self.assertIs(choices[-1]['selected'], True)
        self.assertEqual(choices[-1]['query_string'], '?author__isnull=True')

        request = self.request_factory.get('/', {'author__id__exact': self.alfred.pk})
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)

        # Make sure the correct choice is selected
        filterspec = changelist.get_filters(request)[0][1]
        self.assertEqual(filterspec.title, 'Verbose Author')
        # order of choices depends on User model, which has no order
        choice = select_by(filterspec.choices(changelist), "display", "alfred")
        self.assertIs(choice['selected'], True)
        self.assertEqual(choice['query_string'], '?author__id__exact=%d' % self.alfred.pk)

    def test_relatedfieldlistfilter_foreignkey_ordering(self):
        """RelatedFieldListFilter ordering respects ModelAdmin.ordering."""
        class EmployeeAdminWithOrdering(ModelAdmin):
            ordering = ('name',)

        class BookAdmin(ModelAdmin):
            list_filter = ('employee',)

        site.register(Employee, EmployeeAdminWithOrdering)
        self.addCleanup(lambda: site.unregister(Employee))
        modeladmin = BookAdmin(Book, site)

        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)
        filterspec = changelist.get_filters(request)[0][0]
        expected = [(self.jack.pk, 'Jack Red'), (self.john.pk, 'John Blue')]
        self.assertEqual(filterspec.lookup_choices, expected)

    def test_relatedfieldlistfilter_foreignkey_ordering_reverse(self):
        class EmployeeAdminWithOrdering(ModelAdmin):
            ordering = ('-name',)

        class BookAdmin(ModelAdmin):
            list_filter = ('employee',)

        site.register(Employee, EmployeeAdminWithOrdering)
        self.addCleanup(lambda: site.unregister(Employee))
        modeladmin = BookAdmin(Book, site)

        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)
        filterspec = changelist.get_filters(request)[0][0]
        expected = [(self.john.pk, 'John Blue'), (self.jack.pk, 'Jack Red')]
        self.assertEqual(filterspec.lookup_choices, expected)

    def test_relatedfieldlistfilter_manytomany(self):
        modeladmin = BookAdmin(Book, site)

        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)

import datetime
import sys
import unittest

from django.contrib.admin import (
    AllValuesFieldListFilter, BooleanFieldListFilter, ModelAdmin,
    RelatedOnlyFieldListFilter, SimpleListFilter, site,
)
from django.contrib.admin.options import IncorrectLookupParameters
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from django.core.exceptions import ImproperlyConfigured
from django.test import RequestFactory, TestCase, override_settings

from .models import Book, Bookmark, Department, Employee, TaggedItem


def select_by(dictlist, key, value):
    return [x for x in dictlist if x[key] == value][0]


class DecadeListFilter(SimpleListFilter):

    def lookups(self, request, model_admin):
        return (
            ('the 80s', "the 1980's"),
            ('the 90s', "the 1990's"),
            ('the 00s', "the 2000's"),
            ('other', "other decades"),
        )

    def queryset(self, request, queryset):
        decade = self.value()
        if decade == 'the 80s':
            return queryset.filter(year__gte=1980, year__lte=1989)
        if decade == 'the 90s':
            return queryset.filter(year__gte=1990, year__lte=1999)
        if decade == 'the 00s':
            return queryset.filter(year__gte=2000, year__lte=2009)


class NotNinetiesListFilter(SimpleListFilter):
    title = "Not nineties books"
    parameter_name = "book_year"

    def lookups(self, request, model_admin):
        return (
            ('the 90s', "the 1990's"),
        )

    def queryset(self, request, queryset):
        if self.value() == 'the 90s':
            return queryset.filter(year__gte=1990, year__lte=1999)
        else:
            return queryset.exclude(year__gte=1990, year__lte=1999)


class DecadeListFilterWithTitleAndParameter(DecadeListFilter):
    title = 'publication decade'
    parameter_name = 'publication-decade'
136:class CustomUserAdmin(UserAdmin):
140:class BookAdmin(ModelAdmin):
142:    ordering = ('-id',)
145:class BookAdmin2(ModelAdmin):
149:class BookAdminWithTupleBooleanFilter(BookAdmin):
160:class BookAdminWithUnderscoreLookupAndTuple(BookAdmin):
171:class BookAdminWithCustomQueryset(ModelAdmin):
183:class BookAdminRelatedOnlyFilter(ModelAdmin):
190:    ordering = ('-id',)
193:class DecadeFilterBookAdmin(ModelAdmin):
195:    ordering = ('-id',)
198:class NotNinetiesListFilterAdmin(ModelAdmin):
202:class DecadeFilterBookAdminWithoutTitle(ModelAdmin):
206:class DecadeFilterBookAdminWithoutParameter(ModelAdmin):
210:class DecadeFilterBookAdminWithNoneReturningLookups(ModelAdmin):
214:class DecadeFilterBookAdminWithFailingQueryset(ModelAdmin):
218:class DecadeFilterBookAdminWithQuerysetBasedLookups(ModelAdmin):
222:class DecadeFilterBookAdminParameterEndsWith__In(ModelAdmin):
226:class DecadeFilterBookAdminParameterEndsWith__Isnull(ModelAdmin):
230:class EmployeeAdmin(ModelAdmin):
235:class DepartmentFilterEmployeeAdmin(EmployeeAdmin):
239:class DepartmentFilterUnderscoredEmployeeAdmin(EmployeeAdmin):
243:class DepartmentFilterDynamicValueBookAdmin(EmployeeAdmin):
247:class BookmarkAdminGenericRelation(ModelAdmin):
305:        class BookmarkChoicesAdmin(ModelAdmin):
557:    def test_relatedfieldlistfilter_foreignkey_ordering(self):
558:        """RelatedFieldListFilter ordering respects ModelAdmin.ordering."""
559:        class EmployeeAdminWithOrdering(ModelAdmin):
560:            ordering = ('name',)
562:        class BookAdmin(ModelAdmin):
576:    def test_relatedfieldlistfilter_foreignkey_ordering_reverse(self):
577:        class EmployeeAdminWithOrdering(ModelAdmin):
578:            ordering = ('-name',)
580:        class BookAdmin(ModelAdmin):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def get_choices\" -A45 django/db/models/fields/__init__.py"
}
```

**tool result**

```
809:    def get_choices(self, include_blank=True, blank_choice=BLANK_CHOICE_DASH, limit_choices_to=None, ordering=()):
810-        """
811-        Return choices with a default blank choices included, for use
812-        as <select> choices for this field.
813-        """
814-        if self.choices is not None:
815-            choices = list(self.choices)
816-            if include_blank:
817-                blank_defined = any(choice in ('', None) for choice, _ in self.flatchoices)
818-                if not blank_defined:
819-                    choices = blank_choice + choices
820-            return choices
821-        rel_model = self.remote_field.model
822-        limit_choices_to = limit_choices_to or self.get_limit_choices_to()
823-        choice_func = operator.attrgetter(
824-            self.remote_field.get_related_field().attname
825-            if hasattr(self.remote_field, 'get_related_field')
826-            else 'pk'
827-        )
828-        return (blank_choice if include_blank else []) + [
829-            (choice_func(x), str(x))
830-            for x in rel_model._default_manager.complex_filter(limit_choices_to).order_by(*ordering)
831-        ]
832-
833-    def value_to_string(self, obj):
834-        """
835-        Return a string value of this field from the passed obj.
836-        This is used by the serialization framework.
837-        """
838-        return str(self.value_from_object(obj))
839-
840-    def _get_flatchoices(self):
841-        """Flattened version of choices tuple."""
842-        if self.choices is None:
843-            return []
844-        flat = []
845-        for choice, value in self.choices:
846-            if isinstance(value, (list, tuple)):
847-                flat.extend(value)
848-            else:
849-                flat.append((choice, value))
850-        return flat
851-    flatchoices = property(_get_flatchoices)
852-
853-    def save_form_data(self, instance, data):
854-        setattr(instance, self.name, data)
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -5 && grep -n \"VERSION\" django/__init__.py && grep -rn \"get_choices(include_blank=False\" django/contrib/admin/"
}
```

**tool result**

```
8020819f97 SWE-bench
1f8382d34d Fixed #30672 -- Fixed crash of JSONField/HStoreField key transforms on expressions with params.
0b8d911d28 Optimized Field.deconstruct() by using elif.
eed2e740f7 Fixed #30461 -- Made GeoIP2 and GEOIP_PATH setting accept pathlib.Path as library path.
88c0b907e7 Refs #30461 -- Added django.utils._os.to_path().
3:VERSION = (3, 0, 0, 'alpha', 0)
5:__version__ = get_version(VERSION)
django/contrib/admin/filters.py:201:        return field.get_choices(include_blank=False, ordering=ordering)
django/contrib/admin/filters.py:422:        return field.get_choices(include_blank=False, limit_choices_to={'pk__in': pk_qs})
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Employee\\|class Department\\|class Book\\b\\|ordering\" -A20 tests/admin_filters/models.py | head -120"
}
```

**tool result**

```
9:class Book(models.Model):
10-    title = models.CharField(max_length=50)
11-    year = models.PositiveIntegerField(null=True, blank=True)
12-    author = models.ForeignKey(
13-        User,
14-        models.SET_NULL,
15-        verbose_name="Verbose Author",
16-        related_name='books_authored',
17-        blank=True, null=True,
18-    )
19-    contributors = models.ManyToManyField(
20-        User,
21-        verbose_name="Verbose Contributors",
22-        related_name='books_contributed',
23-        blank=True,
24-    )
25-    employee = models.ForeignKey(
26-        'Employee',
27-        models.SET_NULL,
28-        verbose_name='Employee',
29-        blank=True, null=True,
--
41:class Department(models.Model):
42-    code = models.CharField(max_length=4, unique=True)
43-    description = models.CharField(max_length=50, blank=True, null=True)
44-
45-    def __str__(self):
46-        return self.description
47-
48-
49:class Employee(models.Model):
50-    department = models.ForeignKey(Department, models.CASCADE, to_field="code")
51-    name = models.CharField(max_length=100)
52-
53-    def __str__(self):
54-        return self.name
55-
56-
57-class TaggedItem(models.Model):
58-    tag = models.SlugField()
59-    content_type = models.ForeignKey(ContentType, models.CASCADE, related_name='tagged_items')
60-    object_id = models.PositiveIntegerField()
61-    content_object = GenericForeignKey('content_type', 'object_id')
62-
63-    def __str__(self):
64-        return self.tag
65-
66-
67-class Bookmark(models.Model):
68-    url = models.URLField()
69-    tags = GenericRelation(TaggedItem)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/contrib/admin/filters.py\n@@\n     def field_choices(self, field, request, model_admin):\n-        ordering = ()\n+        ordering = field.remote_field.model._meta.ordering\n         related_admin = model_admin.admin_site._registry.get(field.remote_field.model)\n         if related_admin is not None:\n-            ordering = related_admin.get_ordering(request)\n+            ordering = related_admin.get_ordering(request) or ordering\n         return field.get_choices(include_blank=False, ordering=ordering)\n@@\n class RelatedOnlyFieldListFilter(RelatedFieldListFilter):\n     def field_choices(self, field, request, model_admin):\n+        ordering = field.remote_field.model._meta.ordering\n+        related_admin = model_admin.admin_site._registry.get(field.remote_field.model)\n+        if related_admin is not None:\n+            ordering = related_admin.get_ordering(request) or ordering\n         pk_qs = model_admin.get_queryset(request).distinct().values_list('%s__pk' % self.field_path, flat=True)\n-        return field.get_choices(include_blank=False, limit_choices_to={'pk__in': pk_qs})\n+        return field.get_choices(include_blank=False, limit_choices_to={'pk__in': pk_qs}, ordering=ordering)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/contrib/admin/filters.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/contrib/admin/filters.py now (426 lines), around the change:
194:        return [self.lookup_kwarg, self.lookup_kwarg_isnull]
195:
196:    def field_choices(self, field, request, model_admin):
197:        ordering = field.remote_field.model._meta.ordering
198:        related_admin = model_admin.admin_site._registry.get(field.remote_field.model)
199:        if related_admin is not None:
200:            ordering = related_admin.get_ordering(request) or ordering
201:        return field.get_choices(include_blank=False, ordering=ordering)
202:
203:    def choices(self, changelist):
…
418:
419:class RelatedOnlyFieldListFilter(RelatedFieldListFilter):
420:    def field_choices(self, field, request, model_admin):
421:        ordering = field.remote_field.model._meta.ordering
422:        related_admin = model_admin.admin_site._registry.get(field.remote_field.model)
423:        if related_admin is not None:
424:            ordering = related_admin.get_ordering(request) or ordering
425:        pk_qs = model_admin.get_queryset(request).distinct().values_list('%s__pk' % self.field_path, flat=True)
426:        return field.get_choices(include_blank=False, limit_choices_to={'pk__in': pk_qs}, ordering=ordering)
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py admin_filters --verbosity 1 2>&1 | tail -30"
}
```

**tool result**

```
Creating test database for alias 'default'...
................................
----------------------------------------------------------------------
Ran 32 tests in 0.355s

OK
Destroying test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cat tests/admin_filters/models.py && sed -n '120,200p' tests/admin_filters/tests.py"
}
```

**tool result**

```
from django.contrib.auth.models import User
from django.contrib.contenttypes.fields import (
    GenericForeignKey, GenericRelation,
)
from django.contrib.contenttypes.models import ContentType
from django.db import models


class Book(models.Model):
    title = models.CharField(max_length=50)
    year = models.PositiveIntegerField(null=True, blank=True)
    author = models.ForeignKey(
        User,
        models.SET_NULL,
        verbose_name="Verbose Author",
        related_name='books_authored',
        blank=True, null=True,
    )
    contributors = models.ManyToManyField(
        User,
        verbose_name="Verbose Contributors",
        related_name='books_contributed',
        blank=True,
    )
    employee = models.ForeignKey(
        'Employee',
        models.SET_NULL,
        verbose_name='Employee',
        blank=True, null=True,
    )
    is_best_seller = models.BooleanField(default=0, null=True)
    is_best_seller2 = models.NullBooleanField(default=0)
    date_registered = models.DateField(null=True)
    # This field name is intentionally 2 characters long (#16080).
    no = models.IntegerField(verbose_name='number', blank=True, null=True)

    def __str__(self):
        return self.title


class Department(models.Model):
    code = models.CharField(max_length=4, unique=True)
    description = models.CharField(max_length=50, blank=True, null=True)

    def __str__(self):
        return self.description


class Employee(models.Model):
    department = models.ForeignKey(Department, models.CASCADE, to_field="code")
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class TaggedItem(models.Model):
    tag = models.SlugField()
    content_type = models.ForeignKey(ContentType, models.CASCADE, related_name='tagged_items')
    object_id = models.PositiveIntegerField()
    content_object = GenericForeignKey('content_type', 'object_id')

    def __str__(self):
        return self.tag


class Bookmark(models.Model):
    url = models.URLField()
    tags = GenericRelation(TaggedItem)

    CHOICES = [
        ('a', 'A'),
        (None, 'None'),
        ('', '-'),
    ]
    none_or_null = models.CharField(max_length=20, choices=CHOICES, blank=True, null=True)

    def __str__(self):
        return self.url

class DepartmentListFilterLookupWithUnderscoredParameter(DepartmentListFilterLookupWithNonStringValue):
    parameter_name = 'department__whatever'


class DepartmentListFilterLookupWithDynamicValue(DecadeListFilterWithTitleAndParameter):

    def lookups(self, request, model_admin):
        if self.value() == 'the 80s':
            return (('the 90s', "the 1990's"),)
        elif self.value() == 'the 90s':
            return (('the 80s', "the 1980's"),)
        else:
            return (('the 80s', "the 1980's"), ('the 90s', "the 1990's"),)


class CustomUserAdmin(UserAdmin):
    list_filter = ('books_authored', 'books_contributed')


class BookAdmin(ModelAdmin):
    list_filter = ('year', 'author', 'contributors', 'is_best_seller', 'date_registered', 'no')
    ordering = ('-id',)


class BookAdmin2(ModelAdmin):
    list_filter = ('year', 'author', 'contributors', 'is_best_seller2', 'date_registered', 'no')


class BookAdminWithTupleBooleanFilter(BookAdmin):
    list_filter = (
        'year',
        'author',
        'contributors',
        ('is_best_seller', BooleanFieldListFilter),
        'date_registered',
        'no',
    )


class BookAdminWithUnderscoreLookupAndTuple(BookAdmin):
    list_filter = (
        'year',
        ('author__email', AllValuesFieldListFilter),
        'contributors',
        'is_best_seller',
        'date_registered',
        'no',
    )


class BookAdminWithCustomQueryset(ModelAdmin):

    def __init__(self, user, *args, **kwargs):
        self.user = user
        super().__init__(*args, **kwargs)

    list_filter = ('year',)

    def get_queryset(self, request):
        return super().get_queryset(request).filter(author=self.user)


class BookAdminRelatedOnlyFilter(ModelAdmin):
    list_filter = (
        'year', 'is_best_seller', 'date_registered', 'no',
        ('author', RelatedOnlyFieldListFilter),
        ('contributors', RelatedOnlyFieldListFilter),
        ('employee__department', RelatedOnlyFieldListFilter),
    )
    ordering = ('-id',)


class DecadeFilterBookAdmin(ModelAdmin):
    list_filter = ('author', DecadeListFilterWithTitleAndParameter)
    ordering = ('-id',)


class NotNinetiesListFilterAdmin(ModelAdmin):
    list_filter = (NotNinetiesListFilter,)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"relatedonly\\|RelatedOnly\\|related_field\\|ordering\" tests/admin_filters/tests.py"
}
```

**tool result**

```
7:    RelatedOnlyFieldListFilter, SimpleListFilter, site,
142:    ordering = ('-id',)
183:class BookAdminRelatedOnlyFilter(ModelAdmin):
186:        ('author', RelatedOnlyFieldListFilter),
187:        ('contributors', RelatedOnlyFieldListFilter),
188:        ('employee__department', RelatedOnlyFieldListFilter),
190:    ordering = ('-id',)
195:    ordering = ('-id',)
557:    def test_relatedfieldlistfilter_foreignkey_ordering(self):
558:        """RelatedFieldListFilter ordering respects ModelAdmin.ordering."""
560:            ordering = ('name',)
576:    def test_relatedfieldlistfilter_foreignkey_ordering_reverse(self):
578:            ordering = ('-name',)
699:    def test_relatedonlyfieldlistfilter_foreignkey(self):
700:        modeladmin = BookAdminRelatedOnlyFilter(Book, site)
711:    def test_relatedonlyfieldlistfilter_underscorelookup_foreignkey(self):
718:        modeladmin = BookAdminRelatedOnlyFilter(Book, site)
732:    def test_relatedonlyfieldlistfilter_manytomany(self):
733:        modeladmin = BookAdminRelatedOnlyFilter(Book, site)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '250,330p' tests/admin_filters/tests.py && sed -n '690,750p' tests/admin_filters/tests.py"
}
```

**tool result**

```

class ListFiltersTests(TestCase):
    request_factory = RequestFactory()

    @classmethod
    def setUpTestData(cls):
        cls.today = datetime.date.today()
        cls.tomorrow = cls.today + datetime.timedelta(days=1)
        cls.one_week_ago = cls.today - datetime.timedelta(days=7)
        if cls.today.month == 12:
            cls.next_month = cls.today.replace(year=cls.today.year + 1, month=1, day=1)
        else:
            cls.next_month = cls.today.replace(month=cls.today.month + 1, day=1)
        cls.next_year = cls.today.replace(year=cls.today.year + 1, month=1, day=1)

        # Users
        cls.alfred = User.objects.create_superuser('alfred', 'alfred@example.com', 'password')
        cls.bob = User.objects.create_user('bob', 'bob@example.com')
        cls.lisa = User.objects.create_user('lisa', 'lisa@example.com')

        # Books
        cls.djangonaut_book = Book.objects.create(
            title='Djangonaut: an art of living', year=2009,
            author=cls.alfred, is_best_seller=True, date_registered=cls.today,
            is_best_seller2=True,
        )
        cls.bio_book = Book.objects.create(
            title='Django: a biography', year=1999, author=cls.alfred,
            is_best_seller=False, no=207,
            is_best_seller2=False,
        )
        cls.django_book = Book.objects.create(
            title='The Django Book', year=None, author=cls.bob,
            is_best_seller=None, date_registered=cls.today, no=103,
            is_best_seller2=None,
        )
        cls.guitar_book = Book.objects.create(
            title='Guitar for dummies', year=2002, is_best_seller=True,
            date_registered=cls.one_week_ago,
            is_best_seller2=True,
        )
        cls.guitar_book.contributors.set([cls.bob, cls.lisa])

        # Departments
        cls.dev = Department.objects.create(code='DEV', description='Development')
        cls.design = Department.objects.create(code='DSN', description='Design')

        # Employees
        cls.john = Employee.objects.create(name='John Blue', department=cls.dev)
        cls.jack = Employee.objects.create(name='Jack Red', department=cls.design)

    def test_choicesfieldlistfilter_has_none_choice(self):
        """
        The last choice is for the None value.
        """
        class BookmarkChoicesAdmin(ModelAdmin):
            list_display = ['none_or_null']
            list_filter = ['none_or_null']

        modeladmin = BookmarkChoicesAdmin(Bookmark, site)
        request = self.request_factory.get('/', {})
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)
        filterspec = changelist.get_filters(request)[0][0]
        choices = list(filterspec.choices(changelist))
        self.assertEqual(choices[-1]['display'], 'None')
        self.assertEqual(choices[-1]['query_string'], '?none_or_null__isnull=True')

    def test_datefieldlistfilter(self):
        modeladmin = BookAdmin(Book, site)

        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist(request)

        request = self.request_factory.get('/', {
            'date_registered__gte': self.today,
            'date_registered__lt': self.tomorrow},
        )
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)
        # (None) option.
        Book.objects.exclude(pk=self.djangonaut_book.pk).delete()
        filterspec = changelist.get_filters(request)[0]
        self.assertEqual(len(filterspec), 2)
        # With no books remaining, no list filters should appear.
        Book.objects.all().delete()
        filterspec = changelist.get_filters(request)[0]
        self.assertEqual(len(filterspec), 0)

    def test_relatedonlyfieldlistfilter_foreignkey(self):
        modeladmin = BookAdminRelatedOnlyFilter(Book, site)

        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)

        # Make sure that only actual authors are present in author's list filter
        filterspec = changelist.get_filters(request)[0][4]
        expected = [(self.alfred.pk, 'alfred'), (self.bob.pk, 'bob')]
        self.assertEqual(sorted(filterspec.lookup_choices), sorted(expected))

    def test_relatedonlyfieldlistfilter_underscorelookup_foreignkey(self):
        Department.objects.create(code='TEST', description='Testing')
        self.djangonaut_book.employee = self.john
        self.djangonaut_book.save()
        self.bio_book.employee = self.jack
        self.bio_book.save()

        modeladmin = BookAdminRelatedOnlyFilter(Book, site)
        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)

        # Only actual departments should be present in employee__department's
        # list filter.
        filterspec = changelist.get_filters(request)[0][6]
        expected = [
            (self.dev.code, str(self.dev)),
            (self.design.code, str(self.design)),
        ]
        self.assertEqual(sorted(filterspec.lookup_choices), sorted(expected))

    def test_relatedonlyfieldlistfilter_manytomany(self):
        modeladmin = BookAdminRelatedOnlyFilter(Book, site)

        request = self.request_factory.get('/')
        request.user = self.alfred
        changelist = modeladmin.get_changelist_instance(request)

        # Make sure that only actual contributors are present in contrib's list filter
        filterspec = changelist.get_filters(request)[0][5]
        expected = [(self.bob.pk, 'bob'), (self.lisa.pk, 'lisa')]
        self.assertEqual(sorted(filterspec.lookup_choices), sorted(expected))

    def test_listfilter_genericrelation(self):
        django_bookmark = Bookmark.objects.create(url='https://www.djangoproject.com/')
        python_bookmark = Bookmark.objects.create(url='https://www.python.org/')
        kernel_bookmark = Bookmark.objects.create(url='https://www.kernel.org/')

        TaggedItem.objects.create(content_object=django_bookmark, tag='python')
        TaggedItem.objects.create(content_object=python_bookmark, tag='python')
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/admin_filters/models.py\n@@\n class Employee(models.Model):\n     department = models.ForeignKey(Department, models.CASCADE, to_field=\"code\")\n     name = models.CharField(max_length=100)\n \n+    class Meta:\n+        ordering = ('name',)\n+\n     def __str__(self):\n         return self.name\n*** Update File: /testbed/tests/admin_filters/tests.py\n@@\n     def test_relatedfieldlistfilter_foreignkey_ordering_reverse(self):\n         class EmployeeAdminWithOrdering(ModelAdmin):\n             ordering = ('-name',)\n@@\n         expected = [(self.john.pk, 'John Blue'), (self.jack.pk, 'Jack Red')]\n         self.assertEqual(filterspec.lookup_choices, expected)\n \n+    def test_relatedfieldlistfilter_foreignkey_ordering_without_admin(self):\n+        \"\"\"RelatedFieldListFilter ordering respects Model._meta.ordering.\"\"\"\n+        class BookAdmin(ModelAdmin):\n+            list_filter = ('employee',)\n+\n+        modeladmin = BookAdmin(Book, site)\n+\n+        request = self.request_factory.get('/')\n+        request.user = self.alfred\n+        changelist = modeladmin.get_changelist_instance(request)\n+        filterspec = changelist.get_filters(request)[0][0]\n+        expected = [(self.jack.pk, 'Jack Red'), (self.john.pk, 'John Blue')]\n+        self.assertEqual(filterspec.lookup_choices, expected)\n+\n@@\n     def test_relatedonlyfieldlistfilter_foreignkey(self):\n         modeladmin = BookAdminRelatedOnlyFilter(Book, site)\n@@\n         expected = [(self.alfred.pk, 'alfred'), (self.bob.pk, 'bob')]\n         self.assertEqual(sorted(filterspec.lookup_choices), sorted(expected))\n \n+    def test_relatedonlyfieldlistfilter_foreignkey_ordering(self):\n+        class EmployeeAdminWithOrdering(ModelAdmin):\n+            ordering = ('-name',)\n+\n+        class BookAdmin(ModelAdmin):\n+            list_filter = (('employee', RelatedOnlyFieldListFilter),)\n+\n+        site.register(Employee, EmployeeAdminWithOrdering)\n+        self.addCleanup(lambda: site.unregister(Employee))\n+        modeladmin = BookAdmin(Book, site)\n+\n+        self.djangonaut_book.employee = self.john\n+        self.djangonaut_book.save()\n+        self.bio_book.employee = self.jack\n+        self.bio_book.save()\n+\n+        request = self.request_factory.get('/')\n+        request.user = self.alfred\n+        changelist = modeladmin.get_changelist_instance(request)\n+        filterspec = changelist.get_filters(request)[0][0]\n+        expected = [(self.john.pk, 'John Blue'), (self.jack.pk, 'Jack Red')]\n+        self.assertEqual(filterspec.lookup_choices, expected)\n+\n+    def test_relatedonlyfieldlistfilter_foreignkey_ordering_without_admin(self):\n+        \"\"\"RelatedOnlyFieldListFilter ordering respects Model._meta.ordering.\"\"\"\n+        class BookAdmin(ModelAdmin):\n+            list_filter = (('employee', RelatedOnlyFieldListFilter),)\n+\n+        modeladmin = BookAdmin(Book, site)\n+\n+        self.djangonaut_book.employee = self.john\n+        self.djangonaut_book.save()\n+        self.bio_book.employee = self.jack\n+        self.bio_book.save()\n+\n+        request = self.request_factory.get('/')\n+        request.user = self.alfred\n+        changelist = modeladmin.get_changelist_instance(request)\n+        filterspec = changelist.get_filters(request)[0][0]\n+        expected = [(self.jack.pk, 'Jack Red'), (self.john.pk, 'John Blue')]\n+        self.assertEqual(filterspec.lookup_choices, expected)\n+\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/admin_filters/models.py /testbed/tests/admin_filters/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/admin_filters/models.py now (82 lines), around the change:
50:    department = models.ForeignKey(Department, models.CASCADE, to_field="code")
51:    name = models.CharField(max_length=100)
52:
53:    class Meta:
54:        ordering = ('name',)
55:
56:    def __str__(self):
57:        return self.name
58:

/testbed/tests/admin_filters/tests.py now (1311 lines), around the change:
591:        expected = [(self.john.pk, 'John Blue'), (self.jack.pk, 'Jack Red')]
592:        self.assertEqual(filterspec.lookup_choices, expected)
593:
594:    def test_relatedfieldlistfilter_foreignkey_ordering_without_admin(self):
595:        """RelatedFieldListFilter ordering respects Model._meta.ordering."""
596:        class BookAdmin(ModelAdmin):
597:            list_filter = ('employee',)
598:
599:        modeladmin = BookAdmin(Book, site)
600:
601:        request = self.request_factory.get('/')
602:        request.user = self.alfred
603:        changelist = modeladmin.get_changelist_instance(request)
604:        filterspec = changelist.get_filters(request)[0][0]
605:        expected = [(self.jack.pk, 'Jack Red'), (self.john.pk, 'John Blue')]
606:        self.assertEqual(filterspec.lookup_choices, expected)
607:
608:    def test_relatedfieldlistfilter_manytomany(self):
609:        modeladmin = BookAdmin(Book, site)
610:
…
722:        expected = [(self.alfred.pk, 'alfred'), (self.bob.pk, 'bob')]
723:        self.assertEqual(sorted(filterspec.lookup_choices), sorted(expected))
724:
725:    def test_relatedonlyfieldlistfilter_foreignkey_ordering(self):
726:        class EmployeeAdminWithOrdering(ModelAdmin):
727:            ordering = ('-name',)
728:
729:        class BookAdmin(ModelAdmin):
730:            list_filter = (('employee', RelatedOnlyFieldListFilter),)
731:
732:        site.register(Employee, EmployeeAdminWithOrdering)
733:        self.addCleanup(lambda: site.unregister(Employee))
734:        modeladmin = BookAdmin(Book, site)
735:
736:        self.djangonaut_book.employee = self.john
737:        self.djangonaut_book.save()
738:        self.bio_book.employee = self.jack
739:        self.bio_book.save()
740:
741:        request = self.request_factory.get('/')
742:        request.user = self.alfred
743:        changelist = modeladmin.get_changelist_instance(request)
744:        filterspec = changelist.get_filters(request)[0][0]
745:        expected = [(self.john.pk, 'John Blue'), (self.jack.pk, 'Jack Red')]
746:        self.assertEqual(filterspec.lookup_choices, expected)
747:
748:    def test_relatedonlyfieldlistfilter_foreignkey_ordering_without_admin(self):
749:        """RelatedOnlyFieldListFilter ordering respects Model._meta.ordering."""
750:        class BookAdmin(ModelAdmin):
751:            list_filter = (('employee', RelatedOnlyFieldListFilter),)
752:
753:        modeladmin = BookAdmin(Book, site)
754:
755:        self.djangonaut_book.employee = self.john
756:        self.djangonaut_book.save()
757:        self.bio_book.employee = self.jack
758:        self.bio_book.save()
759:
760:        request = self.request_factory.get('/')
761:        request.user = self.alfred
762:        changelist = modeladmin.get_changelist_instance(request)
763:        filterspec = changelist.get_filters(request)[0][0]
764:        expected = [(self.jack.pk, 'Jack Red'), (self.john.pk, 'John Blue')]
765:        self.assertEqual(filterspec.lookup_choices, expected)
766:
767:    def test_relatedonlyfieldlistfilter_underscorelookup_foreignkey(self):
768:        Department.objects.create(code='TEST', description='Testing')
769:        self.djangonaut_book.employee = self.john
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py admin_filters --verbosity 1 2>&1 | tail -40"
}
```

**tool result**

```
Creating test database for alias 'default'...
...................................
----------------------------------------------------------------------
Ran 35 tests in 0.361s

OK
Destroying test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport django, inspect\nprint(django.__version__, django.__file__)\nEOF\nfind / -path '*/django/contrib/admin/filters.py' 2>/dev/null | head"
}
```

**tool result**

```
3.0.dev20260813010220 /testbed/django/__init__.py
/testbed/django/contrib/admin/filters.py
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py admin_ordering admin_views --verbosity 1 2>&1 | tail -20"
}
```

**tool result**

```

OK (skipped=15)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'other'...
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
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\"; echo \"exit=$?\"; git status --porcelain -- . ':(exclude).memdoor'"
}
```

**tool result**

```
exit=0
 M django/contrib/admin/filters.py
 M tests/admin_filters/models.py
 M tests/admin_filters/tests.py
```

**assistant**

```
Implemented the ordering fixes:

- `RelatedFieldListFilter.field_choices()` now falls back to the related model's `Meta.ordering` when no related `ModelAdmin` ordering is defined.
- `RelatedOnlyFieldListFilter.field_choices()` now applies the same ordering logic and passes `ordering` to `field.get_choices()`.
- Added regression tests covering both filters with and without a related `ModelAdmin.ordering`, plus `Meta.ordering` on the test `Employee` model.

Verification:
- `admin_filters`: 35 tests passed
- `admin_ordering` and `admin_views`: passed
- Required command exits 0.
```

## Run folder `single-2026-11-06T105050`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Ordering problem in admin.RelatedFieldListFilter and admin.RelatedOnlyFieldListFilter
Description
	
RelatedFieldListFilter doesn't fall back to the ordering defined in Model._meta.ordering. 
Ordering gets set to an empty tuple in ​https://github.com/django/django/blob/2.2.1/django/contrib/admin/filters.py#L196 and unless ordering is defined on the related model's ModelAdmin class it stays an empty tuple. IMHO it should fall back to the ordering defined in the related model's Meta.ordering field.
RelatedOnlyFieldListFilter doesn't order the related model at all, even if ordering is defined on the related model's ModelAdmin class.
That's because the call to field.get_choices ​https://github.com/django/django/blob/2.2.1/django/contrib/admin/filters.py#L422 omits the ordering kwarg entirely.
```
