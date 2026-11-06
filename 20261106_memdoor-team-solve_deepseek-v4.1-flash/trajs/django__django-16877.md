# django__django-16877 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 63s 91 lines cost=0.004760 in=137292 cached=87552 out=8290 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

New template filter `escapeseq`
Description
	
Following #34574, and after some conversations within the security team, it seems appropriate to provide a new template filter escapeseq which would be to escape what safeseq is to safe. An example of usage would be:
{{ some_list|escapeseq|join:"," }}
where each item of some_list is escaped before applying the join operation. This usage makes sense in a context where autoescape is off.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --short | head"
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
35966be495 SWE-bench
98f6ada0e2 Fixed #34580 -- Avoided unnecessary computation of selected expressions in SQLCompiler.
00f5d2d110 Refs #31949 -- Made @xframe_options_(deny/sameorigin/exempt) decorators to work with async functions.
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"safeseq\" django tests docs | head -50"
}
```

**tool result**

```
django/template/defaultfilters.py:492:def safeseq(value):
tests/template_tests/filter_tests/test_safeseq.py:7:    @setup({"safeseq01": '{{ a|join:", " }} -- {{ a|safeseq|join:", " }}'})
tests/template_tests/filter_tests/test_safeseq.py:8:    def test_safeseq01(self):
tests/template_tests/filter_tests/test_safeseq.py:9:        output = self.engine.render_to_string("safeseq01", {"a": ["&", "<"]})
tests/template_tests/filter_tests/test_safeseq.py:14:            "safeseq02": (
tests/template_tests/filter_tests/test_safeseq.py:15:                '{% autoescape off %}{{ a|join:", " }} -- {{ a|safeseq|join:", " }}'
tests/template_tests/filter_tests/test_safeseq.py:20:    def test_safeseq02(self):
tests/template_tests/filter_tests/test_safeseq.py:21:        output = self.engine.render_to_string("safeseq02", {"a": ["&", "<"]})
docs/ref/templates/builtins.txt:2361:.. templatefilter:: safeseq
docs/ref/templates/builtins.txt:2363:``safeseq``
docs/ref/templates/builtins.txt:2372:    {{ some_list|safeseq|join:", " }}
docs/releases/1.1.txt:420:* There's a new :tfilter:`safeseq` template filter which works just like
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '450,520p' django/template/defaultfilters.py; sed -n '2340,2390p' docs/ref/templates/builtins.txt; cat tests/template_tests/filter_tests/test_safeseq.py"
}
```

**tool result**

```
    """
    Escape a string's HTML. Return a new string containing the escaped
    characters (as opposed to "escape", which marks the content for later
    possible escaping).
    """
    return escape(value)


@register.filter("linebreaks", is_safe=True, needs_autoescape=True)
@stringfilter
def linebreaks_filter(value, autoescape=True):
    """
    Replace line breaks in plain text with appropriate HTML; a single
    newline becomes an HTML line break (``<br>``) and a new line
    followed by a blank line becomes a paragraph break (``</p>``).
    """
    autoescape = autoescape and not isinstance(value, SafeData)
    return mark_safe(linebreaks(value, autoescape))


@register.filter(is_safe=True, needs_autoescape=True)
@stringfilter
def linebreaksbr(value, autoescape=True):
    """
    Convert all newlines in a piece of plain text to HTML line breaks
    (``<br>``).
    """
    autoescape = autoescape and not isinstance(value, SafeData)
    value = normalize_newlines(value)
    if autoescape:
        value = escape(value)
    return mark_safe(value.replace("\n", "<br>"))


@register.filter(is_safe=True)
@stringfilter
def safe(value):
    """Mark the value as a string that should not be auto-escaped."""
    return mark_safe(value)


@register.filter(is_safe=True)
def safeseq(value):
    """
    A "safe" filter for sequences. Mark each element in the sequence,
    individually, as safe, after converting them to strings. Return a list
    with the results.
    """
    return [mark_safe(obj) for obj in value]


@register.filter(is_safe=True)
@stringfilter
def striptags(value):
    """Strip all [X]HTML tags."""
    return strip_tags(value)


###################
# LISTS           #
###################


def _property_resolver(arg):
    """
    When arg is convertible to float, behave like operator.itemgetter(arg)
    Otherwise, chain __getitem__() and getattr().

    >>> _property_resolver(1)('abc')
    'b'
    >>> _property_resolver('1')('abc')

If ``value`` is ``Django``, the output will be ``"    Django"``.

.. templatefilter:: safe

``safe``
--------

Marks a string as not requiring further HTML escaping prior to output. When
autoescaping is off, this filter has no effect.

.. note::

    If you are chaining filters, a filter applied after ``safe`` can
    make the contents unsafe again. For example, the following code
    prints the variable as is, unescaped:

    .. code-block:: html+django

        {{ var|safe|escape }}

.. templatefilter:: safeseq

``safeseq``
-----------

Applies the :tfilter:`safe` filter to each element of a sequence. Useful in
conjunction with other filters that operate on sequences, such as
:tfilter:`join`. For example:

.. code-block:: html+django

    {{ some_list|safeseq|join:", " }}

You couldn't use the :tfilter:`safe` filter directly in this case, as it would
first convert the variable into a string, rather than working with the
individual elements of the sequence.

.. templatefilter:: slice

``slice``
---------

Returns a slice of the list.

Uses the same syntax as Python's list slicing. See
https://diveinto.org/python3/native-datatypes.html#slicinglists for an
introduction.

Example:

from django.test import SimpleTestCase

from ..utils import setup


class SafeseqTests(SimpleTestCase):
    @setup({"safeseq01": '{{ a|join:", " }} -- {{ a|safeseq|join:", " }}'})
    def test_safeseq01(self):
        output = self.engine.render_to_string("safeseq01", {"a": ["&", "<"]})
        self.assertEqual(output, "&amp;, &lt; -- &, <")

    @setup(
        {
            "safeseq02": (
                '{% autoescape off %}{{ a|join:", " }} -- {{ a|safeseq|join:", " }}'
                "{% endautoescape %}"
            )
        }
    )
    def test_safeseq02(self):
        output = self.engine.render_to_string("safeseq02", {"a": ["&", "<"]})
        self.assertEqual(output, "&, < -- &, <")
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' django/template/defaultfilters.py; grep -n \"escape\" django/template/defaultfilters.py | head"
}
```

**tool result**

```
"""Default variable filters."""
import random as random_module
import re
import types
import warnings
from decimal import ROUND_HALF_UP, Context, Decimal, InvalidOperation, getcontext
from functools import wraps
from inspect import unwrap
from operator import itemgetter
from pprint import pformat
from urllib.parse import quote

from django.utils import formats
from django.utils.dateformat import format, time_format
from django.utils.deprecation import RemovedInDjango51Warning
from django.utils.encoding import iri_to_uri
from django.utils.html import avoid_wrapping, conditional_escape, escape, escapejs
from django.utils.html import json_script as _json_script
from django.utils.html import linebreaks, strip_tags
from django.utils.html import urlize as _urlize
from django.utils.safestring import SafeData, mark_safe
from django.utils.text import Truncator, normalize_newlines, phone2numeric
from django.utils.text import slugify as _slugify
from django.utils.text import wrap
from django.utils.timesince import timesince, timeuntil
from django.utils.translation import gettext, ngettext

from .base import VARIABLE_ATTRIBUTE_SEPARATOR
from .library import Library

register = Library()


#######################
# STRING DECORATOR    #
#######################


def stringfilter(func):
    """
17:from django.utils.html import avoid_wrapping, conditional_escape, escape, escapejs
66:    example. Less useful for escaping JavaScript; use the ``escapejs``
79:@register.filter("escapejs")
81:def escapejs_filter(value):
83:    return escapejs(value)
217:@register.filter(is_safe=True, needs_autoescape=True)
219:def linenumbers(value, autoescape=True):
225:    if not autoescape or isinstance(value, SafeData):
230:            lines[i] = ("%0" + width + "d. %s") % (i + 1, escape(line))
358:    escaped by Python's quote() function. If not provided, use the default safe
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '50,95p' django/template/defaultfilters.py; grep -n \"escapeseq\\|safeseq\" docs/ref/templates/builtins.txt docs/releases/*.txt | head"
}
```

**tool result**

```
            result = mark_safe(result)
        return result

    return _dec


