# pytest-dev__pytest-7982 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 211s 53 lines cost=0.003587 in=111166 cached=71168 out=6056 calls=15`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Symlinked directories not collected since pytest 6.1.0
When there is a symlink to a directory in a test directory, is is just skipped over, but it should be followed and collected as usual.

This regressed in b473e515bc57ff1133fe650f1e7e6d7e22e5d841 (included in 6.1.0). For some reason I added a `follow_symlinks=False` in there, I don't remember why, but it does not match the previous behavior and should be removed.

PR for this is coming up.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --short && ls"
}
```

**tool result**

```
/testbed
?? .memdoor/
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
bench
changelog
codecov.yml
doc
extra
pyproject.toml
scripts
setup.cfg
setup.py
src
testing
tox.ini
```

**assistant → tool `grep`**

```json
{
  "pattern": "follow_symlinks",
  "path": "src",
  "output_mode": "content",
  "head_limit": 100
}
```

**tool result**

```
/testbed/src/_pytest/pathlib.py:        if entry.is_dir(follow_symlinks=False) and recurse(entry):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '580,680p' src/_pytest/pathlib.py"
}
```

**tool result**

```
    try:
        return Path(os.path.commonpath((str(path1), str(path2))))
    except ValueError:
        return None


def bestrelpath(directory: Path, dest: Path) -> str:
    """Return a string which is a relative path from directory to dest such
    that directory/bestrelpath == dest.

    The paths must be either both absolute or both relative.

    If no such path can be determined, returns dest.
    """
    if dest == directory:
        return os.curdir
    # Find the longest common directory.
    base = commonpath(directory, dest)
    # Can be the case on Windows for two absolute paths on different drives.
    # Can be the case for two relative paths without common prefix.
    # Can be the case for a relative path and an absolute path.
    if not base:
        return str(dest)
    reldirectory = directory.relative_to(base)
    reldest = dest.relative_to(base)
    return os.path.join(
        # Back from directory to base.
        *([os.pardir] * len(reldirectory.parts)),
        # Forward from base to dest.
        *reldest.parts,
    )
```

**assistant → tool `grep`**

```json
{
  "pattern": "def visit|is_dir\\(follow_symlinks|def _collectfile",
  "path": "src/_pytest/pathlib.py",
  "output_mode": "content",
  "head_limit": 50
}
```

**tool result**

```
/testbed/src/_pytest/pathlib.py:def visit(
/testbed/src/_pytest/pathlib.py:        if entry.is_dir(follow_symlinks=False) and recurse(entry):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def visit\" src/_pytest/pathlib.py && sed -n '290,360p' src/_pytest/pathlib.py"
}
```

**tool result**

```
551:def visit(
    try:
        lock_time = lock.stat().st_mtime
    except Exception:
        return False
    else:
        if lock_time < consider_lock_dead_if_created_before:
            # We want to ignore any errors while trying to remove the lock such as:
            # - PermissionDenied, like the file permissions have changed since the lock creation;
            # - FileNotFoundError, in case another pytest process got here first;
            # and any other cause of failure.
            with contextlib.suppress(OSError):
                lock.unlink()
                return True
        return False


def try_cleanup(path: Path, consider_lock_dead_if_created_before: float) -> None:
    """Try to cleanup a folder if we can ensure it's deletable."""
    if ensure_deletable(path, consider_lock_dead_if_created_before):
        maybe_delete_a_numbered_dir(path)


def cleanup_candidates(root: Path, prefix: str, keep: int) -> Iterator[Path]:
    """List candidates for numbered directories to be removed - follows py.path."""
    max_existing = max(map(parse_num, find_suffixes(root, prefix)), default=-1)
    max_delete = max_existing - keep
    paths = find_prefixed(root, prefix)
    paths, paths2 = itertools.tee(paths)
    numbers = map(parse_num, extract_suffixes(paths2, prefix))
    for path, number in zip(paths, numbers):
        if number <= max_delete:
            yield path


def cleanup_numbered_dir(
    root: Path, prefix: str, keep: int, consider_lock_dead_if_created_before: float
) -> None:
    """Cleanup for lock driven numbered directories."""
    for path in cleanup_candidates(root, prefix, keep):
        try_cleanup(path, consider_lock_dead_if_created_before)
    for path in root.glob("garbage-*"):
        try_cleanup(path, consider_lock_dead_if_created_before)


def make_numbered_dir_with_cleanup(
    root: Path, prefix: str, keep: int, lock_timeout: float
) -> Path:
    """Create a numbered dir with a cleanup lock and remove old ones."""
    e = None
    for i in range(10):
        try:
            p = make_numbered_dir(root, prefix)
            lock_path = create_cleanup_lock(p)
            register_cleanup_lock_removal(lock_path)
        except Exception as exc:
            e = exc
        else:
            consider_lock_dead_if_created_before = p.stat().st_mtime - lock_timeout
            # Register a cleanup for program exit
            atexit.register(
                cleanup_numbered_dir,
                root,
                prefix,
                keep,
                consider_lock_dead_if_created_before,
            )
            return p
    assert e is not None
    raise e
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '540,570p' src/_pytest/pathlib.py"
}
```

**tool result**

```
    result = None
    for parent in itertools.chain((path,), path.parents):
        if parent.is_dir():
            if not parent.joinpath("__init__.py").is_file():
                break
            if not parent.name.isidentifier():
                break
            result = parent
    return result


