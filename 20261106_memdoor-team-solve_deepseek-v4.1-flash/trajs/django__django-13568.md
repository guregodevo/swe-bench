# django__django-13568 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 127s 46 lines cost=0.006309 in=109421 cached=80896 out=13394 calls=14`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Skip auth.E003 system check for USERNAME_FIELD with total UniqueConstraints.
Description
	
Defining a user model like this:
class User(AbstractBaseUser):
	username = models.CharField(max_length=30)
	USERNAME_FIELD = "username"
	class Meta:
		constraints = [UniqueConstraint(fields=["username"], name="user_username_unq")]
Will trigger auth.E003:
auth.User: (auth.E003) 'User.username' must be unique because it is named as the 'USERNAME_FIELD'.
Sometimes it’s not preferable to set the field as unique with unique=True as it will create an extra implicit *_like index for CharField and TextField on PostgresSQL. The system check should be extended to check for the presence of USERNAME_FIELD in Model._meta.constraints. Not really sure if this classifies as a bug.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && grep -rn \"E003\" django/contrib/auth/checks.py"
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
scripts
setup.cfg
setup.py
tests
tox.ini
64:                    id='auth.E003',
```

**assistant → tool `read_file`**

```json
{
  "path": "django/contrib/auth/checks.py"
}
```

**tool result**

```
from itertools import chain
from types import MethodType

from django.apps import apps
from django.conf import settings
from django.core import checks

from .management import _get_builtin_permissions


def check_user_model(app_configs=None, **kwargs):
    if app_configs is None:
        cls = apps.get_model(settings.AUTH_USER_MODEL)
    else:
        app_label, model_name = settings.AUTH_USER_MODEL.split('.')
        for app_config in app_configs:
            if app_config.label == app_label:
                cls = app_config.get_model(model_name)
                break
        else:
            # Checks might be run against a set of app configs that don't
            # include the specified user model. In this case we simply don't
            # perform the checks defined below.
            return []

    errors = []

    # Check that REQUIRED_FIELDS is a list
    if not isinstance(cls.REQUIRED_FIELDS, (list, tuple)):
        errors.append(
            checks.Error(
                "'REQUIRED_FIELDS' must be a list or tuple.",
                obj=cls,
                id='auth.E001',
            )
        )

    # Check that the USERNAME FIELD isn't included in REQUIRED_FIELDS.
    if cls.USERNAME_FIELD in cls.REQUIRED_FIELDS:
        errors.append(
            checks.Error(
                "The field named as the 'USERNAME_FIELD' "
                "for a custom user model must not be included in 'REQUIRED_FIELDS'.",
                hint=(
                    "The 'USERNAME_FIELD' is currently set to '%s', you "
                    "should remove '%s' from the 'REQUIRED_FIELDS'."
                    % (cls.USERNAME_FIELD, cls.USERNAME_FIELD)
                ),
                obj=cls,
                id='auth.E002',
            )
        )

    # Check that the username field is unique
    if not cls._meta.get_field(cls.USERNAME_FIELD).unique:
        if (settings.AUTHENTICATION_BACKENDS ==
                ['django.contrib.auth.backends.ModelBackend']):
            errors.append(
                checks.Error(
                    "'%s.%s' must be unique because it is named as the 'USERNAME_FIELD'." % (
                        cls._meta.object_name, cls.USERNAME_FIELD
                    ),
                    obj=cls,
                    id='auth.E003',
                )
            )
        else:
            errors.append(
                checks.Warning(
                    "'%s.%s' is named as the 'USERNAME_FIELD', but it is not unique." % (
                        cls._meta.object_name, cls.USERNAME_FIELD
                    ),
                    hint='Ensure that your authentication backend(s) can handle non-unique usernames.',
                    obj=cls,
                    id='auth.W004',
                )
            )

    if isinstance(cls().is_anonymous, MethodType):
        errors.append(
            checks.Critical(
                '%s.is_anonymous must be an attribute or property rather than '
                'a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % cls,
                obj=cls,
                id='auth.C009',
            )
        )
    if isinstance(cls().is_authenticated, MethodType):
        errors.append(
            checks.Critical(
                '%s.is_authenticated must be an attribute or property rather '
                'than a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % cls,
                obj=cls,
                id='auth.C010',
            )
        )
    return errors