###################
# STRINGS         #
###################


@register.filter(is_safe=True)
@stringfilter
def addslashes(value):
    """
    Add slashes before quotes. Useful for escaping strings in CSV, for
    example. Less useful for escaping JavaScript; use the ``escapejs``
    filter instead.
    """
    return value.replace("\\", "\\\\").replace('"', '\\"').replace("'", "\\'")


@register.filter(is_safe=True)
@stringfilter
def capfirst(value):
    """Capitalize the first character of the value."""
    return value and value[0].upper() + value[1:]


@register.filter("escapejs")
@stringfilter
def escapejs_filter(value):
    """Hex encode characters for use in JavaScript strings."""
    return escapejs(value)


@register.filter(is_safe=True)
def json_script(value, element_id=None):
    """
    Output value JSON-encoded, wrapped in a <script type="application/json">
    tag (with an optional id).
    """
    return _json_script(value, element_id)


@register.filter(is_safe=True)
docs/ref/templates/builtins.txt:2361:.. templatefilter:: safeseq
docs/ref/templates/builtins.txt:2363:``safeseq``
docs/ref/templates/builtins.txt:2372:    {{ some_list|safeseq|join:", " }}
docs/releases/1.1.txt:420:* There's a new :tfilter:`safeseq` template filter which works just like
```

**assistant → tool `bash`**

```json
{
  "command": "ls docs/releases | tail -8; grep -n \"safeseq\\|escape\" docs/ref/templates/builtins.txt | sed -n '1,20p'"
}
```

**tool result**

```
4.1.9.txt
4.1.txt
4.2.1.txt
4.2.2.txt
4.2.txt
5.0.txt
index.txt
security.txt
15:.. templatetag:: autoescape
17:``autoescape``
22:inside the block. The block is closed with an ``endautoescape`` ending tag.
26:been applied). This is equivalent to manually applying the :tfilter:`escape`
31:the :tfilter:`safe` or :tfilter:`escape` filters applied.
37:    {% autoescape on %}
39:    {% endautoescape %}
113:Variables included in the cycle will be escaped.  You can disable auto-escaping
119:        <tr class="{% autoescape off %}{% cycle rowvalue1 rowvalue2 %}{% endautoescape %}">
281:    {% filter force_escape|lower %}
282:        This text will be HTML-escaped, and will appear in all lowercase.
287:    The :tfilter:`escape` and :tfilter:`safe` filters are not acceptable
288:    arguments. Instead, use the :ttag:`autoescape` tag to manage autoescaping
325:This tag auto-escapes variable values. You can disable auto-escaping with:
329:    {% autoescape off %}
331:    {% endautoescape %}
333:Or if only some variables should be escaped, you can use:
902:Note that you can backslash-escape a format string if you want to use the
903:"raw" value. In this example, both "o" and "f" are backslash-escaped, because
1638:backslash-escaped, because otherwise each is a format string that displays the
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/template/defaultfilters.py\n@@\n @register.filter(is_safe=True)\n def safeseq(value):\n     \"\"\"\n     A \"safe\" filter for sequences. Mark each element in the sequence,\n     individually, as safe, after converting them to strings. Return a list\n     with the results.\n     \"\"\"\n     return [mark_safe(obj) for obj in value]\n \n \n+@register.filter(is_safe=True)\n+def escapeseq(value):\n+    \"\"\"\n+    An \"escape\" filter for sequences. Escape each element in the sequence,\n+    individually, and return a list with the results.\n+    \"\"\"\n+    return [escape(obj) for obj in value]\n+\n+\n @register.filter(is_safe=True)\n @stringfilter\n def striptags(value):\n*** Update File: docs/ref/templates/builtins.txt\n@@\n You couldn't use the :tfilter:`safe` filter directly in this case, as it would\n first convert the variable into a string, rather than working with the\n individual elements of the sequence.\n \n+.. templatefilter:: escapeseq\n+\n+``escapeseq``\n+-------------\n+\n+Applies the :tfilter:`escape` filter to each element of a sequence. Useful in\n+conjunction with other filters that operate on sequences, such as\n+:tfilter:`join`. For example:\n+\n+.. code-block:: html+django\n+\n+    {{ some_list|escapeseq|join:\", \" }}\n+\n+You couldn't use the :tfilter:`escape` filter directly in this case, as it\n+would first convert the variable into a string, rather than working with the\n+individual elements of the sequence.\n+\n .. templatefilter:: slice\n \n ``slice``\n*** Add File: tests/template_tests/filter_tests/test_escapeseq.py\n+from django.test import SimpleTestCase\n+\n+from ..utils import setup\n+\n+\n+class EscapeseqTests(SimpleTestCase):\n+    @setup({\"escapeseq01\": '{{ a|join:\", \" }} -- {{ a|escapeseq|join:\", \" }}'})\n+    def test_escapeseq01(self):\n+        output = self.engine.render_to_string(\"escapeseq01\", {\"a\": [\"&\", \"<\"]})\n+        self.assertEqual(output, \"&amp;, &lt; -- &amp;, &lt;\")\n+\n+    @setup(\n+        {\n+            \"escapeseq02\": (\n+                '{% autoescape off %}{{ a|join:\", \" }} -- {{ a|escapeseq|join:\", \" }}'\n+                \"{% endautoescape %}\"\n+            )\n+        }\n+    )\n+    def test_escapeseq02(self):\n+        output = self.engine.render_to_string(\"escapeseq02\", {\"a\": [\"&\", \"<\"]})\n+        self.assertEqual(output, \"&, < -- &amp;, &lt;\")\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[tests/template_tests/filter_tests/test_escapeseq.py] modified=[django/template/defaultfilters.py docs/ref/templates/builtins.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/template/defaultfilters.py now (992 lines), around the change:
496:    with the results.
497:    """
498:    return [mark_safe(obj) for obj in value]
499:
500:
501:@register.filter(is_safe=True)
502:def escapeseq(value):
503:    """
504:    An "escape" filter for sequences. Escape each element in the sequence,
505:    individually, and return a list with the results.
506:    """
507:    return [escape(obj) for obj in value]
508:
509:
510:@register.filter(is_safe=True)

docs/ref/templates/builtins.txt now (3012 lines), around the change:
2375:first convert the variable into a string, rather than working with the
2376:individual elements of the sequence.
2377:
2378:.. templatefilter:: escapeseq
2379:
2380:``escapeseq``
2381:-------------
2382:
2383:Applies the :tfilter:`escape` filter to each element of a sequence. Useful in
2384:conjunction with other filters that operate on sequences, such as
2385::tfilter:`join`. For example:
2386:
2387:.. code-block:: html+django
2388:
2389:    {{ some_list|escapeseq|join:", " }}
2390:
2391:You couldn't use the :tfilter:`escape` filter directly in this case, as it
2392:would first convert the variable into a string, rather than working with the
2393:individual elements of the sequence.
2394:
2395:.. templatefilter:: slice
2396:
2397:``slice``
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/template_tests/filter_tests/test_escapeseq.py tests/template_tests/filter_tests/test_safeseq.py -q 2>&1 | tail -15"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py template_tests.filter_tests.test_escapeseq template_tests.filter_tests.test_safeseq --verbosity 1 2>&1 | tail -15"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 4 test(s).
System check identified no issues (0 silenced).
....
----------------------------------------------------------------------
Ran 4 tests in 0.248s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Template\\|template filter\\|Minor features\" docs/releases/5.0.txt | head -20"
}
```

**tool result**

```
126:Minor features
345:Templates
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '340,360p' docs/releases/5.0.txt"
}
```

**tool result**

```

* The new :meth:`.Signal.asend` and :meth:`.Signal.asend_robust` methods allow
  asynchronous signal dispatch. Signal receivers may be synchronous or
  asynchronous, and will be automatically adapted to the correct calling style.

Templates
~~~~~~~~~

* ...

Tests
~~~~~

* ...

URLs
~~~~

* ...

Utilities
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: docs/releases/5.0.txt\n@@\n Templates\n ~~~~~~~~~\n \n-* ...\n+* The new :tfilter:`escapeseq` template filter applies the :tfilter:`escape`\n+  filter to each element of a sequence, rather than escaping the sequence\n+  itself, which is useful when chaining filters such as :tfilter:`join`.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[docs/releases/5.0.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

docs/releases/5.0.txt now (556 lines), around the change:
345:Templates
346:~~~~~~~~~
347:
348:* The new :tfilter:`escapeseq` template filter applies the :tfilter:`escape`
349:  filter to each element of a sequence, rather than escaping the sequence
350:  itself, which is useful when chaining filters such as :tfilter:`join`.
351:
352:Tests
353:~~~~~
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^def escape\\|^def conditional_escape\" -A12 django/utils/html.py"
}
```

**tool result**

```
18:def escape(text):
19-    """
20-    Return the given text with ampersands, quotes and angle brackets encoded
21-    for use in HTML.
22-
23-    Always escape input, even if it's already escaped and marked as such.
24-    This may result in double-escaping. If this is a concern, use
25-    conditional_escape() instead.
26-    """
27-    return SafeString(html.escape(str(text)))
28-
29-
30-_js_escapes = {
--
50:def escapejs(value):
51-    """Hex encode characters for use in JavaScript strings."""
52-    return mark_safe(str(value).translate(_js_escapes))
53-
54-
55-_json_script_escapes = {
56-    ord(">"): "\\u003E",
57-    ord("<"): "\\u003C",
58-    ord("&"): "\\u0026",
59-}
60-
61-
62-def json_script(value, element_id=None, encoder=None):
--
82:def conditional_escape(text):
83-    """
84-    Similar to escape(), except that it doesn't operate on pre-escaped strings.
85-
86-    This function relies on the __html__ convention used both by Django's
87-    SafeData class and by third-party libraries like markupsafe.
88-    """
89-    if isinstance(text, Promise):
90-        text = str(text)
91-    if hasattr(text, "__html__"):
92-        return text.__html__()
93-    else:
94-        return escape(text)
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py template_tests.filter_tests --verbosity 1 2>&1 | tail -5; git diff --stat; git status --short"
}
```

**tool result**

```
....................................................................................................................................................................................................................................................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 452 tests in 0.547s

OK
 django/template/defaultfilters.py |  9 +++++++++
 docs/ref/templates/builtins.txt   | 17 +++++++++++++++++
 docs/releases/5.0.txt             |  4 +++-
 3 files changed, 29 insertions(+), 1 deletion(-)
 M django/template/defaultfilters.py
 M docs/ref/templates/builtins.txt
 M docs/releases/5.0.txt
?? .memdoor/
?? tests/template_tests/filter_tests/test_escapeseq.py
```

**assistant**

```
Implemented the `escapeseq` template filter.

- `django/template/defaultfilters.py`: added `escapeseq`, applying `escape()` to each sequence element and returning a list (the sequence counterpart to `safeseq`).
- `docs/ref/templates/builtins.txt`: documented `escapeseq` with the `join` example.
- `docs/releases/5.0.txt`: added a release note under Templates.
- `tests/template_tests/filter_tests/test_escapeseq.py`: tests autoescape on/off behavior.

Verification: all 452 `template_tests.filter_tests` pass. No git state changed (no commit/checkout/reset/stash).
```

## Run folder `team-solve-2026-11-06T113736`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
35966be4952409db849194b3c4b41972e29b4047
```

### `baseline-check.log`

```
check: python tests/runtests.py template_tests.filter_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 450 test(s).
System check identified no issues (0 silenced).
..................................................................................................................................................................................................................................................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 450 tests in 0.167s

OK
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/django/template/defaultfilters.py b/django/template/defaultfilters.py
index 5289ef34a0..cbf585ab86 100644
--- a/django/template/defaultfilters.py
+++ b/django/template/defaultfilters.py
@@ -498,6 +498,15 @@ def safeseq(value):
     return [mark_safe(obj) for obj in value]
 
 
+@register.filter(is_safe=True)
+def escapeseq(value):
+    """
+    An "escape" filter for sequences. Escape each element in the sequence,
+    individually, and return a list with the results.
+    """
+    return [escape(obj) for obj in value]
+
+
 @register.filter(is_safe=True)
 @stringfilter
 def striptags(value):
diff --git a/docs/ref/templates/builtins.txt b/docs/ref/templates/builtins.txt
index 3aa20dfc71..c83e7995af 100644
--- a/docs/ref/templates/builtins.txt
+++ b/docs/ref/templates/builtins.txt
@@ -2375,6 +2375,23 @@ You couldn't use the :tfilter:`safe` filter directly in this case, as it would
 first convert the variable into a string, rather than working with the
 individual elements of the sequence.
 
+.. templatefilter:: escapeseq
+
+``escapeseq``
+-------------
+
+Applies the :tfilter:`escape` filter to each element of a sequence. Useful in
+conjunction with other filters that operate on sequences, such as
+:tfilter:`join`. For example:
+
+.. code-block:: html+django
+
+    {{ some_list|escapeseq|join:", " }}
+
+You couldn't use the :tfilter:`escape` filter directly in this case, as it
+would first convert the variable into a string, rather than working with the
+individual elements of the sequence.
+
 .. templatefilter:: slice
 
 ``slice``
diff --git a/docs/releases/5.0.txt b/docs/releases/5.0.txt
index 611a7bd68b..4f13466eac 100644
--- a/docs/releases/5.0.txt
+++ b/docs/releases/5.0.txt
@@ -345,7 +345,9 @@ Signals
 Templates
 ~~~~~~~~~
 
-* ...
+* The new :tfilter:`escapeseq` template filter applies the :tfilter:`escape`
+  filter to each element of a sequence, rather than escaping the sequence
+  itself, which is useful when chaining filters such as :tfilter:`join`.
 
 Tests
 ~~~~~
diff --git a/tests/template_tests/filter_tests/test_escapeseq.py b/tests/template_tests/filter_tests/test_escapeseq.py
new file mode 100644
index 0000000000..f117661762
--- /dev/null
+++ b/tests/template_tests/filter_tests/test_escapeseq.py
@@ -0,0 +1,22 @@
+from django.test import SimpleTestCase
+
+from ..utils import setup
+
+
+class EscapeseqTests(SimpleTestCase):
+    @setup({"escapeseq01": '{{ a|join:", " }} -- {{ a|escapeseq|join:", " }}'})
+    def test_escapeseq01(self):
+        output = self.engine.render_to_string("escapeseq01", {"a": ["&", "<"]})
+        self.assertEqual(output, "&amp;, &lt; -- &amp;, &lt;")
+
+    @setup(
+        {
+            "escapeseq02": (
+                '{% autoescape off %}{{ a|join:", " }} -- {{ a|escapeseq|join:", " }}'
+                "{% endautoescape %}"
+            )
+        }
+    )
+    def test_escapeseq02(self):
+        output = self.engine.render_to_string("escapeseq02", {"a": ["&", "<"]})
+        self.assertEqual(output, "&, < -- &amp;, &lt;")
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

New template filter `escapeseq`
Description
	
Following #34574, and after some conversations within the security team, it seems appropriate to provide a new template filter escapeseq which would be to escape what safeseq is to safe. An example of usage would be:
{{ some_list|escapeseq|join:"," }}
where each item of some_list is escaped before applying the join operation. This usage makes sense in a context where autoescape is off.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py template_tests.filter_tests`

## Scope

`django/template/defaultfilters.py`
`tests/template_tests/filter_tests/`

## Done when

- `escapeseq` is registered as a new template filter in the default filter library.
- `escapeseq` escapes each item of the input sequence, mirroring what `safeseq` does with `safe`.
- With autoescape off, `{{ some_list|escapeseq|join:"," }}` escapes each item before the `join` operation.
- The filter is usable without loading a custom filter library.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py template_tests.filter_tests`

## Scope
`django/template/defaultfilters.py`
`tests/template_tests/filter_tests/`

## Done when
- `escapeseq` is registered as a new template filter in the default filter library.
- `escapeseq` escapes each item of the input sequence, mirroring what `safeseq` does with `safe`.
- With autoescape off, `{{ some_list|escapeseq|join:"," }}` escapes each item before the `join` operation.
- The filter is usable without loading a custom filter library.

## Approach
Add `escapeseq` beside `safeseq` in `django/template/defaultfilters.py`, returning `[escape(item) for item in value]` using Django’s existing `escape` helper, then add behavior tests under `tests/template_tests/filter_tests/` and run the filter test suite.

Candidate approaches:
1. Use `django.utils.html.escape` per item. Simple, matches the existing `escape` filter, and escapes every item including `SafeString` values.
2. Use `conditional_escape` per item. Avoids double-escaping already-safe values, but differs from `escape` and may leave safe items unescaped, which is not the “escape what `safeseq` is to `safe`” behavior.
3. Implement via `mark_safe`/`format_html`. Unnecessary here; `join` already marks its joined result safe, and the filter’s job is only per-item escaping.

If the first attempt fails, check the `escape` import in `defaultfilters.py`, filter registration, test discovery under `template_tests.filter_tests`, and that the test renders with autoescape disabled.


# django/template/defaultfilters.py

```
"""Default variable filters."""
import random as random_module
import re
import types
import warnings
from decimal import ROUND_HALF_UP, Context, Decimal, InvalidOperation, getcontext
from functools import wraps
from inspect import unwrap
from operator import itemgetter
from pprint import pformat
from urllib.parse import quote

from django.utils import formats
from django.utils.dateformat import format, time_format
from django.utils.deprecation import RemovedInDjango51Warning
from django.utils.encoding import iri_to_uri
from django.utils.html import avoid_wrapping, conditional_escape, escape, escapejs
from django.utils.html import json_script as _json_script
from django.utils.html import linebreaks, strip_tags
from django.utils.html import urlize as _urlize
from django.utils.safestring import SafeData, mark_safe
from django.utils.text import Truncator, normalize_newlines, phone2numeric
from django.utils.text import slugify as _slugify
from django.utils.text import wrap
from django.utils.timesince import timesince, timeuntil
from django.utils.translation import gettext, ngettext

from .base import VARIABLE_ATTRIBUTE_SEPARATOR
from .library import Library

register = Library()


#######################
# STRING DECORATOR    #
#######################


def stringfilter(func):
    """
    Decorator for filters which should only receive strings. The object
    passed as the first positional argument will be converted to a string.
    """

    @wraps(func)
    def _dec(first, *args, **kwargs):
        first = str(first)
        result = func(first, *args, **kwargs)
        if isinstance(first, SafeData) and getattr(unwrap(func), "is_safe", False):
            result = mark_safe(result)
        return result

    return _dec


###################
# STRINGS         #
###################


@register.filter(is_safe=True)
@stringfilter
def addslashes(value):
    """
    Add slashes before quotes. Useful for escaping strings in CSV, for
    example. Less useful for escaping JavaScript; use the ``escapejs``
    filter instead.
    """
    return value.replace("\\", "\\\\").replace('"', '\\"').replace("'", "\\'")


@register.filter(is_safe=True)
@stringfilter
def capfirst(value):
    """Capitalize the first character of the value."""
    return value and value[0].upper() + value[1:]


@register.filter("escapejs")
@stringfilter
def escapejs_filter(value):
    """Hex encode characters for use in JavaScript strings."""
    return escapejs(value)


@register.filter(is_safe=True)
def json_script(value, element_id=None):
    """
    Output value JSON-encoded, wrapped in a <script type="application/json">
    tag (with an optional id).
    """
    return _json_script(value, element_id)


@register.filter(is_safe=True)
def floatformat(text, arg=-1):
    """
    Display a float to a specified number of decimal places.

    If called without an argument, display the floating point number with one
    decimal place -- but only if there's a decimal place to be displayed:

    * num1 = 34.23234
    * num2 = 34.00000
    * num3 = 34.26000
    * {{ num1|floatformat }} displays "34.2"
    * {{ num2|floatformat }} displays "34"
    * {{ num3|floatformat }} displays "34.3"

    If arg is positive, always display exactly arg number of decimal places:

    * {{ num1|floatformat:3 }} displays "34.232"
    * {{ num2|floatformat:3 }} displays "34.000"
    * {{ num3|floatformat:3 }} displays "34.260"

    If arg is negative, display arg number of decimal places -- but only if
    there are places to be displayed:

    * {{ num1|floatformat:"-3" }} displays "34.232"
    * {{ num2|floatformat:"-3" }} displays "34"
    * {{ num3|floatformat:"-3" }} displays "34.260"

    If arg has the 'g' suffix, force the result to be grouped by the
    THOUSAND_SEPARATOR for the active locale. When the active locale is
    en (English):

    * {{ 6666.6666|floatformat:"2g" }} displays "6,666.67"
    * {{ 10000|floatformat:"g" }} displays "10,000"

    If arg has the 'u' suffix, force the result to be unlocalized. When the
    active locale is pl (Polish):

    * {{ 66666.6666|floatformat:"2" }} displays "66666,67"
    * {{ 66666.6666|floatformat:"2u" }} displays "66666.67"

    If the input float is infinity or NaN, display the string representation
    of that value.
    """
    force_grouping = False
    use_l10n = True
    if isinstance(arg, str):
        last_char = arg[-1]
        if arg[-2:] in {"gu", "ug"}:
            force_grouping = True
            use_l10n = False
            arg = arg[:-2] or -1
        elif last_char == "g":
            force_grouping = True
            arg = arg[:-1] or -1
        elif last_char == "u":
            use_l10n = False
            arg = arg[:-1] or -1
    try:
        input_val = str(text)
        d = Decimal(input_val)
    except InvalidOperation:
        try:
            d = Decimal(str(float(text)))
        except (ValueError, InvalidOperation, TypeError):
            return ""
    try:
        p = int(arg)
    except ValueError:
        return input_val

    try:
        m = int(d) - d
    except (ValueError, OverflowError, InvalidOperation):
        return input_val

    if not m and p <= 0:
        return mark_safe(
            formats.number_format(
                "%d" % (int(d)),
                0,
                use_l10n=use_l10n,
                force_grouping=force_grouping,
            )
        )

    exp = Decimal(1).scaleb(-abs(p))
    # Set the precision high enough to avoid an exception (#15789).
    tupl = d.as_tuple()
    units = len(tupl[1])
    units += -tupl[2] if m else tupl[2]
    prec = abs(p) + units + 1
    prec = max(getcontext().prec, prec)

    # Avoid conversion to scientific notation by accessing `sign`, `digits`,
    # and `exponent` from Decimal.as_tuple() directly.
    rounded_d = d.quantize(exp, ROUND_HALF_UP, Context(prec=prec))
    sign, digits, exponent = rounded_d.as_tuple()
    digits = [str(digit) for digit in reversed(digits)]
    while len(digits) <= abs(exponent):
        digits.append("0")
    digits.insert(-exponent, ".")
    if sign and rounded_d:
        digits.append("-")
    number = "".join(reversed(digits))
    return mark_safe(
        formats.number_format(
            number,
            abs(p),
            use_l10n=use_l10n,
            force_grouping=force_grouping,
        )
    )


@register.filter(is_safe=True)
@stringfilter
def iriencode(value):
    """Escape an IRI value for use in a URL."""
    return iri_to_uri(value)


@register.filter(is_safe=True, needs_autoescape=True)
@stringfilter
def linenumbers(value, autoescape=True):
    """Display text with line numbers."""
    lines = value.split("\n")
    # Find the maximum width of the line count, for use with zero padding
    # string format command
    width = str(len(str(len(lines))))
    if not autoescape or isinstance(value, SafeData):
        for i, line in enumerate(lines):
            lines[i] = ("%0" + width + "d. %s") % (i + 1, line)
    else:
        for i, line in enumerate(lines):
            lines[i] = ("%0" + width + "d. %s") % (i + 1, escape(line))
    return mark_safe("\n".join(lines))


@register.filter(is_safe=True)
@stringfilter
def lower(value):
    """Convert a string into all lowercase."""
    return value.lower()


@register.filter(is_safe=False)
@stringfilter
def make_list(value):
    """
    Return the value turned into a list.

    For an integer, it's a list of digits.
    For a string, it's a list of characters.
    """
    return list(value)


@register.filter(is_safe=True)
@stringfilter
def slugify(value):
    """
    Convert to ASCII. Convert spaces to hyphens. Remove characters that aren't
    alphanumerics, underscores, or hyphens. Convert to lowercase. Also strip
    leading and trailing whitespace.
    """
    return _slugify(value)


@register.filter(is_safe=True)
def stringformat(value, arg):
    """
    Format the variable according to the arg, a string formatting specifier.

    This specifier uses Python string formatting syntax, with the exception
    that the leading "%" is dropped.

    See https://docs.python.org/library/stdtypes.html#printf-style-string-formatting
    for documentation of Python string formatting.
    """
    if isinstance(value, tuple):
        value = str(value)
    try:
        return ("%" + str(arg)) % value
    except (ValueError, TypeError):
        return ""


@register.filter(is_safe=True)
@stringfilter
def title(value):
    """Convert a string into titlecase."""
    t = re.sub("([a-z])'([A-Z])", lambda m: m[0].lower(), value.title())
    return re.sub(r"\d([A-Z])", lambda m: m[0].lower(), t)


@register.filter(is_safe=True)
@stringfilter
def truncatechars(value, arg):
    """Truncate a string after `arg` number of characters."""
    try:
        length = int(arg)
    except ValueError:  # Invalid literal for int().
        return value  # Fail silently.
    return Truncator(value).chars(length)


@register.filter(is_safe=True)
@stringfilter
def truncatechars_html(value, arg):
    """
    Truncate HTML after `arg` number of chars.
    Preserve newlines in the HTML.
    """
    try:
        length = int(arg)
    except ValueError:  # invalid literal for int()
        return value  # Fail silently.
    return Truncator(value).chars(length, html=True)


@register.filter(is_safe=True)
@stringfilter
def truncatewords(value, arg):
    """
    Truncate a string after `arg` number of words.
    Remove newlines within the string.
    """
    try:
        length = int(arg)
    except ValueError:  # Invalid literal for int().
        return value  # Fail silently.
    return Truncator(value).words(length, truncate=" …")


@register.filter(is_safe=True)
@stringfilter
def truncatewords_html(value, arg):
    """
    Truncate HTML after `arg` number of words.
    Preserve newlines in the HTML.
    """
    try:
        length = int(arg)
    except ValueError:  # invalid literal for int()
        return value  # Fail silently.
    return Truncator(value).words(length, html=True, truncate=" …")


@register.filter(is_safe=False)
@stringfilter
def upper(value):
    """Convert a string into all uppercase."""
    return value.upper()


@register.filter(is_safe=False)
@stringfilter
def urlencode(value, safe=None):
    """
    Escape a value for use in a URL.

    The ``safe`` parameter determines the characters which should not be
    escaped by Python's quote() function. If not provided, use the default safe
    characters (but an empty string can be provided when *all* characters
    should be escaped).
    """
    kwargs = {}
    if safe is not None:
        kwargs["safe"] = safe
    return quote(value, **kwargs)


@register.filter(is_safe=True, needs_autoescape=True)
@stringfilter
def urlize(value, autoescape=True):
    """Convert URLs in plain text into clickable links."""
    return mark_safe(_urlize(value, nofollow=True, autoescape=autoescape))


@register.filter(is_safe=True, needs_autoescape=True)
@stringfilter
def urlizetrunc(value, limit, autoescape=True):
    """
    Convert URLs into clickable links, truncating URLs to the given character
    limit, and adding 'rel=nofollow' attribute to discourage spamming.

    Argument: Length to truncate URLs to.
    """
    return mark_safe(
        _urlize(value, trim_url_limit=int(limit), nofollow=True, autoescape=autoescape)
    )


@register.filter(is_safe=False)
@stringfilter
def wordcount(value):
    """Return the number of words."""
    return len(value.split())


@register.filter(is_safe=True)
@stringfilter
def wordwrap(value, arg):
    """Wrap words at `arg` line length."""
    return wrap(value, int(arg))


@register.filter(is_safe=True)
@stringfilter
def ljust(value, arg):
    """Left-align the value in a field of a given width."""
    return value.ljust(int(arg))


@register.filter(is_safe=True)
@stringfilter
def rjust(value, arg):
    """Right-align the value in a field of a given width."""
    return value.rjust(int(arg))


@register.filter(is_safe=True)
@stringfilter
def center(value, arg):
    """Center the value in a field of a given width."""
    return value.center(int(arg))


@register.filter
@stringfilter
def cut(value, arg):
    """Remove all values of arg from the given string."""
    safe = isinstance(value, SafeData)
    value = value.replace(arg, "")
    if safe and arg != ";":
        return mark_safe(value)
    return value


###################
# HTML STRINGS    #
###################


@register.filter("escape", is_safe=True)
@stringfilter
def escape_filter(value):
    """Mark the value as a string that should be auto-escaped."""
    return conditional_escape(value)


@register.filter(is_safe=True)
@stringfilter
def force_escape(value):
    """
    Escape a string's HTML. Return a new string containing the escaped
    characters (as opposed to "escape", which marks the content for later
    possible escaping).
    """
    return escape(value)


@register.filter("linebreaks", is_safe=True, needs_autoescape=True)
@stringfilter
def linebreaks_filter(value, autoescape=True):
    """
    Replace line breaks in plain text with appropriate HTML; a single
    newline becomes an HTML line break (``<br>``) and a new line
    followed by a blank line becomes a paragraph break (``</p>``).
    """
    autoescape = autoescape and not isinstance(value, SafeData)
    return mark_safe(linebreaks(value, autoescape))


@register.filter(is_safe=True, needs_autoescape=True)
@stringfilter
def linebreaksbr(value, autoescape=True):
    """
    Convert all newlines in a piece of plain text to HTML line breaks
    (``<br>``).
    """
    autoescape = autoescape and not isinstance(value, SafeData)
    value = normalize_newlines(value)
    if autoescape:
        value = escape(value)
    return mark_safe(value.replace("\n", "<br>"))


@register.filter(is_safe=True)
@stringfilter
def safe(value):
    """Mark the value as a string that should not be auto-escaped."""
    return mark_safe(value)


@register.filter(is_safe=True)
def safeseq(value):
    """
    A "safe" filter for sequences. Mark each element in the sequence,
    individually, as safe, after converting them to strings. Return a list
    with the results.
    """
    return [mark_safe(obj) for obj in value]


@register.filter(is_safe=True)
def escapeseq(value):
    """
    An "escape" filter for sequences. Escape each element in the sequence,
    individually, and return a list with the results.
    """
    return [escape(obj) for obj in value]


@register.filter(is_safe=True)
@stringfilter
def striptags(value):
    """Strip all [X]HTML tags."""
    return strip_tags(value)


###################
# LISTS           #
###################


def _property_resolver(arg):
    """
    When arg is convertible to float, behave like operator.itemgetter(arg)
    Otherwise, chain __getitem__() and getattr().

    >>> _property_resolver(1)('abc')
    'b'
    >>> _property_resolver('1')('abc')
    Traceback (most recent call last):
    ...
    TypeError: string indices must be integers
    >>> class Foo:
    ...     a = 42
    ...     b = 3.14
    ...     c = 'Hey!'
    >>> _property_resolver('b')(Foo())
    3.14
    """
    try:
        float(arg)
    except ValueError:
        if VARIABLE_ATTRIBUTE_SEPARATOR + "_" in arg or arg[0] == "_":
            raise AttributeError("Access to private variables is forbidden.")
        parts = arg.split(VARIABLE_ATTRIBUTE_SEPARATOR)

        def resolve(value):
            for part in parts:
                try:
                    value = value[part]
                except (AttributeError, IndexError, KeyError, TypeError, ValueError):
                    value = getattr(value, part)
            return value

        return resolve
    else:
        return itemgetter(arg)


@register.filter(is_safe=False)
def dictsort(value, arg):
    """
    Given a list of dicts, return that list sorted by the property given in
    the argument.
    """
    try:
        return sorted(value, key=_property_resolver(arg))
    except (AttributeError, TypeError):
        return ""


@register.filter(is_safe=False)
def dictsortreversed(value, arg):
    """
    Given a list of dicts, return that list sorted in reverse order by the
    property given in the argument.
    """
    try:
        return sorted(value, key=_property_resolver(arg), reverse=True)
    except (AttributeError, TypeError):
        return ""


@register.filter(is_safe=False)
def first(value):
    """Return the first item in a list."""
    try:
        return value[0]
    except IndexError:
        return ""


@register.filter(is_safe=True, needs_autoescape=True)
def join(value, arg, autoescape=True):
    """Join a list with a string, like Python's ``str.join(list)``."""
    try:
        if autoescape:
            data = conditional_escape(arg).join([conditional_escape(v) for v in value])
        else:
            data = arg.join(value)
    except TypeError:  # Fail silently if arg isn't iterable.
        return value
    return mark_safe(data)


