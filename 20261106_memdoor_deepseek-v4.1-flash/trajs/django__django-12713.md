# django__django-12713 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 35s 63 lines cost=0.001816 in=97397 cached=72704 out=2456 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Allow overridding widget in formfield_for_manytomany().
Description
	 
		(last modified by Mariusz Felisiak)
	 
It does not work when I set widget param to function formfield_for_manytomany().
This is different from the formfield_for_foreignkey() function.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain -- . ':(exclude).memdoor' && git log --oneline -5"
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
90e048cf4d SWE-bench
5b884d45ac Fixed #29501 -- Allowed dbshell to pass options to underlying tool.
8e8c3f964e Refs #29501 -- Allowed customizing exit status for management commands.
6cad911674 Refs #29501 -- Simplified BaseCommand.run_from_argv() a bit.
8bd9000a7d Refs #29501 -- Made dbshell catch more specific FileNotFoundError.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"def formfield_for_manytomany\" django tests | head -20"
}
```

**tool result**

```
django/contrib/auth/admin.py:31:    def formfield_for_manytomany(self, db_field, request=None, **kwargs):
django/contrib/admin/options.py:242:    def formfield_for_manytomany(self, db_field, request, **kwargs):
tests/admin_ordering/tests.py:177:            def formfield_for_manytomany(self, db_field, request, **kwargs):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '205,260p' django/contrib/admin/options.py"
}
```

**tool result**

```
    def get_field_queryset(self, db, db_field, request):
        """
        If the ModelAdmin specifies ordering, the queryset should respect that
        ordering.  Otherwise don't specify the queryset, let the field decide
        (return None in that case).
        """
        related_admin = self.admin_site._registry.get(db_field.remote_field.model)
        if related_admin is not None:
            ordering = related_admin.get_ordering(request)
            if ordering is not None and ordering != ():
                return db_field.remote_field.model._default_manager.using(db).order_by(*ordering)
        return None

    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        """
        Get a form Field for a ForeignKey.
        """
        db = kwargs.get('using')

        if 'widget' not in kwargs:
            if db_field.name in self.get_autocomplete_fields(request):
                kwargs['widget'] = AutocompleteSelect(db_field.remote_field, self.admin_site, using=db)
            elif db_field.name in self.raw_id_fields:
                kwargs['widget'] = widgets.ForeignKeyRawIdWidget(db_field.remote_field, self.admin_site, using=db)
            elif db_field.name in self.radio_fields:
                kwargs['widget'] = widgets.AdminRadioSelect(attrs={
                    'class': get_ul_class(self.radio_fields[db_field.name]),
                })
                kwargs['empty_label'] = _('None') if db_field.blank else None

        if 'queryset' not in kwargs:
            queryset = self.get_field_queryset(db, db_field, request)
            if queryset is not None:
                kwargs['queryset'] = queryset

        return db_field.formfield(**kwargs)

    def formfield_for_manytomany(self, db_field, request, **kwargs):
        """
        Get a form Field for a ManyToManyField.
        """
        # If it uses an intermediary model that isn't auto created, don't show
        # a field in admin.
        if not db_field.remote_field.through._meta.auto_created:
            return None
        db = kwargs.get('using')

        autocomplete_fields = self.get_autocomplete_fields(request)
        if db_field.name in autocomplete_fields:
            kwargs['widget'] = AutocompleteSelectMultiple(db_field.remote_field, self.admin_site, using=db)
        elif db_field.name in self.raw_id_fields:
            kwargs['widget'] = widgets.ManyToManyRawIdWidget(db_field.remote_field, self.admin_site, using=db)
        elif db_field.name in [*self.filter_vertical, *self.filter_horizontal]:
            kwargs['widget'] = widgets.FilteredSelectMultiple(
                db_field.verbose_name,
                db_field.name in self.filter_vertical
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '260,285p' django/contrib/admin/options.py; grep -rn \"formfield_for_manytomany\" tests | head -30"
}
```

**tool result**

```
                db_field.name in self.filter_vertical
            )

        if 'queryset' not in kwargs:
            queryset = self.get_field_queryset(db, db_field, request)
            if queryset is not None:
                kwargs['queryset'] = queryset

        form_field = db_field.formfield(**kwargs)
        if (isinstance(form_field.widget, SelectMultiple) and
                not isinstance(form_field.widget, (CheckboxSelectMultiple, AutocompleteSelectMultiple))):
            msg = _('Hold down “Control”, or “Command” on a Mac, to select more than one.')
            help_text = form_field.help_text
            form_field.help_text = format_lazy('{} {}', help_text, msg) if help_text else msg
        return form_field

    def get_autocomplete_fields(self, request):
        """
        Return a list of ForeignKey and/or ManyToMany fields which should use
        an autocomplete widget.
        """
        return self.autocomplete_fields

    def get_view_on_site_url(self, obj=None):
        if obj is None or not self.view_on_site:
            return None