def check_models_permissions(app_configs=None, **kwargs):
    if app_configs is None:
        models = apps.get_models()
    else:
        models = chain.from_iterable(app_config.get_models() for app_config in app_configs)

    Permission = apps.get_model('auth', 'Permission')
    permission_name_max_length = Permission._meta.get_field('name').max_length
    permission_codename_max_length = Permission._meta.get_field('codename').max_length
    errors = []

    for model in models:
        opts = model._meta
        builtin_permissions = dict(_get_builtin_permissions(opts))
        # Check builtin permission name length.
        max_builtin_permission_name_length = (
            max(len(name) for name in builtin_permissions.values())
            if builtin_permissions else 0
        )
        if max_builtin_permission_name_length > permission_name_max_length:
            verbose_name_max_length = (
                permission_name_max_length - (max_builtin_permission_name_length - len(opts.verbose_name_raw))
            )
            errors.append(
                checks.Error(
                    "The verbose_name of model '%s' must be at most %d "
                    "characters for its builtin permission names to be at "
                    "most %d characters." % (
                        opts.label, verbose_name_max_length, permission_name_max_length
                    ),
                    obj=model,
                    id='auth.E007',
                )
            )
        # Check builtin permission codename length.
        max_builtin_permission_codename_length = (
            max(len(codename) for codename in builtin_permissions.keys())
            if builtin_permissions else 0
        )
        if max_builtin_permission_codename_length > permission_codename_max_length:
            model_name_max_length = permission_codename_max_length - (
                max_builtin_permission_codename_length - len(opts.model_name)
            )
            errors.append(
                checks.Error(
                    "The name of model '%s' must be at most %d characters "
                    "for its builtin permission codenames to be at most %d "
                    "characters." % (
                        opts.label,
                        model_name_max_length,
                        permission_codename_max_length,
                    ),
                    obj=model,
                    id='auth.E011',
                )
            )
        codenames = set()
        for codename, name in opts.permissions:
            # Check custom permission name length.
            if len(name) > permission_name_max_length:
                errors.append(
                    checks.Error(
                        "The permission named '%s' of model '%s' is longer "
                        "than %d characters." % (
                            name, opts.label, permission_name_max_length,
                        ),
                        obj=model,
                        id='auth.E008',
                    )
                )
            # Check custom permission codename length.
            if len(codename) > permission_codename_max_length:
                errors.append(
                    checks.Error(
                        "The permission codenamed '%s' of model '%s' is "
                        "longer than %d characters." % (
                            codename,
                            opts.label,
                            permission_codename_max_length,
                        ),
                        obj=model,
                        id='auth.E012',
                    )
                )
            # Check custom permissions codename clashing.
            if codename in builtin_permissions:
                errors.append(
                    checks.Error(
                        "The permission codenamed '%s' clashes with a builtin permission "
                        "for model '%s'." % (codename, opts.label),
                        obj=model,
                        id='auth.E005',
                    )
                )
            elif codename in codenames:
                errors.append(
                    checks.Error(
                        "The permission codenamed '%s' is duplicated for "
                        "model '%s'." % (codename, opts.label),
                        obj=model,
                        id='auth.E006',
                    )
                )
            codenames.add(codename)

    return errors
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"E003\\|W004\" tests/auth_tests/test_checks.py | head -40; grep -rn \"class UniqueConstraint\" django/db/models/constraints.py"
}
```

**tool result**

```
73:                id='auth.E003',
84:                    id='auth.W004',
79:class UniqueConstraint(BaseConstraint):
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/auth_tests/test_checks.py",
  "limit": 130
}
```

**tool result**

```
from django.contrib.auth.checks import (
    check_models_permissions, check_user_model,
)
from django.contrib.auth.models import AbstractBaseUser
from django.core import checks
from django.db import models
from django.test import (
    SimpleTestCase, override_settings, override_system_checks,
)
from django.test.utils import isolate_apps

from .models import CustomUserNonUniqueUsername


@isolate_apps('auth_tests', attr_name='apps')
@override_system_checks([check_user_model])
class UserModelChecksTests(SimpleTestCase):
    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserNonListRequiredFields')
    def test_required_fields_is_list(self):
        """REQUIRED_FIELDS should be a list."""
        class CustomUserNonListRequiredFields(AbstractBaseUser):
            username = models.CharField(max_length=30, unique=True)
            date_of_birth = models.DateField()

            USERNAME_FIELD = 'username'
            REQUIRED_FIELDS = 'date_of_birth'

        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "'REQUIRED_FIELDS' must be a list or tuple.",
                obj=CustomUserNonListRequiredFields,
                id='auth.E001',
            ),
        ])

    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserBadRequiredFields')
    def test_username_not_in_required_fields(self):
        """USERNAME_FIELD should not appear in REQUIRED_FIELDS."""
        class CustomUserBadRequiredFields(AbstractBaseUser):
            username = models.CharField(max_length=30, unique=True)
            date_of_birth = models.DateField()

            USERNAME_FIELD = 'username'
            REQUIRED_FIELDS = ['username', 'date_of_birth']

        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The field named as the 'USERNAME_FIELD' for a custom user model "
                "must not be included in 'REQUIRED_FIELDS'.",
                hint=(
                    "The 'USERNAME_FIELD' is currently set to 'username', you "
                    "should remove 'username' from the 'REQUIRED_FIELDS'."
                ),
                obj=CustomUserBadRequiredFields,
                id='auth.E002',
            ),
        ])

    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserNonUniqueUsername')
    def test_username_non_unique(self):
        """
        A non-unique USERNAME_FIELD raises an error only if the default
        authentication backend is used. Otherwise, a warning is raised.
        """
        errors = checks.run_checks()
        self.assertEqual(errors, [
            checks.Error(
                "'CustomUserNonUniqueUsername.username' must be "
                "unique because it is named as the 'USERNAME_FIELD'.",
                obj=CustomUserNonUniqueUsername,
                id='auth.E003',
            ),
        ])
        with self.settings(AUTHENTICATION_BACKENDS=['my.custom.backend']):
            errors = checks.run_checks()
            self.assertEqual(errors, [
                checks.Warning(
                    "'CustomUserNonUniqueUsername.username' is named as "
                    "the 'USERNAME_FIELD', but it is not unique.",
                    hint='Ensure that your authentication backend(s) can handle non-unique usernames.',
                    obj=CustomUserNonUniqueUsername,
                    id='auth.W004',
                ),
            ])

    @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')
    def test_is_anonymous_authenticated_methods(self):
        """
        <User Model>.is_anonymous/is_authenticated must not be methods.
        """
        class BadUser(AbstractBaseUser):
            username = models.CharField(max_length=30, unique=True)
            USERNAME_FIELD = 'username'

            def is_anonymous(self):
                return True

            def is_authenticated(self):
                return True

        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Critical(
                '%s.is_anonymous must be an attribute or property rather than '
                'a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % BadUser,
                obj=BadUser,
                id='auth.C009',
            ),
            checks.Critical(
                '%s.is_authenticated must be an attribute or property rather '
                'than a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % BadUser,
                obj=BadUser,
                id='auth.C010',
            ),
        ])


