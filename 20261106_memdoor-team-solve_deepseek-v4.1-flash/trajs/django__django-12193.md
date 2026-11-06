# django__django-12193 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 92s 69 lines cost=0.006524 in=294157 cached=216064 out=9855 calls=25`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

SplitArrayField with BooleanField always has widgets checked after the first True value.
Description
	 
		(last modified by Peter Andersen)
	 
When providing a SplitArrayField BooleanField with preexisting data, the final_attrs dict is updated to include 'checked': True after the for loop has reached the first True value in the initial data array. Once this occurs every widget initialized after that defaults to checked even though the backing data may be False. This is caused by the CheckboxInput widget's get_context() modifying the attrs dict passed into it. This is the only widget that modifies the attrs dict passed into its get_context().
CheckboxInput setting attrs['checked'] to True: ​https://github.com/django/django/blob/master/django/forms/widgets.py#L527


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant**

```
I'll start by locating the relevant code in the Django repository.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls"
}
```

**assistant → tool `locate`**

```json
{
  "query": "SplitArrayField widget rendering with initial data and final_attrs checked"
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
```

**tool result**

```
Where "SplitArrayField widget rendering with initial data and final_attrs checked" lives (judged: 12 of 40 sections kept), most relevant first:
1. django/contrib/postgres/forms/array.py:133-165  p=0.92
2. django/forms/widgets.py:821-854  p=0.92
3. tests/postgres_tests/test_array.py:968-1002  p=0.69
4. docs/ref/forms/widgets.txt:358-396  p=0.58
5. docs/ref/contrib/postgres/forms.txt:80-119  p=0.50

== django/contrib/postgres/forms/array.py:133-165 (p=0.92)
  133      def get_context(self, name, value, attrs=None):
  134          attrs = {} if attrs is None else attrs
  135          context = super().get_context(name, value, attrs)
  136          if self.is_localized:
  137              self.widget.is_localized = self.is_localized
  138          value = value or []
  139          context['widget']['subwidgets'] = []
  140          final_attrs = self.build_attrs(attrs)
  141          id_ = final_attrs.get('id')
  142          for i in range(max(len(value), self.size)):
  143              try:
  144                  widget_value = value[i]
  145              except IndexError:
  146                  widget_value = None
  147              if id_:
  148                  final_attrs = {**final_attrs, 'id': '%s_%s' % (id_, i)}
  149              context['widget']['subwidgets'].append(
  150                  self.widget.get_context(name + '_%s' % i, widget_value, final_attrs)['widget']
  151              )
  152          return context
  153  
  154      @property
  155      def media(self):
  156          return self.widget.media
  157  
  158      def __deepcopy__(self, memo):
  159          obj = super().__deepcopy__(memo)
  160          obj.widget = copy.deepcopy(self.widget)
  161          return obj
  162  
  163      @property
  164      def needs_multipart_form(self):
  165          return self.widget.needs_multipart_form

== django/forms/widgets.py:821-854 (p=0.92)
  821          final_attrs = context['widget']['attrs']
  822          input_type = final_attrs.pop('type', None)
  823          id_ = final_attrs.get('id')
  824          subwidgets = []
  825          for i, widget in enumerate(self.widgets):
  826              if input_type is not None:
  827                  widget.input_type = input_type
  828              widget_name = '%s_%s' % (name, i)
  829              try:
  830                  widget_value = value[i]
  831              except IndexError:
  832                  widget_value = None
  833              if id_:
  834                  widget_attrs = final_attrs.copy()
  835                  widget_attrs['id'] = '%s_%s' % (id_, i)
  836              else:
  837                  widget_attrs = final_attrs
  838              subwidgets.append(widget.get_context(widget_name, widget_value, widget_attrs)['widget'])
  839          context['widget']['subwidgets'] = subwidgets
  840          return context
  841  
  842      def id_for_label(self, id_):
  843          if id_:
  844              id_ += '_0'
  845          return id_
  846  
  847      def value_from_datadict(self, data, files, name):
  848          return [widget.value_from_datadict(data, files, name + '_%s' % i) for i, widget in enumerate(self.widgets)]
  849  
  850      def value_omitted_from_data(self, data, files, name):
  851          return all(
  852              widget.value_omitted_from_data(data, files, name + '_%s' % i)
  853              for i, widget in enumerate(self.widgets)
  854          )

== django/contrib/postgres/forms/array.py:105-131 (p=0.88)
  105  class SplitArrayWidget(forms.Widget):
  106      template_name = 'postgres/widgets/split_array.html'
  107  
  108      def __init__(self, widget, size, **kwargs):
  109          self.widget = widget() if isinstance(widget, type) else widget
  110          self.size = size
  111          super().__init__(**kwargs)
  112  
  113      @property
  114      def is_hidden(self):
  115          return self.widget.is_hidden
  116  
  117      def value_from_datadict(self, data, files, name):
  118          return [self.widget.value_from_datadict(data, files, '%s_%s' % (name, index))
  119                  for index in range(self.size)]
  120  
  121      def value_omitted_from_data(self, data, files, name):
  122          return all(
  123              self.widget.value_omitted_from_data(data, files, '%s_%s' % (name, index))
  124              for index in range(self.size)
  125          )
  126  
  127      def id_for_label(self, id_):
  128          # See the comment for RadioSelect.id_for_label()
  129          if id_:
  130              id_ += '_0'
  131          return id_

read_file or jread a file to see more; locate again with file set to rank one file's sections.
```

**assistant → tool `read_file`**

```json
{
  "path": "django/contrib/postgres/forms/array.py",
  "offset": 125,
  "limit": 50
}
```

**assistant → tool `read_file`**

```json
{
  "path": "django/forms/widgets.py",
  "offset": 500,
  "limit": 55
}
```

**tool result**

```
        )

    def id_for_label(self, id_):
        # See the comment for RadioSelect.id_for_label()
        if id_:
            id_ += '_0'
        return id_

    def get_context(self, name, value, attrs=None):
        attrs = {} if attrs is None else attrs
        context = super().get_context(name, value, attrs)
        if self.is_localized:
            self.widget.is_localized = self.is_localized
        value = value or []
        context['widget']['subwidgets'] = []
        final_attrs = self.build_attrs(attrs)
        id_ = final_attrs.get('id')
        for i in range(max(len(value), self.size)):
            try:
                widget_value = value[i]
            except IndexError:
                widget_value = None
            if id_:
                final_attrs = {**final_attrs, 'id': '%s_%s' % (id_, i)}
            context['widget']['subwidgets'].append(
                self.widget.get_context(name + '_%s' % i, widget_value, final_attrs)['widget']
            )
        return context

    @property
    def media(self):
        return self.widget.media

    def __deepcopy__(self, memo):
        obj = super().__deepcopy__(memo)
        obj.widget = copy.deepcopy(self.widget)
        return obj

    @property
    def needs_multipart_form(self):
        return self.widget.needs_multipart_form


class SplitArrayField(forms.Field):
    default_error_messages = {
        'item_invalid': _('Item %(nth)s in the array did not validate:'),
    }

    def __init__(self, base_field, size, *, remove_trailing_nulls=False, **kwargs):
        self.base_field = base_field

[60 more lines in /testbed/django/contrib/postgres/forms/array.py (234 in all). read_file with offset: 175 to continue]
```

**tool result**

```


# Defined at module level so that CheckboxInput is picklable (#17976)
def boolean_check(v):
    return not (v is False or v is None or v == '')


class CheckboxInput(Input):
    input_type = 'checkbox'
    template_name = 'django/forms/widgets/checkbox.html'

    def __init__(self, attrs=None, check_test=None):
        super().__init__(attrs)
        # check_test is a callable that takes a value and returns True
        # if the checkbox should be checked for that value.
        self.check_test = boolean_check if check_test is None else check_test

    def format_value(self, value):
        """Only return the 'value' attribute if value isn't empty."""
        if value is True or value is False or value is None or value == '':
            return
        return str(value)

    def get_context(self, name, value, attrs):
        if self.check_test(value):
            if attrs is None:
                attrs = {}
            attrs['checked'] = True
        return super().get_context(name, value, attrs)

    def value_from_datadict(self, data, files, name):
        if name not in data:
            # A missing value means False because HTML form submission does not
            # send results for unselected checkboxes.
            return False
        value = data.get(name)
        # Translate true and false strings to boolean values.
        values = {'true': True, 'false': False}
        if isinstance(value, str):
            value = values.get(value.lower(), value)
        return bool(value)

    def value_omitted_from_data(self, data, files, name):
        # HTML checkboxes don't appear in POST data if not checked, so it's
        # never known if the value is actually omitted.
        return False


class ChoiceWidget(Widget):
    allow_multiple_selected = False
    input_type = None
    template_name = None
    option_template_name = None
    add_id_index = True
    checked_attribute = {'checked': True}

[522 more lines in /testbed/django/forms/widgets.py (1076 in all). read_file with offset: 555 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"SplitArray\\|split_array\\|CheckboxInput\" tests/postgres_tests/test_array.py | head -40"
}
```

**assistant → tool `read_file`**

```json
{
  "path": "django/contrib/postgres/forms/array.py",
  "offset": 175,
  "limit": 60
}
```

**tool result**

```
32:        SimpleArrayField, SplitArrayField, SplitArrayWidget,
934:            array = SplitArrayField(forms.CharField(), size=3)
943:            array = SplitArrayField(forms.CharField(), required=True, size=3)
952:            array = SplitArrayField(forms.CharField(required=False), size=5, remove_trailing_nulls=True)
961:            array = SplitArrayField(
975:            array = SplitArrayField(forms.CharField(), size=3)
985:            SplitArrayField(forms.IntegerField(max_value=100), size=2).clean([0, 101])
991:            array = SplitArrayField(forms.CharField(), size=3)
1005:        field = SplitArrayField(forms.CharField(max_length=2), size=3)
1015:            field = SplitArrayField(forms.IntegerField(), required=False, size=2)
1028:            field = SplitArrayField(forms.IntegerField(), required=False, size=2)
1050:            field = SplitArrayField(forms.IntegerField(), required=False, size=2, remove_trailing_nulls=True)
1073:            SplitArrayWidget(forms.TextInput(), size=2).get_context('name', ['val1', 'val2']),
1081:                    'template_name': 'postgres/widgets/split_array.html',
1108:            SplitArrayWidget(forms.TextInput(), size=2), 'array', None,
1117:            SplitArrayWidget(forms.TextInput(), size=2),
1128:        widget = SplitArrayWidget(forms.TextInput(), size=2)
```

**tool result**

```
        self.size = size
        self.remove_trailing_nulls = remove_trailing_nulls
        widget = SplitArrayWidget(widget=base_field.widget, size=size)
        kwargs.setdefault('widget', widget)
        super().__init__(**kwargs)

    def _remove_trailing_nulls(self, values):
        index = None
        if self.remove_trailing_nulls:
            for i, value in reversed(list(enumerate(values))):
                if value in self.base_field.empty_values:
                    index = i
                else:
                    break
            if index is not None:
                values = values[:index]
        return values, index

    def to_python(self, value):
        value = super().to_python(value)
        return [self.base_field.to_python(item) for item in value]

    def clean(self, value):
        cleaned_data = []
        errors = []
        if not any(value) and self.required:
            raise ValidationError(self.error_messages['required'])
        max_size = max(self.size, len(value))
        for index in range(max_size):
            item = value[index]
            try:
                cleaned_data.append(self.base_field.clean(item))
            except ValidationError as error:
                errors.append(prefix_validation_error(
                    error,
                    self.error_messages['item_invalid'],
                    code='item_invalid',
                    params={'nth': index + 1},
                ))
                cleaned_data.append(None)
            else:
                errors.append(None)
        cleaned_data, null_index = self._remove_trailing_nulls(cleaned_data)
        if null_index is not None:
            errors = errors[:null_index]
        errors = list(filter(None, errors))
        if errors:
            raise ValidationError(list(chain.from_iterable(errors)))
        return cleaned_data

    def has_changed(self, initial, data):
        try:
            data = self.to_python(data)
        except ValidationError:
            pass
        else:
            data, _ = self._remove_trailing_nulls(data)
            if initial in self.empty_values and data in self.empty_values:
                return False
        return super().has_changed(initial, data)

[lines 175-234 of /testbed/django/contrib/postgres/forms/array.py, the end]
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/postgres_tests/test_array.py",
  "offset": 1060,
  "limit": 80
}
```

**tool result**

