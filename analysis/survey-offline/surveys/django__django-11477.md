# Survey: translate_url() with missing optional named groups

`django/urls/base.py:translate_url` — the public API named in the issue; it resolves the URL, then re-reverses it with `args=match.args, kwargs=match.kwargs`, so optional named groups that did not participate in the match are forwarded as `None` and corrupt the rebuilt URL.
`django/urls/base.py:resolve` — the resolution step `translate_url` calls; returns the `ResolverMatch` whose `kwargs` carry the `None` values for absent optional groups.
`django/urls/base.py:reverse` — the re-reversal step `translate_url` calls; receives the `None`-valued kwargs and hands them to the resolver's reverse machinery.
`django/urls/resolvers.py:URLResolver._reverse_with_prefix` — where the bad URL is actually produced: it treats the `None` kwargs as real substitutions (`str(None)`), so the candidate pattern either fails to match or renders `None` into the path.
`django/urls/resolvers.py:RegexPattern.match` — the source of the `None` values: `match.groupdict()` includes every named group, with `None` for optional groups that did not match.
`django/urls/resolvers.py:RoutePattern.match` — sibling of `RegexPattern.match`; also builds kwargs from `match.groupdict()`, so `path()` patterns with optional converters behave the same way.
`django/urls/resolvers.py:URLPattern.resolve` — wraps the pattern match into a `ResolverMatch`, preserving the `None`-valued kwargs that `translate_url` later reuses.
`django/urls/resolvers.py:URLResolver.resolve` — merges parent/child kwargs into `sub_match_dict` and returns the `ResolverMatch`; it likewise keeps absent optional groups as `None`.
`django/urls/resolvers.py:ResolverMatch.__init__` — stores `args`/`kwargs` verbatim, so the `None` values survive on the match object read by `translate_url`.
`django/urls/resolvers.py:URLResolver._populate` — builds the reverse possibilities/defaults that `_reverse_with_prefix` consults when deciding whether the `None` kwargs are acceptable.
`django/utils/regex_helper.py:normalize` — generates the optional-group reverse forms (zero-occurrence and one-occurrence) that `_reverse_with_prefix` tries, which is why a `None` kwarg can select the wrong form.
`django/utils/regex_helper.py:flatten_result` — turns those normalized forms into the `(pattern, params)` pairs whose params are compared against the kwargs in `_reverse_with_prefix`.
`django/views/i18n.py:set_language` — the public view that calls `translate_url(next, lang_code)` and redirects to the result, so it surfaces the malformed URL to users.
`django/conf/urls/i18n.py:i18n_patterns` — creates the `LocalePrefixPattern`-wrapped resolver whose language prefix `translate_url` is meant to swap.
`django/urls/resolvers.py:LocalePrefixPattern.match` — strips the language prefix during `translate_url`'s resolve step, returning empty kwargs for the prefix itself.
`django/middleware/locale.py:LocaleMiddleware.process_response` — a parallel path that builds a language-prefixed URL by string manipulation instead of `translate_url`, so it does not share the optional-group bug.
`django/shortcuts.py:resolve_url` — another public API that forwards caller kwargs to `reverse`, the same reverse path `translate_url` uses.
`django/shortcuts.py:redirect` — public redirect helper built on `resolve_url`, so it reaches the same reverse machinery.
`django/views/generic/base.py:RedirectView.get_redirect_url` — parallel class-based redirect that passes URL-pattern kwargs straight to `reverse`.
`django/template/defaulttags.py:URLNode.render` — the `{% url %}` tag, another caller that forwards kwargs to `reverse`.
`django/urls/base.py:is_valid_path` — sibling public helper that resolves a path and swallows `Resolver404`, used by the locale middleware's redirect path.
`tests/i18n/patterns/tests.py:URLTranslationTests.test_translate_url_utility` — the existing test for `translate_url`; the issue's optional-argument case would extend this test.
`tests/urlpatterns_reverse/tests.py:named_optional` cases — the reverse tests showing optional named groups (`arg1`/`arg2`) that `translate_url` mishandles when `arg2` is absent.
