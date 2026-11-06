# django__django-16333 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 130s 64 lines cost=0.007082 in=207044 cached=180736 out=14451 calls=21`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

UserCreationForm should save data from ManyToMany form fields
Description
	
When using contrib.auth.forms.UserCreationForm with a custom User model which has ManyToManyField fields, the data in all related form fields (e.g. a ModelMultipleChoiceField) is not saved. 
This is because unlike its parent class django.forms.ModelForm, UserCreationForm.save(commit=True) omits to call self.save_m2m(). 
This has been discussed on the #django-developers mailing list ​https://groups.google.com/u/1/g/django-developers/c/2jj-ecoBwE4 and I'm ready to work on a PR.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --short"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class UserCreationForm\" -n django/contrib/auth/forms.py"
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
0c9aa8c34d SWE-bench
60a7bd8986 Refs #34119 -- Skipped test_callable_default_hidden_widget_value_not_overridden when JSONField is not supported.
20d575b101 Refs #31169 -- Skipped test_get_test_db_clone_settings_not_supported on not in-memory SQLite database.
?? .memdoor/
```

**tool result**

```
84:class UserCreationForm(forms.ModelForm):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/contrib/auth/forms.py",
  "offset": 80,
  "limit": 100
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"UserCreationForm\" tests/auth_tests/test_forms.py | head -30"
}
```

**tool result**

```
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
            [redacted] = password.help_text.format(
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

[308 more lines in /testbed/django/contrib/auth/forms.py (487 in all). read_file with offset: 180 to continue]
```

**tool result**

```
15:    UserCreationForm,
56:class UserCreationFormTest(TestDataMixin, TestCase):
63:        form = UserCreationForm(data)
76:        form = UserCreationForm(data)
92:        form = UserCreationForm(data)
101:        form = UserCreationForm(data)
108:        form = UserCreationForm(data)
121:        form = UserCreationForm(data)
135:        form = UserCreationForm(data)
149:        form = UserCreationForm(data)
170:        form = UserCreationForm(data)
200:        form = UserCreationForm(data)
212:        class CustomUserCreationForm(UserCreationForm):
213:            class Meta(UserCreationForm.Meta):
215:                fields = UserCreationForm.Meta.fields + ("date_of_birth",)
223:        form = CustomUserCreationForm(data)
227:        class CustomUserCreationForm(UserCreationForm):
228:            class Meta(UserCreationForm.Meta):
238:        form = CustomUserCreationForm(data)
242:        class CustomUserCreationForm(UserCreationForm):
243:            class Meta(UserCreationForm.Meta):
252:        form = CustomUserCreationForm(data)
261:        form = UserCreationForm(data)
277:        form = UserCreationForm()
296:        """UserCreationForm password validation uses all of the form's data."""
298:        class CustomUserCreationForm(UserCreationForm):
299:            class Meta(UserCreationForm.Meta):
303:        form = CustomUserCreationForm(
319:        form = UserCreationForm()
325:        form = UserCreationForm()
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/test_forms.py",
  "offset": 1,
  "limit": 60
}
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/test_forms.py",
  "offset": 200,
  "limit": 80
}
```

**tool result**

```
import datetime
import re
import urllib.parse
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
from django.urls import reverse
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
            username="testclient", password="[redacted]", email="testclient@example.com"
        )
        cls.u2 = User.objects.create_user(
            username="inactive", password="[redacted]", is_active=False
        )
        cls.u3 = User.objects.create_user(username="staff", password="[redacted]")
        cls.u4 = User.objects.create(username="empty_password", password="")
        cls.u5 = User.objects.create(username="unmanageable_password", password="$")
        cls.u6 = User.objects.create(username="unknown_password", password="foo$bar")


