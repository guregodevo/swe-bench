# Survey: LEVEL_TAGS not updated when using @override_settings

`django/contrib/messages/storage/base.py:Message.level_tag` — the property the issue names; it reads the module-level `LEVEL_TAGS` constant captured at import time, so a `MESSAGE_TAGS` change made later by `@override_settings` is never seen and the tag comes back as `''`.
`django/contrib/messages/storage/base.py:<module> (LEVEL_TAGS = utils.get_level_tags())` — the stale snapshot itself: it is evaluated once when the module is imported, before any test-time settings override, and is never recomputed.
`django/contrib/messages/utils.py:get_level_tags` — the function that correctly merges `constants.DEFAULT_TAGS` with the current `settings.MESSAGE_TAGS`; it would return the overridden tags if called at read time instead of import time.
`django/contrib/messages/storage/base.py:Message.tags` — sibling of `level_tag`; it joins `extra_tags` with `self.level_tag`, so it inherits the same empty-string result for overridden levels.
`django/contrib/messages/constants.py:DEFAULT_TAGS` — the built-in level-to-tag mapping that `get_level_tags` merges under `MESSAGE_TAGS`; the fallback source of the tags that go stale.
`django/contrib/messages/storage/base.py:BaseStorage.add` — creates `Message` objects with the numeric level only, deferring tag lookup to the stale `LEVEL_TAGS` at read time.
`django/contrib/messages/storage/base.py:BaseStorage._get_level` — parallel settings-at-runtime pattern: it reads `MESSAGE_LEVEL` lazily via `getattr(settings, ...)` and caches per instance, unlike the module-level `LEVEL_TAGS` snapshot.
`django/contrib/messages/storage/session.py:SessionStorage._get` — a storage backend that deserializes `Message` objects and exposes them for reading, so it surfaces the stale `level_tag` to tests.
`django/contrib/messages/storage/cookie.py:CookieStorage._get` — the parallel cookie backend; `MessageDecoder` rebuilds `Message` objects whose `level_tag` again resolves through the stale module constant.
`django/contrib/messages/storage/fallback.py:FallbackStorage._get` — the parallel fallback backend that merges messages from its child storages, exposing the same stale tags.
`django/contrib/messages/api.py:get_messages` — the public API used inside tests to read messages off the request; it returns the storage whose `Message.level_tag` is stale.
`django/contrib/messages/api.py:add_message` — the public API that queues messages via `storage.add`, the entry point for the messages whose tags later read empty.
`django/contrib/messages/context_processors.py:messages` — exposes `get_messages(request)` to templates, another read path that renders the stale `level_tag`/`tags`.
`django/contrib/admin/options.py:ModelAdmin.message_user` — sibling consumer of message levels/tags; it resolves string levels via `messages.constants` and `DEFAULT_TAGS`, a separate path that does not use `LEVEL_TAGS`.
`tests/messages_tests/base.py:override_settings_tags.enable` — the test helper that works around the bug by manually reassigning `base.LEVEL_TAGS = utils.get_level_tags()` after enabling the override, confirming the constant is the stale piece.
`tests/messages_tests/base.py:override_settings_tags.disable` — restores the saved `base.LEVEL_TAGS`, the other half of the same workaround.
`tests/messages_tests/base.py:BaseTests.test_level_tag` — the test that reads `msg.level_tag` for each stored message, the exact behaviour the issue reports.
`tests/messages_tests/base.py:BaseTests.test_custom_tags` — the sibling test using `@override_settings_tags(MESSAGE_TAGS=...)` that exercises custom tags through `Message.tags`.