```
            ({'field': [1]}, {'field_0': '1', 'field_1': ''}, False),
        ]
        for initial, data, expected_result in tests:
            with self.subTest(initial=initial, data=data):
                obj = IntegerArrayModel(**initial)
                form = Form(data, instance=obj)
                self.assertIs(form.has_changed(), expected_result)


class TestSplitFormWidget(PostgreSQLWidgetTestCase):

    def test_get_context(self):
        self.assertEqual(
            SplitArrayWidget(forms.TextInput(), size=2).get_context('name', ['val1', 'val2']),
            {
                'widget': {
                    'name': 'name',
                    'is_hidden': False,
                    'required': False,
                    'value': "['val1', 'val2']",
                    'attrs': {},
                    'template_name': 'postgres/widgets/split_array.html',
                    'subwidgets': [
                        {
                            'name': 'name_0',
                            'is_hidden': False,
                            'required': False,
                            'value': 'val1',
                            'attrs': {},
                            'template_name': 'django/forms/widgets/text.html',
                            'type': 'text',
                        },
                        {
                            'name': 'name_1',
                            'is_hidden': False,
                            'required': False,
                            'value': 'val2',
                            'attrs': {},
                            'template_name': 'django/forms/widgets/text.html',
                            'type': 'text',
                        },
                    ]
                }
            }
        )

    def test_render(self):
        self.check_html(
            SplitArrayWidget(forms.TextInput(), size=2), 'array', None,
            """
            <input name="array_0" type="text">
            <input name="array_1" type="text">
            """
        )

    def test_render_attrs(self):
        self.check_html(
            SplitArrayWidget(forms.TextInput(), size=2),
            'array', ['val1', 'val2'], attrs={'id': 'foo'},
            html=(
                """
                <input id="foo_0" name="array_0" type="text" value="val1">
                <input id="foo_1" name="array_1" type="text" value="val2">
                """
            )
        )

    def test_value_omitted_from_data(self):
        widget = SplitArrayWidget(forms.TextInput(), size=2)
        self.assertIs(widget.value_omitted_from_data({}, {}, 'field'), True)
        self.assertIs(widget.value_omitted_from_data({'field_0': 'value'}, {}, 'field'), False)
        self.assertIs(widget.value_omitted_from_data({'field_1': 'value'}, {}, 'field'), False)
        self.assertIs(widget.value_omitted_from_data({'field_0': 'value', 'field_1': 'value'}, {}, 'field'), False)

[lines 1060-1132 of /testbed/tests/postgres_tests/test_array.py, the end]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/contrib/postgres/forms/array.py\n@@\n         for i in range(max(len(value), self.size)):\n             try:\n                 widget_value = value[i]\n             except IndexError:\n                 widget_value = None\n+            widget_attrs = final_attrs.copy()\n             if id_:\n-                final_attrs = {**final_attrs, 'id': '%s_%s' % (id_, i)}\n+                widget_attrs['id'] = '%s_%s' % (id_, i)\n             context['widget']['subwidgets'].append(\n-                self.widget.get_context(name + '_%s' % i, widget_value, final_attrs)['widget']\n+                self.widget.get_context(name + '_%s' % i, widget_value, widget_attrs)['widget']\n             )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/contrib/postgres/forms/array.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/contrib/postgres/forms/array.py now (235 lines), around the change:
144:                widget_value = value[i]
145:            except IndexError:
146:                widget_value = None
147:            widget_attrs = final_attrs.copy()
148:            if id_:
149:                widget_attrs['id'] = '%s_%s' % (id_, i)
150:            context['widget']['subwidgets'].append(
151:                self.widget.get_context(name + '_%s' % i, widget_value, widget_attrs)['widget']
152:            )
153:        return context
154:
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,45p' tests/postgres_tests/test_array.py && grep -n \"BooleanField\" tests/postgres_tests/test_array.py | head"
}
```

**tool result**

```
import decimal
import enum
import json
import unittest
import uuid

from django import forms
from django.core import checks, exceptions, serializers, validators
from django.core.exceptions import FieldError
from django.core.management import call_command
from django.db import IntegrityError, connection, models
from django.db.models.expressions import RawSQL
from django.db.models.functions import Cast
from django.test import TransactionTestCase, modify_settings, override_settings
from django.test.utils import isolate_apps
from django.utils import timezone

from . import (
    PostgreSQLSimpleTestCase, PostgreSQLTestCase, PostgreSQLWidgetTestCase,
)
from .models import (
    ArrayEnumModel, ArrayFieldSubclass, CharArrayModel, DateTimeArrayModel,
    IntegerArrayModel, NestedIntegerArrayModel, NullableIntegerArrayModel,
    OtherTypesArrayModel, PostgreSQLModel, Tag,
)

try:
    from django.contrib.postgres.aggregates import ArrayAgg
    from django.contrib.postgres.fields import ArrayField
    from django.contrib.postgres.fields.array import IndexTransform, SliceTransform
    from django.contrib.postgres.forms import (
        SimpleArrayField, SplitArrayField, SplitArrayWidget,
    )
    from django.db.backends.postgresql.base import PSYCOPG2_VERSION
    from psycopg2.extras import NumericRange
except ImportError:
    pass


@isolate_apps('postgres_tests')
class BasicTests(PostgreSQLSimpleTestCase):
    def test_get_field_display(self):
        class MyModel(PostgreSQLModel):
            field = ArrayField(
                models.CharField(max_length=16),
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/postgres_tests/test_array.py\n@@\n     def test_render(self):\n         self.check_html(\n             SplitArrayWidget(forms.TextInput(), size=2), 'array', None,\n             \"\"\"\n             <input name=\"array_0\" type=\"text\">\n             <input name=\"array_1\" type=\"text\">\n             \"\"\"\n         )\n \n+    def test_get_context_does_not_mutate_attrs(self):\n+        widget = SplitArrayWidget(forms.CheckboxInput(), size=3)\n+        context = widget.get_context('name', [True, False, False])\n+        subwidgets = context['widget']['subwidgets']\n+        self.assertIs(subwidgets[0]['attrs']['checked'], True)\n+        self.assertNotIn('checked', subwidgets[1]['attrs'])\n+        self.assertNotIn('checked', subwidgets[2]['attrs'])\n+\n     def test_render_attrs(self):\n         self.check_html(\n             SplitArrayWidget(forms.TextInput(), size=2),\n             'array', ['val1', 'val2'], attrs={'id': 'foo'},\n             html=(\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/postgres_tests/test_array.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/postgres_tests/test_array.py now (1140 lines), around the change:
1112:            """
1113:        )
1114:
1115:    def test_get_context_does_not_mutate_attrs(self):
1116:        widget = SplitArrayWidget(forms.CheckboxInput(), size=3)
1117:        context = widget.get_context('name', [True, False, False])
1118:        subwidgets = context['widget']['subwidgets']
1119:        self.assertIs(subwidgets[0]['attrs']['checked'], True)
1120:        self.assertNotIn('checked', subwidgets[1]['attrs'])
1121:        self.assertNotIn('checked', subwidgets[2]['attrs'])
1122:
1123:    def test_render_attrs(self):
1124:        self.check_html(
1125:            SplitArrayWidget(forms.TextInput(), size=2),
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"attrs\\['checked'\\]\\|checked.*True\\|attrs = {\" tests/forms_tests/widget_tests/test_checkboxinput.py | head -20; grep -n \"def get_context\" -A6 django/forms/widgets.py | sed -n '1,80p'"
}
```

**tool result**

```
227:    def get_context(self, name, value, attrs):
228-        context = {}
229-        context['widget'] = {
230-            'name': name,
231-            'is_hidden': self.is_hidden,
232-            'required': self.is_required,
233-            'value': self.format_value(value),
--
292:    def get_context(self, name, value, attrs):
293-        context = super().get_context(name, value, attrs)
294-        context['widget']['type'] = self.input_type
295-        return context
296-
297-
298-class TextInput(Input):
--
326:    def get_context(self, name, value, attrs):
327-        if not self.render_value:
328-            value = None
329-        return super().get_context(name, value, attrs)
330-
331-
332-class HiddenInput(Input):
--
344:    def get_context(self, name, value, attrs):
345-        context = super().get_context(name, value, attrs)
346-        final_attrs = context['widget']['attrs']
347-        id_ = context['widget']['attrs'].get('id')
348-
349-        subwidgets = []
350-        for index, value_ in enumerate(context['widget']['value']):
--
426:    def get_context(self, name, value, attrs):
427-        context = super().get_context(name, value, attrs)
428-        checkbox_name = self.clear_checkbox_name(name)
429-        checkbox_id = self.clear_checkbox_id(checkbox_name)
430-        context['widget'].update({
431-            'checkbox_name': checkbox_name,
432-            'checkbox_id': checkbox_id,
--
523:    def get_context(self, name, value, attrs):
524-        if self.check_test(value):
525-            if attrs is None:
526-                attrs = {}
527-            attrs['checked'] = True
528-        return super().get_context(name, value, attrs)
529-
--
639:    def get_context(self, name, value, attrs):
640-        context = super().get_context(name, value, attrs)
641-        context['widget']['optgroups'] = self.optgroups(name, context['widget']['value'], attrs)
642-        return context
643-
644-    def id_for_label(self, id_, index='0'):
645-        """
--
679:    def get_context(self, name, value, attrs):
680-        context = super().get_context(name, value, attrs)
681-        if self.allow_multiple_selected:
682-            context['widget']['attrs']['multiple'] = True
683-        return context
684-
685-    @staticmethod
--
811:    def get_context(self, name, value, attrs):
812-        context = super().get_context(name, value, attrs)
813-        if self.is_localized:
814-            for widget in self.widgets:
815-                widget.is_localized = self.is_localized
816-        # value is a list of values, each corresponding to a widget
817-        # in self.widgets.
--
972:    def get_context(self, name, value, attrs):
973-        context = super().get_context(name, value, attrs)
974-        date_context = {}
975-        year_choices = [(i, str(i)) for i in self.years]
976-        if not self.is_required:
977-            year_choices.insert(0, self.year_none_value)
978-        year_name = self.year_field % name
```

**assistant → tool `read_file`**

```json
{
  "path": "django/forms/widgets.py",
  "offset": 225,
  "limit": 18
}
```

**tool result**

```
        return str(value)

    def get_context(self, name, value, attrs):
        context = {}
        context['widget'] = {
            'name': name,
            'is_hidden': self.is_hidden,
            'required': self.is_required,
            'value': self.format_value(value),
            'attrs': self.build_attrs(self.attrs, attrs),
            'template_name': self.template_name,
        }
        return context

    def render(self, name, value, attrs=None, renderer=None):
        """Render the widget as an HTML string."""
        context = self.get_context(name, value, attrs)
        return self._render(self.template_name, context, renderer)

[834 more lines in /testbed/django/forms/widgets.py (1076 in all). read_file with offset: 243 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/postgres_tests/test_array.py::TestSplitFormWidget -q 2>&1 | tail -30 || python tests/runtests.py postgres_tests.test_array.TestSplitFormWidget -v 2 2>&1 | tail -40"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py postgres_tests.test_array.TestSplitFormWidget -v 2 2>&1 | tail -50"
}
```

**tool result**

```
test_get_context (postgres_tests.test_array.TestSplitFormWidget) ... skipped 'PostgreSQL specific tests'
test_get_context_does_not_mutate_attrs (postgres_tests.test_array.TestSplitFormWidget) ... skipped 'PostgreSQL specific tests'
test_render (postgres_tests.test_array.TestSplitFormWidget) ... skipped 'PostgreSQL specific tests'
test_render_attrs (postgres_tests.test_array.TestSplitFormWidget) ... skipped 'PostgreSQL specific tests'
test_value_omitted_from_data (postgres_tests.test_array.TestSplitFormWidget) ... skipped 'PostgreSQL specific tests'

----------------------------------------------------------------------
Ran 5 tests in 0.000s

OK (skipped=5)
Testing against Django installed in '/testbed/django' with up to 8 processes
Importing application postgres_tests
Skipping setup of unused database(s): default, other.
System check identified no issues (0 silenced).
```

**assistant**

```
The root cause is `CheckboxInput.get_context()` mutating the caller's `attrs`. I'll fix it there too, so no other composite widget can hit the same bug:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/forms/widgets.py\n@@\n     def get_context(self, name, value, attrs):\n         if self.check_test(value):\n-            if attrs is None:\n-                attrs = {}\n-            attrs['checked'] = True\n+            attrs = {**(attrs or {}), 'checked': True}\n         return super().get_context(name, value, attrs)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/forms/widgets.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/forms/widgets.py now (1074 lines), around the change:
522:
523:    def get_context(self, name, value, attrs):
524:        if self.check_test(value):
525:            attrs = {**(attrs or {}), 'checked': True}
526:        return super().get_context(name, value, attrs)
527:
528:    def value_from_datadict(self, data, files, name):
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py forms_tests.widget_tests.test_checkboxinput -v 1 2>&1 | tail -15; python - <<'EOF'\nfrom django.contrib.postgres.forms import SplitArrayWidget\nfrom django import forms\nw = SplitArrayWidget(forms.CheckboxInput(), size=3)\nc = w.get_context('name', [True, False, False])\nfor s in c['widget']['subwidgets']:\n    print(s['name'], s['attrs'])\nEOF"
}
```

**tool result**

