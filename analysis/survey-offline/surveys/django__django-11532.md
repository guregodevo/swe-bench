# Survey: non-ASCII hostname crashes email headers

Code paths that produce the behaviour in issue.md (a Unicode `DNS_NAME` reaching a header that is then encoded to a non-Unicode charset), starting with the APIs the issue names.

- `django/core/mail/message.py:EmailMessage.message` — builds the message and sets `msg['Message-ID'] = make_msgid(domain=DNS_NAME)`, injecting the raw (possibly Unicode) hostname into a header; this is the line the issue points at.
- `django/core/mail/message.py:forbid_multi_line_headers` — receives that Message-ID value, fails `val.encode('ascii')`, and falls back to `Header(val, encoding).encode()`, which raises `UnicodeEncodeError` when the domain is not representable in the message encoding (e.g. iso-8859-1).
- `django/core/mail/message.py:SafeMIMEText.__setitem__` — the `__setitem__` that routes every header assignment (including Message-ID) through `forbid_multi_line_headers` with `self.encoding`.
- `django/core/mail/message.py:SafeMIMEMultipart.__setitem__` — sibling header setter that does the same `forbid_multi_line_headers` call for multipart messages.
- `django/core/mail/message.py:SafeMIMEMessage.__setitem__` — sibling header setter that does the same call with a hard-coded `'ascii'` encoding.
- `django/core/mail/utils.py:CachedDnsName.get_fqdn` — returns `socket.getfqdn()` verbatim, so a Unicode hostname is cached and handed out with no punycode/IDNA conversion.
- `django/core/mail/utils.py:CachedDnsName.__str__` — returns the same raw FQDN, so `str(DNS_NAME)` also yields the unencoded Unicode hostname.
- `django/core/mail/message.py:sanitize_address` — the existing sibling that already does the right thing, converting a non-ASCII domain with `domain.encode('idna').decode('ascii')`; the Message-ID path lacks this conversion.
- `django/core/mail/backends/smtp.py:EmailBackend.open` — another consumer of the raw hostname, passing `DNS_NAME.get_fqdn()` as `local_hostname` to smtplib.
- `django/core/mail/backends/smtp.py:EmailBackend._send` — calls `email_message.message()`, so sending over SMTP triggers the same Message-ID header encoding crash.
- `django/core/mail/backends/console.py:EmailBackend.write_message` — calls `message.message()` and serializes it, triggering the same header encoding.
- `django/core/mail/backends/filebased.py:EmailBackend.write_message` — calls `message.message().as_bytes()`, triggering the same header encoding.
- `django/core/mail/backends/locmem.py:EmailBackend.send_messages` — calls `message.message()` for header validation, triggering the same crash in tests.
- `django/core/mail/message.py:EmailMultiAlternatives._create_message` — inherits `EmailMessage.message`, so alternative messages hit the same Message-ID path.
- `django/core/mail/__init__.py:send_mail` — public wrapper that constructs `EmailMultiAlternatives` and sends it, reaching the same Message-ID encoding.
- `django/core/mail/__init__.py:send_mass_mail` — public wrapper that constructs `EmailMessage` objects and sends them, reaching the same path.
- `django/core/mail/__init__.py:mail_admins` — public wrapper that constructs and sends `EmailMultiAlternatives`, reaching the same path.
- `django/core/mail/__init__.py:mail_managers` — public wrapper that constructs and sends `EmailMultiAlternatives`, reaching the same path.
- `django/core/mail/__init__.py:DNS_NAME` / `make_msgid` / `forbid_multi_line_headers` re-exports — the public names the issue's test patches/uses, re-exported from `django.core.mail.message` and `django.core.mail.utils`.
- `django/core/validators.py:URLValidator.__call__` — sibling IDNA conversion (`netloc.encode('idna').decode('ascii')`) showing the project's established punycode pattern.
- `django/utils/html.py:smart_urlquote` — another sibling that converts a Unicode netloc to ACE with `netloc.encode('idna').decode('ascii')` before use.