@isolate_apps('auth_tests', attr_name='apps')
@override_system_checks([check_models_permissions])
class ModelsPermissionsChecksTests(SimpleTestCase):
    def test_clashing_default_permissions(self):
        class Checked(models.Model):
            class Meta:
                permissions = [
                    ('change_checked', 'Can edit permission (duplicate)')
                ]

[109 more lines in /testbed/tests/auth_tests/test_checks.py (239 in all). read_file with offset: 131 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"total_unique_constraints\\|def total_unique\" django/db/models/options.py django/db/models/constraints.py"
}
```

**tool result**

```
django/db/models/options.py:832:    def total_unique_constraints(self):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/db/models/options.py",
  "offset": 820,
  "limit": 30
}
```

**tool result**

```
            if topmost_call:
                fields += self.private_fields

        # In order to avoid list manipulation. Always
        # return a shallow copy of the results
        fields = make_immutable_fields_list("get_fields()", fields)

        # Store result into cache for later access
        self._get_fields_cache[cache_key] = fields
        return fields

    @cached_property
    def total_unique_constraints(self):
        """
        Return a list of total unique constraints. Useful for determining set
        of fields guaranteed to be unique for all rows.
        """
        return [
            constraint
            for constraint in self.constraints
            if isinstance(constraint, UniqueConstraint) and constraint.condition is None
        ]

    @cached_property
    def _property_names(self):
        """Return a set of the names of the properties defined on the model."""
        names = []
        for name in dir(self.model):
            attr = inspect.getattr_static(self.model, name)
            if isinstance(attr, property):

[13 more lines in /testbed/django/db/models/options.py (862 in all). read_file with offset: 850 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/auth/checks.py\n@@\n-    # Check that the username field is unique\n-    if not cls._meta.get_field(cls.USERNAME_FIELD).unique:\n+    # Check that the username field is unique\n+    if not cls._meta.get_field(cls.USERNAME_FIELD).unique and not any(\n+        constraint.fields == (cls.USERNAME_FIELD,)\n+        for constraint in cls._meta.total_unique_constraints\n+    ):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/auth/checks.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/auth/checks.py now (210 lines), around the change:
52:        )
53:
54:    # Check that the username field is unique
55:    if not cls._meta.get_field(cls.USERNAME_FIELD).unique and not any(
56:        constraint.fields == (cls.USERNAME_FIELD,)
57:        for constraint in cls._meta.total_unique_constraints
58:    ):
59:        if (settings.AUTHENTICATION_BACKENDS ==
60:                ['django.contrib.auth.backends.ModelBackend']):
61:            errors.append(
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/auth_tests/test_checks.py\n@@\n     @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')\n     def test_is_anonymous_authenticated_methods(self):\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/auth_tests/test_checks.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file test_checks.py and REWRITE it with *** Add File: test_checks.py using its ACTUAL content plus your change
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/auth_tests/test_checks.py\n@@\n-    @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')\n+    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserUniqueConstraint')\n+    def test_username_unique_constraint(self):\n+        \"\"\"\n+        A USERNAME_FIELD with a UniqueConstraint doesn't raise an error.\n+        \"\"\"\n+        class CustomUserUniqueConstraint(AbstractBaseUser):\n+            username = models.CharField(max_length=30)\n+            USERNAME_FIELD = 'username'\n+\n+            class Meta:\n+                constraints = [\n+                    models.UniqueConstraint(\n+                        fields=['username'], name='user_username_unq',\n+                    ),\n+                ]\n+\n+        errors = checks.run_checks(app_configs=self.apps.get_app_configs())\n+        self.assertEqual(errors, [])\n+\n+    @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')\n     def test_is_anonymous_authenticated_methods(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/auth_tests/test_checks.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/auth_tests/test_checks.py now (258 lines), around the change:
85:                ),
86:            ])
87:
88:    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserUniqueConstraint')
89:    def test_username_unique_constraint(self):
90:        """
91:        A USERNAME_FIELD with a UniqueConstraint doesn't raise an error.
92:        """
93:        class CustomUserUniqueConstraint(AbstractBaseUser):
94:            username = models.CharField(max_length=30)
95:            USERNAME_FIELD = 'username'
96:
97:            class Meta:
98:                constraints = [
99:                    models.UniqueConstraint(
100:                        fields=['username'], name='user_username_unq',
101:                    ),
102:                ]
103:
104:        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
105:        self.assertEqual(errors, [])
106:
107:    @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')
108:    def test_is_anonymous_authenticated_methods(self):
109:        """
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/auth_tests/test_checks.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py auth_tests.test_checks 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
.............
----------------------------------------------------------------------
Ran 13 tests in 0.157s

OK
```

**assistant**

````
Implemented the fix.

**Change** — `django/contrib/auth/checks.py`: `auth.E003`/`auth.W004` now only fire when the `USERNAME_FIELD` is neither `unique=True` nor covered by a total `UniqueConstraint` on that single field:

```python
if not cls._meta.get_field(cls.USERNAME_FIELD).unique and not any(
    constraint.fields == (cls.USERNAME_FIELD,)
    for constraint in cls._meta.total_unique_constraints
):
```

`total_unique_constraints` excludes conditional constraints, so only constraints that guarantee uniqueness for all rows satisfy the check.

**Test** — added `test_username_unique_constraint` in `tests/auth_tests/test_checks.py`, defining a user model with a non-unique `CharField` plus `UniqueConstraint(fields=['username'], ...)` and asserting no system-check errors.

**Verification** — `python runtests.py auth_tests.test_checks`: 13 tests, all OK. No commits or tree changes beyond the two files.
````

## Run folder `team-solve-2026-11-06T110201`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
bbb95199d070ffe90a93a8f0fef0a39c90dadc1f
```

### `baseline-check.log`

```
check: python tests/runtests.py auth_tests.test_checks
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
............
----------------------------------------------------------------------
Ran 12 tests in 0.138s

OK
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/django/contrib/auth/checks.py b/django/contrib/auth/checks.py
index 65fc266f7e..c08ed8a49a 100644
--- a/django/contrib/auth/checks.py
+++ b/django/contrib/auth/checks.py
@@ -52,7 +52,10 @@ def check_user_model(app_configs=None, **kwargs):
         )
 
     # Check that the username field is unique
-    if not cls._meta.get_field(cls.USERNAME_FIELD).unique:
+    if not cls._meta.get_field(cls.USERNAME_FIELD).unique and not any(
+        constraint.fields == (cls.USERNAME_FIELD,)
+        for constraint in cls._meta.total_unique_constraints
+    ):
         if (settings.AUTHENTICATION_BACKENDS ==
                 ['django.contrib.auth.backends.ModelBackend']):
             errors.append(
diff --git a/tests/auth_tests/test_checks.py b/tests/auth_tests/test_checks.py
index cfaa4063f8..53f1c7fe47 100644
--- a/tests/auth_tests/test_checks.py
+++ b/tests/auth_tests/test_checks.py
@@ -85,6 +85,25 @@ class UserModelChecksTests(SimpleTestCase):
                 ),
             ])
 
+    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserUniqueConstraint')
+    def test_username_unique_constraint(self):
+        """
+        A USERNAME_FIELD with a UniqueConstraint doesn't raise an error.
+        """
+        class CustomUserUniqueConstraint(AbstractBaseUser):
+            username = models.CharField(max_length=30)
+            USERNAME_FIELD = 'username'
+
+            class Meta:
+                constraints = [
+                    models.UniqueConstraint(
+                        fields=['username'], name='user_username_unq',
+                    ),
+                ]
+
+        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
+        self.assertEqual(errors, [])
+
     @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')
     def test_is_anonymous_authenticated_methods(self):
         """
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

