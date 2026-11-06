# django__django-12155 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 72s 38 lines cost=0.003594 in=128359 cached=109568 out=6857 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

docutils reports an error rendering view docstring when the first line is not empty
Description
	
Currently admindoc works correctly only with docstrings where the first line is empty, and all Django docstrings are formatted in this way.
However usually the docstring text starts at the first line, e.g.:
def test():
	"""test tests something.
	"""
and this cause an error:
Error in "default-role" directive:
no content permitted.
.. default-role:: cmsreference
The culprit is this code in trim_docstring:
indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
The problem is that the indentation of the first line is 0.
The solution is to skip the first line:
indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
Thanks.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `grep`**

```json
{
  "pattern": "def trim_docstring",
  "output_mode": "content",
  "head_limit": 20
}
```

**tool result**

```
/testbed/django/contrib/admindocs/utils.py:def trim_docstring(docstring):
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/django/contrib/admindocs/utils.py",
  "limit": 60
}
```

**tool result**

```
"Misc. utility functions/classes for admin documentation generator."

import re
from email.errors import HeaderParseError
from email.parser import HeaderParser

from django.urls import reverse
from django.utils.regex_helper import _lazy_re_compile
from django.utils.safestring import mark_safe

try:
    import docutils.core
    import docutils.nodes
    import docutils.parsers.rst.roles
except ImportError:
    docutils_is_available = False
else:
    docutils_is_available = True


def get_view_name(view_func):
    mod_name = view_func.__module__
    view_name = getattr(view_func, '__qualname__', view_func.__class__.__name__)
    return mod_name + '.' + view_name


def trim_docstring(docstring):
    """
    Uniformly trim leading/trailing whitespace from docstrings.

    Based on https://www.python.org/dev/peps/pep-0257/#handling-docstring-indentation
    """
    if not docstring or not docstring.strip():
        return ''
    # Convert tabs to spaces and split into lines
    lines = docstring.expandtabs().splitlines()
    indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
    trimmed = [lines[0].lstrip()] + [line[indent:].rstrip() for line in lines[1:]]
    return "\n".join(trimmed).strip()


def parse_docstring(docstring):
    """
    Parse out the parts of a docstring.  Return (title, body, metadata).
    """
    docstring = trim_docstring(docstring)
    parts = re.split(r'\n{2,}', docstring)
    title = parts[0]
    if len(parts) == 1:
        body = ''
        metadata = {}
    else:
        parser = HeaderParser()
        try:
            metadata = parser.parsestr(parts[-1])
        except HeaderParseError:
            metadata = {}
            body = "\n\n".join(parts[1:])
        else:
            metadata = dict(metadata.items())

[180 more lines in /testbed/django/contrib/admindocs/utils.py (240 in all). read_file with offset: 61 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/contrib/admindocs/utils.py\n@@\n-    indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())\n+    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/contrib/admindocs/utils.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/contrib/admindocs/utils.py now (240 lines), around the change:
34:        return ''
35:    # Convert tabs to spaces and split into lines
36:    lines = docstring.expandtabs().splitlines()
37:    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
38:    trimmed = [lines[0].lstrip()] + [line[indent:].rstrip() for line in lines[1:]]
39:    return "\n".join(trimmed).strip()
40:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"trim_docstring\" /testbed/tests | head -20"
}
```

**tool result**

```
/testbed/tests/admin_docs/test_utils.py:4:    docutils_is_available, parse_docstring, parse_rst, trim_docstring,
/testbed/tests/admin_docs/test_utils.py:34:    def test_trim_docstring(self):
/testbed/tests/admin_docs/test_utils.py:35:        trim_docstring_output = trim_docstring(self.docstring)
/testbed/tests/admin_docs/test_utils.py:45:        self.assertEqual(trim_docstring_output, trimmed_docstring)
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/tests/admin_docs/test_utils.py",
  "limit": 60
}
```

**tool result**

```
import unittest

from django.contrib.admindocs.utils import (
    docutils_is_available, parse_docstring, parse_rst, trim_docstring,
)

from .tests import AdminDocsSimpleTestCase


@unittest.skipUnless(docutils_is_available, "no docutils installed.")
class TestUtils(AdminDocsSimpleTestCase):
    """
    This __doc__ output is required for testing. I copied this example from
    `admindocs` documentation. (TITLE)

    Display an individual :model:`myapp.MyModel`.

    **Context**

    ``RequestContext``

    ``mymodel``
        An instance of :model:`myapp.MyModel`.

    **Template:**

    :template:`myapp/my_template.html` (DESCRIPTION)

    some_metadata: some data
    """
    def setUp(self):
        self.docstring = self.__doc__

    def test_trim_docstring(self):
        trim_docstring_output = trim_docstring(self.docstring)
        trimmed_docstring = (
            'This __doc__ output is required for testing. I copied this '
            'example from\n`admindocs` documentation. (TITLE)\n\n'
            'Display an individual :model:`myapp.MyModel`.\n\n'
            '**Context**\n\n``RequestContext``\n\n``mymodel``\n'
            '    An instance of :model:`myapp.MyModel`.\n\n'
            '**Template:**\n\n:template:`myapp/my_template.html` '
            '(DESCRIPTION)\n\nsome_metadata: some data'
        )
        self.assertEqual(trim_docstring_output, trimmed_docstring)

    def test_parse_docstring(self):
        title, description, metadata = parse_docstring(self.docstring)
        docstring_title = (
            'This __doc__ output is required for testing. I copied this example from\n'
            '`admindocs` documentation. (TITLE)'
        )
        docstring_description = (
            'Display an individual :model:`myapp.MyModel`.\n\n'
            '**Context**\n\n``RequestContext``\n\n``mymodel``\n'
            '    An instance of :model:`myapp.MyModel`.\n\n'
            '**Template:**\n\n:template:`myapp/my_template.html` '
            '(DESCRIPTION)'
        )
        self.assertEqual(title, docstring_title)

[60 more lines in /testbed/tests/admin_docs/test_utils.py (120 in all). read_file with offset: 61 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/tests/admin_docs/test_utils.py",
  "offset": 60
}
```

