# django__django-11790 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 56s 35 lines cost=0.001984 in=147337 cached=135680 out=2963 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

AuthenticationForm's username field doesn't set maxlength HTML attribute.
Description
	
AuthenticationForm's username field doesn't render with maxlength HTML attribute anymore.
Regression introduced in #27515 and 5ceaf14686ce626404afb6a5fbd3d8286410bf13.
​https://groups.google.com/forum/?utm_source=digest&utm_medium=email#!topic/django-developers/qnfSqro0DlA
​https://forum.djangoproject.com/t/possible-authenticationform-max-length-regression-in-django-2-1/241

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git log --oneline -5 && git status --porcelain"
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
84a9058f3f SWE-bench
b1d6b35e14 Fixed #30725 -- Fixed width of DateTimeField inputs in admin tabular inline.
faf4b988fe Fixed #30758 -- Made RangeFields use multiple hidden inputs for initial data.
733dbb21c7 Refs #30758 -- Added more tests for postgres.forms.ranges.
b9db423d3c Fixed #29376 -- Allowed hiding "Save and Add Another" button in admin.
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class AuthenticationForm\" -A 60 django/contrib/auth/forms.py"
}
```

**tool result**

```
163:class AuthenticationForm(forms.Form):
164-    """
165-    Base class for authenticating users. Extend this to get a form that accepts
166-    username/password logins.
167-    """
168-    username = UsernameField(widget=forms.TextInput(attrs={'autofocus': True}))
169-    password = [redacted]
170-        label=_("Password"),
171-        strip=False,
172-        widget=forms.PasswordInput(attrs={'autocomplete': 'current-password'}),
173-    )
174-
175-    error_messages = {
176-        'invalid_login': _(
177-            "Please enter a correct %(username)s and password. Note that both "
178-            "fields may be case-sensitive."
179-        ),
180-        'inactive': _("This account is inactive."),
181-    }
182-
183-    def __init__(self, request=None, *args, **kwargs):
184-        """
185-        The 'request' parameter is set for custom auth use by subclasses.
186-        The form data comes in via the standard 'data' kwarg.
187-        """
188-        self.request = request
189-        self.user_cache = None
190-        super().__init__(*args, **kwargs)
191-
192-        # Set the max length and label for the "username" field.
193-        self.username_field = UserModel._meta.get_field(UserModel.USERNAME_FIELD)
194-        self.fields['username'].max_length = self.username_field.max_length or 254
195-        if self.fields['username'].label is None:
196-            self.fields['username'].label = capfirst(self.username_field.verbose_name)
197-
198-    def clean(self):
199-        username = self.cleaned_data.get('username')
200-        password = [redacted]'password')
201-
202-        if username is not None and password:
203-            self.user_cache = authenticate(self.request, username=username, password=[redacted]
204-            if self.user_cache is None:
205-                raise self.get_invalid_login_error()
206-            else:
207-                self.confirm_login_allowed(self.user_cache)
208-
209-        return self.cleaned_data
210-
211-    def confirm_login_allowed(self, user):
212-        """
213-        Controls whether the given User may log in. This is a policy setting,
214-        independent of end-user authentication. This default behavior is to
215-        allow login by active users, and reject login by inactive users.
216-
217-        If the given user cannot log in, this method should raise a
218-        ``forms.ValidationError``.
219-
220-        If the given user may log in, this method should return None.
221-        """
222-        if not user.is_active:
223-            raise forms.ValidationError(
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class UsernameField\" -A 10 django/contrib/auth/forms.py; grep -rn \"maxlength\" tests/auth_tests/test_forms.py | head -20"
}
```

**tool result**

```
60:class UsernameField(forms.CharField):
61-    def to_python(self, value):
62-        return unicodedata.normalize('NFKC', super().to_python(value))
63-
64-    def widget_attrs(self, widget):
65-        return {
66-            **super().widget_attrs(widget),
67-            'autocapitalize': 'none',
68-            'autocomplete': 'username',
69-        }
70-
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def widget_attrs\" -A 12 django/forms/fields.py | head -40; git log --oneline --all -- django/contrib/auth/forms.py | head -20"
}
```

**tool result**

```
166:    def widget_attrs(self, widget):
167-        """
168-        Given a Widget instance (*not* a Widget class), return a dictionary of
169-        any HTML attributes that should be added to the Widget, based on this
170-        Field.
171-        """
172-        return {}
173-
174-    def has_changed(self, initial, data):
175-        """Return True if data differs from initial."""
176-        # Always return False if the field is disabled since self.bound_data
177-        # always uses the initial value in this case.
178-        if self.disabled:
--
231:    def widget_attrs(self, widget):
232-        attrs = super().widget_attrs(widget)
233-        if self.max_length is not None and not widget.is_hidden:
234-            # The HTML attribute is maxlength, not max_length.
235-            attrs['maxlength'] = str(self.max_length)
236-        if self.min_length is not None and not widget.is_hidden:
237-            # The HTML attribute is minlength, not min_length.
238-            attrs['minlength'] = str(self.min_length)
239-        return attrs
240-
241-
242-class IntegerField(Field):
243-    widget = NumberInput
--
278:    def widget_attrs(self, widget):
279-        attrs = super().widget_attrs(widget)
280-        if isinstance(widget, NumberInput):
281-            if self.min_value is not None:
282-                attrs['min'] = self.min_value
283-            if self.max_value is not None:
284-                attrs['max'] = self.max_value
285-        return attrs
286-
287-
288-class FloatField(IntegerField):
289-    default_error_messages = {
999891bd80 Refs #29379 -- Moved autocomplete attribute to UsernameField.
42b9a23267 Fixed #30400 -- Improved typography of user facing strings.
dcb8f00d06 Fixed #29379 -- Added autocomplete attribute to contrib.auth.forms fields.
9410db9683 Fixed #30236 -- Made UsernameField render with autocapitalize="none" HTML attribute.
c82893cb8c Refs #27795 -- Removed force_bytes() usage from django/utils/http.py.
a7284cc0c3 Fixed #29809 -- Fixed a crash when a "view only" user POSTs to the admin user change form.
bf39978a53 Fixed CVE-2018-16984 -- Fixed password hash disclosure to admin "view only" users.
f3fa86a89b Fixed #29449 -- Reverted "Fixed #28757 -- Allowed using contrib.auth forms without installing contrib.auth."
874977d388 Fixed #29270 -- Fixed UserChangeForm crash if password field is excluded.
fe99fb860f Removed AuthenticationForm.get_user_id().
af33fb250e Fixed CVE-2018-6188 -- Fixed information leakage in AuthenticationForm.
3333d935d2 Fixed #28757 -- Allowed using contrib.auth forms without installing contrib.auth.
d13a9e44de Fixed #28909 -- Simplified code using tuple/list/set/dict unpacking.
359370a8b8 Fixed #28645 -- Reallowed AuthenticationForm to raise the inactive user error when using ModelBackend.
6ed347d851 Fixed #28706 -- Moved AuthenticationFormn invalid login ValidationError to a method for reuse.
5ceaf14686 Fixed #27515 -- Made AuthenticationForm's username field use the max_length from the model field.
a96b981d84 Fixed #28127 -- Allowed UserCreationForm's password validation to check all user fields.
21046e7773 Fixed #28249 -- Removed unnecessary dict.keys() calls.
c52ae33a0c Fixed #28100 -- Removed link in UserChangeForm.password's translatable help_text
3a148f958d Refs #27795 -- Removed force_text from the template layer
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport django\nfrom django.conf import settings\nsettings.configure(INSTALLED_APPS=['django.contrib.auth','django.contrib.contenttypes'],DATABASES={'default':{'ENGINE':'django.db.backends.sqlite3','NAME':':memory:'}})\ndjango.setup()\nfrom django.contrib.auth.forms import AuthenticationForm\nf=AuthenticationForm()\nprint(f['username'])\nprint(f.fields['username'].max_length)\n\""
}
```

**tool result**

```
<input type="text" name="username" autofocus autocapitalize="none" autocomplete="username" required id="id_username">
150
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '200,240p' django/forms/fields.py && grep -n \"build_widget_attrs\\|widget_attrs\" -n django/forms/boundfield.py"
}
```

**tool result**

```
    def __deepcopy__(self, memo):
        result = copy.copy(self)
        memo[id(self)] = result
        result.widget = copy.deepcopy(self.widget, memo)
        result.validators = self.validators[:]
        return result


