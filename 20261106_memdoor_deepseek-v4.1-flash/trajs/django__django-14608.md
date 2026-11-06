# django__django-14608 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 65s 72 lines cost=0.003041 in=213340 cached=165376 out=3310 calls=22`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Add `nonform` CSS class for non form errors in FormSets
Description
	 
		(last modified by Ties Jan Hefting)
	 
Forms add the nonfield CSS class for non field errors in ErrorList instances. This is documented in a section on ​rendering form error messages. Similarly, in FormSets I'd expect to see the nonform CSS class added for non form errors. This would allow a custom ErrorList to make a distinction in form field errors, non field errors (forms) and non form errors (FormSets) when rendering error messages. Therefore I'd suggest to add this nonform CSS class and document it for developers to use.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain | head -50"
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
?? .memdoor/
```

**assistant → tool `grep`**

```json
{
  "pattern": "nonfield",
  "path": "django/forms",
  "output_mode": "content",
  "head_limit": 80
}
```

**assistant → tool `grep`**

```json
{
  "pattern": "nonform",
  "path": "django",
  "output_mode": "content",
  "head_limit": 50
}
```

**tool result**

```
/testbed/django/forms/forms.py:        return self.errors.get(NON_FIELD_ERRORS, self.error_class(error_class='nonfield'))
/testbed/django/forms/forms.py:                    self._errors[field] = self.error_class(error_class='nonfield')
```

**tool result**

```

```

**assistant → tool `grep`**

```json
{
  "pattern": "error_class|non_form_errors|NON_FIELD_ERRORS",
  "path": "django/forms/formsets.py",
  "output_mode": "content",
  "head_limit": 60
}
```

**tool result**

```
/testbed/django/forms/formsets.py:                 initial=None, error_class=ErrorList, form_kwargs=None,
/testbed/django/forms/formsets.py:        self.error_class = error_class
/testbed/django/forms/formsets.py:        self._non_form_errors = None
/testbed/django/forms/formsets.py:            'error_class': self.error_class,
/testbed/django/forms/formsets.py:    def non_form_errors(self):
/testbed/django/forms/formsets.py:        if self._non_form_errors is None:
/testbed/django/forms/formsets.py:        return self._non_form_errors
/testbed/django/forms/formsets.py:        return len(self.non_form_errors()) +\
/testbed/django/forms/formsets.py:        return forms_valid and not self.non_form_errors()
/testbed/django/forms/formsets.py:        self._non_form_errors.
/testbed/django/forms/formsets.py:        self._non_form_errors = self.error_class()
/testbed/django/forms/formsets.py:            self._non_form_errors.append(error)
/testbed/django/forms/formsets.py:            self._non_form_errors = self.error_class(e.error_list)
/testbed/django/forms/formsets.py:        via formset.non_form_errors()
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"_non_form_errors = self.error_class\\|non_form_errors\" django/forms/formsets.py | head; sed -n '1,30p' django/forms/formsets.py; grep -rn \"nonfield\" docs | head -20"
}
```

**tool result**

```
78:        self._non_form_errors = None
290:    def non_form_errors(self):
296:        if self._non_form_errors is None:
298:        return self._non_form_errors
309:        return len(self.non_form_errors()) +\
328:        return forms_valid and not self.non_form_errors()
333:        self._non_form_errors.
336:        self._non_form_errors = self.error_class()
353:            self._non_form_errors.append(error)
383:            self._non_form_errors = self.error_class(e.error_list)
from django.core.exceptions import ValidationError
from django.forms import Form
from django.forms.fields import BooleanField, IntegerField
from django.forms.utils import ErrorList
from django.forms.widgets import HiddenInput, NumberInput
from django.utils.functional import cached_property
from django.utils.html import html_safe
from django.utils.safestring import mark_safe
from django.utils.translation import gettext_lazy as _, ngettext

__all__ = ('BaseFormSet', 'formset_factory', 'all_valid')

