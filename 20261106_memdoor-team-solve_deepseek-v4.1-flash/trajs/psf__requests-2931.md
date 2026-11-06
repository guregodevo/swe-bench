# psf__requests-2931 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 217s 40 lines cost=0.010003 in=338799 cached=300032 out=19875 calls=29`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
17:57:10 weboff: chief: web_fetch,web_search
17:57:11 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

Request with binary payload fails due to calling to_native_string
Introduced with https://github.com/kennethreitz/requests/issues/2844

```
import requests
requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))
```

This works with 2.8.1, but not with 2.9.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls -la && git log --oneline -5 && git status"
}
```

**tool result**

```
/testbed
total 180
drwxrwxrwx 1 root root  4096 Nov  6 17:56 .
drwxr-xr-x 1 root root  4096 Nov  6 17:56 ..
drwxrwxrwx 1 root root  4096 Nov  6 17:57 .git
-rw-r--r-- 1 root root   208 Aug 13 02:47 .gitignore
drwxr-xr-x 4 root root  4096 Nov  6 17:57 .memdoor
-rw-r--r-- 1 root root  5724 Aug 13 02:47 AUTHORS.rst
-rw-r--r-- 1 root root  3010 Aug 13 02:47 CONTRIBUTING.md
-rw-r--r-- 1 root root 32595 Aug 13 02:47 HISTORY.rst
-rw-r--r-- 1 root root   581 Aug 13 02:47 LICENSE
-rw-r--r-- 1 root root   100 Aug 13 02:47 MANIFEST.in
-rw-r--r-- 1 root root  1084 Aug 13 02:47 Makefile
-rw-r--r-- 1 root root  2292 Aug 13 02:47 NOTICE
-rw-r--r-- 1 root root  2748 Aug 13 02:47 README.rst
drwxr-xr-x 4 root root  4096 Aug 13 02:47 build
drwxrwxrwx 8 root root  4096 Aug 13 02:47 docs
drwxrwxrwx 2 root root  4096 Aug 13 02:47 ext
drwxr-xr-x 3 root root  4096 Aug 13 02:47 requests
drwxr-xr-x 2 root root  4096 Aug 13 02:47 requests.egg-info
-rw-r--r-- 1 root root    86 Aug 13 02:47 requirements.txt
-rw-r--r-- 1 root root    22 Aug 13 02:47 setup.cfg
-rwxr-xr-x 1 root root  2080 Aug 13 02:47 setup.py
-rwxr-xr-x 1 root root 60514 Aug 13 02:47 test_requests.py
6e65c2e SWE-bench
5f7a3a7 v2.9.0
046a0f2 Merge pull request #2927 from Lukasa/release/2.9.0
424fe26 Suggested wording from @sigmavirus24
2f744b5 Update 2.9.0 release log.
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.memdoor/

nothing added to commit but untracked files present (use "git add" to track)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"to_native_string\" requests/ | head -50"
}
```

**tool result**

```
requests/auth.py:20:from .utils import parse_dict_header, to_native_string
requests/auth.py:30:    authstr = 'Basic ' + to_native_string(
requests/sessions.py:21:from .utils import to_key_val_list, default_headers, to_native_string
requests/sessions.py:138:            prepared_request.url = to_native_string(url)
requests/utils.py:686:def to_native_string(string, encoding='ascii'):
requests/models.py:30:    iter_slices, guess_json_utf, super_len, to_native_string)
requests/models.py:84:            return to_native_string(data)
requests/models.py:322:            self.method = to_native_string(self.method.upper())
requests/models.py:351:            error = error.format(to_native_string(url, 'utf8'))
requests/models.py:402:            self.headers = CaseInsensitiveDict((to_native_string(name), value) for name, value in headers.items())
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '60,100p' requests/models.py && sed -n '670,710p' requests/utils.py && grep -n \"_encode_params\\|def prepare_body\\|def prepare_content_length\" requests/models.py"
}
```

**tool result**

```

        path = p.path
        if not path:
            path = '/'

        url.append(path)

        query = p.query
        if query:
            url.append('?')
            url.append(query)

        return ''.join(url)

    @staticmethod
    def _encode_params(data):
        """Encode parameters in a piece of data.

        Will successfully encode parameters when passed as a dict or a list of
        2-tuples. Order is retained if data is a list of 2-tuples but arbitrary
        if parameters are supplied as a dict.
        """

        if isinstance(data, (str, bytes)):
            return to_native_string(data)
        elif hasattr(data, 'read'):
            return data
        elif hasattr(data, '__iter__'):
            result = []
            for k, vs in to_key_val_list(data):
                if isinstance(vs, basestring) or not hasattr(vs, '__iter__'):
                    vs = [vs]
                for v in vs:
                    if v is not None:
                        result.append(
                            (k.encode('utf-8') if isinstance(k, str) else k,
                             v.encode('utf-8') if isinstance(v, str) else v))
            return urlencode(result, doseq=True)
        else:
            return data

    return urlunparse((scheme, netloc, path, params, query, fragment))


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

75:    def _encode_params(data):
388:        enc_params = self._encode_params(params)
406:    def prepare_body(self, data, files, json=None):
447:                    body = self._encode_params(data)
461:    def prepare_content_length(self, body):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '380,475p' requests/models.py && grep -n \"def test.*encode\\|_encode_params\\|binary\\|unicode\" test_requests.py | head -40"
}
```

**tool result**

```
                netloc = netloc.encode('utf-8')
            if isinstance(path, str):
                path = path.encode('utf-8')
            if isinstance(query, str):
                query = query.encode('utf-8')
            if isinstance(fragment, str):
                fragment = fragment.encode('utf-8')

        enc_params = self._encode_params(params)
        if enc_params:
            if query:
                query = '%s&%s' % (query, enc_params)
            else:
                query = enc_params

        url = requote_uri(urlunparse([scheme, netloc, path, None, query, fragment]))
        self.url = url

    def prepare_headers(self, headers):
        """Prepares the given HTTP headers."""

        if headers:
            self.headers = CaseInsensitiveDict((to_native_string(name), value) for name, value in headers.items())
        else:
            self.headers = CaseInsensitiveDict()

    def prepare_body(self, data, files, json=None):
        """Prepares the given HTTP body data."""

        # Check if file, fo, generator, iterator.
        # If not, run through normal process.

        # Nottin' on you.
        body = None
        content_type = None
        length = None

        if not data and json is not None:
            content_type = 'application/json'
            body = complexjson.dumps(json)

        is_stream = all([
            hasattr(data, '__iter__'),
            not isinstance(data, (basestring, list, tuple, dict))
        ])

        try:
            length = super_len(data)
        except (TypeError, AttributeError, UnsupportedOperation):
            length = None

        if is_stream:
            body = data

            if files:
                raise NotImplementedError('Streamed bodies and files are mutually exclusive.')

            if length:
                self.headers['Content-Length'] = builtin_str(length)
            else:
                self.headers['Transfer-Encoding'] = 'chunked'
        else:
            # Multi-part file uploads.
            if files:
                (body, content_type) = self._encode_files(files, data)
            else:
                if data:
                    body = self._encode_params(data)
                    if isinstance(data, basestring) or hasattr(data, 'read'):
                        content_type = None
                    else:
                        content_type = 'application/x-www-form-urlencoded'

            self.prepare_content_length(body)

            # Add content-type if it wasn't explicitly provided.
            if content_type and ('content-type' not in self.headers):
                self.headers['Content-Type'] = content_type

        self.body = body

    def prepare_content_length(self, body):
        if hasattr(body, 'seek') and hasattr(body, 'tell'):
            body.seek(0, 2)
            self.headers['Content-Length'] = builtin_str(body.tell())
            body.seek(0, 0)
        elif body is not None:
            l = super_len(body)
            if l:
                self.headers['Content-Length'] = builtin_str(l)
        elif (self.method not in ('GET', 'HEAD')) and (self.headers.get('Content-Length') is None):
            self.headers['Content-Length'] = '0'

    def prepare_auth(self, auth, url=''):
        """Prepares the given HTTP auth data."""

48:        return s.decode('unicode-escape')
135:    def test_path_is_not_double_encoded(self):
155:    def test_params_bytes_are_encoded(self):
510:    def test_unicode_get(self, httpbin):
518:    def test_unicode_header_name(self, httpbin):
522:            data='\xff')  # compat.str is unicode.
527:    def test_urlencoded_get_query_multivalued_param(self, httpbin):
540:    def test_unicode_multipart_post(self, httpbin):
561:    def test_unicode_multipart_post_fieldnames(self, httpbin):
572:    def test_unicode_method_name(self, httpbin):
578:    def test_unicode_method_name_with_request_object(self, httpbin):
811:    def test_response_decode_unicode(self):
813:        When called with decode_unicode, Response.iter_content should always
814:        return unicode.
821:        chunks = r.iter_content(decode_unicode=True)
828:        chunks = r.iter_content(decode_unicode=True)
847:    def test_get_auth_from_url_encoded_spaces(self):
851:    def test_get_auth_from_url_not_encoded_spaces(self):
859:    def test_get_auth_from_url_encoded_hashes(self):
969:        headers = {u('unicode'): 'blah', 'byte'.encode('ascii'): 'blah'}
975:        assert 'unicode' in p.headers.keys()
1408:    def test_guess_filename_with_unicode_name(self):
1578:    def test_encoded_methods(self, httpbin):
1702:def test_prepare_unicode_url():
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '145,165p' test_requests.py; sed -n '505,530p' test_requests.py; sed -n '1,60p' requests/models.py"
}
```

**tool result**

```
            "http://example.com/path?key=value#fragment", params={"a": "b"}).prepare()
        assert request.url == "http://example.com/path?key=value&a=b#fragment"

    def test_params_original_order_is_preserved_by_default(self):
        param_ordered_dict = OrderedDict((('z', 1), ('a', 1), ('k', 1), ('d', 1)))
        session = requests.Session()
        request = requests.Request('GET', 'http://example.com/', params=param_ordered_dict)
        prep = session.prepare_request(request)
        assert prep.url == 'http://example.com/?z=1&a=1&k=1&d=1'

    def test_params_bytes_are_encoded(self):
        request = requests.Request('GET', 'http://example.com',
                                   params=b'test=foo').prepare()
        assert request.url == 'http://example.com/?test=foo'

    def test_mixed_case_scheme_acceptable(self, httpbin):
        s = requests.Session()
        s.proxies = getproxies()
        parts = urlparse(httpbin('get'))
        schemes = ['http://', 'HTTP://', 'hTTp://', 'HttP://']
        for scheme in schemes:

    def test_decompress_gzip(self, httpbin):
        r = requests.get(httpbin('gzip'))
        r.content.decode('ascii')

    def test_unicode_get(self, httpbin):
        url = httpbin('/get')
        requests.get(url, params={'foo': 'føø'})
        requests.get(url, params={'føø': 'føø'})
        requests.get(url, params={'føø': 'føø'})
        requests.get(url, params={'foo': 'foo'})
        requests.get(httpbin('ø'), params={'foo': 'foo'})

    def test_unicode_header_name(self, httpbin):
        requests.put(
            httpbin('put'),
            headers={str('Content-Type'): 'application/octet-stream'},
            data='\xff')  # compat.str is unicode.

    def test_pyopenssl_redirect(self, httpsbin_url, httpbin_ca_bundle):
        requests.get(httpsbin_url('status', '301'), verify=httpbin_ca_bundle)

    def test_urlencoded_get_query_multivalued_param(self, httpbin):

        r = requests.get(httpbin('get'), params=dict(test=['foo', 'baz']))
        assert r.status_code == 200
# -*- coding: utf-8 -*-

"""
requests.models
~~~~~~~~~~~~~~~

This module contains the primary objects that power Requests.
"""

import collections
import datetime

from io import BytesIO, UnsupportedOperation
from .hooks import default_hooks
from .structures import CaseInsensitiveDict

from .auth import HTTPBasicAuth
from .cookies import cookiejar_from_dict, get_cookie_header, _copy_cookie_jar
from .packages.urllib3.fields import RequestField
from .packages.urllib3.filepost import encode_multipart_formdata
from .packages.urllib3.util import parse_url
from .packages.urllib3.exceptions import (
    DecodeError, ReadTimeoutError, ProtocolError, LocationParseError)
from .exceptions import (
    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
    ContentDecodingError, ConnectionError, StreamConsumedError)
from .utils import (
    guess_filename, get_auth_from_url, requote_uri,
    stream_decode_response_unicode, to_key_val_list, parse_header_links,
    iter_slices, guess_json_utf, super_len, to_native_string)
from .compat import (
    cookielib, urlunparse, urlsplit, urlencode, str, bytes, StringIO,
    is_py2, chardet, builtin_str, basestring)
from .compat import json as complexjson
from .status_codes import codes

#: The set of HTTP status codes that indicate an automatically
#: processable redirect.
REDIRECT_STATI = (
    codes.moved,              # 301
    codes.found,              # 302
    codes.other,              # 303
    codes.temporary_redirect, # 307
    codes.permanent_redirect, # 308
)

DEFAULT_REDIRECT_LIMIT = 30
CONTENT_CHUNK_SIZE = 10 * 1024
ITER_CHUNK_SIZE = 512