tests/admin_ordering/tests.py:144:        m2m_field = site._registry[Song].formfield_for_manytomany(Song.other_interpreters.field, request=None)
tests/admin_ordering/tests.py:177:            def formfield_for_manytomany(self, db_field, request, **kwargs):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/admin/options.py\n@@\n-        autocomplete_fields = self.get_autocomplete_fields(request)\n-        if db_field.name in autocomplete_fields:\n-            kwargs['widget'] = AutocompleteSelectMultiple(db_field.remote_field, self.admin_site, using=db)\n-        elif db_field.name in self.raw_id_fields:\n-            kwargs['widget'] = widgets.ManyToManyRawIdWidget(db_field.remote_field, self.admin_site, using=db)\n-        elif db_field.name in [*self.filter_vertical, *self.filter_horizontal]:\n-            kwargs['widget'] = widgets.FilteredSelectMultiple(\n-                db_field.verbose_name,\n-                db_field.name in self.filter_vertical\n-            )\n+        if 'widget' not in kwargs:\n+            autocomplete_fields = self.get_autocomplete_fields(request)\n+            if db_field.name in autocomplete_fields:\n+                kwargs['widget'] = AutocompleteSelectMultiple(db_field.remote_field, self.admin_site, using=db)\n+            elif db_field.name in self.raw_id_fields:\n+                kwargs['widget'] = widgets.ManyToManyRawIdWidget(db_field.remote_field, self.admin_site, using=db)\n+            elif db_field.name in [*self.filter_vertical, *self.filter_horizontal]:\n+                kwargs['widget'] = widgets.FilteredSelectMultiple(\n+                    db_field.verbose_name,\n+                    db_field.name in self.filter_vertical\n+                )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/admin/options.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/admin/options.py now (2185 lines), around the change:
249:            return None
250:        db = kwargs.get('using')
251:
252:        if 'widget' not in kwargs:
253:            autocomplete_fields = self.get_autocomplete_fields(request)
254:            if db_field.name in autocomplete_fields:
255:                kwargs['widget'] = AutocompleteSelectMultiple(db_field.remote_field, self.admin_site, using=db)
256:            elif db_field.name in self.raw_id_fields:
257:                kwargs['widget'] = widgets.ManyToManyRawIdWidget(db_field.remote_field, self.admin_site, using=db)
258:            elif db_field.name in [*self.filter_vertical, *self.filter_horizontal]:
259:                kwargs['widget'] = widgets.FilteredSelectMultiple(
260:                    db_field.verbose_name,
261:                    db_field.name in self.filter_vertical
262:                )
263:
264:        if 'queryset' not in kwargs:
265:            queryset = self.get_field_queryset(db, db_field, request)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"formfield_for_foreignkey\\|widget=.*formfield\\|custom.*widget\" tests/admin_* | grep -i test | head -30"
}
```

**tool result**

```
tests/admin_ordering/tests.py:143:        fk_field = site._registry[Song].formfield_for_foreignkey(Song.band.field, request=None)
tests/admin_ordering/tests.py:172:            def formfield_for_foreignkey(self, db_field, request, **kwargs):
tests/admin_ordering/tests.py:175:                return super().formfield_for_foreignkey(db_field, request, **kwargs)
tests/admin_ordering/tests.py:180:                return super().formfield_for_foreignkey(db_field, request, **kwargs)
tests/admin_widgets/tests.py:673:    def test_custom_widget_render(self):
tests/admin_widgets/widgetadmin.py:19:    def formfield_for_foreignkey(self, db_field, request, **kwargs):
tests/admin_widgets/widgetadmin.py:23:        return super().formfield_for_foreignkey(db_field, request, **kwargs)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '110,200p' tests/admin_ordering/tests.py; sed -n '1,40p' tests/admin_ordering/tests.py"
}
```

**tool result**

```
        inline = SongInlineDefaultOrdering(self.band, site)
        names = [s.name for s in inline.get_queryset(request)]
        self.assertEqual(['Dude (Looks Like a Lady)', 'Jaded', 'Pink'], names)

    def test_specified_ordering(self):
        """
        Let's check with ordering set to something different than the default.
        """
        inline = SongInlineNewOrdering(self.band, site)
        names = [s.name for s in inline.get_queryset(request)]
        self.assertEqual(['Jaded', 'Pink', 'Dude (Looks Like a Lady)'], names)


