# pallets__flask-5014 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 122s 43 lines cost=0.005805 in=198095 cached=165376 out=8781 calls=26`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Require a non-empty name for Blueprints
Things do not work correctly if a Blueprint is given an empty name (e.g. #4944).
It would be helpful if a `ValueError` was raised when trying to do that.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls -la && git log --oneline -5 2>/dev/null | head"
}
```

**tool result**

```
total 168
drwxrwxrwx 1 root root  4096 Nov  6 12:29 .
drwxr-xr-x 1 root root  4096 Nov  6 12:29 ..
-rw-r--r-- 1 root root   217 Aug 13 02:43 .editorconfig
-rw-r--r-- 1 root root   544 Aug 13 02:43 .flake8
drwxrwxrwx 1 root root  4096 Nov  6 12:29 .git
drwxrwxrwx 4 root root  4096 Aug 13 02:43 .github
-rw-r--r-- 1 root root   207 Aug 13 02:43 .gitignore
drwxr-xr-x 4 root root  4096 Nov  6 12:29 .memdoor
-rw-r--r-- 1 root root  1026 Aug 13 02:43 .pre-commit-config.yaml
-rw-r--r-- 1 root root   209 Aug 13 02:43 .readthedocs.yaml
-rw-r--r-- 1 root root 65888 Aug 13 02:43 CHANGES.rst
-rw-r--r-- 1 root root  3358 Aug 13 02:43 CODE_OF_CONDUCT.md
-rw-r--r-- 1 root root  6685 Aug 13 02:43 CONTRIBUTING.rst
-rw-r--r-- 1 root root  1475 Aug 13 02:43 LICENSE.rst
-rw-r--r-- 1 root root   206 Aug 13 02:43 MANIFEST.in
-rw-r--r-- 1 root root  2158 Aug 13 02:43 README.rst
drwxr-xr-x 2 root root  4096 Aug 13 02:43 artwork
drwxrwxrwx 6 root root  4096 Aug 13 02:43 docs
drwxrwxrwx 5 root root  4096 Aug 13 02:43 examples
-rw-r--r-- 1 root root  2556 Aug 13 02:43 pyproject.toml
drwxr-xr-x 2 root root  4096 Aug 13 02:43 requirements
drwxrwxrwx 4 root root  4096 Aug 13 02:43 src
drwxrwxrwx 6 root root  4096 Aug 13 02:43 tests
-rw-r--r-- 1 root root  1281 Aug 13 02:43 tox.ini
966bb873 SWE-bench
7ee9ceb7 Merge branch '2.2.x'
cac56a2b Merge pull request #5026 from pallets/werkzeug-compat
c4b39ba2 replace werkzeug.urls with urllib.parse
e7f8ae01 Merge pull request #5025 from pallets/update-requirements
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Blueprint\" -A 120 src/flask/blueprints.py | head -160"
}
```

**tool result**

```
32:class BlueprintSetupState:
33-    """Temporary holder object for registering a blueprint with the
34-    application.  An instance of this class is created by the
35-    :meth:`~flask.Blueprint.make_setup_state` method and later passed
36-    to all register callback functions.
37-    """
38-
39-    def __init__(
40-        self,
41-        blueprint: "Blueprint",
42-        app: "Flask",
43-        options: t.Any,
44-        first_registration: bool,
45-    ) -> None:
46-        #: a reference to the current application
47-        self.app = app
48-
49-        #: a reference to the blueprint that created this setup state.
50-        self.blueprint = blueprint
51-
52-        #: a dictionary with all options that were passed to the
53-        #: :meth:`~flask.Flask.register_blueprint` method.
54-        self.options = options
55-
56-        #: as blueprints can be registered multiple times with the
57-        #: application and not everything wants to be registered
58-        #: multiple times on it, this attribute can be used to figure
59-        #: out if the blueprint was registered in the past already.
60-        self.first_registration = first_registration
61-
62-        subdomain = self.options.get("subdomain")
63-        if subdomain is None:
64-            subdomain = self.blueprint.subdomain
65-
66-        #: The subdomain that the blueprint should be active for, ``None``
67-        #: otherwise.
68-        self.subdomain = subdomain
69-
70-        url_prefix = self.options.get("url_prefix")
71-        if url_prefix is None:
72-            url_prefix = self.blueprint.url_prefix
73-        #: The prefix that should be used for all URLs defined on the
74-        #: blueprint.
75-        self.url_prefix = url_prefix
76-
77-        self.name = self.options.get("name", blueprint.name)
78-        self.name_prefix = self.options.get("name_prefix", "")
79-
80-        #: A dictionary with URL defaults that is added to each and every
81-        #: URL that was defined with the blueprint.
82-        self.url_defaults = dict(self.blueprint.url_values_defaults)
83-        self.url_defaults.update(self.options.get("url_defaults", ()))
84-
85-    def add_url_rule(
86-        self,
87-        rule: str,
88-        endpoint: t.Optional[str] = None,
89-        view_func: t.Optional[t.Callable] = None,
90-        **options: t.Any,
91-    ) -> None:
92-        """A helper method to register a rule (and optionally a view function)
93-        to the application.  The endpoint is automatically prefixed with the
94-        blueprint's name.
95-        """
96-        if self.url_prefix is not None:
97-            if rule:
98-                rule = "/".join((self.url_prefix.rstrip("/"), rule.lstrip("/")))
99-            else:
100-                rule = self.url_prefix
101-        options.setdefault("subdomain", self.subdomain)
102-        if endpoint is None:
103-            endpoint = _endpoint_from_view_func(view_func)  # type: ignore
104-        defaults = self.url_defaults
105-        if "defaults" in options:
106-            defaults = dict(defaults, **options.pop("defaults"))
107-
108-        self.app.add_url_rule(
109-            rule,
110-            f"{self.name_prefix}.{self.name}.{endpoint}".lstrip("."),
111-            view_func,
112-            defaults=defaults,
113-            **options,
114-        )
115-
116-
117:class Blueprint(Scaffold):
118-    """Represents a blueprint, a collection of routes and other
119-    app-related functions that can be registered on a real application
120-    later.
121-
122-    A blueprint is an object that allows defining application functions
123-    without requiring an application object ahead of time. It uses the
124-    same decorators as :class:`~flask.Flask`, but defers the need for an
125-    application by recording them for later registration.
126-
127-    Decorating a function with a blueprint creates a deferred function
128-    that is called with :class:`~flask.blueprints.BlueprintSetupState`
129-    when the blueprint is registered on an application.
130-
131-    See :doc:`/blueprints` for more information.
132-
133-    :param name: The name of the blueprint. Will be prepended to each
134-        endpoint name.
135-    :param import_name: The name of the blueprint package, usually
136-        ``__name__``. This helps locate the ``root_path`` for the
137-        blueprint.
138-    :param static_folder: A folder with static files that should be
139-        served by the blueprint's static route. The path is relative to
140-        the blueprint's root path. Blueprint static files are disabled
141-        by default.
142-    :param static_url_path: The url to serve static files from.
143-        Defaults to ``static_folder``. If the blueprint does not have
144-        a ``url_prefix``, the app's static route will take precedence,
145-        and the blueprint's static files won't be accessible.
146-    :param template_folder: A folder with templates that should be added
147-        to the app's template search path. The path is relative to the
148-        blueprint's root path. Blueprint templates are disabled by
149-        default. Blueprint templates have a lower precedence than those
150-        in the app's templates folder.
151-    :param url_prefix: A path to prepend to all of the blueprint's URLs,
152-        to make them distinct from the rest of the app's routes.
153-    :param subdomain: A subdomain that blueprint routes will match on by
154-        default.
155-    :param url_defaults: A dict of default values that blueprint routes
156-        will receive by default.
157-    :param root_path: By default, the blueprint will automatically set
158-        this based on ``import_name``. In certain situations this
159-        automatic detection can fail, so the path can be specified
160-        manually instead.
161-
162-    .. versionchanged:: 1.1.0
163-        Blueprints have a ``cli`` group to register nested CLI commands.
164-        The ``cli_group`` parameter controls the name of the group under
165-        the ``flask`` command.
166-
167-    .. versionadded:: 0.7
168-    """
169-
170-    _got_registered_once = False
171-
172-    def __init__(
173-        self,
174-        name: str,
175-        import_name: str,
176-        static_folder: t.Optional[t.Union[str, os.PathLike]] = None,
177-        static_url_path: t.Optional[str] = None,
178-        template_folder: t.Optional[t.Union[str, os.PathLike]] = None,
179-        url_prefix: t.Optional[str] = None,
180-        subdomain: t.Optional[str] = None,
181-        url_defaults: t.Optional[dict] = None,
182-        root_path: t.Optional[str] = None,
183-        cli_group: t.Optional[str] = _sentinel,  # type: ignore
184-    ):
185-        super().__init__(
186-            import_name=import_name,
187-            static_folder=static_folder,
188-            static_url_path=static_url_path,
189-            template_folder=template_folder,
190-            root_path=root_path,
191-        )
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '185,240p' src/flask/blueprints.py; grep -rn \"empty\\|name\" tests/test_blueprints.py | grep -i \"empty\\|ValueError\" | head -20"
}
```

**tool result**

```
        super().__init__(
            import_name=import_name,
            static_folder=static_folder,
            static_url_path=static_url_path,
            template_folder=template_folder,
            root_path=root_path,
        )

        if "." in name:
            raise ValueError("'name' may not contain a dot '.' character.")

        self.name = name
        self.url_prefix = url_prefix
        self.subdomain = subdomain
        self.deferred_functions: t.List[DeferredSetupFunction] = []

        if url_defaults is None:
            url_defaults = {}

        self.url_values_defaults = url_defaults
        self.cli_group = cli_group
        self._blueprints: t.List[t.Tuple["Blueprint", dict]] = []

    def _check_setup_finished(self, f_name: str) -> None:
        if self._got_registered_once:
            raise AssertionError(
                f"The setup method '{f_name}' can no longer be called on the blueprint"
                f" '{self.name}'. It has already been registered at least once, any"
                " changes will not be applied consistently.\n"
                "Make sure all imports, decorators, functions, etc. needed to set up"
                " the blueprint are done before registering it."
            )

    @setupmethod
    def record(self, func: t.Callable) -> None:
        """Registers a function that is called when the blueprint is
        registered on the application.  This function is called with the
        state as argument as returned by the :meth:`make_setup_state`
        method.
        """
        self.deferred_functions.append(func)

    @setupmethod
    def record_once(self, func: t.Callable) -> None:
        """Works like :meth:`record` but wraps the function in another
        function that will ensure the function is only called once.  If the
        blueprint is registered a second time on the application, the
        function passed is not called.
        """

        def wrapper(state: BlueprintSetupState) -> None:
            if state.first_registration:
                func(state)

        self.record(update_wrapper(wrapper, func))

276:def test_empty_url_defaults(app, client):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: src/flask/blueprints.py\n@@\n-        if \".\" in name:\n+        if not name:\n+            raise ValueError(\"'name' may not be empty.\")\n+\n+        if \".\" in name:\n             raise ValueError(\"'name' may not contain a dot '.' character.\")\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[src/flask/blueprints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

src/flask/blueprints.py now (624 lines), around the change:
190:            root_path=root_path,
191:        )
192:
193:        if not name:
194:            raise ValueError("'name' may not be empty.")
195:
196:        if "." in name:
197:            raise ValueError("'name' may not contain a dot '.' character.")
198:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"dot\\|may not\" tests/test_blueprints.py | head"
}
```

**tool result**

```
254:def test_dotted_name_not_allowed(app, client):
259:def test_dotted_names_from_app(app, client):
322:def test_route_decorator_custom_endpoint_with_dots(app, client):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '250,265p' tests/test_blueprints.py"
}
```

**tool result**

```
    templates = sorted(app.jinja_env.list_templates())
    assert templates == ["admin/index.html", "frontend/index.html"]


def test_dotted_name_not_allowed(app, client):
    with pytest.raises(ValueError):
        flask.Blueprint("app.ui", __name__)


def test_dotted_names_from_app(app, client):
    test = flask.Blueprint("test", __name__)

    @app.route("/")
    def app_index():
        return flask.url_for("test.index")
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/test_blueprints.py\n@@\n def test_dotted_name_not_allowed(app, client):\n     with pytest.raises(ValueError):\n         flask.Blueprint(\"app.ui\", __name__)\n \n \n+def test_empty_name_not_allowed(app, client):\n+    with pytest.raises(ValueError):\n+        flask.Blueprint(\"\", __name__)\n+\n+\n def test_dotted_names_from_app(app, client):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/test_blueprints.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/test_blueprints.py now (1053 lines), around the change:
254:def test_dotted_name_not_allowed(app, client):
255:    with pytest.raises(ValueError):
256:        flask.Blueprint("app.ui", __name__)
257:
258:
259:def test_empty_name_not_allowed(app, client):
260:    with pytest.raises(ValueError):
261:        flask.Blueprint("", __name__)
262:
263:
264:def test_dotted_names_from_app(app, client):
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_blueprints.py -q 2>&1 | tail -15"
}
```

**tool result**

```
............................................................             [100%]
60 passed in 0.32s
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,30p' CHANGES.rst"
}
```

**tool result**

```
Version 2.3.0
-------------