Skip auth.E003 system check for USERNAME_FIELD with total UniqueConstraints.
Description
	
Defining a user model like this:
class User(AbstractBaseUser):
	username = models.CharField(max_length=30)
	USERNAME_FIELD = "username"
	class Meta:
		constraints = [UniqueConstraint(fields=["username"], name="user_username_unq")]
Will trigger auth.E003:
auth.User: (auth.E003) 'User.username' must be unique because it is named as the 'USERNAME_FIELD'.
Sometimes it’s not preferable to set the field as unique with unique=True as it will create an extra implicit *_like index for CharField and TextField on PostgresSQL. The system check should be extended to check for the presence of USERNAME_FIELD in Model._meta.constraints. Not really sure if this classifies as a bug.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py auth_tests.test_checks`

## Scope

`django/contrib/auth/checks.py`
`tests/auth_tests/test_checks.py`

## Done when

A custom user model whose `USERNAME_FIELD` is not `unique=True` but has a matching total `UniqueConstraint` in `Meta.constraints` produces no `auth.E003`.
A custom user model whose `USERNAME_FIELD` is neither `unique=True` nor covered by a matching `UniqueConstraint` still produces `auth.E003`.
A matching constraint is one that uniquely covers the `USERNAME_FIELD` alone, not merely a constraint that happens to include it among other fields (inferred).
Existing behavior for `USERNAME_FIELD` fields declared with `unique=True` is unchanged.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py auth_tests.test_checks`

## Scope
`django/contrib/auth/checks.py`
`tests/auth_tests/test_checks.py`

## Done when
A custom user model whose `USERNAME_FIELD` is not `unique=True` but has a matching total `UniqueConstraint` in `Meta.constraints` produces no `auth.E003`.
A custom user model whose `USERNAME_FIELD` is neither `unique=True` nor covered by a matching `UniqueConstraint` still produces `auth.E003`.
A matching constraint is one that uniquely covers the `USERNAME_FIELD` alone, not merely a constraint that happens to include it among other fields (inferred).
Existing behavior for `USERNAME_FIELD` fields declared with `unique=True` is unchanged.

## Approach
Change `_check_username_unicity` in `django/contrib/auth/checks.py` so that after checking the field’s `unique` flag it scans `UserModel._meta.constraints` for a `UniqueConstraint` whose `fields` equal `(UserModel.USERNAME_FIELD,)`; if found, return no errors, otherwise return the existing `auth.E003`. Add regression tests to `tests/auth_tests/test_checks.py` for the constraint case and the still-invalid case.

Candidate approaches:
- Directly scan `_meta.constraints` for an exact single-field `UniqueConstraint`, matching the prompt’s wording and keeping the change narrow.
- Use `_meta.total_unique_constraints`; broader, may also recognize `unique_together`, but changes behavior beyond the requested constraints.
- Add a `condition is None` guard for “total” constraints; safer against partial constraints, but verify against the upstream test expectations before keeping it.


# django/contrib/auth/checks.py