class TestRelatedFieldsAdminOrdering(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.b1 = Band.objects.create(name='Pink Floyd', bio='', rank=1)
        cls.b2 = Band.objects.create(name='Foo Fighters', bio='', rank=5)

    def setUp(self):
        # we need to register a custom ModelAdmin (instead of just using
        # ModelAdmin) because the field creator tries to find the ModelAdmin
        # for the related model
        class SongAdmin(admin.ModelAdmin):
            pass
        site.register(Song, SongAdmin)

    def tearDown(self):
        site.unregister(Song)
        if Band in site._registry:
            site.unregister(Band)

    def check_ordering_of_field_choices(self, correct_ordering):
        fk_field = site._registry[Song].formfield_for_foreignkey(Song.band.field, request=None)
        m2m_field = site._registry[Song].formfield_for_manytomany(Song.other_interpreters.field, request=None)
        self.assertEqual(list(fk_field.queryset), correct_ordering)
        self.assertEqual(list(m2m_field.queryset), correct_ordering)

    def test_no_admin_fallback_to_model_ordering(self):
        # should be ordered by name (as defined by the model)
        self.check_ordering_of_field_choices([self.b2, self.b1])

    def test_admin_with_no_ordering_fallback_to_model_ordering(self):
        class NoOrderingBandAdmin(admin.ModelAdmin):
            pass
        site.register(Band, NoOrderingBandAdmin)

        # should be ordered by name (as defined by the model)
        self.check_ordering_of_field_choices([self.b2, self.b1])

    def test_admin_ordering_beats_model_ordering(self):
        class StaticOrderingBandAdmin(admin.ModelAdmin):
            ordering = ('rank',)
        site.register(Band, StaticOrderingBandAdmin)

        # should be ordered by rank (defined by the ModelAdmin)
        self.check_ordering_of_field_choices([self.b1, self.b2])

    def test_custom_queryset_still_wins(self):
        """Custom queryset has still precedence (#21405)"""
        class SongAdmin(admin.ModelAdmin):
            # Exclude one of the two Bands from the querysets
            def formfield_for_foreignkey(self, db_field, request, **kwargs):
                if db_field.name == 'band':
                    kwargs["queryset"] = Band.objects.filter(rank__gt=2)
                return super().formfield_for_foreignkey(db_field, request, **kwargs)

            def formfield_for_manytomany(self, db_field, request, **kwargs):
                if db_field.name == 'other_interpreters':
                    kwargs["queryset"] = Band.objects.filter(rank__gt=2)
                return super().formfield_for_foreignkey(db_field, request, **kwargs)

        class StaticOrderingBandAdmin(admin.ModelAdmin):
            ordering = ('rank',)

        site.unregister(Song)
        site.register(Song, SongAdmin)
        site.register(Band, StaticOrderingBandAdmin)

        self.check_ordering_of_field_choices([self.b2])
from django.contrib import admin
from django.contrib.admin.options import ModelAdmin
from django.contrib.auth.models import User
from django.db.models import F
from django.test import RequestFactory, TestCase

from .models import (
    Band, DynOrderingBandAdmin, Song, SongInlineDefaultOrdering,
    SongInlineNewOrdering,
)


class MockRequest:
    pass


class MockSuperUser:
    def has_perm(self, perm):
        return True

    def has_module_perms(self, module):
        return True


request = MockRequest()
request.user = MockSuperUser()

site = admin.AdminSite()


class TestAdminOrdering(TestCase):
    """
    Let's make sure that ModelAdmin.get_queryset uses the ordering we define
    in ModelAdmin rather that ordering defined in the model's inner Meta
    class.
    """
    request_factory = RequestFactory()

    @classmethod
    def setUpTestData(cls):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/admin_ordering/tests.py\n@@\n-from django.contrib import admin\n+from django import forms\n+from django.contrib import admin\n@@\n     def test_custom_queryset_still_wins(self):\n         \"\"\"Custom queryset has still precedence (#21405)\"\"\"\n         class SongAdmin(admin.ModelAdmin):\n@@\n             def formfield_for_manytomany(self, db_field, request, **kwargs):\n                 if db_field.name == 'other_interpreters':\n                     kwargs[\"queryset\"] = Band.objects.filter(rank__gt=2)\n-                return super().formfield_for_foreignkey(db_field, request, **kwargs)\n+                return super().formfield_for_manytomany(db_field, request, **kwargs)\n@@\n \n         self.check_ordering_of_field_choices([self.b2])\n+\n+    def test_custom_widget_still_wins(self):\n+        \"\"\"Custom widget has precedence over admin widgets.\"\"\"\n+        class SongAdmin(admin.ModelAdmin):\n+            raw_id_fields = ('other_interpreters',)\n+\n+            def formfield_for_manytomany(self, db_field, request, **kwargs):\n+                if db_field.name == 'other_interpreters':\n+                    kwargs['widget'] = forms.SelectMultiple\n+                return super().formfield_for_manytomany(db_field, request, **kwargs)\n+\n+        site.unregister(Song)\n+        site.register(Song, SongAdmin)\n+\n+        field = site._registry[Song].formfield_for_manytomany(\n+            Song.other_interpreters.field, request=None,\n+        )\n+        self.assertIsInstance(field.widget, forms.SelectMultiple)\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/admin_ordering/tests.py: the lines to change in /testbed/tests/admin_ordering/tests.py appear more than once (lines 188 and 189): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '186,200p' tests/admin_ordering/tests.py"
}
```

**tool result**

```
        site.register(Song, SongAdmin)
        site.register(Band, StaticOrderingBandAdmin)

        self.check_ordering_of_field_choices([self.b2])
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/admin_ordering/tests.py\n@@\n-from django.contrib import admin\n+from django import forms\n+from django.contrib import admin\n@@\n-        self.check_ordering_of_field_choices([self.b2])\n+        self.check_ordering_of_field_choices([self.b2])\n+\n+    def test_custom_widget_still_wins(self):\n+        \"\"\"Custom widget has precedence over admin widgets.\"\"\"\n+        class SongAdmin(admin.ModelAdmin):\n+            raw_id_fields = ('other_interpreters',)\n+\n+            def formfield_for_manytomany(self, db_field, request, **kwargs):\n+                if db_field.name == 'other_interpreters':\n+                    kwargs['widget'] = forms.SelectMultiple\n+                return super().formfield_for_manytomany(db_field, request, **kwargs)\n+\n+        site.unregister(Song)\n+        site.register(Song, SongAdmin)\n+\n+        field = site._registry[Song].formfield_for_manytomany(\n+            Song.other_interpreters.field, request=None,\n+        )\n+        self.assertIsInstance(field.widget, forms.SelectMultiple)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/admin_ordering/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/admin_ordering/tests.py now (208 lines), around the change:
1:from django import forms
2:from django.contrib import admin
3:from django.contrib.admin.options import ModelAdmin
4:from django.contrib.auth.models import User
…
188:        site.register(Band, StaticOrderingBandAdmin)
189:
190:        self.check_ordering_of_field_choices([self.b2])
191:
192:    def test_custom_widget_still_wins(self):
193:        """Custom widget has precedence over admin widgets."""
194:        class SongAdmin(admin.ModelAdmin):
195:            raw_id_fields = ('other_interpreters',)
196:
197:            def formfield_for_manytomany(self, db_field, request, **kwargs):
198:                if db_field.name == 'other_interpreters':
199:                    kwargs['widget'] = forms.SelectMultiple
200:                return super().formfield_for_manytomany(db_field, request, **kwargs)
201:
202:        site.unregister(Song)
203:        site.register(Song, SongAdmin)
204:
205:        field = site._registry[Song].formfield_for_manytomany(
206:            Song.other_interpreters.field, request=None,
207:        )
208:        self.assertIsInstance(field.widget, forms.SelectMultiple)
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py admin_ordering -v1 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
...........
----------------------------------------------------------------------
Ran 11 tests in 0.131s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "git status --porcelain -- . ':(exclude).memdoor' && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS"
}
```

**tool result**

```
 M django/contrib/admin/options.py
 M tests/admin_ordering/tests.py
PASS
```

**assistant**

```
Done. Modified `ModelAdmin.formfield_for_manytomany()` in `django/contrib/admin/options.py` so an explicitly supplied `widget` keyword is respected instead of being overwritten by admin widget selection (matching `formfield_for_foreignkey()` behavior). Added a regression test and fixed the pre-existing test that called the wrong super method. `admin_ordering` tests pass (11 tests OK), and the completion command exits 0.
```

## Run folder `single-2026-11-06T105927`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Allow overridding widget in formfield_for_manytomany().
Description
	 
		(last modified by Mariusz Felisiak)
	 
It does not work when I set widget param to function formfield_for_manytomany().
This is different from the formfield_for_foreignkey() function.
```