class RequestEncodingMixin(object):
    @property
    def path_url(self):
        """Build the path URL to use."""

        url = []

        p = urlsplit(self.url)
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport requests\nr = requests.Request('PUT','http://httpbin.org/put', data=u'ööö'.encode('utf-8')).prepare()\nprint(repr(r.body), r.headers)\n\""
}
```

**tool result**

```
Command FAILED (exit status 1): `python -c "
import requests
r = requests.Request('PUT','http://httpbin.org/put', data=u'ööö'.encode('utf-8')).prepare()
print(repr(r.body), r.headers)
"`
Output: Traceback (most recent call last):
  File "<string>", line 3, in <module>
  File "/testbed/requests/models.py", line 239, in prepare
    p.prepare(
  File "/testbed/requests/models.py", line 296, in prepare
    self.prepare_body(data, files, json)
  File "/testbed/requests/models.py", line 447, in prepare_body
    body = self._encode_params(data)
  File "/testbed/requests/models.py", line 84, in _encode_params
    return to_native_string(data)
  File "/testbed/requests/utils.py", line 700, in to_native_string
    out = string.decode(encoding)
UnicodeDecodeError: 'ascii' codec can't decode byte 0xc3 in position 0: ordinal not in range(128)

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"is_py2\\|builtin_str\\|^    str\\|^    bytes\\|basestring\" requests/compat.py | head -30"
}
```

**tool result**

```
19:is_py2 = (_ver[0] == 2)
35:if is_py2:
44:    builtin_str = str
45:    bytes = str
46:    str = unicode
47:    basestring = basestring
58:    builtin_str = str
59:    str = str
60:    bytes = bytes
61:    basestring = (str, bytes)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: requests/models.py\n@@\n-        if isinstance(data, (str, bytes)):\n-            return to_native_string(data)\n+        if isinstance(data, (str, bytes)):\n+            return data\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[requests/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

requests/models.py now (848 lines), around the change:
81:        """
82:
83:        if isinstance(data, (str, bytes)):
84:            return data
85:        elif hasattr(data, 'read'):
86:            return data
87:        elif hasattr(data, '__iter__'):
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport requests\nr = requests.Request('PUT','http://httpbin.org/put', data=u'ööö'.encode('utf-8')).prepare()\nprint(repr(r.body), r.headers)\nr = requests.Request('GET','http://example.com', params=b'test=foo').prepare()\nprint(r.url)\nr = requests.Request('GET','http://example.com', params={'foo':'føø'}).prepare()\nprint(r.url)\n\""
}
```

**tool result**

```
Command FAILED (exit status 1): `python -c "
import requests
r = requests.Request('PUT','http://httpbin.org/put', data=u'ööö'.encode('utf-8')).prepare()
print(repr(r.body), r.headers)
r = requests.Request('GET','http://example.com', params=b'test=foo').prepare()
print(r.url)
r = requests.Request('GET','http://example.com', params={'foo':'føø'}).prepare()
print(r.url)
"`
Output: Traceback (most recent call last):
  File "<string>", line 5, in <module>
  File "/testbed/requests/models.py", line 239, in prepare
    p.prepare(
  File "/testbed/requests/models.py", line 293, in prepare
    self.prepare_url(url, params)
  File "/testbed/requests/models.py", line 395, in prepare_url
    url = requote_uri(urlunparse([scheme, netloc, path, None, query, fragment]))
  File "/opt/miniconda3/envs/testbed/lib/python3.9/urllib/parse.py", line 512, in urlunparse
    _coerce_args(*components))
  File "/opt/miniconda3/envs/testbed/lib/python3.9/urllib/parse.py", line 133, in _coerce_args
    raise TypeError("Cannot mix str and non-str arguments")
TypeError: Cannot mix str and non-str arguments
b'\xc3\xb6\xc3\xb6\xc3\xb6' {'Content-Length': '6'}

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"enc_params\\|_encode_params\" build/ 2>/dev/null | head; python - <<'EOF'\nimport urllib.parse\nprint(urllib.parse.urlunparse(['http','example.com','/','',b'test=foo','']))\nEOF"
}
```

**tool result**

```
Command FAILED (exit status 1): `grep -rn "enc_params\|_encode_params" build/ 2>/dev/null | head; python - <<'EOF'
import urllib.parse
print(urllib.parse.urlunparse(['http','example.com','/','',b'test=foo','']))
EOF`
Output: build/lib/requests/models.py:75:    def _encode_params(data):
build/lib/requests/models.py:388:        enc_params = self._encode_params(params)
build/lib/requests/models.py:389:        if enc_params:
build/lib/requests/models.py:391:                query = '%s&%s' % (query, enc_params)
build/lib/requests/models.py:393:                query = enc_params
build/lib/requests/models.py:447:                    body = self._encode_params(data)
Traceback (most recent call last):
  File "<stdin>", line 2, in <module>
  File "/opt/miniconda3/envs/testbed/lib/python3.9/urllib/parse.py", line 512, in urlunparse
    _coerce_args(*components))
  File "/opt/miniconda3/envs/testbed/lib/python3.9/urllib/parse.py", line 133, in _coerce_args
    raise TypeError("Cannot mix str and non-str arguments")
TypeError: Cannot mix str and non-str arguments

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -3 -- test_requests.py; git log -S \"test_params_bytes_are_encoded\" --oneline -- test_requests.py; git log -S \"return to_native_string(data)\" --oneline -- requests/models.py"
}
```

**tool result**

```
23d9b07 Fix typos
0a1aaca Add failing test for #2872
43b90d7 Remove remaining test that contacts external server.
edc68a0 fix issue #2844
edc68a0 fix issue #2844
```

**assistant → tool `bash`**

```json
{
  "command": "git show edc68a0 --stat && git show edc68a0 -- requests/models.py test_requests.py | head -120"
}
```

**tool result**

```
commit edc68a0ac899785cd89a726e3da258e880d641dd
Author: Alex Khomchenko <akhomchenko@gmail.com>
Date:   Fri Oct 23 15:22:36 2015 +0300

    fix issue #2844

 requests/models.py | 2 +-
 test_requests.py   | 5 +++++
 2 files changed, 6 insertions(+), 1 deletion(-)
commit edc68a0ac899785cd89a726e3da258e880d641dd
Author: Alex Khomchenko <akhomchenko@gmail.com>
Date:   Fri Oct 23 15:22:36 2015 +0300

    fix issue #2844

diff --git a/requests/models.py b/requests/models.py
index 2727bee..639565c 100644
--- a/requests/models.py
+++ b/requests/models.py
@@ -81,7 +81,7 @@ class RequestEncodingMixin(object):
         """
 
         if isinstance(data, (str, bytes)):
-            return data
+            return to_native_string(data)
         elif hasattr(data, 'read'):
             return data
         elif hasattr(data, '__iter__'):
diff --git a/test_requests.py b/test_requests.py
index c5ac4f8..7b23e59 100755
--- a/test_requests.py
+++ b/test_requests.py
@@ -139,6 +139,11 @@ class RequestsTestCase(unittest.TestCase):
         prep = session.prepare_request(request)
         assert prep.url == 'http://example.com/?z=1&a=1&k=1&d=1'
 
+    def test_params_bytes_are_encoded(self):
+        request = requests.Request('GET', 'http://example.com',
+                                   params=b'test=foo').prepare()
+        assert request.url == 'http://example.com/?test=foo'
+
     def test_mixed_case_scheme_acceptable(self):
         s = requests.Session()
         s.proxies = getproxies()
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '355,400p' requests/models.py"
}
```

**tool result**

```
        if not host:
            raise InvalidURL("Invalid URL %r: No host supplied" % url)

        # Only want to apply IDNA to the hostname
        try:
            host = host.encode('idna').decode('utf-8')
        except UnicodeError:
            raise InvalidURL('URL has an invalid label.')

        # Carefully reconstruct the network location
        netloc = auth or ''
        if netloc:
            netloc += '@'
        netloc += host
        if port:
            netloc += ':' + str(port)

        # Bare domains aren't valid URLs.
        if not path:
            path = '/'

        if is_py2:
            if isinstance(scheme, str):
                scheme = scheme.encode('utf-8')
            if isinstance(netloc, str):
                netloc = netloc.encode('utf-8')
            if isinstance(path, str):
                path = path.encode('utf-8')
            if isinstance(query, str):
                query = query.encode('utf-8')
            if isinstance(fragment, str):
                fragment = fragment.encode('utf-8')

        enc_params = self._encode_params(params)
        if enc_params:
            if query:
                query = '%s&%s' % (query, enc_params)
            else:
                query = enc_params

        url = requote_uri(urlunparse([scheme, netloc, path, None, query, fragment]))
        self.url = url

    def prepare_headers(self, headers):
        """Prepares the given HTTP headers."""
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport requests, inspect\nprint(requests.__version__, requests.__file__)\nprint(inspect.getsource(requests.models.RequestEncodingMixin._encode_params))\nEOF"
}
```

**tool result**

```
2.9.0 /testbed/requests/__init__.py
    @staticmethod
    def _encode_params(data):
        """Encode parameters in a piece of data.

        Will successfully encode parameters when passed as a dict or a list of
        2-tuples. Order is retained if data is a list of 2-tuples but arbitrary
        if parameters are supplied as a dict.
        """

        if isinstance(data, (str, bytes)):
            return data
        elif hasattr(data, 'read'):
            return data
        elif hasattr(data, '__iter__'):
            result = []
            for k, vs in to_key_val_list(data):
                if isinstance(vs, basestring) or not hasattr(vs, '__iter__'):
                    vs = [vs]
                for v in vs:
                    if v is not None:
                        result.append(
                            (k.encode('utf-8') if isinstance(k, str) else k,
                             v.encode('utf-8') if isinstance(v, str) else v))
            return urlencode(result, doseq=True)
        else:
            return data
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest test_requests.py -k \"params_bytes_are_encoded or unicode_header_name\" -x -q 2>&1 | tail -30"
}
```

**tool result**

```

args = ('http', 'example.com', '/', None, b'test=foo', None), str_input = True
arg = b'test=foo'

    def _coerce_args(*args):
        # Invokes decode if necessary to create str args
        # and returns the coerced inputs along with
        # an appropriate result coercion function
        #   - noop for str inputs
        #   - encoding function otherwise
        str_input = isinstance(args[0], str)
        for arg in args[1:]:
            # We special-case the empty string to support the
            # "scheme=''" default argument to some functions
            if arg and isinstance(arg, str) != str_input:
>               raise TypeError("Cannot mix str and non-str arguments")
E               TypeError: Cannot mix str and non-str arguments

/opt/miniconda3/envs/testbed/lib/python3.9/urllib/parse.py:133: TypeError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:2
requests/packages/urllib3/_collections.py:2
  /testbed/requests/packages/urllib3/_collections.py:2: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::TestRequests::test_params_bytes_are_encoded - TypeEr...
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 165 deselected, 2 warnings in 0.54s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: requests/models.py\n@@\n-        enc_params = self._encode_params(params)\n+        if isinstance(params, (str, bytes)):\n+            params = to_native_string(params)\n+\n+        enc_params = self._encode_params(params)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[requests/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

requests/models.py now (851 lines), around the change:
385:            if isinstance(fragment, str):
386:                fragment = fragment.encode('utf-8')
387:
388:        if isinstance(params, (str, bytes)):
389:            params = to_native_string(params)
390:
391:        enc_params = self._encode_params(params)
392:        if enc_params:
393:            if query:
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest test_requests.py -k \"params_bytes_are_encoded or unicode_header_name or unicode_get or unicode_multipart or prepare_unicode_url or encoded_methods\" -q 2>&1 | tail -20"
}
```

**tool result**

```
requests/packages/urllib3/_collections.py:2
  /testbed/requests/packages/urllib3/_collections.py:2: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

requests/models.py:786
  /testbed/requests/models.py:786: DeprecationWarning: invalid escape sequence \*
    """Returns the json-encoded content of a response, if any.

test_requests.py::TestRequests::test_params_bytes_are_encoded
  /testbed/requests/models.py:168: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
ERROR test_requests.py::TestRequests::test_unicode_get
ERROR test_requests.py::TestRequests::test_unicode_header_name
ERROR test_requests.py::TestRequests::test_unicode_multipart_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR test_requests.py::TestTimeout::test_encoded_methods
2 passed, 160 deselected, 4 warnings, 5 errors in 1.36s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest test_requests.py -k \"unicode_header_name\" -q 2>&1 | grep -A5 \"ERROR\\|error\" | head -30"
}
```

**tool result**

```
==================================== ERRORS ====================================
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/test_requests.py, line 518
      def test_unicode_header_name(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
--
ERROR test_requests.py::TestRequests::test_unicode_header_name
166 deselected, 2 warnings, 1 error in 0.53s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest test_requests.py -q 2>&1 | tail -15"
}
```

**tool result**

```
ERROR test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR test_requests.py::TestRequests::test_requests_history_is_saved
ERROR test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR test_requests.py::TestRequests::test_response_iter_lines
ERROR test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR test_requests.py::TestTimeout::test_stream_timeout
ERROR test_requests.py::TestTimeout::test_invalid_timeout
ERROR test_requests.py::TestTimeout::test_none_timeout
ERROR test_requests.py::TestTimeout::test_read_timeout
ERROR test_requests.py::TestTimeout::test_encoded_methods
ERROR test_requests.py::TestRedirects::test_requests_are_updated_each_time
ERROR test_requests.py::test_urllib3_retries
ERROR test_requests.py::test_urllib3_pool_connection_closed
3 failed, 82 passed, 1 xfailed, 9 warnings, 81 errors in 2.75s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest test_requests.py -q 2>&1 | grep \"^FAILED\""
}
```

**tool result**

```
FAILED test_requests.py::TestRequests::test_connection_error_invalid_domain
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
```

**assistant → tool `bash`**

```json
{
  "command": "git tag | tail; git branch -a; git log --all --oneline | head -5"
}
```

**tool result**

```
v2.5.1
v2.5.2
v2.5.3
v2.6.0
v2.6.1
v2.6.2
v2.7.0
v2.8.0
v2.8.1
v2.9.0
* main
6e65c2e SWE-bench
5f7a3a7 v2.9.0
046a0f2 Merge pull request #2927 from Lukasa/release/2.9.0
424fe26 Suggested wording from @sigmavirus24
2f744b5 Update 2.9.0 release log.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"2.9.1\\|2844\\|2935\" HISTORY.rst | head"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport requests\nr = requests.Request('PUT','http://httpbin.org/put', data=u'ööö'.encode('utf-8')).prepare()\nprint(repr(r.body), r.headers)\nr = requests.Request('GET','http://example.com', params=b'test=foo').prepare()\nprint(r.url)\nr = requests.Request('GET','http://example.com', params={'foo':'føø'}).prepare()\nprint(r.url)\nr = requests.Request('POST','http://example.com', data=b'test=foo').prepare()\nprint(repr(r.body), r.headers)\nEOF"
}
```

**tool result**

```
b'\xc3\xb6\xc3\xb6\xc3\xb6' {'Content-Length': '6'}
http://example.com/?test=foo
http://example.com/?foo=f%C3%B8%C3%B8
b'test=foo' {'Content-Length': '8'}
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: test_requests.py\n@@\n     def test_params_bytes_are_encoded(self):\n         request = requests.Request('GET', 'http://example.com',\n                                    params=b'test=foo').prepare()\n         assert request.url == 'http://example.com/?test=foo'\n \n+    def test_binary_body_is_not_decoded(self):\n+        body = u'ööö'.encode('utf-8')\n+        request = requests.Request('PUT', 'http://example.com',\n+                                   data=body).prepare()\n+        assert request.body == body\n+\n     def test_mixed_case_scheme_acceptable(self, httpbin):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[test_requests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

test_requests.py now (1747 lines), around the change:
156:        request = requests.Request('GET', 'http://example.com',
157:                                   params=b'test=foo').prepare()
158:        assert request.url == 'http://example.com/?test=foo'
159:
160:    def test_binary_body_is_not_decoded(self):
161:        body = u'ööö'.encode('utf-8')
162:        request = requests.Request('PUT', 'http://example.com',
163:                                   data=body).prepare()
164:        assert request.body == body
165:
166:    def test_mixed_case_scheme_acceptable(self, httpbin):
167:        s = requests.Session()
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest test_requests.py -k \"params_bytes_are_encoded or binary_body_is_not_decoded\" -q 2>&1 | tail -5 && git diff"
}
```

**tool result**

```
  /testbed/requests/models.py:168: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
2 passed, 166 deselected, 3 warnings in 0.73s
diff --git a/requests/models.py b/requests/models.py
index 9c624d3..4bcbc54 100644
--- a/requests/models.py
+++ b/requests/models.py
@@ -81,7 +81,7 @@ class RequestEncodingMixin(object):
         """
 
         if isinstance(data, (str, bytes)):
-            return to_native_string(data)
+            return data
         elif hasattr(data, 'read'):
             return data
         elif hasattr(data, '__iter__'):
@@ -385,6 +385,9 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
             if isinstance(fragment, str):
                 fragment = fragment.encode('utf-8')
 
+        if isinstance(params, (str, bytes)):
+            params = to_native_string(params)
+
         enc_params = self._encode_params(params)
         if enc_params:
             if query:
diff --git a/test_requests.py b/test_requests.py
index 137edc0..32b9384 100755
--- a/test_requests.py
+++ b/test_requests.py
@@ -157,6 +157,12 @@ class TestRequests(object):
                                    params=b'test=foo').prepare()
         assert request.url == 'http://example.com/?test=foo'
 
+    def test_binary_body_is_not_decoded(self):
+        body = u'ööö'.encode('utf-8')
+        request = requests.Request('PUT', 'http://example.com',
+                                   data=body).prepare()
+        assert request.body == body
+
     def test_mixed_case_scheme_acceptable(self, httpbin):
         s = requests.Session()
         s.proxies = getproxies()
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def super_len\" -A40 requests/utils.py"
}
```

**tool result**

```
50:def super_len(o):
51-    total_length = 0
52-    current_position = 0
53-
54-    if hasattr(o, '__len__'):
55-        total_length = len(o)
56-
57-    elif hasattr(o, 'len'):
58-        total_length = o.len
59-
60-    elif hasattr(o, 'getvalue'):
61-        # e.g. BytesIO, cStringIO.StringIO
62-        total_length = len(o.getvalue())
63-
64-    elif hasattr(o, 'fileno'):
65-        try:
66-            fileno = o.fileno()
67-        except io.UnsupportedOperation:
68-            pass
69-        else:
70-            total_length = os.fstat(fileno).st_size
71-
72-            # Having used fstat to determine the file length, we need to
73-            # confirm that this file was opened up in binary mode.
74-            if 'b' not in o.mode:
75-                warnings.warn((
76-                    "Requests has determined the content-length for this "
77-                    "request using the binary size of the file: however, the "
78-                    "file has been opened in text mode (i.e. without the 'b' "
79-                    "flag in the mode). This may lead to an incorrect "
80-                    "content-length. In Requests 3.0, support will be removed "
81-                    "for files in text mode."),
82-                    FileModeWarning
83-                )
84-
85-    if hasattr(o, 'tell'):
86-        current_position = o.tell()
87-
88-    return max(0, total_length - current_position)
89-
90-
```

**assistant**

```
Fixed. Summary of the change:

**Root cause:** `RequestEncodingMixin._encode_params` was passing raw `str`/`bytes` payloads through `to_native_string()`, which on Python 3 does `string.decode('ascii')`. Any non-ASCII binary body (e.g. UTF-8 encoded `"ööö"`) therefore raised `UnicodeDecodeError` during `PreparedRequest.prepare()`.

**Fix (`requests/models.py`):**
- `_encode_params` now returns `str`/`bytes` data unchanged — a body is opaque bytes and must not be decoded.
- `prepare_url` now normalizes `params` with `to_native_string()` before encoding, preserving the behavior that the original #2844 fix was meant to provide (bytes query params like `params=b'test=foo'` still work, since `urlunparse` can't mix `str` and `bytes`).

**Test added (`test_requests.py`):** `test_binary_body_is_not_decoded` asserts a UTF-8 binary body survives preparation byte-for-byte.

Verified:
- `requests.put(..., data=u"ööö".encode("utf-8"))` now prepares with body `b'\xc3\xb6\xc3\xb6\xc3\xb6'` and `Content-Length: 6`.
- `params=b'test=foo'` → `http://example.com/?test=foo`; unicode params still percent-encoded correctly.
- Both targeted tests pass; the remaining suite failures are pre-existing network/httpbin-fixture errors unrelated to this change. No commits, checkouts, resets, or stashes were made.
```

## Run folder `team-solve-2026-11-06T175715`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
6e65c2e5bccb72305caed91d2d7bf0a3471a788b
```

### `baseline-check.log`