class UserCreationFormTest(TestDataMixin, TestCase):
    def test_user_already_exists(self):
        data = {
            "username": "testclient",
            "password1": "test123",

[1246 more lines in /testbed/tests/auth_tests/test_forms.py (1306 in all). read_file with offset: 61 to continue]
```

**tool result**

```
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

[1027 more lines in /testbed/tests/auth_tests/test_forms.py (1306 in all). read_file with offset: 280 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def save\\|save_m2m\" django/forms/models.py | head -20 && sed -n '450,500p' django/forms/models.py"
}
```

**tool result**

```
505:    def _save_m2m(self):
526:    def save(self, commit=True):
529:        a save_m2m() method to the form which can be called after the instance
543:            self._save_m2m()
547:            self.save_m2m = self._save_m2m
755:    def save_new(self, form, commit=True):
759:    def save_existing(self, form, instance, commit=True):
768:    def save(self, commit=True):
776:            def save_m2m():
778:                    form.save_m2m()
780:            self.save_m2m = save_m2m
909:    def save_existing_objects(self, commit=True):
935:    def save_new_objects(self, commit=True):
1137:    def save_new(self, form, commit=True):
            else:
                continue

            for message in messages:
                if (
                    isinstance(message, ValidationError)
                    and message.code in error_messages
                ):
                    message.message = error_messages[message.code]

        self.add_error(None, errors)

    def _post_clean(self):
        opts = self._meta

        exclude = self._get_validation_exclusions()

        # Foreign Keys being used to represent inline relationships
        # are excluded from basic field value validation. This is for two
        # reasons: firstly, the value may not be supplied (#12507; the
        # case of providing new values to the admin); secondly the
        # object being referred to may not yet fully exist (#12749).
        # However, these fields *must* be included in uniqueness checks,
        # so this can't be part of _get_validation_exclusions().
        for name, field in self.fields.items():
            if isinstance(field, InlineForeignKeyField):
                exclude.add(name)

        try:
            self.instance = construct_instance(
                self, self.instance, opts.fields, opts.exclude
            )
        except ValidationError as e:
            self._update_errors(e)

        try:
            self.instance.full_clean(exclude=exclude, validate_unique=False)
        except ValidationError as e:
            self._update_errors(e)

        # Validate uniqueness if needed.
        if self._validate_unique:
            self.validate_unique()

    def validate_unique(self):
        """
        Call the instance's validate_unique() method and update the form's
        validation errors if any were raised.
        """
        exclude = self._get_validation_exclusions()
        try:
```

**assistant → tool `read_file`**

```json
{
  "path": "django/forms/models.py",
  "offset": 500,
  "limit": 55
}
```

**tool result**

```
        try:
            self.instance.validate_unique(exclude=exclude)
        except ValidationError as e:
            self._update_errors(e)

    def _save_m2m(self):
        """
        Save the many-to-many fields and generic relations for this form.
        """
        cleaned_data = self.cleaned_data
        exclude = self._meta.exclude
        fields = self._meta.fields
        opts = self.instance._meta
        # Note that for historical reasons we want to include also
        # private_fields here. (GenericRelation was previously a fake
        # m2m field).
        for f in chain(opts.many_to_many, opts.private_fields):
            if not hasattr(f, "save_form_data"):
                continue
            if fields and f.name not in fields:
                continue
            if exclude and f.name in exclude:
                continue
            if f.name in cleaned_data:
                f.save_form_data(self.instance, cleaned_data[f.name])

    def save(self, commit=True):
        """
        Save this form's self.instance object if commit=True. Otherwise, add
        a save_m2m() method to the form which can be called after the instance
        is saved manually at a later time. Return the model instance.
        """
        if self.errors:
            raise ValueError(
                "The %s could not be %s because the data didn't validate."
                % (
                    self.instance._meta.object_name,
                    "created" if self.instance._state.adding else "changed",
                )
            )
        if commit:
            # If committing, save the instance and the m2m data immediately.
            self.instance.save()
            self._save_m2m()
        else:
            # If not committing, add a method to the form to allow deferred
            # saving of m2m data.
            self.save_m2m = self._save_m2m
        return self.instance

    save.alters_data = True


class ModelForm(BaseModelForm, metaclass=ModelFormMetaclass):
    pass

[1106 more lines in /testbed/django/forms/models.py (1660 in all). read_file with offset: 555 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "ls tests/auth_tests/models/ && grep -rn \"ManyToMany\" tests/auth_tests/models/ | head"
}
```

**tool result**

```
__init__.py
custom_permissions.py
custom_user.py
invalid_models.py
is_active.py
minimal.py
no_password.py
proxy.py
uuid_pk.py
with_custom_email_field.py
with_foreign_key.py
with_integer_username.py
with_last_login_attr.py
with_many_to_many.py
with_unique_constraint.py
tests/auth_tests/models/with_many_to_many.py:20:    orgs = models.ManyToManyField(Organization)
tests/auth_tests/models/with_many_to_many.py:30:    orgs = models.ManyToManyField(Organization, through="Membership")
tests/auth_tests/models/custom_user.py:88:        groups = models.ManyToManyField(Group, blank=True)
tests/auth_tests/models/custom_user.py:90:        user_permissions = models.ManyToManyField(Permission, blank=True)
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/models/with_many_to_many.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"with_many_to_many\\|ManyToMany\" tests/auth_tests/test_forms.py tests/auth_tests/test_models.py | head -20"
}
```

**tool result**

```
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models


class Organization(models.Model):
    name = models.CharField(max_length=255)


class CustomUserWithM2MManager(BaseUserManager):
    def create_superuser(self, username, orgs, password):
        user = self.model(username=username)
        user.set_password(password)
        user.save(using=self._db)
        user.orgs.add(*orgs)
        return user


class CustomUserWithM2M(AbstractBaseUser):
    username = models.CharField(max_length=30, unique=True)
    orgs = models.ManyToManyField(Organization)

    custom_objects = CustomUserWithM2MManager()

    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = ["orgs"]


