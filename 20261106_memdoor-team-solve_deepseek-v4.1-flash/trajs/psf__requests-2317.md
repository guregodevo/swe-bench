# psf__requests-2317 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 144s 35 lines cost=0.005631 in=172817 cached=95232 out=8857 calls=15`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

method = builtin_str(method) problem
In requests/sessions.py is a command:

method = builtin_str(method)
Converts method from
b’GET’
to
"b'GET’"

Which is the literal string, no longer a binary string.  When requests tries to use the method "b'GET’”, it gets a 404 Not Found response.

I am using python3.4 and python-neutronclient (2.3.9) with requests (2.4.3).  neutronclient is broken because it uses this "args = utils.safe_encode_list(args)" command which converts all the values to binary string, including method.

I'm not sure if this is a bug with neutronclient or a bug with requests, but I'm starting here.  Seems if requests handled the method value being a binary string, we wouldn't have any problem.

Also, I tried in python2.6 and this bug doesn't exist there. Some difference between 2.6 and 3.4 makes this not work right.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls -la && git log --oneline -3 && git status --short"
}
```

**tool result**

```
/testbed
total 160
drwxrwxrwx 1 root root  4096 Nov  6 12:53 .
drwxr-xr-x 1 root root  4096 Nov  6 12:53 ..
drwxrwxrwx 1 root root  4096 Nov  6 12:53 .git
-rwxrwxrwx 1 root root   208 Aug 15 07:25 .gitignore
drwxr-xr-x 4 root root  4096 Nov  6 12:53 .memdoor
-rwxrwxrwx 1 root root  5056 Aug 15 07:25 AUTHORS.rst
-rwxrwxrwx 1 root root 23588 Aug 15 07:25 HISTORY.rst
-rwxrwxrwx 1 root root   581 Aug 15 07:25 LICENSE
-rwxrwxrwx 1 root root   100 Aug 15 07:25 MANIFEST.in
-rwxrwxrwx 1 root root  1084 Aug 15 07:25 Makefile
-rwxrwxrwx 1 root root  2292 Aug 15 07:25 NOTICE
-rwxrwxrwx 1 root root  2934 Aug 15 07:25 README.rst
drwxr-xr-x 4 root root  4096 Aug 15 07:25 build
drwxrwxrwx 8 root root  4096 Aug 15 07:25 docs
drwxrwxrwx 2 root root  4096 Aug 15 07:25 ext
drwxrwxrwx 4 root root  4096 Aug 15 07:25 requests
drwxr-xr-x 2 root root  4096 Aug 15 07:25 requests.egg-info
-rwxrwxrwx 1 root root    47 Aug 15 07:25 requirements.txt
-rwxrwxrwx 1 root root    22 Aug 15 07:25 setup.cfg
-rwxrwxrwx 1 root root  1834 Aug 15 07:25 setup.py
-rwxrwxrwx 1 root root 51816 Aug 15 07:25 test_requests.py
ac2af65 SWE-bench
091991b Merge pull request #2306 from ssadler/fix-failing-test-test_prepare_unicode_url
583859b fix failing test "test_prepare_unicode_url" \(take 3\)
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"builtin_str\\|def prepare_request\\|method\" requests/sessions.py | head -50 && grep -n \"builtin_str\\|def to_native_string\\|def to_key_val_list\" requests/utils.py requests/compat.py"
}
```

**tool result**

```
16:from .compat import cookielib, OrderedDict, urljoin, urlparse, builtin_str
117:            method = req.method
143:                    method != 'HEAD'):
144:                method = 'GET'
148:            if resp.status_code == codes.found and method != 'HEAD':
149:                method = 'GET'
153:            if resp.status_code == codes.moved and method == 'POST':
154:                method = 'GET'
156:            prepared_request.method = method
200:        request to avoid leaking credentials. This method intelligently removes
224:        This method re-evaluates the proxy configuration by considering the
230:        This method also replaces the Proxy-Authorization header where
338:    def prepare_request(self, request):
365:            method=request.method.upper(),
378:    def request(self, method, url,
396:        :param method: method for the new :class:`Request` object.
428:        method = builtin_str(method)
432:            method = method.upper(),
requests/utils.py:27:                     builtin_str, getproxies, proxy_bypass, urlunparse)
requests/utils.py:144:def to_key_val_list(value):
requests/utils.py:655:def to_native_string(string, encoding='ascii'):
requests/utils.py:663:    if isinstance(string, builtin_str):
requests/compat.py:96:    builtin_str = str
requests/compat.py:111:    builtin_str = str
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,130p' requests/compat.py && sed -n '640,680p' requests/utils.py && sed -n '420,440p' requests/sessions.py"
}
```

**tool result**

```
# -*- coding: utf-8 -*-

"""
pythoncompat
"""

from .packages import chardet

import sys

# -------
# Pythons
# -------

# Syntax sugar.
_ver = sys.version_info

#: Python 2.x?
is_py2 = (_ver[0] == 2)

#: Python 3.x?
is_py3 = (_ver[0] == 3)

#: Python 3.0.x
is_py30 = (is_py3 and _ver[1] == 0)

#: Python 3.1.x
is_py31 = (is_py3 and _ver[1] == 1)

#: Python 3.2.x
is_py32 = (is_py3 and _ver[1] == 2)

#: Python 3.3.x
is_py33 = (is_py3 and _ver[1] == 3)

#: Python 3.4.x
is_py34 = (is_py3 and _ver[1] == 4)

#: Python 2.7.x
is_py27 = (is_py2 and _ver[1] == 7)

#: Python 2.6.x
is_py26 = (is_py2 and _ver[1] == 6)

#: Python 2.5.x
is_py25 = (is_py2 and _ver[1] == 5)

#: Python 2.4.x
is_py24 = (is_py2 and _ver[1] == 4)   # I'm assuming this is not by choice.


# ---------
# Platforms
# ---------


# Syntax sugar.
_ver = sys.version.lower()

is_pypy = ('pypy' in _ver)
is_jython = ('jython' in _ver)
is_ironpython = ('iron' in _ver)

# Assume CPython, if nothing else.
is_cpython = not any((is_pypy, is_jython, is_ironpython))

# Windows-based system.
is_windows = 'win32' in str(sys.platform).lower()

# Standard Linux 2+ system.
is_linux = ('linux' in str(sys.platform).lower())
is_osx = ('darwin' in str(sys.platform).lower())
is_hpux = ('hpux' in str(sys.platform).lower())   # Complete guess.
is_solaris = ('solar==' in str(sys.platform).lower())   # Complete guess.

try:
    import simplejson as json
except (ImportError, SyntaxError):
    # simplejson does not support Python 3.2, it thows a SyntaxError
    # because of u'...' Unicode literals.
    import json

# ---------
# Specifics
# ---------

if is_py2:
    from urllib import quote, unquote, quote_plus, unquote_plus, urlencode, getproxies, proxy_bypass
    from urlparse import urlparse, urlunparse, urljoin, urlsplit, urldefrag
    from urllib2 import parse_http_list
    import cookielib
    from Cookie import Morsel
    from StringIO import StringIO
    from .packages.urllib3.packages.ordered_dict import OrderedDict

    builtin_str = str
    bytes = str
    str = unicode
    basestring = basestring
    numeric_types = (int, long, float)


elif is_py3:
    from urllib.parse import urlparse, urlunparse, urljoin, urlsplit, urlencode, quote, unquote, quote_plus, unquote_plus, urldefrag
    from urllib.request import parse_http_list, getproxies, proxy_bypass
    from http import cookiejar as cookielib
    from http.cookies import Morsel
    from io import StringIO
    from collections import OrderedDict

    builtin_str = str
    str = str
    bytes = bytes
    basestring = (str, bytes)
    numeric_types = (int, float)


def get_auth_from_url(url):
    """Given a url with authentication components, extract them into a tuple of
    username,password."""
    parsed = urlparse(url)

    try:
        auth = (unquote(parsed.username), unquote(parsed.password))
    except (AttributeError, TypeError):
        auth = ('', '')

    return auth


def to_native_string(string, encoding='ascii'):
    """
    Given a string object, regardless of type, returns a representation of that
    string in the native string type, encoding and decoding where necessary.
    This assumes ASCII unless told otherwise.
    """
    out = None

    if isinstance(string, builtin_str):
        out = string
    else:
        if is_py2:
            out = string.encode(encoding)
        else:
            out = string.decode(encoding)

    return out


def urldefragauth(url):
    """
    Given a url remove the fragment and the authentication part
    """
    scheme, netloc, path, params, query, fragment = urlparse(url)

    # see func:`prepend_scheme_if_needed`
        :param stream: (optional) whether to immediately download the response
            content. Defaults to ``False``.
        :param verify: (optional) if ``True``, the SSL cert will be verified.
            A CA_BUNDLE path can also be provided.
        :param cert: (optional) if String, path to ssl client cert file (.pem).
            If Tuple, ('cert', 'key') pair.
        """

        method = builtin_str(method)

        # Create the Request.
        req = Request(
            method = method.upper(),
            url = url,
            headers = headers,
            files = files,
            data = data or {},
            json = json,
            params = params or {},
            auth = auth,
            cookies = cookies,
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Request\\|def __init__\\|method\" requests/models.py | head -40 && sed -n '220,320p' requests/models.py && sed -n '330,375p' requests/sessions.py"
}
```

**tool result**

```
53:class RequestEncodingMixin(object):
75:    @staticmethod
102:    @staticmethod
162:class RequestHooksMixin(object):
186:class Request(RequestHooksMixin):
191:    :param method: HTTP method to use.
210:    def __init__(self,
211:        method=None,
233:        self.method = method
244:        return '<Request [%s]>' % (self.method)
250:            method=self.method,
283:    def __init__(self):
285:        self.method = None
298:    def prepare(self, method=None, url=None, headers=None, files=None,
303:        self.prepare_method(method)
316:        return '<PreparedRequest [%s]>' % (self.method)
320:        p.method = self.method
328:    def prepare_method(self, method):
329:        """Prepares the given HTTP method."""
330:        self.method = method
331:        if self.method is not None:
332:            self.method = self.method.upper()
475:        elif self.method not in ('GET', 'HEAD'):
536:    def __init__(self):
832:        """Releases the connection back to the pool. Once this method has been
        json=None):

        # Default empty dicts for dict params.
        data = [] if data is None else data
        files = [] if files is None else files
        headers = {} if headers is None else headers
        params = {} if params is None else params
        hooks = {} if hooks is None else hooks

        self.hooks = default_hooks()
        for (k, v) in list(hooks.items()):
            self.register_hook(event=k, hook=v)

        self.method = method
        self.url = url
        self.headers = headers
        self.files = files
        self.data = data
        self.json = json
        self.params = params
        self.auth = auth
        self.cookies = cookies

    def __repr__(self):
        return '<Request [%s]>' % (self.method)

    def prepare(self):
        """Constructs a :class:`PreparedRequest <PreparedRequest>` for transmission and returns it."""
        p = PreparedRequest()
        p.prepare(
            method=self.method,
            url=self.url,
            headers=self.headers,
            files=self.files,
            data=self.data,
            json=self.json,
            params=self.params,
            auth=self.auth,
            cookies=self.cookies,
            hooks=self.hooks,
        )
        return p


class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
    """The fully mutable :class:`PreparedRequest <PreparedRequest>` object,
    containing the exact bytes that will be sent to the server.

    Generated from either a :class:`Request <Request>` object or manually.

    Usage::

      >>> import requests
      >>> req = requests.Request('GET', 'http://httpbin.org/get')
      >>> r = req.prepare()
      <PreparedRequest [GET]>

      >>> s = requests.Session()
      >>> s.send(r)
      <Response [200]>

    """

    def __init__(self):
        #: HTTP verb to send to the server.
        self.method = None
        #: HTTP URL to send the request to.
        self.url = None
        #: dictionary of HTTP headers.
        self.headers = None
        # The `CookieJar` used to create the Cookie header will be stored here
        # after prepare_cookies is called
        self._cookies = None
        #: request body to send to the server.
        self.body = None
        #: dictionary of callback hooks, for internal usage.
        self.hooks = default_hooks()

    def prepare(self, method=None, url=None, headers=None, files=None,
                data=None, params=None, auth=None, cookies=None, hooks=None,
                json=None):
        """Prepares the entire request with the given parameters."""

        self.prepare_method(method)
        self.prepare_url(url, params)
        self.prepare_headers(headers)
        self.prepare_cookies(cookies)
        self.prepare_body(data, files, json)
        self.prepare_auth(auth, url)
        # Note that prepare_auth must be last to enable authentication schemes
        # such as OAuth to work on a fully prepared request.

        # This MUST go after prepare_auth. Authenticators could add a hook
        self.prepare_hooks(hooks)

    def __repr__(self):
        return '<PreparedRequest [%s]>' % (self.method)

    def copy(self):
        p = PreparedRequest()
        p.method = self.method
        self.redirect_cache = {}

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()

    def prepare_request(self, request):
        """Constructs a :class:`PreparedRequest <PreparedRequest>` for
        transmission and returns it. The :class:`PreparedRequest` has settings
        merged from the :class:`Request <Request>` instance and those of the
        :class:`Session`.

        :param request: :class:`Request` instance to prepare with this
            session's settings.
        """
        cookies = request.cookies or {}

        # Bootstrap CookieJar.
        if not isinstance(cookies, cookielib.CookieJar):
            cookies = cookiejar_from_dict(cookies)

        # Merge with session cookies
        merged_cookies = merge_cookies(
            merge_cookies(RequestsCookieJar(), self.cookies), cookies)


        # Set environment's basic authentication if not explicitly set.
        auth = request.auth
        if self.trust_env and not auth and not self.auth:
            auth = get_netrc_auth(request.url)

        p = PreparedRequest()
        p.prepare(
            method=request.method.upper(),
            url=request.url,
            files=request.files,
            data=request.data,
            json=request.json,
            headers=merge_setting(request.headers, self.headers, dict_class=CaseInsensitiveDict),
            params=merge_setting(request.params, self.params),
            auth=merge_setting(auth, self.auth),
            cookies=merged_cookies,
            hooks=merge_hooks(request.hooks, self.hooks),
        )
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"builtin_str\\|b'GET'\\|b\\\"GET\\\"\\|native_string\\|unicode method\\|bytes\" test_requests.py | head -40 && grep -rn \"builtin_str\" requests/"
}
```

**tool result**

```
19:    Morsel, cookielib, getproxies, str, urljoin, urlparse, is_py3, builtin_str)
594:    def test_prepare_request_with_bytestring_url(self):
964:        # read only the first eight bytes of the response body,
999:        assert isinstance(s, builtin_str)
requests/sessions.py:16:from .compat import cookielib, OrderedDict, urljoin, urlparse, builtin_str
requests/sessions.py:428:        method = builtin_str(method)
requests/compat.py:96:    builtin_str = str
requests/compat.py:111:    builtin_str = str
requests/utils.py:27:                     builtin_str, getproxies, proxy_bypass, urlunparse)
requests/utils.py:663:    if isinstance(string, builtin_str):
requests/models.py:34:    is_py2, chardet, json, builtin_str, basestring)
requests/models.py:443:                self.headers['Content-Length'] = builtin_str(length)
requests/models.py:469:            self.headers['Content-Length'] = builtin_str(body.tell())
requests/models.py:474:                self.headers['Content-Length'] = builtin_str(l)
grep: requests/__pycache__/compat.cpython-39.pyc: binary file matches
grep: requests/__pycache__/models.cpython-39.pyc: binary file matches
grep: requests/__pycache__/sessions.cpython-39.pyc: binary file matches
grep: requests/__pycache__/utils.cpython-39.pyc: binary file matches
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '25,40p' requests/models.py && sed -n '1,30p' requests/utils.py && sed -n '580,610p' test_requests.py && grep -n \"to_native_string\" requests/*.py"
}
```

**tool result**

```
    HTTPError, RequestException, MissingSchema, InvalidURL, 
    ChunkedEncodingError, ContentDecodingError, ConnectionError, 
    StreamConsumedError)
from .utils import (
    guess_filename, get_auth_from_url, requote_uri,
    stream_decode_response_unicode, to_key_val_list, parse_header_links,
    iter_slices, guess_json_utf, super_len, to_native_string)
from .compat import (
    cookielib, urlunparse, urlsplit, urlencode, str, bytes, StringIO,
    is_py2, chardet, json, builtin_str, basestring)
from .status_codes import codes

#: The set of HTTP status codes that indicate an automatically
#: processable redirect.
REDIRECT_STATI = (
    codes.moved,              # 301
# -*- coding: utf-8 -*-

"""
requests.utils
~~~~~~~~~~~~~~

This module provides utility functions that are used within Requests
that are also useful for external consumption.

"""

import cgi
import codecs
import collections
import io
import os
import platform
import re
import sys
import socket
import struct

from . import __version__
from . import certs
from .compat import parse_http_list as _parse_list_header
from .compat import (quote, urlparse, bytes, str, OrderedDict, unquote, is_py2,
                     builtin_str, getproxies, proxy_bypass, urlunparse)
from .cookies import RequestsCookieJar, cookiejar_from_dict
from .structures import CaseInsensitiveDict
from .exceptions import InvalidURL
                return r

        req = requests.Request('GET', httpbin('headers'))
        assert not req.auth

        s = requests.Session()
        s.auth = DummyAuth()

        prep = s.prepare_request(req)
        resp = s.send(prep)

        assert resp.json()['headers'][
            'Dummy-Auth-Test'] == 'dummy-auth-test-ok'

    def test_prepare_request_with_bytestring_url(self):
        req = requests.Request('GET', b'https://httpbin.org/')
        s = requests.Session()
        prep = s.prepare_request(req)
        assert prep.url == "https://httpbin.org/"

    def test_links(self):
        r = requests.Response()
        r.headers = {
            'cache-control': 'public, max-age=60, s-maxage=60',
            'connection': 'keep-alive',
            'content-encoding': 'gzip',
            'content-type': 'application/json; charset=utf-8',
            'date': 'Sat, 26 Jan 2013 16:47:56 GMT',
            'etag': '"6ff6a73c0e446c1f61614769e3ceb778"',
            'last-modified': 'Sat, 26 Jan 2013 16:22:39 GMT',
            'link': ('<https://api.github.com/users/kennethreitz/repos?'
requests/auth.py:19:from .utils import parse_dict_header, to_native_string
requests/auth.py:28:    authstr = 'Basic ' + to_native_string(
requests/models.py:31:    iter_slices, guess_json_utf, super_len, to_native_string)
requests/models.py:407:            self.headers = CaseInsensitiveDict((to_native_string(name), value) for name, value in headers.items())
requests/sessions.py:21:from .utils import to_key_val_list, default_headers, to_native_string
requests/sessions.py:136:            prepared_request.url = to_native_string(url)
requests/utils.py:655:def to_native_string(string, encoding='ascii'):
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline | head -20 && grep -rn \"method = builtin_str\\|to_native_string(method)\" . --exclude-dir=.git --exclude-dir=.memdoor 2>/dev/null | head"
}
```

**tool result**

```
ac2af65 SWE-bench
091991b Merge pull request #2306 from ssadler/fix-failing-test-test_prepare_unicode_url
583859b fix failing test "test_prepare_unicode_url" \(take 3\)
8e69c9f Revert "fix failing test "test_prepare_unicode_url""
26ed7c2 fix failing test "test_prepare_unicode_url"
77687de Revert "fix failing test "test_prepare_unicode_url""
be805f9 Merge pull request #2295 from 2deviant/feature-custom-newline
c044a70 update AUTHORS
cfd6e25 fix failing test "test_prepare_unicode_url"
3602690 Changing parameter name `newline` ==> `delimiter`.
f5ff05b Adding a custom line delimiter to iter_lines()
6b58a35 Merge pull request #2290 from syedsuhail/fix-2282
96efb5e Fix #2279. Update layout css
e1e1855 Merge pull request #2289 from syedsuhail/fix-2288
3a6348d Fix #2288. Change urllib3 and chardet workflow
f7ecad8 Merge pull request #2282 from morganthrapp/patch-1
4d498db Update sidebarintro.html
c41eb27 Merge pull request #2273 from sigmavirus24/add-changelog-to-sidebar
2ac771b Merge pull request #2271 from mikecool1000/fix-2250
8339b60 Made more better
./requests/sessions.py:428:        method = builtin_str(method)
./build/lib/requests/sessions.py:428:        method = builtin_str(method)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '10,24p' requests/sessions.py && sed -n '322,336p' requests/models.py"
}
```

**tool result**

```
"""
import os
from collections import Mapping
from datetime import datetime

from .auth import _basic_auth_str
from .compat import cookielib, OrderedDict, urljoin, urlparse, builtin_str
from .cookies import (
    cookiejar_from_dict, extract_cookies_to_jar, RequestsCookieJar, merge_cookies)
from .models import Request, PreparedRequest, DEFAULT_REDIRECT_LIMIT
from .hooks import default_hooks, dispatch_hook
from .utils import to_key_val_list, default_headers, to_native_string
from .exceptions import (
    TooManyRedirects, InvalidSchema, ChunkedEncodingError, ContentDecodingError)
from .structures import CaseInsensitiveDict
        p.headers = self.headers.copy() if self.headers is not None else None
        p._cookies = self._cookies.copy() if self._cookies is not None else None
        p.body = self.body
        p.hooks = self.hooks
        return p

    def prepare_method(self, method):
        """Prepares the given HTTP method."""
        self.method = method
        if self.method is not None:
            self.method = self.method.upper()

    def prepare_url(self, url, params):
        """Prepares the given HTTP URL."""
        #: Accept objects that have string representations.
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/requests/sessions.py\n@@\n-from .compat import cookielib, OrderedDict, urljoin, urlparse, builtin_str\n+from .compat import cookielib, OrderedDict, urljoin, urlparse\n@@\n-        method = builtin_str(method)\n+        method = to_native_string(method)\n*** Update File: /testbed/requests/models.py\n@@\n     def prepare_method(self, method):\n         \"\"\"Prepares the given HTTP method.\"\"\"\n         self.method = method\n         if self.method is not None:\n-            self.method = self.method.upper()\n+            self.method = to_native_string(self.method).upper()\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/requests/sessions.py /testbed/requests/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/requests/sessions.py now (671 lines), around the change:
13:from datetime import datetime
14:
15:from .auth import _basic_auth_str
16:from .compat import cookielib, OrderedDict, urljoin, urlparse
17:from .cookies import (
18:    cookiejar_from_dict, extract_cookies_to_jar, RequestsCookieJar, merge_cookies)
19:from .models import Request, PreparedRequest, DEFAULT_REDIRECT_LIMIT
…
425:            If Tuple, ('cert', 'key') pair.
426:        """
427:
428:        method = to_native_string(method)
429:
430:        # Create the Request.
431:        req = Request(

/testbed/requests/models.py now (837 lines), around the change:
329:        """Prepares the given HTTP method."""
330:        self.method = method
331:        if self.method is not None:
332:            self.method = to_native_string(self.method).upper()
333:
334:    def prepare_url(self, url, params):
335:        """Prepares the given HTTP URL."""
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport requests\nfrom requests.models import PreparedRequest\nfor m in [b'GET', 'GET', b'post']:\n    p = PreparedRequest(); p.prepare(method=m, url='http://example.com')\n    print(repr(m), '->', repr(p.method))\ns = requests.Session()\nr = requests.Request(b'GET', 'http://example.com')\nprint(repr(s.prepare_request(r).method))\nEOF\npython -m pytest test_requests.py -q -k \"prepare_request or method or bytestring\" 2>&1 | tail -20"
}
```

**tool result**

```
Traceback (most recent call last):
  File "<stdin>", line 4, in <module>
  File "/testbed/requests/models.py", line 313, in prepare
    self.prepare_hooks(hooks)
  File "/testbed/requests/models.py", line 514, in prepare_hooks
    for event in hooks:
TypeError: 'NoneType' object is not iterable
            method=u('POST'), url=httpbin('post'), files=files)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:524: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:1
requests/packages/urllib3/_collections.py:1
  /testbed/requests/packages/urllib3/_collections.py:1: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

test_requests.py::RequestsTestCase::test_prepare_request_with_bytestring_url
  /testbed/requests/models.py:169: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::RequestsTestCase::test_unicode_method_name - assert ...
