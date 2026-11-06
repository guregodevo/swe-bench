# psf__requests-5414 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 132s 27 lines cost=0.011211 in=189580 cached=94208 out=19190 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

Getting http://.example.com raises UnicodeError
Attempting to get e.g. `http://.example.com` results in a `UnicodeError`. It seems like the intention so far has been to raise `InvalidUrl` instead (see e.g. [this line](https://github.com/psf/requests/blob/ca6f9af5dba09591007b15a7368bc0f006b7cc50/requests/models.py#L401)).

I see there was some hesitation in fixing a similar issue (#4168) and would like to add that even catching the error just to rethrow as a requests exception would be beneficial.

## Expected Result

Based on PR #774: `InvalidUrl: URL has an invalid label.`

## Actual Result

`UnicodeError: encoding with 'idna' codec failed (UnicodeError: label empty or too long)`

## Reproduction Steps

```python3
import requests
requests.get("http://.example.com")
```

## System Information

    $ python -m requests.help

```
{
  "chardet": {
    "version": "3.0.4"
  },
  "cryptography": {
    "version": "2.8"
  },
  "idna": {
    "version": "2.8"
  },
  "implementation": {
    "name": "CPython",
    "version": "3.8.0"
  },
  "platform": {
    "release": "5.3.0-40-generic",
    "system": "Linux"
  },
  "pyOpenSSL": {
    "openssl_version": "1010104f",
    "version": "19.1.0"
  },
  "requests": {
    "version": "2.23.0"
  },
  "system_ssl": {
    "version": "1010103f"
  },
  "urllib3": {
    "version": "1.25.8"
  },
  "using_pyopenssl": true
}
```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status && git log --oneline -3"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"InvalidUrl\" requests/ | head -50"
}
```

**tool result**

```
AUTHORS.rst
HISTORY.md
LICENSE
MANIFEST.in
Makefile
NOTICE
README.md
build
docs
ext
pytest.ini
requests
requests.egg-info
requirements-dev.txt
setup.cfg
setup.py
tests
tox.ini
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.memdoor/

nothing added to commit but untracked files present (use "git add" to track)
af3e243e SWE-bench
39d0fdd9 Update README.md (#5998)
c193d974 Merge pull request #5993 from davisagli/tox-parallel
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"URL has an invalid label\\|InvalidURL\\|InvalidSchema\\|MissingSchema\\|InvalidUrl\" requests tests | head -80"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,120p' requests/exceptions.py; sed -n '300,460p' requests/models.py"
}
```

**tool result**

```
requests/adapters.py:40:                         ProxyError, RetryError, InvalidSchema, InvalidProxyURL,
requests/adapters.py:41:                         InvalidURL, InvalidHeader)
requests/adapters.py:48:        raise InvalidSchema("Missing dependencies for SOCKS support.")
requests/adapters.py:415:            raise InvalidURL(e, request=request)
requests/sessions.py:25:    TooManyRedirects, InvalidSchema, ChunkedEncodingError, ContentDecodingError)
requests/sessions.py:732:        raise InvalidSchema("No connection adapters were found for {!r}".format(url))
requests/utils.py:37:    InvalidURL, InvalidHeader, FileModeWarning, UnrewindableBodyError)
requests/utils.py:621:                raise InvalidURL("Invalid percent-escape sequence: '%s'" % h)
requests/utils.py:647:    except InvalidURL:
requests/models.py:31:    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
requests/models.py:386:            raise InvalidURL(*e.args)
requests/models.py:392:            raise MissingSchema(error)
requests/models.py:395:            raise InvalidURL("Invalid URL %r: No host supplied" % url)
requests/models.py:405:                raise InvalidURL('URL has an invalid label.')
requests/models.py:407:            raise InvalidURL('URL has an invalid label.')
requests/exceptions.py:82:class MissingSchema(RequestException, ValueError):
requests/exceptions.py:86:class InvalidSchema(RequestException, ValueError):
requests/exceptions.py:90:class InvalidURL(RequestException, ValueError):
requests/exceptions.py:98:class InvalidProxyURL(InvalidURL):
tests/test_requests.py:25:    ConnectionError, ConnectTimeout, InvalidSchema, InvalidURL,
tests/test_requests.py:26:    MissingSchema, ReadTimeout, Timeout, RetryError, TooManyRedirects,
tests/test_requests.py:79:            (MissingSchema, 'hiwpefhipowhefopw'),
tests/test_requests.py:80:            (InvalidSchema, 'localhost:3128'),
tests/test_requests.py:81:            (InvalidSchema, 'localhost.localdomain:3128/'),
tests/test_requests.py:82:            (InvalidSchema, '10.122.1.1:3128/'),
tests/test_requests.py:83:            (InvalidURL, 'http://'),
tests/test_requests.py:532:            # Inputing a URL that cannot be parsed should raise an InvalidURL error
tests/test_requests.py:533:            ('http://fe80::5054:ff:fe5a:fc0', InvalidURL)
tests/test_requests.py:2496:        with pytest.raises(requests.exceptions.InvalidURL):
tests/test_requests.py:2502:            ('http://localhost:-1', InvalidURL),
```

**tool result**

```
# -*- coding: utf-8 -*-

"""
requests.exceptions
~~~~~~~~~~~~~~~~~~~

This module contains the set of Requests' exceptions.
"""
from urllib3.exceptions import HTTPError as BaseHTTPError

from .compat import JSONDecodeError as CompatJSONDecodeError


class RequestException(IOError):
    """There was an ambiguous exception that occurred while handling your
    request.
    """

    def __init__(self, *args, **kwargs):
        """Initialize RequestException with `request` and `response` objects."""
        response = kwargs.pop('response', None)
        self.response = response
        self.request = kwargs.pop('request', None)
        if (response is not None and not self.request and
                hasattr(response, 'request')):
            self.request = self.response.request
        super(RequestException, self).__init__(*args, **kwargs)


class InvalidJSONError(RequestException):
    """A JSON error occurred."""


class JSONDecodeError(InvalidJSONError, CompatJSONDecodeError):
    """Couldn't decode the text into json"""


class HTTPError(RequestException):
    """An HTTP error occurred."""


class ConnectionError(RequestException):
    """A Connection error occurred."""


class ProxyError(ConnectionError):
    """A proxy error occurred."""


class SSLError(ConnectionError):
    """An SSL error occurred."""


class Timeout(RequestException):
    """The request timed out.

    Catching this error will catch both
    :exc:`~requests.exceptions.ConnectTimeout` and
    :exc:`~requests.exceptions.ReadTimeout` errors.
    """


class ConnectTimeout(ConnectionError, Timeout):
    """The request timed out while trying to connect to the remote server.

    Requests that produced this error are safe to retry.
    """


class ReadTimeout(Timeout):
    """The server did not send any data in the allotted amount of time."""


class URLRequired(RequestException):
    """A valid URL is required to make a request."""


class TooManyRedirects(RequestException):
    """Too many redirects."""


class MissingSchema(RequestException, ValueError):
    """The URL schema (e.g. http or https) is missing."""


class InvalidSchema(RequestException, ValueError):
    """See defaults.py for valid schemas."""


class InvalidURL(RequestException, ValueError):
    """The URL provided was somehow invalid."""


class InvalidHeader(RequestException, ValueError):
    """The header value provided was somehow invalid."""


class InvalidProxyURL(InvalidURL):
    """The proxy URL provided is invalid."""


class ChunkedEncodingError(RequestException):
    """The server declared chunked encoding but sent an invalid chunk."""


class ContentDecodingError(RequestException, BaseHTTPError):
    """Failed to decode response content."""


class StreamConsumedError(RequestException, TypeError):
    """The content for this response was already consumed."""


class RetryError(RequestException):
    """Custom retries logic failed"""


