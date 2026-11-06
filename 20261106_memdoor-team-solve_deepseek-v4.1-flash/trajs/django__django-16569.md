# django__django-16569 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 36s 35 lines cost=0.001692 in=78989 cached=60416 out=2605 calls=12`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Formsets' add_fields() method fails in some circumstances if the argument index is None.
Description
	
Formsets' add_fields() method fails in some circumstances if the argument index is None.
When a FormSet has the attributes self.can_delete == True and self.can_delete_extra == False, calling the add_fields() method on that FormSet fails if the argument index is None. This occurs for example when calling FormSet.empty_form(). The result is that the method raises the exception TypeError: '<' not supported between instances of 'NoneType' and 'int'. 
Code example:
MyFormSet = forms.formset_factory(
	form=MyForm,
	can_delete=True,
	can_delete_extra=False,
)
my_formset = MyFormSet(
	initial=None,
)
print(my_formset.empty_form)
The reason this happens is that in in line 493 of [django.forms.formsets](​https://github.com/django/django/blob/main/django/forms/formsets.py) index is compared to initial_form_count:
if self.can_delete and (self.can_delete_extra or index < initial_form_count):
Checking for index not None should fix the issue:
if self.can_delete and (self.can_delete_extra or (index is not None and index < initial_form_count)):
How to Reproduce
A self-contained example to reproduce this bug is as follows:
#!/usr/bin/env python3
import os
import django
from django import forms
class MyForm(forms.Form):
	my_field = forms.CharField()
if __name__ == "__main__":
	settings_file = os.path.splitext(os.path.basename(__file__))[0]
	django.conf.settings.configure(
		DEBUG=True,
		MIDDLEWARE_CLASSES=[],
		ROOT_URLCONF=settings_file,
	)
	django.setup()
	MyFormSet = forms.formset_factory(
		form=MyForm,
		can_delete=True,
		can_delete_extra=False,
	)
	my_formset = MyFormSet(
		initial=None,
	)
	print(my_formset.empty_form)


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && grep -n \"can_delete_extra or index\" django/forms/formsets.py"
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
pyproject.toml
scripts
setup.cfg
setup.py
tests
tox.ini
493:        if self.can_delete and (self.can_delete_extra or index < initial_form_count):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/forms/formsets.py",
  "offset": 480,
  "limit": 25
}
```

**tool result**

```
            if index is not None and index < initial_form_count:
                form.fields[ORDERING_FIELD_NAME] = IntegerField(
                    label=_("Order"),
                    initial=index + 1,
                    required=False,
                    widget=self.get_ordering_widget(),
                )
            else:
                form.fields[ORDERING_FIELD_NAME] = IntegerField(
                    label=_("Order"),
                    required=False,
                    widget=self.get_ordering_widget(),
                )
        if self.can_delete and (self.can_delete_extra or index < initial_form_count):
            form.fields[DELETION_FIELD_NAME] = BooleanField(
                label=_("Delete"),
                required=False,
                widget=self.get_deletion_widget(),
            )

    def add_prefix(self, index):
        return "%s-%s" % (self.prefix, index)

    def is_multipart(self):
        """

[71 more lines in /testbed/django/forms/formsets.py (575 in all). read_file with offset: 505 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/forms/formsets.py\n@@\n-        if self.can_delete and (self.can_delete_extra or index < initial_form_count):\n+        if self.can_delete and (\n+            self.can_delete_extra or (index is not None and index < initial_form_count)\n+        ):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/forms/formsets.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/forms/formsets.py now (577 lines), around the change:
490:                    required=False,
491:                    widget=self.get_ordering_widget(),
492:                )
493:        if self.can_delete and (
494:            self.can_delete_extra or (index is not None and index < initial_form_count)
495:        ):
496:            form.fields[DELETION_FIELD_NAME] = BooleanField(
497:                label=_("Delete"),
498:                required=False,
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"can_delete_extra\" tests/forms_tests/tests/test_formsets.py | head -20"
}
```

**tool result**

```
1459:    def test_can_delete_extra_formset_forms(self):
1470:            can_delete_extra=False,
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/forms_tests/tests/test_formsets.py",
  "offset": 1450,
  "limit": 40
}
```

**tool result**

```
        data["choices-1-votes"] = ""
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertEqual(formset.total_error_count(), 2)

    def test_html_safe(self):
        formset = self.make_choiceformset()
        self.assertTrue(hasattr(formset, "__html__"))
        self.assertEqual(str(formset), formset.__html__())

    def test_can_delete_extra_formset_forms(self):
        ChoiceFormFormset = formset_factory(form=Choice, can_delete=True, extra=2)
        formset = ChoiceFormFormset()
        self.assertEqual(len(formset), 2)
        self.assertIn("DELETE", formset.forms[0].fields)
        self.assertIn("DELETE", formset.forms[1].fields)

    def test_disable_delete_extra_formset_forms(self):
        ChoiceFormFormset = formset_factory(
            form=Choice,
            can_delete=True,
            can_delete_extra=False,
            extra=2,
        )
        formset = ChoiceFormFormset()
        self.assertEqual(len(formset), 2)
        self.assertNotIn("DELETE", formset.forms[0].fields)
        self.assertNotIn("DELETE", formset.forms[1].fields)

        formset = ChoiceFormFormset(initial=[{"choice": "Zero", "votes": "1"}])
        self.assertEqual(len(formset), 3)
        self.assertIn("DELETE", formset.forms[0].fields)
        self.assertNotIn("DELETE", formset.forms[1].fields)
        self.assertNotIn("DELETE", formset.forms[2].fields)

        formset = ChoiceFormFormset(
            data={
                "form-0-choice": "Zero",
                "form-0-votes": "0",
                "form-0-DELETE": "on",
                "form-1-choice": "One",

[411 more lines in /testbed/tests/forms_tests/tests/test_formsets.py (1900 in all). read_file with offset: 1490 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/forms_tests/tests/test_formsets.py",
  "offset": 1490,
  "limit": 30
}
```

**tool result**

```
                "form-1-votes": "1",
                "form-2-choice": "",
                "form-2-votes": "",
                "form-TOTAL_FORMS": "3",
                "form-INITIAL_FORMS": "1",
            },
            initial=[{"choice": "Zero", "votes": "1"}],
        )
        self.assertEqual(
            formset.cleaned_data,
            [
                {"choice": "Zero", "votes": 0, "DELETE": True},
                {"choice": "One", "votes": 1},
                {},
            ],
        )
        self.assertIs(formset._should_delete_form(formset.forms[0]), True)
        self.assertIs(formset._should_delete_form(formset.forms[1]), False)
        self.assertIs(formset._should_delete_form(formset.forms[2]), False)

    def test_template_name_uses_renderer_value(self):
        class CustomRenderer(TemplatesSetting):
            formset_template_name = "a/custom/formset/template.html"

        ChoiceFormSet = formset_factory(Choice, renderer=CustomRenderer)

        self.assertEqual(
            ChoiceFormSet().template_name, "a/custom/formset/template.html"
        )


[381 more lines in /testbed/tests/forms_tests/tests/test_formsets.py (1900 in all). read_file with offset: 1520 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/forms_tests/tests/test_formsets.py\n@@\n         self.assertIs(formset._should_delete_form(formset.forms[0]), True)\n         self.assertIs(formset._should_delete_form(formset.forms[1]), False)\n         self.assertIs(formset._should_delete_form(formset.forms[2]), False)\n \n+    def test_disable_delete_extra_formset_empty_form(self):\n+        ChoiceFormFormset = formset_factory(\n+            form=Choice,\n+            can_delete=True,\n+            can_delete_extra=False,\n+        )\n+        formset = ChoiceFormFormset(initial=None)\n+        self.assertNotIn(\"DELETE\", formset.empty_form.fields)\n+\n     def test_template_name_uses_renderer_value(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/forms_tests/tests/test_formsets.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/forms_tests/tests/test_formsets.py now (1909 lines), around the change:
1506:        self.assertIs(formset._should_delete_form(formset.forms[0]), True)
1507:        self.assertIs(formset._should_delete_form(formset.forms[1]), False)
1508:        self.assertIs(formset._should_delete_form(formset.forms[2]), False)
1509:
1510:    def test_disable_delete_extra_formset_empty_form(self):
1511:        ChoiceFormFormset = formset_factory(
1512:            form=Choice,
1513:            can_delete=True,
1514:            can_delete_extra=False,
1515:        )
1516:        formset = ChoiceFormFormset(initial=None)
1517:        self.assertNotIn("DELETE", formset.empty_form.fields)
1518:
1519:    def test_template_name_uses_renderer_value(self):
1520:        class CustomRenderer(TemplatesSetting):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/forms_tests/tests/test_formsets.py -q 2>&1 | tail -15"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py forms_tests.tests.test_formsets 2>&1 | tail -15"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 159 test(s).
System check identified no issues (0 silenced).
...............................................................................................................................................................
----------------------------------------------------------------------
Ran 159 tests in 0.820s

OK
```

**assistant**

````
Fixed the bug in `django/forms/formsets.py`.

**Change:** `add_fields()` now guards the index comparison with a `None` check:

```python
if self.can_delete and (
    self.can_delete_extra or (index is not None and index < initial_form_count)
):
```

This prevents `TypeError: '<' not supported between instances of 'NoneType' and 'int'` when `empty_form` (which calls `add_fields(None)`) is accessed on a formset with `can_delete=True` and `can_delete_extra=False`.

**Test added:** `test_disable_delete_extra_formset_empty_form` in `tests/forms_tests/tests/test_formsets.py`, asserting the empty form has no `DELETE` field.

**Verification:** All 159 tests in `forms_tests.tests.test_formsets` pass.
````

## Run folder `team-solve-2026-11-06T112714`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
518ea60e10e202ca63062271c92730596fbb9557
```

### `baseline-check.log`

```
check: python tests/runtests.py forms_tests.tests.test_formsets
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 157 test(s).
System check identified no issues (0 silenced).
.............................................................................................................................................................
----------------------------------------------------------------------
Ran 157 tests in 0.827s

OK
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/django/forms/formsets.py b/django/forms/formsets.py
index 235aaf844c..fd4d53a44f 100644
--- a/django/forms/formsets.py
+++ b/django/forms/formsets.py
@@ -490,7 +490,9 @@ class BaseFormSet(RenderableFormMixin):
                     required=False,
                     widget=self.get_ordering_widget(),
                 )
-        if self.can_delete and (self.can_delete_extra or index < initial_form_count):
+        if self.can_delete and (
+            self.can_delete_extra or (index is not None and index < initial_form_count)
+        ):
             form.fields[DELETION_FIELD_NAME] = BooleanField(
                 label=_("Delete"),
                 required=False,
diff --git a/tests/forms_tests/tests/test_formsets.py b/tests/forms_tests/tests/test_formsets.py
index e2c695f0dc..6c406382bc 100644
--- a/tests/forms_tests/tests/test_formsets.py
+++ b/tests/forms_tests/tests/test_formsets.py
@@ -1507,6 +1507,15 @@ class FormsFormsetTestCase(SimpleTestCase):
         self.assertIs(formset._should_delete_form(formset.forms[1]), False)
         self.assertIs(formset._should_delete_form(formset.forms[2]), False)
 
+    def test_disable_delete_extra_formset_empty_form(self):
+        ChoiceFormFormset = formset_factory(
+            form=Choice,
+            can_delete=True,
+            can_delete_extra=False,
+        )
+        formset = ChoiceFormFormset(initial=None)
+        self.assertNotIn("DELETE", formset.empty_form.fields)
+
     def test_template_name_uses_renderer_value(self):
         class CustomRenderer(TemplatesSetting):
             formset_template_name = "a/custom/formset/template.html"
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

Formsets' add_fields() method fails in some circumstances if the argument index is None.
Description
	
Formsets' add_fields() method fails in some circumstances if the argument index is None.
When a FormSet has the attributes self.can_delete == True and self.can_delete_extra == False, calling the add_fields() method on that FormSet fails if the argument index is None. This occurs for example when calling FormSet.empty_form(). The result is that the method raises the exception TypeError: '<' not supported between instances of 'NoneType' and 'int'. 
Code example:
MyFormSet = forms.formset_factory(
	form=MyForm,
	can_delete=True,
	can_delete_extra=False,
)
my_formset = MyFormSet(
	initial=None,
)
print(my_formset.empty_form)
The reason this happens is that in in line 493 of [django.forms.formsets](​https://github.com/django/django/blob/main/django/forms/formsets.py) index is compared to initial_form_count:
if self.can_delete and (self.can_delete_extra or index < initial_form_count):
Checking for index not None should fix the issue:
if self.can_delete and (self.can_delete_extra or (index is not None and index < initial_form_count)):
How to Reproduce
A self-contained example to reproduce this bug is as follows:
#!/usr/bin/env python3
import os
import django
from django import forms
class MyForm(forms.Form):
	my_field = forms.CharField()
if __name__ == "__main__":
	settings_file = os.path.splitext(os.path.basename(__file__))[0]
	django.conf.settings.configure(
		DEBUG=True,
		MIDDLEWARE_CLASSES=[],
		ROOT_URLCONF=settings_file,
	)
	django.setup()
	MyFormSet = forms.formset_factory(
		form=MyForm,
		can_delete=True,
		can_delete_extra=False,
	)
	my_formset = MyFormSet(
		initial=None,
	)
	print(my_formset.empty_form)

## Deliverable

changes to this tree

## Check

`python tests/runtests.py forms_tests.tests.test_formsets`

## Scope

`django/forms/formsets.py`
`tests/forms_tests/tests/test_formsets.py`

## Done when

- `BaseFormSet.add_fields()` no longer raises `TypeError: '<' not supported between instances of 'NoneType' and 'int'` when `index` is `None`, `can_delete` is `True`, and `can_delete_extra` is `False`.
- Accessing `empty_form` on a formset built with `can_delete=True, can_delete_extra=False` succeeds and includes the delete field.
- The `can_delete`/`can_delete_extra` behavior for non-`None` indexes is unchanged.
- (inferred) A regression test covering `empty_form` with `can_delete=True, can_delete_extra=False` passes in `tests/forms_tests/tests/test_formsets.py`.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py forms_tests.tests.test_formsets`

## Scope
`django/forms/formsets.py`
`tests/forms_tests/tests/test_formsets.py`

## Done when
- `BaseFormSet.add_fields()` no longer raises `TypeError: '<' not supported between instances of 'NoneType' and 'int'` when `index` is `None`, `can_delete` is `True`, and `can_delete_extra` is `False`.
- Accessing `empty_form` on a formset built with `can_delete=True, can_delete_extra=False` succeeds and includes the delete field.
- The `can_delete`/`can_delete_extra` behavior for non-`None` indexes is unchanged.
- (inferred) A regression test covering `empty_form` with `can_delete=True, can_delete_extra=False` passes in `tests/forms_tests/tests/test_formsets.py`.

## Approach
The fix is a one-line guard in `django/forms/formsets.py`: change the condition to `if self.can_delete and (self.can_delete_extra or (index is not None and index < initial_form_count))`, so the delete field is added for the empty form (index `None`) only when `can_delete_extra` is true, and the comparison is skipped otherwise.

Candidate approaches:
1. Guard the comparison with `index is not None` (the prompt's suggestion) — minimal, preserves existing semantics for real indexes, and treats `None` as "not an initial form".
2. Reorder to `if self.can_delete and (self.can_delete_extra or (index or 0) < initial_form_count)` — avoids the `TypeError` but silently treats `None` as index 0, which is wrong for `can_delete_extra=False` since the empty form would then get a delete field when `initial_form_count > 0`.
3. Special-case `index is None` earlier in `add_fields()` — more code for the same result; approach 1 is preferred.

Add a regression test in `tests/forms_tests/tests/test_formsets.py` asserting `empty_form` renders/contains the delete field without raising, then run the scoped test command.


# django/forms/formsets.py

```
from django.core.exceptions import ValidationError
from django.forms import Form
from django.forms.fields import BooleanField, IntegerField
from django.forms.renderers import get_default_renderer
from django.forms.utils import ErrorList, RenderableFormMixin
from django.forms.widgets import CheckboxInput, HiddenInput, NumberInput
from django.utils.functional import cached_property
from django.utils.translation import gettext_lazy as _
from django.utils.translation import ngettext_lazy

__all__ = ("BaseFormSet", "formset_factory", "all_valid")

# special field names
TOTAL_FORM_COUNT = "TOTAL_FORMS"
INITIAL_FORM_COUNT = "INITIAL_FORMS"
MIN_NUM_FORM_COUNT = "MIN_NUM_FORMS"
MAX_NUM_FORM_COUNT = "MAX_NUM_FORMS"
ORDERING_FIELD_NAME = "ORDER"
DELETION_FIELD_NAME = "DELETE"

# default minimum number of forms in a formset
DEFAULT_MIN_NUM = 0

# default maximum number of forms in a formset, to prevent memory exhaustion
DEFAULT_MAX_NUM = 1000


class ManagementForm(Form):
    """
    Keep track of how many form instances are displayed on the page. If adding
    new forms via JavaScript, you should increment the count field of this form
    as well.
    """

    TOTAL_FORMS = IntegerField(widget=HiddenInput)
    INITIAL_FORMS = IntegerField(widget=HiddenInput)
    # MIN_NUM_FORM_COUNT and MAX_NUM_FORM_COUNT are output with the rest of the
    # management form, but only for the convenience of client-side code. The
    # POST value of them returned from the client is not checked.
    MIN_NUM_FORMS = IntegerField(required=False, widget=HiddenInput)
    MAX_NUM_FORMS = IntegerField(required=False, widget=HiddenInput)

    def clean(self):
        cleaned_data = super().clean()
        # When the management form is invalid, we don't know how many forms
        # were submitted.
        cleaned_data.setdefault(TOTAL_FORM_COUNT, 0)
        cleaned_data.setdefault(INITIAL_FORM_COUNT, 0)
        return cleaned_data


class BaseFormSet(RenderableFormMixin):
    """
    A collection of instances of the same Form class.
    """

    deletion_widget = CheckboxInput
    ordering_widget = NumberInput
    default_error_messages = {
        "missing_management_form": _(
            "ManagementForm data is missing or has been tampered with. Missing fields: "
            "%(field_names)s. You may need to file a bug report if the issue persists."
        ),
        "too_many_forms": ngettext_lazy(
            "Please submit at most %(num)d form.",
            "Please submit at most %(num)d forms.",
            "num",
        ),
        "too_few_forms": ngettext_lazy(
            "Please submit at least %(num)d form.",
            "Please submit at least %(num)d forms.",
            "num",
        ),
    }

    template_name_div = "django/forms/formsets/div.html"
    template_name_p = "django/forms/formsets/p.html"
    template_name_table = "django/forms/formsets/table.html"
    template_name_ul = "django/forms/formsets/ul.html"

    def __init__(
        self,
        data=None,
        files=None,
        auto_id="id_%s",
        prefix=None,
        initial=None,
        error_class=ErrorList,
        form_kwargs=None,
        error_messages=None,
    ):
        self.is_bound = data is not None or files is not None
        self.prefix = prefix or self.get_default_prefix()
        self.auto_id = auto_id
        self.data = data or {}
        self.files = files or {}
        self.initial = initial
        self.form_kwargs = form_kwargs or {}
        self.error_class = error_class
        self._errors = None
        self._non_form_errors = None

        messages = {}
        for cls in reversed(type(self).__mro__):
            messages.update(getattr(cls, "default_error_messages", {}))
        if error_messages is not None:
            messages.update(error_messages)
        self.error_messages = messages

    def __iter__(self):
        """Yield the forms in the order they should be rendered."""
        return iter(self.forms)

    def __getitem__(self, index):
        """Return the form at the given index, based on the rendering order."""
        return self.forms[index]

    def __len__(self):
        return len(self.forms)

    def __bool__(self):
        """
        Return True since all formsets have a management form which is not
        included in the length.
        """
        return True

    def __repr__(self):
        if self._errors is None:
            is_valid = "Unknown"
        else:
            is_valid = (
                self.is_bound
                and not self._non_form_errors
                and not any(form_errors for form_errors in self._errors)
            )
        return "<%s: bound=%s valid=%s total_forms=%s>" % (
            self.__class__.__qualname__,
            self.is_bound,
            is_valid,
            self.total_form_count(),
        )

    @cached_property
    def management_form(self):
        """Return the ManagementForm instance for this FormSet."""
        if self.is_bound:
            form = ManagementForm(
                self.data,
                auto_id=self.auto_id,
                prefix=self.prefix,
                renderer=self.renderer,
            )
            form.full_clean()
        else:
            form = ManagementForm(
                auto_id=self.auto_id,
                prefix=self.prefix,
                initial={
                    TOTAL_FORM_COUNT: self.total_form_count(),
                    INITIAL_FORM_COUNT: self.initial_form_count(),
                    MIN_NUM_FORM_COUNT: self.min_num,
                    MAX_NUM_FORM_COUNT: self.max_num,
                },
                renderer=self.renderer,
            )
        return form

    def total_form_count(self):
        """Return the total number of forms in this FormSet."""
        if self.is_bound:
            # return absolute_max if it is lower than the actual total form
            # count in the data; this is DoS protection to prevent clients
            # from forcing the server to instantiate arbitrary numbers of
            # forms
            return min(
                self.management_form.cleaned_data[TOTAL_FORM_COUNT], self.absolute_max
            )
        else:
            initial_forms = self.initial_form_count()
            total_forms = max(initial_forms, self.min_num) + self.extra
            # Allow all existing related objects/inlines to be displayed,
            # but don't allow extra beyond max_num.
            if initial_forms > self.max_num >= 0:
                total_forms = initial_forms
            elif total_forms > self.max_num >= 0:
                total_forms = self.max_num
        return total_forms

    def initial_form_count(self):
        """Return the number of forms that are required in this FormSet."""
        if self.is_bound:
            return self.management_form.cleaned_data[INITIAL_FORM_COUNT]
        else:
            # Use the length of the initial data if it's there, 0 otherwise.
            initial_forms = len(self.initial) if self.initial else 0
        return initial_forms

    @cached_property
    def forms(self):
        """Instantiate forms at first property access."""
        # DoS protection is included in total_form_count()
        return [
            self._construct_form(i, **self.get_form_kwargs(i))
            for i in range(self.total_form_count())
        ]

    def get_form_kwargs(self, index):
        """
        Return additional keyword arguments for each individual formset form.

        index will be None if the form being constructed is a new empty
        form.
        """
        return self.form_kwargs.copy()

    def _construct_form(self, i, **kwargs):
        """Instantiate and return the i-th form instance in a formset."""
        defaults = {
            "auto_id": self.auto_id,
            "prefix": self.add_prefix(i),
            "error_class": self.error_class,
            # Don't render the HTML 'required' attribute as it may cause
            # incorrect validation for extra, optional, and deleted
            # forms in the formset.
            "use_required_attribute": False,
            "renderer": self.renderer,
        }
        if self.is_bound:
            defaults["data"] = self.data
            defaults["files"] = self.files
        if self.initial and "initial" not in kwargs:
            try:
                defaults["initial"] = self.initial[i]
            except IndexError:
                pass
        # Allow extra forms to be empty, unless they're part of
        # the minimum forms.
        if i >= self.initial_form_count() and i >= self.min_num:
            defaults["empty_permitted"] = True
        defaults.update(kwargs)
        form = self.form(**defaults)
        self.add_fields(form, i)
        return form

    @property
    def initial_forms(self):
        """Return a list of all the initial forms in this formset."""
        return self.forms[: self.initial_form_count()]

    @property
    def extra_forms(self):
        """Return a list of all the extra forms in this formset."""
        return self.forms[self.initial_form_count() :]

    @property
    def empty_form(self):
        form_kwargs = {
            **self.get_form_kwargs(None),
            "auto_id": self.auto_id,
            "prefix": self.add_prefix("__prefix__"),
            "empty_permitted": True,
            "use_required_attribute": False,
            "renderer": self.renderer,
        }
        form = self.form(**form_kwargs)
        self.add_fields(form, None)
        return form

    @property
    def cleaned_data(self):
        """
        Return a list of form.cleaned_data dicts for every form in self.forms.
        """
        if not self.is_valid():
            raise AttributeError(
                "'%s' object has no attribute 'cleaned_data'" % self.__class__.__name__
            )
        return [form.cleaned_data for form in self.forms]

    @property
    def deleted_forms(self):
        """Return a list of forms that have been marked for deletion."""
        if not self.is_valid() or not self.can_delete:
            return []
        # construct _deleted_form_indexes which is just a list of form indexes
        # that have had their deletion widget set to True
        if not hasattr(self, "_deleted_form_indexes"):
            self._deleted_form_indexes = []
            for i, form in enumerate(self.forms):
                # if this is an extra form and hasn't changed, don't consider it
                if i >= self.initial_form_count() and not form.has_changed():
                    continue
                if self._should_delete_form(form):
                    self._deleted_form_indexes.append(i)
        return [self.forms[i] for i in self._deleted_form_indexes]

    @property
    def ordered_forms(self):
        """
        Return a list of form in the order specified by the incoming data.
        Raise an AttributeError if ordering is not allowed.
        """
        if not self.is_valid() or not self.can_order:
            raise AttributeError(
                "'%s' object has no attribute 'ordered_forms'" % self.__class__.__name__
            )
        # Construct _ordering, which is a list of (form_index, order_field_value)
        # tuples. After constructing this list, we'll sort it by order_field_value
        # so we have a way to get to the form indexes in the order specified
        # by the form data.
        if not hasattr(self, "_ordering"):
            self._ordering = []
            for i, form in enumerate(self.forms):
                # if this is an extra form and hasn't changed, don't consider it
                if i >= self.initial_form_count() and not form.has_changed():
                    continue
                # don't add data marked for deletion to self.ordered_data
                if self.can_delete and self._should_delete_form(form):
                    continue
                self._ordering.append((i, form.cleaned_data[ORDERING_FIELD_NAME]))
            # After we're done populating self._ordering, sort it.
            # A sort function to order things numerically ascending, but
            # None should be sorted below anything else. Allowing None as
            # a comparison value makes it so we can leave ordering fields
            # blank.

            def compare_ordering_key(k):
                if k[1] is None:
                    return (1, 0)  # +infinity, larger than any number
                return (0, k[1])

            self._ordering.sort(key=compare_ordering_key)
        # Return a list of form.cleaned_data dicts in the order specified by
        # the form data.
        return [self.forms[i[0]] for i in self._ordering]

    @classmethod
    def get_default_prefix(cls):
        return "form"

    @classmethod
    def get_deletion_widget(cls):
        return cls.deletion_widget

    @classmethod
    def get_ordering_widget(cls):
        return cls.ordering_widget

    def non_form_errors(self):
        """
        Return an ErrorList of errors that aren't associated with a particular
        form -- i.e., from formset.clean(). Return an empty ErrorList if there
        are none.
        """
        if self._non_form_errors is None:
            self.full_clean()
        return self._non_form_errors

    @property
    def errors(self):
        """Return a list of form.errors for every form in self.forms."""
        if self._errors is None:
            self.full_clean()
        return self._errors

    def total_error_count(self):
        """Return the number of errors across all forms in the formset."""
        return len(self.non_form_errors()) + sum(
            len(form_errors) for form_errors in self.errors
        )

    def _should_delete_form(self, form):
        """Return whether or not the form was marked for deletion."""
        return form.cleaned_data.get(DELETION_FIELD_NAME, False)

    def is_valid(self):
        """Return True if every form in self.forms is valid."""
        if not self.is_bound:
            return False
        # Accessing errors triggers a full clean the first time only.
        self.errors
        # List comprehension ensures is_valid() is called for all forms.
        # Forms due to be deleted shouldn't cause the formset to be invalid.
        forms_valid = all(
            [
                form.is_valid()
                for form in self.forms
                if not (self.can_delete and self._should_delete_form(form))
            ]
        )
        return forms_valid and not self.non_form_errors()

    def full_clean(self):
        """
        Clean all of self.data and populate self._errors and
        self._non_form_errors.
        """
        self._errors = []
        self._non_form_errors = self.error_class(
            error_class="nonform", renderer=self.renderer
        )
        empty_forms_count = 0

        if not self.is_bound:  # Stop further processing.
            return

        if not self.management_form.is_valid():
            error = ValidationError(
                self.error_messages["missing_management_form"],
                params={
                    "field_names": ", ".join(
                        self.management_form.add_prefix(field_name)
                        for field_name in self.management_form.errors
                    ),
                },
                code="missing_management_form",
            )
            self._non_form_errors.append(error)

        for i, form in enumerate(self.forms):
            # Empty forms are unchanged forms beyond those with initial data.
            if not form.has_changed() and i >= self.initial_form_count():
                empty_forms_count += 1
            # Accessing errors calls full_clean() if necessary.
            # _should_delete_form() requires cleaned_data.
            form_errors = form.errors
            if self.can_delete and self._should_delete_form(form):
                continue
            self._errors.append(form_errors)
        try:
            if (
                self.validate_max
                and self.total_form_count() - len(self.deleted_forms) > self.max_num
            ) or self.management_form.cleaned_data[
                TOTAL_FORM_COUNT
            ] > self.absolute_max:
                raise ValidationError(
                    self.error_messages["too_many_forms"] % {"num": self.max_num},
                    code="too_many_forms",
                )
            if (
                self.validate_min
                and self.total_form_count()
                - len(self.deleted_forms)
                - empty_forms_count
                < self.min_num
            ):
                raise ValidationError(
                    self.error_messages["too_few_forms"] % {"num": self.min_num},
                    code="too_few_forms",
                )
            # Give self.clean() a chance to do cross-form validation.
            self.clean()
        except ValidationError as e:
            self._non_form_errors = self.error_class(
                e.error_list,
                error_class="nonform",
                renderer=self.renderer,
            )

    def clean(self):
        """
        Hook for doing any extra formset-wide cleaning after Form.clean() has
        been called on every form. Any ValidationError raised by this method
        will not be associated with a particular form; it will be accessible
        via formset.non_form_errors()
        """
        pass

    def has_changed(self):
        """Return True if data in any form differs from initial."""
        return any(form.has_changed() for form in self)

    def add_fields(self, form, index):
        """A hook for adding extra fields on to each form instance."""
        initial_form_count = self.initial_form_count()
        if self.can_order:
            # Only pre-fill the ordering field for initial forms.
            if index is not None and index < initial_form_count:
                form.fields[ORDERING_FIELD_NAME] = IntegerField(
                    label=_("Order"),
                    initial=index + 1,
                    required=False,
                    widget=self.get_ordering_widget(),
                )
            else:
                form.fields[ORDERING_FIELD_NAME] = IntegerField(
                    label=_("Order"),
                    required=False,
                    widget=self.get_ordering_widget(),
                )
        if self.can_delete and (
            self.can_delete_extra or (index is not None and index < initial_form_count)
        ):
            form.fields[DELETION_FIELD_NAME] = BooleanField(
                label=_("Delete"),
                required=False,
                widget=self.get_deletion_widget(),
            )

    def add_prefix(self, index):
        return "%s-%s" % (self.prefix, index)

    def is_multipart(self):
        """
        Return True if the formset needs to be multipart, i.e. it
        has FileInput, or False otherwise.
        """
        if self.forms:
            return self.forms[0].is_multipart()
        else:
            return self.empty_form.is_multipart()

    @property
    def media(self):
        # All the forms on a FormSet are the same, so you only need to
        # interrogate the first form for media.
        if self.forms:
            return self.forms[0].media
        else:
            return self.empty_form.media

    @property
    def template_name(self):
        return self.renderer.formset_template_name

    def get_context(self):
        return {"formset": self}


def formset_factory(
    form,
    formset=BaseFormSet,
    extra=1,
    can_order=False,
    can_delete=False,
    max_num=None,
    validate_max=False,
    min_num=None,
    validate_min=False,
    absolute_max=None,
    can_delete_extra=True,
    renderer=None,
):
    """Return a FormSet for the given form class."""
    if min_num is None:
        min_num = DEFAULT_MIN_NUM
    if max_num is None:
        max_num = DEFAULT_MAX_NUM
    # absolute_max is a hard limit on forms instantiated, to prevent
    # memory-exhaustion attacks. Default to max_num + DEFAULT_MAX_NUM
    # (which is 2 * DEFAULT_MAX_NUM if max_num is None in the first place).
    if absolute_max is None:
        absolute_max = max_num + DEFAULT_MAX_NUM
    if max_num > absolute_max:
        raise ValueError("'absolute_max' must be greater or equal to 'max_num'.")
    attrs = {
        "form": form,
        "extra": extra,
        "can_order": can_order,
        "can_delete": can_delete,
        "can_delete_extra": can_delete_extra,
        "min_num": min_num,
        "max_num": max_num,
        "absolute_max": absolute_max,
        "validate_min": validate_min,
        "validate_max": validate_max,
        "renderer": renderer or get_default_renderer(),
    }
    return type(form.__name__ + "FormSet", (formset,), attrs)


def all_valid(formsets):
    """Validate every formset and return True if all are valid."""
    # List comprehension ensures is_valid() is called for all formsets.
    return all([formset.is_valid() for formset in formsets])

```


# tests/forms_tests/tests/test_formsets.py

```
import datetime
from collections import Counter
from unittest import mock

from django.core.exceptions import ValidationError
from django.forms import (
    BaseForm,
    CharField,
    DateField,
    FileField,
    Form,
    IntegerField,
    SplitDateTimeField,
    formsets,
)
from django.forms.formsets import (
    INITIAL_FORM_COUNT,
    MAX_NUM_FORM_COUNT,
    MIN_NUM_FORM_COUNT,
    TOTAL_FORM_COUNT,
    BaseFormSet,
    ManagementForm,
    all_valid,
    formset_factory,
)
from django.forms.renderers import TemplatesSetting
from django.forms.utils import ErrorList
from django.forms.widgets import HiddenInput
from django.test import SimpleTestCase

from . import jinja2_tests


class Choice(Form):
    choice = CharField()
    votes = IntegerField()


ChoiceFormSet = formset_factory(Choice)


class ChoiceFormsetWithNonFormError(ChoiceFormSet):
    def clean(self):
        super().clean()
        raise ValidationError("non-form error")


class FavoriteDrinkForm(Form):
    name = CharField()


class BaseFavoriteDrinksFormSet(BaseFormSet):
    def clean(self):
        seen_drinks = []

        for drink in self.cleaned_data:
            if drink["name"] in seen_drinks:
                raise ValidationError("You may only specify a drink once.")

            seen_drinks.append(drink["name"])


# A FormSet that takes a list of favorite drinks and raises an error if
# there are any duplicates.
FavoriteDrinksFormSet = formset_factory(
    FavoriteDrinkForm, formset=BaseFavoriteDrinksFormSet, extra=3
)


class CustomKwargForm(Form):
    def __init__(self, *args, custom_kwarg, **kwargs):
        self.custom_kwarg = custom_kwarg
        super().__init__(*args, **kwargs)


class FormsFormsetTestCase(SimpleTestCase):
    def make_choiceformset(
        self,
        formset_data=None,
        formset_class=ChoiceFormSet,
        total_forms=None,
        initial_forms=0,
        max_num_forms=0,
        min_num_forms=0,
        **kwargs,
    ):
        """
        Make a ChoiceFormset from the given formset_data.
        The data should be given as a list of (choice, votes) tuples.
        """
        kwargs.setdefault("prefix", "choices")
        kwargs.setdefault("auto_id", False)

        if formset_data is None:
            return formset_class(**kwargs)

        if total_forms is None:
            total_forms = len(formset_data)

        def prefixed(*args):
            args = (kwargs["prefix"],) + args
            return "-".join(args)

        data = {
            prefixed("TOTAL_FORMS"): str(total_forms),
            prefixed("INITIAL_FORMS"): str(initial_forms),
            prefixed("MAX_NUM_FORMS"): str(max_num_forms),
            prefixed("MIN_NUM_FORMS"): str(min_num_forms),
        }
        for i, (choice, votes) in enumerate(formset_data):
            data[prefixed(str(i), "choice")] = choice
            data[prefixed(str(i), "votes")] = votes

        return formset_class(data, **kwargs)

    def test_basic_formset(self):
        """
        A FormSet constructor takes the same arguments as Form. Create a
        FormSet for adding data. By default, it displays 1 blank form.
        """
        formset = self.make_choiceformset()
        self.assertHTMLEqual(
            str(formset),
            """<input type="hidden" name="choices-TOTAL_FORMS" value="1">