@register.filter(is_safe=True)
def last(value):
    """Return the last item in a list."""
    try:
        return value[-1]
    except IndexError:
        return ""


@register.filter(is_safe=False)
def length(value):
    """Return the length of the value - useful for lists."""
    try:
        return len(value)
    except (ValueError, TypeError):
        return 0


@register.filter(is_safe=False)
def length_is(value, arg):
    """Return a boolean of whether the value's length is the argument."""
    warnings.warn(
        "The length_is template filter is deprecated in favor of the length template "
        "filter and the == operator within an {% if %} tag.",
        RemovedInDjango51Warning,
    )
    try:
        return len(value) == int(arg)
    except (ValueError, TypeError):
        return ""


@register.filter(is_safe=True)
def random(value):
    """Return a random item from the list."""
    try:
        return random_module.choice(value)
    except IndexError:
        return ""


@register.filter("slice", is_safe=True)
def slice_filter(value, arg):
    """
    Return a slice of the list using the same syntax as Python's list slicing.
    """
    try:
        bits = []
        for x in str(arg).split(":"):
            if not x:
                bits.append(None)
            else:
                bits.append(int(x))
        return value[slice(*bits)]

    except (ValueError, TypeError):
        return value  # Fail silently.


@register.filter(is_safe=True, needs_autoescape=True)
def unordered_list(value, autoescape=True):
    """
    Recursively take a self-nested list and return an HTML unordered list --
    WITHOUT opening and closing <ul> tags.

    Assume the list is in the proper format. For example, if ``var`` contains:
    ``['States', ['Kansas', ['Lawrence', 'Topeka'], 'Illinois']]``, then
    ``{{ var|unordered_list }}`` returns::

        <li>States
        <ul>
                <li>Kansas
                <ul>
                        <li>Lawrence</li>
                        <li>Topeka</li>
                </ul>
                </li>
                <li>Illinois</li>
        </ul>
        </li>
    """
    if autoescape:
        escaper = conditional_escape
    else:

        def escaper(x):
            return x

    def walk_items(item_list):
        item_iterator = iter(item_list)
        try:
            item = next(item_iterator)
            while True:
                try:
                    next_item = next(item_iterator)
                except StopIteration:
                    yield item, None
                    break
                if isinstance(next_item, (list, tuple, types.GeneratorType)):
                    try:
                        iter(next_item)
                    except TypeError:
                        pass
                    else:
                        yield item, next_item
                        item = next(item_iterator)
                        continue
                yield item, None
                item = next_item
        except StopIteration:
            pass

    def list_formatter(item_list, tabs=1):
        indent = "\t" * tabs
        output = []
        for item, children in walk_items(item_list):
            sublist = ""
            if children:
                sublist = "\n%s<ul>\n%s\n%s</ul>\n%s" % (
                    indent,
                    list_formatter(children, tabs + 1),
                    indent,
                    indent,
                )
            output.append("%s<li>%s%s</li>" % (indent, escaper(item), sublist))
        return "\n".join(output)

    return mark_safe(list_formatter(value))


