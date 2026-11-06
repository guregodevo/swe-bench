# django__django-16333 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 40s 54 lines cost=0.001653 in=123548 cached=114688 out=2498 calls=15`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

UserCreationForm should save data from ManyToMany form fields
Description
	
When using contrib.auth.forms.UserCreationForm with a custom User model which has ManyToManyField fields, the data in all related form fields (e.g. a ModelMultipleChoiceField) is not saved. 
This is because unlike its parent class django.forms.ModelForm, UserCreationForm.save(commit=True) omits to call self.save_m2m(). 
This has been discussed on the #django-developers mailing list ​https://groups.google.com/u/1/g/django-developers/c/2jj-ecoBwE4 and I'm ready to work on a PR.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain | head -50"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"save_m2m\\|class UserCreationForm\" django/contrib/auth/forms.py"
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

**tool result**

```
84:class UserCreationForm(forms.ModelForm):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/contrib/auth/forms.py",
  "offset": 80,
  "limit": 80
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

[328 more lines in /testbed/django/contrib/auth/forms.py (487 in all). read_file with offset: 160 to continue]
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
  "offset": 200,
  "limit": 80
}
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
  "command": "grep -n \"class ExtensionUser\\|ManyToMany\\|class CustomUser\" tests/auth_tests/models.py tests/auth_tests/test_forms.py | head -40"
}
```

**tool result**

```
grep: tests/auth_tests/models.py: No such file or directory
tests/auth_tests/test_forms.py:212:        class CustomUserCreationForm(UserCreationForm):
tests/auth_tests/test_forms.py:227:        class CustomUserCreationForm(UserCreationForm):
tests/auth_tests/test_forms.py:242:        class CustomUserCreationForm(UserCreationForm):
tests/auth_tests/test_forms.py:298:        class CustomUserCreationForm(UserCreationForm):
tests/auth_tests/test_forms.py:918:        class CustomUserChangeForm(UserChangeForm):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"class ExtensionUser\\|class CustomUser\\b\\|class CustomUser(\" tests/auth_tests/ | head"
}
```

**tool result**

```
tests/auth_tests/models/custom_user.py:41:class CustomUser(AbstractBaseUser):
tests/auth_tests/models/custom_user.py:114:    class ExtensionUser(AbstractUser):
tests/auth_tests/test_auth_backends.py:337:class ExtensionUserModelBackendTest(BaseModelBackendTest, TestCase):
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/models/custom_user.py"
}
```

**tool result**

```
from django.contrib.auth.models import (
    AbstractBaseUser,
    AbstractUser,
    BaseUserManager,
    Group,
    Permission,
    PermissionsMixin,
    UserManager,
)
from django.db import models


# The custom user uses email as the unique identifier, and requires
# that every user provide a date of birth. This lets us test
# changes in username datatype, and non-text required fields.
class CustomUserManager(BaseUserManager):
    def create_user(self, email, date_of_birth, password=None, **fields):
        """
        Creates and saves a User with the given email and password.
        """
        if not email:
            raise ValueError("Users must have an email address")

        user = self.model(
            email=self.normalize_email(email), date_of_birth=date_of_birth, **fields
        )

        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, date_of_birth, **fields):
        u = self.create_user(
            email, password=[redacted], date_of_birth=date_of_birth, **fields
        )
        u.is_admin = True
        u.save(using=self._db)
        return u


class CustomUser(AbstractBaseUser):
    email = models.EmailField(verbose_name="email address", max_length=255, unique=True)
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    date_of_birth = models.DateField()
    first_name = models.CharField(max_length=50)

    custom_objects = CustomUserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["date_of_birth", "first_name"]

    def __str__(self):
        return self.email

    # Maybe required?
    def get_group_permissions(self, obj=None):
        return set()

    def get_all_permissions(self, obj=None):
        return set()

    def has_perm(self, perm, obj=None):
        return True

    def has_perms(self, perm_list, obj=None):
        return True

    def has_module_perms(self, app_label):
        return True

    # Admin required fields
    @property
    def is_staff(self):
        return self.is_admin


class RemoveGroupsAndPermissions:
    """
    A context manager to temporarily remove the groups and user_permissions M2M
    fields from the AbstractUser class, so they don't clash with the
    related_name sets.
    """

    def __enter__(self):
        self._old_au_local_m2m = AbstractUser._meta.local_many_to_many
        self._old_pm_local_m2m = PermissionsMixin._meta.local_many_to_many
        groups = models.ManyToManyField(Group, blank=True)
        groups.contribute_to_class(PermissionsMixin, "groups")
        user_permissions = models.ManyToManyField(Permission, blank=True)
        user_permissions.contribute_to_class(PermissionsMixin, "user_permissions")
        PermissionsMixin._meta.local_many_to_many = [groups, user_permissions]
        AbstractUser._meta.local_many_to_many = [groups, user_permissions]

    def __exit__(self, exc_type, exc_value, traceback):
        AbstractUser._meta.local_many_to_many = self._old_au_local_m2m
        PermissionsMixin._meta.local_many_to_many = self._old_pm_local_m2m


class CustomUserWithoutIsActiveField(AbstractBaseUser):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)

    objects = UserManager()

    USERNAME_FIELD = "username"


# The extension user is a simple extension of the built-in user class,
# adding a required date_of_birth field. This allows us to check for
# any hard references to the name "User" in forms/handlers etc.
with RemoveGroupsAndPermissions():

    class ExtensionUser(AbstractUser):
        date_of_birth = models.DateField()

        custom_objects = UserManager()

        REQUIRED_FIELDS = AbstractUser.REQUIRED_FIELDS + ["date_of_birth"]
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/test_forms.py",
  "limit": 55
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



[1251 more lines in /testbed/tests/auth_tests/test_forms.py (1306 in all). read_file with offset: 56 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Group\\|groups\" tests/auth_tests/test_forms.py | head -20"
}
```