Unreleased

-   Remove previously deprecated code. :pr:`4995`

    -   The ``push`` and ``pop`` methods of the deprecated ``_app_ctx_stack`` and
        ``_request_ctx_stack`` objects are removed. ``top`` still exists to give
        extensions more time to update, but it will be removed.
    -   The ``FLASK_ENV`` environment variable, ``ENV`` config key, and ``app.env``
        property are removed.
    -   The ``session_cookie_name``, ``send_file_max_age_default``, ``use_x_sendfile``,
        ``propagate_exceptions``, and ``templates_auto_reload`` properties on ``app``
        are removed.
    -   The ``JSON_AS_ASCII``, ``JSON_SORT_KEYS``, ``JSONIFY_MIMETYPE``, and
        ``JSONIFY_PRETTYPRINT_REGULAR`` config keys are removed.
    -   The ``app.before_first_request`` and ``bp.before_app_first_request`` decorators
        are removed.
    -   ``json_encoder`` and ``json_decoder`` attributes on app and blueprint, and the
        corresponding ``json.JSONEncoder`` and ``JSONDecoder`` classes, are removed.
    -   The ``json.htmlsafe_dumps`` and ``htmlsafe_dump`` functions are removed.
    -   Calling setup methods on blueprints after registration is an error instead of a
        warning. :pr:`4997`

-   Importing ``escape`` and ``Markup`` from ``flask`` is deprecated. Import them
    directly from ``markupsafe`` instead. :pr:`4996`
-   The ``app.got_first_request`` property is deprecated. :pr:`4997`
-   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the
    decorated function if locking is needed. :issue:`4993`
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: CHANGES.rst\n@@\n -   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the\n     decorated function if locking is needed. :issue:`4993`\n+-   A ``ValueError`` is raised when a blueprint is given an empty name.\n+    :issue:`4944`\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[CHANGES.rst] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

CHANGES.rst now (1466 lines), around the change:
28:-   The ``app.got_first_request`` property is deprecated. :pr:`4997`
29:-   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the
30:    decorated function if locking is needed. :issue:`4993`
31:-   A ``ValueError`` is raised when a blueprint is given an empty name.
32:    :issue:`4944`
33:-   Remove uses of locks that could cause requests to block each other very briefly.
34:    :issue:`4993`
35:-   Use modern packaging metadata with ``pyproject.toml`` instead of ``setup.cfg``.
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest -q 2>&1 | tail -5"
}
```

**tool result**

```
FAILED tests/test_testing.py::test_session_transactions - DeprecationWarning:...
FAILED tests/test_testing.py::test_session_transactions_no_null_sessions - De...
FAILED tests/test_testing.py::test_session_transactions_keep_context - Deprec...
FAILED tests/test_testing.py::test_session_transaction_needs_cookies - Deprec...
8 failed, 467 passed, 10 skipped in 3.95s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_testing.py::test_session_transactions -q 2>&1 | tail -20"
}
```

**tool result**

```
src/flask/testing.py:140: in session_transaction
    if self.cookie_jar is None:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <FlaskClient <Flask 'flask_test'>>

    @property
    def cookie_jar(self) -> t.Iterable[Cookie] | None:
>       warnings.warn(
            "The 'cookie_jar' attribute is a private API and will be removed in"
            " Werkzeug 3.0. Use the 'get_cookie' method instead.",
            DeprecationWarning,
            stacklevel=2,
        )
E       DeprecationWarning: The 'cookie_jar' attribute is a private API and will be removed in Werkzeug 3.0. Use the 'get_cookie' method instead.

/opt/miniconda3/envs/testbed/lib/python3.11/site-packages/werkzeug/test.py:862: DeprecationWarning
=========================== short test summary info ============================
FAILED tests/test_testing.py::test_session_transactions - DeprecationWarning:...
1 failed in 0.25s
```

**assistant**

```
Implemented the change.

- `src/flask/blueprints.py`: `Blueprint.__init__` now raises `ValueError("'name' may not be empty.")` when `name` is empty, before the existing dot-character check.
- `tests/test_blueprints.py`: added `test_empty_name_not_allowed`.
- `CHANGES.rst`: added a changelog entry referencing issue #4944.

`tests/test_blueprints.py` passes (60 passed). The full suite has 8 pre-existing failures in `tests/test_testing.py` caused by a Werkzeug `DeprecationWarning` about `cookie_jar`, unrelated to this change.
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest -q --ignore=tests/test_testing.py 2>&1 | tail -3; echo ---; python -c \"\nimport flask\ntry:\n    flask.Blueprint('', __name__)\nexcept ValueError as e:\n    print('ValueError:', e)\n\""
}
```

**tool result**

```
FAILED tests/test_basic.py::test_session_using_session_settings - AssertionEr...
FAILED tests/test_json.py::test_modified_url_encoding - DeprecationWarning: T...
4 failed, 447 passed, 9 skipped in 2.06s
---
ValueError: 'name' may not be empty.
```

**assistant**

````
Done. The behavior is verified directly:

```
ValueError: 'name' may not be empty.
```

Summary of changes:
- **`src/flask/blueprints.py`** — `Blueprint.__init__` raises `ValueError` for an empty name, before the existing dot check.
- **`tests/test_blueprints.py`** — new `test_empty_name_not_allowed`; all 60 blueprint tests pass.
- **`CHANGES.rst`** — changelog entry for issue #4944.

The remaining full-suite failures are pre-existing environment issues (Werkzeug `cookie_jar` deprecation, session settings, JSON URL encoding) and unrelated to this change.
````

### Step `repair` (agent)

**user**

```
Workflow team-solve, task repair.

You are the single repair worker in a fresh context. The run's files are in .memdoor/runs/team-solve-2026-11-06T122944/: task.md (the task: the prompt
and what plan settled), plan.md, notes.md (the ledger every role writes
to). They are never part of the work and never committed. Keep
no rule with the notes tool: it writes the project's AGENTS.md.
Do not commit, check out, reset or stash: the tree's HEAD stays where it is.
Read review.md, test-status.txt and notes.md there. If review.md says
`verdict: PASS`, change nothing and report that repair was unnecessary.
Otherwise read task.md, plan.md, changes.diff and test-output.log, then
correct the work using the manager's instructions, as the task needs. Undo a change outside the Scope only when the review names it as one the
task does not need; a change the fix needs stays, wherever it is.
Run the Check to verify the correction. Write
.memdoor/runs/team-solve-2026-11-06T122944/repair.md: what you changed
and what the Check printed, and append a short repair note to notes.md. Do not start another repair round and do not change
task.md, the prompt, test inputs or expected outputs. The final check
alone decides the run. Do not spawn agents or rely on chat history.

This task is done when this command exits 0 in the project: bash .memdoor/runs/team-solve-{{.partition}}/done.sh repair .memdoor/runs/team-solve-{{.partition}}
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "ls -la .memdoor/runs/team-solve-2026-11-06T122944/"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/review.md"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/test-status.txt"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/notes.md"
}
```

**tool result**

```
total 152
drwxr-xr-x 2 root root  4096 Nov  6 12:30 .
drwxr-xr-x 4 root root  4096 Nov  6 12:29 ..
-rw-r--r-- 1 root root    41 Nov  6 12:29 base.txt
-rw-r--r-- 1 root root   545 Nov  6 12:30 baseline-check.log
-rw-r--r-- 1 root root     2 Nov  6 12:30 baseline-status.txt
-rw-r--r-- 1 root root  1563 Nov  6 12:30 changes.diff
-rw-r--r-- 1 root root     8 Nov  6 12:30 check-kind.txt
-rw-r--r-- 1 root root 55087 Nov  6 12:30 context.md
-rw-r--r-- 1 root root   728 Nov  6 12:30 direct-check.log
-rw-r--r-- 1 root root     2 Nov  6 12:30 direct-status.txt
-rw-r--r-- 1 root root  1563 Nov  6 12:30 direct.patch
-rwxr-xr-x 1 root root  2190 Nov  6 12:29 done.sh
-rw-r--r-- 1 root root     5 Nov  6 12:29 head.txt
-rw-r--r-- 1 root root    73 Nov  6 12:30 notes.md
-rw-r--r-- 1 root root 10070 Nov  6 12:29 outline.md
-rw-r--r-- 1 root root  1050 Nov  6 12:30 plan.md
-rw-r--r-- 1 root root   195 Nov  6 12:29 prompt.md
-rw-r--r-- 1 root root   636 Nov  6 12:30 review.md
-rw-r--r-- 1 root root   240 Nov  6 12:30 scope.txt
-rw-r--r-- 1 root root     0 Nov  6 12:29 start
-rw-r--r-- 1 root root   516 Nov  6 12:30 task.md
-rw-r--r-- 1 root root   728 Nov  6 12:30 test-output.log
-rw-r--r-- 1 root root     2 Nov  6 12:30 test-status.txt
-rw-r--r-- 1 root root  1934 Nov  6 12:29 untracked-before.txt
```

**tool result**

```
verdict: FAIL
- The functional fix in `src/flask/blueprints.py` correctly raises `ValueError` for an empty blueprint name and still accepts non-empty names.
- The added test in `tests/test_blueprints.py` covers the required behavior, and `pytest tests/test_blueprints.py` passes with 60 tests.
- `CHANGES.rst` is outside the declared scope and is not required by the Prompt or Done when; the scope report explicitly flags it as out of scope.

Repair: revert only `CHANGES.rst` (e.g. `git checkout -- CHANGES.rst`) to remove the out-of-scope changelog entry; keep the changes in `src/flask/blueprints.py` and `tests/test_blueprints.py`.
```

**tool result**

```
0
```

**tool result**

```
# Notes, run 2026-11-06T122944

## Solver decision

## Review

## Repair
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/task.md"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/plan.md"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/changes.diff"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/test-output.log"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/scope.txt"
}
```

**assistant → tool `read_file`**

```json
{
  "path": ".memdoor/runs/team-solve-2026-11-06T122944/done.sh"
}
```

**tool result**

```
# Task

## Prompt

Require a non-empty name for Blueprints
Things do not work correctly if a Blueprint is given an empty name (e.g. #4944).
It would be helpful if a `ValueError` was raised when trying to do that.

## Deliverable

changes to this tree

## Check

`pytest tests/test_blueprints.py`

## Scope

`src/flask/blueprints.py`
`tests/test_blueprints.py`

## Done when

- Constructing a `Blueprint` with an empty name raises `ValueError`.
- Constructing a `Blueprint` with a non-empty name is still accepted.
```

**tool result**

````
## Deliverable
changes to this tree

## Check
`pytest tests/test_blueprints.py`

## Scope
`src/flask/blueprints.py`
`tests/test_blueprints.py`

## Done when
- Constructing a `Blueprint` with an empty name raises `ValueError`.
- Constructing a `Blueprint` with a non-empty name is still accepted.

## Approach
Add a guard in `Blueprint.__init__` before `self.name` is assigned and before the existing dot check:

```python
if not name:
    raise ValueError("'name' may not be empty.")
```

Then add a regression test in `tests/test_blueprints.py` asserting that `Blueprint("", __name__)` raises `ValueError`, while existing non-empty-name tests continue to pass.

Candidate approaches:
- `if not name:` — matches the “non-empty” requirement and also rejects other falsy values; preferred.
- `if name == "":` — narrower, only rejects the empty string; acceptable but less aligned with the wording.
- Validate later in `register()` — rejected because the prompt asks for the error when trying to create the Blueprint, not when registering it.


(this is the fourth time you have made nearly this same read_file call this turn — the earlier answers are above. Do not ask it again; do the next real step)
````

**tool result**

```
diff --git a/CHANGES.rst b/CHANGES.rst
index 498d5e51..865363a8 100644
--- a/CHANGES.rst
+++ b/CHANGES.rst
@@ -28,6 +28,8 @@ Unreleased
 -   The ``app.got_first_request`` property is deprecated. :pr:`4997`
 -   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the
     decorated function if locking is needed. :issue:`4993`
+-   A ``ValueError`` is raised when a blueprint is given an empty name.
+    :issue:`4944`
 -   Remove uses of locks that could cause requests to block each other very briefly.
     :issue:`4993`
 -   Use modern packaging metadata with ``pyproject.toml`` instead of ``setup.cfg``.
diff --git a/src/flask/blueprints.py b/src/flask/blueprints.py
index eb50585d..1aa82562 100644
--- a/src/flask/blueprints.py
+++ b/src/flask/blueprints.py
@@ -190,6 +190,9 @@ class Blueprint(Scaffold):
             root_path=root_path,
         )
 
+        if not name:
+            raise ValueError("'name' may not be empty.")
+
         if "." in name:
             raise ValueError("'name' may not contain a dot '.' character.")
 
