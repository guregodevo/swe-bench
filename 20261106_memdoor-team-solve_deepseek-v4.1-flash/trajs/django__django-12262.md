# django__django-12262 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 129s 89 lines cost=0.006552 in=184543 cached=141312 out=12589 calls=16`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Custom template tags raise TemplateSyntaxError when keyword-only arguments with defaults are provided.
Description
	 
		(last modified by P-Seebauer)
	 
When creating simple tags without variable keyword args, but an keyword argument with a default value. It's not possible to supply any other variable.
@register.simple_tag
def hello(*, greeting='hello'):
	return f'{greeting} world'
{% hello greeting='hi' %}
Raises “'hello' received unexpected keyword argument 'greeting'”
Also supplying a keyword argument a second time raises the wrong error message:
#tag
@register.simple_tag
def hi(*, greeting):
	return f'{greeting} world'
{% hi greeting='hi' greeting='hello' %}
Raises “'hi' received unexpected keyword argument 'greeting'”
instead of "'hi' received multiple values for keyword argument 'greeting'"
Same goes for inclusion tags (is the same code) I already have a fix ready, will push it after creating the ticket (that I have a ticket# for the commit).
Is actually for all versions since the offending line is from 2.0…


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --short"
}
```

**assistant → tool `locate`**

```json
{
  "query": "simple_tag keyword-only arguments unexpected keyword argument parsing"
}
```

**tool result**

```
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
6b2b46b416 SWE-bench
69331bb851 Added stub release notes for 3.0.3.
434a81d320 Added release date for 3.0.2.
?? .memdoor/
```

**tool result**

```
Where "simple_tag keyword-only arguments unexpected keyword argument parsing" lives (judged: 16 of 40 sections kept), most relevant first:
1. django/template/library.py:237-276  p=0.94
2. tests/template_tests/templatetags/custom.py:91-93  p=0.87
3. tests/template_tests/test_custom.py:90-128  p=0.65
4. docs/releases/1.4.txt:396-434  p=0.61
5. tests/template_tests/annotated_tag_function.py:6-8  p=0.54
6. docs/howto/custom-template-tags.txt:467-501  p=0.51
7. tests/template_tests/test_library.py:76-111  p=0.51
8. tests/template_tests/templatetags/subpackage/echo.py:6-8  p=0.51

== django/template/library.py:237-276 (p=0.94)
  237  def parse_bits(parser, bits, params, varargs, varkw, defaults,
  238                 kwonly, kwonly_defaults, takes_context, name):
  239      """
  240      Parse bits for template tag helpers simple_tag and inclusion_tag, in
  241      particular by detecting syntax errors and by extracting positional and
  242      keyword arguments.
  243      """
  244      if takes_context:
  245          if params[0] == 'context':
  246              params = params[1:]
  247          else:
  248              raise TemplateSyntaxError(
  249                  "'%s' is decorated with takes_context=True so it must "
  250                  "have a first argument of 'context'" % name)
  251      args = []
  252      kwargs = {}
  253      unhandled_params = list(params)
  254      unhandled_kwargs = [
  255          kwarg for kwarg in kwonly
  256          if not kwonly_defaults or kwarg not in kwonly_defaults
  257      ]
  258      for bit in bits:
  259          # First we try to extract a potential kwarg from the bit
  260          kwarg = token_kwargs([bit], parser)
  261          if kwarg:
  262              # The kwarg was successfully extracted
  263              param, value = kwarg.popitem()
  264              if param not in params and param not in unhandled_kwargs and varkw is None:
  265                  # An unexpected keyword argument was supplied
  266                  raise TemplateSyntaxError(
  267                      "'%s' received unexpected keyword argument '%s'" %
  268                      (name, param))
  269              elif param in kwargs:
  270                  # The keyword argument has already been supplied once
  271                  raise TemplateSyntaxError(
  272                      "'%s' received multiple values for keyword argument '%s'" %
  273                      (name, param))
  274              else:
  275                  # All good, record the keyword argument
  276                  kwargs[str(param)] = value

== django/template/library.py:96-134 (p=0.93)
   96      def filter_function(self, func, **flags):
   97          name = getattr(func, "_decorated_function", func).__name__
   98          return self.filter(name, func, **flags)
   99  
  100      def simple_tag(self, func=None, takes_context=None, name=None):
  101          """
  102          Register a callable as a compiled template tag. Example:
  103  
  104          @register.simple_tag
  105          def hello(*args, **kwargs):
  106              return 'world'
  107          """
  108          def dec(func):
  109              params, varargs, varkw, defaults, kwonly, kwonly_defaults, _ = getfullargspec(unwrap(func))
  110              function_name = (name or getattr(func, '_decorated_function', func).__name__)
  111  
  112              @functools.wraps(func)
  113              def compile_func(parser, token):
  114                  bits = token.split_contents()[1:]
  115                  target_var = None
  116                  if len(bits) >= 2 and bits[-2] == 'as':
  117                      target_var = bits[-1]
  118                      bits = bits[:-2]
  119                  args, kwargs = parse_bits(
  120                      parser, bits, params, varargs, varkw, defaults,
  121                      kwonly, kwonly_defaults, takes_context, function_name,
  122                  )
  123                  return SimpleNode(func, takes_context, args, kwargs, target_var)
  124              self.tag(function_name, compile_func)
  125              return func
  126  
  127          if func is None:
  128              # @register.simple_tag(...)
  129              return dec
  130          elif callable(func):
  131              # @register.simple_tag
  132              return dec(func)
  133          else:
  134              raise ValueError("Invalid arguments provided to simple_tag")

== tests/template_tests/templatetags/custom.py:91-93 (p=0.87)
   91  @register.simple_tag
   92  def simple_keyword_only_param(*, kwarg):
   93      return "simple_keyword_only_param - Expected result: %s" % kwarg

read_file or jread a file to see more; locate again with file set to rank one file's sections.
```

**assistant → tool `read_file`**

```json
{
  "path": "django/template/library.py",
  "offset": 230,
  "limit": 100
}
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/template_tests/test_custom.py",
  "offset": 1,
  "limit": 180
}
```

**tool result**

```
        # protection to be as simple as possible.
        csrf_token = [redacted]'csrf_token')
        if csrf_token is not None:
            new_context['csrf_token'] = csrf_token
        return t.render(new_context)


def parse_bits(parser, bits, params, varargs, varkw, defaults,
               kwonly, kwonly_defaults, takes_context, name):
    """
    Parse bits for template tag helpers simple_tag and inclusion_tag, in
    particular by detecting syntax errors and by extracting positional and
    keyword arguments.
    """
    if takes_context:
        if params[0] == 'context':
            params = params[1:]
        else:
            raise TemplateSyntaxError(
                "'%s' is decorated with takes_context=True so it must "
                "have a first argument of 'context'" % name)
    args = []
    kwargs = {}
    unhandled_params = list(params)
    unhandled_kwargs = [
        kwarg for kwarg in kwonly
        if not kwonly_defaults or kwarg not in kwonly_defaults
    ]
    for bit in bits:
        # First we try to extract a potential kwarg from the bit
        kwarg = token_kwargs([bit], parser)
        if kwarg:
            # The kwarg was successfully extracted
            param, value = kwarg.popitem()
            if param not in params and param not in unhandled_kwargs and varkw is None:
                # An unexpected keyword argument was supplied
                raise TemplateSyntaxError(
                    "'%s' received unexpected keyword argument '%s'" %
                    (name, param))
            elif param in kwargs:
                # The keyword argument has already been supplied once
                raise TemplateSyntaxError(
                    "'%s' received multiple values for keyword argument '%s'" %
                    (name, param))
            else:
                # All good, record the keyword argument
                kwargs[str(param)] = value
                if param in unhandled_params:
                    # If using the keyword syntax for a positional arg, then
                    # consume it.
                    unhandled_params.remove(param)
                elif param in unhandled_kwargs:
                    # Same for keyword-only arguments
                    unhandled_kwargs.remove(param)
        else:
            if kwargs:
                raise TemplateSyntaxError(
                    "'%s' received some positional argument(s) after some "
                    "keyword argument(s)" % name)
            else:
                # Record the positional argument
                args.append(parser.compile_filter(bit))
                try:
                    # Consume from the list of expected positional arguments
                    unhandled_params.pop(0)
                except IndexError:
                    if varargs is None:
                        raise TemplateSyntaxError(
                            "'%s' received too many positional arguments" %
                            name)
    if defaults is not None:
        # Consider the last n params handled, where n is the
        # number of defaults.
        unhandled_params = unhandled_params[:-len(defaults)]
    if unhandled_params or unhandled_kwargs:
        # Some positional arguments were not supplied
        raise TemplateSyntaxError(
            "'%s' did not receive value(s) for the argument(s): %s" %
            (name, ", ".join("'%s'" % p for p in unhandled_params + unhandled_kwargs)))
    return args, kwargs


def import_library(name):
    """
    Load a Library object from a template tag module.
    """
    try:
        module = import_module(name)
    except ImportError as e:
        raise InvalidTemplateLibrary(
            "Invalid template library specified. ImportError raised when "
            "trying to load '%s': %s" % (name, e)
        )
    try:
        return module.register
    except AttributeError:
        raise InvalidTemplateLibrary(
            "Module  %s does not have a variable named 'register'" % name,
        )

[lines 230-328 of /testbed/django/template/library.py, the end]
```

**tool result**

```
import os

from django.template import Context, Engine, TemplateSyntaxError
from django.template.base import Node
from django.template.library import InvalidTemplateLibrary
from django.test import SimpleTestCase
from django.test.utils import extend_sys_path

from .templatetags import custom, inclusion
from .utils import ROOT

LIBRARIES = {
    'custom': 'template_tests.templatetags.custom',
    'inclusion': 'template_tests.templatetags.inclusion',
}


class CustomFilterTests(SimpleTestCase):

    def test_filter(self):
        engine = Engine(libraries=LIBRARIES)
        t = engine.from_string("{% load custom %}{{ string|trim:5 }}")
        self.assertEqual(
            t.render(Context({"string": "abcdefghijklmnopqrstuvwxyz"})),
            "abcde"
        )

    def test_decorated_filter(self):
        engine = Engine(libraries=LIBRARIES)
        t = engine.from_string('{% load custom %}{{ name|make_data_div }}')
        self.assertEqual(t.render(Context({'name': 'foo'})), '<div data-name="foo"></div>')