def visit(
    path: str, recurse: Callable[["os.DirEntry[str]"], bool]
) -> Iterator["os.DirEntry[str]"]:
    """Walk a directory recursively, in breadth-first order.

    Entries at each directory level are sorted.
    """
    entries = sorted(os.scandir(path), key=lambda entry: entry.name)
    yield from entries
    for entry in entries:
        if entry.is_dir(follow_symlinks=False) and recurse(entry):
            yield from visit(entry.path, recurse)


def absolutepath(path: Union[Path, str]) -> Path:
    """Convert a path to an absolute path using os.path.abspath.

    Prefer this over Path.resolve() (see #6523).
    Prefer this over Path.absolute() (not public, doesn't normalize).
    """
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"symlink\\|visit(\" testing/test_pathlib.py testing/test_collection.py | head -80; grep -n \"pathlib\" -A80 testing/test_pathlib.py | tail -100"
}
```

**tool result**

```
testing/test_collection.py:11:from _pytest.pathlib import symlink_or_skip
testing/test_collection.py:1137:def test_collect_symlink_file_arg(testdir):
testing/test_collection.py:1138:    """Collect a direct symlink works even if it does not match python_files (#4325)."""
testing/test_collection.py:1142:            assert request.node.nodeid == "symlink.py::test_nodeid"
testing/test_collection.py:1145:    symlink = testdir.tmpdir.join("symlink.py")
testing/test_collection.py:1146:    symlink_or_skip(real, symlink)
testing/test_collection.py:1147:    result = testdir.runpytest("-v", symlink)
testing/test_collection.py:1148:    result.stdout.fnmatch_lines(["symlink.py::test_nodeid PASSED*", "*1 passed in*"])
testing/test_collection.py:1152:def test_collect_symlink_out_of_tree(testdir):
testing/test_collection.py:1153:    """Test collection of symlink via out-of-tree rootdir."""
testing/test_collection.py:1168:    symlink_to_sub = out_of_tree.join("symlink_to_sub")
testing/test_collection.py:1169:    symlink_or_skip(sub, symlink_to_sub)
testing/test_collection.py:1171:    result = testdir.runpytest("-vs", "--rootdir=%s" % sub, symlink_to_sub)
testing/test_collection.py:1236:def test_collect_sub_with_symlinks(use_pkg, testdir):
testing/test_collection.py:1237:    """Collection works with symlinked files and broken symlinks"""
testing/test_collection.py:1243:    # Create a broken symlink.
testing/test_collection.py:1244:    symlink_or_skip("test_doesnotexist.py", sub.join("test_broken.py"))
testing/test_collection.py:1247:    symlink_or_skip("test_file.py", sub.join("test_symlink.py"))
testing/test_collection.py:1253:            "sub/test_symlink.py::test_file PASSED*",
15:from _pytest.pathlib import get_lock_path
16:from _pytest.pathlib import import_path
17:from _pytest.pathlib import ImportPathMismatchError
18:from _pytest.pathlib import maybe_delete_a_numbered_dir
19:from _pytest.pathlib import resolve_package_path
20-
21-
22-class TestFNMatcherPort:
23-    """Test that our port of py.common.FNMatcher (fnmatch_ex) produces the
24-    same results as the original py.path.local.fnmatch method."""
25-
26:    @pytest.fixture(params=["pathlib", "py.path"])
27-    def match(self, request):
28-        if request.param == "py.path":
29-
30-            def match_(pattern, path):
31-                return py.path.local(path).fnmatch(pattern)
32-
33-        else:
34:            assert request.param == "pathlib"
35-
36-            def match_(pattern, path):
37-                return fnmatch_ex(pattern, path)
38-
39-        return match_
40-
41-    if sys.platform == "win32":
42-        drv1 = "c:"
43-        drv2 = "d:"
44-    else:
45-        drv1 = "/c"
46-        drv2 = "/d"
47-
48-    @pytest.mark.parametrize(
49-        "pattern, path",
50-        [
51-            ("*.py", "foo.py"),
52-            ("*.py", "bar/foo.py"),
53-            ("test_*.py", "foo/test_foo.py"),
54-            ("tests/*.py", "tests/foo.py"),
55-            (drv1 + "/*.py", drv1 + "/foo.py"),
56-            (drv1 + "/foo/*.py", drv1 + "/foo/foo.py"),
57-            ("tests/**/test*.py", "tests/foo/test_foo.py"),
58-            ("tests/**/doc/test*.py", "tests/foo/bar/doc/test_foo.py"),
59-            ("tests/**/doc/**/test*.py", "tests/foo/doc/bar/test_foo.py"),
60-        ],
61-    )
62-    def test_matching(self, match, pattern, path):
63-        assert match(pattern, path)
64-
65-    def test_matching_abspath(self, match):
66-        abspath = os.path.abspath(os.path.join("tests/foo.py"))
67-        assert match("tests/foo.py", abspath)
68-
69-    @pytest.mark.parametrize(
70-        "pattern, path",
71-        [
72-            ("*.py", "foo.pyc"),
73-            ("*.py", "foo/foo.pyc"),
74-            ("tests/*.py", "foo/foo.py"),
75-            (drv1 + "/*.py", drv2 + "/foo.py"),
76-            (drv1 + "/foo/*.py", drv2 + "/foo/foo.py"),
77-            ("tests/**/test*.py", "tests/foo.py"),
78-            ("tests/**/test*.py", "foo/test_foo.py"),
79-            ("tests/**/doc/test*.py", "tests/foo/bar/doc/foo.py"),
80-            ("tests/**/doc/test*.py", "tests/foo/bar/test_foo.py"),
81-        ],
82-    )
83-    def test_not_matching(self, match, pattern, path):
84-        assert not match(pattern, path)
85-
86-
87-class TestImportPath:
88-    """
89-
90-    Most of the tests here were copied from py lib's tests for "py.local.path.pyimport".
91-
92-    Having our own pyimport-like function is inline with removing py.path dependency in the future.
93-    """
94-
95-    @pytest.fixture(scope="session")
96-    def path1(self, tmpdir_factory):
97-        path = tmpdir_factory.mktemp("path")
98-        self.setuptestfs(path)
99-        yield path
100-        assert path.join("samplefile").check()
101-
102-    def setuptestfs(self, path):
103-        # print "setting up test fs for", repr(path)
104-        samplefile = path.ensure("samplefile")
105-        samplefile.write("samplefile\n")
106-
107-        execfile = path.ensure("execfile")
108-        execfile.write("x=42")
109-
110-        execfilepy = path.ensure("execfile.py")
111-        execfilepy.write("x=42")
112-
113-        d = {1: 2, "hello": "world", "answer": 42}
114-        path.ensure("samplepickle").dump(d)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1130,1270p' testing/test_collection.py; ls changelog | head"
}
```

**tool result**

```
    )
    monkeypatch.setenv("PYTHONPATH", str(testdir.tmpdir), prepend=os.pathsep)
    with root.as_cwd():
        result = testdir.runpytest_subprocess()
    result.stdout.fnmatch_lines(["*1 passed in*"])


