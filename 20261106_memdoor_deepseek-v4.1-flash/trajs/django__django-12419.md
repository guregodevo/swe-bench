# django__django-12419 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 101s 63 lines cost=0.006080 in=303639 cached=199168 out=7462 calls=21`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Add secure default SECURE_REFERRER_POLICY / Referrer-policy header
Description
	
#29406 added the ability for the SECURE_REFERRER_POLICY setting to set Referrer-Policy, released in Django 3.0.
I propose we change the default for this to "same-origin" to make Django applications leak less information to third party sites.
The main risk of breakage here would be linked websites breaking, if they depend on verification through the Referer header. This is a pretty fragile technique since it can be spoofed.
Documentation: ​https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
The MDN support grid is out of date: ​https://caniuse.com/#search=Referrer-Policy

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain | head -50 && git log --oneline -3"
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
scripts
setup.cfg
setup.py
tests
tox.ini
?? .memdoor/
98cc670801 SWE-bench
7fa1a93c6c Refs #28214 -- Added test for escaping JSONField key lookups.
de1924e0e7 Improved grammar in 3.0 release notes for SECURE_CONTENT_TYPE_NOSNIFF change.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"SECURE_REFERRER_POLICY\\|Referrer-Policy\\|referrer_policy\" django docs tests | head -50"
}
```

**tool result**

```
grep: django/conf/locale/az/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/pt_BR/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/lv/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/nl/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/de/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/ca/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/sq/LC_MESSAGES/django.mo: binary file matches
django/conf/global_settings.py:640:SECURE_REFERRER_POLICY = None
django/conf/locale/az/LC_MESSAGES/django.po:1149:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/az/LC_MESSAGES/django.po:1155:"“Referrer-Policy: no-referrer” başlığını işlədirsinizsə, lütfən silin. CSRF "
django/conf/locale/pt_BR/LC_MESSAGES/django.po:1172:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/pt_BR/LC_MESSAGES/django.po:1178:"incluindo o cabeçalho “Referrer-Policy: no-referrer”, por favor remova-os. A "
django/conf/locale/hr/LC_MESSAGES/django.po:1157:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/ur/LC_MESSAGES/django.po:1111:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/lv/LC_MESSAGES/django.po:1174:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/lv/LC_MESSAGES/django.po:1180:"iekļaujat “Referrer-Policy: no-referrer” headeri, lūdzu noņemiet tos. CSRF "
django/conf/locale/ia/LC_MESSAGES/django.po:1128:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/io/LC_MESSAGES/django.po:1118:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/nl/LC_MESSAGES/django.po:1163:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/nl/LC_MESSAGES/django.po:1169:"header ‘Referrer-Policy: no-referrer’ opneemt, verwijder deze dan. De CSRF-"
django/conf/locale/de/LC_MESSAGES/django.po:1169:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/de/LC_MESSAGES/django.po:1175:"„Referrer-Policy: no-referrer“-Header verwendet wird, entfernen Sie sie "
django/conf/locale/ml/LC_MESSAGES/django.po:1125:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/kn/LC_MESSAGES/django.po:1119:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/ru/LC_MESSAGES/django.po:1186:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/hi/LC_MESSAGES/django.po:1107:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/hsb/LC_MESSAGES/django.po:1181:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/ca/LC_MESSAGES/django.po:1164:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/ca/LC_MESSAGES/django.po:1170:"inclou la capçalera  'Referrer-Policy: no-referrer' , si et plau elimina-la. "
django/conf/locale/th/LC_MESSAGES/django.po:1095:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/os/LC_MESSAGES/django.po:1122:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/it/LC_MESSAGES/django.po:1140:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/sl/LC_MESSAGES/django.po:1174:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/sq/LC_MESSAGES/django.po:1159:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/sq/LC_MESSAGES/django.po:1165:"etiketën ose përfshini kryet “Referrer-Policy: no-referrer”, ju lutemi, "
django/conf/locale/he/LC_MESSAGES/django.po:1148:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/ga/LC_MESSAGES/django.po:1163:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/zh_Hans/LC_MESSAGES/django.po:1115:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/ar/LC_MESSAGgrep: django/conf/locale/sr/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/be/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/hu/LC_MESSAGES/django.mo: binary file matches
grep: django/conf/locale/uz/LC_MESSAGES/django.mo: binary file matches
ES/django.po:1206:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/sr/LC_MESSAGES/django.po:1173:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/sr/LC_MESSAGES/django.po:1179:"\"Referrer-Policy: no-referrer\" заглавље, молимо да их уклоните. CSRF "
django/conf/locale/bg/LC_MESSAGES/django.po:1131:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/nn/LC_MESSAGES/django.po:1110:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/fy/LC_MESSAGES/django.po:1107:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/es_CO/LC_MESSAGES/django.po:1125:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/br/LC_MESSAGES/django.po:1157:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/mn/LC_MESSAGES/django.po:1133:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/be/LC_MESSAGES/django.po:1197:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/be/LC_MESSAGES/django.po:1203:"ці дадалі загаловак “Referrer-Policy: no-referrer”, калі ласка выдаліце іх. "
django/conf/locale/fa/LC_MESSAGES/django.po:1127:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/zh_Hant/LC_MESSAGES/django.po:1098:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/ja/LC_MESSAGES/django.po:1113:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/hu/LC_MESSAGES/django.po:1171:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/hu/LC_MESSAGES/django.po:1177:"a “Referrer-Policy: no-referrer” fejlécet, kérjük távolítsa el ezeket. A "
django/conf/locale/uz/LC_MESSAGES/django.po:1142:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
django/conf/locale/uz/LC_MESSAGES/django.po:1148:"\"Referrer-Policy: no-referer\" sarlavhasidan  foydalanayotgan bo'lsangiz, "
django/conf/locale/pa/LC_MESSAGES/django.po:1102:"including the “Referrer-Policy: no-referrer” header, please remove them. The "
grep: django/conf/locale/es_AR/LC_MESSAGES/django.mo: binary file matches
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"SECURE_REFERRER_POLICY\\|Referrer-Policy\" django --include=*.py docs --include=*.txt | head -50"
}
```

**tool result**

```
django/conf/global_settings.py:640:SECURE_REFERRER_POLICY = None
django/middleware/security.py:18:        self.referrer_policy = settings.SECURE_REFERRER_POLICY
django/middleware/security.py:50:            response.setdefault('Referrer-Policy', ','.join(
django/views/csrf.py:125:            'content=\"no-referrer\"> tag or including the “Referrer-Policy: '
django/core/checks/security/base.py:18:    "SECURE_REFERRER_POLICY, and SECURE_SSL_REDIRECT settings will have no "
django/core/checks/security/base.py:106:    'You have not set the SECURE_REFERRER_POLICY setting. Without this, your '
django/core/checks/security/base.py:107:    'site will not send a Referrer-Policy header. You should consider '
django/core/checks/security/base.py:113:    'You have set the SECURE_REFERRER_POLICY setting to an invalid value.',
django/core/checks/security/base.py:216:        if settings.SECURE_REFERRER_POLICY is None:
django/core/checks/security/base.py:219:        if isinstance(settings.SECURE_REFERRER_POLICY, str):
django/core/checks/security/base.py:220:            values = {v.strip() for v in settings.SECURE_REFERRER_POLICY.split(',')}
django/core/checks/security/base.py:222:            values = set(settings.SECURE_REFERRER_POLICY)
docs/ref/settings.txt:2391:.. setting:: SECURE_REFERRER_POLICY
docs/ref/settings.txt:2393:``SECURE_REFERRER_POLICY``
docs/ref/settings.txt:3629:  * :setting:`SECURE_REFERRER_POLICY`
docs/ref/csrf.txt:310:    include the ``Referrer-Policy: no-referrer`` header. Due to the CSRF
docs/ref/checks.txt:347:  :setting:`SECURE_REFERRER_POLICY`, and :setting:`SECURE_SSL_REDIRECT`
docs/ref/checks.txt:434:* **security.W022**: You have not set the :setting:`SECURE_REFERRER_POLICY`
docs/ref/checks.txt:435:  setting. Without this, your site will not send a Referrer-Policy header. You
docs/ref/checks.txt:437:* **security.E023**: You have set the :setting:`SECURE_REFERRER_POLICY` setting
docs/ref/middleware.txt:189:* :setting:`SECURE_REFERRER_POLICY`
docs/ref/middleware.txt:262:via `the Referrer-Policy header`__. This header can suggest any of three
docs/ref/middleware.txt:265:__ https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
docs/ref/middleware.txt:296:``SecurityMiddleware`` can set the ``Referrer-Policy`` header for you, based on
docs/ref/middleware.txt:297:the :setting:`SECURE_REFERRER_POLICY` setting (note spelling: browsers send a
docs/ref/middleware.txt:299:browser whether to do so is spelled ``Referrer-Policy``). The valid values for
docs/ref/middleware.txt:339:    comma-separated string can be used with :setting:`SECURE_REFERRER_POLICY`.
docs/releases/3.0.txt:339:  :ref:`Referrer-Policy <referrer-policy>` header.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '2380,2420p' docs/ref/settings.txt; echo ===; sed -n '285,345p' docs/ref/middleware.txt; echo ===; sed -n '640,642p' django/conf/global_settings.py; echo ===; sed -n '200,230p' django/core/checks/security/base.py; echo ===; sed -n '95,118p' django/core/checks/security/base.py"
}
```

**tool result**

```
--------------------------

Default: ``[]`` (Empty list)

If a URL path matches a regular expression in this list, the request will not be
redirected to HTTPS. The
:class:`~django.middleware.security.SecurityMiddleware` strips leading slashes
from URL paths, so patterns shouldn't include them, e.g.
``SECURE_REDIRECT_EXEMPT = [r'^no-ssl/$', …]``. If
:setting:`SECURE_SSL_REDIRECT` is ``False``, this setting has no effect.

.. setting:: SECURE_REFERRER_POLICY

``SECURE_REFERRER_POLICY``
--------------------------

.. versionadded:: 3.0

Default: ``None``

If configured, the :class:`~django.middleware.security.SecurityMiddleware` sets
the :ref:`referrer-policy` header on all responses that do not already have it
to the value provided.

.. setting:: SECURE_SSL_HOST

``SECURE_SSL_HOST``
-------------------

Default: ``None``

If a string (e.g. ``secure.example.com``), all SSL redirects will be directed
to this host rather than the originally-requested host
(e.g. ``www.example.com``). If :setting:`SECURE_SSL_REDIRECT` is ``False``, this
setting has no effect.

.. setting:: SECURE_SSL_REDIRECT

``SECURE_SSL_REDIRECT``
-----------------------

===

* Protocol downgrade: a downgrade occurs if the page containing the link is
  served via HTTPS, but the page being linked to is not served via HTTPS.

.. warning::
    When your site is served via HTTPS, :ref:`Django's CSRF protection system
    <using-csrf>` requires the ``Referer`` header to be present, so completely
    disabling the ``Referer`` header will interfere with CSRF protection. To
    gain most of the benefits of disabling ``Referer`` headers while also
    keeping CSRF protection, consider enabling only same-origin referrers.

``SecurityMiddleware`` can set the ``Referrer-Policy`` header for you, based on
the :setting:`SECURE_REFERRER_POLICY` setting (note spelling: browsers send a
``Referer`` header when a user clicks a link, but the header instructing a
browser whether to do so is spelled ``Referrer-Policy``). The valid values for
this setting are:

``no-referrer``
    Instructs the browser to send no referrer for links clicked on this site.

``no-referrer-when-downgrade``
    Instructs the browser to send a full URL as the referrer, but only when no
    protocol downgrade occurs.

``origin``
    Instructs the browser to send only the origin, not the full URL, as the
    referrer.

``origin-when-cross-origin``
    Instructs the browser to send the full URL as the referrer for same-origin
    links, and only the origin for cross-origin links.

``same-origin``
    Instructs the browser to send a full URL, but only for same-origin links. No
    referrer will be sent for cross-origin links.

``strict-origin``
    Instructs the browser to send only the origin, not the full URL, and to send
    no referrer when a protocol downgrade occurs.

``strict-origin-when-cross-origin``
    Instructs the browser to send the full URL when the link is same-origin and
    no protocol downgrade occurs; send only the origin when the link is
    cross-origin and no protocol downgrade occurs; and no referrer when a
    protocol downgrade occurs.

``unsafe-url``
    Instructs the browser to always send the full URL as the referrer.

.. admonition:: Unknown Policy Values

    Where a policy value is `unknown`__ by a user agent, it is possible to
    specify multiple policy values to provide a fallback. The last specified
    value that is understood takes precedence. To support this, an iterable or
    comma-separated string can be used with :setting:`SECURE_REFERRER_POLICY`.

    __ https://w3c.github.io/webappsec-referrer-policy/#unknown-policy-values

.. _x-content-type-options:

``X-Content-Type-Options: nosniff``
===
SECURE_REFERRER_POLICY = None
SECURE_SSL_HOST = None
SECURE_SSL_REDIRECT = False
===
def check_xframe_deny(app_configs, **kwargs):
    passed_check = (
        not _xframe_middleware() or
        settings.X_FRAME_OPTIONS == 'DENY'
    )
    return [] if passed_check else [W019]


@register(Tags.security, deploy=True)
def check_allowed_hosts(app_configs, **kwargs):
    return [] if settings.ALLOWED_HOSTS else [W020]


@register(Tags.security, deploy=True)
def check_referrer_policy(app_configs, **kwargs):
    if _security_middleware():
        if settings.SECURE_REFERRER_POLICY is None:
            return [W022]
        # Support a comma-separated string or iterable of values to allow fallback.
        if isinstance(settings.SECURE_REFERRER_POLICY, str):
            values = {v.strip() for v in settings.SECURE_REFERRER_POLICY.split(',')}
        else:
            values = set(settings.SECURE_REFERRER_POLICY)
        if not values <= REFERRER_POLICY_VALUES:
            return [E023]
    return []
===
    "ALLOWED_HOSTS must not be empty in deployment.",
    id='security.W020',
)