```
from itertools import chain
from types import MethodType

from django.apps import apps
from django.conf import settings
from django.core import checks

from .management import _get_builtin_permissions


def check_user_model(app_configs=None, **kwargs):
    if app_configs is None:
        cls = apps.get_model(settings.AUTH_USER_MODEL)
    else:
        app_label, model_name = settings.AUTH_USER_MODEL.split('.')
        for app_config in app_configs:
            if app_config.label == app_label:
                cls = app_config.get_model(model_name)
                break
        else:
            # Checks might be run against a set of app configs that don't
            # include the specified user model. In this case we simply don't
            # perform the checks defined below.
            return []

    errors = []

    # Check that REQUIRED_FIELDS is a list
    if not isinstance(cls.REQUIRED_FIELDS, (list, tuple)):
        errors.append(
            checks.Error(
                "'REQUIRED_FIELDS' must be a list or tuple.",
                obj=cls,
                id='auth.E001',
            )
        )

    # Check that the USERNAME FIELD isn't included in REQUIRED_FIELDS.
    if cls.USERNAME_FIELD in cls.REQUIRED_FIELDS:
        errors.append(
            checks.Error(
                "The field named as the 'USERNAME_FIELD' "
                "for a custom user model must not be included in 'REQUIRED_FIELDS'.",
                hint=(
                    "The 'USERNAME_FIELD' is currently set to '%s', you "
                    "should remove '%s' from the 'REQUIRED_FIELDS'."
                    % (cls.USERNAME_FIELD, cls.USERNAME_FIELD)
                ),
                obj=cls,
                id='auth.E002',
            )
        )

    # Check that the username field is unique
    if not cls._meta.get_field(cls.USERNAME_FIELD).unique and not any(
        constraint.fields == (cls.USERNAME_FIELD,)
        for constraint in cls._meta.total_unique_constraints
    ):
        if (settings.AUTHENTICATION_BACKENDS ==
                ['django.contrib.auth.backends.ModelBackend']):
            errors.append(
                checks.Error(
                    "'%s.%s' must be unique because it is named as the 'USERNAME_FIELD'." % (
                        cls._meta.object_name, cls.USERNAME_FIELD
                    ),
                    obj=cls,
                    id='auth.E003',
                )
            )
        else:
            errors.append(
                checks.Warning(
                    "'%s.%s' is named as the 'USERNAME_FIELD', but it is not unique." % (
                        cls._meta.object_name, cls.USERNAME_FIELD
                    ),
                    hint='Ensure that your authentication backend(s) can handle non-unique usernames.',
                    obj=cls,
                    id='auth.W004',
                )
            )

    if isinstance(cls().is_anonymous, MethodType):
        errors.append(
            checks.Critical(
                '%s.is_anonymous must be an attribute or property rather than '
                'a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % cls,
                obj=cls,
                id='auth.C009',
            )
        )
    if isinstance(cls().is_authenticated, MethodType):
        errors.append(
            checks.Critical(
                '%s.is_authenticated must be an attribute or property rather '
                'than a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % cls,
                obj=cls,
                id='auth.C010',
            )
        )
    return errors


def check_models_permissions(app_configs=None, **kwargs):
    if app_configs is None:
        models = apps.get_models()
    else:
        models = chain.from_iterable(app_config.get_models() for app_config in app_configs)

    Permission = apps.get_model('auth', 'Permission')
    permission_name_max_length = Permission._meta.get_field('name').max_length
    permission_codename_max_length = Permission._meta.get_field('codename').max_length
    errors = []

    for model in models:
        opts = model._meta
        builtin_permissions = dict(_get_builtin_permissions(opts))
        # Check builtin permission name length.
        max_builtin_permission_name_length = (
            max(len(name) for name in builtin_permissions.values())
            if builtin_permissions else 0
        )
        if max_builtin_permission_name_length > permission_name_max_length:
            verbose_name_max_length = (
                permission_name_max_length - (max_builtin_permission_name_length - len(opts.verbose_name_raw))
            )
            errors.append(
                checks.Error(
                    "The verbose_name of model '%s' must be at most %d "
                    "characters for its builtin permission names to be at "
                    "most %d characters." % (
                        opts.label, verbose_name_max_length, permission_name_max_length
                    ),
                    obj=model,
                    id='auth.E007',
                )
            )
        # Check builtin permission codename length.
        max_builtin_permission_codename_length = (
            max(len(codename) for codename in builtin_permissions.keys())
            if builtin_permissions else 0
        )
        if max_builtin_permission_codename_length > permission_codename_max_length:
            model_name_max_length = permission_codename_max_length - (
                max_builtin_permission_codename_length - len(opts.model_name)
            )
            errors.append(
                checks.Error(
                    "The name of model '%s' must be at most %d characters "
                    "for its builtin permission codenames to be at most %d "
                    "characters." % (
                        opts.label,
                        model_name_max_length,
                        permission_codename_max_length,
                    ),
                    obj=model,
                    id='auth.E011',
                )
            )
        codenames = set()
        for codename, name in opts.permissions:
            # Check custom permission name length.
            if len(name) > permission_name_max_length:
                errors.append(
                    checks.Error(
                        "The permission named '%s' of model '%s' is longer "
                        "than %d characters." % (
                            name, opts.label, permission_name_max_length,
                        ),
                        obj=model,
                        id='auth.E008',
                    )
                )
            # Check custom permission codename length.
            if len(codename) > permission_codename_max_length:
                errors.append(
                    checks.Error(
                        "The permission codenamed '%s' of model '%s' is "
                        "longer than %d characters." % (
                            codename,
                            opts.label,
                            permission_codename_max_length,
                        ),
                        obj=model,
                        id='auth.E012',
                    )
                )
            # Check custom permissions codename clashing.
            if codename in builtin_permissions:
                errors.append(
                    checks.Error(
                        "The permission codenamed '%s' clashes with a builtin permission "
                        "for model '%s'." % (codename, opts.label),
                        obj=model,
                        id='auth.E005',
                    )
                )
            elif codename in codenames:
                errors.append(
                    checks.Error(
                        "The permission codenamed '%s' is duplicated for "
                        "model '%s'." % (codename, opts.label),
                        obj=model,
                        id='auth.E006',
                    )
                )
            codenames.add(codename)

    return errors

```


