# django__django-15127 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 25s 71 lines cost=0.001084 in=69768 cached=54784 out=1339 calls=10`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

LEVEL_TAGS not updated when using @override_settings
Description
	
When reading messages inside tests, new message tags created using @override_settings is not updated.
That causes the django.contrib.messages.storage.base.Message.level_tag property results to be an empty string and not know the new tags.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain -- . ':(exclude).memdoor' && git log --oneline -3"
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
e257092b4d SWE-bench
9a6e2df3a8 Fixed #32397 -- Made startapp/startproject management commands set User-Agent.
e361621dbc Removed unneeded can_use_chunked_reads feature flag on SQLite.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"LEVEL_TAGS\" django/contrib/messages | head -30"
}
```

**tool result**

```
django/contrib/messages/storage/base.py:4:LEVEL_TAGS = utils.get_level_tags()
django/contrib/messages/storage/base.py:41:        return LEVEL_TAGS.get(self.level, '')
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,80p' django/contrib/messages/storage/base.py; echo ---; grep -rn \"def get_level_tags\" -A20 django/contrib/messages/utils.py; echo ---; grep -rn \"override_settings\\|LEVEL_TAGS\\|level_tag\" tests/messages_tests | head -40"
}
```

**tool result**

```
from django.conf import settings
from django.contrib.messages import constants, utils

LEVEL_TAGS = utils.get_level_tags()


class Message:
    """
    Represent an actual message that can be stored in any of the supported
    storage classes (typically session- or cookie-based) and rendered in a view
    or template.
    """

    def __init__(self, level, message, extra_tags=None):
        self.level = int(level)
        self.message = message
        self.extra_tags = extra_tags

    def _prepare(self):
        """
        Prepare the message for serialization by forcing the ``message``
        and ``extra_tags`` to str in case they are lazy translations.
        """
        self.message = str(self.message)
        self.extra_tags = str(self.extra_tags) if self.extra_tags is not None else None

    def __eq__(self, other):
        if not isinstance(other, Message):
            return NotImplemented
        return self.level == other.level and self.message == other.message

    def __str__(self):
        return str(self.message)

    @property
    def tags(self):
        return ' '.join(tag for tag in [self.extra_tags, self.level_tag] if tag)

    @property
    def level_tag(self):
        return LEVEL_TAGS.get(self.level, '')


class BaseStorage:
    """
    This is the base backend for temporary message storage.

    This is not a complete class; to be a usable storage backend, it must be
    subclassed and the two methods ``_get`` and ``_store`` overridden.
    """

    def __init__(self, request, *args, **kwargs):
        self.request = request
        self._queued_messages = []
        self.used = False
        self.added_new = False
        super().__init__(*args, **kwargs)

    def __len__(self):
        return len(self._loaded_messages) + len(self._queued_messages)

    def __iter__(self):
        self.used = True
        if self._queued_messages:
            self._loaded_messages.extend(self._queued_messages)
            self._queued_messages = []
        return iter(self._loaded_messages)

    def __contains__(self, item):
        return item in self._loaded_messages or item in self._queued_messages

    def __repr__(self):
        return f'<{self.__class__.__qualname__}: request={self.request!r}>'

    @property
    def _loaded_messages(self):
        """
        Return a list of loaded messages, retrieving them first if they have
        not been loaded yet.
        """