# special field names
TOTAL_FORM_COUNT = 'TOTAL_FORMS'
INITIAL_FORM_COUNT = 'INITIAL_FORMS'
MIN_NUM_FORM_COUNT = 'MIN_NUM_FORMS'
MAX_NUM_FORM_COUNT = 'MAX_NUM_FORMS'
ORDERING_FIELD_NAME = 'ORDER'
DELETION_FIELD_NAME = 'DELETE'

# default minimum number of forms in a formset
DEFAULT_MIN_NUM = 0

# default maximum number of forms in a formset, to prevent memory exhaustion
DEFAULT_MAX_NUM = 1000


class ManagementForm(Form):
    """
    Keep track of how many form instances are displayed on the page. If adding
docs/topics/forms/index.txt:610:additional class of ``nonfield`` to help distinguish them from field-specific
docs/topics/forms/index.txt:615:    <ul class="errorlist nonfield">
docs/releases/1.8.txt:340:  ``nonfield`` in its list of classes to distinguish them from field-specific
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '325,390p' django/forms/formsets.py; sed -n '600,625p' docs/topics/forms/index.txt"
}
```

**tool result**

```
            form.is_valid() for form in self.forms
            if not (self.can_delete and self._should_delete_form(form))
        ])
        return forms_valid and not self.non_form_errors()

    def full_clean(self):
        """
        Clean all of self.data and populate self._errors and
        self._non_form_errors.
        """
        self._errors = []
        self._non_form_errors = self.error_class()
        empty_forms_count = 0

        if not self.is_bound:  # Stop further processing.
            return

        if not self.management_form.is_valid():
            error = ValidationError(
                self.error_messages['missing_management_form'],
                params={
                    'field_names': ', '.join(
                        self.management_form.add_prefix(field_name)
                        for field_name in self.management_form.errors
                    ),
                },
                code='missing_management_form',
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
            if (self.validate_max and
                    self.total_form_count() - len(self.deleted_forms) > self.max_num) or \
                    self.management_form.cleaned_data[TOTAL_FORM_COUNT] > self.absolute_max:
                raise ValidationError(ngettext(
                    "Please submit at most %d form.",
                    "Please submit at most %d forms.", self.max_num) % self.max_num,
                    code='too_many_forms',
                )
            if (self.validate_min and
                    self.total_form_count() - len(self.deleted_forms) - empty_forms_count < self.min_num):
                raise ValidationError(ngettext(
                    "Please submit at least %d form.",
                    "Please submit at least %d forms.", self.min_num) % self.min_num,
                    code='too_few_forms')
            # Give self.clean() a chance to do cross-form validation.
            self.clean()
        except ValidationError as e:
            self._non_form_errors = self.error_class(e.error_list)

    def clean(self):
        """
        Hook for doing any extra formset-wide cleaning after Form.clean() has
        been called on every form. Any ValidationError raised by this method
        will not be associated with a particular form; it will be accessible
        via formset.non_form_errors()
    {% if form.subject.errors %}
        <ol>
        {% for error in form.subject.errors %}
            <li><strong>{{ error|escape }}</strong></li>
        {% endfor %}
        </ol>
    {% endif %}

Non-field errors (and/or hidden field errors that are rendered at the top of
the form when using helpers like ``form.as_p()``) will be rendered with an
additional class of ``nonfield`` to help distinguish them from field-specific
errors. For example, ``{{ form.non_field_errors }}`` would look like:

.. code-block:: html+django

    <ul class="errorlist nonfield">
        <li>Generic validation error</li>
    </ul>

See :doc:`/ref/forms/api` for more on errors, styling, and working with form
attributes in templates.

Looping over the form's fields
------------------------------