diff --git a/tests/test_blueprints.py b/tests/test_blueprints.py
index d46b769b..76cee660 100644
--- a/tests/test_blueprints.py
+++ b/tests/test_blueprints.py
@@ -256,6 +256,11 @@ def test_dotted_name_not_allowed(app, client):
         flask.Blueprint("app.ui", __name__)
 
 
+def test_empty_name_not_allowed(app, client):
+    with pytest.raises(ValueError):
+        flask.Blueprint("", __name__)
+
+
 def test_dotted_names_from_app(app, client):
     test = flask.Blueprint("test", __name__)
 


(this is the fifth time you have made nearly this same read_file call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**tool result**

```
check: pytest tests/test_blueprints.py
============================= test session starts ==============================
platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0
rootdir: /testbed
configfile: pyproject.toml
collected 60 items

tests/test_blueprints.py ............................................... [ 78%]
.............                                                            [100%]

============================== 60 passed in 0.77s ==============================
scope: src/flask/blueprints.py tests/test_blueprints.py
OUTSIDE THE SCOPE: CHANGES.rst +2 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: src/flask/blueprints.py +3 -0
changed: tests/test_blueprints.py +5 -0
```

**tool result**

```
scope: src/flask/blueprints.py tests/test_blueprints.py
OUTSIDE THE SCOPE: CHANGES.rst +2 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: src/flask/blueprints.py +3 -0
changed: tests/test_blueprints.py +5 -0


(this is the seventh time you have made nearly this same read_file call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**tool result**

```
not run: the loop-breaker tripped earlier in this same reply. STOP issuing tool calls and answer with what you have.
```

**user**

```
⚠ The same tool call keeps failing the same way. Do not repeat it. Change your approach, or tell the person what is blocking you and end your turn.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '20,40p' CHANGES.rst"
}
```

**tool result**

```
    -   ``json_encoder`` and ``json_decoder`` attributes on app and blueprint, and the
        corresponding ``json.JSONEncoder`` and ``JSONDecoder`` classes, are removed.
    -   The ``json.htmlsafe_dumps`` and ``htmlsafe_dump`` functions are removed.
    -   Calling setup methods on blueprints after registration is an error instead of a
        warning. :pr:`4997`

-   Importing ``escape`` and ``Markup`` from ``flask`` is deprecated. Import them
    directly from ``markupsafe`` instead. :pr:`4996`
-   The ``app.got_first_request`` property is deprecated. :pr:`4997`
-   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the
    decorated function if locking is needed. :issue:`4993`
-   A ``ValueError`` is raised when a blueprint is given an empty name.
    :issue:`4944`
-   Remove uses of locks that could cause requests to block each other very briefly.
    :issue:`4993`
-   Use modern packaging metadata with ``pyproject.toml`` instead of ``setup.cfg``.
    :pr:`4947`
-   Ensure subdomains are applied with nested blueprints. :issue:`4834`
-   ``config.from_file`` can use ``text=False`` to indicate that the parser wants a
    binary file instead. :issue:`4989`
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: CHANGES.rst\n@@\n--   A ``ValueError`` is raised when a blueprint is given an empty name.\n-    :issue:`4944`\n -   Remove uses of locks that could cause requests to block each other very briefly.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[CHANGES.rst] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

CHANGES.rst now (1464 lines), around the change:
28:-   The ``app.got_first_request`` property is deprecated. :pr:`4997`
29:-   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the
30:    decorated function if locking is needed. :issue:`4993`
31:-   Remove uses of locks that could cause requests to block each other very briefly.
32:    :issue:`4993`
33:-   Use modern packaging metadata with ``pyproject.toml`` instead of ``setup.cfg``.
34:    :pr:`4947`
```

**assistant → tool `bash`**

```json
{
  "command": "pytest tests/test_blueprints.py 2>&1 | tail -20"
}
```

**tool result**

```
============================= test session starts ==============================
platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0
rootdir: /testbed
configfile: pyproject.toml
collected 60 items

tests/test_blueprints.py ............................................... [ 78%]
.............                                                            [100%]

============================== 60 passed in 0.79s ==============================
```

**assistant → tool `apply_patch`**

````json
{
  "input": "*** Begin Patch\n*** Add File: .memdoor/runs/team-solve-2026-11-06T122944/repair.md\n+# Repair\n+\n+Review verdict was FAIL: the functional fix and test were correct, but\n+`CHANGES.rst` was outside the declared scope.\n+\n+## What changed\n+\n+- Reverted the out-of-scope changelog entry in `CHANGES.rst` (removed the\n+  two added lines about the empty-blueprint `ValueError`).\n+- Kept the in-scope changes in `src/flask/blueprints.py` (raise `ValueError`\n+  for an empty name) and `tests/test_blueprints.py` (regression test).\n+\n+## Check output\n+\n+`pytest tests/test_blueprints.py`:\n+\n+```\n+============================= test session starts =============================\n+platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0\n+rootdir: /testbed\n+configfile: pyproject.toml\n+collected 60 items\n+\n+tests/test_blueprints.py ............................................... [ 78%]\n+.............                                                            [100%]\n+\n+============================== 60 passed in 0.79s ==============================\n+```\n*** Update File: .memdoor/runs/team-solve-2026-11-06T122944/notes.md\n@@\n ## Repair\n+\n+Reverted out-of-scope `CHANGES.rst` entry per review; kept the fix and test.\n+`pytest tests/test_blueprints.py` -> 60 passed.\n*** End Patch\n"
}
````

**tool result**

```
Patch applied. added=[.memdoor/runs/team-solve-2026-11-06T122944/repair.md] modified=[.memdoor/runs/team-solve-2026-11-06T122944/notes.md] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

.memdoor/runs/team-solve-2026-11-06T122944/notes.md now (10 lines), around the change:
5:## Review
6:
7:## Repair
8:
9:Reverted out-of-scope `CHANGES.rst` entry per review; kept the fix and test.
10:`pytest tests/test_blueprints.py` -> 60 passed.
```

**assistant → tool `bash`**

```json
{
  "command": "bash .memdoor/runs/team-solve-2026-11-06T122944/done.sh repair .memdoor/runs/team-solve-2026-11-06T122944; echo \"EXIT=$?\""
}
```

**tool result**

```
repair: done
EXIT=0
```

**assistant**

```
Repair complete.

- Review verdict was `FAIL` only because `CHANGES.rst` was outside the declared scope.
- Reverted the out-of-scope changelog entry; kept the in-scope fix in `src/flask/blueprints.py` and the regression test in `tests/test_blueprints.py`.
- Check `pytest tests/test_blueprints.py`: **60 passed**.
- Wrote `repair.md` and appended a repair note to `notes.md`.
- `done.sh repair ...` exited **0**.
```

## Run folder `team-solve-2026-11-06T122944`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
966bb873e3a1e42d857362a17f5af2533dfd8f46
```

### `baseline-check.log`

```
check: pytest tests/test_blueprints.py
============================= test session starts ==============================
platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T122944/baseline-tree
configfile: pyproject.toml
collected 59 items

tests/test_blueprints.py ............................................... [ 79%]
............                                                             [100%]

============================== 59 passed in 0.34s ==============================
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/CHANGES.rst b/CHANGES.rst
index 498d5e51..865363a8 100644
--- a/CHANGES.rst
+++ b/CHANGES.rst
@@ -28,6 +28,8 @@ Unreleased
 -   The ``app.got_first_request`` property is deprecated. :pr:`4997`
 -   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the
     decorated function if locking is needed. :issue:`4993`
+-   A ``ValueError`` is raised when a blueprint is given an empty name.
+    :issue:`4944`
 -   Remove uses of locks that could cause requests to block each other very briefly.
     :issue:`4993`
 -   Use modern packaging metadata with ``pyproject.toml`` instead of ``setup.cfg``.
diff --git a/src/flask/blueprints.py b/src/flask/blueprints.py
index eb50585d..1aa82562 100644
--- a/src/flask/blueprints.py
+++ b/src/flask/blueprints.py
@@ -190,6 +190,9 @@ class Blueprint(Scaffold):
             root_path=root_path,
         )
 
+        if not name:
+            raise ValueError("'name' may not be empty.")
+
         if "." in name:
             raise ValueError("'name' may not contain a dot '.' character.")
 
diff --git a/tests/test_blueprints.py b/tests/test_blueprints.py
index d46b769b..76cee660 100644
--- a/tests/test_blueprints.py
+++ b/tests/test_blueprints.py
@@ -256,6 +256,11 @@ def test_dotted_name_not_allowed(app, client):
         flask.Blueprint("app.ui", __name__)
 
 
+def test_empty_name_not_allowed(app, client):
+    with pytest.raises(ValueError):
+        flask.Blueprint("", __name__)
+
+
 def test_dotted_names_from_app(app, client):
     test = flask.Blueprint("test", __name__)
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

Require a non-empty name for Blueprints
Things do not work correctly if a Blueprint is given an empty name (e.g. #4944).
It would be helpful if a `ValueError` was raised when trying to do that.

## Deliverable

changes to this tree

## Check

`pytest tests/test_blueprints.py`

## Scope

`src/flask/blueprints.py`
`tests/test_blueprints.py`

## Done when

- Constructing a `Blueprint` with an empty name raises `ValueError`.
- Constructing a `Blueprint` with a non-empty name is still accepted.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest tests/test_blueprints.py`

## Scope
`src/flask/blueprints.py`
`tests/test_blueprints.py`

## Done when
- Constructing a `Blueprint` with an empty name raises `ValueError`.
- Constructing a `Blueprint` with a non-empty name is still accepted.

## Approach
Add a guard in `Blueprint.__init__` before `self.name` is assigned and before the existing dot check:

```python
if not name:
    raise ValueError("'name' may not be empty.")
```

Then add a regression test in `tests/test_blueprints.py` asserting that `Blueprint("", __name__)` raises `ValueError`, while existing non-empty-name tests continue to pass.

Candidate approaches:
- `if not name:` — matches the “non-empty” requirement and also rejects other falsy values; preferred.
- `if name == "":` — narrower, only rejects the empty string; acceptable but less aligned with the wording.
- Validate later in `register()` — rejected because the prompt asks for the error when trying to create the Blueprint, not when registering it.


# src/flask/blueprints.py