W021 = Warning(
    "You have not set the SECURE_HSTS_PRELOAD setting to True. Without this, "
    "your site cannot be submitted to the browser preload list.",
    id='security.W021',
)

W022 = Warning(
    'You have not set the SECURE_REFERRER_POLICY setting. Without this, your '
    'site will not send a Referrer-Policy header. You should consider '
    'enabling this header to protect user privacy.',
    id='security.W022',
)

E023 = Error(
    'You have set the SECURE_REFERRER_POLICY setting to an invalid value.',
    hint='Valid values are: {}.'.format(', '.join(sorted(REFERRER_POLICY_VALUES))),
    id='security.E023',
)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"SECURE_REFERRER_POLICY\\|referrer_policy\\|Referrer-Policy\" tests --include=*.py | head -60"
}
```

**tool result**

```
tests/view_tests/tests/test_csrf.py:62:            '“Referrer-Policy: no-referrer” header, please remove them.',
tests/middleware/test_security.py:226:    @override_settings(SECURE_REFERRER_POLICY=None)
tests/middleware/test_security.py:227:    def test_referrer_policy_off(self):
tests/middleware/test_security.py:229:        With SECURE_REFERRER_POLICY set to None, the middleware does not add a
tests/middleware/test_security.py:230:        "Referrer-Policy" header to the response.
tests/middleware/test_security.py:232:        self.assertNotIn('Referrer-Policy', self.process_response())
tests/middleware/test_security.py:234:    def test_referrer_policy_on(self):
tests/middleware/test_security.py:236:        With SECURE_REFERRER_POLICY set to a valid value, the middleware adds a
tests/middleware/test_security.py:237:        "Referrer-Policy" header to the response.
tests/middleware/test_security.py:247:            with self.subTest(value=value), override_settings(SECURE_REFERRER_POLICY=value):
tests/middleware/test_security.py:248:                self.assertEqual(self.process_response()['Referrer-Policy'], expected)
tests/middleware/test_security.py:250:    @override_settings(SECURE_REFERRER_POLICY='strict-origin')
tests/middleware/test_security.py:251:    def test_referrer_policy_already_present(self):
tests/middleware/test_security.py:253:        The middleware will not override a "Referrer-Policy" header already
tests/middleware/test_security.py:256:        response = self.process_response(headers={'Referrer-Policy': 'unsafe-url'})
tests/middleware/test_security.py:257:        self.assertEqual(response['Referrer-Policy'], 'unsafe-url')
tests/check_framework/test_security.py:511:        from django.core.checks.security.base import check_referrer_policy
tests/check_framework/test_security.py:512:        return check_referrer_policy
tests/check_framework/test_security.py:516:        SECURE_REFERRER_POLICY=None,
tests/check_framework/test_security.py:518:    def test_no_referrer_policy(self):
tests/check_framework/test_security.py:521:    @override_settings(MIDDLEWARE=[], SECURE_REFERRER_POLICY=None)
tests/check_framework/test_security.py:522:    def test_no_referrer_policy_no_middleware(self):
tests/check_framework/test_security.py:524:        Don't warn if SECURE_REFERRER_POLICY is None and SecurityMiddleware
tests/check_framework/test_security.py:530:    def test_with_referrer_policy(self):
tests/check_framework/test_security.py:539:            with self.subTest(value=value), override_settings(SECURE_REFERRER_POLICY=value):
tests/check_framework/test_security.py:544:        SECURE_REFERRER_POLICY='invalid-value',
tests/check_framework/test_security.py:546:    def test_with_invalid_referrer_policy(self):
```

**assistant → tool `bash`**

```json
{
  "command": "ls docs/releases | tail -15; grep -n \"SECURE_REFERRER_POLICY\" docs/releases/3.1.txt 2>/dev/null; sed -n '220,260p' tests/middleware/test_security.py; sed -n '505,550p' tests/check_framework/test_security.py"
}
```

**tool result**

```
2.2.4.txt
2.2.5.txt
2.2.6.txt
2.2.7.txt
2.2.8.txt
2.2.9.txt
2.2.txt
3.0.1.txt
3.0.2.txt
3.0.3.txt
3.0.4.txt
3.0.txt
3.1.txt
index.txt
security.txt
        """
        With SECURE_SSL_REDIRECT False, the middleware does not redirect.
        """
        ret = self.process_request("get", "/some/url")
        self.assertIsNone(ret)

    @override_settings(SECURE_REFERRER_POLICY=None)
    def test_referrer_policy_off(self):
        """
        With SECURE_REFERRER_POLICY set to None, the middleware does not add a
        "Referrer-Policy" header to the response.
        """
        self.assertNotIn('Referrer-Policy', self.process_response())

    def test_referrer_policy_on(self):
        """
        With SECURE_REFERRER_POLICY set to a valid value, the middleware adds a
        "Referrer-Policy" header to the response.
        """
        tests = (
            ('strict-origin', 'strict-origin'),
            ('strict-origin,origin', 'strict-origin,origin'),
            ('strict-origin, origin', 'strict-origin,origin'),
            (['strict-origin', 'origin'], 'strict-origin,origin'),
            (('strict-origin', 'origin'), 'strict-origin,origin'),
        )
        for value, expected in tests:
            with self.subTest(value=value), override_settings(SECURE_REFERRER_POLICY=value):
                self.assertEqual(self.process_response()['Referrer-Policy'], expected)

    @override_settings(SECURE_REFERRER_POLICY='strict-origin')
    def test_referrer_policy_already_present(self):
        """
        The middleware will not override a "Referrer-Policy" header already
        present in the response.
        """
        response = self.process_response(headers={'Referrer-Policy': 'unsafe-url'})
        self.assertEqual(response['Referrer-Policy'], 'unsafe-url')


