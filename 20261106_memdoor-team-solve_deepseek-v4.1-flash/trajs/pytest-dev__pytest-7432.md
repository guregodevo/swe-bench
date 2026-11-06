# pytest-dev__pytest-7432 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 276s 66 lines cost=0.006990 in=104511 cached=60416 out=14445 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

skipping: --runxfail breaks pytest.mark.skip location reporting
pytest versions: 5.4.x, current master

When `@pytest.mark.skip`/`skipif` marks are used to skip a test, for example

```py
import pytest
@pytest.mark.skip
def test_skip_location() -> None:
    assert 0
```

the expected skip location reported should point to the item itself, and this is indeed what happens when running with `pytest -rs`:

```
SKIPPED [1] test_it.py:3: unconditional skip
```

However, adding `pytest -rs --runxfail` breaks this:

```
SKIPPED [1] src/_pytest/skipping.py:238: unconditional skip
```

The `--runxfail` is only about xfail and should not affect this at all.

---

Hint: the bug is in `src/_pytest/skipping.py`, the `pytest_runtest_makereport` hook.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `read_file`**

```json
{
  "path": "src/_pytest/skipping.py",
  "offset": 200,
  "limit": 120
}
```

**tool result**

```
def evaluate_xfail_marks(item: Item) -> Optional[Xfail]:
    """Evaluate xfail marks on item, returning Xfail if triggered."""
    for mark in item.iter_markers(name="xfail"):
        run = mark.kwargs.get("run", True)
        strict = mark.kwargs.get("strict", item.config.getini("xfail_strict"))
        raises = mark.kwargs.get("raises", None)
        if "condition" not in mark.kwargs:
            conditions = mark.args
        else:
            conditions = (mark.kwargs["condition"],)

        # Unconditional.
        if not conditions:
            reason = mark.kwargs.get("reason", "")
            return Xfail(reason, run, strict, raises)

        # If any of the conditions are true.
        for condition in conditions:
            result, reason = evaluate_condition(item, mark, condition)
            if result:
                return Xfail(reason, run, strict, raises)

    return None


# Whether skipped due to skip or skipif marks.
skipped_by_mark_key = StoreKey[bool]()
# Saves the xfail mark evaluation. Can be refreshed during call if None.
xfailed_key = StoreKey[Optional[Xfail]]()
unexpectedsuccess_key = StoreKey[str]()


@hookimpl(tryfirst=True)
def pytest_runtest_setup(item: Item) -> None:
    item._store[skipped_by_mark_key] = False

    skipped = evaluate_skip_marks(item)
    if skipped:
        item._store[skipped_by_mark_key] = True
        skip(skipped.reason)

    if not item.config.option.runxfail:
        item._store[xfailed_key] = xfailed = evaluate_xfail_marks(item)
        if xfailed and not xfailed.run:
            xfail("[NOTRUN] " + xfailed.reason)


@hookimpl(hookwrapper=True)
def pytest_runtest_call(item: Item) -> Generator[None, None, None]:
    xfailed = item._store.get(xfailed_key, None)
    if xfailed is None:
        item._store[xfailed_key] = xfailed = evaluate_xfail_marks(item)

    if not item.config.option.runxfail:
        if xfailed and not xfailed.run:
            xfail("[NOTRUN] " + xfailed.reason)

    yield


@hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item: Item, call: CallInfo[None]):
    outcome = yield
    rep = outcome.get_result()
    xfailed = item._store.get(xfailed_key, None)
    # unittest special case, see setting of unexpectedsuccess_key
    if unexpectedsuccess_key in item._store and rep.when == "call":
        reason = item._store[unexpectedsuccess_key]
        if reason:
            rep.longrepr = "Unexpected success: {}".format(reason)
        else:
            rep.longrepr = "Unexpected success"
        rep.outcome = "failed"
    elif item.config.option.runxfail:
        pass  # don't interfere
    elif call.excinfo and isinstance(call.excinfo.value, xfail.Exception):
        assert call.excinfo.value.msg is not None
        rep.wasxfail = "reason: " + call.excinfo.value.msg
        rep.outcome = "skipped"
    elif not rep.skipped and xfailed:
        if call.excinfo:
            raises = xfailed.raises
            if raises is not None and not isinstance(call.excinfo.value, raises):
                rep.outcome = "failed"
            else:
                rep.outcome = "skipped"
                rep.wasxfail = xfailed.reason
        elif call.when == "call":
            if xfailed.strict:
                rep.outcome = "failed"
                rep.longrepr = "[XPASS(strict)] " + xfailed.reason
            else:
                rep.outcome = "passed"
                rep.wasxfail = xfailed.reason
    elif (
        item._store.get(skipped_by_mark_key, True)
        and rep.skipped
        and type(rep.longrepr) is tuple
    ):
        # skipped by mark.skipif; change the location of the failure
        # to point to the item definition, otherwise it will display
        # the location of where the skip exception was raised within pytest
        _, _, reason = rep.longrepr
        filename, line = item.reportinfo()[:2]
        assert line is not None
        rep.longrepr = str(filename), line + 1, reason


def pytest_report_teststatus(report: BaseReport) -> Optional[Tuple[str, str, str]]:
    if hasattr(report, "wasxfail"):
        if report.skipped:
            return "xfailed", "x", "XFAIL"
        elif report.passed:
            return "xpassed", "X", "XPASS"
    return None

[lines 200-314 of /testbed/src/_pytest/skipping.py, the end]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: src/_pytest/skipping.py\n@@\n-    elif item.config.option.runxfail:\n-        pass  # don't interfere\n+    elif (\n+        item._store.get(skipped_by_mark_key, True)\n+        and rep.skipped\n+        and type(rep.longrepr) is tuple\n+    ):\n+        # skipped by mark.skipif; change the location of the failure\n+        # to point to the item definition, otherwise it will display\n+        # the location of where the skip exception was raised within pytest\n+        _, _, reason = rep.longrepr\n+        filename, line = item.reportinfo()[:2]\n+        assert line is not None\n+        rep.longrepr = str(filename), line + 1, reason\n+    elif item.config.option.runxfail:\n+        pass  # don't interfere\n@@\n-    elif (\n-        item._store.get(skipped_by_mark_key, True)\n-        and rep.skipped\n-        and type(rep.longrepr) is tuple\n-    ):\n-        # skipped by mark.skipif; change the location of the failure\n-        # to point to the item definition, otherwise it will display\n-        # the location of where the skip exception was raised within pytest\n-        _, _, reason = rep.longrepr\n-        filename, line = item.reportinfo()[:2]\n-        assert line is not None\n-        rep.longrepr = str(filename), line + 1, reason\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[src/_pytest/skipping.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

src/_pytest/skipping.py now (314 lines), around the change:
270:        else:
271:            rep.longrepr = "Unexpected success"
272:        rep.outcome = "failed"
273:    elif (
274:        item._store.get(skipped_by_mark_key, True)
275:        and rep.skipped
276:        and type(rep.longrepr) is tuple
277:    ):
278:        # skipped by mark.skipif; change the location of the failure
279:        # to point to the item definition, otherwise it will display
280:        # the location of where the skip exception was raised within pytest
281:        _, _, reason = rep.longrepr
282:        filename, line = item.reportinfo()[:2]
283:        assert line is not None
284:        rep.longrepr = str(filename), line + 1, reason
285:    elif item.config.option.runxfail:
286:        pass  # don't interfere
287:    elif call.excinfo and isinstance(call.excinfo.value, xfail.Exception):
…
303:            else:
304:                rep.outcome = "passed"
305:                rep.wasxfail = xfailed.reason
306:
307:
308:def pytest_report_teststatus(report: BaseReport) -> Optional[Tuple[str, str, str]]:
309:    if hasattr(report, "wasxfail"):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"runxfail\" testing/ | head -30"
}
```

**tool result**

```
testing/test_skipping.py:233:        result = testdir.runpytest("--runxfail")
testing/test_skipping.py:334:        result = testdir.runpytest(p, "--runxfail")
testing/test_skipping.py:352:        result = testdir.runpytest(p, "--runxfail")
```

**assistant → tool `read_file`**

```json
{
  "path": "testing/test_skipping.py",
  "offset": 200,
  "limit": 70
}
```

**tool result**

```
        )
        reports = runtestprotocol(item, log=False)
        assert len(reports) == 3
        callreport = reports[1]
        assert callreport.wasxfail

    def test_xfail_xpassed_strict(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail(strict=True, reason="nope")
            def test_func():
                assert 1
        """
        )
        reports = runtestprotocol(item, log=False)
        assert len(reports) == 3
        callreport = reports[1]
        assert callreport.failed
        assert str(callreport.longrepr) == "[XPASS(strict)] nope"
        assert not hasattr(callreport, "wasxfail")

    def test_xfail_run_anyway(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.xfail
            def test_func():
                assert 0
            def test_func2():
                pytest.xfail("hello")
        """
        )
        result = testdir.runpytest("--runxfail")
        result.stdout.fnmatch_lines(
            ["*def test_func():*", "*assert 0*", "*1 failed*1 pass*"]
        )

    def test_xfail_evalfalse_but_fails(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail('False')
            def test_func():
                assert 0
        """
        )
        reports = runtestprotocol(item, log=False)
        callreport = reports[1]
        assert callreport.failed
        assert not hasattr(callreport, "wasxfail")
        assert "xfail" in callreport.keywords

    def test_xfail_not_report_default(self, testdir):
        p = testdir.makepyfile(
            test_one="""
            import pytest
            @pytest.mark.xfail
            def test_this():
                assert 0
        """
        )
        testdir.runpytest(p, "-v")
        # result.stdout.fnmatch_lines([
        #    "*HINT*use*-r*"
        # ])

    def test_xfail_not_run_xfail_reporting(self, testdir):
        p = testdir.makepyfile(
            test_one="""

[938 more lines in /testbed/testing/test_skipping.py (1207 in all). read_file with offset: 270 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"skip_location\\|SKIPPED\\|def test_skip\" testing/test_skipping.py | head -40"
}
```

**tool result**

```
140:    def test_skipif_class(self, testdir):
556:    def test_skip_class(self, testdir):
574:    def test_skips_on_false_string(self, testdir):
598:    def test_skip_no_reason(self, testdir):
610:    def test_skip_with_reason(self, testdir):
653:    def test_skipif_conditional(self, testdir):
668:    def test_skipif_reporting(self, testdir, params):
682:    def test_skipif_using_platform(self, testdir):
697:    def test_skipif_reporting_multiple(self, testdir, marker, msg1, msg2):
719:def test_skip_not_report_default(testdir):
736:def test_skipif_class(testdir):
753:def test_skipped_reasons_functional(testdir):
783:            "SKIPPED [[]2[]] conftest.py:4: test",
784:            "SKIPPED [[]1[]] test_one.py:14: via_decorator",
790:def test_skipped_folding(testdir):
937:        def test_skip1():
1010:    def test_skipif(self, testdir):
1029:    def test_skipif_noreason(self, testdir):
1206:        ["SKIPPED [[]1[]] tests/test_1.py:2: unconditional skip"]
```

**assistant → tool `read_file`**

```json
{
  "path": "testing/test_skipping.py",
  "offset": 1180,
  "limit": 30
}
```

**tool result**

```
            "FAILED test_summary_list_after_errors.py::test_fail - assert 0",
        ]
    )


def test_importorskip():
    with pytest.raises(
        pytest.skip.Exception,
        match="^could not import 'doesnotexist': No module named .*",
    ):
        pytest.importorskip("doesnotexist")


def test_relpath_rootdir(testdir):
    testdir.makepyfile(
        **{
            "tests/test_1.py": """
        import pytest
        @pytest.mark.skip()
        def test_pass():
            pass
            """,
        }
    )
    result = testdir.runpytest("-rs", "tests/test_1.py", "--rootdir=tests")
    result.stdout.fnmatch_lines(
        ["SKIPPED [[]1[]] tests/test_1.py:2: unconditional skip"]
    )

[lines 1180-1207 of /testbed/testing/test_skipping.py, the end]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: testing/test_skipping.py\n@@\n def test_relpath_rootdir(testdir):\n@@\n     result.stdout.fnmatch_lines(\n         [\"SKIPPED [[]1[]] tests/test_1.py:2: unconditional skip\"]\n     )\n+\n+\n+def test_skipped_location_with_runxfail(testdir):\n+    testdir.makepyfile(\n+        \"\"\"\n+        import pytest\n+\n+        @pytest.mark.skip\n+        def test_skip_location():\n+            assert 0\n+        \"\"\"\n+    )\n+    result = testdir.runpytest(\"-rs\", \"--runxfail\")\n+    result.stdout.fnmatch_lines(\n+        [\"SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:4: unconditional skip\"]\n+    )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[testing/test_skipping.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

testing/test_skipping.py now (1223 lines), around the change:
1205:    result.stdout.fnmatch_lines(
1206:        ["SKIPPED [[]1[]] tests/test_1.py:2: unconditional skip"]
1207:    )
1208:
1209:
1210:def test_skipped_location_with_runxfail(testdir):
1211:    testdir.makepyfile(
1212:        """
1213:        import pytest
1214:
1215:        @pytest.mark.skip
1216:        def test_skip_location():
1217:            assert 0
1218:        """
1219:    )
1220:    result = testdir.runpytest("-rs", "--runxfail")
1221:    result.stdout.fnmatch_lines(
1222:        ["SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:4: unconditional skip"]
1223:    )
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest testing/test_skipping.py -q 2>&1 | tail -20"
}
```

**tool result**

```
E           and: '=========================== short test summary info ============================'
E           and: 'SKIPPED [1] test_skipped_location_with_runxfail.py:3: unconditional skip'
E           and: '============================== 1 skipped in 0.01s =============================='
E       remains unmatched: 'SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:4: unconditional skip'

/testbed/testing/test_skipping.py:1221: Failed
----------------------------- Captured stdout call -----------------------------
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-5.4.1.dev593+ge6e300e72.d20260815, py-1.11.0, pluggy-0.13.1
rootdir: /tmp/pytest-of-root/pytest-0/test_skipped_location_with_runxfail0
collected 1 item

test_skipped_location_with_runxfail.py s                                 [100%]

=========================== short test summary info ============================
SKIPPED [1] test_skipped_location_with_runxfail.py:3: unconditional skip
============================== 1 skipped in 0.01s ==============================
=========================== short test summary info ============================
FAILED testing/test_skipping.py::test_skipped_location_with_runxfail - Failed...
1 failed, 77 passed in 11.58s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: testing/test_skipping.py\n@@\n-        [\"SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:4: unconditional skip\"]\n+        [\"SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:3: unconditional skip\"]\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[testing/test_skipping.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

testing/test_skipping.py now (1223 lines), around the change:
1219:    )
1220:    result = testdir.runpytest("-rs", "--runxfail")
1221:    result.stdout.fnmatch_lines(
1222:        ["SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:3: unconditional skip"]
1223:    )
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest testing/test_skipping.py -q 2>&1 | tail -5"
}
```

**tool result**

```
........................................................................ [ 92%]
......                                                                   [100%]
78 passed in 4.15s
```

**assistant**

