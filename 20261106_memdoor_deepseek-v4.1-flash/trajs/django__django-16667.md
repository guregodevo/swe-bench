# django__django-16667 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 26s 25 lines cost=0.000746 in=60863 cached=52224 out=867 calls=9`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

SelectDateWidget can crash with OverflowError.
Description
	
Given a relatively common view like this:
from django import forms
from django.forms import SelectDateWidget
from django.http import HttpResponse
class ReproForm(forms.Form):
	 my_date = forms.DateField(widget=SelectDateWidget())
def repro_view(request):
	 form = ReproForm(request.GET) # for ease of reproducibility
	 if form.is_valid():
		 return HttpResponse("ok")
	 else:
		 return HttpResponse("not ok")
# urls.py
urlpatterns = [path('repro/', views.repro_view, name='repro')]
A user can trigger a server crash, reproducible by running locally and visiting ​http://127.0.0.1:8000/repro/?my_date_day=1&my_date_month=1&my_date_year=1234567821345678, which results in
[...] - ERROR - django.request: Internal Server Error: /repro/
Traceback (most recent call last):
[...]
 File "[...]/site-packages/django/forms/widgets.py", line 1160, in value_from_datadict
	date_value = datetime.date(int(y), int(m), int(d))
OverflowError: signed integer is greater than maximum
This can be triggered similarly for a post request.
The issue happens as part of the validation logic run in form.is_valid, specifically, when calling the SelectDateWidget.value_from_datadict, where the user-controlled value is converted into a date without guarding against a possible OverflowError.
Specifically, y, m and d are user controlled, and the code does this:
 date_value = datetime.date(int(y), int(m), int(d)) 
When large integers (larger than sys.maxsize) are supplied to date's constructor it will throw an OverflowError:
>>> import datetime, sys
>>> datetime.date(sys.maxsize+1, 3, 4)
Traceback (most recent call last):
 File "<stdin>", line 1, in <module>
OverflowError: Python int too large to convert to C long

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain | head"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"value_from_datadict\" django/forms/widgets.py | head -20"
}
```

**tool result**

```
/testbed
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
285:    def value_from_datadict(self, data, files, name):
397:    def value_from_datadict(self, data, files, name):
417:    def value_from_datadict(self, data, files, name):
480:    def value_from_datadict(self, data, files, name):
481:        upload = super().value_from_datadict(data, files, name)
482:        if not self.is_required and CheckboxInput().value_from_datadict(
567:    def value_from_datadict(self, data, files, name):
700:    def value_from_datadict(self, data, files, name):
783:    def value_from_datadict(self, data, files, name):
801:    def value_from_datadict(self, data, files, name):
913:    def value_from_datadict(self, data, files, name):
915:            widget.value_from_datadict(data, files, name + widget_name)
1015:    element and hence implements value_from_datadict.
1149:    def value_from_datadict(self, data, files, name):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/forms/widgets.py",
  "offset": 1120,
  "limit": 80
}
```

**tool result**

```
                try:
                    d = datetime.datetime.strptime(value, input_format)
                except ValueError:
                    pass
                else:
                    year, month, day = d.year, d.month, d.day
        return {"year": year, "month": month, "day": day}

    @staticmethod
    def _parse_date_fmt():
        fmt = get_format("DATE_FORMAT")
        escaped = False
        for char in fmt:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char in "Yy":
                yield "year"
            elif char in "bEFMmNn":
                yield "month"
            elif char in "dj":
                yield "day"

    def id_for_label(self, id_):
        for first_select in self._parse_date_fmt():
            return "%s_%s" % (id_, first_select)
        return "%s_month" % id_

    def value_from_datadict(self, data, files, name):
        y = data.get(self.year_field % name)
        m = data.get(self.month_field % name)
        d = data.get(self.day_field % name)
        if y == m == d == "":
            return None
        if y is not None and m is not None and d is not None:
            input_format = get_format("DATE_INPUT_FORMATS")[0]
            input_format = formats.sanitize_strftime_format(input_format)
            try:
                date_value = datetime.date(int(y), int(m), int(d))
            except ValueError:
                # Return pseudo-ISO dates with zeros for any unselected values,
                # e.g. '2017-0-23'.
                return "%s-%s-%s" % (y or 0, m or 0, d or 0)
            return date_value.strftime(input_format)
        return data.get(name)

    def value_omitted_from_data(self, data, files, name):
        return not any(
            ("{}_{}".format(name, interval) in data)
            for interval in ("year", "month", "day")
        )

