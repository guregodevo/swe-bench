# astropy__astropy-7166 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 69s 67 lines cost=0.004502 in=94456 cached=56320 out=8594 calls=12`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

InheritDocstrings metaclass doesn't work for properties
Inside the InheritDocstrings metaclass it uses `inspect.isfunction` which returns `False` for properties.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && grep -rn \"InheritDocstrings\" --include=*.py . | head -50"
}
```

**tool result**

```
CHANGES.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.md
LICENSE.rst
MANIFEST.in
README.rst
__pycache__
ah_bootstrap.py
appveyor.yml
astropy
astropy.egg-info
astropy_helpers
build
cextern
conftest.py
docs
examples
ez_setup.py
licenses
pip-requirements
pip-requirements-dev
pip-requirements-doc
readthedocs.yml
setup.cfg
setup.py
static
./astropy/io/votable/tree.py:24:from ...utils.misc import InheritDocstrings
./astropy/io/votable/tree.py:406:class Element(metaclass=InheritDocstrings):
./astropy/utils/misc.py:33:           'JsonCustomEncoder', 'indent', 'InheritDocstrings',
./astropy/utils/misc.py:497:class InheritDocstrings(type):
./astropy/utils/misc.py:511:        >>> from astropy.utils.misc import InheritDocstrings
./astropy/utils/misc.py:512:        >>> class A(metaclass=InheritDocstrings):
./astropy/utils/tests/test_misc.py:78:    class Base(metaclass=misc.InheritDocstrings):
./astropy/config/configuration.py:23:from ..utils.misc import InheritDocstrings
./astropy/config/configuration.py:160:class ConfigItem(metaclass=InheritDocstrings):
./astropy/visualization/interval.py:12:from ..utils.misc import InheritDocstrings
./astropy/visualization/interval.py:21:class BaseInterval(BaseTransform, metaclass=InheritDocstrings):
./astropy/visualization/stretch.py:11:from ..utils.misc import InheritDocstrings
./astropy/visualization/stretch.py:47:class BaseStretch(BaseTransform, metaclass=InheritDocstrings):
./astropy/constants/constant.py:12:from ..utils.misc import InheritDocstrings
./astropy/constants/constant.py:17:class ConstantMeta(InheritDocstrings):
./astropy/coordinates/representation.py:24:from ..utils.misc import InheritDocstrings
./astropy/coordinates/representation.py:427:class MetaBaseRepresentation(InheritDocstrings, abc.ABCMeta):
./astropy/coordinates/representation.py:1934:class MetaBaseDifferential(InheritDocstrings, abc.ABCMeta):
./astropy/units/core.py:18:from ..utils.misc import isiterable, InheritDocstrings
./astropy/units/core.py:486:class UnitBase(metaclass=InheritDocstrings):
./astropy/units/core.py:1730:class _UnitMetaClass(InheritDocstrings):
./astropy/units/format/base.py:2:from ...utils.misc import InheritDocstrings
./astropy/units/format/base.py:5:class _FormatterMeta(InheritDocstrings):
./astropy/units/quantity.py:26:from ..utils.misc import isiterable, InheritDocstrings
./astropy/units/quantity.py:200:class Quantity(np.ndarray, metaclass=InheritDocstrings):
./astropy/modeling/core.py:39:                     InheritDocstrings, OrderedDescriptorContainer,
./astropy/modeling/core.py:78:class _ModelMeta(OrderedDescriptorContainer, InheritDocstrings, abc.ABCMeta):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '490,560p' astropy/utils/misc.py && sed -n '60,130p' astropy/utils/tests/test_misc.py"
}
```

**tool result**

```
            matches = (', '.join(matches[:-1]) + ' or ' +
                       matches[-1])
        return 'Did you mean {0}?'.format(matches)

    return ''


class InheritDocstrings(type):
    """
    This metaclass makes methods of a class automatically have their
    docstrings filled in from the methods they override in the base
    class.

    If the class uses multiple inheritance, the docstring will be
    chosen from the first class in the bases list, in the same way as
    methods are normally resolved in Python.  If this results in
    selecting the wrong docstring, the docstring will need to be
    explicitly included on the method.

    For example::

        >>> from astropy.utils.misc import InheritDocstrings
        >>> class A(metaclass=InheritDocstrings):
        ...     def wiggle(self):
        ...         "Wiggle the thingamajig"
        ...         pass
        >>> class B(A):
        ...     def wiggle(self):
        ...         pass
        >>> B.wiggle.__doc__
        u'Wiggle the thingamajig'
    """

    def __init__(cls, name, bases, dct):
        def is_public_member(key):
            return (
                (key.startswith('__') and key.endswith('__')
                 and len(key) > 4) or
                not key.startswith('_'))

        for key, val in dct.items():
            if (inspect.isfunction(val) and
                is_public_member(key) and
                val.__doc__ is None):
                for base in cls.__mro__[1:]:
                    super_method = getattr(base, key, None)
                    if super_method is not None:
                        val.__doc__ = super_method.__doc__
                        break

        super().__init__(name, bases, dct)