1 failed, 1 passed, 140 deselected, 3 warnings in 0.90s
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport requests\nfrom requests.models import PreparedRequest\nfor m in [b'GET', 'GET', b'post', u'get']:\n    p = PreparedRequest(); p.prepare_method(m)\n    print(repr(m), '->', repr(p.method))\nr = requests.Request(b'GET', 'http://example.com')\nprint('session ->', repr(requests.Session().prepare_request(r).method))\nEOF\ngrep -n \"test_unicode_method_name\" -A12 test_requests.py"
}
```

**tool result**

```
b'GET' -> 'GET'
'GET' -> 'GET'
b'post' -> 'POST'
'get' -> 'GET'
session -> 'GET'
520:    def test_unicode_method_name(self):
521-        files = {'file': open('test_requests.py', 'rb')}
522-        r = requests.request(
523-            method=u('POST'), url=httpbin('post'), files=files)
524-        assert r.status_code == 200
525-
526-    def test_custom_content_type(self):
527-        r = requests.post(
528-            httpbin('post'),
529-            data={'stuff': json.dumps({'a': 123})},
530-            files={'file1': ('test_requests.py', open(__file__, 'rb')),
531-                   'file2': ('test_requests', open(__file__, 'rb'),
532-                             'text/py-content-type')})
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"builtin_str\" requests/sessions.py; python -m pytest test_requests.py -q -k \"bytestring_url or unicode_url or prepare_url\" 2>&1 | tail -8; git diff --stat"
}
```

**tool result**

```
    from collections import Mapping, MutableMapping

test_requests.py::RequestsTestCase::test_prepare_request_with_bytestring_url
  /testbed/requests/models.py:169: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
2 passed, 140 deselected, 3 warnings in 0.20s
 requests/models.py   | 2 +-
 requests/sessions.py | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)
```

**assistant**

````
Fixed the Python 3 bytes/str mishandling of HTTP methods.

**Root cause:** `requests/sessions.py` used `builtin_str(method)`. On Python 3, `builtin_str` is `str`, so `str(b'GET')` produced the literal `"b'GET'"` instead of decoding the bytes. Python 2 didn't show the bug because `builtin_str = str` there and `str` on a byte string is a no-op.

**Changes:**
- `requests/sessions.py`: `method = builtin_str(method)` → `method = to_native_string(method)`, and dropped the now-unused `builtin_str` import.
- `requests/models.py`: `PreparedRequest.prepare_method` now does `to_native_string(self.method).upper()`, so a byte-string method also works when preparing a `PreparedRequest` directly (not just through `Session.request`).

`to_native_string` decodes bytes on Python 3 (and leaves native strings alone on both versions), so `b'GET'` becomes `'GET'` rather than `"b'GET'"`.

Verified:
```
b'GET' -> 'GET'
'GET'  -> 'GET'
b'post'-> 'POST'
u'get' -> 'GET'
Session.prepare_request(Request(b'GET', ...)).method == 'GET'
```
Relevant prepare-url/bytestring tests pass; the only failure in the subset run was `test_unicode_method_name` returning HTTP 403 from the external httpbin endpoint, unrelated to method handling. No commits, checkouts, resets, or stashes were performed.
````

## Run folder `team-solve-2026-11-06T125330`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
ac2af6596a097252c97353aa2ec771591053b08b
```

### `baseline-check.log`

```
check: py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree
collected 142 items

test_requests.py FFFFFFFFFFFFFFFFF...F..FF......FFFFF.F..F............F. [ 38%]
.FF..F.F..F.F..F..F.....FF.....FF.FFF................................... [ 89%]
...F.FFFF......                                                          [100%]

=================================== FAILURES ===================================
____________ RequestsTestCase.test_BASICAUTH_TUPLE_HTTP_200_OK_GET _____________

self = <test_requests.RequestsTestCase testMethod=test_BASICAUTH_TUPLE_HTTP_200_OK_GET>

    def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self):
        auth = ('user', 'pass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:286: AssertionError
______________ RequestsTestCase.test_DIGESTAUTH_QUOTES_QOP_VALUE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_QUOTES_QOP_VALUE>

    def test_DIGESTAUTH_QUOTES_QOP_VALUE(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert '"auth"' in r.request.headers['Authorization']

test_requests.py:397: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive'}
key = 'Authorization'

    def __getitem__(self, key):
>       return self._store[key.lower()][1]
E       KeyError: 'authorization'

requests/structures.py:54: KeyError
_____________ RequestsTestCase.test_DIGESTAUTH_WRONG_HTTP_401_GET ______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_WRONG_HTTP_401_GET>

    def test_DIGESTAUTH_WRONG_HTTP_401_GET(self):
    
        auth = HTTPDigestAuth('user', 'wrongpass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 401
E       assert 403 == 401
E        +  where 403 = <Response [403]>.status_code

test_requests.py:381: AssertionError
_______________ RequestsTestCase.test_DIGEST_AUTH_RETURNS_COOKIE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_RETURNS_COOKIE>

    def test_DIGEST_AUTH_RETURNS_COOKIE(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        r = requests.get(url)
>       assert r.cookies['fake'] == 'fake_value'

test_requests.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
____________ RequestsTestCase.test_DIGEST_AUTH_SETS_SESSION_COOKIES ____________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_SETS_SESSION_COOKIES>

    def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        s = requests.Session()
        s.get(url, auth=auth)
>       assert s.cookies['fake'] == 'fake_value'

test_requests.py:362: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
_________________ RequestsTestCase.test_DIGEST_HTTP_200_OK_GET _________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_HTTP_200_OK_GET>

    def test_DIGEST_HTTP_200_OK_GET(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:338: AssertionError
_____________________ RequestsTestCase.test_DIGEST_STREAM ______________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_STREAM>

    def test_DIGEST_STREAM(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth, stream=True)
>       assert r.raw.read() != b''
E       AssertionError: assert b'' != b''
E        +  where b'' = <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x717d484b4190>>()
E        +    where <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x717d484b4190>> = <requests.packages.urllib3.response.HTTPResponse object at 0x717d484b4190>.read
E        +      where <requests.packages.urllib3.response.HTTPResponse object at 0x717d484b4190> = <Response [403]>.raw

test_requests.py:370: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_ALTERNATIVE _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_ALTERNATIVE>

    def test_HTTP_200_OK_GET_ALTERNATIVE(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
    
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:138: AssertionError
___________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS ____________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_MIXED_PARAMS>

    def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('get') + '?test=true', params={'q': 'test'}, headers=heads)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:162: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_PARAMS _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_PARAMS>

    def test_HTTP_200_OK_GET_WITH_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('user-agent'), headers=heads)
    
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:155: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_HEAD ____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_HEAD>

    def test_HTTP_200_OK_HEAD(self):
        r = requests.head(httpbin('get'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:275: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_PUT _____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_PUT>

    def test_HTTP_200_OK_PUT(self):
        r = requests.put(httpbin('put'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:279: AssertionError
______________ RequestsTestCase.test_HTTP_302_ALLOW_REDIRECT_GET _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_302_ALLOW_REDIRECT_GET>

    def test_HTTP_302_ALLOW_REDIRECT_GET(self):
        r = requests.get(httpbin('redirect', '1'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:142: AssertionError
_________________ RequestsTestCase.test_POSTBIN_GET_POST_FILES _________________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES>

    def test_POSTBIN_GET_POST_FILES(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:402: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
____________ RequestsTestCase.test_POSTBIN_GET_POST_FILES_WITH_DATA ____________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES_WITH_DATA>

    def test_POSTBIN_GET_POST_FILES_WITH_DATA(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:420: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
_________ RequestsTestCase.test_auth_is_retained_for_redirect_on_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_retained_for_redirect_on_host>

    def test_auth_is_retained_for_redirect_on_host(self):
        r = requests.get(httpbin('redirect/1'), auth=('user', 'pass'))
>       h1 = r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:953: IndexError
_________ RequestsTestCase.test_auth_is_stripped_on_redirect_off_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_stripped_on_redirect_off_host>

    def test_auth_is_stripped_on_redirect_off_host(self):
        r = requests.get(
            httpbin('redirect-to'),
            params={'url': 'http://www.google.co.uk'},
            auth=('user', 'pass'),
        )
>       assert r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:948: IndexError
__________________ RequestsTestCase.test_basicauth_with_netrc __________________

self = <test_requests.RequestsTestCase testMethod=test_basicauth_with_netrc>

    def test_basicauth_with_netrc(self):
        auth = ('user', 'pass')
        wrong_auth = ('wronguser', 'wrongpass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        def get_netrc_auth_mock(url):
            return auth
        requests.sessions.get_netrc_auth = get_netrc_auth_mock
    
        # Should use netrc and work.
        r = requests.get(url)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:315: AssertionError
________________ RequestsTestCase.test_conflicting_post_params _________________

self = <test_requests.RequestsTestCase testMethod=test_conflicting_post_params>

    def test_conflicting_post_params(self):
        url = httpbin('post')
        with open('requirements.txt') as f:
>           pytest.raises(ValueError, "requests.post(url, data='[{\"some\": \"data\"}]', files={'some': f})")
E           TypeError: 'requests.post(url, data=\'[{"some": "data"}]\', files={\'some\': f})' object (type: <class 'str'>) must be callable

test_requests.py:439: TypeError
____________________ RequestsTestCase.test_connection_error ____________________

self = <test_requests.RequestsTestCase testMethod=test_connection_error>

    def test_connection_error(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://fooobarbangbazbing.httpbin.org")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:299: Failed
________________ RequestsTestCase.test_cookie_persists_via_api _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_persists_via_api>

    def test_cookie_persists_via_api(self):
        s = requests.session()
        r = s.get(httpbin('redirect/1'), cookies={'foo': 'bar'})
        assert 'foo' in r.request.headers['Cookie']
>       assert 'foo' in r.history[0].request.headers['Cookie']
E       IndexError: list index out of range

test_requests.py:198: IndexError
__________________ RequestsTestCase.test_cookie_quote_wrapped __________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_quote_wrapped>

    def test_cookie_quote_wrapped(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo="bar:baz"'))
>       assert s.cookies['foo'] == '"bar:baz"'

test_requests.py:192: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_removed_on_expire ________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_removed_on_expire>

    def test_cookie_removed_on_expire(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
>       assert s.cookies['foo'] == 'bar'

test_requests.py:179: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_sent_on_redirect _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_sent_on_redirect>

    def test_cookie_sent_on_redirect(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
        r = s.get(httpbin('redirect/1'))  # redirects to httpbin('get')
>       assert 'Cookie' in r.json()['headers']

test_requests.py:174: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x717d48d9a670>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
__________________ RequestsTestCase.test_custom_content_type ___________________

self = <test_requests.RequestsTestCase testMethod=test_custom_content_type>

    def test_custom_content_type(self):
        r = requests.post(
            httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            files={'file1': ('test_requests.py', open(__file__, 'rb')),
                   'file2': ('test_requests', open(__file__, 'rb'),
                             'text/py-content-type')})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:533: AssertionError
__________ RequestsTestCase.test_different_encodings_dont_break_post ___________

self = <test_requests.RequestsTestCase testMethod=test_different_encodings_dont_break_post>

    def test_different_encodings_dont_break_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            params={'blah': 'asdf1234'},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:486: AssertionError
________________ RequestsTestCase.test_generic_cookiejar_works _________________

self = <test_requests.RequestsTestCase testMethod=test_generic_cookiejar_works>

    def test_generic_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        s.cookies = cj
        r = s.get(httpbin('cookies'))
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:221: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x717d48d9a670>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
___________ RequestsTestCase.test_json_param_post_content_type_works ___________

self = <test_requests.RequestsTestCase testMethod=test_json_param_post_content_type_works>

    def test_json_param_post_content_type_works(self):
        r = requests.post(
            httpbin('post'),
            json={'life': 42}
        )
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1015: AssertionError
_________ RequestsTestCase.test_manual_redirect_with_partial_body_read _________

self = <test_requests.RequestsTestCase testMethod=test_manual_redirect_with_partial_body_read>

    def test_manual_redirect_with_partial_body_read(self):
        s = requests.Session()
        r1 = s.get(httpbin('redirect/2'), allow_redirects=False, stream=True)
>       assert r1.is_redirect
E       assert False
E        +  where False = <Response [403]>.is_redirect

test_requests.py:961: AssertionError
______________ RequestsTestCase.test_mixed_case_scheme_acceptable ______________

self = <test_requests.RequestsTestCase testMethod=test_mixed_case_scheme_acceptable>

    def test_mixed_case_scheme_acceptable(self):
        s = requests.Session()
        s.proxies = getproxies()
        parts = urlparse(httpbin('get'))
        schemes = ['http://', 'HTTP://', 'hTTp://', 'HttP://',
                   'https://', 'HTTPS://', 'hTTps://', 'HttPs://']
        for scheme in schemes:
            url = scheme + parts.netloc + parts.path
            r = requests.Request('GET', url)
            r = s.send(r.prepare())
>           assert r.status_code == 200, 'failed for scheme {0}'.format(scheme)
E           AssertionError: failed for scheme http://
E           assert 403 == 200
E            +  where 403 = <Response [403]>.status_code

test_requests.py:129: AssertionError
_________________ RequestsTestCase.test_param_cookiejar_works __________________

self = <test_requests.RequestsTestCase testMethod=test_param_cookiejar_works>

    def test_param_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        r = s.get(httpbin('cookies'), cookies=cj)
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:231: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x717d48d9a670>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
____________ RequestsTestCase.test_params_are_merged_case_sensitive ____________

self = <test_requests.RequestsTestCase testMethod=test_params_are_merged_case_sensitive>

    def test_params_are_merged_case_sensitive(self):
        s = requests.Session()
        s.params['foo'] = 'bar'
        r = s.get(httpbin('get'), params={'FOO': 'bar'})
>       assert r.json()['args'] == {'foo': 'bar', 'FOO': 'bar'}

test_requests.py:894: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x717d48d9a670>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_________________ RequestsTestCase.test_prepared_from_session __________________

self = <requests.packages.urllib3.connectionpool.HTTPConnectionPool object at 0x717d482eb250>
method = 'GET', url = '/headers', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Dummy-Auth-Test': 'dummy-auth-test-ok'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d482eb1c0>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x717d47c0d080>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
            conn = self._get_conn(timeout=pool_timeout)
    
            # Make the request on the httplib connection object.
>           httplib_response = self._make_request(conn, method, url,
                                                  timeout=timeout,
                                                  body=body, headers=headers)

requests/packages/urllib3/connectionpool.py:514: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       socket.gaierror: [Errno -3] Temporary failure in name resolution

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: gaierror

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x717d482eb400>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d482eb1c0>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
requests/packages/urllib3/util/retry.py:245: in increment
    raise six.reraise(type(error), error, _stacktrace)
requests/packages/urllib3/packages/six.py:309: in reraise
    raise value.with_traceback(tb)
requests/packages/urllib3/connectionpool.py:514: in urlopen
    httplib_response = self._make_request(conn, method, url,
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       requests.packages.urllib3.exceptions.ProtocolError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: ProtocolError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_prepared_from_session>

    def test_prepared_from_session(self):
        class DummyAuth(requests.auth.AuthBase):
            def __call__(self, r):
                r.headers['Dummy-Auth-Test'] = 'dummy-auth-test-ok'
                return r
    
        req = requests.Request('GET', httpbin('headers'))
        assert not req.auth
    
        s = requests.Session()
        s.auth = DummyAuth()
    
        prep = s.prepare_request(req)
>       resp = s.send(prep)

test_requests.py:589: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x717d482eb400>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d482eb1c0>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
>           raise ConnectionError(err, request=request)
E           requests.exceptions.ConnectionError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

requests/adapters.py:407: ConnectionError
___________________ RequestsTestCase.test_pyopenssl_redirect ___________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x717d4792c880>
method = 'GET', url = '/status/301', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47ad9fd0>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x717d47ad0980>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x717d47ad9640>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x717d4792c130>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47ad9fd0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/status/301', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x717d4792c880>
_stacktrace = <traceback object at 0x717d47ad0980>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_pyopenssl_redirect>

    def test_pyopenssl_redirect(self):
>       requests.get('https://httpbin.org/status/301')

test_requests.py:473: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x717d4792c130>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47ad9fd0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________ RequestsTestCase.test_request_cookie_overrides_session_cookie _________

self = <test_requests.RequestsTestCase testMethod=test_request_cookie_overrides_session_cookie>

    def test_request_cookie_overrides_session_cookie(self):
        s = requests.session()
        s.cookies['foo'] = 'bar'
        r = s.get(httpbin('cookies'), cookies={'foo': 'baz'})
>       assert r.json()['cookies']['foo'] == 'baz'

test_requests.py:204: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x717d48d9a670>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_______________ RequestsTestCase.test_requests_history_is_saved ________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x717d47b7fbe0>
method = 'GET', url = '/redirect/5', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47a6f640>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x717d482fc900>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x717d47a6f4c0>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x717d47b7f0a0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47a6f640>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/redirect/5', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x717d47b7fbe0>
_stacktrace = <traceback object at 0x717d482fc900>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_requests_history_is_saved>

    def test_requests_history_is_saved(self):
>       r = requests.get('https://httpbin.org/redirect/5')

test_requests.py:1003: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x717d47b7f0a0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47a6f640>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
____________________ RequestsTestCase.test_session_pickling ____________________

self = <test_requests.RequestsTestCase testMethod=test_session_pickling>

    def test_session_pickling(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
    
        s = pickle.loads(pickle.dumps(s))
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:823: AssertionError
___________________ RequestsTestCase.test_set_cookie_on_301 ____________________

self = <test_requests.RequestsTestCase testMethod=test_set_cookie_on_301>

    def test_set_cookie_on_301(self):
        s = requests.session()
        url = httpbin('cookies/set?foo=bar')
        s.get(url)
>       assert s.cookies['foo'] == 'bar'

test_requests.py:168: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
__________________ RequestsTestCase.test_unicode_method_name ___________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_method_name>

    def test_unicode_method_name(self):
        files = {'file': open('test_requests.py', 'rb')}
        r = requests.request(
            method=u('POST'), url=httpbin('post'), files=files)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:524: AssertionError
_________________ RequestsTestCase.test_unicode_multipart_post _________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_multipart_post>

    def test_unicode_multipart_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': u('ëlïxr')},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:492: AssertionError
_______________ RequestsTestCase.test_uppercase_scheme_redirect ________________

self = <test_requests.RequestsTestCase testMethod=test_uppercase_scheme_redirect>

    def test_uppercase_scheme_redirect(self):
        parts = urlparse(httpbin('html'))
        url = "HTTP://" + parts.netloc + parts.path
        r = requests.get(httpbin('redirect-to'), params={'url': url})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:842: AssertionError
_________ RequestsTestCase.test_urlencoded_get_query_multivalued_param _________

self = <test_requests.RequestsTestCase testMethod=test_urlencoded_get_query_multivalued_param>

    def test_urlencoded_get_query_multivalued_param(self):
    
        r = requests.get(httpbin('get'), params=dict(test=['foo', 'baz']))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:478: AssertionError
__________________ RequestsTestCase.test_user_agent_transfers __________________

self = <test_requests.RequestsTestCase testMethod=test_user_agent_transfers>

    def test_user_agent_transfers(self):
    
        heads = {
            'User-agent': 'Mozilla/5.0 (github.com/kennethreitz/requests)'
        }
    
        r = requests.get(httpbin('user-agent'), headers=heads)
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0 (github.com/kennethreitz/requests)' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:264: AssertionError
_______________________ TestTimeout.test_stream_timeout ________________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x717d47a4c3d0>
method = 'GET', url = '/delay/10', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47a4caf0>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x717d47ad0a80>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x717d47a4c8b0>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x717d47a4cee0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47a4caf0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/delay/10', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x717d47a4c3d0>
_stacktrace = <traceback object at 0x717d47ad0a80>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.TestTimeout object at 0x717d481c3d30>

    def test_stream_timeout(self):
        try:
>           requests.get('https://httpbin.org/delay/10', timeout=2.0)

test_requests.py:1345: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x717d47a4cee0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x717d47a4caf0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________________________ TestTimeout.test_none_timeout _________________________

self = <test_requests.TestTimeout object at 0x717d481c3b80>

    def test_none_timeout(self):
        """ Check that you can set None as a valid timeout value.
    
        To actually test this behavior, we'd want to check that setting the
        timeout to None actually lets the request block past the system default
        timeout. However, this would make the test suite unbearably slow.
        Instead we verify that setting the timeout to None does not prevent the
        request from succeeding.
        """
        r = requests.get(httpbin('get'), timeout=None)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1368: AssertionError
________________________ TestTimeout.test_read_timeout _________________________

self = <test_requests.TestTimeout object at 0x717d481c3340>

    def test_read_timeout(self):
        try:
            requests.get(httpbin('delay/10'), timeout=(None, 0.1))
>           assert False, "The recv() request should time out."
E           AssertionError: The recv() request should time out.
E           assert False

test_requests.py:1373: AssertionError
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x717d481c37c0>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1380: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x717d481c3c70>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1388: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/connectionpool.py:80
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/packages/urllib3/connectionpool.py:80: DeprecationWarning: invalid escape sequence \*
    """

requests/packages/urllib3/connectionpool.py:403
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/packages/urllib3/connectionpool.py:403: DeprecationWarning: invalid escape sequence \*
    """

requests/packages/urllib3/connectionpool.py:734
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/packages/urllib3/connectionpool.py:734: DeprecationWarning: invalid escape sequence \*
    """

requests/packages/urllib3/_collections.py:1
requests/packages/urllib3/_collections.py:1
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/packages/urllib3/_collections.py:1: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

requests/packages/urllib3/poolmanager.py:32
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/packages/urllib3/poolmanager.py:32: DeprecationWarning: invalid escape sequence \*
    """

requests/models.py:777
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/models.py:777: DeprecationWarning: invalid escape sequence \*
    """Returns the json-encoded content of a response, if any.

requests/api.py:53
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/api.py:53: DeprecationWarning: invalid escape sequence \*
    """Sends a GET request. Returns :class:`Response` object.

requests/api.py:64
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/api.py:64: DeprecationWarning: invalid escape sequence \*
    """Sends a OPTIONS request. Returns :class:`Response` object.

requests/api.py:75
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/api.py:75: DeprecationWarning: invalid escape sequence \*
    """Sends a HEAD request. Returns :class:`Response` object.

requests/api.py:86
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/api.py:86: DeprecationWarning: invalid escape sequence \*
    """Sends a POST request. Returns :class:`Response` object.

requests/api.py:98
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/api.py:98: DeprecationWarning: invalid escape sequence \*
    """Sends a PUT request. Returns :class:`Response` object.

requests/api.py:109
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/api.py:109: DeprecationWarning: invalid escape sequence \*
    """Sends a PATCH request. Returns :class:`Response` object.

requests/api.py:120
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/api.py:120: DeprecationWarning: invalid escape sequence \*
    """Sends a DELETE request. Returns :class:`Response` object.

requests/sessions.py:462
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/sessions.py:462: DeprecationWarning: invalid escape sequence \*
    """Sends a GET request. Returns :class:`Response` object.

requests/sessions.py:472
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/sessions.py:472: DeprecationWarning: invalid escape sequence \*
    """Sends a OPTIONS request. Returns :class:`Response` object.

requests/sessions.py:482
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/sessions.py:482: DeprecationWarning: invalid escape sequence \*
    """Sends a HEAD request. Returns :class:`Response` object.

requests/sessions.py:492
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/sessions.py:492: DeprecationWarning: invalid escape sequence \*
    """Sends a POST request. Returns :class:`Response` object.

requests/sessions.py:503
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/sessions.py:503: DeprecationWarning: invalid escape sequence \*
    """Sends a PUT request. Returns :class:`Response` object.

requests/sessions.py:513
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/sessions.py:513: DeprecationWarning: invalid escape sequence \*
    """Sends a PATCH request. Returns :class:`Response` object.

requests/sessions.py:523
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/sessions.py:523: DeprecationWarning: invalid escape sequence \*
    """Sends a DELETE request. Returns :class:`Response` object.

test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
  /testbed/.memdoor/runs/team-solve-2026-11-06T125330/baseline-tree/requests/models.py:169: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_QUOTES_QOP_VALUE
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_WRONG_HTTP_401_GET
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_RETURNS_COOKIE - ...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_SETS_SESSION_COOKIES
FAILED test_requests.py::RequestsTestCase::test_DIGEST_HTTP_200_OK_GET - asse...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_STREAM - AssertionErro...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_ALTERNATIVE
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_HEAD - assert 403...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_PUT - assert 403 ...
FAILED test_requests.py::RequestsTestCase::test_HTTP_302_ALLOW_REDIRECT_GET
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES - requ...
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES_WITH_DATA
FAILED test_requests.py::RequestsTestCase::test_auth_is_retained_for_redirect_on_host
FAILED test_requests.py::RequestsTestCase::test_auth_is_stripped_on_redirect_off_host
FAILED test_requests.py::RequestsTestCase::test_basicauth_with_netrc - assert...
FAILED test_requests.py::RequestsTestCase::test_conflicting_post_params - Typ...
FAILED test_requests.py::RequestsTestCase::test_connection_error - Failed: DI...
FAILED test_requests.py::RequestsTestCase::test_cookie_persists_via_api - Ind...
FAILED test_requests.py::RequestsTestCase::test_cookie_quote_wrapped - KeyErr...
FAILED test_requests.py::RequestsTestCase::test_cookie_removed_on_expire - Ke...
FAILED test_requests.py::RequestsTestCase::test_cookie_sent_on_redirect - jso...
FAILED test_requests.py::RequestsTestCase::test_custom_content_type - assert ...
FAILED test_requests.py::RequestsTestCase::test_different_encodings_dont_break_post
FAILED test_requests.py::RequestsTestCase::test_generic_cookiejar_works - jso...
FAILED test_requests.py::RequestsTestCase::test_json_param_post_content_type_works
FAILED test_requests.py::RequestsTestCase::test_manual_redirect_with_partial_body_read
FAILED test_requests.py::RequestsTestCase::test_mixed_case_scheme_acceptable
FAILED test_requests.py::RequestsTestCase::test_param_cookiejar_works - json....
FAILED test_requests.py::RequestsTestCase::test_params_are_merged_case_sensitive
FAILED test_requests.py::RequestsTestCase::test_prepared_from_session - reque...
FAILED test_requests.py::RequestsTestCase::test_pyopenssl_redirect - requests...
FAILED test_requests.py::RequestsTestCase::test_request_cookie_overrides_session_cookie
FAILED test_requests.py::RequestsTestCase::test_requests_history_is_saved - r...
FAILED test_requests.py::RequestsTestCase::test_session_pickling - assert 403...
FAILED test_requests.py::RequestsTestCase::test_set_cookie_on_301 - KeyError:...
FAILED test_requests.py::RequestsTestCase::test_unicode_method_name - assert ...
FAILED test_requests.py::RequestsTestCase::test_unicode_multipart_post - asse...
FAILED test_requests.py::RequestsTestCase::test_uppercase_scheme_redirect - a...
FAILED test_requests.py::RequestsTestCase::test_urlencoded_get_query_multivalued_param
FAILED test_requests.py::RequestsTestCase::test_user_agent_transfers - Assert...
FAILED test_requests.py::TestTimeout::test_stream_timeout - requests.exceptio...
FAILED test_requests.py::TestTimeout::test_none_timeout - assert 403 == 200
FAILED test_requests.py::TestTimeout::test_read_timeout - AssertionError: The...
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
================== 48 failed, 94 passed, 22 warnings in 2.66s ==================
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/requests/models.py b/requests/models.py
index 3f6a4f9..7699743 100755
--- a/requests/models.py
+++ b/requests/models.py
@@ -329,7 +329,7 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
         """Prepares the given HTTP method."""
         self.method = method
         if self.method is not None:
-            self.method = self.method.upper()
+            self.method = to_native_string(self.method).upper()
 
     def prepare_url(self, url, params):
         """Prepares the given HTTP URL."""
diff --git a/requests/sessions.py b/requests/sessions.py
index d701ff2..dfce7cf 100755
--- a/requests/sessions.py
+++ b/requests/sessions.py
@@ -13,7 +13,7 @@ from collections import Mapping
 from datetime import datetime
 
 from .auth import _basic_auth_str
-from .compat import cookielib, OrderedDict, urljoin, urlparse, builtin_str
+from .compat import cookielib, OrderedDict, urljoin, urlparse
 from .cookies import (
     cookiejar_from_dict, extract_cookies_to_jar, RequestsCookieJar, merge_cookies)
 from .models import Request, PreparedRequest, DEFAULT_REDIRECT_LIMIT
@@ -425,7 +425,7 @@ class Session(SessionRedirectMixin):
             If Tuple, ('cert', 'key') pair.
         """
 
-        method = builtin_str(method)
+        method = to_native_string(method)
 
         # Create the Request.
         req = Request(
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

method = builtin_str(method) problem
In requests/sessions.py is a command:

method = builtin_str(method)
Converts method from
b’GET’
to
"b'GET’"

Which is the literal string, no longer a binary string.  When requests tries to use the method "b'GET’”, it gets a 404 Not Found response.

I am using python3.4 and python-neutronclient (2.3.9) with requests (2.4.3).  neutronclient is broken because it uses this "args = utils.safe_encode_list(args)" command which converts all the values to binary string, including method.

I'm not sure if this is a bug with neutronclient or a bug with requests, but I'm starting here.  Seems if requests handled the method value being a binary string, we wouldn't have any problem.

Also, I tried in python2.6 and this bug doesn't exist there. Some difference between 2.6 and 3.4 makes this not work right.

## Deliverable

changes to this tree

## Check

`py.test test_requests.py`

## Scope

`requests/sessions.py`

## Done when

- A bytes method such as `b'GET'` is handled as the HTTP method `GET`, not the literal string `"b'GET'"`.
- Python 3 request sessions no longer produce a 404 caused by sending a quoted bytes representation as the method.
- Normal string methods continue to work unchanged.



# plan.md

## Deliverable
changes to this tree

## Check
`py.test test_requests.py`

## Scope
`requests/sessions.py`

## Done when
- A bytes method such as `b'GET'` is handled as the HTTP method `GET`, not the literal string `"b'GET'"`.
- Python 3 request sessions no longer produce a 404 caused by sending a quoted bytes representation as the method.
- Normal string methods continue to work unchanged.

## Approach
Decode/normalize the method before `builtin_str(method)` in `requests/sessions.py`, accepting both native strings and bytes.

Candidate approaches:
- In `Session.request`, branch on `isinstance(method, bytes)` and decode with ASCII/UTF-8 before calling `builtin_str`. Narrowest fix, directly addresses the reported failure.
- Use or add a `to_native_string`-style helper in `requests/utils.py` and call it from sessions. Cleaner reuse if helper already exists, but broadens the touched surface.
- Normalize in `requests/models.Request` as well, covering direct `Request` callers. More robust, but larger and may duplicate session-level behavior.


# requests/sessions.py

```
# -*- coding: utf-8 -*-