class CheckReferrerPolicyTest(SimpleTestCase):

    @property
    def func(self):
        from django.core.checks.security.base import check_referrer_policy
        return check_referrer_policy

    @override_settings(
        MIDDLEWARE=['django.middleware.security.SecurityMiddleware'],
        SECURE_REFERRER_POLICY=None,
    )
    def test_no_referrer_policy(self):
        self.assertEqual(self.func(None), [base.W022])

    @override_settings(MIDDLEWARE=[], SECURE_REFERRER_POLICY=None)
    def test_no_referrer_policy_no_middleware(self):
        """
        Don't warn if SECURE_REFERRER_POLICY is None and SecurityMiddleware
        isn't in MIDDLEWARE.
        """
        self.assertEqual(self.func(None), [])

    @override_settings(MIDDLEWARE=['django.middleware.security.SecurityMiddleware'])
    def test_with_referrer_policy(self):
        tests = (
            'strict-origin',
            'strict-origin,origin',
            'strict-origin, origin',
            ['strict-origin', 'origin'],
            ('strict-origin', 'origin'),
        )
        for value in tests:
            with self.subTest(value=value), override_settings(SECURE_REFERRER_POLICY=value):
                self.assertEqual(self.func(None), [])

    @override_settings(
        MIDDLEWARE=['django.middleware.security.SecurityMiddleware'],
        SECURE_REFERRER_POLICY='invalid-value',
    )
    def test_with_invalid_referrer_policy(self):
        self.assertEqual(self.func(None), [base.E023])
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"SECURE_\\|security\\|Backwards incompatible\" docs/releases/3.1.txt | head -50; sed -n '1,80p' django/core/checks/security/base.py; grep -n \"W022\\|security.W022\" -r docs tests django --include=*.py --include=*.txt"
}
```

**tool result**

```
359:Backwards incompatible changes in 3.1
from django.conf import settings