class TagTestCase(SimpleTestCase):

    @classmethod
    def setUpClass(cls):
        cls.engine = Engine(app_dirs=True, libraries=LIBRARIES)
        super().setUpClass()

    def verify_tag(self, tag, name):
        self.assertEqual(tag.__name__, name)
        self.assertEqual(tag.__doc__, 'Expected %s __doc__' % name)
        self.assertEqual(tag.__dict__['anything'], 'Expected %s __dict__' % name)


class SimpleTagTests(TagTestCase):

    def test_simple_tags(self):
        c = Context({'value': 42})

        templates = [
            ('{% load custom %}{% no_params %}', 'no_params - Expected result'),
            ('{% load custom %}{% one_param 37 %}', 'one_param - Expected result: 37'),
            ('{% load custom %}{% explicit_no_context 37 %}', 'explicit_no_context - Expected result: 37'),
            ('{% load custom %}{% no_params_with_context %}',
                'no_params_with_context - Expected result (context value: 42)'),
            ('{% load custom %}{% params_and_context 37 %}',
                'params_and_context - Expected result (context value: 42): 37'),
            ('{% load custom %}{% simple_two_params 37 42 %}', 'simple_two_params - Expected result: 37, 42'),
            ('{% load custom %}{% simple_keyword_only_param kwarg=37 %}',
                'simple_keyword_only_param - Expected result: 37'),
            ('{% load custom %}{% simple_keyword_only_default %}',
                'simple_keyword_only_default - Expected result: 42'),
            ('{% load custom %}{% simple_one_default 37 %}', 'simple_one_default - Expected result: 37, hi'),
            ('{% load custom %}{% simple_one_default 37 two="hello" %}',
                'simple_one_default - Expected result: 37, hello'),
            ('{% load custom %}{% simple_one_default one=99 two="hello" %}',
                'simple_one_default - Expected result: 99, hello'),
            ('{% load custom %}{% simple_one_default 37 42 %}',
                'simple_one_default - Expected result: 37, 42'),
            ('{% load custom %}{% simple_unlimited_args 37 %}', 'simple_unlimited_args - Expected result: 37, hi'),
            ('{% load custom %}{% simple_unlimited_args 37 42 56 89 %}',
                'simple_unlimited_args - Expected result: 37, 42, 56, 89'),
            ('{% load custom %}{% simple_only_unlimited_args %}', 'simple_only_unlimited_args - Expected result: '),
            ('{% load custom %}{% simple_only_unlimited_args 37 42 56 89 %}',
                'simple_only_unlimited_args - Expected result: 37, 42, 56, 89'),
            ('{% load custom %}{% simple_unlimited_args_kwargs 37 40|add:2 56 eggs="scrambled" four=1|add:3 %}',
                'simple_unlimited_args_kwargs - Expected result: 37, 42, 56 / eggs=scrambled, four=4'),
        ]

        for entry in templates:
            t = self.engine.from_string(entry[0])
            self.assertEqual(t.render(c), entry[1])

        for entry in templates:
            t = self.engine.from_string("%s as var %%}Result: {{ var }}" % entry[0][0:-2])
            self.assertEqual(t.render(c), "Result: %s" % entry[1])

    def test_simple_tag_errors(self):
        errors = [
            ("'simple_one_default' received unexpected keyword argument 'three'",
                '{% load custom %}{% simple_one_default 99 two="hello" three="foo" %}'),
            ("'simple_two_params' received too many positional arguments",
                '{% load custom %}{% simple_two_params 37 42 56 %}'),
            ("'simple_one_default' received too many positional arguments",
                '{% load custom %}{% simple_one_default 37 42 56 %}'),
            ("'simple_keyword_only_param' did not receive value(s) for the argument(s): 'kwarg'",
                '{% load custom %}{% simple_keyword_only_param %}'),
            ("'simple_unlimited_args_kwargs' received some positional argument(s) after some keyword argument(s)",
                '{% load custom %}{% simple_unlimited_args_kwargs 37 40|add:2 eggs="scrambled" 56 four=1|add:3 %}'),
            ("'simple_unlimited_args_kwargs' received multiple values for keyword argument 'eggs'",
                '{% load custom %}{% simple_unlimited_args_kwargs 37 eggs="scrambled" eggs="scrambled" %}'),
        ]

        for entry in errors:
            with self.assertRaisesMessage(TemplateSyntaxError, entry[0]):
                self.engine.from_string(entry[1])

        for entry in errors:
            with self.assertRaisesMessage(TemplateSyntaxError, entry[0]):
                self.engine.from_string("%s as var %%}" % entry[1][0:-2])

    def test_simple_tag_escaping_autoescape_off(self):
        c = Context({'name': "Jack & Jill"}, autoescape=False)
        t = self.engine.from_string("{% load custom %}{% escape_naive %}")
        self.assertEqual(t.render(c), "Hello Jack & Jill!")

    def test_simple_tag_naive_escaping(self):
        c = Context({'name': "Jack & Jill"})
        t = self.engine.from_string("{% load custom %}{% escape_naive %}")
        self.assertEqual(t.render(c), "Hello Jack &amp; Jill!")

    def test_simple_tag_explicit_escaping(self):
        # Check we don't double escape
        c = Context({'name': "Jack & Jill"})
        t = self.engine.from_string("{% load custom %}{% escape_explicit %}")
        self.assertEqual(t.render(c), "Hello Jack &amp; Jill!")

    def test_simple_tag_format_html_escaping(self):
        # Check we don't double escape
        c = Context({'name': "Jack & Jill"})
        t = self.engine.from_string("{% load custom %}{% escape_format_html %}")
        self.assertEqual(t.render(c), "Hello Jack &amp; Jill!")

    def test_simple_tag_registration(self):
        # The decorators preserve the decorated function's docstring, name,
        # and attributes.
        self.verify_tag(custom.no_params, 'no_params')
        self.verify_tag(custom.one_param, 'one_param')
        self.verify_tag(custom.explicit_no_context, 'explicit_no_context')
        self.verify_tag(custom.no_params_with_context, 'no_params_with_context')
        self.verify_tag(custom.params_and_context, 'params_and_context')
        self.verify_tag(custom.simple_unlimited_args_kwargs, 'simple_unlimited_args_kwargs')
        self.verify_tag(custom.simple_tag_without_context_parameter, 'simple_tag_without_context_parameter')

    def test_simple_tag_missing_context(self):
        # The 'context' parameter must be present when takes_context is True
        msg = (
            "'simple_tag_without_context_parameter' is decorated with "
            "takes_context=True so it must have a first argument of 'context'"
        )
        with self.assertRaisesMessage(TemplateSyntaxError, msg):
            self.engine.from_string('{% load custom %}{% simple_tag_without_context_parameter 123 %}')