[lines 1120-1171 of /testbed/django/forms/widgets.py, the end]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"2017-0-23\\|value_from_datadict\\|Overflow\" tests/forms_tests/widget_tests/test_selectdatewidget.py | head -20"
}
```

**tool result**

```
446:            w.value_from_datadict(
529:            w.value_from_datadict(
538:            w.value_from_datadict(
559:                        w.value_from_datadict(data, {}, "field"), expected_value
603:    def test_value_from_datadict(self):
621:                    self.widget.value_from_datadict(data, {}, "field"), expected
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/forms_tests/widget_tests/test_selectdatewidget.py",
  "offset": 595,
  "limit": 40
}
```

**tool result**

```
        ]
        for value in invalid_formats:
            with self.subTest(value=value):
                self.assertEqual(
                    self.widget.format_value(value),
                    {"day": None, "month": None, "year": None},
                )

    def test_value_from_datadict(self):
        tests = [
            (("2000", "12", "1"), "2000-12-01"),
            (("", "12", "1"), "0-12-1"),
            (("2000", "", "1"), "2000-0-1"),
            (("2000", "12", ""), "2000-12-0"),
            (("", "", "", ""), None),
            ((None, "12", "1"), None),
            (("2000", None, "1"), None),
            (("2000", "12", None), None),
        ]
        for values, expected in tests:
            with self.subTest(values=values):
                data = {}
                for field_name, value in zip(("year", "month", "day"), values):
                    if value is not None:
                        data["field_%s" % field_name] = value
                self.assertEqual(
                    self.widget.value_from_datadict(data, {}, "field"), expected
                )

    def test_value_omitted_from_data(self):
        self.assertIs(self.widget.value_omitted_from_data({}, {}, "field"), True)
        self.assertIs(
            self.widget.value_omitted_from_data({"field_month": "12"}, {}, "field"),
            False,
        )
        self.assertIs(
            self.widget.value_omitted_from_data({"field_year": "2000"}, {}, "field"),
            False,
        )
        self.assertIs(

[113 more lines in /testbed/tests/forms_tests/widget_tests/test_selectdatewidget.py (747 in all). read_file with offset: 635 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/forms/widgets.py\n@@\n-            except ValueError:\n+            except (ValueError, OverflowError):\n                 # Return pseudo-ISO dates with zeros for any unselected values,\n                 # e.g. '2017-0-23'.\n                 return \"%s-%s-%s\" % (y or 0, m or 0, d or 0)\n*** Update File: tests/forms_tests/widget_tests/test_selectdatewidget.py\n@@\n             ((\"2000\", \"12\", \"\"), \"2000-12-0\"),\n+            ((\"12345678901234567890\", \"12\", \"1\"), \"12345678901234567890-12-1\"),\n             ((\"\", \"\", \"\", \"\"), None),\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/forms/widgets.py tests/forms_tests/widget_tests/test_selectdatewidget.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/forms/widgets.py now (1171 lines), around the change:
1157:            input_format = formats.sanitize_strftime_format(input_format)
1158:            try:
1159:                date_value = datetime.date(int(y), int(m), int(d))
1160:            except (ValueError, OverflowError):
1161:                # Return pseudo-ISO dates with zeros for any unselected values,
1162:                # e.g. '2017-0-23'.
1163:                return "%s-%s-%s" % (y or 0, m or 0, d or 0)

tests/forms_tests/widget_tests/test_selectdatewidget.py now (748 lines), around the change:
606:            (("", "12", "1"), "0-12-1"),
607:            (("2000", "", "1"), "2000-0-1"),
608:            (("2000", "12", ""), "2000-12-0"),
609:            (("12345678901234567890", "12", "1"), "12345678901234567890-12-1"),
610:            (("", "", "", ""), None),
611:            ((None, "12", "1"), None),
612:            (("2000", None, "1"), None),
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/forms_tests/widget_tests/test_selectdatewidget.py -q 2>&1 | tail -15"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py forms_tests.widget_tests.test_selectdatewidget -v 1 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
Found 15 test(s).
System check identified no issues (0 silenced).
...............
----------------------------------------------------------------------
Ran 15 tests in 0.192s

OK
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
Fixed `SelectDateWidget.value_from_datadict()` to catch `OverflowError` alongside `ValueError` when constructing a date from user-supplied year/month/day values, returning the pseudo-ISO fallback instead of crashing. Added a regression test with an oversized year.

All 15 `SelectDateWidget` tests pass, and the completion command exits 0.
```

## Run folder `single-2026-11-06T112859`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
SelectDateWidget can crash with OverflowError.
Description
	
Given a relatively common view like this:
from django import forms
from django.forms import SelectDateWidget
from django.http import HttpResponse
class ReproForm(forms.Form):
	 my_date = forms.DateField(widget=SelectDateWidget())
def repro_view(request):
	 form = ReproForm(request.GET) # for ease of reproducibility
	 if form.is_valid():
		 return HttpResponse("ok")
	 else:
		 return HttpResponse("not ok")
# urls.py
urlpatterns = [path('repro/', views.repro_view, name='repro')]
A user can trigger a server crash, reproducible by running locally and visiting ​http://127.0.0.1:8000/repro/?my_date_day=1&my_date_month=1&my_date_year=1234567821345678, which results in
[...] - ERROR - django.request: Internal Server Error: /repro/
Traceback (most recent call last):
[...]
 File "[...]/site-packages/django/forms/widgets.py", line 1160, in value_from_datadict
	date_value = datetime.date(int(y), int(m), int(d))
OverflowError: signed integer is greater than maximum
This can be triggered similarly for a post request.
The issue happens as part of the validation logic run in form.is_valid, specifically, when calling the SelectDateWidget.value_from_datadict, where the user-controlled value is converted into a date without guarding against a possible OverflowError.
Specifically, y, m and d are user controlled, and the code does this:
 date_value = datetime.date(int(y), int(m), int(d)) 
When large integers (larger than sys.maxsize) are supplied to date's constructor it will throw an OverflowError:
>>> import datetime, sys
>>> datetime.date(sys.maxsize+1, 3, 4)
Traceback (most recent call last):
 File "<stdin>", line 1, in <module>
OverflowError: Python int too large to convert to C long
```