If you're using the same HTML for each of your form fields, you can reduce
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/forms/formsets.py\n@@\n-        self._non_form_errors = self.error_class()\n+        self._non_form_errors = self.error_class(error_class='nonform')\n@@\n-            self._non_form_errors = self.error_class(e.error_list)\n+            self._non_form_errors = self.error_class(e.error_list, error_class='nonform')\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/forms/formsets.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/forms/formsets.py now (496 lines), around the change:
333:        self._non_form_errors.
334:        """
335:        self._errors = []
336:        self._non_form_errors = self.error_class(error_class='nonform')
337:        empty_forms_count = 0
338:
339:        if not self.is_bound:  # Stop further processing.
…
380:            # Give self.clean() a chance to do cross-form validation.
381:            self.clean()
382:        except ValidationError as e:
383:            self._non_form_errors = self.error_class(e.error_list, error_class='nonform')
384:
385:    def clean(self):
386:        """
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"non_form_errors\\|non-form errors\\|non form errors\" docs/topics/forms/formsets.txt docs/ref/forms/api.txt | head -30"
}
```

**tool result**

```
docs/topics/forms/formsets.txt:152:    >>> formset.non_form_errors()
docs/topics/forms/formsets.txt:310:    >>> formset.non_form_errors()
docs/topics/forms/formsets.txt:318:    >>> formset.non_form_errors()
docs/topics/forms/formsets.txt:361:    >>> formset.non_form_errors()
docs/topics/forms/formsets.txt:365:have been called. The errors will be found using the ``non_form_errors()``
docs/topics/forms/formsets.txt:401:    >>> formset.non_form_errors()
docs/topics/forms/formsets.txt:441:    >>> formset.non_form_errors()
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"non_form_errors\\|Non-form\\|non-form\\|errors\" docs/topics/forms/formsets.txt | sed -n '1,60p'"
}
```

**tool result**

```
152:    >>> formset.non_form_errors()
193:    >>> formset.errors
196:As we can see, ``formset.errors`` is a list whose entries correspond to the
207:To check how many errors there are in the formset, we can use the
211:    >>> formset.errors
213:    >>> len(formset.errors)
310:    >>> formset.non_form_errors()
318:    >>> formset.non_form_errors()
335:    ...         if any(self.errors):
359:    >>> formset.errors
361:    >>> formset.non_form_errors()
365:have been called. The errors will be found using the ``non_form_errors()``
399:    >>> formset.errors
401:    >>> formset.non_form_errors()
439:    >>> formset.errors
441:    >>> formset.non_form_errors()
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '350,375p' docs/topics/forms/formsets.txt"
}
```

**tool result**

```
    ...     'form-INITIAL_FORMS': '0',
    ...     'form-0-title': 'Test',
    ...     'form-0-pub_date': '1904-06-16',
    ...     'form-1-title': 'Test',
    ...     'form-1-pub_date': '1912-06-23',
    ... }
    >>> formset = ArticleFormSet(data)
    >>> formset.is_valid()
    False
    >>> formset.errors
    [{}, {}]
    >>> formset.non_form_errors()
    ['Articles in a set must have distinct titles.']

The formset ``clean`` method is called after all the ``Form.clean`` methods
have been called. The errors will be found using the ``non_form_errors()``
method on the formset.

Validating the number of forms in a formset
===========================================

Django provides a couple ways to validate the minimum or maximum number of
submitted forms. Applications which need more customizable validation of the
number of forms should use custom formset validation.