class InclusionTagTests(TagTestCase):

    def test_inclusion_tags(self):
        c = Context({'value': 42})

        templates = [
            ('{% load inclusion %}{% inclusion_no_params %}', 'inclusion_no_params - Expected result\n'),
            ('{% load inclusion %}{% inclusion_one_param 37 %}', 'inclusion_one_param - Expected result: 37\n'),
            ('{% load inclusion %}{% inclusion_explicit_no_context 37 %}',
                'inclusion_explicit_no_context - Expected result: 37\n'),
            ('{% load inclusion %}{% inclusion_no_params_with_context %}',
                'inclusion_no_params_with_context - Expected result (context value: 42)\n'),
            ('{% load inclusion %}{% inclusion_params_and_context 37 %}',
                'inclusion_params_and_context - Expected result (context value: 42): 37\n'),
            ('{% load inclusion %}{% inclusion_two_params 37 42 %}',
                'inclusion_two_params - Expected result: 37, 42\n'),
            (
                '{% load inclusion %}{% inclusion_one_default 37 %}',
                'inclusion_one_default - Expected result: 37, hi\n'
            ),
            ('{% load inclusion %}{% inclusion_one_default 37 two="hello" %}',
                'inclusion_one_default - Expected result: 37, hello\n'),
            ('{% load inclusion %}{% inclusion_one_default one=99 two="hello" %}',
                'inclusion_one_default - Expected result: 99, hello\n'),

[175 more lines in /testbed/tests/template_tests/test_custom.py (355 in all). read_file with offset: 181 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/template_tests/templatetags/custom.py",
  "offset": 80,
  "limit": 30
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"keyword_only\" tests/template_tests/templatetags/inclusion.py tests/template_tests/test_custom.py"
}
```

**tool result**

```


@register.simple_tag
def simple_two_params(one, two):
    """Expected simple_two_params __doc__"""
    return "simple_two_params - Expected result: %s, %s" % (one, two)


simple_two_params.anything = "Expected simple_two_params __dict__"


@register.simple_tag
def simple_keyword_only_param(*, kwarg):
    return "simple_keyword_only_param - Expected result: %s" % kwarg


@register.simple_tag
def simple_keyword_only_default(*, kwarg=42):
    return "simple_keyword_only_default - Expected result: %s" % kwarg


@register.simple_tag
def simple_one_default(one, two='hi'):
    """Expected simple_one_default __doc__"""
    return "simple_one_default - Expected result: %s, %s" % (one, two)


simple_one_default.anything = "Expected simple_one_default __dict__"



[92 more lines in /testbed/tests/template_tests/templatetags/custom.py (201 in all). read_file with offset: 110 to continue]
```

**tool result**

```
tests/template_tests/test_custom.py:61:            ('{% load custom %}{% simple_keyword_only_param kwarg=37 %}',
tests/template_tests/test_custom.py:62:                'simple_keyword_only_param - Expected result: 37'),
tests/template_tests/test_custom.py:63:            ('{% load custom %}{% simple_keyword_only_default %}',
tests/template_tests/test_custom.py:64:                'simple_keyword_only_default - Expected result: 42'),
tests/template_tests/test_custom.py:98:            ("'simple_keyword_only_param' did not receive value(s) for the argument(s): 'kwarg'",
tests/template_tests/test_custom.py:99:                '{% load custom %}{% simple_keyword_only_param %}'),
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"keyword\\|def inclusion_one_default\" tests/template_tests/templatetags/inclusion.py; sed -n '180,260p' tests/template_tests/test_custom.py"
}
```

**tool result**

```
131:def inclusion_one_default(one, two='hi'):
140:def inclusion_one_default_from_template(one, two='hi'):
                'inclusion_one_default - Expected result: 99, hello\n'),
            ('{% load inclusion %}{% inclusion_one_default 37 42 %}',
                'inclusion_one_default - Expected result: 37, 42\n'),
            ('{% load inclusion %}{% inclusion_unlimited_args 37 %}',
                'inclusion_unlimited_args - Expected result: 37, hi\n'),
            ('{% load inclusion %}{% inclusion_unlimited_args 37 42 56 89 %}',
                'inclusion_unlimited_args - Expected result: 37, 42, 56, 89\n'),
            ('{% load inclusion %}{% inclusion_only_unlimited_args %}',
                'inclusion_only_unlimited_args - Expected result: \n'),
            ('{% load inclusion %}{% inclusion_only_unlimited_args 37 42 56 89 %}',
                'inclusion_only_unlimited_args - Expected result: 37, 42, 56, 89\n'),
            ('{% load inclusion %}{% inclusion_unlimited_args_kwargs 37 40|add:2 56 eggs="scrambled" four=1|add:3 %}',
                'inclusion_unlimited_args_kwargs - Expected result: 37, 42, 56 / eggs=scrambled, four=4\n'),
        ]

        for entry in templates:
            t = self.engine.from_string(entry[0])
            self.assertEqual(t.render(c), entry[1])

    def test_inclusion_tag_errors(self):
        errors = [
            ("'inclusion_one_default' received unexpected keyword argument 'three'",
                '{% load inclusion %}{% inclusion_one_default 99 two="hello" three="foo" %}'),
            ("'inclusion_two_params' received too many positional arguments",
                '{% load inclusion %}{% inclusion_two_params 37 42 56 %}'),
            ("'inclusion_one_default' received too many positional arguments",
                '{% load inclusion %}{% inclusion_one_default 37 42 56 %}'),
            ("'inclusion_one_default' did not receive value(s) for the argument(s): 'one'",
                '{% load inclusion %}{% inclusion_one_default %}'),
            ("'inclusion_unlimited_args' did not receive value(s) for the argument(s): 'one'",
                '{% load inclusion %}{% inclusion_unlimited_args %}'),
            (
                "'inclusion_unlimited_args_kwargs' received some positional argument(s) "
                "after some keyword argument(s)",
                '{% load inclusion %}{% inclusion_unlimited_args_kwargs 37 40|add:2 eggs="boiled" 56 four=1|add:3 %}',
            ),
            ("'inclusion_unlimited_args_kwargs' received multiple values for keyword argument 'eggs'",
                '{% load inclusion %}{% inclusion_unlimited_args_kwargs 37 eggs="scrambled" eggs="scrambled" %}'),
        ]

        for entry in errors:
            with self.assertRaisesMessage(TemplateSyntaxError, entry[0]):
                self.engine.from_string(entry[1])

    def test_include_tag_missing_context(self):
        # The 'context' parameter must be present when takes_context is True
        msg = (
            "'inclusion_tag_without_context_parameter' is decorated with "
            "takes_context=True so it must have a first argument of 'context'"
        )
        with self.assertRaisesMessage(TemplateSyntaxError, msg):
            self.engine.from_string('{% load inclusion %}{% inclusion_tag_without_context_parameter 123 %}')

    def test_inclusion_tags_from_template(self):
        c = Context({'value': 42})

        templates = [
            ('{% load inclusion %}{% inclusion_no_params_from_template %}',
                'inclusion_no_params_from_template - Expected result\n'),
            ('{% load inclusion %}{% inclusion_one_param_from_template 37 %}',
                'inclusion_one_param_from_template - Expected result: 37\n'),
            ('{% load inclusion %}{% inclusion_explicit_no_context_from_template 37 %}',
                'inclusion_explicit_no_context_from_template - Expected result: 37\n'),
            ('{% load inclusion %}{% inclusion_no_params_with_context_from_template %}',
                'inclusion_no_params_with_context_from_template - Expected result (context value: 42)\n'),
            ('{% load inclusion %}{% inclusion_params_and_context_from_template 37 %}',
                'inclusion_params_and_context_from_template - Expected result (context value: 42): 37\n'),
            ('{% load inclusion %}{% inclusion_two_params_from_template 37 42 %}',
                'inclusion_two_params_from_template - Expected result: 37, 42\n'),
            ('{% load inclusion %}{% inclusion_one_default_from_template 37 %}',
                'inclusion_one_default_from_template - Expected result: 37, hi\n'),
            ('{% load inclusion %}{% inclusion_one_default_from_template 37 42 %}',
                'inclusion_one_default_from_template - Expected result: 37, 42\n'),
            ('{% load inclusion %}{% inclusion_unlimited_args_from_template 37 %}',
                'inclusion_unlimited_args_from_template - Expected result: 37, hi\n'),
            ('{% load inclusion %}{% inclusion_unlimited_args_from_template 37 42 56 89 %}',
                'inclusion_unlimited_args_from_template - Expected result: 37, 42, 56, 89\n'),
            ('{% load inclusion %}{% inclusion_only_unlimited_args_from_template %}',
                'inclusion_only_unlimited_args_from_template - Expected result: \n'),
            ('{% load inclusion %}{% inclusion_only_unlimited_args_from_template 37 42 56 89 %}',
                'inclusion_only_unlimited_args_from_template - Expected result: 37, 42, 56, 89\n'),
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/template/library.py\n@@\n-            if param not in params and param not in unhandled_kwargs and varkw is None:\n+            if param not in params and param not in kwonly and varkw is None:\n*** Update File: tests/template_tests/templatetags/custom.py\n@@\n @register.simple_tag\n def simple_keyword_only_default(*, kwarg=42):\n     return \"simple_keyword_only_default - Expected result: %s\" % kwarg\n \n \n+@register.simple_tag\n+def simple_keyword_only_default_with_other(*, kwarg=42, other=99):\n+    return \"simple_keyword_only_default_with_other - Expected result: %s, %s\" % (kwarg, other)\n+\n+\n @register.simple_tag\n def simple_one_default(one, two='hi'):\n*** Update File: tests/template_tests/test_custom.py\n@@\n             ('{% load custom %}{% simple_keyword_only_default %}',\n                 'simple_keyword_only_default - Expected result: 42'),\n+            ('{% load custom %}{% simple_keyword_only_default kwarg=37 %}',\n+                'simple_keyword_only_default - Expected result: 37'),\n+            ('{% load custom %}{% simple_keyword_only_default_with_other other=37 %}',\n+                'simple_keyword_only_default_with_other - Expected result: 42, 37'),\n@@\n             (\"'simple_keyword_only_param' did not receive value(s) for the argument(s): 'kwarg'\",\n                 '{% load custom %}{% simple_keyword_only_param %}'),\n+            (\"'simple_keyword_only_param' received multiple values for keyword argument 'kwarg'\",\n+                '{% load custom %}{% simple_keyword_only_param kwarg=37 kwarg=42 %}'),\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/template/library.py tests/template_tests/templatetags/custom.py tests/template_tests/test_custom.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/template/library.py now (328 lines), around the change:
261:        if kwarg:
262:            # The kwarg was successfully extracted
263:            param, value = kwarg.popitem()
264:            if param not in params and param not in kwonly and varkw is None:
265:                # An unexpected keyword argument was supplied
266:                raise TemplateSyntaxError(
267:                    "'%s' received unexpected keyword argument '%s'" %

tests/template_tests/templatetags/custom.py now (206 lines), around the change:
96:@register.simple_tag
97:def simple_keyword_only_default(*, kwarg=42):
98:    return "simple_keyword_only_default - Expected result: %s" % kwarg
99:
100:
101:@register.simple_tag
102:def simple_keyword_only_default_with_other(*, kwarg=42, other=99):
103:    return "simple_keyword_only_default_with_other - Expected result: %s, %s" % (kwarg, other)
104:
105:
106:@register.simple_tag

tests/template_tests/test_custom.py now (361 lines), around the change:
62:                'simple_keyword_only_param - Expected result: 37'),
63:            ('{% load custom %}{% simple_keyword_only_default %}',
64:                'simple_keyword_only_default - Expected result: 42'),
65:            ('{% load custom %}{% simple_keyword_only_default kwarg=37 %}',
66:                'simple_keyword_only_default - Expected result: 37'),
67:            ('{% load custom %}{% simple_keyword_only_default_with_other other=37 %}',
68:                'simple_keyword_only_default_with_other - Expected result: 42, 37'),
69:            ('{% load custom %}{% simple_one_default 37 %}', 'simple_one_default - Expected result: 37, hi'),
70:            ('{% load custom %}{% simple_one_default 37 two="hello" %}',
71:                'simple_one_default - Expected result: 37, hello'),
…
101:                '{% load custom %}{% simple_one_default 37 42 56 %}'),
102:            ("'simple_keyword_only_param' did not receive value(s) for the argument(s): 'kwarg'",
103:                '{% load custom %}{% simple_keyword_only_param %}'),
104:            ("'simple_keyword_only_param' received multiple values for keyword argument 'kwarg'",
105:                '{% load custom %}{% simple_keyword_only_param kwarg=37 kwarg=42 %}'),
106:            ("'simple_unlimited_args_kwargs' received some positional argument(s) after some keyword argument(s)",
107:                '{% load custom %}{% simple_unlimited_args_kwargs 37 40|add:2 eggs="scrambled" 56 four=1|add:3 %}'),
108:            ("'simple_unlimited_args_kwargs' received multiple values for keyword argument 'eggs'",
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/template_tests/test_custom.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py template_tests.test_custom 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
......................
----------------------------------------------------------------------
Ran 22 tests in 0.302s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '120,150p' tests/template_tests/templatetags/inclusion.py"
}
```

**tool result**

```