from .. import Error, Tags, Warning, register

REFERRER_POLICY_VALUES = {
    'no-referrer', 'no-referrer-when-downgrade', 'origin',
    'origin-when-cross-origin', 'same-origin', 'strict-origin',
    'strict-origin-when-cross-origin', 'unsafe-url',
}

SECRET_KEY_MIN_LENGTH = 50
SECRET_KEY_MIN_UNIQUE_CHARACTERS = 5

W001 = Warning(
    "You do not have 'django.middleware.security.SecurityMiddleware' "
    "in your MIDDLEWARE so the SECURE_HSTS_SECONDS, "
    "SECURE_CONTENT_TYPE_NOSNIFF, SECURE_BROWSER_XSS_FILTER, "
    "SECURE_REFERRER_POLICY, and SECURE_SSL_REDIRECT settings will have no "
    "effect.",
    id='security.W001',
)

W002 = Warning(
    "You do not have "
    "'django.middleware.clickjacking.XFrameOptionsMiddleware' in your "
    "MIDDLEWARE, so your pages will not be served with an "
    "'x-frame-options' header. Unless there is a good reason for your "
    "site to be served in a frame, you should consider enabling this "
    "header to help prevent clickjacking attacks.",
    id='security.W002',
)

W004 = Warning(
    "You have not set a value for the SECURE_HSTS_SECONDS setting. "
    "If your entire site is served only over SSL, you may want to consider "
    "setting a value and enabling HTTP Strict Transport Security. "
    "Be sure to read the documentation first; enabling HSTS carelessly "
    "can cause serious, irreversible problems.",
    id='security.W004',
)

W005 = Warning(
    "You have not set the SECURE_HSTS_INCLUDE_SUBDOMAINS setting to True. "
    "Without this, your site is potentially vulnerable to attack "
    "via an insecure connection to a subdomain. Only set this to True if "
    "you are certain that all subdomains of your domain should be served "
    "exclusively via SSL.",
    id='security.W005',
)

W006 = Warning(
    "Your SECURE_CONTENT_TYPE_NOSNIFF setting is not set to True, "
    "so your pages will not be served with an "
    "'X-Content-Type-Options: nosniff' header. "
    "You should consider enabling this header to prevent the "
    "browser from identifying content types incorrectly.",
    id='security.W006',
)

W008 = Warning(
    "Your SECURE_SSL_REDIRECT setting is not set to True. "
    "Unless your site should be available over both SSL and non-SSL "
    "connections, you may want to either set this setting True "
    "or configure a load balancer or reverse-proxy server "
    "to redirect all connections to HTTPS.",
    id='security.W008',
)

W009 = Warning(
    "Your SECRET_KEY has less than %(min_length)s characters or less than "
    "%(min_unique_chars)s unique characters. Please generate a long and random "
    "SECRET_KEY, otherwise many of Django's security-critical features will be "
    "vulnerable to attack." % {
        'min_length': SECRET_KEY_MIN_LENGTH,
        'min_unique_chars': SECRET_KEY_MIN_UNIQUE_CHARACTERS,
    },
    id='security.W009',
)