.. _validate_max:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"nonfield\\|nonform\" tests/forms_tests | head -40"
}
```

**tool result**

```
tests/forms_tests/tests/test_forms.py:1129:<ul class="errorlist nonfield"><li>Please make sure your passwords match.</li></ul></td></tr>
tests/forms_tests/tests/test_forms.py:1136:            """<li><ul class="errorlist nonfield">
tests/forms_tests/tests/test_forms.py:1491:<ul class="errorlist nonfield"><li>(Hidden field hidden_text) This field is required.</li></ul></td></tr>
tests/forms_tests/tests/test_forms.py:1499:            """<li><ul class="errorlist nonfield"><li>(Hidden field hidden_text) This field is required.</li></ul></li>
tests/forms_tests/tests/test_forms.py:1507:            """<ul class="errorlist nonfield"><li>(Hidden field hidden_text) This field is required.</li></ul>
tests/forms_tests/tests/test_forms.py:2567:<tr><td colspan="2"><ul class="errorlist nonfield"><li>Please make sure your passwords match.</li></ul></td></tr>
tests/forms_tests/tests/test_forms.py:2724:<ul class="errorlist nonfield"><li>Please make sure your passwords match.</li></ul>
tests/forms_tests/tests/test_forms.py:3308:            '<li>__all__<ul class="errorlist nonfield"><li>Non-field error.</li></ul></li>',
tests/forms_tests/tests/test_forms.py:3408:            """<li><ul class="errorlist nonfield">
tests/forms_tests/tests/test_forms.py:3416:            """<ul class="errorlist nonfield"><li>(Hidden field last_name) This field is required.</li></ul>
tests/forms_tests/tests/test_forms.py:3423:            """<tr><td colspan="2"><ul class="errorlist nonfield">
tests/forms_tests/tests/test_forms.py:3441:            '<ul class="errorlist nonfield"><li>Generic validation error</li></ul>'
tests/forms_tests/tests/test_forms.py:3446:<ul class="errorlist nonfield"><li>Generic validation error</li></ul></li>
tests/forms_tests/tests/test_forms.py:3458:            """<ul class="errorlist nonfield"><li>Generic validation error</li></ul>
tests/forms_tests/tests/test_forms.py:3466:            """<tr><td colspan="2"><ul class="errorlist nonfield"><li>Generic validation error</li></ul></td></tr>
tests/forms_tests/tests/test_forms.py:3511:            '<li><ul class="errorlist nonfield"><li>(Hidden field hidden) Foo &amp; &quot;bar&quot;!</li></ul></li>'
tests/forms_tests/tests/test_forms.py:3717:            '<ul class="errorlist nonfield">'
tests/forms_tests/tests/test_forms.py:3723:            '<tr><td colspan="2"><ul class="errorlist nonfield">'
tests/forms_tests/tests/test_formsets.py:1319:            '<ul class="errorlist nonfield">'
tests/forms_tests/tests/test_formsets.py:1350:            '<ul class="errorlist nonfield">'
tests/forms_tests/tests/test_error_messages.py:236:            '<ul class="errorlist nonfield"><li>I like to be awkward.</li></ul>'
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1300,1365p' tests/forms_tests/tests/test_formsets.py; grep -rn \"errorlist nonfield\" tests/forms_tests/tests/test_formsets.py"
}
```

**tool result**

```


class TestIsBoundBehavior(SimpleTestCase):
    def test_no_data_error(self):
        formset = ArticleFormSet({})
        self.assertIs(formset.is_valid(), False)
        self.assertEqual(
            formset.non_form_errors(),
            [
                'ManagementForm data is missing or has been tampered with. '
                'Missing fields: form-TOTAL_FORMS, form-INITIAL_FORMS. '
                'You may need to file a bug report if the issue persists.',
            ],
        )
        self.assertEqual(formset.errors, [])
        # Can still render the formset.
        self.assertEqual(
            str(formset),
            '<tr><td colspan="2">'
            '<ul class="errorlist nonfield">'
            '<li>(Hidden field TOTAL_FORMS) This field is required.</li>'
            '<li>(Hidden field INITIAL_FORMS) This field is required.</li>'
            '</ul>'
            '<input type="hidden" name="form-TOTAL_FORMS" id="id_form-TOTAL_FORMS">'
            '<input type="hidden" name="form-INITIAL_FORMS" id="id_form-INITIAL_FORMS">'
            '<input type="hidden" name="form-MIN_NUM_FORMS" id="id_form-MIN_NUM_FORMS">'
            '<input type="hidden" name="form-MAX_NUM_FORMS" id="id_form-MAX_NUM_FORMS">'
            '</td></tr>\n'
        )

    def test_management_form_invalid_data(self):
        data = {
            'form-TOTAL_FORMS': 'two',
            'form-INITIAL_FORMS': 'one',
        }
        formset = ArticleFormSet(data)
        self.assertIs(formset.is_valid(), False)
        self.assertEqual(
            formset.non_form_errors(),
            [
                'ManagementForm data is missing or has been tampered with. '
                'Missing fields: form-TOTAL_FORMS, form-INITIAL_FORMS. '
                'You may need to file a bug report if the issue persists.',
            ],
        )
        self.assertEqual(formset.errors, [])
        # Can still render the formset.
        self.assertEqual(
            str(formset),
            '<tr><td colspan="2">'
            '<ul class="errorlist nonfield">'
            '<li>(Hidden field TOTAL_FORMS) Enter a whole number.</li>'
            '<li>(Hidden field INITIAL_FORMS) Enter a whole number.</li>'
            '</ul>'
            '<input type="hidden" name="form-TOTAL_FORMS" value="two" id="id_form-TOTAL_FORMS">'
            '<input type="hidden" name="form-INITIAL_FORMS" value="one" id="id_form-INITIAL_FORMS">'
            '<input type="hidden" name="form-MIN_NUM_FORMS" id="id_form-MIN_NUM_FORMS">'
            '<input type="hidden" name="form-MAX_NUM_FORMS" id="id_form-MAX_NUM_FORMS">'
            '</td></tr>\n',
        )

    def test_customize_management_form_error(self):
        formset = ArticleFormSet({}, error_messages={'missing_management_form': 'customized'})
        self.assertIs(formset.is_valid(), False)
        self.assertEqual(formset.non_form_errors(), ['customized'])
        self.assertEqual(formset.errors, [])