###################
# INTEGERS        #
###################


@register.filter(is_safe=False)
def add(value, arg):
    """Add the arg to the value."""
    try:
        return int(value) + int(arg)
    except (ValueError, TypeError):
        try:
            return value + arg
        except Exception:
            return ""


@register.filter(is_safe=False)
def get_digit(value, arg):
    """
    Given a whole number, return the requested digit of it, where 1 is the
    right-most digit, 2 is the second-right-most digit, etc. Return the
    original value for invalid input (if input or argument is not an integer,
    or if argument is less than 1). Otherwise, output is always an integer.
    """
    try:
        arg = int(arg)
        value = int(value)
    except ValueError:
        return value  # Fail silently for an invalid argument
    if arg < 1:
        return value
    try:
        return int(str(value)[-arg])
    except IndexError:
        return 0


###################
# DATES           #
###################


@register.filter(expects_localtime=True, is_safe=False)
def date(value, arg=None):
    """Format a date according to the given format."""
    if value in (None, ""):
        return ""
    try:
        return formats.date_format(value, arg)
    except AttributeError:
        try:
            return format(value, arg)
        except AttributeError:
            return ""


@register.filter(expects_localtime=True, is_safe=False)
def time(value, arg=None):
    """Format a time according to the given format."""
    if value in (None, ""):
        return ""
    try:
        return formats.time_format(value, arg)
    except (AttributeError, TypeError):
        try:
            return time_format(value, arg)
        except (AttributeError, TypeError):
            return ""