@register.inclusion_tag(engine.get_template('inclusion.html'))
def inclusion_two_params_from_template(one, two):
    """Expected inclusion_two_params_from_template __doc__"""
    return {"result": "inclusion_two_params_from_template - Expected result: %s, %s" % (one, two)}


inclusion_two_params_from_template.anything = "Expected inclusion_two_params_from_template __dict__"


@register.inclusion_tag('inclusion.html')
def inclusion_one_default(one, two='hi'):
    """Expected inclusion_one_default __doc__"""
    return {"result": "inclusion_one_default - Expected result: %s, %s" % (one, two)}


inclusion_one_default.anything = "Expected inclusion_one_default __dict__"


@register.inclusion_tag(engine.get_template('inclusion.html'))
def inclusion_one_default_from_template(one, two='hi'):
    """Expected inclusion_one_default_from_template __doc__"""
    return {"result": "inclusion_one_default_from_template - Expected result: %s, %s" % (one, two)}


inclusion_one_default_from_template.anything = "Expected inclusion_one_default_from_template __dict__"


@register.inclusion_tag('inclusion.html')
def inclusion_unlimited_args(one, two='hi', *args):
    """Expected inclusion_unlimited_args __doc__"""
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/template_tests/templatetags/inclusion.py\n@@\n @register.inclusion_tag('inclusion.html')\n def inclusion_one_default(one, two='hi'):\n     \"\"\"Expected inclusion_one_default __doc__\"\"\"\n     return {\"result\": \"inclusion_one_default - Expected result: %s, %s\" % (one, two)}\n \n \n inclusion_one_default.anything = \"Expected inclusion_one_default __dict__\"\n \n \n+@register.inclusion_tag('inclusion.html')\n+def inclusion_keyword_only_default(*, kwarg=42):\n+    return {\"result\": \"inclusion_keyword_only_default - Expected result: %s\" % kwarg}\n+\n+\n @register.inclusion_tag(engine.get_template('inclusion.html'))\n def inclusion_one_default_from_template(one, two='hi'):\n*** Update File: tests/template_tests/test_custom.py\n@@\n             ('{% load inclusion %}{% inclusion_one_default 37 42 %}',\n                 'inclusion_one_default - Expected result: 37, 42\\n'),\n+            ('{% load inclusion %}{% inclusion_keyword_only_default %}',\n+                'inclusion_keyword_only_default - Expected result: 42\\n'),\n+            ('{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 %}',\n+                'inclusion_keyword_only_default - Expected result: 37\\n'),\n@@\n             (\"'inclusion_one_default' did not receive value(s) for the argument(s): 'one'\",\n                 '{% load inclusion %}{% inclusion_one_default %}'),\n+            (\"'inclusion_keyword_only_default' received multiple values for keyword argument 'kwarg'\",\n+                '{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 kwarg=42 %}'),\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/template_tests/templatetags/inclusion.py tests/template_tests/test_custom.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/template_tests/templatetags/inclusion.py now (248 lines), around the change:
134:
135:
136:inclusion_one_default.anything = "Expected inclusion_one_default __dict__"
137:
138:
139:@register.inclusion_tag('inclusion.html')
140:def inclusion_keyword_only_default(*, kwarg=42):
141:    return {"result": "inclusion_keyword_only_default - Expected result: %s" % kwarg}
142:
143:
144:@register.inclusion_tag(engine.get_template('inclusion.html'))

tests/template_tests/test_custom.py now (367 lines), around the change:
186:                'inclusion_one_default - Expected result: 99, hello\n'),
187:            ('{% load inclusion %}{% inclusion_one_default 37 42 %}',
188:                'inclusion_one_default - Expected result: 37, 42\n'),
189:            ('{% load inclusion %}{% inclusion_keyword_only_default %}',
190:                'inclusion_keyword_only_default - Expected result: 42\n'),
191:            ('{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 %}',
192:                'inclusion_keyword_only_default - Expected result: 37\n'),
193:            ('{% load inclusion %}{% inclusion_unlimited_args 37 %}',
194:                'inclusion_unlimited_args - Expected result: 37, hi\n'),
195:            ('{% load inclusion %}{% inclusion_unlimited_args 37 42 56 89 %}',
…
216:                '{% load inclusion %}{% inclusion_one_default 37 42 56 %}'),
217:            ("'inclusion_one_default' did not receive value(s) for the argument(s): 'one'",
218:                '{% load inclusion %}{% inclusion_one_default %}'),
219:            ("'inclusion_keyword_only_default' received multiple values for keyword argument 'kwarg'",
220:                '{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 kwarg=42 %}'),
221:            ("'inclusion_unlimited_args' did not receive value(s) for the argument(s): 'one'",
222:                '{% load inclusion %}{% inclusion_unlimited_args %}'),
223:            (
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py template_tests.test_custom 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
......................
----------------------------------------------------------------------
Ran 22 tests in 0.203s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py template_tests 2>&1 | tail -8"
}
```

**tool result**

```
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 135, in _raiseFailure
    raise self.test_case.failureException(msg)
AssertionError: PermissionError not raised

----------------------------------------------------------------------
Ran 1387 tests in 4.720s

FAILED (failures=1, skipped=1)
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py template_tests 2>&1 | grep -B3 \"PermissionError not raised\""
}
```

**tool result**

```
    self._raiseFailure("{} not raised".format(exc_name))
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 135, in _raiseFailure
    raise self.test_case.failureException(msg)
AssertionError: PermissionError not raised
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py template_tests 2>&1 | grep -E \"^(FAIL|ERROR):\""
}
```

**tool result**

```
FAIL: test_permissions_error (template_tests.test_loaders.FileSystemLoaderTests)
```

**assistant**

````
Fixed the bug in `django/template/library.py`.

**Root cause:** `parse_bits()` validated keyword arguments against `unhandled_kwargs`, which excludes keyword-only parameters that have defaults. So `{% hello greeting='hi' %}` for `def hello(*, greeting='hello')` was rejected as an unexpected keyword argument. The same list was also used for the duplicate check, so supplying a keyword-only arg twice produced the wrong "unexpected keyword argument" message instead of "multiple values".

**Change:** the unexpected-keyword check now tests membership in the full `kwonly` list rather than `unhandled_kwargs`:

```python
if param not in params and param not in kwonly and varkw is None:
```

This fixes both reported symptoms for `simple_tag` and `inclusion_tag` (they share `parse_bits`), while the existing `unhandled_kwargs` bookkeeping still correctly reports missing required keyword-only arguments.

**Tests added:**
- `simple_keyword_only_default kwarg=37` (default overridden)
- `simple_keyword_only_default_with_other other=37` (one defaulted kw-only arg supplied, another left at default)
- duplicate `kwarg=37 kwarg=42` → "received multiple values for keyword argument 'kwarg'"
- equivalent inclusion-tag cases (`inclusion_keyword_only_default`)

`template_tests.test_custom` passes (22 tests). The full `template_tests` run has one unrelated failure, `test_permissions_error`, which fails because the suite runs as root (permission checks don't apply). No commits or tree changes beyond the working-tree edits.
````

## Run folder `team-solve-2026-11-06T105440`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
6b2b46b41688bca917e590c7420e045d635365e5
```

### `baseline-check.log`