class CharField(Field):
    def __init__(self, *, max_length=None, min_length=None, strip=True, empty_value='', **kwargs):
        self.max_length = max_length
        self.min_length = min_length
        self.strip = strip
        self.empty_value = empty_value
        super().__init__(**kwargs)
        if min_length is not None:
            self.validators.append(validators.MinLengthValidator(int(min_length)))
        if max_length is not None:
            self.validators.append(validators.MaxLengthValidator(int(max_length)))
        self.validators.append(validators.ProhibitNullCharactersValidator())

    def to_python(self, value):
        """Return a string."""
        if value not in self.empty_values:
            value = str(value)
            if self.strip:
                value = value.strip()
        if value in self.empty_values:
            return self.empty_value
        return value

    def widget_attrs(self, widget):
        attrs = super().widget_attrs(widget)
        if self.max_length is not None and not widget.is_hidden:
            # The HTML attribute is maxlength, not max_length.
            attrs['maxlength'] = str(self.max_length)
        if self.min_length is not None and not widget.is_hidden:
            # The HTML attribute is minlength, not min_length.
            attrs['minlength'] = str(self.min_length)
        return attrs

46:        attrs = self.build_widget_attrs(attrs)
89:        attrs = self.build_widget_attrs(attrs, widget)
221:    def build_widget_attrs(self, attrs, widget=None):
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '215,245p' django/forms/boundfield.py && sed -n '30,100p' django/forms/boundfield.py"
}
```

**tool result**

```
        # standardized handling. See #22502.
        if (isinstance(data, (datetime.datetime, datetime.time)) and
                not self.field.widget.supports_microseconds):
            data = data.replace(microsecond=0)
        return data

    def build_widget_attrs(self, attrs, widget=None):
        widget = widget or self.field.widget
        attrs = dict(attrs)  # Copy attrs to avoid modifying the argument.
        if widget.use_required_attribute(self.initial) and self.field.required and self.form.use_required_attribute:
            attrs['required'] = True
        if self.field.disabled:
            attrs['disabled'] = True
        return attrs