W018 = Warning(
docs/ref/checks.txt:434:* **security.W022**: You have not set the :setting:`SECURE_REFERRER_POLICY`
tests/check_framework/test_security.py:519:        self.assertEqual(self.func(None), [base.W022])
django/core/checks/security/base.py:105:W022 = Warning(
django/core/checks/security/base.py:109:    id='security.W022',
django/core/checks/security/base.py:217:            return [W022]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '425,445p' docs/ref/checks.txt; sed -n '330,365p' docs/releases/3.1.txt; sed -n '1,50p' docs/releases/3.1.txt; sed -n '45,60p' django/middleware/security.py"
}
```

**tool result**

```
* **security.W019**: You have
  :class:`django.middleware.clickjacking.XFrameOptionsMiddleware` in your
  :setting:`MIDDLEWARE`, but :setting:`X_FRAME_OPTIONS` is not set to
  ``'DENY'``. Unless there is a good reason for your site to serve other parts
  of itself in a frame, you should change it to ``'DENY'``.
* **security.W020**: :setting:`ALLOWED_HOSTS` must not be empty in deployment.
* **security.W021**: You have not set the
  :setting:`SECURE_HSTS_PRELOAD` setting to ``True``. Without this, your site
  cannot be submitted to the browser preload list.
* **security.W022**: You have not set the :setting:`SECURE_REFERRER_POLICY`
  setting. Without this, your site will not send a Referrer-Policy header. You
  should consider enabling this header to protect user privacy.
* **security.E023**: You have set the :setting:`SECURE_REFERRER_POLICY` setting
  to an invalid value.

Signals
-------

* **signals.E001**: ``<handler>`` was connected to the ``<signal>`` signal with
  a lazy reference to the sender ``<app label>.<model>``, but app ``<app label>``
  isn't installed or doesn't provide model ``<model>``.

* :func:`~django.utils.dateparse.parse_duration` now supports comma separators
  for decimal fractions in the ISO 8601 format.

* :func:`~django.utils.dateparse.parse_datetime`,
  :func:`~django.utils.dateparse.parse_duration`, and
  :func:`~django.utils.dateparse.parse_time` now support comma separators for
  milliseconds.

Validators
~~~~~~~~~~

* ...

Miscellaneous
~~~~~~~~~~~~~

* The SQLite backend now supports :class:`pathlib.Path` for the ``NAME``
  setting.

* The ``settings.py`` generated by the :djadmin:`startproject` command now uses
  :class:`pathlib.Path` instead of :mod:`os.path` for building filesystem
  paths.

* The :setting:`TIME_ZONE <DATABASE-TIME_ZONE>` setting is now allowed on
  databases that support time zones.

.. _backwards-incompatible-3.1:

Backwards incompatible changes in 3.1
=====================================

Database backend API
--------------------

This section describes changes that may be needed in third-party database
============================================
Django 3.1 release notes - UNDER DEVELOPMENT
============================================

*Expected August 2020*

Welcome to Django 3.1!

These release notes cover the :ref:`new features <whats-new-3.1>`, as well as
some :ref:`backwards incompatible changes <backwards-incompatible-3.1>` you'll
want to be aware of when upgrading from Django 3.0 or earlier. We've
:ref:`dropped some features<removed-features-3.1>` that have reached the end of
their deprecation cycle, and we've :ref:`begun the deprecation process for
some features <deprecated-features-3.1>`.

See the :doc:`/howto/upgrade-version` guide if you're updating an existing
project.

Python compatibility
====================

Django 3.1 supports Python 3.6, 3.7, and 3.8. We **highly recommend** and only
officially support the latest release of each series.

.. _whats-new-3.1:

What's new in Django 3.1
========================

Minor features
--------------

:mod:`django.contrib.admin`
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The new ``django.contrib.admin.EmptyFieldListFilter`` for
  :attr:`.ModelAdmin.list_filter` allows filtering on empty values (empty
  strings and nulls) in the admin changelist view.

* Filters in the right sidebar of the admin changelist view now contains a link
  to clear all filters.

:mod:`django.contrib.admindocs`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.auth`
~~~~~~~~~~~~~~~~~~~~~~~~~~

            response.setdefault('X-XSS-Protection', '1; mode=block')

        if self.referrer_policy:
            # Support a comma-separated string or iterable of values to allow
            # fallback.
            response.setdefault('Referrer-Policy', ','.join(
                [v.strip() for v in self.referrer_policy.split(',')]
                if isinstance(self.referrer_policy, str) else self.referrer_policy
            ))

        return response
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"SECURE_REFERRER_POLICY\\|Referrer-Policy\" tests --include=*.py | grep -v -n \"override\\|test_\" | head; grep -rn \"same-origin\\|referrer\" tests/middleware tests/check_framework --include=*.py | head -30"
}
```

**tool result**

```
tests/middleware/test_security.py:227:    def test_referrer_policy_off(self):
tests/middleware/test_security.py:234:    def test_referrer_policy_on(self):
tests/middleware/test_security.py:251:    def test_referrer_policy_already_present(self):
tests/check_framework/test_security.py:511:        from django.core.checks.security.base import check_referrer_policy
tests/check_framework/test_security.py:512:        return check_referrer_policy
tests/check_framework/test_security.py:518:    def test_no_referrer_policy(self):
tests/check_framework/test_security.py:522:    def test_no_referrer_policy_no_middleware(self):
tests/check_framework/test_security.py:530:    def test_with_referrer_policy(self):
tests/check_framework/test_security.py:546:    def test_with_invalid_referrer_policy(self):
```

**assistant → tool `bash`**

```json
{
  "command": "git branch -a; git log --all --oneline -- django/conf/global_settings.py | head -10; git remote -v"
}
```

**tool result**

```
* main
13e4abf83e Fixed #30752 -- Allowed using ExceptionReporter subclasses in error reports.
188b003014 Fixed #15982 -- Added DATE_INPUT_FORMATS to forms.DateTimeField default input formats.
5b7450080f Added Algerian Arabic language.
6ccb1b68bc Added Uzbek language.
226ebb1729 Fixed #28622 -- Allowed specifying password reset link expiration in seconds and deprecated PASSWORD_RESET_TIMEOUT_DAYS.
3d716467a9 Refs #29817 -- Removed settings.FILE_CHARSET per deprecation timeline.
406dba04e1 Fixed #29406 -- Added support for Referrer-Policy header.
05d0eca635 Fixed #30426 -- Changed X_FRAME_OPTIONS setting default to DENY.
0468159763 Refs #30426 -- Changed default SECURE_CONTENT_TYPE_NOSNIFF to True.
19fc6376ce Fixed #30304 -- Added support for the HttpOnly, SameSite, and Secure flags on language cookies.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Security\\|security\" docs/releases/3.1.txt | head -30; sed -n '80,220p' docs/releases/3.1.txt"
}
```

**tool result**

```
* ...

:mod:`django.contrib.postgres`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The new :class:`~django.contrib.postgres.indexes.BloomIndex` class allows
  creating ``bloom`` indexes in the database. The new
  :class:`~django.contrib.postgres.operations.BloomExtension` migration
  operation installs the ``bloom`` extension to add support for this index.

* :meth:`~django.db.models.Model.get_FOO_display` now supports
  :class:`~django.contrib.postgres.fields.ArrayField` and
  :class:`~django.contrib.postgres.fields.RangeField`.

* The new :lookup:`rangefield.lower_inc`, :lookup:`rangefield.lower_inf`,
  :lookup:`rangefield.upper_inc`, and :lookup:`rangefield.upper_inf` allows
  querying :class:`~django.contrib.postgres.fields.RangeField` by a bound type.

* :lookup:`rangefield.contained_by` now supports
  :class:`~django.db.models.SmallAutoField`,
  :class:`~django.db.models.AutoField`,
  :class:`~django.db.models.BigAutoField`,
  :class:`~django.db.models.SmallIntegerField`, and
  :class:`~django.db.models.DecimalField`.

* :class:`~django.contrib.postgres.search.SearchQuery` now supports
  ``'websearch'`` search type on PostgreSQL 11+.