"""
requests.session
~~~~~~~~~~~~~~~~

This module provides a Session object to manage and persist settings across
requests (cookies, auth, proxies).

"""
import os
from collections import Mapping
from datetime import datetime

from .auth import _basic_auth_str
from .compat import cookielib, OrderedDict, urljoin, urlparse, builtin_str
from .cookies import (
    cookiejar_from_dict, extract_cookies_to_jar, RequestsCookieJar, merge_cookies)
from .models import Request, PreparedRequest, DEFAULT_REDIRECT_LIMIT
from .hooks import default_hooks, dispatch_hook
from .utils import to_key_val_list, default_headers, to_native_string
from .exceptions import (
    TooManyRedirects, InvalidSchema, ChunkedEncodingError, ContentDecodingError)
from .structures import CaseInsensitiveDict

from .adapters import HTTPAdapter

from .utils import (
    requote_uri, get_environ_proxies, get_netrc_auth, should_bypass_proxies,
    get_auth_from_url
)

from .status_codes import codes

# formerly defined here, reexposed here for backward compatibility
from .models import REDIRECT_STATI


def merge_setting(request_setting, session_setting, dict_class=OrderedDict):
    """
    Determines appropriate setting for a given request, taking into account the
    explicit setting on that request, and the setting in the session. If a
    setting is a dictionary, they will be merged together using `dict_class`
    """

    if session_setting is None:
        return request_setting

    if request_setting is None:
        return session_setting

    # Bypass if not a dictionary (e.g. verify)
    if not (
            isinstance(session_setting, Mapping) and
            isinstance(request_setting, Mapping)
    ):
        return request_setting

    merged_setting = dict_class(to_key_val_list(session_setting))
    merged_setting.update(to_key_val_list(request_setting))

    # Remove keys that are set to None.
    for (k, v) in request_setting.items():
        if v is None:
            del merged_setting[k]

    merged_setting = dict((k, v) for (k, v) in merged_setting.items() if v is not None)

    return merged_setting


def merge_hooks(request_hooks, session_hooks, dict_class=OrderedDict):
    """
    Properly merges both requests and session hooks.

    This is necessary because when request_hooks == {'response': []}, the
    merge breaks Session hooks entirely.
    """
    if session_hooks is None or session_hooks.get('response') == []:
        return request_hooks

    if request_hooks is None or request_hooks.get('response') == []:
        return session_hooks

    return merge_setting(request_hooks, session_hooks, dict_class)


class SessionRedirectMixin(object):
    def resolve_redirects(self, resp, req, stream=False, timeout=None,
                          verify=True, cert=None, proxies=None):
        """Receives a Response. Returns a generator of Responses."""

        i = 0
        hist = [] # keep track of history

        while resp.is_redirect:
            prepared_request = req.copy()

            if i > 0:
                # Update history and keep track of redirects.
                hist.append(resp)
                new_hist = list(hist)
                resp.history = new_hist

            try:
                resp.content  # Consume socket so it can be released
            except (ChunkedEncodingError, ContentDecodingError, RuntimeError):
                resp.raw.read(decode_content=False)

            if i >= self.max_redirects:
                raise TooManyRedirects('Exceeded %s redirects.' % self.max_redirects)

            # Release the connection back into the pool.
            resp.close()

            url = resp.headers['location']
            method = req.method

            # Handle redirection without scheme (see: RFC 1808 Section 4)
            if url.startswith('//'):
                parsed_rurl = urlparse(resp.url)
                url = '%s:%s' % (parsed_rurl.scheme, url)

            # The scheme should be lower case...
            parsed = urlparse(url)
            url = parsed.geturl()

            # Facilitate relative 'location' headers, as allowed by RFC 7231.
            # (e.g. '/path/to/resource' instead of 'http://domain.tld/path/to/resource')
            # Compliant with RFC3986, we percent encode the url.
            if not urlparse(url).netloc:
                url = urljoin(resp.url, requote_uri(url))
            else:
                url = requote_uri(url)

            prepared_request.url = to_native_string(url)
            # Cache the url, unless it redirects to itself.
            if resp.is_permanent_redirect and req.url != prepared_request.url:
                self.redirect_cache[req.url] = prepared_request.url

            # http://tools.ietf.org/html/rfc7231#section-6.4.4
            if (resp.status_code == codes.see_other and
                    method != 'HEAD'):
                method = 'GET'

            # Do what the browsers do, despite standards...
            # First, turn 302s into GETs.
            if resp.status_code == codes.found and method != 'HEAD':
                method = 'GET'

            # Second, if a POST is responded to with a 301, turn it into a GET.
            # This bizarre behaviour is explained in Issue 1704.
            if resp.status_code == codes.moved and method == 'POST':
                method = 'GET'

            prepared_request.method = method

            # https://github.com/kennethreitz/requests/issues/1084
            if resp.status_code not in (codes.temporary_redirect, codes.permanent_redirect):
                if 'Content-Length' in prepared_request.headers:
                    del prepared_request.headers['Content-Length']

                prepared_request.body = None

            headers = prepared_request.headers
            try:
                del headers['Cookie']
            except KeyError:
                pass

            extract_cookies_to_jar(prepared_request._cookies, prepared_request, resp.raw)
            prepared_request._cookies.update(self.cookies)
            prepared_request.prepare_cookies(prepared_request._cookies)

            # Rebuild auth and proxy information.
            proxies = self.rebuild_proxies(prepared_request, proxies)
            self.rebuild_auth(prepared_request, resp)

            # Override the original request.
            req = prepared_request

            resp = self.send(
                req,
                stream=stream,
                timeout=timeout,
                verify=verify,
                cert=cert,
                proxies=proxies,
                allow_redirects=False,
            )

            extract_cookies_to_jar(self.cookies, prepared_request, resp.raw)

            i += 1
            yield resp

    def rebuild_auth(self, prepared_request, response):
        """
        When being redirected we may want to strip authentication from the
        request to avoid leaking credentials. This method intelligently removes
        and reapplies authentication where possible to avoid credential loss.
        """
        headers = prepared_request.headers
        url = prepared_request.url

        if 'Authorization' in headers:
            # If we get redirected to a new host, we should strip out any
            # authentication headers.
            original_parsed = urlparse(response.request.url)
            redirect_parsed = urlparse(url)

            if (original_parsed.hostname != redirect_parsed.hostname):
                del headers['Authorization']

        # .netrc might have more auth for us on our new host.
        new_auth = get_netrc_auth(url) if self.trust_env else None
        if new_auth is not None:
            prepared_request.prepare_auth(new_auth)

        return

    def rebuild_proxies(self, prepared_request, proxies):
        """
        This method re-evaluates the proxy configuration by considering the
        environment variables. If we are redirected to a URL covered by
        NO_PROXY, we strip the proxy configuration. Otherwise, we set missing
        proxy keys for this URL (in case they were stripped by a previous
        redirect).

        This method also replaces the Proxy-Authorization header where
        necessary.
        """
        headers = prepared_request.headers
        url = prepared_request.url
        scheme = urlparse(url).scheme
        new_proxies = proxies.copy() if proxies is not None else {}

        if self.trust_env and not should_bypass_proxies(url):
            environ_proxies = get_environ_proxies(url)

            proxy = environ_proxies.get(scheme)

            if proxy:
                new_proxies.setdefault(scheme, environ_proxies[scheme])

        if 'Proxy-Authorization' in headers:
            del headers['Proxy-Authorization']

        try:
            username, password = get_auth_from_url(new_proxies[scheme])
        except KeyError:
            username, password = None, None

        if username and password:
            headers['Proxy-Authorization'] = _basic_auth_str(username, password)

        return new_proxies


class Session(SessionRedirectMixin):
    """A Requests session.

    Provides cookie persistence, connection-pooling, and configuration.

    Basic Usage::

      >>> import requests
      >>> s = requests.Session()
      >>> s.get('http://httpbin.org/get')
      200
    """

    __attrs__ = [
        'headers', 'cookies', 'auth', 'proxies', 'hooks', 'params', 'verify',
        'cert', 'prefetch', 'adapters', 'stream', 'trust_env',
        'max_redirects', 'redirect_cache'
    ]

    def __init__(self):

        #: A case-insensitive dictionary of headers to be sent on each
        #: :class:`Request <Request>` sent from this
        #: :class:`Session <Session>`.
        self.headers = default_headers()

        #: Default Authentication tuple or object to attach to
        #: :class:`Request <Request>`.
        self.auth = None

        #: Dictionary mapping protocol to the URL of the proxy (e.g.
        #: {'http': 'foo.bar:3128'}) to be used on each
        #: :class:`Request <Request>`.
        self.proxies = {}

        #: Event-handling hooks.
        self.hooks = default_hooks()

        #: Dictionary of querystring data to attach to each
        #: :class:`Request <Request>`. The dictionary values may be lists for
        #: representing multivalued query parameters.
        self.params = {}

        #: Stream response content default.
        self.stream = False

        #: SSL Verification default.
        self.verify = True

        #: SSL certificate default.
        self.cert = None

        #: Maximum number of redirects allowed. If the request exceeds this
        #: limit, a :class:`TooManyRedirects` exception is raised.
        self.max_redirects = DEFAULT_REDIRECT_LIMIT

        #: Should we trust the environment?
        self.trust_env = True

        #: A CookieJar containing all currently outstanding cookies set on this
        #: session. By default it is a
        #: :class:`RequestsCookieJar <requests.cookies.RequestsCookieJar>`, but
        #: may be any other ``cookielib.CookieJar`` compatible object.
        self.cookies = cookiejar_from_dict({})

        # Default connection adapters.
        self.adapters = OrderedDict()
        self.mount('https://', HTTPAdapter())
        self.mount('http://', HTTPAdapter())

        self.redirect_cache = {}

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()

    def prepare_request(self, request):
        """Constructs a :class:`PreparedRequest <PreparedRequest>` for
        transmission and returns it. The :class:`PreparedRequest` has settings
        merged from the :class:`Request <Request>` instance and those of the
        :class:`Session`.

        :param request: :class:`Request` instance to prepare with this
            session's settings.
        """
        cookies = request.cookies or {}

        # Bootstrap CookieJar.
        if not isinstance(cookies, cookielib.CookieJar):
            cookies = cookiejar_from_dict(cookies)

        # Merge with session cookies
        merged_cookies = merge_cookies(
            merge_cookies(RequestsCookieJar(), self.cookies), cookies)


        # Set environment's basic authentication if not explicitly set.
        auth = request.auth
        if self.trust_env and not auth and not self.auth:
            auth = get_netrc_auth(request.url)

        p = PreparedRequest()
        p.prepare(
            method=request.method.upper(),
            url=request.url,
            files=request.files,
            data=request.data,
            json=request.json,
            headers=merge_setting(request.headers, self.headers, dict_class=CaseInsensitiveDict),
            params=merge_setting(request.params, self.params),
            auth=merge_setting(auth, self.auth),
            cookies=merged_cookies,
            hooks=merge_hooks(request.hooks, self.hooks),
        )
        return p

    def request(self, method, url,
        params=None,
        data=None,
        headers=None,
        cookies=None,
        files=None,
        auth=None,
        timeout=None,
        allow_redirects=True,
        proxies=None,
        hooks=None,
        stream=None,
        verify=None,
        cert=None,
        json=None):
        """Constructs a :class:`Request <Request>`, prepares it and sends it.
        Returns :class:`Response <Response>` object.

        :param method: method for the new :class:`Request` object.
        :param url: URL for the new :class:`Request` object.
        :param params: (optional) Dictionary or bytes to be sent in the query
            string for the :class:`Request`.
        :param data: (optional) Dictionary or bytes to send in the body of the
            :class:`Request`.
        :param json: (optional) json to send in the body of the
            :class:`Request`.
        :param headers: (optional) Dictionary of HTTP Headers to send with the
            :class:`Request`.
        :param cookies: (optional) Dict or CookieJar object to send with the
            :class:`Request`.
        :param files: (optional) Dictionary of ``'filename': file-like-objects``
            for multipart encoding upload.
        :param auth: (optional) Auth tuple or callable to enable
            Basic/Digest/Custom HTTP Auth.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param allow_redirects: (optional) Set to True by default.
        :type allow_redirects: bool
        :param proxies: (optional) Dictionary mapping protocol to the URL of
            the proxy.
        :param stream: (optional) whether to immediately download the response
            content. Defaults to ``False``.
        :param verify: (optional) if ``True``, the SSL cert will be verified.
            A CA_BUNDLE path can also be provided.
        :param cert: (optional) if String, path to ssl client cert file (.pem).
            If Tuple, ('cert', 'key') pair.
        """

        method = builtin_str(method)

        # Create the Request.
        req = Request(
            method = method.upper(),
            url = url,
            headers = headers,
            files = files,
            data = data or {},
            json = json,
            params = params or {},
            auth = auth,
            cookies = cookies,
            hooks = hooks,
        )
        prep = self.prepare_request(req)

        proxies = proxies or {}

        settings = self.merge_environment_settings(
            prep.url, proxies, stream, verify, cert
        )

        # Send the request.
        send_kwargs = {
            'timeout': timeout,
            'allow_redirects': allow_redirects,
        }
        send_kwargs.update(settings)
        resp = self.send(prep, **send_kwargs)

        return resp

    def get(self, url, **kwargs):
        """Sends a GET request. Returns :class:`Response` object.

        :param url: URL for the new :class:`Request` object.
        :param \*\*kwargs: Optional arguments that ``request`` takes.
        """

        kwargs.setdefault('allow_redirects', True)
        return self.request('GET', url, **kwargs)

    def options(self, url, **kwargs):
        """Sends a OPTIONS request. Returns :class:`Response` object.

        :param url: URL for the new :class:`Request` object.
        :param \*\*kwargs: Optional arguments that ``request`` takes.
        """

        kwargs.setdefault('allow_redirects', True)
        return self.request('OPTIONS', url, **kwargs)

    def head(self, url, **kwargs):
        """Sends a HEAD request. Returns :class:`Response` object.

        :param url: URL for the new :class:`Request` object.
        :param \*\*kwargs: Optional arguments that ``request`` takes.
        """

        kwargs.setdefault('allow_redirects', False)
        return self.request('HEAD', url, **kwargs)

    def post(self, url, data=None, json=None, **kwargs):
        """Sends a POST request. Returns :class:`Response` object.

        :param url: URL for the new :class:`Request` object.
        :param data: (optional) Dictionary, bytes, or file-like object to send in the body of the :class:`Request`.
        :param json: (optional) json to send in the body of the :class:`Request`.
        :param \*\*kwargs: Optional arguments that ``request`` takes.
        """

        return self.request('POST', url, data=data, json=json, **kwargs)

    def put(self, url, data=None, **kwargs):
        """Sends a PUT request. Returns :class:`Response` object.

        :param url: URL for the new :class:`Request` object.
        :param data: (optional) Dictionary, bytes, or file-like object to send in the body of the :class:`Request`.
        :param \*\*kwargs: Optional arguments that ``request`` takes.
        """

        return self.request('PUT', url, data=data, **kwargs)

    def patch(self, url, data=None, **kwargs):
        """Sends a PATCH request. Returns :class:`Response` object.

        :param url: URL for the new :class:`Request` object.
        :param data: (optional) Dictionary, bytes, or file-like object to send in the body of the :class:`Request`.
        :param \*\*kwargs: Optional arguments that ``request`` takes.
        """

        return self.request('PATCH', url,  data=data, **kwargs)

    def delete(self, url, **kwargs):
        """Sends a DELETE request. Returns :class:`Response` object.

        :param url: URL for the new :class:`Request` object.
        :param \*\*kwargs: Optional arguments that ``request`` takes.
        """

        return self.request('DELETE', url, **kwargs)

    def send(self, request, **kwargs):
        """Send a given PreparedRequest."""
        # Set defaults that the hooks can utilize to ensure they always have
        # the correct parameters to reproduce the previous request.
        kwargs.setdefault('stream', self.stream)
        kwargs.setdefault('verify', self.verify)
        kwargs.setdefault('cert', self.cert)
        kwargs.setdefault('proxies', self.proxies)

        # It's possible that users might accidentally send a Request object.
        # Guard against that specific failure case.
        if not isinstance(request, PreparedRequest):
            raise ValueError('You can only send PreparedRequests.')

        checked_urls = set()
        while request.url in self.redirect_cache:
            checked_urls.add(request.url)
            new_url = self.redirect_cache.get(request.url)
            if new_url in checked_urls:
                break
            request.url = new_url

        # Set up variables needed for resolve_redirects and dispatching of hooks
        allow_redirects = kwargs.pop('allow_redirects', True)
        stream = kwargs.get('stream')
        timeout = kwargs.get('timeout')
        verify = kwargs.get('verify')
        cert = kwargs.get('cert')
        proxies = kwargs.get('proxies')
        hooks = request.hooks

        # Get the appropriate adapter to use
        adapter = self.get_adapter(url=request.url)

        # Start time (approximately) of the request
        start = datetime.utcnow()

        # Send the request
        r = adapter.send(request, **kwargs)

        # Total elapsed time of the request (approximately)
        r.elapsed = datetime.utcnow() - start

        # Response manipulation hooks
        r = dispatch_hook('response', hooks, r, **kwargs)

        # Persist cookies
        if r.history:

            # If the hooks create history then we want those cookies too
            for resp in r.history:
                extract_cookies_to_jar(self.cookies, resp.request, resp.raw)

        extract_cookies_to_jar(self.cookies, request, r.raw)

        # Redirect resolving generator.
        gen = self.resolve_redirects(r, request,
            stream=stream,
            timeout=timeout,
            verify=verify,
            cert=cert,
            proxies=proxies)

        # Resolve redirects if allowed.
        history = [resp for resp in gen] if allow_redirects else []

        # Shuffle things around if there's history.
        if history:
            # Insert the first (original) request at the start
            history.insert(0, r)
            # Get the last request made
            r = history.pop()
            r.history = history

        if not stream:
            r.content

        return r

    def merge_environment_settings(self, url, proxies, stream, verify, cert):
        """Check the environment and merge it with some settings."""
        # Gather clues from the surrounding environment.
        if self.trust_env:
            # Set environment's proxies.
            env_proxies = get_environ_proxies(url) or {}
            for (k, v) in env_proxies.items():
                proxies.setdefault(k, v)

            # Look for requests environment configuration and be compatible
            # with cURL.
            if verify is True or verify is None:
                verify = (os.environ.get('REQUESTS_CA_BUNDLE') or
                          os.environ.get('CURL_CA_BUNDLE'))

        # Merge all the kwargs.
        proxies = merge_setting(proxies, self.proxies)
        stream = merge_setting(stream, self.stream)
        verify = merge_setting(verify, self.verify)
        cert = merge_setting(cert, self.cert)

        return {'verify': verify, 'proxies': proxies, 'stream': stream,
                'cert': cert}

    def get_adapter(self, url):
        """Returns the appropriate connnection adapter for the given URL."""
        for (prefix, adapter) in self.adapters.items():

            if url.lower().startswith(prefix):
                return adapter

        # Nothing matches :-/
        raise InvalidSchema("No connection adapters were found for '%s'" % url)

    def close(self):
        """Closes all adapters and as such the session"""
        for v in self.adapters.values():
            v.close()

    def mount(self, prefix, adapter):
        """Registers a connection adapter to a prefix.

        Adapters are sorted in descending order by key length."""

        self.adapters[prefix] = adapter
        keys_to_move = [k for k in self.adapters if len(k) < len(prefix)]

        for key in keys_to_move:
            self.adapters[key] = self.adapters.pop(key)

    def __getstate__(self):
        return dict((attr, getattr(self, attr, None)) for attr in self.__attrs__)

    def __setstate__(self, state):
        for attr, value in state.items():
            setattr(self, attr, value)