@register.filter("timesince", is_safe=False)
def timesince_filter(value, arg=None):
    """Format a date as the time since that date (i.e. "4 days, 6 hours")."""
    if not value:
        return ""
    try:
        if arg:
            return timesince(value, arg)
        return timesince(value)
    except (ValueError, TypeError):
        return ""


@register.filter("timeuntil", is_safe=False)
def timeuntil_filter(value, arg=None):
    """Format a date as the time until that date (i.e. "4 days, 6 hours")."""
    if not value:
        return ""
    try:
        return timeuntil(value, arg)
    except (ValueError, TypeError):
        return ""


###################
# LOGIC           #
###################


@register.filter(is_safe=False)
def default(value, arg):
    """If value is unavailable, use given default."""
    return value or arg


@register.filter(is_safe=False)
def default_if_none(value, arg):
    """If value is None, use given default."""
    if value is None:
        return arg
    return value


@register.filter(is_safe=False)
def divisibleby(value, arg):
    """Return True if the value is divisible by the argument."""
    return int(value) % int(arg) == 0


@register.filter(is_safe=False)
def yesno(value, arg=None):
    """
    Given a string mapping values for true, false, and (optionally) None,
    return one of those strings according to the value:

    ==========  ======================  ==================================
    Value       Argument                Outputs
    ==========  ======================  ==================================
    ``True``    ``"yeah,no,maybe"``     ``yeah``
    ``False``   ``"yeah,no,maybe"``     ``no``
    ``None``    ``"yeah,no,maybe"``     ``maybe``
    ``None``    ``"yeah,no"``           ``"no"`` (converts None to False
                                        if no mapping for None is given.
    ==========  ======================  ==================================
    """
    if arg is None:
        # Translators: Please do not add spaces around commas.
        arg = gettext("yes,no,maybe")
    bits = arg.split(",")
    if len(bits) < 2:
        return value  # Invalid arg.
    try:
        yes, no, maybe = bits
    except ValueError:
        # Unpack list of wrong size (no "maybe" value provided).
        yes, no, maybe = bits[0], bits[1], bits[1]
    if value is None:
        return maybe
    if value:
        return yes
    return no