```
Fixed the bug in `src/_pytest/skipping.py` by moving the `skipif`/`skip`-mark location rewrite before the `runxfail` early-return. Previously `--runxfail` hit `elif item.config.option.runxfail: pass` first, so the skip report kept pytest's internal location.

Also added `test_skipped_location_with_runxfail` to `testing/test_skipping.py`, asserting the reported location points at the test item even with `--runxfail`.

`testing/test_skipping.py`: **78 passed**.
```

## Run folder `team-solve-2026-11-06T130143`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
a0d8040ee4ee621e86a39ae62208596bc865c9c1
```

### `baseline-check.log`

```
check: python -m pytest testing/test_skipping.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-5.4.1.dev593+ge6e300e72.d20260815, py-1.11.0, pluggy-0.13.1
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T130143/baseline-tree, configfile: pyproject.toml
collected 77 items

testing/test_skipping.py ............................................... [ 61%]
..............................                                           [100%]

============================= 77 passed in 19.38s ==============================
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/src/_pytest/skipping.py b/src/_pytest/skipping.py
index 7bd975e5a..4b657af14 100755
--- a/src/_pytest/skipping.py
+++ b/src/_pytest/skipping.py
@@ -270,6 +270,18 @@ def pytest_runtest_makereport(item: Item, call: CallInfo[None]):
         else:
             rep.longrepr = "Unexpected success"
         rep.outcome = "failed"
+    elif (
+        item._store.get(skipped_by_mark_key, True)
+        and rep.skipped
+        and type(rep.longrepr) is tuple
+    ):
+        # skipped by mark.skipif; change the location of the failure
+        # to point to the item definition, otherwise it will display
+        # the location of where the skip exception was raised within pytest
+        _, _, reason = rep.longrepr
+        filename, line = item.reportinfo()[:2]
+        assert line is not None
+        rep.longrepr = str(filename), line + 1, reason
     elif item.config.option.runxfail:
         pass  # don't interfere
     elif call.excinfo and isinstance(call.excinfo.value, xfail.Exception):
@@ -291,18 +303,6 @@ def pytest_runtest_makereport(item: Item, call: CallInfo[None]):
             else:
                 rep.outcome = "passed"
                 rep.wasxfail = xfailed.reason
-    elif (
-        item._store.get(skipped_by_mark_key, True)
-        and rep.skipped
-        and type(rep.longrepr) is tuple
-    ):
-        # skipped by mark.skipif; change the location of the failure
-        # to point to the item definition, otherwise it will display
-        # the location of where the skip exception was raised within pytest
-        _, _, reason = rep.longrepr
-        filename, line = item.reportinfo()[:2]
-        assert line is not None
-        rep.longrepr = str(filename), line + 1, reason
 
 
 def pytest_report_teststatus(report: BaseReport) -> Optional[Tuple[str, str, str]]:
diff --git a/testing/test_skipping.py b/testing/test_skipping.py
index 0b1c0b49b..296f5c59b 100755
--- a/testing/test_skipping.py
+++ b/testing/test_skipping.py
@@ -1205,3 +1205,19 @@ def test_relpath_rootdir(testdir):
     result.stdout.fnmatch_lines(
         ["SKIPPED [[]1[]] tests/test_1.py:2: unconditional skip"]
     )
+
+
+def test_skipped_location_with_runxfail(testdir):
+    testdir.makepyfile(
+        """
+        import pytest
+
+        @pytest.mark.skip
+        def test_skip_location():
+            assert 0
+        """
+    )
+    result = testdir.runpytest("-rs", "--runxfail")
+    result.stdout.fnmatch_lines(
+        ["SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:3: unconditional skip"]
+    )
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

skipping: --runxfail breaks pytest.mark.skip location reporting
pytest versions: 5.4.x, current master

When `@pytest.mark.skip`/`skipif` marks are used to skip a test, for example

```py
import pytest
@pytest.mark.skip
def test_skip_location() -> None:
    assert 0
```

the expected skip location reported should point to the item itself, and this is indeed what happens when running with `pytest -rs`:

```
SKIPPED [1] test_it.py:3: unconditional skip
```

However, adding `pytest -rs --runxfail` breaks this:

```
SKIPPED [1] src/_pytest/skipping.py:238: unconditional skip
```

The `--runxfail` is only about xfail and should not affect this at all.

---

Hint: the bug is in `src/_pytest/skipping.py`, the `pytest_runtest_makereport` hook.

## Deliverable

changes to this tree

## Check

`python -m pytest testing/test_skipping.py`

## Scope

`src/_pytest/skipping.py`
`testing/test_skipping.py`
`changelog/`

## Done when

- With `pytest -rs --runxfail`, a test decorated with `@pytest.mark.skip` is reported at the test item's own file and line, not at `src/_pytest/skipping.py`.
- The same location reporting holds for `@pytest.mark.skipif`.
- Without `--runxfail`, the reported skip location is unchanged.
- `--runxfail` still affects only xfail: xfail-marked tests continue to run and report normally under it.
- The existing skipping tests pass.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest testing/test_skipping.py`

## Scope
`src/_pytest/skipping.py`
`testing/test_skipping.py`
`changelog/`

## Done when
- With `pytest -rs --runxfail`, a test decorated with `@pytest.mark.skip` is reported at the test item's own file and line, not at `src/_pytest/skipping.py`.
- The same location reporting holds for `@pytest.mark.skipif`.
- Without `--runxfail`, the reported skip location is unchanged.
- `--runxfail` still affects only xfail: xfail-marked tests continue to run and report normally under it.
- The existing skipping tests pass.

## Approach
Single, localized change in `src/_pytest/skipping.py::pytest_runtest_makereport`. The `--runxfail` branch currently short-circuits the hook before the code that rewrites a skip report's `longrepr` to the item's location; make the xfail bypass apply only to xfail processing while the skip-location bookkeeping always runs. Decomposition: (1) reproduce with a one-test module under both `-rs` and `-rs --runxfail` to confirm the differing `longrepr`; (2) read the `if/elif` chain in `pytest_runtest_makereport` and trace which branch handles the skipped report; (3) restructure so skip reports get `(item.location[0], item.location[1], reason)` regardless of `runxfail`; (4) add a regression test in `testing/test_skipping.py` asserting the reported location with `--runxfail`, plus a skipif case; (5) run the skipping test module.

Candidate approaches:
1. Move the skip-location fixup ahead of the `if/elif` chain so it is never gated by `runxfail` — smallest diff, but must ensure it doesn't also fire for xfail-produced skips.
2. Narrow the `runxfail` branch (e.g. only `pass` when the report is not a skip, or combine it with the xfail-exception check) so skipped reports fall through to the existing fixup — preserves the current control flow, but the condition must be checked against xfail/xpass cases.
3. Replace the branch with explicit handling: an independent `if rep.skipped and ...` block after the chain that sets `longrepr` from `item.location` whenever the skip came from a `skip`/`skipif` mark — most robust and easiest to reason about, but duplicates a little logic.

Preferred: approach 2 or 3, because they keep xfail semantics intact and make the skip-location rewrite unconditional with respect to `--runxfail`.


# src/_pytest/skipping.py

```
""" support for skip/xfail functions and markers. """
import os
import platform
import sys
import traceback
from typing import Generator
from typing import Optional
from typing import Tuple

import attr

import _pytest._code
from _pytest.compat import TYPE_CHECKING
from _pytest.config import Config
from _pytest.config import hookimpl
from _pytest.config.argparsing import Parser
from _pytest.mark.structures import Mark
from _pytest.nodes import Item
from _pytest.outcomes import fail
from _pytest.outcomes import skip
from _pytest.outcomes import xfail
from _pytest.reports import BaseReport
from _pytest.runner import CallInfo
from _pytest.store import StoreKey

if TYPE_CHECKING:
    from typing import Type


def pytest_addoption(parser: Parser) -> None:
    group = parser.getgroup("general")
    group.addoption(
        "--runxfail",
        action="store_true",
        dest="runxfail",
        default=False,
        help="report the results of xfail tests as if they were not marked",
    )

    parser.addini(
        "xfail_strict",
        "default for the strict parameter of xfail "
        "markers when not given explicitly (default: False)",
        default=False,
        type="bool",
    )


def pytest_configure(config: Config) -> None:
    if config.option.runxfail:
        # yay a hack
        import pytest

        old = pytest.xfail
        config._cleanup.append(lambda: setattr(pytest, "xfail", old))

        def nop(*args, **kwargs):
            pass

        nop.Exception = xfail.Exception  # type: ignore[attr-defined] # noqa: F821
        setattr(pytest, "xfail", nop)

    config.addinivalue_line(
        "markers",
        "skip(reason=None): skip the given test function with an optional reason. "
        'Example: skip(reason="no way of currently testing this") skips the '
        "test.",
    )
    config.addinivalue_line(
        "markers",
        "skipif(condition, ..., *, reason=...): "
        "skip the given test function if any of the conditions evaluate to True. "
        "Example: skipif(sys.platform == 'win32') skips the test if we are on the win32 platform. "
        "See https://docs.pytest.org/en/stable/reference.html#pytest-mark-skipif",
    )
    config.addinivalue_line(
        "markers",
        "xfail(condition, ..., *, reason=..., run=True, raises=None, strict=xfail_strict): "
        "mark the test function as an expected failure if any of the conditions "
        "evaluate to True. Optionally specify a reason for better reporting "
        "and run=False if you don't even want to execute the test function. "
        "If only specific exception(s) are expected, you can list them in "
        "raises, and if the test fails in other ways, it will be reported as "
        "a true failure. See https://docs.pytest.org/en/stable/reference.html#pytest-mark-xfail",
    )


def evaluate_condition(item: Item, mark: Mark, condition: object) -> Tuple[bool, str]:
    """Evaluate a single skipif/xfail condition.

    If an old-style string condition is given, it is eval()'d, otherwise the
    condition is bool()'d. If this fails, an appropriately formatted pytest.fail
    is raised.

    Returns (result, reason). The reason is only relevant if the result is True.
    """
    # String condition.
    if isinstance(condition, str):
        globals_ = {
            "os": os,
            "sys": sys,
            "platform": platform,
            "config": item.config,
        }
        if hasattr(item, "obj"):
            globals_.update(item.obj.__globals__)  # type: ignore[attr-defined]
        try:
            condition_code = _pytest._code.compile(condition, mode="eval")
            result = eval(condition_code, globals_)
        except SyntaxError as exc:
            msglines = [
                "Error evaluating %r condition" % mark.name,
                "    " + condition,
                "    " + " " * (exc.offset or 0) + "^",
                "SyntaxError: invalid syntax",
            ]
            fail("\n".join(msglines), pytrace=False)
        except Exception as exc:
            msglines = [
                "Error evaluating %r condition" % mark.name,
                "    " + condition,
                *traceback.format_exception_only(type(exc), exc),
            ]
            fail("\n".join(msglines), pytrace=False)

    # Boolean condition.
    else:
        try:
            result = bool(condition)
        except Exception as exc:
            msglines = [
                "Error evaluating %r condition as a boolean" % mark.name,
                *traceback.format_exception_only(type(exc), exc),
            ]
            fail("\n".join(msglines), pytrace=False)

    reason = mark.kwargs.get("reason", None)
    if reason is None:
        if isinstance(condition, str):
            reason = "condition: " + condition
        else:
            # XXX better be checked at collection time
            msg = (
                "Error evaluating %r: " % mark.name
                + "you need to specify reason=STRING when using booleans as conditions."
            )
            fail(msg, pytrace=False)

    return result, reason


@attr.s(slots=True, frozen=True)
class Skip:
    """The result of evaluate_skip_marks()."""

    reason = attr.ib(type=str)


def evaluate_skip_marks(item: Item) -> Optional[Skip]:
    """Evaluate skip and skipif marks on item, returning Skip if triggered."""
    for mark in item.iter_markers(name="skipif"):
        if "condition" not in mark.kwargs:
            conditions = mark.args
        else:
            conditions = (mark.kwargs["condition"],)

        # Unconditional.
        if not conditions:
            reason = mark.kwargs.get("reason", "")
            return Skip(reason)

        # If any of the conditions are true.
        for condition in conditions:
            result, reason = evaluate_condition(item, mark, condition)
            if result:
                return Skip(reason)

    for mark in item.iter_markers(name="skip"):
        if "reason" in mark.kwargs:
            reason = mark.kwargs["reason"]
        elif mark.args:
            reason = mark.args[0]
        else:
            reason = "unconditional skip"
        return Skip(reason)

    return None


@attr.s(slots=True, frozen=True)
class Xfail:
    """The result of evaluate_xfail_marks()."""

    reason = attr.ib(type=str)
    run = attr.ib(type=bool)
    strict = attr.ib(type=bool)
    raises = attr.ib(type=Optional[Tuple["Type[BaseException]", ...]])


def evaluate_xfail_marks(item: Item) -> Optional[Xfail]:
    """Evaluate xfail marks on item, returning Xfail if triggered."""
    for mark in item.iter_markers(name="xfail"):
        run = mark.kwargs.get("run", True)
        strict = mark.kwargs.get("strict", item.config.getini("xfail_strict"))
        raises = mark.kwargs.get("raises", None)
        if "condition" not in mark.kwargs:
            conditions = mark.args
        else:
            conditions = (mark.kwargs["condition"],)

        # Unconditional.
        if not conditions:
            reason = mark.kwargs.get("reason", "")
            return Xfail(reason, run, strict, raises)

        # If any of the conditions are true.
        for condition in conditions:
            result, reason = evaluate_condition(item, mark, condition)
            if result:
                return Xfail(reason, run, strict, raises)

    return None


# Whether skipped due to skip or skipif marks.
skipped_by_mark_key = StoreKey[bool]()
# Saves the xfail mark evaluation. Can be refreshed during call if None.
xfailed_key = StoreKey[Optional[Xfail]]()
unexpectedsuccess_key = StoreKey[str]()


@hookimpl(tryfirst=True)
def pytest_runtest_setup(item: Item) -> None:
    item._store[skipped_by_mark_key] = False

    skipped = evaluate_skip_marks(item)
    if skipped:
        item._store[skipped_by_mark_key] = True
        skip(skipped.reason)

    if not item.config.option.runxfail:
        item._store[xfailed_key] = xfailed = evaluate_xfail_marks(item)
        if xfailed and not xfailed.run:
            xfail("[NOTRUN] " + xfailed.reason)


@hookimpl(hookwrapper=True)
def pytest_runtest_call(item: Item) -> Generator[None, None, None]:
    xfailed = item._store.get(xfailed_key, None)
    if xfailed is None:
        item._store[xfailed_key] = xfailed = evaluate_xfail_marks(item)

    if not item.config.option.runxfail:
        if xfailed and not xfailed.run:
            xfail("[NOTRUN] " + xfailed.reason)

    yield


@hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item: Item, call: CallInfo[None]):
    outcome = yield
    rep = outcome.get_result()
    xfailed = item._store.get(xfailed_key, None)
    # unittest special case, see setting of unexpectedsuccess_key
    if unexpectedsuccess_key in item._store and rep.when == "call":
        reason = item._store[unexpectedsuccess_key]
        if reason:
            rep.longrepr = "Unexpected success: {}".format(reason)
        else:
            rep.longrepr = "Unexpected success"
        rep.outcome = "failed"
    elif (
        item._store.get(skipped_by_mark_key, True)
        and rep.skipped
        and type(rep.longrepr) is tuple
    ):
        # skipped by mark.skipif; change the location of the failure
        # to point to the item definition, otherwise it will display
        # the location of where the skip exception was raised within pytest
        _, _, reason = rep.longrepr
        filename, line = item.reportinfo()[:2]
        assert line is not None
        rep.longrepr = str(filename), line + 1, reason
    elif item.config.option.runxfail:
        pass  # don't interfere
    elif call.excinfo and isinstance(call.excinfo.value, xfail.Exception):
        assert call.excinfo.value.msg is not None
        rep.wasxfail = "reason: " + call.excinfo.value.msg
        rep.outcome = "skipped"
    elif not rep.skipped and xfailed:
        if call.excinfo:
            raises = xfailed.raises
            if raises is not None and not isinstance(call.excinfo.value, raises):
                rep.outcome = "failed"
            else:
                rep.outcome = "skipped"
                rep.wasxfail = xfailed.reason
        elif call.when == "call":
            if xfailed.strict:
                rep.outcome = "failed"
                rep.longrepr = "[XPASS(strict)] " + xfailed.reason
            else:
                rep.outcome = "passed"
                rep.wasxfail = xfailed.reason


def pytest_report_teststatus(report: BaseReport) -> Optional[Tuple[str, str, str]]:
    if hasattr(report, "wasxfail"):
        if report.skipped:
            return "xfailed", "x", "XFAIL"
        elif report.passed:
            return "xpassed", "X", "XPASS"
    return None

```


# testing/test_skipping.py

```
import sys

import pytest
from _pytest.runner import runtestprotocol
from _pytest.skipping import evaluate_skip_marks
from _pytest.skipping import evaluate_xfail_marks
from _pytest.skipping import pytest_runtest_setup


class TestEvaluation:
    def test_no_marker(self, testdir):
        item = testdir.getitem("def test_func(): pass")
        skipped = evaluate_skip_marks(item)
        assert not skipped

    def test_marked_xfail_no_args(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail
            def test_func():
                pass
        """
        )
        xfailed = evaluate_xfail_marks(item)
        assert xfailed
        assert xfailed.reason == ""
        assert xfailed.run

    def test_marked_skipif_no_args(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.skipif
            def test_func():
                pass
        """
        )
        skipped = evaluate_skip_marks(item)
        assert skipped
        assert skipped.reason == ""

    def test_marked_one_arg(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.skipif("hasattr(os, 'sep')")
            def test_func():
                pass
        """
        )
        skipped = evaluate_skip_marks(item)
        assert skipped
        assert skipped.reason == "condition: hasattr(os, 'sep')"

    def test_marked_one_arg_with_reason(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.skipif("hasattr(os, 'sep')", attr=2, reason="hello world")
            def test_func():
                pass
        """
        )
        skipped = evaluate_skip_marks(item)
        assert skipped
        assert skipped.reason == "hello world"

    def test_marked_one_arg_twice(self, testdir):
        lines = [
            """@pytest.mark.skipif("not hasattr(os, 'murks')")""",
            """@pytest.mark.skipif(condition="hasattr(os, 'murks')")""",
        ]
        for i in range(0, 2):
            item = testdir.getitem(
                """
                import pytest
                %s
                %s
                def test_func():
                    pass
            """
                % (lines[i], lines[(i + 1) % 2])
            )
            skipped = evaluate_skip_marks(item)
            assert skipped
            assert skipped.reason == "condition: not hasattr(os, 'murks')"

    def test_marked_one_arg_twice2(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.skipif("hasattr(os, 'murks')")
            @pytest.mark.skipif("not hasattr(os, 'murks')")
            def test_func():
                pass
        """
        )
        skipped = evaluate_skip_marks(item)
        assert skipped
        assert skipped.reason == "condition: not hasattr(os, 'murks')"

    def test_marked_skipif_with_boolean_without_reason(self, testdir) -> None:
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.skipif(False)
            def test_func():
                pass
        """
        )
        with pytest.raises(pytest.fail.Exception) as excinfo:
            evaluate_skip_marks(item)
        assert excinfo.value.msg is not None
        assert (
            """Error evaluating 'skipif': you need to specify reason=STRING when using booleans as conditions."""
            in excinfo.value.msg
        )

    def test_marked_skipif_with_invalid_boolean(self, testdir) -> None:
        item = testdir.getitem(
            """
            import pytest

            class InvalidBool:
                def __bool__(self):
                    raise TypeError("INVALID")

            @pytest.mark.skipif(InvalidBool(), reason="xxx")
            def test_func():
                pass
        """
        )
        with pytest.raises(pytest.fail.Exception) as excinfo:
            evaluate_skip_marks(item)
        assert excinfo.value.msg is not None
        assert "Error evaluating 'skipif' condition as a boolean" in excinfo.value.msg
        assert "INVALID" in excinfo.value.msg

    def test_skipif_class(self, testdir):
        (item,) = testdir.getitems(
            """
            import pytest
            class TestClass(object):
                pytestmark = pytest.mark.skipif("config._hackxyz")
                def test_func(self):
                    pass
        """
        )
        item.config._hackxyz = 3
        skipped = evaluate_skip_marks(item)
        assert skipped
        assert skipped.reason == "condition: config._hackxyz"


class TestXFail:
    @pytest.mark.parametrize("strict", [True, False])
    def test_xfail_simple(self, testdir, strict):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail(strict=%s)
            def test_func():
                assert 0
        """
            % strict
        )
        reports = runtestprotocol(item, log=False)
        assert len(reports) == 3
        callreport = reports[1]
        assert callreport.skipped
        assert callreport.wasxfail == ""

    def test_xfail_xpassed(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail(reason="this is an xfail")
            def test_func():
                assert 1
        """
        )
        reports = runtestprotocol(item, log=False)
        assert len(reports) == 3
        callreport = reports[1]
        assert callreport.passed
        assert callreport.wasxfail == "this is an xfail"

    def test_xfail_using_platform(self, testdir):
        """
        Verify that platform can be used with xfail statements.
        """
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail("platform.platform() == platform.platform()")
            def test_func():
                assert 0
        """
        )
        reports = runtestprotocol(item, log=False)
        assert len(reports) == 3
        callreport = reports[1]
        assert callreport.wasxfail

    def test_xfail_xpassed_strict(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail(strict=True, reason="nope")
            def test_func():
                assert 1
        """
        )
        reports = runtestprotocol(item, log=False)
        assert len(reports) == 3
        callreport = reports[1]
        assert callreport.failed
        assert str(callreport.longrepr) == "[XPASS(strict)] nope"
        assert not hasattr(callreport, "wasxfail")

    def test_xfail_run_anyway(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.xfail
            def test_func():
                assert 0
            def test_func2():
                pytest.xfail("hello")
        """
        )
        result = testdir.runpytest("--runxfail")
        result.stdout.fnmatch_lines(
            ["*def test_func():*", "*assert 0*", "*1 failed*1 pass*"]
        )

    def test_xfail_evalfalse_but_fails(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.xfail('False')
            def test_func():
                assert 0
        """
        )
        reports = runtestprotocol(item, log=False)
        callreport = reports[1]
        assert callreport.failed
        assert not hasattr(callreport, "wasxfail")
        assert "xfail" in callreport.keywords

    def test_xfail_not_report_default(self, testdir):
        p = testdir.makepyfile(
            test_one="""
            import pytest
            @pytest.mark.xfail
            def test_this():
                assert 0
        """
        )
        testdir.runpytest(p, "-v")
        # result.stdout.fnmatch_lines([
        #    "*HINT*use*-r*"
        # ])

    def test_xfail_not_run_xfail_reporting(self, testdir):
        p = testdir.makepyfile(
            test_one="""
            import pytest
            @pytest.mark.xfail(run=False, reason="noway")
            def test_this():
                assert 0
            @pytest.mark.xfail("True", run=False)
            def test_this_true():
                assert 0
            @pytest.mark.xfail("False", run=False, reason="huh")
            def test_this_false():
                assert 1
        """
        )
        result = testdir.runpytest(p, "-rx")
        result.stdout.fnmatch_lines(
            [
                "*test_one*test_this*",
                "*NOTRUN*noway",
                "*test_one*test_this_true*",
                "*NOTRUN*condition:*True*",
                "*1 passed*",
            ]
        )

    def test_xfail_not_run_no_setup_run(self, testdir):
        p = testdir.makepyfile(
            test_one="""
            import pytest
            @pytest.mark.xfail(run=False, reason="hello")
            def test_this():
                assert 0
            def setup_module(mod):
                raise ValueError(42)
        """
        )
        result = testdir.runpytest(p, "-rx")
        result.stdout.fnmatch_lines(
            ["*test_one*test_this*", "*NOTRUN*hello", "*1 xfailed*"]
        )

    def test_xfail_xpass(self, testdir):
        p = testdir.makepyfile(
            test_one="""
            import pytest
            @pytest.mark.xfail
            def test_that():
                assert 1
        """
        )
        result = testdir.runpytest(p, "-rX")
        result.stdout.fnmatch_lines(["*XPASS*test_that*", "*1 xpassed*"])
        assert result.ret == 0

    def test_xfail_imperative(self, testdir):
        p = testdir.makepyfile(
            """
            import pytest
            def test_this():
                pytest.xfail("hello")
        """
        )
        result = testdir.runpytest(p)
        result.stdout.fnmatch_lines(["*1 xfailed*"])
        result = testdir.runpytest(p, "-rx")
        result.stdout.fnmatch_lines(["*XFAIL*test_this*", "*reason:*hello*"])
        result = testdir.runpytest(p, "--runxfail")
        result.stdout.fnmatch_lines(["*1 pass*"])

    def test_xfail_imperative_in_setup_function(self, testdir):
        p = testdir.makepyfile(
            """
            import pytest
            def setup_function(function):
                pytest.xfail("hello")

            def test_this():
                assert 0
        """
        )
        result = testdir.runpytest(p)
        result.stdout.fnmatch_lines(["*1 xfailed*"])
        result = testdir.runpytest(p, "-rx")
        result.stdout.fnmatch_lines(["*XFAIL*test_this*", "*reason:*hello*"])
        result = testdir.runpytest(p, "--runxfail")
        result.stdout.fnmatch_lines(
            """
            *def test_this*
            *1 fail*
        """
        )

    def xtest_dynamic_xfail_set_during_setup(self, testdir):
        p = testdir.makepyfile(
            """
            import pytest
            def setup_function(function):
                pytest.mark.xfail(function)
            def test_this():
                assert 0
            def test_that():
                assert 1
        """
        )
        result = testdir.runpytest(p, "-rxX")
        result.stdout.fnmatch_lines(["*XFAIL*test_this*", "*XPASS*test_that*"])

    def test_dynamic_xfail_no_run(self, testdir):
        p = testdir.makepyfile(
            """
            import pytest
            @pytest.fixture
            def arg(request):
                request.applymarker(pytest.mark.xfail(run=False))
            def test_this(arg):
                assert 0
        """
        )
        result = testdir.runpytest(p, "-rxX")
        result.stdout.fnmatch_lines(["*XFAIL*test_this*", "*NOTRUN*"])

    def test_dynamic_xfail_set_during_funcarg_setup(self, testdir):
        p = testdir.makepyfile(
            """
            import pytest
            @pytest.fixture
            def arg(request):
                request.applymarker(pytest.mark.xfail)
            def test_this2(arg):
                assert 0
        """
        )
        result = testdir.runpytest(p)
        result.stdout.fnmatch_lines(["*1 xfailed*"])

    @pytest.mark.parametrize(
        "expected, actual, matchline",
        [
            ("TypeError", "TypeError", "*1 xfailed*"),
            ("(AttributeError, TypeError)", "TypeError", "*1 xfailed*"),
            ("TypeError", "IndexError", "*1 failed*"),
            ("(AttributeError, TypeError)", "IndexError", "*1 failed*"),
        ],
    )
    def test_xfail_raises(self, expected, actual, matchline, testdir):
        p = testdir.makepyfile(
            """
            import pytest
            @pytest.mark.xfail(raises=%s)
            def test_raises():
                raise %s()
        """
            % (expected, actual)
        )
        result = testdir.runpytest(p)
        result.stdout.fnmatch_lines([matchline])

    def test_strict_sanity(self, testdir):
        """sanity check for xfail(strict=True): a failing test should behave
        exactly like a normal xfail.
        """
        p = testdir.makepyfile(
            """
            import pytest
            @pytest.mark.xfail(reason='unsupported feature', strict=True)
            def test_foo():
                assert 0
        """
        )
        result = testdir.runpytest(p, "-rxX")
        result.stdout.fnmatch_lines(["*XFAIL*", "*unsupported feature*"])
        assert result.ret == 0

    @pytest.mark.parametrize("strict", [True, False])
    def test_strict_xfail(self, testdir, strict):
        p = testdir.makepyfile(
            """
            import pytest

            @pytest.mark.xfail(reason='unsupported feature', strict=%s)
            def test_foo():
                with open('foo_executed', 'w'): pass  # make sure test executes
        """
            % strict
        )
        result = testdir.runpytest(p, "-rxX")
        if strict:
            result.stdout.fnmatch_lines(
                ["*test_foo*", "*XPASS(strict)*unsupported feature*"]
            )
        else:
            result.stdout.fnmatch_lines(
                [
                    "*test_strict_xfail*",
                    "XPASS test_strict_xfail.py::test_foo unsupported feature",
                ]
            )
        assert result.ret == (1 if strict else 0)
        assert testdir.tmpdir.join("foo_executed").isfile()

    @pytest.mark.parametrize("strict", [True, False])
    def test_strict_xfail_condition(self, testdir, strict):
        p = testdir.makepyfile(
            """
            import pytest

            @pytest.mark.xfail(False, reason='unsupported feature', strict=%s)
            def test_foo():
                pass
        """
            % strict
        )
        result = testdir.runpytest(p, "-rxX")
        result.stdout.fnmatch_lines(["*1 passed*"])
        assert result.ret == 0

    @pytest.mark.parametrize("strict", [True, False])
    def test_xfail_condition_keyword(self, testdir, strict):
        p = testdir.makepyfile(
            """
            import pytest

            @pytest.mark.xfail(condition=False, reason='unsupported feature', strict=%s)
            def test_foo():
                pass
        """
            % strict
        )
        result = testdir.runpytest(p, "-rxX")
        result.stdout.fnmatch_lines(["*1 passed*"])
        assert result.ret == 0

    @pytest.mark.parametrize("strict_val", ["true", "false"])
    def test_strict_xfail_default_from_file(self, testdir, strict_val):
        testdir.makeini(
            """
            [pytest]
            xfail_strict = %s
        """
            % strict_val
        )
        p = testdir.makepyfile(
            """
            import pytest
            @pytest.mark.xfail(reason='unsupported feature')
            def test_foo():
                pass
        """
        )
        result = testdir.runpytest(p, "-rxX")
        strict = strict_val == "true"
        result.stdout.fnmatch_lines(["*1 failed*" if strict else "*1 xpassed*"])
        assert result.ret == (1 if strict else 0)


class TestXFailwithSetupTeardown:
    def test_failing_setup_issue9(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            def setup_function(func):
                assert 0

            @pytest.mark.xfail
            def test_func():
                pass
        """
        )
        result = testdir.runpytest()
        result.stdout.fnmatch_lines(["*1 xfail*"])

    def test_failing_teardown_issue9(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            def teardown_function(func):
                assert 0

            @pytest.mark.xfail
            def test_func():
                pass
        """
        )
        result = testdir.runpytest()
        result.stdout.fnmatch_lines(["*1 xfail*"])