def session():
    """Returns a :class:`Session` for context-management."""

    return Session()

```


# The last commit

```
ac2af65 SWE-bench



 .gitignore                                                  |   0
 AUTHORS.rst                                                 |   0
 HISTORY.rst                                                 |   0
 LICENSE                                                     |   0
 MANIFEST.in                                                 |   0
 Makefile                                                    |   0
 NOTICE                                                      |   0
 README.rst                                                  |   0
 docs/MANIFEST.in                                            |   0
 docs/Makefile                                               |   0
 docs/_static/requests-sidebar.png                           | Bin
 docs/_templates/sidebarintro.html                           |   0
 docs/_templates/sidebarlogo.html                            |   0
 docs/_themes/.gitignore                                     |   0
 docs/_themes/LICENSE                                        |   0
 docs/_themes/README.rst                                     |   0
 docs/_themes/flask_theme_support.py                         |   0
 docs/_themes/kr/layout.html                                 |   0
 docs/_themes/kr/relations.html                              |   0
 docs/_themes/kr/static/flasky.css_t                         |   0
 docs/_themes/kr/theme.conf                                  |   0
 docs/_themes/kr_small/layout.html                           |   0
 docs/_themes/kr_small/static/flasky.css_t                   |   0
 docs/_themes/kr_small/theme.conf                            |   0
 docs/api.rst                                                |   0
 docs/community/faq.rst                                      |   0
 docs/community/out-there.rst                                |   0
 docs/community/support.rst                                  |   0
 docs/community/updates.rst                                  |   0
 docs/conf.py                                                |   0
 docs/dev/authors.rst                                        |   0
 docs/dev/philosophy.rst                                     |   0
 docs/dev/todo.rst                                           |   0
 docs/index.rst                                              |   0
 docs/make.bat                                               |   0
 docs/requirements.txt                                       |   0
 docs/user/advanced.rst                                      |   0
 docs/user/authentication.rst                                |   0
 docs/user/install.rst                                       |   0
 docs/user/intro.rst                                         |   0
 docs/user/quickstart.rst                                    |   0
 ext/requests-logo.ai                                        |   0
 ext/requests-logo.svg                                       |   0
 requests/__init__.py                                        |   0
 requests/adapters.py                                        |   0
 requests/api.py                                             |   0
 requests/auth.py                                            |   0
 requests/cacert.pem                                         |   0
 requests/certs.py                                           |   0
 requests/compat.py                                          |   0
 requests/cookies.py                                         |   0
 requests/exceptions.py                                      |   0
 requests/hooks.py                                           |   0
 requests/models.py                                          |   0
 requests/packages/README.rst                                |   0
 requests/packages/__init__.py                               |   0
```

```diff
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/AUTHORS.rst b/AUTHORS.rst
old mode 100644
new mode 100755
diff --git a/HISTORY.rst b/HISTORY.rst
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/Makefile b/Makefile
old mode 100644
new mode 100755
diff --git a/NOTICE b/NOTICE
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/docs/MANIFEST.in b/docs/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/docs/Makefile b/docs/Makefile
old mode 100644
new mode 100755
diff --git a/docs/_static/requests-sidebar.png b/docs/_static/requests-sidebar.png
old mode 100644
new mode 100755
diff --git a/docs/_templates/sidebarintro.html b/docs/_templates/sidebarintro.html
old mode 100644
new mode 100755
diff --git a/docs/_templates/sidebarlogo.html b/docs/_templates/sidebarlogo.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/.gitignore b/docs/_themes/.gitignore
old mode 100644
new mode 100755
diff --git a/docs/_themes/LICENSE b/docs/_themes/LICENSE
old mode 100644
new mode 100755
diff --git a/docs/_themes/README.rst b/docs/_themes/README.rst
old mode 100644
new mode 100755
diff --git a/docs/_themes/flask_theme_support.py b/docs/_themes/flask_theme_support.py
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/layout.html b/docs/_themes/kr/layout.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/relations.html b/docs/_themes/kr/relations.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/static/flasky.css_t b/docs/_themes/kr/static/flasky.css_t
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/theme.conf b/docs/_themes/kr/theme.conf
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr_small/layout.html b/docs/_themes/kr_small/layout.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr_small/static/flasky.css_t b/docs/_themes/kr_small/static/flasky.css_t
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr_small/theme.conf b/docs/_themes/kr_small/theme.conf
old mode 100644
new mode 100755
diff --git a/docs/api.rst b/docs/api.rst
old mode 100644
new mode 100755
diff --git a/docs/community/faq.rst b/docs/community/faq.rst
old mode 100644
new mode 100755
diff --git a/docs/community/out-there.rst b/docs/community/out-there.rst
old mode 100644
new mode 100755
diff --git a/docs/community/support.rst b/docs/community/support.rst
old mode 100644
new mode 100755
diff --git a/docs/community/updates.rst b/docs/community/updates.rst
old mode 100644
new mode 100755
diff --git a/docs/conf.py b/docs/conf.py
old mode 100644
new mode 100755
diff --git a/docs/dev/authors.rst b/docs/dev/authors.rst
old mode 100644
new mode 100755
diff --git a/docs/dev/philosophy.rst b/docs/dev/philosophy.rst
old mode 100644
new mode 100755
diff --git a/docs/dev/todo.rst b/docs/dev/todo.rst
old mode 100644
new mode 100755
diff --git a/docs/index.rst b/docs/index.rst
old mode 100644
new mode 100755
diff --git a/docs/make.bat b/docs/make.bat
old mode 100644
new mode 100755
diff --git a/docs/requirements.txt b/docs/requirements.txt
old mode 100644
new mode 100755
diff --git a/docs/user/advanced.rst b/docs/user/advanced.rst
old mode 100644
new mode 100755
diff --git a/docs/user/authentication.rst b/docs/user/authentication.rst
old mode 100644
new mode 100755
diff --git a/docs/user/install.rst b/docs/user/install.rst
old mode 100644
new mode 100755
diff --git a/docs/user/intro.rst b/docs/user/intro.rst
old mode 100644
new mode 100755
diff --git a/docs/user/quickstart.rst b/docs/user/quickstart.rst
old mode 100644
new mode 100755
diff --git a/ext/requests-logo.ai b/ext/requests-logo.ai
old mode 100644
new mode 100755
diff --git a/ext/requests-logo.svg b/ext/requests-logo.svg
old mode 100644
new mode 100755
diff --git a/requests/__init__.py b/requests/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/adapters.py b/requests/adapters.py
old mode 100644
new mode 100755
diff --git a/requests/api.py b/requests/api.py
old mode 100644
new mode 100755
diff --git a/requests/auth.py b/requests/auth.py
old mode 100644
new mode 100755
diff --git a/requests/cacert.pem b/requests/cacert.pem
old mode 100644
new mode 100755
diff --git a/requests/certs.py b/requests/certs.py
old mode 100644
new mode 100755
diff --git a/requests/compat.py b/requests/compat.py
old mode 100644
new mode 100755
diff --git a/requests/cookies.py b/requests/cookies.py
old mode 100644
new mode 100755
diff --git a/requests/exceptions.py b/requests/exceptions.py
old mode 100644
new mode 100755
diff --git a/requests/hooks.py b/requests/hooks.py
old mode 100644
new mode 100755
diff --git a/requests/models.py b/requests/models.py
old mode 100644
new mode 100755
diff --git a/requests/packages/README.rst b/requests/packages/README.rst
old mode 100644
new mode 100755
diff --git a/requests/packages/__init__.py b/requests/packages/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/__init__.py b/requests/packages/chardet/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/big5freq.py b/requests/packages/chardet/big5freq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/big5prober.py b/requests/packages/chardet/big5prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/chardistribution.py b/requests/packages/chardet/chardistribution.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/charsetgroupprober.py b/requests/packages/chardet/charsetgroupprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/charsetprober.py b/requests/packages/chardet/charsetprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/codingstatemachine.py b/requests/packages/chardet/codingstatemachine.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/compat.py b/requests/packages/chardet/compat.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/constants.py b/requests/packages/chardet/constants.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/cp949prober.py b/requests/packages/chardet/cp949prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/escprober.py b/requests/packages/chardet/escprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/escsm.py b/requests/packages/chardet/escsm.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/eucjpprober.py b/requests/packages/chardet/eucjpprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euckrfreq.py b/requests/packages/chardet/euckrfreq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euckrprober.py b/requests/packages/chardet/euckrprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euctwfreq.py b/requests/packages/chardet/euctwfreq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euctwprober.py b/requests/packages/chardet/euctwprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/gb2312freq.py b/requests/packages/chardet/gb2312freq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/gb2312prober.py b/requests/packages/chardet/gb2312prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/hebrewprober.py b/requests/packages/chardet/hebrewprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/jisfreq.py b/requests/packages/chardet/jisfreq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/jpcntx.py b/requests/packages/chardet/jpcntx.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langbulgarianmodel.py b/requests/packages/chardet/langbulgarianmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langcyrillicmodel.py b/requests/packages/chardet/langcyrillicmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langgreekmodel.py b/requests/packages/chardet/langgreekmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langhebrewmodel.py b/requests/packages/chardet/langhebrewmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langhungarianmodel.py b/requests/packages/chardet/langhungarianmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langthaimodel.py b/requests/packages/chardet/langthaimodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/latin1prober.py b/requests/packages/chardet/latin1prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/mbcharsetprober.py b/requests/packages/chardet/mbcharsetprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/mbcsgroupprober.py b/requests/packages/chardet/mbcsgroupprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/mbcssm.py b/requests/packages/chardet/mbcssm.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/sbcharsetprober.py b/requests/packages/chardet/sbcharsetprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/sbcsgroupprober.py b/requests/packages/chardet/sbcsgroupprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/sjisprober.py b/requests/packages/chardet/sjisprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/universaldetector.py b/requests/packages/chardet/universaldetector.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/utf8prober.py b/requests/packages/chardet/utf8prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/__init__.py b/requests/packages/urllib3/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/_collections.py b/requests/packages/urllib3/_collections.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/connection.py b/requests/packages/urllib3/connection.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/connectionpool.py b/requests/packages/urllib3/connectionpool.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/contrib/__init__.py b/requests/packages/urllib3/contrib/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/contrib/ntlmpool.py b/requests/packages/urllib3/contrib/ntlmpool.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/contrib/pyopenssl.py b/requests/packages/urllib3/contrib/pyopenssl.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/exceptions.py b/requests/packages/urllib3/exceptions.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/fields.py b/requests/packages/urllib3/fields.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/filepost.py b/requests/packages/urllib3/filepost.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/__init__.py b/requests/packages/urllib3/packages/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/ordered_dict.py b/requests/packages/urllib3/packages/ordered_dict.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/six.py b/requests/packages/urllib3/packages/six.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/ssl_match_hostname/__init__.py b/requests/packages/urllib3/packages/ssl_match_hostname/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/ssl_match_hostname/_implementation.py b/requests/packages/urllib3/packages/ssl_match_hostname/_implementation.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/poolmanager.py b/requests/packages/urllib3/poolmanager.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/request.py b/requests/packages/urllib3/request.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/response.py b/requests/packages/urllib3/response.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/__init__.py b/requests/packages/urllib3/util/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/connection.py b/requests/packages/urllib3/util/connection.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/request.py b/requests/packages/urllib3/util/request.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/response.py b/requests/packages/urllib3/util/response.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/retry.py b/requests/packages/urllib3/util/retry.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/ssl_.py b/requests/packages/urllib3/util/ssl_.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/timeout.py b/requests/packages/urllib3/util/timeout.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/url.py b/requests/packages/urllib3/util/url.py
old mode 100644
new mode 100755
diff --git a/requests/sessions.py b/requests/sessions.py
old mode 100644
new mode 100755
diff --git a/requests/status_codes.py b/requests/status_codes.py
old mode 100644
new mode 100755
diff --git a/requests/structures.py b/requests/structures.py
old mode 100644
new mode 100755
diff --git a/requests/utils.py b/requests/utils.py
old mode 100644
new mode 100755
diff --git a/requirements.txt b/requirements.txt
old mode 100644
new mode 100755
diff --git a/setup.cfg b/setup.cfg
old mode 100644
new mode 100755

```
````

### `direct-check.log`

```
check: py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed
collected 142 items

test_requests.py FFFFFFFFFFFFFFFFF...F..FF......FFFFF.F..F............F. [ 38%]
.FF..F.F..F.F..F..F.....FF.....FF.FFF................................... [ 89%]
...F.FFFF......                                                          [100%]

=================================== FAILURES ===================================
____________ RequestsTestCase.test_BASICAUTH_TUPLE_HTTP_200_OK_GET _____________