```
Command FAILED (exit status 1): `python tests/runtests.py forms_tests.widget_tests.test_checkboxinput -v 1 2>&1 | tail -15; python - <<'EOF'
from django.contrib.postgres.forms import SplitArrayWidget
from django import forms
w = SplitArrayWidget(forms.CheckboxInput(), size=3)
c = w.get_context('name', [True, False, False])
for s in c['widget']['subwidgets']:
    print(s['name'], s['attrs'])
EOF`
Output: ...........
----------------------------------------------------------------------
Ran 11 tests in 0.022s

OK
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/testbed/django/contrib/postgres/forms/__init__.py", line 4, in <module>
    from .ranges import *  # NOQA
  File "/testbed/django/contrib/postgres/forms/ranges.py", line 1, in <module>
    from psycopg2.extras import DateRange, DateTimeTZRange, NumericRange
ModuleNotFoundError: No module named 'psycopg2'

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant**

```
CheckboxInput tests pass. The postgres module can't import here (no psycopg2), so let me verify the widget behavior directly and run the broader forms tests:
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nfrom django import forms\nattrs = {'id': 'x_0'}\nc = forms.CheckboxInput().get_context('n', True, attrs)\nprint('checked:', c['widget']['attrs'].get('checked'), 'caller attrs:', attrs)\nattrs = {}\nforms.CheckboxInput().get_context('n', False, attrs)\nprint('caller attrs after False:', attrs)\nEOF\npython tests/runtests.py forms_tests.widget_tests -v 1 2>&1 | tail -6"
}
```

**tool result**

```
checked: True caller attrs: {'id': 'x_0'}
caller attrs after False: {}
System check identified no issues (0 silenced).
...........................................................................................................................................................................
----------------------------------------------------------------------
Ran 171 tests in 0.563s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "git diff -- django/contrib/postgres/forms/array.py django/forms/widgets.py tests/postgres_tests/test_array.py"
}
```

**tool result**

```
diff --git a/django/contrib/postgres/forms/array.py b/django/contrib/postgres/forms/array.py
index 2e19cd574a..fb1a836896 100644
--- a/django/contrib/postgres/forms/array.py
+++ b/django/contrib/postgres/forms/array.py
@@ -144,10 +144,11 @@ class SplitArrayWidget(forms.Widget):
                 widget_value = value[i]
             except IndexError:
                 widget_value = None
+            widget_attrs = final_attrs.copy()
             if id_:
-                final_attrs = {**final_attrs, 'id': '%s_%s' % (id_, i)}
+                widget_attrs['id'] = '%s_%s' % (id_, i)
             context['widget']['subwidgets'].append(
-                self.widget.get_context(name + '_%s' % i, widget_value, final_attrs)['widget']
+                self.widget.get_context(name + '_%s' % i, widget_value, widget_attrs)['widget']
             )
         return context
 
diff --git a/django/forms/widgets.py b/django/forms/widgets.py
index 6fe220bea7..d83d63c169 100644
--- a/django/forms/widgets.py
+++ b/django/forms/widgets.py
@@ -522,9 +522,7 @@ class CheckboxInput(Input):
 
     def get_context(self, name, value, attrs):
         if self.check_test(value):
-            if attrs is None:
-                attrs = {}
-            attrs['checked'] = True
+            attrs = {**(attrs or {}), 'checked': True}
         return super().get_context(name, value, attrs)
 
     def value_from_datadict(self, data, files, name):
diff --git a/tests/postgres_tests/test_array.py b/tests/postgres_tests/test_array.py
index 481d93f830..53a7cbb0aa 100644
--- a/tests/postgres_tests/test_array.py
+++ b/tests/postgres_tests/test_array.py
@@ -1112,6 +1112,14 @@ class TestSplitFormWidget(PostgreSQLWidgetTestCase):
             """
         )
 
+    def test_get_context_does_not_mutate_attrs(self):
+        widget = SplitArrayWidget(forms.CheckboxInput(), size=3)
+        context = widget.get_context('name', [True, False, False])
+        subwidgets = context['widget']['subwidgets']
+        self.assertIs(subwidgets[0]['attrs']['checked'], True)
+        self.assertNotIn('checked', subwidgets[1]['attrs'])
+        self.assertNotIn('checked', subwidgets[2]['attrs'])
+
     def test_render_attrs(self):
         self.check_html(
             SplitArrayWidget(forms.TextInput(), size=2),
```

**assistant**

```
Let me add a CheckboxInput test documenting the non-mutation contract:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_render_checked\\|def test_render\\|checked\" tests/forms_tests/widget_tests/test_checkboxinput.py | head -20"
}
```

**tool result**

```
9:    def test_render_empty(self):
12:    def test_render_none(self):
15:    def test_render_false(self):
18:    def test_render_true(self):
21:            html='<input checked type="checkbox" name="is_cool">'
24:    def test_render_value(self):
31:            html='<input checked type="checkbox" name="is_cool" value="foo">',
34:    def test_render_int(self):
40:            html='<input checked type="checkbox" name="is_cool" value="0">',
44:            html='<input checked type="checkbox" name="is_cool" value="1">',
47:    def test_render_check_test(self):
50:        takes the value and returns True if the box should be checked.
57:            '<input checked type="checkbox" name="greeting" value="hello">'
60:            '<input checked type="checkbox" name="greeting" value="hello there">'
63:            '<input checked type="checkbox" name="greeting" value="hello &amp; goodbye">'
66:    def test_render_check_exception(self):
81:        result for unchecked checkboxes).
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/forms_tests/widget_tests/test_checkboxinput.py",
  "offset": 1,
  "limit": 35
}
```

**tool result**

```
from django.forms import CheckboxInput

from .base import WidgetTest


class CheckboxInputTest(WidgetTest):
    widget = CheckboxInput()

    def test_render_empty(self):
        self.check_html(self.widget, 'is_cool', '', html='<input type="checkbox" name="is_cool">')

    def test_render_none(self):
        self.check_html(self.widget, 'is_cool', None, html='<input type="checkbox" name="is_cool">')

    def test_render_false(self):
        self.check_html(self.widget, 'is_cool', False, html='<input type="checkbox" name="is_cool">')

    def test_render_true(self):
        self.check_html(
            self.widget, 'is_cool', True,
            html='<input checked type="checkbox" name="is_cool">'
        )

    def test_render_value(self):
        """
        Using any value that's not in ('', None, False, True) will check the
        checkbox and set the 'value' attribute.
        """
        self.check_html(
            self.widget, 'is_cool', 'foo',
            html='<input checked type="checkbox" name="is_cool" value="foo">',
        )

    def test_render_int(self):
        """