**tool result**

```
        self.assertEqual(title, docstring_title)
        self.assertEqual(description, docstring_description)
        self.assertEqual(metadata, {'some_metadata': 'some data'})

    def test_title_output(self):
        title, description, metadata = parse_docstring(self.docstring)
        title_output = parse_rst(title, 'model', 'model:admindocs')
        self.assertIn('TITLE', title_output)
        title_rendered = (
            '<p>This __doc__ output is required for testing. I copied this '
            'example from\n<a class="reference external" '
            'href="/admindocs/models/admindocs/">admindocs</a> documentation. '
            '(TITLE)</p>\n'
        )
        self.assertHTMLEqual(title_output, title_rendered)

    def test_description_output(self):
        title, description, metadata = parse_docstring(self.docstring)
        description_output = parse_rst(description, 'model', 'model:admindocs')
        description_rendered = (
            '<p>Display an individual <a class="reference external" '
            'href="/admindocs/models/myapp.mymodel/">myapp.MyModel</a>.</p>\n'
            '<p><strong>Context</strong></p>\n<p><tt class="docutils literal">'
            'RequestContext</tt></p>\n<dl class="docutils">\n<dt><tt class="'
            'docutils literal">mymodel</tt></dt>\n<dd>An instance of <a class="'
            'reference external" href="/admindocs/models/myapp.mymodel/">'
            'myapp.MyModel</a>.</dd>\n</dl>\n<p><strong>Template:</strong></p>'
            '\n<p><a class="reference external" href="/admindocs/templates/'
            'myapp/my_template.html/">myapp/my_template.html</a> (DESCRIPTION)'
            '</p>\n'
        )
        self.assertHTMLEqual(description_output, description_rendered)

    def test_initial_header_level(self):
        header = 'should be h3...\n\nHeader\n------\n'
        output = parse_rst(header, 'header')
        self.assertIn('<h3>Header</h3>', output)

    def test_parse_rst(self):
        """
        parse_rst() should use `cmsreference` as the default role.
        """
        markup = '<p><a class="reference external" href="/admindocs/%s">title</a></p>\n'
        self.assertEqual(parse_rst('`title`', 'model'), markup % 'models/title/')
        self.assertEqual(parse_rst('`title`', 'view'), markup % 'views/title/')
        self.assertEqual(parse_rst('`title`', 'template'), markup % 'templates/title/')
        self.assertEqual(parse_rst('`title`', 'filter'), markup % 'filters/#title')
        self.assertEqual(parse_rst('`title`', 'tag'), markup % 'tags/#title')

    def test_publish_parts(self):
        """
        Django shouldn't break the default role for interpreted text
        when ``publish_parts`` is used directly, by setting it to
        ``cmsreference`` (#6681).
        """
        import docutils
        self.assertNotEqual(docutils.parsers.rst.roles.DEFAULT_INTERPRETED_ROLE, 'cmsreference')
        source = 'reST, `interpreted text`, default role.'
        markup = '<p>reST, <cite>interpreted text</cite>, default role.</p>\n'
        parts = docutils.core.publish_parts(source=source, writer_name="html4css1")
        self.assertEqual(parts['fragment'], markup)

[lines 60-120 of /testbed/tests/admin_docs/test_utils.py, the end]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/admin_docs/test_utils.py\n@@\n     def test_trim_docstring(self):\n         trim_docstring_output = trim_docstring(self.docstring)\n         trimmed_docstring = (\n@@\n         )\n         self.assertEqual(trim_docstring_output, trimmed_docstring)\n \n+    def test_trim_docstring_first_line_not_empty(self):\n+        docstring = (\n+            'First line.\\n'\n+            '    Second line.\\n'\n+            '        Third line.'\n+        )\n+        self.assertEqual(\n+            trim_docstring(docstring),\n+            'First line.\\nSecond line.\\n    Third line.',\n+        )\n+\n     def test_parse_docstring(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/admin_docs/test_utils.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/admin_docs/test_utils.py now (131 lines), around the change:
43:            '(DESCRIPTION)\n\nsome_metadata: some data'
44:        )
45:        self.assertEqual(trim_docstring_output, trimmed_docstring)
46:
47:    def test_trim_docstring_first_line_not_empty(self):
48:        docstring = (
49:            'First line.\n'
50:            '    Second line.\n'
51:            '        Third line.'
52:        )
53:        self.assertEqual(
54:            trim_docstring(docstring),
55:            'First line.\nSecond line.\n    Third line.',
56:        )
57:
58:    def test_parse_docstring(self):
59:        title, description, metadata = parse_docstring(self.docstring)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest tests/admin_docs/test_utils.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py admin_docs.test_utils -v2 2>&1 | tail -30"
}
```

**tool result**

```
test_description_output (admin_docs.test_utils.TestUtils) ... ok
test_initial_header_level (admin_docs.test_utils.TestUtils) ... ok
test_parse_docstring (admin_docs.test_utils.TestUtils) ... ok
test_parse_rst (admin_docs.test_utils.TestUtils) ... ok
test_publish_parts (admin_docs.test_utils.TestUtils) ... ok
test_title_output (admin_docs.test_utils.TestUtils) ... ok
test_trim_docstring (admin_docs.test_utils.TestUtils) ... ok
test_trim_docstring_first_line_not_empty (admin_docs.test_utils.TestUtils) ... ok

----------------------------------------------------------------------
Ran 8 tests in 0.263s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
Importing application admin_docs
Skipping setup of unused database(s): default, other.
System check identified no issues (0 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py admin_docs -v1 2>&1 | tail -8"
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
  "command": "cd /testbed && python tests/runtests.py admin_docs -v1 2>&1 | grep -E \"Ran|OK|FAILED|ERROR\""
}
```

**tool result**