def test_collect_symlink_file_arg(testdir):
    """Collect a direct symlink works even if it does not match python_files (#4325)."""
    real = testdir.makepyfile(
        real="""
        def test_nodeid(request):
            assert request.node.nodeid == "symlink.py::test_nodeid"
        """
    )
    symlink = testdir.tmpdir.join("symlink.py")
    symlink_or_skip(real, symlink)
    result = testdir.runpytest("-v", symlink)
    result.stdout.fnmatch_lines(["symlink.py::test_nodeid PASSED*", "*1 passed in*"])
    assert result.ret == 0


def test_collect_symlink_out_of_tree(testdir):
    """Test collection of symlink via out-of-tree rootdir."""
    sub = testdir.tmpdir.join("sub")
    real = sub.join("test_real.py")
    real.write(
        textwrap.dedent(
            """
        def test_nodeid(request):
            # Should not contain sub/ prefix.
            assert request.node.nodeid == "test_real.py::test_nodeid"
        """
        ),
        ensure=True,
    )

    out_of_tree = testdir.tmpdir.join("out_of_tree").ensure(dir=True)
    symlink_to_sub = out_of_tree.join("symlink_to_sub")
    symlink_or_skip(sub, symlink_to_sub)
    sub.chdir()
    result = testdir.runpytest("-vs", "--rootdir=%s" % sub, symlink_to_sub)
    result.stdout.fnmatch_lines(
        [
            # Should not contain "sub/"!
            "test_real.py::test_nodeid PASSED"
        ]
    )
    assert result.ret == 0


def test_collectignore_via_conftest(testdir):
    """collect_ignore in parent conftest skips importing child (issue #4592)."""
    tests = testdir.mkpydir("tests")
    tests.ensure("conftest.py").write("collect_ignore = ['ignore_me']")

    ignore_me = tests.mkdir("ignore_me")
    ignore_me.ensure("__init__.py")
    ignore_me.ensure("conftest.py").write("assert 0, 'should_not_be_called'")

    result = testdir.runpytest()
    assert result.ret == ExitCode.NO_TESTS_COLLECTED