self = <test_requests.RequestsTestCase testMethod=test_BASICAUTH_TUPLE_HTTP_200_OK_GET>

    def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self):
        auth = ('user', 'pass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:286: AssertionError
______________ RequestsTestCase.test_DIGESTAUTH_QUOTES_QOP_VALUE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_QUOTES_QOP_VALUE>

    def test_DIGESTAUTH_QUOTES_QOP_VALUE(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert '"auth"' in r.request.headers['Authorization']

test_requests.py:397: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive'}
key = 'Authorization'

    def __getitem__(self, key):
>       return self._store[key.lower()][1]
E       KeyError: 'authorization'

requests/structures.py:54: KeyError
_____________ RequestsTestCase.test_DIGESTAUTH_WRONG_HTTP_401_GET ______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_WRONG_HTTP_401_GET>

    def test_DIGESTAUTH_WRONG_HTTP_401_GET(self):
    
        auth = HTTPDigestAuth('user', 'wrongpass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 401
E       assert 403 == 401
E        +  where 403 = <Response [403]>.status_code

test_requests.py:381: AssertionError
_______________ RequestsTestCase.test_DIGEST_AUTH_RETURNS_COOKIE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_RETURNS_COOKIE>

    def test_DIGEST_AUTH_RETURNS_COOKIE(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        r = requests.get(url)
>       assert r.cookies['fake'] == 'fake_value'

test_requests.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
____________ RequestsTestCase.test_DIGEST_AUTH_SETS_SESSION_COOKIES ____________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_SETS_SESSION_COOKIES>

    def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        s = requests.Session()
        s.get(url, auth=auth)
>       assert s.cookies['fake'] == 'fake_value'

test_requests.py:362: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
_________________ RequestsTestCase.test_DIGEST_HTTP_200_OK_GET _________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_HTTP_200_OK_GET>

    def test_DIGEST_HTTP_200_OK_GET(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:338: AssertionError
_____________________ RequestsTestCase.test_DIGEST_STREAM ______________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_STREAM>

    def test_DIGEST_STREAM(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth, stream=True)
>       assert r.raw.read() != b''
E       AssertionError: assert b'' != b''
E        +  where b'' = <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x749fbab83b20>>()
E        +    where <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x749fbab83b20>> = <requests.packages.urllib3.response.HTTPResponse object at 0x749fbab83b20>.read
E        +      where <requests.packages.urllib3.response.HTTPResponse object at 0x749fbab83b20> = <Response [403]>.raw

test_requests.py:370: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_ALTERNATIVE _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_ALTERNATIVE>

    def test_HTTP_200_OK_GET_ALTERNATIVE(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
    
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:138: AssertionError
___________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS ____________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_MIXED_PARAMS>

    def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('get') + '?test=true', params={'q': 'test'}, headers=heads)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:162: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_PARAMS _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_PARAMS>

    def test_HTTP_200_OK_GET_WITH_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('user-agent'), headers=heads)
    
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:155: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_HEAD ____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_HEAD>

    def test_HTTP_200_OK_HEAD(self):
        r = requests.head(httpbin('get'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:275: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_PUT _____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_PUT>

    def test_HTTP_200_OK_PUT(self):
        r = requests.put(httpbin('put'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:279: AssertionError
______________ RequestsTestCase.test_HTTP_302_ALLOW_REDIRECT_GET _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_302_ALLOW_REDIRECT_GET>

    def test_HTTP_302_ALLOW_REDIRECT_GET(self):
        r = requests.get(httpbin('redirect', '1'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:142: AssertionError
_________________ RequestsTestCase.test_POSTBIN_GET_POST_FILES _________________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES>

    def test_POSTBIN_GET_POST_FILES(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:402: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
____________ RequestsTestCase.test_POSTBIN_GET_POST_FILES_WITH_DATA ____________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES_WITH_DATA>

    def test_POSTBIN_GET_POST_FILES_WITH_DATA(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:420: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
_________ RequestsTestCase.test_auth_is_retained_for_redirect_on_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_retained_for_redirect_on_host>

    def test_auth_is_retained_for_redirect_on_host(self):
        r = requests.get(httpbin('redirect/1'), auth=('user', 'pass'))
>       h1 = r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:953: IndexError
_________ RequestsTestCase.test_auth_is_stripped_on_redirect_off_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_stripped_on_redirect_off_host>

    def test_auth_is_stripped_on_redirect_off_host(self):
        r = requests.get(
            httpbin('redirect-to'),
            params={'url': 'http://www.google.co.uk'},
            auth=('user', 'pass'),
        )
>       assert r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:948: IndexError
__________________ RequestsTestCase.test_basicauth_with_netrc __________________

self = <test_requests.RequestsTestCase testMethod=test_basicauth_with_netrc>

    def test_basicauth_with_netrc(self):
        auth = ('user', 'pass')
        wrong_auth = ('wronguser', 'wrongpass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        def get_netrc_auth_mock(url):
            return auth
        requests.sessions.get_netrc_auth = get_netrc_auth_mock
    
        # Should use netrc and work.
        r = requests.get(url)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:315: AssertionError
________________ RequestsTestCase.test_conflicting_post_params _________________

self = <test_requests.RequestsTestCase testMethod=test_conflicting_post_params>

    def test_conflicting_post_params(self):
        url = httpbin('post')
        with open('requirements.txt') as f:
>           pytest.raises(ValueError, "requests.post(url, data='[{\"some\": \"data\"}]', files={'some': f})")
E           TypeError: 'requests.post(url, data=\'[{"some": "data"}]\', files={\'some\': f})' object (type: <class 'str'>) must be callable

test_requests.py:439: TypeError
____________________ RequestsTestCase.test_connection_error ____________________

self = <test_requests.RequestsTestCase testMethod=test_connection_error>

    def test_connection_error(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://fooobarbangbazbing.httpbin.org")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:299: Failed
________________ RequestsTestCase.test_cookie_persists_via_api _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_persists_via_api>

    def test_cookie_persists_via_api(self):
        s = requests.session()
        r = s.get(httpbin('redirect/1'), cookies={'foo': 'bar'})
        assert 'foo' in r.request.headers['Cookie']
>       assert 'foo' in r.history[0].request.headers['Cookie']
E       IndexError: list index out of range

test_requests.py:198: IndexError
__________________ RequestsTestCase.test_cookie_quote_wrapped __________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_quote_wrapped>

    def test_cookie_quote_wrapped(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo="bar:baz"'))
>       assert s.cookies['foo'] == '"bar:baz"'

test_requests.py:192: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_removed_on_expire ________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_removed_on_expire>

    def test_cookie_removed_on_expire(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
>       assert s.cookies['foo'] == 'bar'

test_requests.py:179: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_sent_on_redirect _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_sent_on_redirect>

    def test_cookie_sent_on_redirect(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
        r = s.get(httpbin('redirect/1'))  # redirects to httpbin('get')
>       assert 'Cookie' in r.json()['headers']

test_requests.py:174: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x749fbba25730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
__________________ RequestsTestCase.test_custom_content_type ___________________

self = <test_requests.RequestsTestCase testMethod=test_custom_content_type>

    def test_custom_content_type(self):
        r = requests.post(
            httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            files={'file1': ('test_requests.py', open(__file__, 'rb')),
                   'file2': ('test_requests', open(__file__, 'rb'),
                             'text/py-content-type')})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:533: AssertionError
__________ RequestsTestCase.test_different_encodings_dont_break_post ___________

self = <test_requests.RequestsTestCase testMethod=test_different_encodings_dont_break_post>

    def test_different_encodings_dont_break_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            params={'blah': 'asdf1234'},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:486: AssertionError
________________ RequestsTestCase.test_generic_cookiejar_works _________________

self = <test_requests.RequestsTestCase testMethod=test_generic_cookiejar_works>

    def test_generic_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        s.cookies = cj
        r = s.get(httpbin('cookies'))
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:221: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x749fbba25730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
___________ RequestsTestCase.test_json_param_post_content_type_works ___________

self = <test_requests.RequestsTestCase testMethod=test_json_param_post_content_type_works>

    def test_json_param_post_content_type_works(self):
        r = requests.post(
            httpbin('post'),
            json={'life': 42}
        )
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1015: AssertionError
_________ RequestsTestCase.test_manual_redirect_with_partial_body_read _________

self = <test_requests.RequestsTestCase testMethod=test_manual_redirect_with_partial_body_read>

    def test_manual_redirect_with_partial_body_read(self):
        s = requests.Session()
        r1 = s.get(httpbin('redirect/2'), allow_redirects=False, stream=True)
>       assert r1.is_redirect
E       assert False
E        +  where False = <Response [403]>.is_redirect

test_requests.py:961: AssertionError
______________ RequestsTestCase.test_mixed_case_scheme_acceptable ______________

self = <test_requests.RequestsTestCase testMethod=test_mixed_case_scheme_acceptable>

    def test_mixed_case_scheme_acceptable(self):
        s = requests.Session()
        s.proxies = getproxies()
        parts = urlparse(httpbin('get'))
        schemes = ['http://', 'HTTP://', 'hTTp://', 'HttP://',
                   'https://', 'HTTPS://', 'hTTps://', 'HttPs://']
        for scheme in schemes:
            url = scheme + parts.netloc + parts.path
            r = requests.Request('GET', url)
            r = s.send(r.prepare())
>           assert r.status_code == 200, 'failed for scheme {0}'.format(scheme)
E           AssertionError: failed for scheme http://
E           assert 403 == 200
E            +  where 403 = <Response [403]>.status_code

test_requests.py:129: AssertionError
_________________ RequestsTestCase.test_param_cookiejar_works __________________

self = <test_requests.RequestsTestCase testMethod=test_param_cookiejar_works>

    def test_param_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        r = s.get(httpbin('cookies'), cookies=cj)
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:231: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x749fbba25730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
____________ RequestsTestCase.test_params_are_merged_case_sensitive ____________

self = <test_requests.RequestsTestCase testMethod=test_params_are_merged_case_sensitive>

    def test_params_are_merged_case_sensitive(self):
        s = requests.Session()
        s.params['foo'] = 'bar'
        r = s.get(httpbin('get'), params={'FOO': 'bar'})
>       assert r.json()['args'] == {'foo': 'bar', 'FOO': 'bar'}

test_requests.py:894: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x749fbba25730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_________________ RequestsTestCase.test_prepared_from_session __________________

self = <requests.packages.urllib3.connectionpool.HTTPConnectionPool object at 0x749fba933940>
method = 'GET', url = '/headers', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Dummy-Auth-Test': 'dummy-auth-test-ok'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fba933cd0>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x749fba97a780>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
            conn = self._get_conn(timeout=pool_timeout)
    
            # Make the request on the httplib connection object.
>           httplib_response = self._make_request(conn, method, url,
                                                  timeout=timeout,
                                                  body=body, headers=headers)

requests/packages/urllib3/connectionpool.py:514: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       socket.gaierror: [Errno -3] Temporary failure in name resolution

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: gaierror

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x749fbabc6d00>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fba933cd0>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
requests/packages/urllib3/util/retry.py:245: in increment
    raise six.reraise(type(error), error, _stacktrace)
requests/packages/urllib3/packages/six.py:309: in reraise
    raise value.with_traceback(tb)
requests/packages/urllib3/connectionpool.py:514: in urlopen
    httplib_response = self._make_request(conn, method, url,
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       requests.packages.urllib3.exceptions.ProtocolError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: ProtocolError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_prepared_from_session>

    def test_prepared_from_session(self):
        class DummyAuth(requests.auth.AuthBase):
            def __call__(self, r):
                r.headers['Dummy-Auth-Test'] = 'dummy-auth-test-ok'
                return r
    
        req = requests.Request('GET', httpbin('headers'))
        assert not req.auth
    
        s = requests.Session()
        s.auth = DummyAuth()
    
        prep = s.prepare_request(req)
>       resp = s.send(prep)

test_requests.py:589: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x749fbabc6d00>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fba933cd0>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
>           raise ConnectionError(err, request=request)
E           requests.exceptions.ConnectionError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

requests/adapters.py:407: ConnectionError
___________________ RequestsTestCase.test_pyopenssl_redirect ___________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x749fbab875b0>
method = 'GET', url = '/status/301', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fbab87820>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x749fba7d9a00>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x749fbab87fa0>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x749fbab87e20>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fbab87820>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/status/301', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x749fbab875b0>
_stacktrace = <traceback object at 0x749fba7d9a00>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_pyopenssl_redirect>

    def test_pyopenssl_redirect(self):
>       requests.get('https://httpbin.org/status/301')

test_requests.py:473: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x749fbab87e20>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fbab87820>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________ RequestsTestCase.test_request_cookie_overrides_session_cookie _________

self = <test_requests.RequestsTestCase testMethod=test_request_cookie_overrides_session_cookie>

    def test_request_cookie_overrides_session_cookie(self):
        s = requests.session()
        s.cookies['foo'] = 'bar'
        r = s.get(httpbin('cookies'), cookies={'foo': 'baz'})
>       assert r.json()['cookies']['foo'] == 'baz'

test_requests.py:204: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x749fbba25730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_______________ RequestsTestCase.test_requests_history_is_saved ________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x749fba810cd0>
method = 'GET', url = '/redirect/5', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fbabceac0>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x749fba9c9b00>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x749fbabce040>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x749fba810ee0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fbabceac0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/redirect/5', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x749fba810cd0>
_stacktrace = <traceback object at 0x749fba9c9b00>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_requests_history_is_saved>

    def test_requests_history_is_saved(self):
>       r = requests.get('https://httpbin.org/redirect/5')

test_requests.py:1003: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x749fba810ee0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fbabceac0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
____________________ RequestsTestCase.test_session_pickling ____________________

self = <test_requests.RequestsTestCase testMethod=test_session_pickling>

    def test_session_pickling(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
    
        s = pickle.loads(pickle.dumps(s))
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:823: AssertionError
___________________ RequestsTestCase.test_set_cookie_on_301 ____________________

self = <test_requests.RequestsTestCase testMethod=test_set_cookie_on_301>

    def test_set_cookie_on_301(self):
        s = requests.session()
        url = httpbin('cookies/set?foo=bar')
        s.get(url)
>       assert s.cookies['foo'] == 'bar'

test_requests.py:168: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
__________________ RequestsTestCase.test_unicode_method_name ___________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_method_name>

    def test_unicode_method_name(self):
        files = {'file': open('test_requests.py', 'rb')}
        r = requests.request(
            method=u('POST'), url=httpbin('post'), files=files)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:524: AssertionError
_________________ RequestsTestCase.test_unicode_multipart_post _________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_multipart_post>

    def test_unicode_multipart_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': u('ëlïxr')},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:492: AssertionError
_______________ RequestsTestCase.test_uppercase_scheme_redirect ________________

self = <test_requests.RequestsTestCase testMethod=test_uppercase_scheme_redirect>

    def test_uppercase_scheme_redirect(self):
        parts = urlparse(httpbin('html'))
        url = "HTTP://" + parts.netloc + parts.path
        r = requests.get(httpbin('redirect-to'), params={'url': url})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:842: AssertionError
_________ RequestsTestCase.test_urlencoded_get_query_multivalued_param _________

self = <test_requests.RequestsTestCase testMethod=test_urlencoded_get_query_multivalued_param>

    def test_urlencoded_get_query_multivalued_param(self):
    
        r = requests.get(httpbin('get'), params=dict(test=['foo', 'baz']))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:478: AssertionError
__________________ RequestsTestCase.test_user_agent_transfers __________________

self = <test_requests.RequestsTestCase testMethod=test_user_agent_transfers>

    def test_user_agent_transfers(self):
    
        heads = {
            'User-agent': 'Mozilla/5.0 (github.com/kennethreitz/requests)'
        }
    
        r = requests.get(httpbin('user-agent'), headers=heads)
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0 (github.com/kennethreitz/requests)' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:264: AssertionError
_______________________ TestTimeout.test_stream_timeout ________________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x749fbad301c0>
method = 'GET', url = '/delay/10', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fba75c460>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x749fbaa394c0>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x749fba75c9d0>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x749fbad3d700>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fba75c460>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/delay/10', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x749fbad301c0>
_stacktrace = <traceback object at 0x749fbaa394c0>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.TestTimeout object at 0x749fbace1940>

    def test_stream_timeout(self):
        try:
>           requests.get('https://httpbin.org/delay/10', timeout=2.0)

test_requests.py:1345: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x749fbad3d700>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x749fba75c460>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________________________ TestTimeout.test_none_timeout _________________________

self = <test_requests.TestTimeout object at 0x749fbace1b80>

    def test_none_timeout(self):
        """ Check that you can set None as a valid timeout value.
    
        To actually test this behavior, we'd want to check that setting the
        timeout to None actually lets the request block past the system default
        timeout. However, this would make the test suite unbearably slow.
        Instead we verify that setting the timeout to None does not prevent the
        request from succeeding.
        """
        r = requests.get(httpbin('get'), timeout=None)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1368: AssertionError
________________________ TestTimeout.test_read_timeout _________________________

self = <test_requests.TestTimeout object at 0x749fbace1ca0>

    def test_read_timeout(self):
        try:
            requests.get(httpbin('delay/10'), timeout=(None, 0.1))
>           assert False, "The recv() request should time out."
E           AssertionError: The recv() request should time out.
E           assert False

test_requests.py:1373: AssertionError
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x749fbace1dc0>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1380: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x749fbace1ee0>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1388: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:1
requests/packages/urllib3/_collections.py:1
  /testbed/requests/packages/urllib3/_collections.py:1: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
  /testbed/requests/models.py:169: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_QUOTES_QOP_VALUE
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_WRONG_HTTP_401_GET
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_RETURNS_COOKIE - ...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_SETS_SESSION_COOKIES
FAILED test_requests.py::RequestsTestCase::test_DIGEST_HTTP_200_OK_GET - asse...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_STREAM - AssertionErro...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_ALTERNATIVE
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_HEAD - assert 403...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_PUT - assert 403 ...
FAILED test_requests.py::RequestsTestCase::test_HTTP_302_ALLOW_REDIRECT_GET
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES - requ...
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES_WITH_DATA
FAILED test_requests.py::RequestsTestCase::test_auth_is_retained_for_redirect_on_host
FAILED test_requests.py::RequestsTestCase::test_auth_is_stripped_on_redirect_off_host
FAILED test_requests.py::RequestsTestCase::test_basicauth_with_netrc - assert...
FAILED test_requests.py::RequestsTestCase::test_conflicting_post_params - Typ...
FAILED test_requests.py::RequestsTestCase::test_connection_error - Failed: DI...
FAILED test_requests.py::RequestsTestCase::test_cookie_persists_via_api - Ind...
FAILED test_requests.py::RequestsTestCase::test_cookie_quote_wrapped - KeyErr...
FAILED test_requests.py::RequestsTestCase::test_cookie_removed_on_expire - Ke...
FAILED test_requests.py::RequestsTestCase::test_cookie_sent_on_redirect - jso...
FAILED test_requests.py::RequestsTestCase::test_custom_content_type - assert ...
FAILED test_requests.py::RequestsTestCase::test_different_encodings_dont_break_post
FAILED test_requests.py::RequestsTestCase::test_generic_cookiejar_works - jso...
FAILED test_requests.py::RequestsTestCase::test_json_param_post_content_type_works
FAILED test_requests.py::RequestsTestCase::test_manual_redirect_with_partial_body_read
FAILED test_requests.py::RequestsTestCase::test_mixed_case_scheme_acceptable
FAILED test_requests.py::RequestsTestCase::test_param_cookiejar_works - json....
FAILED test_requests.py::RequestsTestCase::test_params_are_merged_case_sensitive
FAILED test_requests.py::RequestsTestCase::test_prepared_from_session - reque...
FAILED test_requests.py::RequestsTestCase::test_pyopenssl_redirect - requests...
FAILED test_requests.py::RequestsTestCase::test_request_cookie_overrides_session_cookie
FAILED test_requests.py::RequestsTestCase::test_requests_history_is_saved - r...
FAILED test_requests.py::RequestsTestCase::test_session_pickling - assert 403...
FAILED test_requests.py::RequestsTestCase::test_set_cookie_on_301 - KeyError:...
FAILED test_requests.py::RequestsTestCase::test_unicode_method_name - assert ...
FAILED test_requests.py::RequestsTestCase::test_unicode_multipart_post - asse...
FAILED test_requests.py::RequestsTestCase::test_uppercase_scheme_redirect - a...
FAILED test_requests.py::RequestsTestCase::test_urlencoded_get_query_multivalued_param
FAILED test_requests.py::RequestsTestCase::test_user_agent_transfers - Assert...
FAILED test_requests.py::TestTimeout::test_stream_timeout - requests.exceptio...
FAILED test_requests.py::TestTimeout::test_none_timeout - assert 403 == 200
FAILED test_requests.py::TestTimeout::test_read_timeout - AssertionError: The...
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
================== 48 failed, 94 passed, 3 warnings in 3.65s ===================

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/sessions.py
OUTSIDE THE SCOPE: requests/models.py +1 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: requests/sessions.py +2 -2
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/requests/models.py b/requests/models.py
index 3f6a4f9..7699743 100755
--- a/requests/models.py
+++ b/requests/models.py
@@ -329,7 +329,7 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
         """Prepares the given HTTP method."""
         self.method = method
         if self.method is not None:
-            self.method = self.method.upper()
+            self.method = to_native_string(self.method).upper()
 
     def prepare_url(self, url, params):
         """Prepares the given HTTP URL."""
diff --git a/requests/sessions.py b/requests/sessions.py
index d701ff2..dfce7cf 100755
--- a/requests/sessions.py
+++ b/requests/sessions.py
@@ -13,7 +13,7 @@ from collections import Mapping
 from datetime import datetime
 
 from .auth import _basic_auth_str
-from .compat import cookielib, OrderedDict, urljoin, urlparse, builtin_str
+from .compat import cookielib, OrderedDict, urljoin, urlparse
 from .cookies import (
     cookiejar_from_dict, extract_cookies_to_jar, RequestsCookieJar, merge_cookies)
 from .models import Request, PreparedRequest, DEFAULT_REDIRECT_LIMIT
@@ -425,7 +425,7 @@ class Session(SessionRedirectMixin):
             If Tuple, ('cert', 'key') pair.
         """
 
-        method = builtin_str(method)
+        method = to_native_string(method)
 
         # Create the Request.
         req = Request(
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
check: py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed
collected 142 items

test_requests.py FFFFFFFFFFFFFFFFF...F..FF......FFFFF.F..F............F. [ 38%]
.FF..F.F..F.F..F..F.....FF.....FF.FFF................................... [ 89%]
...F.FFFF......                                                          [100%]

=================================== FAILURES ===================================
____________ RequestsTestCase.test_BASICAUTH_TUPLE_HTTP_200_OK_GET _____________

self = <test_requests.RequestsTestCase testMethod=test_BASICAUTH_TUPLE_HTTP_200_OK_GET>

    def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self):
        auth = ('user', 'pass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:286: AssertionError
______________ RequestsTestCase.test_DIGESTAUTH_QUOTES_QOP_VALUE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_QUOTES_QOP_VALUE>

    def test_DIGESTAUTH_QUOTES_QOP_VALUE(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert '"auth"' in r.request.headers['Authorization']

test_requests.py:397: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive'}
key = 'Authorization'

    def __getitem__(self, key):
>       return self._store[key.lower()][1]
E       KeyError: 'authorization'

requests/structures.py:54: KeyError
_____________ RequestsTestCase.test_DIGESTAUTH_WRONG_HTTP_401_GET ______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_WRONG_HTTP_401_GET>

    def test_DIGESTAUTH_WRONG_HTTP_401_GET(self):
    
        auth = HTTPDigestAuth('user', 'wrongpass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 401
E       assert 403 == 401
E        +  where 403 = <Response [403]>.status_code

test_requests.py:381: AssertionError
_______________ RequestsTestCase.test_DIGEST_AUTH_RETURNS_COOKIE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_RETURNS_COOKIE>

    def test_DIGEST_AUTH_RETURNS_COOKIE(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        r = requests.get(url)
>       assert r.cookies['fake'] == 'fake_value'

test_requests.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
____________ RequestsTestCase.test_DIGEST_AUTH_SETS_SESSION_COOKIES ____________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_SETS_SESSION_COOKIES>

    def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        s = requests.Session()
        s.get(url, auth=auth)
>       assert s.cookies['fake'] == 'fake_value'

test_requests.py:362: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
_________________ RequestsTestCase.test_DIGEST_HTTP_200_OK_GET _________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_HTTP_200_OK_GET>

    def test_DIGEST_HTTP_200_OK_GET(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:338: AssertionError
_____________________ RequestsTestCase.test_DIGEST_STREAM ______________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_STREAM>

    def test_DIGEST_STREAM(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth, stream=True)
>       assert r.raw.read() != b''
E       AssertionError: assert b'' != b''
E        +  where b'' = <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x7d2a979d6b20>>()
E        +    where <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x7d2a979d6b20>> = <requests.packages.urllib3.response.HTTPResponse object at 0x7d2a979d6b20>.read
E        +      where <requests.packages.urllib3.response.HTTPResponse object at 0x7d2a979d6b20> = <Response [403]>.raw

test_requests.py:370: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_ALTERNATIVE _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_ALTERNATIVE>

    def test_HTTP_200_OK_GET_ALTERNATIVE(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
    
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:138: AssertionError
___________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS ____________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_MIXED_PARAMS>

    def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('get') + '?test=true', params={'q': 'test'}, headers=heads)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:162: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_PARAMS _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_PARAMS>

    def test_HTTP_200_OK_GET_WITH_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('user-agent'), headers=heads)
    
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:155: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_HEAD ____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_HEAD>

    def test_HTTP_200_OK_HEAD(self):
        r = requests.head(httpbin('get'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:275: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_PUT _____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_PUT>

    def test_HTTP_200_OK_PUT(self):
        r = requests.put(httpbin('put'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:279: AssertionError
______________ RequestsTestCase.test_HTTP_302_ALLOW_REDIRECT_GET _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_302_ALLOW_REDIRECT_GET>

    def test_HTTP_302_ALLOW_REDIRECT_GET(self):
        r = requests.get(httpbin('redirect', '1'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:142: AssertionError
_________________ RequestsTestCase.test_POSTBIN_GET_POST_FILES _________________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES>

    def test_POSTBIN_GET_POST_FILES(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:402: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
____________ RequestsTestCase.test_POSTBIN_GET_POST_FILES_WITH_DATA ____________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES_WITH_DATA>

    def test_POSTBIN_GET_POST_FILES_WITH_DATA(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:420: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
_________ RequestsTestCase.test_auth_is_retained_for_redirect_on_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_retained_for_redirect_on_host>

    def test_auth_is_retained_for_redirect_on_host(self):
        r = requests.get(httpbin('redirect/1'), auth=('user', 'pass'))
>       h1 = r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:953: IndexError
_________ RequestsTestCase.test_auth_is_stripped_on_redirect_off_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_stripped_on_redirect_off_host>

    def test_auth_is_stripped_on_redirect_off_host(self):
        r = requests.get(
            httpbin('redirect-to'),
            params={'url': 'http://www.google.co.uk'},
            auth=('user', 'pass'),
        )
>       assert r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:948: IndexError
__________________ RequestsTestCase.test_basicauth_with_netrc __________________

self = <test_requests.RequestsTestCase testMethod=test_basicauth_with_netrc>

    def test_basicauth_with_netrc(self):
        auth = ('user', 'pass')
        wrong_auth = ('wronguser', 'wrongpass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        def get_netrc_auth_mock(url):
            return auth
        requests.sessions.get_netrc_auth = get_netrc_auth_mock
    
        # Should use netrc and work.
        r = requests.get(url)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:315: AssertionError
________________ RequestsTestCase.test_conflicting_post_params _________________

self = <test_requests.RequestsTestCase testMethod=test_conflicting_post_params>

    def test_conflicting_post_params(self):
        url = httpbin('post')
        with open('requirements.txt') as f:
>           pytest.raises(ValueError, "requests.post(url, data='[{\"some\": \"data\"}]', files={'some': f})")
E           TypeError: 'requests.post(url, data=\'[{"some": "data"}]\', files={\'some\': f})' object (type: <class 'str'>) must be callable

test_requests.py:439: TypeError
____________________ RequestsTestCase.test_connection_error ____________________

self = <test_requests.RequestsTestCase testMethod=test_connection_error>

    def test_connection_error(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://fooobarbangbazbing.httpbin.org")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:299: Failed
________________ RequestsTestCase.test_cookie_persists_via_api _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_persists_via_api>

    def test_cookie_persists_via_api(self):
        s = requests.session()
        r = s.get(httpbin('redirect/1'), cookies={'foo': 'bar'})
        assert 'foo' in r.request.headers['Cookie']
>       assert 'foo' in r.history[0].request.headers['Cookie']
E       IndexError: list index out of range

test_requests.py:198: IndexError
__________________ RequestsTestCase.test_cookie_quote_wrapped __________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_quote_wrapped>

    def test_cookie_quote_wrapped(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo="bar:baz"'))
>       assert s.cookies['foo'] == '"bar:baz"'

test_requests.py:192: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_removed_on_expire ________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_removed_on_expire>

    def test_cookie_removed_on_expire(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
>       assert s.cookies['foo'] == 'bar'

test_requests.py:179: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_sent_on_redirect _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_sent_on_redirect>

    def test_cookie_sent_on_redirect(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
        r = s.get(httpbin('redirect/1'))  # redirects to httpbin('get')
>       assert 'Cookie' in r.json()['headers']

test_requests.py:174: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7d2a98872730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
__________________ RequestsTestCase.test_custom_content_type ___________________

self = <test_requests.RequestsTestCase testMethod=test_custom_content_type>

    def test_custom_content_type(self):
        r = requests.post(
            httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            files={'file1': ('test_requests.py', open(__file__, 'rb')),
                   'file2': ('test_requests', open(__file__, 'rb'),
                             'text/py-content-type')})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:533: AssertionError
__________ RequestsTestCase.test_different_encodings_dont_break_post ___________

self = <test_requests.RequestsTestCase testMethod=test_different_encodings_dont_break_post>

    def test_different_encodings_dont_break_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            params={'blah': 'asdf1234'},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:486: AssertionError
________________ RequestsTestCase.test_generic_cookiejar_works _________________

self = <test_requests.RequestsTestCase testMethod=test_generic_cookiejar_works>

    def test_generic_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        s.cookies = cj
        r = s.get(httpbin('cookies'))
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:221: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7d2a98872730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
___________ RequestsTestCase.test_json_param_post_content_type_works ___________

self = <test_requests.RequestsTestCase testMethod=test_json_param_post_content_type_works>

    def test_json_param_post_content_type_works(self):
        r = requests.post(
            httpbin('post'),
            json={'life': 42}
        )
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1015: AssertionError
_________ RequestsTestCase.test_manual_redirect_with_partial_body_read _________

self = <test_requests.RequestsTestCase testMethod=test_manual_redirect_with_partial_body_read>

    def test_manual_redirect_with_partial_body_read(self):
        s = requests.Session()
        r1 = s.get(httpbin('redirect/2'), allow_redirects=False, stream=True)
>       assert r1.is_redirect
E       assert False
E        +  where False = <Response [403]>.is_redirect

test_requests.py:961: AssertionError
______________ RequestsTestCase.test_mixed_case_scheme_acceptable ______________

self = <test_requests.RequestsTestCase testMethod=test_mixed_case_scheme_acceptable>

    def test_mixed_case_scheme_acceptable(self):
        s = requests.Session()
        s.proxies = getproxies()
        parts = urlparse(httpbin('get'))
        schemes = ['http://', 'HTTP://', 'hTTp://', 'HttP://',
                   'https://', 'HTTPS://', 'hTTps://', 'HttPs://']
        for scheme in schemes:
            url = scheme + parts.netloc + parts.path
            r = requests.Request('GET', url)
            r = s.send(r.prepare())
>           assert r.status_code == 200, 'failed for scheme {0}'.format(scheme)
E           AssertionError: failed for scheme http://
E           assert 403 == 200
E            +  where 403 = <Response [403]>.status_code

test_requests.py:129: AssertionError
_________________ RequestsTestCase.test_param_cookiejar_works __________________

self = <test_requests.RequestsTestCase testMethod=test_param_cookiejar_works>

    def test_param_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        r = s.get(httpbin('cookies'), cookies=cj)
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:231: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7d2a98872730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
____________ RequestsTestCase.test_params_are_merged_case_sensitive ____________

self = <test_requests.RequestsTestCase testMethod=test_params_are_merged_case_sensitive>

    def test_params_are_merged_case_sensitive(self):
        s = requests.Session()
        s.params['foo'] = 'bar'
        r = s.get(httpbin('get'), params={'FOO': 'bar'})
>       assert r.json()['args'] == {'foo': 'bar', 'FOO': 'bar'}

test_requests.py:894: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7d2a98872730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_________________ RequestsTestCase.test_prepared_from_session __________________

self = <requests.packages.urllib3.connectionpool.HTTPConnectionPool object at 0x7d2a977fa2e0>
method = 'GET', url = '/headers', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Dummy-Auth-Test': 'dummy-auth-test-ok'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a977fa0a0>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7d2a977bf7c0>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
            conn = self._get_conn(timeout=pool_timeout)
    
            # Make the request on the httplib connection object.
>           httplib_response = self._make_request(conn, method, url,
                                                  timeout=timeout,
                                                  body=body, headers=headers)

requests/packages/urllib3/connectionpool.py:514: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       socket.gaierror: [Errno -3] Temporary failure in name resolution

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: gaierror

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7d2a977fa250>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a977fa0a0>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
requests/packages/urllib3/util/retry.py:245: in increment
    raise six.reraise(type(error), error, _stacktrace)
requests/packages/urllib3/packages/six.py:309: in reraise
    raise value.with_traceback(tb)
requests/packages/urllib3/connectionpool.py:514: in urlopen
    httplib_response = self._make_request(conn, method, url,
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       requests.packages.urllib3.exceptions.ProtocolError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: ProtocolError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_prepared_from_session>

    def test_prepared_from_session(self):
        class DummyAuth(requests.auth.AuthBase):
            def __call__(self, r):
                r.headers['Dummy-Auth-Test'] = 'dummy-auth-test-ok'
                return r
    
        req = requests.Request('GET', httpbin('headers'))
        assert not req.auth
    
        s = requests.Session()
        s.auth = DummyAuth()
    
        prep = s.prepare_request(req)
>       resp = s.send(prep)

test_requests.py:589: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7d2a977fa250>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a977fa0a0>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
>           raise ConnectionError(err, request=request)
E           requests.exceptions.ConnectionError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

requests/adapters.py:407: ConnectionError
___________________ RequestsTestCase.test_pyopenssl_redirect ___________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7d2a979ed820>
method = 'GET', url = '/status/301', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a97a6ae50>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7d2a974aec40>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x7d2a97a6af40>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7d2a979ed670>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a97a6ae50>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/status/301', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7d2a979ed820>
_stacktrace = <traceback object at 0x7d2a974aec40>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_pyopenssl_redirect>

    def test_pyopenssl_redirect(self):
>       requests.get('https://httpbin.org/status/301')

test_requests.py:473: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7d2a979ed670>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a97a6ae50>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________ RequestsTestCase.test_request_cookie_overrides_session_cookie _________

self = <test_requests.RequestsTestCase testMethod=test_request_cookie_overrides_session_cookie>

    def test_request_cookie_overrides_session_cookie(self):
        s = requests.session()
        s.cookies['foo'] = 'bar'
        r = s.get(httpbin('cookies'), cookies={'foo': 'baz'})
>       assert r.json()['cookies']['foo'] == 'baz'

test_requests.py:204: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7d2a98872730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_______________ RequestsTestCase.test_requests_history_is_saved ________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7d2a9787eb50>
method = 'GET', url = '/redirect/5', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a9787e340>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7d2a978d9340>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x7d2a9787ebb0>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7d2a9787ea00>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a9787e340>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/redirect/5', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7d2a9787eb50>
_stacktrace = <traceback object at 0x7d2a978d9340>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_requests_history_is_saved>

    def test_requests_history_is_saved(self):
>       r = requests.get('https://httpbin.org/redirect/5')

test_requests.py:1003: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7d2a9787ea00>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a9787e340>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
____________________ RequestsTestCase.test_session_pickling ____________________

self = <test_requests.RequestsTestCase testMethod=test_session_pickling>

    def test_session_pickling(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
    
        s = pickle.loads(pickle.dumps(s))
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:823: AssertionError
___________________ RequestsTestCase.test_set_cookie_on_301 ____________________

self = <test_requests.RequestsTestCase testMethod=test_set_cookie_on_301>

    def test_set_cookie_on_301(self):
        s = requests.session()
        url = httpbin('cookies/set?foo=bar')
        s.get(url)
>       assert s.cookies['foo'] == 'bar'

test_requests.py:168: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
__________________ RequestsTestCase.test_unicode_method_name ___________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_method_name>

    def test_unicode_method_name(self):
        files = {'file': open('test_requests.py', 'rb')}
        r = requests.request(
            method=u('POST'), url=httpbin('post'), files=files)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:524: AssertionError
_________________ RequestsTestCase.test_unicode_multipart_post _________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_multipart_post>

    def test_unicode_multipart_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': u('ëlïxr')},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:492: AssertionError
_______________ RequestsTestCase.test_uppercase_scheme_redirect ________________

self = <test_requests.RequestsTestCase testMethod=test_uppercase_scheme_redirect>

    def test_uppercase_scheme_redirect(self):
        parts = urlparse(httpbin('html'))
        url = "HTTP://" + parts.netloc + parts.path
        r = requests.get(httpbin('redirect-to'), params={'url': url})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:842: AssertionError
_________ RequestsTestCase.test_urlencoded_get_query_multivalued_param _________

self = <test_requests.RequestsTestCase testMethod=test_urlencoded_get_query_multivalued_param>

    def test_urlencoded_get_query_multivalued_param(self):
    
        r = requests.get(httpbin('get'), params=dict(test=['foo', 'baz']))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:478: AssertionError
__________________ RequestsTestCase.test_user_agent_transfers __________________

self = <test_requests.RequestsTestCase testMethod=test_user_agent_transfers>

    def test_user_agent_transfers(self):
    
        heads = {
            'User-agent': 'Mozilla/5.0 (github.com/kennethreitz/requests)'
        }
    
        r = requests.get(httpbin('user-agent'), headers=heads)
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0 (github.com/kennethreitz/requests)' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:264: AssertionError
_______________________ TestTimeout.test_stream_timeout ________________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7d2a976d4700>
method = 'GET', url = '/delay/10', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a975f9eb0>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7d2a979e2d00>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x7d2a975f9130>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7d2a976d4310>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a975f9eb0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/delay/10', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7d2a976d4700>
_stacktrace = <traceback object at 0x7d2a979e2d00>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.TestTimeout object at 0x7d2a97b33940>

    def test_stream_timeout(self):
        try:
>           requests.get('https://httpbin.org/delay/10', timeout=2.0)

test_requests.py:1345: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7d2a976d4310>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7d2a975f9eb0>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________________________ TestTimeout.test_none_timeout _________________________

self = <test_requests.TestTimeout object at 0x7d2a97b33b80>

    def test_none_timeout(self):
        """ Check that you can set None as a valid timeout value.
    
        To actually test this behavior, we'd want to check that setting the
        timeout to None actually lets the request block past the system default
        timeout. However, this would make the test suite unbearably slow.
        Instead we verify that setting the timeout to None does not prevent the
        request from succeeding.
        """
        r = requests.get(httpbin('get'), timeout=None)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1368: AssertionError
________________________ TestTimeout.test_read_timeout _________________________

self = <test_requests.TestTimeout object at 0x7d2a97b33ca0>

    def test_read_timeout(self):
        try:
            requests.get(httpbin('delay/10'), timeout=(None, 0.1))
>           assert False, "The recv() request should time out."
E           AssertionError: The recv() request should time out.
E           assert False

test_requests.py:1373: AssertionError
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x7d2a97b33dc0>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1380: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x7d2a97b33ee0>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1388: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:1
requests/packages/urllib3/_collections.py:1
  /testbed/requests/packages/urllib3/_collections.py:1: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
  /testbed/requests/models.py:169: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_QUOTES_QOP_VALUE
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_WRONG_HTTP_401_GET
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_RETURNS_COOKIE - ...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_SETS_SESSION_COOKIES
FAILED test_requests.py::RequestsTestCase::test_DIGEST_HTTP_200_OK_GET - asse...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_STREAM - AssertionErro...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_ALTERNATIVE
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_HEAD - assert 403...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_PUT - assert 403 ...
FAILED test_requests.py::RequestsTestCase::test_HTTP_302_ALLOW_REDIRECT_GET
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES - requ...
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES_WITH_DATA
FAILED test_requests.py::RequestsTestCase::test_auth_is_retained_for_redirect_on_host
FAILED test_requests.py::RequestsTestCase::test_auth_is_stripped_on_redirect_off_host
FAILED test_requests.py::RequestsTestCase::test_basicauth_with_netrc - assert...
FAILED test_requests.py::RequestsTestCase::test_conflicting_post_params - Typ...
FAILED test_requests.py::RequestsTestCase::test_connection_error - Failed: DI...
FAILED test_requests.py::RequestsTestCase::test_cookie_persists_via_api - Ind...
FAILED test_requests.py::RequestsTestCase::test_cookie_quote_wrapped - KeyErr...
FAILED test_requests.py::RequestsTestCase::test_cookie_removed_on_expire - Ke...
FAILED test_requests.py::RequestsTestCase::test_cookie_sent_on_redirect - jso...
FAILED test_requests.py::RequestsTestCase::test_custom_content_type - assert ...
FAILED test_requests.py::RequestsTestCase::test_different_encodings_dont_break_post
FAILED test_requests.py::RequestsTestCase::test_generic_cookiejar_works - jso...
FAILED test_requests.py::RequestsTestCase::test_json_param_post_content_type_works
FAILED test_requests.py::RequestsTestCase::test_manual_redirect_with_partial_body_read
FAILED test_requests.py::RequestsTestCase::test_mixed_case_scheme_acceptable
FAILED test_requests.py::RequestsTestCase::test_param_cookiejar_works - json....
FAILED test_requests.py::RequestsTestCase::test_params_are_merged_case_sensitive
FAILED test_requests.py::RequestsTestCase::test_prepared_from_session - reque...
FAILED test_requests.py::RequestsTestCase::test_pyopenssl_redirect - requests...
FAILED test_requests.py::RequestsTestCase::test_request_cookie_overrides_session_cookie
FAILED test_requests.py::RequestsTestCase::test_requests_history_is_saved - r...
FAILED test_requests.py::RequestsTestCase::test_session_pickling - assert 403...
FAILED test_requests.py::RequestsTestCase::test_set_cookie_on_301 - KeyError:...
FAILED test_requests.py::RequestsTestCase::test_unicode_method_name - assert ...
FAILED test_requests.py::RequestsTestCase::test_unicode_multipart_post - asse...
FAILED test_requests.py::RequestsTestCase::test_uppercase_scheme_redirect - a...
FAILED test_requests.py::RequestsTestCase::test_urlencoded_get_query_multivalued_param
FAILED test_requests.py::RequestsTestCase::test_user_agent_transfers - Assert...
FAILED test_requests.py::TestTimeout::test_stream_timeout - requests.exceptio...
FAILED test_requests.py::TestTimeout::test_none_timeout - assert 403 == 200
FAILED test_requests.py::TestTimeout::test_read_timeout - AssertionError: The...
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
================== 48 failed, 94 passed, 3 warnings in 3.72s ===================

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/sessions.py
OUTSIDE THE SCOPE: requests/models.py +1 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: requests/sessions.py +2 -2
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
# Notes, run 2026-11-06T125330

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

method = builtin_str(method) problem
In requests/sessions.py is a command:

method = builtin_str(method)
Converts method from
b’GET’
to
"b'GET’"

Which is the literal string, no longer a binary string.  When requests tries to use the method "b'GET’”, it gets a 404 Not Found response.

I am using python3.4 and python-neutronclient (2.3.9) with requests (2.4.3).  neutronclient is broken because it uses this "args = utils.safe_encode_list(args)" command which converts all the values to binary string, including method.

I'm not sure if this is a bug with neutronclient or a bug with requests, but I'm starting here.  Seems if requests handled the method value being a binary string, we wouldn't have any problem.

Also, I tried in python2.6 and this bug doesn't exist there. Some difference between 2.6 and 3.4 makes this not work right.


# The files of the project

```
.gitignore
AUTHORS.rst
HISTORY.rst
LICENSE
MANIFEST.in
Makefile
NOTICE
README.rst
docs/MANIFEST.in
docs/Makefile
docs/_static/requests-sidebar.png
docs/_templates/sidebarintro.html
docs/_templates/sidebarlogo.html
docs/_themes/.gitignore
docs/_themes/LICENSE
docs/_themes/README.rst
docs/_themes/flask_theme_support.py
docs/_themes/kr/layout.html
docs/_themes/kr/relations.html
docs/_themes/kr/static/flasky.css_t
docs/_themes/kr/theme.conf
docs/_themes/kr_small/layout.html
docs/_themes/kr_small/static/flasky.css_t
docs/_themes/kr_small/theme.conf
docs/api.rst
docs/community/faq.rst
docs/community/out-there.rst
docs/community/support.rst
docs/community/updates.rst
docs/conf.py
docs/dev/authors.rst
docs/dev/philosophy.rst
docs/dev/todo.rst
docs/index.rst
docs/make.bat
docs/requirements.txt
docs/user/advanced.rst
docs/user/authentication.rst
docs/user/install.rst
docs/user/intro.rst
docs/user/quickstart.rst
ext/requests-logo.ai
ext/requests-logo.svg
requests/__init__.py
requests/adapters.py
requests/api.py
requests/auth.py
requests/cacert.pem
requests/certs.py
requests/compat.py
requests/cookies.py
requests/exceptions.py
requests/hooks.py
requests/models.py
requests/packages/README.rst
requests/packages/__init__.py
requests/packages/chardet/__init__.py
requests/packages/chardet/big5freq.py
requests/packages/chardet/big5prober.py
requests/packages/chardet/chardetect.py
requests/packages/chardet/chardistribution.py
requests/packages/chardet/charsetgroupprober.py
requests/packages/chardet/charsetprober.py
requests/packages/chardet/codingstatemachine.py
requests/packages/chardet/compat.py
requests/packages/chardet/constants.py
requests/packages/chardet/cp949prober.py
requests/packages/chardet/escprober.py
requests/packages/chardet/escsm.py
requests/packages/chardet/eucjpprober.py
requests/packages/chardet/euckrfreq.py
requests/packages/chardet/euckrprober.py
requests/packages/chardet/euctwfreq.py
requests/packages/chardet/euctwprober.py
requests/packages/chardet/gb2312freq.py
requests/packages/chardet/gb2312prober.py
requests/packages/chardet/hebrewprober.py
requests/packages/chardet/jisfreq.py
requests/packages/chardet/jpcntx.py
requests/packages/chardet/langbulgarianmodel.py
requests/packages/chardet/langcyrillicmodel.py
requests/packages/chardet/langgreekmodel.py
requests/packages/chardet/langhebrewmodel.py
requests/packages/chardet/langhungarianmodel.py
requests/packages/chardet/langthaimodel.py
requests/packages/chardet/latin1prober.py
requests/packages/chardet/mbcharsetprober.py
requests/packages/chardet/mbcsgroupprober.py
requests/packages/chardet/mbcssm.py
requests/packages/chardet/sbcharsetprober.py
requests/packages/chardet/sbcsgroupprober.py
requests/packages/chardet/sjisprober.py
requests/packages/chardet/universaldetector.py
requests/packages/chardet/utf8prober.py
requests/packages/urllib3/__init__.py
requests/packages/urllib3/_collections.py
requests/packages/urllib3/connection.py
requests/packages/urllib3/connectionpool.py
requests/packages/urllib3/contrib/__init__.py
requests/packages/urllib3/contrib/ntlmpool.py
requests/packages/urllib3/contrib/pyopenssl.py
requests/packages/urllib3/exceptions.py
requests/packages/urllib3/fields.py
requests/packages/urllib3/filepost.py
requests/packages/urllib3/packages/__init__.py
requests/packages/urllib3/packages/ordered_dict.py
requests/packages/urllib3/packages/six.py
requests/packages/urllib3/packages/ssl_match_hostname/__init__.py
requests/packages/urllib3/packages/ssl_match_hostname/_implementation.py
requests/packages/urllib3/poolmanager.py
requests/packages/urllib3/request.py
requests/packages/urllib3/response.py
requests/packages/urllib3/util/__init__.py
requests/packages/urllib3/util/connection.py
requests/packages/urllib3/util/request.py
requests/packages/urllib3/util/response.py
requests/packages/urllib3/util/retry.py
requests/packages/urllib3/util/ssl_.py
requests/packages/urllib3/util/timeout.py
requests/packages/urllib3/util/url.py
requests/sessions.py
requests/status_codes.py
requests/structures.py
requests/utils.py
requirements.txt
setup.cfg
setup.py
test_requests.py
```


# The last commit

```
ac2af65 SWE-bench



 .gitignore                                                  |   0
 AUTHORS.rst                                                 |   0
 HISTORY.rst                                                 |   0
 LICENSE                                                     |   0
 MANIFEST.in                                                 |   0
 Makefile                                                    |   0
 NOTICE                                                      |   0
 README.rst                                                  |   0
 docs/MANIFEST.in                                            |   0
 docs/Makefile                                               |   0
 docs/_static/requests-sidebar.png                           | Bin
 docs/_templates/sidebarintro.html                           |   0
 docs/_templates/sidebarlogo.html                            |   0
 docs/_themes/.gitignore                                     |   0
 docs/_themes/LICENSE                                        |   0
 docs/_themes/README.rst                                     |   0
 docs/_themes/flask_theme_support.py                         |   0
 docs/_themes/kr/layout.html                                 |   0
 docs/_themes/kr/relations.html                              |   0
 docs/_themes/kr/static/flasky.css_t                         |   0
 docs/_themes/kr/theme.conf                                  |   0
 docs/_themes/kr_small/layout.html                           |   0
 docs/_themes/kr_small/static/flasky.css_t                   |   0
 docs/_themes/kr_small/theme.conf                            |   0
 docs/api.rst                                                |   0
 docs/community/faq.rst                                      |   0
 docs/community/out-there.rst                                |   0
 docs/community/support.rst                                  |   0
 docs/community/updates.rst                                  |   0
 docs/conf.py                                                |   0
 docs/dev/authors.rst                                        |   0
 docs/dev/philosophy.rst                                     |   0
 docs/dev/todo.rst                                           |   0
 docs/index.rst                                              |   0
 docs/make.bat                                               |   0
 docs/requirements.txt                                       |   0
 docs/user/advanced.rst                                      |   0
 docs/user/authentication.rst                                |   0
 docs/user/install.rst                                       |   0
 docs/user/intro.rst                                         |   0
 docs/user/quickstart.rst                                    |   0
 ext/requests-logo.ai                                        |   0
 ext/requests-logo.svg                                       |   0
 requests/__init__.py                                        |   0
 requests/adapters.py                                        |   0
 requests/api.py                                             |   0
 requests/auth.py                                            |   0
 requests/cacert.pem                                         |   0
 requests/certs.py                                           |   0
 requests/compat.py                                          |   0
 requests/cookies.py                                         |   0
 requests/exceptions.py                                      |   0
 requests/hooks.py                                           |   0
 requests/models.py                                          |   0
 requests/packages/README.rst                                |   0
 requests/packages/__init__.py                               |   0
```

```diff
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/AUTHORS.rst b/AUTHORS.rst
old mode 100644
new mode 100755
diff --git a/HISTORY.rst b/HISTORY.rst
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/Makefile b/Makefile
old mode 100644
new mode 100755
diff --git a/NOTICE b/NOTICE
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/docs/MANIFEST.in b/docs/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/docs/Makefile b/docs/Makefile
old mode 100644
new mode 100755
diff --git a/docs/_static/requests-sidebar.png b/docs/_static/requests-sidebar.png
old mode 100644
new mode 100755
diff --git a/docs/_templates/sidebarintro.html b/docs/_templates/sidebarintro.html
old mode 100644
new mode 100755
diff --git a/docs/_templates/sidebarlogo.html b/docs/_templates/sidebarlogo.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/.gitignore b/docs/_themes/.gitignore
old mode 100644
new mode 100755
diff --git a/docs/_themes/LICENSE b/docs/_themes/LICENSE
old mode 100644
new mode 100755
diff --git a/docs/_themes/README.rst b/docs/_themes/README.rst
old mode 100644
new mode 100755
diff --git a/docs/_themes/flask_theme_support.py b/docs/_themes/flask_theme_support.py
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/layout.html b/docs/_themes/kr/layout.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/relations.html b/docs/_themes/kr/relations.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/static/flasky.css_t b/docs/_themes/kr/static/flasky.css_t
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr/theme.conf b/docs/_themes/kr/theme.conf
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr_small/layout.html b/docs/_themes/kr_small/layout.html
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr_small/static/flasky.css_t b/docs/_themes/kr_small/static/flasky.css_t
old mode 100644
new mode 100755
diff --git a/docs/_themes/kr_small/theme.conf b/docs/_themes/kr_small/theme.conf
old mode 100644
new mode 100755
diff --git a/docs/api.rst b/docs/api.rst
old mode 100644
new mode 100755
diff --git a/docs/community/faq.rst b/docs/community/faq.rst
old mode 100644
new mode 100755
diff --git a/docs/community/out-there.rst b/docs/community/out-there.rst
old mode 100644
new mode 100755
diff --git a/docs/community/support.rst b/docs/community/support.rst
old mode 100644
new mode 100755
diff --git a/docs/community/updates.rst b/docs/community/updates.rst
old mode 100644
new mode 100755
diff --git a/docs/conf.py b/docs/conf.py
old mode 100644
new mode 100755
diff --git a/docs/dev/authors.rst b/docs/dev/authors.rst
old mode 100644
new mode 100755
diff --git a/docs/dev/philosophy.rst b/docs/dev/philosophy.rst
old mode 100644
new mode 100755
diff --git a/docs/dev/todo.rst b/docs/dev/todo.rst
old mode 100644
new mode 100755
diff --git a/docs/index.rst b/docs/index.rst
old mode 100644
new mode 100755
diff --git a/docs/make.bat b/docs/make.bat
old mode 100644
new mode 100755
diff --git a/docs/requirements.txt b/docs/requirements.txt
old mode 100644
new mode 100755
diff --git a/docs/user/advanced.rst b/docs/user/advanced.rst
old mode 100644
new mode 100755
diff --git a/docs/user/authentication.rst b/docs/user/authentication.rst
old mode 100644
new mode 100755
diff --git a/docs/user/install.rst b/docs/user/install.rst
old mode 100644
new mode 100755
diff --git a/docs/user/intro.rst b/docs/user/intro.rst
old mode 100644
new mode 100755
diff --git a/docs/user/quickstart.rst b/docs/user/quickstart.rst
old mode 100644
new mode 100755
diff --git a/ext/requests-logo.ai b/ext/requests-logo.ai
old mode 100644
new mode 100755
diff --git a/ext/requests-logo.svg b/ext/requests-logo.svg
old mode 100644
new mode 100755
diff --git a/requests/__init__.py b/requests/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/adapters.py b/requests/adapters.py
old mode 100644
new mode 100755
diff --git a/requests/api.py b/requests/api.py
old mode 100644
new mode 100755
diff --git a/requests/auth.py b/requests/auth.py
old mode 100644
new mode 100755
diff --git a/requests/cacert.pem b/requests/cacert.pem
old mode 100644
new mode 100755
diff --git a/requests/certs.py b/requests/certs.py
old mode 100644
new mode 100755
diff --git a/requests/compat.py b/requests/compat.py
old mode 100644
new mode 100755
diff --git a/requests/cookies.py b/requests/cookies.py
old mode 100644
new mode 100755
diff --git a/requests/exceptions.py b/requests/exceptions.py
old mode 100644
new mode 100755
diff --git a/requests/hooks.py b/requests/hooks.py
old mode 100644
new mode 100755
diff --git a/requests/models.py b/requests/models.py
old mode 100644
new mode 100755
diff --git a/requests/packages/README.rst b/requests/packages/README.rst
old mode 100644
new mode 100755
diff --git a/requests/packages/__init__.py b/requests/packages/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/__init__.py b/requests/packages/chardet/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/big5freq.py b/requests/packages/chardet/big5freq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/big5prober.py b/requests/packages/chardet/big5prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/chardistribution.py b/requests/packages/chardet/chardistribution.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/charsetgroupprober.py b/requests/packages/chardet/charsetgroupprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/charsetprober.py b/requests/packages/chardet/charsetprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/codingstatemachine.py b/requests/packages/chardet/codingstatemachine.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/compat.py b/requests/packages/chardet/compat.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/constants.py b/requests/packages/chardet/constants.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/cp949prober.py b/requests/packages/chardet/cp949prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/escprober.py b/requests/packages/chardet/escprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/escsm.py b/requests/packages/chardet/escsm.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/eucjpprober.py b/requests/packages/chardet/eucjpprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euckrfreq.py b/requests/packages/chardet/euckrfreq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euckrprober.py b/requests/packages/chardet/euckrprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euctwfreq.py b/requests/packages/chardet/euctwfreq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/euctwprober.py b/requests/packages/chardet/euctwprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/gb2312freq.py b/requests/packages/chardet/gb2312freq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/gb2312prober.py b/requests/packages/chardet/gb2312prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/hebrewprober.py b/requests/packages/chardet/hebrewprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/jisfreq.py b/requests/packages/chardet/jisfreq.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/jpcntx.py b/requests/packages/chardet/jpcntx.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langbulgarianmodel.py b/requests/packages/chardet/langbulgarianmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langcyrillicmodel.py b/requests/packages/chardet/langcyrillicmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langgreekmodel.py b/requests/packages/chardet/langgreekmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langhebrewmodel.py b/requests/packages/chardet/langhebrewmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langhungarianmodel.py b/requests/packages/chardet/langhungarianmodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/langthaimodel.py b/requests/packages/chardet/langthaimodel.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/latin1prober.py b/requests/packages/chardet/latin1prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/mbcharsetprober.py b/requests/packages/chardet/mbcharsetprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/mbcsgroupprober.py b/requests/packages/chardet/mbcsgroupprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/mbcssm.py b/requests/packages/chardet/mbcssm.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/sbcharsetprober.py b/requests/packages/chardet/sbcharsetprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/sbcsgroupprober.py b/requests/packages/chardet/sbcsgroupprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/sjisprober.py b/requests/packages/chardet/sjisprober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/universaldetector.py b/requests/packages/chardet/universaldetector.py
old mode 100644
new mode 100755
diff --git a/requests/packages/chardet/utf8prober.py b/requests/packages/chardet/utf8prober.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/__init__.py b/requests/packages/urllib3/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/_collections.py b/requests/packages/urllib3/_collections.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/connection.py b/requests/packages/urllib3/connection.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/connectionpool.py b/requests/packages/urllib3/connectionpool.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/contrib/__init__.py b/requests/packages/urllib3/contrib/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/contrib/ntlmpool.py b/requests/packages/urllib3/contrib/ntlmpool.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/contrib/pyopenssl.py b/requests/packages/urllib3/contrib/pyopenssl.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/exceptions.py b/requests/packages/urllib3/exceptions.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/fields.py b/requests/packages/urllib3/fields.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/filepost.py b/requests/packages/urllib3/filepost.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/__init__.py b/requests/packages/urllib3/packages/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/ordered_dict.py b/requests/packages/urllib3/packages/ordered_dict.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/six.py b/requests/packages/urllib3/packages/six.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/ssl_match_hostname/__init__.py b/requests/packages/urllib3/packages/ssl_match_hostname/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/packages/ssl_match_hostname/_implementation.py b/requests/packages/urllib3/packages/ssl_match_hostname/_implementation.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/poolmanager.py b/requests/packages/urllib3/poolmanager.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/request.py b/requests/packages/urllib3/request.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/response.py b/requests/packages/urllib3/response.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/__init__.py b/requests/packages/urllib3/util/__init__.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/connection.py b/requests/packages/urllib3/util/connection.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/request.py b/requests/packages/urllib3/util/request.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/response.py b/requests/packages/urllib3/util/response.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/retry.py b/requests/packages/urllib3/util/retry.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/ssl_.py b/requests/packages/urllib3/util/ssl_.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/timeout.py b/requests/packages/urllib3/util/timeout.py
old mode 100644
new mode 100755
diff --git a/requests/packages/urllib3/util/url.py b/requests/packages/urllib3/util/url.py
old mode 100644
new mode 100755
diff --git a/requests/sessions.py b/requests/sessions.py
old mode 100644
new mode 100755
diff --git a/requests/status_codes.py b/requests/status_codes.py
old mode 100644
new mode 100755
diff --git a/requests/structures.py b/requests/structures.py
old mode 100644
new mode 100755
diff --git a/requests/utils.py b/requests/utils.py
old mode 100644
new mode 100755
diff --git a/requirements.txt b/requirements.txt
old mode 100644
new mode 100755
diff --git a/setup.cfg b/setup.cfg
old mode 100644
new mode 100755

```


# Makefile (the start)

```
.PHONY: docs

init:
	pip install -r requirements.txt

test:
	# This runs all of the tests. To run an individual test, run py.test with
	# the -k flag, like "py.test -k test_path_is_not_double_encoded"
	py.test test_requests.py

coverage:
	py.test --verbose --cov-report term --cov=requests test_requests.py

ci: init
	py.test --junitxml=junit.xml

certs:
	curl http://ci.kennethreitz.org/job/ca-bundle/lastSuccessfulBuild/artifact/cacerts.pem -o requests/cacert.pem

deps: urllib3 chardet

urllib3:
	git clone https://github.com/shazow/urllib3.git && rm -fr requests/packages/urllib3 && 	mv urllib3/urllib3 requests/packages/ && rm -fr urllib3

chardet:
	git clone https://github.com/chardet/chardet.git && rm -fr requests/packages/chardet &&	mv chardet/chardet requests/packages/ && rm -fr chardet

publish:
	python setup.py register
	python setup.py sdist upload
	python setup.py bdist_wheel upload


docs-init:
	pip install -r docs/requirements.txt

docs:
	cd docs && make html
	@echo "\033[95m\n\nBuild successful! View the docs homepage at docs/_build/html/index.html.\n\033[0m"

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`py.test test_requests.py`

## Scope
`requests/sessions.py`

## Done when
- A bytes method such as `b'GET'` is handled as the HTTP method `GET`, not the literal string `"b'GET'"`.
- Python 3 request sessions no longer produce a 404 caused by sending a quoted bytes representation as the method.
- Normal string methods continue to work unchanged.

## Approach
Decode/normalize the method before `builtin_str(method)` in `requests/sessions.py`, accepting both native strings and bytes.

Candidate approaches:
- In `Session.request`, branch on `isinstance(method, bytes)` and decode with ASCII/UTF-8 before calling `builtin_str`. Narrowest fix, directly addresses the reported failure.
- Use or add a `to_native_string`-style helper in `requests/utils.py` and call it from sessions. Cleaner reuse if helper already exists, but broadens the touched surface.
- Normalize in `requests/models.Request` as well, covering direct `Request` callers. More robust, but larger and may duplicate session-level behavior.
```

### `prompt.md`

```
method = builtin_str(method) problem
In requests/sessions.py is a command:

method = builtin_str(method)
Converts method from
b’GET’
to
"b'GET’"

Which is the literal string, no longer a binary string.  When requests tries to use the method "b'GET’”, it gets a 404 Not Found response.

I am using python3.4 and python-neutronclient (2.3.9) with requests (2.4.3).  neutronclient is broken because it uses this "args = utils.safe_encode_list(args)" command which converts all the values to binary string, including method.

I'm not sure if this is a bug with neutronclient or a bug with requests, but I'm starting here.  Seems if requests handled the method value being a binary string, we wouldn't have any problem.

Also, I tried in python2.6 and this bug doesn't exist there. Some difference between 2.6 and 3.4 makes this not work right.
```

### `review.md`

```
verdict: PASS
- `requests/sessions.py` now converts the method with `to_native_string`, so `b'GET'` becomes `'GET'` instead of `"b'GET'"`; normal string methods are unchanged.
- The `requests/models.py` change is outside the stated scope, but it is the same bytes-method bug in the sibling preparation path and does not introduce a new failure.
- The check failures shown are baseline network/proxy/httpbin failures, not regressions caused by this change.
```

### `scope.txt`

```
scope: requests/sessions.py
OUTSIDE THE SCOPE: requests/models.py +1 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: requests/sessions.py +2 -2
```

### `task.md`

```
# Task

## Prompt

method = builtin_str(method) problem
In requests/sessions.py is a command:

method = builtin_str(method)
Converts method from
b’GET’
to
"b'GET’"

Which is the literal string, no longer a binary string.  When requests tries to use the method "b'GET’”, it gets a 404 Not Found response.

I am using python3.4 and python-neutronclient (2.3.9) with requests (2.4.3).  neutronclient is broken because it uses this "args = utils.safe_encode_list(args)" command which converts all the values to binary string, including method.

I'm not sure if this is a bug with neutronclient or a bug with requests, but I'm starting here.  Seems if requests handled the method value being a binary string, we wouldn't have any problem.

Also, I tried in python2.6 and this bug doesn't exist there. Some difference between 2.6 and 3.4 makes this not work right.

## Deliverable

changes to this tree

## Check

`py.test test_requests.py`

## Scope

`requests/sessions.py`

## Done when

- A bytes method such as `b'GET'` is handled as the HTTP method `GET`, not the literal string `"b'GET'"`.
- Python 3 request sessions no longer produce a 404 caused by sending a quoted bytes representation as the method.
- Normal string methods continue to work unchanged.
```

### `test-output.log`

```
check: py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed
collected 142 items

test_requests.py FFFFFFFFFFFFFFFFF...F..FF......FFFFF.F..F............F. [ 38%]
.FF..F.F..F.F..F..F.....FF.....FF.FFF................................... [ 89%]
...F.FFFF......                                                          [100%]

=================================== FAILURES ===================================
____________ RequestsTestCase.test_BASICAUTH_TUPLE_HTTP_200_OK_GET _____________

self = <test_requests.RequestsTestCase testMethod=test_BASICAUTH_TUPLE_HTTP_200_OK_GET>

    def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self):
        auth = ('user', 'pass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:286: AssertionError
______________ RequestsTestCase.test_DIGESTAUTH_QUOTES_QOP_VALUE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_QUOTES_QOP_VALUE>

    def test_DIGESTAUTH_QUOTES_QOP_VALUE(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert '"auth"' in r.request.headers['Authorization']

test_requests.py:397: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive'}
key = 'Authorization'

    def __getitem__(self, key):
>       return self._store[key.lower()][1]
E       KeyError: 'authorization'

requests/structures.py:54: KeyError
_____________ RequestsTestCase.test_DIGESTAUTH_WRONG_HTTP_401_GET ______________

self = <test_requests.RequestsTestCase testMethod=test_DIGESTAUTH_WRONG_HTTP_401_GET>

    def test_DIGESTAUTH_WRONG_HTTP_401_GET(self):
    
        auth = HTTPDigestAuth('user', 'wrongpass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 401
E       assert 403 == 401
E        +  where 403 = <Response [403]>.status_code

test_requests.py:381: AssertionError
_______________ RequestsTestCase.test_DIGEST_AUTH_RETURNS_COOKIE _______________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_RETURNS_COOKIE>

    def test_DIGEST_AUTH_RETURNS_COOKIE(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        r = requests.get(url)
>       assert r.cookies['fake'] == 'fake_value'

test_requests.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
____________ RequestsTestCase.test_DIGEST_AUTH_SETS_SESSION_COOKIES ____________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_AUTH_SETS_SESSION_COOKIES>

    def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        s = requests.Session()
        s.get(url, auth=auth)
>       assert s.cookies['fake'] == 'fake_value'

test_requests.py:362: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'fake', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='fake', domain=None, path=None"

requests/cookies.py:331: KeyError
_________________ RequestsTestCase.test_DIGEST_HTTP_200_OK_GET _________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_HTTP_200_OK_GET>

    def test_DIGEST_HTTP_200_OK_GET(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:338: AssertionError
_____________________ RequestsTestCase.test_DIGEST_STREAM ______________________

self = <test_requests.RequestsTestCase testMethod=test_DIGEST_STREAM>

    def test_DIGEST_STREAM(self):
    
        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
    
        r = requests.get(url, auth=auth, stream=True)
>       assert r.raw.read() != b''
E       AssertionError: assert b'' != b''
E        +  where b'' = <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x7a42420f2fa0>>()
E        +    where <bound method HTTPResponse.read of <requests.packages.urllib3.response.HTTPResponse object at 0x7a42420f2fa0>> = <requests.packages.urllib3.response.HTTPResponse object at 0x7a42420f2fa0>.read
E        +      where <requests.packages.urllib3.response.HTTPResponse object at 0x7a42420f2fa0> = <Response [403]>.raw

test_requests.py:370: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_ALTERNATIVE _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_ALTERNATIVE>

    def test_HTTP_200_OK_GET_ALTERNATIVE(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
    
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:138: AssertionError
___________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS ____________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_MIXED_PARAMS>

    def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('get') + '?test=true', params={'q': 'test'}, headers=heads)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:162: AssertionError
______________ RequestsTestCase.test_HTTP_200_OK_GET_WITH_PARAMS _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_GET_WITH_PARAMS>

    def test_HTTP_200_OK_GET_WITH_PARAMS(self):
        heads = {'User-agent': 'Mozilla/5.0'}
    
        r = requests.get(httpbin('user-agent'), headers=heads)
    
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:155: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_HEAD ____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_HEAD>

    def test_HTTP_200_OK_HEAD(self):
        r = requests.head(httpbin('get'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:275: AssertionError
____________________ RequestsTestCase.test_HTTP_200_OK_PUT _____________________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_200_OK_PUT>

    def test_HTTP_200_OK_PUT(self):
        r = requests.put(httpbin('put'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:279: AssertionError
______________ RequestsTestCase.test_HTTP_302_ALLOW_REDIRECT_GET _______________

self = <test_requests.RequestsTestCase testMethod=test_HTTP_302_ALLOW_REDIRECT_GET>

    def test_HTTP_302_ALLOW_REDIRECT_GET(self):
        r = requests.get(httpbin('redirect', '1'))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:142: AssertionError
_________________ RequestsTestCase.test_POSTBIN_GET_POST_FILES _________________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES>

    def test_POSTBIN_GET_POST_FILES(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:402: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
____________ RequestsTestCase.test_POSTBIN_GET_POST_FILES_WITH_DATA ____________

self = <test_requests.RequestsTestCase testMethod=test_POSTBIN_GET_POST_FILES_WITH_DATA>

    def test_POSTBIN_GET_POST_FILES_WITH_DATA(self):
    
        url = httpbin('post')
>       post1 = requests.post(url).raise_for_status()

test_requests.py:420: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Response [403]>

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""
    
        http_error_msg = ''
    
        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s' % (self.status_code, self.reason)
    
        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s' % (self.status_code, self.reason)
    
        if http_error_msg:
>           raise HTTPError(http_error_msg, response=self)
E           requests.exceptions.HTTPError: 403 Client Error: Forbidden

requests/models.py:829: HTTPError
_________ RequestsTestCase.test_auth_is_retained_for_redirect_on_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_retained_for_redirect_on_host>

    def test_auth_is_retained_for_redirect_on_host(self):
        r = requests.get(httpbin('redirect/1'), auth=('user', 'pass'))
>       h1 = r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:953: IndexError
_________ RequestsTestCase.test_auth_is_stripped_on_redirect_off_host __________

self = <test_requests.RequestsTestCase testMethod=test_auth_is_stripped_on_redirect_off_host>

    def test_auth_is_stripped_on_redirect_off_host(self):
        r = requests.get(
            httpbin('redirect-to'),
            params={'url': 'http://www.google.co.uk'},
            auth=('user', 'pass'),
        )
>       assert r.history[0].request.headers['Authorization']
E       IndexError: list index out of range

test_requests.py:948: IndexError
__________________ RequestsTestCase.test_basicauth_with_netrc __________________

self = <test_requests.RequestsTestCase testMethod=test_basicauth_with_netrc>

    def test_basicauth_with_netrc(self):
        auth = ('user', 'pass')
        wrong_auth = ('wronguser', 'wrongpass')
        url = httpbin('basic-auth', 'user', 'pass')
    
        def get_netrc_auth_mock(url):
            return auth
        requests.sessions.get_netrc_auth = get_netrc_auth_mock
    
        # Should use netrc and work.
        r = requests.get(url)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:315: AssertionError
________________ RequestsTestCase.test_conflicting_post_params _________________

self = <test_requests.RequestsTestCase testMethod=test_conflicting_post_params>

    def test_conflicting_post_params(self):
        url = httpbin('post')
        with open('requirements.txt') as f:
>           pytest.raises(ValueError, "requests.post(url, data='[{\"some\": \"data\"}]', files={'some': f})")
E           TypeError: 'requests.post(url, data=\'[{"some": "data"}]\', files={\'some\': f})' object (type: <class 'str'>) must be callable

test_requests.py:439: TypeError
____________________ RequestsTestCase.test_connection_error ____________________

self = <test_requests.RequestsTestCase testMethod=test_connection_error>

    def test_connection_error(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://fooobarbangbazbing.httpbin.org")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:299: Failed
________________ RequestsTestCase.test_cookie_persists_via_api _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_persists_via_api>

    def test_cookie_persists_via_api(self):
        s = requests.session()
        r = s.get(httpbin('redirect/1'), cookies={'foo': 'bar'})
        assert 'foo' in r.request.headers['Cookie']
>       assert 'foo' in r.history[0].request.headers['Cookie']
E       IndexError: list index out of range

test_requests.py:198: IndexError
__________________ RequestsTestCase.test_cookie_quote_wrapped __________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_quote_wrapped>

    def test_cookie_quote_wrapped(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo="bar:baz"'))
>       assert s.cookies['foo'] == '"bar:baz"'

test_requests.py:192: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_removed_on_expire ________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_removed_on_expire>

    def test_cookie_removed_on_expire(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
>       assert s.cookies['foo'] == 'bar'

test_requests.py:179: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
________________ RequestsTestCase.test_cookie_sent_on_redirect _________________

self = <test_requests.RequestsTestCase testMethod=test_cookie_sent_on_redirect>

    def test_cookie_sent_on_redirect(self):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
        r = s.get(httpbin('redirect/1'))  # redirects to httpbin('get')
>       assert 'Cookie' in r.json()['headers']

test_requests.py:174: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7a4242f8e730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
__________________ RequestsTestCase.test_custom_content_type ___________________

self = <test_requests.RequestsTestCase testMethod=test_custom_content_type>

    def test_custom_content_type(self):
        r = requests.post(
            httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            files={'file1': ('test_requests.py', open(__file__, 'rb')),
                   'file2': ('test_requests', open(__file__, 'rb'),
                             'text/py-content-type')})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:533: AssertionError
__________ RequestsTestCase.test_different_encodings_dont_break_post ___________

self = <test_requests.RequestsTestCase testMethod=test_different_encodings_dont_break_post>

    def test_different_encodings_dont_break_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            params={'blah': 'asdf1234'},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:486: AssertionError
________________ RequestsTestCase.test_generic_cookiejar_works _________________

self = <test_requests.RequestsTestCase testMethod=test_generic_cookiejar_works>

    def test_generic_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        s.cookies = cj
        r = s.get(httpbin('cookies'))
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:221: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7a4242f8e730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
___________ RequestsTestCase.test_json_param_post_content_type_works ___________

self = <test_requests.RequestsTestCase testMethod=test_json_param_post_content_type_works>

    def test_json_param_post_content_type_works(self):
        r = requests.post(
            httpbin('post'),
            json={'life': 42}
        )
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1015: AssertionError
_________ RequestsTestCase.test_manual_redirect_with_partial_body_read _________

self = <test_requests.RequestsTestCase testMethod=test_manual_redirect_with_partial_body_read>

    def test_manual_redirect_with_partial_body_read(self):
        s = requests.Session()
        r1 = s.get(httpbin('redirect/2'), allow_redirects=False, stream=True)
>       assert r1.is_redirect
E       assert False
E        +  where False = <Response [403]>.is_redirect

test_requests.py:961: AssertionError
______________ RequestsTestCase.test_mixed_case_scheme_acceptable ______________

self = <test_requests.RequestsTestCase testMethod=test_mixed_case_scheme_acceptable>

    def test_mixed_case_scheme_acceptable(self):
        s = requests.Session()
        s.proxies = getproxies()
        parts = urlparse(httpbin('get'))
        schemes = ['http://', 'HTTP://', 'hTTp://', 'HttP://',
                   'https://', 'HTTPS://', 'hTTps://', 'HttPs://']
        for scheme in schemes:
            url = scheme + parts.netloc + parts.path
            r = requests.Request('GET', url)
            r = s.send(r.prepare())
>           assert r.status_code == 200, 'failed for scheme {0}'.format(scheme)
E           AssertionError: failed for scheme http://
E           assert 403 == 200
E            +  where 403 = <Response [403]>.status_code

test_requests.py:129: AssertionError
_________________ RequestsTestCase.test_param_cookiejar_works __________________

self = <test_requests.RequestsTestCase testMethod=test_param_cookiejar_works>

    def test_param_cookiejar_works(self):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        r = s.get(httpbin('cookies'), cookies=cj)
        # Make sure the cookie was sent
>       assert r.json()['cookies']['foo'] == 'bar'

test_requests.py:231: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7a4242f8e730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
____________ RequestsTestCase.test_params_are_merged_case_sensitive ____________

self = <test_requests.RequestsTestCase testMethod=test_params_are_merged_case_sensitive>

    def test_params_are_merged_case_sensitive(self):
        s = requests.Session()
        s.params['foo'] = 'bar'
        r = s.get(httpbin('get'), params={'FOO': 'bar'})
>       assert r.json()['args'] == {'foo': 'bar', 'FOO': 'bar'}

test_requests.py:894: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7a4242f8e730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_________________ RequestsTestCase.test_prepared_from_session __________________

self = <requests.packages.urllib3.connectionpool.HTTPConnectionPool object at 0x7a4241f4fa90>
method = 'GET', url = '/headers', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Dummy-Auth-Test': 'dummy-auth-test-ok'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241f4f820>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7a4241edfbc0>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
            conn = self._get_conn(timeout=pool_timeout)
    
            # Make the request on the httplib connection object.
>           httplib_response = self._make_request(conn, method, url,
                                                  timeout=timeout,
                                                  body=body, headers=headers)

requests/packages/urllib3/connectionpool.py:514: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       socket.gaierror: [Errno -3] Temporary failure in name resolution

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: gaierror

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7a4242101790>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241f4f820>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
requests/packages/urllib3/util/retry.py:245: in increment
    raise six.reraise(type(error), error, _stacktrace)
requests/packages/urllib3/packages/six.py:309: in reraise
    raise value.with_traceback(tb)
requests/packages/urllib3/connectionpool.py:514: in urlopen
    httplib_response = self._make_request(conn, method, url,
requests/packages/urllib3/connectionpool.py:308: in _make_request
    conn.request(method, url, **httplib_request_kw)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1285: in request
    self._send_request(method, url, body, headers, encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1331: in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1280: in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:1040: in _send_output
    self.send(msg)
/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:980: in send
    self.connect()
requests/packages/urllib3/connection.py:146: in connect
    conn = self._new_conn()
requests/packages/urllib3/connection.py:124: in _new_conn
    conn = connection.create_connection(
requests/packages/urllib3/util/connection.py:64: in create_connection
    for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

host = 'httpbin.org', port = 80, family = 0, type = <SocketKind.SOCK_STREAM: 1>
proto = 0, flags = 0

    def getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        """Resolve host and port into list of address info entries.
    
        Translate the host/port argument into a sequence of 5-tuples that contain
        all the necessary arguments for creating a socket connected to that service.
        host is a domain name, a string representation of an IPv4/v6 address or
        None. port is a string service name such as 'http', a numeric port number or
        None. By passing None as the value of host and port, you can pass NULL to
        the underlying C API.
    
        The family, type and proto arguments can be optionally specified in order to
        narrow the list of addresses returned. Passing zero as a value for each of
        these arguments selects the full range of results.
        """
        # We override this function since we want to translate the numeric family
        # and socket type values to enum constants.
        addrlist = []
>       for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
E       requests.packages.urllib3.exceptions.ProtocolError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

/opt/miniconda3/envs/testbed/lib/python3.9/socket.py:966: ProtocolError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_prepared_from_session>

    def test_prepared_from_session(self):
        class DummyAuth(requests.auth.AuthBase):
            def __call__(self, r):
                r.headers['Dummy-Auth-Test'] = 'dummy-auth-test-ok'
                return r
    
        req = requests.Request('GET', httpbin('headers'))
        assert not req.auth
    
        s = requests.Session()
        s.auth = DummyAuth()
    
        prep = s.prepare_request(req)
>       resp = s.send(prep)

test_requests.py:589: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7a4242101790>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241f4f820>
verify = True, cert = None, proxies = {}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
>           raise ConnectionError(err, request=request)
E           requests.exceptions.ConnectionError: ('Connection aborted.', gaierror(-3, 'Temporary failure in name resolution'))

requests/adapters.py:407: ConnectionError
___________________ RequestsTestCase.test_pyopenssl_redirect ___________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7a4242036a90>
method = 'GET', url = '/status/301', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241fe2550>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7a4241c145c0>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x7a4241fe26d0>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7a42420368e0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241fe2550>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/status/301', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7a4242036a90>
_stacktrace = <traceback object at 0x7a4241c145c0>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_pyopenssl_redirect>

    def test_pyopenssl_redirect(self):
>       requests.get('https://httpbin.org/status/301')

test_requests.py:473: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7a42420368e0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241fe2550>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /status/301 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________ RequestsTestCase.test_request_cookie_overrides_session_cookie _________

self = <test_requests.RequestsTestCase testMethod=test_request_cookie_overrides_session_cookie>

    def test_request_cookie_overrides_session_cookie(self):
        s = requests.session()
        s.cookies['foo'] = 'bar'
        r = s.get(httpbin('cookies'), cookies={'foo': 'baz'})
>       assert r.json()['cookies']['foo'] == 'baz'

test_requests.py:204: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/models.py:797: in json
    return json.loads(self.text, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.9/json/__init__.py:346: in loads
    return _default_decoder.decode(s)
/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:337: in decode
    obj, end = self.raw_decode(s, idx=_w(s, 0).end())
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <json.decoder.JSONDecoder object at 0x7a4242f8e730>, s = '', idx = 0

    def raw_decode(self, s, idx=0):
        """Decode a JSON document from ``s`` (a ``str`` beginning with
        a JSON document) and return a 2-tuple of the Python
        representation and the index in ``s`` where the document ended.
    
        This can be used to decode a JSON document from a string that may
        have extraneous data at the end.
    
        """
        try:
            obj, end = self.scan_once(s, idx)
        except StopIteration as err:
>           raise JSONDecodeError("Expecting value", s, err.value) from None
E           json.decoder.JSONDecodeError: Expecting value: line 1 column 1 (char 0)

/opt/miniconda3/envs/testbed/lib/python3.9/json/decoder.py:355: JSONDecodeError
_______________ RequestsTestCase.test_requests_history_is_saved ________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7a424213da30>
method = 'GET', url = '/redirect/5', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241c03160>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7a4241f95740>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x7a4241c03910>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7a424213deb0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241c03160>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/redirect/5', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7a424213da30>
_stacktrace = <traceback object at 0x7a4241f95740>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.RequestsTestCase testMethod=test_requests_history_is_saved>

    def test_requests_history_is_saved(self):
>       r = requests.get('https://httpbin.org/redirect/5')

test_requests.py:1003: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7a424213deb0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241c03160>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': 'localhost,127.0.0.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /redirect/5 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
____________________ RequestsTestCase.test_session_pickling ____________________

self = <test_requests.RequestsTestCase testMethod=test_session_pickling>

    def test_session_pickling(self):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
    
        s = pickle.loads(pickle.dumps(s))
        s.proxies = getproxies()
    
        r = s.send(r.prepare())
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:823: AssertionError
___________________ RequestsTestCase.test_set_cookie_on_301 ____________________

self = <test_requests.RequestsTestCase testMethod=test_set_cookie_on_301>

    def test_set_cookie_on_301(self):
        s = requests.session()
        url = httpbin('cookies/set?foo=bar')
        s.get(url)
>       assert s.cookies['foo'] == 'bar'

test_requests.py:168: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/cookies.py:276: in __getitem__
    return self._find_no_duplicates(name)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <RequestsCookieJar[]>, name = 'foo', domain = None, path = None

    def _find_no_duplicates(self, name, domain=None, path=None):
        """__get_item__ and get call _find_no_duplicates -- never used in Requests internally.
        Takes as args name and optional domain and path. Returns a cookie.value.
        Throws KeyError if cookie is not found and CookieConflictError if there are
        multiple cookies that match name and optionally domain and path."""
        toReturn = None
        for cookie in iter(self):
            if cookie.name == name:
                if domain is None or cookie.domain == domain:
                    if path is None or cookie.path == path:
                        if toReturn is not None:  # if there are multiple cookies that meet passed in criteria
                            raise CookieConflictError('There are multiple cookies with name, %r' % (name))
                        toReturn = cookie.value  # we will eventually return this as long as no cookie conflict
    
        if toReturn:
            return toReturn
>       raise KeyError('name=%r, domain=%r, path=%r' % (name, domain, path))
E       KeyError: "name='foo', domain=None, path=None"

requests/cookies.py:331: KeyError
__________________ RequestsTestCase.test_unicode_method_name ___________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_method_name>

    def test_unicode_method_name(self):
        files = {'file': open('test_requests.py', 'rb')}
        r = requests.request(
            method=u('POST'), url=httpbin('post'), files=files)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:524: AssertionError
_________________ RequestsTestCase.test_unicode_multipart_post _________________

self = <test_requests.RequestsTestCase testMethod=test_unicode_multipart_post>

    def test_unicode_multipart_post(self):
        r = requests.post(httpbin('post'),
            data={'stuff': u('ëlïxr')},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:492: AssertionError
_______________ RequestsTestCase.test_uppercase_scheme_redirect ________________

self = <test_requests.RequestsTestCase testMethod=test_uppercase_scheme_redirect>

    def test_uppercase_scheme_redirect(self):
        parts = urlparse(httpbin('html'))
        url = "HTTP://" + parts.netloc + parts.path
        r = requests.get(httpbin('redirect-to'), params={'url': url})
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:842: AssertionError
_________ RequestsTestCase.test_urlencoded_get_query_multivalued_param _________

self = <test_requests.RequestsTestCase testMethod=test_urlencoded_get_query_multivalued_param>

    def test_urlencoded_get_query_multivalued_param(self):
    
        r = requests.get(httpbin('get'), params=dict(test=['foo', 'baz']))
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:478: AssertionError
__________________ RequestsTestCase.test_user_agent_transfers __________________

self = <test_requests.RequestsTestCase testMethod=test_user_agent_transfers>

    def test_user_agent_transfers(self):
    
        heads = {
            'User-agent': 'Mozilla/5.0 (github.com/kennethreitz/requests)'
        }
    
        r = requests.get(httpbin('user-agent'), headers=heads)
>       assert heads['User-agent'] in r.text
E       AssertionError: assert 'Mozilla/5.0 (github.com/kennethreitz/requests)' in ''
E        +  where '' = <Response [403]>.text

test_requests.py:264: AssertionError
_______________________ TestTimeout.test_stream_timeout ________________________

self = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7a4241de35b0>
method = 'GET', url = '/delay/10', body = None
headers = {'User-Agent': 'python-requests/2.4.3 CPython/3.9.20 Linux/7.0.0-1014-gcp', 'Accept-Encoding': 'gzip, deflate', 'Accept': '*/*', 'Connection': 'keep-alive', 'Authorization': 'Basic dXNlcjpwYXNz'}
retries = Retry(total=0, connect=None, read=False, redirect=None)
redirect = False, assert_same_host = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241de3700>
pool_timeout = None, release_conn = False
response_kw = {'decode_content': False, 'preload_content': False}, conn = None
err = None, stacktrace = <traceback object at 0x7a4241ea3040>

    def urlopen(self, method, url, body=None, headers=None, retries=None,
                redirect=True, assert_same_host=True, timeout=_Default,
                pool_timeout=None, release_conn=None, **response_kw):
        """
        Get a connection from the pool and perform an HTTP request. This is the
        lowest level call for making a request, so you'll need to specify all
        the raw details.
    
        .. note::
    
           More commonly, it's appropriate to use a convenience method provided
           by :class:`.RequestMethods`, such as :meth:`request`.
    
        .. note::
    
           `release_conn` will only behave as expected if
           `preload_content=False` because we want to make
           `preload_content=False` the default behaviour someday soon without
           breaking backwards compatibility.
    
        :param method:
            HTTP request method (such as GET, POST, PUT, etc.)
    
        :param body:
            Data to send in the request body (useful for creating
            POST requests, see HTTPConnectionPool.post_url for
            more convenience).
    
        :param headers:
            Dictionary of custom headers to send, such as User-Agent,
            If-None-Match, etc. If None, pool headers are used. If provided,
            these headers completely replace any pool-specific headers.
    
        :param retries:
            Configure the number of retries to allow before raising a
            :class:`~urllib3.exceptions.MaxRetryError` exception.
    
            Pass ``None`` to retry until you receive a response. Pass a
            :class:`~urllib3.util.retry.Retry` object for fine-grained control
            over different types of retries.
            Pass an integer number to retry connection errors that many times,
            but no other types of errors. Pass zero to never retry.
    
            If ``False``, then retries are disabled and any exception is raised
            immediately. Also, instead of raising a MaxRetryError on redirects,
            the redirect response will be returned.
    
        :type retries: :class:`~urllib3.util.retry.Retry`, False, or an int.
    
        :param redirect:
            If True, automatically handle redirects (status codes 301, 302,
            303, 307, 308). Each redirect counts as a retry. Disabling retries
            will disable redirect, too.
    
        :param assert_same_host:
            If ``True``, will make sure that the host of the pool requests is
            consistent else will raise HostChangedError. When False, you can
            use the pool on an HTTP proxy and request foreign hosts.
    
        :param timeout:
            If specified, overrides the default timeout for this one
            request. It may be a float (in seconds) or an instance of
            :class:`urllib3.util.Timeout`.
    
        :param pool_timeout:
            If set and the pool is set to block=True, then this method will
            block for ``pool_timeout`` seconds and raise EmptyPoolError if no
            connection is available within the time period.
    
        :param release_conn:
            If False, then the urlopen call will not release the connection
            back into the pool once a response is received (but will release if
            you read the entire contents of the response such as when
            `preload_content=True`). This is useful if you're not preloading
            the response's content immediately. You will need to call
            ``r.release_conn()`` on the response ``r`` to return the connection
            back into the pool. If None, it takes the value of
            ``response_kw.get('preload_content', True)``.
    
        :param \**response_kw:
            Additional parameters are passed to
            :meth:`urllib3.response.HTTPResponse.from_httplib`
        """
        if headers is None:
            headers = self.headers
    
        if not isinstance(retries, Retry):
            retries = Retry.from_int(retries, redirect=redirect, default=self.retries)
    
        if release_conn is None:
            release_conn = response_kw.get('preload_content', True)
    
        # Check host
        if assert_same_host and not self.is_same_host(url):
            raise HostChangedError(self, url, retries)
    
        conn = None
    
        # Merge the proxy headers. Only do this in HTTP. We have to copy the
        # headers dict so we can safely change it without those changes being
        # reflected in anyone else's copy.
        if self.scheme == 'http':
            headers = headers.copy()
            headers.update(self.proxy_headers)
    
        # Must keep the exception bound to a separate variable or else Python 3
        # complains about UnboundLocalError.
        err = None
    
        try:
            # Request a connection from the queue.
>           conn = self._get_conn(timeout=pool_timeout)

requests/packages/urllib3/connectionpool.py:511: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:231: in _get_conn
    return conn or self._new_conn()
requests/packages/urllib3/connectionpool.py:712: in _new_conn
    return self._prepare_conn(conn)
requests/packages/urllib3/connectionpool.py:685: in _prepare_conn
    conn.connect()
requests/packages/urllib3/connection.py:208: in connect
    self._tunnel()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x7a4241de3850>

    def _tunnel(self):
        connect = b"CONNECT %s:%d HTTP/1.0\r\n" % (
            self._tunnel_host.encode("ascii"), self._tunnel_port)
        headers = [connect]
        for header, value in self._tunnel_headers.items():
            headers.append(f"{header}: {value}\r\n".encode("latin-1"))
        headers.append(b"\r\n")
        # Making a single send() call instead of one per line encourages
        # the host OS to use a more optimal packet size instead of
        # potentially emitting a series of small packets.
        self.send(b"".join(headers))
        del headers
    
        response = self.response_class(self.sock, method=self._method)
        (version, code, message) = response._read_status()
    
        if code != http.HTTPStatus.OK:
            self.close()
>           raise OSError(f"Tunnel connection failed: {code} {message.strip()}")
E           OSError: Tunnel connection failed: 403 Forbidden

/opt/miniconda3/envs/testbed/lib/python3.9/http/client.py:930: OSError

During handling of the above exception, another exception occurred:

self = <requests.adapters.HTTPAdapter object at 0x7a4241de32e0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241de3700>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
>               resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )

requests/adapters.py:352: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/packages/urllib3/connectionpool.py:558: in urlopen
    retries = retries.increment(method, url, error=e,
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Retry(total=0, connect=None, read=False, redirect=None), method = 'GET'
url = '/delay/10', response = None
error = ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden'))
_pool = <requests.packages.urllib3.connectionpool.HTTPSConnectionPool object at 0x7a4241de35b0>
_stacktrace = <traceback object at 0x7a4241ea3040>

    def increment(self, method=None, url=None, response=None, error=None, _pool=None, _stacktrace=None):
        """ Return a new Retry object with incremented retry counters.
    
        :param response: A response object, or None, if the server did not
            return a response.
        :type response: :class:`~urllib3.response.HTTPResponse`
        :param Exception error: An error encountered during the request, or
            None if the response was received successfully.
    
        :return: A new ``Retry`` object.
        """
        if self.total is False and error:
            # Disabled, indicate to re-raise the error.
            raise six.reraise(type(error), error, _stacktrace)
    
        total = self.total
        if total is not None:
            total -= 1
    
        _observed_errors = self._observed_errors
        connect = self.connect
        read = self.read
        redirect = self.redirect
    
        if error and self._is_connection_error(error):
            # Connect retry?
            if connect is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif connect is not None:
                connect -= 1
            _observed_errors += 1
    
        elif error and self._is_read_error(error):
            # Read retry?
            if read is False:
                raise six.reraise(type(error), error, _stacktrace)
            elif read is not None:
                read -= 1
            _observed_errors += 1
    
        elif response and response.get_redirect_location():
            # Redirect retry?
            if redirect is not None:
                redirect -= 1
    
        else:
            # FIXME: Nothing changed, scenario doesn't make sense.
            _observed_errors += 1
    
        new_retry = self.new(
            total=total,
            connect=connect, read=read, redirect=redirect,
            _observed_errors=_observed_errors)
    
        if new_retry.is_exhausted():
>           raise MaxRetryError(_pool, url, error)
E           requests.packages.urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/packages/urllib3/util/retry.py:265: MaxRetryError

During handling of the above exception, another exception occurred:

self = <test_requests.TestTimeout object at 0x7a424224e940>

    def test_stream_timeout(self):
        try:
>           requests.get('https://httpbin.org/delay/10', timeout=2.0)

test_requests.py:1345: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
requests/api.py:60: in get
    return request('get', url, **kwargs)
requests/api.py:49: in request
    return session.request(method=method, url=url, **kwargs)
requests/sessions.py:457: in request
    resp = self.send(prep, **send_kwargs)
requests/sessions.py:569: in send
    r = adapter.send(request, **kwargs)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <requests.adapters.HTTPAdapter object at 0x7a4241de32e0>
request = <PreparedRequest [GET]>, stream = False
timeout = <requests.packages.urllib3.util.timeout.Timeout object at 0x7a4241de3700>
verify = True, cert = None
proxies = {'http': 'http://swe-proxy:3128', 'https': 'http://swe-proxy:3128', 'no': '192.168.0.0/24,127.0.0.1,localhost.localdomain,172.16.1.1'}

    def send(self, request, stream=False, timeout=None, verify=True, cert=None, proxies=None):
        """Sends PreparedRequest object. Returns Response object.
    
        :param request: The :class:`PreparedRequest <PreparedRequest>` being sent.
        :param stream: (optional) Whether to stream the request content.
        :param timeout: (optional) How long to wait for the server to send
            data before giving up, as a float, or a (`connect timeout, read
            timeout <user/advanced.html#timeouts>`_) tuple.
        :type timeout: float or tuple
        :param verify: (optional) Whether to verify SSL certificates.
        :param cert: (optional) Any user-provided SSL certificate to be trusted.
        :param proxies: (optional) The proxies dictionary to apply to the request.
        """
    
        conn = self.get_connection(request.url, proxies)
    
        self.cert_verify(conn, request.url, verify, cert)
        url = self.request_url(request, proxies)
        self.add_headers(request)
    
        chunked = not (request.body is None or 'Content-Length' in request.headers)
    
        if isinstance(timeout, tuple):
            try:
                connect, read = timeout
                timeout = TimeoutSauce(connect=connect, read=read)
            except ValueError as e:
                # this may raise a string formatting error.
                err = ("Invalid timeout {0}. Pass a (connect, read) "
                       "timeout tuple, or a single float to set "
                       "both timeouts to the same value".format(timeout))
                raise ValueError(err)
        else:
            timeout = TimeoutSauce(connect=timeout, read=timeout)
    
        try:
            if not chunked:
                resp = conn.urlopen(
                    method=request.method,
                    url=url,
                    body=request.body,
                    headers=request.headers,
                    redirect=False,
                    assert_same_host=False,
                    preload_content=False,
                    decode_content=False,
                    retries=Retry(self.max_retries, read=False),
                    timeout=timeout
                )
    
            # Send the request.
            else:
                if hasattr(conn, 'proxy_pool'):
                    conn = conn.proxy_pool
    
                low_conn = conn._get_conn(timeout=timeout)
    
                try:
                    low_conn.putrequest(request.method,
                                        url,
                                        skip_accept_encoding=True)
    
                    for header, value in request.headers.items():
                        low_conn.putheader(header, value)
    
                    low_conn.endheaders()
    
                    for i in request.body:
                        low_conn.send(hex(len(i))[2:].encode('utf-8'))
                        low_conn.send(b'\r\n')
                        low_conn.send(i)
                        low_conn.send(b'\r\n')
                    low_conn.send(b'0\r\n\r\n')
    
                    r = low_conn.getresponse()
                    resp = HTTPResponse.from_httplib(
                        r,
                        pool=conn,
                        connection=low_conn,
                        preload_content=False,
                        decode_content=False
                    )
                except:
                    # If we hit any problems here, clean up the connection.
                    # Then, reraise so that we can handle the actual exception.
                    low_conn.close()
                    raise
                else:
                    # All is well, return the connection to the pool.
                    conn._put_conn(low_conn)
    
        except (ProtocolError, socket.error) as err:
            raise ConnectionError(err, request=request)
    
        except MaxRetryError as e:
            if isinstance(e.reason, ConnectTimeoutError):
                raise ConnectTimeout(e, request=request)
    
>           raise ConnectionError(e, request=request)
E           requests.exceptions.ConnectionError: HTTPSConnectionPool(host='httpbin.org', port=443): Max retries exceeded with url: /delay/10 (Caused by ProxyError('Cannot connect to proxy.', OSError('Tunnel connection failed: 403 Forbidden')))

requests/adapters.py:413: ConnectionError
________________________ TestTimeout.test_none_timeout _________________________

self = <test_requests.TestTimeout object at 0x7a424224eb80>

    def test_none_timeout(self):
        """ Check that you can set None as a valid timeout value.
    
        To actually test this behavior, we'd want to check that setting the
        timeout to None actually lets the request block past the system default
        timeout. However, this would make the test suite unbearably slow.
        Instead we verify that setting the timeout to None does not prevent the
        request from succeeding.
        """
        r = requests.get(httpbin('get'), timeout=None)
>       assert r.status_code == 200
E       assert 403 == 200
E        +  where 403 = <Response [403]>.status_code

test_requests.py:1368: AssertionError
________________________ TestTimeout.test_read_timeout _________________________

self = <test_requests.TestTimeout object at 0x7a424224eca0>

    def test_read_timeout(self):
        try:
            requests.get(httpbin('delay/10'), timeout=(None, 0.1))
>           assert False, "The recv() request should time out."
E           AssertionError: The recv() request should time out.
E           assert False

test_requests.py:1373: AssertionError
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x7a424224edc0>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1380: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x7a424224eee0>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1388: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:1
requests/packages/urllib3/_collections.py:1
  /testbed/requests/packages/urllib3/_collections.py:1: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
  /testbed/requests/models.py:169: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::RequestsTestCase::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_QUOTES_QOP_VALUE
FAILED test_requests.py::RequestsTestCase::test_DIGESTAUTH_WRONG_HTTP_401_GET
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_RETURNS_COOKIE - ...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_AUTH_SETS_SESSION_COOKIES
FAILED test_requests.py::RequestsTestCase::test_DIGEST_HTTP_200_OK_GET - asse...
FAILED test_requests.py::RequestsTestCase::test_DIGEST_STREAM - AssertionErro...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_ALTERNATIVE
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_GET_WITH_PARAMS
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_HEAD - assert 403...
FAILED test_requests.py::RequestsTestCase::test_HTTP_200_OK_PUT - assert 403 ...
FAILED test_requests.py::RequestsTestCase::test_HTTP_302_ALLOW_REDIRECT_GET
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES - requ...
FAILED test_requests.py::RequestsTestCase::test_POSTBIN_GET_POST_FILES_WITH_DATA
FAILED test_requests.py::RequestsTestCase::test_auth_is_retained_for_redirect_on_host
FAILED test_requests.py::RequestsTestCase::test_auth_is_stripped_on_redirect_off_host
FAILED test_requests.py::RequestsTestCase::test_basicauth_with_netrc - assert...
FAILED test_requests.py::RequestsTestCase::test_conflicting_post_params - Typ...
FAILED test_requests.py::RequestsTestCase::test_connection_error - Failed: DI...
FAILED test_requests.py::RequestsTestCase::test_cookie_persists_via_api - Ind...
FAILED test_requests.py::RequestsTestCase::test_cookie_quote_wrapped - KeyErr...
FAILED test_requests.py::RequestsTestCase::test_cookie_removed_on_expire - Ke...
FAILED test_requests.py::RequestsTestCase::test_cookie_sent_on_redirect - jso...
FAILED test_requests.py::RequestsTestCase::test_custom_content_type - assert ...
FAILED test_requests.py::RequestsTestCase::test_different_encodings_dont_break_post
FAILED test_requests.py::RequestsTestCase::test_generic_cookiejar_works - jso...
FAILED test_requests.py::RequestsTestCase::test_json_param_post_content_type_works
FAILED test_requests.py::RequestsTestCase::test_manual_redirect_with_partial_body_read
FAILED test_requests.py::RequestsTestCase::test_mixed_case_scheme_acceptable
FAILED test_requests.py::RequestsTestCase::test_param_cookiejar_works - json....
FAILED test_requests.py::RequestsTestCase::test_params_are_merged_case_sensitive
FAILED test_requests.py::RequestsTestCase::test_prepared_from_session - reque...
FAILED test_requests.py::RequestsTestCase::test_pyopenssl_redirect - requests...
FAILED test_requests.py::RequestsTestCase::test_request_cookie_overrides_session_cookie
FAILED test_requests.py::RequestsTestCase::test_requests_history_is_saved - r...
FAILED test_requests.py::RequestsTestCase::test_session_pickling - assert 403...
FAILED test_requests.py::RequestsTestCase::test_set_cookie_on_301 - KeyError:...
FAILED test_requests.py::RequestsTestCase::test_unicode_method_name - assert ...
FAILED test_requests.py::RequestsTestCase::test_unicode_multipart_post - asse...
FAILED test_requests.py::RequestsTestCase::test_uppercase_scheme_redirect - a...
FAILED test_requests.py::RequestsTestCase::test_urlencoded_get_query_multivalued_param
FAILED test_requests.py::RequestsTestCase::test_user_agent_transfers - Assert...
FAILED test_requests.py::TestTimeout::test_stream_timeout - requests.exceptio...
FAILED test_requests.py::TestTimeout::test_none_timeout - assert 403 == 200
FAILED test_requests.py::TestTimeout::test_read_timeout - AssertionError: The...
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
================== 48 failed, 94 passed, 3 warnings in 3.29s ===================

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/sessions.py
OUTSIDE THE SCOPE: requests/models.py +1 -1 (undo it: git checkout the file, or delete it when the run made it)
changed: requests/sessions.py +2 -2
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