:mod:`django.contrib.redirects`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.sessions`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The :setting:`SESSION_COOKIE_SAMESITE` setting now allows ``'None'`` (string)
  value to explicitly state that the cookie is sent with all same-site and
  cross-site requests.

:mod:`django.contrib.sitemaps`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.sites`
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

:mod:`django.contrib.staticfiles`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The :setting:`STATICFILES_DIRS` setting now supports :class:`pathlib.Path`.

:mod:`django.contrib.syndication`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ...

Cache
~~~~~

* The :func:`~django.views.decorators.cache.cache_control` decorator and
  :func:`~django.utils.cache.patch_cache_control` method now support multiple
  field names in the ``no-cache`` directive for the ``Cache-Control`` header,
  according to :rfc:`7234#section-5.2.2.2`.

* :meth:`~django.core.caches.cache.delete` now returns ``True`` if the key was
  successfully deleted, ``False`` otherwise.

CSRF
~~~~

* The :setting:`CSRF_COOKIE_SAMESITE` setting now allows ``'None'`` (string)
  value to explicitly state that the cookie is sent with all same-site and
  cross-site requests.

Email
~~~~~

* The :setting:`EMAIL_FILE_PATH` setting, used by the :ref:`file email backend
  <topic-email-file-backend>`, now supports :class:`pathlib.Path`.

Error Reporting
~~~~~~~~~~~~~~~

* :class:`django.views.debug.SafeExceptionReporterFilter` now filters sensitive
  values from ``request.META`` in exception reports.

* The new :attr:`.SafeExceptionReporterFilter.cleansed_substitute` and
  :attr:`.SafeExceptionReporterFilter.hidden_settings` attributes allow
  customization of sensitive settings and ``request.META`` filtering in
  exception reports.

* The technical 404 debug view now respects
  :setting:`DEFAULT_EXCEPTION_REPORTER_FILTER` when applying settings
  filtering.

* The new :setting:`DEFAULT_EXCEPTION_REPORTER` allows providing a
  :class:`django.views.debug.ExceptionReporter` subclass to customize exception
  report generation. See :ref:`custom-error-reports` for details.

File Storage
~~~~~~~~~~~~

* ``FileSystemStorage.save()`` method now supports :class:`pathlib.Path`.

File Uploads
~~~~~~~~~~~~

* ...


Forms
~~~~~

* :class:`~django.forms.ModelChoiceIterator`, used by
  :class:`~django.forms.ModelChoiceField` and
  :class:`~django.forms.ModelMultipleChoiceField`, now uses
  :class:`~django.forms.ModelChoiceIteratorValue` that can be used by widgets
  to access model instances. See :ref:`iterating-relationship-choices` for
  details.

* :class:`django.forms.DateTimeField` now accepts dates in a subset of ISO 8601
  datetime formats, including optional timezone (e.g. ``2019-10-10T06:47``,
  ``2019-10-10T06:47:23+04:00``, or ``2019-10-10T06:47:23Z``). Additionally, it
  now uses ``DATE_INPUT_FORMATS`` in addition to ``DATETIME_INPUT_FORMATS``
  when converting a field input to a ``datetime`` value.

Generic Views
~~~~~~~~~~~~~

* ...

Internationalization
~~~~~~~~~~~~~~~~~~~~

* The :setting:`LANGUAGE_COOKIE_SAMESITE` setting now allows ``'None'``
  (string) value to explicitly state that the cookie is sent with all same-site
  and cross-site requests.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^Security\\|^~~~\\|^----\\|^Requests\\|^Serialization\\|^Signals\" docs/releases/3.1.txt | head -40; sed -n '255,275p' docs/ref/middleware.txt"
}
```

**tool result**

```
31:--------------
34:~~~~~~~~~~~~~~~~~~~~~~~~~~~
44:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
49:~~~~~~~~~~~~~~~~~~~~~~~~~~
60:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
65:~~~~~~~~~~~~~~~~~~~~~~~~~
78:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
83:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
109:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
114:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
121:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
126:~~~~~~~~~~~~~~~~~~~~~~~~~~~
131:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
136:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
141:~~~~~
152:~~~~
159:~~~~~
165:~~~~~~~~~~~~~~~
184:~~~~~~~~~~~~
189:~~~~~~~~~~~~
195:~~~~~
211:~~~~~~~~~~~~~
216:~~~~~~~~~~~~~~~~~~~~
225:~~~~~~~
230:~~~~~~~~~~~~~~~~~~~
235:~~~~~~~~~~
241:~~~~~~
270:~~~~~~~~~~
275:Requests and Responses
276:~~~~~~~~~~~~~~~~~~~~~~
288:Serialization
289:~~~~~~~~~~~~~
293:Signals
294:~~~~~~~
299:~~~~~~~~~
307:~~~~~
320:~~~~
326:~~~~~~~~~
340:~~~~~~~~~~
345:~~~~~~~~~~~~~
purposes -- like figuring out who's linking to your site -- it also can cause
privacy concerns by informing one site that a user was visiting another site.

__ https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer

Some browsers have the ability to accept hints about whether they should send
the HTTP ``Referer`` header when a user clicks a link; this hint is provided
via `the Referrer-Policy header`__. This header can suggest any of three
behaviors to browsers:

__ https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy

* Full URL: send the entire URL in the ``Referer`` header. For example, if the
  user is visiting ``https://example.com/page.html``, the ``Referer`` header
  would contain ``"https://example.com/page.html"``.

* Origin only: send only the "origin" in the referrer. The origin consists of
  the scheme, host and (optionally) port number. For example, if the user is
  visiting ``https://example.com/page.html``, the origin would be
  ``https://example.com/``.
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport re\np='django/conf/global_settings.py'\ns=open(p).read().replace('SECURE_REFERRER_POLICY = None','SECURE_REFERRER_POLICY = \"same-origin\"')\nopen(p,'w').write(s)\n\np='docs/ref/settings.txt'\ns=open(p).read()\ns=s.replace(\"\"\".. versionadded:: 3.0\n\nDefault: ``None``\n\nIf configured, the :class:`~django.middleware.security.SecurityMiddleware` sets\nthe :ref:`referrer-policy` header on all responses that do not already have it\nto the value provided.\"\"\",\"\"\".. versionadded:: 3.0\n\nDefault: ``'same-origin'``\n\n.. versionchanged:: 3.1\n\n    The default was changed from ``None`` to ``'same-origin'``.\n\nIf configured, the :class:`~django.middleware.security.SecurityMiddleware` sets\nthe :ref:`referrer-policy` header on all responses that do not already have it\nto the value provided.\"\"\")\nopen(p,'w').write(s)\nEOF\ngrep -n \"SECURE_REFERRER_POLICY\" django/conf/global_settings.py docs/ref/settings.txt"
}
```

**tool result**

```
django/conf/global_settings.py:640:SECURE_REFERRER_POLICY = "same-origin"
docs/ref/settings.txt:2391:.. setting:: SECURE_REFERRER_POLICY
docs/ref/settings.txt:2393:``SECURE_REFERRER_POLICY``
docs/ref/settings.txt:3633:  * :setting:`SECURE_REFERRER_POLICY`
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '359,440p' docs/releases/3.1.txt"
}
```

**tool result**

```
Backwards incompatible changes in 3.1
=====================================