def test_collect_pkg_init_and_file_in_args(testdir):
    subdir = testdir.mkdir("sub")
    init = subdir.ensure("__init__.py")
    init.write("def test_init(): pass")
    p = subdir.ensure("test_file.py")
    p.write("def test_file(): pass")

    # NOTE: without "-o python_files=*.py" this collects test_file.py twice.
    # This changed/broke with "Add package scoped fixtures #2283" (2b1410895)
    # initially (causing a RecursionError).
    result = testdir.runpytest("-v", str(init), str(p))
    result.stdout.fnmatch_lines(
        [
            "sub/test_file.py::test_file PASSED*",
            "sub/test_file.py::test_file PASSED*",
            "*2 passed in*",
        ]
    )

    result = testdir.runpytest("-v", "-o", "python_files=*.py", str(init), str(p))
    result.stdout.fnmatch_lines(
        [
            "sub/__init__.py::test_init PASSED*",
            "sub/test_file.py::test_file PASSED*",
            "*2 passed in*",
        ]
    )


def test_collect_pkg_init_only(testdir):
    subdir = testdir.mkdir("sub")
    init = subdir.ensure("__init__.py")
    init.write("def test_init(): pass")

    result = testdir.runpytest(str(init))
    result.stdout.fnmatch_lines(["*no tests ran in*"])

    result = testdir.runpytest("-v", "-o", "python_files=*.py", str(init))
    result.stdout.fnmatch_lines(["sub/__init__.py::test_init PASSED*", "*1 passed in*"])


@pytest.mark.parametrize("use_pkg", (True, False))
def test_collect_sub_with_symlinks(use_pkg, testdir):
    """Collection works with symlinked files and broken symlinks"""
    sub = testdir.mkdir("sub")
    if use_pkg:
        sub.ensure("__init__.py")
    sub.join("test_file.py").write("def test_file(): pass")

    # Create a broken symlink.
    symlink_or_skip("test_doesnotexist.py", sub.join("test_broken.py"))

    # Symlink that gets collected.
    symlink_or_skip("test_file.py", sub.join("test_symlink.py"))

    result = testdir.runpytest("-v", str(sub))
    result.stdout.fnmatch_lines(
        [
            "sub/test_file.py::test_file PASSED*",
            "sub/test_symlink.py::test_file PASSED*",
            "*2 passed in*",
        ]
    )


def test_collector_respects_tbstyle(testdir):
    p1 = testdir.makepyfile("assert 0")
    result = testdir.runpytest(p1, "--tb=native")
    assert result.ret == ExitCode.INTERRUPTED
    result.stdout.fnmatch_lines(
        [
            "*_ ERROR collecting test_collector_respects_tbstyle.py _*",
            "Traceback (most recent call last):",
            '  File "*/test_collector_respects_tbstyle.py", line 1, in <module>',
            "    assert 0",
            "AssertionError: assert 0",
            "*! Interrupted: 1 error during collection !*",
4824.bugfix.rst
7425.feature.rst
7710.improvement.rst
7758.bugfix.rst
7780.doc.rst
7802.trivial.rst
7808.breaking.rst
7872.doc.rst
7878.doc.rst
7911.bugfix.rst
```

**assistant → tool `bash`**

```json
{
  "command": "git log -3 --oneline; grep -rn \"follow_symlinks\" doc testing src | head -30; ls changelog | sort -n | tail"
}
```

**tool result**

```
0ca93ffdc SWE-bench
a7e38c5c6 pytest-dev#7942 test_runner_xunit.py (#7964)
3c7eb5a39 migrated test_nodes.py from testdir to pytester #7492. (#7969)
src/_pytest/pathlib.py:561:        if entry.is_dir(follow_symlinks=False) and recurse(entry):
7710.improvement.rst
7758.bugfix.rst
7780.doc.rst
7802.trivial.rst
7808.breaking.rst
7872.doc.rst
7878.doc.rst
7911.bugfix.rst
7913.bugfix.rst
7938.improvement.rst
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/src/_pytest/pathlib.py\n@@\n-        if entry.is_dir(follow_symlinks=False) and recurse(entry):\n+        if entry.is_dir() and recurse(entry):\n             yield from visit(entry.path, recurse)\n*** Add File: /testbed/changelog/7950.bugfix.rst\n+Fixed regression where symlinked directories were not collected anymore.\n*** Update File: /testbed/testing/test_collection.py\n@@\n def test_collect_symlink_out_of_tree(testdir):\n@@\n     assert result.ret == 0\n \n \n+def test_collect_symlink_directory(testdir):\n+    \"\"\"Directories which are symlinks are collected (regression #7950).\"\"\"\n+    real = testdir.mkdir(\"real\")\n+    real.join(\"test_real.py\").write(\n+        textwrap.dedent(\n+            \"\"\"\n+            def test_nodeid(request):\n+                assert request.node.nodeid == \"tests/symlink/test_real.py::test_nodeid\"\n+            \"\"\"\n+        )\n+    )\n+\n+    tests = testdir.mkdir(\"tests\")\n+    symlink_or_skip(real, tests.join(\"symlink\"))\n+\n+    result = testdir.runpytest(\"-v\", str(tests))\n+    result.stdout.fnmatch_lines(\n+        [\"tests/symlink/test_real.py::test_nodeid PASSED*\", \"*1 passed in*\"]\n+    )\n+    assert result.ret == 0\n+\n+\n def test_collectignore_via_conftest(testdir):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[/testbed/changelog/7950.bugfix.rst] modified=[/testbed/src/_pytest/pathlib.py /testbed/testing/test_collection.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/src/_pytest/pathlib.py now (610 lines), around the change:
558:    entries = sorted(os.scandir(path), key=lambda entry: entry.name)
559:    yield from entries
560:    for entry in entries:
561:        if entry.is_dir() and recurse(entry):
562:            yield from visit(entry.path, recurse)
563:
564:

/testbed/testing/test_collection.py now (1428 lines), around the change:
1178:    assert result.ret == 0
1179:
1180:
1181:def test_collect_symlink_directory(testdir):
1182:    """Directories which are symlinks are collected (regression #7950)."""
1183:    real = testdir.mkdir("real")
1184:    real.join("test_real.py").write(
1185:        textwrap.dedent(
1186:            """
1187:            def test_nodeid(request):
1188:                assert request.node.nodeid == "tests/symlink/test_real.py::test_nodeid"
1189:            """
1190:        )
1191:    )
1192:
1193:    tests = testdir.mkdir("tests")
1194:    symlink_or_skip(real, tests.join("symlink"))
1195:
1196:    result = testdir.runpytest("-v", str(tests))
1197:    result.stdout.fnmatch_lines(
1198:        ["tests/symlink/test_real.py::test_nodeid PASSED*", "*1 passed in*"]
1199:    )
1200:    assert result.ret == 0
1201:
1202:
1203:def test_collectignore_via_conftest(testdir):
1204:    """collect_ignore in parent conftest skips importing child (issue #4592)."""
1205:    tests = testdir.mkpydir("tests")
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest testing/test_collection.py::test_collect_symlink_directory testing/test_collection.py::test_collect_sub_with_symlinks testing/test_pathlib.py -q 2>&1 | tail -30"
}
```

**tool result**

```
.................................................................        [100%]
65 passed in 4.96s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest testing/test_collection.py -q 2>&1 | tail -15"
}
```

**tool result**

```
.............................x.......................................... [ 90%]
........                                                                 [100%]
79 passed, 1 xfailed in 19.93s
```

**assistant**

```
Implemented the fix.