<input type="hidden" name="choices-INITIAL_FORMS" value="0">
<input type="hidden" name="choices-MIN_NUM_FORMS" value="0">
<input type="hidden" name="choices-MAX_NUM_FORMS" value="1000">
<div>Choice:<input type="text" name="choices-0-choice"></div>
<div>Votes:<input type="number" name="choices-0-votes"></div>""",
        )
        # FormSet are treated similarly to Forms. FormSet has an is_valid()
        # method, and a cleaned_data or errors attribute depending on whether
        # all the forms passed validation. However, unlike a Form, cleaned_data
        # and errors will be a list of dicts rather than a single dict.
        formset = self.make_choiceformset([("Calexico", "100")])
        self.assertTrue(formset.is_valid())
        self.assertEqual(
            [form.cleaned_data for form in formset.forms],
            [{"votes": 100, "choice": "Calexico"}],
        )

        # If a FormSet wasn't passed any data, is_valid() and has_changed()
        # return False.
        formset = self.make_choiceformset()
        self.assertFalse(formset.is_valid())
        self.assertFalse(formset.has_changed())

    def test_form_kwargs_formset(self):
        """
        Custom kwargs set on the formset instance are passed to the
        underlying forms.
        """
        FormSet = formset_factory(CustomKwargForm, extra=2)
        formset = FormSet(form_kwargs={"custom_kwarg": 1})
        for form in formset:
            self.assertTrue(hasattr(form, "custom_kwarg"))
            self.assertEqual(form.custom_kwarg, 1)

    def test_form_kwargs_formset_dynamic(self):
        """Form kwargs can be passed dynamically in a formset."""

        class DynamicBaseFormSet(BaseFormSet):
            def get_form_kwargs(self, index):
                return {"custom_kwarg": index}

        DynamicFormSet = formset_factory(
            CustomKwargForm, formset=DynamicBaseFormSet, extra=2
        )
        formset = DynamicFormSet(form_kwargs={"custom_kwarg": "ignored"})
        for i, form in enumerate(formset):
            self.assertTrue(hasattr(form, "custom_kwarg"))
            self.assertEqual(form.custom_kwarg, i)

    def test_form_kwargs_empty_form(self):
        FormSet = formset_factory(CustomKwargForm)
        formset = FormSet(form_kwargs={"custom_kwarg": 1})
        self.assertTrue(hasattr(formset.empty_form, "custom_kwarg"))
        self.assertEqual(formset.empty_form.custom_kwarg, 1)

    def test_empty_permitted_ignored_empty_form(self):
        formset = ArticleFormSet(form_kwargs={"empty_permitted": False})
        self.assertIs(formset.empty_form.empty_permitted, True)

    def test_formset_validation(self):
        # FormSet instances can also have an error attribute if validation failed for
        # any of the forms.
        formset = self.make_choiceformset([("Calexico", "")])
        self.assertFalse(formset.is_valid())
        self.assertEqual(formset.errors, [{"votes": ["This field is required."]}])

    def test_formset_validation_count(self):
        """
        A formset's ManagementForm is validated once per FormSet.is_valid()
        call and each form of the formset is cleaned once.
        """

        def make_method_counter(func):
            """Add a counter to func for the number of times it's called."""
            counter = Counter()
            counter.call_count = 0

            def mocked_func(*args, **kwargs):
                counter.call_count += 1
                return func(*args, **kwargs)

            return mocked_func, counter

        mocked_is_valid, is_valid_counter = make_method_counter(
            formsets.ManagementForm.is_valid
        )
        mocked_full_clean, full_clean_counter = make_method_counter(BaseForm.full_clean)
        formset = self.make_choiceformset(
            [("Calexico", "100"), ("Any1", "42"), ("Any2", "101")]
        )

        with mock.patch(
            "django.forms.formsets.ManagementForm.is_valid", mocked_is_valid
        ), mock.patch("django.forms.forms.BaseForm.full_clean", mocked_full_clean):
            self.assertTrue(formset.is_valid())
        self.assertEqual(is_valid_counter.call_count, 1)
        self.assertEqual(full_clean_counter.call_count, 4)

    def test_formset_has_changed(self):
        """
        FormSet.has_changed() is True if any data is passed to its forms, even
        if the formset didn't validate.
        """
        blank_formset = self.make_choiceformset([("", "")])
        self.assertFalse(blank_formset.has_changed())
        # invalid formset
        invalid_formset = self.make_choiceformset([("Calexico", "")])
        self.assertFalse(invalid_formset.is_valid())
        self.assertTrue(invalid_formset.has_changed())
        # valid formset
        valid_formset = self.make_choiceformset([("Calexico", "100")])
        self.assertTrue(valid_formset.is_valid())
        self.assertTrue(valid_formset.has_changed())

    def test_formset_initial_data(self):
        """
        A FormSet can be prefilled with existing data by providing a list of
        dicts to the `initial` argument. By default, an extra blank form is
        included.
        """
        formset = self.make_choiceformset(
            initial=[{"choice": "Calexico", "votes": 100}]
        )
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            '<li>Choice: <input type="text" name="choices-0-choice" value="Calexico">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-0-votes" value="100"></li>'
            '<li>Choice: <input type="text" name="choices-1-choice"></li>'
            '<li>Votes: <input type="number" name="choices-1-votes"></li>',
        )

    def test_blank_form_unfilled(self):
        """A form that's displayed as blank may be submitted as blank."""
        formset = self.make_choiceformset(
            [("Calexico", "100"), ("", "")], initial_forms=1
        )
        self.assertTrue(formset.is_valid())
        self.assertEqual(
            [form.cleaned_data for form in formset.forms],
            [{"votes": 100, "choice": "Calexico"}, {}],
        )

    def test_second_form_partially_filled(self):
        """
        If at least one field is filled out on a blank form, it will be
        validated.
        """
        formset = self.make_choiceformset(
            [("Calexico", "100"), ("The Decemberists", "")], initial_forms=1
        )
        self.assertFalse(formset.is_valid())
        self.assertEqual(formset.errors, [{}, {"votes": ["This field is required."]}])

    def test_delete_prefilled_data(self):
        """
        Deleting prefilled data is an error. Removing data from form fields
        isn't the proper way to delete it.
        """
        formset = self.make_choiceformset([("", ""), ("", "")], initial_forms=1)
        self.assertFalse(formset.is_valid())
        self.assertEqual(
            formset.errors,
            [
                {
                    "votes": ["This field is required."],
                    "choice": ["This field is required."],
                },
                {},
            ],
        )

    def test_displaying_more_than_one_blank_form(self):
        """
        More than 1 empty form can be displayed using formset_factory's
        `extra` argument.
        """
        ChoiceFormSet = formset_factory(Choice, extra=3)
        formset = ChoiceFormSet(auto_id=False, prefix="choices")
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            """<li>Choice: <input type="text" name="choices-0-choice"></li>
<li>Votes: <input type="number" name="choices-0-votes"></li>
<li>Choice: <input type="text" name="choices-1-choice"></li>
<li>Votes: <input type="number" name="choices-1-votes"></li>
<li>Choice: <input type="text" name="choices-2-choice"></li>
<li>Votes: <input type="number" name="choices-2-votes"></li>""",
        )
        # Since every form was displayed as blank, they are also accepted as
        # blank. This may seem a little strange, but min_num is used to require
        # a minimum number of forms to be completed.
        data = {
            "choices-TOTAL_FORMS": "3",  # the number of forms rendered
            "choices-INITIAL_FORMS": "0",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
            "choices-0-choice": "",
            "choices-0-votes": "",
            "choices-1-choice": "",
            "choices-1-votes": "",
            "choices-2-choice": "",
            "choices-2-votes": "",
        }
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertTrue(formset.is_valid())
        self.assertEqual([form.cleaned_data for form in formset.forms], [{}, {}, {}])

    def test_min_num_displaying_more_than_one_blank_form(self):
        """
        More than 1 empty form can also be displayed using formset_factory's
        min_num argument. It will (essentially) increment the extra argument.
        """
        ChoiceFormSet = formset_factory(Choice, extra=1, min_num=1)
        formset = ChoiceFormSet(auto_id=False, prefix="choices")
        # Min_num forms are required; extra forms can be empty.
        self.assertFalse(formset.forms[0].empty_permitted)
        self.assertTrue(formset.forms[1].empty_permitted)
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            """<li>Choice: <input type="text" name="choices-0-choice"></li>
<li>Votes: <input type="number" name="choices-0-votes"></li>
<li>Choice: <input type="text" name="choices-1-choice"></li>
<li>Votes: <input type="number" name="choices-1-votes"></li>""",
        )

    def test_min_num_displaying_more_than_one_blank_form_with_zero_extra(self):
        """More than 1 empty form can be displayed using min_num."""
        ChoiceFormSet = formset_factory(Choice, extra=0, min_num=3)
        formset = ChoiceFormSet(auto_id=False, prefix="choices")
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            """<li>Choice: <input type="text" name="choices-0-choice"></li>
<li>Votes: <input type="number" name="choices-0-votes"></li>
<li>Choice: <input type="text" name="choices-1-choice"></li>
<li>Votes: <input type="number" name="choices-1-votes"></li>
<li>Choice: <input type="text" name="choices-2-choice"></li>
<li>Votes: <input type="number" name="choices-2-votes"></li>""",
        )

    def test_single_form_completed(self):
        """Just one form may be completed."""
        data = {
            "choices-TOTAL_FORMS": "3",  # the number of forms rendered
            "choices-INITIAL_FORMS": "0",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
            "choices-0-choice": "Calexico",
            "choices-0-votes": "100",
            "choices-1-choice": "",
            "choices-1-votes": "",
            "choices-2-choice": "",
            "choices-2-votes": "",
        }
        ChoiceFormSet = formset_factory(Choice, extra=3)
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertTrue(formset.is_valid())
        self.assertEqual(
            [form.cleaned_data for form in formset.forms],
            [{"votes": 100, "choice": "Calexico"}, {}, {}],
        )

    def test_formset_validate_max_flag(self):
        """
        If validate_max is set and max_num is less than TOTAL_FORMS in the
        data, a ValidationError is raised. MAX_NUM_FORMS in the data is
        irrelevant here (it's output as a hint for the client but its value
        in the returned data is not checked).
        """
        data = {
            "choices-TOTAL_FORMS": "2",  # the number of forms rendered
            "choices-INITIAL_FORMS": "0",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "2",  # max number of forms - should be ignored
            "choices-0-choice": "Zero",
            "choices-0-votes": "0",
            "choices-1-choice": "One",
            "choices-1-votes": "1",
        }
        ChoiceFormSet = formset_factory(Choice, extra=1, max_num=1, validate_max=True)
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertFalse(formset.is_valid())
        self.assertEqual(formset.non_form_errors(), ["Please submit at most 1 form."])
        self.assertEqual(
            str(formset.non_form_errors()),
            '<ul class="errorlist nonform"><li>Please submit at most 1 form.</li></ul>',
        )

    def test_formset_validate_max_flag_custom_error(self):
        data = {
            "choices-TOTAL_FORMS": "2",
            "choices-INITIAL_FORMS": "0",
            "choices-MIN_NUM_FORMS": "0",
            "choices-MAX_NUM_FORMS": "2",
            "choices-0-choice": "Zero",
            "choices-0-votes": "0",
            "choices-1-choice": "One",
            "choices-1-votes": "1",
        }
        ChoiceFormSet = formset_factory(Choice, extra=1, max_num=1, validate_max=True)
        formset = ChoiceFormSet(
            data,
            auto_id=False,
            prefix="choices",
            error_messages={
                "too_many_forms": "Number of submitted forms should be at most %(num)d."
            },
        )
        self.assertFalse(formset.is_valid())
        self.assertEqual(
            formset.non_form_errors(),
            ["Number of submitted forms should be at most 1."],
        )
        self.assertEqual(
            str(formset.non_form_errors()),
            '<ul class="errorlist nonform">'
            "<li>Number of submitted forms should be at most 1.</li></ul>",
        )

    def test_formset_validate_min_flag(self):
        """
        If validate_min is set and min_num is more than TOTAL_FORMS in the
        data, a ValidationError is raised. MIN_NUM_FORMS in the data is
        irrelevant here (it's output as a hint for the client but its value
        in the returned data is not checked).
        """
        data = {
            "choices-TOTAL_FORMS": "2",  # the number of forms rendered
            "choices-INITIAL_FORMS": "0",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms - should be ignored
            "choices-0-choice": "Zero",
            "choices-0-votes": "0",
            "choices-1-choice": "One",
            "choices-1-votes": "1",
        }
        ChoiceFormSet = formset_factory(Choice, extra=1, min_num=3, validate_min=True)
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertFalse(formset.is_valid())
        self.assertEqual(formset.non_form_errors(), ["Please submit at least 3 forms."])
        self.assertEqual(
            str(formset.non_form_errors()),
            '<ul class="errorlist nonform"><li>'
            "Please submit at least 3 forms.</li></ul>",
        )

    def test_formset_validate_min_flag_custom_formatted_error(self):
        data = {
            "choices-TOTAL_FORMS": "2",
            "choices-INITIAL_FORMS": "0",
            "choices-MIN_NUM_FORMS": "0",
            "choices-MAX_NUM_FORMS": "0",
            "choices-0-choice": "Zero",
            "choices-0-votes": "0",
            "choices-1-choice": "One",
            "choices-1-votes": "1",
        }
        ChoiceFormSet = formset_factory(Choice, extra=1, min_num=3, validate_min=True)
        formset = ChoiceFormSet(
            data,
            auto_id=False,
            prefix="choices",
            error_messages={
                "too_few_forms": "Number of submitted forms should be at least %(num)d."
            },
        )
        self.assertFalse(formset.is_valid())
        self.assertEqual(
            formset.non_form_errors(),
            ["Number of submitted forms should be at least 3."],
        )
        self.assertEqual(
            str(formset.non_form_errors()),
            '<ul class="errorlist nonform">'
            "<li>Number of submitted forms should be at least 3.</li></ul>",
        )

    def test_formset_validate_min_unchanged_forms(self):
        """
        min_num validation doesn't consider unchanged forms with initial data
        as "empty".
        """
        initial = [
            {"choice": "Zero", "votes": 0},
            {"choice": "One", "votes": 0},
        ]
        data = {
            "choices-TOTAL_FORMS": "2",
            "choices-INITIAL_FORMS": "2",
            "choices-MIN_NUM_FORMS": "0",
            "choices-MAX_NUM_FORMS": "2",
            "choices-0-choice": "Zero",
            "choices-0-votes": "0",
            "choices-1-choice": "One",
            "choices-1-votes": "1",  # changed from initial
        }
        ChoiceFormSet = formset_factory(Choice, min_num=2, validate_min=True)
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices", initial=initial)
        self.assertFalse(formset.forms[0].has_changed())
        self.assertTrue(formset.forms[1].has_changed())
        self.assertTrue(formset.is_valid())

    def test_formset_validate_min_excludes_empty_forms(self):
        data = {
            "choices-TOTAL_FORMS": "2",
            "choices-INITIAL_FORMS": "0",
        }
        ChoiceFormSet = formset_factory(
            Choice, extra=2, min_num=1, validate_min=True, can_delete=True
        )
        formset = ChoiceFormSet(data, prefix="choices")
        self.assertFalse(formset.has_changed())
        self.assertFalse(formset.is_valid())
        self.assertEqual(formset.non_form_errors(), ["Please submit at least 1 form."])

    def test_second_form_partially_filled_2(self):
        """A partially completed form is invalid."""
        data = {
            "choices-TOTAL_FORMS": "3",  # the number of forms rendered
            "choices-INITIAL_FORMS": "0",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
            "choices-0-choice": "Calexico",
            "choices-0-votes": "100",
            "choices-1-choice": "The Decemberists",
            "choices-1-votes": "",  # missing value
            "choices-2-choice": "",
            "choices-2-votes": "",
        }
        ChoiceFormSet = formset_factory(Choice, extra=3)
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertFalse(formset.is_valid())
        self.assertEqual(
            formset.errors, [{}, {"votes": ["This field is required."]}, {}]
        )

    def test_more_initial_data(self):
        """
        The extra argument works when the formset is pre-filled with initial
        data.
        """
        initial = [{"choice": "Calexico", "votes": 100}]
        ChoiceFormSet = formset_factory(Choice, extra=3)
        formset = ChoiceFormSet(initial=initial, auto_id=False, prefix="choices")
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            '<li>Choice: <input type="text" name="choices-0-choice" value="Calexico">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-0-votes" value="100"></li>'
            '<li>Choice: <input type="text" name="choices-1-choice"></li>'
            '<li>Votes: <input type="number" name="choices-1-votes"></li>'
            '<li>Choice: <input type="text" name="choices-2-choice"></li>'
            '<li>Votes: <input type="number" name="choices-2-votes"></li>'
            '<li>Choice: <input type="text" name="choices-3-choice"></li>'
            '<li>Votes: <input type="number" name="choices-3-votes"></li>',
        )
        # Retrieving an empty form works. Tt shows up in the form list.
        self.assertTrue(formset.empty_form.empty_permitted)
        self.assertHTMLEqual(
            formset.empty_form.as_ul(),
            """<li>Choice: <input type="text" name="choices-__prefix__-choice"></li>
<li>Votes: <input type="number" name="choices-__prefix__-votes"></li>""",
        )

    def test_formset_with_deletion(self):
        """
        formset_factory's can_delete argument adds a boolean "delete" field to
        each form. When that boolean field is True, the form will be in
        formset.deleted_forms.
        """
        ChoiceFormSet = formset_factory(Choice, can_delete=True)
        initial = [
            {"choice": "Calexico", "votes": 100},
            {"choice": "Fergie", "votes": 900},
        ]
        formset = ChoiceFormSet(initial=initial, auto_id=False, prefix="choices")
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            '<li>Choice: <input type="text" name="choices-0-choice" value="Calexico">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-0-votes" value="100"></li>'
            '<li>Delete: <input type="checkbox" name="choices-0-DELETE"></li>'
            '<li>Choice: <input type="text" name="choices-1-choice" value="Fergie">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-1-votes" value="900"></li>'
            '<li>Delete: <input type="checkbox" name="choices-1-DELETE"></li>'
            '<li>Choice: <input type="text" name="choices-2-choice"></li>'
            '<li>Votes: <input type="number" name="choices-2-votes"></li>'
            '<li>Delete: <input type="checkbox" name="choices-2-DELETE"></li>',
        )
        # To delete something, set that form's special delete field to 'on'.
        # Let's go ahead and delete Fergie.
        data = {
            "choices-TOTAL_FORMS": "3",  # the number of forms rendered
            "choices-INITIAL_FORMS": "2",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
            "choices-0-choice": "Calexico",
            "choices-0-votes": "100",
            "choices-0-DELETE": "",
            "choices-1-choice": "Fergie",
            "choices-1-votes": "900",
            "choices-1-DELETE": "on",
            "choices-2-choice": "",
            "choices-2-votes": "",
            "choices-2-DELETE": "",
        }
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertTrue(formset.is_valid())
        self.assertEqual(
            [form.cleaned_data for form in formset.forms],
            [
                {"votes": 100, "DELETE": False, "choice": "Calexico"},
                {"votes": 900, "DELETE": True, "choice": "Fergie"},
                {},
            ],
        )
        self.assertEqual(
            [form.cleaned_data for form in formset.deleted_forms],
            [{"votes": 900, "DELETE": True, "choice": "Fergie"}],
        )

    def test_formset_with_deletion_remove_deletion_flag(self):
        """
        If a form is filled with something and can_delete is also checked, that
        form's errors shouldn't make the entire formset invalid since it's
        going to be deleted.
        """

        class CheckForm(Form):
            field = IntegerField(min_value=100)

        data = {
            "check-TOTAL_FORMS": "3",  # the number of forms rendered
            "check-INITIAL_FORMS": "2",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "check-MAX_NUM_FORMS": "0",  # max number of forms
            "check-0-field": "200",
            "check-0-DELETE": "",
            "check-1-field": "50",
            "check-1-DELETE": "on",
            "check-2-field": "",
            "check-2-DELETE": "",
        }
        CheckFormSet = formset_factory(CheckForm, can_delete=True)
        formset = CheckFormSet(data, prefix="check")
        self.assertTrue(formset.is_valid())
        # If the deletion flag is removed, validation is enabled.
        data["check-1-DELETE"] = ""
        formset = CheckFormSet(data, prefix="check")
        self.assertFalse(formset.is_valid())

    def test_formset_with_deletion_invalid_deleted_form(self):
        """
        deleted_forms works on a valid formset even if a deleted form would
        have been invalid.
        """
        FavoriteDrinkFormset = formset_factory(form=FavoriteDrinkForm, can_delete=True)
        formset = FavoriteDrinkFormset(
            {
                "form-0-name": "",
                "form-0-DELETE": "on",  # no name!
                "form-TOTAL_FORMS": 1,
                "form-INITIAL_FORMS": 1,
                "form-MIN_NUM_FORMS": 0,
                "form-MAX_NUM_FORMS": 1,
            }
        )
        self.assertTrue(formset.is_valid())
        self.assertEqual(formset._errors, [])
        self.assertEqual(len(formset.deleted_forms), 1)

    def test_formset_with_deletion_custom_widget(self):
        class DeletionAttributeFormSet(BaseFormSet):
            deletion_widget = HiddenInput

        class DeletionMethodFormSet(BaseFormSet):
            def get_deletion_widget(self):
                return HiddenInput(attrs={"class": "deletion"})

        tests = [
            (DeletionAttributeFormSet, '<input type="hidden" name="form-0-DELETE">'),
            (
                DeletionMethodFormSet,
                '<input class="deletion" type="hidden" name="form-0-DELETE">',
            ),
        ]
        for formset_class, delete_html in tests:
            with self.subTest(formset_class=formset_class.__name__):
                ArticleFormSet = formset_factory(
                    ArticleForm,
                    formset=formset_class,
                    can_delete=True,
                )
                formset = ArticleFormSet(auto_id=False)
                self.assertHTMLEqual(
                    "\n".join([form.as_ul() for form in formset.forms]),
                    (
                        f'<li>Title: <input type="text" name="form-0-title"></li>'
                        f'<li>Pub date: <input type="text" name="form-0-pub_date">'
                        f"{delete_html}</li>"
                    ),
                )

    def test_formsets_with_ordering(self):
        """
        formset_factory's can_order argument adds an integer field to each
        form. When form validation succeeds,
            [form.cleaned_data for form in formset.forms]
        will have the data in the correct order specified by the ordering
        fields. If a number is duplicated in the set of ordering fields, for
        instance form 0 and form 3 are both marked as 1, then the form index
        used as a secondary ordering criteria. In order to put something at the
        front of the list, you'd need to set its order to 0.
        """
        ChoiceFormSet = formset_factory(Choice, can_order=True)
        initial = [
            {"choice": "Calexico", "votes": 100},
            {"choice": "Fergie", "votes": 900},
        ]
        formset = ChoiceFormSet(initial=initial, auto_id=False, prefix="choices")
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            '<li>Choice: <input type="text" name="choices-0-choice" value="Calexico">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-0-votes" value="100"></li>'
            '<li>Order: <input type="number" name="choices-0-ORDER" value="1"></li>'
            '<li>Choice: <input type="text" name="choices-1-choice" value="Fergie">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-1-votes" value="900"></li>'
            '<li>Order: <input type="number" name="choices-1-ORDER" value="2"></li>'
            '<li>Choice: <input type="text" name="choices-2-choice"></li>'
            '<li>Votes: <input type="number" name="choices-2-votes"></li>'
            '<li>Order: <input type="number" name="choices-2-ORDER"></li>',
        )
        data = {
            "choices-TOTAL_FORMS": "3",  # the number of forms rendered
            "choices-INITIAL_FORMS": "2",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
            "choices-0-choice": "Calexico",
            "choices-0-votes": "100",
            "choices-0-ORDER": "1",
            "choices-1-choice": "Fergie",
            "choices-1-votes": "900",
            "choices-1-ORDER": "2",
            "choices-2-choice": "The Decemberists",
            "choices-2-votes": "500",
            "choices-2-ORDER": "0",
        }
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertTrue(formset.is_valid())
        self.assertEqual(
            [form.cleaned_data for form in formset.ordered_forms],
            [
                {"votes": 500, "ORDER": 0, "choice": "The Decemberists"},
                {"votes": 100, "ORDER": 1, "choice": "Calexico"},
                {"votes": 900, "ORDER": 2, "choice": "Fergie"},
            ],
        )

    def test_formsets_with_ordering_custom_widget(self):
        class OrderingAttributeFormSet(BaseFormSet):
            ordering_widget = HiddenInput

        class OrderingMethodFormSet(BaseFormSet):
            def get_ordering_widget(self):
                return HiddenInput(attrs={"class": "ordering"})

        tests = (
            (OrderingAttributeFormSet, '<input type="hidden" name="form-0-ORDER">'),
            (
                OrderingMethodFormSet,
                '<input class="ordering" type="hidden" name="form-0-ORDER">',
            ),
        )
        for formset_class, order_html in tests:
            with self.subTest(formset_class=formset_class.__name__):
                ArticleFormSet = formset_factory(
                    ArticleForm, formset=formset_class, can_order=True
                )
                formset = ArticleFormSet(auto_id=False)
                self.assertHTMLEqual(
                    "\n".join(form.as_ul() for form in formset.forms),
                    (
                        '<li>Title: <input type="text" name="form-0-title"></li>'
                        '<li>Pub date: <input type="text" name="form-0-pub_date">'
                        "%s</li>" % order_html
                    ),
                )

    def test_empty_ordered_fields(self):
        """
        Ordering fields are allowed to be left blank. If they are left blank,
        they'll be sorted below everything else.
        """
        data = {
            "choices-TOTAL_FORMS": "4",  # the number of forms rendered
            "choices-INITIAL_FORMS": "3",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
            "choices-0-choice": "Calexico",
            "choices-0-votes": "100",
            "choices-0-ORDER": "1",
            "choices-1-choice": "Fergie",
            "choices-1-votes": "900",
            "choices-1-ORDER": "2",
            "choices-2-choice": "The Decemberists",
            "choices-2-votes": "500",
            "choices-2-ORDER": "",
            "choices-3-choice": "Basia Bulat",
            "choices-3-votes": "50",
            "choices-3-ORDER": "",
        }
        ChoiceFormSet = formset_factory(Choice, can_order=True)
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertTrue(formset.is_valid())
        self.assertEqual(
            [form.cleaned_data for form in formset.ordered_forms],
            [
                {"votes": 100, "ORDER": 1, "choice": "Calexico"},
                {"votes": 900, "ORDER": 2, "choice": "Fergie"},
                {"votes": 500, "ORDER": None, "choice": "The Decemberists"},
                {"votes": 50, "ORDER": None, "choice": "Basia Bulat"},
            ],
        )

    def test_ordering_blank_fieldsets(self):
        """Ordering works with blank fieldsets."""
        data = {
            "choices-TOTAL_FORMS": "3",  # the number of forms rendered
            "choices-INITIAL_FORMS": "0",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
        }
        ChoiceFormSet = formset_factory(Choice, can_order=True)
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertTrue(formset.is_valid())
        self.assertEqual(formset.ordered_forms, [])

    def test_formset_with_ordering_and_deletion(self):
        """FormSets with ordering + deletion."""
        ChoiceFormSet = formset_factory(Choice, can_order=True, can_delete=True)
        initial = [
            {"choice": "Calexico", "votes": 100},
            {"choice": "Fergie", "votes": 900},
            {"choice": "The Decemberists", "votes": 500},
        ]
        formset = ChoiceFormSet(initial=initial, auto_id=False, prefix="choices")
        self.assertHTMLEqual(
            "\n".join(form.as_ul() for form in formset.forms),
            '<li>Choice: <input type="text" name="choices-0-choice" value="Calexico">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-0-votes" value="100"></li>'
            '<li>Order: <input type="number" name="choices-0-ORDER" value="1"></li>'
            '<li>Delete: <input type="checkbox" name="choices-0-DELETE"></li>'
            '<li>Choice: <input type="text" name="choices-1-choice" value="Fergie">'
            "</li>"
            '<li>Votes: <input type="number" name="choices-1-votes" value="900"></li>'
            '<li>Order: <input type="number" name="choices-1-ORDER" value="2"></li>'
            '<li>Delete: <input type="checkbox" name="choices-1-DELETE"></li>'
            '<li>Choice: <input type="text" name="choices-2-choice" '
            'value="The Decemberists"></li>'
            '<li>Votes: <input type="number" name="choices-2-votes" value="500"></li>'
            '<li>Order: <input type="number" name="choices-2-ORDER" value="3"></li>'
            '<li>Delete: <input type="checkbox" name="choices-2-DELETE"></li>'
            '<li>Choice: <input type="text" name="choices-3-choice"></li>'
            '<li>Votes: <input type="number" name="choices-3-votes"></li>'
            '<li>Order: <input type="number" name="choices-3-ORDER"></li>'
            '<li>Delete: <input type="checkbox" name="choices-3-DELETE"></li>',
        )
        # Let's delete Fergie, and put The Decemberists ahead of Calexico.
        data = {
            "choices-TOTAL_FORMS": "4",  # the number of forms rendered
            "choices-INITIAL_FORMS": "3",  # the number of forms with initial data
            "choices-MIN_NUM_FORMS": "0",  # min number of forms
            "choices-MAX_NUM_FORMS": "0",  # max number of forms
            "choices-0-choice": "Calexico",
            "choices-0-votes": "100",
            "choices-0-ORDER": "1",
            "choices-0-DELETE": "",
            "choices-1-choice": "Fergie",
            "choices-1-votes": "900",
            "choices-1-ORDER": "2",
            "choices-1-DELETE": "on",
            "choices-2-choice": "The Decemberists",
            "choices-2-votes": "500",
            "choices-2-ORDER": "0",
            "choices-2-DELETE": "",
            "choices-3-choice": "",
            "choices-3-votes": "",
            "choices-3-ORDER": "",
            "choices-3-DELETE": "",
        }
        formset = ChoiceFormSet(data, auto_id=False, prefix="choices")
        self.assertTrue(formset.is_valid())
        self.assertEqual(
            [form.cleaned_data for form in formset.ordered_forms],
            [
                {
                    "votes": 500,
                    "DELETE": False,
                    "ORDER": 0,
                    "choice": "The Decemberists",
                },
                {"votes": 100, "DELETE": False, "ORDER": 1, "choice": "Calexico"},
            ],
        )
        self.assertEqual(
            [form.cleaned_data for form in formset.deleted_forms],
            [{"votes": 900, "DELETE": True, "ORDER": 2, "choice": "Fergie"}],
        )

    def test_invalid_deleted_form_with_ordering(self):
        """
        Can get ordered_forms from a valid formset even if a deleted form
        would have been invalid.
        """
        FavoriteDrinkFormset = formset_factory(
            form=FavoriteDrinkForm, can_delete=True, can_order=True
        
```


# The last commit

```
518ea60e10 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py forms_tests.tests.test_formsets
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 159 test(s).
System check identified no issues (0 silenced).
...............................................................................................................................................................
----------------------------------------------------------------------
Ran 159 tests in 0.466s

OK
scope: django/forms/formsets.py tests/forms_tests/tests/test_formsets.py
changed: django/forms/formsets.py +3 -1
changed: tests/forms_tests/tests/test_formsets.py +9 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/forms/formsets.py b/django/forms/formsets.py
index 235aaf844c..fd4d53a44f 100644
--- a/django/forms/formsets.py
+++ b/django/forms/formsets.py
@@ -490,7 +490,9 @@ class BaseFormSet(RenderableFormMixin):
                     required=False,
                     widget=self.get_ordering_widget(),
                 )