# tests/auth_tests/test_checks.py

```
from django.contrib.auth.checks import (
    check_models_permissions, check_user_model,
)
from django.contrib.auth.models import AbstractBaseUser
from django.core import checks
from django.db import models
from django.test import (
    SimpleTestCase, override_settings, override_system_checks,
)
from django.test.utils import isolate_apps

from .models import CustomUserNonUniqueUsername


@isolate_apps('auth_tests', attr_name='apps')
@override_system_checks([check_user_model])
class UserModelChecksTests(SimpleTestCase):
    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserNonListRequiredFields')
    def test_required_fields_is_list(self):
        """REQUIRED_FIELDS should be a list."""
        class CustomUserNonListRequiredFields(AbstractBaseUser):
            username = models.CharField(max_length=30, unique=True)
            date_of_birth = models.DateField()

            USERNAME_FIELD = 'username'
            REQUIRED_FIELDS = 'date_of_birth'

        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "'REQUIRED_FIELDS' must be a list or tuple.",
                obj=CustomUserNonListRequiredFields,
                id='auth.E001',
            ),
        ])

    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserBadRequiredFields')
    def test_username_not_in_required_fields(self):
        """USERNAME_FIELD should not appear in REQUIRED_FIELDS."""
        class CustomUserBadRequiredFields(AbstractBaseUser):
            username = models.CharField(max_length=30, unique=True)
            date_of_birth = models.DateField()

            USERNAME_FIELD = 'username'
            REQUIRED_FIELDS = ['username', 'date_of_birth']

        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The field named as the 'USERNAME_FIELD' for a custom user model "
                "must not be included in 'REQUIRED_FIELDS'.",
                hint=(
                    "The 'USERNAME_FIELD' is currently set to 'username', you "
                    "should remove 'username' from the 'REQUIRED_FIELDS'."
                ),
                obj=CustomUserBadRequiredFields,
                id='auth.E002',
            ),
        ])

    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserNonUniqueUsername')
    def test_username_non_unique(self):
        """
        A non-unique USERNAME_FIELD raises an error only if the default
        authentication backend is used. Otherwise, a warning is raised.
        """
        errors = checks.run_checks()
        self.assertEqual(errors, [
            checks.Error(
                "'CustomUserNonUniqueUsername.username' must be "
                "unique because it is named as the 'USERNAME_FIELD'.",
                obj=CustomUserNonUniqueUsername,
                id='auth.E003',
            ),
        ])
        with self.settings(AUTHENTICATION_BACKENDS=['my.custom.backend']):
            errors = checks.run_checks()
            self.assertEqual(errors, [
                checks.Warning(
                    "'CustomUserNonUniqueUsername.username' is named as "
                    "the 'USERNAME_FIELD', but it is not unique.",
                    hint='Ensure that your authentication backend(s) can handle non-unique usernames.',
                    obj=CustomUserNonUniqueUsername,
                    id='auth.W004',
                ),
            ])

    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserUniqueConstraint')
    def test_username_unique_constraint(self):
        """
        A USERNAME_FIELD with a UniqueConstraint doesn't raise an error.
        """
        class CustomUserUniqueConstraint(AbstractBaseUser):
            username = models.CharField(max_length=30)
            USERNAME_FIELD = 'username'

            class Meta:
                constraints = [
                    models.UniqueConstraint(
                        fields=['username'], name='user_username_unq',
                    ),
                ]

        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
        self.assertEqual(errors, [])

    @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')
    def test_is_anonymous_authenticated_methods(self):
        """
        <User Model>.is_anonymous/is_authenticated must not be methods.
        """
        class BadUser(AbstractBaseUser):
            username = models.CharField(max_length=30, unique=True)
            USERNAME_FIELD = 'username'

            def is_anonymous(self):
                return True

            def is_authenticated(self):
                return True

        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Critical(
                '%s.is_anonymous must be an attribute or property rather than '
                'a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % BadUser,
                obj=BadUser,
                id='auth.C009',
            ),
            checks.Critical(
                '%s.is_authenticated must be an attribute or property rather '
                'than a method. Ignoring this is a security issue as anonymous '
                'users will be treated as authenticated!' % BadUser,
                obj=BadUser,
                id='auth.C010',
            ),
        ])


@isolate_apps('auth_tests', attr_name='apps')
@override_system_checks([check_models_permissions])
class ModelsPermissionsChecksTests(SimpleTestCase):
    def test_clashing_default_permissions(self):
        class Checked(models.Model):
            class Meta:
                permissions = [
                    ('change_checked', 'Can edit permission (duplicate)')
                ]
        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The permission codenamed 'change_checked' clashes with a builtin "
                "permission for model 'auth_tests.Checked'.",
                obj=Checked,
                id='auth.E005',
            ),
        ])

    def test_non_clashing_custom_permissions(self):
        class Checked(models.Model):
            class Meta:
                permissions = [
                    ('my_custom_permission', 'Some permission'),
                    ('other_one', 'Some other permission'),
                ]
        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [])

    def test_clashing_custom_permissions(self):
        class Checked(models.Model):
            class Meta:
                permissions = [
                    ('my_custom_permission', 'Some permission'),
                    ('other_one', 'Some other permission'),
                    ('my_custom_permission', 'Some permission with duplicate permission code'),
                ]
        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The permission codenamed 'my_custom_permission' is duplicated for "
                "model 'auth_tests.Checked'.",
                obj=Checked,
                id='auth.E006',
            ),
        ])

    def test_verbose_name_max_length(self):
        class Checked(models.Model):
            class Meta:
                verbose_name = 'some ridiculously long verbose name that is out of control' * 5
        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The verbose_name of model 'auth_tests.Checked' must be at most 244 "
                "characters for its builtin permission names to be at most 255 characters.",
                obj=Checked,
                id='auth.E007',
            ),
        ])

    def test_model_name_max_length(self):
        model_name = 'X' * 94
        model = type(model_name, (models.Model,), {'__module__': self.__module__})
        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The name of model 'auth_tests.%s' must be at most 93 "
                "characters for its builtin permission codenames to be at "
                "most 100 characters." % model_name,
                obj=model,
                id='auth.E011',
            ),
        ])

    def test_custom_permission_name_max_length(self):
        custom_permission_name = 'some ridiculously long verbose name that is out of control' * 5

        class Checked(models.Model):
            class Meta:
                permissions = [
                    ('my_custom_permission', custom_permission_name),
                ]
        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The permission named '%s' of model 'auth_tests.Checked' is longer "
                "than 255 characters." % custom_permission_name,
                obj=Checked,
                id='auth.E008',
            ),
        ])

    def test_custom_permission_codename_max_length(self):
        custom_permission_codename = 'x' * 101

        class Checked(models.Model):
            class Meta:
                permissions = [
                    (custom_permission_codename, 'Custom permission'),
                ]

        errors = checks.run_checks(self.apps.get_app_configs())
        self.assertEqual(errors, [
            checks.Error(
                "The permission codenamed '%s' of model 'auth_tests.Checked' "
                "is longer than 100 characters." % custom_permission_codename,
                obj=Checked,
                id='auth.E012',
            ),
        ])

    def test_empty_default_permissions(self):
        class Checked(models.Model):
            class Meta:
                default_permissions = ()

        self.assertEqual(checks.run_checks(self.apps.get_app_configs()), [])

```