1319:            '<ul class="errorlist nonfield">'
1350:            '<ul class="errorlist nonfield">'
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"non_form_errors()\" tests/forms_tests/tests/test_formsets.py | head; grep -rn \"errorlist\\\"\\|errorlist \" tests/forms_tests/tests/test_formsets.py | head -30"
}
```

**tool result**

```
339:        self.assertEqual(formset.non_form_errors(), ['Please submit at most 1 form.'])
361:        self.assertEqual(formset.non_form_errors(), ['Please submit at least 3 forms.'])
397:        self.assertEqual(formset.non_form_errors(), ['Please submit at least 1 form.'])
769:        # formset.non_form_errors() method.
770:        for error in formset.non_form_errors():
776:        self.assertEqual(formset.non_form_errors(), [])
890:            formset.non_form_errors(),
914:            formset.non_form_errors(),
933:            formset.non_form_errors(),
985:        self.assertEqual(formset.non_form_errors(), ['You may only specify a drink once.'])
1319:            '<ul class="errorlist nonfield">'
1350:            '<ul class="errorlist nonfield">'
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"error_class\\|nonform\\|non_form\" tests/forms_tests/tests/test_formsets.py | head -40; grep -rn \"nonfield\\|nonform\" docs/topics/forms/formsets.txt docs/releases/*.txt | tail -20"
}
```

**tool result**

```
339:        self.assertEqual(formset.non_form_errors(), ['Please submit at most 1 form.'])
361:        self.assertEqual(formset.non_form_errors(), ['Please submit at least 3 forms.'])
397:        self.assertEqual(formset.non_form_errors(), ['Please submit at least 1 form.'])
769:        # formset.non_form_errors() method.
770:        for error in formset.non_form_errors():
776:        self.assertEqual(formset.non_form_errors(), [])
890:            formset.non_form_errors(),
914:            formset.non_form_errors(),
933:            formset.non_form_errors(),
974:    def test_non_form_errors(self):
985:        self.assertEqual(formset.non_form_errors(), ['You may only specify a drink once.'])
1040:    def test_formset_error_class(self):
1041:        """Formset's forms use the formset's error_class."""
1045:        formset = FavoriteDrinksFormSet(error_class=CustomErrorList)
1046:        self.assertEqual(formset.forms[0].error_class, CustomErrorList)
1130:    def test_non_form_errors_run_full_clean(self):
1132:        If non_form_errors() is called without calling is_valid() first,
1145:        self.assertIsInstance(formset.non_form_errors(), ErrorList)
1146:        self.assertEqual(list(formset.non_form_errors()), ['This is a non-form error'])
1178:    def test_formset_total_error_count_with_non_form_errors(self):
1307:            formset.non_form_errors(),
1338:            formset.non_form_errors(),
1364:        self.assertEqual(formset.non_form_errors(), ['customized'])
docs/releases/1.8.txt:340:  ``nonfield`` in its list of classes to distinguish them from field-specific
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '960,990p' tests/forms_tests/tests/test_formsets.py; sed -n '1120,1150p' tests/forms_tests/tests/test_formsets.py; ls docs/releases | tail -10; grep -n \"non_form_errors\" docs/ref/forms/api.txt | head"
}
```

**tool result**

```
        """The management form has the correct prefix."""
        formset = FavoriteDrinksFormSet()
        self.assertEqual(formset.management_form.prefix, 'form')
        data = {
            'form-TOTAL_FORMS': '2',
            'form-INITIAL_FORMS': '0',
            'form-MIN_NUM_FORMS': '0',
            'form-MAX_NUM_FORMS': '0',
        }
        formset = FavoriteDrinksFormSet(data=data)
        self.assertEqual(formset.management_form.prefix, 'form')
        formset = FavoriteDrinksFormSet(initial={})
        self.assertEqual(formset.management_form.prefix, 'form')

    def test_non_form_errors(self):
        data = {
            'drinks-TOTAL_FORMS': '2',  # the number of forms rendered
            'drinks-INITIAL_FORMS': '0',  # the number of forms with initial data
            'drinks-MIN_NUM_FORMS': '0',  # min number of forms
            'drinks-MAX_NUM_FORMS': '0',  # max number of forms
            'drinks-0-name': 'Gin and Tonic',
            'drinks-1-name': 'Gin and Tonic',
        }
        formset = FavoriteDrinksFormSet(data, prefix='drinks')
        self.assertFalse(formset.is_valid())
        self.assertEqual(formset.non_form_errors(), ['You may only specify a drink once.'])

    def test_formset_iteration(self):
        """Formset instances are iterable."""
        ChoiceFormset = formset_factory(Choice, extra=3)
        formset = ChoiceFormset()
                    'choices-3-choice': 'Three',
                    'choices-3-votes': '3',
                },
                prefix='choices',
            )
            # Four forms are instantiated and no exception is raised
            self.assertEqual(len(formset.forms), 4)
        finally:
            formsets.DEFAULT_MAX_NUM = _old_DEFAULT_MAX_NUM

    def test_non_form_errors_run_full_clean(self):
        """
        If non_form_errors() is called without calling is_valid() first,
        it should ensure that full_clean() is called.
        """
        class BaseCustomFormSet(BaseFormSet):
            def clean(self):
                raise ValidationError("This is a non-form error")

        ChoiceFormSet = formset_factory(Choice, formset=BaseCustomFormSet)
        data = {
            'choices-TOTAL_FORMS': '1',
            'choices-INITIAL_FORMS': '0',
        }
        formset = ChoiceFormSet(data, auto_id=False, prefix='choices')
        self.assertIsInstance(formset.non_form_errors(), ErrorList)
        self.assertEqual(list(formset.non_form_errors()), ['This is a non-form error'])

    def test_validate_max_ignores_forms_marked_for_deletion(self):
        class CheckForm(Form):
            field = IntegerField()