**Change:** In `src/_pytest/pathlib.py`, `visit()` now follows directory symlinks during recursive collection by using `entry.is_dir()` instead of `entry.is_dir(follow_symlinks=False)`.

**Tests:** Added `test_collect_symlink_directory` in `testing/test_collection.py`, verifying a symlinked directory is collected and its tests run under the symlink path.

**Changelog:** Added `changelog/7950.bugfix.rst`.

Verification:
- New test + related symlink/pathlib tests: `65 passed`
- Full `testing/test_collection.py`: `79 passed, 1 xfailed`
```

## Run folder `team-solve-2026-11-06T130229`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
0ca93ffdc963c344cccd3e7e84f4cfa09ab99337
```

### `baseline-check.log`

```
check: python -m pytest testing/test_collection.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-6.2.0.dev154+ga7e38c5c6, py-1.11.0, pluggy-0.13.1
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T130229/baseline-tree, configfile: pyproject.toml
collected 79 items

testing/test_collection.py .............................x............... [ 56%]
..................................                                       [100%]

======================== 78 passed, 1 xfailed in 21.73s ========================
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/src/_pytest/pathlib.py b/src/_pytest/pathlib.py
index f0bdb1481..b96cba069 100644
--- a/src/_pytest/pathlib.py
+++ b/src/_pytest/pathlib.py
@@ -558,7 +558,7 @@ def visit(
     entries = sorted(os.scandir(path), key=lambda entry: entry.name)
     yield from entries
     for entry in entries:
-        if entry.is_dir(follow_symlinks=False) and recurse(entry):
+        if entry.is_dir() and recurse(entry):
             yield from visit(entry.path, recurse)
 
 
diff --git a/testing/test_collection.py b/testing/test_collection.py
index 841aa358b..c59e5d6c3 100644
--- a/testing/test_collection.py
+++ b/testing/test_collection.py
@@ -1178,6 +1178,28 @@ def test_collect_symlink_out_of_tree(testdir):
     assert result.ret == 0
 
 
+def test_collect_symlink_directory(testdir):
+    """Directories which are symlinks are collected (regression #7950)."""
+    real = testdir.mkdir("real")
+    real.join("test_real.py").write(
+        textwrap.dedent(
+            """
+            def test_nodeid(request):
+                assert request.node.nodeid == "tests/symlink/test_real.py::test_nodeid"
+            """
+        )
+    )
+
+    tests = testdir.mkdir("tests")
+    symlink_or_skip(real, tests.join("symlink"))
+
+    result = testdir.runpytest("-v", str(tests))
+    result.stdout.fnmatch_lines(
+        ["tests/symlink/test_real.py::test_nodeid PASSED*", "*1 passed in*"]
+    )
+    assert result.ret == 0
+
+
 def test_collectignore_via_conftest(testdir):
     """collect_ignore in parent conftest skips importing child (issue #4592)."""
     tests = testdir.mkpydir("tests")
diff --git a/changelog/7950.bugfix.rst b/changelog/7950.bugfix.rst
new file mode 100644
index 000000000..a1b4b27d5
--- /dev/null
+++ b/changelog/7950.bugfix.rst
@@ -0,0 +1 @@
+Fixed regression where symlinked directories were not collected anymore.
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

Symlinked directories not collected since pytest 6.1.0
When there is a symlink to a directory in a test directory, is is just skipped over, but it should be followed and collected as usual.

This regressed in b473e515bc57ff1133fe650f1e7e6d7e22e5d841 (included in 6.1.0). For some reason I added a `follow_symlinks=False` in there, I don't remember why, but it does not match the previous behavior and should be removed.

PR for this is coming up.

## Deliverable

changes to this tree

## Check

`python -m pytest testing/test_collection.py`

## Scope

`src/_pytest/`
`testing/`
`changelog/`

## Done when

A symlink to a directory inside a test directory is followed and collected as usual.
The `follow_symlinks=False` behavior introduced in b473e515 is removed from directory collection.
Collection behavior matches pytest before 6.1.0 with respect to symlinked directories.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest testing/test_collection.py`