class CustomUserWithM2MThrough(AbstractBaseUser):
    username = models.CharField(max_length=30, unique=True)
    orgs = models.ManyToManyField(Organization, through="Membership")

    custom_objects = CustomUserWithM2MManager()

    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = ["orgs"]


class Membership(models.Model):
    user = models.ForeignKey(CustomUserWithM2MThrough, on_delete=models.CASCADE)
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE)
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"CustomUserWithM2M\" tests/ | head -20"
}
```

**tool result**

```
tests/auth_tests/models/with_many_to_many.py:9:class CustomUserWithM2MManager(BaseUserManager):
tests/auth_tests/models/with_many_to_many.py:18:class CustomUserWithM2M(AbstractBaseUser):
tests/auth_tests/models/with_many_to_many.py:22:    custom_objects = CustomUserWithM2MManager()
tests/auth_tests/models/with_many_to_many.py:28:class CustomUserWithM2MThrough(AbstractBaseUser):
tests/auth_tests/models/with_many_to_many.py:32:    custom_objects = CustomUserWithM2MManager()
tests/auth_tests/models/with_many_to_many.py:39:    user = models.ForeignKey(CustomUserWithM2MThrough, on_delete=models.CASCADE)
tests/auth_tests/models/__init__.py:13:from .with_many_to_many import CustomUserWithM2M, CustomUserWithM2MThrough, Organization
tests/auth_tests/models/__init__.py:22:    "CustomUserWithM2M",
tests/auth_tests/models/__init__.py:23:    "CustomUserWithM2MThrough",
tests/auth_tests/test_management.py:25:    CustomUserWithM2M,
tests/auth_tests/test_management.py:670:        user = CustomUserWithM2M._default_manager.get(username="joe")
tests/auth_tests/test_management.py:673:    @override_settings(AUTH_USER_MODEL="auth_tests.CustomUserWithM2M")
tests/auth_tests/test_management.py:695:            user = CustomUserWithM2M._default_manager.get(username="joe")
tests/auth_tests/test_management.py:700:    @override_settings(AUTH_USER_MODEL="auth_tests.CustomUserWithM2M")
tests/auth_tests/test_management.py:732:    @override_settings(AUTH_USER_MODEL="auth_tests.CustomUserWithM2MThrough")
tests/auth_tests/test_management.py:1305:        user = CustomUserWithM2M._default_manager.get(username="joe")
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' tests/auth_tests/test_management.py && grep -n \"class UserCreationFormTest\" -A5 tests/auth_tests/test_forms.py && sed -n '55,80p' tests/auth_tests/test_forms.py"
}
```

**tool result**

```
import builtins
import getpass
import os
import sys
from datetime import date
from io import StringIO
from unittest import mock

from django.apps import apps
from django.contrib.auth import get_permission_codename, management
from django.contrib.auth.management import create_permissions, get_default_username
from django.contrib.auth.management.commands import changepassword, createsuperuser
from django.contrib.auth.models import Group, Permission, User
from django.contrib.contenttypes.models import ContentType
from django.core.management import call_command
from django.core.management.base import CommandError
from django.db import migrations
from django.test import TestCase, override_settings
from django.utils.translation import gettext_lazy as _

from .models import (
    CustomUser,
    CustomUserNonUniqueUsername,
    CustomUserWithFK,
    CustomUserWithM2M,
    CustomUserWithUniqueConstraint,
    Email,
    Organization,
    UserProxy,
)