```
ERROR: test_model_with_many_to_one (admin_docs.test_views.TestModelDetailView)
ERROR: test_model_with_no_backward_relations_render_only_relevant_fields (admin_docs.test_views.TestModelDetailView)
ERROR: test_templatefilter_index (admin_docs.test_views.AdminDocViewWithMultipleEngines)
ERROR: test_templatetag_index (admin_docs.test_views.AdminDocViewWithMultipleEngines)
ERROR: test_templatefilter_index (admin_docs.test_views.AdminDocViewTests)
ERROR: test_templatetag_index (admin_docs.test_views.AdminDocViewTests)
Ran 58 tests in 2.709s
FAILED (errors=6)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py admin_docs.test_views.TestModelDetailView.test_model_with_many_to_one -v2 2>&1 | tail -40"
}
```

**tool result**

```
  File "/testbed/django/views/generic/base.py", line 158, in get
    context = self.get_context_data(**kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 199, in get_context_data
    title, body, metadata = utils.parse_docstring(model.__doc__)
  File "/testbed/django/contrib/admindocs/utils.py", line 46, in parse_docstring
    docstring = trim_docstring(docstring)
  File "/testbed/django/contrib/admindocs/utils.py", line 37, in trim_docstring
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
ValueError: min() arg is an empty sequence

----------------------------------------------------------------------
Ran 1 test in 0.790s

FAILED (errors=1)
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Testing against Django installed in '/testbed/django' with up to 8 processes
Importing application admin_docs
Skipping setup of unused database(s): other.
Operations to perform:
  Synchronize unmigrated apps: admin_docs, auth, contenttypes, messages, sessions, staticfiles
  Apply all migrations: admin, sites
Synchronizing apps without migrations:
  Creating tables...
    Creating table django_content_type
    Creating table auth_permission
    Creating table auth_group
    Creating table auth_user
    Creating table django_session
    Creating table admin_docs_company
    Creating table admin_docs_group
    Creating table admin_docs_family
    Creating table admin_docs_person
    Running deferred SQL...
Running migrations:
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying sites.0001_initial... OK
  Applying sites.0002_alter_domain_unique... OK
System check identified no issues (0 silenced).
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/contrib/admindocs/utils.py\n@@\n-    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())\n+    indent = min(\n+        (len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip()),\n+        default=0,\n+    )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/contrib/admindocs/utils.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/contrib/admindocs/utils.py now (243 lines), around the change:
34:        return ''
35:    # Convert tabs to spaces and split into lines
36:    lines = docstring.expandtabs().splitlines()
37:    indent = min(
38:        (len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip()),
39:        default=0,
40:    )
41:    trimmed = [lines[0].lstrip()] + [line[indent:].rstrip() for line in lines[1:]]
42:    return "\n".join(trimmed).strip()
43:
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python tests/runtests.py admin_docs -v1 2>&1 | grep -E \"Ran|OK|FAILED|ERROR\""
}
```

**tool result**

```
Ran 58 tests in 1.437s
OK
```

**assistant**

```
Fixed `trim_docstring` in `django/contrib/admindocs/utils.py`:

- Indentation is now computed from `lines[1:]`, so a non-empty first line no longer forces `indent` to 0.
- Added `default=0` to `min()` so single-line docstrings (where `lines[1:]` is empty) don't raise `ValueError`.
- Added a regression test `test_trim_docstring_first_line_not_empty` in `tests/admin_docs/test_utils.py`.

All 58 `admin_docs` tests pass.
```