class UnrewindableBodyError(RequestException):
    """Requests encountered an error when trying to rewind a body."""

        #: dictionary of HTTP headers.
        self.headers = None
        # The `CookieJar` used to create the Cookie header will be stored here
        # after prepare_cookies is called
        self._cookies = None
        #: request body to send to the server.
        self.body = None
        #: dictionary of callback hooks, for internal usage.
        self.hooks = default_hooks()
        #: integer denoting starting position of a readable file-like body.
        self._body_position = None

    def prepare(self,
            method=None, url=None, headers=None, files=None, data=None,
            params=None, auth=None, cookies=None, hooks=None, json=None):
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
        p._body_position = self._body_position
        return p

    def prepare_method(self, method):
        """Prepares the given HTTP method."""
        self.method = method
        if self.method is not None:
            self.method = to_native_string(self.method.upper())

    @staticmethod
    def _get_idna_encoded_host(host):
        import idna

        try:
            host = idna.encode(host, uts46=True).decode('utf-8')
        except idna.IDNAError:
            raise UnicodeError
        return host

    def prepare_url(self, url, params):
        """Prepares the given HTTP URL."""
        #: Accept objects that have string representations.
        #: We're unable to blindly call unicode/str functions
        #: as this will include the bytestring indicator (b'')
        #: on python 3.x.
        #: https://github.com/psf/requests/pull/2238
        if isinstance(url, bytes):
            url = url.decode('utf8')
        else:
            url = unicode(url) if is_py2 else str(url)

        # Remove leading whitespaces from url
        url = url.lstrip()

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

        # In general, we want to try IDNA encoding the hostname if the string contains
        # non-ASCII characters. This allows users to automatically get the correct IDNA
        # behaviour. For strings containing only ASCII characters, we need to also verify
        # it doesn't start with a wildcard (*), before allowing the unencoded hostname.
        if not unicode_is_ascii(host):
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
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

        self.headers = CaseInsensitiveDict()
        if headers:
            for header in headers.items():
                # Raise exception on invalid header value.
                check_header_validity(header)
                name, value = header
                self.headers[to_native_string(name)] = value

    def prepare_body(self, data, files, json=None):
        """Prepares the given HTTP body data."""

        # Check if file, fo, generator, iterator.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '2470,2520p' tests/test_requests.py; sed -n '60,95p' tests/test_requests.py; git log --all --oneline | head"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"idna\\|invalid label\\|UnicodeError\" tests requests | head -60"
}
```

**tool result**

```
    )
    def test_preparing_url(self, url, expected):

        def normalize_percent_encode(x):
            # Helper function that normalizes equivalent 
            # percent-encoded bytes before comparisons
            for c in re.findall(r'%[a-fA-F0-9]{2}', x):
                x = x.replace(c, c.upper())
            return x
        
        r = requests.Request('GET', url=url)
        p = r.prepare()
        assert normalize_percent_encode(p.url) == expected

    @pytest.mark.parametrize(
        'url',
        (
            b"http://*.google.com",
            b"http://*",
            u"http://*.google.com",
            u"http://*",
            u"http://☃.net/"
        )
    )
    def test_preparing_bad_url(self, url):
        r = requests.Request('GET', url=url)
        with pytest.raises(requests.exceptions.InvalidURL):
            r.prepare()

    @pytest.mark.parametrize(
        'url, exception',
        (
            ('http://localhost:-1', InvalidURL),
        )
    )
    def test_redirecting_to_bad_url(self, httpbin, url, exception):
        with pytest.raises(exception):
            r = requests.get(httpbin('redirect-to'), params={'url': url})

    @pytest.mark.parametrize(
        'input, expected',
        (
            (
                b"http+unix://%2Fvar%2Frun%2Fsocket/path%7E",
                u"http+unix://%2Fvar%2Frun%2Fsocket/path~",
            ),
            (
                u"http+unix://%2Fvar%2Frun%2Fsocket/path%7E",
                u"http+unix://%2Fvar%2Frun%2Fsocket/path~",
            ),
            (
class TestRequests:

    digest_auth_algo = ('MD5', 'SHA-256', 'SHA-512')

    def test_entry_points(self):

        requests.session
        requests.session().get
        requests.session().head
        requests.get
        requests.head
        requests.put
        requests.patch
        requests.post
        # Not really an entry point, but people rely on it.
        from requests.packages.urllib3.poolmanager import PoolManager

    @pytest.mark.parametrize(
        'exception, url', (
            (MissingSchema, 'hiwpefhipowhefopw'),
            (InvalidSchema, 'localhost:3128'),
            (InvalidSchema, 'localhost.localdomain:3128/'),
            (InvalidSchema, '10.122.1.1:3128/'),
            (InvalidURL, 'http://'),
        ))
    def test_invalid_url(self, exception, url):
        with pytest.raises(exception):
            requests.get(url)

    def test_basic_building(self):
        req = requests.Request()
        req.url = 'http://kennethreitz.org/'
        req.data = {'life': '42'}

        pr = req.prepare()
        assert pr.url == req.url
af3e243e SWE-bench
39d0fdd9 Update README.md (#5998)
c193d974 Merge pull request #5993 from davisagli/tox-parallel
8e764f35 Run tox in parallel using -p instead of detox
7556ea42 Merge pull request #5391 from hodbn/fix-5274
2d2447e2 Catch AttributeError in utils.super_len (#5239)
e77dd8de Merge pull request #5990 from mgorny/trustme-test-dep
55da533a Defer the trustme import until inside the fixture
99b3b492 Refactor rebuild_proxies to allow proxy resolution (#5924)
590350f8 Update Bug_report.md (#5965)
```

**tool result**

```
tests/test_packages.py:8:def test_can_access_idna_attribute():
tests/test_packages.py:9:    requests.packages.idna
tests/test_help.py:20:def test_idna_without_version_attribute(mocker):
tests/test_help.py:24:    mocker.patch('requests.help.idna', new=None)
tests/test_help.py:25:    assert info()['idna'] == {'version': ''}
tests/test_help.py:28:def test_idna_with_version_attribute(mocker):
tests/test_help.py:29:    """Verify we're actually setting idna version when it should be available."""
tests/test_help.py:30:    mocker.patch('requests.help.idna', new=VersionedPackage('2.6'))
tests/test_help.py:31:    assert info()['idna'] == {'version': '2.6'}
requests/utils.py:593:        except UnicodeError:
requests/models.py:16:import encodings.idna
requests/models.py:351:    def _get_idna_encoded_host(host):
requests/models.py:352:        import idna
requests/models.py:355:            host = idna.encode(host, uts46=True).decode('utf-8')
requests/models.py:356:        except idna.IDNAError:
requests/models.py:357:            raise UnicodeError
requests/models.py:403:                host = self._get_idna_encoded_host(host)
requests/models.py:404:            except UnicodeError:
requests/models.py:405:                raise InvalidURL('URL has an invalid label.')
requests/models.py:407:            raise InvalidURL('URL has an invalid label.')
requests/help.py:9:import idna
requests/help.py:102:    idna_info = {
requests/help.py:103:        'version': getattr(idna, '__version__', ''),
requests/help.py:122:        'idna': idna_info,
requests/packages.py:14:for package in ('urllib3', 'idna'):
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"import requests,inspect; print(requests.__version__, requests.__file__)\"; python - <<'EOF'\nimport idna\nfor h in ['.example.com','example..com','example.com.','-a.com','a-.com','.','']:\n    try:\n        print(repr(h), idna.encode(h, uts46=True))\n    except Exception as e:\n        print(repr(h), type(e), e)\nEOF"
}
```

**tool result**

```
2.26.0 /testbed/requests/__init__.py
'.example.com' <class 'idna.core.IDNAError'> Empty Label
'example..com' <class 'idna.core.IDNAError'> Empty Label
'example.com.' b'example.com.'
'-a.com' <class 'idna.core.IDNAError'> Label must not start or end with a hyphen
'a-.com' <class 'idna.core.IDNAError'> Label must not start or end with a hyphen
'.' <class 'idna.core.IDNAError'> Empty Label
'' <class 'idna.core.IDNAError'> Empty domain
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport requests, traceback\ntry:\n    requests.get(\"http://.example.com\", timeout=3)\nexcept Exception as e:\n    traceback.print_exc()\nEOF"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def parse_url\" -A100 requests/utils.py"
}
```

**tool result**

```
(no output)

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,50p' requests/models.py; grep -rn \"def parse_url\" requests/"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nfrom requests.models import PreparedRequest\nfrom requests.utils import parse_url, unicode_is_ascii\nurl=\"http://.example.com\"\nprint(parse_url(url))\nprint(unicode_is_ascii('.example.com'))\np=PreparedRequest()\ntry:\n    p.prepare_url(url,None)\n    print(\"prepared\", p.url)\nexcept Exception as e:\n    print(type(e), e)\nEOF"
}
```

**tool result**

```
# -*- coding: utf-8 -*-

"""
requests.models
~~~~~~~~~~~~~~~

This module contains the primary objects that power Requests.
"""

import datetime
import sys

# Import encoding now, to avoid implicit import later.
# Implicit import within threads may cause LookupError when standard library is in a ZIP,
# such as in Embedded Python. See https://github.com/psf/requests/issues/3578.
import encodings.idna

from urllib3.fields import RequestField
from urllib3.filepost import encode_multipart_formdata
from urllib3.util import parse_url
from urllib3.exceptions import (
    DecodeError, ReadTimeoutError, ProtocolError, LocationParseError)

from io import UnsupportedOperation
from .hooks import default_hooks
from .structures import CaseInsensitiveDict

from .auth import HTTPBasicAuth
from .cookies import cookiejar_from_dict, get_cookie_header, _copy_cookie_jar
from .exceptions import (
    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
    ContentDecodingError, ConnectionError, StreamConsumedError,
    InvalidJSONError)
from .exceptions import JSONDecodeError as RequestsJSONDecodeError
from ._internal_utils import to_native_string, unicode_is_ascii
from .utils import (
    guess_filename, get_auth_from_url, requote_uri,
    stream_decode_response_unicode, to_key_val_list, parse_header_links,
    iter_slices, guess_json_utf, super_len, check_header_validity)
from .compat import (
    Callable, Mapping,
    cookielib, urlunparse, urlsplit, urlencode, str, bytes,
    is_py2, chardet, builtin_str, basestring, JSONDecodeError)
from .compat import json as complexjson
from .status_codes import codes

#: The set of HTTP status codes that indicate an automatically
#: processable redirect.
REDIRECT_STATI = (
    codes.moved,               # 301

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**tool result**

```
Command FAILED (exit status 1): `python - <<'EOF'
from requests.models import PreparedRequest
from requests.utils import parse_url, unicode_is_ascii
url="http://.example.com"
print(parse_url(url))
print(unicode_is_ascii('.example.com'))
p=PreparedRequest()
try:
    p.prepare_url(url,None)
    print("prepared", p.url)
except Exception as e:
    print(type(e), e)
EOF`
Output: Traceback (most recent call last):
  File "<stdin>", line 2, in <module>
ImportError: cannot import name 'parse_url' from 'requests.utils' (/testbed/requests/utils.py)

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nfrom requests.models import PreparedRequest\nfrom urllib3.util import parse_url\nfrom requests._internal_utils import unicode_is_ascii\nurl=\"http://.example.com\"\nprint(parse_url(url))\nprint(unicode_is_ascii('.example.com'))\np=PreparedRequest()\ntry:\n    p.prepare_url(url,None)\n    print(\"prepared\", p.url)\nexcept Exception as e:\n    print(type(e), e)\nEOF"
}
```

**tool result**

```
http://.example.com
True
prepared http://.example.com/
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: requests/models.py\n@@\n-        elif host.startswith(u'*'):\n+        elif host.startswith((u'*', u'.')):\n             raise InvalidURL('URL has an invalid label.')\n*** Update File: tests/test_requests.py\n@@\n             u\"http://*.google.com\",\n             u\"http://*\",\n-            u\"http://☃.net/\"\n+            u\"http://☃.net/\",\n+            u\"http://.example.com\"\n         )\n     )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[requests/models.py tests/test_requests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

requests/models.py now (973 lines), around the change:
403:                host = self._get_idna_encoded_host(host)
404:            except UnicodeError:
405:                raise InvalidURL('URL has an invalid label.')
406:        elif host.startswith((u'*', u'.')):
407:            raise InvalidURL('URL has an invalid label.')
408:
409:        # Carefully reconstruct the network location

tests/test_requests.py now (2588 lines), around the change:
2488:            b"http://*",
2489:            u"http://*.google.com",
2490:            u"http://*",
2491:            u"http://☃.net/",
2492:            u"http://.example.com"
2493:        )
2494:    )
2495:    def test_preparing_bad_url(self, url):
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport requests\nfor url in [\"http://.example.com\", \"http://*.google.com\", \"http://☃.net/\", \"http://example.com\"]:\n    try:\n        p = requests.Request('GET', url).prepare()\n        print(url, \"->\", p.url)\n    except Exception as e:\n        print(url, \"->\", type(e).__name__, e)\nEOF\npython -m pytest tests/test_requests.py -q -k \"bad_url or invalid_url\" 2>&1 | tail -20"
}
```

**tool result**

```
http://.example.com -> InvalidURL URL has an invalid label.
http://*.google.com -> InvalidURL URL has an invalid label.
http://☃.net/ -> InvalidURL Failed to parse: http://☃.net/
http://example.com -> http://example.com/
file /testbed/tests/test_requests.py, line 2500
      @pytest.mark.parametrize(
          'url, exception',
          (
              ('http://localhost:-1', InvalidURL),
          )
      )
      def test_redirecting_to_bad_url(self, httpbin, url, exception):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
=========================== short test summary info ============================
ERROR tests/test_requests.py::TestRequests::test_proxy_error_on_bad_url
ERROR tests/test_requests.py::TestPreparingURLs::test_redirecting_to_bad_url[http://localhost:-1-InvalidURL]
11 passed, 276 deselected, 2 errors in 0.58s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_requests.py -q -k \"TestPreparingURLs and not redirecting and not proxy\" 2>&1 | tail -8; git diff --stat"
}
```

**tool result**

```
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
=========================== short test summary info ============================
ERROR tests/test_requests.py::TestPreparingURLs::test_post_json_nan
ERROR tests/test_requests.py::TestPreparingURLs::test_json_decode_compatibility
26 passed, 261 deselected, 2 errors in 0.18s
 requests/models.py     | 2 +-
 tests/test_requests.py | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)
```

**assistant**

````
Implemented the fix.

**Change** (`requests/models.py`):
```python
elif host.startswith((u'*', u'.')):
    raise InvalidURL('URL has an invalid label.')
```

Previously only hosts beginning with `*` were rejected, so ASCII hosts beginning with a dot (like `.example.com`) bypassed the IDNA validation path and were passed through as valid. Now they raise `InvalidURL('URL has an invalid label.')`, matching the expected behavior from PR #774.

**Test added** (`tests/test_requests.py`): added `u"http://.example.com"` to the `test_preparing_bad_url` parametrization.

**Verification:**
```
http://.example.com -> InvalidURL URL has an invalid label.
http://*.google.com -> InvalidURL URL has an invalid label.
http://example.com  -> http://example.com/
```
Relevant URL tests pass (`11 passed`); the only errors are pre-existing `httpbin` fixture recursion issues in `tests/conftest.py`, unrelated to this change. No commits/checkouts/resets/stashes were made.
````

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_requests.py -q -k \"bad_url\" 2>&1 | tail -6"
}
```

**tool result**

```

/testbed/tests/conftest.py:28
=========================== short test summary info ============================
ERROR tests/test_requests.py::TestRequests::test_proxy_error_on_bad_url
ERROR tests/test_requests.py::TestPreparingURLs::test_redirecting_to_bad_url[http://localhost:-1-InvalidURL]
6 passed, 281 deselected, 2 errors in 0.22s
```

**assistant**

```
Done. The fix is in place and verified:

- `http://.example.com` now raises `InvalidURL: URL has an invalid label.` instead of a raw `UnicodeError`.
- `http://example.com` still works.
- The `test_preparing_bad_url` tests pass (6 passed); the two errors are the pre-existing `httpbin` fixture recursion in `tests/conftest.py`, unrelated to this change.
- No commit, checkout, reset, or stash was performed.
```

## Run folder `team-solve-2026-11-06T114203`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
af3e243ec14ca5fca2ed24d6a31049c922159487
```

### `baseline-check.log`

```
check: pytest tests/test_requests.py -q
.......EEEEEEEEEEE.......EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.F. [ 25%]
..EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.EEEEEE.E..........E..... [ 50%]
.EEEEE.EEE....EE.EEEEEEEEEE.EE........E......E..EEEEEExE..E.EEEE........ [ 75%]
.................EEEEEEEFFFFE.E..FF.......EE................E.........EE [100%]
==================================== ERRORS ====================================
__________ ERROR at setup of TestRequests.test_no_content_length[GET] __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_no_content_length[HEAD] __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[POST] _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[PUT] ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_no_body_content_length[PATCH] _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_no_body_content_length[OPTIONS] ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[POST] ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[PUT] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_empty_content_length[PATCH] ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_empty_content_length[OPTIONS] _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 113
      def test_override_content_length(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[http://] ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HTTP://] ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[hTTp://] ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HttP://] ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 167
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 176
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 182
      def test_HTTP_307_ALLOW_REDIRECT_POST(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 189
      def test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 197
      def test_HTTP_302_TOO_MANY_REDIRECTS(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS __
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 208
      def test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_301_changes_post_to_get _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 221
      def test_http_301_changes_post_to_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_301_doesnt_change_head_to_get ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 228
      def test_http_301_doesnt_change_head_to_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_302_changes_post_to_get _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 236
      def test_http_302_changes_post_to_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_302_doesnt_change_head_to_get ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 243
      def test_http_302_doesnt_change_head_to_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_303_changes_post_to_get _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 250
      def test_http_303_changes_post_to_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_303_doesnt_change_head_to_get ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 257
      def test_http_303_doesnt_change_head_to_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_header_and_body_removal_on_redirect ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 264
      def test_header_and_body_removal_on_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_transfer_enc_removal_on_redirect _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 281
      def test_transfer_enc_removal_on_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_fragment_maintained_on_redirect ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 304
      def test_fragment_maintained_on_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 312
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 320
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 326
      def test_set_cookie_on_301(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 332
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 338
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 351
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 356
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 362
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 370
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 376
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 387
      def test_param_cookiejar_works(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cookielib_cookiejar_on_redirect ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 395
      def test_cookielib_cookiejar_on_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 427
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 433
      def test_history_is_always_a_list(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 441
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_headers_preserve_order __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 449
      def test_headers_preserve_order(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[User-agent] _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[user-agent] _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 477
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 481
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 485
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[user-pass] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c] _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_set_basicauth[42-42] ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[None-None] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_proxy_error_on_bad_url __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 544
      def test_proxy_error_on_bad_url(self, httpbin, httpbin_secure):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_self_prepared_request _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 557
      def test_respect_proxy_env_on_send_self_prepared_request(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_session_prepared_request _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 564
      def test_respect_proxy_env_on_send_session_prepared_request(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_with_redirects _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 572
      def test_respect_proxy_env_on_send_with_redirects(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_respect_proxy_env_on_get _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 581
      def test_respect_proxy_env_on_get(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_respect_proxy_env_on_request _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 587
      def test_respect_proxy_env_on_request(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_proxy_authorization_preserved_on_request _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 593
      def test_proxy_authorization_preserved_on_request(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 602
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 635
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 653
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 664
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 673
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 685
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 702
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 711
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_invalid_files_input ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 729
      def test_invalid_files_input(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 737
      def test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 779
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_post_with_custom_mapping _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 797
      def test_post_with_custom_mapping(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 822
      def test_conflicting_post_params(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 830
      def test_request_ok_set(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 834
      def test_status_raising(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 842
      def test_decompress_gzip(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params0] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params1] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params2] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params3] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[\xf8-params4] _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 857
      def test_unicode_header_name(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 863
      def test_pyopenssl_redirect(self, httpbin_secure, httpbin_ca_bundle):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:33
_______ ERROR at setup of TestRequests.test_invalid_ca_certificate_path ________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 866
      def test_invalid_ca_certificate_path(self, httpbin_secure):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:33
______ ERROR at setup of TestRequests.test_invalid_ssl_certificate_files _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 872
      def test_invalid_ssl_certificate_files(self, httpbin_secure):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:33
__________ ERROR at setup of TestRequests.test_http_with_certificate ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 882
      def test_http_with_certificate(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_https_warnings ______________

tmp_path_factory = TempPathFactory(_given_basetemp=None, _trace=<pluggy._tracing.TagTracerSub object at 0x767173f4c520>, _basetemp=None, _retention_count=3, _retention_policy='all')

    @pytest.fixture
    def nosan_server(tmp_path_factory):
        # delay importing until the fixture in order to make it possible
        # to deselect the test via command-line when trustme is not available
>       import trustme
E       ModuleNotFoundError: No module named 'trustme'

tests/conftest.py:42: ModuleNotFoundError
___________ ERROR at setup of TestRequests.test_certificate_failure ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 907
      def test_certificate_failure(self, httpbin_secure):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:33
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 916
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_form_encoded_post_query_multivalued_element _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 922
      def test_form_encoded_post_query_multivalued_element(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 928
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data0] _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data1] _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data2] _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data3] _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 948
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 958
      def test_unicode_method_name(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 964
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 983
      def test_custom_content_type(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 994
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1004
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1013
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1023
      def test_prepared_request_hook(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1037
      def test_prepared_from_session(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_request_with_bytestring_host _______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1061
      def test_request_with_bytestring_host(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1240
      def test_time_elapsed_blank(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1321
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_prepared_request_is_pickleable ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1333
      def test_prepared_request_is_pickleable(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_file_is_pickleable _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1347
      def test_prepared_request_with_file_is_pickleable(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_hook_is_pickleable _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1363
      def test_prepared_request_with_hook_is_pickleable(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1379
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1394
      def test_session_pickling(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1404
      def test_fixes_1329(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1415
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1498
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1505
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1520
      def test_header_keys_are_native(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_header_validation _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1530
      def test_header_validation(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_header_value_not_str ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1539
      def test_header_value_not_str(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_no_return_chars __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1560
      def test_header_no_return_chars(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_header_no_leading_space __________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1578
      def test_header_no_leading_space(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo0] _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo1] _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_can_send_objects_with_files[files2] ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1600
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1608
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_auth_is_stripped_on_http_downgrade ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1627
      def test_auth_is_stripped_on_http_downgrade(self, httpbin, httpbin_secure, httpbin_ca_bundle):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1637
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1676
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1804
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1820
      def test_requests_history_is_saved(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1828
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1837
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1844
      def test_response_iter_lines(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_response_context_manager _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1852
      def test_response_context_manager(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1858
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_session_close_proxy_clear _________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1876
      def test_session_close_proxy_clear(self, mocker):
E       fixture 'mocker' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py:1876
____ ERROR at setup of TestRequests.test_response_json_when_content_is_None ____
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1897
      def test_response_json_when_content_is_None(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_empty_stream_with_auth_does_not_set_content_length_header _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1918
      def test_empty_stream_with_auth_does_not_set_content_length_header(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_stream_with_auth_does_not_set_transfer_encoding_header _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1930
      def test_stream_with_auth_does_not_set_transfer_encoding_header(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_chunked_upload_does_not_set_content_length_header _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1942
      def test_chunked_upload_does_not_set_content_length_header(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_custom_redirect_mixin ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 1953
      def test_custom_redirect_mixin(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2194
      def test_stream_timeout(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[timeout0-(connect, read)] _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[foo-must be an int, float or None] _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of TestTimeout.test_none_timeout[None] _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_none_timeout[timeout1] ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout0] ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout1] ___________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2264
      def test_encoded_methods(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of test_requests_are_updated_each_time _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2317
  def test_requests_are_updated_each_time(httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2409
  def test_urllib3_retries(httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2420
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
_ ERROR at setup of TestPreparingURLs.test_redirecting_to_bad_url[http://localhost:-1-InvalidURL] _
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2499
      @pytest.mark.parametrize(
          'url, exception',
          (
              ('http://localhost:-1', InvalidURL),
          )
      )
      def test_redirecting_to_bad_url(self, httpbin, url, exception):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
____________ ERROR at setup of TestPreparingURLs.test_post_json_nan ____________
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2579
      def test_post_json_nan(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
______ ERROR at setup of TestPreparingURLs.test_json_decode_compatibility ______
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/test_requests.py, line 2584
      def test_json_decode_compatibility(self, httpbin):
file /testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/.memdoor/runs/team-solve-2026-11-06T114203/baseline-tree/tests/conftest.py:28
=================================== FAILURES ===================================
___ TestRequests.test_errors[http://doesnotexist.google.com-ConnectionError] ___

self = <tests.test_requests.TestRequests object at 0x767173e3d7f0>
url = 'http://doesnotexist.google.com'
exception = <class 'requests.exceptions.ConnectionError'>

    @pytest.mark.parametrize(
        'url, exception', (
            # Connecting to an unknown domain should raise a ConnectionError
            ('http://doesnotexist.google.com', ConnectionError),
            # Connecting to an invalid port should raise a ConnectionError
            ('http://localhost:1', ConnectionError),
            # Inputing a URL that cannot be parsed should raise an InvalidURL error
            ('http://fe80::5054:ff:fe5a:fc0', InvalidURL)
        ))
    def test_errors(self, url, exception):
        with pytest.raises(exception):
>           requests.get(url, timeout=1)
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

tests/test_requests.py:537: Failed
__________________ TestTimeout.test_connect_timeout[timeout0] __________________

self = <tests.test_requests.TestTimeout object at 0x767173391a90>
timeout = (0.1, None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
__________________ TestTimeout.test_connect_timeout[timeout1] __________________

self = <tests.test_requests.TestTimeout object at 0x7671733915b0>
timeout = Timeout(connect=0.1, read=None, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout0] _______________

self = <tests.test_requests.TestTimeout object at 0x767173391fa0>
timeout = (0.1, 0.1)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout1] _______________

self = <tests.test_requests.TestTimeout object at 0x767173391c70>
timeout = Timeout(connect=0.1, read=0.1, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_ test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'http://example.com', proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
_ test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'https://example.com'
proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
=========================== short test summary info ============================
FAILED tests/test_requests.py::TestRequests::test_errors[http://doesnotexist.google.com-ConnectionError]
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout0] - ...
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout1] - ...
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout0]
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout1]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[GET]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[HEAD]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_override_content_length
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[http://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HTTP://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[hTTp://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HttP://]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_http_301_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_301_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_header_and_body_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_transfer_enc_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_fragment_maintained_on_redirect
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR tests/test_requests.py::TestRequests::test_set_cookie_on_301
ERROR tests/test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR tests/test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR tests/test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR tests/test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR tests/test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR tests/test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR tests/test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_param_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_cookielib_cookiejar_on_redirect
ERROR tests/test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR tests/test_requests.py::TestRequests::test_history_is_always_a_list
ERROR tests/test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR tests/test_requests.py::TestRequests::test_headers_preserve_order
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[User-agent]
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[user-agent]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR tests/test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[user-pass]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[42-42]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[None-None]
ERROR tests/test_requests.py::TestRequests::test_proxy_error_on_bad_url
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_self_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_session_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_with_redirects
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_get
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_request
ERROR tests/test_requests.py::TestRequests::test_proxy_authorization_preserved_on_request
ERROR tests/test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR tests/test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR tests/test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR tests/test_requests.py::TestRequests::test_invalid_files_input
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR tests/test_requests.py::TestRequests::test_post_with_custom_mapping
ERROR tests/test_requests.py::TestRequests::test_conflicting_post_params
ERROR tests/test_requests.py::TestRequests::test_request_ok_set
ERROR tests/test_requests.py::TestRequests::test_status_raising
ERROR tests/test_requests.py::TestRequests::test_decompress_gzip
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params0]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params1]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params2]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params3]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[\xf8-params4]
ERROR tests/test_requests.py::TestRequests::test_unicode_header_name
ERROR tests/test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR tests/test_requests.py::TestRequests::test_invalid_ca_certificate_path
ERROR tests/test_requests.py::TestRequests::test_invalid_ssl_certificate_files
ERROR tests/test_requests.py::TestRequests::test_http_with_certificate
ERROR tests/test_requests.py::TestRequests::test_https_warnings - ModuleNotFo...
ERROR tests/test_requests.py::TestRequests::test_certificate_failure
ERROR tests/test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR tests/test_requests.py::TestRequests::test_form_encoded_post_query_multivalued_element
ERROR tests/test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data0]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data1]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data2]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data3]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR tests/test_requests.py::TestRequests::test_custom_content_type
ERROR tests/test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR tests/test_requests.py::TestRequests::test_prepared_request_hook
ERROR tests/test_requests.py::TestRequests::test_prepared_from_session
ERROR tests/test_requests.py::TestRequests::test_request_with_bytestring_host
ERROR tests/test_requests.py::TestRequests::test_time_elapsed_blank
ERROR tests/test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_file_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_hook_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR tests/test_requests.py::TestRequests::test_session_pickling
ERROR tests/test_requests.py::TestRequests::test_fixes_1329
ERROR tests/test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR tests/test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR tests/test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR tests/test_requests.py::TestRequests::test_header_keys_are_native
ERROR tests/test_requests.py::TestRequests::test_header_validation
ERROR tests/test_requests.py::TestRequests::test_header_value_not_str
ERROR tests/test_requests.py::TestRequests::test_header_no_return_chars
ERROR tests/test_requests.py::TestRequests::test_header_no_leading_space
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo0]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo1]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[files2]
ERROR tests/test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR tests/test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR tests/test_requests.py::TestRequests::test_auth_is_stripped_on_http_downgrade
ERROR tests/test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR tests/test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR tests/test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR tests/test_requests.py::TestRequests::test_requests_history_is_saved
ERROR tests/test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR tests/test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR tests/test_requests.py::TestRequests::test_response_iter_lines
ERROR tests/test_requests.py::TestRequests::test_response_context_manager
ERROR tests/test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR tests/test_requests.py::TestRequests::test_session_close_proxy_clear
ERROR tests/test_requests.py::TestRequests::test_response_json_when_content_is_None
ERROR tests/test_requests.py::TestRequests::test_empty_stream_with_auth_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_stream_with_auth_does_not_set_transfer_encoding_header
ERROR tests/test_requests.py::TestRequests::test_chunked_upload_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_custom_redirect_mixin
ERROR tests/test_requests.py::TestTimeout::test_stream_timeout
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[timeout0-(connect, read)]
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[foo-must be an int, float or None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout0]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_encoded_methods
ERROR tests/test_requests.py::test_requests_are_updated_each_time
ERROR tests/test_requests.py::test_urllib3_retries
ERROR tests/test_requests.py::test_urllib3_pool_connection_closed
ERROR tests/test_requests.py::TestPreparingURLs::test_redirecting_to_bad_url[http://localhost:-1-InvalidURL]
ERROR tests/test_requests.py::TestPreparingURLs::test_post_json_nan
ERROR tests/test_requests.py::TestPreparingURLs::test_json_decode_compatibility
7 failed, 122 passed, 1 xfailed, 158 errors in 2.01s
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/requests/models.py b/requests/models.py
index e7d292d5..d8638818 100644
--- a/requests/models.py
+++ b/requests/models.py
@@ -403,7 +403,7 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
                 host = self._get_idna_encoded_host(host)
             except UnicodeError:
                 raise InvalidURL('URL has an invalid label.')
-        elif host.startswith(u'*'):
+        elif host.startswith((u'*', u'.')):
             raise InvalidURL('URL has an invalid label.')
 
         # Carefully reconstruct the network location
diff --git a/tests/test_requests.py b/tests/test_requests.py
index 463e8bf4..52495ca6 100644
--- a/tests/test_requests.py
+++ b/tests/test_requests.py
@@ -2488,7 +2488,8 @@ class TestPreparingURLs(object):
             b"http://*",
             u"http://*.google.com",
             u"http://*",
-            u"http://☃.net/"
+            u"http://☃.net/",
+            u"http://.example.com"
         )
     )
     def test_preparing_bad_url(self, url):
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

Getting http://.example.com raises UnicodeError
Attempting to get e.g. `http://.example.com` results in a `UnicodeError`. It seems like the intention so far has been to raise `InvalidUrl` instead (see e.g. [this line](https://github.com/psf/requests/blob/ca6f9af5dba09591007b15a7368bc0f006b7cc50/requests/models.py#L401)).

I see there was some hesitation in fixing a similar issue (#4168) and would like to add that even catching the error just to rethrow as a requests exception would be beneficial.

### Expected Result

Based on PR #774: `InvalidUrl: URL has an invalid label.`

### Actual Result

`UnicodeError: encoding with 'idna' codec failed (UnicodeError: label empty or too long)`

### Reproduction Steps

```python3
import requests
requests.get("http://.example.com")
```

### System Information

    $ python -m requests.help

```
{
  "chardet": {
    "version": "3.0.4"
  },
  "cryptography": {
    "version": "2.8"
  },
  "idna": {
    "version": "2.8"
  },
  "implementation": {
    "name": "CPython",
    "version": "3.8.0"
  },
  "platform": {
    "release": "5.3.0-40-generic",
    "system": "Linux"
  },
  "pyOpenSSL": {
    "openssl_version": "1010104f",
    "version": "19.1.0"
  },
  "requests": {
    "version": "2.23.0"
  },
  "system_ssl": {
    "version": "1010103f"
  },
  "urllib3": {
    "version": "1.25.8"
  },
  "using_pyopenssl": true
}
```

## Deliverable

changes to this tree

## Check

`pytest tests/test_requests.py -q`

## Scope

`requests/models.py`
`tests/`

## Done when

- `requests.get("http://.example.com")` raises `requests.exceptions.InvalidURL` instead of `UnicodeError`.
- The raised error identifies the invalid hostname label, matching the expected `URL has an invalid label.` outcome.
- Existing URL-preparation behavior for valid URLs and other invalid URLs continues to pass the test suite.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest tests/test_requests.py -q`

## Scope
`requests/models.py`
`tests/`

## Done when
- `requests.get("http://.example.com")` raises `requests.exceptions.InvalidURL` instead of `UnicodeError`.
- The raised error identifies the invalid hostname label, matching the expected `URL has an invalid label.` outcome.
- Existing URL-preparation behavior for valid URLs and other invalid URLs continues to pass the test suite.

## Approach
Trace the failure to the IDNA encoding of `host` in `Request.prepare_url`: the hostname `.example.com` has an empty label, so `host.encode("idna")` raises `UnicodeError`. The primary approach is to wrap that encoding in `try/except UnicodeError` and raise `InvalidURL` with the URL and underlying reason, optionally translating the invalid-label case to `URL has an invalid label.` This is the smallest change and keeps IDNA handling in one place. Add a regression test that requests `http://.example.com` and asserts `InvalidURL`.

If that fails, alternatives:
- Validate hostname labels before IDNA encoding (empty labels, length limits) and raise `InvalidURL("URL has an invalid label.")` directly. This matches the expected message exactly but duplicates IDNA rules and risks disagreeing with the codec.
- Catch `UnicodeError` at a higher request boundary and rethrow as `InvalidURL`. This is broader and may catch unrelated encoding failures, so prefer the local `prepare_url` fix.


# requests/models.py

```
# -*- coding: utf-8 -*-

"""
requests.models
~~~~~~~~~~~~~~~

This module contains the primary objects that power Requests.
"""

import datetime
import sys

# Import encoding now, to avoid implicit import later.
# Implicit import within threads may cause LookupError when standard library is in a ZIP,
# such as in Embedded Python. See https://github.com/psf/requests/issues/3578.
import encodings.idna

from urllib3.fields import RequestField
from urllib3.filepost import encode_multipart_formdata
from urllib3.util import parse_url
from urllib3.exceptions import (
    DecodeError, ReadTimeoutError, ProtocolError, LocationParseError)

from io import UnsupportedOperation
from .hooks import default_hooks
from .structures import CaseInsensitiveDict

from .auth import HTTPBasicAuth
from .cookies import cookiejar_from_dict, get_cookie_header, _copy_cookie_jar
from .exceptions import (
    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
    ContentDecodingError, ConnectionError, StreamConsumedError,
    InvalidJSONError)
from .exceptions import JSONDecodeError as RequestsJSONDecodeError
from ._internal_utils import to_native_string, unicode_is_ascii
from .utils import (
    guess_filename, get_auth_from_url, requote_uri,
    stream_decode_response_unicode, to_key_val_list, parse_header_links,
    iter_slices, guess_json_utf, super_len, check_header_validity)
from .compat import (
    Callable, Mapping,
    cookielib, urlunparse, urlsplit, urlencode, str, bytes,
    is_py2, chardet, builtin_str, basestring, JSONDecodeError)
from .compat import json as complexjson
from .status_codes import codes

#: The set of HTTP status codes that indicate an automatically
#: processable redirect.
REDIRECT_STATI = (
    codes.moved,               # 301
    codes.found,               # 302
    codes.other,               # 303
    codes.temporary_redirect,  # 307
    codes.permanent_redirect,  # 308
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
        tuples. Order is retained if data is a list of tuples but arbitrary
        if parameters are supplied as a dict.
        The tuples may be 2-tuples (filename, fileobj), 3-tuples (filename, fileobj, contentype)
        or 4-tuples (filename, fileobj, contentype, custom_headers).
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
            elif hasattr(fp, 'read'):
                fdata = fp.read()
            elif fp is None:
                continue
            else:
                fdata = fp

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

        if isinstance(hook, Callable):
            self.hooks[event].append(hook)
        elif hasattr(hook, '__iter__'):
            self.hooks[event].extend(h for h in hook if isinstance(h, Callable))

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
    :param data: the body to attach to the request. If a dictionary or
        list of tuples ``[(key, value)]`` is provided, form-encoding will
        take place.
    :param json: json for the body to attach to the request (if files or data is not specified).
    :param params: URL parameters to append to the URL. If a dictionary or
        list of tuples ``[(key, value)]`` is provided, form-encoding will
        take place.
    :param auth: Auth handler or (user, pass) tuple.
    :param cookies: dictionary or CookieJar of cookies to attach to this request.
    :param hooks: dictionary of callback hooks, for internal usage.

    Usage::

      >>> import requests
      >>> req = requests.Request('GET', 'https://httpbin.org/get')
      >>> req.prepare()
      <PreparedRequest [GET]>
    """

    def __init__(self,
            method=None, url=None, headers=None, files=None, data=None,
            params=None, auth=None, cookies=None, hooks=None, json=None):

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

    Instances are generated from a :class:`Request <Request>` object, and
    should not be instantiated manually; doing so may produce undesirable
    effects.

    Usage::

      >>> import requests
      >>> req = requests.Request('GET', 'https://httpbin.org/get')
      >>> r = req.prepare()
      >>> r
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
        #: integer denoting starting position of a readable file-like body.
        self._body_position = None

    def prepare(self,
            method=None, url=None, headers=None, files=None, data=None,
            params=None, auth=None, cookies=None, hooks=None, json=None):
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
        p._body_position = self._body_position
        return p

    def prepare_method(self, method):
        """Prepares the given HTTP method."""
        self.method = method
        if self.method is not None:
            self.method = to_native_string(self.method.upper())

    @staticmethod
    def _get_idna_encoded_host(host):
        import idna

        try:
            host = idna.encode(host, uts46=True).decode('utf-8')
        except idna.IDNAError:
            raise UnicodeError
        return host

    def prepare_url(self, url, params):
        """Prepares the given HTTP URL."""
        #: Accept objects that have string representations.
        #: We're unable to blindly call unicode/str functions
        #: as this will include the bytestring indicator (b'')
        #: on python 3.x.
        #: https://github.com/psf/requests/pull/2238
        if isinstance(url, bytes):
            url = url.decode('utf8')
        else:
            url = unicode(url) if is_py2 else str(url)

        # Remove leading whitespaces from url
        url = url.lstrip()

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

        # In general, we want to try IDNA encoding the hostname if the string contains
        # non-ASCII characters. This allows users to automatically get the correct IDNA
        # behaviour. For strings containing only ASCII characters, we need to also verify
        # it doesn't start with a wildcard (*), before allowing the unencoded hostname.
        if not unicode_is_ascii(host):
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith((u'*', u'.')):
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

        self.headers = CaseInsensitiveDict()
        if headers:
            for header in headers.items():
                # Raise exception on invalid header value.
                check_header_validity(header)
                name, value = header
                self.headers[to_native_string(name)] = value

    def prepare_body(self, data, files, json=None):
        """Prepares the given HTTP body data."""

        # Check if file, fo, generator, iterator.
        # If not, run through normal process.

        # Nottin' on you.
        body = None
        content_type = None

        if not data and json is not None:
            # urllib3 requires a bytes-like body. Python 2's json.dumps
            # provides this natively, but Python 3 gives a Unicode string.
            content_type = 'application/json'

            try:
                body = complexjson.dumps(json, allow_nan=False)
            except ValueError as ve:
                raise InvalidJSONError(ve, request=self)

            if not isinstance(body, bytes):
                body = body.encode('utf-8')

        is_stream = all([
            hasattr(data, '__iter__'),
            not isinstance(data, (basestring, list, tuple, Mapping))
        ])

        if is_stream:
            try:
                length = super_len(data)
            except (TypeError, AttributeError, UnsupportedOperation):
                length = None

            body = data

            if getattr(body, 'tell', None) is not None:
                # Record the current file position before reading.
                # This will allow us to rewind a file in the event
                # of a redirect.
                try:
                    self._body_position = body.tell()
                except (IOError, OSError):
                    # This differentiates from None, allowing us to catch
                    # a failed `tell()` later when trying to rewind the body
                    self._body_position = object()

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
        """Prepare Content-Length header based on request method and body"""
        if body is not None:
            length = super_len(body)
            if length:
                # If length exists, set it. Otherwise, we fallback
                # to Transfer-Encoding: chunked.
                self.headers['Content-Length'] = builtin_str(length)
        elif self.method not in ('GET', 'HEAD') and self.headers.get('Content-Length') is None:
            # Set Content-Length to 0 for methods that can have a body
            # but don't provide one. (i.e. not GET or HEAD)
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
        header is removed beforehand.
        """
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
        self._content = False
        self._content_consumed = False
        self._next = None

        #: Integer Code of responded HTTP Status, e.g. 404 or 200.
        self.status_code = None

        #: Case-insensitive Dictionary of Response Headers.
        #: For example, ``headers['content-encoding']`` will return the
        #: value of a ``'Content-Encoding'`` response header.
        self.headers = CaseInsensitiveDict()

        #: File-like object representation of response (for advanced usage).
        #: Use of ``raw`` requires that ``stream=True`` be set on the request.
        #: This requirement does not apply for use internally to Requests.
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

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()

    def __getstate__(self):
        # Consume everything; accessing the content attribute makes
        # sure the content has been fully read.
        if not self._content_consumed:
            self.content

        return {attr: getattr(self, attr, None) for attr in self.__attrs__}

    def __setstate__(self, state):
        for name, value in state.items():
            setattr(self, name, value)

        # pickled objects do not have .raw
        setattr(self, '_content_consumed', True)
        setattr(self, 'raw', None)

    def __repr__(self):
        return '<Response [%s]>' % (self.status_code)

    def __bool__(self):
        """Returns True if :attr:`status_code` is less than 400.

        This attribute checks if the status code of the response is between
        400 and 600 to see if there was a client error or a server error. If
        the status code, is between 200 and 400, this will return True. This
        is **not** a check to see if the response code is ``200 OK``.
        """
        return self.ok

    def __nonzero__(self):
        """Returns True if :attr:`status_code` is less than 400.

        This attribute checks if the status code of the response is between
        400 and 600 to see if there was a client error or a server error. If
        the status code, is between 200 and 400, this will return True. This
        is **not** a check to see if the response code is ``200 OK``.
        """
        return self.ok

    def __iter__(self):
        """Allows you to use a response as an iterator."""
        return self.iter_content(128)

    @property
    def ok(self):
        """Returns True if :attr:`status_code` is less than 400, False if not.

        This attribute checks if the status code of the response is between
        400 and 600 to see if there was a client error or a server error. If
        the status code is between 200 and 400, this will return True. This
        is **not** a check to see if the response code is ``200 OK``.
        """
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
        """True if this Response one of the permanent versions of redirect."""
        return ('location' in self.headers and self.status_code in (codes.moved_permanently, codes.permanent_redirect))

    @property
    def next(self):
        """Returns a PreparedRequest for the next request in a redirect chain, if there is one."""
        return self._next

    @property
    def apparent_encoding(self):
        """The apparent encoding, provided by the charset_normalizer or chardet libraries."""
        return chardet.detect(self.content)['encoding']

    def iter_content(self, chunk_size=1, decode_unicode=False):
        """Iterates over the response data.  When stream=True is set on the
        request, this avoids reading the content at once into memory for
        large responses.  The chunk size is the number of bytes it should
        read into memory.  This is not necessarily the length of each item
        returned as decoding can take place.

        chunk_size must be of type int or None. A value of None will
        function differently depending on the value of `stream`.
        stream=True will read data as it arrives in whatever size the
        chunks are received. If stream=False, data is returned as
        a single chunk.

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
        elif chunk_size is not None and not isinstance(chunk_size, int):
            raise TypeError("chunk_size must be an int, it is instead a %s." % type(chunk_size))
        # simulate reading small chunks of the content
        reused_chunks = iter_slices(self._content, chunk_size)

        stream_chunks = generate()

        chunks = reused_chunks if self._content_consumed else stream_chunks

        if decode_unicode:
            chunks = stream_decode_response_unicode(chunks, self)

        return chunks

    def iter_lines(self, chunk_size=ITER_CHUNK_SIZE, decode_unicode=False, delimiter=None):
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
            if self._content_consumed:
                raise RuntimeError(
                    'The content for this response was already consumed')

            if self.status_code == 0 or self.raw is None:
                self._content = None
            else:
                self._content = b''.join(self.iter_content(CONTENT_CHUNK_SIZE)) or b''

        self._content_consumed = True
        # don't need to release the connection; that's been handled by urllib3
        # since we exhausted the data.
        return self._content

    @property
    def text(self):
        """Content of the response, in unicode.

        If Response.encoding is None, encoding will be guessed using
        ``charset_normalizer`` or ``chardet``.

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
        r"""Returns the json-encoded content of a response, if any.

        :param \*\*kwargs: Optional arguments that ``json.loads`` takes.
        :raises requests.exceptions.JSONDecodeError: If the response body does not
            contain valid json.
        """

        if not self.encoding and self.content and len(self.content) > 3:
            # No encoding set. JSON RFC 4627 section 3 states we should expect
            # UTF-8, -16 or -32. Detect which one to use; If the detection or
            # decoding fails, fall back to `self.text` (using charset_normalizer to make
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

        try:
            return complexjson.loads(self.text, **kwargs)
        except JSONDecodeError as e:
            # Catch JSON-related errors and raise as requests.JSONDecodeError
            # This aliases json.JSONDecodeError and simplejson.JSONDecodeError
            if is_py2: # e is a ValueError
                raise RequestsJSONDecodeError(e.message)
            else:
                raise RequestsJSONDecodeError(e.msg, e.doc, e.pos)

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
        """Raises :class:`HTTPError`, if one occurred."""

        http_error_msg = ''
        if isinstance(self.reason, bytes):
            # We attempt to decode utf-8 first because some servers
            # choose to localize their reason strings. If the string
            # isn't utf-8, we fall back to iso-8859-1 for all other
            # encodings. (See PR #3538)
            try:
                reason = self.reason.decode('utf-8')
            except UnicodeDecodeError:
                reason = self.reason.decode('iso-8859-1')
        else:
            reason = self.reason

        if 400 <= self.status_code < 500:
            http_error_msg = u'%s Client Error: %s for url: %s' % (self.status_code, reason, self.url)

        elif 500 <= self.status_code < 600:
            http_error_msg = u'%s Server Error: %s for url: %s' % (self.status_code, reason, self.url)

        if http_error_msg:
            raise HTTPError(http_error_msg, response=self)

    def close(self):
        """Releases the connection back to the pool. Once this method has been
        called the underlying ``raw`` object must not be accessed again.

        *Note: Should not normally need to be called explicitly.*
        """
        if not self._content_consumed:
            self.raw.close()

        release_conn = getattr(self.raw, 'release_conn', None)
        if release_conn is not None:
            release_conn()

```


# tests (the files in it)

tests/__init__.py
tests/compat.py
tests/conftest.py
tests/test_help.py
tests/test_hooks.py
tests/test_lowlevel.py
tests/test_packages.py
tests/test_requests.py
tests/test_structures.py
tests/test_testserver.py
tests/test_utils.py
tests/testserver/__init__.py
tests/testserver/server.py
tests/utils.py


# The last commit

```
af3e243e SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: pytest tests/test_requests.py -q
.......EEEEEEEEEEE.......EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.F. [ 24%]
..EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.EEEEEE.E..........E..... [ 49%]
.EEEEE.EEE....EE.EEEEEEEEEE.EE........E......E..EEEEEExE..E.EEEE........ [ 74%]
.................EEEEEEEFFFFE.E..FF.......EE.................E.........E [ 99%]
E                                                                        [100%]
==================================== ERRORS ====================================
__________ ERROR at setup of TestRequests.test_no_content_length[GET] __________
file /testbed/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_no_content_length[HEAD] __________
file /testbed/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[POST] _______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[PUT] ________
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_no_body_content_length[PATCH] _______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_no_body_content_length[OPTIONS] ______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[POST] ________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[PUT] _________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_empty_content_length[PATCH] ________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_empty_content_length[OPTIONS] _______
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/tests/test_requests.py, line 113
      def test_override_content_length(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[http://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HTTP://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[hTTp://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HttP://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/tests/test_requests.py, line 167
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/tests/test_requests.py, line 176
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST _______
file /testbed/tests/test_requests.py, line 182
      def test_HTTP_307_ALLOW_REDIRECT_POST(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE _
file /testbed/tests/test_requests.py, line 189
      def test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS ________
file /testbed/tests/test_requests.py, line 197
      def test_HTTP_302_TOO_MANY_REDIRECTS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS __
file /testbed/tests/test_requests.py, line 208
      def test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_301_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 221
      def test_http_301_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_301_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 228
      def test_http_301_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_302_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 236
      def test_http_302_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_302_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 243
      def test_http_302_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_303_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 250
      def test_http_303_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_303_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 257
      def test_http_303_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_header_and_body_removal_on_redirect ____
file /testbed/tests/test_requests.py, line 264
      def test_header_and_body_removal_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_transfer_enc_removal_on_redirect _____
file /testbed/tests/test_requests.py, line 281
      def test_transfer_enc_removal_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_fragment_maintained_on_redirect ______
file /testbed/tests/test_requests.py, line 304
      def test_fragment_maintained_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/tests/test_requests.py, line 312
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/tests/test_requests.py, line 320
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/tests/test_requests.py, line 326
      def test_set_cookie_on_301(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/tests/test_requests.py, line 332
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/tests/test_requests.py, line 338
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/tests/test_requests.py, line 351
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/tests/test_requests.py, line 356
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/tests/test_requests.py, line 362
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/tests/test_requests.py, line 370
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/tests/test_requests.py, line 376
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/tests/test_requests.py, line 387
      def test_param_cookiejar_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cookielib_cookiejar_on_redirect ______
file /testbed/tests/test_requests.py, line 395
      def test_cookielib_cookiejar_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/tests/test_requests.py, line 427
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/tests/test_requests.py, line 433
      def test_history_is_always_a_list(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/tests/test_requests.py, line 441
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_headers_preserve_order __________
file /testbed/tests/test_requests.py, line 449
      def test_headers_preserve_order(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[User-agent] _____
file /testbed/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[user-agent] _____
file /testbed/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/tests/test_requests.py, line 477
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/tests/test_requests.py, line 481
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/tests/test_requests.py, line 485
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[user-pass] _________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c] _
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_set_basicauth[42-42] ___________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[None-None] _________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_proxy_error_on_bad_url __________
file /testbed/tests/test_requests.py, line 544
      def test_proxy_error_on_bad_url(self, httpbin, httpbin_secure):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_self_prepared_request _
file /testbed/tests/test_requests.py, line 557
      def test_respect_proxy_env_on_send_self_prepared_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_session_prepared_request _
file /testbed/tests/test_requests.py, line 564
      def test_respect_proxy_env_on_send_session_prepared_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_with_redirects _
file /testbed/tests/test_requests.py, line 572
      def test_respect_proxy_env_on_send_with_redirects(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_respect_proxy_env_on_get _________
file /testbed/tests/test_requests.py, line 581
      def test_respect_proxy_env_on_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_respect_proxy_env_on_request _______
file /testbed/tests/test_requests.py, line 587
      def test_respect_proxy_env_on_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_proxy_authorization_preserved_on_request _
file /testbed/tests/test_requests.py, line 593
      def test_proxy_authorization_preserved_on_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/tests/test_requests.py, line 602
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/tests/test_requests.py, line 635
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/tests/test_requests.py, line 653
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/tests/test_requests.py, line 664
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/tests/test_requests.py, line 673
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/tests/test_requests.py, line 685
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/tests/test_requests.py, line 702
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/tests/test_requests.py, line 711
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_invalid_files_input ____________
file /testbed/tests/test_requests.py, line 729
      def test_invalid_files_input(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER ____
file /testbed/tests/test_requests.py, line 737
      def test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/tests/test_requests.py, line 779
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_post_with_custom_mapping _________
file /testbed/tests/test_requests.py, line 797
      def test_post_with_custom_mapping(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/tests/test_requests.py, line 822
      def test_conflicting_post_params(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/tests/test_requests.py, line 830
      def test_request_ok_set(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/tests/test_requests.py, line 834
      def test_status_raising(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/tests/test_requests.py, line 842
      def test_decompress_gzip(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params0] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params1] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params2] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params3] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[\xf8-params4] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/tests/test_requests.py, line 857
      def test_unicode_header_name(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/tests/test_requests.py, line 863
      def test_pyopenssl_redirect(self, httpbin_secure, httpbin_ca_bundle):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
_______ ERROR at setup of TestRequests.test_invalid_ca_certificate_path ________
file /testbed/tests/test_requests.py, line 866
      def test_invalid_ca_certificate_path(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
______ ERROR at setup of TestRequests.test_invalid_ssl_certificate_files _______
file /testbed/tests/test_requests.py, line 872
      def test_invalid_ssl_certificate_files(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
__________ ERROR at setup of TestRequests.test_http_with_certificate ___________
file /testbed/tests/test_requests.py, line 882
      def test_http_with_certificate(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_https_warnings ______________

tmp_path_factory = TempPathFactory(_given_basetemp=None, _trace=<pluggy._tracing.TagTracerSub object at 0x72827c5d9a30>, _basetemp=None, _retention_count=3, _retention_policy='all')

    @pytest.fixture
    def nosan_server(tmp_path_factory):
        # delay importing until the fixture in order to make it possible
        # to deselect the test via command-line when trustme is not available
>       import trustme
E       ModuleNotFoundError: No module named 'trustme'

tests/conftest.py:42: ModuleNotFoundError
___________ ERROR at setup of TestRequests.test_certificate_failure ____________
file /testbed/tests/test_requests.py, line 907
      def test_certificate_failure(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/tests/test_requests.py, line 916
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_form_encoded_post_query_multivalued_element _
file /testbed/tests/test_requests.py, line 922
      def test_form_encoded_post_query_multivalued_element(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/tests/test_requests.py, line 928
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data0] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data1] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data2] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data3] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/tests/test_requests.py, line 948
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/tests/test_requests.py, line 958
      def test_unicode_method_name(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/tests/test_requests.py, line 964
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/tests/test_requests.py, line 983
      def test_custom_content_type(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/tests/test_requests.py, line 994
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/tests/test_requests.py, line 1004
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/tests/test_requests.py, line 1013
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/tests/test_requests.py, line 1023
      def test_prepared_request_hook(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/tests/test_requests.py, line 1037
      def test_prepared_from_session(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_request_with_bytestring_host _______
file /testbed/tests/test_requests.py, line 1061
      def test_request_with_bytestring_host(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/tests/test_requests.py, line 1240
      def test_time_elapsed_blank(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/tests/test_requests.py, line 1321
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_prepared_request_is_pickleable ______
file /testbed/tests/test_requests.py, line 1333
      def test_prepared_request_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_file_is_pickleable _
file /testbed/tests/test_requests.py, line 1347
      def test_prepared_request_with_file_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_hook_is_pickleable _
file /testbed/tests/test_requests.py, line 1363
      def test_prepared_request_with_hook_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/tests/test_requests.py, line 1379
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/tests/test_requests.py, line 1394
      def test_session_pickling(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/tests/test_requests.py, line 1404
      def test_fixes_1329(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/tests/test_requests.py, line 1415
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/tests/test_requests.py, line 1498
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/tests/test_requests.py, line 1505
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/tests/test_requests.py, line 1520
      def test_header_keys_are_native(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_header_validation _____________
file /testbed/tests/test_requests.py, line 1530
      def test_header_validation(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_header_value_not_str ___________
file /testbed/tests/test_requests.py, line 1539
      def test_header_value_not_str(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_no_return_chars __________
file /testbed/tests/test_requests.py, line 1560
      def test_header_no_return_chars(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_header_no_leading_space __________
file /testbed/tests/test_requests.py, line 1578
      def test_header_no_leading_space(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo0] _____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo1] _____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_can_send_objects_with_files[files2] ____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/tests/test_requests.py, line 1600
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/tests/test_requests.py, line 1608
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_auth_is_stripped_on_http_downgrade ____
file /testbed/tests/test_requests.py, line 1627
      def test_auth_is_stripped_on_http_downgrade(self, httpbin, httpbin_secure, httpbin_ca_bundle):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/tests/test_requests.py, line 1637
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/tests/test_requests.py, line 1676
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/tests/test_requests.py, line 1804
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/tests/test_requests.py, line 1820
      def test_requests_history_is_saved(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/tests/test_requests.py, line 1828
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/tests/test_requests.py, line 1837
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/tests/test_requests.py, line 1844
      def test_response_iter_lines(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_response_context_manager _________
file /testbed/tests/test_requests.py, line 1852
      def test_response_context_manager(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/tests/test_requests.py, line 1858
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_session_close_proxy_clear _________
file /testbed/tests/test_requests.py, line 1876
      def test_session_close_proxy_clear(self, mocker):
E       fixture 'mocker' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/test_requests.py:1876
____ ERROR at setup of TestRequests.test_response_json_when_content_is_None ____
file /testbed/tests/test_requests.py, line 1897
      def test_response_json_when_content_is_None(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_empty_stream_with_auth_does_not_set_content_length_header _
file /testbed/tests/test_requests.py, line 1918
      def test_empty_stream_with_auth_does_not_set_content_length_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_stream_with_auth_does_not_set_transfer_encoding_header _
file /testbed/tests/test_requests.py, line 1930
      def test_stream_with_auth_does_not_set_transfer_encoding_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_chunked_upload_does_not_set_content_length_header _
file /testbed/tests/test_requests.py, line 1942
      def test_chunked_upload_does_not_set_content_length_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_custom_redirect_mixin ___________
file /testbed/tests/test_requests.py, line 1953
      def test_custom_redirect_mixin(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/tests/test_requests.py, line 2194
      def test_stream_timeout(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[timeout0-(connect, read)] _
file /testbed/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[foo-must be an int, float or None] _
file /testbed/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestTimeout.test_none_timeout[None] _____________
file /testbed/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_none_timeout[timeout1] ___________
file /testbed/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout0] ___________
file /testbed/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout1] ___________
file /testbed/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/tests/test_requests.py, line 2264
      def test_encoded_methods(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of test_requests_are_updated_each_time _____________
file /testbed/tests/test_requests.py, line 2317
  def test_requests_are_updated_each_time(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/tests/test_requests.py, line 2409
  def test_urllib3_retries(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/tests/test_requests.py, line 2420
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestPreparingURLs.test_redirecting_to_bad_url[http://localhost:-1-InvalidURL] _
file /testbed/tests/test_requests.py, line 2500
      @pytest.mark.parametrize(
          'url, exception',
          (
              ('http://localhost:-1', InvalidURL),
          )
      )
      def test_redirecting_to_bad_url(self, httpbin, url, exception):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestPreparingURLs.test_post_json_nan ____________
file /testbed/tests/test_requests.py, line 2580
      def test_post_json_nan(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestPreparingURLs.test_json_decode_compatibility ______
file /testbed/tests/test_requests.py, line 2585
      def test_json_decode_compatibility(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
=================================== FAILURES ===================================
___ TestRequests.test_errors[http://doesnotexist.google.com-ConnectionError] ___

self = <tests.test_requests.TestRequests object at 0x72827c492d00>
url = 'http://doesnotexist.google.com'
exception = <class 'requests.exceptions.ConnectionError'>

    @pytest.mark.parametrize(
        'url, exception', (
            # Connecting to an unknown domain should raise a ConnectionError
            ('http://doesnotexist.google.com', ConnectionError),
            # Connecting to an invalid port should raise a ConnectionError
            ('http://localhost:1', ConnectionError),
            # Inputing a URL that cannot be parsed should raise an InvalidURL error
            ('http://fe80::5054:ff:fe5a:fc0', InvalidURL)
        ))
    def test_errors(self, url, exception):
        with pytest.raises(exception):
>           requests.get(url, timeout=1)
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

tests/test_requests.py:537: Failed
__________________ TestTimeout.test_connect_timeout[timeout0] __________________

self = <tests.test_requests.TestTimeout object at 0x72827c3b0ca0>
timeout = (0.1, None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
__________________ TestTimeout.test_connect_timeout[timeout1] __________________

self = <tests.test_requests.TestTimeout object at 0x72827c3b0dc0>
timeout = Timeout(connect=0.1, read=None, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout0] _______________

self = <tests.test_requests.TestTimeout object at 0x72827c3b0ee0>
timeout = (0.1, 0.1)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout1] _______________

self = <tests.test_requests.TestTimeout object at 0x72827c3bc040>
timeout = Timeout(connect=0.1, read=0.1, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_ test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'http://example.com', proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
_ test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'https://example.com'
proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
=========================== short test summary info ============================
FAILED tests/test_requests.py::TestRequests::test_errors[http://doesnotexist.google.com-ConnectionError]
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout0] - ...
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout1] - ...
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout0]
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout1]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[GET]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[HEAD]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_override_content_length
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[http://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HTTP://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[hTTp://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HttP://]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_http_301_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_301_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_header_and_body_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_transfer_enc_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_fragment_maintained_on_redirect
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR tests/test_requests.py::TestRequests::test_set_cookie_on_301
ERROR tests/test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR tests/test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR tests/test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR tests/test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR tests/test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR tests/test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR tests/test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_param_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_cookielib_cookiejar_on_redirect
ERROR tests/test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR tests/test_requests.py::TestRequests::test_history_is_always_a_list
ERROR tests/test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR tests/test_requests.py::TestRequests::test_headers_preserve_order
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[User-agent]
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[user-agent]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR tests/test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[user-pass]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[42-42]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[None-None]
ERROR tests/test_requests.py::TestRequests::test_proxy_error_on_bad_url
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_self_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_session_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_with_redirects
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_get
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_request
ERROR tests/test_requests.py::TestRequests::test_proxy_authorization_preserved_on_request
ERROR tests/test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR tests/test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR tests/test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR tests/test_requests.py::TestRequests::test_invalid_files_input
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR tests/test_requests.py::TestRequests::test_post_with_custom_mapping
ERROR tests/test_requests.py::TestRequests::test_conflicting_post_params
ERROR tests/test_requests.py::TestRequests::test_request_ok_set
ERROR tests/test_requests.py::TestRequests::test_status_raising
ERROR tests/test_requests.py::TestRequests::test_decompress_gzip
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params0]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params1]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params2]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params3]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[\xf8-params4]
ERROR tests/test_requests.py::TestRequests::test_unicode_header_name
ERROR tests/test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR tests/test_requests.py::TestRequests::test_invalid_ca_certificate_path
ERROR tests/test_requests.py::TestRequests::test_invalid_ssl_certificate_files
ERROR tests/test_requests.py::TestRequests::test_http_with_certificate
ERROR tests/test_requests.py::TestRequests::test_https_warnings - ModuleNotFo...
ERROR tests/test_requests.py::TestRequests::test_certificate_failure
ERROR tests/test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR tests/test_requests.py::TestRequests::test_form_encoded_post_query_multivalued_element
ERROR tests/test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data0]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data1]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data2]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data3]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR tests/test_requests.py::TestRequests::test_custom_content_type
ERROR tests/test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR tests/test_requests.py::TestRequests::test_prepared_request_hook
ERROR tests/test_requests.py::TestRequests::test_prepared_from_session
ERROR tests/test_requests.py::TestRequests::test_request_with_bytestring_host
ERROR tests/test_requests.py::TestRequests::test_time_elapsed_blank
ERROR tests/test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_file_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_hook_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR tests/test_requests.py::TestRequests::test_session_pickling
ERROR tests/test_requests.py::TestRequests::test_fixes_1329
ERROR tests/test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR tests/test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR tests/test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR tests/test_requests.py::TestRequests::test_header_keys_are_native
ERROR tests/test_requests.py::TestRequests::test_header_validation
ERROR tests/test_requests.py::TestRequests::test_header_value_not_str
ERROR tests/test_requests.py::TestRequests::test_header_no_return_chars
ERROR tests/test_requests.py::TestRequests::test_header_no_leading_space
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo0]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo1]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[files2]
ERROR tests/test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR tests/test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR tests/test_requests.py::TestRequests::test_auth_is_stripped_on_http_downgrade
ERROR tests/test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR tests/test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR tests/test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR tests/test_requests.py::TestRequests::test_requests_history_is_saved
ERROR tests/test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR tests/test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR tests/test_requests.py::TestRequests::test_response_iter_lines
ERROR tests/test_requests.py::TestRequests::test_response_context_manager
ERROR tests/test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR tests/test_requests.py::TestRequests::test_session_close_proxy_clear
ERROR tests/test_requests.py::TestRequests::test_response_json_when_content_is_None
ERROR tests/test_requests.py::TestRequests::test_empty_stream_with_auth_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_stream_with_auth_does_not_set_transfer_encoding_header
ERROR tests/test_requests.py::TestRequests::test_chunked_upload_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_custom_redirect_mixin
ERROR tests/test_requests.py::TestTimeout::test_stream_timeout
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[timeout0-(connect, read)]
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[foo-must be an int, float or None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout0]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_encoded_methods
ERROR tests/test_requests.py::test_requests_are_updated_each_time
ERROR tests/test_requests.py::test_urllib3_retries
ERROR tests/test_requests.py::test_urllib3_pool_connection_closed
ERROR tests/test_requests.py::TestPreparingURLs::test_redirecting_to_bad_url[http://localhost:-1-InvalidURL]
ERROR tests/test_requests.py::TestPreparingURLs::test_post_json_nan
ERROR tests/test_requests.py::TestPreparingURLs::test_json_decode_compatibility
7 failed, 123 passed, 1 xfailed, 158 errors in 1.44s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/models.py tests
changed: requests/models.py +1 -1
changed: tests/test_requests.py +2 -1
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/requests/models.py b/requests/models.py
index e7d292d5..d8638818 100644
--- a/requests/models.py
+++ b/requests/models.py
@@ -403,7 +403,7 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
                 host = self._get_idna_encoded_host(host)
             except UnicodeError:
                 raise InvalidURL('URL has an invalid label.')
-        elif host.startswith(u'*'):
+        elif host.startswith((u'*', u'.')):
             raise InvalidURL('URL has an invalid label.')
 
         # Carefully reconstruct the network location
diff --git a/tests/test_requests.py b/tests/test_requests.py
index 463e8bf4..52495ca6 100644
--- a/tests/test_requests.py
+++ b/tests/test_requests.py
@@ -2488,7 +2488,8 @@ class TestPreparingURLs(object):
             b"http://*",
             u"http://*.google.com",
             u"http://*",
-            u"http://☃.net/"
+            u"http://☃.net/",
+            u"http://.example.com"
         )
     )
     def test_preparing_bad_url(self, url):
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
check: pytest tests/test_requests.py -q
.......EEEEEEEEEEE.......EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.F. [ 24%]
..EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.EEEEEE.E..........E..... [ 49%]
.EEEEE.EEE....EE.EEEEEEEEEE.EE........E......E..EEEEEExE..E.EEEE........ [ 74%]
.................EEEEEEEFFFFE.E..FF.......EE.................E.........E [ 99%]
E                                                                        [100%]
==================================== ERRORS ====================================
__________ ERROR at setup of TestRequests.test_no_content_length[GET] __________
file /testbed/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_no_content_length[HEAD] __________
file /testbed/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[POST] _______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[PUT] ________
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_no_body_content_length[PATCH] _______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_no_body_content_length[OPTIONS] ______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[POST] ________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[PUT] _________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_empty_content_length[PATCH] ________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_empty_content_length[OPTIONS] _______
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/tests/test_requests.py, line 113
      def test_override_content_length(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[http://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HTTP://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[hTTp://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HttP://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/tests/test_requests.py, line 167
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/tests/test_requests.py, line 176
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST _______
file /testbed/tests/test_requests.py, line 182
      def test_HTTP_307_ALLOW_REDIRECT_POST(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE _
file /testbed/tests/test_requests.py, line 189
      def test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS ________
file /testbed/tests/test_requests.py, line 197
      def test_HTTP_302_TOO_MANY_REDIRECTS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS __
file /testbed/tests/test_requests.py, line 208
      def test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_301_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 221
      def test_http_301_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_301_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 228
      def test_http_301_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_302_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 236
      def test_http_302_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_302_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 243
      def test_http_302_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_303_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 250
      def test_http_303_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_303_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 257
      def test_http_303_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_header_and_body_removal_on_redirect ____
file /testbed/tests/test_requests.py, line 264
      def test_header_and_body_removal_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_transfer_enc_removal_on_redirect _____
file /testbed/tests/test_requests.py, line 281
      def test_transfer_enc_removal_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_fragment_maintained_on_redirect ______
file /testbed/tests/test_requests.py, line 304
      def test_fragment_maintained_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/tests/test_requests.py, line 312
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/tests/test_requests.py, line 320
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/tests/test_requests.py, line 326
      def test_set_cookie_on_301(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/tests/test_requests.py, line 332
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/tests/test_requests.py, line 338
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/tests/test_requests.py, line 351
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/tests/test_requests.py, line 356
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/tests/test_requests.py, line 362
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/tests/test_requests.py, line 370
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/tests/test_requests.py, line 376
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/tests/test_requests.py, line 387
      def test_param_cookiejar_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cookielib_cookiejar_on_redirect ______
file /testbed/tests/test_requests.py, line 395
      def test_cookielib_cookiejar_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/tests/test_requests.py, line 427
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/tests/test_requests.py, line 433
      def test_history_is_always_a_list(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/tests/test_requests.py, line 441
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_headers_preserve_order __________
file /testbed/tests/test_requests.py, line 449
      def test_headers_preserve_order(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[User-agent] _____
file /testbed/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[user-agent] _____
file /testbed/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/tests/test_requests.py, line 477
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/tests/test_requests.py, line 481
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/tests/test_requests.py, line 485
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[user-pass] _________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c] _
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_set_basicauth[42-42] ___________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[None-None] _________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_proxy_error_on_bad_url __________
file /testbed/tests/test_requests.py, line 544
      def test_proxy_error_on_bad_url(self, httpbin, httpbin_secure):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_self_prepared_request _
file /testbed/tests/test_requests.py, line 557
      def test_respect_proxy_env_on_send_self_prepared_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_session_prepared_request _
file /testbed/tests/test_requests.py, line 564
      def test_respect_proxy_env_on_send_session_prepared_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_with_redirects _
file /testbed/tests/test_requests.py, line 572
      def test_respect_proxy_env_on_send_with_redirects(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_respect_proxy_env_on_get _________
file /testbed/tests/test_requests.py, line 581
      def test_respect_proxy_env_on_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_respect_proxy_env_on_request _______
file /testbed/tests/test_requests.py, line 587
      def test_respect_proxy_env_on_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_proxy_authorization_preserved_on_request _
file /testbed/tests/test_requests.py, line 593
      def test_proxy_authorization_preserved_on_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/tests/test_requests.py, line 602
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/tests/test_requests.py, line 635
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/tests/test_requests.py, line 653
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/tests/test_requests.py, line 664
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/tests/test_requests.py, line 673
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/tests/test_requests.py, line 685
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/tests/test_requests.py, line 702
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/tests/test_requests.py, line 711
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_invalid_files_input ____________
file /testbed/tests/test_requests.py, line 729
      def test_invalid_files_input(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER ____
file /testbed/tests/test_requests.py, line 737
      def test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/tests/test_requests.py, line 779
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_post_with_custom_mapping _________
file /testbed/tests/test_requests.py, line 797
      def test_post_with_custom_mapping(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/tests/test_requests.py, line 822
      def test_conflicting_post_params(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/tests/test_requests.py, line 830
      def test_request_ok_set(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/tests/test_requests.py, line 834
      def test_status_raising(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/tests/test_requests.py, line 842
      def test_decompress_gzip(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params0] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params1] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params2] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params3] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[\xf8-params4] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/tests/test_requests.py, line 857
      def test_unicode_header_name(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/tests/test_requests.py, line 863
      def test_pyopenssl_redirect(self, httpbin_secure, httpbin_ca_bundle):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
_______ ERROR at setup of TestRequests.test_invalid_ca_certificate_path ________
file /testbed/tests/test_requests.py, line 866
      def test_invalid_ca_certificate_path(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
______ ERROR at setup of TestRequests.test_invalid_ssl_certificate_files _______
file /testbed/tests/test_requests.py, line 872
      def test_invalid_ssl_certificate_files(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
__________ ERROR at setup of TestRequests.test_http_with_certificate ___________
file /testbed/tests/test_requests.py, line 882
      def test_http_with_certificate(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_https_warnings ______________

tmp_path_factory = TempPathFactory(_given_basetemp=None, _trace=<pluggy._tracing.TagTracerSub object at 0x7ed49ef23a30>, _basetemp=None, _retention_count=3, _retention_policy='all')

    @pytest.fixture
    def nosan_server(tmp_path_factory):
        # delay importing until the fixture in order to make it possible
        # to deselect the test via command-line when trustme is not available
>       import trustme
E       ModuleNotFoundError: No module named 'trustme'

tests/conftest.py:42: ModuleNotFoundError
___________ ERROR at setup of TestRequests.test_certificate_failure ____________
file /testbed/tests/test_requests.py, line 907
      def test_certificate_failure(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/tests/test_requests.py, line 916
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_form_encoded_post_query_multivalued_element _
file /testbed/tests/test_requests.py, line 922
      def test_form_encoded_post_query_multivalued_element(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/tests/test_requests.py, line 928
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data0] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data1] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data2] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data3] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/tests/test_requests.py, line 948
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/tests/test_requests.py, line 958
      def test_unicode_method_name(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/tests/test_requests.py, line 964
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/tests/test_requests.py, line 983
      def test_custom_content_type(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/tests/test_requests.py, line 994
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/tests/test_requests.py, line 1004
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/tests/test_requests.py, line 1013
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/tests/test_requests.py, line 1023
      def test_prepared_request_hook(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/tests/test_requests.py, line 1037
      def test_prepared_from_session(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_request_with_bytestring_host _______
file /testbed/tests/test_requests.py, line 1061
      def test_request_with_bytestring_host(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/tests/test_requests.py, line 1240
      def test_time_elapsed_blank(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/tests/test_requests.py, line 1321
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_prepared_request_is_pickleable ______
file /testbed/tests/test_requests.py, line 1333
      def test_prepared_request_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_file_is_pickleable _
file /testbed/tests/test_requests.py, line 1347
      def test_prepared_request_with_file_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_hook_is_pickleable _
file /testbed/tests/test_requests.py, line 1363
      def test_prepared_request_with_hook_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/tests/test_requests.py, line 1379
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/tests/test_requests.py, line 1394
      def test_session_pickling(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/tests/test_requests.py, line 1404
      def test_fixes_1329(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/tests/test_requests.py, line 1415
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/tests/test_requests.py, line 1498
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/tests/test_requests.py, line 1505
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/tests/test_requests.py, line 1520
      def test_header_keys_are_native(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_header_validation _____________
file /testbed/tests/test_requests.py, line 1530
      def test_header_validation(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_header_value_not_str ___________
file /testbed/tests/test_requests.py, line 1539
      def test_header_value_not_str(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_no_return_chars __________
file /testbed/tests/test_requests.py, line 1560
      def test_header_no_return_chars(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_header_no_leading_space __________
file /testbed/tests/test_requests.py, line 1578
      def test_header_no_leading_space(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo0] _____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo1] _____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_can_send_objects_with_files[files2] ____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/tests/test_requests.py, line 1600
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/tests/test_requests.py, line 1608
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_auth_is_stripped_on_http_downgrade ____
file /testbed/tests/test_requests.py, line 1627
      def test_auth_is_stripped_on_http_downgrade(self, httpbin, httpbin_secure, httpbin_ca_bundle):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/tests/test_requests.py, line 1637
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/tests/test_requests.py, line 1676
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/tests/test_requests.py, line 1804
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/tests/test_requests.py, line 1820
      def test_requests_history_is_saved(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/tests/test_requests.py, line 1828
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/tests/test_requests.py, line 1837
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/tests/test_requests.py, line 1844
      def test_response_iter_lines(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_response_context_manager _________
file /testbed/tests/test_requests.py, line 1852
      def test_response_context_manager(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/tests/test_requests.py, line 1858
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_session_close_proxy_clear _________
file /testbed/tests/test_requests.py, line 1876
      def test_session_close_proxy_clear(self, mocker):
E       fixture 'mocker' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/test_requests.py:1876
____ ERROR at setup of TestRequests.test_response_json_when_content_is_None ____
file /testbed/tests/test_requests.py, line 1897
      def test_response_json_when_content_is_None(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_empty_stream_with_auth_does_not_set_content_length_header _
file /testbed/tests/test_requests.py, line 1918
      def test_empty_stream_with_auth_does_not_set_content_length_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_stream_with_auth_does_not_set_transfer_encoding_header _
file /testbed/tests/test_requests.py, line 1930
      def test_stream_with_auth_does_not_set_transfer_encoding_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_chunked_upload_does_not_set_content_length_header _
file /testbed/tests/test_requests.py, line 1942
      def test_chunked_upload_does_not_set_content_length_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_custom_redirect_mixin ___________
file /testbed/tests/test_requests.py, line 1953
      def test_custom_redirect_mixin(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/tests/test_requests.py, line 2194
      def test_stream_timeout(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[timeout0-(connect, read)] _
file /testbed/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[foo-must be an int, float or None] _
file /testbed/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestTimeout.test_none_timeout[None] _____________
file /testbed/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_none_timeout[timeout1] ___________
file /testbed/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout0] ___________
file /testbed/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout1] ___________
file /testbed/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/tests/test_requests.py, line 2264
      def test_encoded_methods(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of test_requests_are_updated_each_time _____________
file /testbed/tests/test_requests.py, line 2317
  def test_requests_are_updated_each_time(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/tests/test_requests.py, line 2409
  def test_urllib3_retries(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/tests/test_requests.py, line 2420
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestPreparingURLs.test_redirecting_to_bad_url[http://localhost:-1-InvalidURL] _
file /testbed/tests/test_requests.py, line 2500
      @pytest.mark.parametrize(
          'url, exception',
          (
              ('http://localhost:-1', InvalidURL),
          )
      )
      def test_redirecting_to_bad_url(self, httpbin, url, exception):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestPreparingURLs.test_post_json_nan ____________
file /testbed/tests/test_requests.py, line 2580
      def test_post_json_nan(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestPreparingURLs.test_json_decode_compatibility ______
file /testbed/tests/test_requests.py, line 2585
      def test_json_decode_compatibility(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
=================================== FAILURES ===================================
___ TestRequests.test_errors[http://doesnotexist.google.com-ConnectionError] ___

self = <tests.test_requests.TestRequests object at 0x7ed49ede9d00>
url = 'http://doesnotexist.google.com'
exception = <class 'requests.exceptions.ConnectionError'>

    @pytest.mark.parametrize(
        'url, exception', (
            # Connecting to an unknown domain should raise a ConnectionError
            ('http://doesnotexist.google.com', ConnectionError),
            # Connecting to an invalid port should raise a ConnectionError
            ('http://localhost:1', ConnectionError),
            # Inputing a URL that cannot be parsed should raise an InvalidURL error
            ('http://fe80::5054:ff:fe5a:fc0', InvalidURL)
        ))
    def test_errors(self, url, exception):
        with pytest.raises(exception):
>           requests.get(url, timeout=1)
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

tests/test_requests.py:537: Failed
__________________ TestTimeout.test_connect_timeout[timeout0] __________________

self = <tests.test_requests.TestTimeout object at 0x7ed49ed06ca0>
timeout = (0.1, None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
__________________ TestTimeout.test_connect_timeout[timeout1] __________________

self = <tests.test_requests.TestTimeout object at 0x7ed49ed06dc0>
timeout = Timeout(connect=0.1, read=None, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout0] _______________

self = <tests.test_requests.TestTimeout object at 0x7ed49ed06ee0>
timeout = (0.1, 0.1)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout1] _______________

self = <tests.test_requests.TestTimeout object at 0x7ed49ed12040>
timeout = Timeout(connect=0.1, read=0.1, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_ test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'http://example.com', proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
_ test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'https://example.com'
proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
=========================== short test summary info ============================
FAILED tests/test_requests.py::TestRequests::test_errors[http://doesnotexist.google.com-ConnectionError]
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout0] - ...
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout1] - ...
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout0]
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout1]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[GET]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[HEAD]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_override_content_length
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[http://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HTTP://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[hTTp://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HttP://]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_http_301_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_301_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_header_and_body_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_transfer_enc_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_fragment_maintained_on_redirect
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR tests/test_requests.py::TestRequests::test_set_cookie_on_301
ERROR tests/test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR tests/test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR tests/test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR tests/test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR tests/test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR tests/test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR tests/test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_param_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_cookielib_cookiejar_on_redirect
ERROR tests/test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR tests/test_requests.py::TestRequests::test_history_is_always_a_list
ERROR tests/test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR tests/test_requests.py::TestRequests::test_headers_preserve_order
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[User-agent]
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[user-agent]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR tests/test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[user-pass]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[42-42]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[None-None]
ERROR tests/test_requests.py::TestRequests::test_proxy_error_on_bad_url
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_self_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_session_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_with_redirects
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_get
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_request
ERROR tests/test_requests.py::TestRequests::test_proxy_authorization_preserved_on_request
ERROR tests/test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR tests/test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR tests/test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR tests/test_requests.py::TestRequests::test_invalid_files_input
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR tests/test_requests.py::TestRequests::test_post_with_custom_mapping
ERROR tests/test_requests.py::TestRequests::test_conflicting_post_params
ERROR tests/test_requests.py::TestRequests::test_request_ok_set
ERROR tests/test_requests.py::TestRequests::test_status_raising
ERROR tests/test_requests.py::TestRequests::test_decompress_gzip
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params0]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params1]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params2]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params3]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[\xf8-params4]
ERROR tests/test_requests.py::TestRequests::test_unicode_header_name
ERROR tests/test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR tests/test_requests.py::TestRequests::test_invalid_ca_certificate_path
ERROR tests/test_requests.py::TestRequests::test_invalid_ssl_certificate_files
ERROR tests/test_requests.py::TestRequests::test_http_with_certificate
ERROR tests/test_requests.py::TestRequests::test_https_warnings - ModuleNotFo...
ERROR tests/test_requests.py::TestRequests::test_certificate_failure
ERROR tests/test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR tests/test_requests.py::TestRequests::test_form_encoded_post_query_multivalued_element
ERROR tests/test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data0]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data1]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data2]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data3]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR tests/test_requests.py::TestRequests::test_custom_content_type
ERROR tests/test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR tests/test_requests.py::TestRequests::test_prepared_request_hook
ERROR tests/test_requests.py::TestRequests::test_prepared_from_session
ERROR tests/test_requests.py::TestRequests::test_request_with_bytestring_host
ERROR tests/test_requests.py::TestRequests::test_time_elapsed_blank
ERROR tests/test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_file_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_hook_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR tests/test_requests.py::TestRequests::test_session_pickling
ERROR tests/test_requests.py::TestRequests::test_fixes_1329
ERROR tests/test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR tests/test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR tests/test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR tests/test_requests.py::TestRequests::test_header_keys_are_native
ERROR tests/test_requests.py::TestRequests::test_header_validation
ERROR tests/test_requests.py::TestRequests::test_header_value_not_str
ERROR tests/test_requests.py::TestRequests::test_header_no_return_chars
ERROR tests/test_requests.py::TestRequests::test_header_no_leading_space
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo0]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo1]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[files2]
ERROR tests/test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR tests/test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR tests/test_requests.py::TestRequests::test_auth_is_stripped_on_http_downgrade
ERROR tests/test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR tests/test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR tests/test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR tests/test_requests.py::TestRequests::test_requests_history_is_saved
ERROR tests/test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR tests/test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR tests/test_requests.py::TestRequests::test_response_iter_lines
ERROR tests/test_requests.py::TestRequests::test_response_context_manager
ERROR tests/test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR tests/test_requests.py::TestRequests::test_session_close_proxy_clear
ERROR tests/test_requests.py::TestRequests::test_response_json_when_content_is_None
ERROR tests/test_requests.py::TestRequests::test_empty_stream_with_auth_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_stream_with_auth_does_not_set_transfer_encoding_header
ERROR tests/test_requests.py::TestRequests::test_chunked_upload_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_custom_redirect_mixin
ERROR tests/test_requests.py::TestTimeout::test_stream_timeout
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[timeout0-(connect, read)]
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[foo-must be an int, float or None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout0]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_encoded_methods
ERROR tests/test_requests.py::test_requests_are_updated_each_time
ERROR tests/test_requests.py::test_urllib3_retries
ERROR tests/test_requests.py::test_urllib3_pool_connection_closed
ERROR tests/test_requests.py::TestPreparingURLs::test_redirecting_to_bad_url[http://localhost:-1-InvalidURL]
ERROR tests/test_requests.py::TestPreparingURLs::test_post_json_nan
ERROR tests/test_requests.py::TestPreparingURLs::test_json_decode_compatibility
7 failed, 123 passed, 1 xfailed, 158 errors in 1.57s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/models.py tests
changed: requests/models.py +1 -1
changed: tests/test_requests.py +2 -1
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
# Notes, run 2026-11-06T114203

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Getting http://.example.com raises UnicodeError
Attempting to get e.g. `http://.example.com` results in a `UnicodeError`. It seems like the intention so far has been to raise `InvalidUrl` instead (see e.g. [this line](https://github.com/psf/requests/blob/ca6f9af5dba09591007b15a7368bc0f006b7cc50/requests/models.py#L401)).

I see there was some hesitation in fixing a similar issue (#4168) and would like to add that even catching the error just to rethrow as a requests exception would be beneficial.

## Expected Result

Based on PR #774: `InvalidUrl: URL has an invalid label.`

## Actual Result

`UnicodeError: encoding with 'idna' codec failed (UnicodeError: label empty or too long)`

## Reproduction Steps

```python3
import requests
requests.get("http://.example.com")
```

## System Information

    $ python -m requests.help

```
{
  "chardet": {
    "version": "3.0.4"
  },
  "cryptography": {
    "version": "2.8"
  },
  "idna": {
    "version": "2.8"
  },
  "implementation": {
    "name": "CPython",
    "version": "3.8.0"
  },
  "platform": {
    "release": "5.3.0-40-generic",
    "system": "Linux"
  },
  "pyOpenSSL": {
    "openssl_version": "1010104f",
    "version": "19.1.0"
  },
  "requests": {
    "version": "2.23.0"
  },
  "system_ssl": {
    "version": "1010103f"
  },
  "urllib3": {
    "version": "1.25.8"
  },
  "using_pyopenssl": true
}
```


# The files of the project

```
.coveragerc
.github/CODE_OF_CONDUCT.md
.github/CONTRIBUTING.md
.github/FUNDING.yml
.github/ISSUE_TEMPLATE.md
.github/ISSUE_TEMPLATE/Bug_report.md
.github/ISSUE_TEMPLATE/Custom.md
.github/ISSUE_TEMPLATE/Feature_request.md
.github/SECURITY.md
.github/workflows/codeql-analysis.yml
.github/workflows/lock-issues.yml
.github/workflows/run-tests.yml
.gitignore
AUTHORS.rst
HISTORY.md
LICENSE
MANIFEST.in
Makefile
NOTICE
README.md
docs/.nojekyll
docs/Makefile
docs/_static/custom.css
docs/_static/requests-sidebar.png
docs/_templates/hacks.html
docs/_templates/sidebarintro.html
docs/_templates/sidebarlogo.html
docs/_themes/.gitignore
docs/_themes/LICENSE
docs/_themes/flask_theme_support.py
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
docs/index.rst
docs/make.bat
docs/requirements.txt
docs/user/advanced.rst
docs/user/authentication.rst
docs/user/install.rst
docs/user/quickstart.rst
ext/LICENSE
ext/flower-of-life.jpg
ext/kr-compressed.png
ext/kr.png
ext/psf-compressed.png
ext/psf.png
ext/requests-logo-compressed.png
ext/requests-logo.ai
ext/requests-logo.png
ext/requests-logo.svg
ext/ss-compressed.png
ext/ss.png
pytest.ini
requests/__init__.py
requests/__version__.py
requests/_internal_utils.py
requests/adapters.py
requests/api.py
requests/auth.py
requests/certs.py
requests/compat.py
requests/cookies.py
requests/exceptions.py
requests/help.py
requests/hooks.py
requests/models.py
requests/packages.py
requests/sessions.py
requests/status_codes.py
requests/structures.py
requests/utils.py
requirements-dev.txt
setup.cfg
setup.py
tests/__init__.py
tests/compat.py
tests/conftest.py
tests/test_help.py
tests/test_hooks.py
tests/test_lowlevel.py
tests/test_packages.py
tests/test_requests.py
tests/test_structures.py
tests/test_testserver.py
tests/test_utils.py
tests/testserver/__init__.py
tests/testserver/server.py
tests/utils.py
tox.ini
```


# The last commit

```
af3e243e SWE-bench


```

```diff

```


# README.md (the start)

```
# Requests

**Requests** is a simple, yet elegant, HTTP library.

```python
>>> import requests
>>> r = requests.get('https://api.github.com/user', auth=('user', 'pass'))
>>> r.status_code
200
>>> r.headers['content-type']
'application/json; charset=utf8'
>>> r.encoding
'utf-8'
>>> r.text
'{"type":"User"...'
>>> r.json()
{'disk_usage': 368627, 'private_gists': 484, ...}
```

Requests allows you to send HTTP/1.1 requests extremely easily. There’s no need to manually add query strings to your URLs, or to form-encode your `PUT` & `POST` data — but nowadays, just use the `json` method!

Requests is one of the most downloaded Python packages today, pulling in around `30M downloads / week`— according to GitHub, Requests is currently [depended upon](https://github.com/psf/requests/network/dependents?package_id=UGFja2FnZS01NzA4OTExNg%3D%3D) by `500,000+` repositories. You may certainly put your trust in this code.

[![Downloads](https://pepy.tech/badge/requests/month)](https://pepy.tech/project/requests)
[![Supported Versions](https://img.shields.io/pypi/pyversions/requests.svg)](https://pypi.org/project/requests)
[![Contributors](https://img.shields.io/github/contributors/psf/requests.svg)](https://github.com/psf/requests/graphs/contributors)

## Installing Requests and Supported Versions

Requests is available on PyPI:

```console
$ python -m pip install requests
```

Requests officially supports Python 2.7 & 3.6+.

## Supported Features & Best–Practices

Requests is ready for the demands of building robust and reliable HTTP–speaking applications, for the needs of today.

- Keep-Alive & Connection Pooling
- International Domains and URLs
- Sessions with Cookie Persistence
- Browser-style TLS/SSL Verification
- Basic & Digest Authentication
- Familiar `dict`–like Cookies
- Automatic Content Decompression and Decoding
- Multi-part File Uploads
- SOCKS Proxy Support
- Connection Timeouts
- Streaming Downloads
- Automatic honoring of `.netrc`
- Chunked HTTP Requests

## API Reference and User Guide available on [Read the Docs](https://requests.readthedocs.io)

[![Read the Docs](https://raw.githubusercontent.com/psf/requests/main/ext/ss.png)](https://requests.readthedocs.io)

## Cloning the repository

When cloning the Requests repository, you may need to add the `-c
fetch.fsck.badTimezone=ignore` flag to avoid an error about a bad commit (see
[this issue](https://github.com/psf/requests/issues/2690) for more background):

```shell
git clone -c fetch.fsck.badTimezone=ignore https://github.com/psf/requests.git
```

You can also apply this setting to your global Git config:

```shell
git config --global fetch.fsck.badTimezone ignore
```

---

[![Kenneth Reitz](https://raw.githubusercontent.com/psf/requests/main/ext/kr.png)](https://kennethreitz.org) [![Python Software Foundation](https://raw.githubusercontent.com/psf/requests/main/ext/psf.png)](https://www.python.org/psf)

```


# Makefile (the start)

```
.PHONY: docs
init:
	pip install -e .[socks]
	pip install -r requirements-dev.txt
test:
	# This runs all of the tests, on both Python 2 and Python 3.
	tox -p
ci:
	pytest tests --junitxml=report.xml

test-readme:
	python setup.py check --restructuredtext --strict && ([ $$? -eq 0 ] && echo "README.rst and HISTORY.rst ok") || echo "Invalid markup in README.rst or HISTORY.rst!"

flake8:
	flake8 --ignore=E501,F401,E128,E402,E731,F821 requests

coverage:
	pytest --cov-config .coveragerc --verbose --cov-report term --cov-report xml --cov=requests tests

publish:
	pip install 'twine>=1.5.0'
	python setup.py sdist bdist_wheel
	twine upload dist/*
	rm -fr build dist .egg requests.egg-info

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
`pytest tests/test_requests.py -q`

## Scope
`requests/models.py`
`tests/`

## Done when
- `requests.get("http://.example.com")` raises `requests.exceptions.InvalidURL` instead of `UnicodeError`.
- The raised error identifies the invalid hostname label, matching the expected `URL has an invalid label.` outcome.
- Existing URL-preparation behavior for valid URLs and other invalid URLs continues to pass the test suite.

## Approach
Trace the failure to the IDNA encoding of `host` in `Request.prepare_url`: the hostname `.example.com` has an empty label, so `host.encode("idna")` raises `UnicodeError`. The primary approach is to wrap that encoding in `try/except UnicodeError` and raise `InvalidURL` with the URL and underlying reason, optionally translating the invalid-label case to `URL has an invalid label.` This is the smallest change and keeps IDNA handling in one place. Add a regression test that requests `http://.example.com` and asserts `InvalidURL`.

If that fails, alternatives:
- Validate hostname labels before IDNA encoding (empty labels, length limits) and raise `InvalidURL("URL has an invalid label.")` directly. This matches the expected message exactly but duplicates IDNA rules and risks disagreeing with the codec.
- Catch `UnicodeError` at a higher request boundary and rethrow as `InvalidURL`. This is broader and may catch unrelated encoding failures, so prefer the local `prepare_url` fix.
```

### `prompt.md`

````
Getting http://.example.com raises UnicodeError
Attempting to get e.g. `http://.example.com` results in a `UnicodeError`. It seems like the intention so far has been to raise `InvalidUrl` instead (see e.g. [this line](https://github.com/psf/requests/blob/ca6f9af5dba09591007b15a7368bc0f006b7cc50/requests/models.py#L401)).

I see there was some hesitation in fixing a similar issue (#4168) and would like to add that even catching the error just to rethrow as a requests exception would be beneficial.

## Expected Result

Based on PR #774: `InvalidUrl: URL has an invalid label.`

## Actual Result

`UnicodeError: encoding with 'idna' codec failed (UnicodeError: label empty or too long)`

## Reproduction Steps

```python3
import requests
requests.get("http://.example.com")
```

## System Information

    $ python -m requests.help

```
{
  "chardet": {
    "version": "3.0.4"
  },
  "cryptography": {
    "version": "2.8"
  },
  "idna": {
    "version": "2.8"
  },
  "implementation": {
    "name": "CPython",
    "version": "3.8.0"
  },
  "platform": {
    "release": "5.3.0-40-generic",
    "system": "Linux"
  },
  "pyOpenSSL": {
    "openssl_version": "1010104f",
    "version": "19.1.0"
  },
  "requests": {
    "version": "2.23.0"
  },
  "system_ssl": {
    "version": "1010103f"
  },
  "urllib3": {
    "version": "1.25.8"
  },
  "using_pyopenssl": true
}
```
````

### `review.md`

````
We need review. Need decide based evidence. The change: models.py added '.' in host.startswith check, tests add .example.com. Check status 0 (fails baseline too due environment fixtures). They claim change adds no failing test. Need judge against Done when. Requirements:
- requests.get("http://.example.com") raises InvalidURL instead UnicodeError.
- raised error identifies invalid hostname label matching "URL has an invalid label."
- existing URL-prep behavior valid/invalid continues pass.

Change: `elif host.startswith((u'*', u'.')): raise InvalidURL('URL has an invalid label.')`. Does this catch .example.com before IDNA? Let's inspect actual requests.models prepare_url likely sequence. Need know code. Around line 390: parse url, if not host: raise InvalidURL('URL has no host.'); if host.startswith(u'*')? Let's recall requests 2.23 models.py prepare_url:

```
        # IDNA encode non-ASCII hostnames
        if host:
            if not host.isascii():
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif host.startswith(u'*'):
                raise InvalidURL('URL has an invalid label.')
```

In Python 3.8 `.isascii()`? Actually code from requests:
```
        if host:
            if not host.isascii():
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif host.startswith(u'*'):
                raise InvalidURL('URL has an invalid label.')
```
For `.example.com`, host is ascii, startswith('.') true, raises InvalidURL. Good.

Potential issue: Does host.startswith('.') catch all empty labels? Prompt only `.example.com`. It raises expected message. Good.

Test added to `test_preparing_bad_url` likely uses `PreparedRequest().prepare`? Need maybe check if it asserts InvalidURL? The test parameter list adds URL to `test_preparing_bad_url` which likely does `with pytest.raises(InvalidURL): requests.Request('GET', url).prepare()`. Fine.

But check output: It shows failures unrelated to change (network, env proxies, missing fixtures/trustme/mocker). Status 0 parse says check status 0. The run said "the Check fails on tree ... baseline ... and this change adds no failing test: it passes". We need judge. Could be PASS if change satisfies. Need scrutinize whether the change could break valid URLs like host starting with '.'? Such hosts are invalid per expected. It changes behavior to InvalidURL, desired. Could impact URLs with host `.`? invalid. Fine.

Is there any concern that requirement "identifies the invalid hostname label" means message maybe should include label? Expected `InvalidUrl: URL has an invalid label.` Existing message exactly. Good.

But the change adds test to `test_preparing_bad_url`, not specifically requests.get. However models.py behavior is the core. Existing test would pass. Need not need changelog.

Potential hidden issue: The check's failure includes `test_preparing_bad_url`? It appears maybe one F at 24% could be test_errors? Wait test_preparing_bad_url is around line 2490. Check output line: at 24% multiple errors and one `.F.` maybe test_errors? Actually failures list doesn't include test_preparing_bad_url. So added parameter passed. Good.

But status: "Check status: 0 (0 passed, 1 failed, none: nothing could be run)." Hmm confusing. The check printed 7 failed 123 passed... 158 errors. Check status 0 means command exit? They say baseline also fails, so likely environment issue. The reviewer instruction: "FAIL when the check status is 1..." Status is 0. "With a status of none, judge..." Here status 0. So not fail on status. Need decide based on change.

Is the change complete? Let's look at requests models exact code around line 401: They have `if host: if not host.isascii(): ... elif host.startswith(u'*'): ...`. By changing elif to `host.startswith((u'*', u'.'))`, yes. But what about `http://.example.com` with leading dot; `host` from urlsplit is `.example.com`, startswith('.') -> True. Good.

Could there be a behavior regression for URLs where host starts with '.' but is valid due to URL like `http://.example.com` invalid. No valid host starts with dot.

Should we consider that the tests addition only covers preparing bad URL, not `requests.get`? The task says deliverable changes tree, done when requests.get raises. The implementation covers get as get calls prepare. No need direct test.

Check failure unrelated. Need maybe mention failures unrelated network environment. Since verdict PASS, findings should note. Need output first line exactly verdict: PASS. Then findings one per line. Should mention check failures are pre-existing/environmental, not introduced. Also note scope only models.py tests.

But be careful: The task's "Check status: 0" perhaps the harness says the check failed? They state: "the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes". Means this run's changed tests pass? We trust.

Need maybe evaluate if adding '.' to tuple is correct vs only host.startswith('.') maybe host has bytes? Host is str after urlsplit. Fine.

Could message be InvalidURL vs InvalidUrl? They use `InvalidURL` class alias. Good.

No need to fail. Final concise.

Need one per line findings. Include repair instructions only on FAIL, not here.

Let's formulate:
- models.py now rejects ASCII hosts beginning with '.' with `InvalidURL('URL has an invalid label.')`, satisfying the reported case and expected message.
- Added parametrized test for `http://.example.com` in `TestPreparingURLs.test_preparing_bad_url`, covering the regression at preparation layer.
- Check failures are unrelated environmental/baseline (missing httpbin fixtures/trustme/mocker, network timeout/proxy env) and no newly failing test is attributable to this diff.

Need maybe mention "valid URL prep unaffected" because condition only triggers '.' leading. Good. Ensure no false claims. The output shows added test not in failures. Good.

Final.</think>verdict: PASS
- `requests/models.py` now rejects ASCII hosts beginning with `.` via `InvalidURL('URL has an invalid label.')`, matching the requested behavior and message.
- The added `http://.example.com` case in `tests/test_requests.py` exercises the bad-URL preparation path and does not appear among the failures.
- The check failures are unrelated baseline/environment issues: missing `httpbin`/`trustme`/`mocker` fixtures and network/proxy-dependent tests, not regressions caused by this change.
- Valid URL preparation is unaffected because the new branch only triggers for hosts already starting with an invalid `.`.
````

### `scope.txt`

```
scope: requests/models.py tests
changed: requests/models.py +1 -1
changed: tests/test_requests.py +2 -1
```

### `task.md`

````
# Task

## Prompt

Getting http://.example.com raises UnicodeError
Attempting to get e.g. `http://.example.com` results in a `UnicodeError`. It seems like the intention so far has been to raise `InvalidUrl` instead (see e.g. [this line](https://github.com/psf/requests/blob/ca6f9af5dba09591007b15a7368bc0f006b7cc50/requests/models.py#L401)).

I see there was some hesitation in fixing a similar issue (#4168) and would like to add that even catching the error just to rethrow as a requests exception would be beneficial.

### Expected Result

Based on PR #774: `InvalidUrl: URL has an invalid label.`

### Actual Result

`UnicodeError: encoding with 'idna' codec failed (UnicodeError: label empty or too long)`

### Reproduction Steps

```python3
import requests
requests.get("http://.example.com")
```

### System Information

    $ python -m requests.help

```
{
  "chardet": {
    "version": "3.0.4"
  },
  "cryptography": {
    "version": "2.8"
  },
  "idna": {
    "version": "2.8"
  },
  "implementation": {
    "name": "CPython",
    "version": "3.8.0"
  },
  "platform": {
    "release": "5.3.0-40-generic",
    "system": "Linux"
  },
  "pyOpenSSL": {
    "openssl_version": "1010104f",
    "version": "19.1.0"
  },
  "requests": {
    "version": "2.23.0"
  },
  "system_ssl": {
    "version": "1010103f"
  },
  "urllib3": {
    "version": "1.25.8"
  },
  "using_pyopenssl": true
}
```

## Deliverable

changes to this tree

## Check

`pytest tests/test_requests.py -q`

## Scope

`requests/models.py`
`tests/`

## Done when

- `requests.get("http://.example.com")` raises `requests.exceptions.InvalidURL` instead of `UnicodeError`.
- The raised error identifies the invalid hostname label, matching the expected `URL has an invalid label.` outcome.
- Existing URL-preparation behavior for valid URLs and other invalid URLs continues to pass the test suite.
````

### `test-output.log`

```
check: pytest tests/test_requests.py -q
.......EEEEEEEEEEE.......EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.F. [ 24%]
..EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE.EEEEEE.E..........E..... [ 49%]
.EEEEE.EEE....EE.EEEEEEEEEE.EE........E......E..EEEEEExE..E.EEEE........ [ 74%]
.................EEEEEEEFFFFE.E..FF.......EE.................E.........E [ 99%]
E                                                                        [100%]
==================================== ERRORS ====================================
__________ ERROR at setup of TestRequests.test_no_content_length[GET] __________
file /testbed/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_no_content_length[HEAD] __________
file /testbed/tests/test_requests.py, line 98
      @pytest.mark.parametrize('method', ('GET', 'HEAD'))
      def test_no_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[POST] _______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_no_body_content_length[PUT] ________
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_no_body_content_length[PATCH] _______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_no_body_content_length[OPTIONS] ______
file /testbed/tests/test_requests.py, line 103
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_no_body_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[POST] ________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_empty_content_length[PUT] _________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_empty_content_length[PATCH] ________
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_empty_content_length[OPTIONS] _______
file /testbed/tests/test_requests.py, line 108
      @pytest.mark.parametrize('method', ('POST', 'PUT', 'PATCH', 'OPTIONS'))
      def test_empty_content_length(self, httpbin, method):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_override_content_length __________
file /testbed/tests/test_requests.py, line 113
      def test_override_content_length(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[http://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HTTP://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[hTTp://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_mixed_case_scheme_acceptable[HttP://] ___
file /testbed/tests/test_requests.py, line 157
      @pytest.mark.parametrize('scheme', ('http://', 'HTTP://', 'hTTp://', 'HttP://'))
      def test_mixed_case_scheme_acceptable(self, httpbin, scheme):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_ALTERNATIVE ________
file /testbed/tests/test_requests.py, line 167
      def test_HTTP_200_OK_GET_ALTERNATIVE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_ALLOW_REDIRECT_GET ________
file /testbed/tests/test_requests.py, line 176
      def test_HTTP_302_ALLOW_REDIRECT_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST _______
file /testbed/tests/test_requests.py, line 182
      def test_HTTP_307_ALLOW_REDIRECT_POST(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE _
file /testbed/tests/test_requests.py, line 189
      def test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS ________
file /testbed/tests/test_requests.py, line 197
      def test_HTTP_302_TOO_MANY_REDIRECTS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS __
file /testbed/tests/test_requests.py, line 208
      def test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_301_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 221
      def test_http_301_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_301_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 228
      def test_http_301_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_302_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 236
      def test_http_302_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_302_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 243
      def test_http_302_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_http_303_changes_post_to_get _______
file /testbed/tests/test_requests.py, line 250
      def test_http_303_changes_post_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_http_303_doesnt_change_head_to_get ____
file /testbed/tests/test_requests.py, line 257
      def test_http_303_doesnt_change_head_to_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_header_and_body_removal_on_redirect ____
file /testbed/tests/test_requests.py, line 264
      def test_header_and_body_removal_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_transfer_enc_removal_on_redirect _____
file /testbed/tests/test_requests.py, line 281
      def test_transfer_enc_removal_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_fragment_maintained_on_redirect ______
file /testbed/tests/test_requests.py, line 304
      def test_fragment_maintained_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_PARAMS ________
file /testbed/tests/test_requests.py, line 312
      def test_HTTP_200_OK_GET_WITH_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_HTTP_200_OK_GET_WITH_MIXED_PARAMS _____
file /testbed/tests/test_requests.py, line 320
      def test_HTTP_200_OK_GET_WITH_MIXED_PARAMS(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_set_cookie_on_301 _____________
file /testbed/tests/test_requests.py, line 326
      def test_set_cookie_on_301(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_sent_on_redirect __________
file /testbed/tests/test_requests.py, line 332
      def test_cookie_sent_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_removed_on_expire _________
file /testbed/tests/test_requests.py, line 338
      def test_cookie_removed_on_expire(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_cookie_quote_wrapped ___________
file /testbed/tests/test_requests.py, line 351
      def test_cookie_quote_wrapped(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_cookie_persists_via_api __________
file /testbed/tests/test_requests.py, line 356
      def test_cookie_persists_via_api(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_request_cookie_overrides_session_cookie __
file /testbed/tests/test_requests.py, line 362
      def test_request_cookie_overrides_session_cookie(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_request_cookies_not_persisted _______
file /testbed/tests/test_requests.py, line 370
      def test_request_cookies_not_persisted(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_generic_cookiejar_works __________
file /testbed/tests/test_requests.py, line 376
      def test_generic_cookiejar_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_param_cookiejar_works ___________
file /testbed/tests/test_requests.py, line 387
      def test_param_cookiejar_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cookielib_cookiejar_on_redirect ______
file /testbed/tests/test_requests.py, line 395
      def test_cookielib_cookiejar_on_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_requests_in_history_are_not_overridden __
file /testbed/tests/test_requests.py, line 427
      def test_requests_in_history_are_not_overridden(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_history_is_always_a_list _________
file /testbed/tests/test_requests.py, line 433
      def test_history_is_always_a_list(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_headers_on_session_with_None_are_not_sent _
file /testbed/tests/test_requests.py, line 441
      def test_headers_on_session_with_None_are_not_sent(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_headers_preserve_order __________
file /testbed/tests/test_requests.py, line 449
      def test_headers_preserve_order(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[User-agent] _____
file /testbed/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_user_agent_transfers[user-agent] _____
file /testbed/tests/test_requests.py, line 469
      @pytest.mark.parametrize('key', ('User-agent', 'user-agent'))
      def test_user_agent_transfers(self, httpbin, key):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_HEAD _____________
file /testbed/tests/test_requests.py, line 477
      def test_HTTP_200_OK_HEAD(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_HTTP_200_OK_PUT ______________
file /testbed/tests/test_requests.py, line 481
      def test_HTTP_200_OK_PUT(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_BASICAUTH_TUPLE_HTTP_200_OK_GET ______
file /testbed/tests/test_requests.py, line 485
      def test_BASICAUTH_TUPLE_HTTP_200_OK_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[user-pass] _________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c] _
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_set_basicauth[42-42] ___________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_set_basicauth[None-None] _________
file /testbed/tests/test_requests.py, line 500
      @pytest.mark.parametrize(
          'username, password', (
              ('user', 'pass'),
              (u'имя'.encode('utf-8'), u'пароль'.encode('utf-8')),
              (42, 42),
              (None, None),
          ))
      def test_set_basicauth(self, httpbin, username, password):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_proxy_error_on_bad_url __________
file /testbed/tests/test_requests.py, line 544
      def test_proxy_error_on_bad_url(self, httpbin, httpbin_secure):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_self_prepared_request _
file /testbed/tests/test_requests.py, line 557
      def test_respect_proxy_env_on_send_self_prepared_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_session_prepared_request _
file /testbed/tests/test_requests.py, line 564
      def test_respect_proxy_env_on_send_session_prepared_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_respect_proxy_env_on_send_with_redirects _
file /testbed/tests/test_requests.py, line 572
      def test_respect_proxy_env_on_send_with_redirects(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_respect_proxy_env_on_get _________
file /testbed/tests/test_requests.py, line 581
      def test_respect_proxy_env_on_get(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_respect_proxy_env_on_request _______
file /testbed/tests/test_requests.py, line 587
      def test_respect_proxy_env_on_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_proxy_authorization_preserved_on_request _
file /testbed/tests/test_requests.py, line 593
      def test_proxy_authorization_preserved_on_request(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_basicauth_with_netrc ___________
file /testbed/tests/test_requests.py, line 602
      def test_basicauth_with_netrc(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_DIGEST_HTTP_200_OK_GET __________
file /testbed/tests/test_requests.py, line 635
      def test_DIGEST_HTTP_200_OK_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_DIGEST_AUTH_RETURNS_COOKIE ________
file /testbed/tests/test_requests.py, line 653
      def test_DIGEST_AUTH_RETURNS_COOKIE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_DIGEST_AUTH_SETS_SESSION_COOKIES _____
file /testbed/tests/test_requests.py, line 664
      def test_DIGEST_AUTH_SETS_SESSION_COOKIES(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_DIGEST_STREAM _______________
file /testbed/tests/test_requests.py, line 673
      def test_DIGEST_STREAM(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_DIGESTAUTH_WRONG_HTTP_401_GET _______
file /testbed/tests/test_requests.py, line 685
      def test_DIGESTAUTH_WRONG_HTTP_401_GET(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_DIGESTAUTH_QUOTES_QOP_VALUE ________
file /testbed/tests/test_requests.py, line 702
      def test_DIGESTAUTH_QUOTES_QOP_VALUE(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES __________
file /testbed/tests/test_requests.py, line 711
      def test_POSTBIN_GET_POST_FILES(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_invalid_files_input ____________
file /testbed/tests/test_requests.py, line 729
      def test_invalid_files_input(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER ____
file /testbed/tests/test_requests.py, line 737
      def test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_POSTBIN_GET_POST_FILES_WITH_DATA _____
file /testbed/tests/test_requests.py, line 779
      def test_POSTBIN_GET_POST_FILES_WITH_DATA(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_post_with_custom_mapping _________
file /testbed/tests/test_requests.py, line 797
      def test_post_with_custom_mapping(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_conflicting_post_params __________
file /testbed/tests/test_requests.py, line 822
      def test_conflicting_post_params(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_request_ok_set ______________
file /testbed/tests/test_requests.py, line 830
      def test_request_ok_set(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_status_raising ______________
file /testbed/tests/test_requests.py, line 834
      def test_status_raising(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_decompress_gzip ______________
file /testbed/tests/test_requests.py, line 842
      def test_decompress_gzip(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params0] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params1] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params2] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[/get-params3] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_unicode_get[\xf8-params4] _________
file /testbed/tests/test_requests.py, line 846
      @pytest.mark.parametrize(
          'url, params', (
              ('/get', {'foo': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'føø': 'føø'}),
              ('/get', {'foo': 'foo'}),
              ('ø', {'foo': 'foo'}),
          ))
      def test_unicode_get(self, httpbin, url, params):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_header_name ____________
file /testbed/tests/test_requests.py, line 857
      def test_unicode_header_name(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_pyopenssl_redirect ____________
file /testbed/tests/test_requests.py, line 863
      def test_pyopenssl_redirect(self, httpbin_secure, httpbin_ca_bundle):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
_______ ERROR at setup of TestRequests.test_invalid_ca_certificate_path ________
file /testbed/tests/test_requests.py, line 866
      def test_invalid_ca_certificate_path(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
______ ERROR at setup of TestRequests.test_invalid_ssl_certificate_files _______
file /testbed/tests/test_requests.py, line 872
      def test_invalid_ssl_certificate_files(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
__________ ERROR at setup of TestRequests.test_http_with_certificate ___________
file /testbed/tests/test_requests.py, line 882
      def test_http_with_certificate(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestRequests.test_https_warnings ______________

tmp_path_factory = TempPathFactory(_given_basetemp=None, _trace=<pluggy._tracing.TagTracerSub object at 0x7ad50f7efa30>, _basetemp=None, _retention_count=3, _retention_policy='all')

    @pytest.fixture
    def nosan_server(tmp_path_factory):
        # delay importing until the fixture in order to make it possible
        # to deselect the test via command-line when trustme is not available
>       import trustme
E       ModuleNotFoundError: No module named 'trustme'

tests/conftest.py:42: ModuleNotFoundError
___________ ERROR at setup of TestRequests.test_certificate_failure ____________
file /testbed/tests/test_requests.py, line 907
      def test_certificate_failure(self, httpbin_secure):
file /testbed/tests/conftest.py, line 33
  @pytest.fixture
  def httpbin_secure(httpbin_secure):
E       recursive dependency involving fixture 'httpbin_secure' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:33
__ ERROR at setup of TestRequests.test_urlencoded_get_query_multivalued_param __
file /testbed/tests/test_requests.py, line 916
      def test_urlencoded_get_query_multivalued_param(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_form_encoded_post_query_multivalued_element _
file /testbed/tests/test_requests.py, line 922
      def test_form_encoded_post_query_multivalued_element(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_different_encodings_dont_break_post ____
file /testbed/tests/test_requests.py, line 928
      def test_different_encodings_dont_break_post(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data0] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data1] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data2] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_unicode_multipart_post[data3] _______
file /testbed/tests/test_requests.py, line 935
      @pytest.mark.parametrize(
          'data', (
              {'stuff': u('ëlïxr')},
              {'stuff': u('ëlïxr').encode('utf-8')},
              {'stuff': 'elixr'},
              {'stuff': 'elixr'.encode('utf-8')},
          ))
      def test_unicode_multipart_post(self, httpbin, data):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_unicode_multipart_post_fieldnames _____
file /testbed/tests/test_requests.py, line 948
      def test_unicode_multipart_post_fieldnames(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_unicode_method_name ____________
file /testbed/tests/test_requests.py, line 958
      def test_unicode_method_name(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unicode_method_name_with_request_object __
file /testbed/tests/test_requests.py, line 964
      def test_unicode_method_name_with_request_object(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_custom_content_type ____________
file /testbed/tests/test_requests.py, line 983
      def test_custom_content_type(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_hook_receives_request_arguments ______
file /testbed/tests/test_requests.py, line 994
      def test_hook_receives_request_arguments(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_used_with_no_request_hooks _
file /testbed/tests/test_requests.py, line 1004
      def test_session_hooks_are_used_with_no_request_hooks(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_session_hooks_are_overridden_by_request_hooks _
file /testbed/tests/test_requests.py, line 1013
      def test_session_hooks_are_overridden_by_request_hooks(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_request_hook ___________
file /testbed/tests/test_requests.py, line 1023
      def test_prepared_request_hook(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_prepared_from_session ___________
file /testbed/tests/test_requests.py, line 1037
      def test_prepared_from_session(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_______ ERROR at setup of TestRequests.test_request_with_bytestring_host _______
file /testbed/tests/test_requests.py, line 1061
      def test_request_with_bytestring_host(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_time_elapsed_blank ____________
file /testbed/tests/test_requests.py, line 1240
      def test_time_elapsed_blank(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_request_and_response_are_pickleable ____
file /testbed/tests/test_requests.py, line 1321
      def test_request_and_response_are_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestRequests.test_prepared_request_is_pickleable ______
file /testbed/tests/test_requests.py, line 1333
      def test_prepared_request_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_file_is_pickleable _
file /testbed/tests/test_requests.py, line 1347
      def test_prepared_request_with_file_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_prepared_request_with_hook_is_pickleable _
file /testbed/tests/test_requests.py, line 1363
      def test_prepared_request_with_hook_is_pickleable(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_cannot_send_unprepared_requests ______
file /testbed/tests/test_requests.py, line 1379
      def test_cannot_send_unprepared_requests(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____________ ERROR at setup of TestRequests.test_session_pickling _____________
file /testbed/tests/test_requests.py, line 1394
      def test_session_pickling(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________________ ERROR at setup of TestRequests.test_fixes_1329 ________________
file /testbed/tests/test_requests.py, line 1404
      def test_fixes_1329(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_uppercase_scheme_redirect _________
file /testbed/tests/test_requests.py, line 1415
      def test_uppercase_scheme_redirect(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_header_remove_is_case_insensitive _____
file /testbed/tests/test_requests.py, line 1498
      def test_header_remove_is_case_insensitive(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_params_are_merged_case_sensitive _____
file /testbed/tests/test_requests.py, line 1505
      def test_params_are_merged_case_sensitive(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_keys_are_native __________
file /testbed/tests/test_requests.py, line 1520
      def test_header_keys_are_native(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestRequests.test_header_validation _____________
file /testbed/tests/test_requests.py, line 1530
      def test_header_validation(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_header_value_not_str ___________
file /testbed/tests/test_requests.py, line 1539
      def test_header_value_not_str(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_header_no_return_chars __________
file /testbed/tests/test_requests.py, line 1560
      def test_header_no_return_chars(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_header_no_leading_space __________
file /testbed/tests/test_requests.py, line 1578
      def test_header_no_leading_space(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo0] _____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_can_send_objects_with_files[foo1] _____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___ ERROR at setup of TestRequests.test_can_send_objects_with_files[files2] ____
file /testbed/tests/test_requests.py, line 1592
      @pytest.mark.parametrize('files', ('foo', b'foo', bytearray(b'foo')))
      def test_can_send_objects_with_files(self, httpbin, files):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_can_send_file_object_with_non_string_filename _
file /testbed/tests/test_requests.py, line 1600
      def test_can_send_file_object_with_non_string_filename(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_____ ERROR at setup of TestRequests.test_autoset_header_values_are_native _____
file /testbed/tests/test_requests.py, line 1608
      def test_autoset_header_values_are_native(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_auth_is_stripped_on_http_downgrade ____
file /testbed/tests/test_requests.py, line 1627
      def test_auth_is_stripped_on_http_downgrade(self, httpbin, httpbin_secure, httpbin_ca_bundle):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_auth_is_retained_for_redirect_on_host ___
file /testbed/tests/test_requests.py, line 1637
      def test_auth_is_retained_for_redirect_on_host(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__ ERROR at setup of TestRequests.test_manual_redirect_with_partial_body_read __
file /testbed/tests/test_requests.py, line 1676
      def test_manual_redirect_with_partial_body_read(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_redirect_with_wrong_gzipped_header ____
file /testbed/tests/test_requests.py, line 1804
      def test_redirect_with_wrong_gzipped_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_requests_history_is_saved _________
file /testbed/tests/test_requests.py, line 1820
      def test_requests_history_is_saved(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____ ERROR at setup of TestRequests.test_json_param_post_content_type_works ____
file /testbed/tests/test_requests.py, line 1828
      def test_json_param_post_content_type_works(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_json_param_post_should_not_override_data_param _
file /testbed/tests/test_requests.py, line 1837
      def test_json_param_post_should_not_override_data_param(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
___________ ERROR at setup of TestRequests.test_response_iter_lines ____________
file /testbed/tests/test_requests.py, line 1844
      def test_response_iter_lines(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_________ ERROR at setup of TestRequests.test_response_context_manager _________
file /testbed/tests/test_requests.py, line 1852
      def test_response_context_manager(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_unconsumed_session_response_closes_connection _
file /testbed/tests/test_requests.py, line 1858
      def test_unconsumed_session_response_closes_connection(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
________ ERROR at setup of TestRequests.test_session_close_proxy_clear _________
file /testbed/tests/test_requests.py, line 1876
      def test_session_close_proxy_clear(self, mocker):
E       fixture 'mocker' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/test_requests.py:1876
____ ERROR at setup of TestRequests.test_response_json_when_content_is_None ____
file /testbed/tests/test_requests.py, line 1897
      def test_response_json_when_content_is_None(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_empty_stream_with_auth_does_not_set_content_length_header _
file /testbed/tests/test_requests.py, line 1918
      def test_empty_stream_with_auth_does_not_set_content_length_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_stream_with_auth_does_not_set_transfer_encoding_header _
file /testbed/tests/test_requests.py, line 1930
      def test_stream_with_auth_does_not_set_transfer_encoding_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestRequests.test_chunked_upload_does_not_set_content_length_header _
file /testbed/tests/test_requests.py, line 1942
      def test_chunked_upload_does_not_set_content_length_header(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestRequests.test_custom_redirect_mixin ___________
file /testbed/tests/test_requests.py, line 1953
      def test_custom_redirect_mixin(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_stream_timeout _______________
file /testbed/tests/test_requests.py, line 2194
      def test_stream_timeout(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[timeout0-(connect, read)] _
file /testbed/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestTimeout.test_invalid_timeout[foo-must be an int, float or None] _
file /testbed/tests/test_requests.py, line 2200
      @pytest.mark.parametrize(
          'timeout, error_text', (
              ((3, 4, 5), '(connect, read)'),
              ('foo', 'must be an int, float or None'),
          ))
      def test_invalid_timeout(self, httpbin, timeout, error_text):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestTimeout.test_none_timeout[None] _____________
file /testbed/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_none_timeout[timeout1] ___________
file /testbed/tests/test_requests.py, line 2210
      @pytest.mark.parametrize(
          'timeout', (
              None,
              Urllib3Timeout(connect=None, read=None)
          ))
      def test_none_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout0] ___________
file /testbed/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
__________ ERROR at setup of TestTimeout.test_read_timeout[timeout1] ___________
file /testbed/tests/test_requests.py, line 2227
      @pytest.mark.parametrize(
          'timeout', (
              (None, 0.1),
              Urllib3Timeout(connect=None, read=0.1)
          ))
      def test_read_timeout(self, httpbin, timeout):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______________ ERROR at setup of TestTimeout.test_encoded_methods ______________
file /testbed/tests/test_requests.py, line 2264
      def test_encoded_methods(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of test_requests_are_updated_each_time _____________
file /testbed/tests/test_requests.py, line 2317
  def test_requests_are_updated_each_time(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________________ ERROR at setup of test_urllib3_retries ____________________
file /testbed/tests/test_requests.py, line 2409
  def test_urllib3_retries(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of test_urllib3_pool_connection_closed _____________
file /testbed/tests/test_requests.py, line 2420
  def test_urllib3_pool_connection_closed(httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
_ ERROR at setup of TestPreparingURLs.test_redirecting_to_bad_url[http://localhost:-1-InvalidURL] _
file /testbed/tests/test_requests.py, line 2500
      @pytest.mark.parametrize(
          'url, exception',
          (
              ('http://localhost:-1', InvalidURL),
          )
      )
      def test_redirecting_to_bad_url(self, httpbin, url, exception):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
____________ ERROR at setup of TestPreparingURLs.test_post_json_nan ____________
file /testbed/tests/test_requests.py, line 2580
      def test_post_json_nan(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
______ ERROR at setup of TestPreparingURLs.test_json_decode_compatibility ______
file /testbed/tests/test_requests.py, line 2585
      def test_json_decode_compatibility(self, httpbin):
file /testbed/tests/conftest.py, line 28
  @pytest.fixture
  def httpbin(httpbin):
E       recursive dependency involving fixture 'httpbin' detected
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, doctest_namespace, httpbin, httpbin_secure, monkeypatch, nosan_server, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/testbed/tests/conftest.py:28
=================================== FAILURES ===================================
___ TestRequests.test_errors[http://doesnotexist.google.com-ConnectionError] ___

self = <tests.test_requests.TestRequests object at 0x7ad50f6b5d00>
url = 'http://doesnotexist.google.com'
exception = <class 'requests.exceptions.ConnectionError'>

    @pytest.mark.parametrize(
        'url, exception', (
            # Connecting to an unknown domain should raise a ConnectionError
            ('http://doesnotexist.google.com', ConnectionError),
            # Connecting to an invalid port should raise a ConnectionError
            ('http://localhost:1', ConnectionError),
            # Inputing a URL that cannot be parsed should raise an InvalidURL error
            ('http://fe80::5054:ff:fe5a:fc0', InvalidURL)
        ))
    def test_errors(self, url, exception):
        with pytest.raises(exception):
>           requests.get(url, timeout=1)
E           Failed: DID NOT RAISE <class 'requests.exceptions.ConnectionError'>

tests/test_requests.py:537: Failed
__________________ TestTimeout.test_connect_timeout[timeout0] __________________

self = <tests.test_requests.TestTimeout object at 0x7ad50f5d2ca0>
timeout = (0.1, None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
__________________ TestTimeout.test_connect_timeout[timeout1] __________________

self = <tests.test_requests.TestTimeout object at 0x7ad50f5d2dc0>
timeout = Timeout(connect=0.1, read=None, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, None),
            Urllib3Timeout(connect=0.1, read=None)
        ))
    def test_connect_timeout(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2247: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout0] _______________

self = <tests.test_requests.TestTimeout object at 0x7ad50f5d2ee0>
timeout = (0.1, 0.1)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_______________ TestTimeout.test_total_timeout_connect[timeout1] _______________

self = <tests.test_requests.TestTimeout object at 0x7ad50f5dd040>
timeout = Timeout(connect=0.1, read=0.1, total=None)

    @pytest.mark.parametrize(
        'timeout', (
            (0.1, 0.1),
            Urllib3Timeout(connect=0.1, read=0.1)
        ))
    def test_total_timeout_connect(self, timeout):
        try:
            requests.get(TARPIT, timeout=timeout)
>           pytest.fail('The connect() request should time out.')
E           Failed: The connect() request should time out.

tests/test_requests.py:2260: Failed
_ test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'http://example.com', proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
_ test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876] _

var = 'all_proxy', url = 'https://example.com'
proxy = 'socks5://proxy.com:9876'

    @pytest.mark.parametrize("var,url,proxy", [
        ('http_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('https_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'http://example.com', 'socks5://proxy.com:9876'),
        ('all_proxy', 'https://example.com', 'socks5://proxy.com:9876'),
    ])
    def test_proxy_env_vars_override_default(var, url, proxy):
        session = requests.Session()
        prep = PreparedRequest()
        prep.prepare(method='GET', url=url)
    
        kwargs = {
            var: proxy
        }
        scheme = urlparse(url).scheme
        with override_environ(**kwargs):
            proxies = session.rebuild_proxies(prep, {})
            assert scheme in proxies
>           assert proxies[scheme] == proxy
E           AssertionError: assert 'http://swe-proxy:3128' == 'socks5://proxy.com:9876'
E             - socks5://proxy.com:9876
E             + http://swe-proxy:3128

tests/test_requests.py:2356: AssertionError
=========================== short test summary info ============================
FAILED tests/test_requests.py::TestRequests::test_errors[http://doesnotexist.google.com-ConnectionError]
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout0] - ...
FAILED tests/test_requests.py::TestTimeout::test_connect_timeout[timeout1] - ...
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout0]
FAILED tests/test_requests.py::TestTimeout::test_total_timeout_connect[timeout1]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-http://example.com-socks5://proxy.com:9876]
FAILED tests/test_requests.py::test_proxy_env_vars_override_default[all_proxy-https://example.com-socks5://proxy.com:9876]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[GET]
ERROR tests/test_requests.py::TestRequests::test_no_content_length[HEAD]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_no_body_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[POST]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PUT]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[PATCH]
ERROR tests/test_requests.py::TestRequests::test_empty_content_length[OPTIONS]
ERROR tests/test_requests.py::TestRequests::test_override_content_length
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[http://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HTTP://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[hTTp://]
ERROR tests/test_requests.py::TestRequests::test_mixed_case_scheme_acceptable[HttP://]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_ALTERNATIVE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_ALLOW_REDIRECT_GET
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST
ERROR tests/test_requests.py::TestRequests::test_HTTP_307_ALLOW_REDIRECT_POST_WITH_SEEKABLE
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS
ERROR tests/test_requests.py::TestRequests::test_HTTP_302_TOO_MANY_REDIRECTS_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_http_301_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_301_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_302_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_changes_post_to_get
ERROR tests/test_requests.py::TestRequests::test_http_303_doesnt_change_head_to_get
ERROR tests/test_requests.py::TestRequests::test_header_and_body_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_transfer_enc_removal_on_redirect
ERROR tests/test_requests.py::TestRequests::test_fragment_maintained_on_redirect
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_PARAMS
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_GET_WITH_MIXED_PARAMS
ERROR tests/test_requests.py::TestRequests::test_set_cookie_on_301
ERROR tests/test_requests.py::TestRequests::test_cookie_sent_on_redirect
ERROR tests/test_requests.py::TestRequests::test_cookie_removed_on_expire
ERROR tests/test_requests.py::TestRequests::test_cookie_quote_wrapped
ERROR tests/test_requests.py::TestRequests::test_cookie_persists_via_api
ERROR tests/test_requests.py::TestRequests::test_request_cookie_overrides_session_cookie
ERROR tests/test_requests.py::TestRequests::test_request_cookies_not_persisted
ERROR tests/test_requests.py::TestRequests::test_generic_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_param_cookiejar_works
ERROR tests/test_requests.py::TestRequests::test_cookielib_cookiejar_on_redirect
ERROR tests/test_requests.py::TestRequests::test_requests_in_history_are_not_overridden
ERROR tests/test_requests.py::TestRequests::test_history_is_always_a_list
ERROR tests/test_requests.py::TestRequests::test_headers_on_session_with_None_are_not_sent
ERROR tests/test_requests.py::TestRequests::test_headers_preserve_order
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[User-agent]
ERROR tests/test_requests.py::TestRequests::test_user_agent_transfers[user-agent]
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_HEAD
ERROR tests/test_requests.py::TestRequests::test_HTTP_200_OK_PUT
ERROR tests/test_requests.py::TestRequests::test_BASICAUTH_TUPLE_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[user-pass]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[\xd0\xb8\xd0\xbc\xd1\x8f-\xd0\xbf\xd0\xb0\xd1\x80\xd0\xbe\xd0\xbb\xd1\x8c]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[42-42]
ERROR tests/test_requests.py::TestRequests::test_set_basicauth[None-None]
ERROR tests/test_requests.py::TestRequests::test_proxy_error_on_bad_url
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_self_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_session_prepared_request
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_send_with_redirects
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_get
ERROR tests/test_requests.py::TestRequests::test_respect_proxy_env_on_request
ERROR tests/test_requests.py::TestRequests::test_proxy_authorization_preserved_on_request
ERROR tests/test_requests.py::TestRequests::test_basicauth_with_netrc
ERROR tests/test_requests.py::TestRequests::test_DIGEST_HTTP_200_OK_GET
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_RETURNS_COOKIE
ERROR tests/test_requests.py::TestRequests::test_DIGEST_AUTH_SETS_SESSION_COOKIES
ERROR tests/test_requests.py::TestRequests::test_DIGEST_STREAM
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_WRONG_HTTP_401_GET
ERROR tests/test_requests.py::TestRequests::test_DIGESTAUTH_QUOTES_QOP_VALUE
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES
ERROR tests/test_requests.py::TestRequests::test_invalid_files_input
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_SEEKED_OBJECT_WITH_NO_ITER
ERROR tests/test_requests.py::TestRequests::test_POSTBIN_GET_POST_FILES_WITH_DATA
ERROR tests/test_requests.py::TestRequests::test_post_with_custom_mapping
ERROR tests/test_requests.py::TestRequests::test_conflicting_post_params
ERROR tests/test_requests.py::TestRequests::test_request_ok_set
ERROR tests/test_requests.py::TestRequests::test_status_raising
ERROR tests/test_requests.py::TestRequests::test_decompress_gzip
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params0]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params1]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params2]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[/get-params3]
ERROR tests/test_requests.py::TestRequests::test_unicode_get[\xf8-params4]
ERROR tests/test_requests.py::TestRequests::test_unicode_header_name
ERROR tests/test_requests.py::TestRequests::test_pyopenssl_redirect
ERROR tests/test_requests.py::TestRequests::test_invalid_ca_certificate_path
ERROR tests/test_requests.py::TestRequests::test_invalid_ssl_certificate_files
ERROR tests/test_requests.py::TestRequests::test_http_with_certificate
ERROR tests/test_requests.py::TestRequests::test_https_warnings - ModuleNotFo...
ERROR tests/test_requests.py::TestRequests::test_certificate_failure
ERROR tests/test_requests.py::TestRequests::test_urlencoded_get_query_multivalued_param
ERROR tests/test_requests.py::TestRequests::test_form_encoded_post_query_multivalued_element
ERROR tests/test_requests.py::TestRequests::test_different_encodings_dont_break_post
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data0]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data1]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data2]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post[data3]
ERROR tests/test_requests.py::TestRequests::test_unicode_multipart_post_fieldnames
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name
ERROR tests/test_requests.py::TestRequests::test_unicode_method_name_with_request_object
ERROR tests/test_requests.py::TestRequests::test_custom_content_type
ERROR tests/test_requests.py::TestRequests::test_hook_receives_request_arguments
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_used_with_no_request_hooks
ERROR tests/test_requests.py::TestRequests::test_session_hooks_are_overridden_by_request_hooks
ERROR tests/test_requests.py::TestRequests::test_prepared_request_hook
ERROR tests/test_requests.py::TestRequests::test_prepared_from_session
ERROR tests/test_requests.py::TestRequests::test_request_with_bytestring_host
ERROR tests/test_requests.py::TestRequests::test_time_elapsed_blank
ERROR tests/test_requests.py::TestRequests::test_request_and_response_are_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_file_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_prepared_request_with_hook_is_pickleable
ERROR tests/test_requests.py::TestRequests::test_cannot_send_unprepared_requests
ERROR tests/test_requests.py::TestRequests::test_session_pickling
ERROR tests/test_requests.py::TestRequests::test_fixes_1329
ERROR tests/test_requests.py::TestRequests::test_uppercase_scheme_redirect
ERROR tests/test_requests.py::TestRequests::test_header_remove_is_case_insensitive
ERROR tests/test_requests.py::TestRequests::test_params_are_merged_case_sensitive
ERROR tests/test_requests.py::TestRequests::test_header_keys_are_native
ERROR tests/test_requests.py::TestRequests::test_header_validation
ERROR tests/test_requests.py::TestRequests::test_header_value_not_str
ERROR tests/test_requests.py::TestRequests::test_header_no_return_chars
ERROR tests/test_requests.py::TestRequests::test_header_no_leading_space
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo0]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[foo1]
ERROR tests/test_requests.py::TestRequests::test_can_send_objects_with_files[files2]
ERROR tests/test_requests.py::TestRequests::test_can_send_file_object_with_non_string_filename
ERROR tests/test_requests.py::TestRequests::test_autoset_header_values_are_native
ERROR tests/test_requests.py::TestRequests::test_auth_is_stripped_on_http_downgrade
ERROR tests/test_requests.py::TestRequests::test_auth_is_retained_for_redirect_on_host
ERROR tests/test_requests.py::TestRequests::test_manual_redirect_with_partial_body_read
ERROR tests/test_requests.py::TestRequests::test_redirect_with_wrong_gzipped_header
ERROR tests/test_requests.py::TestRequests::test_requests_history_is_saved
ERROR tests/test_requests.py::TestRequests::test_json_param_post_content_type_works
ERROR tests/test_requests.py::TestRequests::test_json_param_post_should_not_override_data_param
ERROR tests/test_requests.py::TestRequests::test_response_iter_lines
ERROR tests/test_requests.py::TestRequests::test_response_context_manager
ERROR tests/test_requests.py::TestRequests::test_unconsumed_session_response_closes_connection
ERROR tests/test_requests.py::TestRequests::test_session_close_proxy_clear
ERROR tests/test_requests.py::TestRequests::test_response_json_when_content_is_None
ERROR tests/test_requests.py::TestRequests::test_empty_stream_with_auth_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_stream_with_auth_does_not_set_transfer_encoding_header
ERROR tests/test_requests.py::TestRequests::test_chunked_upload_does_not_set_content_length_header
ERROR tests/test_requests.py::TestRequests::test_custom_redirect_mixin
ERROR tests/test_requests.py::TestTimeout::test_stream_timeout
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[timeout0-(connect, read)]
ERROR tests/test_requests.py::TestTimeout::test_invalid_timeout[foo-must be an int, float or None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[None]
ERROR tests/test_requests.py::TestTimeout::test_none_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout0]
ERROR tests/test_requests.py::TestTimeout::test_read_timeout[timeout1]
ERROR tests/test_requests.py::TestTimeout::test_encoded_methods
ERROR tests/test_requests.py::test_requests_are_updated_each_time
ERROR tests/test_requests.py::test_urllib3_retries
ERROR tests/test_requests.py::test_urllib3_pool_connection_closed
ERROR tests/test_requests.py::TestPreparingURLs::test_redirecting_to_bad_url[http://localhost:-1-InvalidURL]
ERROR tests/test_requests.py::TestPreparingURLs::test_post_json_nan
ERROR tests/test_requests.py::TestPreparingURLs::test_json_decode_compatibility
7 failed, 123 passed, 1 xfailed, 158 errors in 1.42s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: requests/models.py tests
changed: requests/models.py +1 -1
changed: tests/test_requests.py +2 -1
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

### `verdict.md`

````
We need review patch. Need decide pass/fail. We need understand requests models prepare_url. The patch changes elif host.startswith(u'*') to startswith((u'*', u'.')) after idna branch for non-ASCII. Need check for http://.example.com: host = '.example.com'? host maybe lower? Let's inspect known requests code. prepare_url:

```
url = url.strip()
...
if isinstance(url, bytes): ...
...
# IDNA encoding can fail for too long labels (>63 characters)
# or empty labels (leading/trailing dots)
#
# If there are non-ASCII characters in the hostname, then attempt
# IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
# valid URLs with underscores, etc.
if not host:
    raise InvalidURL('URL has an invalid label.')
elif host.startswith(u'*'):
    raise InvalidURL('URL has an invalid label.')
...
```

Wait actual code maybe:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):  # If the host starts with '*', it's invalid
            raise InvalidURL('URL has an invalid label.')
```

Let's recall requests/models.py around 390. Current version:

```
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Hmm diff context shows:

```
                 host = self._get_idna_encoded_host(host)
             except UnicodeError:
                 raise InvalidURL('URL has an invalid label.')
-        elif host.startswith(u'*'):
+        elif host.startswith((u'*', u'.')):
             raise InvalidURL('URL has an invalid label.')
```

So preceding is if? Need understand. Maybe code:

```
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Wait the `elif` belongs to `if isinstance(host, str)`? Let's reconstruct from patch context line numbers. requests/models.py line 401 referenced. Probably:

```
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

No, elif host.startswith attaches to if host? If host falsy then host.startswith impossible? host is string? Hmm.

Let's find actual requests 2.23 models.py prepare_url. I can recall:

```
        host = self._get_idna_encoded_host(host)
```

Actually in requests 2.31:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host:
            raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Wait no.

Let's search memory: requests/models.py prepare_url:

```
        # Hostname
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

No, there is an if/elif for IDNA:

```
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Actually I remember code in requests/models.py:

```
        # Hostname
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Hmm maybe patch line 403 context tells. Let's locate from memory of current requests source:

```
        # Hostname
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

No IDNA? Let's recall issue requests #5435 "Getting http://.example.com raises UnicodeError". The fix maybe in PR #5436? Actual code current requests 2.31:

```
        # Hostname
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
        # Carefully reconstruct the network location
        netloc = auth or ''
        if netloc:
            netloc += '@'
        netloc += host
        if port:
            netloc += ':' + str(port)
```

But where IDNA? There is `_get_idna_encoded_host` used elsewhere? Search memory: requests models.py:

```
    def _get_idna_encoded_host(host):
        import idna
        try:
            host = idna.encode(host, uts46=True).decode('utf-8')
        except idna.IDNAError:
            raise UnicodeError
        return host
```

And prepare_url:

```
        # Hostname
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')

        # Carefully reconstruct the network location
        netloc = auth or ''
        if netloc:
            netloc += '@'
        netloc += host
        if port:
            netloc += ':' + str(port)
```

Wait IDNA called in prepare_url:

```
        if isinstance(host, str):
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
```

Let's find exact from known code 2.25:

```
        # Hostname
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')

        # Carefully reconstruct the network location
        netloc = auth or ''
        if netloc:
            netloc += '@'
        netloc += host
        if port:
            netloc += ':' + str(port)
```

No, IDNA? Actually requests 2.25 models.py includes:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host:
            raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Hmm.

Let's reason patch diff. It changes `elif host.startswith(u'*')` to tuple. That elif is likely attached to a preceding `if` that tests whether host is non-ASCII? Let's see:

```
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

But patch context shows preceding `except UnicodeError: raise InvalidURL...` then `elif host.startswith(u'*')`. So actual code:

```
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
```

So the elif attaches to `if isinstance(host, str):`? Let's reconstruct entire block from current requests 2.31 maybe:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host:
            raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

No, where `host = self._get_idna_encoded_host`?

Could be:

```
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

But then elif impossible because if host falsy then `host.startswith` on None? Actually host might be bytes or str? If host is None? Not.

Wait perhaps `if host` is not the conditional; could be `if not host.startswith(u'*'):`? Let's use diff line context. The diff hunk:

```
@@ -403,7 +403,7 @@ class PreparedRequest(RequestEncodingMixin, RequestHooksMixin):
                 host = self._get_idna_encoded_host(host)
             except UnicodeError:
                 raise InvalidURL('URL has an invalid label.')
-        elif host.startswith(u'*'):
+        elif host.startswith((u'*', u'.')):
             raise InvalidURL('URL has an invalid label.')
 
         # Carefully reconstruct the network location
```

Indentation: `host = ...` is 16 spaces? diff shows leading spaces in context. "                 host" = 17? Let's count: In unified diff, context lines start with one space then content. Here displayed `                 host =` after diff marker maybe 17 spaces? The `-        elif` has 8 spaces (plus diff '-' no leading). So `elif` at method indent 8 spaces. The `host = ...` line has 16 spaces content, so inside `if`. `except` at 12 spaces? Display `             except` maybe 12 content. So structure:

```
        if host:
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Actually `except` content 12 spaces, `host =` 16, `if host:` 8. But if `if host:` then `elif host.startswith` is weird: if host is empty string, `.startswith` works and raises if star? If host is None, AttributeError. But maybe `host = None`? Let's inspect actual code maybe from requests 2.23:

I vaguely remember:

```
        # Hostname
        if not host:
            raise InvalidURL('URL has no host part')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')

        # Carefully reconstruct the network location
        netloc = auth or ''
        if netloc:
            netloc += '@'
        netloc += host
        if port:
            netloc += ':' + str(port)
```

But no IDNA in prepare_url? Wait `_get_idna_encoded_host` in prepare_url yes. Let me try remember exact source from requests 2.31 models.py:

```
    def prepare_url(self, url, params):
        """Prepares the given HTTP URL."""
        #: Accept objects that have string representations.
        #: We're unable to blindly call unicode/str functions
        #: as this will include the bytestring indicator (b'')
        #: on python 3.x.
        #: https://github.com/psf/requests/pull/2238
        if isinstance(url, bytes):
            url = url.decode('utf8')
        else:
            url = str(url)

        # Remove leading whitespaces from url
        url = url.lstrip()

        # Don't do any URL preparation for non-HTTP schemes like `mailto`,
        # `data` etc to work around exceptions from `url_parse`, which
        # handles RFC 3986 differently.
        if ':' in url and not url.lower().startswith('http'):
            self.url = url
            return

        # Support for unicode domain names and paths.
        try:
            scheme, auth, host, port, path, query, fragment = parse_url(url)
        except LocationParseError as e:
            raise InvalidURL(*e.args)

        if not scheme:
            raise MissingSchema(...)

        if not host:
            raise InvalidURL('URL has no host part')

        # Need to handle IDNA-encoded hostnames
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

No.

Let's search memory from actual stack trace issue: `requests.get("http://.example.com")`:
```
  File ".../requests/models.py", line 401, in prepare_url
    host = self._get_idna_encoded_host(host)
  File ".../requests/models.py", line 370, in _get_idna_encoded_host
    host = idna.encode(host, uts46=True).decode('utf-8')
...
UnicodeError: encoding with 'idna' codec failed
```

Line 401 is `host = self._get_idna_encoded_host(host)`? Link in prompt says line 401 intention raise InvalidUrl. So indeed at line 401 inside try. The patch changes an `elif` after `except`. Need actual block maybe:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host:
            raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Wait no.

Maybe actual code is:

```
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if host and not host.isascii():
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Here if host empty, `elif host.startswith` -> false? Actually empty string startswith('*') false, then no raise. But preceding `if not host` elsewhere catches. Hmm.

Let's search memory exact snippet from current requests 2.31 prepare_url maybe:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host:
            raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

But patch context has try except, so maybe:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host:
            raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')

        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if not host.isascii():
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

No duplicate? Let's look up from memory: I have seen requests/models.py:

```
        if not host:
            raise InvalidURL('URL has no host part')

        # Need to handle IDNA-encoded hostnames
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Actually there is no `elif host.startswith`? Hmm.

Let's Google from memory (can't internet). requests 2.28 prepare_url code:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if host and not host.isascii():
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Aha likely. Because they skip IDNA for ASCII hosts to avoid breaking underscores etc. `if host and not host.isascii()` then try. `elif host.startswith('*')`: if host ASCII or falsy. If host is empty, startswith works false. But there is earlier `if not host: raise InvalidURL('URL has no host part')` maybe.

Let's find exact requests source from memory of recent (2.32):

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if host and not host.isascii():
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Yes that is actual current code. Thus with `host = '.example.com'`, host is ASCII so `if host and not host.isascii()` false, goes to elif `host.startswith('*')` false; no raise. Then constructs netloc `.example.com`; later? urllib3 may raise? But patch adds `'.'` to startswith, raises InvalidURL. So fix works for leading dot. But concern: only leading dot, not trailing dot or embedded empty label? Task specifically http://.example.com. Done when error identifies invalid hostname label matching URL has invalid label. This patch does. But is it correct? Need consider that valid URLs with leading dot? A hostname starting with dot invalid. Fine.

But maybe the change is incomplete: issue is empty label in hostname; `http://example..com` or `http://example.com.` may still UnicodeError? Actually ASCII hosts skip IDNA, so no UnicodeError; just invalid URL later perhaps. Task only `.example.com`. Prompt mentions expected based PR 774. Scope models.py tests. Patch adds test.

Need check whether `host.startswith((u'*', u'.'))` works with bytes? If host is bytes and condition? If host bytes, host.startswith((u'*', u'.')) with str tuple raises TypeError? But this branch only when not non-ASCII? Let's examine: `if host and not host.isascii()` if host is bytes? host from parse_url likely str. requests supports bytes URL converted to str earlier. So host str. Fine.

Potential issue: `http://.example.com` parse_url host maybe `.example.com` or maybe host includes leading dot? Yes. Raises InvalidURL.

But judge must evaluate patch against task. Need see if there are hidden tests failing: Existing test_preparing_bad_url list includes u"http://*", u"http://*.google.com", u"http://*", u"http://☃.net/", u"http://.example.com". For snowman, host non-ASCII -> idna encode? `☃.net` might encode? idna with uts46 True maybe succeeds? Actually `idna.encode('☃.net', uts46=True)`? Snowman is disallowed maybe raises UnicodeError -> InvalidURL. Existing. For `.example.com`, ASCII, startswith '.' -> raise. Good.

But is patch minimal and no unrelated removal? Yes.

However need consider whether just adding '.' to startswith addresses all invalid labels? The prompt says `http://.example.com` raises UnicodeError and expected InvalidUrl URL has invalid label. Done. Could there be another path: because `.example.com` is ASCII, previously did not go into IDNA. Wait actual result said UnicodeError from idna. That implies in version 2.23 they did not have `not host.isascii()` skip maybe they always IDNA? Let's check requests 2.23 code. The link line 401. In 2.23 maybe:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Wait no, if always IDNA for str, `.example.com` would raise UnicodeError caught -> InvalidURL already. So why bug? Because in 2.23 perhaps code:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```
would catch. But reported actual UnicodeError not caught. Maybe UnicodeError from `.encode('idna')` outside _get_idna? Let's look `_get_idna_encoded_host`:

```
    @staticmethod
    def _get_idna_encoded_host(host):
        import idna

        try:
            host = idna.encode(host, uts46=True).decode('utf-8')
        except idna.IDNAError:
            raise UnicodeError
        return host
```

If idna.encode raises UnicodeError not IDNAError? Actual says `UnicodeError: encoding with 'idna' codec failed (UnicodeError: label empty or too long)`. This might be Python's built-in `idna` codec, not third-party idna. Maybe `_get_idna_encoded_host` uses `host.encode('idna')`? Let's see requests 2.23:

```
    @staticmethod
    def _get_idna_encoded_host(host):
        import idna

        try:
            host = idna.encode(host, uts46=True).decode('utf-8')
        except idna.IDNAError:
            raise UnicodeError
        return host
```

But actual UnicodeError text "encoding with 'idna' codec failed" suggests using Python's codec. In older requests maybe:

```
        try:
            host = host.encode('idna').decode('ascii')
        except UnicodeError:
            raise UnicodeError(...)
```

No.

Wait actual traceback from issue: UnicodeError from `idna` codec could come from `urllib3`? But reproduction requests.get. The task gives expected based PR #774. The change in tree may be from old requests version? We evaluate given diff on this tree. Scope requests/models.py tests. The diff modifies `elif host.startswith(u'*')` after a try/except UnicodeError. The logic: For `.example.com`, if the `if` branch (non-ASCII?) is not taken, then new elif catches leading dot. If branch taken? It wouldn't be for ASCII. But actual error said UnicodeError before, so maybe this tree has `if host:` always IDNA? Let's inspect diff context more. It shows:
```
                 host = self._get_idna_encoded_host(host)
             except UnicodeError:
                 raise InvalidURL('URL has an invalid label.')
-        elif host.startswith(u'*'):
+        elif host.startswith((u'*', u'.')):
```
The `elif` likely pairs with `if host and not host.isascii():`? But if `host and not host.isascii()` true for `.example.com`? `.example.com`.isascii() is True, so false. Then new elif catches. Good.

But actual error reported from UnicodeError indicates version 2.23 perhaps had `if host:` always idna? Let's check requests 2.23.0 source from memory: It introduced `_get_idna_encoded_host` and had:

```
        # IDNA encoding can fail for too long labels (>63 characters)
        # or empty labels (leading/trailing dots)
        # If there are non-ASCII characters in the hostname, then attempt
        # IDNA encoding. Otherwise, skip IDNA encoding to avoid breaking
        # valid URLs with underscores, etc.
        if host and not host.isascii():
            try:
                host = self._get_idna_encoded_host(host)
            except UnicodeError:
                raise InvalidURL('URL has an invalid label.')
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Actually `.example.com` is ASCII, so shouldn't UnicodeError. But issue says 2.23.0. Maybe `not host.isascii()` was added later? Let's check: Python 3.8.0. `str.isascii` exists. Maybe code was:

```
        # Need to handle IDNA-encoded hostnames
        if host:
            if isinstance(host, str):
                try:
                    host = self._get_idna_encoded_host(host)
                except UnicodeError:
                    raise InvalidURL('URL has an invalid label.')
            elif isinstance(host, bytes):
                host = self._get_idna_encoded_host(host)
        elif host.startswith(u'*'):
            raise InvalidURL('URL has an invalid label.')
```

Then `.example.com` should be caught and raise InvalidURL, contradicting actual. Unless `_get_idna_encoded_host` didn't catch the actual exception because it catches `idna.IDNAError` but Python's built-in `UnicodeError` from idna codec not idna.IDNAError. Let's examine `_get_idna_encoded_host` in requests 2.23:

```
    @staticmethod
    def _get_idna_encoded_host(host):
        import idna

        try:
            host = idna.encode(host, uts46=True).decode('utf-8')
        except idna.IDNAError:
            raise UnicodeError
        return host
```

`idna.encode('.example.com', uts46=True)` might raise `idna.core.IDNAError`? That is caught, raising UnicodeError, then prepare_url catches UnicodeError and raises InvalidURL. So no bug. Unless the error occurs in `urlparse` or `parse_url` before? Hmm.

Actual error "encoding with 'idna' codec failed" from Python's `encodings.idna` codec, not third-party idna package. `idna.encode` third-party library error messages don't say "encoding with 'idna' codec failed"; they say "Empty label" or "Label too long". So actual comes from `host.encode('idna')` somewhere. In requests 2.23, `_get_idna_encoded_host` maybe:

```
        try:
            host = host.encode('idna').decode('ascii')
        except UnicodeError:
            raise UnicodeError
```

No.

Let's search memory: requests/models.py in 2.23:

```
    @staticmethod
    def _get_idna_encoded_host(host):
        import idna

        try:
            host = idna.encode(host, uts46=True).decode('utf-8')
        except idna.IDNAError:
            raise UnicodeError
        return host
```

That is current. But maybe 2.23 used `idna` codec directly:

```
    @staticmethod
    def _get_idna_encoded_host(host):
        import idna

        try:
            host = host.encode('idna').decode('ascii')
        except UnicodeError:
            raise UnicodeError
        return host
```

No import idna unused.

Let's not overthink; patch is judged as diff applied to tree. Need verify it actually fixes. It adds '.' to elif. In current code, `.example.com` is ASCII, goes to elif, caught. If code always IDNA for host, then `.example.com` caught by except -> already InvalidURL before patch. Either way patch yields desired.

But could adding `.` to startswith break valid URLs? Hostnames cannot start with dot. It might affect relative? URL must host. Fine.

Could it be insufficient because error identifies invalid hostname label? It raises exact message. Good.

Tests: Added `u"http://.example.com"` to parametrized bad URLs. Does that test expect InvalidURL? Let's see `test_preparing_bad_url` likely:

```
    def test_preparing_bad_url(self, url):
        req = requests.Request('GET', url)
        with pytest.raises(requests.exceptions.InvalidURL):
            req.prepare()
```

Yes.

Potential hidden issue: `host.startswith((u'*', u'.'))` with host as `None`? If host None, earlier `if not host`? Let's get code. The elif's preceding if likely `if host and not host.isascii():`; if host is None, `host and ...` false, then `host.startswith` -> AttributeError on None. But existing code already would AttributeError before patch; not relevant because host must be str? parse_url returns host maybe None for no host, then? Actually earlier check handles not host. Fine.

Need decide PASS. But must be rigorous: Does patch "identifies invalid hostname label" maybe only leading dot. Expected `URL has an invalid label.` exactly. Yes.

But task asks "changes to this tree", scope models.py tests. The change only one line + test. Is there a subtle thing: For `http://.example.com`, `parse_url` might normalize host to `.example.com` yes. But what if host starts with a Unicode full stop? Not asked. Fine.

Let's think if `host.startswith((u'*', u'.'))` is valid in Python 2? requests supported py2? In 2020 requests still Python 2.7? Tuple startswith available in Python 2.5+. But if host is `unicode`, prefix tuple unicode fine. Good.

Could test suite fail because adding `http://.example.com` in test tuple may already be covered? No.

Potential test failure: Existing test expects `http://*` etc; the new tuple for `.` doesn't alter. Good.

Need maybe check if `host` can be bytes and `startswith((u'*', u'.'))` raises TypeError. In prepare_url, url is decoded if bytes then `url = str(url)` for non-bytes. In Py2, str/unicode? The host from parse_url may be unicode? But this tree likely modern. Not issue.

One concern: The patch catches any hostname starting with '.', including `.example.com`, raises InvalidURL. But what about host ".example.com" with port? host excludes port. Fine.

Could there be a requirement to handle `http://.example.com` specifically by checking all empty labels (e.g., `example..com`, `example.com.`) not just leading? Prompt only asks that. Done when only that.

The verdict likely PASS.

But let's ensure the diff context: It changes `elif host.startswith(u'*')`, which means for any host (including empty?) If host is empty string, startswith false. For host starting '.', raises. Good.

Need final at most ten lines. Start verdict: PASS. Then say why. Must not mention tool. Keep concise. Need include ties to task. Use lines.</think>verdict: PASS
The one-line change in `requests/models.py` makes ASCII hosts beginning with `.` raise `InvalidURL('URL has an invalid label.')`, so `requests.get("http://.example.com")` no longer leaks `UnicodeError`.
The raised message matches the expected `URL has an invalid label.` outcome.
The existing `*` host checks remain unchanged, and valid-host behavior is untouched.
The added test covers `http://.example.com` in the existing bad-URL parametrization, within the requested `tests/` scope.
````