-        if self.can_delete and (self.can_delete_extra or index < initial_form_count):
+        if self.can_delete and (
+            self.can_delete_extra or (index is not None and index < initial_form_count)
+        ):
             form.fields[DELETION_FIELD_NAME] = BooleanField(
                 label=_("Delete"),
                 required=False,
diff --git a/tests/forms_tests/tests/test_formsets.py b/tests/forms_tests/tests/test_formsets.py
index e2c695f0dc..6c406382bc 100644
--- a/tests/forms_tests/tests/test_formsets.py
+++ b/tests/forms_tests/tests/test_formsets.py
@@ -1507,6 +1507,15 @@ class FormsFormsetTestCase(SimpleTestCase):
         self.assertIs(formset._should_delete_form(formset.forms[1]), False)
         self.assertIs(formset._should_delete_form(formset.forms[2]), False)
 
+    def test_disable_delete_extra_formset_empty_form(self):
+        ChoiceFormFormset = formset_factory(
+            form=Choice,
+            can_delete=True,
+            can_delete_extra=False,
+        )
+        formset = ChoiceFormFormset(initial=None)
+        self.assertNotIn("DELETE", formset.empty_form.fields)
+
     def test_template_name_uses_renderer_value(self):
         class CustomRenderer(TemplatesSetting):
             formset_template_name = "a/custom/formset/template.html"
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
check: python tests/runtests.py forms_tests.tests.test_formsets
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 159 test(s).
System check identified no issues (0 silenced).
...............................................................................................................................................................
----------------------------------------------------------------------
Ran 159 tests in 0.525s

OK
scope: django/forms/formsets.py tests/forms_tests/tests/test_formsets.py
changed: django/forms/formsets.py +3 -1
changed: tests/forms_tests/tests/test_formsets.py +9 -0
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
# Notes, run 2026-11-06T112714

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Formsets' add_fields() method fails in some circumstances if the argument index is None.
Description
	
Formsets' add_fields() method fails in some circumstances if the argument index is None.
When a FormSet has the attributes self.can_delete == True and self.can_delete_extra == False, calling the add_fields() method on that FormSet fails if the argument index is None. This occurs for example when calling FormSet.empty_form(). The result is that the method raises the exception TypeError: '<' not supported between instances of 'NoneType' and 'int'. 
Code example:
MyFormSet = forms.formset_factory(
	form=MyForm,
	can_delete=True,
	can_delete_extra=False,
)
my_formset = MyFormSet(
	initial=None,
)
print(my_formset.empty_form)
The reason this happens is that in in line 493 of [django.forms.formsets](​https://github.com/django/django/blob/main/django/forms/formsets.py) index is compared to initial_form_count:
if self.can_delete and (self.can_delete_extra or index < initial_form_count):
Checking for index not None should fix the issue:
if self.can_delete and (self.can_delete_extra or (index is not None and index < initial_form_count)):
How to Reproduce
A self-contained example to reproduce this bug is as follows:
#!/usr/bin/env python3
import os
import django
from django import forms
class MyForm(forms.Form):
	my_field = forms.CharField()
if __name__ == "__main__":
	settings_file = os.path.splitext(os.path.basename(__file__))[0]
	django.conf.settings.configure(
		DEBUG=True,
		MIDDLEWARE_CLASSES=[],
		ROOT_URLCONF=settings_file,
	)
	django.setup()
	MyFormSet = forms.formset_factory(
		form=MyForm,
		can_delete=True,
		can_delete_extra=False,
	)
	my_formset = MyFormSet(
		initial=None,
	)
	print(my_formset.empty_form)


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.git-blame-ignore-revs
.gitattributes
.github/CODE_OF_CONDUCT.md
.github/FUNDING.yml
.github/SECURITY.md
.github/workflows/benchmark.yml
.github/workflows/docs.yml
.github/workflows/linters.yml
.github/workflows/new_contributor_pr.yml
.github/workflows/schedule_tests.yml
.github/workflows/schedules.yml
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
django/conf/locale/ckb/__init__.py
django/conf/locale/ckb/formats.py
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
```


# The last commit

```
518ea60e10 SWE-bench


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
    "npm": ">=1.3.0"
  },
  "devDependencies": {
    "eslint": "^8.34.0",
    "puppeteer": "^19.7.0",
    "grunt": "^1.6.1",
    "grunt-cli": "^1.4.3",
    "grunt-contrib-qunit": "^7.0.0",
    "qunit": "^2.19.4"
  }
}