###################
# MISC            #
###################


@register.filter(is_safe=True)
def filesizeformat(bytes_):
    """
    Format the value like a 'human-readable' file size (i.e. 13 KB, 4.1 MB,
    102 bytes, etc.).
    """
    try:
        bytes_ = int(bytes_)
    except (TypeError, ValueError, UnicodeDecodeError):
        value = ngettext("%(size)d byte", "%(size)d bytes", 0) % {"size": 0}
        return avoid_wrapping(value)

    def filesize_number_format(value):
        return formats.number_format(round(value, 1), 1)

    KB = 1 << 10
    MB = 1 << 20
    GB = 1 << 30
    TB = 1 << 40
    PB = 1 << 50

    negative = bytes_ < 0
    if negative:
        bytes_ = -bytes_  # Allow formatting of negative numbers.

    if bytes_ < KB:
        value = ngettext("%(size)d byte", "%(size)d bytes", bytes_) % {"size": bytes_}
    elif bytes_ < MB:
        value = gettext("%s KB") % filesize_number_format(bytes_ / KB)
    elif bytes_ < GB:
        value = gettext("%s MB") % filesize_number_format(bytes_ / MB)
    elif bytes_ < TB:
        value = gettext("%s GB") % filesize_number_format(bytes_ / GB)
    elif bytes_ < PB:
        value = gettext("%s TB") % filesize_number_format(bytes_ / TB)
    else:
        value = gettext("%s PB") % filesize_number_format(bytes_ / PB)

    if negative:
        value = "-%s" % value
    return avoid_wrapping(value)