```
check: make test
# This runs all of the tests. To run an individual test, run py.test with
# the -k flag, like "py.test -k test_path_is_not_double_encoded"
py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree
collected 167 items

test_requests.py ...EE....EEEEEEEEEEEEEEEEEEEEEF..EEEEEEEEEEEEEEEEEEEEEE [ 32%]
EEEEEE........E..E.....E.EEE.EE.EEEEE.EEEE.EEEEEx....................... [ 76%]
........................EEEEFFEE.....EE.                                 [100%]

==================================== ERRORS ====================================
____________ ERROR at setup of TestRequests.test_no_content_length _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 121
      def test_no_content_length(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 127
      def test_override_content_length(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 160
      def test_mixed_case_scheme_acceptable(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 171
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 180
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 190
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 198
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 204
      def test_set_cookie_on_301(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 210
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 216
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 229
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 234
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 240
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 248
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 254
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 265
      def test_param_cookiejar_works(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 273
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 279
      def test_history_is_always_a_list(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 289
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___________ ERROR at setup of TestRequests.test_user_agent_transfers ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 297
      def test_user_agent_transfers(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 313
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 317
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 321
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 351
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 384
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 400
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 409
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 416
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 427
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 443
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 451
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 469
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 488
      def test_conflicting_post_params(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 494
      def test_request_ok_set(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 498
      def test_status_raising(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 506
      def test_decompress_gzip(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______________ ERROR at setup of TestRequests.test_unicode_get ________________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 510
      def test_unicode_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 518
      def test_unicode_header_name(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 524
      def test_pyopenssl_redirect(self, httpsbin_url, httpbin_ca_bundle):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 62
  @pytest.fixture
  def httpsbin_url(httpbin_secure):
E       fixture 'httpbin_secure' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:62
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 527
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 533
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__________ ERROR at setup of TestRequests.test_unicode_multipart_post __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 540
      def test_unicode_multipart_post(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 561
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 572
      def test_unicode_method_name(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 578
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 589
      def test_custom_content_type(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 599
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 606
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 615
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 625
      def test_prepared_request_hook(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 639
      def test_prepared_from_session(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 792
      def test_time_elapsed_blank(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 831
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 863
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 878
      def test_session_pickling(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 888
      def test_fixes_1329(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 901
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 946
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 953
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 968
      def test_header_keys_are_native(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__ ERROR at setup of TestRequests.test_can_send_nonstring_objects_with_files ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 978
      def test_can_send_nonstring_objects_with_files(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_bytes_bytearray_objects_with_files _
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 986
      def test_can_send_bytes_bytearray_objects_with_files(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 999
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1007
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_stripped_on_redirect_off_host ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1026
      def test_auth_is_stripped_on_redirect_off_host(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1035
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1042
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1075
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1086
      def test_requests_history_is_saved(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1094
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1103
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1110
      def test_response_iter_lines(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1118
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1529
      def test_stream_timeout(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_invalid_timeout ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1535
      def test_invalid_timeout(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_none_timeout ________________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1544
      def test_none_timeout(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_read_timeout ________________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1556
      def test_read_timeout(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1578
      def test_encoded_methods(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
_____ ERROR at setup of TestRedirects.test_requests_are_updated_each_time ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1629
      def test_requests_are_updated_each_time(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1711
  def test_urllib3_retries(httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 1722
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/test_requests.py:51
=================================== FAILURES ===================================
______________ TestRequests.test_connection_error_invalid_domain _______________

self = <test_requests.TestRequests object at 0x79ccb96ce340>

    def test_connection_error_invalid_domain(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://doesnotexist.google.com")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:339: Failed
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x79ccb8f24b50>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1566: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x79ccb8f24a30>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1574: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/connectionpool.py:99
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/packages/urllib3/connectionpool.py:99: DeprecationWarning: invalid escape sequence \*
    """

requests/packages/urllib3/connectionpool.py:439
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/packages/urllib3/connectionpool.py:439: DeprecationWarning: invalid escape sequence \*
    """

requests/packages/urllib3/connectionpool.py:795
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/packages/urllib3/connectionpool.py:795: DeprecationWarning: invalid escape sequence \*
    """

requests/packages/urllib3/_collections.py:2
requests/packages/urllib3/_collections.py:2
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/packages/urllib3/_collections.py:2: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

requests/packages/urllib3/poolmanager.py:33
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/packages/urllib3/poolmanager.py:33: DeprecationWarning: invalid escape sequence \*
    """

requests/models.py:783
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/models.py:783: DeprecationWarning: invalid escape sequence \*
    """Returns the json-encoded content of a response, if any.

requests/api.py:57
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/api.py:57: DeprecationWarning: invalid escape sequence \*
    """Sends a GET request.

requests/api.py:71
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/api.py:71: DeprecationWarning: invalid escape sequence \*
    """Sends a OPTIONS request.

requests/api.py:84
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/api.py:84: DeprecationWarning: invalid escape sequence \*
    """Sends a HEAD request.

requests/api.py:97
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/api.py:97: DeprecationWarning: invalid escape sequence \*
    """Sends a POST request.

requests/api.py:111
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/api.py:111: DeprecationWarning: invalid escape sequence \*
    """Sends a PUT request.

requests/api.py:124
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/api.py:124: DeprecationWarning: invalid escape sequence \*
    """Sends a PATCH request.

requests/api.py:137
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/api.py:137: DeprecationWarning: invalid escape sequence \*
    """Sends a DELETE request.

requests/sessions.py:473
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/sessions.py:473: DeprecationWarning: invalid escape sequence \*
    """Sends a GET request. Returns :class:`Response` object.

requests/sessions.py:483
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/sessions.py:483: DeprecationWarning: invalid escape sequence \*
    """Sends a OPTIONS request. Returns :class:`Response` object.

requests/sessions.py:493
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/sessions.py:493: DeprecationWarning: invalid escape sequence \*
    """Sends a HEAD request. Returns :class:`Response` object.

requests/sessions.py:503
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/sessions.py:503: DeprecationWarning: invalid escape sequence \*
    """Sends a POST request. Returns :class:`Response` object.

requests/sessions.py:514
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/sessions.py:514: DeprecationWarning: invalid escape sequence \*
    """Sends a PUT request. Returns :class:`Response` object.

requests/sessions.py:524
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/sessions.py:524: DeprecationWarning: invalid escape sequence \*
    """Sends a PATCH request. Returns :class:`Response` object.

requests/sessions.py:534
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/sessions.py:534: DeprecationWarning: invalid escape sequence \*
    """Sends a DELETE request. Returns :class:`Response` object.

test_requests.py::TestRequests::test_invalid_url
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/models.py:168: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

test_requests.py::TestContentEncodingDetection::test_html4_pragma
test_requests.py::TestContentEncodingDetection::test_html_charset
test_requests.py::TestContentEncodingDetection::test_none
test_requests.py::TestContentEncodingDetection::test_precedence
test_requests.py::TestContentEncodingDetection::test_xhtml_pragma
test_requests.py::TestContentEncodingDetection::test_xml
  /testbed/.memdoor/runs/team-solve-2026-11-06T175715/baseline-tree/requests/utils.py:315: DeprecationWarning: In requests 3.0, get_encodings_from_content will be removed. For more information, please see the discussion on issue #2266. (This warning should only appear once.)
    warnings.warn((

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::TestRequests::test_connection_error_invalid_domain
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
ERROR test_requests.py::TestRequests::test_no_content_length
ERROR test_requests.py::TestRequests::test_override_content_length
ERROR test_requests.py::TestRequests::test_mixed_case_scheme_acceptable
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR test_requests.py::TestRequests::test_set_cookie_on_301
ERROR test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR test_requests.py::TestRequests::test_param_cookiejar_works
ERROR test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR test_requests.py::TestRequests::test_history_is_always_a_list
ERROR test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR test_requests.py::TestRequests::test_user_agent_transfers
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR test_requests.py::TestRequests::test_conflicting_post_params
ERROR test_requests.py::TestRequests::test_request_ok_set
ERROR test_requests.py::TestRequests::test_status_raising
ERROR test_requests.py::TestRequests::test_decompress_gzip
ERROR test_requests.py::TestRequests::test_unicode_get
ERROR test_requests.py::TestRequests::test_unicode_header_name
ERROR test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR test_requests.py::TestRequests::test_unicode_method_name
ERROR test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR test_requests.py::TestRequests::test_custom_content_type
ERROR test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR test_requests.py::TestRequests::test_prepared_request_hook
ERROR test_requests.py::TestRequests::test_prepared_from_session
ERROR test_requests.py::TestRequests::test_time_elapsed_blank
ERROR test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR test_requests.py::TestRequests::test_session_pickling
ERROR test_requests.py::TestRequests::test_fixes_1329
ERROR test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR test_requests.py::TestRequests::test_header_keys_are_native
ERROR test_requests.py::TestRequests::test_can_send_nonstring_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_bytes_bytearray_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR test_requests.py::TestRequests::test_auth_is_stripped_on_redirect_off_host
ERROR test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR test_requests.py::TestRequests::test_requests_history_is_saved
ERROR test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR test_requests.py::TestRequests::test_response_iter_lines
ERROR test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR test_requests.py::TestTimeout::test_stream_timeout
ERROR test_requests.py::TestTimeout::test_invalid_timeout
ERROR test_requests.py::TestTimeout::test_none_timeout
ERROR test_requests.py::TestTimeout::test_read_timeout
ERROR test_requests.py::TestTimeout::test_encoded_methods
ERROR test_requests.py::TestRedirects::test_requests_are_updated_each_time
ERROR test_requests.py::test_urllib3_retries
ERROR test_requests.py::test_urllib3_pool_connection_closed
======= 3 failed, 82 passed, 1 xfailed, 28 warnings, 81 errors in 3.30s ========
make: *** [Makefile:9: test] Error 1
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/requests/models.py b/requests/models.py
index 9c624d3..4bcbc54 100644
--- a/requests/models.py
+++ b/requests/models.py
@@ -81,7 +81,7 @@ class RequestEncodingMixin(object):
         """
 
         if isinstance(data, (str, bytes)):
-            return to_native_string(data)
+            return data
         elif hasattr(data, 'read'):
             return data
         elif hasattr(data, '__iter__'):
@@ -385,6 +385,9 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
             if isinstance(fragment, str):
                 fragment = fragment.encode('utf-8')
 
+        if isinstance(params, (str, bytes)):
+            params = to_native_string(params)
+
         enc_params = self._encode_params(params)
         if enc_params:
             if query:
diff --git a/test_requests.py b/test_requests.py
index 137edc0..32b9384 100755
--- a/test_requests.py
+++ b/test_requests.py
@@ -157,6 +157,12 @@ class TestRequests(object):
                                    params=b'test=foo').prepare()
         assert request.url == 'http://example.com/?test=foo'
 
+    def test_binary_body_is_not_decoded(self):
+        body = u'ööö'.encode('utf-8')
+        request = requests.Request('PUT', 'http://example.com',
+                                   data=body).prepare()
+        assert request.body == body
+
     def test_mixed_case_scheme_acceptable(self, httpbin):
         s = requests.Session()
         s.proxies = getproxies()
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

Request with binary payload fails due to calling to_native_string
Introduced with https://github.com/kennethreitz/requests/issues/2844

```
import requests
requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))
```

This works with 2.8.1, but not with 2.9.

## Deliverable

changes to this tree

## Check

`make test`

## Scope

`requests/models.py`
`test_requests.py`

## Done when

- `requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))` completes without raising `UnicodeDecodeError`.
- The request body remains the original UTF-8 bytes, not decoded as ASCII.
- `to_native_string` is not applied to a `bytes` body in the request-body preparation path.



# plan.md

## Deliverable
changes to this tree

## Check
`make test`

## Scope
`requests/models.py`
`test_requests.py`

## Done when
- `requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))` completes without raising `UnicodeDecodeError`.
- The request body remains the original UTF-8 bytes, not decoded as ASCII.
- `to_native_string` is not applied to a `bytes` body in the request-body preparation path.

## Approach
Locate the `to_native_string` call in `PreparedRequest`’s body handling, preserve `bytes` unchanged, add a regression test for the reported call, and run the project test suite.

Candidate approaches:
1. In `requests/models.py`, change `_encode_params` so `str`/`bytes` data is returned as-is instead of passed through `to_native_string`. This is the minimal upstream-style fix and preserves binary payloads.
2. In `prepare_body`, guard the conversion with `if not isinstance(body, bytes): body = to_native_string(body)`. This fixes the immediate crash but still risks incorrect handling of non-ASCII text bodies.
3. Change `to_native_string` itself to return `bytes` unchanged. This is too broad because the helper is used for headers and other callers, so it risks unrelated behavior changes.


# requests/models.py

```
# -*- coding: utf-8 -*-

"""
requests.models
~~~~~~~~~~~~~~~

This module contains the primary objects that power Requests.
"""

import collections
import datetime

from io import BytesIO, UnsupportedOperation
from .hooks import default_hooks
from .structures import CaseInsensitiveDict

from .auth import HTTPBasicAuth
from .cookies import cookiejar_from_dict, get_cookie_header, _copy_cookie_jar
from .packages.urllib3.fields import RequestField
from .packages.urllib3.filepost import encode_multipart_formdata
from .packages.urllib3.util import parse_url
from .packages.urllib3.exceptions import (
    DecodeError, ReadTimeoutError, ProtocolError, LocationParseError)
from .exceptions import (
    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
    ContentDecodingError, ConnectionError, StreamConsumedError)
from .utils import (
    guess_filename, get_auth_from_url, requote_uri,
    stream_decode_response_unicode, to_key_val_list, parse_header_links,
    iter_slices, guess_json_utf, super_len, to_native_string)
from .compat import (
    cookielib, urlunparse, urlsplit, urlencode, str, bytes, StringIO,
    is_py2, chardet, builtin_str, basestring)
from .compat import json as complexjson
from .status_codes import codes

#: The set of HTTP status codes that indicate an automatically
#: processable redirect.
REDIRECT_STATI = (
    codes.moved,              # 301
    codes.found,              # 302
    codes.other,              # 303
    codes.temporary_redirect, # 307
    codes.permanent_redirect, # 308
)

DEFAULT_REDIRECT_LIMIT = 30
CONTENT_CHUNK_SIZE = 10 * 1024
ITER_CHUNK_SIZE = 512


class RequestEncodingMixin(object):
    @property
    def path_url(self):
        """Build the path URL to use."""

        url = []

        p = urlsplit(self.url)

        path = p.path
        if not path:
            path = '/'

        url.append(path)

        query = p.query
        if query:
            url.append('?')
            url.append(query)

        return ''.join(url)

    @staticmethod
    def _encode_params(data):
        """Encode parameters in a piece of data.

        Will successfully encode parameters when passed as a dict or a list of
        2-tuples. Order is retained if data is a list of 2-tuples but arbitrary
        if parameters are supplied as a dict.
        """

        if isinstance(data, (str, bytes)):
            return data
        elif hasattr(data, 'read'):
            return data
        elif hasattr(data, '__iter__'):
            result = []
            for k, vs in to_key_val_list(data):
                if isinstance(vs, basestring) or not hasattr(vs, '__iter__'):
                    vs = [vs]
                for v in vs:
                    if v is not None:
                        result.append(
                            (k.encode('utf-8') if isinstance(k, str) else k,
                             v.encode('utf-8') if isinstance(v, str) else v))
            return urlencode(result, doseq=True)
        else:
            return data

    @staticmethod
    def _encode_files(files, data):
        """Build the body for a multipart/form-data request.

        Will successfully encode files when passed as a dict or a list of
        2-tuples. Order is retained if data is a list of 2-tuples but arbitrary
        if parameters are supplied as a dict.

        """
        if (not files):
            raise ValueError("Files must be provided.")
        elif isinstance(data, basestring):
            raise ValueError("Data must not be a string.")

        new_fields = []
        fields = to_key_val_list(data or {})
        files = to_key_val_list(files or {})

        for field, val in fields:
            if isinstance(val, basestring) or not hasattr(val, '__iter__'):
                val = [val]
            for v in val:
                if v is not None:
                    # Don't call str() on bytestrings: in Py3 it all goes wrong.
                    if not isinstance(v, bytes):
                        v = str(v)

                    new_fields.append(
                        (field.decode('utf-8') if isinstance(field, bytes) else field,
                         v.encode('utf-8') if isinstance(v, str) else v))

        for (k, v) in files:
            # support for explicit filename
            ft = None
            fh = None
            if isinstance(v, (tuple, list)):
                if len(v) == 2:
                    fn, fp = v
                elif len(v) == 3:
                    fn, fp, ft = v
                else:
                    fn, fp, ft, fh = v
            else:
                fn = guess_filename(v) or k
                fp = v

            if isinstance(fp, (str, bytes, bytearray)):
                fdata = fp
            else:
                fdata = fp.read()

            rf = RequestField(name=k, data=fdata, filename=fn, headers=fh)
            rf.make_multipart(content_type=ft)
            new_fields.append(rf)

        body, content_type = encode_multipart_formdata(new_fields)

        return body, content_type


class RequestHooksMixin(object):
    def register_hook(self, event, hook):
        """Properly register a hook."""

        if event not in self.hooks:
            raise ValueError('Unsupported event specified, with event name "%s"' % (event))

        if isinstance(hook, collections.Callable):
            self.hooks[event].append(hook)
        elif hasattr(hook, '__iter__'):
            self.hooks[event].extend(h for h in hook if isinstance(h, collections.Callable))

    def deregister_hook(self, event, hook):
        """Deregister a previously registered hook.
        Returns True if the hook existed, False if not.
        """

        try:
            self.hooks[event].remove(hook)
            return True
        except ValueError:
            return False