```


# pyproject.toml (the start)

```
[build-system]
requires = ['setuptools>=40.8.0']
build-backend = 'setuptools.build_meta'

[tool.black]
target-version = ['py38']
force-exclude = 'tests/test_runner_apps/tagged/tests_syntax_error.py'

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python tests/runtests.py forms_tests.tests.test_formsets`

## Scope
`django/forms/formsets.py`
`tests/forms_tests/tests/test_formsets.py`

## Done when
- `BaseFormSet.add_fields()` no longer raises `TypeError: '<' not supported between instances of 'NoneType' and 'int'` when `index` is `None`, `can_delete` is `True`, and `can_delete_extra` is `False`.
- Accessing `empty_form` on a formset built with `can_delete=True, can_delete_extra=False` succeeds and includes the delete field.
- The `can_delete`/`can_delete_extra` behavior for non-`None` indexes is unchanged.
- (inferred) A regression test covering `empty_form` with `can_delete=True, can_delete_extra=False` passes in `tests/forms_tests/tests/test_formsets.py`.

## Approach
The fix is a one-line guard in `django/forms/formsets.py`: change the condition to `if self.can_delete and (self.can_delete_extra or (index is not None and index < initial_form_count))`, so the delete field is added for the empty form (index `None`) only when `can_delete_extra` is true, and the comparison is skipped otherwise.

Candidate approaches:
1. Guard the comparison with `index is not None` (the prompt's suggestion) — minimal, preserves existing semantics for real indexes, and treats `None` as "not an initial form".
2. Reorder to `if self.can_delete and (self.can_delete_extra or (index or 0) < initial_form_count)` — avoids the `TypeError` but silently treats `None` as index 0, which is wrong for `can_delete_extra=False` since the empty form would then get a delete field when `initial_form_count > 0`.
3. Special-case `index is None` earlier in `add_fields()` — more code for the same result; approach 1 is preferred.

Add a regression test in `tests/forms_tests/tests/test_formsets.py` asserting `empty_form` renders/contains the delete field without raising, then run the scoped test command.
```