3.2.1.txt
3.2.2.txt
3.2.3.txt
3.2.4.txt
3.2.5.txt
3.2.6.txt
3.2.txt
4.0.txt
index.txt
security.txt
```

**assistant → tool `bash`**

```json
{
  "command": "cat django/__init__.py | head -5; grep -n \"Forms\\|formset\\|error\" docs/releases/4.0.txt | head -30"
}
```

**tool result**

```
from django.utils.version import get_version

VERSION = (4, 0, 0, 'alpha', 0)

__version__ = get_version(VERSION)
70:* The new :meth:`.ModelAdmin.get_formset_kwargs` method allows customizing the
71:  keyword arguments passed to the constructor of a formset.
212:Forms
218:  error message. This allows custom error messages to use the ``%(value)s``
479:* Tests that fail to load, for example due to syntax errors, now always match
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '138,160p' docs/topics/forms/formsets.txt; sed -n '205,225p' docs/releases/4.0.txt"
}
```

**tool result**

```
protects against memory exhaustion attacks using forged ``POST`` requests::

    >>> from django.forms.formsets import formset_factory
    >>> from myapp.forms import ArticleForm
    >>> ArticleFormSet = formset_factory(ArticleForm, absolute_max=1500)
    >>> data = {
    ...     'form-TOTAL_FORMS': '1501',
    ...     'form-INITIAL_FORMS': '0',
    ... }
    >>> formset = ArticleFormSet(data)
    >>> len(formset.forms)
    1500
    >>> formset.is_valid()
    False
    >>> formset.non_form_errors()
    ['Please submit at most 1000 forms.']

