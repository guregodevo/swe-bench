# pylint-dev__pylint-7277 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 62s 45 lines cost=0.003324 in=131054 cached=86016 out=4974 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

`pylint` removes first item from `sys.path` when running from `runpy`.
### Bug description

This is the line where the first item from sys.path is removed.
https://github.com/PyCQA/pylint/blob/ce7cccf96454fb6e286e4a8f38919733a0f28f44/pylint/__init__.py#L99

I think there should be a check to ensure that the first item is `""`, `"."` or `os.getcwd()` before removing.

### Configuration

_No response_

### Command used

```shell
Run programmatically to repro this, using this code:

import sys
import runpy

sys.path.insert(0, "something")

runpy.run_module('pylint', run_name="__main__", alter_sys=True)
```


### Pylint output

```shell
When using pylint extension which bundles the libraries, the extension add them to sys.path depending on user settings. Pylint removes the first entry from sys path causing it to fail to load.
```


### Expected behavior

Check if  `""`, `"."` or `os.getcwd()` before removing the first item from sys.path

### Pylint version

```shell
pylint 2.14.5
```


### OS / Environment

_No response_

### Additional dependencies

_No response_

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "cd /workspace 2>/dev/null || pwd; git status --porcelain; ls"
}
```

**tool result**

```
refused: this command cd's to /workspace, outside your working directory (/testbed). You are ALREADY in the right directory — drop the cd and use paths relative to it.

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "git status --porcelain; ls; sed -n '80,120p' pylint/__init__.py"
}
```

**tool result**

```
?? .memdoor/
CODE_OF_CONDUCT.md
CONTRIBUTORS.txt
Dockerfile
LICENSE
MANIFEST.in
README.rst
doc
elisp
examples
pylint
pylint.egg-info
pylintrc
pyproject.toml
requirements_test.txt
requirements_test_min.txt
requirements_test_pre_commit.txt
script
setup.cfg
tbump.toml
tests
towncrier.toml
tox.ini
def modify_sys_path() -> None:
    """Modify sys path for execution as Python module.

    Strip out the current working directory from sys.path.
    Having the working directory in `sys.path` means that `pylint` might
    inadvertently import user code from modules having the same name as
    stdlib or pylint's own modules.
    CPython issue: https://bugs.python.org/issue33053

    - Remove the first entry. This will always be either "" or the working directory
    - Remove the working directory from the second and third entries
      if PYTHONPATH includes a ":" at the beginning or the end.
      https://github.com/PyCQA/pylint/issues/3636
      Don't remove it if PYTHONPATH contains the cwd or '.' as the entry will
      only be added once.
    - Don't remove the working directory from the rest. It will be included
      if pylint is installed in an editable configuration (as the last item).
      https://github.com/PyCQA/pylint/issues/4161
    """
    sys.path.pop(0)
    env_pythonpath = os.environ.get("PYTHONPATH", "")
    cwd = os.getcwd()
    if env_pythonpath.startswith(":") and env_pythonpath not in (f":{cwd}", ":."):
        sys.path.pop(0)
    elif env_pythonpath.endswith(":") and env_pythonpath not in (f"{cwd}:", ".:"):
        sys.path.pop(1)


version = __version__
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"modify_sys_path\" tests pylint | head -30; sed -n '1,80p' pylint/__init__.py"
}
```

**tool result**

```
tests/test_self.py:32:from pylint import extensions, modify_sys_path
tests/test_self.py:746:    def test_modify_sys_path() -> None:
tests/test_self.py:759:                modify_sys_path()
tests/test_self.py:765:                modify_sys_path()
tests/test_self.py:771:                modify_sys_path()
tests/test_self.py:777:                modify_sys_path()
tests/test_self.py:783:                modify_sys_path()
tests/test_self.py:789:                modify_sys_path()
tests/test_self.py:795:                modify_sys_path()
tests/test_self.py:799:                modify_sys_path()
tests/test_self.py:804:                modify_sys_path()
tests/test_self.py:808:                modify_sys_path()
tests/test_self.py:814:                modify_sys_path()
pylint/__main__.py:9:pylint.modify_sys_path()
pylint/__init__.py:10:    "modify_sys_path",
pylint/__init__.py:80:def modify_sys_path() -> None:
# Licensed under the GPL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
# For details: https://github.com/PyCQA/pylint/blob/main/LICENSE
# Copyright (c) https://github.com/PyCQA/pylint/blob/main/CONTRIBUTORS.txt

from __future__ import annotations

__all__ = [
    "__version__",
    "version",
    "modify_sys_path",
    "run_pylint",
    "run_epylint",
    "run_symilar",
    "run_pyreverse",
]

import os
import sys
from collections.abc import Sequence
from typing import NoReturn

from pylint.__pkginfo__ import __version__

# pylint: disable=import-outside-toplevel


def run_pylint(argv: Sequence[str] | None = None) -> None:
    """Run pylint.

    argv can be a sequence of strings normally supplied as arguments on the command line
    """
    from pylint.lint import Run as PylintRun

    try:
        PylintRun(argv or sys.argv[1:])
    except KeyboardInterrupt:
        sys.exit(1)


def _run_pylint_config(argv: Sequence[str] | None = None) -> None:
    """Run pylint-config.

    argv can be a sequence of strings normally supplied as arguments on the command line
    """
    from pylint.lint.run import _PylintConfigRun

    _PylintConfigRun(argv or sys.argv[1:])


def run_epylint(argv: Sequence[str] | None = None) -> NoReturn:
    """Run epylint.

    argv can be a list of strings normally supplied as arguments on the command line
    """
    from pylint.epylint import Run as EpylintRun

    EpylintRun(argv)