**tool result**

```
836:                    "groups"
837:                ].help_text = "These groups give users different permissions"
840:                fields = ("groups",)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/auth/forms.py\n@@\n     def save(self, commit=True):\n         user = super().save(commit=False)\n         user.set_password(self.cleaned_data[\"password1\"])\n         if commit:\n             user.save()\n+            self.save_m2m()\n         return user\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/auth/forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/auth/forms.py now (488 lines), around the change:
141:        user.set_password(self.cleaned_data["password1"])
142:        if commit:
143:            user.save()
144:            self.save_m2m()
145:        return user
146:
147:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/auth_tests/test_forms.py\n@@\n     def test_custom_form(self):\n         class CustomUserCreationForm(UserCreationForm):\n             class Meta(UserCreationForm.Meta):\n                 model = ExtensionUser\n                 fields = UserCreationForm.Meta.fields + (\"date_of_birth\",)\n@@\n         form = CustomUserCreationForm(data)\n         self.assertTrue(form.is_valid())\n \n+    def test_custom_form_with_many_to_many(self):\n+        class CustomUserCreationForm(UserCreationForm):\n+            class Meta(UserCreationForm.Meta):\n+                model = ExtensionUser\n+                fields = UserCreationForm.Meta.fields + (\n+                    \"date_of_birth\",\n+                    \"groups\",\n+                )\n+\n+        group = Group.objects.create(name=\"test_group\")\n+        data = {\n+            \"username\": \"testclient\",\n+            \"password1\": \"testclient\",\n+            \"password2\": \"testclient\",\n+            \"date_of_birth\": \"1988-02-24\",\n+            \"groups\": [group.pk],\n+        }\n+        form = CustomUserCreationForm(data)\n+        self.assertTrue(form.is_valid())\n+        user = form.save()\n+        self.assertSequenceEqual(user.groups.all(), [group])\n+\n     def test_custom_form_with_different_username_field(self):\n         class CustomUserCreationForm(UserCreationForm):\n             class Meta(UserCreationForm.Meta):\n                 model = CustomUser\n                 fields = (\"email\", \"date_of_birth\")\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/auth_tests/test_forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/auth_tests/test_forms.py now (1328 lines), around the change:
222:        }
223:        form = CustomUserCreationForm(data)
224:        self.assertTrue(form.is_valid())
225:
226:    def test_custom_form_with_many_to_many(self):
227:        class CustomUserCreationForm(UserCreationForm):
228:            class Meta(UserCreationForm.Meta):
229:                model = ExtensionUser
230:                fields = UserCreationForm.Meta.fields + (
231:                    "date_of_birth",
232:                    "groups",
233:                )
234:
235:        group = Group.objects.create(name="test_group")
236:        data = {
237:            "username": "testclient",
238:            "password1": "testclient",
239:            "password2": "testclient",
240:            "date_of_birth": "1988-02-24",
241:            "groups": [group.pk],
242:        }
243:        form = CustomUserCreationForm(data)
244:        self.assertTrue(form.is_valid())
245:        user = form.save()
246:        self.assertSequenceEqual(user.groups.all(), [group])
247:
248:    def test_custom_form_with_different_username_field(self):
249:        class CustomUserCreationForm(UserCreationForm):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/auth_tests/test_forms.py\n@@\n-from django.contrib.auth.models import User\n+from django.contrib.auth.models import Group, User\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/auth_tests/test_forms.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/auth_tests/test_forms.py now (1328 lines), around the change:
14:    UserChangeForm,
15:    UserCreationForm,
16:)
17:from django.contrib.auth.models import Group, User
18:from django.contrib.auth.signals import user_login_failed
19:from django.contrib.sites.models import Site
20:from django.core import mail
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
  "command": "cd tests && python runtests.py auth_tests.test_forms.UserCreationFormTest 2>&1 | tail -20"
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
Ran 18 tests in 0.051s

OK
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS"
}
```

**tool result**

```
PASS
```

**assistant**

```
Done. `UserCreationForm.save()` now calls `self.save_m2m()` when `commit=True`, so ManyToMany form fields are persisted. Added a regression test using `ExtensionUser` with the `groups` field; the auth form test suite passes (18 tests), and the completion command exits 0.
```

## Run folder `single-2026-11-06T112547`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
UserCreationForm should save data from ManyToMany form fields
Description
	
When using contrib.auth.forms.UserCreationForm with a custom User model which has ManyToManyField fields, the data in all related form fields (e.g. a ModelMultipleChoiceField) is not saved. 
This is because unlike its parent class django.forms.ModelForm, UserCreationForm.save(commit=True) omits to call self.save_m2m(). 
This has been discussed on the #django-developers mailing list ​https://groups.google.com/u/1/g/django-developers/c/2jj-ecoBwE4 and I'm ready to work on a PR.
```