When ``absolute_max`` is ``None``, it defaults to ``max_num + 1000``. (If
``max_num`` is ``None``, it defaults to ``2000``).

If ``absolute_max`` is less than ``max_num``, a ``ValueError`` will be raised.

Formset validation
* ...

File Uploads
~~~~~~~~~~~~

* ...

Forms
~~~~~

* :class:`~django.forms.ModelChoiceField` now includes the provided value in
  the ``params`` argument of a raised
  :exc:`~django.core.exceptions.ValidationError` for the ``invalid_choice``
  error message. This allows custom error messages to use the ``%(value)s``
  placeholder.

Generic Views
~~~~~~~~~~~~~

* :class:`~django.views.generic.edit.DeleteView` now uses
  :class:`~django.views.generic.edit.FormMixin`, allowing you to provide a
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Formset validation\\|Custom formset validation\\|validate_min\\|non_form\" docs/topics/forms/formsets.txt | head -20; sed -n '310,325p' docs/topics/forms/formsets.txt"
}
```

**tool result**

```
152:    >>> formset.non_form_errors()
160:Formset validation
310:    >>> formset.non_form_errors()
318:    >>> formset.non_form_errors()
321:Custom formset validation
361:    >>> formset.non_form_errors()
365:have been called. The errors will be found using the ``non_form_errors()``
401:    >>> formset.non_form_errors()
417:``validate_min``
420:If ``validate_min=True`` is passed to
427:    >>> ArticleFormSet = formset_factory(ArticleForm, min_num=3, validate_min=True)
441:    >>> formset.non_form_errors()
446:    Regardless of ``validate_min``, if a formset contains no data, then
    >>> formset.non_form_errors()
    ['ManagementForm data is missing or has been tampered with. Missing fields: form-TOTAL_FORMS, form-INITIAL_FORMS. You may need to file a bug report if the issue persists.']

And here is a custom error message::

    >>> formset = ArticleFormSet({}, error_messages={'missing_management_form': 'Sorry, something went wrong.'})
    >>> formset.is_valid()
    False
    >>> formset.non_form_errors()
    ['Sorry, something went wrong.']

Custom formset validation
-------------------------

A formset has a ``clean`` method similar to the one on a ``Form`` class. This
is where you define your own validation that works at the formset level::
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/topics/forms/formsets.txt\n@@\n The formset ``clean`` method is called after all the ``Form.clean`` methods\n have been called. The errors will be found using the ``non_form_errors()``\n method on the formset.\n+\n+Non-form errors are rendered with an additional ``nonform`` CSS class to help\n+distinguish them from field-specific and non-field errors. For example,\n+``{{ formset.non_form_errors }}`` would look like:\n+\n+.. code-block:: html+django\n+\n+    <ul class=\"errorlist nonform\">\n+        <li>Articles in a set must have distinct titles.</li>\n+    </ul>\n \n Validating the number of forms in a formset\n ===========================================\n*** Update File: /testbed/docs/releases/4.0.txt\n@@\n Forms\n ~~~~~\n \n+* Non-form errors in formsets now have the ``nonform`` CSS class, allowing\n+  them to be distinguished from field-specific and non-field errors.\n+\n * :class:`~django.forms.ModelChoiceField` now includes the provided value in\n   the ``params`` argument of a raised\n   :exc:`~django.core.exceptions.ValidationError` for the ``invalid_choice``\n*** Update File: /testbed/tests/forms_tests/tests/test_formsets.py\n@@\n     def test_non_form_errors(self):\n         data = {\n             'drinks-TOTAL_FORMS': '2',  # the number of forms rendered\n             'drinks-INITIAL_FORMS': '0',  # the number of forms with initial data\n             'drinks-MIN_NUM_FORMS': '0',  # min number of forms\n@@\n         }\n         formset = FavoriteDrinksFormSet(data, prefix='drinks')\n         self.assertFalse(formset.is_valid())\n         self.assertEqual(formset.non_form_errors(), ['You may only specify a drink once.'])\n+        self.assertEqual(\n+            formset.non_form_errors().as_ul(),\n+            '<ul class=\"errorlist nonform\"><li>You may only specify a drink once.</li></ul>',\n+        )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/docs/topics/forms/formsets.txt /testbed/docs/releases/4.0.txt /testbed/tests/forms_tests/tests/test_formsets.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/docs/topics/forms/formsets.txt now (843 lines), around the change:
364:The formset ``clean`` method is called after all the ``Form.clean`` methods
365:have been called. The errors will be found using the ``non_form_errors()``
366:method on the formset.
367:
368:Non-form errors are rendered with an additional ``nonform`` CSS class to help
369:distinguish them from field-specific and non-field errors. For example,
370:``{{ formset.non_form_errors }}`` would look like:
371:
372:.. code-block:: html+django
373:
374:    <ul class="errorlist nonform">
375:        <li>Articles in a set must have distinct titles.</li>
376:    </ul>
377:
378:Validating the number of forms in a formset
379:===========================================