# The last commit

```
bbb95199d0 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py auth_tests.test_checks
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
.............
----------------------------------------------------------------------
Ran 13 tests in 0.138s

OK
scope: django/contrib/auth/checks.py tests/auth_tests/test_checks.py
changed: django/contrib/auth/checks.py +4 -1
changed: tests/auth_tests/test_checks.py +19 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/contrib/auth/checks.py b/django/contrib/auth/checks.py
index 65fc266f7e..c08ed8a49a 100644
--- a/django/contrib/auth/checks.py
+++ b/django/contrib/auth/checks.py
@@ -52,7 +52,10 @@ def check_user_model(app_configs=None, **kwargs):
         )
 
     # Check that the username field is unique
-    if not cls._meta.get_field(cls.USERNAME_FIELD).unique:
+    if not cls._meta.get_field(cls.USERNAME_FIELD).unique and not any(
+        constraint.fields == (cls.USERNAME_FIELD,)
+        for constraint in cls._meta.total_unique_constraints
+    ):
         if (settings.AUTHENTICATION_BACKENDS ==
                 ['django.contrib.auth.backends.ModelBackend']):
             errors.append(
diff --git a/tests/auth_tests/test_checks.py b/tests/auth_tests/test_checks.py
index cfaa4063f8..53f1c7fe47 100644
--- a/tests/auth_tests/test_checks.py
+++ b/tests/auth_tests/test_checks.py
@@ -85,6 +85,25 @@ class UserModelChecksTests(SimpleTestCase):
                 ),
             ])
 
+    @override_settings(AUTH_USER_MODEL='auth_tests.CustomUserUniqueConstraint')
+    def test_username_unique_constraint(self):
+        """
+        A USERNAME_FIELD with a UniqueConstraint doesn't raise an error.
+        """
+        class CustomUserUniqueConstraint(AbstractBaseUser):
+            username = models.CharField(max_length=30)
+            USERNAME_FIELD = 'username'
+
+            class Meta:
+                constraints = [
+                    models.UniqueConstraint(
+                        fields=['username'], name='user_username_unq',
+                    ),
+                ]
+
+        errors = checks.run_checks(app_configs=self.apps.get_app_configs())
+        self.assertEqual(errors, [])
+
     @override_settings(AUTH_USER_MODEL='auth_tests.BadUser')
     def test_is_anonymous_authenticated_methods(self):
         """
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
check: python tests/runtests.py auth_tests.test_checks
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
.............
----------------------------------------------------------------------
Ran 13 tests in 0.126s

OK
scope: django/contrib/auth/checks.py tests/auth_tests/test_checks.py
changed: django/contrib/auth/checks.py +4 -1
changed: tests/auth_tests/test_checks.py +19 -0
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
# Notes, run 2026-11-06T110201

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Skip auth.E003 system check for USERNAME_FIELD with total UniqueConstraints.
Description
	
Defining a user model like this:
class User(AbstractBaseUser):
	username = models.CharField(max_length=30)
	USERNAME_FIELD = "username"
	class Meta:
		constraints = [UniqueConstraint(fields=["username"], name="user_username_unq")]
Will trigger auth.E003:
auth.User: (auth.E003) 'User.username' must be unique because it is named as the 'USERNAME_FIELD'.
Sometimes it’s not preferable to set the field as unique with unique=True as it will create an extra implicit *_like index for CharField and TextField on PostgresSQL. The system check should be extended to check for the presence of USERNAME_FIELD in Model._meta.constraints. Not really sure if this classifies as a bug.


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.gitattributes
.github/FUNDING.yml
.github/SECURITY.md
.gitignore
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
```


# The last commit

```
bbb95199d0 SWE-bench


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
    "eslint": "^6.8.0",
    "grunt": "^1.0.1",
    "grunt-cli": "^1.2.0",
    "grunt-contrib-qunit": "^3.1.0",
    "qunit": "^2.9.3"
  }
}

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python tests/runtests.py auth_tests.test_checks`