class Request(RequestHooksMixin):
    """A user-created :class:`Request <Request>` object.

    Used to prepare a :class:`PreparedRequest <PreparedRequest>`, which is sent to the server.

    :param method: HTTP method to use.
    :param url: URL to send.
    :param headers: dictionary of headers to send.
    :param files: dictionary of {filename: fileobject} files to multipart upload.
    :param data: the body to attach to the request. If a dictionary is provided, form-encoding will take place.
    :param json: json for the body to attach to the request (if files or data is not specified).
    :param params: dictionary of URL parameters to append to the URL.
    :param auth: Auth handler or (user, pass) tuple.
    :param cookies: dictionary or CookieJar of cookies to attach to this request.
    :param hooks: dictionary of callback hooks, for internal usage.

    Usage::

      >>> import requests
      >>> req = requests.Request('GET', 'http://httpbin.org/get')
      >>> req.prepare()
      <PreparedRequest [GET]>

    """
    def __init__(self, method=None, url=None, headers=None, files=None,
        data=None, params=None, auth=None, cookies=None, hooks=None, json=None):

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
        data=None, params=None, auth=None, cookies=None, hooks=None, json=None):
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
        p.url = self.url
        p.headers = self.headers.copy() if self.headers is not None else None
        p._cookies = _copy_cookie_jar(self._cookies)
        p.body = self.body
        p.hooks = self.hooks
        return p

    def prepare_method(self, method):
        """Prepares the given HTTP method."""
        self.method = method
        if self.method is not None:
            self.method = to_native_string(self.method.upper())

    def prepare_url(self, url, params):
        """Prepares the given HTTP URL."""
        #: Accept objects that have string representations.
        #: We're unable to blindly call unicode/str functions
        #: as this will include the bytestring indicator (b'')
        #: on python 3.x.
        #: https://github.com/kennethreitz/requests/pull/2238
        if isinstance(url, bytes):
            url = url.decode('utf8')
        else:
            url = unicode(url) if is_py2 else str(url)

        # Don't do any URL preparation for non-HTTP schemes like `mailto`,
        # `data` etc to work around exceptions from `url_parse`, which
        # handles RFC 3986 only.
        if ':' in url and not url.lower().startswith('http'):
            self.url = url
            return

        # Support for unicode domain names and paths.
        try:
            scheme, auth, host, port, path, query, fragment = parse_url(url)
        except LocationParseError as e:
            raise InvalidURL(*e.args)

        if not scheme:
            error = ("Invalid URL {0!r}: No schema supplied. Perhaps you meant http://{0}?")
            error = error.format(to_native_string(url, 'utf8'))

            raise MissingSchema(error)

        if not host:
            raise InvalidURL("Invalid URL %r: No host supplied" % url)

        # Only want to apply IDNA to the hostname
        try:
            host = host.encode('idna').decode('utf-8')
        except UnicodeError:
            raise InvalidURL('URL has an invalid label.')

        # Carefully reconstruct the network location
        netloc = auth or ''
        if netloc:
            netloc += '@'
        netloc += host
        if port:
            netloc += ':' + str(port)

        # Bare domains aren't valid URLs.
        if not path:
            path = '/'

        if is_py2:
            if isinstance(scheme, str):
                scheme = scheme.encode('utf-8')
            if isinstance(netloc, str):
                netloc = netloc.encode('utf-8')
            if isinstance(path, str):
                path = path.encode('utf-8')
            if isinstance(query, str):
                query = query.encode('utf-8')
            if isinstance(fragment, str):
                fragment = fragment.encode('utf-8')

        if isinstance(params, (str, bytes)):
            params = to_native_string(params)

        enc_params = self._encode_params(params)
        if enc_params:
            if query:
                query = '%s&%s' % (query, enc_params)
            else:
                query = enc_params

        url = requote_uri(urlunparse([scheme, netloc, path, None, query, fragment]))
        self.url = url

    def prepare_headers(self, headers):
        """Prepares the given HTTP headers."""

        if headers:
            self.headers = CaseInsensitiveDict((to_native_string(name), value) for name, value in headers.items())
        else:
            self.headers = CaseInsensitiveDict()

    def prepare_body(self, data, files, json=None):
        """Prepares the given HTTP body data."""

        # Check if file, fo, generator, iterator.
        # If not, run through normal process.

        # Nottin' on you.
        body = None
        content_type = None
        length = None

        if not data and json is not None:
            content_type = 'application/json'
            body = complexjson.dumps(json)

        is_stream = all([
            hasattr(data, '__iter__'),
            not isinstance(data, (basestring, list, tuple, dict))
        ])

        try:
            length = super_len(data)
        except (TypeError, AttributeError, UnsupportedOperation):
            length = None

        if is_stream:
            body = data

            if files:
                raise NotImplementedError('Streamed bodies and files are mutually exclusive.')

            if length:
                self.headers['Content-Length'] = builtin_str(length)
            else:
                self.headers['Transfer-Encoding'] = 'chunked'
        else:
            # Multi-part file uploads.
            if files:
                (body, content_type) = self._encode_files(files, data)
            else:
                if data:
                    body = self._encode_params(data)
                    if isinstance(data, basestring) or hasattr(data, 'read'):
                        content_type = None
                    else:
                        content_type = 'application/x-www-form-urlencoded'

            self.prepare_content_length(body)

            # Add content-type if it wasn't explicitly provided.
            if content_type and ('content-type' not in self.headers):
                self.headers['Content-Type'] = content_type

        self.body = body

    def prepare_content_length(self, body):
        if hasattr(body, 'seek') and hasattr(body, 'tell'):
            body.seek(0, 2)
            self.headers['Content-Length'] = builtin_str(body.tell())
            body.seek(0, 0)
        elif body is not None:
            l = super_len(body)
            if l:
                self.headers['Content-Length'] = builtin_str(l)
        elif (self.method not in ('GET', 'HEAD')) and (self.headers.get('Content-Length') is None):
            self.headers['Content-Length'] = '0'

    def prepare_auth(self, auth, url=''):
        """Prepares the given HTTP auth data."""

        # If no Auth is explicitly provided, extract it from the URL first.
        if auth is None:
            url_auth = get_auth_from_url(self.url)
            auth = url_auth if any(url_auth) else None

        if auth:
            if isinstance(auth, tuple) and len(auth) == 2:
                # special-case basic HTTP auth
                auth = HTTPBasicAuth(*auth)

            # Allow auth to make its changes.
            r = auth(self)

            # Update self to reflect the auth changes.
            self.__dict__.update(r.__dict__)

            # Recompute Content-Length
            self.prepare_content_length(self.body)

    def prepare_cookies(self, cookies):
        """Prepares the given HTTP cookie data.

        This function eventually generates a ``Cookie`` header from the
        given cookies using cookielib. Due to cookielib's design, the header
        will not be regenerated if it already exists, meaning this function
        can only be called once for the life of the
        :class:`PreparedRequest <PreparedRequest>` object. Any subsequent calls
        to ``prepare_cookies`` will have no actual effect, unless the "Cookie"
        header is removed beforehand."""

        if isinstance(cookies, cookielib.CookieJar):
            self._cookies = cookies
        else:
            self._cookies = cookiejar_from_dict(cookies)

        cookie_header = get_cookie_header(self._cookies, self)
        if cookie_header is not None:
            self.headers['Cookie'] = cookie_header

    def prepare_hooks(self, hooks):
        """Prepares the given hooks."""
        # hooks can be passed as None to the prepare method and to this
        # method. To prevent iterating over None, simply use an empty list
        # if hooks is False-y
        hooks = hooks or []
        for event in hooks:
            self.register_hook(event, hooks[event])


class Response(object):
    """The :class:`Response <Response>` object, which contains a
    server's response to an HTTP request.
    """

    __attrs__ = [
        '_content', 'status_code', 'headers', 'url', 'history',
        'encoding', 'reason', 'cookies', 'elapsed', 'request'
    ]

    def __init__(self):
        super(Response, self).__init__()

        self._content = False
        self._content_consumed = False

        #: Integer Code of responded HTTP Status, e.g. 404 or 200.
        self.status_code = None

        #: Case-insensitive Dictionary of Response Headers.
        #: For example, ``headers['content-encoding']`` will return the
        #: value of a ``'Content-Encoding'`` response header.
        self.headers = CaseInsensitiveDict()

        #: File-like object representation of response (for advanced usage).
        #: Use of ``raw`` requires that ``stream=True`` be set on the request.
        # This requirement does not apply for use internally to Requests.
        self.raw = None

        #: Final URL location of Response.
        self.url = None

        #: Encoding to decode with when accessing r.text.
        self.encoding = None

        #: A list of :class:`Response <Response>` objects from
        #: the history of the Request. Any redirect responses will end
        #: up here. The list is sorted from the oldest to the most recent request.
        self.history = []

        #: Textual reason of responded HTTP Status, e.g. "Not Found" or "OK".
        self.reason = None

        #: A CookieJar of Cookies the server sent back.
        self.cookies = cookiejar_from_dict({})

        #: The amount of time elapsed between sending the request
        #: and the arrival of the response (as a timedelta).
        #: This property specifically measures the time taken between sending
        #: the first byte of the request and finishing parsing the headers. It
        #: is therefore unaffected by consuming the response content or the
        #: value of the ``stream`` keyword argument.
        self.elapsed = datetime.timedelta(0)

        #: The :class:`PreparedRequest <PreparedRequest>` object to which this
        #: is a response.
        self.request = None

    def __getstate__(self):
        # Consume everything; accessing the content attribute makes
        # sure the content has been fully read.
        if not self._content_consumed:
            self.content

        return dict(
            (attr, getattr(self, attr, None))
            for attr in self.__attrs__
        )

    def __setstate__(self, state):
        for name, value in state.items():
            setattr(self, name, value)

        # pickled objects do not have .raw
        setattr(self, '_content_consumed', True)
        setattr(self, 'raw', None)

    def __repr__(self):
        return '<Response [%s]>' % (self.status_code)

    def __bool__(self):
        """Returns true if :attr:`status_code` is 'OK'."""
        return self.ok

    def __nonzero__(self):
        """Returns true if :attr:`status_code` is 'OK'."""
        return self.ok

    def __iter__(self):
        """Allows you to use a response as an iterator."""
        return self.iter_content(128)

    @property
    def ok(self):
        try:
            self.raise_for_status()
        except HTTPError:
            return False
        return True

    @property
    def is_redirect(self):
        """True if this Response is a well-formed HTTP redirect that could have
        been processed automatically (by :meth:`Session.resolve_redirects`).
        """
        return ('location' in self.headers and self.status_code in REDIRECT_STATI)

    @property
    def is_permanent_redirect(self):
        """True if this Response one of the permanent versions of redirect"""
        return ('location' in self.headers and self.status_code in (codes.moved_permanently, codes.permanent_redirect))

    @property
    def apparent_encoding(self):
        """The apparent encoding, provided by the chardet library"""
        return chardet.detect(self.content)['encoding']

    def iter_content(self, chunk_size=1, decode_unicode=False):
        """Iterates over the response data.  When stream=True is set on the
        request, this avoids reading the content at once into memory for
        large responses.  The chunk size is the number of bytes it should
        read into memory.  This is not necessarily the length of each item
        returned as decoding can take place.

        If decode_unicode is True, content will be decoded using the best
        available encoding based on the response.
        """

        def generate():
            # Special case for urllib3.
            if hasattr(self.raw, 'stream'):
                try:
                    for chunk in self.raw.stream(chunk_size, decode_content=True):
                        yield chunk
                except ProtocolError as e:
                    raise ChunkedEncodingError(e)
                except DecodeError as e:
                    raise ContentDecodingError(e)
                except ReadTimeoutError as e:
                    raise ConnectionError(e)
            else:
                # Standard file-like object.
                while True:
                    chunk = self.raw.read(chunk_size)
                    if not chunk:
                        break
                    yield chunk

            self._content_consumed = True

        if self._content_consumed and isinstance(self._content, bool):
            raise StreamConsumedError()
        # simulate reading small chunks of the content
        reused_chunks = iter_slices(self._content, chunk_size)

        stream_chunks = generate()

        chunks = reused_chunks if self._content_consumed else stream_chunks

        if decode_unicode:
            chunks = stream_decode_response_unicode(chunks, self)

        return chunks

    def iter_lines(self, chunk_size=ITER_CHUNK_SIZE, decode_unicode=None, delimiter=None):
        """Iterates over the response data, one line at a time.  When
        stream=True is set on the request, this avoids reading the
        content at once into memory for large responses.

        .. note:: This method is not reentrant safe.
        """

        pending = None

        for chunk in self.iter_content(chunk_size=chunk_size, decode_unicode=decode_unicode):

            if pending is not None:
                chunk = pending + chunk

            if delimiter:
                lines = chunk.split(delimiter)
            else:
                lines = chunk.splitlines()

            if lines and lines[-1] and chunk and lines[-1][-1] == chunk[-1]:
                pending = lines.pop()
            else:
                pending = None

            for line in lines:
                yield line

        if pending is not None:
            yield pending

    @property
    def content(self):
        """Content of the response, in bytes."""

        if self._content is False:
            # Read the contents.
            try:
                if self._content_consumed:
                    raise RuntimeError(
                        'The content for this response was already consumed')

                if self.status_code == 0:
                    self._content = None
                else:
                    self._content = bytes().join(self.iter_content(CONTENT_CHUNK_SIZE)) or bytes()

            except AttributeError:
                self._content = None

        self._content_consumed = True
        # don't need to release the connection; that's been handled by urllib3
        # since we exhausted the data.
        return self._content

    @property
    def text(self):
        """Content of the response, in unicode.

        If Response.encoding is None, encoding will be guessed using
        ``chardet``.

        The encoding of the response content is determined based solely on HTTP
        headers, following RFC 2616 to the letter. If you can take advantage of
        non-HTTP knowledge to make a better guess at the encoding, you should
        set ``r.encoding`` appropriately before accessing this property.
        """

        # Try charset from content-type
        content = None
        encoding = self.encoding

        if not self.content:
            return str('')

        # Fallback to auto-detected encoding.
        if self.encoding is None:
            encoding = self.apparent_encoding

        # Decode unicode from given encoding.
        try:
            content = str(self.content, encoding, errors='replace')
        except (LookupError, TypeError):
            # A LookupError is raised if the encoding was not found which could
            # indicate a misspelling or similar mistake.
            #
            # A TypeError can be raised if encoding is None
            #
            # So we try blindly encoding.
            content = str(self.content, errors='replace')

        return content

    def json(self, **kwargs):
        """Returns the json-encoded content of a response, if any.

        :param \*\*kwargs: Optional arguments that ``json.loads`` takes.
        """

        if not self.encoding and len(self.content) > 3:
            # No encoding set. JSON RFC 4627 section 3 states we should expect
            # UTF-8, -16 or -32. Detect which one to use; If the detection or
            # decoding fails, fall back to `self.text` (using chardet to make
            # a best guess).
            encoding = guess_json_utf(self.content)
            if encoding is not None:
                try:
                    return complexjson.loads(
                        self.content.decode(encoding), **kwargs
                    )
                except UnicodeDecodeError:
                    # Wrong UTF codec detected; usually because it's not UTF-8
                    # but some other 8-bit codec.  This is an RFC violation,
                    # and the server didn't bother to tell us what codec *was*
                    # used.
                    pass
        return complexjson.loads(self.text, **kwargs)

    @property
    def links(self):
        """Returns the parsed header links of the response, if any."""

        header = self.headers.get('link')

        # l = MultiDict()
        l = {}

        if header:
            links = parse_header_links(header)

            for link in links:
                key = link.get('rel') or link.get('url')
                l[key] = link

        return l

    def raise_for_status(self):
        """Raises stored :class:`HTTPError`, if one occurred."""

        http_error_msg = ''

        if 400 <= self.status_code < 500:
            http_error_msg = '%s Client Error: %s for url: %s' % (self.status_code, self.reason, self.url)

        elif 500 <= self.status_code < 600:
            http_error_msg = '%s Server Error: %s for url: %s' % (self.status_code, self.reason, self.url)

        if http_error_msg:
            raise HTTPError(http_error_msg, response=self)

    def close(self):
        """Releases the connection back to the pool. Once this method has been
        called the underlying ``raw`` object must not be accessed again.

        *Note: Should not normally need to be called explicitly.*
        """
        if not self._content_consumed:
            return self.raw.close()

        return self.raw.release_conn()