class TestSkip:
    def test_skip_class(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skip
            class TestSomething(object):
                def test_foo(self):
                    pass
                def test_bar(self):
                    pass

            def test_baz():
                pass
        """
        )
        rec = testdir.inline_run()
        rec.assertoutcome(skipped=2, passed=1)

    def test_skips_on_false_string(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skip('False')
            def test_foo():
                pass
        """
        )
        rec = testdir.inline_run()
        rec.assertoutcome(skipped=1)

    def test_arg_as_reason(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skip('testing stuff')
            def test_bar():
                pass
        """
        )
        result = testdir.runpytest("-rs")
        result.stdout.fnmatch_lines(["*testing stuff*", "*1 skipped*"])

    def test_skip_no_reason(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skip
            def test_foo():
                pass
        """
        )
        result = testdir.runpytest("-rs")
        result.stdout.fnmatch_lines(["*unconditional skip*", "*1 skipped*"])

    def test_skip_with_reason(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skip(reason="for lolz")
            def test_bar():
                pass
        """
        )
        result = testdir.runpytest("-rs")
        result.stdout.fnmatch_lines(["*for lolz*", "*1 skipped*"])

    def test_only_skips_marked_test(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skip
            def test_foo():
                pass
            @pytest.mark.skip(reason="nothing in particular")
            def test_bar():
                pass
            def test_baz():
                assert True
        """
        )
        result = testdir.runpytest("-rs")
        result.stdout.fnmatch_lines(["*nothing in particular*", "*1 passed*2 skipped*"])

    def test_strict_and_skip(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skip
            def test_hello():
                pass
        """
        )
        result = testdir.runpytest("-rs")
        result.stdout.fnmatch_lines(["*unconditional skip*", "*1 skipped*"])


class TestSkipif:
    def test_skipif_conditional(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.skipif("hasattr(os, 'sep')")
            def test_func():
                pass
        """
        )
        x = pytest.raises(pytest.skip.Exception, lambda: pytest_runtest_setup(item))
        assert x.value.msg == "condition: hasattr(os, 'sep')"

    @pytest.mark.parametrize(
        "params", ["\"hasattr(sys, 'platform')\"", 'True, reason="invalid platform"']
    )
    def test_skipif_reporting(self, testdir, params):
        p = testdir.makepyfile(
            test_foo="""
            import pytest
            @pytest.mark.skipif(%(params)s)
            def test_that():
                assert 0
        """
            % dict(params=params)
        )
        result = testdir.runpytest(p, "-s", "-rs")
        result.stdout.fnmatch_lines(["*SKIP*1*test_foo.py*platform*", "*1 skipped*"])
        assert result.ret == 0

    def test_skipif_using_platform(self, testdir):
        item = testdir.getitem(
            """
            import pytest
            @pytest.mark.skipif("platform.platform() == platform.platform()")
            def test_func():
                pass
        """
        )
        pytest.raises(pytest.skip.Exception, lambda: pytest_runtest_setup(item))

    @pytest.mark.parametrize(
        "marker, msg1, msg2",
        [("skipif", "SKIP", "skipped"), ("xfail", "XPASS", "xpassed")],
    )
    def test_skipif_reporting_multiple(self, testdir, marker, msg1, msg2):
        testdir.makepyfile(
            test_foo="""
            import pytest
            @pytest.mark.{marker}(False, reason='first_condition')
            @pytest.mark.{marker}(True, reason='second_condition')
            def test_foobar():
                assert 1
        """.format(
                marker=marker
            )
        )
        result = testdir.runpytest("-s", "-rsxX")
        result.stdout.fnmatch_lines(
            [
                "*{msg1}*test_foo.py*second_condition*".format(msg1=msg1),
                "*1 {msg2}*".format(msg2=msg2),
            ]
        )
        assert result.ret == 0


def test_skip_not_report_default(testdir):
    p = testdir.makepyfile(
        test_one="""
        import pytest
        def test_this():
            pytest.skip("hello")
    """
    )
    result = testdir.runpytest(p, "-v")
    result.stdout.fnmatch_lines(
        [
            # "*HINT*use*-r*",
            "*1 skipped*"
        ]
    )


def test_skipif_class(testdir):
    p = testdir.makepyfile(
        """
        import pytest

        class TestClass(object):
            pytestmark = pytest.mark.skipif("True")
            def test_that(self):
                assert 0
            def test_though(self):
                assert 0
    """
    )
    result = testdir.runpytest(p)
    result.stdout.fnmatch_lines(["*2 skipped*"])


def test_skipped_reasons_functional(testdir):
    testdir.makepyfile(
        test_one="""
            import pytest
            from conftest import doskip

            def setup_function(func):
                doskip()

            def test_func():
                pass

            class TestClass(object):
                def test_method(self):
                    doskip()

                @pytest.mark.skip("via_decorator")
                def test_deco(self):
                    assert 0
        """,
        conftest="""
            import pytest, sys
            def doskip():
                assert sys._getframe().f_lineno == 3
                pytest.skip('test')
        """,
    )
    result = testdir.runpytest("-rs")
    result.stdout.fnmatch_lines_random(
        [
            "SKIPPED [[]2[]] conftest.py:4: test",
            "SKIPPED [[]1[]] test_one.py:14: via_decorator",
        ]
    )
    assert result.ret == 0


def test_skipped_folding(testdir):
    testdir.makepyfile(
        test_one="""
            import pytest
            pytestmark = pytest.mark.skip("Folding")
            def setup_function(func):
                pass
            def test_func():
                pass
            class TestClass(object):
                def test_method(self):
                    pass
       """
    )
    result = testdir.runpytest("-rs")
    result.stdout.fnmatch_lines(["*SKIP*2*test_one.py: Folding"])
    assert result.ret == 0


def test_reportchars(testdir):
    testdir.makepyfile(
        """
        import pytest
        def test_1():
            assert 0
        @pytest.mark.xfail
        def test_2():
            assert 0
        @pytest.mark.xfail
        def test_3():
            pass
        def test_4():
            pytest.skip("four")
    """
    )
    result = testdir.runpytest("-rfxXs")
    result.stdout.fnmatch_lines(
        ["FAIL*test_1*", "XFAIL*test_2*", "XPASS*test_3*", "SKIP*four*"]
    )


def test_reportchars_error(testdir):
    testdir.makepyfile(
        conftest="""
        def pytest_runtest_teardown():
            assert 0
        """,
        test_simple="""
        def test_foo():
            pass
        """,
    )
    result = testdir.runpytest("-rE")
    result.stdout.fnmatch_lines(["ERROR*test_foo*"])


def test_reportchars_all(testdir):
    testdir.makepyfile(
        """
        import pytest
        def test_1():
            assert 0
        @pytest.mark.xfail
        def test_2():
            assert 0
        @pytest.mark.xfail
        def test_3():
            pass
        def test_4():
            pytest.skip("four")
        @pytest.fixture
        def fail():
            assert 0
        def test_5(fail):
            pass
    """
    )
    result = testdir.runpytest("-ra")
    result.stdout.fnmatch_lines(
        [
            "SKIP*four*",
            "XFAIL*test_2*",
            "XPASS*test_3*",
            "ERROR*test_5*",
            "FAIL*test_1*",
        ]
    )


def test_reportchars_all_error(testdir):
    testdir.makepyfile(
        conftest="""
        def pytest_runtest_teardown():
            assert 0
        """,
        test_simple="""
        def test_foo():
            pass
        """,
    )
    result = testdir.runpytest("-ra")
    result.stdout.fnmatch_lines(["ERROR*test_foo*"])


def test_errors_in_xfail_skip_expressions(testdir) -> None:
    testdir.makepyfile(
        """
        import pytest
        @pytest.mark.skipif("asd")
        def test_nameerror():
            pass
        @pytest.mark.xfail("syntax error")
        def test_syntax():
            pass

        def test_func():
            pass
    """
    )
    result = testdir.runpytest()
    markline = "                ^"
    pypy_version_info = getattr(sys, "pypy_version_info", None)
    if pypy_version_info is not None and pypy_version_info < (6,):
        markline = markline[5:]
    elif sys.version_info >= (3, 8) or hasattr(sys, "pypy_version_info"):
        markline = markline[4:]
    result.stdout.fnmatch_lines(
        [
            "*ERROR*test_nameerror*",
            "*evaluating*skipif*condition*",
            "*asd*",
            "*ERROR*test_syntax*",
            "*evaluating*xfail*condition*",
            "    syntax error",
            markline,
            "SyntaxError: invalid syntax",
            "*1 pass*2 errors*",
        ]
    )


def test_xfail_skipif_with_globals(testdir):
    testdir.makepyfile(
        """
        import pytest
        x = 3
        @pytest.mark.skipif("x == 3")
        def test_skip1():
            pass
        @pytest.mark.xfail("x == 3")
        def test_boolean():
            assert 0
    """
    )
    result = testdir.runpytest("-rsx")
    result.stdout.fnmatch_lines(["*SKIP*x == 3*", "*XFAIL*test_boolean*", "*x == 3*"])


def test_default_markers(testdir):
    result = testdir.runpytest("--markers")
    result.stdout.fnmatch_lines(
        [
            "*skipif(condition, ..., [*], reason=...)*skip*",
            "*xfail(condition, ..., [*], reason=..., run=True, raises=None, strict=xfail_strict)*expected failure*",
        ]
    )


def test_xfail_test_setup_exception(testdir):
    testdir.makeconftest(
        """
            def pytest_runtest_setup():
                0 / 0
        """
    )
    p = testdir.makepyfile(
        """
            import pytest
            @pytest.mark.xfail
            def test_func():
                assert 0
        """
    )
    result = testdir.runpytest(p)
    assert result.ret == 0
    assert "xfailed" in result.stdout.str()
    result.stdout.no_fnmatch_line("*xpassed*")


def test_imperativeskip_on_xfail_test(testdir):
    testdir.makepyfile(
        """
        import pytest
        @pytest.mark.xfail
        def test_that_fails():
            assert 0

        @pytest.mark.skipif("True")
        def test_hello():
            pass
    """
    )
    testdir.makeconftest(
        """
        import pytest
        def pytest_runtest_setup(item):
            pytest.skip("abc")
    """
    )
    result = testdir.runpytest("-rsxX")
    result.stdout.fnmatch_lines_random(
        """
        *SKIP*abc*
        *SKIP*condition: True*
        *2 skipped*
    """
    )


class TestBooleanCondition:
    def test_skipif(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skipif(True, reason="True123")
            def test_func1():
                pass
            @pytest.mark.skipif(False, reason="True123")
            def test_func2():
                pass
        """
        )
        result = testdir.runpytest()
        result.stdout.fnmatch_lines(
            """
            *1 passed*1 skipped*
        """
        )

    def test_skipif_noreason(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.skipif(True)
            def test_func():
                pass
        """
        )
        result = testdir.runpytest("-rs")
        result.stdout.fnmatch_lines(
            """
            *1 error*
        """
        )

    def test_xfail(self, testdir):
        testdir.makepyfile(
            """
            import pytest
            @pytest.mark.xfail(True, reason="True123")
            def test_func():
                assert 0
        """
        )
        result = testdir.runpytest("-rxs")
        result.stdout.fnmatch_lines(
            """
            *XFAIL*
            *True123*
            *1 xfail*
        """
        )


def test_xfail_item(testdir):
    # Ensure pytest.xfail works with non-Python Item
    testdir.makeconftest(
        """
        import pytest

        class MyItem(pytest.Item):
            nodeid = 'foo'
            def runtest(self):
                pytest.xfail("Expected Failure")

        def pytest_collect_file(path, parent):
            return MyItem("foo", parent)
    """
    )
    result = testdir.inline_run()
    passed, skipped, failed = result.listoutcomes()
    assert not failed
    xfailed = [r for r in skipped if hasattr(r, "wasxfail")]
    assert xfailed


def test_module_level_skip_error(testdir):
    """
    Verify that using pytest.skip at module level causes a collection error
    """
    testdir.makepyfile(
        """
        import pytest
        pytest.skip("skip_module_level")

        def test_func():
            assert True
    """
    )
    result = testdir.runpytest()
    result.stdout.fnmatch_lines(
        ["*Using pytest.skip outside of a test is not allowed*"]
    )


def test_module_level_skip_with_allow_module_level(testdir):
    """
    Verify that using pytest.skip(allow_module_level=True) is allowed
    """
    testdir.makepyfile(
        """
        import pytest
        pytest.skip("skip_module_level", allow_module_level=True)

        def test_func():
            assert 0
    """
    )
    result = testdir.runpytest("-rxs")
    result.stdout.fnmatch_lines(["*SKIP*skip_module_level"])


def test_invalid_skip_keyword_parameter(testdir):
    """
    Verify that using pytest.skip() with unknown parameter raises an error
    """
    testdir.makepyfile(
        """
        import pytest
        pytest.skip("skip_module_level", unknown=1)

        def test_func():
            assert 0
    """
    )
    result = testdir.runpytest()
    result.stdout.fnmatch_lines(["*TypeError:*['unknown']*"])


def test_mark_xfail_item(testdir):
    # Ensure pytest.mark.xfail works with non-Python Item
    testdir.makeconftest(
        """
        import pytest

        class MyItem(pytest.Item):
            nodeid = 'foo'
            def setup(self):
                marker = pytest.mark.xfail("1 == 2", reason="Expected failure - false")
                self.add_marker(marker)
                marker = pytest.mark.xfail(True, reason="Expected failure - true")
                self.add_marker(marker)
            def runtest(self):
                assert False

        def pytest_collect_file(path, parent):
            return MyItem("foo", parent)
    """
    )
    result = testdir.inline_run()
    passed, skipped, failed = result.listoutcomes()
    assert not failed
    xfailed = [r for r in skipped if hasattr(r, "wasxfail")]
    assert xfailed


def test_summary_list_after_errors(testdir):
    """Ensure the list of errors/fails/xfails/skips appears after tracebacks in terminal reporting."""
    testdir.makepyfile(
        """
        import pytest
        def test_fail():
            assert 0
    """
    )
    result = testdir.runpytest("-ra")
    result.stdout.fnmatch_lines(
        [
            "=* FAILURES *=",
            "*= short test summary info =*",
            "FAILED test_summary_list_after_errors.py::test_fail - assert 0",
        ]
    )


def test_importorskip():
    with pytest.raises(
        pytest.skip.Exception,
        match="^could not import 'doesnotexist': No module named .*",
    ):
        pytest.importorskip("doesnotexist")


def test_relpath_rootdir(testdir):
    testdir.makepyfile(
        **{
            "tests/test_1.py": """
        import pytest
        @pytest.mark.skip()
        def test_pass():
            pass
            """,
        }
    )
    result = testdir.runpytest("-rs", "tests/test_1.py", "--rootdir=tests")
    result.stdout.fnmatch_lines(
        ["SKIPPED [[]1[]] tests/test_1.py:2: unconditional skip"]
    )