@html_safe
class BoundWidget:
    """
    A container class used for iterating over widgets. This is useful for
    widgets that have choices. For example, the following can be used in a
    template:

    {% for radio in myform.beatles %}
      <label for="{{ radio.id_for_label }}">
        {{ radio.choice_label }}
        <span class="radio">{{ radio.tag }}</span>
      </label>
    {% endfor %}
    """
    def __init__(self, parent_widget, data, renderer):
        """Render this field as an HTML widget."""
        if self.field.show_hidden_initial:
            return self.as_widget() + self.as_hidden(only_initial=True)
        return self.as_widget()

    @cached_property
    def subwidgets(self):
        """
        Most widgets yield a single subwidget, but others like RadioSelect and
        CheckboxSelectMultiple produce one subwidget for each choice.

        This property is cached so that only one database query occurs when
        rendering ModelChoiceFields.
        """
        id_ = self.field.widget.attrs.get('id') or self.auto_id
        attrs = {'id': id_} if id_ else {}
        attrs = self.build_widget_attrs(attrs)
        return [
            BoundWidget(self.field.widget, widget, self.form.renderer)
            for widget in self.field.widget.subwidgets(self.html_name, self.value(), attrs=attrs)
        ]

    def __bool__(self):
        # BoundField evaluates to True even if it doesn't have subwidgets.
        return True

    def __iter__(self):
        return iter(self.subwidgets)

    def __len__(self):
        return len(self.subwidgets)

    def __getitem__(self, idx):
        # Prevent unnecessary reevaluation when accessing BoundField's attrs
        # from templates.
        if not isinstance(idx, (int, slice)):
            raise TypeError(
                'BoundField indices must be integers or slices, not %s.'
                % type(idx).__name__
            )
        return self.subwidgets[idx]

    @property
    def errors(self):
        """
        Return an ErrorList (empty if there are no errors) for this field.
        """
        return self.form.errors.get(self.name, self.form.error_class())

    def as_widget(self, widget=None, attrs=None, only_initial=False):
        """
        Render the field by rendering the passed widget, adding any HTML
        attributes passed as attrs. If a widget isn't specified, use the
        field's default widget.
        """
        widget = widget or self.field.widget
        if self.field.localize:
            widget.is_localized = True
        attrs = attrs or {}
        attrs = self.build_widget_attrs(attrs, widget)
        if self.auto_id and 'id' not in widget.attrs:
            attrs.setdefault('id', self.html_initial_id if only_initial else self.auto_id)
        return widget.render(
            name=self.html_initial_name if only_initial else self.html_name,
            value=self.value(),
            attrs=attrs,
            renderer=self.form.renderer,
        )

    def as_text(self, attrs=None, **kwargs):
        """
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -rn \"widget_attrs\" django/forms/ | grep -v \"def widget_attrs\""
}
```

**tool result**

```
grep: django/forms/__pycache__/boundfield.cpython-36.pyc: binary file matches
grep: django/forms/__pycache__/fields.cpython-36.pyc: binary file matches
grep: django/forms/__pycache__/widgets.cpython-36.pyc: binary file matches
django/forms/fields.py:102:        # Hook into self.widget_attrs() for any Field-specific HTML attributes.
django/forms/fields.py:103:        extra_attrs = self.widget_attrs(widget)
django/forms/fields.py:232:        attrs = super().widget_attrs(widget)
django/forms/fields.py:279:        attrs = super().widget_attrs(widget)
django/forms/fields.py:317:        attrs = super().widget_attrs(widget)
django/forms/fields.py:359:        attrs = super().widget_attrs(widget)
django/forms/fields.py:649:        attrs = super().widget_attrs(widget)
django/forms/boundfield.py:46:        attrs = self.build_widget_attrs(attrs)
django/forms/boundfield.py:89:        attrs = self.build_widget_attrs(attrs, widget)
django/forms/boundfield.py:221:    def build_widget_attrs(self, attrs, widget=None):
django/forms/widgets.py:351:            widget_attrs = final_attrs.copy()
django/forms/widgets.py:355:                widget_attrs['id'] = '%s_%s' % (id_, index)
django/forms/widgets.py:358:            subwidgets.append(widget.get_context(name, value_, widget_attrs)['widget'])
django/forms/widgets.py:834:                widget_attrs = final_attrs.copy()
django/forms/widgets.py:835:                widget_attrs['id'] = '%s_%s' % (id_, i)
django/forms/widgets.py:837:                widget_attrs = final_attrs
django/forms/widgets.py:838:            subwidgets.append(widget.get_context(widget_name, widget_value, widget_attrs)['widget'])
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '80,115p' django/forms/fields.py"
}
```

**tool result**

```
        #             is its widget is shown in the form but not editable.
        # label_suffix -- Suffix to be added to the label. Overrides
        #                 form's label_suffix.
        self.required, self.label, self.initial = required, label, initial
        self.show_hidden_initial = show_hidden_initial
        self.help_text = help_text
        self.disabled = disabled
        self.label_suffix = label_suffix
        widget = widget or self.widget
        if isinstance(widget, type):
            widget = widget()
        else:
            widget = copy.deepcopy(widget)

        # Trigger the localization machinery if needed.
        self.localize = localize
        if self.localize:
            widget.is_localized = True

        # Let the widget know whether it should display as required.
        widget.is_required = self.required

        # Hook into self.widget_attrs() for any Field-specific HTML attributes.
        extra_attrs = self.widget_attrs(widget)
        if extra_attrs:
            widget.attrs.update(extra_attrs)

        self.widget = widget

        messages = {}
        for c in reversed(self.__class__.__mro__):
            messages.update(getattr(c, 'default_error_messages', {}))
        messages.update(error_messages or {})
        self.error_messages = messages

        self.validators = [*self.default_validators, *validators]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/contrib/auth/forms.py\n@@\n         # Set the max length and label for the \"username\" field.\n         self.username_field = UserModel._meta.get_field(UserModel.USERNAME_FIELD)\n-        self.fields['username'].max_length = self.username_field.max_length or 254\n+        username_max_length = self.username_field.max_length or 254\n+        self.fields['username'].max_length = username_max_length\n+        self.fields['username'].widget.attrs['maxlength'] = username_max_length\n         if self.fields['username'].label is None:\n             self.fields['username'].label = capfirst(self.username_field.verbose_name)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/contrib/auth/forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/contrib/auth/forms.py now (437 lines), around the change:
191:
192:        # Set the max length and label for the "username" field.
193:        self.username_field = UserModel._meta.get_field(UserModel.USERNAME_FIELD)
194:        username_max_length = self.username_field.max_length or 254
195:        self.fields['username'].max_length = username_max_length
196:        self.fields['username'].widget.attrs['maxlength'] = username_max_length
197:        if self.fields['username'].label is None:
198:            self.fields['username'].label = capfirst(self.username_field.verbose_name)
199:
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -rn \"maxlength\" tests/auth_tests/ | head -20 && python -c \"\nimport django\nfrom django.conf import settings\nsettings.configure(INSTALLED_APPS=['django.contrib.auth','django.contrib.contenttypes'],DATABASES={'default':{'ENGINE':'django.db.backends.sqlite3','NAME':':memory:'}})\ndjango.setup()\nfrom django.contrib.auth.forms import AuthenticationForm\nf=AuthenticationForm()\nprint(f['username'])\n\""
}
```

**tool result**

```
<input type="text" name="username" autofocus autocapitalize="none" autocomplete="username" maxlength="150" required id="id_username">
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py auth_tests.test_forms -v1 2>&1 | tail -20"
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
...............................................................................
----------------------------------------------------------------------
Ran 79 tests in 0.775s

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
  "command": "cd /testbed && grep -n \"autocomplete\\|autocapitalize\\|username.*attrs\\|test_username\" tests/auth_tests/test_forms.py | head -20"
}
```

**tool result**

```
264:    def test_username_field_autocapitalize_none(self):
266:        self.assertEqual(form.fields['username'].widget.attrs.get('autocapitalize'), 'none')
268:    def test_html_autocomplete_attributes(self):
275:        for field_name, autocomplete in tests:
276:            with self.subTest(field_name=field_name, autocomplete=autocomplete):
277:                self.assertEqual(form.fields[field_name].widget.attrs['autocomplete'], autocomplete)
416:    def test_username_field_max_length_matches_user_model(self):
429:    def test_username_field_max_length_defaults_to_254(self):
440:    def test_username_field_label(self):
448:    def test_username_field_label_not_set(self):
457:    def test_username_field_autocapitalize_none(self):
459:        self.assertEqual(form.fields['username'].widget.attrs.get('autocapitalize'), 'none')
461:    def test_username_field_label_empty_string(self):
506:    def test_html_autocomplete_attributes(self):
512:        for field_name, autocomplete in tests:
513:            with self.subTest(field_name=field_name, autocomplete=autocomplete):
514:                self.assertEqual(form.fields[field_name].widget.attrs['autocomplete'], autocomplete)
596:    def test_html_autocomplete_attributes(self):
602:        for field_name, autocomplete in tests:
603:            with self.subTest(field_name=field_name, autocomplete=autocomplete):
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '410,440p' tests/auth_tests/test_forms.py"
}
```

**tool result**

```
        }
        form = AuthenticationForm(None, data)
        self.assertTrue(form.is_valid())
        self.assertEqual(form.non_field_errors(), [])

    @override_settings(AUTH_USER_MODEL='auth_tests.CustomEmailField')
    def test_username_field_max_length_matches_user_model(self):
        self.assertEqual(CustomEmailField._meta.get_field('username').max_length, 255)
        data = {
            'username': 'u' * 255,
            'password': 'pwd',
            'email': 'test@example.com',
        }
        CustomEmailField.objects.create_user(**data)
        form = AuthenticationForm(None, data)
        self.assertEqual(form.fields['username'].max_length, 255)
        self.assertEqual(form.errors, {})

    @override_settings(AUTH_USER_MODEL='auth_tests.IntegerUsernameUser')
    def test_username_field_max_length_defaults_to_254(self):
        self.assertIsNone(IntegerUsernameUser._meta.get_field('username').max_length)
        data = {
            'username': '0123456',
            'password': '[redacted]',
        }
        IntegerUsernameUser.objects.create_user(**data)
        form = AuthenticationForm(None, data)
        self.assertEqual(form.fields['username'].max_length, 254)
        self.assertEqual(form.errors, {})

    def test_username_field_label(self):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/auth_tests/test_forms.py\n@@\n         CustomEmailField.objects.create_user(**data)\n         form = AuthenticationForm(None, data)\n         self.assertEqual(form.fields['username'].max_length, 255)\n+        self.assertEqual(form.fields['username'].widget.attrs['maxlength'], 255)\n         self.assertEqual(form.errors, {})\n@@\n         IntegerUsernameUser.objects.create_user(**data)\n         form = AuthenticationForm(None, data)\n         self.assertEqual(form.fields['username'].max_length, 254)\n+        self.assertEqual(form.fields['username'].widget.attrs['maxlength'], 254)\n         self.assertEqual(form.errors, {})\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/auth_tests/test_forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/auth_tests/test_forms.py now (1052 lines), around the change:
423:        CustomEmailField.objects.create_user(**data)
424:        form = AuthenticationForm(None, data)
425:        self.assertEqual(form.fields['username'].max_length, 255)
426:        self.assertEqual(form.fields['username'].widget.attrs['maxlength'], 255)
427:        self.assertEqual(form.errors, {})
428:
429:    @override_settings(AUTH_USER_MODEL='auth_tests.IntegerUsernameUser')
…
436:        IntegerUsernameUser.objects.create_user(**data)
437:        form = AuthenticationForm(None, data)
438:        self.assertEqual(form.fields['username'].max_length, 254)
439:        self.assertEqual(form.fields['username'].widget.attrs['maxlength'], 254)
440:        self.assertEqual(form.errors, {})
441:
442:    def test_username_field_label(self):
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py auth_tests.test_forms -v1 2>&1 | tail -8 && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
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
TASK_OK
```

**assistant**

```
Fixed the regression.

**Change** (`django/contrib/auth/forms.py`): `AuthenticationForm.__init__` now sets the `maxlength` widget attribute when it applies the user model's username max length, so the rendered input includes `maxlength="150"` (or the custom model's value / 254 fallback).

**Tests** (`tests/auth_tests/test_forms.py`): extended the max-length tests to assert the widget attribute for both a custom 255-char username field and the 254 fallback.

`auth_tests.test_forms` passes (79 tests), and the completion check exits 0.
```

## Run folder `single-2026-11-06T105220`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
AuthenticationForm's username field doesn't set maxlength HTML attribute.
Description
	
AuthenticationForm's username field doesn't render with maxlength HTML attribute anymore.
Regression introduced in #27515 and 5ceaf14686ce626404afb6a5fbd3d8286410bf13.
​https://groups.google.com/forum/?utm_source=digest&utm_medium=email#!topic/django-developers/qnfSqro0DlA
​https://forum.djangoproject.com/t/possible-authenticationform-max-length-regression-in-django-2-1/241
```