```
check: ./tests/runtests.py template_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................s......F...........................................................................................................................................................................................................................................................................................
======================================================================
FAIL: test_permissions_error (template_tests.test_loaders.FileSystemLoaderTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T105440/baseline-tree/tests/template_tests/test_loaders.py", line 195, in test_permissions_error
    self.engine.get_template(tmpfile.name)
  File "/opt/miniconda3/envs/testbed/lib/python3.6/contextlib.py", line 88, in __exit__
    next(self.gen)
  File "/testbed/django/test/testcases.py", line 682, in _assert_raises_or_warns_cm
    yield cm
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 203, in __exit__
    self._raiseFailure("{} not raised".format(exc_name))
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 135, in _raiseFailure
    raise self.test_case.failureException(msg)
AssertionError: PermissionError not raised

----------------------------------------------------------------------
Ran 1387 tests in 6.201s

FAILED (failures=1, skipped=1)
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/django/template/library.py b/django/template/library.py
index 20bc86dac8..2f74556268 100644
--- a/django/template/library.py
+++ b/django/template/library.py
@@ -261,7 +261,7 @@ def parse_bits(parser, bits, params, varargs, varkw, defaults,
         if kwarg:
             # The kwarg was successfully extracted
             param, value = kwarg.popitem()
-            if param not in params and param not in unhandled_kwargs and varkw is None:
+            if param not in params and param not in kwonly and varkw is None:
                 # An unexpected keyword argument was supplied
                 raise TemplateSyntaxError(
                     "'%s' received unexpected keyword argument '%s'" %
diff --git a/tests/template_tests/templatetags/custom.py b/tests/template_tests/templatetags/custom.py
index a5e1b33c67..eaf6739ac3 100644
--- a/tests/template_tests/templatetags/custom.py
+++ b/tests/template_tests/templatetags/custom.py
@@ -98,6 +98,11 @@ def simple_keyword_only_default(*, kwarg=42):
     return "simple_keyword_only_default - Expected result: %s" % kwarg
 
 
+@register.simple_tag
+def simple_keyword_only_default_with_other(*, kwarg=42, other=99):
+    return "simple_keyword_only_default_with_other - Expected result: %s, %s" % (kwarg, other)
+
+
 @register.simple_tag
 def simple_one_default(one, two='hi'):
     """Expected simple_one_default __doc__"""
diff --git a/tests/template_tests/templatetags/inclusion.py b/tests/template_tests/templatetags/inclusion.py
index 242fbe80cb..784da91fde 100644
--- a/tests/template_tests/templatetags/inclusion.py
+++ b/tests/template_tests/templatetags/inclusion.py
@@ -136,6 +136,11 @@ def inclusion_one_default(one, two='hi'):
 inclusion_one_default.anything = "Expected inclusion_one_default __dict__"
 
 
+@register.inclusion_tag('inclusion.html')
+def inclusion_keyword_only_default(*, kwarg=42):
+    return {"result": "inclusion_keyword_only_default - Expected result: %s" % kwarg}
+
+
 @register.inclusion_tag(engine.get_template('inclusion.html'))
 def inclusion_one_default_from_template(one, two='hi'):
     """Expected inclusion_one_default_from_template __doc__"""
diff --git a/tests/template_tests/test_custom.py b/tests/template_tests/test_custom.py
index dbc5bc267d..434c892261 100644
--- a/tests/template_tests/test_custom.py
+++ b/tests/template_tests/test_custom.py
@@ -62,6 +62,10 @@ class SimpleTagTests(TagTestCase):
                 'simple_keyword_only_param - Expected result: 37'),
             ('{% load custom %}{% simple_keyword_only_default %}',
                 'simple_keyword_only_default - Expected result: 42'),
+            ('{% load custom %}{% simple_keyword_only_default kwarg=37 %}',
+                'simple_keyword_only_default - Expected result: 37'),
+            ('{% load custom %}{% simple_keyword_only_default_with_other other=37 %}',
+                'simple_keyword_only_default_with_other - Expected result: 42, 37'),
             ('{% load custom %}{% simple_one_default 37 %}', 'simple_one_default - Expected result: 37, hi'),
             ('{% load custom %}{% simple_one_default 37 two="hello" %}',
                 'simple_one_default - Expected result: 37, hello'),
@@ -97,6 +101,8 @@ class SimpleTagTests(TagTestCase):
                 '{% load custom %}{% simple_one_default 37 42 56 %}'),
             ("'simple_keyword_only_param' did not receive value(s) for the argument(s): 'kwarg'",
                 '{% load custom %}{% simple_keyword_only_param %}'),
+            ("'simple_keyword_only_param' received multiple values for keyword argument 'kwarg'",
+                '{% load custom %}{% simple_keyword_only_param kwarg=37 kwarg=42 %}'),
             ("'simple_unlimited_args_kwargs' received some positional argument(s) after some keyword argument(s)",
                 '{% load custom %}{% simple_unlimited_args_kwargs 37 40|add:2 eggs="scrambled" 56 four=1|add:3 %}'),
             ("'simple_unlimited_args_kwargs' received multiple values for keyword argument 'eggs'",
@@ -180,6 +186,10 @@ class InclusionTagTests(TagTestCase):
                 'inclusion_one_default - Expected result: 99, hello\n'),
             ('{% load inclusion %}{% inclusion_one_default 37 42 %}',
                 'inclusion_one_default - Expected result: 37, 42\n'),
+            ('{% load inclusion %}{% inclusion_keyword_only_default %}',
+                'inclusion_keyword_only_default - Expected result: 42\n'),
+            ('{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 %}',
+                'inclusion_keyword_only_default - Expected result: 37\n'),
             ('{% load inclusion %}{% inclusion_unlimited_args 37 %}',
                 'inclusion_unlimited_args - Expected result: 37, hi\n'),
             ('{% load inclusion %}{% inclusion_unlimited_args 37 42 56 89 %}',
@@ -206,6 +216,8 @@ class InclusionTagTests(TagTestCase):
                 '{% load inclusion %}{% inclusion_one_default 37 42 56 %}'),
             ("'inclusion_one_default' did not receive value(s) for the argument(s): 'one'",
                 '{% load inclusion %}{% inclusion_one_default %}'),
+            ("'inclusion_keyword_only_default' received multiple values for keyword argument 'kwarg'",
+                '{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 kwarg=42 %}'),
             ("'inclusion_unlimited_args' did not receive value(s) for the argument(s): 'one'",
                 '{% load inclusion %}{% inclusion_unlimited_args %}'),
             (
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

Custom template tags raise TemplateSyntaxError when keyword-only arguments with defaults are provided.
Description
	 
		(last modified by P-Seebauer)
	 
When creating simple tags without variable keyword args, but an keyword argument with a default value. It's not possible to supply any other variable.
@register.simple_tag
def hello(*, greeting='hello'):
	return f'{greeting} world'
{% hello greeting='hi' %}
Raises “'hello' received unexpected keyword argument 'greeting'”
Also supplying a keyword argument a second time raises the wrong error message:
#tag
@register.simple_tag
def hi(*, greeting):
	return f'{greeting} world'
{% hi greeting='hi' greeting='hello' %}
Raises “'hi' received unexpected keyword argument 'greeting'”
instead of "'hi' received multiple values for keyword argument 'greeting'"
Same goes for inclusion tags (is the same code) I already have a fix ready, will push it after creating the ticket (that I have a ticket# for the commit).
Is actually for all versions since the offending line is from 2.0…

## Deliverable

changes to this tree

## Check

`./tests/runtests.py template_tests`

## Scope

`django/template/library.py`
`tests/template_tests/`

## Done when

- A `simple_tag` with a keyword-only argument that has a default accepts that keyword in a template, e.g. `{% hello greeting='hi' %}` renders instead of raising `TemplateSyntaxError`.
- Supplying the same keyword-only argument twice raises `TemplateSyntaxError` with a “received multiple values for keyword argument” message, not “unexpected keyword argument”.
- Inclusion tags using the same keyword-only signatures behave the same as simple tags.
- The scoped template test command exits 0.



# plan.md

## Deliverable
changes to this tree

## Check
`./tests/runtests.py template_tests`

## Scope
`django/template/library.py`
`tests/template_tests/`

## Done when
- A `simple_tag` with a keyword-only argument that has a default accepts that keyword in a template, e.g. `{% hello greeting='hi' %}` renders instead of raising `TemplateSyntaxError`.
- Supplying the same keyword-only argument twice raises `TemplateSyntaxError` with a “received multiple values for keyword argument” message, not “unexpected keyword argument”.
- Inclusion tags using the same keyword-only signatures behave the same as simple tags.
- The scoped template test command exits 0.

## Approach
The bug is in the shared `parse_bits()` path used by both `simple_tag` and `inclusion_tag`: keyword-only arguments with defaults are excluded from the bookkeeping used to decide whether a supplied keyword is valid, so they are treated as unexpected, and duplicate detection is wrong.

Decompose as:
1. Add regression coverage under `tests/template_tests/` for a simple tag with `def hello(*, greeting='hello')`, a required keyword-only tag, duplicate keyword supply, and the inclusion-tag equivalent.
2. Fix `parse_bits()` so all keyword-only names are recognized as valid keyword targets, while required keyword-only names are tracked separately for the missing-argument check.
3. Run `./tests/runtests.py template_tests`.

Candidate approaches:
- Minimal bookkeeping fix: keep an `unhandled_kwargs` list containing all keyword-only names, and add a separate required-keyword-only list for the final missing-argument validation. This preserves existing error messages and is the smallest change.
- Seen-set fix: track supplied keyword names in a `seen_kwargs` set, validate against `kwonly`, and check required keyword-only arguments at the end. Slightly clearer, but touches more of the parser loop.
- Signature-based binding: use `inspect.signature` to bind arguments. Too invasive for this parser and risks changing existing template-tag error behavior.


# django/template/library.py

```
import functools
from importlib import import_module
from inspect import getfullargspec, unwrap

from django.utils.html import conditional_escape
from django.utils.itercompat import is_iterable

from .base import Node, Template, token_kwargs
from .exceptions import TemplateSyntaxError


class InvalidTemplateLibrary(Exception):
    pass


class Library:
    """
    A class for registering template tags and filters. Compiled filter and
    template tag functions are stored in the filters and tags attributes.
    The filter, simple_tag, and inclusion_tag methods provide a convenient
    way to register callables as tags.
    """
    def __init__(self):
        self.filters = {}
        self.tags = {}

    def tag(self, name=None, compile_function=None):
        if name is None and compile_function is None:
            # @register.tag()
            return self.tag_function
        elif name is not None and compile_function is None:
            if callable(name):
                # @register.tag
                return self.tag_function(name)
            else:
                # @register.tag('somename') or @register.tag(name='somename')
                def dec(func):
                    return self.tag(name, func)
                return dec
        elif name is not None and compile_function is not None:
            # register.tag('somename', somefunc)
            self.tags[name] = compile_function
            return compile_function
        else:
            raise ValueError(
                "Unsupported arguments to Library.tag: (%r, %r)" %
                (name, compile_function),
            )

    def tag_function(self, func):
        self.tags[getattr(func, "_decorated_function", func).__name__] = func
        return func

    def filter(self, name=None, filter_func=None, **flags):
        """
        Register a callable as a template filter. Example:

        @register.filter
        def lower(value):
            return value.lower()
        """
        if name is None and filter_func is None:
            # @register.filter()
            def dec(func):
                return self.filter_function(func, **flags)
            return dec
        elif name is not None and filter_func is None:
            if callable(name):
                # @register.filter
                return self.filter_function(name, **flags)
            else:
                # @register.filter('somename') or @register.filter(name='somename')
                def dec(func):
                    return self.filter(name, func, **flags)
                return dec
        elif name is not None and filter_func is not None:
            # register.filter('somename', somefunc)
            self.filters[name] = filter_func
            for attr in ('expects_localtime', 'is_safe', 'needs_autoescape'):
                if attr in flags:
                    value = flags[attr]
                    # set the flag on the filter for FilterExpression.resolve
                    setattr(filter_func, attr, value)
                    # set the flag on the innermost decorated function
                    # for decorators that need it, e.g. stringfilter
                    if hasattr(filter_func, "_decorated_function"):
                        setattr(filter_func._decorated_function, attr, value)
            filter_func._filter_name = name
            return filter_func
        else:
            raise ValueError(
                "Unsupported arguments to Library.filter: (%r, %r)" %
                (name, filter_func),
            )

    def filter_function(self, func, **flags):
        name = getattr(func, "_decorated_function", func).__name__
        return self.filter(name, func, **flags)

    def simple_tag(self, func=None, takes_context=None, name=None):
        """
        Register a callable as a compiled template tag. Example:

        @register.simple_tag
        def hello(*args, **kwargs):
            return 'world'
        """
        def dec(func):
            params, varargs, varkw, defaults, kwonly, kwonly_defaults, _ = getfullargspec(unwrap(func))
            function_name = (name or getattr(func, '_decorated_function', func).__name__)

            @functools.wraps(func)
            def compile_func(parser, token):
                bits = token.split_contents()[1:]
                target_var = None
                if len(bits) >= 2 and bits[-2] == 'as':
                    target_var = bits[-1]
                    bits = bits[:-2]
                args, kwargs = parse_bits(
                    parser, bits, params, varargs, varkw, defaults,
                    kwonly, kwonly_defaults, takes_context, function_name,
                )
                return SimpleNode(func, takes_context, args, kwargs, target_var)
            self.tag(function_name, compile_func)
            return func

        if func is None:
            # @register.simple_tag(...)
            return dec
        elif callable(func):
            # @register.simple_tag
            return dec(func)
        else:
            raise ValueError("Invalid arguments provided to simple_tag")

    def inclusion_tag(self, filename, func=None, takes_context=None, name=None):
        """
        Register a callable as an inclusion tag:

        @register.inclusion_tag('results.html')
        def show_results(poll):
            choices = poll.choice_set.all()
            return {'choices': choices}
        """
        def dec(func):
            params, varargs, varkw, defaults, kwonly, kwonly_defaults, _ = getfullargspec(unwrap(func))
            function_name = (name or getattr(func, '_decorated_function', func).__name__)

            @functools.wraps(func)
            def compile_func(parser, token):
                bits = token.split_contents()[1:]
                args, kwargs = parse_bits(
                    parser, bits, params, varargs, varkw, defaults,
                    kwonly, kwonly_defaults, takes_context, function_name,
                )
                return InclusionNode(
                    func, takes_context, args, kwargs, filename,
                )
            self.tag(function_name, compile_func)
            return func
        return dec