Database backend API
--------------------

This section describes changes that may be needed in third-party database
backends.

* ``DatabaseOperations.fetch_returned_insert_columns()`` now requires an
  additional ``returning_params`` argument.

* ``connection.timezone`` property is now ``'UTC'`` by default, or the
  :setting:`TIME_ZONE <DATABASE-TIME_ZONE>` when :setting:`USE_TZ` is ``True``
  on databases that support time zones. Previously, it was ``None`` on
  databases that support time zones.

Dropped support for MariaDB 10.1
--------------------------------

Upstream support for MariaDB 10.1 ends in October 2020. Django 3.1 supports
MariaDB 10.2 and higher.

Miscellaneous
-------------

* The cache keys used by :ttag:`cache` and generated by
  :func:`~django.core.cache.utils.make_template_fragment_key` are different
  from the keys generated by older versions of Django. After upgrading to
  Django 3.1, the first request to any previously cached template fragment will
  be a cache miss.

* The logic behind the decision to return a redirection fallback or a 204 HTTP
  response from the :func:`~django.views.i18n.set_language` view is now based
  on the ``Accept`` HTTP header instead of the ``X-Requested-With`` HTTP header
  presence.

* The compatibility imports of ``django.core.exceptions.EmptyResultSet`` in
  ``django.db.models.query``, ``django.db.models.sql``, and
  ``django.db.models.sql.datastructures`` are removed.

* The compatibility import of ``django.core.exceptions.FieldDoesNotExist`` in
  ``django.db.models.fields`` is removed.

* The compatibility imports of ``django.forms.utils.pretty_name()`` and
  ``django.forms.boundfield.BoundField`` in ``django.forms.forms`` are removed.

* The compatibility imports of ``Context``, ``ContextPopException``, and
  ``RequestContext`` in ``django.template.base`` are removed.

* The compatibility import of
  ``django.contrib.admin.helpers.ACTION_CHECKBOX_NAME`` in
  ``django.contrib.admin`` is removed.

* The :setting:`STATIC_URL` and :setting:`MEDIA_URL` settings set to relative
  paths are now prefixed by the server-provided value of ``SCRIPT_NAME`` (or
  ``/`` if not set). This change should not affect settings set to valid URLs
  or absolute paths.

* :class:`~django.middleware.http.ConditionalGetMiddleware` no longer adds the
  ``ETag`` header to responses with an empty
  :attr:`~django.http.HttpResponse.content`.

* ``django.utils.decorators.classproperty()`` decorator is moved to
  ``django.utils.functional.classproperty()``.

* :tfilter:`floatformat` template filter now outputs (positive) ``0`` for
  negative numbers which round to zero.

* :attr:`Meta.ordering <django.db.models.Options.ordering>` and
  :attr:`Meta.unique_together <django.db.models.Options.unique_together>`
  options on models in ``django.contrib`` modules that were formerly tuples are
  now lists.

* The admin calendar widget now handles two-digit years according to the Open
  Group Specification, i.e. values between 69 and 99 are mapped to the previous
  century, and values between 0 and 68 are mapped to the current century.

* Date-only formats are removed from the default list for
  :setting:`DATETIME_INPUT_FORMATS`.

* The :class:`~django.forms.FileInput` widget no longer renders with the
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\np='docs/releases/3.1.txt'\ns=open(p).read()\nneedle=\"\"\"* The admin calendar widget now handles two-digit years according to the Open\n  Group Specification, i.e. values between 69 and 99 are mapped to the previous\n  century, and values between 0 and 68 are mapped to the current century.\"\"\"\nassert needle in s\ns=s.replace(needle, needle+\"\"\"\n\n* The :setting:`SECURE_REFERRER_POLICY` setting now defaults to\n  ``'same-origin'``. With this configured,\n  :class:`~django.middleware.security.SecurityMiddleware` sets the\n  :ref:`Referrer-Policy <referrer-policy>` header to ``same-origin`` on all\n  responses that do not already have it.\"\"\")\nopen(p,'w').write(s)\nEOF\ngit diff --stat && git diff"
}
```

**tool result**

```
 django/conf/global_settings.py | 2 +-
 docs/ref/settings.txt          | 6 +++++-
 docs/releases/3.1.txt          | 6 ++++++
 3 files changed, 12 insertions(+), 2 deletions(-)
diff --git a/django/conf/global_settings.py b/django/conf/global_settings.py
index 09c9b95d26..5e30e02773 100644
--- a/django/conf/global_settings.py
+++ b/django/conf/global_settings.py
@@ -637,6 +637,6 @@ SECURE_HSTS_INCLUDE_SUBDOMAINS = False
 SECURE_HSTS_PRELOAD = False
 SECURE_HSTS_SECONDS = 0
 SECURE_REDIRECT_EXEMPT = []
-SECURE_REFERRER_POLICY = None
+SECURE_REFERRER_POLICY = "same-origin"
 SECURE_SSL_HOST = None
 SECURE_SSL_REDIRECT = False
diff --git a/docs/ref/settings.txt b/docs/ref/settings.txt
index b4a5bdc48f..5148a26465 100644
--- a/docs/ref/settings.txt
+++ b/docs/ref/settings.txt
@@ -2395,7 +2395,11 @@ from URL paths, so patterns shouldn't include them, e.g.
 
 .. versionadded:: 3.0
 
-Default: ``None``
+Default: ``'same-origin'``
+
+.. versionchanged:: 3.1
+
+    The default was changed from ``None`` to ``'same-origin'``.
 
 If configured, the :class:`~django.middleware.security.SecurityMiddleware` sets
 the :ref:`referrer-policy` header on all responses that do not already have it
diff --git a/docs/releases/3.1.txt b/docs/releases/3.1.txt
index 4a165156e1..52173bf826 100644
--- a/docs/releases/3.1.txt
+++ b/docs/releases/3.1.txt
@@ -434,6 +434,12 @@ Miscellaneous
   Group Specification, i.e. values between 69 and 99 are mapped to the previous
   century, and values between 0 and 68 are mapped to the current century.
 