class OrderedDescriptor(metaclass=abc.ABCMeta):
    """
    Base class for descriptors whose order in the class body should be
    preserved.  Intended for use in concert with the
    `OrderedDescriptorContainer` metaclass.

    Subclasses of `OrderedDescriptor` must define a value for a class attribute
    called ``_class_attribute_``.  This is the name of a class attribute on the
    *container* class for these descriptors, which will be set to an
    `~collections.OrderedDict` at class creation time.  This
    `~collections.OrderedDict` will contain a mapping of all class attributes
    that were assigned instances of the `OrderedDescriptor` subclass, to the
    instances themselves.  See the documentation for
    `OrderedDescriptorContainer` for a concrete example.

    Optionally, subclasses of `OrderedDescriptor` may define a value for a
    class attribute called ``_name_attribute_``.  This should be the name of
    an attribute on instances of the subclass.  When specified, during
                      cls=misc.JsonCustomEncoder) == '{"1": 2}'  # default
    assert json.dumps({1: u.m}, cls=misc.JsonCustomEncoder) == '{"1": "m"}'
    # Quantities
    tmp = json.dumps({'a': 5*u.cm}, cls=misc.JsonCustomEncoder)
    newd = json.loads(tmp)
    tmpd = {"a": {"unit": "cm", "value": 5.0}}
    assert newd == tmpd
    tmp2 = json.dumps({'a': np.arange(2)*u.cm}, cls=misc.JsonCustomEncoder)
    newd = json.loads(tmp2)
    tmpd = {"a": {"unit": "cm", "value": [0., 1.]}}
    assert newd == tmpd
    tmp3 = json.dumps({'a': np.arange(2)*u.erg/u.s}, cls=misc.JsonCustomEncoder)
    newd = json.loads(tmp3)
    tmpd = {"a": {"unit": "erg / s", "value": [0., 1.]}}
    assert newd == tmpd


def test_inherit_docstrings():
    class Base(metaclass=misc.InheritDocstrings):
        def __call__(self, *args):
            "FOO"
            pass

    class Subclass(Base):
        def __call__(self, *args):
            pass

    if Base.__call__.__doc__ is not None:
        # TODO: Maybe if __doc__ is None this test should be skipped instead?
        assert Subclass.__call__.__doc__ == "FOO"


def test_set_locale():
    # First, test if the required locales are available
    current = locale.setlocale(locale.LC_ALL)
    try:
        locale.setlocale(locale.LC_ALL, str('en_US'))
        locale.setlocale(locale.LC_ALL, str('de_DE'))
    except locale.Error as e:
        pytest.skip('Locale error: {}'.format(e))
    finally:
        locale.setlocale(locale.LC_ALL, current)

    date = datetime(2000, 10, 1, 0, 0, 0)
    day_mon = date.strftime('%a, %b')

    with misc.set_locale('en_US'):
        assert date.strftime('%a, %b') == 'Sun, Oct'

    with misc.set_locale('de_DE'):
        assert date.strftime('%a, %b') == 'So, Okt'

    # Back to original
    assert date.strftime('%a, %b') == day_mon

    with misc.set_locale(current):
        assert date.strftime('%a, %b') == day_mon


def test_check_broadcast():
    assert misc.check_broadcast((10, 1), (3,)) == (10, 3)
    assert misc.check_broadcast((10, 1), (3,), (4, 1, 1, 3)) == (4, 1, 10, 3)
    with pytest.raises(ValueError):
        misc.check_broadcast((10, 2), (3,))

    with pytest.raises(ValueError):
        misc.check_broadcast((10, 1), (3,), (4, 1, 2, 3))


def test_dtype_bytes_or_chars():
    assert misc.dtype_bytes_or_chars(np.dtype(np.float64)) == 8
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport sys\nprint(sys.version)\nclass A:\n    @property\n    def x(self):\n        \"doc\"\n        pass\np = A.__dict__['x']\nprint(p.__doc__, p.fget.__doc__)\ntry:\n    p.__doc__ = 'new'\n    print('writable', p.__doc__, p.fget.__doc__)\nexcept Exception as e:\n    print('not writable', type(e), e)\nEOF"
}
```

**tool result**

```
3.6.13 |Anaconda, Inc.| (default, Jun  4 2021, 14:25:59) 
[GCC 7.5.0]
doc doc
writable new doc
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: astropy/utils/misc.py\n@@\n-        for key, val in dct.items():\n-            if (inspect.isfunction(val) and\n-                is_public_member(key) and\n-                val.__doc__ is None):\n+        for key, val in dct.items():\n+            if (not is_public_member(key) or\n+                    not (inspect.isfunction(val) or\n+                         isinstance(val, property)) or\n+                    val.__doc__ is not None):\n+                continue\n+\n+            if isinstance(val, property):\n+                # A property's docstring comes from its getter, but the\n+                # property object itself also has a writable __doc__.  Set\n+                # both so that the inherited documentation is visible both\n+                # through the property and through its getter.\n+                fget = val.fget\n+                if fget is not None and fget.__doc__ is None:\n+                    for base in cls.__mro__[1:]:\n+                        super_method = getattr(base, key, None)\n+                        if super_method is not None:\n+                            fget.__doc__ = super_method.__doc__\n+                            val.__doc__ = super_method.__doc__\n+                            break\n+            else:\n                 for base in cls.__mro__[1:]:\n                     super_method = getattr(base, key, None)\n                     if super_method is not None:\n                         val.__doc__ = super_method.__doc__\n                         break\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[astropy/utils/misc.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

astropy/utils/misc.py now (1146 lines), around the change:
528:                not key.startswith('_'))
529:
530:        for key, val in dct.items():
531:            if (not is_public_member(key) or
532:                    not (inspect.isfunction(val) or
533:                         isinstance(val, property)) or
534:                    val.__doc__ is not None):
535:                continue
536:
537:            if isinstance(val, property):
538:                # A property's docstring comes from its getter, but the
539:                # property object itself also has a writable __doc__.  Set
540:                # both so that the inherited documentation is visible both
541:                # through the property and through its getter.
542:                fget = val.fget
543:                if fget is not None and fget.__doc__ is None:
544:                    for base in cls.__mro__[1:]:
545:                        super_method = getattr(base, key, None)
546:                        if super_method is not None:
547:                            fget.__doc__ = super_method.__doc__
548:                            val.__doc__ = super_method.__doc__
549:                            break
550:            else:
551:                for base in cls.__mro__[1:]:
552:                    super_method = getattr(base, key, None)
553:                    if super_method is not None:
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: astropy/utils/misc.py\n@@\n-        for key, val in dct.items():\n-            if (not is_public_member(key) or\n-                    not (inspect.isfunction(val) or\n-                         isinstance(val, property)) or\n-                    val.__doc__ is not None):\n-                continue\n-\n-            if isinstance(val, property):\n-                # A property's docstring comes from its getter, but the\n-                # property object itself also has a writable __doc__.  Set\n-                # both so that the inherited documentation is visible both\n-                # through the property and through its getter.\n-                fget = val.fget\n-                if fget is not None and fget.__doc__ is None:\n-                    for base in cls.__mro__[1:]:\n-                        super_method = getattr(base, key, None)\n-                        if super_method is not None:\n-                            fget.__doc__ = super_method.__doc__\n-                            val.__doc__ = super_method.__doc__\n-                            break\n-            else:\n-                for base in cls.__mro__[1:]:\n-                    super_method = getattr(base, key, None)\n-                    if super_method is not None:\n-                        val.__doc__ = super_method.__doc__\n-                        break\n+        for key, val in dct.items():\n+            if not is_public_member(key):\n+                continue\n+\n+            if inspect.isfunction(val):\n+                if val.__doc__ is None:\n+                    for base in cls.__mro__[1:]:\n+                        super_method = getattr(base, key, None)\n+                        if super_method is not None:\n+                            val.__doc__ = super_method.__doc__\n+                            break\n+\n+            elif isinstance(val, property):\n+                # A property's docstring is normally taken from its getter,\n+                # but the property object itself has a writable __doc__.\n+                # Set both so the inherited documentation is visible both\n+                # through the property and through its getter.\n+                if val.__doc__ is not None:\n+                    continue\n+                for base in cls.__mro__[1:]:\n+                    super_method = getattr(base, key, None)\n+                    if super_method is not None:\n+                        val.__doc__ = super_method.__doc__\n+                        if val.fget is not None and val.fget.__doc__ is None:\n+                            val.fget.__doc__ = super_method.__doc__\n+                        break\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[astropy/utils/misc.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

astropy/utils/misc.py now (1146 lines), around the change:
528:                not key.startswith('_'))
529:
530:        for key, val in dct.items():
531:            if not is_public_member(key):
532:                continue
533:
534:            if inspect.isfunction(val):
535:                if val.__doc__ is None:
536:                    for base in cls.__mro__[1:]:
537:                        super_method = getattr(base, key, None)
538:                        if super_method is not None:
539:                            val.__doc__ = super_method.__doc__
540:                            break
541:
542:            elif isinstance(val, property):
543:                # A property's docstring is normally taken from its getter,
544:                # but the property object itself has a writable __doc__.
545:                # Set both so the inherited documentation is visible both
546:                # through the property and through its getter.
547:                if val.__doc__ is not None:
548:                    continue
549:                for base in cls.__mro__[1:]:
550:                    super_method = getattr(base, key, None)
551:                    if super_method is not None:
552:                        val.__doc__ = super_method.__doc__
553:                        if val.fget is not None and val.fget.__doc__ is None:
554:                            val.fget.__doc__ = super_method.__doc__
555:                        break
556:
557:        super().__init__(name, bases, dct)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: astropy/utils/tests/test_misc.py\n@@\n def test_inherit_docstrings():\n@@\n     if Base.__call__.__doc__ is not None:\n         # TODO: Maybe if __doc__ is None this test should be skipped instead?\n         assert Subclass.__call__.__doc__ == \"FOO\"\n \n \n+def test_inherit_docstrings_property():\n+    class Base(metaclass=misc.InheritDocstrings):\n+        @property\n+        def prop(self):\n+            \"PROPERTY\"\n+            return 1\n+\n+    class Subclass(Base):\n+        @property\n+        def prop(self):\n+            return 2\n+\n+    assert Subclass.__dict__['prop'].__doc__ == \"PROPERTY\"\n+    assert Subclass.prop.__doc__ == \"PROPERTY\"\n+    assert Subclass().prop == 2\n+\n+\n def test_set_locale():\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[astropy/utils/tests/test_misc.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

astropy/utils/tests/test_misc.py now (151 lines), around the change:
89:        assert Subclass.__call__.__doc__ == "FOO"
90:
91:
92:def test_inherit_docstrings_property():
93:    class Base(metaclass=misc.InheritDocstrings):
94:        @property
95:        def prop(self):
96:            "PROPERTY"
97:            return 1
98:
99:    class Subclass(Base):
100:        @property
101:        def prop(self):
102:            return 2
103:
104:    assert Subclass.__dict__['prop'].__doc__ == "PROPERTY"
105:    assert Subclass.prop.__doc__ == "PROPERTY"
106:    assert Subclass().prop == 2
107:
108:
109:def test_set_locale():
110:    # First, test if the required locales are available
111:    current = locale.setlocale(locale.LC_ALL)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/utils/tests/test_misc.py -q 2>&1 | tail -20"
}
```

**tool result**

```
..s.......                                                               [100%]
=============================== warnings summary ===============================
None
  Module already imported so cannot be rewritten: astropy.tests.plugins.display

-- Docs: http://doc.pytest.org/en/latest/warnings.html
9 passed, 1 skipped, 1 warnings in 0.25 seconds
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: astropy/utils/tests/test_misc.py\n@@\n     assert Subclass.__dict__['prop'].__doc__ == \"PROPERTY\"\n+    assert Subclass.__dict__['prop'].fget.__doc__ == \"PROPERTY\"\n     assert Subclass.prop.__doc__ == \"PROPERTY\"\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[astropy/utils/tests/test_misc.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

astropy/utils/tests/test_misc.py now (152 lines), around the change:
102:            return 2
103:
104:    assert Subclass.__dict__['prop'].__doc__ == "PROPERTY"
105:    assert Subclass.__dict__['prop'].fget.__doc__ == "PROPERTY"
106:    assert Subclass.prop.__doc__ == "PROPERTY"
107:    assert Subclass().prop == 2
108:
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/utils/tests/test_misc.py -q 2>&1 | tail -5 && git diff --stat && git status --short"
}
```

**tool result**

```
None
  Module already imported so cannot be rewritten: astropy.tests.plugins.display

-- Docs: http://doc.pytest.org/en/latest/warnings.html
9 passed, 1 skipped, 1 warnings in 0.19 seconds
 astropy/utils/misc.py            | 23 ++++++++++++++++++++---
 astropy/utils/tests/test_misc.py | 18 ++++++++++++++++++
 2 files changed, 38 insertions(+), 3 deletions(-)
 M astropy/utils/misc.py
 M astropy/utils/tests/test_misc.py
?? .memdoor/
```

**assistant**

```
Implemented the fix.

**Change in `astropy/utils/misc.py`** — `InheritDocstrings` now handles `property` objects in addition to plain functions:
- It no longer requires `inspect.isfunction(val)`, so properties are considered.
- When the subclass property has no docstring, it copies the base class member's docstring onto both the property object and its getter (`fget`), since `help()`/introspection reads the getter's `__doc__` while the property object also exposes a writable `__doc__`.
- Existing function-docstring behavior is unchanged.

**Test added in `astropy/utils/tests/test_misc.py`** — `test_inherit_docstrings_property` verifies that a docstring-less property in a subclass inherits the base property's docstring (on both the property and its getter) and still returns the subclass value.

**Verification:** `python -m pytest astropy/utils/tests/test_misc.py -q` → `9 passed, 1 skipped`. No commits or git state changes were made (only working-tree edits).
```

## Run folder `team-solve-2026-11-06T104713`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
e4f19c1063ddfd213eb2c215a93ec91fb253a61d
```

### `baseline-check.log`

```
check: pytest astropy/utils/tests/test_misc.py
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/site-packages/_pytest/config.py", line 328, in _getconftestmodules
    return self._path2confmods[path]
KeyError: local('/testbed/.memdoor/runs/team-solve-2026-11-06T104713/baseline-tree/astropy/utils/tests/test_misc.py')

During handling of the above exception, another exception occurred:
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/site-packages/_pytest/config.py", line 328, in _getconftestmodules
    return self._path2confmods[path]
KeyError: local('/testbed/.memdoor/runs/team-solve-2026-11-06T104713/baseline-tree/astropy/utils/tests')

During handling of the above exception, another exception occurred:
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/site-packages/_pytest/config.py", line 359, in _importconftest
    return self._conftestpath2mod[conftestpath]
KeyError: local('/testbed/.memdoor/runs/team-solve-2026-11-06T104713/baseline-tree/astropy/conftest.py')

During handling of the above exception, another exception occurred:
Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.6/site-packages/_pytest/config.py", line 365, in _importconftest
    mod = conftestpath.pyimport()
  File "/opt/miniconda3/envs/testbed/lib/python3.6/site-packages/py/_path/local.py", line 724, in pyimport
    raise self.ImportMismatchError(modname, modfile, self)
py._path.local.LocalPath.ImportMismatchError: ('astropy.conftest', '/testbed/astropy/conftest.py', local('/testbed/.memdoor/runs/team-solve-2026-11-06T104713/baseline-tree/astropy/conftest.py'))
ERROR: could not load /testbed/.memdoor/runs/team-solve-2026-11-06T104713/baseline-tree/astropy/conftest.py
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/astropy/utils/misc.py b/astropy/utils/misc.py
index de3fb01d1..96a1aa8c9 100644
--- a/astropy/utils/misc.py
+++ b/astropy/utils/misc.py
@@ -528,13 +528,30 @@ class InheritDocstrings(type):
                 not key.startswith('_'))
 
         for key, val in dct.items():
-            if (inspect.isfunction(val) and
-                is_public_member(key) and
-                val.__doc__ is None):
+            if not is_public_member(key):
+                continue
+
+            if inspect.isfunction(val):
+                if val.__doc__ is None:
+                    for base in cls.__mro__[1:]:
+                        super_method = getattr(base, key, None)
+                        if super_method is not None:
+                            val.__doc__ = super_method.__doc__
+                            break
+
+            elif isinstance(val, property):
+                # A property's docstring is normally taken from its getter,
+                # but the property object itself has a writable __doc__.
+                # Set both so the inherited documentation is visible both
+                # through the property and through its getter.
+                if val.__doc__ is not None:
+                    continue
                 for base in cls.__mro__[1:]:
                     super_method = getattr(base, key, None)
                     if super_method is not None:
                         val.__doc__ = super_method.__doc__
+                        if val.fget is not None and val.fget.__doc__ is None:
+                            val.fget.__doc__ = super_method.__doc__
                         break
 
         super().__init__(name, bases, dct)
diff --git a/astropy/utils/tests/test_misc.py b/astropy/utils/tests/test_misc.py
index 4f632e8d1..778fd3d2e 100644
--- a/astropy/utils/tests/test_misc.py
+++ b/astropy/utils/tests/test_misc.py
@@ -89,6 +89,24 @@ def test_inherit_docstrings():
         assert Subclass.__call__.__doc__ == "FOO"
 
 
+def test_inherit_docstrings_property():
+    class Base(metaclass=misc.InheritDocstrings):
+        @property
+        def prop(self):
+            "PROPERTY"
+            return 1
+
+    class Subclass(Base):
+        @property
+        def prop(self):
+            return 2
+
+    assert Subclass.__dict__['prop'].__doc__ == "PROPERTY"
+    assert Subclass.__dict__['prop'].fget.__doc__ == "PROPERTY"
+    assert Subclass.prop.__doc__ == "PROPERTY"
+    assert Subclass().prop == 2
+
+
 def test_set_locale():
     # First, test if the required locales are available
     current = locale.setlocale(locale.LC_ALL)
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

InheritDocstrings metaclass doesn't work for properties
Inside the InheritDocstrings metaclass it uses `inspect.isfunction` which returns `False` for properties.

## Deliverable

changes to this tree

## Check

`pytest astropy/utils/tests/test_misc.py`

## Scope

`astropy/utils/misc.py`
`astropy/utils/tests/`

## Done when

- Attributes that are `property` objects receive the docstring of the corresponding property in the base class when their own docstring is absent.
- Function and method attributes keep inheriting docstrings exactly as before.
- The metaclass no longer skips properties merely because `inspect.isfunction` is false for them.
- A subclass property without a docstring exposes a non-`None` `__doc__` matching the base property's docstring.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest astropy/utils/tests/test_misc.py`

## Scope
`astropy/utils/misc.py`
`astropy/utils/tests/`

## Done when
- Attributes that are `property` objects receive the docstring of the corresponding property in the base class when their own docstring is absent.
- Function and method attributes keep inheriting docstrings exactly as before.
- The metaclass no longer skips properties merely because `inspect.isfunction` is false for them.
- A subclass property without a docstring exposes a non-`None` `__doc__` matching the base property's docstring.

## Approach
Work is in `InheritDocstrings.__new__` in `astropy/utils/misc.py`: for each attribute placed in the class body, resolve the same-named attribute on the base classes, and if the child attribute has no docstring, copy the base attribute's docstring onto it. The current branch only handles `inspect.isfunction`, so add a branch for `isinstance(value, property)`.

Candidate approaches:
1. Special-case properties first: when `value` is a `property`, look up the base property and assign `value.__doc__ = getattr(base_attr, '__doc__', None)` (or `value.fget.__doc__` if assigning on the property itself does not stick). Keeps the function path untouched.
2. Normalize the doc source up front: treat functions as themselves and properties as `value.fget`, enter the common inheritance block when either `inspect.isfunction(value)` or `isinstance(value, property)`, then copy the source docstring back onto the appropriate object. More uniform, but touches the existing function logic.
3. Avoid the metaclass by using `__init_subclass__`/a class decorator; this changes the public mechanism and is riskier for existing users, so use only if the metaclass route cannot be made to work.

Likely failure points to check if the first attempt fails: properties may be descriptors whose `__doc__` must be set on the getter or on the property depending on Python version; base lookup should search the MRO rather than only direct bases; and a child property with an explicit docstring must not be overwritten.


# astropy/utils/misc.py

```
# -*- coding: utf-8 -*-
# Licensed under a 3-clause BSD style license - see LICENSE.rst
"""
A "grab bag" of relatively small general-purpose utilities that don't have
a clear module/package to live in.
"""



import abc
import contextlib
import difflib
import inspect
import json
import os
import signal
import sys
import traceback
import unicodedata
import locale
import threading
import re
import urllib.request

from itertools import zip_longest
from contextlib import contextmanager
from collections import defaultdict, OrderedDict



__all__ = ['isiterable', 'silence', 'format_exception', 'NumpyRNGContext',
           'find_api_page', 'is_path_hidden', 'walk_skip_hidden',
           'JsonCustomEncoder', 'indent', 'InheritDocstrings',
           'OrderedDescriptor', 'OrderedDescriptorContainer', 'set_locale',
           'ShapedLikeNDArray', 'check_broadcast', 'IncompatibleShapeError',
           'dtype_bytes_or_chars']


def isiterable(obj):
    """Returns `True` if the given object is iterable."""

    try:
        iter(obj)
        return True
    except TypeError:
        return False


def indent(s, shift=1, width=4):
    """Indent a block of text.  The indentation is applied to each line."""

    indented = '\n'.join(' ' * (width * shift) + l if l else ''
                         for l in s.splitlines())
    if s[-1] == '\n':
        indented += '\n'

    return indented


class _DummyFile:
    """A noop writeable object."""

    def write(self, s):
        pass


@contextlib.contextmanager
def silence():
    """A context manager that silences sys.stdout and sys.stderr."""

    old_stdout = sys.stdout
    old_stderr = sys.stderr
    sys.stdout = _DummyFile()
    sys.stderr = _DummyFile()
    yield
    sys.stdout = old_stdout
    sys.stderr = old_stderr


def format_exception(msg, *args, **kwargs):
    """
    Given an exception message string, uses new-style formatting arguments
    ``{filename}``, ``{lineno}``, ``{func}`` and/or ``{text}`` to fill in
    information about the exception that occurred.  For example:

        try:
            1/0
        except:
            raise ZeroDivisionError(
                format_except('A divide by zero occurred in {filename} at '
                              'line {lineno} of function {func}.'))

    Any additional positional or keyword arguments passed to this function are
    also used to format the message.

    .. note::
        This uses `sys.exc_info` to gather up the information needed to fill
        in the formatting arguments. Since `sys.exc_info` is not carried
        outside a handled exception, it's not wise to use this
        outside of an ``except`` clause - if it is, this will substitute
        '<unkown>' for the 4 formatting arguments.
    """

    tb = traceback.extract_tb(sys.exc_info()[2], limit=1)
    if len(tb) > 0:
        filename, lineno, func, text = tb[0]
    else:
        filename = lineno = func = text = '<unknown>'

    return msg.format(*args, filename=filename, lineno=lineno, func=func,
                      text=text, **kwargs)


class NumpyRNGContext:
    """
    A context manager (for use with the ``with`` statement) that will seed the
    numpy random number generator (RNG) to a specific value, and then restore
    the RNG state back to whatever it was before.

    This is primarily intended for use in the astropy testing suit, but it
    may be useful in ensuring reproducibility of Monte Carlo simulations in a
    science context.

    Parameters
    ----------
    seed : int
        The value to use to seed the numpy RNG

    Examples
    --------
    A typical use case might be::

        with NumpyRNGContext(<some seed value you pick>):
            from numpy import random

            randarr = random.randn(100)
            ... run your test using `randarr` ...

        #Any code using numpy.random at this indent level will act just as it
        #would have if it had been before the with statement - e.g. whatever
        #the default seed is.


    """

    def __init__(self, seed):
        self.seed = seed

    def __enter__(self):
        from numpy import random

        self.startstate = random.get_state()
        random.seed(self.seed)

    def __exit__(self, exc_type, exc_value, traceback):
        from numpy import random

        random.set_state(self.startstate)


def find_api_page(obj, version=None, openinbrowser=True, timeout=None):
    """
    Determines the URL of the API page for the specified object, and
    optionally open that page in a web browser.

    .. note::
        You must be connected to the internet for this to function even if
        ``openinbrowser`` is `False`, unless you provide a local version of
        the documentation to ``version`` (e.g., ``file:///path/to/docs``).

    Parameters
    ----------
    obj
        The object to open the docs for or its fully-qualified name
        (as a str).
    version : str
        The doc version - either a version number like '0.1', 'dev' for
        the development/latest docs, or a URL to point to a specific
        location that should be the *base* of the documentation. Defaults to
        latest if you are on aren't on a release, otherwise, the version you
        are on.
    openinbrowser : bool
        If `True`, the `webbrowser` package will be used to open the doc
        page in a new web browser window.
    timeout : number, optional
        The number of seconds to wait before timing-out the query to
        the astropy documentation.  If not given, the default python
        stdlib timeout will be used.

    Returns
    -------
    url : str
        The loaded URL

    Raises
    ------
    ValueError
        If the documentation can't be found

    """
    import webbrowser

    from zlib import decompress

    if (not isinstance(obj, str) and
            hasattr(obj, '__module__') and
            hasattr(obj, '__name__')):
        obj = obj.__module__ + '.' + obj.__name__
    elif inspect.ismodule(obj):
        obj = obj.__name__

    if version is None:
        from .. import version

        if version.release:
            version = 'v' + version.version
        else:
            version = 'dev'

    if '://' in version:
        if version.endswith('index.html'):
            baseurl = version[:-10]
        elif version.endswith('/'):
            baseurl = version
        else:
            baseurl = version + '/'
    elif version == 'dev' or version == 'latest':
        baseurl = 'http://devdocs.astropy.org/'
    else:
        baseurl = 'http://docs.astropy.org/en/{vers}/'.format(vers=version)

    if timeout is None:
        uf = urllib.request.urlopen(baseurl + 'objects.inv')
    else:
        uf = urllib.request.urlopen(baseurl + 'objects.inv', timeout=timeout)

    try:
        oiread = uf.read()

        # need to first read/remove the first four lines, which have info before
        # the compressed section with the actual object inventory
        idx = -1
        headerlines = []
        for _ in range(4):
            oldidx = idx
            idx = oiread.index(b'\n', oldidx + 1)
            headerlines.append(oiread[(oldidx+1):idx].decode('utf-8'))

        # intersphinx version line, project name, and project version
        ivers, proj, vers, compr = headerlines
        if 'The remainder of this file is compressed using zlib' not in compr:
            raise ValueError('The file downloaded from {0} does not seem to be'
                             'the usual Sphinx objects.inv format.  Maybe it '
                             'has changed?'.format(baseurl + 'objects.inv'))

        compressed = oiread[(idx+1):]
    finally:
        uf.close()

    decompressed = decompress(compressed).decode('utf-8')

    resurl = None

    for l in decompressed.strip().splitlines():
        ls = l.split()
        name = ls[0]
        loc = ls[3]
        if loc.endswith('$'):
            loc = loc[:-1] + name

        if name == obj:
            resurl = baseurl + loc
            break

    if resurl is None:
        raise ValueError('Could not find the docs for the object {obj}'.format(obj=obj))
    elif openinbrowser:
        webbrowser.open(resurl)

    return resurl


def signal_number_to_name(signum):
    """
    Given an OS signal number, returns a signal name.  If the signal
    number is unknown, returns ``'UNKNOWN'``.
    """
    # Since these numbers and names are platform specific, we use the
    # builtin signal module and build a reverse mapping.

    signal_to_name_map = dict((k, v) for v, k in signal.__dict__.items()
                              if v.startswith('SIG'))

    return signal_to_name_map.get(signum, 'UNKNOWN')


if sys.platform == 'win32':
    import ctypes

    def _has_hidden_attribute(filepath):
        """
        Returns True if the given filepath has the hidden attribute on
        MS-Windows.  Based on a post here:
        http://stackoverflow.com/questions/284115/cross-platform-hidden-file-detection
        """
        if isinstance(filepath, bytes):
            filepath = filepath.decode(sys.getfilesystemencoding())
        try:
            attrs = ctypes.windll.kernel32.GetFileAttributesW(filepath)
            result = bool(attrs & 2) and attrs != -1
        except AttributeError:
            result = False
        return result
else:
    def _has_hidden_attribute(filepath):
        return False


def is_path_hidden(filepath):
    """
    Determines if a given file or directory is hidden.

    Parameters
    ----------
    filepath : str
        The path to a file or directory

    Returns
    -------
    hidden : bool
        Returns `True` if the file is hidden
    """
    name = os.path.basename(os.path.abspath(filepath))
    if isinstance(name, bytes):
        is_dotted = name.startswith(b'.')
    else:
        is_dotted = name.startswith('.')
    return is_dotted or _has_hidden_attribute(filepath)


def walk_skip_hidden(top, onerror=None, followlinks=False):
    """
    A wrapper for `os.walk` that skips hidden files and directories.

    This function does not have the parameter ``topdown`` from
    `os.walk`: the directories must always be recursed top-down when
    using this function.

    See also
    --------
    os.walk : For a description of the parameters
    """
    for root, dirs, files in os.walk(
            top, topdown=True, onerror=onerror,
            followlinks=followlinks):
        # These lists must be updated in-place so os.walk will skip
        # hidden directories
        dirs[:] = [d for d in dirs if not is_path_hidden(d)]
        files[:] = [f for f in files if not is_path_hidden(f)]
        yield root, dirs, files


class JsonCustomEncoder(json.JSONEncoder):
    """Support for data types that JSON default encoder
    does not do.

    This includes:

        * Numpy array or number
        * Complex number
        * Set
        * Bytes
        * astropy.UnitBase
        * astropy.Quantity

    Examples
    --------
    >>> import json
    >>> import numpy as np
    >>> from astropy.utils.misc import JsonCustomEncoder
    >>> json.dumps(np.arange(3), cls=JsonCustomEncoder)
    '[0, 1, 2]'

    """

    def default(self, obj):
        from .. import units as u
        import numpy as np
        if isinstance(obj, u.Quantity):
            return dict(value=obj.value, unit=obj.unit.to_string())
        if isinstance(obj, (np.number, np.ndarray)):
            return obj.tolist()
        elif isinstance(obj, complex):
            return [obj.real, obj.imag]
        elif isinstance(obj, set):
            return list(obj)
        elif isinstance(obj, bytes):  # pragma: py3
            return obj.decode()
        elif isinstance(obj, (u.UnitBase, u.FunctionUnitBase)):
            if obj == u.dimensionless_unscaled:
                obj = 'dimensionless_unit'
            else:
                return obj.to_string()

        return json.JSONEncoder.default(self, obj)


def strip_accents(s):
    """
    Remove accents from a Unicode string.

    This helps with matching "ångström" to "angstrom", for example.
    """
    return ''.join(
        c for c in unicodedata.normalize('NFD', s)
        if unicodedata.category(c) != 'Mn')


def did_you_mean(s, candidates, n=3, cutoff=0.8, fix=None):
    """
    When a string isn't found in a set of candidates, we can be nice
    to provide a list of alternatives in the exception.  This
    convenience function helps to format that part of the exception.

    Parameters
    ----------
    s : str

    candidates : sequence of str or dict of str keys

    n : int
        The maximum number of results to include.  See
        `difflib.get_close_matches`.

    cutoff : float
        In the range [0, 1]. Possibilities that don't score at least
        that similar to word are ignored.  See
        `difflib.get_close_matches`.

    fix : callable
        A callable to modify the results after matching.  It should
        take a single string and return a sequence of strings
        containing the fixed matches.

    Returns
    -------
    message : str
        Returns the string "Did you mean X, Y, or Z?", or the empty
        string if no alternatives were found.
    """
    if isinstance(s, str):
        s = strip_accents(s)
    s_lower = s.lower()

    # Create a mapping from the lower case name to all capitalization
    # variants of that name.
    candidates_lower = {}
    for candidate in candidates:
        candidate_lower = candidate.lower()
        candidates_lower.setdefault(candidate_lower, [])
        candidates_lower[candidate_lower].append(candidate)

    # The heuristic here is to first try "singularizing" the word.  If
    # that doesn't match anything use difflib to find close matches in
    # original, lower and upper case.
    if s_lower.endswith('s') and s_lower[:-1] in candidates_lower:
        matches = [s_lower[:-1]]
    else:
        matches = difflib.get_close_matches(
            s_lower, candidates_lower, n=n, cutoff=cutoff)

    if len(matches):
        capitalized_matches = set()
        for match in matches:
            capitalized_matches.update(candidates_lower[match])
        matches = capitalized_matches

        if fix is not None:
            mapped_matches = []
            for match in matches:
                mapped_matches.extend(fix(match))
            matches = mapped_matches

        matches = list(set(matches))
        matches = sorted(matches)

        if len(matches) == 1:
            matches = matches[0]
        else:
            matches = (', '.join(matches[:-1]) + ' or ' +
                       matches[-1])
        return 'Did you mean {0}?'.format(matches)

    return ''


class InheritDocstrings(type):
    """
    This metaclass makes methods of a class automatically have their
    docstrings filled in from the methods they override in the base
    class.

    If the class uses multiple inheritance, the docstring will be
    chosen from the first class in the bases list, in the same way as
    methods are normally resolved in Python.  If this results in
    selecting the wrong docstring, the docstring will need to be
    explicitly included on the method.

    For example::

        >>> from astropy.utils.misc import InheritDocstrings
        >>> class A(metaclass=InheritDocstrings):
        ...     def wiggle(self):
        ...         "Wiggle the thingamajig"
        ...         pass
        >>> class B(A):
        ...     def wiggle(self):
        ...         pass
        >>> B.wiggle.__doc__
        u'Wiggle the thingamajig'
    """

    def __init__(cls, name, bases, dct):
        def is_public_member(key):
            return (
                (key.startswith('__') and key.endswith('__')
                 and len(key) > 4) or
                not key.startswith('_'))

        for key, val in dct.items():
            if not is_public_member(key):
                continue

            if inspect.isfunction(val):
                if val.__doc__ is None:
                    for base in cls.__mro__[1:]:
                        super_method = getattr(base, key, None)
                        if super_method is not None:
                            val.__doc__ = super_method.__doc__
                            break

            elif isinstance(val, property):
                # A property's docstring is normally taken from its getter,
                # but the property object itself has a writable __doc__.
                # Set both so the inherited documentation is visible both
                # through the property and through its getter.
                if val.__doc__ is not None:
                    continue
                for base in cls.__mro__[1:]:
                    super_method = getattr(base, key, None)
                    if super_method is not None:
                        val.__doc__ = super_method.__doc__
                        if val.fget is not None and val.fget.__doc__ is None:
                            val.fget.__doc__ = super_method.__doc__
                        break

        super().__init__(name, bases, dct)


class OrderedDescriptor(metaclass=abc.ABCMeta):
    """
    Base class for descriptors whose order in the class body should be
    preserved.  Intended for use in concert with the
    `OrderedDescriptorContainer` metaclass.

    Subclasses of `OrderedDescriptor` must define a value for a class attribute
    called ``_class_attribute_``.  This is the name of a class attribute on the
    *container* class for these descriptors, which will be set to an
    `~collections.OrderedDict` at class creation time.  This
    `~collections.OrderedDict` will contain a mapping of all class attributes
    that were assigned instances of the `OrderedDescriptor` subclass, to the
    instances themselves.  See the documentation for
    `OrderedDescriptorContainer` for a concrete example.

    Optionally, subclasses of `OrderedDescriptor` may define a value for a
    class attribute called ``_name_attribute_``.  This should be the name of
    an attribute on instances of the subclass.  When specified, during
    creation of a class containing these descriptors, the name attribute on
    each instance will be set to the name of the class attribute it was
    assigned to on the class.

    .. note::

        Although this class is intended for use with *descriptors* (i.e.
        classes that define any of the ``__get__``, ``__set__``, or
        ``__delete__`` magic methods), this base class is not itself a
        descriptor, and technically this could be used for classes that are
        not descriptors too.  However, use with descriptors is the original
        intended purpose.
    """

    # This id increments for each OrderedDescriptor instance created, so they
    # are always ordered in the order they were created.  Class bodies are
    # guaranteed to be executed from top to bottom.  Not sure if this is
    # thread-safe though.
    _nextid = 1

    @property
    @abc.abstractmethod
    def _class_attribute_(self):
        """
        Subclasses should define this attribute to the name of an attribute on
        classes containing this subclass.  That attribute will contain the mapping
        of all instances of that `OrderedDescriptor` subclass defined in the class
        body.  If the same descriptor needs to be used with different classes,
        each with different names of this attribute, multiple subclasses will be
        needed.
        """

    _name_attribute_ = None
    """
    Subclasses may optionally define this attribute to specify the name of an
    attribute on instances of the class that should be filled with the
    instance's attribute name at class creation time.
    """

    def __init__(self, *args, **kwargs):
        # The _nextid attribute is shared across all subclasses so that
        # different subclasses of OrderedDescriptors can be sorted correctly
        # between themselves
        self.__order = OrderedDescriptor._nextid
        OrderedDescriptor._nextid += 1
        super().__init__()

    def __lt__(self, other):
        """
        Defined for convenient sorting of `OrderedDescriptor` instances, which
        are defined to sort in their creation order.
        """

        if (isinstance(self, OrderedDescriptor) and
                isinstance(other, OrderedDescriptor)):
            try:
                return self.__order < other.__order
            except AttributeError:
                raise RuntimeError(
                    'Could not determine ordering for {0} and {1}; at least '
                    'one of them is not calling super().__init__ in its '
                    '__init__.'.format(self, other))
        else:
            return NotImplemented


class OrderedDescriptorContainer(type):
    """
    Classes should use this metaclass if they wish to use `OrderedDescriptor`
    attributes, which are class attributes that "remember" the order in which
    they were defined in the class body.

    Every subclass of `OrderedDescriptor` has an attribute called
    ``_class_attribute_``.  For example, if we have

    .. code:: python

        class ExampleDecorator(OrderedDescriptor):
            _class_attribute_ = '_examples_'

    Then when a class with the `OrderedDescriptorContainer` metaclass is
    created, it will automatically be assigned a class attribute ``_examples_``
    referencing an `~collections.OrderedDict` containing all instances of
    ``ExampleDecorator`` defined in the class body, mapped to by the names of
    the attributes they were assigned to.

    When subclassing a class with this metaclass, the descriptor dict (i.e.
    ``_examples_`` in the above example) will *not* contain descriptors
    inherited from the base class.  That is, this only works by default with
    decorators explicitly defined in the class body.  However, the subclass
    *may* define an attribute ``_inherit_decorators_`` which lists
    `OrderedDescriptor` classes that *should* be added from base classes.
    See the examples section below for an example of this.

    Examples
    --------

    >>> from astropy.utils import OrderedDescriptor, OrderedDescriptorContainer
    >>> class TypedAttribute(OrderedDescriptor):
    ...     \"\"\"
    ...     Attributes that may only be assigned objects of a specific type,
    ...     or subclasses thereof.  For some reason we care about their order.
    ...     \"\"\"
    ...
    ...     _class_attribute_ = 'typed_attributes'
    ...     _name_attribute_ = 'name'
    ...     # A default name so that instances not attached to a class can
    ...     # still be repr'd; useful for debugging
    ...     name = '<unbound>'
    ...
    ...     def __init__(self, type):
    ...         # Make sure not to forget to call the super __init__
    ...         super().__init__()
    ...         self.type = type
    ...
    ...     def __get__(self, obj, objtype=None):
    ...         if obj is None:
    ...             return self
    ...         if self.name in obj.__dict__:
    ...             return obj.__dict__[self.name]
    ...         else:
    ...             raise AttributeError(self.name)
    ...
    ...     def __set__(self, obj, value):
    ...         if not isinstance(value, self.type):
    ...             raise ValueError('{0}.{1} must be of type {2!r}'.format(
    ...                 obj.__class__.__name__, self.name, self.type))
    ...         obj.__dict__[self.name] = value
    ...
    ...     def __delete__(self, obj):
    ...         if self.name in obj.__dict__:
    ...             del obj.__dict__[self.name]
    ...         else:
    ...             raise AttributeError(self.name)
    ...
    ...     def __repr__(self):
    ...         if isinstance(self.type, tuple) and len(self.type) > 1:
    ...             typestr = '({0})'.format(
    ...                 ', '.join(t.__name__ for t in self.type))
    ...         else:
    ...             typestr = self.type.__name__
    ...         return '<{0}(name={1}, type={2})>'.format(
    ...                 self.__class__.__name__, self.name, typestr)
    ...

    Now let's create an example class that uses this ``TypedAttribute``::

        >>> class Point2D(metaclass=OrderedDescriptorContainer):
        ...     x = TypedAttribute((float, int))
        ...     y = TypedAttribute((float, int))
        ...
        ...     def __init__(self, x, y):
        ...         self.x, self.y = x, y
        ...
        >>> p1 = Point2D(1.0, 2.0)
        >>> p1.x
        1.0
        >>> p1.y
        2.0
        >>> p2 = Point2D('a', 'b')  # doctest: +IGNORE_EXCEPTION_DETAIL
        Traceback (most recent call last):
            ...
        ValueError: Point2D.x must be of type (float, int>)

    We see that ``TypedAttribute`` works more or less as advertised, but
    there's nothing special about that.  Let's see what
    `OrderedDescriptorContainer` did for us::

        >>> Point2D.typed_attributes
        OrderedDict([('x', <TypedAttribute(name=x, type=(float, int))>),
        ('y', <TypedAttribute(name=y, type=(float, int))>)])

    If we create a subclass, it does *not* by default add inherited descriptors
    to ``typed_attributes``::

        >>> class Point3D(Point2D):
        ...     z = TypedAttribute((float, int))
        ...
        >>> Point3D.typed_attributes
        OrderedDict([('z', <TypedAttribute(name=z, type=(float, int))>)])

    However, if we specify ``_inherit_descriptors_`` from ``Point2D`` then
    it will do so::

        >>> class Point3D(Point2D):
        ...     _inherit_descriptors_ = (TypedAttribute,)
        ...     z = TypedAttribute((float, int))
        ...
        >>> Point3D.typed_attributes
        OrderedDict([('x', <TypedAttribute(name=x, type=(float, int))>),
        ('y', <TypedAttribute(name=y, type=(float, int))>),
        ('z', <TypedAttribute(name=z, type=(float, int))>)])

    .. note::

        Hopefully it is clear from these examples that this construction
        also allows a class of type `OrderedDescriptorContainer` to use
        multiple different `OrderedDescriptor` classes simultaneously.
    """

    _inherit_descriptors_ = ()

    def __init__(cls, cls_name, bases, members):
        descriptors = defaultdict(list)
        seen = set()
        inherit_descriptors = ()
        descr_bases = {}

        for mro_cls in cls.__mro__:
            for name, obj in mro_cls.__dict__.items():
                if name in seen:
                    # Checks if we've already seen an attribute of the given
                    # name (if so it will override anything of the same name in
                    # any base class)
                    continue

                seen.add(name)

                if (not isinstance(obj, OrderedDescriptor) or
                        (inherit_descriptors and
                            not isinstance(obj, inherit_descriptors))):
                    # The second condition applies when checking any
                    # subclasses, to see if we can inherit any descriptors of
                    # the given type from subclasses (by default inheritance is
                    # disabled unless the class has _inherit_descriptors_
                    # defined)
                    continue

                if obj._name_attribute_ is not None:
                    setattr(obj, obj._name_attribute_, name)

                # Don't just use the descriptor's class directly; instead go
                # through its MRO and find the class on which _class_attribute_
                # is defined directly.  This way subclasses of some
                # OrderedDescriptor *may* override _class_attribute_ and have
                # its own _class_attribute_, but by default all subclasses of
                # some OrderedDescriptor are still grouped together
                # TODO: It might be worth clarifying this in the docs
                if obj.__class__ not in descr_bases:
                    for obj_cls_base in obj.__class__.__mro__:
                        if '_class_attribute_' in obj_cls_base.__dict__:
                            descr_bases[obj.__class__] = obj_cls_base
                            descriptors[obj_cls_base].append((obj, name))
                            break
                else:
                    # Make sure to put obj first for sorting purposes
                    obj_cls_base = descr_bases[obj.__class__]
                    descriptors[obj_cls_base].append((obj, name))

            if not getattr(mro_cls, '_inherit_descriptors_', False):
                # If _inherit_descriptors_ is undefined then we don't inherit
                # any OrderedDescriptors from any of the base classes, and
                # there's no reason to continue through the MRO
                break
            else:
                inherit_descriptors = mro_cls._inherit_descriptors_

        for descriptor_cls, instances in descriptors.items():
            instances.sort()
            instances = OrderedDict((key, value) for value, key in instances)
            setattr(cls, descriptor_cls._class_attribute_, instances)

        super().__init__(cls_name, bases, members)


LOCALE_LOCK = threading.Lock()


@contextmanager
def set_locale(name):
    """
    Context manager to temporarily set the locale to ``name``.

    An example is setting locale to "C" so that the C strtod()
    function will use "." as the decimal point to enable consistent
    numerical string parsing.

    Note that one cannot nest multiple set_locale() context manager
    statements as this causes a threading lock.

    This code taken from https://stackoverflow.com/questions/18593661/how-do-i-strftime-a-date-object-in-a-different-locale.

    Parameters
    ==========
    name : str
        Locale name, e.g. "C" or "fr_FR".
    """
    name = str(name)

    with LOCALE_LOCK:
        saved = locale.setlocale(locale.LC_ALL)
        if saved == name:
            # Don't do anything if locale is already the requested locale
            yield
        else:
            try:
                locale.setlocale(locale.LC_ALL, name)
                yield
            finally:
                locale.setlocale(locale.LC_ALL, saved)


class ShapedLikeNDArray(metaclass=abc.ABCMeta):
    """Mixin class to provide shape-changing methods.

    The class proper is assumed to have some underlying data, which are arrays
    or array-like structures. It must define a ``shape`` property, which gives
    the shape of those data, as well as an ``_apply`` method that creates a new
    instance in which a `~numpy.ndarray` method has been applied to those.

    Furthermore, for consistency with `~numpy.ndarray`, it is recommended to
    define a setter for the ``shape`` property, which, like the
    `~numpy.ndarray.shape` property allows in-place reshaping the internal data
    (and, unlike the ``reshape`` method raises an exception if this is not
    possible).

    This class also defines default implementations for ``ndim`` and ``size``
    properties, calculating those from the ``shape``.  These can be overridden
    by subclasses if there are faster ways to obtain those numbers.

    """

    # Note to developers: if new methods are added here, be sure to check that
    # they work properly with the classes that use this, such as Time and
    # BaseRepresentation, i.e., look at their ``_apply`` methods and add
    # relevant tests.  This is particularly important for methods that imply
    # copies rather than views of data (see the special-case treatment of
    # 'flatten' in Time).

    @property
    @abc.abstractmethod
    def shape(self):
        """The shape of the instance and underlying arrays."""

    @abc.abstractmethod
    def _apply(method, *args, **kwargs):
        """Create a new instance, with ``method`` applied to underlying data.

        The method is any of the shape-changing methods for `~numpy.ndarray`
        (``reshape``, ``swapaxes``, etc.), as well as those picking particular
        elements (``__getitem__``, ``take``, etc.). It will be applied to the
        underlying arrays (e.g., ``jd1`` and ``jd2`` in `~astropy.time.Time`),
        with the results used to create a new instance.

        Parameters
        ----------
        method : str
            Method to be applied to the instance's internal data arrays.
        args : tuple
            Any positional arguments for ``method``.
        kwargs : dict
            Any keyword arguments for ``method``.

        """

    @property
    def ndim(self):
        """The number of dimensions of the instance and underlying arrays."""
        return len(self.shape)

    @property
    def size(self):
        """The size of the object, as calculated from its shape."""
        size = 1
        for sh in self.shape:
            size *= sh
        return size

    @property
    def isscalar(self):
        return self.shape == ()

    def __len__(self):
        if self.isscalar:
            raise TypeError("Scalar {0!r} object has no len()"
                            .format(self.__class__.__name__))
        return self.shape[0]

    def __bool__(self):
        """Any instance should evaluate to True, except when it is empty."""
        return self.size > 0

    def __getitem__(self, item):
        try:
            return self._apply('__getitem__', item)
        except IndexError:
            if self.isscalar:
                raise TypeError('scalar {0!r} object is not subscriptable.'
                                .format(self.__class__.__name__))
            else:
                raise

    def __iter__(self):
        if self.isscalar:
            raise TypeError('scalar {0!r} object is not iterable.'
                            .format(self.__class__.__name__))

        # We cannot just write a generator here, since then the above error
        # would only be raised once we try to use the iterator, rather than
        # upon its definition using iter(self).
        def self_iter():
            for idx in range(len(self)):
                yield self[idx]

        return self_iter()

    def copy(self, *args, **kwargs):
        """Return an instance containing copies of the internal data.

        Parameters are as for :meth:`~numpy.ndarray.copy`.
        """
        return self._apply('copy', *args, **kwargs)

    def reshape(self, *args, **kwargs):
        """Returns an instance containing the same data with a new shape.

        Parameters are as for :meth:`~numpy.ndarray.reshape`.  Note that it is
        not always possible to change the shape of an array without copying the
        data (see :func:`~numpy.reshape` documentation). If you want an error
        to be raise if the data is copied, you should assign the new shape to
        the shape attribute (note: this may not be implemented for all classes
        using ``ShapedLikeNDArray``).
        """
        return self._apply('reshape', *args, **kwargs)

    def ravel(self, *args, **kwargs):
        """Return an instance with the array collapsed into one dimension.

        Parameters are as for :meth:`~numpy.ndarray.ravel`. Note that it is
        not always possible to unravel an array without copying the data.
        If you want an error to be raise if the data is copied, you should
        should assign shape ``(-1,)`` to the shape attribute.
        """
        return self._apply('ravel', *args, **kwargs)

    def flatten(self, *args, **kwargs):
        """Return a copy with the array collapsed into one dimension.

        Parameters are as for :meth:`~numpy.ndarray.flatten`.
        """
        return self._apply('flatten', *args, **kwargs)

    def transpose(self, *args, **kwargs):
        """Return an instance with the data transposed.

        Parameters are as for :meth:`~numpy.ndarray.transpose`.  All internal
        data are views of the data of the original.
        """
        return self._apply('transpose', *args, **kwargs)

    @property
    def T(self):
        """Return an instance with the data transposed.

        Parameters are as for :attr:`~numpy.ndarray.T`.  All internal
        data are views of the data of the original.
        """
        if self.ndim < 2:
            return self
        else:
            return self.transpose()

    def swapaxes(self, *args, **kwargs):
        """Return an instance with the given axes interchanged.

        Parameters are as for :meth:`~numpy.ndarray.swapaxes`:
        ``axis1, axis2``.  All internal data are views of the data of the
        original.
        """
        return self._apply('swapaxes', *args, **kwargs)

    def diagonal(self, *args, **kwargs):
        """Return an instance with the specified diagonals.

        Parameters are as for :meth:`~numpy.ndarray.diagonal`.  All internal
        data are views of the data of the original.
        """
        return self._apply('diagonal', *args, **kwargs)

    def squeeze(self, *args, **kwargs):
        """Return an instance with single-dimensional shape entries removed

        Parameters are as for :meth:`~numpy.ndarray.squeeze`.  All internal
        data are views of the data of the original.
        """
        return self._apply('squeeze', *args, **kwargs)

    def take(self, indices, axis=None, mode='raise'):
        """Return a new instance formed from the elements at the given indices.

        Parameters are as for :meth:`~numpy.ndarray.take`, except that,
        obviously, no output array can be given.
        """
        return self._apply('take', indices, axis=axis, mode=mode)


class IncompatibleShapeError(ValueError):
    def __init__(self, shape_a, shape_a_idx, shape_b, shape_b_idx):
        super().__init__(shape_a, shape_a_idx, shape_b, shape_b_idx)


def check_broadcast(*shapes):
    """
    Determines whether two or more Numpy arrays can be broadcast with each
    other based on their shape tuple alone.

    Parameters
    ----------
    *shapes : tuple
        All shapes to include in the comparison.  If only one shape is given it
        is passed through unmodified.  If no shapes are given returns an empty
        `tuple`.

    Returns
    -------
    broadcast : `tuple`
        If all shapes are mutually broadcastable, returns a tuple of the full
        broadcast shape.
    """

    if len(shapes) == 0:
        return ()
    elif len(shapes) == 1:
        return shapes[0]

    reversed_shapes = (reversed(shape) for shape in shapes)

    full_shape = []

    for dims in zip_longest(*reversed_shapes, fillvalue=1):
        max_dim = 1
        max_dim_idx = None
        for idx, dim in enumerate(dims):
            if dim == 1:
                continue

            if max_dim == 1:
                # The first dimension of size greater than 1
                max_dim = dim
                max_dim_idx = idx
            elif dim != max_dim:
                raise IncompatibleShapeError(
                    shapes[max_dim_idx], max_dim_idx, shapes[idx], idx)

        full_shape.append(max_dim)

    return tuple(full_shape[::-1])


def dtype_bytes_or_chars(dtype):
    """
    Parse the number out of a dtype.str value like '<U5' or '<f8'.

    See #5819 for discussion on the need for this function for getting
    the number of characters corresponding to a string dtype.

    Parameters
    ----------
    dtype : numpy dtype object
        Input dtype

    Returns
    -------
    bytes_or_chars : int or None
        Bits (for numeric types) or characters (for string types)
    """
    match = re.search(r'(\d+)$', dtype.str)
    out = int(match.group(1)) if match else None
    return out

```


# astropy/utils/tests (the files in it)

astropy/utils/tests/__init__.py
astropy/utils/tests/data/.hidden_file.txt
astropy/utils/tests/data/alias.cfg
astropy/utils/tests/data/local.dat
astropy/utils/tests/data/local.dat.bz2
astropy/utils/tests/data/local.dat.gz
astropy/utils/tests/data/local.dat.xz
astropy/utils/tests/data/test_package/__init__.py
astropy/utils/tests/data/test_package/data/foo.txt
astropy/utils/tests/data/unicode.txt
astropy/utils/tests/data/unicode.txt.bz2
astropy/utils/tests/data/unicode.txt.gz
astropy/utils/tests/data/unicode.txt.xz
astropy/utils/tests/test_codegen.py
astropy/utils/tests/test_collections.py
astropy/utils/tests/test_console.py
astropy/utils/tests/test_data.py
astropy/utils/tests/test_data_info.py
astropy/utils/tests/test_decorators.py
astropy/utils/tests/test_introspection.py
astropy/utils/tests/test_metadata.py
astropy/utils/tests/test_misc.py
astropy/utils/tests/test_progress_bar_func.py
astropy/utils/tests/test_timer.py
astropy/utils/tests/test_xml.py


# The last commit

```
e4f19c106 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: pytest astropy/utils/tests/test_misc.py
============================= test session starts ==============================
platform linux -- Python 3.6.13, pytest-3.3.1, py-1.11.0, pluggy-0.6.0

Running tests with Astropy version 3.1.dev21447.
Running tests in astropy/utils/tests/test_misc.py.

Date: 2026-11-06T10:47:45

Platform: Linux-7.0.0-1014-gcp-x86_64-with-debian-bookworm-sid

Executable: /opt/miniconda3/envs/testbed/bin/python

Full Python Version: 
3.6.13 |Anaconda, Inc.| (default, Jun  4 2021, 14:25:59) 
[GCC 7.5.0]

encodings: sys: utf-8, locale: UTF-8, filesystem: utf-8
byteorder: little
float info: dig: 15, mant_dig: 15

Numpy: 1.16.0
Scipy: not available
Matplotlib: not available
h5py: not available
Pandas: not available
Cython: 0.27.3
Using Astropy options: remote_data: none.

rootdir: /testbed, inifile: setup.cfg
plugins: xdist-1.20.1, remotedata-0.2.0, openfiles-0.2.0, mock-1.6.3, forked-0.2, filter-subpackage-0.1, doctestplus-0.1.2, cov-2.5.1, astropy-header-0.1, arraydiff-0.1, hypothesis-3.44.2
collected 10 items

astropy/utils/tests/test_misc.py ..s.......                              [100%]

=============================== warnings summary ===============================
None
  Module already imported so cannot be rewritten: astropy.tests.plugins.display

-- Docs: http://doc.pytest.org/en/latest/warnings.html
=============== 9 passed, 1 skipped, 1 warnings in 0.22 seconds ================
scope: astropy/utils/misc.py astropy/utils/tests
changed: astropy/utils/misc.py +20 -3
changed: astropy/utils/tests/test_misc.py +18 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/astropy/utils/misc.py b/astropy/utils/misc.py
index de3fb01d1..96a1aa8c9 100644
--- a/astropy/utils/misc.py
+++ b/astropy/utils/misc.py
@@ -528,13 +528,30 @@ class InheritDocstrings(type):
                 not key.startswith('_'))
 
         for key, val in dct.items():
-            if (inspect.isfunction(val) and
-                is_public_member(key) and
-                val.__doc__ is None):
+            if not is_public_member(key):
+                continue
+
+            if inspect.isfunction(val):
+                if val.__doc__ is None:
+                    for base in cls.__mro__[1:]:
+                        super_method = getattr(base, key, None)
+                        if super_method is not None:
+                            val.__doc__ = super_method.__doc__
+                            break
+
+            elif isinstance(val, property):
+                # A property's docstring is normally taken from its getter,
+                # but the property object itself has a writable __doc__.
+                # Set both so the inherited documentation is visible both
+                # through the property and through its getter.
+                if val.__doc__ is not None:
+                    continue
                 for base in cls.__mro__[1:]:
                     super_method = getattr(base, key, None)
                     if super_method is not None:
                         val.__doc__ = super_method.__doc__
+                        if val.fget is not None and val.fget.__doc__ is None:
+                            val.fget.__doc__ = super_method.__doc__
                         break
 
         super().__init__(name, bases, dct)
diff --git a/astropy/utils/tests/test_misc.py b/astropy/utils/tests/test_misc.py
index 4f632e8d1..778fd3d2e 100644
--- a/astropy/utils/tests/test_misc.py
+++ b/astropy/utils/tests/test_misc.py
@@ -89,6 +89,24 @@ def test_inherit_docstrings():
         assert Subclass.__call__.__doc__ == "FOO"
 
 
+def test_inherit_docstrings_property():
+    class Base(metaclass=misc.InheritDocstrings):
+        @property
+        def prop(self):
+            "PROPERTY"
+            return 1
+
+    class Subclass(Base):
+        @property
+        def prop(self):
+            return 2
+
+    assert Subclass.__dict__['prop'].__doc__ == "PROPERTY"
+    assert Subclass.__dict__['prop'].fget.__doc__ == "PROPERTY"
+    assert Subclass.prop.__doc__ == "PROPERTY"
+    assert Subclass().prop == 2
+
+
 def test_set_locale():
     # First, test if the required locales are available
     current = locale.setlocale(locale.LC_ALL)
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
check: pytest astropy/utils/tests/test_misc.py
============================= test session starts ==============================
platform linux -- Python 3.6.13, pytest-3.3.1, py-1.11.0, pluggy-0.6.0

Running tests with Astropy version 3.1.dev21447.
Running tests in astropy/utils/tests/test_misc.py.

Date: 2026-11-06T10:48:17

Platform: Linux-7.0.0-1014-gcp-x86_64-with-debian-bookworm-sid

Executable: /opt/miniconda3/envs/testbed/bin/python

Full Python Version: 
3.6.13 |Anaconda, Inc.| (default, Jun  4 2021, 14:25:59) 
[GCC 7.5.0]

encodings: sys: utf-8, locale: UTF-8, filesystem: utf-8
byteorder: little
float info: dig: 15, mant_dig: 15

Numpy: 1.16.0
Scipy: not available
Matplotlib: not available
h5py: not available
Pandas: not available
Cython: 0.27.3
Using Astropy options: remote_data: none.

rootdir: /testbed, inifile: setup.cfg
plugins: xdist-1.20.1, remotedata-0.2.0, openfiles-0.2.0, mock-1.6.3, forked-0.2, filter-subpackage-0.1, doctestplus-0.1.2, cov-2.5.1, astropy-header-0.1, arraydiff-0.1, hypothesis-3.44.2
collected 10 items

astropy/utils/tests/test_misc.py ..s.......                              [100%]

=============================== warnings summary ===============================
None
  Module already imported so cannot be rewritten: astropy.tests.plugins.display

-- Docs: http://doc.pytest.org/en/latest/warnings.html
=============== 9 passed, 1 skipped, 1 warnings in 0.28 seconds ================
scope: astropy/utils/misc.py astropy/utils/tests
changed: astropy/utils/misc.py +20 -3
changed: astropy/utils/tests/test_misc.py +18 -0
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
# Notes, run 2026-11-06T104713

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

InheritDocstrings metaclass doesn't work for properties
Inside the InheritDocstrings metaclass it uses `inspect.isfunction` which returns `False` for properties.


# The files of the project

```
.astropy-root
.circleci/config.yml
.gitattributes
.gitignore
.gitmodules
.mailmap
.rtd-environment.yml
.travis.yml
CHANGES.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.md
LICENSE.rst
MANIFEST.in
README.rst
ah_bootstrap.py
appveyor.yml
astropy/__init__.py
astropy/_erfa/__init__.py
astropy/_erfa/core.c.templ
astropy/_erfa/core.py.templ
astropy/_erfa/erfa_generator.py
astropy/_erfa/setup_package.py
astropy/_erfa/tests/__init__.py
astropy/_erfa/tests/test_erfa.py
astropy/astropy.cfg
astropy/config/__init__.py
astropy/config/affiliated.py
astropy/config/configuration.py
astropy/config/paths.py
astropy/config/setup_package.py
astropy/config/tests/__init__.py
astropy/config/tests/data/alias.cfg
astropy/config/tests/data/astropy.0.3.cfg
astropy/config/tests/data/astropy.0.3.windows.cfg
astropy/config/tests/data/deprecated.cfg
astropy/config/tests/data/empty.cfg
astropy/config/tests/data/not_empty.cfg
astropy/config/tests/test_configs.py
astropy/conftest.py
astropy/constants/__init__.py
astropy/constants/astropyconst13.py
astropy/constants/astropyconst20.py
astropy/constants/cgs.py
astropy/constants/codata2010.py
astropy/constants/codata2014.py
astropy/constants/constant.py
astropy/constants/iau2012.py
astropy/constants/iau2015.py
astropy/constants/si.py
astropy/constants/tests/__init__.py
astropy/constants/tests/test_constant.py
astropy/constants/tests/test_pickle.py
astropy/constants/tests/test_prior_version.py
astropy/constants/utils.py
astropy/convolution/__init__.py
astropy/convolution/boundary_extend.pyx
astropy/convolution/boundary_fill.pyx
astropy/convolution/boundary_none.pyx
astropy/convolution/boundary_wrap.pyx
astropy/convolution/convolve.py
astropy/convolution/core.py
astropy/convolution/kernels.py
astropy/convolution/tests/__init__.py
astropy/convolution/tests/test_convolve.py
astropy/convolution/tests/test_convolve_fft.py
astropy/convolution/tests/test_convolve_kernels.py
astropy/convolution/tests/test_convolve_models.py
astropy/convolution/tests/test_convolve_nddata.py
astropy/convolution/tests/test_convolve_speeds.py
astropy/convolution/tests/test_discretize.py
astropy/convolution/tests/test_kernel_class.py
astropy/convolution/tests/test_pickle.py
astropy/convolution/utils.py
astropy/coordinates/__init__.py
astropy/coordinates/angle_lextab.py
astropy/coordinates/angle_parsetab.py
astropy/coordinates/angle_utilities.py
astropy/coordinates/angles.py
astropy/coordinates/attributes.py
astropy/coordinates/baseframe.py
astropy/coordinates/builtin_frames/__init__.py
astropy/coordinates/builtin_frames/altaz.py
astropy/coordinates/builtin_frames/baseradec.py
astropy/coordinates/builtin_frames/cirs.py
astropy/coordinates/builtin_frames/cirs_observed_transforms.py
astropy/coordinates/builtin_frames/ecliptic.py
astropy/coordinates/builtin_frames/ecliptic_transforms.py
astropy/coordinates/builtin_frames/fk4.py
astropy/coordinates/builtin_frames/fk4_fk5_transforms.py
astropy/coordinates/builtin_frames/fk5.py
astropy/coordinates/builtin_frames/galactic.py
astropy/coordinates/builtin_frames/galactic_transforms.py
astropy/coordinates/builtin_frames/galactocentric.py
astropy/coordinates/builtin_frames/gcrs.py
astropy/coordinates/builtin_frames/hcrs.py
astropy/coordinates/builtin_frames/icrs.py
astropy/coordinates/builtin_frames/icrs_cirs_transforms.py
astropy/coordinates/builtin_frames/icrs_fk5_transforms.py
astropy/coordinates/builtin_frames/intermediate_rotation_transforms.py
astropy/coordinates/builtin_frames/itrs.py
astropy/coordinates/builtin_frames/lsr.py
astropy/coordinates/builtin_frames/skyoffset.py
astropy/coordinates/builtin_frames/supergalactic.py
astropy/coordinates/builtin_frames/supergalactic_transforms.py
astropy/coordinates/builtin_frames/utils.py
astropy/coordinates/calculation.py
astropy/coordinates/data/constellation_data_roman87.dat
astropy/coordinates/data/constellation_names.dat
astropy/coordinates/data/sites.json
astropy/coordinates/distances.py
astropy/coordinates/earth.py
astropy/coordinates/earth_orientation.py
astropy/coordinates/errors.py
astropy/coordinates/funcs.py
astropy/coordinates/matching.py
astropy/coordinates/matrix_utilities.py
astropy/coordinates/name_resolve.py
astropy/coordinates/orbital_elements.py
astropy/coordinates/representation.py
astropy/coordinates/setup_package.py
astropy/coordinates/sites.py
astropy/coordinates/sky_coordinate.py
astropy/coordinates/solar_system.py
astropy/coordinates/tests/__init__.py
astropy/coordinates/tests/accuracy/__init__.py
astropy/coordinates/tests/accuracy/fk4_no_e_fk4.csv
astropy/coordinates/tests/accuracy/fk4_no_e_fk5.csv
astropy/coordinates/tests/accuracy/galactic_fk4.csv
astropy/coordinates/tests/accuracy/generate_ref_ast.py
astropy/coordinates/tests/accuracy/icrs_fk5.csv
astropy/coordinates/tests/accuracy/test_altaz_icrs.py
astropy/coordinates/tests/accuracy/test_ecliptic.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk4.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk5.py
astropy/coordinates/tests/accuracy/test_galactic_fk4.py
astropy/coordinates/tests/accuracy/test_icrs_fk5.py
astropy/coordinates/tests/test_angles.py
astropy/coordinates/tests/test_angular_separation.py
astropy/coordinates/tests/test_api_ape5.py
astropy/coordinates/tests/test_arrays.py
astropy/coordinates/tests/test_atc_replacements.py
astropy/coordinates/tests/test_celestial_transformations.py
astropy/coordinates/tests/test_distance.py
astropy/coordinates/tests/test_earth.py
astropy/coordinates/tests/test_finite_difference_velocities.py
astropy/coordinates/tests/test_formatting.py
astropy/coordinates/tests/test_frames.py
astropy/coordinates/tests/test_frames_with_velocity.py
astropy/coordinates/tests/test_funcs.py
astropy/coordinates/tests/test_iau_fullstack.py
astropy/coordinates/tests/test_intermediate_transformations.py
astropy/coordinates/tests/test_matching.py
astropy/coordinates/tests/test_matrix_utilities.py
astropy/coordinates/tests/test_name_resolve.py
astropy/coordinates/tests/test_pickle.py
astropy/coordinates/tests/test_regression.py
astropy/coordinates/tests/test_representation.py
astropy/coordinates/tests/test_representation_arithmetic.py
astropy/coordinates/tests/test_representation_methods.py
astropy/coordinates/tests/test_shape_manipulation.py
astropy/coordinates/tests/test_sites.py
astropy/coordinates/tests/test_sky_coord.py
astropy/coordinates/tests/test_sky_coord_velocities.py
astropy/coordinates/tests/test_skyoffset_transformations.py
astropy/coordinates/tests/test_solar_system.py
astropy/coordinates/tests/test_transformations.py
astropy/coordinates/tests/test_unit_representation.py
astropy/coordinates/tests/test_velocity_corrs.py
astropy/coordinates/tests/utils.py
astropy/coordinates/transformations.py
astropy/cosmology/__init__.py
astropy/cosmology/core.py
astropy/cosmology/funcs.py
astropy/cosmology/parameters.py
astropy/cosmology/scalar_inv_efuncs.pyx
astropy/cosmology/tests/__init__.py
astropy/cosmology/tests/test_cosmology.py
astropy/cosmology/tests/test_pickle.py
astropy/extern/README.rst
astropy/extern/__init__.py
astropy/extern/bundled/__init__.py
astropy/extern/bundled/six.py
astropy/extern/configobj/__init__.py
astropy/extern/configobj/configobj.py
astropy/extern/configobj/validate.py
astropy/extern/css/jquery.dataTables.css
astropy/extern/js/jquery-3.1.1.js
astropy/extern/js/jquery-3.1.1.min.js
astropy/extern/js/jquery.dataTables.js
astropy/extern/js/jquery.dataTables.min.js
astropy/extern/ply/__init__.py
astropy/extern/ply/cpp.py
astropy/extern/ply/ctokens.py
astropy/extern/ply/lex.py
astropy/extern/ply/yacc.py
astropy/extern/setup_package.py
astropy/extern/six.py
astropy/io/__init__.py
astropy/io/ascii/__init__.py
astropy/io/ascii/basic.py
astropy/io/ascii/cds.py
astropy/io/ascii/connect.py
astropy/io/ascii/core.py
astropy/io/ascii/cparser.pyx
astropy/io/ascii/daophot.py
astropy/io/ascii/ecsv.py
astropy/io/ascii/fastbasic.py
astropy/io/ascii/fixedwidth.py
astropy/io/ascii/html.py
astropy/io/ascii/ipac.py
astropy/io/ascii/latex.py
astropy/io/ascii/misc.py
astropy/io/ascii/rst.py
astropy/io/ascii/setup_package.py
astropy/io/ascii/sextractor.py
astropy/io/ascii/src/tokenizer.c
astropy/io/ascii/src/tokenizer.h
astropy/io/ascii/tests/__init__.py
astropy/io/ascii/tests/common.py
astropy/io/ascii/tests/t/apostrophe.rdb
astropy/io/ascii/tests/t/apostrophe.tab
astropy/io/ascii/tests/t/bad.txt
astropy/io/ascii/tests/t/bars_at_ends.txt
astropy/io/ascii/tests/t/cds.dat
astropy/io/ascii/tests/t/cds/description/ReadMe
astropy/io/ascii/tests/t/cds/description/table.dat
astropy/io/ascii/tests/t/cds/glob/ReadMe
astropy/io/ascii/tests/t/cds/glob/lmxbrefs.dat
astropy/io/ascii/tests/t/cds/multi/ReadMe
astropy/io/ascii/tests/t/cds/multi/lhs2065.dat
astropy/io/ascii/tests/t/cds/multi/lp944-20.dat
astropy/io/ascii/tests/t/cds2.dat
astropy/io/ascii/tests/t/cds_malformed.dat
astropy/io/ascii/tests/t/commented_header.dat
astropy/io/ascii/tests/t/commented_header2.dat
astropy/io/ascii/tests/t/continuation.dat
astropy/io/ascii/tests/t/daophot.dat
astropy/io/ascii/tests/t/daophot.dat.gz
astropy/io/ascii/tests/t/daophot2.dat
astropy/io/ascii/tests/t/daophot3.dat
astropy/io/ascii/tests/t/daophot4.dat
astropy/io/ascii/tests/t/fill_values.txt
astropy/io/ascii/tests/t/fixed_width_2_line.txt
astropy/io/ascii/tests/t/html.html
astropy/io/ascii/tests/t/html2.html
astropy/io/ascii/tests/t/ipac.dat
astropy/io/ascii/tests/t/ipac.dat.bz2
astropy/io/ascii/tests/t/ipac.dat.xz
astropy/io/ascii/tests/t/latex1.tex
astropy/io/ascii/tests/t/latex1.tex.gz
astropy/io/ascii/tests/t/latex2.tex
astropy/io/ascii/tests/t/latex3.tex
astropy/io/ascii/tests/t/nls1_stackinfo.dbout
astropy/io/ascii/tests/t/no_data_cds.dat
astropy/io/ascii/tests/t/no_data_daophot.dat
astropy/io/ascii/tests/t/no_data_ipac.dat
astropy/io/ascii/tests/t/no_data_sextractor.dat
astropy/io/ascii/tests/t/no_data_with_header.dat
astropy/io/ascii/tests/t/no_data_without_header.dat
astropy/io/ascii/tests/t/sextractor.dat
astropy/io/ascii/tests/t/sextractor2.dat
astropy/io/ascii/tests/t/sextractor3.dat
astropy/io/ascii/tests/t/short.rdb
astropy/io/ascii/tests/t/short.rdb.bz2
astropy/io/ascii/tests/t/short.rdb.gz
astropy/io/ascii/tests/t/short.rdb.xz
astropy/io/ascii/tests/t/short.tab
astropy/io/ascii/tests/t/simple.txt
astropy/io/ascii/tests/t/simple2.txt
astropy/io/ascii/tests/t/simple3.txt
astropy/io/ascii/tests/t/simple4.txt
astropy/io/ascii/tests/t/simple5.txt
astropy/io/ascii/tests/t/simple_csv.csv
astropy/io/ascii/tests/t/simple_csv_missing.csv
astropy/io/ascii/tests/t/space_delim_blank_lines.txt
astropy/io/ascii/tests/t/space_delim_no_header.dat
astropy/io/ascii/tests/t/space_delim_no_names.dat
astropy/io/ascii/tests/t/test4.dat
astropy/io/ascii/tests/t/test5.dat
astropy/io/ascii/tests/t/vizier/ReadMe
astropy/io/ascii/tests/t/vizier/table1.dat
astropy/io/ascii/tests/t/vizier/table5.dat
astropy/io/ascii/tests/t/vots_spec.dat
astropy/io/ascii/tests/t/whitespace.dat
astropy/io/ascii/tests/test_c_reader.py
astropy/io/ascii/tests/test_cds_header_from_readme.py
astropy/io/ascii/tests/test_compressed.py
astropy/io/ascii/tests/test_connect.py
astropy/io/ascii/tests/test_ecsv.py
astropy/io/ascii/tests/test_fixedwidth.py
astropy/io/ascii/tests/test_html.py
astropy/io/ascii/tests/test_ipac_definitions.py
astropy/io/ascii/tests/test_read.py
astropy/io/ascii/tests/test_rst.py
astropy/io/ascii/tests/test_types.py
astropy/io/ascii/tests/test_write.py
astropy/io/ascii/ui.py
astropy/io/fits/__init__.py
astropy/io/fits/_numpy_hacks.py
astropy/io/fits/card.py
astropy/io/fits/column.py
astropy/io/fits/connect.py
astropy/io/fits/convenience.py
astropy/io/fits/diff.py
astropy/io/fits/file.py
astropy/io/fits/fitsrec.py
astropy/io/fits/fitstime.py
astropy/io/fits/hdu/__init__.py
astropy/io/fits/hdu/base.py
astropy/io/fits/hdu/compressed.py
astropy/io/fits/hdu/groups.py
astropy/io/fits/hdu/hdulist.py
astropy/io/fits/hdu/image.py
astropy/io/fits/hdu/nonstandard.py
astropy/io/fits/hdu/streaming.py
astropy/io/fits/hdu/table.py
astropy/io/fits/header.py
astropy/io/fits/scripts/__init__.py
astropy/io/fits/scripts/fitscheck.py
astropy/io/fits/scripts/fitsdiff.py
astropy/io/fits/scripts/fitsheader.py
astropy/io/fits/scripts/fitsinfo.py
astropy/io/fits/setup_package.py
astropy/io/fits/src/compressionmodule.c
astropy/io/fits/src/compressionmodule.h
astropy/io/fits/tests/__init__.py
astropy/io/fits/tests/cfitsio_verify.c
astropy/io/fits/tests/data/arange.fits
astropy/io/fits/tests/data/ascii.fits
astropy/io/fits/tests/data/blank.fits
astropy/io/fits/tests/data/btable.fits
astropy/io/fits/tests/data/chandra_time.fits
astropy/io/fits/tests/data/checksum.fits
astropy/io/fits/tests/data/comp.fits
astropy/io/fits/tests/data/compressed_float_bzero.fits
astropy/io/fits/tests/data/compressed_image.fits
astropy/io/fits/tests/data/fixed-1890.fits
astropy/io/fits/tests/data/group.fits
astropy/io/fits/tests/data/history_header.fits
astropy/io/fits/tests/data/memtest.fits
astropy/io/fits/tests/data/o4sp040b0_raw.fits
astropy/io/fits/tests/data/random_groups.fits
astropy/io/fits/tests/data/scale.fits
astropy/io/fits/tests/data/stddata.fits
astropy/io/fits/tests/data/table.fits
astropy/io/fits/tests/data/tb.fits
astropy/io/fits/tests/data/tdim.fits
astropy/io/fits/tests/data/test0.fits
astropy/io/fits/tests/data/variable_length_table.fits
astropy/io/fits/tests/data/zerowidth.fits
astropy/io/fits/tests/test_checksum.py
astropy/io/fits/tests/test_compression_failures.py
astropy/io/fits/tests/test_connect.py
astropy/io/fits/tests/test_convenience.py
astropy/io/fits/tests/test_core.py
astropy/io/fits/tests/test_diff.py
astropy/io/fits/tests/test_division.py
astropy/io/fits/tests/test_fitscheck.py
astropy/io/fits/tests/test_fitsdiff.py
astropy/io/fits/tests/test_fitsheader.py
astropy/io/fits/tests/test_fitsinfo.py
astropy/io/fits/tests/test_fitstime.py
astropy/io/fits/tests/test_groups.py
astropy/io/fits/tests/test_hdulist.py
astropy/io/fits/tests/test_header.py
astropy/io/fits/tests/test_image.py
astropy/io/fits/tests/test_nonstandard.py
astropy/io/fits/tests/test_structured.py
astropy/io/fits/tests/test_table.py
astropy/io/fits/tests/test_uint.py
astropy/io/fits/tests/test_util.py
astropy/io/fits/util.py
astropy/io/fits/verify.py
astropy/io/misc/__init__.py
astropy/io/misc/asdf/__init__.py
astropy/io/misc/asdf/extension.py
astropy/io/misc/asdf/schemas/astropy.org/astropy/coordinates/frames/icrs-1.0.0.yaml
astropy/io/misc/asdf/setup_package.py
astropy/io/misc/asdf/tags/__init__.py
astropy/io/misc/asdf/tags/coordinates/__init__.py
astropy/io/misc/asdf/tags/coordinates/frames.py
astropy/io/misc/asdf/tags/coordinates/tests/__init__.py
astropy/io/misc/asdf/tags/coordinates/tests/test_coords.py
astropy/io/misc/asdf/tags/fits/__init__.py
astropy/io/misc/asdf/tags/fits/fits.py
astropy/io/misc/asdf/tags/fits/setup_package.py
astropy/io/misc/asdf/tags/fits/tests/__init__.py
astropy/io/misc/asdf/tags/fits/tests/data/complex.fits
astropy/io/misc/asdf/tags/fits/tests/test_fits.py
astropy/io/misc/asdf/tags/table/__init__.py
astropy/io/misc/asdf/tags/table/table.py
astropy/io/misc/asdf/tags/table/tests/__init__.py
astropy/io/misc/asdf/tags/table/tests/test_table.py
astropy/io/misc/asdf/tags/time/__init__.py
astropy/io/misc/asdf/tags/time/tests/__init__.py
astropy/io/misc/asdf/tags/time/tests/test_time.py
astropy/io/misc/asdf/tags/time/time.py
astropy/io/misc/asdf/tags/transform/__init__.py
astropy/io/misc/asdf/tags/transform/basic.py
astropy/io/misc/asdf/tags/transform/compound.py
astropy/io/misc/asdf/tags/transform/polynomial.py
astropy/io/misc/asdf/tags/transform/projections.py
astropy/io/misc/asdf/tags/transform/tabular.py
astropy/io/misc/asdf/tags/transform/tests/__init__.py
astropy/io/misc/asdf/tags/transform/tests/test_transform.py
astropy/io/misc/asdf/tags/unit/__init__.py
astropy/io/misc/asdf/tags/unit/quantity.py
astropy/io/misc/asdf/tags/unit/tests/__init__.py
astropy/io/misc/asdf/tags/unit/tests/test_quantity.py
astropy/io/misc/asdf/tags/unit/tests/test_unit.py
astropy/io/misc/asdf/tags/unit/unit.py
astropy/io/misc/asdf/types.py
astropy/io/misc/connect.py
astropy/io/misc/hdf5.py
astropy/io/misc/pickle_helpers.py
astropy/io/misc/tests/__init__.py
astropy/io/misc/tests/test_hdf5.py
astropy/io/misc/tests/test_pickle_helpers.py
astropy/io/misc/tests/test_yaml.py
astropy/io/misc/yaml.py
astropy/io/registry.py
astropy/io/tests/__init__.py
astropy/io/tests/test_registry.py
astropy/io/votable/__init__.py
astropy/io/votable/connect.py
astropy/io/votable/converters.py
astropy/io/votable/data/VOTable.dtd
astropy/io/votable/data/VOTable.v1.1.xsd
astropy/io/votable/data/VOTable.v1.2.xsd
astropy/io/votable/data/VOTable.v1.3.xsd
astropy/io/votable/data/ucd1p-words.txt
astropy/io/votable/exceptions.py
astropy/io/votable/setup_package.py
astropy/io/votable/src/.gitignore
astropy/io/votable/src/tablewriter.c
astropy/io/votable/table.py
astropy/io/votable/tests/__init__.py
astropy/io/votable/tests/converter_test.py
astropy/io/votable/tests/data/custom_datatype.xml
astropy/io/votable/tests/data/empty_table.xml
astropy/io/votable/tests/data/gemini.xml
astropy/io/votable/tests/data/irsa-nph-error.xml
astropy/io/votable/tests/data/irsa-nph-m31.xml
astropy/io/votable/tests/data/names.xml
astropy/io/votable/tests/data/no_resource.txt
astropy/io/votable/tests/data/no_resource.xml
astropy/io/votable/tests/data/nonstandard_units.xml
astropy/io/votable/tests/data/regression.bin.tabledata.truth.1.1.xml
astropy/io/votable/tests/data/regression.bin.tabledata.truth.1.3.xml
astropy/io/votable/tests/data/regression.xml
astropy/io/votable/tests/data/resource_groups.xml
astropy/io/votable/tests/data/tb.fits
astropy/io/votable/tests/data/too_many_columns.xml.gz
astropy/io/votable/tests/data/validation.txt
astropy/io/votable/tests/exception_test.py
astropy/io/votable/tests/resource_test.py
astropy/io/votable/tests/table_test.py
astropy/io/votable/tests/tree_test.py
astropy/io/votable/tests/ucd_test.py
astropy/io/votable/tests/util_test.py
astropy/io/votable/tests/vo_test.py
astropy/io/votable/tree.py
astropy/io/votable/ucd.py
astropy/io/votable/util.py
astropy/io/votable/validator/__init__.py
astropy/io/votable/validator/html.py
astropy/io/votable/validator/main.py
astropy/io/votable/validator/result.py
astropy/io/votable/validator/urls/cone.big.dat.gz
astropy/io/votable/validator/urls/cone.broken.dat.gz
astropy/io/votable/validator/urls/cone.good.dat.gz
astropy/io/votable/validator/urls/cone.incorrect.dat.gz
astropy/io/votable/volint.py
astropy/io/votable/xmlutil.py
astropy/logger.py
astropy/modeling/__init__.py
astropy/modeling/blackbody.py
astropy/modeling/core.py
astropy/modeling/fitting.py
astropy/modeling/functional_models.py
astropy/modeling/mappings.py
astropy/modeling/models.py
astropy/modeling/optimizers.py
astropy/modeling/parameters.py
astropy/modeling/polynomial.py
astropy/modeling/powerlaws.py
astropy/modeling/projections.py
astropy/modeling/rotations.py
astropy/modeling/separable.py
astropy/modeling/setup_package.py
astropy/modeling/src/.gitignore
astropy/modeling/src/projections.c.templ
astropy/modeling/statistic.py
astropy/modeling/tabular.py
astropy/modeling/tests/__init__.py
astropy/modeling/tests/data/1904-66_AZP.fits
astropy/modeling/tests/data/__init__.py
astropy/modeling/tests/data/hst_sip.hdr
astropy/modeling/tests/data/idcompspec.fits
astropy/modeling/tests/data/irac_sip.hdr
astropy/modeling/tests/example_models.py
astropy/modeling/tests/irafutil.py
astropy/modeling/tests/test_blackbody.py
astropy/modeling/tests/test_compound.py
astropy/modeling/tests/test_constraints.py
astropy/modeling/tests/test_core.py
astropy/modeling/tests/test_fitters.py
astropy/modeling/tests/test_functional_models.py
astropy/modeling/tests/test_input.py
astropy/modeling/tests/test_mappings.py
astropy/modeling/tests/test_models.py
astropy/modeling/tests/test_models_quantities.py
astropy/modeling/tests/test_parameters.py
astropy/modeling/tests/test_polynomial.py
astropy/modeling/tests/test_projections.py
astropy/modeling/tests/test_quantities_evaluation.py
astropy/modeling/tests/test_quantities_fitting.py
astropy/modeling/tests/test_quantities_model.py
astropy/modeling/tests/test_quantities_parameters.py
astropy/modeling/tests/test_quantities_rotations.py
astropy/modeling/tests/test_rotations.py
astropy/modeling/tests/test_separable.py
astropy/modeling/tests/test_utils.py
astropy/modeling/tests/utils.py
astropy/modeling/utils.py
astropy/nddata/__init__.py
astropy/nddata/ccddata.py
astropy/nddata/compat.py
astropy/nddata/decorators.py
astropy/nddata/flag_collection.py
astropy/nddata/mixins/__init__.py
astropy/nddata/mixins/ndarithmetic.py
astropy/nddata/mixins/ndio.py
astropy/nddata/mixins/ndslicing.py
astropy/nddata/mixins/tests/__init__.py
astropy/nddata/mixins/tests/test_ndarithmetic.py
astropy/nddata/mixins/tests/test_ndio.py
astropy/nddata/mixins/tests/test_ndslicing.py
astropy/nddata/nddata.py
astropy/nddata/nddata_base.py
astropy/nddata/nddata_withmixins.py
astropy/nddata/nduncertainty.py
astropy/nddata/setup_package.py
astropy/nddata/tests/__init__.py
astropy/nddata/tests/data/sip-wcs.fits
astropy/nddata/tests/test_ccddata.py
astropy/nddata/tests/test_compat.py
astropy/nddata/tests/test_decorators.py
astropy/nddata/tests/test_flag_collection.py
astropy/nddata/tests/test_nddata.py
astropy/nddata/tests/test_nddata_base.py
astropy/nddata/tests/test_nduncertainty.py
astropy/nddata/tests/test_utils.py
astropy/nddata/utils.py
astropy/samp/__init__.py
astropy/samp/client.py
astropy/samp/constants.py
astropy/samp/data/astropy_icon.png
astropy/samp/data/clientaccesspolicy.xml
astropy/samp/data/crossdomain.xml
astropy/samp/errors.py
astropy/samp/hub.py
astropy/samp/hub_proxy.py
astropy/samp/hub_script.py
astropy/samp/integrated_client.py
astropy/samp/lockfile_helpers.py
astropy/samp/setup_package.py
astropy/samp/standard_profile.py
astropy/samp/tests/__init__.py
astropy/samp/tests/test_client.py
astropy/samp/tests/test_errors.py
astropy/samp/tests/test_helpers.py
astropy/samp/tests/test_hub.py
astropy/samp/tests/test_hub_proxy.py
astropy/samp/tests/test_hub_script.py
astropy/samp/tests/test_standard_profile.py
astropy/samp/tests/test_web_profile.py
astropy/samp/tests/web_profile_test_helpers.py
astropy/samp/utils.py
astropy/samp/web_profile.py
astropy/setup_package.py
astropy/stats/__init__.py
astropy/stats/bayesian_blocks.py
astropy/stats/biweight.py
astropy/stats/circstats.py
astropy/stats/funcs.py
astropy/stats/histogram.py
astropy/stats/info_theory.py
astropy/stats/jackknife.py
astropy/stats/lombscargle/__init__.py
astropy/stats/lombscargle/_statistics.py
astropy/stats/lombscargle/core.py
astropy/stats/lombscargle/implementations/__init__.py
astropy/stats/lombscargle/implementations/chi2_impl.py
astropy/stats/lombscargle/implementations/cython_impl.pyx
astropy/stats/lombscargle/implementations/fast_impl.py
astropy/stats/lombscargle/implementations/fastchi2_impl.py
astropy/stats/lombscargle/implementations/main.py
astropy/stats/lombscargle/implementations/mle.py
```


# The last commit

```
e4f19c106 SWE-bench


```

```diff

```


# CONTRIBUTING.md (the start)

```
Contributing to Astropy
=======================

Reporting Issues
----------------

When opening an issue to report a problem, please try and provide a minimal
code example that reproduces the issue, and also include details of the
operating system, and the Python, Numpy, and Astropy versions you are using.

Contributing code
-----------------

So you're interested in contributing code to Astropy? Excellent!

Most contributions to Astropy are done via pull requests from GitHub users'
forks of the [astropy repository](https://github.com/astropy/astropy). If you're new to this style of development,
you'll want to read over our [development workflow](http://docs.astropy.org/en/latest/development/workflow/development_workflow.html).

Once you open a pull request (which should be opened against the ``master``
branch, not against any of the other branches), please make sure that you
include the following:

- **Code**: the code you are adding, which should follow as much as possible
  our [coding guidelines](http://docs.astropy.org/en/latest/development/codeguide.html).

- **Tests**: these are usually tests to ensure that code that previously
  failed now works (regression tests) or tests that cover as much as possible
  of the new functionality to make sure it doesn't break in future, and also
  returns consistent results on all platforms (since we run these tests on many
  platforms/configurations). For more information about how to write tests, see
  our [testing guidelines](http://docs.astropy.org/en/latest/development/testguide.html).

- **Documentation**: if you are adding new functionality, be sure to include a
  description in the main documentation (in ``docs/``). Again, we have some
  detailed [documentation guidelines](http://docs.astropy.org/en/latest/development/docguide.html)
  to help you out.

- **Changelog entry**: whether you are fixing a bug or adding new
  functionality, you should add an entry to the ``CHANGES.rst`` file that
  includes the PR number and if possible the issue number (if you are
  opening a pull request you may not know this yet, but you can add it once
  the pull request is open). If you're not sure where to put the changelog
  entry, wait at least until a maintainer has reviewed your PR and assigned
  it to a milestone.

  You do not need to include a changelog entry for fixes to bugs introduced in
  the developer version and therefore are not present in the stable releases.
  In general you do not need to include a changelog entry for minor
  documentation or test updates.  Only user-visible changes (new features/API
  changes, fixed issues) need to be mentioned.  If in doubt ask the core
  maintainer reviewing your changes.

Other Tips
----------

- To prevent the automated tests from running you can add ``[ci
  skip]`` to your commit message. This is useful if your PR is a work
  in progress and you are not yet ready for the tests to run.  For
  example:

      $ git commit -m "WIP widget [ci skip]"

  - If you already made the commit without including this string, you can edit
    your existing commit message by running:

        $ git commit --amend

- To skip only the AppVeyor (Windows) CI builds you can use ``[skip
  appveyor]``, and to skip testing on Travis CI use ``[skip travis]``.

- If your commit makes substantial changes to the documentation, but no code
  changes, the you can use ``[docs only]``, that will skip all but the
  documentation building jobs on Travis.

- When contributing trivial documentation fixes (i.e. fixes to typos,
  spelling, grammar) that do not contain any special markup and are
  not associated with code changes, please include the string ``[docs
  only]`` in your commit message.

      $ git commit -m "Fixed typo [docs only]"


Checklist for Contributed Code
------------------------------

A pull request for a new feature will be reviewed to see if it meets the
following requirements.  For any pull request, an astropy maintainer can
help to make sure that the pull request meets the requirements for inclusion
in the package.

**Scientific Quality**
(when applicable)
  * Is the submission relevant to astronomy?
  * Are references included to the origin source for the algorithm?
  * Does the code perform as expected?
  * Has the code been tested against previously existing implementations?

**Code Quality**
  * Are the [coding guidelines](http://docs.astropy.org/en/latest/development/codeguide.html)
    followed?
  * Is the code compatible with Python >=3.5?
  * Are there dependencies other than the Astropy core, the Python Standard
    Library, and NumPy 1.10.0 or later?
    * Is the package importable even if the C-extensions are not built?
    * Are additional dependencies handled appropriately?
    * Do functions that require additional dependencies  raise an `ImportError`
        if they are not present?

**Testing**
  * Are the [testing guidelines](http://docs.astropy.org/en/latest/development/testguide.html) followed?
  * Are the inputs to the functions sufficiently tested?
  * Are there tests for any exceptions raised?
  * Are there tests for the expected performance?
  * Are the sources for the tests documented?
  * Have tests that require an [optional dependency marked](http://docs.astropy.org/en/latest/development/testguide.html#tests-requiring-optional-dependencies) as such?
  * Does python setup.py test run without failures?

**Documentation**
  * Are the [documentation guidelines](http://docs.astropy.org/en/latest/development/docguide.html) followed?
  * Is there a [docstring](http://docs.astropy.org/en/latest/development/docrules.html) in the function describing:
    * What the code does?
    * The format of the inputs of the function?
    * The format of the outputs of the function?
    * References to the original algorithms?
    * Any exceptions which are raised?
    * An example of running the code?
  * Is there any information needed to be added to the docs to describe the function?
  * Does the docume
```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`pytest astropy/utils/tests/test_misc.py`

## Scope
`astropy/utils/misc.py`
`astropy/utils/tests/`

## Done when
- Attributes that are `property` objects receive the docstring of the corresponding property in the base class when their own docstring is absent.
- Function and method attributes keep inheriting docstrings exactly as before.
- The metaclass no longer skips properties merely because `inspect.isfunction` is false for them.
- A subclass property without a docstring exposes a non-`None` `__doc__` matching the base property's docstring.

## Approach
Work is in `InheritDocstrings.__new__` in `astropy/utils/misc.py`: for each attribute placed in the class body, resolve the same-named attribute on the base classes, and if the child attribute has no docstring, copy the base attribute's docstring onto it. The current branch only handles `inspect.isfunction`, so add a branch for `isinstance(value, property)`.

Candidate approaches:
1. Special-case properties first: when `value` is a `property`, look up the base property and assign `value.__doc__ = getattr(base_attr, '__doc__', None)` (or `value.fget.__doc__` if assigning on the property itself does not stick). Keeps the function path untouched.
2. Normalize the doc source up front: treat functions as themselves and properties as `value.fget`, enter the common inheritance block when either `inspect.isfunction(value)` or `isinstance(value, property)`, then copy the source docstring back onto the appropriate object. More uniform, but touches the existing function logic.
3. Avoid the metaclass by using `__init_subclass__`/a class decorator; this changes the public mechanism and is riskier for existing users, so use only if the metaclass route cannot be made to work.

Likely failure points to check if the first attempt fails: properties may be descriptors whose `__doc__` must be set on the getter or on the property depending on Python version; base lookup should search the MRO rather than only direct bases; and a child property with an explicit docstring must not be overwritten.
```

### `prompt.md`

```
InheritDocstrings metaclass doesn't work for properties
Inside the InheritDocstrings metaclass it uses `inspect.isfunction` which returns `False` for properties.
```

### `review.md`

```
verdict: PASS

Findings:
- The metaclass now handles `property` attributes explicitly (`elif isinstance(val, property)`), so properties are no longer skipped merely because `inspect.isfunction` is false. This meets the core ask.
- Function/method handling is preserved: the `inspect.isfunction(val)` branch keeps the original condition (`val.__doc__ is None`) and the same MRO search, so existing behavior is unchanged.
- Property attributes with no docstring receive the base class's corresponding property docstring; the code also propagates it to `fget.__doc__` when absent, satisfying the "non-None `__doc__` matching base" requirement.
- The added test `test_inherit_docstrings_property` exercises the required scenario (subclass property without docstring inherits "PROPERTY", value still works) and passes.
- The `is_public_member` guard is applied consistently (early `continue`) to both branches, matching prior intent.
- Both modified files (`astropy/utils/misc.py`, `astropy/utils/tests/test_misc.py`) are within Scope; no unrelated files touched.
- Check output shows 9 passed, 1 skipped with exit status 0, so no regressions in the targeted test module.
- Minor observation (not a failure): the property branch mutates the subclass `fget.__doc__` as a side effect, which is harmless here and consistent with exposing inherited docs; and a property whose `__doc__` is already set is left untouched, which aligns with "when their own docstring is absent."
```

### `scope.txt`

```
scope: astropy/utils/misc.py astropy/utils/tests
changed: astropy/utils/misc.py +20 -3
changed: astropy/utils/tests/test_misc.py +18 -0
```

### `task.md`

```
# Task

## Prompt

InheritDocstrings metaclass doesn't work for properties
Inside the InheritDocstrings metaclass it uses `inspect.isfunction` which returns `False` for properties.

## Deliverable

changes to this tree

## Check

`pytest astropy/utils/tests/test_misc.py`

## Scope

`astropy/utils/misc.py`
`astropy/utils/tests/`

## Done when

- Attributes that are `property` objects receive the docstring of the corresponding property in the base class when their own docstring is absent.
- Function and method attributes keep inheriting docstrings exactly as before.
- The metaclass no longer skips properties merely because `inspect.isfunction` is false for them.
- A subclass property without a docstring exposes a non-`None` `__doc__` matching the base property's docstring.
```

### `test-output.log`

```
check: pytest astropy/utils/tests/test_misc.py
============================= test session starts ==============================
platform linux -- Python 3.6.13, pytest-3.3.1, py-1.11.0, pluggy-0.6.0

Running tests with Astropy version 3.1.dev21447.
Running tests in astropy/utils/tests/test_misc.py.

Date: 2026-11-06T10:47:47

Platform: Linux-7.0.0-1014-gcp-x86_64-with-debian-bookworm-sid

Executable: /opt/miniconda3/envs/testbed/bin/python

Full Python Version: 
3.6.13 |Anaconda, Inc.| (default, Jun  4 2021, 14:25:59) 
[GCC 7.5.0]

encodings: sys: utf-8, locale: UTF-8, filesystem: utf-8
byteorder: little
float info: dig: 15, mant_dig: 15

Numpy: 1.16.0
Scipy: not available
Matplotlib: not available
h5py: not available
Pandas: not available
Cython: 0.27.3
Using Astropy options: remote_data: none.

rootdir: /testbed, inifile: setup.cfg
plugins: xdist-1.20.1, remotedata-0.2.0, openfiles-0.2.0, mock-1.6.3, forked-0.2, filter-subpackage-0.1, doctestplus-0.1.2, cov-2.5.1, astropy-header-0.1, arraydiff-0.1, hypothesis-3.44.2
collected 10 items

astropy/utils/tests/test_misc.py ..s.......                              [100%]

=============================== warnings summary ===============================
None
  Module already imported so cannot be rewritten: astropy.tests.plugins.display

-- Docs: http://doc.pytest.org/en/latest/warnings.html
=============== 9 passed, 1 skipped, 1 warnings in 0.25 seconds ================
scope: astropy/utils/misc.py astropy/utils/tests
changed: astropy/utils/misc.py +20 -3
changed: astropy/utils/tests/test_misc.py +18 -0
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