### `prompt.md`

```
Formsets' add_fields() method fails in some circumstances if the argument index is None.
Description
	
Formsets' add_fields() method fails in some circumstances if the argument index is None.
When a FormSet has the attributes self.can_delete == True and self.can_delete_extra == False, calling the add_fields() method on that FormSet fails if the argument index is None. This occurs for example when calling FormSet.empty_form(). The result is that the method raises the exception TypeError: '<' not supported between instances of 'NoneType' and 'int'. 
Code example:
MyFormSet = forms.formset_factory(
	form=MyForm,
	can_delete=True,
	can_delete_extra=False,
)
my_formset = MyFormSet(
	initial=None,
)
print(my_formset.empty_form)
The reason this happens is that in in line 493 of [django.forms.formsets](​https://github.com/django/django/blob/main/django/forms/formsets.py) index is compared to initial_form_count:
if self.can_delete and (self.can_delete_extra or index < initial_form_count):
Checking for index not None should fix the issue:
if self.can_delete and (self.can_delete_extra or (index is not None and index < initial_form_count)):
How to Reproduce
A self-contained example to reproduce this bug is as follows:
#!/usr/bin/env python3
import os
import django
from django import forms
class MyForm(forms.Form):
	my_field = forms.CharField()
if __name__ == "__main__":
	settings_file = os.path.splitext(os.path.basename(__file__))[0]
	django.conf.settings.configure(
		DEBUG=True,
		MIDDLEWARE_CLASSES=[],
		ROOT_URLCONF=settings_file,
	)
	django.setup()
	MyFormSet = forms.formset_factory(
		form=MyForm,
		can_delete=True,
		can_delete_extra=False,
	)
	my_formset = MyFormSet(
		initial=None,
	)
	print(my_formset.empty_form)
```

