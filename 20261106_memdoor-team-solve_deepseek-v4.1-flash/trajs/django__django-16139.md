# django__django-16139 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 86s 34 lines cost=0.003427 in=106746 cached=75264 out=6084 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Accessing UserAdmin via to_field leads to link to PasswordResetForm being broken (404)
Description
	 
		(last modified by Simon Kern)
	 
Accessing the UserAdmin via another model's Admin that has a reference to User (with to_field set, e.g., to_field="uuid") leads to the UserAdmin being accessed via an url that looks similar to this one:
.../user/22222222-3333-4444-5555-666677778888/change/?_to_field=uuid
However the underlying form looks like this: 
Code highlighting:
class UserChangeForm(forms.ModelForm):
	password = ReadOnlyPasswordHashField(
		label=_("Password"),
		help_text=_(
			"Raw passwords are not stored, so there is no way to see this "
			"user’s password, but you can change the password using "
			'<a href="{}">this form</a>.'
		),
	)
	...
	...
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		password = self.fields.get("password")
		if password:
			password.help_text = password.help_text.format("../password/")
	...
	...
This results in the link to the PasswordResetForm being wrong and thus ending up in a 404. If we drop the assumption that UserAdmin is always accessed via its pk, then we're good to go. It's as simple as replacing password.help_text = password.help_text.format("../password/") with password.help_text = password.help_text.format(f"../../{self.instance.pk}/password/")
I've opened a pull request on GitHub for this Ticket, please see:
​PR


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn 'password.help_text.format' --include=*.py . | head -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "git status --short && git log -1 --oneline"
}
```

**tool result**

```
./django/contrib/auth/forms.py:166:            password.help_text = password.help_text.format("../password/")
```

**tool result**

```
?? .memdoor/
9d540a3f34 SWE-bench
```

**assistant → tool `read_file`**

```json
{
  "path": "django/contrib/auth/forms.py",
  "offset": 120,
  "limit": 80
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn 'password/' tests/auth_tests/test_forms.py tests/auth_tests/test_admin.py 2>/dev/null | head -30; ls tests/auth_tests/"
}
```

**tool result**

```
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise ValidationError(
                self.error_messages["password_mismatch"],
                code="password_mismatch",
            )
        return password2

    def _post_clean(self):
        super()._post_clean()
        # Validate the password after self.instance is updated with form data
        # by super().
        password = [redacted]"password2")
        if password:
            try:
                password_validation.validate_password(password, self.instance)
            except ValidationError as error:
                self.add_error("password2", error)

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user


class UserChangeForm(forms.ModelForm):
    password = [redacted]
        label=_("Password"),
        help_text=_(
            "Raw passwords are not stored, so there is no way to see this "
            "user’s password, but you can change the password using "
            '<a href="{}">this form</a>.'
        ),
    )

    class Meta:
        model = User
        fields = "__all__"
        field_classes = {"username": UsernameField}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        password = [redacted]"password")
        if password:
            [redacted] = password.help_text.format("../password/")
        user_permissions = self.fields.get("user_permissions")
        if user_permissions:
            user_permissions.queryset = user_permissions.queryset.select_related(
                "content_type"
            )


class AuthenticationForm(forms.Form):
    """
    Base class for authenticating users. Extend this to get a form that accepts
    username/password logins.
    """

    username = UsernameField(widget=forms.TextInput(attrs={"autofocus": True}))
    password = [redacted]
        label=_("Password"),
        strip=False,
        widget=forms.PasswordInput(attrs={"autocomplete": "current-password"}),
    )

    error_messages = {
        "invalid_login": _(
            "Please enter a correct %(username)s and password. Note that both "
            "fields may be case-sensitive."
        ),
        "inactive": _("This account is inactive."),
    }

    def __init__(self, request=None, *args, **kwargs):
        """
        The 'request' parameter is set for custom auth use by subclasses.
        The form data comes in via the standard 'data' kwarg.
        """