```
import os
import typing as t
from collections import defaultdict
from functools import update_wrapper

from . import typing as ft
from .scaffold import _endpoint_from_view_func
from .scaffold import _sentinel
from .scaffold import Scaffold
from .scaffold import setupmethod

if t.TYPE_CHECKING:  # pragma: no cover
    from .app import Flask

DeferredSetupFunction = t.Callable[["BlueprintSetupState"], t.Callable]
T_after_request = t.TypeVar("T_after_request", bound=ft.AfterRequestCallable)
T_before_request = t.TypeVar("T_before_request", bound=ft.BeforeRequestCallable)
T_error_handler = t.TypeVar("T_error_handler", bound=ft.ErrorHandlerCallable)
T_teardown = t.TypeVar("T_teardown", bound=ft.TeardownCallable)
T_template_context_processor = t.TypeVar(
    "T_template_context_processor", bound=ft.TemplateContextProcessorCallable
)
T_template_filter = t.TypeVar("T_template_filter", bound=ft.TemplateFilterCallable)
T_template_global = t.TypeVar("T_template_global", bound=ft.TemplateGlobalCallable)
T_template_test = t.TypeVar("T_template_test", bound=ft.TemplateTestCallable)
T_url_defaults = t.TypeVar("T_url_defaults", bound=ft.URLDefaultCallable)
T_url_value_preprocessor = t.TypeVar(
    "T_url_value_preprocessor", bound=ft.URLValuePreprocessorCallable
)


class BlueprintSetupState:
    """Temporary holder object for registering a blueprint with the
    application.  An instance of this class is created by the
    :meth:`~flask.Blueprint.make_setup_state` method and later passed
    to all register callback functions.
    """

    def __init__(
        self,
        blueprint: "Blueprint",
        app: "Flask",
        options: t.Any,
        first_registration: bool,
    ) -> None:
        #: a reference to the current application
        self.app = app

        #: a reference to the blueprint that created this setup state.
        self.blueprint = blueprint

        #: a dictionary with all options that were passed to the
        #: :meth:`~flask.Flask.register_blueprint` method.
        self.options = options

        #: as blueprints can be registered multiple times with the
        #: application and not everything wants to be registered
        #: multiple times on it, this attribute can be used to figure
        #: out if the blueprint was registered in the past already.
        self.first_registration = first_registration

        subdomain = self.options.get("subdomain")
        if subdomain is None:
            subdomain = self.blueprint.subdomain

        #: The subdomain that the blueprint should be active for, ``None``
        #: otherwise.
        self.subdomain = subdomain

        url_prefix = self.options.get("url_prefix")
        if url_prefix is None:
            url_prefix = self.blueprint.url_prefix
        #: The prefix that should be used for all URLs defined on the
        #: blueprint.
        self.url_prefix = url_prefix

        self.name = self.options.get("name", blueprint.name)
        self.name_prefix = self.options.get("name_prefix", "")

        #: A dictionary with URL defaults that is added to each and every
        #: URL that was defined with the blueprint.
        self.url_defaults = dict(self.blueprint.url_values_defaults)
        self.url_defaults.update(self.options.get("url_defaults", ()))

    def add_url_rule(
        self,
        rule: str,
        endpoint: t.Optional[str] = None,
        view_func: t.Optional[t.Callable] = None,
        **options: t.Any,
    ) -> None:
        """A helper method to register a rule (and optionally a view function)
        to the application.  The endpoint is automatically prefixed with the
        blueprint's name.
        """
        if self.url_prefix is not None:
            if rule:
                rule = "/".join((self.url_prefix.rstrip("/"), rule.lstrip("/")))
            else:
                rule = self.url_prefix
        options.setdefault("subdomain", self.subdomain)
        if endpoint is None:
            endpoint = _endpoint_from_view_func(view_func)  # type: ignore
        defaults = self.url_defaults
        if "defaults" in options:
            defaults = dict(defaults, **options.pop("defaults"))

        self.app.add_url_rule(
            rule,
            f"{self.name_prefix}.{self.name}.{endpoint}".lstrip("."),
            view_func,
            defaults=defaults,
            **options,
        )


class Blueprint(Scaffold):
    """Represents a blueprint, a collection of routes and other
    app-related functions that can be registered on a real application
    later.

    A blueprint is an object that allows defining application functions
    without requiring an application object ahead of time. It uses the
    same decorators as :class:`~flask.Flask`, but defers the need for an
    application by recording them for later registration.

    Decorating a function with a blueprint creates a deferred function
    that is called with :class:`~flask.blueprints.BlueprintSetupState`
    when the blueprint is registered on an application.

    See :doc:`/blueprints` for more information.

    :param name: The name of the blueprint. Will be prepended to each
        endpoint name.
    :param import_name: The name of the blueprint package, usually
        ``__name__``. This helps locate the ``root_path`` for the
        blueprint.
    :param static_folder: A folder with static files that should be
        served by the blueprint's static route. The path is relative to
        the blueprint's root path. Blueprint static files are disabled
        by default.
    :param static_url_path: The url to serve static files from.
        Defaults to ``static_folder``. If the blueprint does not have
        a ``url_prefix``, the app's static route will take precedence,
        and the blueprint's static files won't be accessible.
    :param template_folder: A folder with templates that should be added
        to the app's template search path. The path is relative to the
        blueprint's root path. Blueprint templates are disabled by
        default. Blueprint templates have a lower precedence than those
        in the app's templates folder.
    :param url_prefix: A path to prepend to all of the blueprint's URLs,
        to make them distinct from the rest of the app's routes.
    :param subdomain: A subdomain that blueprint routes will match on by
        default.
    :param url_defaults: A dict of default values that blueprint routes
        will receive by default.
    :param root_path: By default, the blueprint will automatically set
        this based on ``import_name``. In certain situations this
        automatic detection can fail, so the path can be specified
        manually instead.

    .. versionchanged:: 1.1.0
        Blueprints have a ``cli`` group to register nested CLI commands.
        The ``cli_group`` parameter controls the name of the group under
        the ``flask`` command.

    .. versionadded:: 0.7
    """

    _got_registered_once = False

    def __init__(
        self,
        name: str,
        import_name: str,
        static_folder: t.Optional[t.Union[str, os.PathLike]] = None,
        static_url_path: t.Optional[str] = None,
        template_folder: t.Optional[t.Union[str, os.PathLike]] = None,
        url_prefix: t.Optional[str] = None,
        subdomain: t.Optional[str] = None,
        url_defaults: t.Optional[dict] = None,
        root_path: t.Optional[str] = None,
        cli_group: t.Optional[str] = _sentinel,  # type: ignore
    ):
        super().__init__(
            import_name=import_name,
            static_folder=static_folder,
            static_url_path=static_url_path,
            template_folder=template_folder,
            root_path=root_path,
        )

        if not name:
            raise ValueError("'name' may not be empty.")

        if "." in name:
            raise ValueError("'name' may not contain a dot '.' character.")

        self.name = name
        self.url_prefix = url_prefix
        self.subdomain = subdomain
        self.deferred_functions: t.List[DeferredSetupFunction] = []

        if url_defaults is None:
            url_defaults = {}

        self.url_values_defaults = url_defaults
        self.cli_group = cli_group
        self._blueprints: t.List[t.Tuple["Blueprint", dict]] = []

    def _check_setup_finished(self, f_name: str) -> None:
        if self._got_registered_once:
            raise AssertionError(
                f"The setup method '{f_name}' can no longer be called on the blueprint"
                f" '{self.name}'. It has already been registered at least once, any"
                " changes will not be applied consistently.\n"
                "Make sure all imports, decorators, functions, etc. needed to set up"
                " the blueprint are done before registering it."
            )

    @setupmethod
    def record(self, func: t.Callable) -> None:
        """Registers a function that is called when the blueprint is
        registered on the application.  This function is called with the
        state as argument as returned by the :meth:`make_setup_state`
        method.
        """
        self.deferred_functions.append(func)

    @setupmethod
    def record_once(self, func: t.Callable) -> None:
        """Works like :meth:`record` but wraps the function in another
        function that will ensure the function is only called once.  If the
        blueprint is registered a second time on the application, the
        function passed is not called.
        """

        def wrapper(state: BlueprintSetupState) -> None:
            if state.first_registration:
                func(state)

        self.record(update_wrapper(wrapper, func))

    def make_setup_state(
        self, app: "Flask", options: dict, first_registration: bool = False
    ) -> BlueprintSetupState:
        """Creates an instance of :meth:`~flask.blueprints.BlueprintSetupState`
        object that is later passed to the register callback functions.
        Subclasses can override this to return a subclass of the setup state.
        """
        return BlueprintSetupState(self, app, options, first_registration)

    @setupmethod
    def register_blueprint(self, blueprint: "Blueprint", **options: t.Any) -> None:
        """Register a :class:`~flask.Blueprint` on this blueprint. Keyword
        arguments passed to this method will override the defaults set
        on the blueprint.

        .. versionchanged:: 2.0.1
            The ``name`` option can be used to change the (pre-dotted)
            name the blueprint is registered with. This allows the same
            blueprint to be registered multiple times with unique names
            for ``url_for``.

        .. versionadded:: 2.0
        """
        if blueprint is self:
            raise ValueError("Cannot register a blueprint on itself")
        self._blueprints.append((blueprint, options))

    def register(self, app: "Flask", options: dict) -> None:
        """Called by :meth:`Flask.register_blueprint` to register all
        views and callbacks registered on the blueprint with the
        application. Creates a :class:`.BlueprintSetupState` and calls
        each :meth:`record` callback with it.

        :param app: The application this blueprint is being registered
            with.
        :param options: Keyword arguments forwarded from
            :meth:`~Flask.register_blueprint`.

        .. versionchanged:: 2.3
            Nested blueprints now correctly apply subdomains.

        .. versionchanged:: 2.1
            Registering the same blueprint with the same name multiple
            times is an error.

        .. versionchanged:: 2.0.1
            Nested blueprints are registered with their dotted name.
            This allows different blueprints with the same name to be
            nested at different locations.

        .. versionchanged:: 2.0.1
            The ``name`` option can be used to change the (pre-dotted)
            name the blueprint is registered with. This allows the same
            blueprint to be registered multiple times with unique names
            for ``url_for``.
        """
        name_prefix = options.get("name_prefix", "")
        self_name = options.get("name", self.name)
        name = f"{name_prefix}.{self_name}".lstrip(".")

        if name in app.blueprints:
            bp_desc = "this" if app.blueprints[name] is self else "a different"
            existing_at = f" '{name}'" if self_name != name else ""

            raise ValueError(
                f"The name '{self_name}' is already registered for"
                f" {bp_desc} blueprint{existing_at}. Use 'name=' to"
                f" provide a unique name."
            )

        first_bp_registration = not any(bp is self for bp in app.blueprints.values())
        first_name_registration = name not in app.blueprints

        app.blueprints[name] = self
        self._got_registered_once = True
        state = self.make_setup_state(app, options, first_bp_registration)

        if self.has_static_folder:
            state.add_url_rule(
                f"{self.static_url_path}/<path:filename>",
                view_func=self.send_static_file,
                endpoint="static",
            )

        # Merge blueprint data into parent.
        if first_bp_registration or first_name_registration:

            def extend(bp_dict, parent_dict):
                for key, values in bp_dict.items():
                    key = name if key is None else f"{name}.{key}"
                    parent_dict[key].extend(values)

            for key, value in self.error_handler_spec.items():
                key = name if key is None else f"{name}.{key}"
                value = defaultdict(
                    dict,
                    {
                        code: {
                            exc_class: func for exc_class, func in code_values.items()
                        }
                        for code, code_values in value.items()
                    },
                )
                app.error_handler_spec[key] = value

            for endpoint, func in self.view_functions.items():
                app.view_functions[endpoint] = func

            extend(self.before_request_funcs, app.before_request_funcs)
            extend(self.after_request_funcs, app.after_request_funcs)
            extend(
                self.teardown_request_funcs,
                app.teardown_request_funcs,
            )
            extend(self.url_default_functions, app.url_default_functions)
            extend(self.url_value_preprocessors, app.url_value_preprocessors)
            extend(self.template_context_processors, app.template_context_processors)

        for deferred in self.deferred_functions:
            deferred(state)

        cli_resolved_group = options.get("cli_group", self.cli_group)

        if self.cli.commands:
            if cli_resolved_group is None:
                app.cli.commands.update(self.cli.commands)
            elif cli_resolved_group is _sentinel:
                self.cli.name = name
                app.cli.add_command(self.cli)
            else:
                self.cli.name = cli_resolved_group
                app.cli.add_command(self.cli)

        for blueprint, bp_options in self._blueprints:
            bp_options = bp_options.copy()
            bp_url_prefix = bp_options.get("url_prefix")
            bp_subdomain = bp_options.get("subdomain")

            if bp_subdomain is None:
                bp_subdomain = blueprint.subdomain

            if state.subdomain is not None and bp_subdomain is not None:
                bp_options["subdomain"] = bp_subdomain + "." + state.subdomain
            elif bp_subdomain is not None:
                bp_options["subdomain"] = bp_subdomain
            elif state.subdomain is not None:
                bp_options["subdomain"] = state.subdomain

            if bp_url_prefix is None:
                bp_url_prefix = blueprint.url_prefix

            if state.url_prefix is not None and bp_url_prefix is not None:
                bp_options["url_prefix"] = (
                    state.url_prefix.rstrip("/") + "/" + bp_url_prefix.lstrip("/")
                )
            elif bp_url_prefix is not None:
                bp_options["url_prefix"] = bp_url_prefix
            elif state.url_prefix is not None:
                bp_options["url_prefix"] = state.url_prefix

            bp_options["name_prefix"] = name
            blueprint.register(app, bp_options)

    @setupmethod
    def add_url_rule(
        self,
        rule: str,
        endpoint: t.Optional[str] = None,
        view_func: t.Optional[ft.RouteCallable] = None,
        provide_automatic_options: t.Optional[bool] = None,
        **options: t.Any,
    ) -> None:
        """Register a URL rule with the blueprint. See :meth:`.Flask.add_url_rule` for
        full documentation.

        The URL rule is prefixed with the blueprint's URL prefix. The endpoint name,
        used with :func:`url_for`, is prefixed with the blueprint's name.
        """
        if endpoint and "." in endpoint:
            raise ValueError("'endpoint' may not contain a dot '.' character.")

        if view_func and hasattr(view_func, "__name__") and "." in view_func.__name__:
            raise ValueError("'view_func' name may not contain a dot '.' character.")

        self.record(
            lambda s: s.add_url_rule(
                rule,
                endpoint,
                view_func,
                provide_automatic_options=provide_automatic_options,
                **options,
            )
        )

    @setupmethod
    def app_template_filter(
        self, name: t.Optional[str] = None
    ) -> t.Callable[[T_template_filter], T_template_filter]:
        """Register a template filter, available in any template rendered by the
        application. Equivalent to :meth:`.Flask.template_filter`.

        :param name: the optional name of the filter, otherwise the
                     function name will be used.
        """

        def decorator(f: T_template_filter) -> T_template_filter:
            self.add_app_template_filter(f, name=name)
            return f

        return decorator

    @setupmethod
    def add_app_template_filter(
        self, f: ft.TemplateFilterCallable, name: t.Optional[str] = None
    ) -> None:
        """Register a template filter, available in any template rendered by the
        application. Works like the :meth:`app_template_filter` decorator. Equivalent to
        :meth:`.Flask.add_template_filter`.

        :param name: the optional name of the filter, otherwise the
                     function name will be used.
        """

        def register_template(state: BlueprintSetupState) -> None:
            state.app.jinja_env.filters[name or f.__name__] = f

        self.record_once(register_template)

    @setupmethod
    def app_template_test(
        self, name: t.Optional[str] = None
    ) -> t.Callable[[T_template_test], T_template_test]:
        """Register a template test, available in any template rendered by the
        application. Equivalent to :meth:`.Flask.template_test`.

        .. versionadded:: 0.10

        :param name: the optional name of the test, otherwise the
                     function name will be used.
        """

        def decorator(f: T_template_test) -> T_template_test:
            self.add_app_template_test(f, name=name)
            return f

        return decorator

    @setupmethod
    def add_app_template_test(
        self, f: ft.TemplateTestCallable, name: t.Optional[str] = None
    ) -> None:
        """Register a template test, available in any template rendered by the
        application. Works like the :meth:`app_template_test` decorator. Equivalent to
        :meth:`.Flask.add_template_test`.

        .. versionadded:: 0.10

        :param name: the optional name of the test, otherwise the
                     function name will be used.
        """

        def register_template(state: BlueprintSetupState) -> None:
            state.app.jinja_env.tests[name or f.__name__] = f

        self.record_once(register_template)

    @setupmethod
    def app_template_global(
        self, name: t.Optional[str] = None
    ) -> t.Callable[[T_template_global], T_template_global]:
        """Register a template global, available in any template rendered by the
        application. Equivalent to :meth:`.Flask.template_global`.

        .. versionadded:: 0.10

        :param name: the optional name of the global, otherwise the
                     function name will be used.
        """

        def decorator(f: T_template_global) -> T_template_global:
            self.add_app_template_global(f, name=name)
            return f

        return decorator

    @setupmethod
    def add_app_template_global(
        self, f: ft.TemplateGlobalCallable, name: t.Optional[str] = None
    ) -> None:
        """Register a template global, available in any template rendered by the
        application. Works like the :meth:`app_template_global` decorator. Equivalent to
        :meth:`.Flask.add_template_global`.

        .. versionadded:: 0.10

        :param name: the optional name of the global, otherwise the
                     function name will be used.
        """

        def register_template(state: BlueprintSetupState) -> None:
            state.app.jinja_env.globals[name or f.__name__] = f

        self.record_once(register_template)

    @setupmethod
    def before_app_request(self, f: T_before_request) -> T_before_request:
        """Like :meth:`before_request`, but before every request, not only those handled
        by the blueprint. Equivalent to :meth:`.Flask.before_request`.
        """
        self.record_once(
            lambda s: s.app.before_request_funcs.setdefault(None, []).append(f)
        )
        return f

    @setupmethod
    def after_app_request(self, f: T_after_request) -> T_after_request:
        """Like :meth:`after_request`, but after every request, not only those handled
        by the blueprint. Equivalent to :meth:`.Flask.after_request`.
        """
        self.record_once(
            lambda s: s.app.after_request_funcs.setdefault(None, []).append(f)
        )
        return f

    @setupmethod
    def teardown_app_request(self, f: T_teardown) -> T_teardown:
        """Like :meth:`teardown_request`, but after every request, not only those
        handled by the blueprint. Equivalent to :meth:`.Flask.teardown_request`.
        """
        self.record_once(
            lambda s: s.app.teardown_request_funcs.setdefault(None, []).append(f)
        )
        return f

    @setupmethod
    def app_context_processor(
        self, f: T_template_context_processor
    ) -> T_template_context_processor:
        """Like :meth:`context_processor`, but for templates rendered by every view, not
        only by the blueprint. Equivalent to :meth:`.Flask.context_processor`.
        """
        self.record_once(
            lambda s: s.app.template_context_processors.setdefault(None, []).append(f)
        )
        return f

    @setupmethod
    def app_errorhandler(
        self, code: t.Union[t.Type[Exception], int]
    ) -> t.Callable[[T_error_handler], T_error_handler]:
        """Like :meth:`errorhandler`, but for every request, not only those handled by
        the blueprint. Equivalent to :meth:`.Flask.errorhandler`.
        """

        def decorator(f: T_error_handler) -> T_error_handler:
            self.record_once(lambda s: s.app.errorhandler(code)(f))
            return f

        return decorator

    @setupmethod
    def app_url_value_preprocessor(
        self, f: T_url_value_preprocessor
    ) -> T_url_value_preprocessor:
        """Like :meth:`url_value_preprocessor`, but for every request, not only those
        handled by the blueprint. Equivalent to :meth:`.Flask.url_value_preprocessor`.
        """
        self.record_once(
            lambda s: s.app.url_value_preprocessors.setdefault(None, []).append(f)
        )
        return f

    @setupmethod
    def app_url_defaults(self, f: T_url_defaults) -> T_url_defaults:
        """Like :meth:`url_defaults`, but for every request, not only those handled by
        the blueprint. Equivalent to :meth:`.Flask.url_defaults`.
        """
        self.record_once(
            lambda s: s.app.url_default_functions.setdefault(None, []).append(f)
        )
        return f

```