## Run folder `team-solve-2026-11-06T105420`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
153bc9db1b2231896f3d69e3adfad2041a03dec9
```

### `baseline-check.log`

```
check: python tests/runtests.py admin_docs
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
......................EE.................EE.......EE.....
======================================================================
ERROR: test_templatefilter_index (admin_docs.test_views.AdminDocViewTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T105420/baseline-tree/tests/admin_docs/test_views.py", line 42, in test_templatefilter_index
    response = self.client.get(reverse('django-admindocs-filters'))
  File "/testbed/django/test/client.py", line 520, in get
    response = super().get(path, data=data, secure=secure, **extra)
  File "/testbed/django/test/client.py", line 346, in get
    **extra,
  File "/testbed/django/test/client.py", line 421, in generic
    return self.request(**r)
  File "/testbed/django/test/client.py", line 497, in request
    raise exc_value
  File "/testbed/django/core/handlers/exception.py", line 34, in inner
    response = get_response(request)
  File "/testbed/django/core/handlers/base.py", line 115, in _get_response
    response = self.process_exception_by_middleware(e, request)
  File "/testbed/django/core/handlers/base.py", line 113, in _get_response
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
  File "/testbed/django/views/generic/base.py", line 69, in view
    return self.dispatch(request, *args, **kwargs)
  File "/testbed/django/utils/decorators.py", line 43, in _wrapper
    return bound_method(*args, **kwargs)
  File "/testbed/django/contrib/auth/decorators.py", line 21, in _wrapped_view
    return view_func(request, *args, **kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 42, in dispatch
    return super().dispatch(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 97, in dispatch
    return handler(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 158, in get
    context = self.get_context_data(**kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 101, in get_context_data
    title, body, metadata = utils.parse_docstring(filter_func.__doc__)
  File "/testbed/django/contrib/admindocs/utils.py", line 46, in parse_docstring
    docstring = trim_docstring(docstring)
  File "/testbed/django/contrib/admindocs/utils.py", line 37, in trim_docstring
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
ValueError: min() arg is an empty sequence

======================================================================
ERROR: test_templatetag_index (admin_docs.test_views.AdminDocViewTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T105420/baseline-tree/tests/admin_docs/test_views.py", line 38, in test_templatetag_index
    response = self.client.get(reverse('django-admindocs-tags'))
  File "/testbed/django/test/client.py", line 520, in get
    response = super().get(path, data=data, secure=secure, **extra)
  File "/testbed/django/test/client.py", line 346, in get
    **extra,
  File "/testbed/django/test/client.py", line 421, in generic
    return self.request(**r)
  File "/testbed/django/test/client.py", line 497, in request
    raise exc_value
  File "/testbed/django/core/handlers/exception.py", line 34, in inner
    response = get_response(request)
  File "/testbed/django/core/handlers/base.py", line 115, in _get_response
    response = self.process_exception_by_middleware(e, request)
  File "/testbed/django/core/handlers/base.py", line 113, in _get_response
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
  File "/testbed/django/views/generic/base.py", line 69, in view
    return self.dispatch(request, *args, **kwargs)
  File "/testbed/django/utils/decorators.py", line 43, in _wrapper
    return bound_method(*args, **kwargs)
  File "/testbed/django/contrib/auth/decorators.py", line 21, in _wrapped_view
    return view_func(request, *args, **kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 42, in dispatch
    return super().dispatch(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 97, in dispatch
    return handler(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 158, in get
    context = self.get_context_data(**kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 70, in get_context_data
    title, body, metadata = utils.parse_docstring(tag_func.__doc__)
  File "/testbed/django/contrib/admindocs/utils.py", line 46, in parse_docstring
    docstring = trim_docstring(docstring)
  File "/testbed/django/contrib/admindocs/utils.py", line 37, in trim_docstring
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
ValueError: min() arg is an empty sequence

======================================================================
ERROR: test_model_with_many_to_one (admin_docs.test_views.TestModelDetailView)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T105420/baseline-tree/tests/admin_docs/test_views.py", line 264, in test_model_with_many_to_one
    reverse('django-admindocs-models-detail', args=['admin_docs', 'company'])
  File "/testbed/django/test/client.py", line 520, in get
    response = super().get(path, data=data, secure=secure, **extra)
  File "/testbed/django/test/client.py", line 346, in get
    **extra,
  File "/testbed/django/test/client.py", line 421, in generic
    return self.request(**r)
  File "/testbed/django/test/client.py", line 497, in request
    raise exc_value
  File "/testbed/django/core/handlers/exception.py", line 34, in inner
    response = get_response(request)
  File "/testbed/django/core/handlers/base.py", line 115, in _get_response
    response = self.process_exception_by_middleware(e, request)
  File "/testbed/django/core/handlers/base.py", line 113, in _get_response
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
  File "/testbed/django/views/generic/base.py", line 69, in view
    return self.dispatch(request, *args, **kwargs)
  File "/testbed/django/utils/decorators.py", line 43, in _wrapper
    return bound_method(*args, **kwargs)
  File "/testbed/django/contrib/auth/decorators.py", line 21, in _wrapped_view
    return view_func(request, *args, **kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 42, in dispatch
    return super().dispatch(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 97, in dispatch
    return handler(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 158, in get
    context = self.get_context_data(**kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 199, in get_context_data
    title, body, metadata = utils.parse_docstring(model.__doc__)
  File "/testbed/django/contrib/admindocs/utils.py", line 46, in parse_docstring
    docstring = trim_docstring(docstring)
  File "/testbed/django/contrib/admindocs/utils.py", line 37, in trim_docstring
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
ValueError: min() arg is an empty sequence

======================================================================
ERROR: test_model_with_no_backward_relations_render_only_relevant_fields (admin_docs.test_views.TestModelDetailView)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T105420/baseline-tree/tests/admin_docs/test_views.py", line 280, in test_model_with_no_backward_relations_render_only_relevant_fields
    response = self.client.get(reverse('django-admindocs-models-detail', args=['admin_docs', 'family']))
  File "/testbed/django/test/client.py", line 520, in get
    response = super().get(path, data=data, secure=secure, **extra)
  File "/testbed/django/test/client.py", line 346, in get
    **extra,
  File "/testbed/django/test/client.py", line 421, in generic
    return self.request(**r)
  File "/testbed/django/test/client.py", line 497, in request
    raise exc_value
  File "/testbed/django/core/handlers/exception.py", line 34, in inner
    response = get_response(request)
  File "/testbed/django/core/handlers/base.py", line 115, in _get_response
    response = self.process_exception_by_middleware(e, request)
  File "/testbed/django/core/handlers/base.py", line 113, in _get_response
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
  File "/testbed/django/views/generic/base.py", line 69, in view
    return self.dispatch(request, *args, **kwargs)
  File "/testbed/django/utils/decorators.py", line 43, in _wrapper
    return bound_method(*args, **kwargs)
  File "/testbed/django/contrib/auth/decorators.py", line 21, in _wrapped_view
    return view_func(request, *args, **kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 42, in dispatch
    return super().dispatch(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 97, in dispatch
    return handler(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 158, in get
    context = self.get_context_data(**kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 199, in get_context_data
    title, body, metadata = utils.parse_docstring(model.__doc__)
  File "/testbed/django/contrib/admindocs/utils.py", line 46, in parse_docstring
    docstring = trim_docstring(docstring)
  File "/testbed/django/contrib/admindocs/utils.py", line 37, in trim_docstring
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
ValueError: min() arg is an empty sequence

======================================================================
ERROR: test_templatefilter_index (admin_docs.test_views.AdminDocViewWithMultipleEngines)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T105420/baseline-tree/tests/admin_docs/test_views.py", line 152, in test_templatefilter_index
    response = self.client.get(reverse('django-admindocs-filters'))
  File "/testbed/django/test/client.py", line 520, in get
    response = super().get(path, data=data, secure=secure, **extra)
  File "/testbed/django/test/client.py", line 346, in get
    **extra,
  File "/testbed/django/test/client.py", line 421, in generic
    return self.request(**r)
  File "/testbed/django/test/client.py", line 497, in request
    raise exc_value
  File "/testbed/django/core/handlers/exception.py", line 34, in inner
    response = get_response(request)
  File "/testbed/django/core/handlers/base.py", line 115, in _get_response
    response = self.process_exception_by_middleware(e, request)
  File "/testbed/django/core/handlers/base.py", line 113, in _get_response
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
  File "/testbed/django/views/generic/base.py", line 69, in view
    return self.dispatch(request, *args, **kwargs)
  File "/testbed/django/utils/decorators.py", line 43, in _wrapper
    return bound_method(*args, **kwargs)
  File "/testbed/django/contrib/auth/decorators.py", line 21, in _wrapped_view
    return view_func(request, *args, **kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 42, in dispatch
    return super().dispatch(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 97, in dispatch
    return handler(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 158, in get
    context = self.get_context_data(**kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 101, in get_context_data
    title, body, metadata = utils.parse_docstring(filter_func.__doc__)
  File "/testbed/django/contrib/admindocs/utils.py", line 46, in parse_docstring
    docstring = trim_docstring(docstring)
  File "/testbed/django/contrib/admindocs/utils.py", line 37, in trim_docstring
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
ValueError: min() arg is an empty sequence

======================================================================
ERROR: test_templatetag_index (admin_docs.test_views.AdminDocViewWithMultipleEngines)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T105420/baseline-tree/tests/admin_docs/test_views.py", line 158, in test_templatetag_index
    response = self.client.get(reverse('django-admindocs-tags'))
  File "/testbed/django/test/client.py", line 520, in get
    response = super().get(path, data=data, secure=secure, **extra)
  File "/testbed/django/test/client.py", line 346, in get
    **extra,
  File "/testbed/django/test/client.py", line 421, in generic
    return self.request(**r)
  File "/testbed/django/test/client.py", line 497, in request
    raise exc_value
  File "/testbed/django/core/handlers/exception.py", line 34, in inner
    response = get_response(request)
  File "/testbed/django/core/handlers/base.py", line 115, in _get_response
    response = self.process_exception_by_middleware(e, request)
  File "/testbed/django/core/handlers/base.py", line 113, in _get_response
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
  File "/testbed/django/views/generic/base.py", line 69, in view
    return self.dispatch(request, *args, **kwargs)
  File "/testbed/django/utils/decorators.py", line 43, in _wrapper
    return bound_method(*args, **kwargs)
  File "/testbed/django/contrib/auth/decorators.py", line 21, in _wrapped_view
    return view_func(request, *args, **kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 42, in dispatch
    return super().dispatch(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 97, in dispatch
    return handler(request, *args, **kwargs)
  File "/testbed/django/views/generic/base.py", line 158, in get
    context = self.get_context_data(**kwargs)
  File "/testbed/django/contrib/admindocs/views.py", line 70, in get_context_data
    title, body, metadata = utils.parse_docstring(tag_func.__doc__)
  File "/testbed/django/contrib/admindocs/utils.py", line 46, in parse_docstring
    docstring = trim_docstring(docstring)
  File "/testbed/django/contrib/admindocs/utils.py", line 37, in trim_docstring
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
ValueError: min() arg is an empty sequence

----------------------------------------------------------------------
Ran 57 tests in 2.012s

FAILED (errors=6)
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
1
```

### `changes.diff`

```diff
diff --git a/django/contrib/admindocs/utils.py b/django/contrib/admindocs/utils.py
index 4c0e7e2a56..cda95a90b3 100644
--- a/django/contrib/admindocs/utils.py
+++ b/django/contrib/admindocs/utils.py
@@ -34,7 +34,10 @@ def trim_docstring(docstring):
         return ''
     # Convert tabs to spaces and split into lines
     lines = docstring.expandtabs().splitlines()
-    indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
+    indent = min(
+        (len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip()),
+        default=0,
+    )
     trimmed = [lines[0].lstrip()] + [line[indent:].rstrip() for line in lines[1:]]
     return "\n".join(trimmed).strip()
 
diff --git a/tests/admin_docs/test_utils.py b/tests/admin_docs/test_utils.py
index 17ea912015..ec2cd16ed5 100644
--- a/tests/admin_docs/test_utils.py
+++ b/tests/admin_docs/test_utils.py
@@ -44,6 +44,17 @@ class TestUtils(AdminDocsSimpleTestCase):
         )
         self.assertEqual(trim_docstring_output, trimmed_docstring)
 
+    def test_trim_docstring_first_line_not_empty(self):
+        docstring = (
+            'First line.\n'
+            '    Second line.\n'
+            '        Third line.'
+        )
+        self.assertEqual(
+            trim_docstring(docstring),
+            'First line.\nSecond line.\n    Third line.',
+        )
+
     def test_parse_docstring(self):
         title, description, metadata = parse_docstring(self.docstring)
         docstring_title = (
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

docutils reports an error rendering view docstring when the first line is not empty
Description
	
Currently admindoc works correctly only with docstrings where the first line is empty, and all Django docstrings are formatted in this way.
However usually the docstring text starts at the first line, e.g.:
def test():
	"""test tests something.
	"""
and this cause an error:
Error in "default-role" directive:
no content permitted.
.. default-role:: cmsreference
The culprit is this code in trim_docstring:
indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
The problem is that the indentation of the first line is 0.
The solution is to skip the first line:
indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
Thanks.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py admin_docs`

## Scope

`django/contrib/admindocs/utils.py`
`tests/admin_docs/`

## Done when

`trim_docstring` computes indentation from lines after the first, so a non-empty first line no longer forces indentation to 0.
A view docstring whose first line is not empty renders through admindocs without the docutils `default-role` error.
Docstrings with an empty first line continue to render correctly.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py admin_docs`

## Scope
`django/contrib/admindocs/utils.py`
`tests/admin_docs/`

## Done when
`trim_docstring` computes indentation from lines after the first, so a non-empty first line no longer forces indentation to 0.
A view docstring whose first line is not empty renders through admindocs without the docutils `default-role` error.
Docstrings with an empty first line continue to render correctly.

## Approach
Decompose into: locate `trim_docstring` in `django/contrib/admindocs/utils.py`, change the indentation calculation to ignore the first line, add a regression test under `tests/admin_docs/` for a docstring beginning with text, then run the scoped admin_docs test command.

Candidate approaches:
1. Prompt’s minimal fix: use `lines[1:]` in the indentation `min(...)`, with a fallback such as `default=0` when no later non-blank lines exist. Tradeoff: smallest behavior change, but needs care for single-line or trailing-whitespace-only docstrings.
2. Replace the custom trimming with `inspect.cleandoc`. Tradeoff: standard-library behavior handles first-line text and blank lines, but may change formatting more broadly than the reported bug requires.
3. Normalize by prepending a newline before the existing logic. Tradeoff: simple to reason about, but can alter output and still requires handling empty/single-line docstrings.


# django/contrib/admindocs/utils.py

```
"Misc. utility functions/classes for admin documentation generator."

import re
from email.errors import HeaderParseError
from email.parser import HeaderParser

from django.urls import reverse
from django.utils.regex_helper import _lazy_re_compile
from django.utils.safestring import mark_safe

try:
    import docutils.core
    import docutils.nodes
    import docutils.parsers.rst.roles
except ImportError:
    docutils_is_available = False
else:
    docutils_is_available = True


def get_view_name(view_func):
    mod_name = view_func.__module__
    view_name = getattr(view_func, '__qualname__', view_func.__class__.__name__)
    return mod_name + '.' + view_name


def trim_docstring(docstring):
    """
    Uniformly trim leading/trailing whitespace from docstrings.

    Based on https://www.python.org/dev/peps/pep-0257/#handling-docstring-indentation
    """
    if not docstring or not docstring.strip():
        return ''
    # Convert tabs to spaces and split into lines
    lines = docstring.expandtabs().splitlines()
    indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
    trimmed = [lines[0].lstrip()] + [line[indent:].rstrip() for line in lines[1:]]
    return "\n".join(trimmed).strip()


def parse_docstring(docstring):
    """
    Parse out the parts of a docstring.  Return (title, body, metadata).
    """
    docstring = trim_docstring(docstring)
    parts = re.split(r'\n{2,}', docstring)
    title = parts[0]
    if len(parts) == 1:
        body = ''
        metadata = {}
    else:
        parser = HeaderParser()
        try:
            metadata = parser.parsestr(parts[-1])
        except HeaderParseError:
            metadata = {}
            body = "\n\n".join(parts[1:])
        else:
            metadata = dict(metadata.items())
            if metadata:
                body = "\n\n".join(parts[1:-1])
            else:
                body = "\n\n".join(parts[1:])
    return title, body, metadata


def parse_rst(text, default_reference_context, thing_being_parsed=None):
    """
    Convert the string from reST to an XHTML fragment.
    """
    overrides = {
        'doctitle_xform': True,
        'initial_header_level': 3,
        "default_reference_context": default_reference_context,
        "link_base": reverse('django-admindocs-docroot').rstrip('/'),
        'raw_enabled': False,
        'file_insertion_enabled': False,
    }
    thing_being_parsed = thing_being_parsed and '<%s>' % thing_being_parsed
    # Wrap ``text`` in some reST that sets the default role to ``cmsreference``,
    # then restores it.
    source = """
.. default-role:: cmsreference

%s

.. default-role::
"""
    parts = docutils.core.publish_parts(
        source % text,
        source_path=thing_being_parsed, destination_path=None,
        writer_name='html', settings_overrides=overrides,
    )
    return mark_safe(parts['fragment'])


#
# reST roles
#
ROLES = {
    'model': '%s/models/%s/',
    'view': '%s/views/%s/',
    'template': '%s/templates/%s/',
    'filter': '%s/filters/#%s',
    'tag': '%s/tags/#%s',
}


def create_reference_role(rolename, urlbase):
    def _role(name, rawtext, text, lineno, inliner, options=None, content=None):
        if options is None:
            options = {}
        node = docutils.nodes.reference(
            rawtext,
            text,
            refuri=(urlbase % (
                inliner.document.settings.link_base,
                text.lower(),
            )),
            **options
        )
        return [node], []
    docutils.parsers.rst.roles.register_canonical_role(rolename, _role)


def default_reference_role(name, rawtext, text, lineno, inliner, options=None, content=None):
    if options is None:
        options = {}
    context = inliner.document.settings.default_reference_context
    node = docutils.nodes.reference(
        rawtext,
        text,
        refuri=(ROLES[context] % (
            inliner.document.settings.link_base,
            text.lower(),
        )),
        **options
    )
    return [node], []


if docutils_is_available:
    docutils.parsers.rst.roles.register_canonical_role('cmsreference', default_reference_role)

    for name, urlbase in ROLES.items():
        create_reference_role(name, urlbase)

# Match the beginning of a named or unnamed group.
named_group_matcher = _lazy_re_compile(r'\(\?P(<\w+>)')
unnamed_group_matcher = _lazy_re_compile(r'\(')


def replace_named_groups(pattern):
    r"""
    Find named groups in `pattern` and replace them with the group name. E.g.,
    1. ^(?P<a>\w+)/b/(\w+)$ ==> ^<a>/b/(\w+)$
    2. ^(?P<a>\w+)/b/(?P<c>\w+)/$ ==> ^<a>/b/<c>/$
    3. ^(?P<a>\w+)/b/(\w+) ==> ^<a>/b/(\w+)
    4. ^(?P<a>\w+)/b/(?P<c>\w+) ==> ^<a>/b/<c>
    """
    named_group_indices = [
        (m.start(0), m.end(0), m.group(1))
        for m in named_group_matcher.finditer(pattern)
    ]
    # Tuples of (named capture group pattern, group name).
    group_pattern_and_name = []
    # Loop over the groups and their start and end indices.
    for start, end, group_name in named_group_indices:
        # Handle nested parentheses, e.g. '^(?P<a>(x|y))/b'.
        unmatched_open_brackets, prev_char = 1, None
        for idx, val in enumerate(pattern[end:]):
            # Check for unescaped `(` and `)`. They mark the start and end of a
            # nested group.
            if val == '(' and prev_char != '\\':
                unmatched_open_brackets += 1
            elif val == ')' and prev_char != '\\':
                unmatched_open_brackets -= 1
            prev_char = val
            # If brackets are balanced, the end of the string for the current
            # named capture group pattern has been reached.
            if unmatched_open_brackets == 0:
                group_pattern_and_name.append((pattern[start:end + idx + 1], group_name))
                break

    # Replace the string for named capture groups with their group names.
    for group_pattern, group_name in group_pattern_and_name:
        pattern = pattern.replace(group_pattern, group_name)
    return pattern


def replace_unnamed_groups(pattern):
    r"""
    Find unnamed groups in `pattern` and replace them with '<var>'. E.g.,
    1. ^(?P<a>\w+)/b/(\w+)$ ==> ^(?P<a>\w+)/b/<var>$
    2. ^(?P<a>\w+)/b/((x|y)\w+)$ ==> ^(?P<a>\w+)/b/<var>$
    3. ^(?P<a>\w+)/b/(\w+) ==> ^(?P<a>\w+)/b/<var>
    4. ^(?P<a>\w+)/b/((x|y)\w+) ==> ^(?P<a>\w+)/b/<var>
    """
    unnamed_group_indices = [m.start(0) for m in unnamed_group_matcher.finditer(pattern)]
    # Indices of the start of unnamed capture groups.
    group_indices = []
    # Loop over the start indices of the groups.
    for start in unnamed_group_indices:
        # Handle nested parentheses, e.g. '^b/((x|y)\w+)$'.
        unmatched_open_brackets, prev_char = 1, None
        for idx, val in enumerate(pattern[start + 1:]):
            # Check for unescaped `(` and `)`. They mark the start and end of
            # a nested group.
            if val == '(' and prev_char != '\\':
                unmatched_open_brackets += 1
            elif val == ')' and prev_char != '\\':
                unmatched_open_brackets -= 1
            prev_char = val

            if unmatched_open_brackets == 0:
                group_indices.append((start, start + 2 + idx))
                break
    # Remove unnamed group matches inside other unnamed capture groups.
    group_start_end_indices = []
    prev_end = None
    for start, end in group_indices:
        if prev_end and start > prev_end or not prev_end:
            group_start_end_indices.append((start, end))
        prev_end = end

    if group_start_end_indices:
        # Replace unnamed groups with <var>. Handle the fact that replacing the
        # string between indices will change string length and thus indices
        # will point to the wrong substring if not corrected.
        final_pattern, prev_end = [], None
        for start, end in group_start_end_indices:
            if prev_end:
                final_pattern.append(pattern[prev_end:start])
            final_pattern.append(pattern[:start] + '<var>')
            prev_end = end
        final_pattern.append(pattern[prev_end:])
        return ''.join(final_pattern)
    else:
        return pattern

```


# tests/admin_docs (the files in it)

tests/admin_docs/__init__.py
tests/admin_docs/evilfile.txt
tests/admin_docs/models.py
tests/admin_docs/namespace_urls.py
tests/admin_docs/test_middleware.py
tests/admin_docs/test_utils.py
tests/admin_docs/test_views.py
tests/admin_docs/tests.py
tests/admin_docs/urls.py
tests/admin_docs/views.py


# The last commit

```
153bc9db1b SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py admin_docs
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
..........................................................
----------------------------------------------------------------------
Ran 58 tests in 2.045s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/contrib/admindocs/utils.py tests/admin_docs
changed: django/contrib/admindocs/utils.py +4 -1
changed: tests/admin_docs/test_utils.py +11 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/contrib/admindocs/utils.py b/django/contrib/admindocs/utils.py
index 4c0e7e2a56..cda95a90b3 100644
--- a/django/contrib/admindocs/utils.py
+++ b/django/contrib/admindocs/utils.py
@@ -34,7 +34,10 @@ def trim_docstring(docstring):
         return ''
     # Convert tabs to spaces and split into lines
     lines = docstring.expandtabs().splitlines()
-    indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
+    indent = min(
+        (len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip()),
+        default=0,
+    )
     trimmed = [lines[0].lstrip()] + [line[indent:].rstrip() for line in lines[1:]]
     return "\n".join(trimmed).strip()
 
diff --git a/tests/admin_docs/test_utils.py b/tests/admin_docs/test_utils.py
index 17ea912015..ec2cd16ed5 100644
--- a/tests/admin_docs/test_utils.py
+++ b/tests/admin_docs/test_utils.py
@@ -44,6 +44,17 @@ class TestUtils(AdminDocsSimpleTestCase):
         )
         self.assertEqual(trim_docstring_output, trimmed_docstring)
 
+    def test_trim_docstring_first_line_not_empty(self):
+        docstring = (
+            'First line.\n'
+            '    Second line.\n'
+            '        Third line.'
+        )
+        self.assertEqual(
+            trim_docstring(docstring),
+            'First line.\nSecond line.\n    Third line.',
+        )
+
     def test_parse_docstring(self):
         title, description, metadata = parse_docstring(self.docstring)
         docstring_title = (
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
check: python tests/runtests.py admin_docs
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
..........................................................
----------------------------------------------------------------------
Ran 58 tests in 1.335s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/contrib/admindocs/utils.py tests/admin_docs
changed: django/contrib/admindocs/utils.py +4 -1
changed: tests/admin_docs/test_utils.py +11 -0
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
# Notes, run 2026-11-06T105420

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

docutils reports an error rendering view docstring when the first line is not empty
Description
	
Currently admindoc works correctly only with docstrings where the first line is empty, and all Django docstrings are formatted in this way.
However usually the docstring text starts at the first line, e.g.:
def test():
	"""test tests something.
	"""
and this cause an error:
Error in "default-role" directive:
no content permitted.
.. default-role:: cmsreference
The culprit is this code in trim_docstring:
indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
The problem is that the indentation of the first line is 0.
The solution is to skip the first line:
indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
Thanks.


# The files of the project

```
.editorconfig
.eslintignore
.eslintrc
.gitattributes
.gitignore
.hgignore
.tx/config
AUTHORS
CONTRIBUTING.rst
FUNDING.yml
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
django/conf/locale/th/LC_MESSAGES/django.mo
django/conf/locale/th/LC_MESSAGES/django.po
django/conf/locale/th/__init__.py
django/conf/locale/th/formats.py
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
django/contrib/admin/bin/compress.py
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
django/contrib/admin/locale/kn/LC_MESSAGES/django.po
django/contrib/admin/locale/kn/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/kn/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ko/LC_MESSAGES/django.mo
django/contrib/admin/locale/ko/LC_MESSAGES/django.po
django/contrib/admin/locale/ko/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ko/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lb/LC_MESSAGES/django.mo
django/contrib/admin/locale/lb/LC_MESSAGES/django.po
django/contrib/admin/locale/lb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lb/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lt/LC_MESSAGES/django.mo
django/contrib/admin/locale/lt/LC_MESSAGES/django.po
django/contrib/admin/locale/lt/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lt/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/lv/LC_MESSAGES/django.mo
django/contrib/admin/locale/lv/LC_MESSAGES/django.po
django/contrib/admin/locale/lv/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/lv/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/mk/LC_MESSAGES/django.mo
django/contrib/admin/locale/mk/LC_MESSAGES/django.po
django/contrib/admin/locale/mk/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/mk/LC_MESSAGES/djangojs.po
django/contrib/admin/locale/ml/LC_MESSAGES/django.mo
django/contrib/admin/locale/ml/LC_MESSAGES/django.po
```


# The last commit

```
153bc9db1b SWE-bench


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
    "eslint": "^4.18.2",
    "grunt": "^1.0.1",
    "grunt-cli": "^1.2.0",
    "grunt-contrib-qunit": "^1.2.0"
  }
}

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python tests/runtests.py admin_docs`

## Scope
`django/contrib/admindocs/utils.py`
`tests/admin_docs/`

## Done when
`trim_docstring` computes indentation from lines after the first, so a non-empty first line no longer forces indentation to 0.
A view docstring whose first line is not empty renders through admindocs without the docutils `default-role` error.
Docstrings with an empty first line continue to render correctly.

## Approach
Decompose into: locate `trim_docstring` in `django/contrib/admindocs/utils.py`, change the indentation calculation to ignore the first line, add a regression test under `tests/admin_docs/` for a docstring beginning with text, then run the scoped admin_docs test command.

Candidate approaches:
1. Prompt’s minimal fix: use `lines[1:]` in the indentation `min(...)`, with a fallback such as `default=0` when no later non-blank lines exist. Tradeoff: smallest behavior change, but needs care for single-line or trailing-whitespace-only docstrings.
2. Replace the custom trimming with `inspect.cleandoc`. Tradeoff: standard-library behavior handles first-line text and blank lines, but may change formatting more broadly than the reported bug requires.
3. Normalize by prepending a newline before the existing logic. Tradeoff: simple to reason about, but can alter output and still requires handling empty/single-line docstrings.
```

### `prompt.md`

```
docutils reports an error rendering view docstring when the first line is not empty
Description
	
Currently admindoc works correctly only with docstrings where the first line is empty, and all Django docstrings are formatted in this way.
However usually the docstring text starts at the first line, e.g.:
def test():
	"""test tests something.
	"""
and this cause an error:
Error in "default-role" directive:
no content permitted.
.. default-role:: cmsreference
The culprit is this code in trim_docstring:
indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
The problem is that the indentation of the first line is 0.
The solution is to skip the first line:
indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
Thanks.
```

### `review.md`

```
verdict: PASS

- `trim_docstring` now computes indentation from `lines[1:]`, so a non-empty first line no longer forces the indent baseline to 0.
- `default=0` safely handles single-line docstrings and docstrings with no non-empty lines after the first.
- Existing empty-first-line docstrings still use the same indentation calculation, preserving prior behavior.
- The regression test covers a non-empty first line and verifies relative indentation is preserved.
- Scope report shows only `django/contrib/admindocs/utils.py` and `tests/admin_docs/test_utils.py` changed, both within scope.
- The check command ran 58 admin_docs tests successfully with status 0.
```

### `scope.txt`

```
scope: django/contrib/admindocs/utils.py tests/admin_docs
changed: django/contrib/admindocs/utils.py +4 -1
changed: tests/admin_docs/test_utils.py +11 -0
```

### `task.md`

```
# Task

## Prompt

docutils reports an error rendering view docstring when the first line is not empty
Description
	
Currently admindoc works correctly only with docstrings where the first line is empty, and all Django docstrings are formatted in this way.
However usually the docstring text starts at the first line, e.g.:
def test():
	"""test tests something.
	"""
and this cause an error:
Error in "default-role" directive:
no content permitted.
.. default-role:: cmsreference
The culprit is this code in trim_docstring:
indent = min(len(line) - len(line.lstrip()) for line in lines if line.lstrip())
The problem is that the indentation of the first line is 0.
The solution is to skip the first line:
indent = min(len(line) - len(line.lstrip()) for line in lines[1:] if line.lstrip())
Thanks.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py admin_docs`

## Scope

`django/contrib/admindocs/utils.py`
`tests/admin_docs/`

## Done when

`trim_docstring` computes indentation from lines after the first, so a non-empty first line no longer forces indentation to 0.
A view docstring whose first line is not empty renders through admindocs without the docutils `default-role` error.
Docstrings with an empty first line continue to render correctly.
```

### `test-output.log`

```
check: python tests/runtests.py admin_docs
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Creating test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
Cloning test database for alias 'default'...
..........................................................
----------------------------------------------------------------------
Ran 58 tests in 2.246s

OK
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/contrib/admindocs/utils.py tests/admin_docs
changed: django/contrib/admindocs/utils.py +4 -1
changed: tests/admin_docs/test_utils.py +11 -0
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