@register.filter(is_safe=False)
def pluralize(value, arg="s"):
    """
    Return a plural suffix if the value is not 1, '1', or an object of
    length 1. By default, use 's' as the suffix:

    * If value is 0, vote{{ value|pluralize }} display "votes".
    * If value is 1, vote{{ value|pluralize }} display "vote".
    * If value is 2, vote{{ value|pluralize }} display "votes".

    If an argument is provided, use that string instead:

    * If value is 0, class{{ value|pluralize:"es" }} display "classes".
    * If value is 1, class{{ value|pluralize:"es" }} display "class".
    * If value is 2, class{{ value|pluralize:"es" }} display "classes".

    If the provided argument contains a comma, use the text before the comma
    for the singular case and the text after the comma for the plural case:

    * If value is 0, cand{{ value|pluralize:"y,ies" }} display "candies".
    * If value is 1, cand{{ value|pluralize:"y,ies" }} display "candy".
    * If value is 2, cand{{ value|pluralize:"y,ies" }} display "candies".
    """
    if "," not in arg:
        arg = "," + arg
    bits = arg.split(",")
    if len(bits) > 2:
        return ""
    singular_suffix, plural_suffix = bits[:2]

    try:
        return singular_suffix if float(value) == 1 else plural_suffix
    except ValueError:  # Invalid string that's not a number.
        pass
    except TypeError:  # Value isn't a string or a number; maybe it's a list?
        try:
            return singular_suffix if len(value) == 1 else plural_suffix
        except TypeError:  # len() of unsized object.
            pass
    return ""


@register.filter("phone2numeric", is_safe=True)
def phone2numeric_filter(value):
    """Take a phone number and converts it in to its numerical equivalent."""
    return phone2numeric(value)


@register.filter(is_safe=True)
def pprint(value):
    """A wrapper around pprint.pprint -- for debugging, really."""
    try:
        return pformat(value)
    except Exception as e:
        return "Error in formatting: %s: %s" % (e.__class__.__name__, e)

```


# tests/template_tests/filter_tests (the files in it)

tests/template_tests/filter_tests/__init__.py
tests/template_tests/filter_tests/test_add.py
tests/template_tests/filter_tests/test_addslashes.py
tests/template_tests/filter_tests/test_autoescape.py
tests/template_tests/filter_tests/test_capfirst.py
tests/template_tests/filter_tests/test_center.py
tests/template_tests/filter_tests/test_chaining.py
tests/template_tests/filter_tests/test_cut.py
tests/template_tests/filter_tests/test_date.py
tests/template_tests/filter_tests/test_default.py
tests/template_tests/filter_tests/test_default_if_none.py
tests/template_tests/filter_tests/test_dictsort.py
tests/template_tests/filter_tests/test_dictsortreversed.py
tests/template_tests/filter_tests/test_divisibleby.py
tests/template_tests/filter_tests/test_escape.py
tests/template_tests/filter_tests/test_escapejs.py
tests/template_tests/filter_tests/test_filesizeformat.py
tests/template_tests/filter_tests/test_first.py
tests/template_tests/filter_tests/test_floatformat.py
tests/template_tests/filter_tests/test_force_escape.py
tests/template_tests/filter_tests/test_get_digit.py
tests/template_tests/filter_tests/test_iriencode.py
tests/template_tests/filter_tests/test_join.py
tests/template_tests/filter_tests/test_json_script.py
tests/template_tests/filter_tests/test_last.py
tests/template_tests/filter_tests/test_length.py
tests/template_tests/filter_tests/test_length_is.py
tests/template_tests/filter_tests/test_linebreaks.py
tests/template_tests/filter_tests/test_linebreaksbr.py
tests/template_tests/filter_tests/test_linenumbers.py
tests/template_tests/filter_tests/test_ljust.py
tests/template_tests/filter_tests/test_lower.py
tests/template_tests/filter_tests/test_make_list.py
tests/template_tests/filter_tests/test_phone2numeric.py
tests/template_tests/filter_tests/test_pluralize.py
tests/template_tests/filter_tests/test_random.py
tests/template_tests/filter_tests/test_rjust.py
tests/template_tests/filter_tests/test_safe.py
tests/template_tests/filter_tests/test_safeseq.py
tests/template_tests/filter_tests/test_slice.py
tests/template_tests/filter_tests/test_slugify.py
tests/template_tests/filter_tests/test_stringformat.py
tests/template_tests/filter_tests/test_striptags.py
tests/template_tests/filter_tests/test_time.py
tests/template_tests/filter_tests/test_timesince.py
tests/template_tests/filter_tests/test_timeuntil.py
tests/template_tests/filter_tests/test_title.py
tests/template_tests/filter_tests/test_truncatechars.py
tests/template_tests/filter_tests/test_truncatechars_html.py
tests/template_tests/filter_tests/test_truncatewords.py
tests/template_tests/filter_tests/test_truncatewords_html.py
tests/template_tests/filter_tests/test_unordered_list.py
tests/template_tests/filter_tests/test_upper.py
tests/template_tests/filter_tests/test_urlencode.py
tests/template_tests/filter_tests/test_urlize.py
tests/template_tests/filter_tests/test_urlizetrunc.py
tests/template_tests/filter_tests/test_wordcount.py
tests/template_tests/filter_tests/test_wordwrap.py
tests/template_tests/filter_tests/test_yesno.py
tests/template_tests/filter_tests/timezone_utils.py


# The last commit

```
35966be495 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py template_tests.filter_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 452 test(s).
System check identified no issues (0 silenced).
....................................................................................................................................................................................................................................................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 452 tests in 0.146s

OK
scope: django/template/defaultfilters.py tests/template_tests/filter_tests
changed: django/template/defaultfilters.py +9 -0
OUTSIDE THE SCOPE: docs/ref/templates/builtins.txt +17 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: docs/releases/5.0.txt +3 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/template_tests/filter_tests/test_escapeseq.py +22 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/template/defaultfilters.py b/django/template/defaultfilters.py
index 5289ef34a0..cbf585ab86 100644
--- a/django/template/defaultfilters.py
+++ b/django/template/defaultfilters.py
@@ -498,6 +498,15 @@ def safeseq(value):
     return [mark_safe(obj) for obj in value]
 
 
+@register.filter(is_safe=True)
+def escapeseq(value):
+    """
+    An "escape" filter for sequences. Escape each element in the sequence,
+    individually, and return a list with the results.
+    """
+    return [escape(obj) for obj in value]
+
+
 @register.filter(is_safe=True)
 @stringfilter
 def striptags(value):
diff --git a/docs/ref/templates/builtins.txt b/docs/ref/templates/builtins.txt
index 3aa20dfc71..c83e7995af 100644
--- a/docs/ref/templates/builtins.txt
+++ b/docs/ref/templates/builtins.txt
@@ -2375,6 +2375,23 @@ You couldn't use the :tfilter:`safe` filter directly in this case, as it would
 first convert the variable into a string, rather than working with the
 individual elements of the sequence.
 
+.. templatefilter:: escapeseq
+
+``escapeseq``
+-------------
+
+Applies the :tfilter:`escape` filter to each element of a sequence. Useful in
+conjunction with other filters that operate on sequences, such as
+:tfilter:`join`. For example:
+
+.. code-block:: html+django
+
+    {{ some_list|escapeseq|join:", " }}
+
+You couldn't use the :tfilter:`escape` filter directly in this case, as it
+would first convert the variable into a string, rather than working with the
+individual elements of the sequence.
+
 .. templatefilter:: slice
 
 ``slice``