## Scope
`src/_pytest/`
`testing/`
`changelog/`

## Done when
A symlink to a directory inside a test directory is followed and collected as usual.
The `follow_symlinks=False` behavior introduced in b473e515 is removed from directory collection.
Collection behavior matches pytest before 6.1.0 with respect to symlinked directories.

## Approach
Find the directory-scanning/collection code changed by b473e515 (likely `_pytest/main.py` using `os.scandir` with `Entry.is_dir(follow_symlinks=False)`), and remove the `follow_symlinks=False` argument so symlinked directories are treated like ordinary directories. Then add or run a collection test that creates a real directory and a symlink to it, and asserts tests under both are collected.

Candidate approaches:
1. Remove the `follow_symlinks=False` argument entirely, restoring the implicit default `follow_symlinks=True`; smallest diff and matches the prompt.
2. Replace the call with explicit `is_dir(follow_symlinks=True)`; equivalent, but noisier than needed.
3. Switch the scan back to `Path.is_dir()`/`iterdir()`, which follows symlinks by default; larger refactor with more regression risk, so only if the minimal removal fails.

If the first attempt fails, verify whether the collection path uses `os.scandir` or `Path.iterdir`, and check that the symlink target is not excluded earlier by `norecursedirs`, `isinitpath`, or path matching.


# src/_pytest (the files in it)

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
src/_pytest/py.typed
src/_pytest/pytester.py
src/_pytest/python.py
src/_pytest/python_api.py
src/_pytest/recwarn.py
src/_pytest/reports.py
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


# testing (the files in it)

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
testing/example_scripts/unittest/test_unittest_plain_async.py
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
testing/plugins_integration/.gitignore
testing/plugins_integration/README.rst
testing/plugins_integration/bdd_wallet.feature
testing/plugins_integration/bdd_wallet.py
testing/plugins_integration/django_settings.py
testing/plugins_integration/pytest.ini
testing/plugins_integration/pytest_anyio_integration.py
testing/plugins_integration/pytest_asyncio_integration.py
testing/plugins_integration/pytest_mock_integration.py
testing/plugins_integration/pytest_trio_integration.py
testing/plugins_integration/pytest_twisted_integration.py
testing/plugins_integration/requirements.txt
testing/plugins_integration/simple_integration.py
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
testing/typing_checks.py


# changelog (the files in it)

changelog/4824.bugfix.rst
changelog/7425.feature.rst
changelog/7710.improvement.rst
changelog/7758.bugfix.rst
changelog/7780.doc.rst
changelog/7802.trivial.rst
changelog/7808.breaking.rst
changelog/7872.doc.rst
changelog/7878.doc.rst
changelog/7911.bugfix.rst
changelog/7913.bugfix.rst
changelog/7938.improvement.rst
changelog/README.rst
changelog/_template.rst


# The last commit