def test_skipped_location_with_runxfail(testdir):
    testdir.makepyfile(
        """
        import pytest

        @pytest.mark.skip
        def test_skip_location():
            assert 0
        """
    )
    result = testdir.runpytest("-rs", "--runxfail")
    result.stdout.fnmatch_lines(
        ["SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:3: unconditional skip"]
    )

```


# changelog (the files in it)

changelog/1120.bugfix.rst
changelog/1316.breaking.rst
changelog/1556.feature.rst
changelog/4049.feature.rst
changelog/4375.improvement.rst
changelog/4391.improvement.rst
changelog/4583.bugfix.rst
changelog/4675.improvement.rst
changelog/4677.bugfix.rst
changelog/5456.bugfix.rst
changelog/5965.breaking.rst
changelog/6240.bugfix.rst
changelog/6285.feature.rst
changelog/6428.bugfix.rst
changelog/6433.feature.rst
changelog/6471.feature.rst
changelog/6505.breaking.rst
changelog/6755.bugfix.rst
changelog/6817.improvement.rst
changelog/6856.feature.rst
changelog/6871.bugfix.rst
changelog/6903.breaking.rst
changelog/6906.feature.rst
changelog/6909.bugfix.rst
changelog/6910.bugfix.rst
changelog/6924.bugfix.rst
changelog/6925.bugfix.rst
changelog/6940.improvement.rst
changelog/6947.bugfix.rst
changelog/6951.bugfix.rst
changelog/6956.bugfix.rst
changelog/6981.deprecation.rst
changelog/6991.bugfix.rst
changelog/6991.improvement.rst
changelog/6992.bugfix.rst
changelog/7035.trivial.rst
changelog/7040.breaking.rst
changelog/7061.bugfix.rst
changelog/7076.bugfix.rst
changelog/7091.improvement.rst
changelog/7097.deprecation.rst
changelog/7110.bugfix.rst
changelog/7119.improvement.rst
changelog/7122.breaking.rst
changelog/7126.bugfix.rst
changelog/7128.improvement.rst
changelog/7133.improvement.rst
changelog/7135.breaking.rst
changelog/7143.bugfix.rst
changelog/7145.bugfix.rst
changelog/7150.bugfix.rst
changelog/7180.bugfix.rst
changelog/7202.doc.rst
changelog/7210.deprecation.rst
changelog/7215.bugfix.rst
changelog/7224.breaking.rst
changelog/7226.breaking.rst
changelog/7233.doc.rst
changelog/7245.feature.rst
changelog/7253.bugfix.rst
changelog/7264.improvement.rst
changelog/7291.trivial.rst
changelog/7295.trivial.rst
changelog/7305.feature.rst
changelog/7345.doc.rst
changelog/7346.feature.rst
changelog/7356.trivial.rst
changelog/7357.trivial.rst
changelog/7360.bugfix.rst
changelog/7383.bugfix.rst
changelog/7385.improvement.rst
changelog/7418.breaking.rst
changelog/README.rst
changelog/_template.rst


# The last commit

```
a0d8040ee SWE-bench



 .coveragerc                                                 |   0
 .gitattributes                                              |   0
 .gitblameignore                                             |   0
 .github/FUNDING.yml                                         |   0
 .github/ISSUE_TEMPLATE.md                                   |   0
 .github/PULL_REQUEST_TEMPLATE.md                            |   0
 .github/config.yml                                          |   0
 .github/labels.toml                                         |   0
 .github/workflows/main.yml                                  |   0
 .github/workflows/release-on-comment.yml                    |   0
 .gitignore                                                  |   0
 .pre-commit-config.yaml                                     |   0
 .travis.yml                                                 |   0
 AUTHORS                                                     |   0
 CHANGELOG.rst                                               |   0
 CITATION                                                    |   0
 CODE_OF_CONDUCT.md                                          |   0
 CONTRIBUTING.rst                                            |   0
 LICENSE                                                     |   0
 OPENCOLLECTIVE.rst                                          |   0
 README.rst                                                  |   0
 RELEASING.rst                                               |   0
 TIDELIFT.rst                                                |   0
 bench/bench.py                                              |   0
 bench/bench_argcomplete.py                                  |   0
 bench/empty.py                                              |   0
 bench/manyparam.py                                          |   0
 bench/skip.py                                               |   0
 changelog/1120.bugfix.rst                                   |   0
 changelog/1316.breaking.rst                                 |   0
 changelog/1556.feature.rst                                  |   0
 changelog/4049.feature.rst                                  |   0
 changelog/4375.improvement.rst                              |   0
 changelog/4391.improvement.rst                              |   0
 changelog/4583.bugfix.rst                                   |   0
 changelog/4675.improvement.rst                              |   0
 changelog/4677.bugfix.rst                                   |   0
 changelog/5456.bugfix.rst                                   |   0
 changelog/5965.breaking.rst                                 |   0
 changelog/6240.bugfix.rst                                   |   0
 changelog/6285.feature.rst                                  |   0
 changelog/6428.bugfix.rst                                   |   0
 changelog/6433.feature.rst                                  |   0
 changelog/6471.feature.rst                                  |   0
 changelog/6505.breaking.rst                                 |   0
 changelog/6755.bugfix.rst                                   |   0
 changelog/6817.improvement.rst                              |   0
 changelog/6856.feature.rst                                  |   0
 changelog/6871.bugfix.rst                                   |   0
 changelog/6903.breaking.rst                                 |   0
 changelog/6906.feature.rst                                  |   0
 changelog/6909.bugfix.rst                                   |   0
 changelog/6910.bugfix.rst                                   |   0
 changelog/6924.bugfix.rst                                   |   0
 changelog/6925.bugfix.rst                                   |   0
 changelog/6940.improvement.rst                              |   0
```

```diff
diff --git a/.coveragerc b/.coveragerc
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.gitblameignore b/.gitblameignore
old mode 100644
new mode 100755
diff --git a/.github/FUNDING.yml b/.github/FUNDING.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE.md b/.github/ISSUE_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/PULL_REQUEST_TEMPLATE.md b/.github/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/config.yml b/.github/config.yml
old mode 100644
new mode 100755
diff --git a/.github/labels.toml b/.github/labels.toml
old mode 100644
new mode 100755
diff --git a/.github/workflows/main.yml b/.github/workflows/main.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/release-on-comment.yml b/.github/workflows/release-on-comment.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.pre-commit-config.yaml b/.pre-commit-config.yaml
old mode 100644
new mode 100755
diff --git a/.travis.yml b/.travis.yml
old mode 100644
new mode 100755
diff --git a/AUTHORS b/AUTHORS
old mode 100644
new mode 100755
diff --git a/CHANGELOG.rst b/CHANGELOG.rst
old mode 100644
new mode 100755
diff --git a/CITATION b/CITATION
old mode 100644
new mode 100755
diff --git a/CODE_OF_CONDUCT.md b/CODE_OF_CONDUCT.md
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.rst b/CONTRIBUTING.rst
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/OPENCOLLECTIVE.rst b/OPENCOLLECTIVE.rst
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/RELEASING.rst b/RELEASING.rst
old mode 100644
new mode 100755
diff --git a/TIDELIFT.rst b/TIDELIFT.rst
old mode 100644
new mode 100755
diff --git a/bench/bench.py b/bench/bench.py
old mode 100644
new mode 100755
diff --git a/bench/bench_argcomplete.py b/bench/bench_argcomplete.py
old mode 100644
new mode 100755
diff --git a/bench/empty.py b/bench/empty.py
old mode 100644
new mode 100755
diff --git a/bench/manyparam.py b/bench/manyparam.py
old mode 100644
new mode 100755
diff --git a/bench/skip.py b/bench/skip.py
old mode 100644
new mode 100755
diff --git a/changelog/1120.bugfix.rst b/changelog/1120.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/1316.breaking.rst b/changelog/1316.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/1556.feature.rst b/changelog/1556.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/4049.feature.rst b/changelog/4049.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/4375.improvement.rst b/changelog/4375.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/4391.improvement.rst b/changelog/4391.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/4583.bugfix.rst b/changelog/4583.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/4675.improvement.rst b/changelog/4675.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/4677.bugfix.rst b/changelog/4677.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/5456.bugfix.rst b/changelog/5456.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/5965.breaking.rst b/changelog/5965.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/6240.bugfix.rst b/changelog/6240.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6285.feature.rst b/changelog/6285.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6428.bugfix.rst b/changelog/6428.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6433.feature.rst b/changelog/6433.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6471.feature.rst b/changelog/6471.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6505.breaking.rst b/changelog/6505.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/6755.bugfix.rst b/changelog/6755.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6817.improvement.rst b/changelog/6817.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/6856.feature.rst b/changelog/6856.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6871.bugfix.rst b/changelog/6871.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6903.breaking.rst b/changelog/6903.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/6906.feature.rst b/changelog/6906.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6909.bugfix.rst b/changelog/6909.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6910.bugfix.rst b/changelog/6910.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6924.bugfix.rst b/changelog/6924.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6925.bugfix.rst b/changelog/6925.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6940.improvement.rst b/changelog/6940.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/6947.bugfix.rst b/changelog/6947.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6951.bugfix.rst b/changelog/6951.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6956.bugfix.rst b/changelog/6956.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6981.deprecation.rst b/changelog/6981.deprecation.rst
old mode 100644
new mode 100755
diff --git a/changelog/6991.bugfix.rst b/changelog/6991.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6991.improvement.rst b/changelog/6991.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/6992.bugfix.rst b/changelog/6992.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7035.trivial.rst b/changelog/7035.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7040.breaking.rst b/changelog/7040.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7061.bugfix.rst b/changelog/7061.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7076.bugfix.rst b/changelog/7076.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7091.improvement.rst b/changelog/7091.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7097.deprecation.rst b/changelog/7097.deprecation.rst
old mode 100644
new mode 100755
diff --git a/changelog/7110.bugfix.rst b/changelog/7110.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7119.improvement.rst b/changelog/7119.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7122.breaking.rst b/changelog/7122.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7126.bugfix.rst b/changelog/7126.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7128.improvement.rst b/changelog/7128.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7133.improvement.rst b/changelog/7133.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7135.breaking.rst b/changelog/7135.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7143.bugfix.rst b/changelog/7143.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7145.bugfix.rst b/changelog/7145.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7150.bugfix.rst b/changelog/7150.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7180.bugfix.rst b/changelog/7180.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7202.doc.rst b/changelog/7202.doc.rst
old mode 100644
new mode 100755
diff --git a/changelog/7210.deprecation.rst b/changelog/7210.deprecation.rst
old mode 100644
new mode 100755
diff --git a/changelog/7215.bugfix.rst b/changelog/7215.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7224.breaking.rst b/changelog/7224.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7226.breaking.rst b/changelog/7226.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7233.doc.rst b/changelog/7233.doc.rst
old mode 100644
new mode 100755
diff --git a/changelog/7245.feature.rst b/changelog/7245.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/7253.bugfix.rst b/changelog/7253.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7264.improvement.rst b/changelog/7264.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7291.trivial.rst b/changelog/7291.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7295.trivial.rst b/changelog/7295.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7305.feature.rst b/changelog/7305.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/7345.doc.rst b/changelog/7345.doc.rst
old mode 100644
new mode 100755
diff --git a/changelog/7346.feature.rst b/changelog/7346.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/7356.trivial.rst b/changelog/7356.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7357.trivial.rst b/changelog/7357.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7360.bugfix.rst b/changelog/7360.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7383.bugfix.rst b/changelog/7383.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7385.improvement.rst b/changelog/7385.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7418.breaking.rst b/changelog/7418.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/README.rst b/changelog/README.rst
old mode 100644
new mode 100755
diff --git a/changelog/_template.rst b/changelog/_template.rst
old mode 100644
new mode 100755
diff --git a/codecov.yml b/codecov.yml
old mode 100644
new mode 100755
diff --git a/doc/en/Makefile b/doc/en/Makefile
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/globaltoc.html b/doc/en/_templates/globaltoc.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/links.html b/doc/en/_templates/links.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/relations.html b/doc/en/_templates/relations.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/sidebarintro.html b/doc/en/_templates/sidebarintro.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/slim_searchbox.html b/doc/en/_templates/slim_searchbox.html
old mode 100644
new mode 100755
diff --git a/doc/en/adopt.rst b/doc/en/adopt.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/index.rst b/doc/en/announce/index.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.0.rst b/doc/en/announce/release-2.0.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.1.rst b/doc/en/announce/release-2.0.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.2.rst b/doc/en/announce/release-2.0.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.3.rst b/doc/en/announce/release-2.0.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.0.rst b/doc/en/announce/release-2.1.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.1.rst b/doc/en/announce/release-2.1.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.2.rst b/doc/en/announce/release-2.1.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.3.rst b/doc/en/announce/release-2.1.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.0.rst b/doc/en/announce/release-2.2.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.1.rst b/doc/en/announce/release-2.2.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.2.rst b/doc/en/announce/release-2.2.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.4.rst b/doc/en/announce/release-2.2.4.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.0.rst b/doc/en/announce/release-2.3.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.1.rst b/doc/en/announce/release-2.3.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.2.rst b/doc/en/announce/release-2.3.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.3.rst b/doc/en/announce/release-2.3.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.4.rst b/doc/en/announce/release-2.3.4.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.5.rst b/doc/en/announce/release-2.3.5.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.4.0.rst b/doc/en/announce/release-2.4.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.4.1.rst b/doc/en/announce/release-2.4.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.4.2.rst b/doc/en/announce/release-2.4.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.5.0.rst b/doc/en/announce/release-2.5.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.5.1.rst b/doc/en/announce/release-2.5.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.5.2.rst b/doc/en/announce/release-2.5.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.0.rst b/doc/en/announce/release-2.6.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.1.rst b/doc/en/announce/release-2.6.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.2.rst b/doc/en/announce/release-2.6.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.3.rst b/doc/en/announce/release-2.6.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.7.0.rst b/doc/en/announce/release-2.7.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.7.1.rst b/doc/en/announce/release-2.7.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.7.2.rst b/doc/en/announce/release-2.7.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.2.rst b/doc/en/announce/release-2.8.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.3.rst b/doc/en/announce/release-2.8.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.4.rst b/doc/en/announce/release-2.8.4.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.5.rst b/doc/en/announce/release-2.8.5.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.6.rst b/doc/en/announce/release-2.8.6.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.7.rst b/doc/en/announce/release-2.8.7.rst
old mode 100644
new mode 100755
diff --git a/doc
```
````

### `direct-check.log`

```
check: python -m pytest testing/test_skipping.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-5.4.1.dev593+ge6e300e72.d20260815, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: pyproject.toml
collected 78 items

testing/test_skipping.py ............................................... [ 60%]
...............................                                          [100%]

============================= 78 passed in 22.38s ==============================
scope: src/_pytest/skipping.py testing/test_skipping.py changelog
changed: src/_pytest/skipping.py +12 -12
changed: testing/test_skipping.py +16 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/src/_pytest/skipping.py b/src/_pytest/skipping.py
index 7bd975e5a..4b657af14 100755
--- a/src/_pytest/skipping.py
+++ b/src/_pytest/skipping.py
@@ -270,6 +270,18 @@ def pytest_runtest_makereport(item: Item, call: CallInfo[None]):
         else:
             rep.longrepr = "Unexpected success"
         rep.outcome = "failed"