```


# test_requests.py

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Tests for Requests."""

from __future__ import division
import json
import os
import pickle
import unittest
import collections
import contextlib

import io
import requests
import pytest
from requests.adapters import HTTPAdapter
from requests.auth import HTTPDigestAuth, _basic_auth_str
from requests.compat import (
    Morsel, cookielib, getproxies, str, urljoin, urlparse, is_py3,
    builtin_str, OrderedDict
    )
from requests.cookies import cookiejar_from_dict, morsel_to_cookie
from requests.exceptions import (ConnectionError, ConnectTimeout,
                                 InvalidSchema, InvalidURL, MissingSchema,
                                 ReadTimeout, Timeout, RetryError)
from requests.models import PreparedRequest
from requests.structures import CaseInsensitiveDict
from requests.sessions import SessionRedirectMixin
from requests.models import urlencode
from requests.hooks import default_hooks

try:
    import StringIO
except ImportError:
    import io as StringIO

try:
    from multiprocessing.pool import ThreadPool
except ImportError:
    ThreadPool = None

if is_py3:
    def u(s):
        return s
else:
    def u(s):
        return s.decode('unicode-escape')


@pytest.fixture
def httpbin(httpbin):
    # Issue #1483: Make sure the URL always has a trailing slash
    httpbin_url = httpbin.url.rstrip('/') + '/'

    def inner(*suffix):
        return urljoin(httpbin_url, '/'.join(suffix))

    return inner


@pytest.fixture
def httpsbin_url(httpbin_secure):
    # Issue #1483: Make sure the URL always has a trailing slash
    httpbin_url = httpbin_secure.url.rstrip('/') + '/'

    def inner(*suffix):
        return urljoin(httpbin_url, '/'.join(suffix))

    return inner


# Requests to this URL should always fail with a connection timeout (nothing
# listening on that port)
TARPIT = "http://10.255.255.1"

class TestRequests(object):

    _multiprocess_can_split_ = True

    def setUp(self):
        """Create simple data set with headers."""
        pass

    def tearDown(self):
        """Teardown."""
        pass

    def test_entry_points(self):

        requests.session
        requests.session().get
        requests.session().head
        requests.get
        requests.head
        requests.put
        requests.patch
        requests.post

    def test_invalid_url(self):
        with pytest.raises(MissingSchema):
            requests.get('hiwpefhipowhefopw')
        with pytest.raises(InvalidSchema):
            requests.get('localhost:3128')
        with pytest.raises(InvalidSchema):
            requests.get('localhost.localdomain:3128/')
        with pytest.raises(InvalidSchema):
            requests.get('10.122.1.1:3128/')
        with pytest.raises(InvalidURL):
            requests.get('http://')

    def test_basic_building(self):
        req = requests.Request()
        req.url = 'http://kennethreitz.org/'
        req.data = {'life': '42'}

        pr = req.prepare()
        assert pr.url == req.url
        assert pr.body == 'life=42'

    def test_no_content_length(self, httpbin):
        get_req = requests.Request('GET', httpbin('get')).prepare()
        assert 'Content-Length' not in get_req.headers
        head_req = requests.Request('HEAD', httpbin('head')).prepare()
        assert 'Content-Length' not in head_req.headers

    def test_override_content_length(self, httpbin):
        headers = {
            'Content-Length': 'not zero'
        }
        r = requests.Request('POST', httpbin('post'), headers=headers).prepare()
        assert 'Content-Length' in r.headers
        assert r.headers['Content-Length'] == 'not zero'

    def test_path_is_not_double_encoded(self):
        request = requests.Request('GET', "http://0.0.0.0/get/test case").prepare()

        assert request.path_url == '/get/test%20case'

    def test_params_are_added_before_fragment(self):
        request = requests.Request('GET',
            "http://example.com/path#fragment", params={"a": "b"}).prepare()
        assert request.url == "http://example.com/path?a=b#fragment"
        request = requests.Request('GET',
            "http://example.com/path?key=value#fragment", params={"a": "b"}).prepare()
        assert request.url == "http://example.com/path?key=value&a=b#fragment"

    def test_params_original_order_is_preserved_by_default(self):
        param_ordered_dict = OrderedDict((('z', 1), ('a', 1), ('k', 1), ('d', 1)))
        session = requests.Session()
        request = requests.Request('GET', 'http://example.com/', params=param_ordered_dict)
        prep = session.prepare_request(request)
        assert prep.url == 'http://example.com/?z=1&a=1&k=1&d=1'

    def test_params_bytes_are_encoded(self):
        request = requests.Request('GET', 'http://example.com',
                                   params=b'test=foo').prepare()
        assert request.url == 'http://example.com/?test=foo'

    def test_mixed_case_scheme_acceptable(self, httpbin):
        s = requests.Session()
        s.proxies = getproxies()
        parts = urlparse(httpbin('get'))
        schemes = ['http://', 'HTTP://', 'hTTp://', 'HttP://']
        for scheme in schemes:
            url = scheme + parts.netloc + parts.path
            r = requests.Request('GET', url)
            r = s.send(r.prepare())
            assert r.status_code == 200, 'failed for scheme {0}'.format(scheme)

    def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()
        s.proxies = getproxies()

        r = s.send(r.prepare())

        assert r.status_code == 200

    def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
        r = requests.get(httpbin('redirect', '1'))
        assert r.status_code == 200
        assert r.history[0].status_code == 302
        assert r.history[0].is_redirect

    # def test_HTTP_302_ALLOW_REDIRECT_POST(self):
    #     r = requests.post(httpbin('status', '302'), data={'some': 'data'})
    #     self.assertEqual(r.status_code, 200)

    def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
        heads = {'User-agent': 'Mozilla/5.0'}

        r = requests.get(httpbin('user-agent'), headers=heads)

        assert heads['User-agent'] in r.text
        assert r.status_code == 200

    def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
        heads = {'User-agent': 'Mozilla/5.0'}

        r = requests.get(httpbin('get') + '?test=true', params={'q': 'test'}, headers=heads)
        assert r.status_code == 200

    def test_set_cookie_on_301(self, httpbin):
        s = requests.session()
        url = httpbin('cookies/set?foo=bar')
        s.get(url)
        assert s.cookies['foo'] == 'bar'

    def test_cookie_sent_on_redirect(self, httpbin):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
        r = s.get(httpbin('redirect/1'))  # redirects to httpbin('get')
        assert 'Cookie' in r.json()['headers']

    def test_cookie_removed_on_expire(self, httpbin):
        s = requests.session()
        s.get(httpbin('cookies/set?foo=bar'))
        assert s.cookies['foo'] == 'bar'
        s.get(
            httpbin('response-headers'),
            params={
                'Set-Cookie':
                    'foo=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT'
            }
        )
        assert 'foo' not in s.cookies

    def test_cookie_quote_wrapped(self, httpbin):
        s = requests.session()
        s.get(httpbin('cookies/set?foo="bar:baz"'))
        assert s.cookies['foo'] == '"bar:baz"'

    def test_cookie_persists_via_api(self, httpbin):
        s = requests.session()
        r = s.get(httpbin('redirect/1'), cookies={'foo': 'bar'})
        assert 'foo' in r.request.headers['Cookie']
        assert 'foo' in r.history[0].request.headers['Cookie']

    def test_request_cookie_overrides_session_cookie(self, httpbin):
        s = requests.session()
        s.cookies['foo'] = 'bar'
        r = s.get(httpbin('cookies'), cookies={'foo': 'baz'})
        assert r.json()['cookies']['foo'] == 'baz'
        # Session cookie should not be modified
        assert s.cookies['foo'] == 'bar'

    def test_request_cookies_not_persisted(self, httpbin):
        s = requests.session()
        s.get(httpbin('cookies'), cookies={'foo': 'baz'})
        # Sending a request with cookies should not add cookies to the session
        assert not s.cookies

    def test_generic_cookiejar_works(self, httpbin):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        s.cookies = cj
        r = s.get(httpbin('cookies'))
        # Make sure the cookie was sent
        assert r.json()['cookies']['foo'] == 'bar'
        # Make sure the session cj is still the custom one
        assert s.cookies is cj

    def test_param_cookiejar_works(self, httpbin):
        cj = cookielib.CookieJar()
        cookiejar_from_dict({'foo': 'bar'}, cj)
        s = requests.session()
        r = s.get(httpbin('cookies'), cookies=cj)
        # Make sure the cookie was sent
        assert r.json()['cookies']['foo'] == 'bar'

    def test_requests_in_history_are_not_overridden(self, httpbin):
        resp = requests.get(httpbin('redirect/3'))
        urls = [r.url for r in resp.history]
        req_urls = [r.request.url for r in resp.history]
        assert urls == req_urls

    def test_history_is_always_a_list(self, httpbin):
        """
        Show that even with redirects, Response.history is always a list.
        """
        resp = requests.get(httpbin('get'))
        assert isinstance(resp.history, list)
        resp = requests.get(httpbin('redirect/1'))
        assert isinstance(resp.history, list)
        assert not isinstance(resp.history, tuple)

    def test_headers_on_session_with_None_are_not_sent(self, httpbin):
        """Do not send headers in Session.headers with None values."""
        ses = requests.Session()
        ses.headers['Accept-Encoding'] = None
        req = requests.Request('GET', httpbin('get'))
        prep = ses.prepare_request(req)
        assert 'Accept-Encoding' not in prep.headers

    def test_user_agent_transfers(self, httpbin):

        heads = {
            'User-agent': 'Mozilla/5.0 (github.com/kennethreitz/requests)'
        }

        r = requests.get(httpbin('user-agent'), headers=heads)
        assert heads['User-agent'] in r.text

        heads = {
            'user-agent': 'Mozilla/5.0 (github.com/kennethreitz/requests)'
        }

        r = requests.get(httpbin('user-agent'), headers=heads)
        assert heads['user-agent'] in r.text

    def test_HTTP_200_OK_HEAD(self, httpbin):
        r = requests.head(httpbin('get'))
        assert r.status_code == 200

    def test_HTTP_200_OK_PUT(self, httpbin):
        r = requests.put(httpbin('put'))
        assert r.status_code == 200

    def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
        auth = ('user', 'pass')
        url = httpbin('basic-auth', 'user', 'pass')

        r = requests.get(url, auth=auth)
        assert r.status_code == 200

        r = requests.get(url)
        assert r.status_code == 401

        s = requests.session()
        s.auth = auth
        r = s.get(url)
        assert r.status_code == 200

    def test_connection_error_invalid_domain(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
            requests.get("http://doesnotexist.google.com")

    def test_connection_error_invalid_port(self):
        """Connecting to an invalid port should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
            requests.get("http://localhost:1", timeout=1)

    def test_LocationParseError(self):
        """Inputing a URL that cannot be parsed should raise an InvalidURL error"""
        with pytest.raises(InvalidURL):
            requests.get("http://fe80::5054:ff:fe5a:fc0")

    def test_basicauth_with_netrc(self, httpbin):
        auth = ('user', 'pass')
        wrong_auth = ('wronguser', 'wrongpass')
        url = httpbin('basic-auth', 'user', 'pass')

        old_auth = requests.sessions.get_netrc_auth

        try:
            def get_netrc_auth_mock(url):
                return auth
            requests.sessions.get_netrc_auth = get_netrc_auth_mock

            # Should use netrc and work.
            r = requests.get(url)
            assert r.status_code == 200

            # Given auth should override and fail.
            r = requests.get(url, auth=wrong_auth)
            assert r.status_code == 401

            s = requests.session()

            # Should use netrc and work.
            r = s.get(url)
            assert r.status_code == 200

            # Given auth should override and fail.
            s.auth = wrong_auth
            r = s.get(url)
            assert r.status_code == 401
        finally:
            requests.sessions.get_netrc_auth = old_auth

    def test_DIGEST_HTTP_200_OK_GET(self, httpbin):

        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')

        r = requests.get(url, auth=auth)
        assert r.status_code == 200

        r = requests.get(url)
        assert r.status_code == 401

        s = requests.session()
        s.auth = HTTPDigestAuth('user', 'pass')
        r = s.get(url)
        assert r.status_code == 200

    def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        r = requests.get(url)
        assert r.cookies['fake'] == 'fake_value'

        r = requests.get(url, auth=auth)
        assert r.status_code == 200

    def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
        url = httpbin('digest-auth', 'auth', 'user', 'pass')
        auth = HTTPDigestAuth('user', 'pass')
        s = requests.Session()
        s.get(url, auth=auth)
        assert s.cookies['fake'] == 'fake_value'

    def test_DIGEST_STREAM(self, httpbin):

        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')

        r = requests.get(url, auth=auth, stream=True)
        assert r.raw.read() != b''

        r = requests.get(url, auth=auth, stream=False)
        assert r.raw.read() == b''

    def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):

        auth = HTTPDigestAuth('user', 'wrongpass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')

        r = requests.get(url, auth=auth)
        assert r.status_code == 401

        r = requests.get(url)
        assert r.status_code == 401

        s = requests.session()
        s.auth = auth
        r = s.get(url)
        assert r.status_code == 401

    def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):

        auth = HTTPDigestAuth('user', 'pass')
        url = httpbin('digest-auth', 'auth', 'user', 'pass')

        r = requests.get(url, auth=auth)
        assert '"auth"' in r.request.headers['Authorization']

    def test_POSTBIN_GET_POST_FILES(self, httpbin):

        url = httpbin('post')
        post1 = requests.post(url).raise_for_status()

        post1 = requests.post(url, data={'some': 'data'})
        assert post1.status_code == 200

        with open('requirements.txt') as f:
            post2 = requests.post(url, files={'some': f})
        assert post2.status_code == 200

        post4 = requests.post(url, data='[{"some": "json"}]')
        assert post4.status_code == 200

        with pytest.raises(ValueError):
            requests.post(url, files=['bad file data'])

    def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):

        url = httpbin('post')
        post1 = requests.post(url).raise_for_status()

        post1 = requests.post(url, data={'some': 'data'})
        assert post1.status_code == 200

        with open('requirements.txt') as f:
            post2 = requests.post(url,
                data={'some': 'data'}, files={'some': f})
        assert post2.status_code == 200

        post4 = requests.post(url, data='[{"some": "json"}]')
        assert post4.status_code == 200

        with pytest.raises(ValueError):
            requests.post(url, files=['bad file data'])

    def test_conflicting_post_params(self, httpbin):
        url = httpbin('post')
        with open('requirements.txt') as f:
            pytest.raises(ValueError, "requests.post(url, data='[{\"some\": \"data\"}]', files={'some': f})")
            pytest.raises(ValueError, "requests.post(url, data=u('[{\"some\": \"data\"}]'), files={'some': f})")

    def test_request_ok_set(self, httpbin):
        r = requests.get(httpbin('status', '404'))
        assert not r.ok

    def test_status_raising(self, httpbin):
        r = requests.get(httpbin('status', '404'))
        with pytest.raises(requests.exceptions.HTTPError):
            r.raise_for_status()

        r = requests.get(httpbin('status', '500'))
        assert not r.ok

    def test_decompress_gzip(self, httpbin):
        r = requests.get(httpbin('gzip'))
        r.content.decode('ascii')

    def test_unicode_get(self, httpbin):
        url = httpbin('/get')
        requests.get(url, params={'foo': 'føø'})
        requests.get(url, params={'føø': 'føø'})
        requests.get(url, params={'føø': 'føø'})
        requests.get(url, params={'foo': 'foo'})
        requests.get(httpbin('ø'), params={'foo': 'foo'})

    def test_unicode_header_name(self, httpbin):
        requests.put(
            httpbin('put'),
            headers={str('Content-Type'): 'application/octet-stream'},
            data='\xff')  # compat.str is unicode.

    def test_pyopenssl_redirect(self, httpsbin_url, httpbin_ca_bundle):
        requests.get(httpsbin_url('status', '301'), verify=httpbin_ca_bundle)

    def test_urlencoded_get_query_multivalued_param(self, httpbin):

        r = requests.get(httpbin('get'), params=dict(test=['foo', 'baz']))
        assert r.status_code == 200
        assert r.url == httpbin('get?test=foo&test=baz')

    def test_different_encodings_dont_break_post(self, httpbin):
        r = requests.post(httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            params={'blah': 'asdf1234'},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
        assert r.status_code == 200

    def test_unicode_multipart_post(self, httpbin):
        r = requests.post(httpbin('post'),
            data={'stuff': u('ëlïxr')},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
        assert r.status_code == 200

        r = requests.post(httpbin('post'),
            data={'stuff': u('ëlïxr').encode('utf-8')},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
        assert r.status_code == 200

        r = requests.post(httpbin('post'),
            data={'stuff': 'elixr'},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
        assert r.status_code == 200

        r = requests.post(httpbin('post'),
            data={'stuff': 'elixr'.encode('utf-8')},
            files={'file': ('test_requests.py', open(__file__, 'rb'))})
        assert r.status_code == 200

    def test_unicode_multipart_post_fieldnames(self, httpbin):
        filename = os.path.splitext(__file__)[0] + '.py'
        r = requests.Request(method='POST',
                             url=httpbin('post'),
                             data={'stuff'.encode('utf-8'): 'elixr'},
                             files={'file': ('test_requests.py',
                                             open(filename, 'rb'))})
        prep = r.prepare()
        assert b'name="stuff"' in prep.body
        assert b'name="b\'stuff\'"' not in prep.body

    def test_unicode_method_name(self, httpbin):
        files = {'file': open('test_requests.py', 'rb')}
        r = requests.request(
            method=u('POST'), url=httpbin('post'), files=files)
        assert r.status_code == 200

    def test_unicode_method_name_with_request_object(self, httpbin):
        files = {'file': open('test_requests.py', 'rb')}
        s = requests.Session()
        req = requests.Request(u("POST"), httpbin('post'), files=files)
        prep = s.prepare_request(req)
        assert isinstance(prep.method, builtin_str)
        assert prep.method == "POST"

        resp = s.send(prep)
        assert resp.status_code == 200

    def test_custom_content_type(self, httpbin):
        r = requests.post(
            httpbin('post'),
            data={'stuff': json.dumps({'a': 123})},
            files={'file1': ('test_requests.py', open(__file__, 'rb')),
                   'file2': ('test_requests', open(__file__, 'rb'),
                             'text/py-content-type')})
        assert r.status_code == 200
        assert b"text/py-content-type" in r.request.body

    def test_hook_receives_request_arguments(self, httpbin):
        def hook(resp, **kwargs):
            assert resp is not None
            assert kwargs != {}

        requests.Request('GET', httpbin(), hooks={'response': hook})

    def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
        hook = lambda x, *args, **kwargs: x
        s = requests.Session()
        s.hooks['response'].append(hook)
        r = requests.Request('GET', httpbin())
        prep = s.prepare_request(r)
        assert prep.hooks['response'] != []
        assert prep.hooks['response'] == [hook]

    def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
        hook1 = lambda x, *args, **kwargs: x
        hook2 = lambda x, *args, **kwargs: x
        assert hook1 is not hook2
        s = requests.Session()
        s.hooks['response'].append(hook2)
        r = requests.Request('GET', httpbin(), hooks={'response': [hook1]})
        prep = s.prepare_request(r)
        assert prep.hooks['response'] == [hook1]

    def test_prepared_request_hook(self, httpbin):
        def hook(resp, **kwargs):
            resp.hook_working = True
            return resp

        req = requests.Request('GET', httpbin(), hooks={'response': hook})
        prep = req.prepare()

        s = requests.Session()
        s.proxies = getproxies()
        resp = s.send(prep)

        assert hasattr(resp, 'hook_working')

    def test_prepared_from_session(self, httpbin):
        class DummyAuth(requests.auth.AuthBase):
            def __call__(self, r):
                r.headers['Dummy-Auth-Test'] = 'dummy-auth-test-ok'
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
                     'page=2&per_page=10>; rel="next", <https://api.github.'
                     'com/users/kennethreitz/repos?page=7&per_page=10>; '
                     ' rel="last"'),
            'server': 'GitHub.com',
            'status': '200 OK',
            'vary': 'Accept',
            'x-content-type-options': 'nosniff',
            'x-github-media-type': 'github.beta',
            'x-ratelimit-limit': '60',
            'x-ratelimit-remaining': '57'
        }
        assert r.links['next']['rel'] == 'next'

    def test_cookie_parameters(self):
        key = 'some_cookie'
        value = 'some_value'
        secure = True
        domain = 'test.com'
        rest = {'HttpOnly': True}

        jar = requests.cookies.RequestsCookieJar()
        jar.set(key, value, secure=secure, domain=domain, rest=rest)

        assert len(jar) == 1
        assert 'some_cookie' in jar

        cookie = list(jar)[0]
        assert cookie.secure == secure
        assert cookie.domain == domain
        assert cookie._rest['HttpOnly'] == rest['HttpOnly']

    def test_cookie_as_dict_keeps_len(self):
        key = 'some_cookie'
        value = 'some_value'

        key1 = 'some_cookie1'
        value1 = 'some_value1'

        jar = requests.cookies.RequestsCookieJar()
        jar.set(key, value)
        jar.set(key1, value1)

        d1 = dict(jar)
        d2 = dict(jar.iteritems())
        d3 = dict(jar.items())

        assert len(jar) == 2
        assert len(d1) == 2
        assert len(d2) == 2
        assert len(d3) == 2

    def test_cookie_as_dict_keeps_items(self):
        key = 'some_cookie'
        value = 'some_value'

        key1 = 'some_cookie1'
        value1 = 'some_value1'

        jar = requests.cookies.RequestsCookieJar()
        jar.set(key, value)
        jar.set(key1, value1)

        d1 = dict(jar)
        d2 = dict(jar.iteritems())
        d3 = dict(jar.items())

        assert d1['some_cookie'] == 'some_value'
        assert d2['some_cookie'] == 'some_value'
        assert d3['some_cookie1'] == 'some_value1'

    def test_cookie_as_dict_keys(self):
        key = 'some_cookie'
        value = 'some_value'

        key1 = 'some_cookie1'
        value1 = 'some_value1'

        jar = requests.cookies.RequestsCookieJar()
        jar.set(key, value)
        jar.set(key1, value1)

        keys = jar.keys()
        assert keys == list(keys)
        # make sure one can use keys multiple times
        assert list(keys) == list(keys)

    def test_cookie_as_dict_values(self):
        key = 'some_cookie'
        value = 'some_value'

        key1 = 'some_cookie1'
        value1 = 'some_value1'

        jar = requests.cookies.RequestsCookieJar()
        jar.set(key, value)
        jar.set(key1, value1)

        values = jar.values()
        assert values == list(values)
        # make sure one can use values multiple times
        assert list(values) == list(values)

    def test_cookie_as_dict_items(self):
        key = 'some_cookie'
        value = 'some_value'

        key1 = 'some_cookie1'
        value1 = 'some_value1'

        jar = requests.cookies.RequestsCookieJar()
        jar.set(key, value)
        jar.set(key1, value1)

        items = jar.items()
        assert items == list(items)
        # make sure one can use items multiple times
        assert list(items) == list(items)

    def test_time_elapsed_blank(self, httpbin):
        r = requests.get(httpbin('get'))
        td = r.elapsed
        total_seconds = ((td.microseconds + (td.seconds + td.days * 24 * 3600)
                         * 10**6) / 10**6)
        assert total_seconds > 0.0

    def test_response_is_iterable(self):
        r = requests.Response()
        io = StringIO.StringIO('abc')
        read_ = io.read

        def read_mock(amt, decode_content=None):
            return read_(amt)
        setattr(io, 'read', read_mock)
        r.raw = io
        assert next(iter(r))
        io.close()

    def test_response_decode_unicode(self):
        """
        When called with decode_unicode, Response.iter_content should always
        return unicode.
        """
        r = requests.Response()
        r._content_consumed = True
        r._content = b'the content'
        r.encoding = 'ascii'

        chunks = r.iter_content(decode_unicode=True)
        assert all(isinstance(chunk, str) for chunk in chunks)

        # also for streaming
        r = requests.Response()
        r.raw = io.BytesIO(b'the content')
        r.encoding = 'ascii'
        chunks = r.iter_content(decode_unicode=True)
        assert all(isinstance(chunk, str) for chunk in chunks)

    def test_request_and_response_are_pickleable(self, httpbin):
        r = requests.get(httpbin('get'))

        # verify we can pickle the original request
        assert pickle.loads(pickle.dumps(r.request))

        # verify we can pickle the response and that we have access to
        # the original request.
        pr = pickle.loads(pickle.dumps(r))
        assert r.request.url == pr.request.url
        assert r.request.headers == pr.request.headers

    def test_get_auth_from_url(self):
        url = 'http://user:pass@complex.url.com/path?query=yes'
        assert ('user', 'pass') == requests.utils.get_auth_from_url(url)

    def test_get_auth_from_url_encoded_spaces(self):
        url = 'http://user:pass%20pass@complex.url.com/path?query=yes'
        assert ('user', 'pass pass') == requests.utils.get_auth_from_url(url)

    def test_get_auth_from_url_not_encoded_spaces(self):
        url = 'http://user:pass pass@complex.url.com/path?query=yes'
        assert ('user', 'pass pass') == requests.utils.get_auth_from_url(url)

    def test_get_auth_from_url_percent_chars(self):
        url = 'http://user%25user:pass@complex.url.com/path?query=yes'
        assert ('user%user', 'pass') == requests.utils.get_auth_from_url(url)

    def test_get_auth_from_url_encoded_hashes(self):
        url = 'http://user:pass%23pass@complex.url.com/path?query=yes'
        assert ('user', 'pass#pass') == requests.utils.get_auth_from_url(url)

    def test_cannot_send_unprepared_requests(self, httpbin):
        r = requests.Request(url=httpbin())
        with pytest.raises(ValueError):
            requests.Session().send(r)

    def test_http_error(self):
        error = requests.exceptions.HTTPError()
        assert not error.response
        response = requests.Response()
        error = requests.exceptions.HTTPError(response=response)
        assert error.response == response
        error = requests.exceptions.HTTPError('message', response=response)
        assert str(error) == 'message'
        assert error.response == response

    def test_session_pickling(self, httpbin):
        r = requests.Request('GET', httpbin('get'))
        s = requests.Session()

        s = pickle.loads(pickle.dumps(s))
        s.proxies = getproxies()

        r = s.send(r.prepare())
        assert r.status_code == 200

    def test_fixes_1329(self, httpbin):
        """
        Ensure that header updates are done case-insensitively.
        """
        s = requests.Session()
        s.headers.update({'ACCEPT': 'BOGUS'})
        s.headers.update({'accept': 'application/json'})
        r = s.get(httpbin('get'))
        headers = r.request.headers
        assert headers['accept'] == 'application/json'
        assert headers['Accept'] == 'application/json'
        assert headers['ACCEPT'] == 'application/json'

    def test_uppercase_scheme_redirect(self, httpbin):
        parts = urlparse(httpbin('html'))
        url = "HTTP://" + parts.netloc + parts.path
        r = requests.get(httpbin('redirect-to'), params={'url': url})
        assert r.status_code == 200
        assert r.url.lower() == url.lower()

    def test_transport_adapter_ordering(self):
        s = requests.Session()
        order = ['https://', 'http://']
        assert order == list(s.adapters)
        s.mount('http://git', HTTPAdapter())
        s.mount('http://github', HTTPAdapter())
        s.mount('http://github.com', HTTPAdapter())
        s.mount('http://github.com/about/', HTTPAdapter())
        order = [
            'http://github.com/about/',
            'http://github.com',
            'http://github',
            'http://git',
            'https://',
            'http://',
        ]
        assert order == list(s.adapters)
        s.mount('http://gittip', HTTPAdapter())
        s.mount('http://gittip.com', HTTPAdapter())
        s.mount('http://gittip.com/about/', HTTPAdapter())
        order = [
            'http://github.com/about/',
            'http://gittip.com/about/',
            'http://github.com',
            'http://gittip.com',
            'http://github',
            'http://gittip',
            'http://git',
            'https://',
            'http://',
        ]
        assert order == list(s.adapters)
        s2 = requests.Session()
        s2.adapters = {'http://': HTTPAdapter()}
        s2.mount('https://', HTTPAdapter())
        assert 'http://' in s2.adapters
        assert 'https://' in s2.adapters

    def test_header_remove_is_case_insensitive(self, httpbin):
        # From issue #1321
        s = requests.Session()
        s.headers['foo'] = 'bar'
        r = s.get(httpbin('get'), headers={'FOO': None})
        assert 'foo' not in r.request.headers

    def test_params_are_merged_case_sensitive(self, httpbin):
        s = requests.Session()
        s.params['foo'] = 'bar'
        r = s.get(httpbin('get'), params={'FOO': 'bar'})
        assert r.json()['args'] == {'foo': 'bar', 'FOO': 'bar'}

    def test_long_authinfo_in_url(self):
        url = 'http://{0}:{1}@{2}:9000/path?query#frag'.format(
            'E8A3BE87-9E3F-4620-8858-95478E385B5B',
            'EA770032-DA4D-4D84-8CE9-29C6D910BF1E',
            'exactly-------------sixty-----------three------------characters',
        )
        r = requests.Request('GET', url).prepare()
        assert r.url == url

    def test_header_keys_are_native(self, httpbin):
        headers = {u('unicode'): 'blah', 'byte'.encode('ascii'): 'blah'}
        r = requests.Request('GET', httpbin('get'), headers=headers)
        p = r.prepare()

        # This is testing that they are builtin strings. A bit weird, but there
        # we go.
        assert 'unicode' in p.headers.keys()
        assert 'byte' in p.headers.keys()

    def test_can_send_nonstring_objects_with_files(self, httpbin):
        data = {'a': 0.0}
        files = {'b': 'foo'}
        r = requests.Request('POST', httpbin('post'), data=data, files=files)
        p = r.prepare()

        assert 'multipart/form-data' in p.headers['Content-Type']

    def test_can_send_bytes_bytearray_objects_with_files(self, httpbin):
        # Test bytes:
        data = {'a': 'this is a string'}
        files = {'b': b'foo'}
        r = requests.Request('POST', httpbin('post'), data=data, files=files)
        p = r.prepare()
        assert 'multipart/form-data' in p.headers['Content-Type']
        # Test bytearrays:
        files = {'b': bytearray(b'foo')}
        r = requests.Request('POST', httpbin('post'), data=data, files=files)
        p = r.prepare()
        assert 'multipart/form-data' in p.headers['Content-Type']

    def test_can_send_file_object_with_non_string_filename(self, httpbin):
        f = io.BytesIO()
        f.name = 2
        r = requests.Request('POST', httpbin('post'), files={'f': f})
        p = r.prepare()

        assert 'multipart/form-data' in p.headers['Content-Type']

    def test_autoset_header_values_are_native(self, httpbin):
        data = 'this is a string'
        length = '16'
        req = requests.Request('POST', httpbin('post'), data=data)
        p = req.prepare()

        assert p.headers['Content-Length'] == length

    def test_nonhttp_schemes_dont_check_URLs(self):
        test_urls = (
            'data:image/gif;base64,R0lGODlhAQABAHAAACH5BAUAAAAALAAAAAABAAEAAAICRAEAOw==',
            'file:///etc/passwd',
            'magnet:?xt=urn:btih:be08f00302bc2d1d3cfa3af02024fa647a271431',
        )
        for test_url in test_urls:
            req = requests.Request('GET', test_url)
            preq = req.prepare()
            assert test_url == preq.url

    def test_auth_is_stripped_on_redirect_off_host(self, httpbin):
        r = requests.get(
            httpbin('redirect-to'),
            params={'url': 'http://www.google.co.uk'},
            auth=('user', 'pass'),
        )
        assert r.history[0].request.headers['Authorization']
        assert not r.request.headers.get('Authorization', '')

    def test_auth_is_retained_for_redirect_on_host(self, httpbin):
        r = requests.get(httpbin('redirect/1'), auth=('user', 'pass'))
        h1 = r.history[0].request.headers['Authorization']
        h2 = r.request.headers['Authorization']

        assert h1 == h2

    def test_manual_redirect_with_partial_body_read(self, httpbin):
        s = requests.Session()
        r1 = s.get(httpbin('redirect/2'), allow_redirects=False, stream=True)
        assert r1.is_redirect
        rg = s.resolve_redirects(r1, r1.request, stream=True)

        # read only the first eight bytes of the response body,
        # then follow the redirect
        r1.iter_content(8)
        r2 = next(rg)
        assert r2.is_redirect

        # read all of the response via iter_content,
        # then follow the redirect
        for _ in r2.iter_content():
            pass
        r3 = next(rg)
        assert not r3.is_redirect

    def _patch_adapter_gzipped_redirect(self, session, url):
        adapter = session.get_adapter(url=url)
        org_build_response = adapter.build_response
        self._patched_response = False

        def build_response(*args, **kwargs):
            resp = org_build_response(*args, **kwargs)
            if not self._patched_response:
                resp.raw.headers['content-encoding'] = 'gzip'
                self._patched_response = True
            return resp

        adapter.build_response = build_response

    def test_redirect_with_wrong_gzipped_header(self, httpbin):
        s = requests.Session()
        url = httpbin('redirect/1')
        self._patch_adapter_gzipped_redirect(s, url)
        s.get(url)

    def test_basic_auth_str_is_always_native(self):
        s = _basic_auth_str("test", "test")
        assert isinstance(s, builtin_str)
        assert s == "Basic dGVzdDp0ZXN0"

    def test_requests_history_is_saved(self, httpbin):
        r = requests.get(httpbin('redirect/5'))
        total = r.history[-1].history
        i = 0
        for item in r.history:
            assert item.history == total[0:i]
            i = i + 1

    def test_json_param_post_content_type_works(self, httpbin):
        r = requests.post(
            httpbin('post'),
            json={'life': 42}
        )
        assert r.status_code == 200
        assert 'application/json' in r.request.headers['Content-Type']
        assert {'life': 42} == r.json()['json']

    def test_json_param_post_should_not_override_data_param(self, httpbin):
        r = requests.Request(method='POST', url=httpbin('post'),
                             data={'stuff': 'elixr'},
                             json={'music': 'flute'})
        prep = r.prepare()
        assert 'stuff=elixr' == prep.body

    def test_response_iter_lines(self, httpbin):
        r = requests.get(httpbin('stream/4'), stream=True)
        assert r.status_code == 200

        it = r.iter_lines()
        next(it)
        assert len(list(it)) == 3

    def test_unconsumed_session_response_closes_connection(self, httpbin):
        s = requests.session()

        with contextlib.closing(s.get(httpbin('stream/4'), stream=True)) as response:
            pass

        assert response._content_consumed is False
        assert response.raw.closed

    @pytest.mark.xfail
    def test_response_iter_lines_reentrant(self, httpbin):
        """Response.iter_lines() is not reentrant safe"""
        r = requests.get(httpbin('stream/4'), stream=True)
        assert r.status_code == 200

        next(r.iter_lines())
        assert len(list(r.iter_lines())) == 3


class TestContentEncodingDetection(unittest.TestCase):

    def test_none(self):
        encodings = requests.utils.get_encodings_from_content('')
        assert not len(encodings)

    def test_html_charset(self):
        """HTML5 meta charset attribute"""
    
```