## Scope
`django/contrib/auth/checks.py`
`tests/auth_tests/test_checks.py`

## Done when
A custom user model whose `USERNAME_FIELD` is not `unique=True` but has a matching total `UniqueConstraint` in `Meta.constraints` produces no `auth.E003`.
A custom user model whose `USERNAME_FIELD` is neither `unique=True` nor covered by a matching `UniqueConstraint` still produces `auth.E003`.
A matching constraint is one that uniquely covers the `USERNAME_FIELD` alone, not merely a constraint that happens to include it among other fields (inferred).
Existing behavior for `USERNAME_FIELD` fields declared with `unique=True` is unchanged.

## Approach
Change `_check_username_unicity` in `django/contrib/auth/checks.py` so that after checking the field’s `unique` flag it scans `UserModel._meta.constraints` for a `UniqueConstraint` whose `fields` equal `(UserModel.USERNAME_FIELD,)`; if found, return no errors, otherwise return the existing `auth.E003`. Add regression tests to `tests/auth_tests/test_checks.py` for the constraint case and the still-invalid case.

Candidate approaches:
- Directly scan `_meta.constraints` for an exact single-field `UniqueConstraint`, matching the prompt’s wording and keeping the change narrow.
- Use `_meta.total_unique_constraints`; broader, may also recognize `unique_together`, but changes behavior beyond the requested constraints.
- Add a `condition is None` guard for “total” constraints; safer against partial constraints, but verify against the upstream test expectations before keeping it.
```

### `prompt.md`

```
Skip auth.E003 system check for USERNAME_FIELD with total UniqueConstraints.
Description
	
Defining a user model like this:
class User(AbstractBaseUser):
	username = models.CharField(max_length=30)
	USERNAME_FIELD = "username"
	class Meta:
		constraints = [UniqueConstraint(fields=["username"], name="user_username_unq")]
Will trigger auth.E003:
auth.User: (auth.E003) 'User.username' must be unique because it is named as the 'USERNAME_FIELD'.
Sometimes it’s not preferable to set the field as unique with unique=True as it will create an extra implicit *_like index for CharField and TextField on PostgresSQL. The system check should be extended to check for the presence of USERNAME_FIELD in Model._meta.constraints. Not really sure if this classifies as a bug.
```

### `review.md`

```
verdict: PASS

Findings:
- `django/contrib/auth/checks.py` now skips `auth.E003` when the `USERNAME_FIELD` is either `unique=True` or matched by a total `UniqueConstraint` whose `fields` tuple is exactly `(USERNAME_FIELD,)`, satisfying the "alone, not among other fields" requirement.
- Using `_meta.total_unique_constraints` correctly restricts the match to unconditional `UniqueConstraint`s (consistent with the "total" wording in the prompt) and excludes conditional/expression constraints, which would not guarantee uniqueness.
- `constraint.fields` is stored as a tuple by `UniqueConstraint.__init__`, so the `== (cls.USERNAME_FIELD,)` comparison is sound.
- The new test exercises the positive case (constraint present → no errors) and the existing `test_username_unique`/`test_username_non_unique` tests still cover the negative case; the check run reports 13 tests OK, so existing behavior for `unique=True` is unchanged.
- Only the two in-scope files were touched; no unrelated behavior was changed or content removed.
- Note (not a failure reason, inferred/coverage): no new test asserts the negative case for a constraint that merely includes `USERNAME_FIELD` among other fields, nor a conditional constraint; the implementation handles both correctly, so this is only a test-coverage suggestion.
```

### `scope.txt`

```
scope: django/contrib/auth/checks.py tests/auth_tests/test_checks.py
changed: django/contrib/auth/checks.py +4 -1
changed: tests/auth_tests/test_checks.py +19 -0
```

### `task.md`

```
# Task

## Prompt

Skip auth.E003 system check for USERNAME_FIELD with total UniqueConstraints.
Description
	
Defining a user model like this:
class User(AbstractBaseUser):
	username = models.CharField(max_length=30)
	USERNAME_FIELD = "username"
	class Meta:
		constraints = [UniqueConstraint(fields=["username"], name="user_username_unq")]
Will trigger auth.E003:
auth.User: (auth.E003) 'User.username' must be unique because it is named as the 'USERNAME_FIELD'.
Sometimes it’s not preferable to set the field as unique with unique=True as it will create an extra implicit *_like index for CharField and TextField on PostgresSQL. The system check should be extended to check for the presence of USERNAME_FIELD in Model._meta.constraints. Not really sure if this classifies as a bug.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py auth_tests.test_checks`

## Scope

`django/contrib/auth/checks.py`
`tests/auth_tests/test_checks.py`

## Done when

A custom user model whose `USERNAME_FIELD` is not `unique=True` but has a matching total `UniqueConstraint` in `Meta.constraints` produces no `auth.E003`.
A custom user model whose `USERNAME_FIELD` is neither `unique=True` nor covered by a matching `UniqueConstraint` still produces `auth.E003`.
A matching constraint is one that uniquely covers the `USERNAME_FIELD` alone, not merely a constraint that happens to include it among other fields (inferred).
Existing behavior for `USERNAME_FIELD` fields declared with `unique=True` is unchanged.
```

### `test-output.log`

```
check: python tests/runtests.py auth_tests.test_checks
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
.............
----------------------------------------------------------------------
Ran 13 tests in 0.138s

OK
scope: django/contrib/auth/checks.py tests/auth_tests/test_checks.py
changed: django/contrib/auth/checks.py +4 -1
changed: tests/auth_tests/test_checks.py +19 -0
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