+    elif (
+        item._store.get(skipped_by_mark_key, True)
+        and rep.skipped
+        and type(rep.longrepr) is tuple
+    ):
+        # skipped by mark.skipif; change the location of the failure
+        # to point to the item definition, otherwise it will display
+        # the location of where the skip exception was raised within pytest
+        _, _, reason = rep.longrepr
+        filename, line = item.reportinfo()[:2]
+        assert line is not None
+        rep.longrepr = str(filename), line + 1, reason
     elif item.config.option.runxfail:
         pass  # don't interfere
     elif call.excinfo and isinstance(call.excinfo.value, xfail.Exception):
@@ -291,18 +303,6 @@ def pytest_runtest_makereport(item: Item, call: CallInfo[None]):
             else:
                 rep.outcome = "passed"
                 rep.wasxfail = xfailed.reason
-    elif (
-        item._store.get(skipped_by_mark_key, True)
-        and rep.skipped
-        and type(rep.longrepr) is tuple
-    ):
-        # skipped by mark.skipif; change the location of the failure
-        # to point to the item definition, otherwise it will display
-        # the location of where the skip exception was raised within pytest
-        _, _, reason = rep.longrepr
-        filename, line = item.reportinfo()[:2]
-        assert line is not None
-        rep.longrepr = str(filename), line + 1, reason
 
 
 def pytest_report_teststatus(report: BaseReport) -> Optional[Tuple[str, str, str]]:
diff --git a/testing/test_skipping.py b/testing/test_skipping.py
index 0b1c0b49b..296f5c59b 100755
--- a/testing/test_skipping.py
+++ b/testing/test_skipping.py
@@ -1205,3 +1205,19 @@ def test_relpath_rootdir(testdir):
     result.stdout.fnmatch_lines(
         ["SKIPPED [[]1[]] tests/test_1.py:2: unconditional skip"]
     )
+
+
+def test_skipped_location_with_runxfail(testdir):
+    testdir.makepyfile(
+        """
+        import pytest
+
+        @pytest.mark.skip
+        def test_skip_location():
+            assert 0
+        """
+    )
+    result = testdir.runpytest("-rs", "--runxfail")
+    result.stdout.fnmatch_lines(
+        ["SKIPPED [[]1[]] test_skipped_location_with_runxfail.py:3: unconditional skip"]
+    )
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
check: python -m pytest testing/test_skipping.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-5.4.1.dev593+ge6e300e72.d20260815, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: pyproject.toml
collected 78 items

testing/test_skipping.py ............................................... [ 60%]
...............................                                          [100%]

============================== 78 passed in 6.24s ==============================
scope: src/_pytest/skipping.py testing/test_skipping.py changelog
changed: src/_pytest/skipping.py +12 -12
changed: testing/test_skipping.py +16 -0
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
# Notes, run 2026-11-06T130143

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

skipping: --runxfail breaks pytest.mark.skip location reporting
pytest versions: 5.4.x, current master

When `@pytest.mark.skip`/`skipif` marks are used to skip a test, for example

```py
import pytest
@pytest.mark.skip
def test_skip_location() -> None:
    assert 0
```

the expected skip location reported should point to the item itself, and this is indeed what happens when running with `pytest -rs`:

```
SKIPPED [1] test_it.py:3: unconditional skip
```

However, adding `pytest -rs --runxfail` breaks this:

```
SKIPPED [1] src/_pytest/skipping.py:238: unconditional skip
```

The `--runxfail` is only about xfail and should not affect this at all.

---

Hint: the bug is in `src/_pytest/skipping.py`, the `pytest_runtest_makereport` hook.


# The files of the project

```
.coveragerc
.gitattributes
.gitblameignore
.github/FUNDING.yml
.github/ISSUE_TEMPLATE.md
.github/PULL_REQUEST_TEMPLATE.md
.github/config.yml
.github/labels.toml
.github/workflows/main.yml
.github/workflows/release-on-comment.yml
.gitignore
.pre-commit-config.yaml
.travis.yml
AUTHORS
CHANGELOG.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.rst
LICENSE
OPENCOLLECTIVE.rst
README.rst
RELEASING.rst
TIDELIFT.rst
bench/bench.py
bench/bench_argcomplete.py
bench/empty.py
bench/manyparam.py
bench/skip.py
changelog/1120.bugfix.rst
changelog/1316.breaking.rst
changelog/1556.feature.rst
changelog/4049.feature.rst
changelog/4375.improvement.rst
changelog/4391.improvement.rst
changelog/4583.bugfix.rst
changelog/4675.improvement.rst
changelog/4677.bugfix.rst
changelog/5456.bugfix.rst
changelog/5965.breaking.rst
changelog/6240.bugfix.rst
changelog/6285.feature.rst
changelog/6428.bugfix.rst
changelog/6433.feature.rst
changelog/6471.feature.rst
changelog/6505.breaking.rst
changelog/6755.bugfix.rst
changelog/6817.improvement.rst
changelog/6856.feature.rst
changelog/6871.bugfix.rst
changelog/6903.breaking.rst
changelog/6906.feature.rst
changelog/6909.bugfix.rst
changelog/6910.bugfix.rst
changelog/6924.bugfix.rst
changelog/6925.bugfix.rst
changelog/6940.improvement.rst
changelog/6947.bugfix.rst
changelog/6951.bugfix.rst
changelog/6956.bugfix.rst
changelog/6981.deprecation.rst
changelog/6991.bugfix.rst
changelog/6991.improvement.rst
changelog/6992.bugfix.rst
changelog/7035.trivial.rst
changelog/7040.breaking.rst
changelog/7061.bugfix.rst
changelog/7076.bugfix.rst
changelog/7091.improvement.rst
changelog/7097.deprecation.rst
changelog/7110.bugfix.rst
changelog/7119.improvement.rst
changelog/7122.breaking.rst
changelog/7126.bugfix.rst
changelog/7128.improvement.rst
changelog/7133.improvement.rst
changelog/7135.breaking.rst
changelog/7143.bugfix.rst
changelog/7145.bugfix.rst
changelog/7150.bugfix.rst
changelog/7180.bugfix.rst
changelog/7202.doc.rst
changelog/7210.deprecation.rst
changelog/7215.bugfix.rst
changelog/7224.breaking.rst
changelog/7226.breaking.rst
changelog/7233.doc.rst
changelog/7245.feature.rst
changelog/7253.bugfix.rst
changelog/7264.improvement.rst
changelog/7291.trivial.rst
changelog/7295.trivial.rst
changelog/7305.feature.rst
changelog/7345.doc.rst
changelog/7346.feature.rst
changelog/7356.trivial.rst
changelog/7357.trivial.rst
changelog/7360.bugfix.rst
changelog/7383.bugfix.rst
changelog/7385.improvement.rst
changelog/7418.breaking.rst
changelog/README.rst
changelog/_template.rst
codecov.yml
doc/en/Makefile
doc/en/_templates/globaltoc.html
doc/en/_templates/links.html
doc/en/_templates/relations.html
doc/en/_templates/sidebarintro.html
doc/en/_templates/slim_searchbox.html
doc/en/adopt.rst
doc/en/announce/index.rst
doc/en/announce/release-2.0.0.rst
doc/en/announce/release-2.0.1.rst
doc/en/announce/release-2.0.2.rst
doc/en/announce/release-2.0.3.rst
doc/en/announce/release-2.1.0.rst
doc/en/announce/release-2.1.1.rst
doc/en/announce/release-2.1.2.rst
doc/en/announce/release-2.1.3.rst
doc/en/announce/release-2.2.0.rst
doc/en/announce/release-2.2.1.rst
doc/en/announce/release-2.2.2.rst
doc/en/announce/release-2.2.4.rst
doc/en/announce/release-2.3.0.rst
doc/en/announce/release-2.3.1.rst
doc/en/announce/release-2.3.2.rst
doc/en/announce/release-2.3.3.rst
doc/en/announce/release-2.3.4.rst
doc/en/announce/release-2.3.5.rst
doc/en/announce/release-2.4.0.rst
doc/en/announce/release-2.4.1.rst
doc/en/announce/release-2.4.2.rst
doc/en/announce/release-2.5.0.rst
doc/en/announce/release-2.5.1.rst
doc/en/announce/release-2.5.2.rst
doc/en/announce/release-2.6.0.rst
doc/en/announce/release-2.6.1.rst
doc/en/announce/release-2.6.2.rst
doc/en/announce/release-2.6.3.rst
doc/en/announce/release-2.7.0.rst
doc/en/announce/release-2.7.1.rst
doc/en/announce/release-2.7.2.rst
doc/en/announce/release-2.8.2.rst
doc/en/announce/release-2.8.3.rst
doc/en/announce/release-2.8.4.rst
doc/en/announce/release-2.8.5.rst
doc/en/announce/release-2.8.6.rst
doc/en/announce/release-2.8.7.rst
doc/en/announce/release-2.9.0.rst
doc/en/announce/release-2.9.1.rst
doc/en/announce/release-2.9.2.rst
doc/en/announce/release-3.0.0.rst
doc/en/announce/release-3.0.1.rst
doc/en/announce/release-3.0.2.rst
doc/en/announce/release-3.0.3.rst
doc/en/announce/release-3.0.4.rst
doc/en/announce/release-3.0.5.rst
doc/en/announce/release-3.0.6.rst
doc/en/announce/release-3.0.7.rst
doc/en/announce/release-3.1.0.rst
doc/en/announce/release-3.1.1.rst
doc/en/announce/release-3.1.2.rst
doc/en/announce/release-3.1.3.rst
doc/en/announce/release-3.10.0.rst
doc/en/announce/release-3.10.1.rst
doc/en/announce/release-3.2.0.rst
doc/en/announce/release-3.2.1.rst
doc/en/announce/release-3.2.2.rst
doc/en/announce/release-3.2.3.rst
doc/en/announce/release-3.2.4.rst
doc/en/announce/release-3.2.5.rst
doc/en/announce/release-3.3.0.rst
doc/en/announce/release-3.3.1.rst
doc/en/announce/release-3.3.2.rst
doc/en/announce/release-3.4.0.rst
doc/en/announce/release-3.4.1.rst
doc/en/announce/release-3.4.2.rst
doc/en/announce/release-3.5.0.rst
doc/en/announce/release-3.5.1.rst
doc/en/announce/release-3.6.0.rst
doc/en/announce/release-3.6.1.rst
doc/en/announce/release-3.6.2.rst
doc/en/announce/release-3.6.3.rst
doc/en/announce/release-3.6.4.rst
doc/en/announce/release-3.7.0.rst
doc/en/announce/release-3.7.1.rst
doc/en/announce/release-3.7.2.rst
doc/en/announce/release-3.7.3.rst
doc/en/announce/release-3.7.4.rst
doc/en/announce/release-3.8.0.rst
doc/en/announce/release-3.8.1.rst
doc/en/announce/release-3.8.2.rst
doc/en/announce/release-3.9.0.rst
doc/en/announce/release-3.9.1.rst
doc/en/announce/release-3.9.2.rst
doc/en/announce/release-3.9.3.rst
doc/en/announce/release-4.0.0.rst
doc/en/announce/release-4.0.1.rst
doc/en/announce/release-4.0.2.rst
doc/en/announce/release-4.1.0.rst
doc/en/announce/release-4.1.1.rst
doc/en/announce/release-4.2.0.rst
doc/en/announce/release-4.2.1.rst
doc/en/announce/release-4.3.0.rst
doc/en/announce/release-4.3.1.rst
doc/en/announce/release-4.4.0.rst
doc/en/announce/release-4.4.1.rst
doc/en/announce/release-4.4.2.rst
doc/en/announce/release-4.5.0.rst
doc/en/announce/release-4.6.0.rst
doc/en/announce/release-4.6.1.rst
doc/en/announce/release-4.6.2.rst
doc/en/announce/release-4.6.3.rst
doc/en/announce/release-4.6.4.rst
doc/en/announce/release-4.6.5.rst
doc/en/announce/release-4.6.6.rst
doc/en/announce/release-4.6.7.rst
doc/en/announce/release-4.6.8.rst
doc/en/announce/release-4.6.9.rst
doc/en/announce/release-5.0.0.rst
doc/en/announce/release-5.0.1.rst
doc/en/announce/release-5.1.0.rst
doc/en/announce/release-5.1.1.rst
doc/en/announce/release-5.1.2.rst
doc/en/announce/release-5.1.3.rst
doc/en/announce/release-5.2.0.rst
doc/en/announce/release-5.2.1.rst
doc/en/announce/release-5.2.2.rst
doc/en/announce/release-5.2.3.rst
doc/en/announce/release-5.2.4.rst
doc/en/announce/release-5.3.0.rst
doc/en/announce/release-5.3.1.rst
doc/en/announce/release-5.3.2.rst
doc/en/announce/release-5.3.3.rst
doc/en/announce/release-5.3.4.rst
doc/en/announce/release-5.3.5.rst
doc/en/announce/release-5.4.0.rst
doc/en/announce/release-5.4.1.rst
doc/en/announce/release-5.4.2.rst
doc/en/announce/release-5.4.3.rst
doc/en/announce/sprint2016.rst
doc/en/assert.rst
doc/en/backwards-compatibility.rst
doc/en/bash-completion.rst
doc/en/builtin.rst
doc/en/cache.rst
doc/en/capture.rst
doc/en/changelog.rst
doc/en/conf.py
doc/en/conftest.py
doc/en/contact.rst
doc/en/contents.rst
doc/en/contributing.rst
doc/en/customize.rst
doc/en/deprecations.rst
doc/en/development_guide.rst
doc/en/doctest.rst
doc/en/example/assertion/failure_demo.py
doc/en/example/assertion/global_testmodule_config/conftest.py
doc/en/example/assertion/global_testmodule_config/test_hello_world.py
doc/en/example/assertion/test_failures.py
doc/en/example/assertion/test_setup_flow_example.py
doc/en/example/attic.rst
doc/en/example/conftest.py
doc/en/example/fixtures/test_fixtures_order.py
doc/en/example/index.rst
doc/en/example/markers.rst
doc/en/example/multipython.py
doc/en/example/nonpython.rst
doc/en/example/nonpython/__init__.py
doc/en/example/nonpython/conftest.py
doc/en/example/nonpython/test_simple.yaml
doc/en/example/parametrize.rst
doc/en/example/pythoncollection.py
doc/en/example/pythoncollection.rst
doc/en/example/reportingdemo.rst
doc/en/example/simple.rst
doc/en/example/special.rst
doc/en/example/xfail_demo.py
doc/en/existingtestsuite.rst
doc/en/faq.rst
doc/en/fixture.rst
doc/en/flaky.rst
doc/en/funcarg_compare.rst
doc/en/funcargs.rst
doc/en/getting-started.rst
doc/en/goodpractices.rst
doc/en/historical-notes.rst
doc/en/img/cramer2.png
doc/en/img/favicon.png
doc/en/img/freiburg2.jpg
doc/en/img/gaynor3.png
doc/en/img/keleshev.png
doc/en/img/pullrequest.png
doc/en/img/pylib.png
doc/en/img/pytest1.png
doc/en/img/theuni.png
doc/en/index.rst
doc/en/license.rst
doc/en/logging.rst
doc/en/mark.rst
doc/en/monkeypatch.rst
doc/en/naming20.rst
doc/en/nose.rst
doc/en/parametrize.rst
doc/en/plugins.rst
doc/en/projects.rst
doc/en/proposals/parametrize_with_fixtures.rst
doc/en/py27-py34-deprecation.rst
doc/en/pytest.ini
doc/en/pythonpath.rst
doc/en/recwarn.rst
doc/en/reference.rst
doc/en/requirements.txt
doc/en/skipping.rst
doc/en/sponsor.rst
doc/en/talks.rst
doc/en/tidelift.rst
doc/en/tmpdir.rst
doc/en/unittest.rst
doc/en/usage.rst
doc/en/warnings.rst
doc/en/writing_plugins.rst
doc/en/xunit_setup.rst
doc/en/yieldfixture.rst
extra/get_issues.py
extra/setup-py.test/setup.py
pyproject.toml
scripts/append_codecov_token.py
scripts/publish-gh-release-notes.py
scripts/release-on-comment.py
scripts/release.minor.rst
scripts/release.patch.rst
scripts/release.py
scripts/report-coverage.sh
scripts/towncrier-draft-to-file.py
setup.cfg
setup.py
src/_pytest/__init__.py
src/_pytest/_argcomplete.py
src/_pytest/_code/__init__.py
src/_pytest/_code/code.py
src/_pytest/_code/source.py
src/_pytest/_io/__init__.py
src/_pytest/_io/saferepr.py
src/_pytest/_io/terminalwriter.py
src/_pytest/_io/wcwidth.py
src/_pytest/assertion/__init__.py
src/_pytest/assertion/rewrite.py
src/_pytest/assertion/truncate.py
src/_pytest/assertion/util.py
src/_pytest/cacheprovider.py
src/_pytest/capture.py
src/_pytest/compat.py
src/_pytest/config/__init__.py
src/_pytest/config/argparsing.py
src/_pytest/config/exceptions.py
src/_pytest/config/findpaths.py
src/_pytest/debugging.py
src/_pytest/deprecated.py
src/_pytest/doctest.py
src/_pytest/faulthandler.py
src/_pytest/fixtures.py
src/_pytest/freeze_support.py
src/_pytest/helpconfig.py
src/_pytest/hookspec.py
src/_pytest/junitxml.py
src/_pytest/logging.py
src/_pytest/main.py
src/_pytest/mark/__init__.py
src/_pytest/mark/expression.py
src/_pytest/mark/structures.py
src/_pytest/monkeypatch.py
src/_pytest/nodes.py
src/_pytest/nose.py
src/_pytest/outcomes.py
src/_pytest/pastebin.py
src/_pytest/pathlib.py
src/_pytest/pytester.py
src/_pytest/python.py
src/_pytest/python_api.py
src/_pytest/recwarn.py
src/_pytest/reports.py
src/_pytest/resultlog.py
src/_pytest/runner.py
src/_pytest/setuponly.py
src/_pytest/setupplan.py
src/_pytest/skipping.py
src/_pytest/stepwise.py
src/_pytest/store.py
src/_pytest/terminal.py
src/_pytest/timing.py
src/_pytest/tmpdir.py
src/_pytest/unittest.py
src/_pytest/warning_types.py
src/_pytest/warnings.py
src/pytest/__init__.py
src/pytest/__main__.py
src/pytest/collect.py
testing/acceptance_test.py
testing/code/test_code.py
testing/code/test_excinfo.py
testing/code/test_source.py
testing/conftest.py
testing/deprecated_test.py
testing/example_scripts/README.rst
testing/example_scripts/acceptance/fixture_mock_integration.py
testing/example_scripts/collect/collect_init_tests/pytest.ini
testing/example_scripts/collect/collect_init_tests/tests/__init__.py
testing/example_scripts/collect/collect_init_tests/tests/test_foo.py
testing/example_scripts/collect/package_infinite_recursion/__init__.pyi
testing/example_scripts/collect/package_infinite_recursion/conftest.py
testing/example_scripts/collect/package_infinite_recursion/tests/__init__.py
testing/example_scripts/collect/package_infinite_recursion/tests/test_basic.py
testing/example_scripts/collect/package_init_given_as_arg/pkg/__init__.py
testing/example_scripts/collect/package_init_given_as_arg/pkg/test_foo.py
testing/example_scripts/config/collect_pytest_prefix/__init__.pyi
testing/example_scripts/config/collect_pytest_prefix/conftest.py
testing/example_scripts/config/collect_pytest_prefix/test_foo.py
testing/example_scripts/conftest_usageerror/__init__.pyi
testing/example_scripts/conftest_usageerror/conftest.py
testing/example_scripts/dataclasses/test_compare_dataclasses.py
testing/example_scripts/dataclasses/test_compare_dataclasses_field_comparison_off.py
testing/example_scripts/dataclasses/test_compare_dataclasses_verbose.py
testing/example_scripts/dataclasses/test_compare_recursive_dataclasses.py
testing/example_scripts/dataclasses/test_compare_two_different_dataclasses.py
testing/example_scripts/fixtures/custom_item/__init__.pyi
testing/example_scripts/fixtures/custom_item/conftest.py
testing/example_scripts/fixtures/custom_item/foo/__init__.py
testing/example_scripts/fixtures/custom_item/foo/test_foo.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub1/__init__.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub1/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub1/test_in_sub1.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub2/__init__.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub2/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_conftest_funcargs_only_available_in_subdir/sub2/test_in_sub2.py
testing/example_scripts/fixtures/fill_fixtures/test_detect_recursive_dependency_error.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/__init__.pyi
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/pkg/__init__.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/pkg/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_conftest/pkg/test_spam.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_module/__init__.pyi
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_module/conftest.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_conftest_module/test_extend_fixture_conftest_module.py
testing/example_scripts/fixtures/fill_fixtures/test_extend_fixture_module_class.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_basic.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_lookup_classlevel.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_lookup_modulelevel.py
testing/example_scripts/fixtures/fill_fixtures/test_funcarg_lookupfails.py
testing/example_scripts/fixtures/test_fixture_named_request.py
testing/example_scripts/fixtures/test_getfixturevalue_dynamic.py
testing/example_scripts/issue88_initial_file_multinodes/__init__.pyi
testing/example_scripts/issue88_initial_file_multinodes/conftest.py
testing/example_scripts/issue88_initial_file_multinodes/test_hello.py
testing/example_scripts/issue_519.py
testing/example_scripts/junit-10.xsd
testing/example_scripts/marks/marks_considered_keywords/__init__.pyi
testing/example_scripts/marks/marks_considered_keywords/conftest.py
testing/example_scripts/marks/marks_considered_keywords/test_marks_as_keywords.py
testing/example_scripts/perf_examples/collect_stats/.gitignore
testing/example_scripts/perf_examples/collect_stats/generate_folders.py
testing/example_scripts/perf_examples/collect_stats/template_test.py
testing/example_scripts/pytest.ini
testing/example_scripts/tmpdir/tmpdir_fixture.py
testing/example_scripts/unittest/test_parametrized_fixture_error_message.py
testing/example_scripts/unittest/test_setup_skip.py
testing/example_scripts/unittest/test_setup_skip_class.py
testing/example_scripts/unittest/test_setup_skip_module.py
testing/example_scripts/unittest/test_unittest_asyncio.py
testing/example_scripts/unittest/test_unittest_asynctest.py
testing/example_scripts/warnings/test_group_warnings_by_message.py
testing/example_scripts/warnings/test_group_warnings_by_message_summary/test_1.py
testing/example_scripts/warnings/test_group_warnings_by_message_summary/test_2.py
testing/examples/test_issue519.py
testing/freeze/.gitignore
testing/freeze/create_executable.py
testing/freeze/runtests_script.py
testing/freeze/tests/test_doctest.txt
testing/freeze/tests/test_trivial.py
testing/freeze/tox_run.py
testing/io/test_saferepr.py
testing/io/test_terminalwriter.py
testing/io/test_wcwidth.py
testing/logging/test_fixture.py
testing/logging/test_formatter.py
testing/logging/test_reporting.py
testing/python/approx.py
testing/python/collect.py
testing/python/fixtures.py
testing/python/integration.py
testing/python/metafunc.py
testing/python/raises.py
testing/python/show_fixtures_per_test.py
testing/test_argcomplete.py
testing/test_assertion.py
testing/test_assertrewrite.py
testing/test_cacheprovider.py
testing/test_capture.py
testing/test_collection.py
testing/test_compat.py
testing/test_config.py
testing/test_conftest.py
testing/test_debugging.py
testing/test_doctest.py
testing/test_entry_points.py
testing/test_error_diffs.py
testing/test_faulthandler.py
testing/test_findpaths.py
testing/test_helpconfig.py
testing/test_junitxml.py
testing/test_link_resolve.py
testing/test_main.py
testing/test_mark.py
testing/test_mark_expression.py
testing/test_meta.py
testing/test_monkeypatch.py
testing/test_nodes.py
testing/test_nose.py
testing/test_parseopt.py
testing/test_pastebin.py
testing/test_pathlib.py
testing/test_pluginmanager.py
testing/test_pytester.py
testing/test_recwarn.py
testing/test_reports.py
testing/test_resultlog.py
testing/test_runner.py
testing/test_runner_xunit.py
testing/test_session.py
testing/test_setuponly.py
testing/test_setupplan.py
testing/test_skipping.py
testing/test_stepwise.py
testing/test_store.py
testing/test_terminal.py
testing/test_tmpdir.py
testing/test_unittest.py
testing/test_warning_types.py
testing/test_warnings.py
tox.ini
```