def run_pyreverse(argv: Sequence[str] | None = None) -> NoReturn:  # type: ignore[misc]
    """Run pyreverse.

    argv can be a sequence of strings normally supplied as arguments on the command line
    """
    from pylint.pyreverse.main import Run as PyreverseRun

    PyreverseRun(argv or sys.argv[1:])


def run_symilar(argv: Sequence[str] | None = None) -> NoReturn:
    """Run symilar.

    argv can be a sequence of strings normally supplied as arguments on the command line
    """
    from pylint.checkers.similar import Run as SimilarRun

    SimilarRun(argv or sys.argv[1:])


def modify_sys_path() -> None:
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '730,830p' tests/test_self.py"
}
```

**tool result**

```
            (["--disable=C0116", "--fail-on=C"], 0),
            # Ensure order does not matter
            (["--fail-on=C", "--disable=C0116"], 0),
            # Ensure --fail-on takes precedence over --disable
            (["--disable=C0116", "--fail-on=C0116"], 16),
            # Ensure order does not matter
            (["--fail-on=C0116", "--disable=C0116"], 16),
        ],
    )
    def test_fail_on_edge_case(self, opts, out):
        self._runtest(
            opts + [join(HERE, "regrtest_data", "fail_under_plus7_5.py")],
            code=out,
        )

    @staticmethod
    def test_modify_sys_path() -> None:
        cwd = "/tmp/pytest-of-root/pytest-0/test_do_not_import_files_from_0"
        default_paths = [
            "/usr/local/lib/python39.zip",
            "/usr/local/lib/python3.9",
            "/usr/local/lib/python3.9/lib-dynload",
            "/usr/local/lib/python3.9/site-packages",
        ]
        with _test_sys_path(), patch("os.getcwd") as mock_getcwd:
            mock_getcwd.return_value = cwd
            paths = [cwd, *default_paths]
            sys.path = copy(paths)
            with _test_environ_pythonpath():
                modify_sys_path()
            assert sys.path == paths[1:]

            paths = [cwd, cwd, *default_paths]
            sys.path = copy(paths)
            with _test_environ_pythonpath("."):
                modify_sys_path()
            assert sys.path == paths[1:]

            paths = [cwd, "/custom_pythonpath", *default_paths]
            sys.path = copy(paths)
            with _test_environ_pythonpath("/custom_pythonpath"):
                modify_sys_path()
            assert sys.path == paths[1:]

            paths = [cwd, "/custom_pythonpath", cwd, *default_paths]
            sys.path = copy(paths)
            with _test_environ_pythonpath("/custom_pythonpath:"):
                modify_sys_path()
            assert sys.path == [paths[1]] + paths[3:]

            paths = ["", cwd, "/custom_pythonpath", *default_paths]
            sys.path = copy(paths)
            with _test_environ_pythonpath(":/custom_pythonpath"):
                modify_sys_path()
            assert sys.path == paths[2:]

            paths = [cwd, cwd, "/custom_pythonpath", *default_paths]
            sys.path = copy(paths)
            with _test_environ_pythonpath(":/custom_pythonpath:"):
                modify_sys_path()
            assert sys.path == paths[2:]

            paths = [cwd, cwd, *default_paths]
            sys.path = copy(paths)
            with _test_environ_pythonpath(":."):
                modify_sys_path()
            assert sys.path == paths[1:]
            sys.path = copy(paths)
            with _test_environ_pythonpath(f":{cwd}"):
                modify_sys_path()
            assert sys.path == paths[1:]

            sys.path = copy(paths)
            with _test_environ_pythonpath(".:"):
                modify_sys_path()
            assert sys.path == paths[1:]
            sys.path = copy(paths)
            with _test_environ_pythonpath(f"{cwd}:"):
                modify_sys_path()
            assert sys.path == paths[1:]

            paths = ["", cwd, *default_paths, cwd]
            sys.path = copy(paths)
            with _test_environ_pythonpath(cwd):
                modify_sys_path()
            assert sys.path == paths[1:]

    @pytest.mark.parametrize(
        "args",
        [
            ["--disable=import-error,unused-import"],
            # Test with multiple jobs for 'hmac.py' for which we have a
            # CVE against: https://github.com/PyCQA/pylint/issues/959
            ["-j2", "--disable=import-error,unused-import"],
        ],
    )
    def test_do_not_import_files_from_local_directory(
        self, tmpdir: LocalPath, args: list[str]
    ) -> None:
        for path in ("astroid.py", "hmac.py"):
            file_path = tmpdir / path
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -5; python -c \"import pylint; print(pylint.__version__)\""
}
```

**tool result**

```
b2b4b41e SWE-bench
684a1d6a Bump actions/setup-python from 4.1.0 to 4.2.0
635f52e6 Bump flake8 from 5.0.2 to 5.0.4
d50ddee3 Bump flake8-typing-imports from 1.12.0 to 1.13.0
e0ecc35e [open source insight] Add the badge from OpenSSF (#7267)
2.15.0-a0
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: pylint/__init__.py\n@@\n-    - Remove the first entry. This will always be either \"\" or the working directory\n+    - Remove the first entry if it is either \"\" or the working directory\n@@\n-    sys.path.pop(0)\n-    env_pythonpath = os.environ.get(\"PYTHONPATH\", \"\")\n     cwd = os.getcwd()\n+    if sys.path[0] in (\"\", \".\", cwd):\n+        sys.path.pop(0)\n+    env_pythonpath = os.environ.get(\"PYTHONPATH\", \"\")\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[pylint/__init__.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

pylint/__init__.py now (109 lines), around the change:
86:    stdlib or pylint's own modules.
87:    CPython issue: https://bugs.python.org/issue33053
88:
89:    - Remove the first entry if it is either "" or the working directory
90:    - Remove the working directory from the second and third entries
91:      if PYTHONPATH includes a ":" at the beginning or the end.
92:      https://github.com/PyCQA/pylint/issues/3636
…
96:      if pylint is installed in an editable configuration (as the last item).
97:      https://github.com/PyCQA/pylint/issues/4161
98:    """
99:    cwd = os.getcwd()
100:    if sys.path[0] in ("", ".", cwd):
101:        sys.path.pop(0)
102:    env_pythonpath = os.environ.get("PYTHONPATH", "")
103:    if env_pythonpath.startswith(":") and env_pythonpath not in (f":{cwd}", ":."):
104:        sys.path.pop(0)
105:    elif env_pythonpath.endswith(":") and env_pythonpath not in (f"{cwd}:", ".:"):
106:        sys.path.pop(1)
```

**assistant → tool `bash`**

```json
{
  "command": "PYTHONPATH=\":/foo\" python -c 'import sys; print(sys.path[:4])'; PYTHONPATH=\".:\" python -c 'import sys; print(sys.path[:4])'; python -c 'import sys; print(sys.path[:3])'"
}
```

**tool result**

```
['', '/testbed', '/foo', '/opt/miniconda3/envs/testbed/lib/python39.zip']
['', '/testbed', '/opt/miniconda3/envs/testbed/lib/python39.zip', '/opt/miniconda3/envs/testbed/lib/python3.9']
['', '/opt/miniconda3/envs/testbed/lib/python39.zip', '/opt/miniconda3/envs/testbed/lib/python3.9']
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_self.py::TestRunTC::test_modify_sys_path -q 2>&1 | tail -30"
}
```

**tool result**

```
.                                                                        [100%]
1 passed in 0.25s
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport sys, runpy\nsys.path.insert(0, \"something\")\nold = list(sys.path)\ntry:\n    runpy.run_module('pylint', run_name=\"__main__\", alter_sys=True)\nexcept SystemExit:\n    pass\nprint(sys.path[:4])\nassert sys.path[0] == \"something\", sys.path[:4]\nEOF"
}
```

**tool result**

```
usage: pylint [options]

optional arguments:
  -h, --help            show this help message and exit

Commands:
  Options which are actually commands. Options in this group are mutually exclusive.

  --rcfile RCFILE       Specify a configuration file to load.
  --output OUTPUT       Specify an output file.
  --help-msg HELP_MSG [HELP_MSG ...]
                        Display a help message for the given message id and
                        exit. The value may be a comma separated list of
                        message ids.
  --list-msgs           Display a list of all pylint's messages divided by
                        whether they are emittable with the given interpreter.
  --list-msgs-enabled   Display a list of what messages are enabled, disabled
                        and non-emittable with the given configuration.
  --list-groups         List pylint's message groups.
  --list-conf-levels    Generate pylint's confidence levels.
  --list-extensions     List available extensions.
  --full-documentation  Generate pylint's full documentation.
  --generate-rcfile     Generate a sample configuration file according to the
                        current configuration. You can put other options
                        before this one to get them in the generated
                        configuration.
  --generate-toml-config
                        Generate a sample configuration file according to the
                        current configuration. You can put other options
                        before this one to get them in the generated
                        configuration. The config is in the .toml format.
  --long-help           Show more verbose help.

Main:
  --init-hook INIT_HOOK
                        Python code to execute, usually for sys.path
                        manipulation such as pygtk.require().
  --errors-only, -E     In error mode, messages with a category besides ERROR
                        or FATAL are suppressed, and no reports are done by
                        default. Error mode is compatible with disabling
                        specific errors.
  --verbose , -v        In verbose mode, extra non-checker-related info will
                        be displayed.
  --enable-all-extensions 
                        Load and enable all available extensions. Use --list-
                        extensions to see a list all available extensions.
  --ignore <file>[,<file>...]
                        Files or directories to be skipped. They should be
                        base names, not paths. (default: ('CVS',))
  --ignore-patterns <pattern>[,<pattern>...]
                        Files or directories matching the regular expression
                        patterns are skipped. The regex matches against base
                        names, not paths. The default value ignores Emacs file
                        locks (default: (re.compile('^\\.#'),))
  --ignore-paths <pattern>[,<pattern>...]
                        Add files or directories matching the regular
                        expressions patterns to the ignore-list. The regex
                        matches against paths and can be in Posix or Windows
                        format. Because '\' represents the directory delimiter
                        on Windows systems, it can't be used as an escape
                        character. (default: [])
  --persistent <y or n>
                        Pickle collected data for later comparisons. (default:
                        True)
  --load-plugins <modules>
                        List of plugins (as comma separated values of python
                        module names) to load, usually to register additional
                        checkers. (default: ())
  --fail-under <score>  Specify a score threshold under which the program will
                        exit with error. (default: 10)
  --fail-on <msg ids>   Return non-zero exit code if any of these
                        messages/categories are detected, even if score is
                        above --fail-under value. Syntax same as enable.
                        Messages specified are enabled, while categories only
                        check already-enabled messages. (default: )
  --jobs <n-processes>, -j <n-processes>
                        Use multiple processes to speed up Pylint. Specifying
                        0 will auto-detect the number of processors available
                        to use, and will cap the count on Windows to avoid
                        hangs. (default: 1)
  --limit-inference-results <number-of-results>
                        Control the amount of potential inferred values when
                        inferring a single object. This can help the
                        performance when dealing with large functions or
                        complex, nested conditions. (default: 100)
  --extension-pkg-allow-list <pkg[,pkg]>
                        A comma-separated list of package or module names from
                        where C extensions may be loaded. Extensions are
                        loading into the active Python interpreter and may run
                        arbitrary code. (default: [])
  --extension-pkg-whitelist <pkg[,pkg]>
                        A comma-separated list of package or module names from
                        where C extensions may be loaded. Extensions are
                        loading into the active Python interpreter and may run
                        arbitrary code. (This is an alternative name to
                        extension-pkg-allow-list for backward compatibility.)
                        (default: [])
  --suggestion-mode <y or n>
                        When enabled, pylint would attempt to guess common
                        misconfiguration and emit user-friendly hints instead
                        of false-positive error messages. (default: True)
  --exit-zero           Always return a 0 (non-error) status code, even if
                        lint errors are found. This is primarily useful in
                        continuous integration scripts. (default: False)
  --from-stdin          Interpret the stdin as a python script, whose filename
                        needs to be passed as the module_or_package argument.
                        (default: False)
  --recursive <yn>      Discover python modules and packages in the file
                        system subtree. (default: False)
  --py-version <py_version>
                        Minimum Python version to use for version dependent
                        checks. Will default to the version used to run
                        pylint. (default: (3, 9))
  --ignored-modules <module names>
                        List of module names for which member attributes
                        should not be checked (useful for modules/projects
                        where namespaces are manipulated during runtime and
                        thus existing member attributes cannot be deduced by
                        static analysis). It supports qualified module names,
                        as well as Unix pattern matching. (default: ())
  --analyse-fallback-blocks <y or n>
                        Analyse import fallback blocks. This can be used to
                        support both Python 2 and 3 compatible code, which
                        means that the block might have code that exists only
                        in one or another interpreter, leading to false
                        positives when analysed. (default: False)

Reports:
  Options related to output formatting and reporting

  --output-format <format>, -f <format>
                        Set the output format. Available formats are text,
                        parseable, colorized, json and msvs (visual studio).
                        You can also give a reporter class, e.g.
                        mypackage.mymodule.MyReporterClass.
  --reports <y or n>, -r <y or n>
                        Tells whether to display a full report or only the
                        messages. (default: False)
  --evaluation <python_expression>
                        Python expression which should return a score less
                        than or equal to 10. You have access to the variables
                        'fatal', 'error', 'warning', 'refactor', 'convention',
                        and 'info' which contain the number of messages in
                        each category, as well as 'statement' which is the
                        total number of statements analyzed. This score is
                        used by the global evaluation report (RP0004).
                        (default: max(0, 0 if fatal else 10.0 - ((float(5 *
                        error + warning + refactor + convention) / statement)
                        * 10)))
  --score <y or n>, -s <y or n>
                        Activate the evaluation score. (default: True)
  --msg-template <template>
                        Template used to display messages. This is a python
                        new-style format string used to format the message
                        information. See doc for all details. (default: )

Messages control:
  Options controlling analysis messages

  --confidence <levels>
                        Only show warnings with the listed confidence levels.
                        Leave empty to show all. Valid levels: HIGH,
                        CONTROL_FLOW, INFERENCE, INFERENCE_FAILURE, UNDEFINED.
                        (default: ['HIGH', 'CONTROL_FLOW', 'INFERENCE',
                        'INFERENCE_FAILURE', 'UNDEFINED'])
  --enable <msg ids>, -e <msg ids>
                        Enable the message, report, category or checker with
                        the given id(s). You can either give multiple
                        identifier separated by comma (,) or put this option
                        multiple time (only on the command line, not in the
                        configuration file where it should appear only once).
                        See also the "--disable" option for examples.
  --disable <msg ids>, -d <msg ids>
                        Disable the message, report, category or checker with
                        the given id(s). You can either give multiple
                        identifiers separated by comma (,) or put this option
                        multiple times (only on the command line, not in the
                        configuration file where it should appear only once).
                        You can also use "--disable=all" to disable everything
                        first and then re-enable specific checks. For example,
                        if you want to run only the similarities checker, you
                        can use "--disable=all --enable=similarities". If you
                        want to run only the classes checker, but have no
                        Warning level messages displayed, use "--disable=all
                        --enable=classes --disable=W".

Refactoring:
  Looks for code which can be refactored.

  --max-nested-blocks <int>
                        Maximum number of nested blocks for function / method
                        body (default: 5)
  --never-returning-functions <members names>
                        Complete name of functions that never returns. When
                        checking for inconsistent-return-statements if a never
                        returning function is called then it will be
                        considered as an explicit return statement and no
                        message will be printed. (default: ('sys.exit',
                        'argparse.parse_error'))

Variables:
  BaseChecker for variables.

  --init-import <y or n>
                        Tells whether we should check for unused import in
                        __init__ files. (default: False)
  --dummy-variables-rgx <regexp>
                        A regular expression matching the name of dummy
                        variables (i.e. expected to not be used). (default: _+
                        $|(_[a-zA-Z0-9_]*[a-zA-Z0-9]+?$)|dummy|^ignored_|^unus
                        ed_)
  --additional-builtins <comma separated list>
                        List of additional names supposed to be defined in
                        builtins. Remember that you should avoid defining new
                        builtins when possible. (default: ())
  --callbacks <callbacks>
                        List of strings which can identify a callback function
                        by name. A callback name must start or end with one of
                        those strings. (default: ('cb_', '_cb'))
  --redefining-builtins-modules <comma separated list>
                        List of qualified module names which can have objects
                        that can redefine builtins. (default: ('six.moves',
                        'past.builtins', 'future.builtins', 'builtins', 'io'))
  --ignored-argument-names <regexp>
                        Argument names that match this expression will be
                        ignored. (default:
                        re.compile('_.*|^ignored_|^unused_'))
  --allow-global-unused-variables <y or n>
                        Tells whether unused global variables should be
                        treated as a violation. (default: True)
  --allowed-redefined-builtins <comma separated list>
                        List of names allowed to shadow builtins (default: ())

Method_args:
  BaseChecker for method_args.

  --timeout-methods <comma separated list>
                        List of qualified names (i.e., library.method) which
                        require a timeout parameter e.g.
                        'requests.api.get,requests.api.post' (default:
                        ('requests.api.delete', 'requests.api.get',
                        'requests.api.head', 'requests.api.options',
                        'requests.api.patch', 'requests.api.post',
                        'requests.api.put', 'requests.api.request'))

Miscellaneous:
  BaseChecker for encoding issues.

  --notes <comma separated values>
                        List of note tags to take in consideration, separated
                        by a comma. (default: ('FIXME', 'XXX', 'TODO'))
  --notes-rgx <regexp>  Regular expression of note tags to take in
                        consideration. (default: )

Format:
  Formatting checker.

  --max-line-length <int>
                        Maximum number of characters on a single line.
                        (default: 100)
  --ignore-long-lines <regexp>
                        Regexp for a line that is allowed to be longer than
                        the limit. (default: ^\s*(# )?<?https?://\S+>?$)
  --single-line-if-stmt <y or n>
                        Allow the body of an if to be on the same line as the
                        test if there is no else. (default: False)
  --single-line-class-stmt <y or n>
                        Allow the body of a class to be on the same line as
                        the declaration if body contains single statement.
                        (default: False)
  --max-module-lines <int>
                        Maximum number of lines in a module. (default: 1000)
  --indent-string <string>
                        String used as indentation unit. This is usually " "
                        (4 spaces) or "\t" (1 tab). (default: )
  --indent-after-paren <int>
                        Number of spaces of indent required inside a hanging
                        or continued line. (default: 4)
  --expected-line-ending-format <empty or LF or CRLF>
                        Expected format of line ending, e.g. empty (any line
                        ending), LF or CRLF. (default: )

Design:
  Checker of potential misdesigns.

  --max-args <int>      Maximum number of arguments for function / method.
                        (default: 5)
  --max-locals <int>    Maximum number of locals for function / method body.
                        (default: 15)
  --max-returns <int>   Maximum number of return / yield for function / method
                        body. (default: 6)
  --max-branches <int>  Maximum number of branch for function / method body.
                        (default: 12)
  --max-statements <int>
                        Maximum number of statements in function / method
                        body. (default: 50)
  --max-parents <num>   Maximum number of parents for a class (see R0901).
                        (default: 7)
  --ignored-parents <comma separated list of class names>
                        List of qualified class names to ignore when counting
                        class parents (see R0901) (default: ())
  --max-attributes <num>
                        Maximum number of attributes for a class (see R0902).
                        (default: 7)
  --min-public-methods <num>
                        Minimum number of public methods for a class (see
                        R0903). (default: 2)
  --max-public-methods <num>
                        Maximum number of public methods for a class (see
                        R0904). (default: 20)
  --max-bool-expr <num>
                        Maximum number of boolean expressions in an if
                        statement (see R0916). (default: 5)
  --exclude-too-few-public-methods <pattern>[,<pattern>...]
                        List of regular expressions of class ancestor names to
                        ignore when counting public methods (see R0903)
                        (default: [])

Similarities:
  Checks for similarities and duplicated code.

  --min-similarity-lines <int>
                        Minimum lines number of a similarity. (default: 4)
  --ignore-comments <y or n>
                        Comments are removed from the similarity computation
                        (default: True)
  --ignore-docstrings <y or n>
                        Docstrings are removed from the similarity computation
                        (default: True)
  --ignore-imports <y or n>
                        Imports are removed from the similarity computation
                        (default: True)
  --ignore-signatures <y or n>
                        Signatures are removed from the similarity computation
                        (default: True)

Typecheck:
  Try to find bugs in the code using type inference.

  --ignore-on-opaque-inference <y or n>
                        This flag controls whether pylint should warn about
                        no-member and similar checks whenever an opaque object
                        is returned when inferring. The inference can return
                        multiple potential results while evaluating a Python
                        object, but some branches might not be evaluated,
                        which results in partial inference. In that case, it
                        might be useful to still emit no-member and other
                        checks for the rest of the inferred objects. (default:
                        True)
  --mixin-class-rgx <regexp>
                        Regex pattern to define which classes are considered
                        mixins. (default: .*[Mm]ixin)
  --ignore-mixin-members <y or n>
                        Tells whether missing members accessed in mixin class
                        should be ignored. A class is considered mixin if its
                        name matches the mixin-class-rgx option. (default:
                        True)
  --ignored-checks-for-mixins <list of messages names>
                        List of symbolic message names to ignore for Mixin
                        members. (default: ['no-member', 'not-async-context-
                        manager', 'not-context-manager', 'attribute-defined-
                        outside-init'])
  --ignore-none <y or n>
                        Tells whether to warn about missing members when the
                        owner of the attribute is inferred to be None.
                        (default: True)
  --ignored-classes <members names>
                        List of class names for which member attributes should
                        not be checked (useful for classes with dynamically
                        set attributes). This supports the use of qualified
                        names. (default: ('optparse.Values', 'thread._local',
                        '_thread._local', 'argparse.Namespace'))
  --generated-members <members names>
                        List of members which are set dynamically and missed
                        by pylint inference system, and so shouldn't trigger
                        E1101 when accessed. Python regular expressions are
                        accepted. (default: ())
  --contextmanager-decorators <decorator names>
                        List of decorators that produce context managers, such
                        as contextlib.contextmanager. Add to this list to
                        register other decorators that produce valid context
                        managers. (default: ['contextlib.contextmanager'])
  --missing-member-hint-distance <member hint edit distance>
                        The minimum edit distance a name should have in order
                        to be considered a similar match for a missing member
                        name. (default: 1)
  --missing-member-max-choices <member hint max choices>
                        The total number of similar names that should be taken
                        in consideration when showing a hint for a missing
                        member. (default: 1)
  --missing-member-hint <missing member hint>
                        Show a hint with possible names when a member name was
                        not found. The aspect of finding the hint is based on
                        edit distance. (default: True)
  --signature-mutators <decorator names>
                        List of decorators that change the signature of a
                        decorated function. (default: [])

Basic:
  --good-names <names>  Good variable names which should always be accepted,
                        separated by a comma. (default: ('i', 'j', 'k', 'ex',
                        'Run', '_'))
  --good-names-rgxs <names>
                        Good variable names regexes, separated by a comma. If
                        names match any regex, they will always be accepted
                        (default: )
  --bad-names <names>   Bad variable names which should always be refused,
                        separated by a comma. (default: ('foo', 'bar', 'baz',
                        'toto', 'tutu', 'tata'))
  --bad-names-rgxs <names>
                        Bad variable names regexes, separated by a comma. If
                        names match any regex, they will always be refused
                        (default: )
  --name-group <name1:name2>
                        Colon-delimited sets of names that determine each
                        other's naming style when the name regexes allow
                        several styles. (default: ())
  --include-naming-hint <y or n>
                        Include a hint for the correct naming format with
                        invalid-name. (default: False)
  --property-classes <decorator names>
                        List of decorators that produce properties, such as
                        abc.abstractproperty. Add to this list to register
                        other decorators that produce valid properties. These
                        decorators are taken in consideration only for
                        invalid-name. (default: ('abc.abstractproperty',))
  --argument-naming-style <style>
                        Naming style matching correct argument names.
                        (default: snake_case)
  --argument-rgx <regexp>
                        Regular expression matching correct argument names.
                        Overrides argument-naming-style. If left empty,
                        argument names will be checked with the set naming
                        style. (default: None)
  --attr-naming-style <style>
                        Naming style matching correct attribute names.
                        (default: snake_case)
  --attr-rgx <regexp>   Regular expression matching correct attribute names.
                        Overrides attr-naming-style. If left empty, attribute
                        names will be checked with the set naming style.
                        (default: None)
  --class-naming-style <style>
                        Naming style matching correct class names. (default:
                        PascalCase)
  --class-rgx <regexp>  Regular expression matching correct class names.
                        Overrides class-naming-style. If left empty, class
                        names will be checked with the set naming style.
                        (default: None)
  --class-attribute-naming-style <style>
                        Naming style matching correct class attribute names.
                        (default: any)
  --class-attribute-rgx <regexp>
                        Regular expression matching correct class attribute
                        names. Overrides class-attribute-naming-style. If left
                        empty, class attribute names will be checked with the
                        set naming style. (default: None)
  --class-const-naming-style <style>
                        Naming style matching correct class constant names.
                        (default: UPPER_CASE)
  --class-const-rgx <regexp>
                        Regular expression matching correct class constant
                        names. Overrides class-const-naming-style. If left
                        empty, class constant names will be checked with the
                        set naming style. (default: None)
  --const-naming-style <style>
                        Naming style matching correct constant names.
                        (default: UPPER_CASE)
  --const-rgx <regexp>  Regular expression matching correct constant names.
                        Overrides const-naming-style. If left empty, constant
                        names will be checked with the set naming style.
                        (default: None)
  --function-naming-style <style>
                        Naming style matching correct function names.
                        (default: snake_case)
  --function-rgx <regexp>
                        Regular expression matching correct function names.
                        Overrides function-naming-style. If left empty,
                        function names will be checked with the set naming
                        style. (default: None)
  --inlinevar-naming-style <style>
                        Naming style matching correct inline iteration names.
                        (default: any)
  --inlinevar-rgx <regexp>
                        Regular expression matching correct inline iteration
                        names. Overrides inlinevar-naming-style. If left
                        empty, inline iteration names will be checked with the
                        set naming style. (default: None)
  --method-naming-style <style>
                        Naming style matching correct method names. (default:
                        snake_case)
  --method-rgx <regexp>
                        Regular expression matching correct method names.
                        Overrides method-naming-style. If left empty, method
                        names will be checked with the set naming style.
                        (default: None)
  --module-naming-style <style>
                        Naming style matching correct module names. (default:
                        snake_case)
  --module-rgx <regexp>
                        Regular expression matching correct module names.
                        Overrides module-naming-style. If left empty, module
                        names will be checked with the set naming style.
                        (default: None)
  --typevar-rgx <regexp>
                        Regular expression matching correct type variable
                        names. If left empty, type variable names will be
                        checked with the set naming style. (default: None)
  --variable-naming-style <style>
                        Naming style matching correct variable names.
                        (default: snake_case)
  --variable-rgx <regexp>
                        Regular expression matching correct variable names.
                        Overrides variable-naming-style. If left empty,
                        variable names will be checked with the set naming
                        style. (default: None)
  --no-docstring-rgx <regexp>
                        Regular expression which should only match function or
                        class names that do not require a docstring. (default:
                        re.compile('^_'))
  --docstring-min-length <int>
                        Minimum line length for functions/classes that require
                        docstrings, shorter ones are exempt. (default: -1)

Spelling:
  Check spelling in comments and docstrings.

  --spelling-dict <dict name>
                        Spelling dictionary name. Available dictionaries:
                        none. To make it work, install the 'python-enchant'
                        package. (default: )
  --spelling-ignore-words <comma separated words>
                        List of comma separated words that should not be
                        checked. (default: )
  --spelling-private-dict-file <path to file>
                        A path to a file that contains the private dictionary;
                        one word per line. (default: )
  --spelling-store-unknown-words <y or n>
                        Tells whether to store unknown words to the private
                        dictionary (see the --spelling-private-dict-file
                        option) instead of raising a message. (default: n)
  --max-spelling-suggestions N
                        Limits count of emitted suggestions for spelling
                        mistakes. (default: 4)
  --spelling-ignore-comment-directives <comma separated words>
                        List of comma separated words that should be
                        considered directives if they appear at the beginning
                        of a comment and should not be checked. (default: fmt:
                        on,fmt: off,noqa:,noqa,nosec,isort:skip,mypy:)

Exceptions:
  Exception related checks.

  --overgeneral-exceptions <comma-separated class names>
                        Exceptions that will emit a warning when caught.
                        (default: ('BaseException', 'Exception'))

Imports:
  BaseChecker for import statements.

  --deprecated-modules <modules>
                        Deprecated modules which should not be used, separated
                        by a comma. (default: ())
  --preferred-modules <module:preferred-module>
                        Couples of modules and preferred modules, separated by
                        a comma. (default: ())
  --import-graph <file.gv>
                        Output a graph (.gv or any supported image format) of
                        all (i.e. internal and external) dependencies to the
                        given file (report RP0402 must not be disabled).
                        (default: )
  --ext-import-graph <file.gv>
                        Output a graph (.gv or any supported image format) of
                        external dependencies to the given file (report RP0402
                        must not be disabled). (default: )
  --int-import-graph <file.gv>
                        Output a graph (.gv or any supported image format) of
                        internal dependencies to the given file (report RP0402
                        must not be disabled). (default: )
  --known-standard-library <modules>
                        Force import order to recognize a module as part of
                        the standard compatibility libraries. (default: ())
  --known-third-party <modules>
                        Force import order to recognize a module as part of a
                        third party library. (default: ('enchant',))
  --allow-any-import-level <modules>
                        List of modules that can be imported at any level, not
                        just the top level one. (default: ())
  --allow-wildcard-with-all <y or n>
                        Allow wildcard imports from modules that define
                        __all__. (default: False)

Classes:
  Checker for class nodes.

  --defining-attr-methods <method names>
                        List of method names used to declare (i.e. assign)
                        instance attributes. (default: ('__init__', '__new__',
                        'setUp', '__post_init__'))
  --valid-classmethod-first-arg <argument names>
                        List of valid names for the first argument in a class
                        method. (default: ('cls',))
  --valid-metaclass-classmethod-first-arg <argument names>
                        List of valid names for the first argument in a
                        metaclass class method. (default: ('cls',))
  --exclude-protected <protected access exclusions>
                        List of member names, which should be excluded from
                        the protected access warning. (default: ('_asdict',
                        '_fields', '_replace', '_source', '_make'))
  --check-protected-access-in-special-methods <y or n>
                        Warn about protected attribute access inside special
                        methods (default: False)

Logging:
  Checks use of the logging module.

  --logging-modules <comma separated list>
                        Logging modules to check that the string format
                        arguments are in logging function parameter format.
                        (default: ('logging',))
  --logging-format-style <old (%) or new ({)>
                        The type of string formatting that logging methods do.
                        `old` means using % formatting, `new` is for `{}`
                        formatting. (default: old)

String:
  Check string literals.

  --check-str-concat-over-line-jumps <y or n>
                        This flag controls whether the implicit-str-concat
                        should generate a warning on implicit string
                        concatenation in sequences defined over several lines.
                        (default: False)
  --check-quote-consistency <y or n>
                        This flag controls whether inconsistent-quotes
                        generates a warning when the character used as a quote
                        delimiter is used inconsistently within a module.
                        (default: False)

Deprecated_builtins:
  --bad-functions <builtin function names>
                        List of builtins function names that should not be
                        used, separated by a comma (default: ['map',
                        'filter'])

Parameter_documentation:
  Checker for Sphinx, Google, or Numpy style docstrings.

  --accept-no-param-doc <y or n>
                        Whether to accept totally missing parameter
                        documentation in the docstring of a function that has
                        parameters. (default: True)
  --accept-no-raise-doc <y or n>
                        Whether to accept totally missing raises documentation
                        in the docstring of a function that raises an
                        exception. (default: True)
  --accept-no-return-doc <y or n>
                        Whether to accept totally missing return documentation
                        in the docstring of a function that returns a
                        statement. (default: True)
  --accept-no-yields-doc <y or n>
                        Whether to accept totally missing yields documentation
                        in the docstring of a generator. (default: True)
  --default-docstring-type <docstring type>
                        If the docstring type cannot be guessed the specified
                        docstring type will be used. (default: default)

Code_style:
  Checkers that can improve code consistency.

  --max-line-length-suggestions <int>
                        Max line length for which to sill emit suggestions.
                        Used to prevent optional suggestions which would get
                        split by a code formatter (e.g., black). Will default
                        to the setting for ``max-line-length``. (default: 0)

Typing:
  Find issue specifically related to type annotations.

  --runtime-typing <y or n>
                        Set to ``no`` if the app / library does **NOT** need
                        to support runtime introspection of type annotations.
                        If you use type annotations **exclusively** for type
                        checking of an application, you're probably fine. For
                        libraries, evaluate if some users want to access the
                        type hints at runtime first, e.g., through
                        ``typing.get_type_hints``. Applies to Python versions
                        3.7 - 3.9 (default: True)

['something', '', '/opt/miniconda3/envs/testbed/lib/python39.zip', '/opt/miniconda3/envs/testbed/lib/python3.9']
```

**assistant → tool `bash`**

```json
{
  "command": "git diff -- pylint/__init__.py; python -m pytest tests/test_self.py::TestRunTC::test_modify_sys_path -q; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\"; echo \"TASK_CHECK_EXIT=$?\""
}
```

**tool result**

```
diff --git a/pylint/__init__.py b/pylint/__init__.py
index 9f3dd74e..74f07b12 100644
--- a/pylint/__init__.py
+++ b/pylint/__init__.py
@@ -86,7 +86,7 @@ def modify_sys_path() -> None:
     stdlib or pylint's own modules.
     CPython issue: https://bugs.python.org/issue33053
 
-    - Remove the first entry. This will always be either "" or the working directory
+    - Remove the first entry if it is either "" or the working directory
     - Remove the working directory from the second and third entries
       if PYTHONPATH includes a ":" at the beginning or the end.
       https://github.com/PyCQA/pylint/issues/3636
@@ -96,9 +96,10 @@ def modify_sys_path() -> None:
       if pylint is installed in an editable configuration (as the last item).
       https://github.com/PyCQA/pylint/issues/4161
     """
-    sys.path.pop(0)
-    env_pythonpath = os.environ.get("PYTHONPATH", "")
     cwd = os.getcwd()
+    if sys.path[0] in ("", ".", cwd):
+        sys.path.pop(0)
+    env_pythonpath = os.environ.get("PYTHONPATH", "")
     if env_pythonpath.startswith(":") and env_pythonpath not in (f":{cwd}", ":."):
         sys.path.pop(0)
     elif env_pythonpath.endswith(":") and env_pythonpath not in (f"{cwd}:", ".:"):
.                                                                        [100%]
1 passed in 0.08s
TASK_CHECK_EXIT=0
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: tests/test_self.py\n@@\n             paths = [\"\", cwd, *default_paths, cwd]\n             sys.path = copy(paths)\n             with _test_environ_pythonpath(cwd):\n                 modify_sys_path()\n             assert sys.path == paths[1:]\n+\n+            # Do not remove the first entry if it is not the working directory,\n+            # e.g. when running through runpy with a custom sys.path entry.\n+            paths = [\"/custom_pythonpath\", *default_paths]\n+            sys.path = copy(paths)\n+            with _test_environ_pythonpath():\n+                modify_sys_path()\n+            assert sys.path == paths\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[tests/test_self.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/test_self.py now (1388 lines), around the change:
814:                modify_sys_path()
815:            assert sys.path == paths[1:]
816:
817:            # Do not remove the first entry if it is not the working directory,
818:            # e.g. when running through runpy with a custom sys.path entry.
819:            paths = ["/custom_pythonpath", *default_paths]
820:            sys.path = copy(paths)
821:            with _test_environ_pythonpath():
822:                modify_sys_path()
823:            assert sys.path == paths
824:
825:    @pytest.mark.parametrize(
826:        "args",
827:        [
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_self.py::TestRunTC::test_modify_sys_path -q && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\"; echo \"TASK_CHECK_EXIT=$?\""
}
```

**tool result**

```
.                                                                        [100%]
1 passed in 0.16s
TASK_CHECK_EXIT=0
```

**assistant**

```
Fixed `modify_sys_path()` in `pylint/__init__.py`:

- It now only pops the first `sys.path` entry when that entry is `""`, `"."`, or the current working directory, instead of unconditionally removing it.
- Updated the docstring accordingly.
- Added a regression test in `tests/test_self.py` verifying a custom first entry (e.g. inserted by `runpy`/an extension) is preserved.

Verified the repro no longer drops the custom path, the existing test passes, and the task check command exits 0.
```

## Run folder `single-2026-11-06T114931`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
`pylint` removes first item from `sys.path` when running from `runpy`.
### Bug description

This is the line where the first item from sys.path is removed.
https://github.com/PyCQA/pylint/blob/ce7cccf96454fb6e286e4a8f38919733a0f28f44/pylint/__init__.py#L99

I think there should be a check to ensure that the first item is `""`, `"."` or `os.getcwd()` before removing.

### Configuration

_No response_

### Command used

```shell
Run programmatically to repro this, using this code:

import sys
import runpy

sys.path.insert(0, "something")

runpy.run_module('pylint', run_name="__main__", alter_sys=True)
```


### Pylint output

```shell
When using pylint extension which bundles the libraries, the extension add them to sys.path depending on user settings. Pylint removes the first entry from sys path causing it to fail to load.
```


### Expected behavior

Check if  `""`, `"."` or `os.getcwd()` before removing the first item from sys.path

### Pylint version

```shell
pylint 2.14.5
```


### OS / Environment

_No response_

### Additional dependencies

_No response_
````