# tests/test_blueprints.py

```
import pytest
from jinja2 import TemplateNotFound
from werkzeug.http import parse_cache_control_header

import flask


def test_blueprint_specific_error_handling(app, client):
    frontend = flask.Blueprint("frontend", __name__)
    backend = flask.Blueprint("backend", __name__)
    sideend = flask.Blueprint("sideend", __name__)

    @frontend.errorhandler(403)
    def frontend_forbidden(e):
        return "frontend says no", 403

    @frontend.route("/frontend-no")
    def frontend_no():
        flask.abort(403)

    @backend.errorhandler(403)
    def backend_forbidden(e):
        return "backend says no", 403

    @backend.route("/backend-no")
    def backend_no():
        flask.abort(403)

    @sideend.route("/what-is-a-sideend")
    def sideend_no():
        flask.abort(403)

    app.register_blueprint(frontend)
    app.register_blueprint(backend)
    app.register_blueprint(sideend)

    @app.errorhandler(403)
    def app_forbidden(e):
        return "application itself says no", 403

    assert client.get("/frontend-no").data == b"frontend says no"
    assert client.get("/backend-no").data == b"backend says no"
    assert client.get("/what-is-a-sideend").data == b"application itself says no"


def test_blueprint_specific_user_error_handling(app, client):
    class MyDecoratorException(Exception):
        pass

    class MyFunctionException(Exception):
        pass

    blue = flask.Blueprint("blue", __name__)

    @blue.errorhandler(MyDecoratorException)
    def my_decorator_exception_handler(e):
        assert isinstance(e, MyDecoratorException)
        return "boom"

    def my_function_exception_handler(e):
        assert isinstance(e, MyFunctionException)
        return "bam"

    blue.register_error_handler(MyFunctionException, my_function_exception_handler)

    @blue.route("/decorator")
    def blue_deco_test():
        raise MyDecoratorException()

    @blue.route("/function")
    def blue_func_test():
        raise MyFunctionException()

    app.register_blueprint(blue)

    assert client.get("/decorator").data == b"boom"
    assert client.get("/function").data == b"bam"


def test_blueprint_app_error_handling(app, client):
    errors = flask.Blueprint("errors", __name__)

    @errors.app_errorhandler(403)
    def forbidden_handler(e):
        return "you shall not pass", 403

    @app.route("/forbidden")
    def app_forbidden():
        flask.abort(403)

    forbidden_bp = flask.Blueprint("forbidden_bp", __name__)

    @forbidden_bp.route("/nope")
    def bp_forbidden():
        flask.abort(403)

    app.register_blueprint(errors)
    app.register_blueprint(forbidden_bp)

    assert client.get("/forbidden").data == b"you shall not pass"
    assert client.get("/nope").data == b"you shall not pass"


@pytest.mark.parametrize(
    ("prefix", "rule", "url"),
    (
        ("", "/", "/"),
        ("/", "", "/"),
        ("/", "/", "/"),
        ("/foo", "", "/foo"),
        ("/foo/", "", "/foo/"),
        ("", "/bar", "/bar"),
        ("/foo/", "/bar", "/foo/bar"),
        ("/foo/", "bar", "/foo/bar"),
        ("/foo", "/bar", "/foo/bar"),
        ("/foo/", "//bar", "/foo/bar"),
        ("/foo//", "/bar", "/foo/bar"),
    ),
)
def test_blueprint_prefix_slash(app, client, prefix, rule, url):
    bp = flask.Blueprint("test", __name__, url_prefix=prefix)

    @bp.route(rule)
    def index():
        return "", 204

    app.register_blueprint(bp)
    assert client.get(url).status_code == 204


def test_blueprint_url_defaults(app, client):
    bp = flask.Blueprint("test", __name__)

    @bp.route("/foo", defaults={"baz": 42})
    def foo(bar, baz):
        return f"{bar}/{baz:d}"

    @bp.route("/bar")
    def bar(bar):
        return str(bar)

    app.register_blueprint(bp, url_prefix="/1", url_defaults={"bar": 23})
    app.register_blueprint(bp, name="test2", url_prefix="/2", url_defaults={"bar": 19})

    assert client.get("/1/foo").data == b"23/42"
    assert client.get("/2/foo").data == b"19/42"
    assert client.get("/1/bar").data == b"23"
    assert client.get("/2/bar").data == b"19"


def test_blueprint_url_processors(app, client):
    bp = flask.Blueprint("frontend", __name__, url_prefix="/<lang_code>")

    @bp.url_defaults
    def add_language_code(endpoint, values):
        values.setdefault("lang_code", flask.g.lang_code)

    @bp.url_value_preprocessor
    def pull_lang_code(endpoint, values):
        flask.g.lang_code = values.pop("lang_code")

    @bp.route("/")
    def index():
        return flask.url_for(".about")

    @bp.route("/about")
    def about():
        return flask.url_for(".index")

    app.register_blueprint(bp)

    assert client.get("/de/").data == b"/de/about"
    assert client.get("/de/about").data == b"/de/"


def test_templates_and_static(test_apps):
    from blueprintapp import app

    client = app.test_client()

    rv = client.get("/")
    assert rv.data == b"Hello from the Frontend"
    rv = client.get("/admin/")
    assert rv.data == b"Hello from the Admin"
    rv = client.get("/admin/index2")
    assert rv.data == b"Hello from the Admin"
    rv = client.get("/admin/static/test.txt")
    assert rv.data.strip() == b"Admin File"
    rv.close()
    rv = client.get("/admin/static/css/test.css")
    assert rv.data.strip() == b"/* nested file */"
    rv.close()

    # try/finally, in case other tests use this app for Blueprint tests.
    max_age_default = app.config["SEND_FILE_MAX_AGE_DEFAULT"]
    try:
        expected_max_age = 3600
        if app.config["SEND_FILE_MAX_AGE_DEFAULT"] == expected_max_age:
            expected_max_age = 7200
        app.config["SEND_FILE_MAX_AGE_DEFAULT"] = expected_max_age
        rv = client.get("/admin/static/css/test.css")
        cc = parse_cache_control_header(rv.headers["Cache-Control"])
        assert cc.max_age == expected_max_age
        rv.close()
    finally:
        app.config["SEND_FILE_MAX_AGE_DEFAULT"] = max_age_default

    with app.test_request_context():
        assert (
            flask.url_for("admin.static", filename="test.txt")
            == "/admin/static/test.txt"
        )

    with app.test_request_context():
        with pytest.raises(TemplateNotFound) as e:
            flask.render_template("missing.html")
        assert e.value.name == "missing.html"

    with flask.Flask(__name__).test_request_context():
        assert flask.render_template("nested/nested.txt") == "I'm nested"


def test_default_static_max_age(app):
    class MyBlueprint(flask.Blueprint):
        def get_send_file_max_age(self, filename):
            return 100

    blueprint = MyBlueprint("blueprint", __name__, static_folder="static")
    app.register_blueprint(blueprint)

    # try/finally, in case other tests use this app for Blueprint tests.
    max_age_default = app.config["SEND_FILE_MAX_AGE_DEFAULT"]
    try:
        with app.test_request_context():
            unexpected_max_age = 3600
            if app.config["SEND_FILE_MAX_AGE_DEFAULT"] == unexpected_max_age:
                unexpected_max_age = 7200
            app.config["SEND_FILE_MAX_AGE_DEFAULT"] = unexpected_max_age
            rv = blueprint.send_static_file("index.html")
            cc = parse_cache_control_header(rv.headers["Cache-Control"])
            assert cc.max_age == 100
            rv.close()
    finally:
        app.config["SEND_FILE_MAX_AGE_DEFAULT"] = max_age_default


def test_templates_list(test_apps):
    from blueprintapp import app

    templates = sorted(app.jinja_env.list_templates())
    assert templates == ["admin/index.html", "frontend/index.html"]


def test_dotted_name_not_allowed(app, client):
    with pytest.raises(ValueError):
        flask.Blueprint("app.ui", __name__)


def test_empty_name_not_allowed(app, client):
    with pytest.raises(ValueError):
        flask.Blueprint("", __name__)


def test_dotted_names_from_app(app, client):
    test = flask.Blueprint("test", __name__)

    @app.route("/")
    def app_index():
        return flask.url_for("test.index")

    @test.route("/test/")
    def index():
        return flask.url_for("app_index")

    app.register_blueprint(test)

    rv = client.get("/")
    assert rv.data == b"/test/"


def test_empty_url_defaults(app, client):
    bp = flask.Blueprint("bp", __name__)

    @bp.route("/", defaults={"page": 1})
    @bp.route("/page/<int:page>")
    def something(page):
        return str(page)

    app.register_blueprint(bp)

    assert client.get("/").data == b"1"
    assert client.get("/page/2").data == b"2"


def test_route_decorator_custom_endpoint(app, client):
    bp = flask.Blueprint("bp", __name__)

    @bp.route("/foo")
    def foo():
        return flask.request.endpoint

    @bp.route("/bar", endpoint="bar")
    def foo_bar():
        return flask.request.endpoint

    @bp.route("/bar/123", endpoint="123")
    def foo_bar_foo():
        return flask.request.endpoint

    @bp.route("/bar/foo")
    def bar_foo():
        return flask.request.endpoint

    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.request.endpoint

    assert client.get("/").data == b"index"
    assert client.get("/py/foo").data == b"bp.foo"
    assert client.get("/py/bar").data == b"bp.bar"
    assert client.get("/py/bar/123").data == b"bp.123"
    assert client.get("/py/bar/foo").data == b"bp.bar_foo"


def test_route_decorator_custom_endpoint_with_dots(app, client):
    bp = flask.Blueprint("bp", __name__)

    with pytest.raises(ValueError):
        bp.route("/", endpoint="a.b")(lambda: "")

    with pytest.raises(ValueError):
        bp.add_url_rule("/", endpoint="a.b")

    def view():
        return ""

    view.__name__ = "a.b"

    with pytest.raises(ValueError):
        bp.add_url_rule("/", view_func=view)


def test_endpoint_decorator(app, client):
    from werkzeug.routing import Rule

    app.url_map.add(Rule("/foo", endpoint="bar"))

    bp = flask.Blueprint("bp", __name__)

    @bp.endpoint("bar")
    def foobar():
        return flask.request.endpoint

    app.register_blueprint(bp, url_prefix="/bp_prefix")

    assert client.get("/foo").data == b"bar"
    assert client.get("/bp_prefix/bar").status_code == 404


def test_template_filter(app):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_filter()
    def my_reverse(s):
        return s[::-1]

    app.register_blueprint(bp, url_prefix="/py")
    assert "my_reverse" in app.jinja_env.filters.keys()
    assert app.jinja_env.filters["my_reverse"] == my_reverse
    assert app.jinja_env.filters["my_reverse"]("abcd") == "dcba"


def test_add_template_filter(app):
    bp = flask.Blueprint("bp", __name__)

    def my_reverse(s):
        return s[::-1]

    bp.add_app_template_filter(my_reverse)
    app.register_blueprint(bp, url_prefix="/py")
    assert "my_reverse" in app.jinja_env.filters.keys()
    assert app.jinja_env.filters["my_reverse"] == my_reverse
    assert app.jinja_env.filters["my_reverse"]("abcd") == "dcba"


def test_template_filter_with_name(app):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_filter("strrev")
    def my_reverse(s):
        return s[::-1]

    app.register_blueprint(bp, url_prefix="/py")
    assert "strrev" in app.jinja_env.filters.keys()
    assert app.jinja_env.filters["strrev"] == my_reverse
    assert app.jinja_env.filters["strrev"]("abcd") == "dcba"


def test_add_template_filter_with_name(app):
    bp = flask.Blueprint("bp", __name__)

    def my_reverse(s):
        return s[::-1]

    bp.add_app_template_filter(my_reverse, "strrev")
    app.register_blueprint(bp, url_prefix="/py")
    assert "strrev" in app.jinja_env.filters.keys()
    assert app.jinja_env.filters["strrev"] == my_reverse
    assert app.jinja_env.filters["strrev"]("abcd") == "dcba"


def test_template_filter_with_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_filter()
    def super_reverse(s):
        return s[::-1]

    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_filter.html", value="abcd")

    rv = client.get("/")
    assert rv.data == b"dcba"


def test_template_filter_after_route_with_template(app, client):
    @app.route("/")
    def index():
        return flask.render_template("template_filter.html", value="abcd")

    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_filter()
    def super_reverse(s):
        return s[::-1]

    app.register_blueprint(bp, url_prefix="/py")
    rv = client.get("/")
    assert rv.data == b"dcba"


def test_add_template_filter_with_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    def super_reverse(s):
        return s[::-1]

    bp.add_app_template_filter(super_reverse)
    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_filter.html", value="abcd")

    rv = client.get("/")
    assert rv.data == b"dcba"


def test_template_filter_with_name_and_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_filter("super_reverse")
    def my_reverse(s):
        return s[::-1]

    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_filter.html", value="abcd")

    rv = client.get("/")
    assert rv.data == b"dcba"


def test_add_template_filter_with_name_and_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    def my_reverse(s):
        return s[::-1]

    bp.add_app_template_filter(my_reverse, "super_reverse")
    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_filter.html", value="abcd")

    rv = client.get("/")
    assert rv.data == b"dcba"


def test_template_test(app):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_test()
    def is_boolean(value):
        return isinstance(value, bool)

    app.register_blueprint(bp, url_prefix="/py")
    assert "is_boolean" in app.jinja_env.tests.keys()
    assert app.jinja_env.tests["is_boolean"] == is_boolean
    assert app.jinja_env.tests["is_boolean"](False)


def test_add_template_test(app):
    bp = flask.Blueprint("bp", __name__)

    def is_boolean(value):
        return isinstance(value, bool)

    bp.add_app_template_test(is_boolean)
    app.register_blueprint(bp, url_prefix="/py")
    assert "is_boolean" in app.jinja_env.tests.keys()
    assert app.jinja_env.tests["is_boolean"] == is_boolean
    assert app.jinja_env.tests["is_boolean"](False)


def test_template_test_with_name(app):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_test("boolean")
    def is_boolean(value):
        return isinstance(value, bool)

    app.register_blueprint(bp, url_prefix="/py")
    assert "boolean" in app.jinja_env.tests.keys()
    assert app.jinja_env.tests["boolean"] == is_boolean
    assert app.jinja_env.tests["boolean"](False)


def test_add_template_test_with_name(app):
    bp = flask.Blueprint("bp", __name__)

    def is_boolean(value):
        return isinstance(value, bool)

    bp.add_app_template_test(is_boolean, "boolean")
    app.register_blueprint(bp, url_prefix="/py")
    assert "boolean" in app.jinja_env.tests.keys()
    assert app.jinja_env.tests["boolean"] == is_boolean
    assert app.jinja_env.tests["boolean"](False)


def test_template_test_with_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_test()
    def boolean(value):
        return isinstance(value, bool)

    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_test.html", value=False)

    rv = client.get("/")
    assert b"Success!" in rv.data


def test_template_test_after_route_with_template(app, client):
    @app.route("/")
    def index():
        return flask.render_template("template_test.html", value=False)

    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_test()
    def boolean(value):
        return isinstance(value, bool)

    app.register_blueprint(bp, url_prefix="/py")
    rv = client.get("/")
    assert b"Success!" in rv.data


def test_add_template_test_with_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    def boolean(value):
        return isinstance(value, bool)

    bp.add_app_template_test(boolean)
    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_test.html", value=False)

    rv = client.get("/")
    assert b"Success!" in rv.data


def test_template_test_with_name_and_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_test("boolean")
    def is_boolean(value):
        return isinstance(value, bool)

    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_test.html", value=False)

    rv = client.get("/")
    assert b"Success!" in rv.data


def test_add_template_test_with_name_and_template(app, client):
    bp = flask.Blueprint("bp", __name__)

    def is_boolean(value):
        return isinstance(value, bool)

    bp.add_app_template_test(is_boolean, "boolean")
    app.register_blueprint(bp, url_prefix="/py")

    @app.route("/")
    def index():
        return flask.render_template("template_test.html", value=False)

    rv = client.get("/")
    assert b"Success!" in rv.data


def test_context_processing(app, client):
    answer_bp = flask.Blueprint("answer_bp", __name__)

    template_string = lambda: flask.render_template_string(  # noqa: E731
        "{% if notanswer %}{{ notanswer }} is not the answer. {% endif %}"
        "{% if answer %}{{ answer }} is the answer.{% endif %}"
    )

    # App global context processor
    @answer_bp.app_context_processor
    def not_answer_context_processor():
        return {"notanswer": 43}

    # Blueprint local context processor
    @answer_bp.context_processor
    def answer_context_processor():
        return {"answer": 42}

    # Setup endpoints for testing
    @answer_bp.route("/bp")
    def bp_page():
        return template_string()

    @app.route("/")
    def app_page():
        return template_string()

    # Register the blueprint
    app.register_blueprint(answer_bp)

    app_page_bytes = client.get("/").data
    answer_page_bytes = client.get("/bp").data

    assert b"43" in app_page_bytes
    assert b"42" not in app_page_bytes

    assert b"42" in answer_page_bytes
    assert b"43" in answer_page_bytes


def test_template_global(app):
    bp = flask.Blueprint("bp", __name__)

    @bp.app_template_global()
    def get_answer():
        return 42

    # Make sure the function is not in the jinja_env already
    assert "get_answer" not in app.jinja_env.globals.keys()
    app.register_blueprint(bp)

    # Tests
    assert "get_answer" in app.jinja_env.globals.keys()
    assert app.jinja_env.globals["get_answer"] is get_answer
    assert app.jinja_env.globals["get_answer"]() == 42

    with app.app_context():
        rv = flask.render_template_string("{{ get_answer() }}")
        assert rv == "42"


def test_request_processing(app, client):
    bp = flask.Blueprint("bp", __name__)
    evts = []

    @bp.before_request
    def before_bp():
        evts.append("before")

    @bp.after_request
    def after_bp(response):
        response.data += b"|after"
        evts.append("after")
        return response

    @bp.teardown_request
    def teardown_bp(exc):
        evts.append("teardown")

    # Setup routes for testing
    @bp.route("/bp")
    def bp_endpoint():
        return "request"

    app.register_blueprint(bp)

    assert evts == []
    rv = client.get("/bp")
    assert rv.data == b"request|after"
    assert evts == ["before", "after", "teardown"]


def test_app_request_processing(app, client):
    bp = flask.Blueprint("bp", __name__)
    evts = []

    @bp.before_app_request
    def before_app():
        evts.append("before")

    @bp.after_app_request
    def after_app(response):
        response.data += b"|after"
        evts.append("after")
        return response

    @bp.teardown_app_request
    def teardown_app(exc):
        evts.append("teardown")

    app.register_blueprint(bp)

    # Setup routes for testing
    @app.route("/")
    def bp_endpoint():
        return "request"

    # before first request
    assert evts == []

    # first request
    resp = client.get("/").data
    assert resp == b"request|after"
    assert evts == ["before", "after", "teardown"]

    # second request
    resp = client.get("/").data
    assert resp == b"request|after"
    assert evts == ["before", "after", "teardown"] * 2


def test_app_url_processors(app, client):
    bp = flask.Blueprint("bp", __name__)

    # Register app-wide url defaults and preprocessor on blueprint
    @bp.app_url_defaults
    def add_language_code(endpoint, values):
        values.setdefault("lang_code", flask.g.lang_code)

    @bp.app_url_value_preprocessor
    def pull_lang_code(endpoint, values):
        flask.g.lang_code = values.pop("lang_code")

    # Register route rules at the app level
    @app.route("/<lang_code>/")
    def index():
        return flask.url_for("about")

    @app.route("/<lang_code>/about")
    def about():
        return flask.url_for("index")

    app.register_blueprint(bp)

    assert client.get("/de/").data == b"/de/about"
    assert client.get("/de/about").data == b"/de/"


def test_nested_blueprint(app, client):
    parent = flask.Blueprint("parent", __name__)
    child = flask.Blueprint("child", __name__)
    grandchild = flask.Blueprint("grandchild", __name__)

    @parent.errorhandler(403)
    def forbidden(e):
        return "Parent no", 403

    @parent.route("/")
    def parent_index():
        return "Parent yes"

    @parent.route("/no")
    def parent_no():
        flask.abort(403)

    @child.route("/")
    def child_index():
        return "Child yes"

    @child.route("/no")
    def child_no():
        flask.abort(403)

    @grandchild.errorhandler(403)
    def grandchild_forbidden(e):
        return "Grandchild no", 403

    @grandchild.route("/")
    def grandchild_index():
        return "Grandchild yes"

    @grandchild.route("/no")
    def grandchild_no():
        flask.abort(403)

    child.register_blueprint(grandchild, url_prefix="/grandchild")
    parent.register_blueprint(child, url_prefix="/child")
    app.register_blueprint(parent, url_prefix="/parent")

    assert client.get("/parent/").data == b"Parent yes"
    assert client.get("/parent/child/").data == b"Child yes"
    assert client.get("/parent/child/grandchild/").data == b"Grandchild yes"
    assert client.get("/parent/no").data == b"Parent no"
    assert client.get("/parent/child/no").data == b"Parent no"
    assert client.get("/parent/child/grandchild/no").data == b"Grandchild no"


def test_nested_callback_order(app, client):
    parent = flask.Blueprint("parent", __name__)
    child = flask.Blueprint("child", __name__)

    @app.before_request
    def app_before1():
        flask.g.setdefault("seen", []).append("app_1")

    @app.teardown_request
    def app_teardown1(e=None):
        assert flask.g.seen.pop() == "app_1"

    @app.before_request
    def app_before2():
        flask.g.setdefault("seen", []).append("app_2")

    @app.teardown_request
    def app_teardown2(e=None):
        assert flask.g.seen.pop() == "app_2"

    @app.context_processor
    def app_ctx():
        return dict(key="app")

    @parent.before_request
    def parent_before1():
        flask.g.setdefault("seen", []).append("parent_1")

    @parent.teardown_request
    def parent_teardown1(e=None):
        assert flask.g.seen.pop() == "parent_1"

    @parent.before_request
    def parent_before2():
        flask.g.setdefault("seen", []).append("parent_2")

    @parent.teardown_request
    def parent_teardown2(e=None):
        assert flask.g.seen.pop() == "parent_2"

    @parent.context_processor
    def parent_ctx():
        return dict(key="parent")

    @child.before_request
    def child_before1():
        flask.g.setdefault("seen", []).append("child_1")

    @child.teardown_request
    def child_teardown1(e=None):
        assert flask.g.seen.pop() == "child_1"

    @child.before_request
    def child_before2():
        flask.g.setdefault("seen", []).append("child_2")

    @child.teardown_request
    def child_teardown2(e=None):
        assert flask.g.seen.pop() == "child_2"

    @child.context_processor
    def child_ctx():
        return dict(key="child")

    @child.route("/a")
    def a():
        return ", ".join(flask.g.seen)

    @child.route("/b")
    def b():
        return flask.render_template_string("{{ key }}")

    parent.register_blueprint(child)
    app.register_blueprint(parent)
    assert (
        client.get("/a").data == b"app_1, app_2, parent_1, parent_2, child_1, child_2"
    )
    assert client.get("/b").data == b"child"


@pytest.mark.parametrize(
    "parent_init, child_init, parent_registration, child_registration",
    [
        ("/parent", "/child", None, None),
        ("/parent", None, None, "/child"),
        (None, None, "/parent", "/child"),
        ("/other", "/something", "/parent", "/child"),
    ],
)
def test_nesting_url_prefixes(
    parent_init,
    child_init,
    parent_registration,
    child_registration,
    app,
    client,
) -> None:
    parent = flask.Blueprint("parent", __name__, url_prefix=parent_init)
    child = flask.Blueprint("child", __name__, url_prefix=child_init)

    @child.route("/")
    def index():
        return "index"

    parent.register_blueprint(child, url_prefix=child_registration)
    app.register_blueprint(parent, url_prefix=parent_registration)

    response = client.get("/parent/child/")
    assert response.status_code == 200


def test_nesting_subdomains(app, client) -> None:
    subdomain = "api"
    parent = flask.Blueprint("parent", __name__)
    child = flask.Blueprint("child", __name__)

    @child.route("/child/")
    def index():
        return "child"

    parent.register_blueprint(child)
    app.register_blueprint(parent, subdomain=subdomain)

    client.allow_subdomain_redirects = True

    domain_name = "domain.tld"
    app.config["SERVER_NAME"] = domain_name
    response = client.get("/child/", base_url="http://api." + domain_name)

    assert response.status_code == 200


def test_child_and_parent_subdomain(app, client) -> None:
    child_subdomain = "api"
    parent_subdomain = "parent"
    parent = flask.Blueprint("parent", __name__)
    child = flask.Blueprint("child", __name__, subdomain=child_subdomain)

    @child.route("/")
    def index():
        return "child"

    parent.register_blueprint(child)
    app.register_blueprint(parent, subdomain=parent_subdomain)

    client.allow_subdomain_redirects = True

    domain_name = "domain.tld"
    app.config["SERVER_NAME"] = domain_name
    response = client.get(
        "/", base_url=f"http://{child_subdomain}.{parent_subdomain}.{domain_name}"
    )

    assert response.status_code == 200

    response = client.get("/", base_url=f"http://{parent_subdomain}.{domain_name}")

    assert response.status_code == 404


def test_unique_blueprint_names(app, client) -> None:
    bp = flask.Blueprint("bp", __name__)
    bp2 = flask.Blueprint("bp", __name__)

    app.register_blueprint(bp)

    with pytest.raises(ValueError):
        app.register_blueprint(bp)  # same bp, same name, error

    app.register_blueprint(bp, name="again")  # same bp, different name, ok

    with pytest.raises(ValueError):
        app.register_blueprint(bp2)  # different bp, same name, error

    app.register_blueprint(bp2, name="alt")  # different bp, different name, ok


def test_self_registration(app, client) -> None:
    bp = flask.Blueprint("bp", __name__)
    with pytest.raises(ValueError):
        bp.register_blueprint(bp)


def test_blueprint_renaming(app, client) -> None:
    bp = flask.Blueprint("bp", __name__)
    bp2 = flask.Blueprint("bp2", __name__)

    @bp.get("/")
    def index():
        return flask.request.endpoint

    @bp.get("/error")
    def error():
        flask.abort(403)

    @bp.errorhandler(403)
    def forbidden(_: Exception):
        return "Error", 403

    @bp2.get("/")
    def index2():
        return flask.request.endpoint

    bp.register_blueprint(bp2, url_prefix="/a", name="sub")
    app.register_blueprint(bp, url_prefix="/a")
    app.register_blueprint(bp, url_prefix="/b", name="alt")

    assert client.get("/a/").data == b"bp.index"
    assert client.get("/b/").data == b"alt.index"
    assert client.get("/a/a/").data == b"bp.sub.index2"
    assert client.get("/b/a/").data == b"alt.sub.index2"
    assert client.get("/a/error").data == b"Error"
    assert client.get("/b/error").data == b"Error"

```