### `review.md`

```
verdict: PASS

- The fix in `django/forms/formsets.py` matches the Prompt's proposed change exactly: `self.can_delete_extra or (index is not None and index < initial_form_count)`, so `add_fields()` no longer compares `None < int` and `empty_form` no longer raises `TypeError`.
- Behavior for non-`None` indexes is untouched: the added `index is not None` guard only short-circuits the `None` case, leaving `can_delete`/`can_delete_extra` semantics for real form indexes identical.
- The regression test `test_disable_delete_extra_formset_empty_form` exercises exactly the reported scenario (`can_delete=True, can_delete_extra=False`, `initial=None`, access `empty_form`) and would have errored before the fix; the full `forms_tests.tests.test_formsets` suite passes (159 tests, OK, check status 0).
- Note (not a failure): the Done-when line "includes the delete field" is inconsistent with the intended semantics and with the Prompt's own suggested fix. `empty_form` is the template for *extra* forms, and `can_delete_extra=False` means extra forms get no delete checkbox, so asserting `"DELETE" not in formset.empty_form.fields` is the correct expectation. The Prompt only asks that the `TypeError` be eliminated, which the change does; the test's assertion is the right one, not a defect.
- No files outside the stated Scope were modified, and no content was removed.
```

### `scope.txt`