class TagHelperNode(Node):
    """
    Base class for tag helper nodes such as SimpleNode and InclusionNode.
    Manages the positional and keyword arguments to be passed to the decorated
    function.
    """
    def __init__(self, func, takes_context, args, kwargs):
        self.func = func
        self.takes_context = takes_context
        self.args = args
        self.kwargs = kwargs

    def get_resolved_arguments(self, context):
        resolved_args = [var.resolve(context) for var in self.args]
        if self.takes_context:
            resolved_args = [context] + resolved_args
        resolved_kwargs = {k: v.resolve(context) for k, v in self.kwargs.items()}
        return resolved_args, resolved_kwargs


class SimpleNode(TagHelperNode):

    def __init__(self, func, takes_context, args, kwargs, target_var):
        super().__init__(func, takes_context, args, kwargs)
        self.target_var = target_var

    def render(self, context):
        resolved_args, resolved_kwargs = self.get_resolved_arguments(context)
        output = self.func(*resolved_args, **resolved_kwargs)
        if self.target_var is not None:
            context[self.target_var] = output
            return ''
        if context.autoescape:
            output = conditional_escape(output)
        return output


class InclusionNode(TagHelperNode):

    def __init__(self, func, takes_context, args, kwargs, filename):
        super().__init__(func, takes_context, args, kwargs)
        self.filename = filename

    def render(self, context):
        """
        Render the specified template and context. Cache the template object
        in render_context to avoid reparsing and loading when used in a for
        loop.
        """
        resolved_args, resolved_kwargs = self.get_resolved_arguments(context)
        _dict = self.func(*resolved_args, **resolved_kwargs)

        t = context.render_context.get(self)
        if t is None:
            if isinstance(self.filename, Template):
                t = self.filename
            elif isinstance(getattr(self.filename, 'template', None), Template):
                t = self.filename.template
            elif not isinstance(self.filename, str) and is_iterable(self.filename):
                t = context.template.engine.select_template(self.filename)
            else:
                t = context.template.engine.get_template(self.filename)
            context.render_context[self] = t
        new_context = context.new(_dict)
        # Copy across the CSRF token, if present, because inclusion tags are
        # often used for forms, and we need instructions for using CSRF
        # protection to be as simple as possible.
        csrf_token = context.get('csrf_token')
        if csrf_token is not None:
            new_context['csrf_token'] = csrf_token
        return t.render(new_context)


def parse_bits(parser, bits, params, varargs, varkw, defaults,
               kwonly, kwonly_defaults, takes_context, name):
    """
    Parse bits for template tag helpers simple_tag and inclusion_tag, in
    particular by detecting syntax errors and by extracting positional and
    keyword arguments.
    """
    if takes_context:
        if params[0] == 'context':
            params = params[1:]
        else:
            raise TemplateSyntaxError(
                "'%s' is decorated with takes_context=True so it must "
                "have a first argument of 'context'" % name)
    args = []
    kwargs = {}
    unhandled_params = list(params)
    unhandled_kwargs = [
        kwarg for kwarg in kwonly
        if not kwonly_defaults or kwarg not in kwonly_defaults
    ]
    for bit in bits:
        # First we try to extract a potential kwarg from the bit
        kwarg = token_kwargs([bit], parser)
        if kwarg:
            # The kwarg was successfully extracted
            param, value = kwarg.popitem()
            if param not in params and param not in kwonly and varkw is None:
                # An unexpected keyword argument was supplied
                raise TemplateSyntaxError(
                    "'%s' received unexpected keyword argument '%s'" %
                    (name, param))
            elif param in kwargs:
                # The keyword argument has already been supplied once
                raise TemplateSyntaxError(
                    "'%s' received multiple values for keyword argument '%s'" %
                    (name, param))
            else:
                # All good, record the keyword argument
                kwargs[str(param)] = value
                if param in unhandled_params:
                    # If using the keyword syntax for a positional arg, then
                    # consume it.
                    unhandled_params.remove(param)
                elif param in unhandled_kwargs:
                    # Same for keyword-only arguments
                    unhandled_kwargs.remove(param)
        else:
            if kwargs:
                raise TemplateSyntaxError(
                    "'%s' received some positional argument(s) after some "
                    "keyword argument(s)" % name)
            else:
                # Record the positional argument
                args.append(parser.compile_filter(bit))
                try:
                    # Consume from the list of expected positional arguments
                    unhandled_params.pop(0)
                except IndexError:
                    if varargs is None:
                        raise TemplateSyntaxError(
                            "'%s' received too many positional arguments" %
                            name)
    if defaults is not None:
        # Consider the last n params handled, where n is the
        # number of defaults.
        unhandled_params = unhandled_params[:-len(defaults)]
    if unhandled_params or unhandled_kwargs:
        # Some positional arguments were not supplied
        raise TemplateSyntaxError(
            "'%s' did not receive value(s) for the argument(s): %s" %
            (name, ", ".join("'%s'" % p for p in unhandled_params + unhandled_kwargs)))
    return args, kwargs


def import_library(name):
    """
    Load a Library object from a template tag module.
    """
    try:
        module = import_module(name)
    except ImportError as e:
        raise InvalidTemplateLibrary(
            "Invalid template library specified. ImportError raised when "
            "trying to load '%s': %s" % (name, e)
        )
    try:
        return module.register
    except AttributeError:
        raise InvalidTemplateLibrary(
            "Module  %s does not have a variable named 'register'" % name,
        )