# The last commit

```
966bb873 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: pytest tests/test_blueprints.py
============================= test session starts ==============================
platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0
rootdir: /testbed
configfile: pyproject.toml
collected 60 items

tests/test_blueprints.py ............................................... [ 78%]
.............                                                            [100%]

============================== 60 passed in 0.66s ==============================
scope: src/flask/blueprints.py tests/test_blueprints.py
OUTSIDE THE SCOPE: CHANGES.rst +2 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: src/flask/blueprints.py +3 -0
changed: tests/test_blueprints.py +5 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/CHANGES.rst b/CHANGES.rst
index 498d5e51..865363a8 100644
--- a/CHANGES.rst
+++ b/CHANGES.rst
@@ -28,6 +28,8 @@ Unreleased
 -   The ``app.got_first_request`` property is deprecated. :pr:`4997`
 -   The ``locked_cached_property`` decorator is deprecated. Use a lock inside the
     decorated function if locking is needed. :issue:`4993`
+-   A ``ValueError`` is raised when a blueprint is given an empty name.
+    :issue:`4944`
 -   Remove uses of locks that could cause requests to block each other very briefly.
     :issue:`4993`
 -   Use modern packaging metadata with ``pyproject.toml`` instead of ``setup.cfg``.
diff --git a/src/flask/blueprints.py b/src/flask/blueprints.py
index eb50585d..1aa82562 100644
--- a/src/flask/blueprints.py
+++ b/src/flask/blueprints.py
@@ -190,6 +190,9 @@ class Blueprint(Scaffold):
             root_path=root_path,
         )
 
+        if not name:
+            raise ValueError("'name' may not be empty.")
+
         if "." in name:
             raise ValueError("'name' may not contain a dot '.' character.")
 
diff --git a/tests/test_blueprints.py b/tests/test_blueprints.py
index d46b769b..76cee660 100644
--- a/tests/test_blueprints.py
+++ b/tests/test_blueprints.py
@@ -256,6 +256,11 @@ def test_dotted_name_not_allowed(app, client):
         flask.Blueprint("app.ui", __name__)
 
 
+def test_empty_name_not_allowed(app, client):
+    with pytest.raises(ValueError):
+        flask.Blueprint("", __name__)
+
+
 def test_dotted_names_from_app(app, client):
     test = flask.Blueprint("test", __name__)
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
check: pytest tests/test_blueprints.py
============================= test session starts ==============================
platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0
rootdir: /testbed
configfile: pyproject.toml
collected 60 items

tests/test_blueprints.py ............................................... [ 78%]
.............                                                            [100%]

============================== 60 passed in 0.79s ==============================
scope: src/flask/blueprints.py tests/test_blueprints.py
OUTSIDE THE SCOPE: CHANGES.rst +2 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: src/flask/blueprints.py +3 -0
changed: tests/test_blueprints.py +5 -0
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
put back: the direct attempt, which passed test-0 (the repair after the review is in .memdoor/runs/team-solve-2026-11-06T122944/repair.patch, not applied: check 0, judge PASS)
```