diff --git a/docs/releases/5.0.txt b/docs/releases/5.0.txt
index 611a7bd68b..4f13466eac 100644
--- a/docs/releases/5.0.txt
+++ b/docs/releases/5.0.txt
@@ -345,7 +345,9 @@ Signals
 Templates
 ~~~~~~~~~
 
-* ...
+* The new :tfilter:`escapeseq` template filter applies the :tfilter:`escape`
+  filter to each element of a sequence, rather than escaping the sequence
+  itself, which is useful when chaining filters such as :tfilter:`join`.
 
 Tests
 ~~~~~
diff --git a/tests/template_tests/filter_tests/test_escapeseq.py b/tests/template_tests/filter_tests/test_escapeseq.py
new file mode 100644
index 0000000000..f117661762
--- /dev/null
+++ b/tests/template_tests/filter_tests/test_escapeseq.py
@@ -0,0 +1,22 @@
+from django.test import SimpleTestCase
+
+from ..utils import setup
+
+
+class EscapeseqTests(SimpleTestCase):
+    @setup({"escapeseq01": '{{ a|join:", " }} -- {{ a|escapeseq|join:", " }}'})
+    def test_escapeseq01(self):
+        output = self.engine.render_to_string("escapeseq01", {"a": ["&", "<"]})
+        self.assertEqual(output, "&amp;, &lt; -- &amp;, &lt;")
+
+    @setup(
+        {
+            "escapeseq02": (
+                '{% autoescape off %}{{ a|join:", " }} -- {{ a|escapeseq|join:", " }}'
+                "{% endautoescape %}"
+            )
+        }
+    )
+    def test_escapeseq02(self):
+        output = self.engine.render_to_string("escapeseq02", {"a": ["&", "<"]})
+        self.assertEqual(output, "&, < -- &amp;, &lt;")
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
check: python tests/runtests.py template_tests.filter_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 452 test(s).
System check identified no issues (0 silenced).
....................................................................................................................................................................................................................................................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 452 tests in 0.267s

OK
scope: django/template/defaultfilters.py tests/template_tests/filter_tests
changed: django/template/defaultfilters.py +9 -0
OUTSIDE THE SCOPE: docs/ref/templates/builtins.txt +17 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: docs/releases/5.0.txt +3 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/template_tests/filter_tests/test_escapeseq.py +22 -0
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
# Notes, run 2026-11-06T113736

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

New template filter `escapeseq`
Description
	
Following #34574, and after some conversations within the security team, it seems appropriate to provide a new template filter escapeseq which would be to escape what safeseq is to safe. An example of usage would be:
{{ some_list|escapeseq|join:"," }}
where each item of some_list is escaped before applying the join operation. This usage makes sense in a context where autoescape is off.


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
django/conf/locale/ckb/LC_MESSAGES/django.mo
django/conf/locale/ckb/LC_MESSAGES/django.po
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
django/conf/locale/en_IE/__init__.py
django/conf/locale/en_IE/formats.py
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
django/contrib/admin/locale/ckb/LC_MESSAGES/django.mo
django/contrib/admin/locale/ckb/LC_MESSAGES/django.po
django/contrib/admin/locale/ckb/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/ckb/LC_MESSAGES/djangojs.po
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
```


# The last commit

```
35966be495 SWE-bench


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
    "eslint": "^8.36.0",
    "puppeteer": "^19.8.2",
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
`python tests/runtests.py template_tests.filter_tests`

## Scope
`django/template/defaultfilters.py`
`tests/template_tests/filter_tests/`

## Done when
- `escapeseq` is registered as a new template filter in the default filter library.
- `escapeseq` escapes each item of the input sequence, mirroring what `safeseq` does with `safe`.
- With autoescape off, `{{ some_list|escapeseq|join:"," }}` escapes each item before the `join` operation.
- The filter is usable without loading a custom filter library.

## Approach
Add `escapeseq` beside `safeseq` in `django/template/defaultfilters.py`, returning `[escape(item) for item in value]` using Django’s existing `escape` helper, then add behavior tests under `tests/template_tests/filter_tests/` and run the filter test suite.

Candidate approaches:
1. Use `django.utils.html.escape` per item. Simple, matches the existing `escape` filter, and escapes every item including `SafeString` values.
2. Use `conditional_escape` per item. Avoids double-escaping already-safe values, but differs from `escape` and may leave safe items unescaped, which is not the “escape what `safeseq` is to `safe`” behavior.
3. Implement via `mark_safe`/`format_html`. Unnecessary here; `join` already marks its joined result safe, and the filter’s job is only per-item escaping.

If the first attempt fails, check the `escape` import in `defaultfilters.py`, filter registration, test discovery under `template_tests.filter_tests`, and that the test renders with autoescape disabled.
```

### `prompt.md`

```
New template filter `escapeseq`
Description
	
Following #34574, and after some conversations within the security team, it seems appropriate to provide a new template filter escapeseq which would be to escape what safeseq is to safe. An example of usage would be:
{{ some_list|escapeseq|join:"," }}
where each item of some_list is escaped before applying the join operation. This usage makes sense in a context where autoescape is off.
```

### `review.md`

```
verdict: PASS

- The change adds `escapeseq` to `django/template/defaultfilters.py`, registered via `@register.filter(is_safe=True)` in the default library, so it is usable without loading a custom library.
- It mirrors `safeseq`: `[escape(obj) for obj in value]` applies `escape` to each element rather than to the sequence as a whole.
- With autoescape off, `{{ a|escapeseq|join:", " }}` yields `&amp;, &lt;`, satisfying the requested behaviour (and with autoescape on the result is unchanged, as `escape` produces safe strings).
- Tests in `tests/template_tests/filter_tests/test_escapeseq.py` cover both autoescape on and off; the check `python tests/runtests.py template_tests.filter_tests` ran 452 tests OK.
- The report flags `docs/ref/templates/builtins.txt` and `docs/releases/5.0.txt` as OUTSIDE THE SCOPE. They are documentation additions the Prompt does not require; per the review rules, docs/changelog are notes, not grounds to fail, and they do not alter behaviour or remove content.
```

### `scope.txt`

```
scope: django/template/defaultfilters.py tests/template_tests/filter_tests
changed: django/template/defaultfilters.py +9 -0
OUTSIDE THE SCOPE: docs/ref/templates/builtins.txt +17 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: docs/releases/5.0.txt +3 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/template_tests/filter_tests/test_escapeseq.py +22 -0
```

### `task.md`

```
# Task

## Prompt

New template filter `escapeseq`
Description
	
Following #34574, and after some conversations within the security team, it seems appropriate to provide a new template filter escapeseq which would be to escape what safeseq is to safe. An example of usage would be:
{{ some_list|escapeseq|join:"," }}
where each item of some_list is escaped before applying the join operation. This usage makes sense in a context where autoescape is off.

## Deliverable

changes to this tree

## Check

`python tests/runtests.py template_tests.filter_tests`

## Scope

`django/template/defaultfilters.py`
`tests/template_tests/filter_tests/`

## Done when

- `escapeseq` is registered as a new template filter in the default filter library.
- `escapeseq` escapes each item of the input sequence, mirroring what `safeseq` does with `safe`.
- With autoescape off, `{{ some_list|escapeseq|join:"," }}` escapes each item before the `join` operation.
- The filter is usable without loading a custom filter library.
```

### `test-output.log`

```
check: python tests/runtests.py template_tests.filter_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 452 test(s).
System check identified no issues (0 silenced).
....................................................................................................................................................................................................................................................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 452 tests in 0.127s

OK
scope: django/template/defaultfilters.py tests/template_tests/filter_tests
changed: django/template/defaultfilters.py +9 -0
OUTSIDE THE SCOPE: docs/ref/templates/builtins.txt +17 -0 (undo it: git checkout the file, or delete it when the run made it)
OUTSIDE THE SCOPE: docs/releases/5.0.txt +3 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: tests/template_tests/filter_tests/test_escapeseq.py +22 -0
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