# The last commit

```
6e65c2e SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: make test
# This runs all of the tests. To run an individual test, run py.test with
# the -k flag, like "py.test -k test_path_is_not_double_encoded"
py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed
collected 168 items

test_requests.py ...EE.....EEEEEEEEEEEEEEEEEEEEEF..EEEEEEEEEEEEEEEEEEEEE [ 32%]
EEEEEEE........E..E.....E.EEE.EE.EEEEE.EEEE.EEEEEx...................... [ 75%]
.........................EEEEFFEE.....EE.                                [100%]

==================================== ERRORS ====================================
____________ ERROR at setup of TestRequests.test_no_content_length _____________
file /testbed/test_requests.py, line 121
      def test_no_content_length(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/test_requests.py, line 127
      def test_override_content_length(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable _______
file /testbed/test_requests.py, line 166
      def test_mixed_case_scheme_acceptable(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/test_requests.py, line 177
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/test_requests.py, line 186
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/test_requests.py, line 196
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/test_requests.py, line 204
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/test_requests.py, line 210
      def test_set_cookie_on_301(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/test_requests.py, line 216
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/test_requests.py, line 222
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/test_requests.py, line 235
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/test_requests.py, line 240
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/test_requests.py, line 246
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/test_requests.py, line 254
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/test_requests.py, line 260
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/test_requests.py, line 271
      def test_param_cookiejar_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/test_requests.py, line 279
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/test_requests.py, line 285
      def test_history_is_always_a_list(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/test_requests.py, line 295
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_user_agent_transfers ___________
file /testbed/test_requests.py, line 303
      def test_user_agent_transfers(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/test_requests.py, line 319
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/test_requests.py, line 323
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/test_requests.py, line 327
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/test_requests.py, line 357
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/test_requests.py, line 390
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/test_requests.py, line 406
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/test_requests.py, line 415
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/test_requests.py, line 422
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/test_requests.py, line 433
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/test_requests.py, line 449
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/test_requests.py, line 457
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/test_requests.py, line 475
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/test_requests.py, line 494
      def test_conflicting_post_params(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/test_requests.py, line 500
      def test_request_ok_set(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/test_requests.py, line 504
      def test_status_raising(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/test_requests.py, line 512
      def test_decompress_gzip(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestRequests.test_unicode_get ________________
file /testbed/test_requests.py, line 516
      def test_unicode_get(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/test_requests.py, line 524
      def test_unicode_header_name(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/test_requests.py, line 530
      def test_pyopenssl_redirect(self, httpsbin_url, httpbin_ca_bundle):
file /testbed/test_requests.py, line 62
  @pytest.fixture
  def httpsbin_url(httpbin_secure):
E       fixture 'httpbin_secure' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:62
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/test_requests.py, line 533
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/test_requests.py, line 539
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_unicode_multipart_post __________
file /testbed/test_requests.py, line 546
      def test_unicode_multipart_post(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/test_requests.py, line 567
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/test_requests.py, line 578
      def test_unicode_method_name(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/test_requests.py, line 584
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/test_requests.py, line 595
      def test_custom_content_type(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/test_requests.py, line 605
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/test_requests.py, line 612
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/test_requests.py, line 621
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/test_requests.py, line 631
      def test_prepared_request_hook(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/test_requests.py, line 645
      def test_prepared_from_session(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/test_requests.py, line 798
      def test_time_elapsed_blank(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/test_requests.py, line 837
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/test_requests.py, line 869
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/test_requests.py, line 884
      def test_session_pickling(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/test_requests.py, line 894
      def test_fixes_1329(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/test_requests.py, line 907
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/test_requests.py, line 952
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/test_requests.py, line 959
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/test_requests.py, line 974
      def test_header_keys_are_native(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_can_send_nonstring_objects_with_files ___
file /testbed/test_requests.py, line 984
      def test_can_send_nonstring_objects_with_files(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_bytes_bytearray_objects_with_files _
file /testbed/test_requests.py, line 992
      def test_can_send_bytes_bytearray_objects_with_files(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/test_requests.py, line 1005
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/test_requests.py, line 1013
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_stripped_on_redirect_off_host ___
file /testbed/test_requests.py, line 1032
      def test_auth_is_stripped_on_redirect_off_host(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/test_requests.py, line 1041
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/test_requests.py, line 1048
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/test_requests.py, line 1081
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/test_requests.py, line 1092
      def test_requests_history_is_saved(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/test_requests.py, line 1100
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/test_requests.py, line 1109
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/test_requests.py, line 1116
      def test_response_iter_lines(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/test_requests.py, line 1124
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/test_requests.py, line 1535
      def test_stream_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_invalid_timeout ______________
file /testbed/test_requests.py, line 1541
      def test_invalid_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_none_timeout ________________
file /testbed/test_requests.py, line 1550
      def test_none_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_read_timeout ________________
file /testbed/test_requests.py, line 1562
      def test_read_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/test_requests.py, line 1584
      def test_encoded_methods(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRedirects.test_requests_are_updated_each_time ______
file /testbed/test_requests.py, line 1635
      def test_requests_are_updated_each_time(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/test_requests.py, line 1717
  def test_urllib3_retries(httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/test_requests.py, line 1728
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
=================================== FAILURES ===================================
______________ TestRequests.test_connection_error_invalid_domain _______________

self = <test_requests.TestRequests object at 0x73ecf004e4f0>

    def test_connection_error_invalid_domain(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://doesnotexist.google.com")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:345: Failed
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x73ecf002df10>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1572: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x73ecf003a070>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1580: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:2
requests/packages/urllib3/_collections.py:2
  /testbed/requests/packages/urllib3/_collections.py:2: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

test_requests.py::TestRequests::test_invalid_url
  /testbed/requests/models.py:168: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

test_requests.py::TestContentEncodingDetection::test_html4_pragma
test_requests.py::TestContentEncodingDetection::test_html_charset
test_requests.py::TestContentEncodingDetection::test_none
test_requests.py::TestContentEncodingDetection::test_precedence
test_requests.py::TestContentEncodingDetection::test_xhtml_pragma
test_requests.py::TestContentEncodingDetection::test_xml
  /testbed/requests/utils.py:315: DeprecationWarning: In requests 3.0, get_encodings_from_content will be removed. For more information, please see the discussion on issue #2266. (This warning should only appear once.)
    warnings.warn((

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::TestRequests::test_connection_error_invalid_domain
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
ERROR test_requests.py::TestRequests::test_no_content_length
ERROR test_requests.py::TestRequests::test_override_content_length
ERROR test_requests.py::TestRequests::test_mixed_case_scheme_acceptable
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR test_requests.py::TestRequests::test_set_cookie_on_301
ERROR test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR test_requests.py::TestRequests::test_param_cookiejar_works
ERROR test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR test_requests.py::TestRequests::test_history_is_always_a_list
ERROR test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR test_requests.py::TestRequests::test_user_agent_transfers
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR test_requests.py::TestRequests::test_conflicting_post_params
ERROR test_requests.py::TestRequests::test_request_ok_set
ERROR test_requests.py::TestRequests::test_status_raising
ERROR test_requests.py::TestRequests::test_decompress_gzip
ERROR test_requests.py::TestRequests::test_unicode_get
ERROR test_requests.py::TestRequests::test_unicode_header_name
ERROR test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR test_requests.py::TestRequests::test_unicode_method_name
ERROR test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR test_requests.py::TestRequests::test_custom_content_type
ERROR test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR test_requests.py::TestRequests::test_prepared_request_hook
ERROR test_requests.py::TestRequests::test_prepared_from_session
ERROR test_requests.py::TestRequests::test_time_elapsed_blank
ERROR test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR test_requests.py::TestRequests::test_session_pickling
ERROR test_requests.py::TestRequests::test_fixes_1329
ERROR test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR test_requests.py::TestRequests::test_header_keys_are_native
ERROR test_requests.py::TestRequests::test_can_send_nonstring_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_bytes_bytearray_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR test_requests.py::TestRequests::test_auth_is_stripped_on_redirect_off_host
ERROR test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR test_requests.py::TestRequests::test_requests_history_is_saved
ERROR test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR test_requests.py::TestRequests::test_response_iter_lines
ERROR test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR test_requests.py::TestTimeout::test_stream_timeout
ERROR test_requests.py::TestTimeout::test_invalid_timeout
ERROR test_requests.py::TestTimeout::test_none_timeout
ERROR test_requests.py::TestTimeout::test_read_timeout
ERROR test_requests.py::TestTimeout::test_encoded_methods
ERROR test_requests.py::TestRedirects::test_requests_are_updated_each_time
ERROR test_requests.py::test_urllib3_retries
ERROR test_requests.py::test_urllib3_pool_connection_closed
======== 3 failed, 83 passed, 1 xfailed, 9 warnings, 81 errors in 0.67s ========
make: *** [Makefile:9: test] Error 1

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/models.py test_requests.py
changed: requests/models.py +4 -1
changed: test_requests.py +6 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/requests/models.py b/requests/models.py
index 9c624d3..4bcbc54 100644
--- a/requests/models.py
+++ b/requests/models.py
@@ -81,7 +81,7 @@ class RequestEncodingMixin(object):
         """
 
         if isinstance(data, (str, bytes)):
-            return to_native_string(data)
+            return data
         elif hasattr(data, 'read'):
             return data
         elif hasattr(data, '__iter__'):
@@ -385,6 +385,9 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
             if isinstance(fragment, str):
                 fragment = fragment.encode('utf-8')
 
+        if isinstance(params, (str, bytes)):
+            params = to_native_string(params)
+
         enc_params = self._encode_params(params)
         if enc_params:
             if query:
diff --git a/test_requests.py b/test_requests.py
index 137edc0..32b9384 100755
--- a/test_requests.py
+++ b/test_requests.py
@@ -157,6 +157,12 @@ class TestRequests(object):
                                    params=b'test=foo').prepare()
         assert request.url == 'http://example.com/?test=foo'
 
+    def test_binary_body_is_not_decoded(self):
+        body = u'ööö'.encode('utf-8')
+        request = requests.Request('PUT', 'http://example.com',
+                                   data=body).prepare()
+        assert request.body == body
+
     def test_mixed_case_scheme_acceptable(self, httpbin):
         s = requests.Session()
         s.proxies = getproxies()
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
check: make test
# This runs all of the tests. To run an individual test, run py.test with
# the -k flag, like "py.test -k test_path_is_not_double_encoded"
py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed
collected 168 items

test_requests.py ...EE.....EEEEEEEEEEEEEEEEEEEEEF..EEEEEEEEEEEEEEEEEEEEE [ 32%]
EEEEEEE........E..E.....E.EEE.EE.EEEEE.EEEE.EEEEEx...................... [ 75%]
.........................EEEEFFEE.....EE.                                [100%]

==================================== ERRORS ====================================
____________ ERROR at setup of TestRequests.test_no_content_length _____________
file /testbed/test_requests.py, line 121
      def test_no_content_length(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/test_requests.py, line 127
      def test_override_content_length(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable _______
file /testbed/test_requests.py, line 166
      def test_mixed_case_scheme_acceptable(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/test_requests.py, line 177
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/test_requests.py, line 186
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/test_requests.py, line 196
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/test_requests.py, line 204
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/test_requests.py, line 210
      def test_set_cookie_on_301(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/test_requests.py, line 216
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/test_requests.py, line 222
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/test_requests.py, line 235
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/test_requests.py, line 240
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/test_requests.py, line 246
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/test_requests.py, line 254
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/test_requests.py, line 260
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/test_requests.py, line 271
      def test_param_cookiejar_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/test_requests.py, line 279
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/test_requests.py, line 285
      def test_history_is_always_a_list(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/test_requests.py, line 295
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_user_agent_transfers ___________
file /testbed/test_requests.py, line 303
      def test_user_agent_transfers(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/test_requests.py, line 319
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/test_requests.py, line 323
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/test_requests.py, line 327
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/test_requests.py, line 357
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/test_requests.py, line 390
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/test_requests.py, line 406
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/test_requests.py, line 415
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/test_requests.py, line 422
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/test_requests.py, line 433
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/test_requests.py, line 449
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/test_requests.py, line 457
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/test_requests.py, line 475
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/test_requests.py, line 494
      def test_conflicting_post_params(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/test_requests.py, line 500
      def test_request_ok_set(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/test_requests.py, line 504
      def test_status_raising(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/test_requests.py, line 512
      def test_decompress_gzip(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestRequests.test_unicode_get ________________
file /testbed/test_requests.py, line 516
      def test_unicode_get(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/test_requests.py, line 524
      def test_unicode_header_name(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/test_requests.py, line 530
      def test_pyopenssl_redirect(self, httpsbin_url, httpbin_ca_bundle):
file /testbed/test_requests.py, line 62
  @pytest.fixture
  def httpsbin_url(httpbin_secure):
E       fixture 'httpbin_secure' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:62
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/test_requests.py, line 533
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/test_requests.py, line 539
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_unicode_multipart_post __________
file /testbed/test_requests.py, line 546
      def test_unicode_multipart_post(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/test_requests.py, line 567
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/test_requests.py, line 578
      def test_unicode_method_name(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/test_requests.py, line 584
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/test_requests.py, line 595
      def test_custom_content_type(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/test_requests.py, line 605
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/test_requests.py, line 612
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/test_requests.py, line 621
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/test_requests.py, line 631
      def test_prepared_request_hook(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/test_requests.py, line 645
      def test_prepared_from_session(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/test_requests.py, line 798
      def test_time_elapsed_blank(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/test_requests.py, line 837
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/test_requests.py, line 869
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/test_requests.py, line 884
      def test_session_pickling(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/test_requests.py, line 894
      def test_fixes_1329(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/test_requests.py, line 907
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/test_requests.py, line 952
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/test_requests.py, line 959
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/test_requests.py, line 974
      def test_header_keys_are_native(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_can_send_nonstring_objects_with_files ___
file /testbed/test_requests.py, line 984
      def test_can_send_nonstring_objects_with_files(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_bytes_bytearray_objects_with_files _
file /testbed/test_requests.py, line 992
      def test_can_send_bytes_bytearray_objects_with_files(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/test_requests.py, line 1005
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/test_requests.py, line 1013
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_stripped_on_redirect_off_host ___
file /testbed/test_requests.py, line 1032
      def test_auth_is_stripped_on_redirect_off_host(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/test_requests.py, line 1041
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/test_requests.py, line 1048
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/test_requests.py, line 1081
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/test_requests.py, line 1092
      def test_requests_history_is_saved(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/test_requests.py, line 1100
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/test_requests.py, line 1109
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/test_requests.py, line 1116
      def test_response_iter_lines(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/test_requests.py, line 1124
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/test_requests.py, line 1535
      def test_stream_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_invalid_timeout ______________
file /testbed/test_requests.py, line 1541
      def test_invalid_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_none_timeout ________________
file /testbed/test_requests.py, line 1550
      def test_none_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_read_timeout ________________
file /testbed/test_requests.py, line 1562
      def test_read_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/test_requests.py, line 1584
      def test_encoded_methods(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRedirects.test_requests_are_updated_each_time ______
file /testbed/test_requests.py, line 1635
      def test_requests_are_updated_each_time(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/test_requests.py, line 1717
  def test_urllib3_retries(httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/test_requests.py, line 1728
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
=================================== FAILURES ===================================
______________ TestRequests.test_connection_error_invalid_domain _______________

self = <test_requests.TestRequests object at 0x7728075e14f0>

    def test_connection_error_invalid_domain(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://doesnotexist.google.com")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:345: Failed
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x7728075c0f10>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1572: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x7728075cd070>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1580: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:2
requests/packages/urllib3/_collections.py:2
  /testbed/requests/packages/urllib3/_collections.py:2: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

test_requests.py::TestRequests::test_invalid_url
  /testbed/requests/models.py:168: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

test_requests.py::TestContentEncodingDetection::test_html4_pragma
test_requests.py::TestContentEncodingDetection::test_html_charset
test_requests.py::TestContentEncodingDetection::test_none
test_requests.py::TestContentEncodingDetection::test_precedence
test_requests.py::TestContentEncodingDetection::test_xhtml_pragma
test_requests.py::TestContentEncodingDetection::test_xml
  /testbed/requests/utils.py:315: DeprecationWarning: In requests 3.0, get_encodings_from_content will be removed. For more information, please see the discussion on issue #2266. (This warning should only appear once.)
    warnings.warn((

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::TestRequests::test_connection_error_invalid_domain
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
ERROR test_requests.py::TestRequests::test_no_content_length
ERROR test_requests.py::TestRequests::test_override_content_length
ERROR test_requests.py::TestRequests::test_mixed_case_scheme_acceptable
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR test_requests.py::TestRequests::test_set_cookie_on_301
ERROR test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR test_requests.py::TestRequests::test_param_cookiejar_works
ERROR test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR test_requests.py::TestRequests::test_history_is_always_a_list
ERROR test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR test_requests.py::TestRequests::test_user_agent_transfers
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR test_requests.py::TestRequests::test_conflicting_post_params
ERROR test_requests.py::TestRequests::test_request_ok_set
ERROR test_requests.py::TestRequests::test_status_raising
ERROR test_requests.py::TestRequests::test_decompress_gzip
ERROR test_requests.py::TestRequests::test_unicode_get
ERROR test_requests.py::TestRequests::test_unicode_header_name
ERROR test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR test_requests.py::TestRequests::test_unicode_method_name
ERROR test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR test_requests.py::TestRequests::test_custom_content_type
ERROR test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR test_requests.py::TestRequests::test_prepared_request_hook
ERROR test_requests.py::TestRequests::test_prepared_from_session
ERROR test_requests.py::TestRequests::test_time_elapsed_blank
ERROR test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR test_requests.py::TestRequests::test_session_pickling
ERROR test_requests.py::TestRequests::test_fixes_1329
ERROR test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR test_requests.py::TestRequests::test_header_keys_are_native
ERROR test_requests.py::TestRequests::test_can_send_nonstring_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_bytes_bytearray_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR test_requests.py::TestRequests::test_auth_is_stripped_on_redirect_off_host
ERROR test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR test_requests.py::TestRequests::test_requests_history_is_saved
ERROR test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR test_requests.py::TestRequests::test_response_iter_lines
ERROR test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR test_requests.py::TestTimeout::test_stream_timeout
ERROR test_requests.py::TestTimeout::test_invalid_timeout
ERROR test_requests.py::TestTimeout::test_none_timeout
ERROR test_requests.py::TestTimeout::test_read_timeout
ERROR test_requests.py::TestTimeout::test_encoded_methods
ERROR test_requests.py::TestRedirects::test_requests_are_updated_each_time
ERROR test_requests.py::test_urllib3_retries
ERROR test_requests.py::test_urllib3_pool_connection_closed
======== 3 failed, 83 passed, 1 xfailed, 9 warnings, 81 errors in 0.47s ========
make: *** [Makefile:9: test] Error 1

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/models.py test_requests.py
changed: requests/models.py +4 -1
changed: test_requests.py +6 -0
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
# Notes, run 2026-11-06T175715

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Request with binary payload fails due to calling to_native_string
Introduced with https://github.com/kennethreitz/requests/issues/2844

```
import requests
requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))
```

This works with 2.8.1, but not with 2.9.


# The files of the project

```
.gitignore
AUTHORS.rst
CONTRIBUTING.md
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
docs/community/recommended.rst
docs/community/release-process.rst
docs/community/support.rst
docs/community/updates.rst
docs/community/vulnerabilities.rst
docs/conf.py
docs/dev/authors.rst
docs/dev/contributing.rst
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
requests/packages/urllib3/contrib/appengine.py
requests/packages/urllib3/contrib/ntlmpool.py
requests/packages/urllib3/contrib/pyopenssl.py
requests/packages/urllib3/exceptions.py
requests/packages/urllib3/fields.py
requests/packages/urllib3/filepost.py
requests/packages/urllib3/packages/__init__.py
requests/packages/urllib3/packages/ordered_dict.py
requests/packages/urllib3/packages/six.py
requests/packages/urllib3/packages/ssl_match_hostname/.gitignore
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
6e65c2e SWE-bench