MOCK_INPUT_KEY_TO_PROMPTS = {
    # @mock_inputs dict key: [expected prompt messages],
    "bypass": ["Bypass password validation and create user anyway? [y/N]: "],
    "email": ["Email address: "],
    "date_of_birth": ["Date of birth: "],
    "first_name": ["First name: "],
    "username": [
        "Username: ",
        lambda: "Username (leave blank to use '%s'): " % get_default_username(),
56:class UserCreationFormTest(TestDataMixin, TestCase):
57-    def test_user_already_exists(self):
58-        data = {
59-            "username": "testclient",
60-            "password1": "test123",
61-            "password2": "test123",

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
```

**assistant → tool `bash`**

```json
{
  "command": "ls docs/releases/ | tail -5 && grep -n \"UserCreationForm\" docs/releases/4.2.txt | head"
}
```

**tool result**

```
4.1.4.txt
4.1.txt
4.2.txt
index.txt
security.txt
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/auth/forms.py\n@@\n     def save(self, commit=True):\n         user = super().save(commit=False)\n         user.set_password(self.cleaned_data[\"password1\"])\n         if commit:\n             user.save()\n+            self.save_m2m()\n         return user\n*** Update File: tests/auth_tests/test_forms.py\n@@\n from .models.custom_user import (\n     CustomUser,\n     CustomUserWithoutIsActiveField,\n     ExtensionUser,\n )\n+from .models.with_many_to_many import CustomUserWithM2M, Organization\n from .models.with_custom_email_field import CustomEmailField\n@@\n     def test_custom_form_hidden_username_field(self):\n         class CustomUserCreationForm(UserCreationForm):\n             class Meta(UserCreationForm.Meta):\n                 model = CustomUserWithoutIsActiveField\n                 fields = (\"email\",)  # without USERNAME_FIELD\n@@\n         form = CustomUserCreationForm(data)\n         self.assertTrue(form.is_valid())\n \n+    def test_custom_form_with_many_to_many_field(self):\n+        class CustomUserCreationForm(UserCreationForm):\n+            class Meta(UserCreationForm.Meta):\n+                model = CustomUserWithM2M\n+                fields = (\"username\", \"orgs\")\n+\n+        org1 = Organization.objects.create(name=\"org1\")\n+        org2 = Organization.objects.create(name=\"org2\")\n+        data = {\n+            \"username\": \"testclient\",\n+            \"password1\": \"testclient\",\n+            \"password2\": \"testclient\",\n+            \"orgs\": [org1.pk, org2.pk],\n+        }\n+        form = CustomUserCreationForm(data)\n+        self.assertTrue(form.is_valid())\n+        user = form.save()\n+        self.assertCountEqual(user.orgs.all(), [org1, org2])\n+\n     def test_password_whitespace_not_stripped(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/auth/forms.py tests/auth_tests/test_forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/auth/forms.py now (488 lines), around the change:
141:        user.set_password(self.cleaned_data["password1"])
142:        if commit:
143:            user.save()
144:            self.save_m2m()
145:        return user
146:
147:

tests/auth_tests/test_forms.py now (1326 lines), around the change:
33:    CustomUserWithoutIsActiveField,
34:    ExtensionUser,
35:)
36:from .models.with_many_to_many import CustomUserWithM2M, Organization
37:from .models.with_custom_email_field import CustomEmailField
38:from .models.with_integer_username import IntegerUsernameUser
39:from .settings import AUTH_TEMPLATES
…
252:        }
253:        form = CustomUserCreationForm(data)
254:        self.assertTrue(form.is_valid())
255:
256:    def test_custom_form_with_many_to_many_field(self):
257:        class CustomUserCreationForm(UserCreationForm):
258:            class Meta(UserCreationForm.Meta):
259:                model = CustomUserWithM2M
260:                fields = ("username", "orgs")
261:
262:        org1 = Organization.objects.create(name="org1")
263:        org2 = Organization.objects.create(name="org2")
264:        data = {
265:            "username": "testclient",
266:            "password1": "testclient",
267:            "password2": "testclient",
268:            "orgs": [org1.pk, org2.pk],
269:        }
270:        form = CustomUserCreationForm(data)
271:        self.assertTrue(form.is_valid())
272:        user = form.save()
273:        self.assertCountEqual(user.orgs.all(), [org1, org2])
274:
275:    def test_password_whitespace_not_stripped(self):
276:        data = {
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/auth_tests/test_forms.py\n@@\n-from .models.with_many_to_many import CustomUserWithM2M, Organization\n from .models.with_custom_email_field import CustomEmailField\n from .models.with_integer_username import IntegerUsernameUser\n+from .models.with_many_to_many import CustomUserWithM2M, Organization\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/auth_tests/test_forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/auth_tests/test_forms.py now (1326 lines), around the change:
33:    CustomUserWithoutIsActiveField,
34:    ExtensionUser,
35:)
36:from .models.with_custom_email_field import CustomEmailField
37:from .models.with_integer_username import IntegerUsernameUser
38:from .models.with_many_to_many import CustomUserWithM2M, Organization
39:from .settings import AUTH_TEMPLATES
40:
41:
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py auth_tests.test_forms.UserCreationFormTest -v1 2>&1 | tail -20"
}
```

**tool result**

```
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 18 test(s).
System check identified no issues (0 silenced).
..................
----------------------------------------------------------------------
Ran 18 tests in 0.039s

OK
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"django.contrib.auth\" docs/releases/4.2.txt | head"
}
```

**tool result**

```
62::mod:`django.contrib.auth`
466:* ``django.contrib.auth.hashers.SHA1PasswordHasher``,
467:  ``django.contrib.auth.hashers.UnsaltedSHA1PasswordHasher``, and
468:  ``django.contrib.auth.hashers.UnsaltedMD5PasswordHasher`` are deprecated.
```

**assistant → tool `read_file`**

```json
{
  "path": "docs/releases/4.2.txt",
  "offset": 60,
  "limit": 20
}
```

**tool result**

```
* ...

:mod:`django.contrib.auth`
~~~~~~~~~~~~~~~~~~~~~~~~~~

* The default iteration count for the PBKDF2 password hasher is increased from
  390,000 to 480,000.

:mod:`django.contrib.contenttypes`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.gis`
~~~~~~~~~~~~~~~~~~~~~~~~~

* The :doc:`GeoJSON serializer </ref/contrib/gis/serializers>` now outputs the
  ``id`` key for serialized features, which defaults to the primary key of
  objects.


[412 more lines in /testbed/docs/releases/4.2.txt (491 in all). read_file with offset: 80 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: docs/releases/4.2.txt\n@@\n * The default iteration count for the PBKDF2 password hasher is increased from\n   390,000 to 480,000.\n \n+* :class:`~django.contrib.auth.forms.UserCreationForm` now saves many-to-many\n+  fields from custom user models.\n+\n :mod:`django.contrib.contenttypes`\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[docs/releases/4.2.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

docs/releases/4.2.txt now (494 lines), around the change:
64:
65:* The default iteration count for the PBKDF2 password hasher is increased from
66:  390,000 to 480,000.
67:
68:* :class:`~django.contrib.auth.forms.UserCreationForm` now saves many-to-many
69:  fields from custom user models.
70:
71::mod:`django.contrib.contenttypes`
72:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py auth_tests.test_forms -v1 2>&1 | tail -8"
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
  "command": "python tests/runtests.py auth_tests.test_forms -v1 2>&1 | grep -E \"Ran|OK|FAILED|ERROR\""
}
```

**tool result**

```
Ran 88 tests in 0.246s
OK
```

**assistant**

```
Implemented the fix.

**Change** — `django/contrib/auth/forms.py`:
`UserCreationForm.save()` now calls `self.save_m2m()` after saving the user when `commit=True`, matching `ModelForm.save()` behavior so many-to-many fields on custom user models are persisted.

**Test** — `tests/auth_tests/test_forms.py`:
Added `test_custom_form_with_many_to_many_field`, which builds a `UserCreationForm` subclass for `CustomUserWithM2M`, submits two `Organization` PKs, saves, and asserts both relations exist.

**Docs** — `docs/releases/4.2.txt`:
Added a release note under `django.contrib.auth`.

Verification: `python tests/runtests.py auth_tests.test_forms` → 88 tests, OK. No commits/checkouts/resets/stashes were made.
```

## Run folder `team-solve-2026-11-06T112547`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
0c9aa8c34dfd2829347551dd803357247f21bb7e
```

### `baseline-check.log`

```
check: python tests/runtests.py auth_tests.test_forms
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
Ran 87 tests in 0.319s

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
index d73d1c8495..4c9a4f5556 100644
--- a/django/contrib/auth/forms.py
+++ b/django/contrib/auth/forms.py
@@ -141,6 +141,7 @@ class UserCreationForm(forms.ModelForm):
         user.set_password(self.cleaned_data["password1"])
         if commit:
             user.save()
+            self.save_m2m()
         return user
 
 
diff --git a/docs/releases/4.2.txt b/docs/releases/4.2.txt
index a9841d1af4..073ec2092c 100644
--- a/docs/releases/4.2.txt
+++ b/docs/releases/4.2.txt
@@ -65,6 +65,9 @@ Minor features
 * The default iteration count for the PBKDF2 password hasher is increased from
   390,000 to 480,000.
 
+* :class:`~django.contrib.auth.forms.UserCreationForm` now saves many-to-many
+  fields from custom user models.
+
 :mod:`django.contrib.contenttypes`
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
diff --git a/tests/auth_tests/test_forms.py b/tests/auth_tests/test_forms.py
index 78078316e8..e3e2a7d228 100644
--- a/tests/auth_tests/test_forms.py
+++ b/tests/auth_tests/test_forms.py
@@ -35,6 +35,7 @@ from .models.custom_user import (
 )
 from .models.with_custom_email_field import CustomEmailField
 from .models.with_integer_username import IntegerUsernameUser
+from .models.with_many_to_many import CustomUserWithM2M, Organization
 from .settings import AUTH_TEMPLATES
 
 
@@ -252,6 +253,25 @@ class UserCreationFormTest(TestDataMixin, TestCase):
         form = CustomUserCreationForm(data)
         self.assertTrue(form.is_valid())
 
+    def test_custom_form_with_many_to_many_field(self):
+        class CustomUserCreationForm(UserCreationForm):
+            class Meta(UserCreationForm.Meta):
+                model = CustomUserWithM2M
+                fields = ("username", "orgs")
+
+        org1 = Organization.objects.create(name="org1")
+        org2 = Organization.objects.create(name="org2")
+        data = {
+            "username": "testclient",
+            "password1": "testclient",
+            "password2": "testclient",
+            "orgs": [org1.pk, org2.pk],
+        }
+        form = CustomUserCreationForm(data)
+        self.assertTrue(form.is_valid())
+        user = form.save()
+        self.assertCountEqual(user.orgs.all(), [org1, org2])
+
     def test_password_whitespace_not_stripped(self):
         data = {
             "username": "testuser",
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

UserCreationForm should save data from ManyToMany form fields
Description
	
When using contrib.auth.forms.UserCreationForm with a custom User model which has ManyToManyField fields, the data in all related form fields (e.g. a ModelMultipleChoiceField) is not saved. 
This is because unlike its parent class django.forms.ModelForm, UserCreationForm.save(commit=True) omits to call self.save_m2m(). 
This has been discussed on the #django-developers mailing list ​https://groups.google.com/u/1/g/django-developers/c/2jj-ecoBwE4 and I'm ready to work on a PR.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py auth_tests.test_forms`

## Scope

`django/contrib/auth/forms.py`
`tests/auth_tests/`

## Done when

`UserCreationForm.save(commit=True)` calls `self.save_m2m()` after saving the user, so ManyToManyField form data is persisted.
`UserCreationForm.save(commit=False)` still returns an unsaved user and does not persist ManyToMany data.
The auth forms test suite passes with coverage for a custom user model containing a ManyToManyField.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py auth_tests.test_forms`

## Scope
`django/contrib/auth/forms.py`
`tests/auth_tests/`

## Done when
`UserCreationForm.save(commit=True)` calls `self.save_m2m()` after saving the user, so ManyToManyField form data is persisted.
`UserCreationForm.save(commit=False)` still returns an unsaved user and does not persist ManyToMany data.
The auth forms test suite passes with coverage for a custom user model containing a ManyToManyField.

## Approach
Decompose into: inspect `UserCreationForm.save()`, add the missing m2m save in the `commit=True` path, and add a regression test using a custom user model with a ManyToManyField.

Candidate approaches:
1. Minimal fix: inside `if commit:`, after `user.save()`, call `self.save_m2m()`. This mirrors `ModelForm.save()` and is the smallest correct change.
2. Guarded fix: call `self.save_m2m()` only if it exists. This is defensive but unnecessary because `super().save(commit=False)` sets `save_m2m`.
3. Private call: use `self._save_m2m()` directly. Avoid this because it bypasses the public hook and any overrides.

Prefer approach 1. If tests fail, verify that `super().save(commit=False)` is still called before setting the password and that `save_m2m()` runs only in the `commit=True` branch.


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
    A form that lets a user set their password without entering the old
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


# tests/auth_tests (the files in it)

tests/auth_tests/__init__.py
tests/auth_tests/backend_alias.py
tests/auth_tests/client.py
tests/auth_tests/common-passwords-custom.txt
tests/auth_tests/fixtures/natural.json
tests/auth_tests/fixtures/regular.json
tests/auth_tests/models/__init__.py
tests/auth_tests/models/custom_permissions.py
tests/auth_tests/models/custom_user.py
tests/auth_tests/models/invalid_models.py
tests/auth_tests/models/is_active.py
tests/auth_tests/models/minimal.py
tests/auth_tests/models/no_password.py
tests/auth_tests/models/proxy.py
tests/auth_tests/models/uuid_pk.py
tests/auth_tests/models/with_custom_email_field.py
tests/auth_tests/models/with_foreign_key.py
tests/auth_tests/models/with_integer_username.py
tests/auth_tests/models/with_last_login_attr.py
tests/auth_tests/models/with_many_to_many.py
tests/auth_tests/models/with_unique_constraint.py
tests/auth_tests/settings.py
tests/auth_tests/templates/context_processors/auth_attrs_access.html
tests/auth_tests/templates/context_processors/auth_attrs_messages.html
tests/auth_tests/templates/context_processors/auth_attrs_no_access.html
tests/auth_tests/templates/context_processors/auth_attrs_perm_in_perms.html
tests/auth_tests/templates/context_processors/auth_attrs_perms.html
tests/auth_tests/templates/context_processors/auth_attrs_test_access.html
tests/auth_tests/templates/context_processors/auth_attrs_user.html
tests/auth_tests/templates/registration/html_password_reset_email.html
tests/auth_tests/templates/registration/logged_out.html
tests/auth_tests/templates/registration/login.html
tests/auth_tests/templates/registration/password_change_form.html
tests/auth_tests/templates/registration/password_reset_complete.html
tests/auth_tests/templates/registration/password_reset_confirm.html
tests/auth_tests/templates/registration/password_reset_done.html
tests/auth_tests/templates/registration/password_reset_email.html
tests/auth_tests/templates/registration/password_reset_form.html
tests/auth_tests/templates/registration/password_reset_subject.txt
tests/auth_tests/test_admin_multidb.py
tests/auth_tests/test_auth_backends.py
tests/auth_tests/test_basic.py
tests/auth_tests/test_checks.py
tests/auth_tests/test_context_processors.py
tests/auth_tests/test_decorators.py
tests/auth_tests/test_forms.py
tests/auth_tests/test_handlers.py
tests/auth_tests/test_hashers.py
tests/auth_tests/test_management.py
tests/auth_tests/test_middleware.py
tests/auth_tests/test_migrations.py
tests/auth_tests/test_mixins.py
tests/auth_tests/test_models.py
tests/auth_tests/test_remote_user.py
tests/auth_tests/test_signals.py
tests/auth_tests/test_templates.py
tests/auth_tests/test_tokens.py
tests/auth_tests/test_validators.py
tests/auth_tests/test_views.py
tests/auth_tests/urls.py
tests/auth_tests/urls_admin.py
tests/auth_tests/urls_custom_user_admin.py


# The last commit

```
0c9aa8c34d SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py auth_tests.test_forms
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 88 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
........................................................................................
----------------------------------------------------------------------
Ran 88 tests in 0.269s

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
scope: django/contrib/auth/forms.py tests/auth_tests
changed: django/contrib/auth/forms.py +1 -0
OUTSIDE THE SCOPE: docs/releases/4.2.txt +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/auth_tests/test_forms.py +20 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/contrib/auth/forms.py b/django/contrib/auth/forms.py
index d73d1c8495..4c9a4f5556 100644
--- a/django/contrib/auth/forms.py
+++ b/django/contrib/auth/forms.py
@@ -141,6 +141,7 @@ class UserCreationForm(forms.ModelForm):
         user.set_password(self.cleaned_data["password1"])
         if commit:
             user.save()
+            self.save_m2m()
         return user
 
 
diff --git a/docs/releases/4.2.txt b/docs/releases/4.2.txt
index a9841d1af4..073ec2092c 100644
--- a/docs/releases/4.2.txt
+++ b/docs/releases/4.2.txt
@@ -65,6 +65,9 @@ Minor features
 * The default iteration count for the PBKDF2 password hasher is increased from
   390,000 to 480,000.
 
+* :class:`~django.contrib.auth.forms.UserCreationForm` now saves many-to-many
+  fields from custom user models.
+
 :mod:`django.contrib.contenttypes`
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
diff --git a/tests/auth_tests/test_forms.py b/tests/auth_tests/test_forms.py
index 78078316e8..e3e2a7d228 100644
--- a/tests/auth_tests/test_forms.py
+++ b/tests/auth_tests/test_forms.py
@@ -35,6 +35,7 @@ from .models.custom_user import (
 )
 from .models.with_custom_email_field import CustomEmailField
 from .models.with_integer_username import IntegerUsernameUser
+from .models.with_many_to_many import CustomUserWithM2M, Organization
 from .settings import AUTH_TEMPLATES
 
 
@@ -252,6 +253,25 @@ class UserCreationFormTest(TestDataMixin, TestCase):
         form = CustomUserCreationForm(data)
         self.assertTrue(form.is_valid())
 
+    def test_custom_form_with_many_to_many_field(self):
+        class CustomUserCreationForm(UserCreationForm):
+            class Meta(UserCreationForm.Meta):
+                model = CustomUserWithM2M
+                fields = ("username", "orgs")
+
+        org1 = Organization.objects.create(name="org1")
+        org2 = Organization.objects.create(name="org2")
+        data = {
+            "username": "testclient",
+            "password1": "testclient",
+            "password2": "testclient",
+            "orgs": [org1.pk, org2.pk],
+        }
+        form = CustomUserCreationForm(data)
+        self.assertTrue(form.is_valid())
+        user = form.save()
+        self.assertCountEqual(user.orgs.all(), [org1, org2])
+
     def test_password_whitespace_not_stripped(self):
         data = {
             "username": "testuser",
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
check: python tests/runtests.py auth_tests.test_forms
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 88 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
........................................................................................
----------------------------------------------------------------------
Ran 88 tests in 0.538s

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
scope: django/contrib/auth/forms.py tests/auth_tests
changed: django/contrib/auth/forms.py +1 -0
OUTSIDE THE SCOPE: docs/releases/4.2.txt +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/auth_tests/test_forms.py +20 -0
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
# Notes, run 2026-11-06T112547

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

UserCreationForm should save data from ManyToMany form fields
Description
	
When using contrib.auth.forms.UserCreationForm with a custom User model which has ManyToManyField fields, the data in all related form fields (e.g. a ModelMultipleChoiceField) is not saved. 
This is because unlike its parent class django.forms.ModelForm, UserCreationForm.save(commit=True) omits to call self.save_m2m(). 
This has been discussed on the #django-developers mailing list ​https://groups.google.com/u/1/g/django-developers/c/2jj-ecoBwE4 and I'm ready to work on a PR.


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
0c9aa8c34d SWE-bench


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
`python tests/runtests.py auth_tests.test_forms`

## Scope
`django/contrib/auth/forms.py`
`tests/auth_tests/`

## Done when
`UserCreationForm.save(commit=True)` calls `self.save_m2m()` after saving the user, so ManyToManyField form data is persisted.
`UserCreationForm.save(commit=False)` still returns an unsaved user and does not persist ManyToMany data.
The auth forms test suite passes with coverage for a custom user model containing a ManyToManyField.

## Approach
Decompose into: inspect `UserCreationForm.save()`, add the missing m2m save in the `commit=True` path, and add a regression test using a custom user model with a ManyToManyField.

Candidate approaches:
1. Minimal fix: inside `if commit:`, after `user.save()`, call `self.save_m2m()`. This mirrors `ModelForm.save()` and is the smallest correct change.
2. Guarded fix: call `self.save_m2m()` only if it exists. This is defensive but unnecessary because `super().save(commit=False)` sets `save_m2m`.
3. Private call: use `self._save_m2m()` directly. Avoid this because it bypasses the public hook and any overrides.

Prefer approach 1. If tests fail, verify that `super().save(commit=False)` is still called before setting the password and that `save_m2m()` runs only in the `commit=True` branch.
```

### `prompt.md`

```
UserCreationForm should save data from ManyToMany form fields
Description
	
When using contrib.auth.forms.UserCreationForm with a custom User model which has ManyToManyField fields, the data in all related form fields (e.g. a ModelMultipleChoiceField) is not saved. 
This is because unlike its parent class django.forms.ModelForm, UserCreationForm.save(commit=True) omits to call self.save_m2m(). 
This has been discussed on the #django-developers mailing list ​https://groups.google.com/u/1/g/django-developers/c/2jj-ecoBwE4 and I'm ready to work on a PR.
```

### `review.md`

```
verdict: PASS

- `django/contrib/auth/forms.py`: `UserCreationForm.save()` now calls `self.save_m2m()` immediately after `user.save()` inside the `if commit:` branch, which is exactly what the Prompt and Done when require; the `commit=False` path is untouched, so it still returns an unsaved user without persisting M2M data.
- `tests/auth_tests/test_forms.py`: adds `test_custom_form_with_many_to_many_field`, which builds a `UserCreationForm` subclass over a custom user model with a `ManyToManyField` (`orgs`), saves it, and asserts both organizations are related — real coverage of the fixed behaviour, not a tautology.
- The check `python tests/runtests.py auth_tests.test_forms` ran 88 tests and reported `OK` (status 0), so the new test and the existing auth forms suite pass with the change.
- Note (not a failure): `docs/releases/4.2.txt` is listed as OUTSIDE THE SCOPE. It is a release-note/changelog entry for the new behaviour, which the project's contribution conventions call for; per the review rules a changelog entry is a finding, not grounds to fail.
- Note: the test imports `tests/auth_tests/models/with_many_to_many.py` (`CustomUserWithM2M`, `Organization`), which does not appear in the diff. Since the check passes, that module is present in the tree; if it were newly added by this run it should have been included in the diff, but the passing suite confirms the tree is consistent.
```

### `scope.txt`

```
scope: django/contrib/auth/forms.py tests/auth_tests
changed: django/contrib/auth/forms.py +1 -0
OUTSIDE THE SCOPE: docs/releases/4.2.txt +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/auth_tests/test_forms.py +20 -0
```

### `task.md`

```
# Task

## Prompt

UserCreationForm should save data from ManyToMany form fields
Description
	
When using contrib.auth.forms.UserCreationForm with a custom User model which has ManyToManyField fields, the data in all related form fields (e.g. a ModelMultipleChoiceField) is not saved. 
This is because unlike its parent class django.forms.ModelForm, UserCreationForm.save(commit=True) omits to call self.save_m2m(). 
This has been discussed on the #django-developers mailing list ​https://groups.google.com/u/1/g/django-developers/c/2jj-ecoBwE4 and I'm ready to work on a PR.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py auth_tests.test_forms`

## Scope

`django/contrib/auth/forms.py`
`tests/auth_tests/`

## Done when

`UserCreationForm.save(commit=True)` calls `self.save_m2m()` after saving the user, so ManyToManyField form data is persisted.
`UserCreationForm.save(commit=False)` still returns an unsaved user and does not persist ManyToMany data.
The auth forms test suite passes with coverage for a custom user model containing a ManyToManyField.
```

### `test-output.log`

```
check: python tests/runtests.py auth_tests.test_forms
Creating test database for alias 'default'...
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 88 test(s).
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
........................................................................................
----------------------------------------------------------------------
Ran 88 tests in 0.211s

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
scope: django/contrib/auth/forms.py tests/auth_tests
changed: django/contrib/auth/forms.py +1 -0
OUTSIDE THE SCOPE: docs/releases/4.2.txt +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/auth_tests/test_forms.py +20 -0
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