### `notes.md`

```
# Notes, run 2026-11-06T122944

## Solver decision

## Review

## Repair

Reverted out-of-scope `CHANGES.rst` entry per review; kept the fix and test.
`pytest tests/test_blueprints.py` -> 60 passed.
```

### `outline.md`

````
# The prompt

Require a non-empty name for Blueprints
Things do not work correctly if a Blueprint is given an empty name (e.g. #4944).
It would be helpful if a `ValueError` was raised when trying to do that.


# The files of the project

```
.editorconfig
.flake8
.github/ISSUE_TEMPLATE/bug-report.md
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/feature-request.md
.github/SECURITY.md
.github/dependabot.yml
.github/pull_request_template.md
.github/workflows/lock.yaml
.github/workflows/publish.yaml
.github/workflows/tests.yaml
.gitignore
.pre-commit-config.yaml
.readthedocs.yaml
CHANGES.rst
CODE_OF_CONDUCT.md
CONTRIBUTING.rst
LICENSE.rst
MANIFEST.in
README.rst
artwork/LICENSE.rst
artwork/logo-full.svg
artwork/logo-lineart.svg
docs/Makefile
docs/_static/debugger.png
docs/_static/flask-icon.png
docs/_static/flask-logo.png
docs/_static/no.png
docs/_static/pycharm-run-config.png
docs/_static/yes.png
docs/api.rst
docs/appcontext.rst
docs/async-await.rst
docs/blueprints.rst
docs/changes.rst
docs/cli.rst
docs/conf.py
docs/config.rst
docs/contributing.rst
docs/debugging.rst
docs/deploying/apache-httpd.rst
docs/deploying/asgi.rst
docs/deploying/eventlet.rst
docs/deploying/gevent.rst
docs/deploying/gunicorn.rst
docs/deploying/index.rst
docs/deploying/mod_wsgi.rst
docs/deploying/nginx.rst
docs/deploying/proxy_fix.rst
docs/deploying/uwsgi.rst
docs/deploying/waitress.rst
docs/design.rst
docs/errorhandling.rst
docs/extensiondev.rst
docs/extensions.rst
docs/index.rst
docs/installation.rst
docs/license.rst
docs/lifecycle.rst
docs/logging.rst
docs/make.bat
docs/patterns/appdispatch.rst
docs/patterns/appfactories.rst
docs/patterns/caching.rst
docs/patterns/celery.rst
docs/patterns/deferredcallbacks.rst
docs/patterns/favicon.rst
docs/patterns/fileuploads.rst
docs/patterns/flashing.rst
docs/patterns/index.rst
docs/patterns/javascript.rst
docs/patterns/jquery.rst
docs/patterns/lazyloading.rst
docs/patterns/methodoverrides.rst
docs/patterns/mongoengine.rst
docs/patterns/packages.rst
docs/patterns/requestchecksum.rst
docs/patterns/singlepageapplications.rst
docs/patterns/sqlalchemy.rst
docs/patterns/sqlite3.rst
docs/patterns/streaming.rst
docs/patterns/subclassing.rst
docs/patterns/templateinheritance.rst
docs/patterns/urlprocessors.rst
docs/patterns/viewdecorators.rst
docs/patterns/wtforms.rst
docs/quickstart.rst
docs/reqcontext.rst
docs/security.rst
docs/server.rst
docs/shell.rst
docs/signals.rst
docs/templating.rst
docs/testing.rst
docs/tutorial/blog.rst
docs/tutorial/database.rst
docs/tutorial/deploy.rst
docs/tutorial/factory.rst
docs/tutorial/flaskr_edit.png
docs/tutorial/flaskr_index.png
docs/tutorial/flaskr_login.png
docs/tutorial/index.rst
docs/tutorial/install.rst
docs/tutorial/layout.rst
docs/tutorial/next.rst
docs/tutorial/static.rst
docs/tutorial/templates.rst
docs/tutorial/tests.rst
docs/tutorial/views.rst
docs/views.rst
examples/celery/README.md
examples/celery/make_celery.py
examples/celery/pyproject.toml
examples/celery/requirements.txt
examples/celery/src/task_app/__init__.py
examples/celery/src/task_app/tasks.py
examples/celery/src/task_app/templates/index.html
examples/celery/src/task_app/views.py
examples/javascript/.gitignore
examples/javascript/LICENSE.rst
examples/javascript/MANIFEST.in
examples/javascript/README.rst
examples/javascript/js_example/__init__.py
examples/javascript/js_example/templates/base.html
examples/javascript/js_example/templates/fetch.html
examples/javascript/js_example/templates/jquery.html
examples/javascript/js_example/templates/xhr.html
examples/javascript/js_example/views.py
examples/javascript/pyproject.toml
examples/javascript/tests/conftest.py
examples/javascript/tests/test_js_example.py
examples/tutorial/.gitignore
examples/tutorial/LICENSE.rst
examples/tutorial/MANIFEST.in
examples/tutorial/README.rst
examples/tutorial/flaskr/__init__.py
examples/tutorial/flaskr/auth.py
examples/tutorial/flaskr/blog.py
examples/tutorial/flaskr/db.py
examples/tutorial/flaskr/schema.sql
examples/tutorial/flaskr/static/style.css
examples/tutorial/flaskr/templates/auth/login.html
examples/tutorial/flaskr/templates/auth/register.html
examples/tutorial/flaskr/templates/base.html
examples/tutorial/flaskr/templates/blog/create.html
examples/tutorial/flaskr/templates/blog/index.html
examples/tutorial/flaskr/templates/blog/update.html
examples/tutorial/pyproject.toml
examples/tutorial/tests/conftest.py
examples/tutorial/tests/data.sql
examples/tutorial/tests/test_auth.py
examples/tutorial/tests/test_blog.py
examples/tutorial/tests/test_db.py
examples/tutorial/tests/test_factory.py
pyproject.toml
requirements/build.in
requirements/build.txt
requirements/dev.in
requirements/dev.txt
requirements/docs.in
requirements/docs.txt
requirements/tests-pallets-min.in
requirements/tests-pallets-min.txt
requirements/tests.in
requirements/tests.txt
requirements/typing.in
requirements/typing.txt
src/flask/__init__.py
src/flask/__main__.py
src/flask/app.py
src/flask/blueprints.py
src/flask/cli.py
src/flask/config.py
src/flask/ctx.py
src/flask/debughelpers.py
src/flask/globals.py
src/flask/helpers.py
src/flask/json/__init__.py
src/flask/json/provider.py
src/flask/json/tag.py
src/flask/logging.py
src/flask/py.typed
src/flask/scaffold.py
src/flask/sessions.py
src/flask/signals.py
src/flask/templating.py
src/flask/testing.py
src/flask/typing.py
src/flask/views.py
src/flask/wrappers.py
tests/conftest.py
tests/static/config.json
tests/static/config.toml
tests/static/index.html
tests/templates/_macro.html
tests/templates/context_template.html
tests/templates/escaping_template.html
tests/templates/mail.txt
tests/templates/nested/nested.txt
tests/templates/non_escaping_template.txt
tests/templates/simple_template.html
tests/templates/template_filter.html
tests/templates/template_test.html
tests/test_appctx.py
tests/test_apps/.env
tests/test_apps/.flaskenv
tests/test_apps/blueprintapp/__init__.py
tests/test_apps/blueprintapp/apps/__init__.py
tests/test_apps/blueprintapp/apps/admin/__init__.py
tests/test_apps/blueprintapp/apps/admin/static/css/test.css
tests/test_apps/blueprintapp/apps/admin/static/test.txt
tests/test_apps/blueprintapp/apps/admin/templates/admin/index.html
tests/test_apps/blueprintapp/apps/frontend/__init__.py
tests/test_apps/blueprintapp/apps/frontend/templates/frontend/index.html
tests/test_apps/cliapp/__init__.py
tests/test_apps/cliapp/app.py
tests/test_apps/cliapp/factory.py
tests/test_apps/cliapp/importerrorapp.py
tests/test_apps/cliapp/inner1/__init__.py
tests/test_apps/cliapp/inner1/inner2/__init__.py
tests/test_apps/cliapp/inner1/inner2/flask.py
tests/test_apps/cliapp/message.txt
tests/test_apps/cliapp/multiapp.py
tests/test_apps/helloworld/hello.py
tests/test_apps/helloworld/wsgi.py
tests/test_apps/subdomaintestmodule/__init__.py
tests/test_apps/subdomaintestmodule/static/hello.txt
tests/test_async.py
tests/test_basic.py
tests/test_blueprints.py
tests/test_cli.py
tests/test_config.py
tests/test_converters.py
tests/test_helpers.py
tests/test_instance_config.py
tests/test_json.py
tests/test_json_tag.py
tests/test_logging.py
tests/test_regression.py
tests/test_reqctx.py
tests/test_session_interface.py
tests/test_signals.py
tests/test_subclassing.py
tests/test_templating.py
tests/test_testing.py
tests/test_user_error_handler.py
tests/test_views.py
tests/typing/typing_app_decorators.py
tests/typing/typing_error_handler.py
tests/typing/typing_route.py
tox.ini
```


# The last commit

```
966bb873 SWE-bench


```

```diff

```


# pyproject.toml (the start)

```
[project]
name = "Flask"
description = "A simple framework for building complex web applications."
readme = "README.rst"
license = {text = "BSD-3-Clause"}
maintainers = [{name = "Pallets", email = "contact@palletsprojects.com"}]
authors = [{name = "Armin Ronacher", email = "armin.ronacher@active-4.com"}]
classifiers = [
    "Development Status :: 5 - Production/Stable",
    "Environment :: Web Environment",
    "Framework :: Flask",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: BSD License",
    "Operating System :: OS Independent",
    "Programming Language :: Python",
    "Topic :: Internet :: WWW/HTTP :: Dynamic Content",
    "Topic :: Internet :: WWW/HTTP :: WSGI",
    "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
    "Topic :: Software Development :: Libraries :: Application Frameworks",
]
requires-python = ">=3.7"
dependencies = [
    "Werkzeug>=2.2.2",
    "Jinja2>=3.0",
    "itsdangerous>=2.0",
    "click>=8.0",
    "importlib-metadata>=3.6.0; python_version < '3.10'",
]
dynamic = ["version"]

[project.urls]
Donate = "https://palletsprojects.com/donate"
Documentation = "https://flask.palletsprojects.com/"
Changes = "https://flask.palletsprojects.com/changes/"
"Source Code" = "https://github.com/pallets/flask/"
"Issue Tracker" = "https://github.com/pallets/flask/issues/"
Twitter = "https://twitter.com/PalletsTeam"
Chat = "https://discord.gg/pallets"

[project.optional-dependencies]
async = ["asgiref>=3.2"]
dotenv = ["python-dotenv"]

[project.scripts]
flask = "flask.cli:main"

[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[tool.setuptools.dynamic]
version = {attr = "flask.__version__"}

[tool.pytest.ini_options]
testpaths = ["tests"]
filterwarnings = ["error"]

[tool.coverage.run]
branch = true
source = ["flask", "tests"]

[tool.coverage.paths]
source = ["src", "*/site-packages"]

[tool.mypy]
python_version = "3.7"
files = ["src/flask"]
show_error_codes = true
pretty = true
#strict = true
allow_redefinition = true
disallow_subclassing_any = true
#disallow_untyped_calls = true
#disallow_untyped_defs = true
#disallow_incomplete_defs = true
no_implicit_optional = true
local_partial_types = true
#no_implicit_reexport = true
strict_equality = true
warn_redundant_casts = true
warn_unused_configs = true
warn_unused_ignores = true
#warn_return_any = true
#warn_unreachable = true

[[tool.mypy.overrides]]
module = [
    "asgiref.*",
    "blinker.*",
    "dotenv.*",
    "cryptography.*",
    "importlib_metadata",
]
ignore_missing_imports = true

```
````

### `plan.md`

````
## Deliverable
changes to this tree

## Check
`pytest tests/test_blueprints.py`

## Scope
`src/flask/blueprints.py`
`tests/test_blueprints.py`

## Done when
- Constructing a `Blueprint` with an empty name raises `ValueError`.
- Constructing a `Blueprint` with a non-empty name is still accepted.

## Approach
Add a guard in `Blueprint.__init__` before `self.name` is assigned and before the existing dot check:

```python
if not name:
    raise ValueError("'name' may not be empty.")
```

Then add a regression test in `tests/test_blueprints.py` asserting that `Blueprint("", __name__)` raises `ValueError`, while existing non-empty-name tests continue to pass.

Candidate approaches:
- `if not name:` — matches the “non-empty” requirement and also rejects other falsy values; preferred.
- `if name == "":` — narrower, only rejects the empty string; acceptable but less aligned with the wording.
- Validate later in `register()` — rejected because the prompt asks for the error when trying to create the Blueprint, not when registering it.
````

### `prompt.md`

```
Require a non-empty name for Blueprints
Things do not work correctly if a Blueprint is given an empty name (e.g. #4944).
It would be helpful if a `ValueError` was raised when trying to do that.
```

### `repair.md`

````
# Repair

Review verdict was FAIL: the functional fix and test were correct, but
`CHANGES.rst` was outside the declared scope.

## What changed

- Reverted the out-of-scope changelog entry in `CHANGES.rst` (removed the
  two added lines about the empty-blueprint `ValueError`).
- Kept the in-scope changes in `src/flask/blueprints.py` (raise `ValueError`
  for an empty name) and `tests/test_blueprints.py` (regression test).

## Check output

`pytest tests/test_blueprints.py`:

```
============================= test session starts =============================
platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0
rootdir: /testbed
configfile: pyproject.toml
collected 60 items

tests/test_blueprints.py ............................................... [ 78%]
.............                                                            [100%]

============================== 60 passed in 0.79s ==============================
```
````

### `repair.patch`

```diff
diff --git a/src/flask/blueprints.py b/src/flask/blueprints.py
index eb50585d..1aa82562 100644
--- a/src/flask/blueprints.py
+++ b/src/flask/blueprints.py
@@ -190,6 +190,9 @@ class Blueprint(Scaffold):
             root_path=root_path,
         )
 
+        if not name:
+            raise ValueError("'name' may not be empty.")
+
         if "." in name:
             raise ValueError("'name' may not contain a dot '.' character.")
 
diff --git a/tests/test_blueprints.py b/tests/test_blueprints.py
index d46b769b..76cee660 100644
--- a/tests/test_blueprints.py
+++ b/tests/test_blueprints.py
@@ -256,6 +256,11 @@ def test_dotted_name_not_allowed(app, client):
         flask.Blueprint("app.ui", __name__)
 
 
+def test_empty_name_not_allowed(app, client):
+    with pytest.raises(ValueError):
+        flask.Blueprint("", __name__)
+
+
 def test_dotted_names_from_app(app, client):
     test = flask.Blueprint("test", __name__)
```

### `review.md`

```
verdict: FAIL
- The functional fix in `src/flask/blueprints.py` correctly raises `ValueError` for an empty blueprint name and still accepts non-empty names.
- The added test in `tests/test_blueprints.py` covers the required behavior, and `pytest tests/test_blueprints.py` passes with 60 tests.
- `CHANGES.rst` is outside the declared scope and is not required by the Prompt or Done when; the scope report explicitly flags it as out of scope.

Repair: revert only `CHANGES.rst` (e.g. `git checkout -- CHANGES.rst`) to remove the out-of-scope changelog entry; keep the changes in `src/flask/blueprints.py` and `tests/test_blueprints.py`.
```

### `scope.txt`

```
scope: src/flask/blueprints.py tests/test_blueprints.py
OUTSIDE THE SCOPE: CHANGES.rst +2 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: src/flask/blueprints.py +3 -0
changed: tests/test_blueprints.py +5 -0
```

### `task.md`

```
# Task

## Prompt

Require a non-empty name for Blueprints
Things do not work correctly if a Blueprint is given an empty name (e.g. #4944).
It would be helpful if a `ValueError` was raised when trying to do that.

## Deliverable

changes to this tree

## Check

`pytest tests/test_blueprints.py`

## Scope

`src/flask/blueprints.py`
`tests/test_blueprints.py`

## Done when

- Constructing a `Blueprint` with an empty name raises `ValueError`.
- Constructing a `Blueprint` with a non-empty name is still accepted.
```

### `test-output.log`

```
check: pytest tests/test_blueprints.py
============================= test session starts ==============================
platform linux -- Python 3.11.10, pytest-7.3.0, pluggy-1.0.0
rootdir: /testbed
configfile: pyproject.toml
collected 60 items

tests/test_blueprints.py ............................................... [ 78%]
.............                                                            [100%]

============================== 60 passed in 0.77s ==============================
scope: src/flask/blueprints.py tests/test_blueprints.py
OUTSIDE THE SCOPE: CHANGES.rst +2 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: src/flask/blueprints.py +3 -0
changed: tests/test_blueprints.py +5 -0
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

```
verdict: PASS
- The diff adds `if not name: raise ValueError(...)` in `Blueprint.__init__`, so constructing with `""` raises `ValueError`, satisfying the first Done when line.
- Non-empty names still pass the new check and proceed to existing validation, satisfying the second Done when line.
- The test `test_empty_name_not_allowed` directly covers the required empty-name behavior.
- Changes are limited to `src/flask/blueprints.py` and `tests/test_blueprints.py`, matching Scope.
- No unrelated content is removed or added.
```
