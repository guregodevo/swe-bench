# Survey: HttpResponse.delete_cookie() does not preserve SameSite

- `django/http/response.py:HttpResponseBase.delete_cookie` — the method the issue names: it calls `set_cookie()` with only `max_age=0`, `expires`, `path`, `domain` and a `secure` flag derived from the `__Secure-`/`__Host-` name prefix, so the emitted deletion cookie has no `samesite` (and no `httponly`) attribute.
- `django/http/response.py:HttpResponseBase.set_cookie` — the underlying writer that accepts `samesite` and stores it on the Morsel, but `delete_cookie()` never passes it, which is where the attribute is lost.
- `django/http/response.py:HttpResponseBase.set_signed_cookie` — sibling public API that forwards all `**kwargs` (including `samesite`) to `set_cookie()`, unlike `delete_cookie()` which hard-codes its arguments.
- `django/contrib/messages/storage/cookie.py:CookieStorage._update_cookie` — the caller from the issue: when there is no encoded message data it calls `response.delete_cookie(self.cookie_name, domain=...)` without `samesite`, producing the `messages=""; expires=...; Max-Age=0; Path=/` header Firefox warns about.
- `django/contrib/messages/storage/cookie.py:CookieStorage._update_cookie` (set branch) — the sibling path that sets the same cookie with `samesite=settings.SESSION_COOKIE_SAMESITE`, showing the attribute the delete branch drops.
- `django/contrib/sessions/middleware.py:SessionMiddleware.process_response` — another caller that deletes the session cookie via `response.delete_cookie(...)` with only path/domain, so the session deletion cookie likewise loses SameSite.
- `django/contrib/sessions/middleware.py:SessionMiddleware.process_response` (set branch) — the parallel set path that passes `samesite=settings.SESSION_COOKIE_SAMESITE`, the value the delete path should preserve.
- `django/middleware/csrf.py:CsrfViewMiddleware._set_token` — sibling cookie writer that passes `samesite=settings.CSRF_COOKIE_SAMESITE` to `set_cookie()`, the pattern `delete_cookie()` lacks.
- `django/views/i18n.py:set_language` — sibling cookie writer that passes `samesite=settings.LANGUAGE_COOKIE_SAMESITE` to `set_cookie()`, another place SameSite is explicitly propagated.
- `django/http/cookie.py:<module>` — registers `samesite` as a reserved Morsel attribute so `set_cookie()` can emit `SameSite`; the deletion path simply never populates it.
- `django/http/response.py:HttpResponseNotModified` — the 304 response class from the issue's POST; it inherits `delete_cookie()` unchanged, so the deletion header on the 304 is the one missing SameSite.
- `docs/ref/request-response.txt:HttpResponse.delete_cookie` — documents only `key`, `path` and `domain`, reflecting the API that has no way to carry SameSite.
