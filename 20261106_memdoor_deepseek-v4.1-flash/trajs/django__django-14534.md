# django__django-14534 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 56s 34 lines cost=0.002730 in=113703 cached=83968 out=4350 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

BoundWidget.id_for_label ignores id set by ChoiceWidget.options
Description
	
If you look at the implementation of BoundField.subwidgets
class BoundField:
	...
	def subwidgets(self):
		id_ = self.field.widget.attrs.get('id') or self.auto_id
		attrs = {'id': id_} if id_ else {}
		attrs = self.build_widget_attrs(attrs)
		return [
			BoundWidget(self.field.widget, widget, self.form.renderer)
			for widget in self.field.widget.subwidgets(self.html_name, self.value(), attrs=attrs)
		]
one sees that self.field.widget.subwidgets(self.html_name, self.value(), attrs=attrs) returns a dict and assigns it to widget. Now widget['attrs']['id'] contains the "id" we would like to use when rendering the label of our CheckboxSelectMultiple.
However BoundWidget.id_for_label() is implemented as
class BoundWidget:
	...
	def id_for_label(self):
		return 'id_%s_%s' % (self.data['name'], self.data['index'])
ignoring the id available through self.data['attrs']['id']. This re-implementation for rendering the "id" is confusing and presumably not intended. Nobody has probably realized that so far, because rarely the auto_id-argument is overridden when initializing a form. If however we do, one would assume that the method BoundWidget.id_for_label renders that string as specified through the auto_id format-string.
By changing the code from above to
class BoundWidget:
	...
	def id_for_label(self):
		return self.data['attrs']['id']