```
scope: django/forms/formsets.py tests/forms_tests/tests/test_formsets.py
changed: django/forms/formsets.py +3 -1
changed: tests/forms_tests/tests/test_formsets.py +9 -0
```

### `task.md`

```
# Task

## Prompt

Formsets' add_fields() method fails in some circumstances if the argument index is None.
Description
	
Formsets' add_fields() method fails in some circumstances if the argument index is None.
When a FormSet has the attributes self.can_delete == True and self.can_delete_extra == False, calling the add_fields() method on that FormSet fails if the argument index is None. This occurs for example when calling FormSet.empty_form(). The result is that the method raises the exception TypeError: '<' not supported between instances of 'NoneType' and 'int'. 
Code example:
MyFormSet = forms.formset_factory(
	form=MyForm,
	can_delete=True,
	can_delete_extra=False,
)
my_formset = MyFormSet(
	initial=None,
)
print(my_formset.empty_form)
The reason this happens is that in in line 493 of [django.forms.formsets](​https://github.com/django/django/blob/main/django/forms/formsets.py) index is compared to initial_form_count:
if self.can_delete and (self.can_delete_extra or index < initial_form_count):
Checking for index not None should fix the issue:
if self.can_delete and (self.can_delete_extra or (index is not None and index < initial_form_count)):
How to Reproduce
A self-contained example to reproduce this bug is as follows:
#!/usr/bin/env python3
import os
import django
from django import forms
class MyForm(forms.Form):
	my_field = forms.CharField()
if __name__ == "__main__":
	settings_file = os.path.splitext(os.path.basename(__file__))[0]
	django.conf.settings.configure(
		DEBUG=True,
		MIDDLEWARE_CLASSES=[],
		ROOT_URLCONF=settings_file,
	)
	django.setup()
	MyFormSet = forms.formset_factory(
		form=MyForm,
		can_delete=True,
		can_delete_extra=False,
	)
	my_formset = MyFormSet(
		initial=None,
	)
	print(my_formset.empty_form)

## Deliverable

changes to this tree

## Check

`python tests/runtests.py forms_tests.tests.test_formsets`

## Scope

`django/forms/formsets.py`
`tests/forms_tests/tests/test_formsets.py`

## Done when

- `BaseFormSet.add_fields()` no longer raises `TypeError: '<' not supported between instances of 'NoneType' and 'int'` when `index` is `None`, `can_delete` is `True`, and `can_delete_extra` is `False`.
- Accessing `empty_form` on a formset built with `can_delete=True, can_delete_extra=False` succeeds and includes the delete field.
- The `can_delete`/`can_delete_extra` behavior for non-`None` indexes is unchanged.
- (inferred) A regression test covering `empty_form` with `can_delete=True, can_delete_extra=False` passes in `tests/forms_tests/tests/test_formsets.py`.
```

### `test-output.log`

```
check: python tests/runtests.py forms_tests.tests.test_formsets
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 159 test(s).
System check identified no issues (0 silenced).
...............................................................................................................................................................
----------------------------------------------------------------------
Ran 159 tests in 0.458s

OK
scope: django/forms/formsets.py tests/forms_tests/tests/test_formsets.py
changed: django/forms/formsets.py +3 -1
changed: tests/forms_tests/tests/test_formsets.py +9 -0
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