+* The :setting:`SECURE_REFERRER_POLICY` setting now defaults to
+  ``'same-origin'``. With this configured,
+  :class:`~django.middleware.security.SecurityMiddleware` sets the
+  :ref:`Referrer-Policy <referrer-policy>` header to ``same-origin`` on all
+  responses that do not already have it.
+
 * Date-only formats are removed from the default list for
   :setting:`DATETIME_INPUT_FORMATS`.
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py middleware.test_security check_framework.test_security 2>&1 | tail -20"
}
```

**tool result**

```
Testing against Django installed in '/testbed/django' with up to 8 processes
System check identified no issues (0 silenced).
...........................................................................
----------------------------------------------------------------------
Ran 75 tests in 0.132s

OK
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '288,305p' docs/ref/middleware.txt; sed -n '225,260p' tests/middleware/test_security.py; grep -rn \"Default: \\`\\`None\\`\\`\" docs/ref/settings.txt | head"
}
```

**tool result**

```

.. warning::
    When your site is served via HTTPS, :ref:`Django's CSRF protection system
    <using-csrf>` requires the ``Referer`` header to be present, so completely
    disabling the ``Referer`` header will interfere with CSRF protection. To
    gain most of the benefits of disabling ``Referer`` headers while also
    keeping CSRF protection, consider enabling only same-origin referrers.

``SecurityMiddleware`` can set the ``Referrer-Policy`` header for you, based on
the :setting:`SECURE_REFERRER_POLICY` setting (note spelling: browsers send a
``Referer`` header when a user clicks a link, but the header instructing a
browser whether to do so is spelled ``Referrer-Policy``). The valid values for
this setting are:

``no-referrer``
    Instructs the browser to send no referrer for links clicked on this site.

``no-referrer-when-downgrade``

    @override_settings(SECURE_REFERRER_POLICY=None)
    def test_referrer_policy_off(self):
        """
        With SECURE_REFERRER_POLICY set to None, the middleware does not add a
        "Referrer-Policy" header to the response.
        """
        self.assertNotIn('Referrer-Policy', self.process_response())

    def test_referrer_policy_on(self):
        """
        With SECURE_REFERRER_POLICY set to a valid value, the middleware adds a
        "Referrer-Policy" header to the response.
        """
        tests = (
            ('strict-origin', 'strict-origin'),
            ('strict-origin,origin', 'strict-origin,origin'),
            ('strict-origin, origin', 'strict-origin,origin'),
            (['strict-origin', 'origin'], 'strict-origin,origin'),
            (('strict-origin', 'origin'), 'strict-origin,origin'),
        )
        for value, expected in tests:
            with self.subTest(value=value), override_settings(SECURE_REFERRER_POLICY=value):
                self.assertEqual(self.process_response()['Referrer-Policy'], expected)

    @override_settings(SECURE_REFERRER_POLICY='strict-origin')
    def test_referrer_policy_already_present(self):
        """
        The middleware will not override a "Referrer-Policy" header already
        present in the response.
        """
        response = self.process_response(headers={'Referrer-Policy': 'unsafe-url'})
        self.assertEqual(response['Referrer-Policy'], 'unsafe-url')
219:Default: ``None``
311:Default: ``None``
642:Default: ``None``
743:Default: ``None``
759:Default: ``None``
796:Default: ``None``
812:Default: ``None``
874:Default: ``None``
886:Default: ``None``
910:Default: ``None``
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/middleware/test_security.py\n@@\n     def test_referrer_policy_on(self):\n         \"\"\"\n         With SECURE_REFERRER_POLICY set to a valid value, the middleware adds a\n         \"Referrer-Policy\" header to the response.\n         \"\"\"\n@@\n             with self.subTest(value=value), override_settings(SECURE_REFERRER_POLICY=value):\n                 self.assertEqual(self.process_response()['Referrer-Policy'], expected)\n \n+    def test_referrer_policy_default(self):\n+        \"\"\"\n+        The default SECURE_REFERRER_POLICY is 'same-origin'.\n+        \"\"\"\n+        self.assertEqual(self.process_response()['Referrer-Policy'], 'same-origin')\n+\n     @override_settings(SECURE_REFERRER_POLICY='strict-origin')\n     def test_referrer_policy_already_present(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/middleware/test_security.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/middleware/test_security.py now (263 lines), around the change:
247:            with self.subTest(value=value), override_settings(SECURE_REFERRER_POLICY=value):
248:                self.assertEqual(self.process_response()['Referrer-Policy'], expected)
249:
250:    def test_referrer_policy_default(self):
251:        """
252:        The default SECURE_REFERRER_POLICY is 'same-origin'.
253:        """
254:        self.assertEqual(self.process_response()['Referrer-Policy'], 'same-origin')
255:
256:    @override_settings(SECURE_REFERRER_POLICY='strict-origin')
257:    def test_referrer_policy_already_present(self):
258:        """
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py middleware check_framework view_tests 2>&1 | tail -15 && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
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
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
Destroying test database for alias 'other'...
TASK_OK
```

**assistant → tool `bash`**

```json
{
  "command": "python tests/runtests.py middleware check_framework view_tests 2>&1 | grep -E \"^(OK|FAILED|Ran|ERROR)\" | tail -5"
}
```

**tool result**

```
Ran 413 tests in 2.239s
OK (skipped=3)
```

**assistant**

```
Done. Changes:

- `django/conf/global_settings.py`: `SECURE_REFERRER_POLICY` now defaults to `"same-origin"`.
- `docs/ref/settings.txt`: updated default and added a `versionchanged:: 3.1` note.
- `docs/releases/3.1.txt`: documented the backwards-incompatible default change.
- `tests/middleware/test_security.py`: added a test asserting the default header is `same-origin`.

Verified with `middleware`, `check_framework`, and `view_tests` (413 tests, OK), and the required `git status` command exits 0.
```

## Run folder `single-2026-11-06T105903`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Add secure default SECURE_REFERRER_POLICY / Referrer-policy header
Description
	
#29406 added the ability for the SECURE_REFERRER_POLICY setting to set Referrer-Policy, released in Django 3.0.
I propose we change the default for this to "same-origin" to make Django applications leak less information to third party sites.
The main risk of breakage here would be linked websites breaking, if they depend on verification through the Referer header. This is a pretty fragile technique since it can be spoofed.
Documentation: ​https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
The MDN support grid is out of date: ​https://caniuse.com/#search=Referrer-Policy
```