```
0ca93ffdc SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest testing/test_collection.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-6.2.0.dev154+ga7e38c5c6, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: pyproject.toml
collected 80 items

testing/test_collection.py .............................x............... [ 56%]
...................................                                      [100%]

======================== 79 passed, 1 xfailed in 49.86s ========================
scope: src/_pytest testing changelog
changed: src/_pytest/pathlib.py +1 -1
changed: testing/test_collection.py +22 -0
changed: changelog/7950.bugfix.rst +1 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/src/_pytest/pathlib.py b/src/_pytest/pathlib.py
index f0bdb1481..b96cba069 100644
--- a/src/_pytest/pathlib.py
+++ b/src/_pytest/pathlib.py
@@ -558,7 +558,7 @@ def visit(
     entries = sorted(os.scandir(path), key=lambda entry: entry.name)
     yield from entries
     for entry in entries:
-        if entry.is_dir(follow_symlinks=False) and recurse(entry):
+        if entry.is_dir() and recurse(entry):
             yield from visit(entry.path, recurse)
 
 
diff --git a/testing/test_collection.py b/testing/test_collection.py
index 841aa358b..c59e5d6c3 100644
--- a/testing/test_collection.py
+++ b/testing/test_collection.py
@@ -1178,6 +1178,28 @@ def test_collect_symlink_out_of_tree(testdir):
     assert result.ret == 0
 
 
+def test_collect_symlink_directory(testdir):
+    """Directories which are symlinks are collected (regression #7950)."""
+    real = testdir.mkdir("real")
+    real.join("test_real.py").write(
+        textwrap.dedent(
+            """
+            def test_nodeid(request):
+                assert request.node.nodeid == "tests/symlink/test_real.py::test_nodeid"
+            """
+        )
+    )
+
+    tests = testdir.mkdir("tests")
+    symlink_or_skip(real, tests.join("symlink"))
+
+    result = testdir.runpytest("-v", str(tests))
+    result.stdout.fnmatch_lines(
+        ["tests/symlink/test_real.py::test_nodeid PASSED*", "*1 passed in*"]
+    )
+    assert result.ret == 0
+
+
 def test_collectignore_via_conftest(testdir):
     """collect_ignore in parent conftest skips importing child (issue #4592)."""
     tests = testdir.mkpydir("tests")
diff --git a/changelog/7950.bugfix.rst b/changelog/7950.bugfix.rst
new file mode 100644
index 000000000..a1b4b27d5
--- /dev/null
+++ b/changelog/7950.bugfix.rst
@@ -0,0 +1 @@
+Fixed regression where symlinked directories were not collected anymore.
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
check: python -m pytest testing/test_collection.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-6.2.0.dev154+ga7e38c5c6, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: pyproject.toml
collected 80 items

testing/test_collection.py .............................x............... [ 56%]
...................................                                      [100%]

======================== 79 passed, 1 xfailed in 20.65s ========================
scope: src/_pytest testing changelog
changed: src/_pytest/pathlib.py +1 -1
changed: testing/test_collection.py +22 -0
changed: changelog/7950.bugfix.rst +1 -0
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
# Notes, run 2026-11-06T130229

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Symlinked directories not collected since pytest 6.1.0
When there is a symlink to a directory in a test directory, is is just skipped over, but it should be followed and collected as usual.

This regressed in b473e515bc57ff1133fe650f1e7e6d7e22e5d841 (included in 6.1.0). For some reason I added a `follow_symlinks=False` in there, I don't remember why, but it does not match the previous behavior and should be removed.

PR for this is coming up.


# The files of the project

```
.coveragerc
.gitattributes
.gitblameignore
.github/FUNDING.yml
.github/ISSUE_TEMPLATE/1_bug_report.md
.github/ISSUE_TEMPLATE/2_feature_request.md
.github/ISSUE_TEMPLATE/config.yml
.github/PULL_REQUEST_TEMPLATE.md
.github/config.yml
.github/dependabot.yml
.github/labels.toml
.github/workflows/main.yml
.github/workflows/release-on-comment.yml
.gitignore
.pre-commit-config.yaml
.readthedocs.yml
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
bench/xunit.py
changelog/4824.bugfix.rst
changelog/7425.feature.rst
changelog/7710.improvement.rst
changelog/7758.bugfix.rst
changelog/7780.doc.rst
changelog/7802.trivial.rst
changelog/7808.breaking.rst
changelog/7872.doc.rst
changelog/7878.doc.rst
changelog/7911.bugfix.rst
changelog/7913.bugfix.rst
changelog/7938.improvement.rst
changelog/README.rst
changelog/_template.rst
codecov.yml
doc/en/Makefile
doc/en/_templates/globaltoc.html
doc/en/_templates/layout.html
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
doc/en/announce/release-6.0.0.rst
doc/en/announce/release-6.0.0rc1.rst
doc/en/announce/release-6.0.1.rst
doc/en/announce/release-6.0.2.rst
doc/en/announce/release-6.1.0.rst
doc/en/announce/release-6.1.1.rst
doc/en/announce/release-6.1.2.rst
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
src/_pytest/py.typed
src/_pytest/pytester.py
src/_pytest/python.py
src/_pytest/python_api.py
src/_pytest/recwarn.py
src/_pytest/reports.py
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
src/pytest/py.typed
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
testing/example_scripts/unittest/test_unittest_plain_async.py
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
testing/plugins_integration/.gitignore
testing/plugins_integration/README.rst
testing/plugins_integration/bdd_wallet.feature
testing/plugins_integration/bdd_wallet.py
testing/plugins_integration/django_settings.py
testing/plugins_integration/pytest.ini
testing/plugins_integration/pytest_anyio_integration.py
testing/plugins_integration/pytest_asyncio_integration.py
testing/plugins_integration/pytest_mock_integration.py
testing/plugins_integration/pytest_trio_integration.py
testing/plugins_integration/pytest_twisted_integration.py
testing/plugins_integration/requirements.txt
testing/plugins_integration/simple_integration.py
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
testing/typing_checks.py
tox.ini
```


# The last commit

```
0ca93ffdc SWE-bench


```

```diff