[286 more lines in /testbed/django/contrib/auth/forms.py (485 in all). read_file with offset: 200 to continue]
```

**tool result**

```
__init__.py
backend_alias.py
client.py
common-passwords-custom.txt
fixtures
models
settings.py
templates
test_admin_multidb.py
test_auth_backends.py
test_basic.py
test_checks.py
test_context_processors.py
test_decorators.py
test_forms.py
test_handlers.py
test_hashers.py
test_management.py
test_middleware.py
test_migrations.py
test_mixins.py
test_models.py
test_remote_user.py
test_signals.py
test_templates.py
test_tokens.py
test_validators.py
test_views.py
urls.py
urls_admin.py
urls_custom_user_admin.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn 'help_text\\|UserChangeForm' tests/auth_tests/test_forms.py | head -30; grep -rn 'to_field\\|_to_field' tests/auth_tests/test_admin.py tests/auth_tests/urls_custom_user_admin.py | head -30"
}
```

**tool result**

```
13:    UserChangeForm,
274:    def test_password_help_text(self):
277:            form.fields["password1"].help_text,
712:    def test_help_text_translation(self):
713:        french_help_texts = [
721:            for french_text in french_help_texts:
813:class UserChangeFormTest(TestDataMixin, TestCase):
817:        form = UserChangeForm(data, instance=user)
828:        # UserChangeForm.
830:        class MyUserForm(UserChangeForm):
835:                ].help_text = "These groups give users different permissions"
837:            class Meta(UserChangeForm.Meta):
847:        form = UserChangeForm(instance=user)
852:        form = UserChangeForm(instance=user)
857:        form = UserChangeForm(instance=user)
864:        form = UserChangeForm(instance=user)
873:        form_for_data = UserChangeForm(instance=user)
881:        form = UserChangeForm(instance=user, data=post_data)
889:        form = UserChangeForm(data={}, instance=user)
896:        class CustomUserChangeForm(UserChangeForm):
897:            class Meta(UserChangeForm.Meta):
911:        form = CustomUserChangeForm(data, instance=user)
918:        class UserChangeFormWithoutPassword(UserChangeForm):
925:        form = UserChangeFormWithoutPassword()
929:        form = UserChangeForm()
grep: tests/auth_tests/test_admin.py: No such file or directory
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/test_forms.py",
  "offset": 840,
  "limit": 100
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn 'to_field\\|_to_field\\|password/' tests/auth_tests/*.py | head -40"
}
```

**tool result**

```
        # Just check we can create it
        MyUserForm({})

    def test_unusable_password(self):
        user = User.objects.get(username="empty_password")
        user.set_unusable_password()
        user.save()
        form = UserChangeForm(instance=user)
        self.assertIn(_("No password set."), form.as_table())

    def test_bug_17944_empty_password(self):
        user = User.objects.get(username="empty_password")
        form = UserChangeForm(instance=user)
        self.assertIn(_("No password set."), form.as_table())

    def test_bug_17944_unmanageable_password(self):
        user = User.objects.get(username="unmanageable_password")
        form = UserChangeForm(instance=user)
        self.assertIn(
            _("Invalid password format or unknown hashing algorithm."), form.as_table()
        )

    def test_bug_17944_unknown_password_algorithm(self):
        user = User.objects.get(username="unknown_password")
        form = UserChangeForm(instance=user)
        self.assertIn(
            _("Invalid password format or unknown hashing algorithm."), form.as_table()
        )

    def test_bug_19133(self):
        "The change form does not return the password value"
        # Use the form to construct the POST data
        user = User.objects.get(username="testclient")
        form_for_data = UserChangeForm(instance=user)
        post_data = form_for_data.initial

        # The password field should be readonly, so anything
        # posted here should be ignored; the form will be
        # valid, and give back the 'initial' value for the
        # password field.
        post_data["password"] = "new password"
        form = UserChangeForm(instance=user, data=post_data)

        self.assertTrue(form.is_valid())
        # original hashed password contains $
        self.assertIn("$", form.cleaned_data["password"])

    def test_bug_19349_bound_password_field(self):
        user = User.objects.get(username="testclient")
        form = UserChangeForm(data={}, instance=user)
        # When rendering the bound password field,
        # ReadOnlyPasswordHashWidget needs the initial
        # value to render correctly
        self.assertEqual(form.initial["password"], form["password"].value())

    def test_custom_form(self):
        class CustomUserChangeForm(UserChangeForm):
            class Meta(UserChangeForm.Meta):
                model = ExtensionUser
                fields = (
                    "username",
                    "password",
                    "date_of_birth",
                )

        user = User.objects.get(username="testclient")
        data = {
            "username": "testclient",
            "password": "[redacted]",
            "date_of_birth": "1998-02-24",
        }
        form = CustomUserChangeForm(data, instance=user)
        self.assertTrue(form.is_valid())
        form.save()
        self.assertEqual(form.cleaned_data["username"], "testclient")
        self.assertEqual(form.cleaned_data["date_of_birth"], datetime.date(1998, 2, 24))

    def test_password_excluded(self):
        class UserChangeFormWithoutPassword(UserChangeForm):
            password = None

            class Meta:
                model = User
                exclude = ["password"]

        form = UserChangeFormWithoutPassword()
        self.assertNotIn("password", form.fields)

    def test_username_field_autocapitalize_none(self):
        form = UserChangeForm()
        self.assertEqual(
            form.fields["username"].widget.attrs.get("autocapitalize"), "none"
        )


@override_settings(TEMPLATES=AUTH_TEMPLATES)
class PasswordResetFormTest(TestDataMixin, TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()

[345 more lines in /testbed/tests/auth_tests/test_forms.py (1284 in all). read_file with offset: 940 to continue]
```

**tool result**

```
tests/auth_tests/client.py:21:    to '/reset/bla/set-password/':
tests/auth_tests/test_views.py:448:        self.assertRedirects(response, "/reset/%s/set-password/" % uuidb64)
tests/auth_tests/test_views.py:466:        response = Client().get("/reset/%s/set-password/" % uuidb64)
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/test_forms.py",
  "offset": 1,
  "limit": 40
}
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/test_forms.py",
  "offset": 810,
  "limit": 35
}
```

**tool result**

```
import datetime
import re
from unittest import mock

from django.contrib.auth.forms import (
    AdminPasswordChangeForm,
    AuthenticationForm,
    PasswordChangeForm,
    PasswordResetForm,
    ReadOnlyPasswordHashField,
    ReadOnlyPasswordHashWidget,
    SetPasswordForm,
    UserChangeForm,
    UserCreationForm,
)
from django.contrib.auth.models import User
from django.contrib.auth.signals import user_login_failed
from django.contrib.sites.models import Site
from django.core import mail
from django.core.exceptions import ValidationError
from django.core.mail import EmailMultiAlternatives
from django.forms import forms
from django.forms.fields import CharField, Field, IntegerField
from django.test import SimpleTestCase, TestCase, override_settings
from django.utils import translation
from django.utils.text import capfirst
from django.utils.translation import gettext as _

from .models.custom_user import (
    CustomUser,
    CustomUserWithoutIsActiveField,
    ExtensionUser,
)
from .models.with_custom_email_field import CustomEmailField
from .models.with_integer_username import IntegerUsernameUser
from .settings import AUTH_TEMPLATES


class TestDataMixin:
    @classmethod

[1244 more lines in /testbed/tests/auth_tests/test_forms.py (1284 in all). read_file with offset: 41 to continue]
```

**tool result**

```
        )


class UserChangeFormTest(TestDataMixin, TestCase):
    def test_username_validity(self):
        user = User.objects.get(username="testclient")
        data = {"username": "not valid"}
        form = UserChangeForm(data, instance=user)
        self.assertFalse(form.is_valid())
        validator = next(
            v
            for v in User._meta.get_field("username").validators
            if v.code == "invalid"
        )
        self.assertEqual(form["username"].errors, [str(validator.message)])

    def test_bug_14242(self):
        # A regression test, introduce by adding an optimization for the
        # UserChangeForm.

        class MyUserForm(UserChangeForm):
            def __init__(self, *args, **kwargs):
                super().__init__(*args, **kwargs)
                self.fields[
                    "groups"
                ].help_text = "These groups give users different permissions"

            class Meta(UserChangeForm.Meta):
                fields = ("groups",)

        # Just check we can create it
        MyUserForm({})

    def test_unusable_password(self):
        user = User.objects.get(username="empty_password")

[440 more lines in /testbed/tests/auth_tests/test_forms.py (1284 in all). read_file with offset: 845 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/auth/forms.py\n@@\n         password = self.fields.get(\"password\")\n         if password:\n-            password.help_text = password.help_text.format(\"../password/\")\n+            password.help_text = password.help_text.format(\n+                f\"../../{self.instance.pk}/password/\"\n+            )\n*** Update File: tests/auth_tests/test_forms.py\n@@\n     def test_username_field_autocapitalize_none(self):\n         form = UserChangeForm()\n         self.assertEqual(\n             form.fields[\"username\"].widget.attrs.get(\"autocapitalize\"), \"none\"\n         )\n+\n+    def test_password_help_text(self):\n+        user = User.objects.get(username=\"testclient\")\n+        form = UserChangeForm(instance=user)\n+        self.assertIn(\n+            f'href=\"../../{user.pk}/password/\"',\n+            form.fields[\"password\"].help_text,\n+        )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/auth/forms.py tests/auth_tests/test_forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/auth/forms.py now (487 lines), around the change:
163:        super().__init__(*args, **kwargs)
164:        password = [redacted]"password")
165:        if password:
166:            password.help_text = password.help_text.format(
167:                f"../../{self.instance.pk}/password/"
168:            )
169:        user_permissions = self.fields.get("user_permissions")
170:        if user_permissions:
171:            user_permissions.queryset = user_permissions.queryset.select_related(

tests/auth_tests/test_forms.py now (1292 lines), around the change:
931:            form.fields["username"].widget.attrs.get("autocapitalize"), "none"
932:        )
933:
934:    def test_password_help_text(self):
935:        user = User.objects.get(username="testclient")
936:        form = UserChangeForm(instance=user)
937:        self.assertIn(
938:            f'href="../../{user.pk}/password/"',
939:            form.fields["password"].help_text,
940:        )
941:
942:
943:@override_settings(TEMPLATES=AUTH_TEMPLATES)
944:class PasswordResetFormTest(TestDataMixin, TestCase):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/auth_tests/test_forms.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py auth_tests.test_forms.UserChangeFormTest -v1 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 12 test(s).
System check identified no issues (0 silenced).
............
----------------------------------------------------------------------
Ran 12 tests in 0.199s

OK
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py auth_tests -v1 2>&1 | tail -8"
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
  "command": "python tests/runtests.py auth_tests -v1 2>&1 | grep -E 'Ran |OK|FAILED|ERROR' | tail -5; git diff --stat"
}
```

**tool result**

```
Ran 616 tests in 15.895s
OK
 django/contrib/auth/forms.py   | 4 +++-
 tests/auth_tests/test_forms.py | 8 ++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)
```

**assistant**

````
Fixed the broken password-reset link in `UserChangeForm`.

**Change** (`django/contrib/auth/forms.py`):
```python
password.help_text = password.help_text.format(
    f"../../{self.instance.pk}/password/"
)
```
Instead of assuming the admin change page is always reached via the user's PK (`../password/`), the link now uses the instance's actual PK relative to the current change URL. This works when the UserAdmin is reached through a `to_field` reference (e.g. `.../user/<uuid>/change/?_to_field=uuid`), where the extra path segment previously made `../password/` resolve incorrectly and 404.

**Test added** (`tests/auth_tests/test_forms.py`): `UserChangeFormTest.test_password_help_text` asserts the rendered help text contains `href="../../<pk>/password/"`.

**Verification**: `python tests/runtests.py auth_tests` — 616 tests, all OK. No commits or tree changes beyond the two files.
````

## Run folder `team-solve-2026-11-06T113031`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
9d540a3f34d9cbd64fb022ee69c663bd25fea220
```

### `baseline-check.log`

```
check: ./tests/runtests.py auth_tests.test_forms
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 86 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
......................................................................................
----------------------------------------------------------------------
Ran 86 tests in 0.240s

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

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/django/contrib/auth/forms.py b/django/contrib/auth/forms.py
index b3cfc6723c..523830e8ee 100755
--- a/django/contrib/auth/forms.py
+++ b/django/contrib/auth/forms.py
@@ -163,7 +163,9 @@ class UserChangeForm(forms.ModelForm):
         super().__init__(*args, **kwargs)
         password = self.fields.get("password")
         if password:
-            password.help_text = password.help_text.format("../password/")
+            password.help_text = password.help_text.format(
+                f"../../{self.instance.pk}/password/"
+            )
         user_permissions = self.fields.get("user_permissions")
         if user_permissions:
             user_permissions.queryset = user_permissions.queryset.select_related(
diff --git a/tests/auth_tests/test_forms.py b/tests/auth_tests/test_forms.py
index 3bacd7a9fb..505cb6c756 100755
--- a/tests/auth_tests/test_forms.py
+++ b/tests/auth_tests/test_forms.py
@@ -931,6 +931,14 @@ class UserChangeFormTest(TestDataMixin, TestCase):
             form.fields["username"].widget.attrs.get("autocapitalize"), "none"
         )
 
+    def test_password_help_text(self):
+        user = User.objects.get(username="testclient")
+        form = UserChangeForm(instance=user)
+        self.assertIn(
+            f'href="../../{user.pk}/password/"',
+            form.fields["password"].help_text,
+        )
+
 
 @override_settings(TEMPLATES=AUTH_TEMPLATES)
 class PasswordResetFormTest(TestDataMixin, TestCase):
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

Accessing UserAdmin via to_field leads to link to PasswordResetForm being broken (404)
Description
	 
		(last modified by Simon Kern)
	 
Accessing the UserAdmin via another model's Admin that has a reference to User (with to_field set, e.g., to_field="uuid") leads to the UserAdmin being accessed via an url that looks similar to this one:
.../user/22222222-3333-4444-5555-666677778888/change/?_to_field=uuid
However the underlying form looks like this: 
Code highlighting:
class UserChangeForm(forms.ModelForm):
	password = ReadOnlyPasswordHashField(
		label=_("Password"),
		help_text=_(
			"Raw passwords are not stored, so there is no way to see this "
			"user’s password, but you can change the password using "
			'<a href="{}">this form</a>.'
		),
	)
	...
	...
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		password = self.fields.get("password")
		if password:
			password.help_text = password.help_text.format("../password/")
	...
	...
This results in the link to the PasswordResetForm being wrong and thus ending up in a 404. If we drop the assumption that UserAdmin is always accessed via its pk, then we're good to go. It's as simple as replacing password.help_text = password.help_text.format("../password/") with password.help_text = password.help_text.format(f"../../{self.instance.pk}/password/")
I've opened a pull request on GitHub for this Ticket, please see:
​PR

## Deliverable

changes to this tree

## Check

`./tests/runtests.py auth_tests.test_forms`

## Scope

`django/contrib/auth/forms.py`
`tests/auth_tests/test_forms.py`

## Done when

- `UserChangeForm` formats the password help text with `../../{self.instance.pk}/password/` instead of `../password/`.
- A user change page reached through a `to_field` URL renders a password-change link that resolves to the user’s password change form instead of a 404.
- The scoped auth form tests pass.



# plan.md

## Deliverable
changes to this tree

## Check
`./tests/runtests.py auth_tests.test_forms`

## Scope
`django/contrib/auth/forms.py`
`tests/auth_tests/test_forms.py`

## Done when
- `UserChangeForm` formats the password help text with `../../{self.instance.pk}/password/` instead of `../password/`.
- A user change page reached through a `to_field` URL renders a password-change link that resolves to the user’s password change form instead of a 404.
- The scoped auth form tests pass.

## Approach
Change `UserChangeForm.__init__` so the password help text uses the instance’s primary key and two parent path segments: `password.help_text = password.help_text.format(f"../../{self.instance.pk}/password/")`. This matches the actual admin URL shape when the change view is reached with `_to_field`.

Candidate alternatives:
- Use `reverse("admin:auth_user_password_change", args=[self.instance.pk])` for an absolute admin URL. More robust to path depth, but couples the auth form to admin URL names and may not fit custom user admins.
- Override `UserAdmin.get_form()` and set the help text from the request path. Handles custom admin routing, but is more invasive and does not fix direct `UserChangeForm` use.
- Keep the relative link but compute depth from the request. The form has no request, so this requires passing context through the admin, which is unnecessary for the reported bug.


# django/contrib/auth/forms.py

```
import unicodedata

from django import forms
from django.contrib.auth import authenticate, get_user_model, password_validation
from django.contrib.auth.hashers import UNUSABLE_PASSWORD_PREFIX, identify_hasher
from django.contrib.auth.models import User
from django.contrib.auth.tokens import default_token_generator
from django.contrib.sites.shortcuts import get_current_site
from django.core.exceptions import ValidationError
from django.core.mail import EmailMultiAlternatives
from django.template import loader
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from django.utils.text import capfirst
from django.utils.translation import gettext
from django.utils.translation import gettext_lazy as _

UserModel = get_user_model()


def _unicode_ci_compare(s1, s2):
    """
    Perform case-insensitive comparison of two identifiers, using the
    recommended algorithm from Unicode Technical Report 36, section
    2.11.2(B)(2).
    """
    return (
        unicodedata.normalize("NFKC", s1).casefold()
        == unicodedata.normalize("NFKC", s2).casefold()
    )


class ReadOnlyPasswordHashWidget(forms.Widget):
    template_name = "auth/widgets/read_only_password_hash.html"
    read_only = True

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        summary = []
        if not value or value.startswith(UNUSABLE_PASSWORD_PREFIX):
            summary.append({"label": gettext("No password set.")})
        else:
            try:
                hasher = identify_hasher(value)
            except ValueError:
                summary.append(
                    {
                        "label": gettext(
                            "Invalid password format or unknown hashing algorithm."
                        )
                    }
                )
            else:
                for key, value_ in hasher.safe_summary(value).items():
                    summary.append({"label": gettext(key), "value": value_})
        context["summary"] = summary
        return context

    def id_for_label(self, id_):
        return None


class ReadOnlyPasswordHashField(forms.Field):
    widget = ReadOnlyPasswordHashWidget

    def __init__(self, *args, **kwargs):
        kwargs.setdefault("required", False)
        kwargs.setdefault("disabled", True)
        super().__init__(*args, **kwargs)


class UsernameField(forms.CharField):
    def to_python(self, value):
        return unicodedata.normalize("NFKC", super().to_python(value))

    def widget_attrs(self, widget):
        return {
            **super().widget_attrs(widget),
            "autocapitalize": "none",
            "autocomplete": "username",
        }


class UserCreationForm(forms.ModelForm):
    """
    A form that creates a user, with no privileges, from the given username and
    password.
    """

    error_messages = {
        "password_mismatch": _("The two password fields didn’t match."),
    }
    password1 = forms.CharField(
        label=_("Password"),
        strip=False,
        widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}),
        help_text=password_validation.password_validators_help_text_html(),
    )
    password2 = forms.CharField(
        label=_("Password confirmation"),
        widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}),
        strip=False,
        help_text=_("Enter the same password as before, for verification."),
    )

    class Meta:
        model = User
        fields = ("username",)
        field_classes = {"username": UsernameField}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self._meta.model.USERNAME_FIELD in self.fields:
            self.fields[self._meta.model.USERNAME_FIELD].widget.attrs[
                "autofocus"
            ] = True

    def clean_password2(self):
        password1 = self.cleaned_data.get("password1")
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise ValidationError(
                self.error_messages["password_mismatch"],
                code="password_mismatch",
            )
        return password2

    def _post_clean(self):
        super()._post_clean()
        # Validate the password after self.instance is updated with form data
        # by super().
        password = self.cleaned_data.get("password2")
        if password:
            try:
                password_validation.validate_password(password, self.instance)
            except ValidationError as error:
                self.add_error("password2", error)

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user


class UserChangeForm(forms.ModelForm):
    password = ReadOnlyPasswordHashField(
        label=_("Password"),
        help_text=_(
            "Raw passwords are not stored, so there is no way to see this "
            "user’s password, but you can change the password using "
            '<a href="{}">this form</a>.'
        ),
    )

    class Meta:
        model = User
        fields = "__all__"
        field_classes = {"username": UsernameField}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        password = self.fields.get("password")
        if password:
            password.help_text = password.help_text.format(
                f"../../{self.instance.pk}/password/"
            )
        user_permissions = self.fields.get("user_permissions")
        if user_permissions:
            user_permissions.queryset = user_permissions.queryset.select_related(
                "content_type"
            )


class AuthenticationForm(forms.Form):
    """
    Base class for authenticating users. Extend this to get a form that accepts
    username/password logins.
    """

    username = UsernameField(widget=forms.TextInput(attrs={"autofocus": True}))
    password = forms.CharField(
        label=_("Password"),
        strip=False,
        widget=forms.PasswordInput(attrs={"autocomplete": "current-password"}),
    )

    error_messages = {
        "invalid_login": _(
            "Please enter a correct %(username)s and password. Note that both "
            "fields may be case-sensitive."
        ),
        "inactive": _("This account is inactive."),
    }

    def __init__(self, request=None, *args, **kwargs):
        """
        The 'request' parameter is set for custom auth use by subclasses.
        The form data comes in via the standard 'data' kwarg.
        """
        self.request = request
        self.user_cache = None
        super().__init__(*args, **kwargs)

        # Set the max length and label for the "username" field.
        self.username_field = UserModel._meta.get_field(UserModel.USERNAME_FIELD)
        username_max_length = self.username_field.max_length or 254
        self.fields["username"].max_length = username_max_length
        self.fields["username"].widget.attrs["maxlength"] = username_max_length
        if self.fields["username"].label is None:
            self.fields["username"].label = capfirst(self.username_field.verbose_name)

    def clean(self):
        username = self.cleaned_data.get("username")
        password = self.cleaned_data.get("password")

        if username is not None and password:
            self.user_cache = authenticate(
                self.request, username=username, password=password
            )
            if self.user_cache is None:
                raise self.get_invalid_login_error()
            else:
                self.confirm_login_allowed(self.user_cache)

        return self.cleaned_data

    def confirm_login_allowed(self, user):
        """
        Controls whether the given User may log in. This is a policy setting,
        independent of end-user authentication. This default behavior is to
        allow login by active users, and reject login by inactive users.

        If the given user cannot log in, this method should raise a
        ``ValidationError``.

        If the given user may log in, this method should return None.
        """
        if not user.is_active:
            raise ValidationError(
                self.error_messages["inactive"],
                code="inactive",
            )

    def get_user(self):
        return self.user_cache

    def get_invalid_login_error(self):
        return ValidationError(
            self.error_messages["invalid_login"],
            code="invalid_login",
            params={"username": self.username_field.verbose_name},
        )


class PasswordResetForm(forms.Form):
    email = forms.EmailField(
        label=_("Email"),
        max_length=254,
        widget=forms.EmailInput(attrs={"autocomplete": "email"}),
    )

    def send_mail(
        self,
        subject_template_name,
        email_template_name,
        context,
        from_email,
        to_email,
        html_email_template_name=None,
    ):
        """
        Send a django.core.mail.EmailMultiAlternatives to `to_email`.
        """
        subject = loader.render_to_string(subject_template_name, context)
        # Email subject *must not* contain newlines
        subject = "".join(subject.splitlines())
        body = loader.render_to_string(email_template_name, context)

        email_message = EmailMultiAlternatives(subject, body, from_email, [to_email])
        if html_email_template_name is not None:
            html_email = loader.render_to_string(html_email_template_name, context)
            email_message.attach_alternative(html_email, "text/html")

        email_message.send()

    def get_users(self, email):
        """Given an email, return matching user(s) who should receive a reset.

        This allows subclasses to more easily customize the default policies
        that prevent inactive users and users with unusable passwords from
        resetting their password.
        """
        email_field_name = UserModel.get_email_field_name()
        active_users = UserModel._default_manager.filter(
            **{
                "%s__iexact" % email_field_name: email,
                "is_active": True,
            }
        )
        return (
            u
            for u in active_users
            if u.has_usable_password()
            and _unicode_ci_compare(email, getattr(u, email_field_name))
        )

    def save(
        self,
        domain_override=None,
        subject_template_name="registration/password_reset_subject.txt",
        email_template_name="registration/password_reset_email.html",
        use_https=False,
        token_generator=default_token_generator,
        from_email=None,
        request=None,
        html_email_template_name=None,
        extra_email_context=None,
    ):
        """
        Generate a one-use only link for resetting password and send it to the
        user.
        """
        email = self.cleaned_data["email"]
        if not domain_override:
            current_site = get_current_site(request)
            site_name = current_site.name
            domain = current_site.domain
        else:
            site_name = domain = domain_override
        email_field_name = UserModel.get_email_field_name()
        for user in self.get_users(email):
            user_email = getattr(user, email_field_name)
            context = {
                "email": user_email,
                "domain": domain,
                "site_name": site_name,
                "uid": urlsafe_base64_encode(force_bytes(user.pk)),
                "user": user,
                "token": token_generator.make_token(user),
                "protocol": "https" if use_https else "http",
                **(extra_email_context or {}),
            }
            self.send_mail(
                subject_template_name,
                email_template_name,
                context,
                from_email,
                user_email,
                html_email_template_name=html_email_template_name,
            )


class SetPasswordForm(forms.Form):
    """
    A form that lets a user change set their password without entering the old
    password
    """

    error_messages = {
        "password_mismatch": _("The two password fields didn’t match."),
    }
    new_password1 = forms.CharField(
        label=_("New password"),
        widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}),
        strip=False,
        help_text=password_validation.password_validators_help_text_html(),
    )
    new_password2 = forms.CharField(
        label=_("New password confirmation"),
        strip=False,
        widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}),
    )

    def __init__(self, user, *args, **kwargs):
        self.user = user
        super().__init__(*args, **kwargs)

    def clean_new_password2(self):
        password1 = self.cleaned_data.get("new_password1")
        password2 = self.cleaned_data.get("new_password2")
        if password1 and password2 and password1 != password2:
            raise ValidationError(
                self.error_messages["password_mismatch"],
                code="password_mismatch",
            )
        password_validation.validate_password(password2, self.user)
        return password2

    def save(self, commit=True):
        password = self.cleaned_data["new_password1"]
        self.user.set_password(password)
        if commit:
            self.user.save()
        return self.user


class PasswordChangeForm(SetPasswordForm):
    """
    A form that lets a user change their password by entering their old
    password.
    """

    error_messages = {
        **SetPasswordForm.error_messages,
        "password_incorrect": _(
            "Your old password was entered incorrectly. Please enter it again."
        ),
    }
    old_password = forms.CharField(
        label=_("Old password"),
        strip=False,
        widget=forms.PasswordInput(
            attrs={"autocomplete": "current-password", "autofocus": True}
        ),
    )

    field_order = ["old_password", "new_password1", "new_password2"]

    def clean_old_password(self):
        """
        Validate that the old_password field is correct.
        """
        old_password = self.cleaned_data["old_password"]
        if not self.user.check_password(old_password):
            raise ValidationError(
                self.error_messages["password_incorrect"],
                code="password_incorrect",
            )
        return old_password


class AdminPasswordChangeForm(forms.Form):
    """
    A form used to change the password of a user in the admin interface.
    """

    error_messages = {
        "password_mismatch": _("The two password fields didn’t match."),
    }
    required_css_class = "required"
    password1 = forms.CharField(
        label=_("Password"),
        widget=forms.PasswordInput(
            attrs={"autocomplete": "new-password", "autofocus": True}
        ),
        strip=False,
        help_text=password_validation.password_validators_help_text_html(),
    )
    password2 = forms.CharField(
        label=_("Password (again)"),
        widget=forms.PasswordInput(attrs={"autocomplete": "new-password"}),
        strip=False,
        help_text=_("Enter the same password as before, for verification."),
    )

    def __init__(self, user, *args, **kwargs):
        self.user = user
        super().__init__(*args, **kwargs)

    def clean_password2(self):
        password1 = self.cleaned_data.get("password1")
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise ValidationError(
                self.error_messages["password_mismatch"],
                code="password_mismatch",
            )
        password_validation.validate_password(password2, self.user)
        return password2

    def save(self, commit=True):
        """Save the new password."""
        password = self.cleaned_data["password1"]
        self.user.set_password(password)
        if commit:
            self.user.save()
        return self.user

    @property
    def changed_data(self):
        data = super().changed_data
        for name in self.fields:
            if name not in data:
                return []
        return ["password"]

```


# tests/auth_tests/test_forms.py

```
import datetime
import re
from unittest import mock

from django.contrib.auth.forms import (
    AdminPasswordChangeForm,
    AuthenticationForm,
    PasswordChangeForm,
    PasswordResetForm,
    ReadOnlyPasswordHashField,
    ReadOnlyPasswordHashWidget,
    SetPasswordForm,
    UserChangeForm,
    UserCreationForm,
)
from django.contrib.auth.models import User
from django.contrib.auth.signals import user_login_failed
from django.contrib.sites.models import Site
from django.core import mail
from django.core.exceptions import ValidationError
from django.core.mail import EmailMultiAlternatives
from django.forms import forms
from django.forms.fields import CharField, Field, IntegerField
from django.test import SimpleTestCase, TestCase, override_settings
from django.utils import translation
from django.utils.text import capfirst
from django.utils.translation import gettext as _

from .models.custom_user import (
    CustomUser,
    CustomUserWithoutIsActiveField,
    ExtensionUser,
)
from .models.with_custom_email_field import CustomEmailField
from .models.with_integer_username import IntegerUsernameUser
from .settings import AUTH_TEMPLATES


class TestDataMixin:
    @classmethod
    def setUpTestData(cls):
        cls.u1 = User.objects.create_user(
            username="testclient", password="password", email="testclient@example.com"
        )
        cls.u2 = User.objects.create_user(
            username="inactive", password="password", is_active=False
        )
        cls.u3 = User.objects.create_user(username="staff", password="password")
        cls.u4 = User.objects.create(username="empty_password", password="")
        cls.u5 = User.objects.create(username="unmanageable_password", password="$")
        cls.u6 = User.objects.create(username="unknown_password", password="foo$bar")


class UserCreationFormTest(TestDataMixin, TestCase):
    def test_user_already_exists(self):
        data = {
            "username": "testclient",
            "password1": "test123",
            "password2": "test123",
        }
        form = UserCreationForm(data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form["username"].errors,
            [str(User._meta.get_field("username").error_messages["unique"])],
        )

    def test_invalid_data(self):
        data = {
            "username": "jsmith!",
            "password1": "test123",
            "password2": "test123",
        }
        form = UserCreationForm(data)
        self.assertFalse(form.is_valid())
        validator = next(
            v
            for v in User._meta.get_field("username").validators
            if v.code == "invalid"
        )
        self.assertEqual(form["username"].errors, [str(validator.message)])

    def test_password_verification(self):
        # The verification password is incorrect.
        data = {
            "username": "jsmith",
            "password1": "test123",
            "password2": "test",
        }
        form = UserCreationForm(data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form["password2"].errors, [str(form.error_messages["password_mismatch"])]
        )

    def test_both_passwords(self):
        # One (or both) passwords weren't given
        data = {"username": "jsmith"}
        form = UserCreationForm(data)
        required_error = [str(Field.default_error_messages["required"])]
        self.assertFalse(form.is_valid())
        self.assertEqual(form["password1"].errors, required_error)
        self.assertEqual(form["password2"].errors, required_error)

        data["password2"] = "test123"
        form = UserCreationForm(data)
        self.assertFalse(form.is_valid())
        self.assertEqual(form["password1"].errors, required_error)
        self.assertEqual(form["password2"].errors, [])

    @mock.patch("django.contrib.auth.password_validation.password_changed")
    def test_success(self, password_changed):
        # The success case.
        data = {
            "username": "jsmith@example.com",
            "password1": "test123",
            "password2": "test123",
        }
        form = UserCreationForm(data)
        self.assertTrue(form.is_valid())
        form.save(commit=False)
        self.assertEqual(password_changed.call_count, 0)
        u = form.save()
        self.assertEqual(password_changed.call_count, 1)
        self.assertEqual(repr(u), "<User: jsmith@example.com>")

    def test_unicode_username(self):
        data = {
            "username": "宝",
            "password1": "test123",
            "password2": "test123",
        }
        form = UserCreationForm(data)
        self.assertTrue(form.is_valid())
        u = form.save()
        self.assertEqual(u.username, "宝")

    def test_normalize_username(self):
        # The normalization happens in AbstractBaseUser.clean() and ModelForm
        # validation calls Model.clean().
        ohm_username = "testΩ"  # U+2126 OHM SIGN
        data = {
            "username": ohm_username,
            "password1": "pwd2",
            "password2": "pwd2",
        }
        form = UserCreationForm(data)
        self.assertTrue(form.is_valid())
        user = form.save()
        self.assertNotEqual(user.username, ohm_username)
        self.assertEqual(user.username, "testΩ")  # U+03A9 GREEK CAPITAL LETTER OMEGA

    def test_duplicate_normalized_unicode(self):
        """
        To prevent almost identical usernames, visually identical but differing
        by their unicode code points only, Unicode NFKC normalization should
        make appear them equal to Django.
        """
        omega_username = "iamtheΩ"  # U+03A9 GREEK CAPITAL LETTER OMEGA
        ohm_username = "iamtheΩ"  # U+2126 OHM SIGN
        self.assertNotEqual(omega_username, ohm_username)
        User.objects.create_user(username=omega_username, password="pwd")
        data = {
            "username": ohm_username,
            "password1": "pwd2",
            "password2": "pwd2",
        }
        form = UserCreationForm(data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form.errors["username"], ["A user with that username already exists."]
        )

    @override_settings(
        AUTH_PASSWORD_VALIDATORS=[
            {
                "NAME": (
                    "django.contrib.auth.password_validation."
                    "UserAttributeSimilarityValidator"
                )
            },
            {
                "NAME": (
                    "django.contrib.auth.password_validation.MinimumLengthValidator"
                ),
                "OPTIONS": {
                    "min_length": 12,
                },
            },
        ]
    )
    def test_validates_password(self):
        data = {
            "username": "testclient",
            "password1": "testclient",
            "password2": "testclient",
        }
        form = UserCreationForm(data)
        self.assertFalse(form.is_valid())
        self.assertEqual(len(form["password2"].errors), 2)
        self.assertIn(
            "The password is too similar to the username.", form["password2"].errors
        )
        self.assertIn(
            "This password is too short. It must contain at least 12 characters.",
            form["password2"].errors,
        )

    def test_custom_form(self):
        class CustomUserCreationForm(UserCreationForm):
            class Meta(UserCreationForm.Meta):
                model = ExtensionUser
                fields = UserCreationForm.Meta.fields + ("date_of_birth",)

        data = {
            "username": "testclient",
            "password1": "testclient",
            "password2": "testclient",
            "date_of_birth": "1988-02-24",
        }
        form = CustomUserCreationForm(data)
        self.assertTrue(form.is_valid())

    def test_custom_form_with_different_username_field(self):
        class CustomUserCreationForm(UserCreationForm):
            class Meta(UserCreationForm.Meta):
                model = CustomUser
                fields = ("email", "date_of_birth")

        data = {
            "email": "test@client222.com",
            "password1": "testclient",
            "password2": "testclient",
            "date_of_birth": "1988-02-24",
        }
        form = CustomUserCreationForm(data)
        self.assertTrue(form.is_valid())

    def test_custom_form_hidden_username_field(self):
        class CustomUserCreationForm(UserCreationForm):
            class Meta(UserCreationForm.Meta):
                model = CustomUserWithoutIsActiveField
                fields = ("email",)  # without USERNAME_FIELD

        data = {
            "email": "testclient@example.com",
            "password1": "testclient",
            "password2": "testclient",
        }
        form = CustomUserCreationForm(data)
        self.assertTrue(form.is_valid())

    def test_password_whitespace_not_stripped(self):
        data = {
            "username": "testuser",
            "password1": "   testpassword   ",
            "password2": "   testpassword   ",
        }
        form = UserCreationForm(data)
        self.assertTrue(form.is_valid())
        self.assertEqual(form.cleaned_data["password1"], data["password1"])
        self.assertEqual(form.cleaned_data["password2"], data["password2"])

    @override_settings(
        AUTH_PASSWORD_VALIDATORS=[
            {
                "NAME": (
                    "django.contrib.auth.password_validation."
                    "UserAttributeSimilarityValidator"
                )
            },
        ]
    )
    def test_password_help_text(self):
        form = UserCreationForm()
        self.assertEqual(
            form.fields["password1"].help_text,
            "<ul><li>"
            "Your password can’t be too similar to your other personal information."
            "</li></ul>",
        )

    @override_settings(
        AUTH_PASSWORD_VALIDATORS=[
            {
                "NAME": (
                    "django.contrib.auth.password_validation."
                    "UserAttributeSimilarityValidator"
                )
            },
        ]
    )
    def test_user_create_form_validates_password_with_all_data(self):
        """UserCreationForm password validation uses all of the form's data."""

        class CustomUserCreationForm(UserCreationForm):
            class Meta(UserCreationForm.Meta):
                model = User
                fields = ("username", "email", "first_name", "last_name")

        form = CustomUserCreationForm(
            {
                "username": "testuser",
                "password1": "testpassword",
                "password2": "testpassword",
                "first_name": "testpassword",
                "last_name": "lastname",
            }
        )
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form.errors["password2"],
            ["The password is too similar to the first name."],
        )

    def test_username_field_autocapitalize_none(self):
        form = UserCreationForm()
        self.assertEqual(
            form.fields["username"].widget.attrs.get("autocapitalize"), "none"
        )

    def test_html_autocomplete_attributes(self):
        form = UserCreationForm()
        tests = (
            ("username", "username"),
            ("password1", "new-password"),
            ("password2", "new-password"),
        )
        for field_name, autocomplete in tests:
            with self.subTest(field_name=field_name, autocomplete=autocomplete):
                self.assertEqual(
                    form.fields[field_name].widget.attrs["autocomplete"], autocomplete
                )


# To verify that the login form rejects inactive users, use an authentication
# backend that allows them.
@override_settings(
    AUTHENTICATION_BACKENDS=["django.contrib.auth.backends.AllowAllUsersModelBackend"]
)
class AuthenticationFormTest(TestDataMixin, TestCase):
    def test_invalid_username(self):
        # The user submits an invalid username.

        data = {
            "username": "jsmith_does_not_exist",
            "password": "test123",
        }
        form = AuthenticationForm(None, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form.non_field_errors(),
            [
                form.error_messages["invalid_login"]
                % {"username": User._meta.get_field("username").verbose_name}
            ],
        )

    def test_inactive_user(self):
        # The user is inactive.
        data = {
            "username": "inactive",
            "password": "password",
        }
        form = AuthenticationForm(None, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form.non_field_errors(), [str(form.error_messages["inactive"])]
        )

    # Use an authentication backend that rejects inactive users.
    @override_settings(
        AUTHENTICATION_BACKENDS=["django.contrib.auth.backends.ModelBackend"]
    )
    def test_inactive_user_incorrect_password(self):
        """An invalid login doesn't leak the inactive status of a user."""
        data = {
            "username": "inactive",
            "password": "incorrect",
        }
        form = AuthenticationForm(None, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form.non_field_errors(),
            [
                form.error_messages["invalid_login"]
                % {"username": User._meta.get_field("username").verbose_name}
            ],
        )

    def test_login_failed(self):
        signal_calls = []

        def signal_handler(**kwargs):
            signal_calls.append(kwargs)

        user_login_failed.connect(signal_handler)
        fake_request = object()
        try:
            form = AuthenticationForm(
                fake_request,
                {
                    "username": "testclient",
                    "password": "incorrect",
                },
            )
            self.assertFalse(form.is_valid())
            self.assertIs(signal_calls[0]["request"], fake_request)
        finally:
            user_login_failed.disconnect(signal_handler)

    def test_inactive_user_i18n(self):
        with self.settings(USE_I18N=True), translation.override(
            "pt-br", deactivate=True
        ):
            # The user is inactive.
            data = {
                "username": "inactive",
                "password": "password",
            }
            form = AuthenticationForm(None, data)
            self.assertFalse(form.is_valid())
            self.assertEqual(
                form.non_field_errors(), [str(form.error_messages["inactive"])]
            )

    # Use an authentication backend that allows inactive users.
    @override_settings(
        AUTHENTICATION_BACKENDS=[
            "django.contrib.auth.backends.AllowAllUsersModelBackend"
        ]
    )
    def test_custom_login_allowed_policy(self):
        # The user is inactive, but our custom form policy allows them to log in.
        data = {
            "username": "inactive",
            "password": "password",
        }

        class AuthenticationFormWithInactiveUsersOkay(AuthenticationForm):
            def confirm_login_allowed(self, user):
                pass

        form = AuthenticationFormWithInactiveUsersOkay(None, data)
        self.assertTrue(form.is_valid())

        # Raise a ValidationError in the form to disallow some logins according
        # to custom logic.
        class PickyAuthenticationForm(AuthenticationForm):
            def confirm_login_allowed(self, user):
                if user.username == "inactive":
                    raise ValidationError("This user is disallowed.")
                raise ValidationError("Sorry, nobody's allowed in.")

        form = PickyAuthenticationForm(None, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(form.non_field_errors(), ["This user is disallowed."])

        data = {
            "username": "testclient",
            "password": "password",
        }
        form = PickyAuthenticationForm(None, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(form.non_field_errors(), ["Sorry, nobody's allowed in."])

    def test_success(self):
        # The success case
        data = {
            "username": "testclient",
            "password": "password",
        }
        form = AuthenticationForm(None, data)
        self.assertTrue(form.is_valid())
        self.assertEqual(form.non_field_errors(), [])

    def test_unicode_username(self):
        User.objects.create_user(username="Σαρα", password="pwd")
        data = {
            "username": "Σαρα",
            "password": "pwd",
        }
        form = AuthenticationForm(None, data)
        self.assertTrue(form.is_valid())
        self.assertEqual(form.non_field_errors(), [])

    @override_settings(AUTH_USER_MODEL="auth_tests.CustomEmailField")
    def test_username_field_max_length_matches_user_model(self):
        self.assertEqual(CustomEmailField._meta.get_field("username").max_length, 255)
        data = {
            "username": "u" * 255,
            "password": "pwd",
            "email": "test@example.com",
        }
        CustomEmailField.objects.create_user(**data)
        form = AuthenticationForm(None, data)
        self.assertEqual(form.fields["username"].max_length, 255)
        self.assertEqual(form.fields["username"].widget.attrs.get("maxlength"), 255)
        self.assertEqual(form.errors, {})

    @override_settings(AUTH_USER_MODEL="auth_tests.IntegerUsernameUser")
    def test_username_field_max_length_defaults_to_254(self):
        self.assertIsNone(IntegerUsernameUser._meta.get_field("username").max_length)
        data = {
            "username": "0123456",
            "password": "password",
        }
        IntegerUsernameUser.objects.create_user(**data)
        form = AuthenticationForm(None, data)
        self.assertEqual(form.fields["username"].max_length, 254)
        self.assertEqual(form.fields["username"].widget.attrs.get("maxlength"), 254)
        self.assertEqual(form.errors, {})

    def test_username_field_label(self):
        class CustomAuthenticationForm(AuthenticationForm):
            username = CharField(label="Name", max_length=75)

        form = CustomAuthenticationForm()
        self.assertEqual(form["username"].label, "Name")

    def test_username_field_label_not_set(self):
        class CustomAuthenticationForm(AuthenticationForm):
            username = CharField()

        form = CustomAuthenticationForm()
        username_field = User._meta.get_field(User.USERNAME_FIELD)
        self.assertEqual(
            form.fields["username"].label, capfirst(username_field.verbose_name)
        )

    def test_username_field_autocapitalize_none(self):
        form = AuthenticationForm()
        self.assertEqual(
            form.fields["username"].widget.attrs.get("autocapitalize"), "none"
        )

    def test_username_field_label_empty_string(self):
        class CustomAuthenticationForm(AuthenticationForm):
            username = CharField(label="")

        form = CustomAuthenticationForm()
        self.assertEqual(form.fields["username"].label, "")

    def test_password_whitespace_not_stripped(self):
        data = {
            "username": "testuser",
            "password": " pass ",
        }
        form = AuthenticationForm(None, data)
        form.is_valid()  # Not necessary to have valid credentails for the test.
        self.assertEqual(form.cleaned_data["password"], data["password"])

    @override_settings(AUTH_USER_MODEL="auth_tests.IntegerUsernameUser")
    def test_integer_username(self):
        class CustomAuthenticationForm(AuthenticationForm):
            username = IntegerField()

        user = IntegerUsernameUser.objects.create_user(username=0, password="pwd")
        data = {
            "username": 0,
            "password": "pwd",
        }
        form = CustomAuthenticationForm(None, data)
        self.assertTrue(form.is_valid())
        self.assertEqual(form.cleaned_data["username"], data["username"])
        self.assertEqual(form.cleaned_data["password"], data["password"])
        self.assertEqual(form.errors, {})
        self.assertEqual(form.user_cache, user)

    def test_get_invalid_login_error(self):
        error = AuthenticationForm().get_invalid_login_error()
        self.assertIsInstance(error, ValidationError)
        self.assertEqual(
            error.message,
            "Please enter a correct %(username)s and password. Note that both "
            "fields may be case-sensitive.",
        )
        self.assertEqual(error.code, "invalid_login")
        self.assertEqual(error.params, {"username": "username"})

    def test_html_autocomplete_attributes(self):
        form = AuthenticationForm()
        tests = (
            ("username", "username"),
            ("password", "current-password"),
        )
        for field_name, autocomplete in tests:
            with self.subTest(field_name=field_name, autocomplete=autocomplete):
                self.assertEqual(
                    form.fields[field_name].widget.attrs["autocomplete"], autocomplete
                )

    def test_no_password(self):
        data = {"username": "username"}
        form = AuthenticationForm(None, data)
        self.assertIs(form.is_valid(), False)
        self.assertEqual(
            form["password"].errors, [Field.default_error_messages["required"]]
        )


class SetPasswordFormTest(TestDataMixin, TestCase):
    def test_password_verification(self):
        # The two new passwords do not match.
        user = User.objects.get(username="testclient")
        data = {
            "new_password1": "abc123",
            "new_password2": "abc",
        }
        form = SetPasswordForm(user, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form["new_password2"].errors,
            [str(form.error_messages["password_mismatch"])],
        )

    @mock.patch("django.contrib.auth.password_validation.password_changed")
    def test_success(self, password_changed):
        user = User.objects.get(username="testclient")
        data = {
            "new_password1": "abc123",
            "new_password2": "abc123",
        }
        form = SetPasswordForm(user, data)
        self.assertTrue(form.is_valid())
        form.save(commit=False)
        self.assertEqual(password_changed.call_count, 0)
        form.save()
        self.assertEqual(password_changed.call_count, 1)

    @override_settings(
        AUTH_PASSWORD_VALIDATORS=[
            {
                "NAME": (
                    "django.contrib.auth.password_validation."
                    "UserAttributeSimilarityValidator"
                )
            },
            {
                "NAME": (
                    "django.contrib.auth.password_validation.MinimumLengthValidator"
                ),
                "OPTIONS": {
                    "min_length": 12,
                },
            },
        ]
    )
    def test_validates_password(self):
        user = User.objects.get(username="testclient")
        data = {
            "new_password1": "testclient",
            "new_password2": "testclient",
        }
        form = SetPasswordForm(user, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(len(form["new_password2"].errors), 2)
        self.assertIn(
            "The password is too similar to the username.", form["new_password2"].errors
        )
        self.assertIn(
            "This password is too short. It must contain at least 12 characters.",
            form["new_password2"].errors,
        )

    def test_no_password(self):
        user = User.objects.get(username="testclient")
        data = {"new_password1": "new-password"}
        form = SetPasswordForm(user, data)
        self.assertIs(form.is_valid(), False)
        self.assertEqual(
            form["new_password2"].errors, [Field.default_error_messages["required"]]
        )
        form = SetPasswordForm(user, {})
        self.assertIs(form.is_valid(), False)
        self.assertEqual(
            form["new_password1"].errors, [Field.default_error_messages["required"]]
        )
        self.assertEqual(
            form["new_password2"].errors, [Field.default_error_messages["required"]]
        )

    def test_password_whitespace_not_stripped(self):
        user = User.objects.get(username="testclient")
        data = {
            "new_password1": "   password   ",
            "new_password2": "   password   ",
        }
        form = SetPasswordForm(user, data)
        self.assertTrue(form.is_valid())
        self.assertEqual(form.cleaned_data["new_password1"], data["new_password1"])
        self.assertEqual(form.cleaned_data["new_password2"], data["new_password2"])

    @override_settings(
        AUTH_PASSWORD_VALIDATORS=[
            {
                "NAME": (
                    "django.contrib.auth.password_validation."
                    "UserAttributeSimilarityValidator"
                )
            },
            {
                "NAME": (
                    "django.contrib.auth.password_validation.MinimumLengthValidator"
                ),
                "OPTIONS": {
                    "min_length": 12,
                },
            },
        ]
    )
    def test_help_text_translation(self):
        french_help_texts = [
            "Votre mot de passe ne peut pas trop ressembler à vos autres informations "
            "personnelles.",
            "Votre mot de passe doit contenir au minimum 12 caractères.",
        ]
        form = SetPasswordForm(self.u1)
        with translation.override("fr"):
            html = form.as_p()
            for french_text in french_help_texts:
                self.assertIn(french_text, html)

    def test_html_autocomplete_attributes(self):
        form = SetPasswordForm(self.u1)
        tests = (
            ("new_password1", "new-password"),
            ("new_password2", "new-password"),
        )
        for field_name, autocomplete in tests:
            with self.subTest(field_name=field_name, autocomplete=autocomplete):
                self.assertEqual(
                    form.fields[field_name].widget.attrs["autocomplete"], autocomplete
                )


class PasswordChangeFormTest(TestDataMixin, TestCase):
    def test_incorrect_password(self):
        user = User.objects.get(username="testclient")
        data = {
            "old_password": "test",
            "new_password1": "abc123",
            "new_password2": "abc123",
        }
        form = PasswordChangeForm(user, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form["old_password"].errors,
            [str(form.error_messages["password_incorrect"])],
        )

    def test_password_verification(self):
        # The two new passwords do not match.
        user = User.objects.get(username="testclient")
        data = {
            "old_password": "password",
            "new_password1": "abc123",
            "new_password2": "abc",
        }
        form = PasswordChangeForm(user, data)
        self.assertFalse(form.is_valid())
        self.assertEqual(
            form["new_password2"].errors,
            [str(form.error_messages["password_mismatch"])],
        )

    @mock.patch("django.contrib.auth.password_validation.password_changed")
    def test_success(self, password_changed):
        # The success case.
        user = User.objects.get(username="testclient")
        data = {
            "old_password": "password",
            "new_password1": "abc123",
            "new_password2": "abc123",
        }
        form = PasswordChangeForm(user, data)
        self.assertTrue(form.is_valid())
        form.save(commit=False)
        self.assertEqual(password_changed.call_count, 0)
        form.save()
        self.assertEqual(password_changed.call_count, 1)

    def test_field_order(self):
        # Regression test - check the order of fields:
        user = User.objects.get(username="testclient")
        self.assertEqual(
            list(PasswordChangeForm(user, {}).fields),
            ["old_password", "new_password1", "new_password2"],
        )

    def test_password_whitespace_not_stripped(self):
        user = User.objects.get(username="testclient")
        user.set_password("   oldpassword   ")
        data = {
            "old_password": "   oldpassword   ",
            "new_password1": " pass ",
            "new_password2": " pass ",
        }
        form = PasswordChangeForm(user, data)
        self.assertTrue(form.is_valid())
        self.assertEqual(form.cleaned_data["old_password"], data["old_password"])
        self.assertEqual(form.cleaned_data["new_password1"], data["new_password1"])
        self.assertEqual(form.cleaned_data["new_password2"], data["new_password2"])

    def test_html_autocomplete_attributes(self):
        user = User.objects.get(username="testclient")
        form = PasswordChangeForm(user)
        self.assertEqual(
            form.fields["old_password"].widget.attrs["autocomplete"], "current-password"
        )


class UserChangeFormTest(TestDataMixin, TestCase):
    def test_username_validity(self):
        user = User.objects.get(username="testclient")
        data = {"username": "not valid"}
        form = UserChangeForm(data, instance=user)
        self.assertFalse(form.is_valid())
        validator = next(
            v
            for v in User._meta.get_field("username").validators
            if v.code == "invalid"
        )
        self.assertEqual(form["username"].errors, [str(validator.message)])

    def test_bug_14242(self):
        # A regression test, introduce by adding an optimization for the
        # UserChangeForm.

        class MyUserForm(UserChangeForm):
            def __init__(self, *args, **kwargs):
                super().__init__(*args, **kwargs)
                self.fields[
                    "groups"
                ].help_text = "These groups give users different permissions"

            class Meta(UserChangeForm.Meta):
                fields = ("groups",)

        # Just check we can create it
        MyUserForm({})

    def test_unusable_password(self):
        user = User.objects.get(username="empty_password")
        user.set_unusable_password()
        user.save()
        form = UserChangeForm(instance=user)
        self.assertIn(_("No password set."), form.as_table())

    def test_bug_17944_empty_password(self):
        user = User.objects.get(username="empty_password")
        form = UserChangeForm(instance=user)
        self.assertIn(_("No password set."), form.as_table())

    def test_bug_17944_unmanageable_password(self):
        user = User.objects.get(username="unmanageable_password")
        form = UserChangeForm(instance=user)
        self.assertIn(
            _("Invalid password format or unknown hashing algorithm."), form.as_table()
        )

    def test_bug_17944_unknown_password_algorithm(self):
        user = User.objects.get(username="unknown_password")
        form = UserChangeForm(instance=user)
        self.assertIn(
            _("Invalid password format or unknown hashing algorithm."), form.as_table()
        )

    def test_bug_19133(self):
        "The change form does not return the password value"
        # Use the form to construct the POST data
        user = User.objects.get(username="testclient")
        form_for_data = UserChangeForm(instance=user)
        post_data = form_for_data.initial

        # The password field should be readonly, so anything
        # posted here should be ignored; the form will be
        # valid, and give back the 'initial' value for the
        # password field.
        post_data["password"] = "new password"
        form = UserChangeForm(instance=user, data=post_data)

        self.assertTrue(form.is_valid())
        # original hashed password contains $
        self.assertIn("$", form.cleaned_data["password"])

    def test_bug_19349_bound_password_field(self):
        user = User.objects.get(username="testclient")
        form = UserChangeForm(data={}, instance=user)
        # When rendering the bound password field,
        # ReadOnlyPasswordHashWidget needs the initial
        # value to render correctly
        self.assertEqual(form.initial["password"], form["password"].value())

    def test_custom_form(self):
        class CustomUserChangeForm(UserChangeForm):
            class Meta(UserChangeForm.Meta):
                model = ExtensionUser
                fields = (
                    "username",
                    "password",
                    "date_of_birth",
                )

        user = User.objects.get(username="testclient")
        data = {
            "username": "testclient",
            "password": "testclient",
            "date_of_birth": "1998-02-24",
        }
        form = CustomUserChangeForm(data, instance=user)
        self.assertTrue(form.is_valid())
        form.save()
        self.assertEqual(form.cleaned_data["username"], "testclient")
        self.assertEqual(form.cleaned_data["date_of_birth"], datetime.date(1998, 2, 24))

    def test_password_excluded(self):
        class UserChangeFormWithoutPassword(UserChangeForm):
            password = None

            class Meta:
                model = User
                exclude = ["password"]

        form = UserChangeFormWithoutPassword()
        self.assertNotIn("password", form.fields)

    def test_username_field_autocapitalize_none(self):
        form = UserChangeForm()
        self.assertEqual(
            form.fields["username"].widget.attrs.get("autocapitalize"), "none"
        )

    def test_password_help_text(self):
        user = User.objects.get(username="testclient")
        form = UserChangeForm(instance=user)
        self.assertIn(
            f'href="../../{user.pk}/password/"',
            form.fields["password"].help_text,
        )


@override_settings(TEMPLATES=AUTH_TEMPLATES)
class PasswordResetFormTest(TestDataMixin, TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        # This cleanup is necessary because contrib.sites cache
        # makes tests interfere with each other, see #11505
        Site.objects.clear_cache()

    def create_dummy_user(self):
        """
        Create a user and return a tuple (user_object, username, email).
        """
        username = "jsmith"
        email = "jsmith@example.com"
        user = User.objects.create_user(username, email, "test123")
        return (user, username, email)

    def test_invalid_email(self):
        data = {"email": "not valid"}
        form = PasswordResetForm(data)
        self.assertFalse(form.is_valid())
        self.assertEqual(form["email"].errors, [_("Enter a valid email address.")])

    def test_user_email_unicode_collision(self):
        User.objects.create_user("mike123", "mike@example.org", "test123")
        User.objects.create_user("mike456", "mıke@example.org", "test123")
        data = {"email": "mıke@example.org"}
        form = PasswordResetForm(data)
        self.assertTrue(form.is_valid())
        form.save()
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].to, ["mıke@example.org"])

    def test_user_email_domain_unicode_collision(self):
        User.objects.create_user("mike123", "mike@ixample.org", "test123")
        User.objects.create_user("mike456", "mike@ıxample.org", "test123")
        data = {"email": "mike@ıxample.org"}
        form = PasswordResetForm(data)
        self.assertTrue(form.is_valid())
        form.save()
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].to, ["mike@ıxample.org"])

    def test_user_email_unicode_collision_nonexistent(self):
        User.objects.create_user("mike123", "mike@example.org", "test123")
        data = {"email": "mıke@example.org"}
        form = PasswordResetForm(data)
        self.assertTrue(form.is_valid())
        form.save()
        self.assertEqual(len(mail.outbox), 0)

    def test_user_email_domain_unicode_collision_nonexistent(self):
        User.objects.create_user("mike123", "mike@ixample.org", "test123")
        data = {"email": "mike@ıxample.org"}
        form = PasswordResetForm(data)
        self.assertTrue(form.is_valid())
        form.save()
        self.assertEqual(len(mail.outbox), 0)

    def test_nonexistent_email(self):
        """
        Test nonexistent email address. This should not fail because it would
        expose information about registered users.
        """
        data = {"email": "foo@bar.com"}
        form = PasswordResetForm(data)
        self.assertTrue(form.is_valid())
        self.assertEqual(len(mail.outbox), 0)

    def test_cleaned_data(self):
        (user, username, email) = self.create_dummy_user()
        data = {"email": email}
        form = PasswordResetForm(data)
        self.assertTrue(form.is_valid())
        form.save(domain_override="example.com")
        self.assertEqual(form.cleaned_data["email"], email)
        self.assertEqual(len(mail.outbox), 1)

    def test_custom_email_subject(self):
        data = {"email": "testclient@example.com"}
        form = PasswordResetForm(data)
        self.assertTrue(form.is_valid())
        # Since we're not providing a request object, we must provide a
        # domain_override to prevent the save operation from failing in the
        # potential case where contrib.sites is not installed. Refs #16412.
        form.save(domain_override="example.com")
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].subject, "Custom password reset on example.com")

    def test_custom_email_constructor(self):
        data = {"email": "testclient@example.com"}

        class CustomEmailPasswordResetForm(PasswordResetForm):
            def send_mail(
                self,
                subject_template_name,
                email_template_name,
                context,
                from_email,
                to_email,
                html_email_template_name=None,
            ):
                EmailMultiAlternatives(
                    "Forgot your password?",
                    "Sorry to hear you forgot your password.",
                    None,
                    [to_email],
                    ["site_monitor@example.com"],
                    headers={"Reply-To": "webmaster@example.com"},
                    alternatives=[
                        ("Really sorry to hear you forgot your password.", "text/html")
                    ],
                ).send()

        form = CustomEmailPasswordResetForm(data)
        self.assertTrue(form.is_valid())
        # Since we're not providing a request object, we must provide a
        # domain_override to prevent the save operation from failing in the
        # potential case where contrib.sites is not installed. Refs #16412.
        form.save(domain_override="example.com")
        self.assertEqual(len(mail.outbox), 1)
        self.assertEqual(mail.outbox[0].subject, "Forgot your password?")
        self.assertEqual(mail.outbox[0].bcc, ["site_monitor@example.com"])
        self.assertEqual(mail.outbox[0].content_subtype, "plain")

    def test_preserve_username_case(self):
        """
        Preserve the case of the user name (before the @ in the email address)
        when creating a user (#5605).
        """
        user = User.objects.create_user("forms_test2", "tesT@EXAMple.com", "test")
        self.assertEqual(user.email, "tesT@example.com")
        user = User.objects.create_user("forms_test3", "tesT", "test")
        self.assertEqual(user.email, "tesT")

    def test_inactive_user(self):
        """
        Inactive user cannot receive password reset email.
        """
        (user, username, email) = self.create_dummy_user()
      
```


# The last commit

```
9d540a3f34 SWE-bench



 .editorconfig                                               |   0
 .eslintignore                                               |   0
 .eslintrc                                                   |   0
 .git-blame-ignore-revs                                      |   0
 .gitattributes                                              |   0
 .github/CODE_OF_CONDUCT.md                                  |   0
 .github/FUNDING.yml                                         |   0
 .github/SECURITY.md                                         |   0
 .github/workflows/benchmark.yml                             |   0
 .github/workflows/docs.yml                                  |   0
 .github/workflows/linters.yml                               |   0
 .github/workflows/new_contributor_pr.yml                    |   0
 .github/workflows/schedule_tests.yml                        |   0
 .github/workflows/schedules.yml                             |   0
 .github/workflows/tests.yml                                 |   0
 .gitignore                                                  |   0
 .pre-commit-config.yaml                                     |   0
 .readthedocs.yml                                            |   0
 .tx/config                                                  |   0
 AUTHORS                                                     |   0
 CONTRIBUTING.rst                                            |   0
 Gruntfile.js                                                |   0
 INSTALL                                                     |   0
 LICENSE                                                     |   0
 LICENSE.python                                              |   0
 MANIFEST.in                                                 |   0
 README.rst                                                  |   0
 django/__init__.py                                          |   0
 django/__main__.py                                          |   0
 django/apps/__init__.py                                     |   0
 django/apps/config.py                                       |   0
 django/apps/registry.py                                     |   0
 django/conf/__init__.py                                     |   0
 django/conf/app_template/__init__.py-tpl                    |   0
 django/conf/app_template/admin.py-tpl                       |   0
 django/conf/app_template/apps.py-tpl                        |   0
 django/conf/app_template/migrations/__init__.py-tpl         |   0
 django/conf/app_template/models.py-tpl                      |   0
 django/conf/app_template/tests.py-tpl                       |   0
 django/conf/app_template/views.py-tpl                       |   0
 django/conf/global_settings.py                              |   0
 django/conf/locale/__init__.py                              |   0
 django/conf/locale/af/LC_MESSAGES/django.mo                 | Bin
 django/conf/locale/af/LC_MESSAGES/django.po                 |   0
 django/conf/locale/ar/LC_MESSAGES/django.mo                 | Bin
 django/conf/locale/ar/LC_MESSAGES/django.po                 |   0
 django/conf/locale/ar/__init__.py                           |   0
 django/conf/locale/ar/formats.py                            |   0
 django/conf/locale/ar_DZ/LC_MESSAGES/django.mo              | Bin
 django/conf/locale/ar_DZ/LC_MESSAGES/django.po              |   0
 django/conf/locale/ar_DZ/__init__.py                        |   0
 django/conf/locale/ar_DZ/formats.py                         |   0
 django/conf/locale/ast/LC_MESSAGES/django.mo                | Bin
 django/conf/locale/ast/LC_MESSAGES/django.po                |   0
 django/conf/locale/az/LC_MESSAGES/django.mo                 | Bin
 django/conf/locale/az/LC_MESSAGES/django.po                 |   0
```

```diff
diff --git a/.editorconfig b/.editorconfig
old mode 100644
new mode 100755
diff --git a/.eslintignore b/.eslintignore
old mode 100644
new mode 100755
diff --git a/.eslintrc b/.eslintrc
old mode 100644
new mode 100755
diff --git a/.git-blame-ignore-revs b/.git-blame-ignore-revs
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.github/CODE_OF_CONDUCT.md b/.github/CODE_OF_CONDUCT.md
old mode 100644
new mode 100755
diff --git a/.github/FUNDING.yml b/.github/FUNDING.yml
old mode 100644
new mode 100755
diff --git a/.github/SECURITY.md b/.github/SECURITY.md
old mode 100644
new mode 100755
diff --git a/.github/workflows/benchmark.yml b/.github/workflows/benchmark.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/docs.yml b/.github/workflows/docs.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/linters.yml b/.github/workflows/linters.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/new_contributor_pr.yml b/.github/workflows/new_contributor_pr.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/schedule_tests.yml b/.github/workflows/schedule_tests.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/schedules.yml b/.github/workflows/schedules.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/tests.yml b/.github/workflows/tests.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.pre-commit-config.yaml b/.pre-commit-config.yaml
old mode 100644
new mode 100755
diff --git a/.readthedocs.yml b/.readthedocs.yml
old mode 100644
new mode 100755
diff --git a/.tx/config b/.tx/config
old mode 100644
new mode 100755
diff --git a/AUTHORS b/AUTHORS
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.rst b/CONTRIBUTING.rst
old mode 100644
new mode 100755
diff --git a/Gruntfile.js b/Gruntfile.js
old mode 100644
new mode 100755
diff --git a/INSTALL b/INSTALL
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/LICENSE.python b/LICENSE.python
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/django/__init__.py b/django/__init__.py
old mode 100644
new mode 100755
diff --git a/django/__main__.py b/django/__main__.py
old mode 100644
new mode 100755
diff --git a/django/apps/__init__.py b/django/apps/__init__.py
old mode 100644
new mode 100755
diff --git a/django/apps/config.py b/django/apps/config.py
old mode 100644
new mode 100755
diff --git a/django/apps/registry.py b/django/apps/registry.py
old mode 100644
new mode 100755
diff --git a/django/conf/__init__.py b/django/conf/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/__init__.py-tpl b/django/conf/app_template/__init__.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/admin.py-tpl b/django/conf/app_template/admin.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/apps.py-tpl b/django/conf/app_template/apps.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/migrations/__init__.py-tpl b/django/conf/app_template/migrations/__init__.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/models.py-tpl b/django/conf/app_template/models.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/tests.py-tpl b/django/conf/app_template/tests.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/views.py-tpl b/django/conf/app_template/views.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/global_settings.py b/django/conf/global_settings.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/__init__.py b/django/conf/locale/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/af/LC_MESSAGES/django.mo b/django/conf/locale/af/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/af/LC_MESSAGES/django.po b/django/conf/locale/af/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/LC_MESSAGES/django.mo b/django/conf/locale/ar/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/LC_MESSAGES/django.po b/django/conf/locale/ar/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/__init__.py b/django/conf/locale/ar/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/formats.py b/django/conf/locale/ar/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/LC_MESSAGES/django.mo b/django/conf/locale/ar_DZ/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/LC_MESSAGES/django.po b/django/conf/locale/ar_DZ/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/__init__.py b/django/conf/locale/ar_DZ/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/formats.py b/django/conf/locale/ar_DZ/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ast/LC_MESSAGES/django.mo b/django/conf/locale/ast/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ast/LC_MESSAGES/django.po b/django/conf/locale/ast/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/LC_MESSAGES/django.mo b/django/conf/locale/az/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/LC_MESSAGES/django.po b/django/conf/locale/az/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/__init__.py b/django/conf/locale/az/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/formats.py b/django/conf/locale/az/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/be/LC_MESSAGES/django.mo b/django/conf/locale/be/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/be/LC_MESSAGES/django.po b/django/conf/locale/be/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/LC_MESSAGES/django.mo b/django/conf/locale/bg/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/LC_MESSAGES/django.po b/django/conf/locale/bg/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/__init__.py b/django/conf/locale/bg/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/formats.py b/django/conf/locale/bg/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/LC_MESSAGES/django.mo b/django/conf/locale/bn/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/LC_MESSAGES/django.po b/django/conf/locale/bn/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/__init__.py b/django/conf/locale/bn/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/formats.py b/django/conf/locale/bn/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/br/LC_MESSAGES/django.mo b/django/conf/locale/br/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/br/LC_MESSAGES/django.po b/django/conf/locale/br/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/LC_MESSAGES/django.mo b/django/conf/locale/bs/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/LC_MESSAGES/django.po b/django/conf/locale/bs/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/__init__.py b/django/conf/locale/bs/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/formats.py b/django/conf/locale/bs/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/LC_MESSAGES/django.mo b/django/conf/locale/ca/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/LC_MESSAGES/django.po b/django/conf/locale/ca/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/__init__.py b/django/conf/locale/ca/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/formats.py b/django/conf/locale/ca/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ckb/__init__.py b/django/conf/locale/ckb/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ckb/formats.py b/django/conf/locale/ckb/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/LC_MESSAGES/django.mo b/django/conf/locale/cs/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/LC_MESSAGES/django.po b/django/conf/locale/cs/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/__init__.py b/django/conf/locale/cs/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/formats.py b/django/conf/locale/cs/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/LC_MESSAGES/django.mo b/django/conf/locale/cy/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/LC_MESSAGES/django.po b/django/conf/locale/cy/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/__init__.py b/django/conf/locale/cy/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/formats.py b/django/conf/locale/cy/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/LC_MESSAGES/django.mo b/django/conf/locale/da/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/LC_MESSAGES/django.po b/django/conf/locale/da/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/__init__.py b/django/conf/locale/da/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/formats.py b/django/conf/locale/da/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/LC_MESSAGES/django.mo b/django/conf/locale/de/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/LC_MESSAGES/django.po b/django/conf/locale/de/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/__init__.py b/django/conf/locale/de/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/formats.py b/django/conf/locale/de/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de_CH/__init__.py b/django/conf/locale/de_CH/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de_CH/formats.py b/django/conf/locale/de_CH/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/dsb/LC_MESSAGES/django.mo b/django/conf/locale/dsb/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/dsb/LC_MESSAGES/django.po b/django/conf/locale/dsb/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/LC_MESSAGES/django.mo b/django/conf/locale/el/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/LC_MESSAGES/django.po b/django/conf/locale/el/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/__init__.py b/django/conf/locale/el/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/formats.py b/django/conf/locale/el/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/LC_MESSAGES/django.mo b/django/conf/locale/en/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/LC_MESSAGES/django.po b/django/conf/locale/en/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/__init__.py b/django/conf/locale/en/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/formats.py b/django/conf/locale/en/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/LC_MESSAGES/django.mo b/django/conf/locale/en_AU/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/LC_MESSAGES/django.po b/django/conf/locale/en_AU/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/__init__.py b/django/conf/locale/en_AU/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/formats.py b/django/conf/locale/en_AU/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/LC_MESSAGES/django.mo b/django/conf/locale/en_GB/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/LC_MESSAGES/django.po b/django/conf/locale/en_GB/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/__init__.py b/django/conf/locale/en_GB/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/formats.py b/django/conf/locale/en_GB/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/LC_MESSAGES/django.mo b/django/conf/locale/eo/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/LC_MESSAGES/django.po b/django/conf/locale/eo/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/__init__.py b/django/conf/locale/eo/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/formats.py b/django/conf/locale/eo/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/LC_MESSAGES/django.mo b/django/conf/locale/es/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/LC_MESSAGES/django.po b/django/conf/locale/es/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/__init__.py b/django/conf/locale/es/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/formats.py b/django/conf/locale/es/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/LC_MESSAGES/django.mo b/django/conf/locale/es_AR/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/LC_MESSAGES/django.po b/django/conf/locale/es_AR/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/__init__.py b/django/conf/locale/es_AR/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/formats.py b/django/conf/locale/es_AR/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_CO/LC_MESSAGES/django.mo b/django/conf/locale/es_CO/LC_MESSAGES/django.mo
old mode 100644
new mod
```
````

### `direct-check.log`

```
check: ./tests/runtests.py auth_tests.test_forms
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 87 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.......................................................................................
----------------------------------------------------------------------
Ran 87 tests in 0.386s

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
scope: django/contrib/auth/forms.py tests/auth_tests/test_forms.py
changed: django/contrib/auth/forms.py +3 -1
changed: tests/auth_tests/test_forms.py +8 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/contrib/auth/forms.py b/django/contrib/auth/forms.py
index b3cfc6723c..523830e8ee 100755
--- a/django/contrib/auth/forms.py
+++ b/django/contrib/auth/forms.py
@@ -163,7 +163,9 @@ class UserChangeForm(forms.ModelForm):
         super().__init__(*args, **kwargs)
         password = self.fields.get("password")
         if password:
-            password.help_text = password.help_text.format("../password/")
+            password.help_text = password.help_text.format(
+                f"../../{self.instance.pk}/password/"
+            )
         user_permissions = self.fields.get("user_permissions")
         if user_permissions:
             user_permissions.queryset = user_permissions.queryset.select_related(
diff --git a/tests/auth_tests/test_forms.py b/tests/auth_tests/test_forms.py
index 3bacd7a9fb..505cb6c756 100755
--- a/tests/auth_tests/test_forms.py
+++ b/tests/auth_tests/test_forms.py
@@ -931,6 +931,14 @@ class UserChangeFormTest(TestDataMixin, TestCase):
             form.fields["username"].widget.attrs.get("autocapitalize"), "none"
         )
 
+    def test_password_help_text(self):
+        user = User.objects.get(username="testclient")
+        form = UserChangeForm(instance=user)
+        self.assertIn(
+            f'href="../../{user.pk}/password/"',
+            form.fields["password"].help_text,
+        )
+
 
 @override_settings(TEMPLATES=AUTH_TEMPLATES)
 class PasswordResetFormTest(TestDataMixin, TestCase):
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
check: ./tests/runtests.py auth_tests.test_forms
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 87 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.......................................................................................
----------------------------------------------------------------------
Ran 87 tests in 0.199s

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
scope: django/contrib/auth/forms.py tests/auth_tests/test_forms.py
changed: django/contrib/auth/forms.py +3 -1
changed: tests/auth_tests/test_forms.py +8 -0
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
# Notes, run 2026-11-06T113031

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Accessing UserAdmin via to_field leads to link to PasswordResetForm being broken (404)
Description
	 
		(last modified by Simon Kern)
	 
Accessing the UserAdmin via another model's Admin that has a reference to User (with to_field set, e.g., to_field="uuid") leads to the UserAdmin being accessed via an url that looks similar to this one:
.../user/22222222-3333-4444-5555-666677778888/change/?_to_field=uuid
However the underlying form looks like this: 
Code highlighting:
class UserChangeForm(forms.ModelForm):
	password = ReadOnlyPasswordHashField(
		label=_("Password"),
		help_text=_(
			"Raw passwords are not stored, so there is no way to see this "
			"user’s password, but you can change the password using "
			'<a href="{}">this form</a>.'
		),
	)
	...
	...
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		password = self.fields.get("password")
		if password:
			password.help_text = password.help_text.format("../password/")
	...
	...
This results in the link to the PasswordResetForm being wrong and thus ending up in a 404. If we drop the assumption that UserAdmin is always accessed via its pk, then we're good to go. It's as simple as replacing password.help_text = password.help_text.format("../password/") with password.help_text = password.help_text.format(f"../../{self.instance.pk}/password/")
I've opened a pull request on GitHub for this Ticket, please see:
​PR


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
9d540a3f34 SWE-bench



 .editorconfig                                               |   0
 .eslintignore                                               |   0
 .eslintrc                                                   |   0
 .git-blame-ignore-revs                                      |   0
 .gitattributes                                              |   0
 .github/CODE_OF_CONDUCT.md                                  |   0
 .github/FUNDING.yml                                         |   0
 .github/SECURITY.md                                         |   0
 .github/workflows/benchmark.yml                             |   0
 .github/workflows/docs.yml                                  |   0
 .github/workflows/linters.yml                               |   0
 .github/workflows/new_contributor_pr.yml                    |   0
 .github/workflows/schedule_tests.yml                        |   0
 .github/workflows/schedules.yml                             |   0
 .github/workflows/tests.yml                                 |   0
 .gitignore                                                  |   0
 .pre-commit-config.yaml                                     |   0
 .readthedocs.yml                                            |   0
 .tx/config                                                  |   0
 AUTHORS                                                     |   0
 CONTRIBUTING.rst                                            |   0
 Gruntfile.js                                                |   0
 INSTALL                                                     |   0
 LICENSE                                                     |   0
 LICENSE.python                                              |   0
 MANIFEST.in                                                 |   0
 README.rst                                                  |   0
 django/__init__.py                                          |   0
 django/__main__.py                                          |   0
 django/apps/__init__.py                                     |   0
 django/apps/config.py                                       |   0
 django/apps/registry.py                                     |   0
 django/conf/__init__.py                                     |   0
 django/conf/app_template/__init__.py-tpl                    |   0
 django/conf/app_template/admin.py-tpl                       |   0
 django/conf/app_template/apps.py-tpl                        |   0
 django/conf/app_template/migrations/__init__.py-tpl         |   0
 django/conf/app_template/models.py-tpl                      |   0
 django/conf/app_template/tests.py-tpl                       |   0
 django/conf/app_template/views.py-tpl                       |   0
 django/conf/global_settings.py                              |   0
 django/conf/locale/__init__.py                              |   0
 django/conf/locale/af/LC_MESSAGES/django.mo                 | Bin
 django/conf/locale/af/LC_MESSAGES/django.po                 |   0
 django/conf/locale/ar/LC_MESSAGES/django.mo                 | Bin
 django/conf/locale/ar/LC_MESSAGES/django.po                 |   0
 django/conf/locale/ar/__init__.py                           |   0
 django/conf/locale/ar/formats.py                            |   0
 django/conf/locale/ar_DZ/LC_MESSAGES/django.mo              | Bin
 django/conf/locale/ar_DZ/LC_MESSAGES/django.po              |   0
 django/conf/locale/ar_DZ/__init__.py                        |   0
 django/conf/locale/ar_DZ/formats.py                         |   0
 django/conf/locale/ast/LC_MESSAGES/django.mo                | Bin
 django/conf/locale/ast/LC_MESSAGES/django.po                |   0
 django/conf/locale/az/LC_MESSAGES/django.mo                 | Bin
 django/conf/locale/az/LC_MESSAGES/django.po                 |   0
```

```diff
diff --git a/.editorconfig b/.editorconfig
old mode 100644
new mode 100755
diff --git a/.eslintignore b/.eslintignore
old mode 100644
new mode 100755
diff --git a/.eslintrc b/.eslintrc
old mode 100644
new mode 100755
diff --git a/.git-blame-ignore-revs b/.git-blame-ignore-revs
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.github/CODE_OF_CONDUCT.md b/.github/CODE_OF_CONDUCT.md
old mode 100644
new mode 100755
diff --git a/.github/FUNDING.yml b/.github/FUNDING.yml
old mode 100644
new mode 100755
diff --git a/.github/SECURITY.md b/.github/SECURITY.md
old mode 100644
new mode 100755
diff --git a/.github/workflows/benchmark.yml b/.github/workflows/benchmark.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/docs.yml b/.github/workflows/docs.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/linters.yml b/.github/workflows/linters.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/new_contributor_pr.yml b/.github/workflows/new_contributor_pr.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/schedule_tests.yml b/.github/workflows/schedule_tests.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/schedules.yml b/.github/workflows/schedules.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/tests.yml b/.github/workflows/tests.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.pre-commit-config.yaml b/.pre-commit-config.yaml
old mode 100644
new mode 100755
diff --git a/.readthedocs.yml b/.readthedocs.yml
old mode 100644
new mode 100755
diff --git a/.tx/config b/.tx/config
old mode 100644
new mode 100755
diff --git a/AUTHORS b/AUTHORS
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.rst b/CONTRIBUTING.rst
old mode 100644
new mode 100755
diff --git a/Gruntfile.js b/Gruntfile.js
old mode 100644
new mode 100755
diff --git a/INSTALL b/INSTALL
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/LICENSE.python b/LICENSE.python
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/django/__init__.py b/django/__init__.py
old mode 100644
new mode 100755
diff --git a/django/__main__.py b/django/__main__.py
old mode 100644
new mode 100755
diff --git a/django/apps/__init__.py b/django/apps/__init__.py
old mode 100644
new mode 100755
diff --git a/django/apps/config.py b/django/apps/config.py
old mode 100644
new mode 100755
diff --git a/django/apps/registry.py b/django/apps/registry.py
old mode 100644
new mode 100755
diff --git a/django/conf/__init__.py b/django/conf/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/__init__.py-tpl b/django/conf/app_template/__init__.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/admin.py-tpl b/django/conf/app_template/admin.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/apps.py-tpl b/django/conf/app_template/apps.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/migrations/__init__.py-tpl b/django/conf/app_template/migrations/__init__.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/models.py-tpl b/django/conf/app_template/models.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/tests.py-tpl b/django/conf/app_template/tests.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/app_template/views.py-tpl b/django/conf/app_template/views.py-tpl
old mode 100644
new mode 100755
diff --git a/django/conf/global_settings.py b/django/conf/global_settings.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/__init__.py b/django/conf/locale/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/af/LC_MESSAGES/django.mo b/django/conf/locale/af/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/af/LC_MESSAGES/django.po b/django/conf/locale/af/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/LC_MESSAGES/django.mo b/django/conf/locale/ar/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/LC_MESSAGES/django.po b/django/conf/locale/ar/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/__init__.py b/django/conf/locale/ar/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar/formats.py b/django/conf/locale/ar/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/LC_MESSAGES/django.mo b/django/conf/locale/ar_DZ/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/LC_MESSAGES/django.po b/django/conf/locale/ar_DZ/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/__init__.py b/django/conf/locale/ar_DZ/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ar_DZ/formats.py b/django/conf/locale/ar_DZ/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ast/LC_MESSAGES/django.mo b/django/conf/locale/ast/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ast/LC_MESSAGES/django.po b/django/conf/locale/ast/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/LC_MESSAGES/django.mo b/django/conf/locale/az/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/LC_MESSAGES/django.po b/django/conf/locale/az/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/__init__.py b/django/conf/locale/az/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/az/formats.py b/django/conf/locale/az/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/be/LC_MESSAGES/django.mo b/django/conf/locale/be/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/be/LC_MESSAGES/django.po b/django/conf/locale/be/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/LC_MESSAGES/django.mo b/django/conf/locale/bg/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/LC_MESSAGES/django.po b/django/conf/locale/bg/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/__init__.py b/django/conf/locale/bg/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bg/formats.py b/django/conf/locale/bg/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/LC_MESSAGES/django.mo b/django/conf/locale/bn/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/LC_MESSAGES/django.po b/django/conf/locale/bn/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/__init__.py b/django/conf/locale/bn/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bn/formats.py b/django/conf/locale/bn/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/br/LC_MESSAGES/django.mo b/django/conf/locale/br/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/br/LC_MESSAGES/django.po b/django/conf/locale/br/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/LC_MESSAGES/django.mo b/django/conf/locale/bs/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/LC_MESSAGES/django.po b/django/conf/locale/bs/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/__init__.py b/django/conf/locale/bs/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/bs/formats.py b/django/conf/locale/bs/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/LC_MESSAGES/django.mo b/django/conf/locale/ca/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/LC_MESSAGES/django.po b/django/conf/locale/ca/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/__init__.py b/django/conf/locale/ca/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ca/formats.py b/django/conf/locale/ca/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ckb/__init__.py b/django/conf/locale/ckb/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/ckb/formats.py b/django/conf/locale/ckb/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/LC_MESSAGES/django.mo b/django/conf/locale/cs/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/LC_MESSAGES/django.po b/django/conf/locale/cs/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/__init__.py b/django/conf/locale/cs/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cs/formats.py b/django/conf/locale/cs/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/LC_MESSAGES/django.mo b/django/conf/locale/cy/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/LC_MESSAGES/django.po b/django/conf/locale/cy/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/__init__.py b/django/conf/locale/cy/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/cy/formats.py b/django/conf/locale/cy/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/LC_MESSAGES/django.mo b/django/conf/locale/da/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/LC_MESSAGES/django.po b/django/conf/locale/da/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/__init__.py b/django/conf/locale/da/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/da/formats.py b/django/conf/locale/da/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/LC_MESSAGES/django.mo b/django/conf/locale/de/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/LC_MESSAGES/django.po b/django/conf/locale/de/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/__init__.py b/django/conf/locale/de/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de/formats.py b/django/conf/locale/de/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de_CH/__init__.py b/django/conf/locale/de_CH/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/de_CH/formats.py b/django/conf/locale/de_CH/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/dsb/LC_MESSAGES/django.mo b/django/conf/locale/dsb/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/dsb/LC_MESSAGES/django.po b/django/conf/locale/dsb/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/LC_MESSAGES/django.mo b/django/conf/locale/el/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/LC_MESSAGES/django.po b/django/conf/locale/el/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/__init__.py b/django/conf/locale/el/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/el/formats.py b/django/conf/locale/el/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/LC_MESSAGES/django.mo b/django/conf/locale/en/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/LC_MESSAGES/django.po b/django/conf/locale/en/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/__init__.py b/django/conf/locale/en/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en/formats.py b/django/conf/locale/en/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/LC_MESSAGES/django.mo b/django/conf/locale/en_AU/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/LC_MESSAGES/django.po b/django/conf/locale/en_AU/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/__init__.py b/django/conf/locale/en_AU/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_AU/formats.py b/django/conf/locale/en_AU/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/LC_MESSAGES/django.mo b/django/conf/locale/en_GB/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/LC_MESSAGES/django.po b/django/conf/locale/en_GB/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/__init__.py b/django/conf/locale/en_GB/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/en_GB/formats.py b/django/conf/locale/en_GB/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/LC_MESSAGES/django.mo b/django/conf/locale/eo/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/LC_MESSAGES/django.po b/django/conf/locale/eo/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/__init__.py b/django/conf/locale/eo/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/eo/formats.py b/django/conf/locale/eo/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/LC_MESSAGES/django.mo b/django/conf/locale/es/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/LC_MESSAGES/django.po b/django/conf/locale/es/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/__init__.py b/django/conf/locale/es/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es/formats.py b/django/conf/locale/es/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/LC_MESSAGES/django.mo b/django/conf/locale/es_AR/LC_MESSAGES/django.mo
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/LC_MESSAGES/django.po b/django/conf/locale/es_AR/LC_MESSAGES/django.po
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/__init__.py b/django/conf/locale/es_AR/__init__.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_AR/formats.py b/django/conf/locale/es_AR/formats.py
old mode 100644
new mode 100755
diff --git a/django/conf/locale/es_CO/LC_MESSAGES/django.mo b/django/conf/locale/es_CO/LC_MESSAGES/django.mo
old mode 100644
new mod
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
    "npm": ">=1.3.0 <3.0.0"
  },
  "devDependencies": {
    "eslint": "^8.24.0",
    "puppeteer": "^14.1.1",
    "grunt": "^1.5.3",
    "grunt-cli": "^1.4.3",
    "grunt-contrib-qunit": "^6.1.0",
    "qunit": "^2.19.1"
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
`./tests/runtests.py auth_tests.test_forms`

## Scope
`django/contrib/auth/forms.py`
`tests/auth_tests/test_forms.py`

## Done when
- `UserChangeForm` formats the password help text with `../../{self.instance.pk}/password/` instead of `../password/`.
- A user change page reached through a `to_field` URL renders a password-change link that resolves to the user’s password change form instead of a 404.
- The scoped auth form tests pass.

## Approach
Change `UserChangeForm.__init__` so the password help text uses the instance’s primary key and two parent path segments: `password.help_text = password.help_text.format(f"../../{self.instance.pk}/password/")`. This matches the actual admin URL shape when the change view is reached with `_to_field`.

Candidate alternatives:
- Use `reverse("admin:auth_user_password_change", args=[self.instance.pk])` for an absolute admin URL. More robust to path depth, but couples the auth form to admin URL names and may not fit custom user admins.
- Override `UserAdmin.get_form()` and set the help text from the request path. Handles custom admin routing, but is more invasive and does not fix direct `UserChangeForm` use.
- Keep the relative link but compute depth from the request. The form has no request, so this requires passing context through the admin, which is unnecessary for the reported bug.
```

### `prompt.md`

```
Accessing UserAdmin via to_field leads to link to PasswordResetForm being broken (404)
Description
	 
		(last modified by Simon Kern)
	 
Accessing the UserAdmin via another model's Admin that has a reference to User (with to_field set, e.g., to_field="uuid") leads to the UserAdmin being accessed via an url that looks similar to this one:
.../user/22222222-3333-4444-5555-666677778888/change/?_to_field=uuid
However the underlying form looks like this: 
Code highlighting:
class UserChangeForm(forms.ModelForm):
	password = ReadOnlyPasswordHashField(
		label=_("Password"),
		help_text=_(
			"Raw passwords are not stored, so there is no way to see this "
			"user’s password, but you can change the password using "
			'<a href="{}">this form</a>.'
		),
	)
	...
	...
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		password = self.fields.get("password")
		if password:
			password.help_text = password.help_text.format("../password/")
	...
	...
This results in the link to the PasswordResetForm being wrong and thus ending up in a 404. If we drop the assumption that UserAdmin is always accessed via its pk, then we're good to go. It's as simple as replacing password.help_text = password.help_text.format("../password/") with password.help_text = password.help_text.format(f"../../{self.instance.pk}/password/")
I've opened a pull request on GitHub for this Ticket, please see:
​PR
```

### `review.md`

```
verdict: PASS

- The fix in `django/contrib/auth/forms.py` matches the Prompt exactly: `password.help_text` is now formatted with `f"../../{self.instance.pk}/password/"` instead of `"../password/"`, so the link is absolute from the change page rather than relative to the `_to_field` query string.
- The added test `test_password_help_text` in `tests/auth_tests/test_forms.py` asserts the new href, and the scoped check (`auth_tests.test_forms`) ran 87 tests with status 0 / OK.
- Only the two in-scope files changed (+3/-1 and +8/-0); no unrelated files touched, no content removed.
- Note (not a failure): the Done-when item about a `to_field` URL rendering a resolving link is covered only indirectly — the test checks the form's help text, not an end-to-end admin request through a `to_field` URL. The Prompt itself only asks for the format change, so this is a test-shape observation, not a reason to fail.
```

### `scope.txt`

```
scope: django/contrib/auth/forms.py tests/auth_tests/test_forms.py
changed: django/contrib/auth/forms.py +3 -1
changed: tests/auth_tests/test_forms.py +8 -0
```

### `task.md`

```
# Task

## Prompt

Accessing UserAdmin via to_field leads to link to PasswordResetForm being broken (404)
Description
	 
		(last modified by Simon Kern)
	 
Accessing the UserAdmin via another model's Admin that has a reference to User (with to_field set, e.g., to_field="uuid") leads to the UserAdmin being accessed via an url that looks similar to this one:
.../user/22222222-3333-4444-5555-666677778888/change/?_to_field=uuid
However the underlying form looks like this: 
Code highlighting:
class UserChangeForm(forms.ModelForm):
	password = ReadOnlyPasswordHashField(
		label=_("Password"),
		help_text=_(
			"Raw passwords are not stored, so there is no way to see this "
			"user’s password, but you can change the password using "
			'<a href="{}">this form</a>.'
		),
	)
	...
	...
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		password = self.fields.get("password")
		if password:
			password.help_text = password.help_text.format("../password/")
	...
	...
This results in the link to the PasswordResetForm being wrong and thus ending up in a 404. If we drop the assumption that UserAdmin is always accessed via its pk, then we're good to go. It's as simple as replacing password.help_text = password.help_text.format("../password/") with password.help_text = password.help_text.format(f"../../{self.instance.pk}/password/")
I've opened a pull request on GitHub for this Ticket, please see:
​PR

## Deliverable

changes to this tree

## Check

`./tests/runtests.py auth_tests.test_forms`

## Scope

`django/contrib/auth/forms.py`
`tests/auth_tests/test_forms.py`

## Done when

- `UserChangeForm` formats the password help text with `../../{self.instance.pk}/password/` instead of `../password/`.
- A user change page reached through a `to_field` URL renders a password-change link that resolves to the user’s password change form instead of a 404.
- The scoped auth form tests pass.
```

### `test-output.log`

```
check: ./tests/runtests.py auth_tests.test_forms
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 87 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
.......................................................................................
----------------------------------------------------------------------
Ran 87 tests in 0.312s

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
scope: django/contrib/auth/forms.py tests/auth_tests/test_forms.py
changed: django/contrib/auth/forms.py +3 -1
changed: tests/auth_tests/test_forms.py +8 -0
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