# The last commit

```
a0d8040ee SWE-bench



 .coveragerc                                                 |   0
 .gitattributes                                              |   0
 .gitblameignore                                             |   0
 .github/FUNDING.yml                                         |   0
 .github/ISSUE_TEMPLATE.md                                   |   0
 .github/PULL_REQUEST_TEMPLATE.md                            |   0
 .github/config.yml                                          |   0
 .github/labels.toml                                         |   0
 .github/workflows/main.yml                                  |   0
 .github/workflows/release-on-comment.yml                    |   0
 .gitignore                                                  |   0
 .pre-commit-config.yaml                                     |   0
 .travis.yml                                                 |   0
 AUTHORS                                                     |   0
 CHANGELOG.rst                                               |   0
 CITATION                                                    |   0
 CODE_OF_CONDUCT.md                                          |   0
 CONTRIBUTING.rst                                            |   0
 LICENSE                                                     |   0
 OPENCOLLECTIVE.rst                                          |   0
 README.rst                                                  |   0
 RELEASING.rst                                               |   0
 TIDELIFT.rst                                                |   0
 bench/bench.py                                              |   0
 bench/bench_argcomplete.py                                  |   0
 bench/empty.py                                              |   0
 bench/manyparam.py                                          |   0
 bench/skip.py                                               |   0
 changelog/1120.bugfix.rst                                   |   0
 changelog/1316.breaking.rst                                 |   0
 changelog/1556.feature.rst                                  |   0
 changelog/4049.feature.rst                                  |   0
 changelog/4375.improvement.rst                              |   0
 changelog/4391.improvement.rst                              |   0
 changelog/4583.bugfix.rst                                   |   0
 changelog/4675.improvement.rst                              |   0
 changelog/4677.bugfix.rst                                   |   0
 changelog/5456.bugfix.rst                                   |   0
 changelog/5965.breaking.rst                                 |   0
 changelog/6240.bugfix.rst                                   |   0
 changelog/6285.feature.rst                                  |   0
 changelog/6428.bugfix.rst                                   |   0
 changelog/6433.feature.rst                                  |   0
 changelog/6471.feature.rst                                  |   0
 changelog/6505.breaking.rst                                 |   0
 changelog/6755.bugfix.rst                                   |   0
 changelog/6817.improvement.rst                              |   0
 changelog/6856.feature.rst                                  |   0
 changelog/6871.bugfix.rst                                   |   0
 changelog/6903.breaking.rst                                 |   0
 changelog/6906.feature.rst                                  |   0
 changelog/6909.bugfix.rst                                   |   0
 changelog/6910.bugfix.rst                                   |   0
 changelog/6924.bugfix.rst                                   |   0
 changelog/6925.bugfix.rst                                   |   0
 changelog/6940.improvement.rst                              |   0
```