```


# pyproject.toml (the start)

```
[build-system]
requires = [
  # sync with setup.py until we discard non-pep-517/518
  "setuptools>=42.0",
  "setuptools-scm[toml]>=3.4",
  "wheel",
]
build-backend = "setuptools.build_meta"

[tool.setuptools_scm]
write_to = "src/_pytest/_version.py"

[tool.pytest.ini_options]
minversion = "2.0"
addopts = "-rfEX -p pytester --strict-markers"
python_files = ["test_*.py", "*_test.py", "testing/python/*.py"]
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
    # produced on execnet (pytest-xdist)
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
target-version = ['py36']

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest testing/test_collection.py`

## Scope
`src/_pytest/`
`testing/`
`changelog/`

## Done when
A symlink to a directory inside a test directory is followed and collected as usual.
The `follow_symlinks=False` behavior introduced in b473e515 is removed from directory collection.
Collection behavior matches pytest before 6.1.0 with respect to symlinked directories.

## Approach
Find the directory-scanning/collection code changed by b473e515 (likely `_pytest/main.py` using `os.scandir` with `Entry.is_dir(follow_symlinks=False)`), and remove the `follow_symlinks=False` argument so symlinked directories are treated like ordinary directories. Then add or run a collection test that creates a real directory and a symlink to it, and asserts tests under both are collected.

Candidate approaches:
1. Remove the `follow_symlinks=False` argument entirely, restoring the implicit default `follow_symlinks=True`; smallest diff and matches the prompt.
2. Replace the call with explicit `is_dir(follow_symlinks=True)`; equivalent, but noisier than needed.
3. Switch the scan back to `Path.is_dir()`/`iterdir()`, which follows symlinks by default; larger refactor with more regression risk, so only if the minimal removal fails.

If the first attempt fails, verify whether the collection path uses `os.scandir` or `Path.iterdir`, and check that the symlink target is not excluded earlier by `norecursedirs`, `isinitpath`, or path matching.
```

### `prompt.md`

```
Symlinked directories not collected since pytest 6.1.0
When there is a symlink to a directory in a test directory, is is just skipped over, but it should be followed and collected as usual.

This regressed in b473e515bc57ff1133fe650f1e7e6d7e22e5d841 (included in 6.1.0). For some reason I added a `follow_symlinks=False` in there, I don't remember why, but it does not match the previous behavior and should be removed.

PR for this is coming up.
```

### `review.md`

```
verdict: PASS

- The core regression is fixed exactly as the Prompt requests: `src/_pytest/pathlib.py` in `visit()` now uses `entry.is_dir()` instead of `entry.is_dir(follow_symlinks=False)`, restoring pre-6.1.0 behavior of following symlinked directories during collection.
- A regression test `test_collect_symlink_directory` was added in `testing/test_collection.py`, asserting that a symlinked directory inside a test directory is collected and that the nodeid reflects the symlink path.
- A changelog entry `changelog/7950.bugfix.rst` was added, matching the issue number and project convention (a project-convention nicety, not a Prompt requirement).
- All modified files (`src/_pytest/pathlib.py`, `testing/test_collection.py`, `changelog/7950.bugfix.rst`) fall within the stated Scope; nothing outside was touched, and no content was removed beyond the single incorrect `follow_symlinks=False` argument the Prompt asked to remove.
- The check `python -m pytest testing/test_collection.py` passed (79 passed, 1 xfailed, status 0), confirming collection behavior is intact and the new test exercises the fixed path.
```

### `scope.txt`

```
scope: src/_pytest testing changelog
changed: src/_pytest/pathlib.py +1 -1
changed: testing/test_collection.py +22 -0
changed: changelog/7950.bugfix.rst +1 -0
```

### `task.md`

```
# Task

## Prompt

Symlinked directories not collected since pytest 6.1.0
When there is a symlink to a directory in a test directory, is is just skipped over, but it should be followed and collected as usual.

This regressed in b473e515bc57ff1133fe650f1e7e6d7e22e5d841 (included in 6.1.0). For some reason I added a `follow_symlinks=False` in there, I don't remember why, but it does not match the previous behavior and should be removed.

PR for this is coming up.

## Deliverable

changes to this tree

## Check

`python -m pytest testing/test_collection.py`

## Scope

`src/_pytest/`
`testing/`
`changelog/`

## Done when

A symlink to a directory inside a test directory is followed and collected as usual.
The `follow_symlinks=False` behavior introduced in b473e515 is removed from directory collection.
Collection behavior matches pytest before 6.1.0 with respect to symlinked directories.
```

### `test-output.log`

```
check: python -m pytest testing/test_collection.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-6.2.0.dev154+ga7e38c5c6, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: pyproject.toml
collected 80 items

testing/test_collection.py .............................x............... [ 56%]
...................................                                      [100%]

======================== 79 passed, 1 xfailed in 30.52s ========================
scope: src/_pytest testing changelog
changed: src/_pytest/pathlib.py +1 -1
changed: testing/test_collection.py +22 -0
changed: changelog/7950.bugfix.rst +1 -0
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