```

```diff

```


# CONTRIBUTING.md (the start)

```
# Contribution Guidelines

Before opening any issues or proposing any pull requests, please do the
following:

1. Read our [Contributor's Guide](http://docs.python-requests.org/en/latest/dev/contributing/).
2. Understand our [development philosophy](http://docs.python-requests.org/en/latest/dev/philosophy/).

To get the greatest chance of helpful responses, please also observe the
following additional notes.

## Questions

The GitHub issue tracker is for *bug reports* and *feature requests*. Please do
not use it to ask questions about how to use Requests. These questions should
instead be directed to [Stack Overflow](https://stackoverflow.com/). Make sure
that your question is tagged with the `python-requests` tag when asking it on
Stack Overflow, to ensure that it is answered promptly and accurately.

## Good Bug Reports

Please be aware of the following things when filing bug reports:

1. Avoid raising duplicate issues. *Please* use the GitHub issue search feature
   to check whether your bug report or feature request has been mentioned in
   the past. Duplicate bug reports and feature requests are a huge maintenance
   burden on the limited resources of the project. If it is clear from your
   report that you would have struggled to find the original, that's ok, but
   if searching for a selection of words in your issue title would have found
   the duplicate then the issue will likely be closed extremely abruptly.
2. When filing bug reports about exceptions or tracebacks, please include the
   *complete* traceback. Partial tracebacks, or just the exception text, are
   not helpful. Issues that do not contain complete tracebacks may be closed
   without warning.
3. Make sure you provide a suitable amount of information to work with. This
   means you should provide:

   - Guidance on **how to reproduce the issue**. Ideally, this should be a
     *small* code sample that can be run immediately by the maintainers.
     Failing that, let us know what you're doing, how often it happens, what
     environment you're using, etc. Be thorough: it prevents us needing to ask
     further questions.
   - Tell us **what you expected to happen**. When we run your example code,
     what are we expecting to happen? What does "success" look like for your
     code?
   - Tell us **what actually happens**. It's not helpful for you to say "it
     doesn't work" or "it fails". Tell us *how* it fails: do you get an
     exception? A hang? A non-200 status code? How was the actual result
     different from your expected result?
   - Tell us **what version of Requests you're using**, and
     **how you installed it**. Different versions of Requests behave
     differently and have different bugs, and some distributors of Requests
     ship patches on top of the code we supply.

   If you do not provide all of these things, it will take us much longer to
   fix your problem. If we ask you to clarify these and you never respond, we
   will close your issue without fixing it.

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
`make test`

## Scope
`requests/models.py`
`test_requests.py`

## Done when
- `requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))` completes without raising `UnicodeDecodeError`.
- The request body remains the original UTF-8 bytes, not decoded as ASCII.
- `to_native_string` is not applied to a `bytes` body in the request-body preparation path.

## Approach
Locate the `to_native_string` call in `PreparedRequest`’s body handling, preserve `bytes` unchanged, add a regression test for the reported call, and run the project test suite.

Candidate approaches:
1. In `requests/models.py`, change `_encode_params` so `str`/`bytes` data is returned as-is instead of passed through `to_native_string`. This is the minimal upstream-style fix and preserves binary payloads.
2. In `prepare_body`, guard the conversion with `if not isinstance(body, bytes): body = to_native_string(body)`. This fixes the immediate crash but still risks incorrect handling of non-ASCII text bodies.
3. Change `to_native_string` itself to return `bytes` unchanged. This is too broad because the helper is used for headers and other callers, so it risks unrelated behavior changes.
```

### `prompt.md`

````
Request with binary payload fails due to calling to_native_string
Introduced with https://github.com/kennethreitz/requests/issues/2844

```
import requests
requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))
```

This works with 2.8.1, but not with 2.9.
````

### `review.md`

```
verdict: PASS
The change removes `to_native_string` from the `bytes` body path in `_encode_params`, so the original UTF-8 bytes are preserved and no ASCII decode is attempted.
URL parameter handling is preserved by converting `str`/`bytes` params in `prepare_url` before `_encode_params`.
The added regression test checks that a binary body remains unchanged after preparation.
The `make test` failures shown are pre-existing environment/network/fixture issues, not introduced by this change; the new test is not among the failures.
No out-of-scope files were changed.
```

### `scope.txt`

```
scope: requests/models.py test_requests.py
changed: requests/models.py +4 -1
changed: test_requests.py +6 -0
```

### `task.md`

````
# Task

## Prompt

Request with binary payload fails due to calling to_native_string
Introduced with https://github.com/kennethreitz/requests/issues/2844

```
import requests
requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))
```

This works with 2.8.1, but not with 2.9.

## Deliverable

changes to this tree

## Check

`make test`

## Scope

`requests/models.py`
`test_requests.py`

## Done when

- `requests.put("http://httpbin.org/put", data=u"ööö".encode("utf-8"))` completes without raising `UnicodeDecodeError`.
- The request body remains the original UTF-8 bytes, not decoded as ASCII.
- `to_native_string` is not applied to a `bytes` body in the request-body preparation path.
````

### `test-output.log`

```
check: make test
# This runs all of the tests. To run an individual test, run py.test with
# the -k flag, like "py.test -k test_path_is_not_double_encoded"
py.test test_requests.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.4.4, pluggy-1.0.0
rootdir: /testbed
collected 168 items