```diff
diff --git a/.coveragerc b/.coveragerc
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.gitblameignore b/.gitblameignore
old mode 100644
new mode 100755
diff --git a/.github/FUNDING.yml b/.github/FUNDING.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE.md b/.github/ISSUE_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/PULL_REQUEST_TEMPLATE.md b/.github/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/config.yml b/.github/config.yml
old mode 100644
new mode 100755
diff --git a/.github/labels.toml b/.github/labels.toml
old mode 100644
new mode 100755
diff --git a/.github/workflows/main.yml b/.github/workflows/main.yml
old mode 100644
new mode 100755
diff --git a/.github/workflows/release-on-comment.yml b/.github/workflows/release-on-comment.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.pre-commit-config.yaml b/.pre-commit-config.yaml
old mode 100644
new mode 100755
diff --git a/.travis.yml b/.travis.yml
old mode 100644
new mode 100755
diff --git a/AUTHORS b/AUTHORS
old mode 100644
new mode 100755
diff --git a/CHANGELOG.rst b/CHANGELOG.rst
old mode 100644
new mode 100755
diff --git a/CITATION b/CITATION
old mode 100644
new mode 100755
diff --git a/CODE_OF_CONDUCT.md b/CODE_OF_CONDUCT.md
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.rst b/CONTRIBUTING.rst
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/OPENCOLLECTIVE.rst b/OPENCOLLECTIVE.rst
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/RELEASING.rst b/RELEASING.rst
old mode 100644
new mode 100755
diff --git a/TIDELIFT.rst b/TIDELIFT.rst
old mode 100644
new mode 100755
diff --git a/bench/bench.py b/bench/bench.py
old mode 100644
new mode 100755
diff --git a/bench/bench_argcomplete.py b/bench/bench_argcomplete.py
old mode 100644
new mode 100755
diff --git a/bench/empty.py b/bench/empty.py
old mode 100644
new mode 100755
diff --git a/bench/manyparam.py b/bench/manyparam.py
old mode 100644
new mode 100755
diff --git a/bench/skip.py b/bench/skip.py
old mode 100644
new mode 100755
diff --git a/changelog/1120.bugfix.rst b/changelog/1120.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/1316.breaking.rst b/changelog/1316.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/1556.feature.rst b/changelog/1556.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/4049.feature.rst b/changelog/4049.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/4375.improvement.rst b/changelog/4375.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/4391.improvement.rst b/changelog/4391.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/4583.bugfix.rst b/changelog/4583.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/4675.improvement.rst b/changelog/4675.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/4677.bugfix.rst b/changelog/4677.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/5456.bugfix.rst b/changelog/5456.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/5965.breaking.rst b/changelog/5965.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/6240.bugfix.rst b/changelog/6240.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6285.feature.rst b/changelog/6285.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6428.bugfix.rst b/changelog/6428.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6433.feature.rst b/changelog/6433.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6471.feature.rst b/changelog/6471.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6505.breaking.rst b/changelog/6505.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/6755.bugfix.rst b/changelog/6755.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6817.improvement.rst b/changelog/6817.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/6856.feature.rst b/changelog/6856.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6871.bugfix.rst b/changelog/6871.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6903.breaking.rst b/changelog/6903.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/6906.feature.rst b/changelog/6906.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/6909.bugfix.rst b/changelog/6909.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6910.bugfix.rst b/changelog/6910.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6924.bugfix.rst b/changelog/6924.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6925.bugfix.rst b/changelog/6925.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6940.improvement.rst b/changelog/6940.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/6947.bugfix.rst b/changelog/6947.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6951.bugfix.rst b/changelog/6951.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6956.bugfix.rst b/changelog/6956.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6981.deprecation.rst b/changelog/6981.deprecation.rst
old mode 100644
new mode 100755
diff --git a/changelog/6991.bugfix.rst b/changelog/6991.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/6991.improvement.rst b/changelog/6991.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/6992.bugfix.rst b/changelog/6992.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7035.trivial.rst b/changelog/7035.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7040.breaking.rst b/changelog/7040.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7061.bugfix.rst b/changelog/7061.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7076.bugfix.rst b/changelog/7076.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7091.improvement.rst b/changelog/7091.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7097.deprecation.rst b/changelog/7097.deprecation.rst
old mode 100644
new mode 100755
diff --git a/changelog/7110.bugfix.rst b/changelog/7110.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7119.improvement.rst b/changelog/7119.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7122.breaking.rst b/changelog/7122.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7126.bugfix.rst b/changelog/7126.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7128.improvement.rst b/changelog/7128.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7133.improvement.rst b/changelog/7133.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7135.breaking.rst b/changelog/7135.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7143.bugfix.rst b/changelog/7143.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7145.bugfix.rst b/changelog/7145.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7150.bugfix.rst b/changelog/7150.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7180.bugfix.rst b/changelog/7180.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7202.doc.rst b/changelog/7202.doc.rst
old mode 100644
new mode 100755
diff --git a/changelog/7210.deprecation.rst b/changelog/7210.deprecation.rst
old mode 100644
new mode 100755
diff --git a/changelog/7215.bugfix.rst b/changelog/7215.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7224.breaking.rst b/changelog/7224.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7226.breaking.rst b/changelog/7226.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/7233.doc.rst b/changelog/7233.doc.rst
old mode 100644
new mode 100755
diff --git a/changelog/7245.feature.rst b/changelog/7245.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/7253.bugfix.rst b/changelog/7253.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7264.improvement.rst b/changelog/7264.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7291.trivial.rst b/changelog/7291.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7295.trivial.rst b/changelog/7295.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7305.feature.rst b/changelog/7305.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/7345.doc.rst b/changelog/7345.doc.rst
old mode 100644
new mode 100755
diff --git a/changelog/7346.feature.rst b/changelog/7346.feature.rst
old mode 100644
new mode 100755
diff --git a/changelog/7356.trivial.rst b/changelog/7356.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7357.trivial.rst b/changelog/7357.trivial.rst
old mode 100644
new mode 100755
diff --git a/changelog/7360.bugfix.rst b/changelog/7360.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7383.bugfix.rst b/changelog/7383.bugfix.rst
old mode 100644
new mode 100755
diff --git a/changelog/7385.improvement.rst b/changelog/7385.improvement.rst
old mode 100644
new mode 100755
diff --git a/changelog/7418.breaking.rst b/changelog/7418.breaking.rst
old mode 100644
new mode 100755
diff --git a/changelog/README.rst b/changelog/README.rst
old mode 100644
new mode 100755
diff --git a/changelog/_template.rst b/changelog/_template.rst
old mode 100644
new mode 100755
diff --git a/codecov.yml b/codecov.yml
old mode 100644
new mode 100755
diff --git a/doc/en/Makefile b/doc/en/Makefile
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/globaltoc.html b/doc/en/_templates/globaltoc.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/links.html b/doc/en/_templates/links.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/relations.html b/doc/en/_templates/relations.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/sidebarintro.html b/doc/en/_templates/sidebarintro.html
old mode 100644
new mode 100755
diff --git a/doc/en/_templates/slim_searchbox.html b/doc/en/_templates/slim_searchbox.html
old mode 100644
new mode 100755
diff --git a/doc/en/adopt.rst b/doc/en/adopt.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/index.rst b/doc/en/announce/index.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.0.rst b/doc/en/announce/release-2.0.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.1.rst b/doc/en/announce/release-2.0.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.2.rst b/doc/en/announce/release-2.0.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.0.3.rst b/doc/en/announce/release-2.0.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.0.rst b/doc/en/announce/release-2.1.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.1.rst b/doc/en/announce/release-2.1.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.2.rst b/doc/en/announce/release-2.1.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.1.3.rst b/doc/en/announce/release-2.1.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.0.rst b/doc/en/announce/release-2.2.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.1.rst b/doc/en/announce/release-2.2.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.2.rst b/doc/en/announce/release-2.2.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.2.4.rst b/doc/en/announce/release-2.2.4.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.0.rst b/doc/en/announce/release-2.3.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.1.rst b/doc/en/announce/release-2.3.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.2.rst b/doc/en/announce/release-2.3.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.3.rst b/doc/en/announce/release-2.3.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.4.rst b/doc/en/announce/release-2.3.4.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.3.5.rst b/doc/en/announce/release-2.3.5.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.4.0.rst b/doc/en/announce/release-2.4.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.4.1.rst b/doc/en/announce/release-2.4.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.4.2.rst b/doc/en/announce/release-2.4.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.5.0.rst b/doc/en/announce/release-2.5.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.5.1.rst b/doc/en/announce/release-2.5.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.5.2.rst b/doc/en/announce/release-2.5.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.0.rst b/doc/en/announce/release-2.6.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.1.rst b/doc/en/announce/release-2.6.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.2.rst b/doc/en/announce/release-2.6.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.6.3.rst b/doc/en/announce/release-2.6.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.7.0.rst b/doc/en/announce/release-2.7.0.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.7.1.rst b/doc/en/announce/release-2.7.1.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.7.2.rst b/doc/en/announce/release-2.7.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.2.rst b/doc/en/announce/release-2.8.2.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.3.rst b/doc/en/announce/release-2.8.3.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.4.rst b/doc/en/announce/release-2.8.4.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.5.rst b/doc/en/announce/release-2.8.5.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.6.rst b/doc/en/announce/release-2.8.6.rst
old mode 100644
new mode 100755
diff --git a/doc/en/announce/release-2.8.7.rst b/doc/en/announce/release-2.8.7.rst
old mode 100644
new mode 100755
diff --git a/doc
```


# pyproject.toml (the start)

```
[build-system]
requires = [
  # sync with setup.py until we discard non-pep-517/518
  "setuptools>=40.0",
  "setuptools-scm",
  "wheel",
]
build-backend = "setuptools.build_meta"

[tool.pytest.ini_options]
minversion = "2.0"
addopts = "-rfEX -p pytester --strict-markers"
python_files = ["test_*.py", "*_test.py", "testing/*/*.py"]
python_classes = ["Test", "Acceptance"]
python_functions = ["test"]
# NOTE: "doc" is not included here, but gets tested explicitly via "doctesting".
testpaths = ["testing"]
norecursedirs = ["testing/example_scripts"]
xfail_strict = true
filterwarnings = [
    "error",
    "default:Using or importing the ABCs:DeprecationWarning:unittest2.*",
    "default:the imp module is deprecated in favour of importlib:DeprecationWarning:nose.*",
    "ignore:Module already imported so cannot be rewritten:pytest.PytestWarning",
    # produced by python3.6/site.py itself (3.6.7 on Travis, could not trigger it with 3.6.8)."
    "ignore:.*U.*mode is deprecated:DeprecationWarning:(?!(pytest|_pytest))",
    # produced by pytest-xdist
    "ignore:.*type argument to addoption.*:DeprecationWarning",
    # produced by python >=3.5 on execnet (pytest-xdist)
    "ignore:.*inspect.getargspec.*deprecated, use inspect.signature.*:DeprecationWarning",
    # pytest's own futurewarnings
    "ignore::pytest.PytestExperimentalApiWarning",
    # Do not cause SyntaxError for invalid escape sequences in py37.
    # Those are caught/handled by pyupgrade, and not easy to filter with the
    # module being the filename (with .py removed).
    "default:invalid escape sequence:DeprecationWarning",
    # ignore use of unregistered marks, because we use many to test the implementation
    "ignore::_pytest.warning_types.PytestUnknownMarkWarning",
]
pytester_example_dir = "testing/example_scripts"
markers = [
    # dummy markers for testing
    "foo",
    "bar",
    "baz",
    # conftest.py reorders tests moving slow ones to the end of the list
    "slow",
    # experimental mark for all tests using pexpect
    "uses_pexpect",
]


[tool.towncrier]
package = "pytest"
package_dir = "src"
filename = "doc/en/changelog.rst"
directory = "changelog/"
title_format = "pytest {version} ({project_date})"
template = "changelog/_template.rst"

  [[tool.towncrier.type]]
  directory = "breaking"
  name = "Breaking Changes"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "deprecation"
  name = "Deprecations"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "feature"
  name = "Features"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "improvement"
  name = "Improvements"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "bugfix"
  name = "Bug Fixes"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "vendor"
  name = "Vendored Libraries"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "doc"
  name = "Improved Documentation"
  showcontent = true

  [[tool.towncrier.type]]
  directory = "trivial"
  name = "Trivial/Internal Changes"
  showcontent = true

[tool.black]
target-version = ['py35']

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest testing/test_skipping.py`

## Scope
`src/_pytest/skipping.py`
`testing/test_skipping.py`
`changelog/`

## Done when
- With `pytest -rs --runxfail`, a test decorated with `@pytest.mark.skip` is reported at the test item's own file and line, not at `src/_pytest/skipping.py`.
- The same location reporting holds for `@pytest.mark.skipif`.
- Without `--runxfail`, the reported skip location is unchanged.
- `--runxfail` still affects only xfail: xfail-marked tests continue to run and report normally under it.
- The existing skipping tests pass.

## Approach
Single, localized change in `src/_pytest/skipping.py::pytest_runtest_makereport`. The `--runxfail` branch currently short-circuits the hook before the code that rewrites a skip report's `longrepr` to the item's location; make the xfail bypass apply only to xfail processing while the skip-location bookkeeping always runs. Decomposition: (1) reproduce with a one-test module under both `-rs` and `-rs --runxfail` to confirm the differing `longrepr`; (2) read the `if/elif` chain in `pytest_runtest_makereport` and trace which branch handles the skipped report; (3) restructure so skip reports get `(item.location[0], item.location[1], reason)` regardless of `runxfail`; (4) add a regression test in `testing/test_skipping.py` asserting the reported location with `--runxfail`, plus a skipif case; (5) run the skipping test module.

Candidate approaches:
1. Move the skip-location fixup ahead of the `if/elif` chain so it is never gated by `runxfail` — smallest diff, but must ensure it doesn't also fire for xfail-produced skips.
2. Narrow the `runxfail` branch (e.g. only `pass` when the report is not a skip, or combine it with the xfail-exception check) so skipped reports fall through to the existing fixup — preserves the current control flow, but the condition must be checked against xfail/xpass cases.
3. Replace the branch with explicit handling: an independent `if rep.skipped and ...` block after the chain that sets `longrepr` from `item.location` whenever the skip came from a `skip`/`skipif` mark — most robust and easiest to reason about, but duplicates a little logic.

Preferred: approach 2 or 3, because they keep xfail semantics intact and make the skip-location rewrite unconditional with respect to `--runxfail`.
```

### `prompt.md`

````
skipping: --runxfail breaks pytest.mark.skip location reporting
pytest versions: 5.4.x, current master

When `@pytest.mark.skip`/`skipif` marks are used to skip a test, for example

```py
import pytest
@pytest.mark.skip
def test_skip_location() -> None:
    assert 0
```

the expected skip location reported should point to the item itself, and this is indeed what happens when running with `pytest -rs`:

```
SKIPPED [1] test_it.py:3: unconditional skip
```

However, adding `pytest -rs --runxfail` breaks this:

```
SKIPPED [1] src/_pytest/skipping.py:238: unconditional skip
```

The `--runxfail` is only about xfail and should not affect this at all.

---

Hint: the bug is in `src/_pytest/skipping.py`, the `pytest_runtest_makereport` hook.
````

### `review.md`

```
verdict: PASS

The fix moves the `skipped_by_mark_key` / tuple-`longrepr` relocation branch ahead of the `runxfail` short-circuit in `pytest_runtest_makereport`, so `--runxfail` no longer suppresses the relocation of the skip location to the test item. The branches are mutually exclusive (`rep.skipped` vs `not rep.skipped`, and `xfail.Exception` vs a skip tuple), so reordering does not alter xfail behaviour, and the location for non-`--runxfail` runs is unchanged.

- `src/_pytest/skipping.py`: the 12 removed lines are the same block relocated, not deleted; no unrelated behaviour changed.
- `testing/test_skipping.py`: adds a regression test for `@pytest.mark.skip` with `-rs --runxfail`, asserting the item's own file/line.
- Check status 0: all 78 tests in `testing/test_skipping.py` pass, including the new one.
- The fix is generic to the tuple longrepr produced by both `skip` and `skipif`, so the skipif requirement is covered even though no dedicated skipif test was added.
- No changelog entry was added; the prompt did not ask for one, so this is a note only, not a failure.
```

### `scope.txt`

```
scope: src/_pytest/skipping.py testing/test_skipping.py changelog
changed: src/_pytest/skipping.py +12 -12
changed: testing/test_skipping.py +16 -0
```

### `task.md`

````
# Task

## Prompt

skipping: --runxfail breaks pytest.mark.skip location reporting
pytest versions: 5.4.x, current master

When `@pytest.mark.skip`/`skipif` marks are used to skip a test, for example

```py
import pytest
@pytest.mark.skip
def test_skip_location() -> None:
    assert 0
```

the expected skip location reported should point to the item itself, and this is indeed what happens when running with `pytest -rs`:

```
SKIPPED [1] test_it.py:3: unconditional skip
```

However, adding `pytest -rs --runxfail` breaks this:

```
SKIPPED [1] src/_pytest/skipping.py:238: unconditional skip
```

The `--runxfail` is only about xfail and should not affect this at all.

---

Hint: the bug is in `src/_pytest/skipping.py`, the `pytest_runtest_makereport` hook.

## Deliverable

changes to this tree

## Check

`python -m pytest testing/test_skipping.py`

## Scope

`src/_pytest/skipping.py`
`testing/test_skipping.py`
`changelog/`

## Done when

- With `pytest -rs --runxfail`, a test decorated with `@pytest.mark.skip` is reported at the test item's own file and line, not at `src/_pytest/skipping.py`.
- The same location reporting holds for `@pytest.mark.skipif`.
- Without `--runxfail`, the reported skip location is unchanged.
- `--runxfail` still affects only xfail: xfail-marked tests continue to run and report normally under it.
- The existing skipping tests pass.
````

### `test-output.log`

```
check: python -m pytest testing/test_skipping.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-5.4.1.dev593+ge6e300e72.d20260815, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: pyproject.toml
collected 78 items

testing/test_skipping.py ............................................... [ 60%]
...............................                                          [100%]

============================== 78 passed in 7.75s ==============================
scope: src/_pytest/skipping.py testing/test_skipping.py changelog
changed: src/_pytest/skipping.py +12 -12
changed: testing/test_skipping.py +16 -0
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