```


# tests/template_tests (the files in it)

tests/template_tests/__init__.py
tests/template_tests/alternate_urls.py
tests/template_tests/annotated_tag_function.py
tests/template_tests/broken_tag.py
tests/template_tests/eggs/tagsegg.egg
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
tests/template_tests/jinja2/template_tests/using.html
tests/template_tests/other_templates/priority/foo.html
tests/template_tests/other_templates/test_dirs.html
tests/template_tests/recursive_templates/fs/extend-missing.html
tests/template_tests/recursive_templates/fs/one.html
tests/template_tests/recursive_templates/fs/other-recursive.html
tests/template_tests/recursive_templates/fs/recursive.html
tests/template_tests/recursive_templates/fs/self.html
tests/template_tests/recursive_templates/fs/three.html
tests/template_tests/recursive_templates/fs/two.html
tests/template_tests/recursive_templates/fs2/recursive.html
tests/template_tests/recursive_templates/fs3/recursive.html
tests/template_tests/relative_templates/dir1/dir2/inc1.html
tests/template_tests/relative_templates/dir1/dir2/inc2.html
tests/template_tests/relative_templates/dir1/dir2/include_content.html
tests/template_tests/relative_templates/dir1/dir2/one.html
tests/template_tests/relative_templates/dir1/looped.html
tests/template_tests/relative_templates/dir1/one.html
tests/template_tests/relative_templates/dir1/one1.html
tests/template_tests/relative_templates/dir1/one2.html
tests/template_tests/relative_templates/dir1/one3.html
tests/template_tests/relative_templates/dir1/three.html
tests/template_tests/relative_templates/dir1/two.html
tests/template_tests/relative_templates/error_extends.html
tests/template_tests/relative_templates/error_include.html
tests/template_tests/relative_templates/one.html
tests/template_tests/relative_templates/three.html
tests/template_tests/relative_templates/two.html
tests/template_tests/syntax_tests/__init__.py
tests/template_tests/syntax_tests/i18n/__init__.py
tests/template_tests/syntax_tests/i18n/base.py
tests/template_tests/syntax_tests/i18n/test_blocktranslate.py
tests/template_tests/syntax_tests/i18n/test_filters.py
tests/template_tests/syntax_tests/i18n/test_get_available_languages.py
tests/template_tests/syntax_tests/i18n/test_get_current_language.py
tests/template_tests/syntax_tests/i18n/test_get_current_language_bidi.py
tests/template_tests/syntax_tests/i18n/test_get_language_info.py
tests/template_tests/syntax_tests/i18n/test_get_language_info_list.py
tests/template_tests/syntax_tests/i18n/test_language.py
tests/template_tests/syntax_tests/i18n/test_translate.py
tests/template_tests/syntax_tests/i18n/test_underscore_syntax.py
tests/template_tests/syntax_tests/test_autoescape.py
tests/template_tests/syntax_tests/test_basic.py
tests/template_tests/syntax_tests/test_builtins.py
tests/template_tests/syntax_tests/test_cache.py
tests/template_tests/syntax_tests/test_comment.py
tests/template_tests/syntax_tests/test_cycle.py
tests/template_tests/syntax_tests/test_exceptions.py
tests/template_tests/syntax_tests/test_extends.py
tests/template_tests/syntax_tests/test_filter_syntax.py
tests/template_tests/syntax_tests/test_filter_tag.py
tests/template_tests/syntax_tests/test_firstof.py
tests/template_tests/syntax_tests/test_for.py
tests/template_tests/syntax_tests/test_if.py
tests/template_tests/syntax_tests/test_if_changed.py
tests/template_tests/syntax_tests/test_if_equal.py
tests/template_tests/syntax_tests/test_include.py
tests/template_tests/syntax_tests/test_invalid_string.py
tests/template_tests/syntax_tests/test_list_index.py
tests/template_tests/syntax_tests/test_load.py
tests/template_tests/syntax_tests/test_lorem.py
tests/template_tests/syntax_tests/test_multiline.py
tests/template_tests/syntax_tests/test_named_endblock.py
tests/template_tests/syntax_tests/test_now.py
tests/template_tests/syntax_tests/test_numpy.py
tests/template_tests/syntax_tests/test_regroup.py
tests/template_tests/syntax_tests/test_resetcycle.py
tests/template_tests/syntax_tests/test_setup.py
tests/template_tests/syntax_tests/test_simple_tag.py
tests/template_tests/syntax_tests/test_spaceless.py
tests/template_tests/syntax_tests/test_static.py
tests/template_tests/syntax_tests/test_template_tag.py
tests/template_tests/syntax_tests/test_url.py
tests/template_tests/syntax_tests/test_verbatim.py
tests/template_tests/syntax_tests/test_width_ratio.py
tests/template_tests/syntax_tests/test_with.py
tests/template_tests/templates/27584_child.html
tests/template_tests/templates/27584_parent.html
tests/template_tests/templates/27956_child.html
tests/template_tests/templates/27956_parent.html
tests/template_tests/templates/broken_base.html
tests/template_tests/templates/first/test.html
tests/template_tests/templates/include_tpl.html
tests/template_tests/templates/included_base.html
tests/template_tests/templates/included_content.html
tests/template_tests/templates/inclusion.html
tests/template_tests/templates/inclusion_base.html
tests/template_tests/templates/inclusion_extends1.html
tests/template_tests/templates/inclusion_extends2.html
tests/template_tests/templates/index.html
tests/template_tests/templates/priority/foo.html
tests/template_tests/templates/recursive_include.html
tests/template_tests/templates/response.html
tests/template_tests/templates/second/test.html
tests/template_tests/templates/ssi include with spaces.html
tests/template_tests/templates/ssi_include.html
tests/template_tests/templates/template_tests/using.html
tests/template_tests/templates/test_context.html
tests/template_tests/templates/test_context_stack.html
tests/template_tests/templates/test_extends_error.html
tests/template_tests/templates/test_incl_tag_use_l10n.html
tests/template_tests/templates/test_include_error.html
tests/template_tests/templatetags/__init__.py
tests/template_tests/templatetags/bad_tag.py
tests/template_tests/templatetags/custom.py
tests/template_tests/templatetags/inclusion.py
tests/template_tests/templatetags/subpackage/__init__.py
tests/template_tests/templatetags/subpackage/echo.py
tests/template_tests/templatetags/tag_27584.py
tests/template_tests/templatetags/testtags.py
tests/template_tests/test_base.py
tests/template_tests/test_callables.py
tests/template_tests/test_context.py
tests/template_tests/test_custom.py
tests/template_tests/test_engine.py
tests/template_tests/test_extends.py
tests/template_tests/test_extends_relative.py
tests/template_tests/test_library.py
tests/template_tests/test_loaders.py
tests/template_tests/test_logging.py
tests/template_tests/test_nodelist.py
tests/template_tests/test_origin.py
tests/template_tests/test_parser.py
tests/template_tests/test_response.py
tests/template_tests/test_smartif.py
tests/template_tests/tests.py
tests/template_tests/urls.py
tests/template_tests/utils.py
tests/template_tests/views.py


# The last commit

```
6b2b46b416 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: ./tests/runtests.py template_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
...............................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................s......F....................................................................................................................................................................................................................................................
======================================================================
FAIL: test_permissions_error (template_tests.test_loaders.FileSystemLoaderTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/tests/template_tests/test_loaders.py", line 195, in test_permissions_error
    self.engine.get_template(tmpfile.name)
  File "/opt/miniconda3/envs/testbed/lib/python3.6/contextlib.py", line 88, in __exit__
    next(self.gen)
  File "/testbed/django/test/testcases.py", line 682, in _assert_raises_or_warns_cm
    yield cm
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 203, in __exit__
    self._raiseFailure("{} not raised".format(exc_name))
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 135, in _raiseFailure
    raise self.test_case.failureException(msg)
AssertionError: PermissionError not raised

----------------------------------------------------------------------
Ran 1387 tests in 5.775s

FAILED (failures=1, skipped=1)

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/template/library.py tests/template_tests
changed: django/template/library.py +1 -1
changed: tests/template_tests/templatetags/custom.py +5 -0
changed: tests/template_tests/templatetags/inclusion.py +5 -0
changed: tests/template_tests/test_custom.py +12 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/template/library.py b/django/template/library.py
index 20bc86dac8..2f74556268 100644
--- a/django/template/library.py
+++ b/django/template/library.py
@@ -261,7 +261,7 @@ def parse_bits(parser, bits, params, varargs, varkw, defaults,
         if kwarg:
             # The kwarg was successfully extracted
             param, value = kwarg.popitem()
-            if param not in params and param not in unhandled_kwargs and varkw is None:
+            if param not in params and param not in kwonly and varkw is None:
                 # An unexpected keyword argument was supplied
                 raise TemplateSyntaxError(
                     "'%s' received unexpected keyword argument '%s'" %
diff --git a/tests/template_tests/templatetags/custom.py b/tests/template_tests/templatetags/custom.py
index a5e1b33c67..eaf6739ac3 100644
--- a/tests/template_tests/templatetags/custom.py
+++ b/tests/template_tests/templatetags/custom.py
@@ -98,6 +98,11 @@ def simple_keyword_only_default(*, kwarg=42):
     return "simple_keyword_only_default - Expected result: %s" % kwarg
 
 
+@register.simple_tag
+def simple_keyword_only_default_with_other(*, kwarg=42, other=99):
+    return "simple_keyword_only_default_with_other - Expected result: %s, %s" % (kwarg, other)
+
+
 @register.simple_tag
 def simple_one_default(one, two='hi'):
     """Expected simple_one_default __doc__"""
diff --git a/tests/template_tests/templatetags/inclusion.py b/tests/template_tests/templatetags/inclusion.py
index 242fbe80cb..784da91fde 100644
--- a/tests/template_tests/templatetags/inclusion.py
+++ b/tests/template_tests/templatetags/inclusion.py
@@ -136,6 +136,11 @@ def inclusion_one_default(one, two='hi'):
 inclusion_one_default.anything = "Expected inclusion_one_default __dict__"
 
 
+@register.inclusion_tag('inclusion.html')
+def inclusion_keyword_only_default(*, kwarg=42):
+    return {"result": "inclusion_keyword_only_default - Expected result: %s" % kwarg}
+
+
 @register.inclusion_tag(engine.get_template('inclusion.html'))
 def inclusion_one_default_from_template(one, two='hi'):
     """Expected inclusion_one_default_from_template __doc__"""
diff --git a/tests/template_tests/test_custom.py b/tests/template_tests/test_custom.py
index dbc5bc267d..434c892261 100644
--- a/tests/template_tests/test_custom.py
+++ b/tests/template_tests/test_custom.py
@@ -62,6 +62,10 @@ class SimpleTagTests(TagTestCase):
                 'simple_keyword_only_param - Expected result: 37'),
             ('{% load custom %}{% simple_keyword_only_default %}',
                 'simple_keyword_only_default - Expected result: 42'),
+            ('{% load custom %}{% simple_keyword_only_default kwarg=37 %}',
+                'simple_keyword_only_default - Expected result: 37'),
+            ('{% load custom %}{% simple_keyword_only_default_with_other other=37 %}',
+                'simple_keyword_only_default_with_other - Expected result: 42, 37'),
             ('{% load custom %}{% simple_one_default 37 %}', 'simple_one_default - Expected result: 37, hi'),
             ('{% load custom %}{% simple_one_default 37 two="hello" %}',
                 'simple_one_default - Expected result: 37, hello'),
@@ -97,6 +101,8 @@ class SimpleTagTests(TagTestCase):
                 '{% load custom %}{% simple_one_default 37 42 56 %}'),
             ("'simple_keyword_only_param' did not receive value(s) for the argument(s): 'kwarg'",
                 '{% load custom %}{% simple_keyword_only_param %}'),
+            ("'simple_keyword_only_param' received multiple values for keyword argument 'kwarg'",
+                '{% load custom %}{% simple_keyword_only_param kwarg=37 kwarg=42 %}'),
             ("'simple_unlimited_args_kwargs' received some positional argument(s) after some keyword argument(s)",
                 '{% load custom %}{% simple_unlimited_args_kwargs 37 40|add:2 eggs="scrambled" 56 four=1|add:3 %}'),
             ("'simple_unlimited_args_kwargs' received multiple values for keyword argument 'eggs'",
@@ -180,6 +186,10 @@ class InclusionTagTests(TagTestCase):
                 'inclusion_one_default - Expected result: 99, hello\n'),
             ('{% load inclusion %}{% inclusion_one_default 37 42 %}',
                 'inclusion_one_default - Expected result: 37, 42\n'),
+            ('{% load inclusion %}{% inclusion_keyword_only_default %}',
+                'inclusion_keyword_only_default - Expected result: 42\n'),
+            ('{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 %}',
+                'inclusion_keyword_only_default - Expected result: 37\n'),
             ('{% load inclusion %}{% inclusion_unlimited_args 37 %}',
                 'inclusion_unlimited_args - Expected result: 37, hi\n'),
             ('{% load inclusion %}{% inclusion_unlimited_args 37 42 56 89 %}',
@@ -206,6 +216,8 @@ class InclusionTagTests(TagTestCase):
                 '{% load inclusion %}{% inclusion_one_default 37 42 56 %}'),
             ("'inclusion_one_default' did not receive value(s) for the argument(s): 'one'",
                 '{% load inclusion %}{% inclusion_one_default %}'),
+            ("'inclusion_keyword_only_default' received multiple values for keyword argument 'kwarg'",
+                '{% load inclusion %}{% inclusion_keyword_only_default kwarg=37 kwarg=42 %}'),
             ("'inclusion_unlimited_args' did not receive value(s) for the argument(s): 'one'",
                 '{% load inclusion %}{% inclusion_unlimited_args %}'),
             (
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
check: ./tests/runtests.py template_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
..........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................s......F.........................................................................................................................................................................................................................................................
======================================================================
FAIL: test_permissions_error (template_tests.test_loaders.FileSystemLoaderTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/tests/template_tests/test_loaders.py", line 195, in test_permissions_error
    self.engine.get_template(tmpfile.name)
  File "/opt/miniconda3/envs/testbed/lib/python3.6/contextlib.py", line 88, in __exit__
    next(self.gen)
  File "/testbed/django/test/testcases.py", line 682, in _assert_raises_or_warns_cm
    yield cm
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 203, in __exit__
    self._raiseFailure("{} not raised".format(exc_name))
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 135, in _raiseFailure
    raise self.test_case.failureException(msg)
AssertionError: PermissionError not raised

----------------------------------------------------------------------
Ran 1387 tests in 5.057s

FAILED (failures=1, skipped=1)

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/template/library.py tests/template_tests
changed: django/template/library.py +1 -1
changed: tests/template_tests/templatetags/custom.py +5 -0
changed: tests/template_tests/templatetags/inclusion.py +5 -0
changed: tests/template_tests/test_custom.py +12 -0
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
# Notes, run 2026-11-06T105440

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Custom template tags raise TemplateSyntaxError when keyword-only arguments with defaults are provided.
Description
	 
		(last modified by P-Seebauer)
	 
When creating simple tags without variable keyword args, but an keyword argument with a default value. It's not possible to supply any other variable.
@register.simple_tag
def hello(*, greeting='hello'):
	return f'{greeting} world'
{% hello greeting='hi' %}
Raises “'hello' received unexpected keyword argument 'greeting'”
Also supplying a keyword argument a second time raises the wrong error message:
#tag
@register.simple_tag
def hi(*, greeting):
	return f'{greeting} world'
{% hi greeting='hi' greeting='hello' %}
Raises “'hi' received unexpected keyword argument 'greeting'”
instead of "'hi' received multiple values for keyword argument 'greeting'"
Same goes for inclusion tags (is the same code) I already have a fix ready, will push it after creating the ticket (that I have a ticket# for the commit).
Is actually for all versions since the offending line is from 2.0…


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
```


# The last commit

```
6b2b46b416 SWE-bench


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
`./tests/runtests.py template_tests`

## Scope
`django/template/library.py`
`tests/template_tests/`

## Done when
- A `simple_tag` with a keyword-only argument that has a default accepts that keyword in a template, e.g. `{% hello greeting='hi' %}` renders instead of raising `TemplateSyntaxError`.
- Supplying the same keyword-only argument twice raises `TemplateSyntaxError` with a “received multiple values for keyword argument” message, not “unexpected keyword argument”.
- Inclusion tags using the same keyword-only signatures behave the same as simple tags.
- The scoped template test command exits 0.

## Approach
The bug is in the shared `parse_bits()` path used by both `simple_tag` and `inclusion_tag`: keyword-only arguments with defaults are excluded from the bookkeeping used to decide whether a supplied keyword is valid, so they are treated as unexpected, and duplicate detection is wrong.

Decompose as:
1. Add regression coverage under `tests/template_tests/` for a simple tag with `def hello(*, greeting='hello')`, a required keyword-only tag, duplicate keyword supply, and the inclusion-tag equivalent.
2. Fix `parse_bits()` so all keyword-only names are recognized as valid keyword targets, while required keyword-only names are tracked separately for the missing-argument check.
3. Run `./tests/runtests.py template_tests`.

Candidate approaches:
- Minimal bookkeeping fix: keep an `unhandled_kwargs` list containing all keyword-only names, and add a separate required-keyword-only list for the final missing-argument validation. This preserves existing error messages and is the smallest change.
- Seen-set fix: track supplied keyword names in a `seen_kwargs` set, validate against `kwonly`, and check required keyword-only arguments at the end. Slightly clearer, but touches more of the parser loop.
- Signature-based binding: use `inspect.signature` to bind arguments. Too invasive for this parser and risks changing existing template-tag error behavior.
```

### `prompt.md`

```
Custom template tags raise TemplateSyntaxError when keyword-only arguments with defaults are provided.
Description
	 
		(last modified by P-Seebauer)
	 
When creating simple tags without variable keyword args, but an keyword argument with a default value. It's not possible to supply any other variable.
@register.simple_tag
def hello(*, greeting='hello'):
	return f'{greeting} world'
{% hello greeting='hi' %}
Raises “'hello' received unexpected keyword argument 'greeting'”
Also supplying a keyword argument a second time raises the wrong error message:
#tag
@register.simple_tag
def hi(*, greeting):
	return f'{greeting} world'
{% hi greeting='hi' greeting='hello' %}
Raises “'hi' received unexpected keyword argument 'greeting'”
instead of "'hi' received multiple values for keyword argument 'greeting'"
Same goes for inclusion tags (is the same code) I already have a fix ready, will push it after creating the ticket (that I have a ticket# for the commit).
Is actually for all versions since the offending line is from 2.0…
```

### `review.md`

```
verdict: PASS

- The one-line change in `django/template/library.py` is the correct fix: the unexpected-keyword guard now tests `param not in kwonly` instead of `param not in unhandled_kwargs`, so keyword-only params that have defaults (and are therefore absent from `unhandled_kwargs`) are accepted, while genuinely unknown keywords still raise.
- Done-when 1 is met: `{% simple_keyword_only_default kwarg=37 %}` and `{% simple_keyword_only_default_with_other other=37 %}` are added to `SimpleTagTests.test_tags` and exercise the previously failing path (before the fix, `kwarg`/`other` were not in `unhandled_kwargs` and hit the "unexpected keyword argument" branch).
- Done-when 2 is met: the duplicate-keyword test `{% simple_keyword_only_param kwarg=37 kwarg=42 %}` now reaches the `elif param in kwargs` branch and yields "received multiple values for keyword argument 'kwarg'". This is a real regression test — before the fix the first occurrence removed `kwarg` from `unhandled_kwargs`, so the second occurrence fell into the "unexpected" branch.
- Done-when 3 is met: `inclusion_keyword_only_default` is added and tested both with the default and with `kwarg=37`, plus the duplicate-keyword case, matching the simple-tag behaviour (inclusion tags share `parse_bits`).
- Done-when 4: the check command's only failure is `test_permissions_error` (`PermissionError not raised`), which the report states also fails on the unmodified baseline (running as root); it is unrelated to this change and the change adds no new failure. Check status is 0.
- Scope is respected: only `django/template/library.py` and `tests/template_tests/` files are touched; no unrelated files, no removed content (the single `-1` line is the replaced guard).
```

### `scope.txt`

```
scope: django/template/library.py tests/template_tests
changed: django/template/library.py +1 -1
changed: tests/template_tests/templatetags/custom.py +5 -0
changed: tests/template_tests/templatetags/inclusion.py +5 -0
changed: tests/template_tests/test_custom.py +12 -0
```

### `task.md`

```
# Task

## Prompt

Custom template tags raise TemplateSyntaxError when keyword-only arguments with defaults are provided.
Description
	 
		(last modified by P-Seebauer)
	 
When creating simple tags without variable keyword args, but an keyword argument with a default value. It's not possible to supply any other variable.
@register.simple_tag
def hello(*, greeting='hello'):
	return f'{greeting} world'
{% hello greeting='hi' %}
Raises “'hello' received unexpected keyword argument 'greeting'”
Also supplying a keyword argument a second time raises the wrong error message:
#tag
@register.simple_tag
def hi(*, greeting):
	return f'{greeting} world'
{% hi greeting='hi' greeting='hello' %}
Raises “'hi' received unexpected keyword argument 'greeting'”
instead of "'hi' received multiple values for keyword argument 'greeting'"
Same goes for inclusion tags (is the same code) I already have a fix ready, will push it after creating the ticket (that I have a ticket# for the commit).
Is actually for all versions since the offending line is from 2.0…

## Deliverable

changes to this tree

## Check

`./tests/runtests.py template_tests`

## Scope

`django/template/library.py`
`tests/template_tests/`

## Done when

- A `simple_tag` with a keyword-only argument that has a default accepts that keyword in a template, e.g. `{% hello greeting='hi' %}` renders instead of raising `TemplateSyntaxError`.
- Supplying the same keyword-only argument twice raises `TemplateSyntaxError` with a “received multiple values for keyword argument” message, not “unexpected keyword argument”.
- Inclusion tags using the same keyword-only signatures behave the same as simple tags.
- The scoped template test command exits 0.
```

### `test-output.log`

```
check: ./tests/runtests.py template_tests
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................s......F...................................................................................................................................................................................................................................................................
======================================================================
FAIL: test_permissions_error (template_tests.test_loaders.FileSystemLoaderTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 59, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 605, in run
    testMethod()
  File "/testbed/tests/template_tests/test_loaders.py", line 195, in test_permissions_error
    self.engine.get_template(tmpfile.name)
  File "/opt/miniconda3/envs/testbed/lib/python3.6/contextlib.py", line 88, in __exit__
    next(self.gen)
  File "/testbed/django/test/testcases.py", line 682, in _assert_raises_or_warns_cm
    yield cm
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 203, in __exit__
    self._raiseFailure("{} not raised".format(exc_name))
  File "/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py", line 135, in _raiseFailure
    raise self.test_case.failureException(msg)
AssertionError: PermissionError not raised

----------------------------------------------------------------------
Ran 1387 tests in 4.386s

FAILED (failures=1, skipped=1)

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: django/template/library.py tests/template_tests
changed: django/template/library.py +1 -1
changed: tests/template_tests/templatetags/custom.py +5 -0
changed: tests/template_tests/templatetags/inclusion.py +5 -0
changed: tests/template_tests/test_custom.py +12 -0
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