test_requests.py ...EE.....EEEEEEEEEEEEEEEEEEEEEF..EEEEEEEEEEEEEEEEEEEEE [ 32%]
EEEEEEE........E..E.....E.EEE.EE.EEEEE.EEEE.EEEEEx...................... [ 75%]
.........................EEEEFFEE.....EE.                                [100%]

==================================== ERRORS ====================================
____________ ERROR at setup of TestRequests.test_no_content_length _____________
file /testbed/test_requests.py, line 121
      def test_no_content_length(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/test_requests.py, line 127
      def test_override_content_length(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable _______
file /testbed/test_requests.py, line 166
      def test_mixed_case_scheme_acceptable(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/test_requests.py, line 177
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/test_requests.py, line 186
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/test_requests.py, line 196
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/test_requests.py, line 204
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/test_requests.py, line 210
      def test_set_cookie_on_301(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/test_requests.py, line 216
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/test_requests.py, line 222
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/test_requests.py, line 235
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/test_requests.py, line 240
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/test_requests.py, line 246
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/test_requests.py, line 254
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/test_requests.py, line 260
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/test_requests.py, line 271
      def test_param_cookiejar_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/test_requests.py, line 279
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/test_requests.py, line 285
      def test_history_is_always_a_list(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/test_requests.py, line 295
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_user_agent_transfers ___________
file /testbed/test_requests.py, line 303
      def test_user_agent_transfers(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/test_requests.py, line 319
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/test_requests.py, line 323
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/test_requests.py, line 327
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/test_requests.py, line 357
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/test_requests.py, line 390
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/test_requests.py, line 406
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/test_requests.py, line 415
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/test_requests.py, line 422
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/test_requests.py, line 433
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/test_requests.py, line 449
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/test_requests.py, line 457
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/test_requests.py, line 475
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/test_requests.py, line 494
      def test_conflicting_post_params(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/test_requests.py, line 500
      def test_request_ok_set(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/test_requests.py, line 504
      def test_status_raising(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/test_requests.py, line 512
      def test_decompress_gzip(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestRequests.test_unicode_get ________________
file /testbed/test_requests.py, line 516
      def test_unicode_get(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/test_requests.py, line 524
      def test_unicode_header_name(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/test_requests.py, line 530
      def test_pyopenssl_redirect(self, httpsbin_url, httpbin_ca_bundle):
file /testbed/test_requests.py, line 62
  @pytest.fixture
  def httpsbin_url(httpbin_secure):
E       fixture 'httpbin_secure' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:62
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/test_requests.py, line 533
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/test_requests.py, line 539
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_unicode_multipart_post __________
file /testbed/test_requests.py, line 546
      def test_unicode_multipart_post(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/test_requests.py, line 567
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/test_requests.py, line 578
      def test_unicode_method_name(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/test_requests.py, line 584
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/test_requests.py, line 595
      def test_custom_content_type(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/test_requests.py, line 605
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/test_requests.py, line 612
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/test_requests.py, line 621
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/test_requests.py, line 631
      def test_prepared_request_hook(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/test_requests.py, line 645
      def test_prepared_from_session(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/test_requests.py, line 798
      def test_time_elapsed_blank(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/test_requests.py, line 837
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/test_requests.py, line 869
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/test_requests.py, line 884
      def test_session_pickling(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/test_requests.py, line 894
      def test_fixes_1329(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/test_requests.py, line 907
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/test_requests.py, line 952
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/test_requests.py, line 959
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/test_requests.py, line 974
      def test_header_keys_are_native(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_can_send_nonstring_objects_with_files ___
file /testbed/test_requests.py, line 984
      def test_can_send_nonstring_objects_with_files(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_bytes_bytearray_objects_with_files _
file /testbed/test_requests.py, line 992
      def test_can_send_bytes_bytearray_objects_with_files(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/test_requests.py, line 1005
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/test_requests.py, line 1013
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_stripped_on_redirect_off_host ___
file /testbed/test_requests.py, line 1032
      def test_auth_is_stripped_on_redirect_off_host(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/test_requests.py, line 1041
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/test_requests.py, line 1048
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/test_requests.py, line 1081
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/test_requests.py, line 1092
      def test_requests_history_is_saved(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/test_requests.py, line 1100
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/test_requests.py, line 1109
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/test_requests.py, line 1116
      def test_response_iter_lines(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/test_requests.py, line 1124
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/test_requests.py, line 1535
      def test_stream_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_invalid_timeout ______________
file /testbed/test_requests.py, line 1541
      def test_invalid_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_none_timeout ________________
file /testbed/test_requests.py, line 1550
      def test_none_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_______________ ERROR at setup of TestTimeout.test_read_timeout ________________
file /testbed/test_requests.py, line 1562
      def test_read_timeout(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/test_requests.py, line 1584
      def test_encoded_methods(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
_____ ERROR at setup of TestRedirects.test_requests_are_updated_each_time ______
file /testbed/test_requests.py, line 1635
      def test_requests_are_updated_each_time(self, httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/test_requests.py, line 1717
  def test_urllib3_retries(httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/test_requests.py, line 1728
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/test_requests.py, line 51
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpsbin_url, list_of_tuples, monkeypatch, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/test_requests.py:51
=================================== FAILURES ===================================
______________ TestRequests.test_connection_error_invalid_domain _______________

self = <test_requests.TestRequests object at 0x76a9986334f0>

    def test_connection_error_invalid_domain(self):
        """Connecting to an unknown domain should raise a ConnectionError"""
        with pytest.raises(ConnectionError):
>           requests.get("http://doesnotexist.google.com")
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

test_requests.py:345: Failed
_______________________ TestTimeout.test_connect_timeout _______________________

self = <test_requests.TestTimeout object at 0x76a998612f10>

    def test_connect_timeout(self):
        try:
            requests.get(TARPIT, timeout=(0.1, None))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1572: AssertionError
____________________ TestTimeout.test_total_timeout_connect ____________________

self = <test_requests.TestTimeout object at 0x76a998620070>

    def test_total_timeout_connect(self):
        try:
            requests.get(TARPIT, timeout=(0.1, 0.1))
>           assert False, "The connect() request should time out."
E           AssertionError: The connect() request should time out.
E           assert False

test_requests.py:1580: AssertionError
=============================== warnings summary ===============================
requests/packages/urllib3/_collections.py:2
requests/packages/urllib3/_collections.py:2
  /testbed/requests/packages/urllib3/_collections.py:2: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    from collections import Mapping, MutableMapping

test_requests.py::TestRequests::test_invalid_url
  /testbed/requests/models.py:168: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated since Python 3.3, and in 3.10 it will stop working
    if isinstance(hook, collections.Callable):

test_requests.py::TestContentEncodingDetection::test_html4_pragma
test_requests.py::TestContentEncodingDetection::test_html_charset
test_requests.py::TestContentEncodingDetection::test_none
test_requests.py::TestContentEncodingDetection::test_precedence
test_requests.py::TestContentEncodingDetection::test_xhtml_pragma
test_requests.py::TestContentEncodingDetection::test_xml
  /testbed/requests/utils.py:315: DeprecationWarning: In requests 3.0, get_encodings_from_content will be removed. For more information, please see the discussion on issue #2266. (This warning should only appear once.)
    warnings.warn((

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED test_requests.py::TestRequests::test_connection_error_invalid_domain
FAILED test_requests.py::TestTimeout::test_connect_timeout - AssertionError: ...
FAILED test_requests.py::TestTimeout::test_total_timeout_connect - AssertionE...
ERROR test_requests.py::TestRequests::test_no_content_length
ERROR test_requests.py::TestRequests::test_override_content_length
ERROR test_requests.py::TestRequests::test_mixed_case_scheme_acceptable
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR test_requests.py::TestRequests::test_set_cookie_on_301
ERROR test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR test_requests.py::TestRequests::test_param_cookiejar_works
ERROR test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR test_requests.py::TestRequests::test_history_is_always_a_list
ERROR test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR test_requests.py::TestRequests::test_user_agent_transfers
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR test_requests.py::TestRequests::test_conflicting_post_params
ERROR test_requests.py::TestRequests::test_request_ok_set
ERROR test_requests.py::TestRequests::test_status_raising
ERROR test_requests.py::TestRequests::test_decompress_gzip
ERROR test_requests.py::TestRequests::test_unicode_get
ERROR test_requests.py::TestRequests::test_unicode_header_name
ERROR test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post
ERROR test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR test_requests.py::TestRequests::test_unicode_method_name
ERROR test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR test_requests.py::TestRequests::test_custom_content_type
ERROR test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR test_requests.py::TestRequests::test_prepared_request_hook
ERROR test_requests.py::TestRequests::test_prepared_from_session
ERROR test_requests.py::TestRequests::test_time_elapsed_blank
ERROR test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR test_requests.py::TestRequests::test_session_pickling
ERROR test_requests.py::TestRequests::test_fixes_1329
ERROR test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR test_requests.py::TestRequests::test_header_keys_are_native
ERROR test_requests.py::TestRequests::test_can_send_nonstring_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_bytes_bytearray_objects_with_files
ERROR test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR test_requests.py::TestRequests::test_auth_is_stripped_on_redirect_off_host
ERROR test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR test_requests.py::TestRequests::test_requests_history_is_saved
ERROR test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR test_requests.py::TestRequests::test_response_iter_lines
ERROR test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR test_requests.py::TestTimeout::test_stream_timeout
ERROR test_requests.py::TestTimeout::test_invalid_timeout
ERROR test_requests.py::TestTimeout::test_none_timeout
ERROR test_requests.py::TestTimeout::test_read_timeout
ERROR test_requests.py::TestTimeout::test_encoded_methods
ERROR test_requests.py::TestRedirects::test_requests_are_updated_each_time
ERROR test_requests.py::test_urllib3_retries
ERROR test_requests.py::test_urllib3_pool_connection_closed
======== 3 failed, 83 passed, 1 xfailed, 9 warnings, 81 errors in 2.36s ========
make: *** [Makefile:9: test] Error 1

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/models.py test_requests.py
changed: requests/models.py +4 -1
changed: test_requests.py +6 -0
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
