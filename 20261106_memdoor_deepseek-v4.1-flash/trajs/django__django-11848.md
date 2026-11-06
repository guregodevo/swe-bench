# django__django-11848 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 24s 19 lines cost=0.000951 in=59818 cached=54784 out=1552 calls=9`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

django.utils.http.parse_http_date two digit year check is incorrect
Description
	 
		(last modified by Ad Timmering)
	 
RFC 850 does not mention this, but in RFC 7231 (and there's something similar in RFC 2822), there's the following quote:
Recipients of a timestamp value in rfc850-date format, which uses a
two-digit year, MUST interpret a timestamp that appears to be more
than 50 years in the future as representing the most recent year in
the past that had the same last two digits.
Current logic is hard coded to consider 0-69 to be in 2000-2069, and 70-99 to be 1970-1999, instead of comparing versus the current year.

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
  "command": "grep -n \"parse_http_date\\|two digit\\|rfc850\\|RFC 850\" django/utils/http.py"
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
?? .memdoor/
```

**tool result**

```
158:def parse_http_date(date):
194:def parse_http_date_safe(date):
196:    Same as parse_http_date, but return None if the input is invalid.
199:        return parse_http_date(date)
```

**assistant → tool `read_file`**

```json
{
  "path": "django/utils/http.py",
  "offset": 140,
  "limit": 70
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"parse_http_date\" tests/ | head -30"
}
```

**tool result**

```
        query_params.append((key, query_val))
    return original_urlencode(query_params, doseq)


def http_date(epoch_seconds=None):
    """
    Format the time to match the RFC1123 date format as specified by HTTP
    RFC7231 section 7.1.1.1.

    `epoch_seconds` is a floating point number expressed in seconds since the
    epoch, in UTC - such as that outputted by time.time(). If set to None, it
    defaults to the current time.

    Output a string in the format 'Wdy, DD Mon YYYY HH:MM:SS GMT'.
    """
    return formatdate(epoch_seconds, usegmt=True)


def parse_http_date(date):
    """
    Parse a date format as specified by HTTP RFC7231 section 7.1.1.1.

    The three formats allowed by the RFC are accepted, even if only the first
    one is still in widespread use.

    Return an integer expressed in seconds since the epoch, in UTC.
    """
    # email.utils.parsedate() does the job for RFC1123 dates; unfortunately
    # RFC7231 makes it mandatory to support RFC850 dates too. So we roll
    # our own RFC-compliant parsing.
    for regex in RFC1123_DATE, RFC850_DATE, ASCTIME_DATE:
        m = regex.match(date)
        if m is not None:
            break
    else:
        raise ValueError("%r is not in a valid HTTP date format" % date)
    try:
        year = int(m.group('year'))
        if year < 100:
            if year < 70:
                year += 2000
            else:
                year += 1900
        month = MONTHS.index(m.group('mon').lower()) + 1
        day = int(m.group('day'))
        hour = int(m.group('hour'))
        min = int(m.group('min'))
        sec = int(m.group('sec'))
        result = datetime.datetime(year, month, day, hour, min, sec)
        return calendar.timegm(result.utctimetuple())
    except Exception as exc:
        raise ValueError("%r is not a valid date" % date) from exc


def parse_http_date_safe(date):
    """
    Same as parse_http_date, but return None if the input is invalid.
    """
    try:
        return parse_http_date(date)
    except Exception:
        pass


# Base 36 functions: useful for generating compact URLs

def base36_to_int(s):
    """
    Convert a base 36 string to an int. Raise ValueError if the input won't fit
    into an int.

[265 more lines in /testbed/django/utils/http.py (474 in all). read_file with offset: 210 to continue]
```

**tool result**

```
tests/utils_tests/test_http.py:9:    is_safe_url, is_same_domain, parse_etags, parse_http_date, quote_etag,
tests/utils_tests/test_http.py:316:        parsed = parse_http_date('Sun, 06 Nov 1994 08:49:37 GMT')
tests/utils_tests/test_http.py:320:        parsed = parse_http_date('Sunday, 06-Nov-94 08:49:37 GMT')
tests/utils_tests/test_http.py:324:        parsed = parse_http_date('Sun Nov  6 08:49:37 1994')
tests/utils_tests/test_http.py:328:        parsed = parse_http_date('Sun Nov  6 08:49:37 0037')
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/utils_tests/test_http.py",
  "offset": 300,
  "limit": 45
}
```

**tool result**

```

        # Ignore RFC 2616 ETags that are invalid according to RFC 7232.
        self.assertEqual(parse_etags(r'"etag", "e\"t\"ag"'), ['"etag"'])

    def test_quoting(self):
        self.assertEqual(quote_etag('etag'), '"etag"')  # unquoted
        self.assertEqual(quote_etag('"etag"'), '"etag"')  # quoted
        self.assertEqual(quote_etag('W/"etag"'), 'W/"etag"')  # quoted, weak


class HttpDateProcessingTests(unittest.TestCase):
    def test_http_date(self):
        t = 1167616461.0
        self.assertEqual(http_date(t), 'Mon, 01 Jan 2007 01:54:21 GMT')

    def test_parsing_rfc1123(self):
        parsed = parse_http_date('Sun, 06 Nov 1994 08:49:37 GMT')
        self.assertEqual(datetime.utcfromtimestamp(parsed), datetime(1994, 11, 6, 8, 49, 37))

    def test_parsing_rfc850(self):
        parsed = parse_http_date('Sunday, 06-Nov-94 08:49:37 GMT')
        self.assertEqual(datetime.utcfromtimestamp(parsed), datetime(1994, 11, 6, 8, 49, 37))

    def test_parsing_asctime(self):
        parsed = parse_http_date('Sun Nov  6 08:49:37 1994')
        self.assertEqual(datetime.utcfromtimestamp(parsed), datetime(1994, 11, 6, 8, 49, 37))

    def test_parsing_year_less_than_70(self):
        parsed = parse_http_date('Sun Nov  6 08:49:37 0037')
        self.assertEqual(datetime.utcfromtimestamp(parsed), datetime(2037, 11, 6, 8, 49, 37))


class EscapeLeadingSlashesTests(unittest.TestCase):
    def test(self):
        tests = (
            ('//example.com', '/%2Fexample.com'),
            ('//', '/%2F'),
        )
        for url, expected in tests:
            with self.subTest(url=url):
                self.assertEqual(escape_leading_slashes(url), expected)

[lines 300-340 of /testbed/tests/utils_tests/test_http.py, the end]
```

**assistant → tool `bash`**

```json
{
  "command": "head -20 django/utils/http.py"
}
```

**tool result**

```
import base64
import calendar
import datetime
import re
import unicodedata
import warnings
from binascii import Error as BinasciiError
from email.utils import formatdate
from urllib.parse import (
    ParseResult, SplitResult, _coerce_args, _splitnetloc, _splitparams, quote,
    quote_plus, scheme_chars, unquote, unquote_plus,
    urlencode as original_urlencode, uses_params,
)

from django.core.exceptions import TooManyFieldsSent
from django.utils.datastructures import MultiValueDict
from django.utils.deprecation import RemovedInDjango40Warning
from django.utils.functional import keep_lazy_text

# based on RFC 7232, Appendix C
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: django/utils/http.py\n@@\n         year = int(m.group('year'))\n         if year < 100:\n-            if year < 70:\n-                year += 2000\n-            else:\n-                year += 1900\n+            current_year = datetime.datetime.utcnow().year\n+            year += current_year - current_year % 100\n+            if year > current_year + 50:\n+                year -= 100\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[django/utils/http.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

django/utils/http.py now (474 lines), around the change:
176:    try:
177:        year = int(m.group('year'))
178:        if year < 100:
179:            current_year = datetime.datetime.utcnow().year
180:            year += current_year - current_year % 100
181:            if year > current_year + 50:
182:                year -= 100
183:        month = MONTHS.index(m.group('mon').lower()) + 1
184:        day = int(m.group('day'))
185:        hour = int(m.group('hour'))
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/utils_tests/test_http.py -q 2>&1 | tail -20"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named pytest
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py utils_tests.test_http 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
.............................................
----------------------------------------------------------------------
Ran 45 tests in 0.161s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS; git diff --stat"
}
```

**tool result**

```
PASS
 django/utils/http.py | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)
```

**assistant**

```
Implemented the RFC 7231 two-digit-year rule in `django/utils/http.py`:

- Two-digit years are now resolved relative to the current year (not hard-coded 1970/2000 cutoffs).
- A timestamp more than 50 years in the future is interpreted as the most recent past year with the same last two digits.

Verified with `python tests/runtests.py utils_tests.test_http` (45 tests pass), and the required `git status` check exits 0.
```

## Run folder `single-2026-11-06T105557`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
django.utils.http.parse_http_date two digit year check is incorrect
Description
	 
		(last modified by Ad Timmering)
	 
RFC 850 does not mention this, but in RFC 7231 (and there's something similar in RFC 2822), there's the following quote:
Recipients of a timestamp value in rfc850-date format, which uses a
two-digit year, MUST interpret a timestamp that appears to be more
than 50 years in the future as representing the most recent year in
the past that had the same last two digits.
Current logic is hard coded to consider 0-69 to be in 2000-2069, and 70-99 to be 1970-1999, instead of comparing versus the current year.
```