[56 more lines in /testbed/tests/forms_tests/widget_tests/test_checkboxinput.py (91 in all). read_file with offset: 36 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/forms_tests/widget_tests/test_checkboxinput.py\n@@\n     def test_render_int(self):\n         \"\"\"\n         Using a numeric value will check the checkbox and set the 'value'\n         attribute.\n         \"\"\"\n         self.check_html(\n             self.widget, 'is_cool', 0,\n             html='<input checked type=\"checkbox\" name=\"is_cool\" value=\"0\">',\n         )\n         self.check_html(\n             self.widget, 'is_cool', 1,\n             html='<input checked type=\"checkbox\" name=\"is_cool\" value=\"1\">',\n         )\n \n+    def test_get_context_does_not_mutate_attrs(self):\n+        attrs = {'id': 'is_cool'}\n+        context = self.widget.get_context('is_cool', True, attrs)\n+        self.assertIs(context['widget']['attrs']['checked'], True)\n+        self.assertEqual(attrs, {'id': 'is_cool'})\n+\n     def test_render_check_test(self):\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/forms_tests/widget_tests/test_checkboxinput.py: failed to find expected lines in /testbed/tests/forms_tests/widget_tests/test_checkboxinput.py:
    def test_render_int(self):
        """
        Using a numeric value will check the checkbox and set the 'value'
        attribute.
        """
        self.check_html(
            self.widget, 'is_cool', 0,
            html='<input checked type="checkbox" name="is_cool" value="0">',
        )
        self.check_html(
            self.widget, 'is_cool', 1,
            html='<input checked type="checkbox" name="is_cool" value="1">',
        )

    def test_render_check_test(self):

The file's ACTUAL current content is below. Copy your context lines from THIS exact text — do not edit from memory:
1	from django.forms import CheckboxInput
2	
3	from .base import WidgetTest
4	
5	
6	class CheckboxInputTest(WidgetTest):
7	    widget = CheckboxInput()
8	
9	    def test_render_empty(self):
10	        self.check_html(self.widget, 'is_cool', '', html='<input type="checkbox" name="is_cool">')
11	
12	    def test_render_none(self):
13	        self.check_html(self.widget, 'is_cool', None, html='<input type="checkbox" name="is_cool">')
14	
15	    def test_render_false(self):
16	        self.check_html(self.widget, 'is_cool', False, html='<input type="checkbox" name="is_cool">')
17	
18	    def test_render_true(self):
19	        self.check_html(
20	            self.widget, 'is_cool', True,
21	            html='<input checked type="checkbox" name="is_cool">'
22	        )
23	
24	    def test_render_value(self):
25	        """
26	        Using any value that's not in ('', None, False, True) will check the
27	        checkbox and set the 'value' attribute.
28	        """
29	        self.check_html(
30	            self.widget, 'is_cool', 'foo',
31	            html='<input checked type="checkbox" name="is_cool" value="foo">',
32	        )
33	
34	    def test_render_int(self):
35	        """
36	        Integers are handled by value, not as booleans (#17114).
37	        """
38	        self.check_html(
39	            self.widget, 'is_cool', 0,
40	            html='<input checked type="checkbox" name="is_cool" value="0">',
41	        )
42	        self.check_html(
43	            self.widget, 'is_cool', 1,
44	            html='<input checked type="checkbox" name="is_cool" value="1">',
45	        )
46	
47	    def test_render_check_test(self):
48	        """
49	        You can pass 'check_test' to the constructor. This is a callable that
50	        takes the value and returns True if the box should be checked.
51	        """
52	        widget = CheckboxInput(check_test=lambda value: value.startswith('hello'))
53	        self.check_html(widget, 'greeting', '', html=(
54	            '<input type="checkbox" name="greeting">'
55	        ))
56	        self.check_html(widget, 'greeting', 'hello', html=(
57	            '<input checked type="checkbox" name="greeting" value="hello">'
58	        ))
59	        self.check_html(widget, 'greeting', 'hello there', html=(
60	            '<input checked type="checkbox" name="greeting" value="hello there">'
61	        ))
62	        self.check_html(widget, 'greeting', 'hello & goodbye', html=(
63	            '<input checked type="checkbox" name="greeting" value="hello &amp; goodbye">'
64	        ))
65	
66	    def test_render_check_exception(self):
67	        """
68	        Calling check_test() shouldn't swallow exceptions (#17888).
69	        """
70	        widget = CheckboxInput(
71	            check_test=lambda value: value.startswith('hello'),
72	        )
73	
74	        with self.assertRaises(AttributeError):
75	            widget.render('greeting', True)
76	
77	    def test_value_from_datadict(self):
78	        """
79	        The CheckboxInput widget will return False if the key is not found in
80	        the data dictionary (because HTML form submission doesn't send any
81	        result for unchecked checkboxes).
82	        """
83	        self.assertFalse(self.widget.value_from_datadict({}, {}, 'testing'))
84	
85	    def test_value_from_datadict_string_int(self):
86	        value = self.widget.value_from_datadict({'testing': '0'}, {}, 'testing')
87	        self.assertIs(value, True)
88	
89	    def test_value_omitted_from_data(self):
90	        self.assertIs(self.widget.value_omitted_from_data({'field': 'value'}, {}, 'field'), False)
91	        self.assertIs(self.widget.value_omitted_from_data({}, {}, 'field'), False)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/forms_tests/widget_tests/test_checkboxinput.py\n@@\n         self.check_html(\n             self.widget, 'is_cool', 1,\n             html='<input checked type=\"checkbox\" name=\"is_cool\" value=\"1\">',\n         )\n \n+    def test_get_context_does_not_mutate_attrs(self):\n+        attrs = {'id': 'is_cool'}\n+        context = self.widget.get_context('is_cool', True, attrs)\n+        self.assertIs(context['widget']['attrs']['checked'], True)\n+        self.assertEqual(attrs, {'id': 'is_cool'})\n+\n     def test_render_check_test(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/forms_tests/widget_tests/test_checkboxinput.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/forms_tests/widget_tests/test_checkboxinput.py now (97 lines), around the change:
44:            html='<input checked type="checkbox" name="is_cool" value="1">',
45:        )
46:
47:    def test_get_context_does_not_mutate_attrs(self):
48:        attrs = {'id': 'is_cool'}
49:        context = self.widget.get_context('is_cool', True, attrs)
50:        self.assertIs(context['widget']['attrs']['checked'], True)
51:        self.assertEqual(attrs, {'id': 'is_cool'})
52:
53:    def test_render_check_test(self):
54:        """
55:        You can pass 'check_test' to the constructor. This is a callable that
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py forms_tests.widget_tests forms_tests.tests.test_forms -v 1 2>&1 | tail -8"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
...............................................................................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 287 tests in 0.854s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py forms_tests -v 1 2>&1 | tail -6"
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
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py forms_tests -v 1 2>&1 | grep -E \"^(Ran|OK|FAILED|ERROR)\" | tail -5"
}
```

**tool result**

```
Ran 648 tests in 0.564s
OK (skipped=1)
```

**assistant**

````
Done. All `forms_tests` pass (648 tests, OK).

## Root cause

`CheckboxInput.get_context()` mutated the `attrs` dict it was given:

```python
if self.check_test(value):
    if attrs is None:
        attrs = {}
    attrs['checked'] = True
```

`SplitArrayWidget.get_context()` reused a single `final_attrs` dict across all subwidgets. So once the loop hit the first `True` value, `checked: True` was written into that shared dict and every subsequent subwidget inherited it, even when its own value was `False`.

## Changes

1. **`django/forms/widgets.py` — `CheckboxInput.get_context()`**: no longer mutates the caller's dict; it builds a new one (`attrs = {**(attrs or {}), 'checked': True}`). This fixes the bug at the source, so any composite widget gets correct isolation.

2. **`django/contrib/postgres/forms/array.py` — `SplitArrayWidget.get_context()`**: also made defensive by copying per iteration (`widget_attrs = final_attrs.copy()` and setting the indexed id on the copy rather than reassigning `final_attrs`). This mirrors how `MultiWidget` already handles it and protects against other widgets that might mutate attrs.

3. **Tests**:
   - `tests/postgres_tests/test_array.py::TestSplitFormWidget.test_get_context_does_not_mutate_attrs` — a `CheckboxInput` split widget with `[True, False, False]` checks only the first subwidget.
   - `tests/forms_tests/widget_tests/test_checkboxinput.py::CheckboxInputTest.test_get_context_does_not_mutate_attrs` — locks in the non-mutation contract directly.

Note: the postgres test module couldn't run in this environment (no `psycopg2` installed), so those tests skip here; the equivalent behavior was verified directly against `CheckboxInput.get_context()`, and the full non-postgres `forms_tests` suite passes.
````

## Run folder `team-solve-2026-11-06T105748`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
5c2b5096910046b971df67c59904741b4acf8dae
```

### `baseline-check.log`

```
check: python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array
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
Cloning test database for alias 'default'...
sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss...........
----------------------------------------------------------------------
Ran 120 tests in 0.133s

OK (skipped=109)
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
diff --git a/django/contrib/postgres/forms/array.py b/django/contrib/postgres/forms/array.py
index 2e19cd574a..fb1a836896 100644
--- a/django/contrib/postgres/forms/array.py
+++ b/django/contrib/postgres/forms/array.py
@@ -144,10 +144,11 @@ class SplitArrayWidget(forms.Widget):
                 widget_value = value[i]
             except IndexError:
                 widget_value = None
+            widget_attrs = final_attrs.copy()
             if id_:
-                final_attrs = {**final_attrs, 'id': '%s_%s' % (id_, i)}
+                widget_attrs['id'] = '%s_%s' % (id_, i)
             context['widget']['subwidgets'].append(
-                self.widget.get_context(name + '_%s' % i, widget_value, final_attrs)['widget']
+                self.widget.get_context(name + '_%s' % i, widget_value, widget_attrs)['widget']
             )
         return context
 
diff --git a/django/forms/widgets.py b/django/forms/widgets.py
index 6fe220bea7..d83d63c169 100644
--- a/django/forms/widgets.py
+++ b/django/forms/widgets.py
@@ -522,9 +522,7 @@ class CheckboxInput(Input):
 
     def get_context(self, name, value, attrs):
         if self.check_test(value):
-            if attrs is None:
-                attrs = {}
-            attrs['checked'] = True
+            attrs = {**(attrs or {}), 'checked': True}
         return super().get_context(name, value, attrs)
 
     def value_from_datadict(self, data, files, name):
diff --git a/tests/forms_tests/widget_tests/test_checkboxinput.py b/tests/forms_tests/widget_tests/test_checkboxinput.py
index 6483b7f211..3c4bf79a1c 100644
--- a/tests/forms_tests/widget_tests/test_checkboxinput.py
+++ b/tests/forms_tests/widget_tests/test_checkboxinput.py
@@ -44,6 +44,12 @@ class CheckboxInputTest(WidgetTest):
             html='<input checked type="checkbox" name="is_cool" value="1">',
         )
 
+    def test_get_context_does_not_mutate_attrs(self):
+        attrs = {'id': 'is_cool'}
+        context = self.widget.get_context('is_cool', True, attrs)
+        self.assertIs(context['widget']['attrs']['checked'], True)
+        self.assertEqual(attrs, {'id': 'is_cool'})
+
     def test_render_check_test(self):
         """
         You can pass 'check_test' to the constructor. This is a callable that
diff --git a/tests/postgres_tests/test_array.py b/tests/postgres_tests/test_array.py
index 481d93f830..53a7cbb0aa 100644
--- a/tests/postgres_tests/test_array.py
+++ b/tests/postgres_tests/test_array.py
@@ -1112,6 +1112,14 @@ class TestSplitFormWidget(PostgreSQLWidgetTestCase):
             """
         )
 
+    def test_get_context_does_not_mutate_attrs(self):
+        widget = SplitArrayWidget(forms.CheckboxInput(), size=3)
+        context = widget.get_context('name', [True, False, False])
+        subwidgets = context['widget']['subwidgets']
+        self.assertIs(subwidgets[0]['attrs']['checked'], True)
+        self.assertNotIn('checked', subwidgets[1]['attrs'])
+        self.assertNotIn('checked', subwidgets[2]['attrs'])
+
     def test_render_attrs(self):
         self.check_html(
             SplitArrayWidget(forms.TextInput(), size=2),
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

SplitArrayField with BooleanField always has widgets checked after the first True value.
Description
	 
		(last modified by Peter Andersen)
	 
When providing a SplitArrayField BooleanField with preexisting data, the final_attrs dict is updated to include 'checked': True after the for loop has reached the first True value in the initial data array. Once this occurs every widget initialized after that defaults to checked even though the backing data may be False. This is caused by the CheckboxInput widget's get_context() modifying the attrs dict passed into it. This is the only widget that modifies the attrs dict passed into its get_context().
CheckboxInput setting attrs['checked'] to True: ​https://github.com/django/django/blob/master/django/forms/widgets.py#L527

## Deliverable

changes to this tree

## Check

`python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array`

## Scope

`django/forms/widgets.py`
`django/contrib/postgres/forms/array.py`
`tests/forms_tests/`
`tests/postgres_tests/`

## Done when

- `CheckboxInput.get_context()` no longer writes `checked = True` into the `attrs` dict it was passed; callers that reuse that dict do not see a stale `checked` key.
- `SplitArrayField` with a `BooleanField` and initial data containing `False, True, False, ...` renders only the `True` position(s) checked; positions after the first `True` whose backing data is `False` remain unchecked.
- Checked and unchecked checkbox rendering for ordinary forms is unchanged.
- Regression tests covering both of the above pass under Django's test runner.



# plan.md

## Deliverable
changes to this tree

## Check
`python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array`

## Scope
`django/forms/widgets.py`
`django/contrib/postgres/forms/array.py`
`tests/forms_tests/`
`tests/postgres_tests/`

## Done when
- `CheckboxInput.get_context()` no longer writes `checked = True` into the `attrs` dict it was passed; callers that reuse that dict do not see a stale `checked` key.
- `SplitArrayField` with a `BooleanField` and initial data containing `False, True, False, ...` renders only the `True` position(s) checked; positions after the first `True` whose backing data is `False` remain unchecked.
- Checked and unchecked checkbox rendering for ordinary forms is unchanged.
- Regression tests covering both of the above pass under Django's test runner.

## Approach
1. Reproduce at the widget level: build a `SplitArrayField` whose `BooleanField` has initial data with a `False` after a `True`, call `get_context()`, and inspect each subwidget's `attrs` for `checked`.
2. Confirm the mutation chain: `SplitArrayField.get_context()` builds one `final_attrs` and passes it to each `widget.get_context()`; `CheckboxInput.get_context()` sets `attrs['checked'] = True` on that shared dict; the next iteration copies the polluted dict.
3. Apply the smallest correct fix, then rerun both the widget tests and the postgres array tests.
4. Add regression coverage for each behavior changed.

Candidate approaches if the first fails:
- **Fix `CheckboxInput.get_context()` (preferred):** set `checked` on `context['widget']['attrs']` rather than on the caller-supplied `attrs`. Fixes the root cause and every other widget that shares an attrs dict. Risk: subtly changes how `attrs` is reflected in the rendered context; verify existing checked/unchecked rendering and custom `check_test` behavior.
- **Fix `SplitArrayField.get_context()`:** pass a fresh copy of `base_attrs` per subwidget instead of reusing `final_attrs`. Localized and low-risk, but leaves the general footgun in `CheckboxInput` and only fixes the array case.
- **Both:** make `CheckboxInput` non-mutating and have `SplitArrayField` copy attrs per iteration. Most defensive; slightly larger diff than needed.


# django/forms/widgets.py

```
"""
HTML Widget classes
"""

import copy
import datetime
import warnings
from collections import defaultdict
from itertools import chain

from django.conf import settings
from django.forms.utils import to_current_timezone
from django.templatetags.static import static
from django.utils import datetime_safe, formats
from django.utils.datastructures import OrderedSet
from django.utils.dates import MONTHS
from django.utils.formats import get_format
from django.utils.html import format_html, html_safe
from django.utils.regex_helper import _lazy_re_compile
from django.utils.safestring import mark_safe
from django.utils.topological_sort import (
    CyclicDependencyError, stable_topological_sort,
)
from django.utils.translation import gettext_lazy as _

from .renderers import get_default_renderer

__all__ = (
    'Media', 'MediaDefiningClass', 'Widget', 'TextInput', 'NumberInput',
    'EmailInput', 'URLInput', 'PasswordInput', 'HiddenInput',
    'MultipleHiddenInput', 'FileInput', 'ClearableFileInput', 'Textarea',
    'DateInput', 'DateTimeInput', 'TimeInput', 'CheckboxInput', 'Select',
    'NullBooleanSelect', 'SelectMultiple', 'RadioSelect',
    'CheckboxSelectMultiple', 'MultiWidget', 'SplitDateTimeWidget',
    'SplitHiddenDateTimeWidget', 'SelectDateWidget',
)

MEDIA_TYPES = ('css', 'js')


class MediaOrderConflictWarning(RuntimeWarning):
    pass


@html_safe
class Media:
    def __init__(self, media=None, css=None, js=None):
        if media is not None:
            css = getattr(media, 'css', {})
            js = getattr(media, 'js', [])
        else:
            if css is None:
                css = {}
            if js is None:
                js = []
        self._css_lists = [css]
        self._js_lists = [js]

    def __repr__(self):
        return 'Media(css=%r, js=%r)' % (self._css, self._js)

    def __str__(self):
        return self.render()

    @property
    def _css(self):
        css = defaultdict(list)
        for css_list in self._css_lists:
            for medium, sublist in css_list.items():
                css[medium].append(sublist)
        return {medium: self.merge(*lists) for medium, lists in css.items()}

    @property
    def _js(self):
        return self.merge(*self._js_lists)

    def render(self):
        return mark_safe('\n'.join(chain.from_iterable(getattr(self, 'render_' + name)() for name in MEDIA_TYPES)))

    def render_js(self):
        return [
            format_html(
                '<script type="text/javascript" src="{}"></script>',
                self.absolute_path(path)
            ) for path in self._js
        ]

    def render_css(self):
        # To keep rendering order consistent, we can't just iterate over items().
        # We need to sort the keys, and iterate over the sorted list.
        media = sorted(self._css)
        return chain.from_iterable([
            format_html(
                '<link href="{}" type="text/css" media="{}" rel="stylesheet">',
                self.absolute_path(path), medium
            ) for path in self._css[medium]
        ] for medium in media)

    def absolute_path(self, path):
        """
        Given a relative or absolute path to a static asset, return an absolute
        path. An absolute path will be returned unchanged while a relative path
        will be passed to django.templatetags.static.static().
        """
        if path.startswith(('http://', 'https://', '/')):
            return path
        return static(path)

    def __getitem__(self, name):
        """Return a Media object that only contains media of the given type."""
        if name in MEDIA_TYPES:
            return Media(**{str(name): getattr(self, '_' + name)})
        raise KeyError('Unknown media type "%s"' % name)

    @staticmethod
    def merge(*lists):
        """
        Merge lists while trying to keep the relative order of the elements.
        Warn if the lists have the same elements in a different relative order.

        For static assets it can be important to have them included in the DOM
        in a certain order. In JavaScript you may not be able to reference a
        global or in CSS you might want to override a style.
        """
        dependency_graph = defaultdict(set)
        all_items = OrderedSet()
        for list_ in filter(None, lists):
            head = list_[0]
            # The first items depend on nothing but have to be part of the
            # dependency graph to be included in the result.
            dependency_graph.setdefault(head, set())
            for item in list_:
                all_items.add(item)
                # No self dependencies
                if head != item:
                    dependency_graph[item].add(head)
                head = item
        try:
            return stable_topological_sort(all_items, dependency_graph)
        except CyclicDependencyError:
            warnings.warn(
                'Detected duplicate Media files in an opposite order: {}'.format(
                    ', '.join(repr(l) for l in lists)
                ), MediaOrderConflictWarning,
            )
            return list(all_items)

    def __add__(self, other):
        combined = Media()
        combined._css_lists = self._css_lists + other._css_lists
        combined._js_lists = self._js_lists + other._js_lists
        return combined


def media_property(cls):
    def _media(self):
        # Get the media property of the superclass, if it exists
        sup_cls = super(cls, self)
        try:
            base = sup_cls.media
        except AttributeError:
            base = Media()

        # Get the media definition for this class
        definition = getattr(cls, 'Media', None)
        if definition:
            extend = getattr(definition, 'extend', True)
            if extend:
                if extend is True:
                    m = base
                else:
                    m = Media()
                    for medium in extend:
                        m = m + base[medium]
                return m + Media(definition)
            return Media(definition)
        return base
    return property(_media)


class MediaDefiningClass(type):
    """
    Metaclass for classes that can have media definitions.
    """
    def __new__(mcs, name, bases, attrs):
        new_class = super().__new__(mcs, name, bases, attrs)

        if 'media' not in attrs:
            new_class.media = media_property(new_class)

        return new_class


class Widget(metaclass=MediaDefiningClass):
    needs_multipart_form = False  # Determines does this widget need multipart form
    is_localized = False
    is_required = False
    supports_microseconds = True

    def __init__(self, attrs=None):
        self.attrs = {} if attrs is None else attrs.copy()

    def __deepcopy__(self, memo):
        obj = copy.copy(self)
        obj.attrs = self.attrs.copy()
        memo[id(self)] = obj
        return obj

    @property
    def is_hidden(self):
        return self.input_type == 'hidden' if hasattr(self, 'input_type') else False

    def subwidgets(self, name, value, attrs=None):
        context = self.get_context(name, value, attrs)
        yield context['widget']

    def format_value(self, value):
        """
        Return a value as it should appear when rendered in a template.
        """
        if value == '' or value is None:
            return None
        if self.is_localized:
            return formats.localize_input(value)
        return str(value)

    def get_context(self, name, value, attrs):
        context = {}
        context['widget'] = {
            'name': name,
            'is_hidden': self.is_hidden,
            'required': self.is_required,
            'value': self.format_value(value),
            'attrs': self.build_attrs(self.attrs, attrs),
            'template_name': self.template_name,
        }
        return context

    def render(self, name, value, attrs=None, renderer=None):
        """Render the widget as an HTML string."""
        context = self.get_context(name, value, attrs)
        return self._render(self.template_name, context, renderer)

    def _render(self, template_name, context, renderer=None):
        if renderer is None:
            renderer = get_default_renderer()
        return mark_safe(renderer.render(template_name, context))

    def build_attrs(self, base_attrs, extra_attrs=None):
        """Build an attribute dictionary."""
        return {**base_attrs, **(extra_attrs or {})}

    def value_from_datadict(self, data, files, name):
        """
        Given a dictionary of data and this widget's name, return the value
        of this widget or None if it's not provided.
        """
        return data.get(name)

    def value_omitted_from_data(self, data, files, name):
        return name not in data

    def id_for_label(self, id_):
        """
        Return the HTML ID attribute of this Widget for use by a <label>,
        given the ID of the field. Return None if no ID is available.

        This hook is necessary because some widgets have multiple HTML
        elements and, thus, multiple IDs. In that case, this method should
        return an ID value that corresponds to the first ID in the widget's
        tags.
        """
        return id_

    def use_required_attribute(self, initial):
        return not self.is_hidden


class Input(Widget):
    """
    Base class for all <input> widgets.
    """
    input_type = None  # Subclasses must define this.
    template_name = 'django/forms/widgets/input.html'

    def __init__(self, attrs=None):
        if attrs is not None:
            attrs = attrs.copy()
            self.input_type = attrs.pop('type', self.input_type)
        super().__init__(attrs)

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        context['widget']['type'] = self.input_type
        return context


class TextInput(Input):
    input_type = 'text'
    template_name = 'django/forms/widgets/text.html'


class NumberInput(Input):
    input_type = 'number'
    template_name = 'django/forms/widgets/number.html'


class EmailInput(Input):
    input_type = 'email'
    template_name = 'django/forms/widgets/email.html'


class URLInput(Input):
    input_type = 'url'
    template_name = 'django/forms/widgets/url.html'


class PasswordInput(Input):
    input_type = 'password'
    template_name = 'django/forms/widgets/password.html'

    def __init__(self, attrs=None, render_value=False):
        super().__init__(attrs)
        self.render_value = render_value

    def get_context(self, name, value, attrs):
        if not self.render_value:
            value = None
        return super().get_context(name, value, attrs)


class HiddenInput(Input):
    input_type = 'hidden'
    template_name = 'django/forms/widgets/hidden.html'


class MultipleHiddenInput(HiddenInput):
    """
    Handle <input type="hidden"> for fields that have a list
    of values.
    """
    template_name = 'django/forms/widgets/multiple_hidden.html'

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        final_attrs = context['widget']['attrs']
        id_ = context['widget']['attrs'].get('id')

        subwidgets = []
        for index, value_ in enumerate(context['widget']['value']):
            widget_attrs = final_attrs.copy()
            if id_:
                # An ID attribute was given. Add a numeric index as a suffix
                # so that the inputs don't all have the same ID attribute.
                widget_attrs['id'] = '%s_%s' % (id_, index)
            widget = HiddenInput()
            widget.is_required = self.is_required
            subwidgets.append(widget.get_context(name, value_, widget_attrs)['widget'])

        context['widget']['subwidgets'] = subwidgets
        return context

    def value_from_datadict(self, data, files, name):
        try:
            getter = data.getlist
        except AttributeError:
            getter = data.get
        return getter(name)

    def format_value(self, value):
        return [] if value is None else value


class FileInput(Input):
    input_type = 'file'
    needs_multipart_form = True
    template_name = 'django/forms/widgets/file.html'

    def format_value(self, value):
        """File input never renders a value."""
        return

    def value_from_datadict(self, data, files, name):
        "File widgets take data from FILES, not POST"
        return files.get(name)

    def value_omitted_from_data(self, data, files, name):
        return name not in files


FILE_INPUT_CONTRADICTION = object()


class ClearableFileInput(FileInput):
    clear_checkbox_label = _('Clear')
    initial_text = _('Currently')
    input_text = _('Change')
    template_name = 'django/forms/widgets/clearable_file_input.html'

    def clear_checkbox_name(self, name):
        """
        Given the name of the file input, return the name of the clear checkbox
        input.
        """
        return name + '-clear'

    def clear_checkbox_id(self, name):
        """
        Given the name of the clear checkbox input, return the HTML id for it.
        """
        return name + '_id'

    def is_initial(self, value):
        """
        Return whether value is considered to be initial value.
        """
        return bool(value and getattr(value, 'url', False))

    def format_value(self, value):
        """
        Return the file object if it has a defined url attribute.
        """
        if self.is_initial(value):
            return value

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        checkbox_name = self.clear_checkbox_name(name)
        checkbox_id = self.clear_checkbox_id(checkbox_name)
        context['widget'].update({
            'checkbox_name': checkbox_name,
            'checkbox_id': checkbox_id,
            'is_initial': self.is_initial(value),
            'input_text': self.input_text,
            'initial_text': self.initial_text,
            'clear_checkbox_label': self.clear_checkbox_label,
        })
        return context

    def value_from_datadict(self, data, files, name):
        upload = super().value_from_datadict(data, files, name)
        if not self.is_required and CheckboxInput().value_from_datadict(
                data, files, self.clear_checkbox_name(name)):

            if upload:
                # If the user contradicts themselves (uploads a new file AND
                # checks the "clear" checkbox), we return a unique marker
                # object that FileField will turn into a ValidationError.
                return FILE_INPUT_CONTRADICTION
            # False signals to clear any existing value, as opposed to just None
            return False
        return upload

    def use_required_attribute(self, initial):
        return super().use_required_attribute(initial) and not initial

    def value_omitted_from_data(self, data, files, name):
        return (
            super().value_omitted_from_data(data, files, name) and
            self.clear_checkbox_name(name) not in data
        )


class Textarea(Widget):
    template_name = 'django/forms/widgets/textarea.html'

    def __init__(self, attrs=None):
        # Use slightly better defaults than HTML's 20x2 box
        default_attrs = {'cols': '40', 'rows': '10'}
        if attrs:
            default_attrs.update(attrs)
        super().__init__(default_attrs)


class DateTimeBaseInput(TextInput):
    format_key = ''
    supports_microseconds = False

    def __init__(self, attrs=None, format=None):
        super().__init__(attrs)
        self.format = format or None

    def format_value(self, value):
        return formats.localize_input(value, self.format or formats.get_format(self.format_key)[0])


class DateInput(DateTimeBaseInput):
    format_key = 'DATE_INPUT_FORMATS'
    template_name = 'django/forms/widgets/date.html'


class DateTimeInput(DateTimeBaseInput):
    format_key = 'DATETIME_INPUT_FORMATS'
    template_name = 'django/forms/widgets/datetime.html'


class TimeInput(DateTimeBaseInput):
    format_key = 'TIME_INPUT_FORMATS'
    template_name = 'django/forms/widgets/time.html'


# Defined at module level so that CheckboxInput is picklable (#17976)
def boolean_check(v):
    return not (v is False or v is None or v == '')


class CheckboxInput(Input):
    input_type = 'checkbox'
    template_name = 'django/forms/widgets/checkbox.html'

    def __init__(self, attrs=None, check_test=None):
        super().__init__(attrs)
        # check_test is a callable that takes a value and returns True
        # if the checkbox should be checked for that value.
        self.check_test = boolean_check if check_test is None else check_test

    def format_value(self, value):
        """Only return the 'value' attribute if value isn't empty."""
        if value is True or value is False or value is None or value == '':
            return
        return str(value)

    def get_context(self, name, value, attrs):
        if self.check_test(value):
            if attrs is None:
                attrs = {}
            attrs['checked'] = True
        return super().get_context(name, value, attrs)

    def value_from_datadict(self, data, files, name):
        if name not in data:
            # A missing value means False because HTML form submission does not
            # send results for unselected checkboxes.
            return False
        value = data.get(name)
        # Translate true and false strings to boolean values.
        values = {'true': True, 'false': False}
        if isinstance(value, str):
            value = values.get(value.lower(), value)
        return bool(value)

    def value_omitted_from_data(self, data, files, name):
        # HTML checkboxes don't appear in POST data if not checked, so it's
        # never known if the value is actually omitted.
        return False


class ChoiceWidget(Widget):
    allow_multiple_selected = False
    input_type = None
    template_name = None
    option_template_name = None
    add_id_index = True
    checked_attribute = {'checked': True}
    option_inherits_attrs = True

    def __init__(self, attrs=None, choices=()):
        super().__init__(attrs)
        # choices can be any iterable, but we may need to render this widget
        # multiple times. Thus, collapse it into a list so it can be consumed
        # more than once.
        self.choices = list(choices)

    def __deepcopy__(self, memo):
        obj = copy.copy(self)
        obj.attrs = self.attrs.copy()
        obj.choices = copy.copy(self.choices)
        memo[id(self)] = obj
        return obj

    def subwidgets(self, name, value, attrs=None):
        """
        Yield all "subwidgets" of this widget. Used to enable iterating
        options from a BoundField for choice widgets.
        """
        value = self.format_value(value)
        yield from self.options(name, value, attrs)

    def options(self, name, value, attrs=None):
        """Yield a flat list of options for this widgets."""
        for group in self.optgroups(name, value, attrs):
            yield from group[1]

    def optgroups(self, name, value, attrs=None):
        """Return a list of optgroups for this widget."""
        groups = []
        has_selected = False

        for index, (option_value, option_label) in enumerate(self.choices):
            if option_value is None:
                option_value = ''

            subgroup = []
            if isinstance(option_label, (list, tuple)):
                group_name = option_value
                subindex = 0
                choices = option_label
            else:
                group_name = None
                subindex = None
                choices = [(option_value, option_label)]
            groups.append((group_name, subgroup, index))

            for subvalue, sublabel in choices:
                selected = (
                    str(subvalue) in value and
                    (not has_selected or self.allow_multiple_selected)
                )
                has_selected |= selected
                subgroup.append(self.create_option(
                    name, subvalue, sublabel, selected, index,
                    subindex=subindex, attrs=attrs,
                ))
                if subindex is not None:
                    subindex += 1
        return groups

    def create_option(self, name, value, label, selected, index, subindex=None, attrs=None):
        index = str(index) if subindex is None else "%s_%s" % (index, subindex)
        if attrs is None:
            attrs = {}
        option_attrs = self.build_attrs(self.attrs, attrs) if self.option_inherits_attrs else {}
        if selected:
            option_attrs.update(self.checked_attribute)
        if 'id' in option_attrs:
            option_attrs['id'] = self.id_for_label(option_attrs['id'], index)
        return {
            'name': name,
            'value': value,
            'label': label,
            'selected': selected,
            'index': index,
            'attrs': option_attrs,
            'type': self.input_type,
            'template_name': self.option_template_name,
            'wrap_label': True,
        }

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        context['widget']['optgroups'] = self.optgroups(name, context['widget']['value'], attrs)
        return context

    def id_for_label(self, id_, index='0'):
        """
        Use an incremented id for each option where the main widget
        references the zero index.
        """
        if id_ and self.add_id_index:
            id_ = '%s_%s' % (id_, index)
        return id_

    def value_from_datadict(self, data, files, name):
        getter = data.get
        if self.allow_multiple_selected:
            try:
                getter = data.getlist
            except AttributeError:
                pass
        return getter(name)

    def format_value(self, value):
        """Return selected values as a list."""
        if value is None and self.allow_multiple_selected:
            return []
        if not isinstance(value, (tuple, list)):
            value = [value]
        return [str(v) if v is not None else '' for v in value]


class Select(ChoiceWidget):
    input_type = 'select'
    template_name = 'django/forms/widgets/select.html'
    option_template_name = 'django/forms/widgets/select_option.html'
    add_id_index = False
    checked_attribute = {'selected': True}
    option_inherits_attrs = False

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        if self.allow_multiple_selected:
            context['widget']['attrs']['multiple'] = True
        return context

    @staticmethod
    def _choice_has_empty_value(choice):
        """Return True if the choice's value is empty string or None."""
        value, _ = choice
        return value is None or value == ''

    def use_required_attribute(self, initial):
        """
        Don't render 'required' if the first <option> has a value, as that's
        invalid HTML.
        """
        use_required_attribute = super().use_required_attribute(initial)
        # 'required' is always okay for <select multiple>.
        if self.allow_multiple_selected:
            return use_required_attribute

        first_choice = next(iter(self.choices), None)
        return use_required_attribute and first_choice is not None and self._choice_has_empty_value(first_choice)


class NullBooleanSelect(Select):
    """
    A Select Widget intended to be used with NullBooleanField.
    """
    def __init__(self, attrs=None):
        choices = (
            ('unknown', _('Unknown')),
            ('true', _('Yes')),
            ('false', _('No')),
        )
        super().__init__(attrs, choices)

    def format_value(self, value):
        try:
            return {
                True: 'true', False: 'false',
                'true': 'true', 'false': 'false',
                # For backwards compatibility with Django < 2.2.
                '2': 'true', '3': 'false',
            }[value]
        except KeyError:
            return 'unknown'

    def value_from_datadict(self, data, files, name):
        value = data.get(name)
        return {
            True: True,
            'True': True,
            'False': False,
            False: False,
            'true': True,
            'false': False,
            # For backwards compatibility with Django < 2.2.
            '2': True,
            '3': False,
        }.get(value)


class SelectMultiple(Select):
    allow_multiple_selected = True

    def value_from_datadict(self, data, files, name):
        try:
            getter = data.getlist
        except AttributeError:
            getter = data.get
        return getter(name)

    def value_omitted_from_data(self, data, files, name):
        # An unselected <select multiple> doesn't appear in POST data, so it's
        # never known if the value is actually omitted.
        return False


class RadioSelect(ChoiceWidget):
    input_type = 'radio'
    template_name = 'django/forms/widgets/radio.html'
    option_template_name = 'django/forms/widgets/radio_option.html'


class CheckboxSelectMultiple(ChoiceWidget):
    allow_multiple_selected = True
    input_type = 'checkbox'
    template_name = 'django/forms/widgets/checkbox_select.html'
    option_template_name = 'django/forms/widgets/checkbox_option.html'

    def use_required_attribute(self, initial):
        # Don't use the 'required' attribute because browser validation would
        # require all checkboxes to be checked instead of at least one.
        return False

    def value_omitted_from_data(self, data, files, name):
        # HTML checkboxes don't appear in POST data if not checked, so it's
        # never known if the value is actually omitted.
        return False

    def id_for_label(self, id_, index=None):
        """"
        Don't include for="field_0" in <label> because clicking such a label
        would toggle the first checkbox.
        """
        if index is None:
            return ''
        return super().id_for_label(id_, index)


class MultiWidget(Widget):
    """
    A widget that is composed of multiple widgets.

    In addition to the values added by Widget.get_context(), this widget
    adds a list of subwidgets to the context as widget['subwidgets'].
    These can be looped over and rendered like normal widgets.

    You'll probably want to use this class with MultiValueField.
    """
    template_name = 'django/forms/widgets/multiwidget.html'

    def __init__(self, widgets, attrs=None):
        self.widgets = [w() if isinstance(w, type) else w for w in widgets]
        super().__init__(attrs)

    @property
    def is_hidden(self):
        return all(w.is_hidden for w in self.widgets)

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        if self.is_localized:
            for widget in self.widgets:
                widget.is_localized = self.is_localized
        # value is a list of values, each corresponding to a widget
        # in self.widgets.
        if not isinstance(value, list):
            value = self.decompress(value)

        final_attrs = context['widget']['attrs']
        input_type = final_attrs.pop('type', None)
        id_ = final_attrs.get('id')
        subwidgets = []
        for i, widget in enumerate(self.widgets):
            if input_type is not None:
                widget.input_type = input_type
            widget_name = '%s_%s' % (name, i)
            try:
                widget_value = value[i]
            except IndexError:
                widget_value = None
            if id_:
                widget_attrs = final_attrs.copy()
                widget_attrs['id'] = '%s_%s' % (id_, i)
            else:
                widget_attrs = final_attrs
            subwidgets.append(widget.get_context(widget_name, widget_value, widget_attrs)['widget'])
        context['widget']['subwidgets'] = subwidgets
        return context

    def id_for_label(self, id_):
        if id_:
            id_ += '_0'
        return id_

    def value_from_datadict(self, data, files, name):
        return [widget.value_from_datadict(data, files, name + '_%s' % i) for i, widget in enumerate(self.widgets)]

    def value_omitted_from_data(self, data, files, name):
        return all(
            widget.value_omitted_from_data(data, files, name + '_%s' % i)
            for i, widget in enumerate(self.widgets)
        )

    def decompress(self, value):
        """
        Return a list of decompressed values for the given compressed value.
        The given value can be assumed to be valid, but not necessarily
        non-empty.
        """
        raise NotImplementedError('Subclasses must implement this method.')

    def _get_media(self):
        """
        Media for a multiwidget is the combination of all media of the
        subwidgets.
        """
        media = Media()
        for w in self.widgets:
            media = media + w.media
        return media
    media = property(_get_media)

    def __deepcopy__(self, memo):
        obj = super().__deepcopy__(memo)
        obj.widgets = copy.deepcopy(self.widgets)
        return obj

    @property
    def needs_multipart_form(self):
        return any(w.needs_multipart_form for w in self.widgets)


class SplitDateTimeWidget(MultiWidget):
    """
    A widget that splits datetime input into two <input type="text"> boxes.
    """
    supports_microseconds = False
    template_name = 'django/forms/widgets/splitdatetime.html'

    def __init__(self, attrs=None, date_format=None, time_format=None, date_attrs=None, time_attrs=None):
        widgets = (
            DateInput(
                attrs=attrs if date_attrs is None else date_attrs,
                format=date_format,
            ),
            TimeInput(
                attrs=attrs if time_attrs is None else time_attrs,
                format=time_format,
            ),
        )
        super().__init__(widgets)

    def decompress(self, value):
        if value:
            value = to_current_timezone(value)
            return [value.date(), value.time()]
        return [None, None]


class SplitHiddenDateTimeWidget(SplitDateTimeWidget):
    """
    A widget that splits datetime input into two <input type="hidden"> inputs.
    """
    template_name = 'django/forms/widgets/splithiddendatetime.html'

    def __init__(self, attrs=None, date_format=None, time_format=None, date_attrs=None, time_attrs=None):
        super().__init__(attrs, date_format, time_format, date_attrs, time_attrs)
        for widget in self.widgets:
            widget.input_type = 'hidden'


class SelectDateWidget(Widget):
    """
    A widget that splits date input into three <select> boxes.

    This also serves as an example of a Widget that has more than one HTML
    element and hence implements value_from_datadict.
    """
    none_value = ('', '---')
    month_field = '%s_month'
    day_field = '%s_day'
    year_field = '%s_year'
    template_name = 'django/forms/widgets/select_date.html'
    input_type = 'select'
    select_widget = Select
    date_re = _lazy_re_compile(r'(\d{4}|0)-(\d\d?)-(\d\d?)$')

    def __init__(self, attrs=None, years=None, months=None, empty_label=None):
        self.attrs = attrs or {}

        # Optional list or tuple of years to use in the "year" select box.
        if years:
            self.years = years
        else:
            this_year = datetime.date.today().year
            self.years = range(this_year, this_year + 10)

        # Optional dict of months to use in the "month" select box.
        if months:
            self.months = months
        else:
            self.months = MONTHS

        # Optional string, list, or tuple to use as empty_label.
        if isinstance(empty_label, (list, tuple)):
            if not len(empty_label) == 3:
                raise ValueError('empty_label list/tuple must have 3 elements.')

            self.year_none_value = ('', empty_label[0])
            self.month_none_value = ('', empty_label[1])
            self.day_none_value = ('', empty_label[2])
        else:
            if empty_label is not None:
                self.none_value = ('', empty_label)

            self.year_none_value = self.none_value
            self.month_none_value = self.none_value
            self.day_none_value = self.none_value

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        date_context = {}
        year_choices = [(i, str(i)) for i in self.years]
        if not self.is_required:
            year_choices.insert(0, self.year_none_value)
        year_name = self.year_field % name
        date_context['year'] = self.select_widget(attrs, choices=year_choices).get_context(
            name=year_name,
            value=context['widget']['value']['year'],
            attrs={**context['widget']['attrs'], 'id': 'id_%s' % year_name},
        )
        month_choices = list(self.months.items())
        if not self.is_required:
            month_choices.insert(0, self.month_none_value)
        month_name = self.month_field % name
        date_context['month'] = self.select_widget(attrs, choices=month_choices).get_context(
            name=month_name,
            value=context['widget']['value']['month'],
            attrs={**context['widget']['attrs'], 'id': 'id_%s' % month_name},
        )
        day_choices = [(i, i) for i in range(1, 32)]
        if not self.is_required:
            day_choices.insert(0, self.day_none_value)
        day_name = self.day_field % name
        date_context['day'] = self.select_widget(attrs, choices=day_choices,).get_context(
            name=day_name,
            value=context['widget']['value']['day'],
            attrs={**context['widget']['attrs'], 'id': 'id_%s' % day_name},
        )
        subwidgets = []
        for field in self._parse_date_fmt():
            subwidgets.append(date_context[field]['widget'])
        context['widget']['subwidgets'] = subwidgets
        return context

    def format_value(self, value):
        """
        Return a dict containing the year, month, and day of the current value.
        Use dict instead of a datetime to allow invalid dates such as February
        31 to display correctly.
        """
        year, month, day = None, None, None
        if isinstance(value, (datetime.date, datetime.datetime)):
            year, month, day = value.year, value.month, value.day
        elif isinstance(value, str):
            match = self.date_re.match(value)
            if match:
                # Convert any zeros in the date to empty strings to match the
                # empty option value.
                year, month, day = [int(val) or '' for val in match.groups()]
            elif settings.USE_L10N:
                input_format = get_format('DATE_INPUT_FORMATS')[0]
                try:
                    d = datetime.datetime.strptime(value, input_format)
                except ValueError:
                    pass
                else:
                    year, month, day = d.year, d.month, d.day
        return {'year': year, 'month': month, 'day': day}

    @staticmethod
    def _parse_date_fmt():
        fmt = get_format('DATE_FORMAT')
        escaped = False
        for char in fmt:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char in 'Yy':
                yield 'year'
            elif char in 'bEFMmNn':
                yield 'month'
            elif char in 'dj':
                yield 'day'

    def id_for_label(self, id_):
        for first_select in self._parse_date_fmt():
            return '%s_%s' % (id_, first_select)
        return '%s_month' % id_

    def value_from_datadict(self, data, files, name):
        y = data.get(self.year_field % name)
        m = data.get(self.month_field % name)
        d = data.get(self.day_field % name)
        if y == m == d == '':
            return None
        if y is not None and m is not None and d is not None:
            input_format = get_format('DATE_INPUT_FORMATS')[0]
            try:
                date_value = datetime.date(int(y), int(m), int(d))
            except ValueError:
                # Return pseudo-ISO dates with zeros for any unselected values,
                # e.g. '2017-0-23'.
                return '%s-%s-%s' % (y or 0, m or 0, d or 0)
            date_value = datetime_safe.new_date(date_value)
            return date_value.strftime(input_format)
        return data.get(name)

    def value_omitted_from_data(self, data, files, name):
        return not any(
            ('{}_{}'.format(name, interval) in data)
            for interval in ('year', 'month', 'day')
        )

```


# django/contrib/postgres/forms/array.py

```
import copy
from itertools import chain

from django import forms
from django.contrib.postgres.validators import (
    ArrayMaxLengthValidator, ArrayMinLengthValidator,
)
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

from ..utils import prefix_validation_error


class SimpleArrayField(forms.CharField):
    default_error_messages = {
        'item_invalid': _('Item %(nth)s in the array did not validate:'),
    }

    def __init__(self, base_field, *, delimiter=',', max_length=None, min_length=None, **kwargs):
        self.base_field = base_field
        self.delimiter = delimiter
        super().__init__(**kwargs)
        if min_length is not None:
            self.min_length = min_length
            self.validators.append(ArrayMinLengthValidator(int(min_length)))
        if max_length is not None:
            self.max_length = max_length
            self.validators.append(ArrayMaxLengthValidator(int(max_length)))

    def clean(self, value):
        value = super().clean(value)
        return [self.base_field.clean(val) for val in value]

    def prepare_value(self, value):
        if isinstance(value, list):
            return self.delimiter.join(str(self.base_field.prepare_value(v)) for v in value)
        return value

    def to_python(self, value):
        if isinstance(value, list):
            items = value
        elif value:
            items = value.split(self.delimiter)
        else:
            items = []
        errors = []
        values = []
        for index, item in enumerate(items):
            try:
                values.append(self.base_field.to_python(item))
            except ValidationError as error:
                errors.append(prefix_validation_error(
                    error,
                    prefix=self.error_messages['item_invalid'],
                    code='item_invalid',
                    params={'nth': index + 1},
                ))
        if errors:
            raise ValidationError(errors)
        return values

    def validate(self, value):
        super().validate(value)
        errors = []
        for index, item in enumerate(value):
            try:
                self.base_field.validate(item)
            except ValidationError as error:
                errors.append(prefix_validation_error(
                    error,
                    prefix=self.error_messages['item_invalid'],
                    code='item_invalid',
                    params={'nth': index + 1},
                ))
        if errors:
            raise ValidationError(errors)

    def run_validators(self, value):
        super().run_validators(value)
        errors = []
        for index, item in enumerate(value):
            try:
                self.base_field.run_validators(item)
            except ValidationError as error:
                errors.append(prefix_validation_error(
                    error,
                    prefix=self.error_messages['item_invalid'],
                    code='item_invalid',
                    params={'nth': index + 1},
                ))
        if errors:
            raise ValidationError(errors)

    def has_changed(self, initial, data):
        try:
            value = self.to_python(data)
        except ValidationError:
            pass
        else:
            if initial in self.empty_values and value in self.empty_values:
                return False
        return super().has_changed(initial, data)


class SplitArrayWidget(forms.Widget):
    template_name = 'postgres/widgets/split_array.html'

    def __init__(self, widget, size, **kwargs):
        self.widget = widget() if isinstance(widget, type) else widget
        self.size = size
        super().__init__(**kwargs)

    @property
    def is_hidden(self):
        return self.widget.is_hidden

    def value_from_datadict(self, data, files, name):
        return [self.widget.value_from_datadict(data, files, '%s_%s' % (name, index))
                for index in range(self.size)]

    def value_omitted_from_data(self, data, files, name):
        return all(
            self.widget.value_omitted_from_data(data, files, '%s_%s' % (name, index))
            for index in range(self.size)
        )

    def id_for_label(self, id_):
        # See the comment for RadioSelect.id_for_label()
        if id_:
            id_ += '_0'
        return id_

    def get_context(self, name, value, attrs=None):
        attrs = {} if attrs is None else attrs
        context = super().get_context(name, value, attrs)
        if self.is_localized:
            self.widget.is_localized = self.is_localized
        value = value or []
        context['widget']['subwidgets'] = []
        final_attrs = self.build_attrs(attrs)
        id_ = final_attrs.get('id')
        for i in range(max(len(value), self.size)):
            try:
                widget_value = value[i]
            except IndexError:
                widget_value = None
            widget_attrs = final_attrs.copy()
            if id_:
                widget_attrs['id'] = '%s_%s' % (id_, i)
            context['widget']['subwidgets'].append(
                self.widget.get_context(name + '_%s' % i, widget_value, widget_attrs)['widget']
            )
        return context

    @property
    def media(self):
        return self.widget.media

    def __deepcopy__(self, memo):
        obj = super().__deepcopy__(memo)
        obj.widget = copy.deepcopy(self.widget)
        return obj

    @property
    def needs_multipart_form(self):
        return self.widget.needs_multipart_form


class SplitArrayField(forms.Field):
    default_error_messages = {
        'item_invalid': _('Item %(nth)s in the array did not validate:'),
    }

    def __init__(self, base_field, size, *, remove_trailing_nulls=False, **kwargs):
        self.base_field = base_field
        self.size = size
        self.remove_trailing_nulls = remove_trailing_nulls
        widget = SplitArrayWidget(widget=base_field.widget, size=size)
        kwargs.setdefault('widget', widget)
        super().__init__(**kwargs)

    def _remove_trailing_nulls(self, values):
        index = None
        if self.remove_trailing_nulls:
            for i, value in reversed(list(enumerate(values))):
                if value in self.base_field.empty_values:
                    index = i
                else:
                    break
            if index is not None:
                values = values[:index]
        return values, index

    def to_python(self, value):
        value = super().to_python(value)
        return [self.base_field.to_python(item) for item in value]

    def clean(self, value):
        cleaned_data = []
        errors = []
        if not any(value) and self.required:
            raise ValidationError(self.error_messages['required'])
        max_size = max(self.size, len(value))
        for index in range(max_size):
            item = value[index]
            try:
                cleaned_data.append(self.base_field.clean(item))
            except ValidationError as error:
                errors.append(prefix_validation_error(
                    error,
                    self.error_messages['item_invalid'],
                    code='item_invalid',
                    params={'nth': index + 1},
                ))
                cleaned_data.append(None)
            else:
                errors.append(None)
        cleaned_data, null_index = self._remove_trailing_nulls(cleaned_data)
        if null_index is not None:
            errors = errors[:null_index]
        errors = list(filter(None, errors))
        if errors:
            raise ValidationError(list(chain.from_iterable(errors)))
        return cleaned_data

    def has_changed(self, initial, data):
        try:
            data = self.to_python(data)
        except ValidationError:
            pass
        else:
            data, _ = self._remove_trailing_nulls(data)
            if initial in self.empty_values and data in self.empty_values:
                return False
        return super().has_changed(initial, data)

```


# tests/forms_tests (the files in it)

tests/forms_tests/__init__.py
tests/forms_tests/field_tests/__init__.py
tests/forms_tests/field_tests/filepathfield_test_dir/README
tests/forms_tests/field_tests/filepathfield_test_dir/__init__.py
tests/forms_tests/field_tests/filepathfield_test_dir/a.py
tests/forms_tests/field_tests/filepathfield_test_dir/ab.py
tests/forms_tests/field_tests/filepathfield_test_dir/b.py
tests/forms_tests/field_tests/filepathfield_test_dir/c/__init__.py
tests/forms_tests/field_tests/filepathfield_test_dir/c/d.py
tests/forms_tests/field_tests/filepathfield_test_dir/c/e.py
tests/forms_tests/field_tests/filepathfield_test_dir/c/f/__init__.py
tests/forms_tests/field_tests/filepathfield_test_dir/c/f/g.py
tests/forms_tests/field_tests/filepathfield_test_dir/h/__init__.py
tests/forms_tests/field_tests/filepathfield_test_dir/j/__init__.py
tests/forms_tests/field_tests/test_base.py
tests/forms_tests/field_tests/test_booleanfield.py
tests/forms_tests/field_tests/test_charfield.py
tests/forms_tests/field_tests/test_choicefield.py
tests/forms_tests/field_tests/test_combofield.py
tests/forms_tests/field_tests/test_datefield.py
tests/forms_tests/field_tests/test_datetimefield.py
tests/forms_tests/field_tests/test_decimalfield.py
tests/forms_tests/field_tests/test_durationfield.py
tests/forms_tests/field_tests/test_emailfield.py
tests/forms_tests/field_tests/test_filefield.py
tests/forms_tests/field_tests/test_filepathfield.py
tests/forms_tests/field_tests/test_floatfield.py
tests/forms_tests/field_tests/test_genericipaddressfield.py
tests/forms_tests/field_tests/test_imagefield.py
tests/forms_tests/field_tests/test_integerfield.py
tests/forms_tests/field_tests/test_multiplechoicefield.py
tests/forms_tests/field_tests/test_multivaluefield.py
tests/forms_tests/field_tests/test_nullbooleanfield.py
tests/forms_tests/field_tests/test_regexfield.py
tests/forms_tests/field_tests/test_slugfield.py
tests/forms_tests/field_tests/test_splitdatetimefield.py
tests/forms_tests/field_tests/test_timefield.py
tests/forms_tests/field_tests/test_typedchoicefield.py
tests/forms_tests/field_tests/test_typedmultiplechoicefield.py
tests/forms_tests/field_tests/test_urlfield.py
tests/forms_tests/field_tests/test_uuidfield.py
tests/forms_tests/jinja2/forms_tests/custom_widget.html
tests/forms_tests/models.py
tests/forms_tests/templates/forms_tests/article_form.html
tests/forms_tests/templates/forms_tests/custom_widget.html
tests/forms_tests/tests/__init__.py
tests/forms_tests/tests/filepath_test_files/.dot-file
tests/forms_tests/tests/filepath_test_files/1x1.bmp
tests/forms_tests/tests/filepath_test_files/1x1.png
tests/forms_tests/tests/filepath_test_files/directory/.keep
tests/forms_tests/tests/filepath_test_files/fake-image.jpg
tests/forms_tests/tests/filepath_test_files/real-text-file.txt
tests/forms_tests/tests/test_error_messages.py
tests/forms_tests/tests/test_forms.py
tests/forms_tests/tests/test_formsets.py
tests/forms_tests/tests/test_i18n.py
tests/forms_tests/tests/test_input_formats.py
tests/forms_tests/tests/test_media.py
tests/forms_tests/tests/test_renderers.py
tests/forms_tests/tests/test_utils.py
tests/forms_tests/tests/test_validators.py
tests/forms_tests/tests/test_widgets.py
tests/forms_tests/tests/tests.py
tests/forms_tests/urls.py
tests/forms_tests/views.py
tests/forms_tests/widget_tests/__init__.py
tests/forms_tests/widget_tests/base.py
tests/forms_tests/widget_tests/test_checkboxinput.py
tests/forms_tests/widget_tests/test_checkboxselectmultiple.py
tests/forms_tests/widget_tests/test_clearablefileinput.py
tests/forms_tests/widget_tests/test_dateinput.py
tests/forms_tests/widget_tests/test_datetimeinput.py
tests/forms_tests/widget_tests/test_fileinput.py
tests/forms_tests/widget_tests/test_hiddeninput.py
tests/forms_tests/widget_tests/test_input.py
tests/forms_tests/widget_tests/test_multiplehiddeninput.py
tests/forms_tests/widget_tests/test_multiwidget.py
tests/forms_tests/widget_tests/test_nullbooleanselect.py
tests/forms_tests/widget_tests/test_numberinput.py
tests/forms_tests/widget_tests/test_passwordinput.py
tests/forms_tests/widget_tests/test_radioselect.py
tests/forms_tests/widget_tests/test_select.py
tests/forms_tests/widget_tests/test_selectdatewidget.py
tests/forms_tests/widget_tests/test_selectmultiple.py
tests/forms_tests/widget_tests/test_splitdatetimewidget.py
tests/forms_tests/widget_tests/test_splithiddendatetimewidget.py
tests/forms_tests/widget_tests/test_textarea.py
tests/forms_tests/widget_tests/test_textinput.py
tests/forms_tests/widget_tests/test_timeinput.py
tests/forms_tests/widget_tests/test_widget.py


# tests/postgres_tests (the files in it)

tests/postgres_tests/__init__.py
tests/postgres_tests/array_default_migrations/0001_initial.py
tests/postgres_tests/array_default_migrations/0002_integerarraymodel_field_2.py
tests/postgres_tests/array_default_migrations/__init__.py
tests/postgres_tests/array_index_migrations/0001_initial.py
tests/postgres_tests/array_index_migrations/__init__.py
tests/postgres_tests/fields.py
tests/postgres_tests/integration_settings.py
tests/postgres_tests/migrations/0001_setup_extensions.py
tests/postgres_tests/migrations/0002_create_test_models.py
tests/postgres_tests/migrations/__init__.py
tests/postgres_tests/models.py
tests/postgres_tests/test_aggregates.py
tests/postgres_tests/test_apps.py
tests/postgres_tests/test_array.py
tests/postgres_tests/test_bulk_update.py
tests/postgres_tests/test_citext.py
tests/postgres_tests/test_constraints.py
tests/postgres_tests/test_functions.py
tests/postgres_tests/test_hstore.py
tests/postgres_tests/test_indexes.py
tests/postgres_tests/test_integration.py
tests/postgres_tests/test_introspection.py
tests/postgres_tests/test_json.py
tests/postgres_tests/test_operations.py
tests/postgres_tests/test_ranges.py
tests/postgres_tests/test_search.py
tests/postgres_tests/test_signals.py
tests/postgres_tests/test_trigram.py
tests/postgres_tests/test_unaccent.py


# The last commit

```
5c2b509691 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array
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
Cloning test database for alias 'default'...
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss............
----------------------------------------------------------------------
Ran 122 tests in 0.133s

OK (skipped=110)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/forms/widgets.py django/contrib/postgres/forms/array.py tests/forms_tests tests/postgres_tests
changed: django/contrib/postgres/forms/array.py +3 -2
changed: django/forms/widgets.py +1 -3
changed: tests/forms_tests/widget_tests/test_checkboxinput.py +6 -0
changed: tests/postgres_tests/test_array.py +8 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/django/contrib/postgres/forms/array.py b/django/contrib/postgres/forms/array.py
index 2e19cd574a..fb1a836896 100644
--- a/django/contrib/postgres/forms/array.py
+++ b/django/contrib/postgres/forms/array.py
@@ -144,10 +144,11 @@ class SplitArrayWidget(forms.Widget):
                 widget_value = value[i]
             except IndexError:
                 widget_value = None
+            widget_attrs = final_attrs.copy()
             if id_:
-                final_attrs = {**final_attrs, 'id': '%s_%s' % (id_, i)}
+                widget_attrs['id'] = '%s_%s' % (id_, i)
             context['widget']['subwidgets'].append(
-                self.widget.get_context(name + '_%s' % i, widget_value, final_attrs)['widget']
+                self.widget.get_context(name + '_%s' % i, widget_value, widget_attrs)['widget']
             )
         return context
 
diff --git a/django/forms/widgets.py b/django/forms/widgets.py
index 6fe220bea7..d83d63c169 100644
--- a/django/forms/widgets.py
+++ b/django/forms/widgets.py
@@ -522,9 +522,7 @@ class CheckboxInput(Input):
 
     def get_context(self, name, value, attrs):
         if self.check_test(value):
-            if attrs is None:
-                attrs = {}
-            attrs['checked'] = True
+            attrs = {**(attrs or {}), 'checked': True}
         return super().get_context(name, value, attrs)
 
     def value_from_datadict(self, data, files, name):
diff --git a/tests/forms_tests/widget_tests/test_checkboxinput.py b/tests/forms_tests/widget_tests/test_checkboxinput.py
index 6483b7f211..3c4bf79a1c 100644
--- a/tests/forms_tests/widget_tests/test_checkboxinput.py
+++ b/tests/forms_tests/widget_tests/test_checkboxinput.py
@@ -44,6 +44,12 @@ class CheckboxInputTest(WidgetTest):
             html='<input checked type="checkbox" name="is_cool" value="1">',
         )
 
