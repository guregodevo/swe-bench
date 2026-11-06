# psf__requests-5414 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 36s 26 lines cost=0.001907 in=92349 cached=66048 out=2661 calls=11`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

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

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && git log --oneline -5"
}
```

**assistant → tool `grep`**

```json
{
  "pattern": "invalid label|InvalidURL|idna",
  "glob": "*.py",
  "output_mode": "content",
  "head_limit": 50
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
?? .memdoor/
af3e243e SWE-bench
39d0fdd9 Update README.md (#5998)
c193d974 Merge pull request #5993 from davisagli/tox-parallel
8e764f35 Run tox in parallel using -p instead of detox
7556ea42 Merge pull request #5391 from hodbn/fix-5274
```

**tool result**

```
/testbed/build/lib/requests/adapters.py:                         InvalidURL, InvalidHeader)
/testbed/build/lib/requests/adapters.py:            raise InvalidURL(e, request=request)
/testbed/build/lib/requests/exceptions.py:class InvalidURL(RequestException, ValueError):
/testbed/build/lib/requests/exceptions.py:class InvalidProxyURL(InvalidURL):
/testbed/build/lib/requests/help.py:import idna
/testbed/build/lib/requests/help.py:    idna_info = {
/testbed/build/lib/requests/help.py:        'version': getattr(idna, '__version__', ''),
/testbed/build/lib/requests/help.py:        'idna': idna_info,
/testbed/build/lib/requests/models.py:import encodings.idna
/testbed/build/lib/requests/models.py:    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
/testbed/build/lib/requests/models.py:    def _get_idna_encoded_host(host):
/testbed/build/lib/requests/models.py:        import idna
/testbed/build/lib/requests/models.py:            host = idna.encode(host, uts46=True).decode('utf-8')
/testbed/build/lib/requests/models.py:        except idna.IDNAError:
/testbed/build/lib/requests/models.py:            raise InvalidURL(*e.args)
/testbed/build/lib/requests/models.py:            raise InvalidURL("Invalid URL %r: No host supplied" % url)
/testbed/build/lib/requests/models.py:                host = self._get_idna_encoded_host(host)
/testbed/build/lib/requests/models.py:                raise InvalidURL('URL has an invalid label.')
/testbed/build/lib/requests/models.py:            raise InvalidURL('URL has an invalid label.')
/testbed/build/lib/requests/packages.py:for package in ('urllib3', 'idna'):
/testbed/build/lib/requests/utils.py:    InvalidURL, InvalidHeader, FileModeWarning, UnrewindableBodyError)
/testbed/build/lib/requests/utils.py:                raise InvalidURL("Invalid percent-escape sequence: '%s'" % h)
/testbed/build/lib/requests/utils.py:    except InvalidURL:
/testbed/requests/adapters.py:                         InvalidURL, InvalidHeader)
/testbed/requests/adapters.py:            raise InvalidURL(e, request=request)
/testbed/requests/exceptions.py:class InvalidURL(RequestException, ValueError):
/testbed/requests/exceptions.py:class InvalidProxyURL(InvalidURL):
/testbed/requests/help.py:import idna
/testbed/requests/help.py:    idna_info = {
/testbed/requests/help.py:        'version': getattr(idna, '__version__', ''),
/testbed/requests/help.py:        'idna': idna_info,
/testbed/requests/models.py:import encodings.idna
/testbed/requests/models.py:    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
/testbed/requests/models.py:    def _get_idna_encoded_host(host):
/testbed/requests/models.py:        import idna
/testbed/requests/models.py:            host = idna.encode(host, uts46=True).decode('utf-8')
/testbed/requests/models.py:        except idna.IDNAError:
/testbed/requests/models.py:            raise InvalidURL(*e.args)
/testbed/requests/models.py:            raise InvalidURL("Invalid URL %r: No host supplied" % url)
/testbed/requests/models.py:                host = self._get_idna_encoded_host(host)
/testbed/requests/models.py:                raise InvalidURL('URL has an invalid label.')
/testbed/requests/models.py:            raise InvalidURL('URL has an invalid label.')
/testbed/requests/packages.py:for package in ('urllib3', 'idna'):
/testbed/requests/utils.py:    InvalidURL, InvalidHeader, FileModeWarning, UnrewindableBodyError)
/testbed/requests/utils.py:                raise InvalidURL("Invalid percent-escape sequence: '%s'" % h)
/testbed/requests/utils.py:    except InvalidURL:
/testbed/setup.py:    'idna>=2.5,<3; python_version < "3"',
/testbed/setup.py:    'idna>=2.5,<4; python_version >= "3"',
/testbed/tests/test_help.py:def test_idna_without_version_attribute(mocker):
/testbed/tests/test_help.py:    mocker.patch('requests.help.idna', new=None)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"_get_idna_encoded_host\\|invalid label\\|InvalidURL\" requests/models.py; sed -n '380,420p' requests/models.py; git diff --stat"
}
```

**tool result**

```
31:    HTTPError, MissingSchema, InvalidURL, ChunkedEncodingError,
351:    def _get_idna_encoded_host(host):
386:            raise InvalidURL(*e.args)
395:            raise InvalidURL("Invalid URL %r: No host supplied" % url)
403:                host = self._get_idna_encoded_host(host)
405:                raise InvalidURL('URL has an invalid label.')
407:            raise InvalidURL('URL has an invalid label.')
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
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"invalid label\\|\\.example\\.com\\|\\*\\.example\\|startswith\" tests/test_requests.py tests/ | head -30"
}
```

**tool result**

```
tests/test_requests.py:1466:        url_not_matching_prefix = 'https://another.example.com/'
tests/test_requests.py:1646:        assert s.should_strip_auth('http://example.com/foo', 'http://another.example.com/')
tests/test_requests.py:2311:        url='https://www.example.com/',
tests/test_requests.py:2372:        url='http://www.example.com',
tests/test_requests.py:2384:            'url': 'http://www.example.com',
tests/test_requests.py:2390:            'url': 'http://www.example.com',
tests/test_requests.py:2397:            'url': u('http://www.example.com/üniçø∂é')
tests/test_utils.py:215:        monkeypatch.setenv('http_proxy', 'http://proxy.example.com:3128/')
tests/test_requests.py:1466:        url_not_matching_prefix = 'https://another.example.com/'
tests/test_requests.py:1646:        assert s.should_strip_auth('http://example.com/foo', 'http://another.example.com/')
tests/test_requests.py:2311:        url='https://www.example.com/',
tests/test_requests.py:2372:        url='http://www.example.com',
tests/test_requests.py:2384:            'url': 'http://www.example.com',
tests/test_requests.py:2390:            'url': 'http://www.example.com',
tests/test_requests.py:2397:            'url': u('http://www.example.com/üniçø∂é')
tests/test_lowlevel.py:151:        assert request_content.startswith(b"GET / HTTP/1.1")
tests/test_lowlevel.py:182:        assert r.request.headers['Authorization'].startswith('Digest ')
tests/test_lowlevel.py:207:        assert request_content.startswith(b"GET / HTTP/1.1")
tests/test_lowlevel.py:250:        assert request_content.startswith(b"GET / HTTP/1.1")
tests/test_lowlevel.py:330:        assert redirect_request[0].startswith(b'GET /' + expected_path + b' HTTP/1.1')
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"invalid_url\\|InvalidURL\\|invalid label\\|unicode\" tests/test_requests.py | head -40"
}
```

**tool result**

```
25:    ConnectionError, ConnectTimeout, InvalidSchema, InvalidURL,
83:            (InvalidURL, 'http://'),
85:    def test_invalid_url(self, exception, url):
518:        than the unicode string "b'test'" in Python 3.
532:            # Inputing a URL that cannot be parsed should raise an InvalidURL error
533:            ('http://fe80::5054:ff:fe5a:fc0', InvalidURL)
854:    def test_unicode_get(self, httpbin, url, params):
857:    def test_unicode_header_name(self, httpbin):
861:            data='\xff')  # compat.str is unicode.
942:    def test_unicode_multipart_post(self, httpbin, data):
948:    def test_unicode_multipart_post_fieldnames(self, httpbin):
958:    def test_unicode_method_name(self, httpbin):
964:    def test_unicode_method_name_with_request_object(self, httpbin):
1262:    def test_response_decode_unicode(self):
1263:        """When called with decode_unicode, Response.iter_content should always
1264:        return unicode.
1271:        chunks = r.iter_content(decode_unicode=True)
1278:        chunks = r.iter_content(decode_unicode=True)
1281:    def test_response_reason_unicode(self):
1282:        # check for unicode HTTP status
1284:        r.url = u'unicode URL'
1290:    def test_response_reason_unicode_fallback(self):
1521:        headers = {u('unicode'): 'blah', 'byte'.encode('ascii'): 'blah'}
1527:        assert 'unicode' in p.headers.keys()
2496:        with pytest.raises(requests.exceptions.InvalidURL):
2502:            ('http://localhost:-1', InvalidURL),
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '60,100p' tests/test_requests.py; sed -n '2480,2530p' tests/test_requests.py; sed -n '340,360p' requests/models.py"
}
```

**tool result**

```
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
        assert pr.body == 'life=42'

    @pytest.mark.parametrize('method', ('GET', 'HEAD'))
    def test_no_content_length(self, httpbin, method):
        req = requests.Request(method, httpbin(method.lower())).prepare()
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
                b"mailto:user@example.org",
                u"mailto:user@example.org",
            ),
            (
                u"mailto:user@example.org",
                u"mailto:user@example.org",
            ),
            (
                b"data:SSDimaUgUHl0aG9uIQ==",
                u"data:SSDimaUgUHl0aG9uIQ==",
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
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"import requests; requests.get('http://.example.com')\" 2>&1 | tail -20"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "pwd; python -c \"import requests; print(requests.__file__); print(requests.get('http://.example.com'))\" 2>&1 | tail -25"
}
```

**tool result**

```
/testbed
/testbed/requests/__init__.py
<Response [403]>
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: requests/models.py\n@@\n-        elif host.startswith(u'*'):\n+        elif host.startswith((u'*', u'.')):\n+            # Cannot use '*' or '.' as a valid label.\n             raise InvalidURL('URL has an invalid label.')\n*** Update File: tests/test_requests.py\n@@\n             u\"http://*.google.com\",\n             u\"http://*\",\n+            u\"http://.example.com\",\n             u\"http://☃.net/\"\n         )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[requests/models.py tests/test_requests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

requests/models.py now (974 lines), around the change:
403:                host = self._get_idna_encoded_host(host)
404:            except UnicodeError:
405:                raise InvalidURL('URL has an invalid label.')
406:        elif host.startswith((u'*', u'.')):
407:            # Cannot use '*' or '.' as a valid label.
408:            raise InvalidURL('URL has an invalid label.')
409:
410:        # Carefully reconstruct the network location

tests/test_requests.py now (2588 lines), around the change:
2488:            b"http://*",
2489:            u"http://*.google.com",
2490:            u"http://*",
2491:            u"http://.example.com",
2492:            u"http://☃.net/"
2493:        )
2494:    )
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"import requests\ntry:\n    requests.get('http://.example.com')\nexcept Exception as e:\n    print(type(e).__name__, e)\" && python -m pytest tests/test_requests.py -k \"preparing_bad_url or invalid_url\" -q 2>&1 | tail -15"
}
```

**tool result**

```
InvalidURL URL has an invalid label.
...........                                                              [100%]
11 passed, 278 deselected in 0.48s
```

**assistant → tool `bash`**

```json
{
  "command": "git status --porcelain -- . ':(exclude).memdoor'; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\"; echo exit=$?"
}
```

**tool result**

```
 M requests/models.py
 M tests/test_requests.py
exit=0
```

**assistant**

```
Done.

`http://.example.com` now raises `InvalidURL: URL has an invalid label.` instead of leaking a `UnicodeError` from the IDNA codec.

Changes:
- `requests/models.py`: reject hosts starting with `.` (in addition to `*`) before attempting IDNA encoding.
- `tests/test_requests.py`: added `http://.example.com` to the bad-URL preparation test.

Verified the reproduction raises `InvalidURL`, relevant tests pass (11 passed), and the completion command exits 0.
```

## Run folder `single-2026-11-06T114203`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

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