---
5:def get_level_tags():
6-    """
7-    Return the message level tags.
8-    """
9-    return {
10-        **constants.DEFAULT_TAGS,
11-        **getattr(settings, 'MESSAGE_TAGS', {}),
12-    }
---
tests/messages_tests/test_cookie.py:10:from django.test import SimpleTestCase, override_settings
tests/messages_tests/test_cookie.py:48:@override_settings(SESSION_COOKIE_DOMAIN='.example.com', SESSION_COOKIE_SECURE=True, SESSION_COOKIE_HTTPONLY=True)
tests/messages_tests/test_cookie.py:63:    @override_settings(SESSION_COOKIE_SAMESITE='Strict')
tests/messages_tests/test_mixins.py:2:from django.test import TestCase, override_settings
tests/messages_tests/test_mixins.py:9:@override_settings(ROOT_URLCONF='messages_tests.urls')
tests/messages_tests/base.py:7:from django.test import modify_settings, override_settings
tests/messages_tests/base.py:25:class override_settings_tags(override_settings):
tests/messages_tests/base.py:28:        # LEVEL_TAGS is a constant defined in the
tests/messages_tests/base.py:31:        self.old_level_tags = base.LEVEL_TAGS
tests/messages_tests/base.py:32:        base.LEVEL_TAGS = utils.get_level_tags()
tests/messages_tests/base.py:36:        base.LEVEL_TAGS = self.old_level_tags
tests/messages_tests/base.py:50:        self.settings_override = override_settings_tags(
tests/messages_tests/base.py:157:    @override_settings(MESSAGE_LEVEL=constants.DEBUG)
tests/messages_tests/base.py:177:    @override_settings(MESSAGE_LEVEL=constants.DEBUG)
tests/messages_tests/base.py:203:    @override_settings(MESSAGE_LEVEL=constants.DEBUG)
tests/messages_tests/base.py:227:    @override_settings(
tests/messages_tests/base.py:253:    @override_settings(
tests/messages_tests/base.py:346:    @override_settings(MESSAGE_LEVEL=29)
tests/messages_tests/base.py:364:    def test_level_tag(self):
tests/messages_tests/base.py:368:        tags = [msg.level_tag for msg in storage]
tests/messages_tests/base.py:371:    @override_settings_tags(MESSAGE_TAGS={
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,60p' tests/messages_tests/base.py; sed -n '355,400p' tests/messages_tests/base.py"
}
```

**tool result**

```
from django.contrib.messages import constants, get_level, set_level, utils
from django.contrib.messages.api import MessageFailure
from django.contrib.messages.constants import DEFAULT_LEVELS
from django.contrib.messages.storage import base, default_storage
from django.contrib.messages.storage.base import Message
from django.http import HttpRequest, HttpResponse
from django.test import modify_settings, override_settings
from django.urls import reverse
from django.utils.translation import gettext_lazy


def add_level_messages(storage):
    """
    Add 6 messages from different levels (including a custom one) to a storage
    instance.
    """
    storage.add(constants.INFO, 'A generic info message')
    storage.add(29, 'Some custom level')
    storage.add(constants.DEBUG, 'A debugging message', extra_tags='extra-tag')
    storage.add(constants.WARNING, 'A warning')
    storage.add(constants.ERROR, 'An error')
    storage.add(constants.SUCCESS, 'This was a triumph.')


class override_settings_tags(override_settings):
    def enable(self):
        super().enable()
        # LEVEL_TAGS is a constant defined in the
        # django.contrib.messages.storage.base module, so after changing
        # settings.MESSAGE_TAGS, update that constant also.
        self.old_level_tags = base.LEVEL_TAGS
        base.LEVEL_TAGS = utils.get_level_tags()

    def disable(self):
        super().disable()
        base.LEVEL_TAGS = self.old_level_tags


class BaseTests:
    storage_class = default_storage
    levels = {
        'debug': constants.DEBUG,
        'info': constants.INFO,
        'success': constants.SUCCESS,
        'warning': constants.WARNING,
        'error': constants.ERROR,
    }

    def setUp(self):
        self.settings_override = override_settings_tags(
            TEMPLATES=[{
                'BACKEND': 'django.template.backends.django.DjangoTemplates',
                'DIRS': [],
                'APP_DIRS': True,
                'OPTIONS': {
                    'context_processors': (
                        'django.contrib.auth.context_processors.auth',
                        'django.contrib.messages.context_processors.messages',
                    ),
                },

    def test_tags(self):
        storage = self.get_storage()
        storage.level = 0
        add_level_messages(storage)
        storage.add(constants.INFO, 'A generic info message', extra_tags=None)
        tags = [msg.tags for msg in storage]
        self.assertEqual(tags, ['info', '', 'extra-tag debug', 'warning', 'error', 'success', 'info'])

    def test_level_tag(self):
        storage = self.get_storage()
        storage.level = 0
        add_level_messages(storage)
        tags = [msg.level_tag for msg in storage]
        self.assertEqual(tags, ['info', '', 'debug', 'warning', 'error', 'success'])

    @override_settings_tags(MESSAGE_TAGS={
        constants.INFO: 'info',
        constants.DEBUG: '',
        constants.WARNING: '',
        constants.ERROR: 'bad',
        29: 'custom',
    })
    def test_custom_tags(self):
        storage = self.get_storage()
        storage.level = 0
        add_level_messages(storage)
        tags = [msg.tags for msg in storage]
        self.assertEqual(tags, ['info', 'custom', 'extra-tag', '', 'bad', 'success'])
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"LEVEL_TAGS\" . --exclude-dir=.git --exclude-dir=.memdoor"
}
```

**tool result**

```
./django/contrib/messages/storage/base.py:4:LEVEL_TAGS = utils.get_level_tags()
./django/contrib/messages/storage/base.py:41:        return LEVEL_TAGS.get(self.level, '')
./tests/messages_tests/base.py:28:        # LEVEL_TAGS is a constant defined in the
./tests/messages_tests/base.py:31:        self.old_level_tags = base.LEVEL_TAGS
./tests/messages_tests/base.py:32:        base.LEVEL_TAGS = utils.get_level_tags()
./tests/messages_tests/base.py:36:        base.LEVEL_TAGS = self.old_level_tags
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport re\np='django/contrib/messages/storage/base.py'\ns=open(p).read()\ns=s.replace(\"from django.contrib.messages import constants, utils\\n\\nLEVEL_TAGS = utils.get_level_tags()\\n\", \"from django.contrib.messages import constants, utils\\n\")\ns=s.replace(\"        return LEVEL_TAGS.get(self.level, '')\", \"        return utils.get_level_tags().get(self.level, '')\")\nopen(p,'w').write(s)\np='tests/messages_tests/base.py'\ns=open(p).read()\ns=s.replace(\"from django.contrib.messages import constants, get_level, set_level, utils\\n\", \"from django.contrib.messages import constants, get_level, set_level\\n\")\nstart=s.index(\"class override_settings_tags(override_settings):\")\nend=s.index(\"class BaseTests:\")\ns=s[:start]+s[end:]\ns=s.replace(\"        self.settings_override = override_settings_tags(\", \"        self.settings_override = override_settings(\")\ns=s.replace(\"    @override_settings_tags(MESSAGE_TAGS={\", \"    @override_settings(MESSAGE_TAGS={\")\nopen(p,'w').write(s)\nEOF\ngit diff --stat && grep -rn \"override_settings_tags\\|utils\\.\" tests/messages_tests/base.py django/contrib/messages/storage/base.py"
}
```

**tool result**

```
 django/contrib/messages/storage/base.py |  4 +---
 tests/messages_tests/base.py            | 20 +++-----------------
 2 files changed, 4 insertions(+), 20 deletions(-)
tests/messages_tests/base.py:9:from django.utils.translation import gettext_lazy
django/contrib/messages/storage/base.py:39:        return utils.get_level_tags().get(self.level, '')
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py messages_tests --verbosity 1 2>&1 | tail -20"
}
```

**tool result**

```
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
System check identified no issues (0 silenced).
................................................................................................
----------------------------------------------------------------------
Ran 96 tests in 0.236s

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
  "command": "git diff; echo ===; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS"
}
```

**tool result**

```
diff --git a/django/contrib/messages/storage/base.py b/django/contrib/messages/storage/base.py
index 01422066a6..8cdbbd92c7 100644
--- a/django/contrib/messages/storage/base.py
+++ b/django/contrib/messages/storage/base.py
@@ -1,8 +1,6 @@
 from django.conf import settings
 from django.contrib.messages import constants, utils
 
-LEVEL_TAGS = utils.get_level_tags()
-
 
 class Message:
     """
@@ -38,7 +36,7 @@ class Message:
 
     @property
     def level_tag(self):
-        return LEVEL_TAGS.get(self.level, '')
+        return utils.get_level_tags().get(self.level, '')
 
 
 class BaseStorage:
diff --git a/tests/messages_tests/base.py b/tests/messages_tests/base.py
index 9dad08e6c7..c7094ecfc1 100644
--- a/tests/messages_tests/base.py
+++ b/tests/messages_tests/base.py
@@ -1,4 +1,4 @@
-from django.contrib.messages import constants, get_level, set_level, utils
+from django.contrib.messages import constants, get_level, set_level
 from django.contrib.messages.api import MessageFailure
 from django.contrib.messages.constants import DEFAULT_LEVELS
 from django.contrib.messages.storage import base, default_storage
@@ -22,20 +22,6 @@ def add_level_messages(storage):
     storage.add(constants.SUCCESS, 'This was a triumph.')
 
 
-class override_settings_tags(override_settings):
-    def enable(self):
-        super().enable()
-        # LEVEL_TAGS is a constant defined in the
-        # django.contrib.messages.storage.base module, so after changing
-        # settings.MESSAGE_TAGS, update that constant also.
-        self.old_level_tags = base.LEVEL_TAGS
-        base.LEVEL_TAGS = utils.get_level_tags()
-
-    def disable(self):
-        super().disable()
-        base.LEVEL_TAGS = self.old_level_tags
-
-
 class BaseTests:
     storage_class = default_storage
     levels = {
@@ -47,7 +33,7 @@ class BaseTests:
     }
 
     def setUp(self):
-        self.settings_override = override_settings_tags(
+        self.settings_override = override_settings(
             TEMPLATES=[{
                 'BACKEND': 'django.template.backends.django.DjangoTemplates',
                 'DIRS': [],
@@ -368,7 +354,7 @@ class BaseTests:
         tags = [msg.level_tag for msg in storage]
         self.assertEqual(tags, ['info', '', 'debug', 'warning', 'error', 'success'])
 
-    @override_settings_tags(MESSAGE_TAGS={
+    @override_settings(MESSAGE_TAGS={
         constants.INFO: 'info',
         constants.DEBUG: '',
         constants.WARNING: '',
===
PASS
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"settings\\|constants\" django/contrib/messages/storage/base.py"
}
```

**tool result**

```
1:from django.conf import settings
2:from django.contrib.messages import constants, utils
157:            self._level = getattr(settings, 'MESSAGE_LEVEL', constants.INFO)
```

**assistant**

```
Done. The issue was that `LEVEL_TAGS` was a module-level constant computed once at import, so later `MESSAGE_TAGS` changes via `override_settings` were ignored.

Changes:
- `django/contrib/messages/storage/base.py`: removed the cached `LEVEL_TAGS` constant; `Message.level_tag` now calls `utils.get_level_tags()` dynamically, honoring current settings.
- `tests/messages_tests/base.py`: removed the now-unneeded `override_settings_tags` workaround and used plain `override_settings`, which also verifies the fix.

`messages_tests` pass (96 tests), and the required command exits 0 (working tree has changes).
```

## Run folder `single-2026-11-06T112530`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
LEVEL_TAGS not updated when using @override_settings
Description
	
When reading messages inside tests, new message tags created using @override_settings is not updated.
That causes the django.contrib.messages.storage.base.Message.level_tag property results to be an empty string and not know the new tags.
```
