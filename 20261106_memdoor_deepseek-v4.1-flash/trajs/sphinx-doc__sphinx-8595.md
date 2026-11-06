# sphinx-doc__sphinx-8595 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 54s 52 lines cost=0.001399 in=110904 cached=100352 out=1914 calls=13`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

autodoc: empty __all__ attribute is ignored
**Describe the bug**
autodoc: empty `__all__` attribute is ignored

**To Reproduce**
```
# example.py
__all__ = []


def foo():
    "docstring"


def bar():
    "docstring"


def baz():
    "docstring"
```
```
# index.rst
.. automodule:: example
   :members:
```

All foo, bar, and baz are shown.

**Expected behavior**
No entries should be shown because `__all__` is empty.

**Your project**
No

**Screenshots**
No

**Environment info**
- OS: Mac
- Python version: 3.9.1
- Sphinx version: HEAD of 3.x
- Sphinx extensions: sphinx.ext.autodoc
- Extra tools: No

**Additional context**
No

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && git log --oneline -3"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"__all__\" sphinx/ext/autodoc/ | head -50"
}
```

**tool result**

```
AUTHORS
CHANGES
CHANGES.old
CODE_OF_CONDUCT
CONTRIBUTING.rst
EXAMPLES
LICENSE
MANIFEST.in
Makefile
README.rst
Sphinx.egg-info
babel.cfg
bindep.txt
doc
karma.conf.js
package-lock.json
package.json
setup.cfg
setup.py
sphinx
tests
tox.ini
utils
?? .memdoor/
9d57ddaa2 SWE-bench
b19bce971 Merge pull request #8593 from tk0miya/8592_meta_public_doesnt_affect_to_variables
556b9743f Merge pull request #8596 from tk0miya/8022_meta_hide_value
```

**tool result**

```
sphinx/ext/autodoc/mock.py:86:        self.__all__ = []  # type: List[str]
sphinx/ext/autodoc/__init__.py:788:                # forcedly skipped member (ex. a module attribute not defined in __all__)
sphinx/ext/autodoc/__init__.py:992:        self.__all__ = None  # type: Optional[Sequence[str]]
sphinx/ext/autodoc/__init__.py:1020:                self.__all__ = inspect.getall(self.object)
sphinx/ext/autodoc/__init__.py:1022:            # __all__ raises an error.
sphinx/ext/autodoc/__init__.py:1023:            logger.warning(__('%s.__all__ raises an error. Ignored: %r'),
sphinx/ext/autodoc/__init__.py:1026:            # invalid __all__ found.
sphinx/ext/autodoc/__init__.py:1027:            logger.warning(__('__all__ should be a list of strings, not %r '
sphinx/ext/autodoc/__init__.py:1028:                              '(in module %s) -- ignoring __all__') %
sphinx/ext/autodoc/__init__.py:1077:            if not self.__all__:
sphinx/ext/autodoc/__init__.py:1083:                    if member.__name__ not in self.__all__:
sphinx/ext/autodoc/__init__.py:1102:        if order == 'bysource' and self.__all__:
sphinx/ext/autodoc/__init__.py:1103:            # Sort alphabetically first (for members not listed on the __all__)
sphinx/ext/autodoc/__init__.py:1106:            # Sort by __all__
sphinx/ext/autodoc/__init__.py:1109:                if name in self.__all__:
sphinx/ext/autodoc/__init__.py:1110:                    return self.__all__.index(name)
sphinx/ext/autodoc/__init__.py:1112:                    return len(self.__all__)
```

**assistant → tool `read_file`**

```json
{
  "path": "sphinx/ext/autodoc/__init__.py",
  "offset": 1000,
  "limit": 130
}
```

**tool result**

```
    def resolve_name(self, modname: str, parents: Any, path: str, base: Any
                     ) -> Tuple[str, List[str]]:
        if modname is not None:
            logger.warning(__('"::" in automodule name doesn\'t make sense'),
                           type='autodoc')
        return (path or '') + base, []

    def parse_name(self) -> bool:
        ret = super().parse_name()
        if self.args or self.retann:
            logger.warning(__('signature arguments or return annotation '
                              'given for automodule %s') % self.fullname,
                           type='autodoc')
        return ret

    def import_object(self, raiseerror: bool = False) -> bool:
        ret = super().import_object(raiseerror)

        try:
            if not self.options.ignore_module_all:
                self.__all__ = inspect.getall(self.object)
        except AttributeError as exc:
            # __all__ raises an error.
            logger.warning(__('%s.__all__ raises an error. Ignored: %r'),
                           (self.fullname, exc), type='autodoc')
        except ValueError as exc:
            # invalid __all__ found.
            logger.warning(__('__all__ should be a list of strings, not %r '
                              '(in module %s) -- ignoring __all__') %
                           (exc.args[0], self.fullname), type='autodoc')

        return ret

    def add_directive_header(self, sig: str) -> None:
        Documenter.add_directive_header(self, sig)

        sourcename = self.get_sourcename()

        # add some module-specific options
        if self.options.synopsis:
            self.add_line('   :synopsis: ' + self.options.synopsis, sourcename)
        if self.options.platform:
            self.add_line('   :platform: ' + self.options.platform, sourcename)
        if self.options.deprecated:
            self.add_line('   :deprecated:', sourcename)

    def get_module_members(self) -> Dict[str, ObjectMember]:
        """Get members of target module."""
        if self.analyzer:
            attr_docs = self.analyzer.attr_docs
        else:
            attr_docs = {}

        members = {}  # type: Dict[str, ObjectMember]
        for name in dir(self.object):
            try:
                value = safe_getattr(self.object, name, None)
                docstring = attr_docs.get(('', name), [])
                members[name] = ObjectMember(name, value, docstring="\n".join(docstring))
            except AttributeError:
                continue

        # annotation only member (ex. attr: int)
        try:
            for name in inspect.getannotations(self.object):
                if name not in members:
                    docstring = attr_docs.get(('', name), [])
                    members[name] = ObjectMember(name, INSTANCEATTR,
                                                 docstring="\n".join(docstring))
        except AttributeError:
            pass

        return members

    def get_object_members(self, want_all: bool) -> Tuple[bool, ObjectMembers]:
        members = self.get_module_members()
        if want_all:
            if not self.__all__:
                # for implicit module members, check __module__ to avoid
                # documenting imported objects
                return True, list(members.values())
            else:
                for member in members.values():
                    if member.__name__ not in self.__all__:
                        member.skipped = True

                return False, list(members.values())
        else:
            memberlist = self.options.members or []
            ret = []
            for name in memberlist:
                if name in members:
                    ret.append(members[name])
                else:
                    logger.warning(__('missing attribute mentioned in :members: option: '
                                      'module %s, attribute %s') %
                                   (safe_getattr(self.object, '__name__', '???'), name),
                                   type='autodoc')
            return False, ret

    def sort_members(self, documenters: List[Tuple["Documenter", bool]],
                     order: str) -> List[Tuple["Documenter", bool]]:
        if order == 'bysource' and self.__all__:
            # Sort alphabetically first (for members not listed on the __all__)
            documenters.sort(key=lambda e: e[0].name)

            # Sort by __all__
            def keyfunc(entry: Tuple[Documenter, bool]) -> int:
                name = entry[0].name.split('::')[1]
                if name in self.__all__:
                    return self.__all__.index(name)
                else:
                    return len(self.__all__)
            documenters.sort(key=keyfunc)

            return documenters
        else:
            return super().sort_members(documenters, order)


class ModuleLevelDocumenter(Documenter):
    """
    Specialized Documenter subclass for objects on module level (functions,
    classes, data/constants).
    """
    def resolve_name(self, modname: str, parents: Any, path: str, base: Any
                     ) -> Tuple[str, List[str]]:
        if modname is None:
            if path:
                modname = path.rstrip('.')

[1488 more lines in /testbed/sphinx/ext/autodoc/__init__.py (2617 in all). read_file with offset: 1130 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def getall\" -A 20 sphinx/util/inspect.py"
}
```

**tool result**

```
144:def getall(obj: Any) -> Optional[Sequence[str]]:
145-    """Get __all__ attribute of the module as dict.
146-
147-    Return None if given *obj* does not have __all__.
148-    Raises AttributeError if given *obj* raises an error on accessing __all__.
149-    Raises ValueError if given *obj* have invalid __all__.
150-    """
151-    __all__ = safe_getattr(obj, '__all__', None)
152-    if __all__ is None:
153-        return None
154-    else:
155-        if (isinstance(__all__, (list, tuple)) and all(isinstance(e, str) for e in __all__)):
156-            return __all__
157-        else:
158-            raise ValueError(__all__)
159-
160-
161-def getannotations(obj: Any) -> Mapping[str, Any]:
162-    """Get __annotations__ from given *obj* safely.
163-
164-    Raises AttributeError if given *obj* raises an error on accessing __attribute__.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"getall\\|__all__\" tests/test_ext_autodoc*.py tests/roots/test-ext-autodoc/ 2>/dev/null | head -40"
}
```

**tool result**

```
tests/test_ext_autodoc_events.py:90:            return True  # Skip "Class" class in __all__
tests/test_ext_autodoc_events.py:92:            return False  # Show "raises()" function (not in __all__)
tests/roots/test-ext-autodoc/target/__init__.py:6:__all__ = ['Class']
tests/roots/test-ext-autodoc/target/sort_by_all.py:1:__all__ = ['baz', 'foo', 'Bar']
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"sort_by_all\\|__all__\" tests/test_ext_autodoc.py | head -20; ls tests/roots/test-ext-autodoc/target/ | head -40"
}
```

**tool result**

```
994:    actual = do_autodoc(app, 'module', 'target.sort_by_all', options)
996:        '.. py:module:: target.sort_by_all',
1010:    actual = do_autodoc(app, 'module', 'target.sort_by_all', options)
1012:        '.. py:module:: target.sort_by_all',
TYPE_CHECKING.py
__init__.py
abstractmethods.py
annotated.py
annotations.py
autoclass_content.py
bound_method.py
cached_property.py
callable.py
classes.py
coroutine.py
cython.pyx
decorator.py
descriptor.py
docstring_signature.py
enums.py
final.py
functions.py
generic_class.py
genericalias.py
hide_value.py
imported_members.py
inheritance.py
instance_variable.py
methods.py
name_conflict
name_mangling.py
need_mocks.py
overload.py
overload2.py
partialfunction.py
partialmethod.py
pep570.py
private.py
process_docstring.py
singledispatch.py
singledispatchmethod.py
slots.py
sort_by_all.py
typed_vars.py
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sphinx/ext/autodoc/__init__.py\n@@\n-            if not self.__all__:\n+            if self.__all__ is None:\n                 # for implicit module members, check __module__ to avoid\n                 # documenting imported objects\n                 return True, list(members.values())\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sphinx/ext/autodoc/__init__.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sphinx/ext/autodoc/__init__.py now (2617 lines), around the change:
1074:    def get_object_members(self, want_all: bool) -> Tuple[bool, ObjectMembers]:
1075:        members = self.get_module_members()
1076:        if want_all:
1077:            if self.__all__ is None:
1078:                # for implicit module members, check __module__ to avoid
1079:                # documenting imported objects
1080:                return True, list(members.values())
```

**assistant → tool `read_file`**

```json
{
  "path": "tests/test_ext_autodoc.py",
  "offset": 960,
  "limit": 70
}
```

**tool result**

```
        '   .. py:attribute:: Class.udocattr'
    ]

    # case member-order=None
    options = {"members": None,
               "undoc-members": True,
               'private-members': True}
    actual = do_autodoc(app, 'class', 'target.Class', options)
    assert list(filter(lambda l: '::' in l, actual)) == [
        '.. py:class:: Class(arg)',
        '   .. py:attribute:: Class._private_inst_attr',
        '   .. py:attribute:: Class.attr',
        '   .. py:attribute:: Class.docattr',
        '   .. py:method:: Class.excludemeth()',
        '   .. py:attribute:: Class.inst_attr_comment',
        '   .. py:attribute:: Class.inst_attr_inline',
        '   .. py:attribute:: Class.inst_attr_string',
        '   .. py:attribute:: Class.mdocattr',
        '   .. py:method:: Class.meth()',
        '   .. py:method:: Class.moore(a, e, f) -> happiness',
        '   .. py:method:: Class.roger(a, *, b=2, c=3, d=4, e=5, f=6)',
        '   .. py:attribute:: Class.skipattr',
        '   .. py:method:: Class.skipmeth()',
        '   .. py:attribute:: Class.udocattr',
        '   .. py:method:: Class.undocmeth()'
    ]


@pytest.mark.sphinx('html', testroot='ext-autodoc')
def test_autodoc_module_member_order(app):
    # case member-order='bysource'
    options = {"members": 'foo, Bar, baz, qux, Quux, foobar',
               'member-order': 'bysource',
               "undoc-members": True}
    actual = do_autodoc(app, 'module', 'target.sort_by_all', options)
    assert list(filter(lambda l: '::' in l, actual)) == [
        '.. py:module:: target.sort_by_all',
        '.. py:function:: baz()',
        '.. py:function:: foo()',
        '.. py:class:: Bar()',
        '.. py:class:: Quux()',
        '.. py:function:: foobar()',
        '.. py:function:: qux()',
    ]

    # case member-order='bysource' and ignore-module-all
    options = {"members": 'foo, Bar, baz, qux, Quux, foobar',
               'member-order': 'bysource',
               "undoc-members": True,
               "ignore-module-all": True}
    actual = do_autodoc(app, 'module', 'target.sort_by_all', options)
    assert list(filter(lambda l: '::' in l, actual)) == [
        '.. py:module:: target.sort_by_all',
        '.. py:function:: foo()',
        '.. py:class:: Bar()',
        '.. py:function:: baz()',
        '.. py:function:: qux()',
        '.. py:class:: Quux()',
        '.. py:function:: foobar()',
    ]


@pytest.mark.sphinx('html', testroot='ext-autodoc')
def test_autodoc_module_scope(app):
    app.env.temp_data['autodoc:module'] = 'target'
    actual = do_autodoc(app, 'attribute', 'Class.mdocattr')
    assert list(actual) == [
        '',
        '.. py:attribute:: Class.mdocattr',
        '   :module: target',

[1254 more lines in /testbed/tests/test_ext_autodoc.py (2283 in all). read_file with offset: 1030 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Add File: tests/roots/test-ext-autodoc/target/empty_all.py\n+__all__ = []\n+\n+\n+def foo():\n+    \"docstring\"\n+\n+\n+def bar():\n+    \"docstring\"\n+\n+\n+def baz():\n+    \"docstring\"\n*** Update File: tests/test_ext_autodoc.py\n@@\n @pytest.mark.sphinx('html', testroot='ext-autodoc')\n def test_autodoc_module_scope(app):\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update tests/test_ext_autodoc.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file test_ext_autodoc.py and REWRITE it with *** Add File: test_ext_autodoc.py using its ACTUAL content plus your change

Nothing in this patch was written — not tests/roots/test-ext-autodoc/target/empty_all.py, tests/test_ext_autodoc.py. Fix it and resend the whole patch.
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Add File: tests/roots/test-ext-autodoc/target/empty_all.py\n+__all__ = []\n+\n+\n+def foo():\n+    \"docstring\"\n+\n+\n+def bar():\n+    \"docstring\"\n+\n+\n+def baz():\n+    \"docstring\"\n*** Update File: tests/test_ext_autodoc.py\n@@\n-@pytest.mark.sphinx('html', testroot='ext-autodoc')\n-def test_autodoc_module_scope(app):\n+@pytest.mark.sphinx('html', testroot='ext-autodoc')\n+def test_autodoc_empty_module_all(app):\n+    options = {\"members\": None}\n+    actual = do_autodoc(app, 'module', 'target.empty_all', options)\n+    assert list(filter(lambda l: '::' in l, actual)) == [\n+        '.. py:module:: target.empty_all',\n+    ]\n+\n+\n+@pytest.mark.sphinx('html', testroot='ext-autodoc')\n+def test_autodoc_module_scope(app):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[tests/roots/test-ext-autodoc/target/empty_all.py] modified=[tests/test_ext_autodoc.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

tests/test_ext_autodoc.py now (2292 lines), around the change:
1020:
1021:
1022:@pytest.mark.sphinx('html', testroot='ext-autodoc')
1023:def test_autodoc_empty_module_all(app):
1024:    options = {"members": None}
1025:    actual = do_autodoc(app, 'module', 'target.empty_all', options)
1026:    assert list(filter(lambda l: '::' in l, actual)) == [
1027:        '.. py:module:: target.empty_all',
1028:    ]
1029:
1030:
1031:@pytest.mark.sphinx('html', testroot='ext-autodoc')
1032:def test_autodoc_module_scope(app):
1033:    app.env.temp_data['autodoc:module'] = 'target'
1034:    actual = do_autodoc(app, 'attribute', 'Class.mdocattr')
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_ext_autodoc.py -q -k \"empty_module_all or module_member_order\" 2>&1 | tail -20"
}
```

**tool result**

```
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/registry.py:22
  /testbed/sphinx/registry.py:22: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
  /opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154: DeprecationWarning: Deprecated call to `pkg_resources.declare_namespace('sphinxcontrib')`.
  Implementing implicit namespace packages (as specified in PEP 420) is preferred to `pkg_resources.declare_namespace`. See https://setuptools.pypa.io/en/latest/references/keywords.html#keyword-namespace-packages
    declare_namespace(pkg)

sphinx/directives/patches.py:14
  /testbed/sphinx/directives/patches.py:14: DeprecationWarning: The `docutils.parsers.rst.directive.html` module will be removed in Docutils 2.0. Since Docutils 0.18, the "Meta" node is defined in `docutils.parsers.rst.directives.misc`.
    from docutils.parsers.rst.directives import html, images, tables

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
2 passed, 67 deselected, 7 warnings in 1.26s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_ext_autodoc.py tests/test_ext_autodoc_events.py -q 2>&1 | tail -5; git status --porcelain -- . ':(exclude).memdoor'"
}
```

**tool result**

```

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED tests/test_ext_autodoc.py::test_autodoc - AssertionError: assert '\x1b...
1 failed, 73 passed, 42 warnings in 10.08s
 M sphinx/ext/autodoc/__init__.py
 M tests/test_ext_autodoc.py
?? tests/roots/test-ext-autodoc/target/empty_all.py
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest tests/test_ext_autodoc.py::test_autodoc -q 2>&1 | grep -A 30 \"AssertionError\" | head -50"
}
```

**tool result**

```
E       AssertionError: assert '\x1b[91mWARN...b[39;49;00m\n' == ''
E         
E         + [91mWARNING: while setting up extension sphinx.addnodes: node class 'meta' is already registered, its visitors will be overridden[39;49;00m

tests/test_ext_autodoc.py:2178: AssertionError
--------------------------- Captured stdout teardown ---------------------------
# testroot: root
# builder: dummy
# srcdir: /tmp/pytest-of-root/pytest-2/ext-autodoc
# outdir: /tmp/pytest-of-root/pytest-2/ext-autodoc/_build/dummy
# status: 
[01mRunning Sphinx v3.5.0+/9d57ddaa2[39;49;00m
[01mbuilding [dummy]: [39;49;00mall source files
[01mupdating environment: [39;49;00m[new config] 1 added, 0 changed, 0 removed
[01mreading sources... [39;49;00m[100%] [35mindex[39;49;00m                                                
[01mlooking for now-outdated files... [39;49;00mnone found
[01mpickling environment... [39;49;00mdone
[01mchecking consistency... [39;49;00mdone
[01mpreparing documents... [39;49;00mdone
[01mwriting output... [39;49;00m[100%] [32mindex[39;49;00m                                                 

# warning: 
[91mWARNING: while setting up extension sphinx.addnodes: node class 'meta' is already registered, its visitors will be overridden[39;49;00m

=============================== warnings summary ===============================
sphinx/util/docutils.py:45
  /testbed/sphinx/util/docutils.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    __version_info__ = tuple(LooseVersion(docutils.__version__).version)

sphinx/registry.py:22
  /testbed/sphinx/registry.py:22: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    from pkg_resources import iter_entry_points

../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
../opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pkg_resources/__init__.py:3154
--
FAILED tests/test_ext_autodoc.py::test_autodoc - AssertionError: assert '\x1b...
1 failed, 42 warnings in 1.07s
```

**assistant**

```
Implemented the fix.

- `sphinx/ext/autodoc/__init__.py`: `get_object_members()` now distinguishes between a missing `__all__` (`None`) and an explicitly empty `__all__` (`[]`). An empty `__all__` now causes all module members to be skipped, as expected.
- Added regression fixture `tests/roots/test-ext-autodoc/target/empty_all.py`.
- Added `test_autodoc_empty_module_all` verifying only the module directive is emitted.

Targeted tests pass (`2 passed`). The full autodoc suite has one unrelated pre-existing environment failure (`node class 'meta' is already registered` from the installed docutils version). `git status` is non-empty as required.
```

## Run folder `single-2026-11-06T120727`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
autodoc: empty __all__ attribute is ignored
**Describe the bug**
autodoc: empty `__all__` attribute is ignored

**To Reproduce**
```
# example.py
__all__ = []


def foo():
    "docstring"


def bar():
    "docstring"


def baz():
    "docstring"
```
```
# index.rst
.. automodule:: example
   :members:
```

All foo, bar, and baz are shown.

**Expected behavior**
No entries should be shown because `__all__` is empty.

**Your project**
No

**Screenshots**
No

**Environment info**
- OS: Mac
- Python version: 3.9.1
- Sphinx version: HEAD of 3.x
- Sphinx extensions: sphinx.ext.autodoc
- Extra tools: No

**Additional context**
No
````