that function behaves as expected.
Please note that this error only occurs when rendering the subwidgets of a widget of type CheckboxSelectMultiple. This has nothing to do with the method BoundField.id_for_label().

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3"
}
```

**assistant → tool `grep`**

```json
{
  "pattern": "class BoundWidget",
  "output_mode": "files_with_matches"
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
3ad74ddc23 SWE-bench
910ecd1b8d Fixed #29063 -- Fixed migrate crash when specifying a name of partially applied squashed migrations.
202d3e193a Fixed typos in migrations tests, comments, and error message.
```

**tool result**

```
/testbed/django/forms/boundfield.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class BoundWidget\" -A 50 django/forms/boundfield.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"id_for_label\" tests/forms_tests/ | head -40"
}
```

**tool result**

```
247:class BoundWidget:
248-    """
249-    A container class used for iterating over widgets. This is useful for
250-    widgets that have choices. For example, the following can be used in a
251-    template:
252-
253-    {% for radio in myform.beatles %}
254-      <label for="{{ radio.id_for_label }}">
255-        {{ radio.choice_label }}
256-        <span class="radio">{{ radio.tag }}</span>
257-      </label>
258-    {% endfor %}
259-    """
260-    def __init__(self, parent_widget, data, renderer):
261-        self.parent_widget = parent_widget
262-        self.data = data
263-        self.renderer = renderer
264-
265-    def __str__(self):
266-        return self.tag(wrap_label=True)
267-
268-    def tag(self, wrap_label=False):
269-        context = {'widget': {**self.data, 'wrap_label': wrap_label}}
270-        return self.parent_widget._render(self.template_name, context, self.renderer)
271-
272-    @property
273-    def template_name(self):
274-        if 'template_name' in self.data:
275-            return self.data['template_name']
276-        return self.parent_widget.template_name
277-
278-    @property
279-    def id_for_label(self):
280-        return 'id_%s_%s' % (self.data['name'], self.data['index'])
281-
282-    @property
283-    def choice_label(self):
284-        return self.data['label']
```

**tool result**

```
tests/forms_tests/widget_tests/test_checkboxselectmultiple.py:207:        self.assertEqual(bound_field.field.widget.id_for_label('id'), '')
tests/forms_tests/tests/test_forms.py:693:        self.assertEqual(fields[0].id_for_label, 'id_name_0')
tests/forms_tests/tests/test_forms.py:705:        self.assertEqual(fields[1].id_for_label, 'id_name_1')
tests/forms_tests/tests/test_forms.py:723:        self.assertEqual(fields[0].id_for_label, 'id_name_0')
tests/forms_tests/tests/test_forms.py:3162:    def test_boundfield_label_tag_custom_widget_id_for_label(self):
tests/forms_tests/tests/test_forms.py:3164:            def id_for_label(self, id):
tests/forms_tests/tests/test_forms.py:3168:            def id_for_label(self, id):
tests/forms_tests/tests/test_forms.py:3186:    def test_boundfield_id_for_label(self):
tests/forms_tests/tests/test_forms.py:3190:        self.assertEqual(SomeForm()['field'].id_for_label, 'id_field')
tests/forms_tests/tests/test_forms.py:3192:    def test_boundfield_id_for_label_override_by_attrs(self):
tests/forms_tests/tests/test_forms.py:3202:        self.assertEqual(form['field'].id_for_label, 'myCustomID')
tests/forms_tests/tests/test_forms.py:3203:        self.assertEqual(form['field_none'].id_for_label, 'id_field_none')
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def subwidgets\" -A 20 django/forms/widgets.py | head -100; sed -n '680,730p' tests/forms_tests/tests/test_forms.py"
}
```

**tool result**

```
218:    def subwidgets(self, name, value, attrs=None):
219-        context = self.get_context(name, value, attrs)
220-        yield context['widget']
221-
222-    def format_value(self, value):
223-        """
224-        Return a value as it should appear when rendered in a template.
225-        """
226-        if value == '' or value is None:
227-            return None
228-        if self.is_localized:
229-            return formats.localize_input(value)
230-        return str(value)
231-
232-    def get_context(self, name, value, attrs):
233-        return {
234-            'widget': {
235-                'name': name,
236-                'is_hidden': self.is_hidden,
237-                'required': self.is_required,
238-                'value': self.format_value(value),
--
574:    def subwidgets(self, name, value, attrs=None):
575-        """
576-        Yield all "subwidgets" of this widget. Used to enable iterating
577-        options from a BoundField for choice widgets.
578-        """
579-        value = self.format_value(value)
580-        yield from self.options(name, value, attrs)
581-
582-    def options(self, name, value, attrs=None):
583-        """Yield a flat list of options for this widgets."""
584-        for group in self.optgroups(name, value, attrs):
585-            yield from group[1]
586-
587-    def optgroups(self, name, value, attrs=None):
588-        """Return a list of optgroups for this widget."""
589-        groups = []
590-        has_selected = False
591-
592-        for index, (option_value, option_label) in enumerate(self.choices):
593-            if option_value is None:
594-                option_value = ''
<div><label><input type="radio" name="name" value="george" required> George</label></div>
<div><label><input type="radio" name="name" value="ringo" required> Ringo</label></div>"""
        )

    def test_form_with_iterable_boundfield_id(self):
        class BeatleForm(Form):
            name = ChoiceField(
                choices=[('john', 'John'), ('paul', 'Paul'), ('george', 'George'), ('ringo', 'Ringo')],
                widget=RadioSelect,
            )
        fields = list(BeatleForm()['name'])
        self.assertEqual(len(fields), 4)

        self.assertEqual(fields[0].id_for_label, 'id_name_0')
        self.assertEqual(fields[0].choice_label, 'John')
        self.assertHTMLEqual(
            fields[0].tag(),
            '<input type="radio" name="name" value="john" id="id_name_0" required>'
        )
        self.assertHTMLEqual(
            str(fields[0]),
            '<label for="id_name_0"><input type="radio" name="name" '
            'value="john" id="id_name_0" required> John</label>'
        )

        self.assertEqual(fields[1].id_for_label, 'id_name_1')
        self.assertEqual(fields[1].choice_label, 'Paul')
        self.assertHTMLEqual(
            fields[1].tag(),
            '<input type="radio" name="name" value="paul" id="id_name_1" required>'
        )
        self.assertHTMLEqual(
            str(fields[1]),
            '<label for="id_name_1"><input type="radio" name="name" '
            'value="paul" id="id_name_1" required> Paul</label>'
        )

    def test_iterable_boundfield_select(self):
        class BeatleForm(Form):
            name = ChoiceField(choices=[('john', 'John'), ('paul', 'Paul'), ('george', 'George'), ('ringo', 'Ringo')])
        fields = list(BeatleForm(auto_id=False)['name'])
        self.assertEqual(len(fields), 4)

        self.assertEqual(fields[0].id_for_label, 'id_name_0')
        self.assertEqual(fields[0].choice_label, 'John')
        self.assertHTMLEqual(fields[0].tag(), '<option value="john">John</option>')
        self.assertHTMLEqual(str(fields[0]), '<option value="john">John</option>')

    def test_form_with_noniterable_boundfield(self):
        # You can iterate over any BoundField, not just those with widget=RadioSelect.
        class BeatleForm(Form):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '587,660p' django/forms/widgets.py; sed -n '180,230p' tests/forms_tests/widget_tests/test_checkboxselectmultiple.py"
}
```

**tool result**

```
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
                    (not has_selected or self.allow_multiple_selected) and
                    str(subvalue) in value
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
        <li><label><input type="checkbox" name="times" value="12:00:00"> noon</label></li>
        </ul>
        """
        self.check_html(self.widget(choices=choices), 'times', None, html=html)

    def test_use_required_attribute(self):
        widget = self.widget(choices=self.beatles)
        # Always False because browser validation would require all checkboxes
        # to be checked instead of at least one.
        self.assertIs(widget.use_required_attribute(None), False)
        self.assertIs(widget.use_required_attribute([]), False)
        self.assertIs(widget.use_required_attribute(['J', 'P']), False)

    def test_value_omitted_from_data(self):
        widget = self.widget(choices=self.beatles)
        self.assertIs(widget.value_omitted_from_data({}, {}, 'field'), False)
        self.assertIs(widget.value_omitted_from_data({'field': 'value'}, {}, 'field'), False)

    def test_label(self):
        """
        CheckboxSelectMultiple doesn't contain 'for="field_0"' in the <label>
        because clicking that would toggle the first checkbox.
        """
        class TestForm(forms.Form):
            f = forms.MultipleChoiceField(widget=CheckboxSelectMultiple)

        bound_field = TestForm()['f']
        self.assertEqual(bound_field.field.widget.id_for_label('id'), '')
        self.assertEqual(bound_field.label_tag(), '<label>F:</label>')
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"auto_id\" tests/forms_tests/tests/test_forms.py | grep -i \"iterable\\|subwidget\\|radio\\|checkbox\" | head"
}
```

**tool result**

```
602:        # Regarding auto_id and <label>, RadioSelect is a special case. Each radio button
616:        # When RadioSelect is used with auto_id, and the whole form is printed
893:    def test_checkbox_auto_id(self):
894:        # Regarding auto_id, CheckboxSelectMultiple is a special case. Each checkbox
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '710,745p' tests/forms_tests/tests/test_forms.py; sed -n '885,930p' tests/forms_tests/tests/test_forms.py"
}
```

**tool result**

```
        )
        self.assertHTMLEqual(
            str(fields[1]),
            '<label for="id_name_1"><input type="radio" name="name" '
            'value="paul" id="id_name_1" required> Paul</label>'
        )

    def test_iterable_boundfield_select(self):
        class BeatleForm(Form):
            name = ChoiceField(choices=[('john', 'John'), ('paul', 'Paul'), ('george', 'George'), ('ringo', 'Ringo')])
        fields = list(BeatleForm(auto_id=False)['name'])
        self.assertEqual(len(fields), 4)

        self.assertEqual(fields[0].id_for_label, 'id_name_0')
        self.assertEqual(fields[0].choice_label, 'John')
        self.assertHTMLEqual(fields[0].tag(), '<option value="john">John</option>')
        self.assertHTMLEqual(str(fields[0]), '<option value="john">John</option>')

    def test_form_with_noniterable_boundfield(self):
        # You can iterate over any BoundField, not just those with widget=RadioSelect.
        class BeatleForm(Form):
            name = CharField()

        f = BeatleForm(auto_id=False)
        self.assertHTMLEqual('\n'.join(str(bf) for bf in f['name']), '<input type="text" name="name" required>')

    def test_boundfield_slice(self):
        class BeatleForm(Form):
            name = ChoiceField(
                choices=[('john', 'John'), ('paul', 'Paul'), ('george', 'George'), ('ringo', 'Ringo')],
                widget=RadioSelect,
            )

        f = BeatleForm()
        bf = f['name']
        self.assertEqual(
</ul>""")
        # Test iterating on individual checkboxes in a template
        t = Template('{% for checkbox in form.composers %}<div class="mycheckbox">{{ checkbox }}</div>{% endfor %}')
        self.assertHTMLEqual(t.render(Context({'form': f})), """<div class="mycheckbox"><label>
<input checked name="composers" type="checkbox" value="J"> John Lennon</label></div>
<div class="mycheckbox"><label>
<input checked name="composers" type="checkbox" value="P"> Paul McCartney</label></div>""")

    def test_checkbox_auto_id(self):
        # Regarding auto_id, CheckboxSelectMultiple is a special case. Each checkbox
        # gets a distinct ID, formed by appending an underscore plus the checkbox's
        # zero-based index.
        class SongForm(Form):
            name = CharField()
            composers = MultipleChoiceField(
                choices=[('J', 'John Lennon'), ('P', 'Paul McCartney')],
                widget=CheckboxSelectMultiple,
            )

        f = SongForm(auto_id='%s_id')
        self.assertHTMLEqual(
            str(f['composers']),
            """<ul id="composers_id">
<li><label for="composers_id_0">
<input type="checkbox" name="composers" value="J" id="composers_id_0"> John Lennon</label></li>
<li><label for="composers_id_1">
<input type="checkbox" name="composers" value="P" id="composers_id_1"> Paul McCartney</label></li>
</ul>"""
        )

    def test_multiple_choice_list_data(self):
        # Data for a MultipleChoiceField should be a list. QueryDict and
        # MultiValueDict conveniently work with this.
        class SongForm(Form):
            name = CharField()
            composers = MultipleChoiceField(
                choices=[('J', 'John Lennon'), ('P', 'Paul McCartney')],
                widget=CheckboxSelectMultiple,
            )

        data = {'name': 'Yesterday', 'composers': ['J', 'P']}
        f = SongForm(data)
        self.assertEqual(f.errors, {})

        data = QueryDict('name=Yesterday&composers=J&composers=P')
        f = SongForm(data)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/forms/boundfield.py\n@@\n     @property\n     def id_for_label(self):\n-        return 'id_%s_%s' % (self.data['name'], self.data['index'])\n+        return self.data['attrs'].get('id', '')\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/forms/boundfield.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/forms/boundfield.py now (284 lines), around the change:
277:
278:    @property
279:    def id_for_label(self):
280:        return self.data['attrs'].get('id', '')
281:
282:    @property
283:    def choice_label(self):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/forms_tests/tests/test_forms.py -q 2>&1 | tail -30"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py forms_tests.tests.test_forms forms_tests.widget_tests.test_checkboxselectmultiple forms_tests.widget_tests.test_radioselect 2>&1 | tail -40"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 138 test(s).
System check identified no issues (0 silenced).
...............................................................................................................F..........................
======================================================================
FAIL: test_iterable_boundfield_select (forms_tests.tests.test_forms.FormsTestCase)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/case.py", line 60, in testPartExecutor
    yield
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/case.py", line 676, in run
    self._callTestMethod(testMethod)
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/case.py", line 633, in _callTestMethod
    method()
  File "/testbed/tests/forms_tests/tests/test_forms.py", line 723, in test_iterable_boundfield_select
    self.assertEqual(fields[0].id_for_label, 'id_name_0')
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/case.py", line 912, in assertEqual
    assertion_func(first, second, msg=msg)
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/case.py", line 1292, in assertMultiLineEqual
    self.fail(self._formatMessage(msg, standardMsg))
  File "/opt/miniconda3/envs/testbed/lib/python3.8/unittest/case.py", line 753, in fail
    raise self.failureException(msg)
AssertionError: '' != 'id_name_0'
+ id_name_0

----------------------------------------------------------------------
Ran 138 tests in 0.309s

FAILED (failures=1)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '716,726p' tests/forms_tests/tests/test_forms.py"
}
```

**tool result**

```

    def test_iterable_boundfield_select(self):
        class BeatleForm(Form):
            name = ChoiceField(choices=[('john', 'John'), ('paul', 'Paul'), ('george', 'George'), ('ringo', 'Ringo')])
        fields = list(BeatleForm(auto_id=False)['name'])
        self.assertEqual(len(fields), 4)

        self.assertEqual(fields[0].id_for_label, 'id_name_0')
        self.assertEqual(fields[0].choice_label, 'John')
        self.assertHTMLEqual(fields[0].tag(), '<option value="john">John</option>')
        self.assertHTMLEqual(str(fields[0]), '<option value="john">John</option>')
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport re\np='tests/forms_tests/tests/test_forms.py'\ns=open(p).read()\ns=s.replace(\"\"\"        fields = list(BeatleForm(auto_id=False)['name'])\n        self.assertEqual(len(fields), 4)\n\n        self.assertEqual(fields[0].id_for_label, 'id_name_0')\n        self.assertEqual(fields[0].choice_label, 'John')\n        self.assertHTMLEqual(fields[0].tag(), '<option value=\"john\">John</option>')\"\"\",\"\"\"        fields = list(BeatleForm(auto_id=False)['name'])\n        self.assertEqual(len(fields), 4)\n\n        self.assertEqual(fields[0].id_for_label, '')\n        self.assertEqual(fields[0].choice_label, 'John')\n        self.assertHTMLEqual(fields[0].tag(), '<option value=\"john\">John</option>')\"\"\")\nopen(p,'w').write(s)\nEOF\ncd tests && python runtests.py forms_tests 2>&1 | tail -12"
}
```

**tool result**

```
Ran 695 tests in 0.625s

OK (skipped=1)
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
  "command": "python - <<'EOF'\np='tests/forms_tests/tests/test_forms.py'\ns=open(p).read()\nold=\"\"\"        f = SongForm(auto_id='%s_id')\n        self.assertHTMLEqual(\n            str(f['composers']),\"\"\"\nnew=\"\"\"        f = SongForm(auto_id='%s_id')\n        self.assertEqual(f['composers'][0].id_for_label, 'composers_id_0')\n        self.assertHTMLEqual(\n            str(f['composers']),\"\"\"\nassert old in s\ns=s.replace(old,new,1)\nopen(p,'w').write(s)\nEOF\ncd tests && python runtests.py forms_tests.tests.test_forms 2>&1 | tail -6\ncd .. && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo OK"
}
```

**tool result**

```
System check identified no issues (0 silenced).
........................................................................................................................
----------------------------------------------------------------------
Ran 120 tests in 0.265s

OK
OK
```

**assistant**

```
Implemented the fix:

- `BoundWidget.id_for_label` now returns the id from the rendered subwidget's attrs (`self.data['attrs'].get('id', '')`) instead of reconstructing `id_<name>_<index>`, so custom `auto_id` formats and widget `id` attrs are respected.
- Updated `test_iterable_boundfield_select` (which used `auto_id=False`) to expect `''`.
- Added an assertion in `test_checkbox_auto_id` covering `id_for_label` under a custom `auto_id` format.

`forms_tests` all pass, and the required `git status` check exits 0.
```

## Run folder `single-2026-11-06T112037`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
BoundWidget.id_for_label ignores id set by ChoiceWidget.options
Description
	
If you look at the implementation of BoundField.subwidgets
class BoundField:
	...
	def subwidgets(self):
		id_ = self.field.widget.attrs.get('id') or self.auto_id
		attrs = {'id': id_} if id_ else {}
		attrs = self.build_widget_attrs(attrs)
		return [
			BoundWidget(self.field.widget, widget, self.form.renderer)
			for widget in self.field.widget.subwidgets(self.html_name, self.value(), attrs=attrs)
		]
one sees that self.field.widget.subwidgets(self.html_name, self.value(), attrs=attrs) returns a dict and assigns it to widget. Now widget['attrs']['id'] contains the "id" we would like to use when rendering the label of our CheckboxSelectMultiple.
However BoundWidget.id_for_label() is implemented as
class BoundWidget:
	...
	def id_for_label(self):
		return 'id_%s_%s' % (self.data['name'], self.data['index'])
ignoring the id available through self.data['attrs']['id']. This re-implementation for rendering the "id" is confusing and presumably not intended. Nobody has probably realized that so far, because rarely the auto_id-argument is overridden when initializing a form. If however we do, one would assume that the method BoundWidget.id_for_label renders that string as specified through the auto_id format-string.
By changing the code from above to
class BoundWidget:
	...
	def id_for_label(self):
		return self.data['attrs']['id']
that function behaves as expected.
Please note that this error only occurs when rendering the subwidgets of a widget of type CheckboxSelectMultiple. This has nothing to do with the method BoundField.id_for_label().
```