/testbed/docs/releases/4.0.txt now (622 lines), around the change:
212:Forms
213:~~~~~
214:
215:* Non-form errors in formsets now have the ``nonform`` CSS class, allowing
216:  them to be distinguished from field-specific and non-field errors.
217:
218:* :class:`~django.forms.ModelChoiceField` now includes the provided value in
219:  the ``params`` argument of a raised
220:  :exc:`~django.core.exceptions.ValidationError` for the ``invalid_choice``

/testbed/tests/forms_tests/tests/test_formsets.py now (1488 lines), around the change:
983:        formset = FavoriteDrinksFormSet(data, prefix='drinks')
984:        self.assertFalse(formset.is_valid())
985:        self.assertEqual(formset.non_form_errors(), ['You may only specify a drink once.'])
986:        self.assertEqual(
987:            formset.non_form_errors().as_ul(),
988:            '<ul class="errorlist nonform"><li>You may only specify a drink once.</li></ul>',
989:        )
990:
991:    def test_formset_iteration(self):
992:        """Formset instances are iterable."""
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py forms_tests.tests.test_formsets -v1 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 73 test(s).
System check identified no issues (0 silenced).
.........................................................................
----------------------------------------------------------------------
Ran 73 tests in 0.346s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py forms_tests -v1 2>&1 | tail -8; git status --porcelain -- . ':(exclude).memdoor'"
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
 M django/forms/formsets.py
 M docs/releases/4.0.txt
 M docs/topics/forms/formsets.txt
 M tests/forms_tests/tests/test_formsets.py
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py forms_tests 2>&1 | grep -E \"Ran |OK|FAILED\" | tail -5; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\"; echo exit:$?"
}
```

**tool result**

```
Ran 693 tests in 0.658s
OK (skipped=1)
exit:0
```

**assistant**

```
Done. Formset non-form errors now get the `nonform` CSS class.

Changes:
- `django/forms/formsets.py`: `non_form_errors` are built with `error_class='nonform'` in both initialization and the `ValidationError` handling path.
- `docs/topics/forms/formsets.txt`: documented the `nonform` class with an example.
- `docs/releases/4.0.txt`: added a release note.
- `tests/forms_tests/tests/test_formsets.py`: added an assertion for the rendered `nonform` class.

Verification: all 693 `forms_tests` pass, and the required `git status` command exits 0.
```

## Run folder `single-2026-11-06T112100`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Add `nonform` CSS class for non form errors in FormSets
Description
	 
		(last modified by Ties Jan Hefting)
	 
Forms add the nonfield CSS class for non field errors in ErrorList instances. This is documented in a section on ​rendering form error messages. Similarly, in FormSets I'd expect to see the nonform CSS class added for non form errors. This would allow a custom ErrorList to make a distinction in form field errors, non field errors (forms) and non form errors (FormSets) when rendering error messages. Therefore I'd suggest to add this nonform CSS class and document it for developers to use.
```