+    def test_get_context_does_not_mutate_attrs(self):
+        attrs = {'id': 'is_cool'}
+        context = self.widget.get_context('is_cool', True, attrs)
+        self.assertIs(context['widget']['attrs']['checked'], True)
+        self.assertEqual(attrs, {'id': 'is_cool'})
+
     def test_render_check_test(self):
         """
         You can pass 'check_test' to the constructor. This is a callable that
diff --git a/tests/postgres_tests/test_array.py b/tests/postgres_tests/test_array.py
index 481d93f830..53a7cbb0aa 100644
--- a/tests/postgres_tests/test_array.py
+++ b/tests/postgres_tests/test_array.py
@@ -1112,6 +1112,14 @@ class TestSplitFormWidget(PostgreSQLWidgetTestCase):
             """
         )
 
+    def test_get_context_does_not_mutate_attrs(self):
+        widget = SplitArrayWidget(forms.CheckboxInput(), size=3)
+        context = widget.get_context('name', [True, False, False])
+        subwidgets = context['widget']['subwidgets']
+        self.assertIs(subwidgets[0]['attrs']['checked'], True)
+        self.assertNotIn('checked', subwidgets[1]['attrs'])
+        self.assertNotIn('checked', subwidgets[2]['attrs'])
+
     def test_render_attrs(self):
         self.check_html(
             SplitArrayWidget(forms.TextInput(), size=2),
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
check: python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array
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
Cloning test database for alias 'default'...
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss............
----------------------------------------------------------------------
Ran 122 tests in 0.132s

OK (skipped=110)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/forms/widgets.py django/contrib/postgres/forms/array.py tests/forms_tests tests/postgres_tests
changed: django/contrib/postgres/forms/array.py +3 -2
changed: django/forms/widgets.py +1 -3
changed: tests/forms_tests/widget_tests/test_checkboxinput.py +6 -0
changed: tests/postgres_tests/test_array.py +8 -0
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
# Notes, run 2026-11-06T105748

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

SplitArrayField with BooleanField always has widgets checked after the first True value.
Description
	 
		(last modified by Peter Andersen)
	 
When providing a SplitArrayField BooleanField with preexisting data, the final_attrs dict is updated to include 'checked': True after the for loop has reached the first True value in the initial data array. Once this occurs every widget initialized after that defaults to checked even though the backing data may be False. This is caused by the CheckboxInput widget's get_context() modifying the attrs dict passed into it. This is the only widget that modifies the attrs dict passed into its get_context().
CheckboxInput setting attrs['checked'] to True: ​https://github.com/django/django/blob/master/django/forms/widgets.py#L527


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
django/contrib/admin/locale/mk/LC_MESSAGES/djangojs.mo
django/contrib/admin/locale/mk/LC_MESSAGES/djangojs.po
```


# The last commit

```
5c2b509691 SWE-bench


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
`python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array`

## Scope
`django/forms/widgets.py`
`django/contrib/postgres/forms/array.py`
`tests/forms_tests/`
`tests/postgres_tests/`

## Done when
- `CheckboxInput.get_context()` no longer writes `checked = True` into the `attrs` dict it was passed; callers that reuse that dict do not see a stale `checked` key.
- `SplitArrayField` with a `BooleanField` and initial data containing `False, True, False, ...` renders only the `True` position(s) checked; positions after the first `True` whose backing data is `False` remain unchecked.
- Checked and unchecked checkbox rendering for ordinary forms is unchanged.
- Regression tests covering both of the above pass under Django's test runner.

## Approach
1. Reproduce at the widget level: build a `SplitArrayField` whose `BooleanField` has initial data with a `False` after a `True`, call `get_context()`, and inspect each subwidget's `attrs` for `checked`.
2. Confirm the mutation chain: `SplitArrayField.get_context()` builds one `final_attrs` and passes it to each `widget.get_context()`; `CheckboxInput.get_context()` sets `attrs['checked'] = True` on that shared dict; the next iteration copies the polluted dict.
3. Apply the smallest correct fix, then rerun both the widget tests and the postgres array tests.
4. Add regression coverage for each behavior changed.

Candidate approaches if the first fails:
- **Fix `CheckboxInput.get_context()` (preferred):** set `checked` on `context['widget']['attrs']` rather than on the caller-supplied `attrs`. Fixes the root cause and every other widget that shares an attrs dict. Risk: subtly changes how `attrs` is reflected in the rendered context; verify existing checked/unchecked rendering and custom `check_test` behavior.
- **Fix `SplitArrayField.get_context()`:** pass a fresh copy of `base_attrs` per subwidget instead of reusing `final_attrs`. Localized and low-risk, but leaves the general footgun in `CheckboxInput` and only fixes the array case.
- **Both:** make `CheckboxInput` non-mutating and have `SplitArrayField` copy attrs per iteration. Most defensive; slightly larger diff than needed.
```

### `prompt.md`

```
SplitArrayField with BooleanField always has widgets checked after the first True value.
Description
	 
		(last modified by Peter Andersen)
	 
When providing a SplitArrayField BooleanField with preexisting data, the final_attrs dict is updated to include 'checked': True after the for loop has reached the first True value in the initial data array. Once this occurs every widget initialized after that defaults to checked even though the backing data may be False. This is caused by the CheckboxInput widget's get_context() modifying the attrs dict passed into it. This is the only widget that modifies the attrs dict passed into its get_context().
CheckboxInput setting attrs['checked'] to True: ​https://github.com/django/django/blob/master/django/forms/widgets.py#L527
```

### `review.md`

```
verdict: PASS

- `CheckboxInput.get_context()` no longer writes into the caller's `attrs`: it builds a fresh dict via `{**(attrs or {}), 'checked': True}`, so a reused `final_attrs` cannot leak a stale `checked` key. Ordinary checked/unchecked rendering is unchanged.
- `SplitArrayWidget.get_context()` now copies `final_attrs` per subwidget (`widget_attrs = final_attrs.copy()`) and sets the per-index `id` on the copy, so `[True, False, False]` yields only the first subwidget checked. `SplitArrayField` builds on this widget, so the reported `False, True, False, ...` case is fixed.
- Regression tests were added in both required areas: `test_checkboxinput.py` asserts the attrs dict is not mutated and the context carries `checked`, and `test_array.py` asserts only the `True` position of a `SplitArrayWidget(CheckboxInput(), size=3)` is checked.
- The change is confined to the scoped files, removes no unrelated content (only the three now-unneeded lines in `widgets.py`), and the check run completed with status 0 (`OK`, 122 tests, 110 skipped; skips are the expected PostgreSQL/Oracle-gated cases in this environment).
- Minor note, not a failure: the array regression test exercises `SplitArrayWidget` with `CheckboxInput` rather than `SplitArrayField` with `BooleanField` directly; since `BooleanField`'s widget is `CheckboxInput` and `SplitArrayField` wraps `SplitArrayWidget`, the behavior under test is the same one the prompt reports.
```

### `scope.txt`

```
scope: django/forms/widgets.py django/contrib/postgres/forms/array.py tests/forms_tests tests/postgres_tests
changed: django/contrib/postgres/forms/array.py +3 -2
changed: django/forms/widgets.py +1 -3
changed: tests/forms_tests/widget_tests/test_checkboxinput.py +6 -0
changed: tests/postgres_tests/test_array.py +8 -0
```

### `task.md`

```
# Task

## Prompt

SplitArrayField with BooleanField always has widgets checked after the first True value.
Description
	 
		(last modified by Peter Andersen)
	 
When providing a SplitArrayField BooleanField with preexisting data, the final_attrs dict is updated to include 'checked': True after the for loop has reached the first True value in the initial data array. Once this occurs every widget initialized after that defaults to checked even though the backing data may be False. This is caused by the CheckboxInput widget's get_context() modifying the attrs dict passed into it. This is the only widget that modifies the attrs dict passed into its get_context().
CheckboxInput setting attrs['checked'] to True: ​https://github.com/django/django/blob/master/django/forms/widgets.py#L527

## Deliverable

changes to this tree

## Check

`python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array`

## Scope

`django/forms/widgets.py`
`django/contrib/postgres/forms/array.py`
`tests/forms_tests/`
`tests/postgres_tests/`

## Done when

- `CheckboxInput.get_context()` no longer writes `checked = True` into the `attrs` dict it was passed; callers that reuse that dict do not see a stale `checked` key.
- `SplitArrayField` with a `BooleanField` and initial data containing `False, True, False, ...` renders only the `True` position(s) checked; positions after the first `True` whose backing data is `False` remain unchecked.
- Checked and unchecked checkbox rendering for ordinary forms is unchanged.
- Regression tests covering both of the above pass under Django's test runner.
```

### `test-output.log`

```
check: python tests/runtests.py forms_tests.widget_tests.test_checkboxinput postgres_tests.test_array
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
Cloning test database for alias 'default'...
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss............
----------------------------------------------------------------------
Ran 122 tests in 0.156s

OK (skipped=110)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
scope: django/forms/widgets.py django/contrib/postgres/forms/array.py tests/forms_tests tests/postgres_tests
changed: django/contrib/postgres/forms/array.py +3 -2
changed: django/forms/widgets.py +1 -3
changed: tests/forms_tests/widget_tests/test_checkboxinput.py +6 -0
changed: tests/postgres_tests/test_array.py +8 -0
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
