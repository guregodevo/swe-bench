# astropy__astropy-14096 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 345s 48 lines cost=0.014836 in=275131 cached=217600 out=31751 calls=27`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

Rerun with the web tools removed: in the first pass an agent's `web_search` (answered by OpenRouter, so through the one allowed host) returned web results on this task, in the single call or the team, so both first-pass attempts were discarded and the task run again with `web_search` and `web_fetch` taken out of every agent's tools before the workflow started. No model request of this run offered a web tool:

```
17:16:21 weboff: chief: web_fetch,web_search
17:16:21 weboff: coder: web_fetch,web_search
```

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

Subclassed SkyCoord gives misleading attribute access message
I'm trying to subclass `SkyCoord`, and add some custom properties. This all seems to be working fine, but when I have a custom property (`prop` below) that tries to access a non-existent attribute (`random_attr`) below, the error message is misleading because it says `prop` doesn't exist, where it should say `random_attr` doesn't exist.

```python
import astropy.coordinates as coord


class custom_coord(coord.SkyCoord):
    @property
    def prop(self):
        return self.random_attr


c = custom_coord('00h42m30s', '+41d12m00s', frame='icrs')
c.prop
```

raises
```
Traceback (most recent call last):
  File "test.py", line 11, in <module>
    c.prop
  File "/Users/dstansby/miniconda3/lib/python3.7/site-packages/astropy/coordinates/sky_coordinate.py", line 600, in __getattr__
    .format(self.__class__.__name__, attr))
AttributeError: 'custom_coord' object has no attribute 'prop'
```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"__getattr__\" astropy/coordinates/sky_coordinate.py | head"
}
```

**tool result**

```
/testbed
CHANGES.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.md
GOVERNANCE.md
LICENSE.rst
MANIFEST.in
README.rst
astropy
astropy.egg-info
cextern
codecov.yml
conftest.py
docs
examples
licenses
pip-requirements
pyproject.toml
setup.cfg
setup.py
tox.ini
```

**tool result**

```
869:    def __getattr__(self, attr):
903:        # This is to make anything available through __getattr__ immutable
918:            # variable.  See __getattr__ above.
945:            # the corresponding private variable.  See __getattr__ above.
```

**assistant → tool `read_file`**

```json
{
  "path": "astropy/coordinates/sky_coordinate.py",
  "offset": 850,
  "limit": 100
}
```

**tool result**

```
            attrnm: getattr(self, attrnm) for attrnm in self._extra_frameattr_names
        }
        frattrs["obstime"] = new_obstime
        result = self.__class__(icrs2, **frattrs).transform_to(self.frame)

        # Without this the output might not have the right differential type.
        # Not sure if this fixes the problem or just hides it.  See #11932
        result.differential_type = self.differential_type

        return result

    def _is_name(self, string):
        """
        Returns whether a string is one of the aliases for the frame.
        """
        return self.frame.name == string or (
            isinstance(self.frame.name, list) and string in self.frame.name
        )

    def __getattr__(self, attr):
        """
        Overrides getattr to return coordinates that this can be transformed
        to, based on the alias attr in the primary transform graph.
        """
        if "_sky_coord_frame" in self.__dict__:
            if self._is_name(attr):
                return self  # Should this be a deepcopy of self?

            # Anything in the set of all possible frame_attr_names is handled
            # here. If the attr is relevant for the current frame then delegate
            # to self.frame otherwise get it from self._<attr>.
            if attr in frame_transform_graph.frame_attributes:
                if attr in self.frame.frame_attributes:
                    return getattr(self.frame, attr)
                else:
                    return getattr(self, "_" + attr, None)

            # Some attributes might not fall in the above category but still
            # are available through self._sky_coord_frame.
            if not attr.startswith("_") and hasattr(self._sky_coord_frame, attr):
                return getattr(self._sky_coord_frame, attr)

            # Try to interpret as a new frame for transforming.
            frame_cls = frame_transform_graph.lookup_name(attr)
            if frame_cls is not None and self.frame.is_transformable_to(frame_cls):
                return self.transform_to(attr)

        # Fail
        raise AttributeError(
            f"'{self.__class__.__name__}' object has no attribute '{attr}'"
        )

    def __setattr__(self, attr, val):
        # This is to make anything available through __getattr__ immutable
        if "_sky_coord_frame" in self.__dict__:
            if self._is_name(attr):
                raise AttributeError(f"'{attr}' is immutable")

            if not attr.startswith("_") and hasattr(self._sky_coord_frame, attr):
                setattr(self._sky_coord_frame, attr, val)
                return

            frame_cls = frame_transform_graph.lookup_name(attr)
            if frame_cls is not None and self.frame.is_transformable_to(frame_cls):
                raise AttributeError(f"'{attr}' is immutable")

        if attr in frame_transform_graph.frame_attributes:
            # All possible frame attributes can be set, but only via a private
            # variable.  See __getattr__ above.
            super().__setattr__("_" + attr, val)
            # Validate it
            frame_transform_graph.frame_attributes[attr].__get__(self)
            # And add to set of extra attributes
            self._extra_frameattr_names |= {attr}

        else:
            # Otherwise, do the standard Python attribute setting
            super().__setattr__(attr, val)

    def __delattr__(self, attr):
        # mirror __setattr__ above
        if "_sky_coord_frame" in self.__dict__:
            if self._is_name(attr):
                raise AttributeError(f"'{attr}' is immutable")

            if not attr.startswith("_") and hasattr(self._sky_coord_frame, attr):
                delattr(self._sky_coord_frame, attr)
                return

            frame_cls = frame_transform_graph.lookup_name(attr)
            if frame_cls is not None and self.frame.is_transformable_to(frame_cls):
                raise AttributeError(f"'{attr}' is immutable")

        if attr in frame_transform_graph.frame_attributes:
            # All possible frame attributes can be deleted, but need to remove
            # the corresponding private variable.  See __getattr__ above.
            super().__delattr__("_" + attr)
            # Also remove it from the set of extra attributes
            self._extra_frameattr_names -= {attr}


[1274 more lines in /testbed/astropy/coordinates/sky_coordinate.py (2223 in all). read_file with offset: 950 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"random_attr\\|no attribute.*prop\\|__getattr__\" astropy/coordinates/tests/test_sky_coord.py | head -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -5 && git status --short | head"
}
```

**tool result**

```

```

**tool result**

```
06c74e6ae SWE-bench
1a4462d72 Merge pull request #14102 from zoghbi-a/fix-votable-validator-issue-#14099
8916498eb Merge pull request #14051 from dstansby/manifest-clean
05d27d567 Fixed ProgressBar iterator, and added support for str urls in io.votable.validator.validator.make_validation_report
0e923721d Merge pull request #14103 from astropy/pre-commit-ci-update-config
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"def __getattr__\" astropy/coordinates/*.py astropy/coordinates/**/*.py | head -30"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport astropy.coordinates as coord\nclass custom_coord(coord.SkyCoord):\n    @property\n    def prop(self):\n        return self.random_attr\nc=custom_coord('00h42m30s','+41d12m00s',frame='icrs')\ntry:\n    c.prop\nexcept Exception as e:\n    import traceback; traceback.print_exc()\nprint(type(c).__dict__.get('prop'))\nEOF"
}
```

**tool result**

```
astropy/coordinates/baseframe.py:1726:    def __getattr__(self, attr):
astropy/coordinates/baseframe.py:2025:    def __getattr__(self, name):
astropy/coordinates/sky_coordinate.py:869:    def __getattr__(self, attr):
```

**tool result**

```
Traceback (most recent call last):
  File "<stdin>", line 8, in <module>
  File "/testbed/astropy/coordinates/sky_coordinate.py", line 898, in __getattr__
    raise AttributeError(
AttributeError: 'custom_coord' object has no attribute 'prop'
<property object at 0x74d39af669f0>
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class SkyCoord\\|class BaseCoordinateFrame\" astropy/coordinates/sky_coordinate.py astropy/coordinates/baseframe.py | head; python - <<'EOF'\nfrom astropy.coordinates import SkyCoord\nprint(SkyCoord.__mro__)\nEOF"
}
```

**tool result**

```
astropy/coordinates/sky_coordinate.py:37:class SkyCoordInfo(MixinInfo):
astropy/coordinates/sky_coordinate.py:168:class SkyCoord(ShapedLikeNDArray):
astropy/coordinates/baseframe.py:174:class BaseCoordinateFrame(ShapedLikeNDArray):
(<class 'astropy.coordinates.sky_coordinate.SkyCoord'>, <class 'astropy.utils.shapes.ShapedLikeNDArray'>, <class 'astropy.utils.shapes.NDArrayShapeMethods'>, <class 'object'>)
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport sys, traceback\nclass A:\n    @property\n    def prop(self):\n        return self.random_attr\n    def __getattr__(self, attr):\n        print('getattr called', attr, 'exc_info', sys.exc_info())\n        raise AttributeError('masked %s' % attr)\ntry:\n    A().prop\nexcept Exception:\n    traceback.print_exc()\nEOF"
}
```

**tool result**

```
Traceback (most recent call last):
  File "<stdin>", line 10, in <module>
  File "<stdin>", line 8, in __getattr__
AttributeError: masked prop
getattr called random_attr exc_info (None, None, None)
getattr called prop exc_info (None, None, None)
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline -- astropy/coordinates/sky_coordinate.py | head -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python -V; grep -n \"version\" astropy/version.py 2>/dev/null | head; grep -rn \"class ShapedLikeNDArray\" astropy/utils/shapes.py"
}
```

**tool result**

```
da8973fe3 [refactor] Prefer f-strings in `astropy/coordinates`
fbbc0cb37 [black] Allow `black` to run on `astropy.coordinates`
940baa3e7 isort changes for black compatibility
0c37a7141 Merge pull request #13484 from maxnoe/fix_get_frame_attr_names
eea7b8eed Deprecate get_frame_attr_names, add get_frame_attr_defaults
223081236 Allow comparing frame with data to SkyCoord, fixes #13476
fdc2dd273 Apply flake8 checks
c1695fa07 isort coordinates
4977f6e50 deprecate override__dir__
9caaf1169 run pyupgrade
72165b071 run pyupgrade
e5a4baeeb Apply suggestions from @mhvk code review
c412e8043 Misc coordinate docstring fixes
07422a947 Raise exceptions from other exceptions in coordinates
36e7e743d Make `apply_space_motion()` keep differential type
4027356d3 Fix various typos
9318f427c Add a method for converting a SkyCoord to a QTable
23f059173 Update SkyCoordInfo._represent_as_dict()
239639781 Do not propagate origin to SkyCoord.
dc469939a Resolve intersphinx to astropy as current build
```

**tool result**

```
Python 3.9.20
1:# NOTE: First try _dev.scm_version if it exists and setuptools_scm is installed
3:# fall back on the generated _version module.
6:        from ._dev.scm_version import version
8:        from ._version import version
13:        f'could not determine {__name__.split(".")[0]} package version; '
18:    version = "0.0.0"
22:def split_version(version):
26:        from packaging.version import Version
28:        v = Version(version)
37:major, minor, bugfix = split_version(version)
142:class ShapedLikeNDArray(NDArrayShapeMethods, metaclass=abc.ABCMeta):
```

**assistant → tool `bash`**

```json
{
  "command": "find / -path '*/astropy/coordinates/sky_coordinate.py' 2>/dev/null | head"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport astropy\nprint(astropy.__file__, astropy.__version__)\nEOF"
}
```

**tool result**

```
/testbed/astropy/coordinates/sky_coordinate.py
```

**tool result**

```
/testbed/astropy/__init__.py 5.3.dev62+g1a4462d72.d20260813
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class.*SkyCoord\\|subclass\" astropy/coordinates/tests/test_sky_coord.py | head -30; grep -n \"getattr\\|AttributeError\" astropy/coordinates/tests/test_sky_coord.py | head -40"
}
```

**tool result**

```
4:Tests for the SkyCoord class.  Note that there are also SkyCoord tests in
570:    class SkyCoordSub(SkyCoord):
580:        match="an only set from object of same class: SkyCoordSub vs. SkyCoord",
1374:    class SkyCoord2(SkyCoord):
1378:    assert scnew.__class__ is SkyCoord
1379:    assert scnew2.__class__ is SkyCoord2
59:        atol = 1.0e-8 * getattr(a, "unit", 1.0)
708:def test_frame_attr_getattr():
1020:    q2s = [getattr(coord, attr) for attr in attrs]
1460:    with pytest.raises(AttributeError):
1856:    with pytest.raises(AttributeError):
```

**assistant → tool `read_file`**

```json
{
  "path": "astropy/coordinates/baseframe.py",
  "offset": 1715,
  "limit": 60
}
```

**tool result**

```
        Override the builtin `dir` behavior to include representation
        names.

        TODO: dynamic representation transforms (i.e. include cylindrical et al.).
        """
        return sorted(
            set(super().__dir__())
            | set(self.representation_component_names)
            | set(self.get_representation_component_names("s"))
        )

    def __getattr__(self, attr):
        """
        Allow access to attributes on the representation and differential as
        found via ``self.get_representation_component_names``.

        TODO: We should handle dynamic representation transforms here (e.g.,
        `.cylindrical`) instead of defining properties as below.
        """

        # attr == '_representation' is likely from the hasattr() test in the
        # representation property which is used for
        # self.representation_component_names.
        #
        # Prevent infinite recursion here.
        if attr.startswith("_"):
            return self.__getattribute__(attr)  # Raise AttributeError.

        repr_names = self.representation_component_names
        if attr in repr_names:
            if self._data is None:
                self.data  # this raises the "no data" error by design - doing it
                # this way means we don't have to replicate the error message here

            rep = self.represent_as(self.representation_type, in_frame_units=True)
            val = getattr(rep, repr_names[attr])
            return val

        diff_names = self.get_representation_component_names("s")
        if attr in diff_names:
            if self._data is None:
                self.data  # see above.
            # TODO: this doesn't work for the case when there is only
            # unitspherical information. The differential_type gets set to the
            # default_differential, which expects full information, so the
            # units don't work out
            rep = self.represent_as(
                in_frame_units=True, **self.get_representation_cls(None)
            )
            val = getattr(rep.differentials["s"], diff_names[attr])
            return val

        return self.__getattribute__(attr)  # Raise AttributeError.

    def __setattr__(self, attr, value):
        # Don't slow down access of private attributes!
        if not attr.startswith("_"):
            if hasattr(self, "representation_info"):
                repr_attr_names = set()
                for representation_attr in self.representation_info.values():

[261 more lines in /testbed/astropy/coordinates/baseframe.py (2035 in all). read_file with offset: 1775 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"misleading\\|subclass.*property\\|property.*AttributeError\\|AttributeError.*property\" CHANGES.rst astropy/coordinates | head -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport inspect\nclass B:\n    @property\n    def p(self): return self.q\nprint(inspect.getattr_static(B(), 'p'))\nEOF"
}
```

**tool result**

```
CHANGES.rst:2966:- Fix misleading missing END card error when extra data are found at the end
CHANGES.rst:4817:  previous value of None was misleading as it always was an error. [#8450]
```

**tool result**

```
<property object at 0x77a46d5e59a0>
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport sys, traceback\nclass A:\n    @property\n    def prop(self):\n        return self.random_attr\n    def __getattr__(self, attr):\n        print('getattr', attr, 'exc', sys.exc_info())\n        raise AttributeError('masked %s' % attr)\ntry:\n    A().prop\nexcept Exception:\n    traceback.print_exc()\nEOF"
}
```

**tool result**

```
Traceback (most recent call last):
  File "<stdin>", line 10, in <module>
  File "<stdin>", line 8, in __getattr__
AttributeError: masked prop
getattr random_attr exc (None, None, None)
getattr prop exc (None, None, None)
```

**assistant → tool `read_file`**

```json
{
  "path": "astropy/coordinates/tests/test_sky_coord.py",
  "offset": 555,
  "limit": 45
}
```

**assistant → tool `read_file`**

```json
{
  "path": "astropy/coordinates/tests/test_sky_coord.py",
  "offset": 1445,
  "limit": 30
}
```

**tool result**

```

    sc1 = sc0.copy()
    sc1[:] = sc2[:]
    assert np.allclose(sc1.ra.to_value(u.deg), [10, 20])
    assert np.allclose(sc1.dec.to_value(u.deg), [30, 40])
    assert np.allclose(sc1.radial_velocity.to_value(u.km / u.s), [10, 20])

    sc1 = sc0.copy()
    sc1[[1, 0]] = sc2[:]
    assert np.allclose(sc1.ra.to_value(u.deg), [20, 10])
    assert np.allclose(sc1.dec.to_value(u.deg), [40, 30])
    assert np.allclose(sc1.radial_velocity.to_value(u.km / u.s), [20, 10])


def test_setitem_exceptions():
    class SkyCoordSub(SkyCoord):
        pass

    obstime = "B1955"
    sc0 = SkyCoord([1, 2] * u.deg, [3, 4] * u.deg, frame="fk4")
    sc2 = SkyCoord([10, 20] * u.deg, [30, 40] * u.deg, frame="fk4", obstime=obstime)

    sc1 = SkyCoordSub(sc0)
    with pytest.raises(
        TypeError,
        match="an only set from object of same class: SkyCoordSub vs. SkyCoord",
    ):
        sc1[0] = sc2[0]

    sc1 = SkyCoord(sc0.ra, sc0.dec, frame="fk4", obstime="B2001")
    with pytest.raises(
        ValueError, match="can only set frame item from an equivalent frame"
    ):
        sc1.frame[0] = sc2.frame[0]

    sc1 = SkyCoord(sc0.ra[0], sc0.dec[0], frame="fk4", obstime=obstime)
    with pytest.raises(
        TypeError, match="scalar 'FK4' frame object does not support item assignment"
    ):
        sc1[0] = sc2[0]

    # Different differentials
    sc1 = SkyCoord(
        [1, 2] * u.deg,
        [3, 4] * u.deg,

[1568 more lines in /testbed/astropy/coordinates/tests/test_sky_coord.py (2167 in all). read_file with offset: 600 to continue]
```

**tool result**

```
    assert c5.representation_type == c4.representation_type


def test_no_copy():
    c1 = SkyCoord(np.arange(10.0) * u.hourangle, np.arange(20.0, 30.0) * u.deg)
    c2 = SkyCoord(c1, copy=False)
    # Note: c1.ra and c2.ra will *not* share memory, as these are recalculated
    # to be in "preferred" units.  See discussion in #4883.
    assert np.may_share_memory(c1.data.lon, c2.data.lon)
    c3 = SkyCoord(c1, copy=True)
    assert not np.may_share_memory(c1.data.lon, c3.data.lon)


def test_immutable():
    c1 = SkyCoord(1 * u.deg, 2 * u.deg)
    with pytest.raises(AttributeError):
        c1.ra = 3.0

    c1.foo = 42
    assert c1.foo == 42


@pytest.mark.skipif(not HAS_SCIPY, reason="Requires scipy")
def test_search_around():
    """
    Test the search_around_* methods

    Here we don't actually test the values are right, just that the methods of
    SkyCoord work.  The accuracy tests are in ``test_matching.py``
    """

[693 more lines in /testbed/astropy/coordinates/tests/test_sky_coord.py (2167 in all). read_file with offset: 1475 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,35p' astropy/coordinates/sky_coordinate.py"
}
```

**tool result**

```
import copy
import operator
import re
import warnings

import erfa
import numpy as np

from astropy import units as u
from astropy.constants import c as speed_of_light
from astropy.table import QTable
from astropy.time import Time
from astropy.utils import ShapedLikeNDArray
from astropy.utils.data_info import MixinInfo
from astropy.utils.exceptions import AstropyUserWarning

from .angles import Angle
from .baseframe import BaseCoordinateFrame, GenericFrame, frame_transform_graph
from .distances import Distance
from .representation import (
    RadialDifferential,
    SphericalDifferential,
    SphericalRepresentation,
    UnitSphericalCosLatDifferential,
    UnitSphericalDifferential,
    UnitSphericalRepresentation,
)
from .sky_coordinate_parsers import (
    _get_frame_class,
    _get_frame_without_data,
    _parse_coordinate_data,
)

__all__ = ["SkyCoord", "SkyCoordInfo"]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/astropy/coordinates/sky_coordinate.py\n@@\n     def __getattr__(self, attr):\n         \"\"\"\n         Overrides getattr to return coordinates that this can be transformed\n         to, based on the alias attr in the primary transform graph.\n         \"\"\"\n+        # If ``attr`` is defined as a descriptor on the class, then normal\n+        # attribute lookup failed because the descriptor itself raised an\n+        # AttributeError (e.g., a property whose getter accesses a missing\n+        # attribute).  Re-run the descriptor so that the original, more\n+        # informative error propagates instead of being replaced below by a\n+        # misleading message claiming that ``attr`` does not exist.\n+        for cls in type(self).__mro__:\n+            if attr in cls.__dict__:\n+                descriptor = cls.__dict__[attr]\n+                if hasattr(descriptor, \"__get__\"):\n+                    return descriptor.__get__(self, type(self))\n+                break\n+\n         if \"_sky_coord_frame\" in self.__dict__:\n             if self._is_name(attr):\n                 return self  # Should this be a deepcopy of self?\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/astropy/coordinates/sky_coordinate.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/astropy/coordinates/sky_coordinate.py now (2236 lines), around the change:
871:        Overrides getattr to return coordinates that this can be transformed
872:        to, based on the alias attr in the primary transform graph.
873:        """
874:        # If ``attr`` is defined as a descriptor on the class, then normal
875:        # attribute lookup failed because the descriptor itself raised an
876:        # AttributeError (e.g., a property whose getter accesses a missing
877:        # attribute).  Re-run the descriptor so that the original, more
878:        # informative error propagates instead of being replaced below by a
879:        # misleading message claiming that ``attr`` does not exist.
880:        for cls in type(self).__mro__:
881:            if attr in cls.__dict__:
882:                descriptor = cls.__dict__[attr]
883:                if hasattr(descriptor, "__get__"):
884:                    return descriptor.__get__(self, type(self))
885:                break
886:
887:        if "_sky_coord_frame" in self.__dict__:
888:            if self._is_name(attr):
889:                return self  # Should this be a deepcopy of self?
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport astropy.coordinates as coord\nclass custom_coord(coord.SkyCoord):\n    @property\n    def prop(self):\n        return self.random_attr\nc=custom_coord('00h42m30s','+41d12m00s',frame='icrs')\ntry:\n    c.prop\nexcept Exception as e:\n    import traceback; traceback.print_exc()\n# normal behavior still works\nprint(c.ra, c.icrs)\ntry:\n    c.nonexistent\nexcept AttributeError as e:\n    print('OK:', e)\nEOF"
}
```

**tool result**

```
Traceback (most recent call last):
  File "<stdin>", line 8, in <module>
  File "/testbed/astropy/coordinates/sky_coordinate.py", line 884, in __getattr__
    return descriptor.__get__(self, type(self))
  File "<stdin>", line 5, in prop
  File "/testbed/astropy/coordinates/sky_coordinate.py", line 911, in __getattr__
    raise AttributeError(
AttributeError: 'custom_coord' object has no attribute 'random_attr'
10d37m30s <custom_coord (ICRS): (ra, dec) in deg
    (10.625, 41.2)>
OK: 'custom_coord' object has no attribute 'nonexistent'
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/astropy/coordinates/tests/test_sky_coord.py\n@@\n def test_immutable():\n     c1 = SkyCoord(1 * u.deg, 2 * u.deg)\n     with pytest.raises(AttributeError):\n         c1.ra = 3.0\n \n     c1.foo = 42\n     assert c1.foo == 42\n \n \n+def test_subclass_property_attribute_error():\n+    \"\"\"Errors from properties on subclasses should not be masked by __getattr__.\"\"\"\n+\n+    class CustomCoord(SkyCoord):\n+        @property\n+        def prop(self):\n+            return self.random_attr\n+\n+    c = CustomCoord(\"00h42m30s\", \"+41d12m00s\", frame=\"icrs\")\n+    with pytest.raises(AttributeError, match=\"random_attr\"):\n+        c.prop\n+\n+\n @pytest.mark.skipif(not HAS_SCIPY, reason=\"Requires scipy\")\n def test_search_around():\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/astropy/coordinates/tests/test_sky_coord.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/astropy/coordinates/tests/test_sky_coord.py now (2180 lines), around the change:
1464:    assert c1.foo == 42
1465:
1466:
1467:def test_subclass_property_attribute_error():
1468:    """Errors from properties on subclasses should not be masked by __getattr__."""
1469:
1470:    class CustomCoord(SkyCoord):
1471:        @property
1472:        def prop(self):
1473:            return self.random_attr
1474:
1475:    c = CustomCoord("00h42m30s", "+41d12m00s", frame="icrs")
1476:    with pytest.raises(AttributeError, match="random_attr"):
1477:        c.prop
1478:
1479:
1480:@pytest.mark.skipif(not HAS_SCIPY, reason="Requires scipy")
1481:def test_search_around():
1482:    """
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/coordinates/tests/test_sky_coord.py -q 2>&1 | tail -20"
}
```

**tool result**

```
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
            table = iers.LeapSeconds.auto_open(files)
            return erfa.leap_seconds.update(table)
    
        except Exception as exc:
>           warn(
                f"leap-second auto-update failed due to the following exception: {exc!r}",
                AstropyWarning,
            )
[1m[31mE           astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due to the following exception: IERSStaleWarning('leap-second file is expired.')[0m

[1m[31mastropy/time/core.py[0m:3315: AstropyWarning
[36m[1m=========================== short test summary info ============================[0m
[31mFAILED[0m astropy/coordinates/tests/test_sky_coord.py::[1mtest_repr_altaz[0m - astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due...
[31m[31m[1m1 failed[0m, [32m427 passed[0m, [33m3 skipped[0m, [33m1 xfailed[0m[31m in 7.62s[0m[0m
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/coordinates/tests/test_sky_coord.py::test_subclass_property_attribute_error astropy/coordinates/tests/test_sky_coord.py::test_immutable -q 2>&1 | tail -5"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/coordinates/tests/test_frames.py -q 2>&1 | tail -5"
}
```

**tool result**

```
<frozen importlib._bootstrap>:228: RuntimeWarning: numpy.ndarray size changed, may indicate binary incompatibility. Expected 80 from C header, got 96 from PyObject
Internet access disabled
[32m.[0m[32m.[0m[32m                                                                       [100%][0m
[32m[32m[1m2 passed[0m[32m in 0.43s[0m[0m
```

**tool result**

```

[1m[31mastropy/time/core.py[0m:3315: AstropyWarning
[36m[1m=========================== short test summary info ============================[0m
[31mFAILED[0m astropy/coordinates/tests/test_frames.py::[1mtest_no_data_nonscalar_frames[0m - astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due...
[31m[31m[1m1 failed[0m, [32m55 passed[0m[31m in 2.09s[0m[0m
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nfrom astropy.coordinates import SkyCoord\nclass A(SkyCoord):\n    @property\n    def prop(self):\n        return self.missing\nclass B(A):\n    pass\nb=B('00h42m30s','+41d12m00s',frame='icrs')\ntry:\n    b.prop\nexcept AttributeError as e:\n    print(e)\n# descriptor that raises AttributeError deliberately\nclass C(SkyCoord):\n    @property\n    def weird(self):\n        raise AttributeError('custom message')\ntry:\n    C('00h42m30s','+41d12m00s',frame='icrs').weird\nexcept AttributeError as e:\n    print(e)\nEOF"
}
```

**tool result**

```
'B' object has no attribute 'missing'
custom message
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"coordinates\" CHANGES.rst | head -10; sed -n '1,60p' CHANGES.rst"
}
```

**tool result**

```
13:  should be used to specify the data coordinates of the tick label being added.
16:  calculate pixel coordinates before Matplotlib is drawing a figure. [#12630]
22:astropy.coordinates
176:astropy.coordinates
179:- The ephemeris used in ``astropy.coordinates`` can now be set to any version of
404:astropy.coordinates
518:astropy.coordinates
734:astropy.coordinates
737:- Trying to create an instance of ``astropy.coordinates.Distance`` by providing
743:- ``astropy.coordinates.Distance`` constructor no longer ignores the ``unit``
Version 5.1.1 (2022-10-23)
==========================

API Changes
-----------

astropy.wcs
^^^^^^^^^^^

- The ``pixel`` argument to ``astropy.visualization.wcsaxes.ticklabels.TickLabels.add``
  no longer does anything, is deprecated, and will be removed in a future
  astropy version. It has been replaced by a new required ``data`` argument, which
  should be used to specify the data coordinates of the tick label being added.

  This changes has been made because it is (in general) not possible to correctly
  calculate pixel coordinates before Matplotlib is drawing a figure. [#12630]


Bug Fixes
---------

astropy.coordinates
^^^^^^^^^^^^^^^^^^^

- Fixed a bug that prevented ``SkyOffsetFrame`` instances to be pickled by adding
  a custom ``__reduce__`` method to the class (see issue #9249). [#13305]

- Fixed the check for invalid ``Latitude`` values for float32 values.
  ``Latitude`` now accepts the float32 value of pi/2, which was rejected
  before because a comparison was made using the slightly smaller float64 representation.
  See issue #13708. [#13745]

astropy.io.ascii
^^^^^^^^^^^^^^^^

- Fixed confusing chained exception messages of ``read()`` function when it fails. [#13170]

- When writing out a :class:`~astropy.table.Table` to HTML format, the
  ``formats`` keyword argument to the :meth:`~astropy.table.Table.write` method
  will now be applied. [#13453]

astropy.io.fits
^^^^^^^^^^^^^^^

- ``heapsize`` is now checked for VLA tables. An error is thrown whether P format is used
  but the heap size is bigger than what can be indexed with a 32 bit signed int. [#13429]

- Fix parsing of ascii TFORM when precision is missing. [#13520]

- A compressed image HDU created from the header of a PRIMARY HDU, now correctly updates
  'XTENSION' and 'SIMPLE' keywords. [#13557]

- Empty variable-length arrays are now properly handled when pathological combinations of
  heapoffset and heapsize are encountered. [#13621]

- ``PCOUNT`` and ``GCOUNT`` keywords are now removed from an uncompressed Primary header,
  for compliancy with ``fitsverify`` behavior. [#13753]

astropy.modeling
^^^^^^^^^^^^^^^^
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/CHANGES.rst",
  "offset": 20,
  "limit": 30
}
```

**tool result**

```
---------

astropy.coordinates
^^^^^^^^^^^^^^^^^^^

- Fixed a bug that prevented ``SkyOffsetFrame`` instances to be pickled by adding
  a custom ``__reduce__`` method to the class (see issue #9249). [#13305]

- Fixed the check for invalid ``Latitude`` values for float32 values.
  ``Latitude`` now accepts the float32 value of pi/2, which was rejected
  before because a comparison was made using the slightly smaller float64 representation.
  See issue #13708. [#13745]

astropy.io.ascii
^^^^^^^^^^^^^^^^

- Fixed confusing chained exception messages of ``read()`` function when it fails. [#13170]

- When writing out a :class:`~astropy.table.Table` to HTML format, the
  ``formats`` keyword argument to the :meth:`~astropy.table.Table.write` method
  will now be applied. [#13453]

astropy.io.fits
^^^^^^^^^^^^^^^

- ``heapsize`` is now checked for VLA tables. An error is thrown whether P format is used
  but the heap size is bigger than what can be indexed with a 32 bit signed int. [#13429]

- Fix parsing of ascii TFORM when precision is missing. [#13520]


[15114 more lines in /testbed/CHANGES.rst (15163 in all). read_file with offset: 50 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/CHANGES.rst",
  "limit": 20
}
```

**tool result**

```
Version 5.1.1 (2022-10-23)
==========================

API Changes
-----------

astropy.wcs
^^^^^^^^^^^

- The ``pixel`` argument to ``astropy.visualization.wcsaxes.ticklabels.TickLabels.add``
  no longer does anything, is deprecated, and will be removed in a future
  astropy version. It has been replaced by a new required ``data`` argument, which
  should be used to specify the data coordinates of the tick label being added.

  This changes has been made because it is (in general) not possible to correctly
  calculate pixel coordinates before Matplotlib is drawing a figure. [#12630]


Bug Fixes
---------

[15143 more lines in /testbed/CHANGES.rst (15163 in all). read_file with offset: 21 to continue]
```

**assistant**

````
Implemented the fix.

### Change
In `astropy/coordinates/sky_coordinate.py`, `SkyCoord.__getattr__` now checks whether the missing attribute is actually a descriptor (such as a `property`) defined on the class. If so, it re-invokes the descriptor so the original `AttributeError` from inside the property propagates, instead of replacing it with the misleading `'<class>' object has no attribute '<property>'` message.

### Result
The example now raises:

```text
AttributeError: 'custom_coord' object has no attribute 'random_attr'
```

### Test
Added `test_subclass_property_attribute_error` in `astropy/coordinates/tests/test_sky_coord.py`.

Verification:
- New test passes.
- `test_sky_coord.py`: 427 passed, 3 skipped, 1 xfailed; the only failure is an unrelated expired leap-second/IERS warning.
- `test_frames.py`: 55 passed; one unrelated IERS warning failure.
````

## Run folder `team-solve-2026-11-06T171621`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
06c74e6aeed73a852c2b5e00151240fc2556e8d3
```

### `baseline-check.log`

```
check: python -m pytest astropy/coordinates/tests/test_sky_coord.py -q
<frozen importlib._bootstrap>:228: RuntimeWarning: numpy.ndarray size changed, may indicate binary incompatibility. Expected 80 from C header, got 96 from PyObject
Internet access disabled
[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 16%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 33%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 50%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31mF[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 66%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 83%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33mx[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[31m  [100%][0m
=================================== FAILURES ===================================
[31m[1m_______________________________ test_repr_altaz ________________________________[0m

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
>           table = iers.LeapSeconds.auto_open(files)

[1m[31mastropy/time/core.py[0m:3311: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

cls = <class 'astropy.utils.iers.iers.LeapSeconds'>
files = ['erfa', '/testbed/.memdoor/runs/team-solve-2026-11-06T171621/baseline-tree/astropy/utils/iers/data/Leap_Second.dat', 'https://hpiers.obspm.fr/iers/bul/bulc/Leap_Second.dat', 'https://www.ietf.org/timezones/data/leap-seconds.list']

    @classmethod
    def auto_open(cls, files=None):
        """Attempt to get an up-to-date leap-second list.
    
        The routine will try the files in sequence until it finds one
        whose expiration date is "good enough" (see below).  If none
        are good enough, it returns the one with the most recent expiration
        date, warning if that file is expired.
    
        For remote files that are cached already, the cached file is tried
        first before attempting to retrieve it again.
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses
            ``cls._auto_open_files``.
    
        Returns
        -------
        leap_seconds : `~astropy.utils.iers.LeapSeconds`
            Up to date leap-second table
    
        Notes
        -----
        Bulletin C is released about 10 days after a possible leap second is
        introduced, i.e., mid-January or mid-July.  Expiration days are thus
        generally at least 150 days after the present.  We look for a file
        that expires more than 180 - `~astropy.utils.iers.Conf.auto_max_age`
        after the present.
        """
        offset = 180 - (30 if conf.auto_max_age is None else conf.auto_max_age)
        good_enough = cls._today() + TimeDelta(offset, format="jd")
    
        if files is None:
            # Basic files to go over (entries in _auto_open_files can be
            # configuration items, which we want to be sure are up to date).
            files = [getattr(conf, f, f) for f in cls._auto_open_files]
    
        # Remove empty entries.
        files = [f for f in files if f]
    
        # Our trials start with normal files and remote ones that are
        # already in cache.  The bools here indicate that the cache
        # should be used.
        trials = [
            (f, True) for f in files if not urlparse(f).netloc or is_url_in_cache(f)
        ]
        # If we are allowed to download, we try downloading new versions
        # if none of the above worked.
        if conf.auto_download:
            trials += [(f, False) for f in files if urlparse(f).netloc]
    
        self = None
        err_list = []
        # Go through all entries, and return the first one that
        # is not expired, or the most up to date one.
        for f, allow_cache in trials:
            if not allow_cache:
                clear_download_cache(f)
    
            try:
                trial = cls.open(f, cache=True)
            except Exception as exc:
                err_list.append(exc)
                continue
    
            if self is None or trial.expires > self.expires:
                self = trial
                self.meta["data_url"] = str(f)
                if self.expires > good_enough:
                    break
    
        if self is None:
            raise ValueError(
                "none of the files could be read. The "
                f"following errors were raised:\n {err_list}"
            )
    
        if self.expires < self._today() and conf.auto_max_age is not None:
>           warn("leap-second file is expired.", IERSStaleWarning)
[1m[31mE           astropy.utils.iers.iers.IERSStaleWarning: leap-second file is expired.[0m

[1m[31mastropy/utils/iers/iers.py[0m:1142: IERSStaleWarning

[33mDuring handling of the above exception, another exception occurred:[0m

    def test_repr_altaz():
        sc2 = SkyCoord(1 * u.deg, 1 * u.deg, frame="icrs", distance=1 * u.kpc)
        loc = EarthLocation(-2309223 * u.m, -3695529 * u.m, -4641767 * u.m)
        time = Time("2005-03-21 00:00:00")
>       sc4 = sc2.transform_to(AltAz(location=loc, obstime=time))

[1m[31mastropy/coordinates/tests/test_sky_coord.py[0m:783: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
[1m[31mastropy/coordinates/sky_coordinate.py[0m:704: in transform_to
    new_coord = trans(self.frame, generic_frame)
[1m[31mastropy/coordinates/transformations.py[0m:1575: in __call__
    curr_coord = t(curr_coord, curr_toframe)
[1m[31mastropy/coordinates/transformations.py[0m:1144: in __call__
    return supcall(fromcoord, toframe)
[1m[31mastropy/coordinates/builtin_frames/icrs_observed_transforms.py[0m:33: in icrs_to_observed
    astrom = erfa_astrom.get().apco(observed_frame)
[1m[31mastropy/coordinates/erfa_astrom.py[0m:52: in apco
    jd1_tt, jd2_tt = get_jd12(obstime, "tt")
[1m[31mastropy/coordinates/builtin_frames/utils.py[0m:115: in get_jd12
    newtime = getattr(time, scale)
[1m[31mastropy/time/core.py[0m:1635: in __getattr__
    tm._set_scale(attr)
[1m[31mastropy/time/core.py[0m:742: in _set_scale
    _check_leapsec()
[1m[31mastropy/time/core.py[0m:3282: in _check_leapsec
    update_leap_seconds()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
            table = iers.LeapSeconds.auto_open(files)
            return erfa.leap_seconds.update(table)
    
        except Exception as exc:
>           warn(
                f"leap-second auto-update failed due to the following exception: {exc!r}",
                AstropyWarning,
            )
[1m[31mE           astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due to the following exception: IERSStaleWarning('leap-second file is expired.')[0m

[1m[31mastropy/time/core.py[0m:3315: AstropyWarning
[36m[1m=========================== short test summary info ============================[0m
[31mFAILED[0m astropy/coordinates/tests/test_sky_coord.py::[1mtest_repr_altaz[0m - astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due...
[31m[31m[1m1 failed[0m, [32m426 passed[0m, [33m3 skipped[0m, [33m1 xfailed[0m[31m in 7.21s[0m[0m
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/astropy/coordinates/sky_coordinate.py b/astropy/coordinates/sky_coordinate.py
index ab475f7d0..ec6250c79 100644
--- a/astropy/coordinates/sky_coordinate.py
+++ b/astropy/coordinates/sky_coordinate.py
@@ -871,6 +871,19 @@ class SkyCoord(ShapedLikeNDArray):
         Overrides getattr to return coordinates that this can be transformed
         to, based on the alias attr in the primary transform graph.
         """
+        # If ``attr`` is defined as a descriptor on the class, then normal
+        # attribute lookup failed because the descriptor itself raised an
+        # AttributeError (e.g., a property whose getter accesses a missing
+        # attribute).  Re-run the descriptor so that the original, more
+        # informative error propagates instead of being replaced below by a
+        # misleading message claiming that ``attr`` does not exist.
+        for cls in type(self).__mro__:
+            if attr in cls.__dict__:
+                descriptor = cls.__dict__[attr]
+                if hasattr(descriptor, "__get__"):
+                    return descriptor.__get__(self, type(self))
+                break
+
         if "_sky_coord_frame" in self.__dict__:
             if self._is_name(attr):
                 return self  # Should this be a deepcopy of self?
diff --git a/astropy/coordinates/tests/test_sky_coord.py b/astropy/coordinates/tests/test_sky_coord.py
index 4dcfba0d4..e41f9f03c 100644
--- a/astropy/coordinates/tests/test_sky_coord.py
+++ b/astropy/coordinates/tests/test_sky_coord.py
@@ -1464,6 +1464,19 @@ def test_immutable():
     assert c1.foo == 42
 
 
+def test_subclass_property_attribute_error():
+    """Errors from properties on subclasses should not be masked by __getattr__."""
+
+    class CustomCoord(SkyCoord):
+        @property
+        def prop(self):
+            return self.random_attr
+
+    c = CustomCoord("00h42m30s", "+41d12m00s", frame="icrs")
+    with pytest.raises(AttributeError, match="random_attr"):
+        c.prop
+
+
 @pytest.mark.skipif(not HAS_SCIPY, reason="Requires scipy")
 def test_search_around():
     """
```

### `check-kind.txt`

```
judge
```

### `context.md`

````
# task.md

# Task

## Prompt

Subclassed SkyCoord gives misleading attribute access message
I'm trying to subclass `SkyCoord`, and add some custom properties. This all seems to be working fine, but when I have a custom property (`prop` below) that tries to access a non-existent attribute (`random_attr`) below, the error message is misleading because it says `prop` doesn't exist, where it should say `random_attr` doesn't exist.

```python
import astropy.coordinates as coord


class custom_coord(coord.SkyCoord):
    @property
    def prop(self):
        return self.random_attr


c = custom_coord('00h42m30s', '+41d12m00s', frame='icrs')
c.prop
```

raises
```
Traceback (most recent call last):
  File "test.py", line 11, in <module>
    c.prop
  File "/Users/dstansby/miniconda3/lib/python3.7/site-packages/astropy/coordinates/sky_coordinate.py", line 600, in __getattr__
    .format(self.__class__.__name__, attr))
AttributeError: 'custom_coord' object has no attribute 'prop'
```

## Deliverable

changes to this tree

## Check

`python -m pytest astropy/coordinates/tests/test_sky_coord.py -q`

## Scope

`astropy/coordinates/sky_coordinate.py`
`astropy/coordinates/tests/`

## Done when

- A `SkyCoord` subclass property whose getter accesses a nonexistent attribute raises `AttributeError` naming the missing inner attribute (`random_attr`), not the property (`prop`).
- The inner exception's message is preserved through the subclass property access path.
- Accessing a genuinely nonexistent attribute on a `SkyCoord` still raises the existing `AttributeError` naming that requested attribute.
- Existing frame/representation attribute fallback in `__getattr__` continues to work.
- The coordinates tests covering `SkyCoord` attribute access pass.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest astropy/coordinates/tests/test_sky_coord.py -q`

## Scope
`astropy/coordinates/sky_coordinate.py`
`astropy/coordinates/tests/`

## Done when
- A `SkyCoord` subclass property whose getter accesses a nonexistent attribute raises `AttributeError` naming the missing inner attribute (`random_attr`), not the property (`prop`).
- The inner exception's message is preserved through the subclass property access path.
- Accessing a genuinely nonexistent attribute on a `SkyCoord` still raises the existing `AttributeError` naming that requested attribute.
- Existing frame/representation attribute fallback in `__getattr__` continues to work.
- The coordinates tests covering `SkyCoord` attribute access pass.

## Approach
Reproduce the failure first, then fix `SkyCoord.__getattr__` so it distinguishes “attribute genuinely absent” from “attribute exists on the class but its descriptor raised `AttributeError`.” The key constraint is that the original exception is cleared before `__getattr__` is called, so it must be regenerated by re-invoking the descriptor, not by a bare `raise` or `sys.exc_info()`.

Candidate approaches:
- In `__getattr__`, before raising the misleading message, test whether `attr` exists on the class (e.g. `attr in dir(type(self))` or `hasattr(type(self), attr)`) and, if so, return `object.__getattribute__(self, attr)`. This re-runs the property getter and lets the inner `AttributeError` propagate. Tradeoff: class-level `hasattr` may invoke custom descriptors unless `inspect.getattr_static` is used.
- Use `inspect.getattr_static(type(self), attr, None)` to detect a descriptor without invoking it, then delegate to `object.__getattribute__`. Safer for exotic descriptors; slightly more code.
- Narrow the check to members of `type(self).__mro__` dictionaries rather than `dir(self)`, avoiding frame/representation dynamic names that are not ordinary class attributes.

Avoid calling `getattr(self, attr)` inside `__getattr__` (infinite recursion). After the fix, add a focused regression test under `astropy/coordinates/tests/` and run the scoped test command above.


# astropy/coordinates/sky_coordinate.py

```
import copy
import operator
import re
import warnings

import erfa
import numpy as np

from astropy import units as u
from astropy.constants import c as speed_of_light
from astropy.table import QTable
from astropy.time import Time
from astropy.utils import ShapedLikeNDArray
from astropy.utils.data_info import MixinInfo
from astropy.utils.exceptions import AstropyUserWarning

from .angles import Angle
from .baseframe import BaseCoordinateFrame, GenericFrame, frame_transform_graph
from .distances import Distance
from .representation import (
    RadialDifferential,
    SphericalDifferential,
    SphericalRepresentation,
    UnitSphericalCosLatDifferential,
    UnitSphericalDifferential,
    UnitSphericalRepresentation,
)
from .sky_coordinate_parsers import (
    _get_frame_class,
    _get_frame_without_data,
    _parse_coordinate_data,
)

__all__ = ["SkyCoord", "SkyCoordInfo"]


class SkyCoordInfo(MixinInfo):
    """
    Container for meta information like name, description, format.  This is
    required when the object is used as a mixin column within a table, but can
    be used as a general way to store meta information.
    """

    attrs_from_parent = {"unit"}  # Unit is read-only
    _supports_indexing = False

    @staticmethod
    def default_format(val):
        repr_data = val.info._repr_data
        formats = ["{0." + compname + ".value:}" for compname in repr_data.components]
        return ",".join(formats).format(repr_data)

    @property
    def unit(self):
        repr_data = self._repr_data
        unit = ",".join(
            str(getattr(repr_data, comp).unit) or "None"
            for comp in repr_data.components
        )
        return unit

    @property
    def _repr_data(self):
        if self._parent is None:
            return None

        sc = self._parent
        if issubclass(sc.representation_type, SphericalRepresentation) and isinstance(
            sc.data, UnitSphericalRepresentation
        ):
            repr_data = sc.represent_as(sc.data.__class__, in_frame_units=True)
        else:
            repr_data = sc.represent_as(sc.representation_type, in_frame_units=True)
        return repr_data

    def _represent_as_dict(self):
        sc = self._parent
        attrs = list(sc.representation_component_names)

        # Don't output distance unless it's actually distance.
        if isinstance(sc.data, UnitSphericalRepresentation):
            attrs = attrs[:-1]

        diff = sc.data.differentials.get("s")
        if diff is not None:
            diff_attrs = list(sc.get_representation_component_names("s"))
            # Don't output proper motions if they haven't been specified.
            if isinstance(diff, RadialDifferential):
                diff_attrs = diff_attrs[2:]
            # Don't output radial velocity unless it's actually velocity.
            elif isinstance(
                diff, (UnitSphericalDifferential, UnitSphericalCosLatDifferential)
            ):
                diff_attrs = diff_attrs[:-1]
            attrs.extend(diff_attrs)

        attrs.extend(frame_transform_graph.frame_attributes.keys())

        out = super()._represent_as_dict(attrs)

        out["representation_type"] = sc.representation_type.get_name()
        out["frame"] = sc.frame.name
        # Note that sc.info.unit is a fake composite unit (e.g. 'deg,deg,None'
        # or None,None,m) and is not stored.  The individual attributes have
        # units.

        return out

    def new_like(self, skycoords, length, metadata_conflicts="warn", name=None):
        """
        Return a new SkyCoord instance which is consistent with the input
        SkyCoord objects ``skycoords`` and has ``length`` rows.  Being
        "consistent" is defined as being able to set an item from one to each of
        the rest without any exception being raised.

        This is intended for creating a new SkyCoord instance whose elements can
        be set in-place for table operations like join or vstack.  This is used
        when a SkyCoord object is used as a mixin column in an astropy Table.

        The data values are not predictable and it is expected that the consumer
        of the object will fill in all values.

        Parameters
        ----------
        skycoords : list
            List of input SkyCoord objects
        length : int
            Length of the output skycoord object
        metadata_conflicts : str ('warn'|'error'|'silent')
            How to handle metadata conflicts
        name : str
            Output name (sets output skycoord.info.name)

        Returns
        -------
        skycoord : SkyCoord (or subclass)
            Instance of this class consistent with ``skycoords``

        """
        # Get merged info attributes like shape, dtype, format, description, etc.
        attrs = self.merge_cols_attributes(
            skycoords, metadata_conflicts, name, ("meta", "description")
        )
        skycoord0 = skycoords[0]

        # Make a new SkyCoord object with the desired length and attributes
        # by using the _apply / __getitem__ machinery to effectively return
        # skycoord0[[0, 0, ..., 0, 0]]. This will have the all the right frame
        # attributes with the right shape.
        indexes = np.zeros(length, dtype=np.int64)
        out = skycoord0[indexes]

        # Use __setitem__ machinery to check for consistency of all skycoords
        for skycoord in skycoords[1:]:
            try:
                out[0] = skycoord[0]
            except Exception as err:
                raise ValueError("Input skycoords are inconsistent.") from err

        # Set (merged) info attributes
        for attr in ("name", "meta", "description"):
            if attr in attrs:
                setattr(out.info, attr, attrs[attr])

        return out


class SkyCoord(ShapedLikeNDArray):
    """High-level object providing a flexible interface for celestial coordinate
    representation, manipulation, and transformation between systems.

    The `SkyCoord` class accepts a wide variety of inputs for initialization. At
    a minimum these must provide one or more celestial coordinate values with
    unambiguous units.  Inputs may be scalars or lists/tuples/arrays, yielding
    scalar or array coordinates (can be checked via ``SkyCoord.isscalar``).
    Typically one also specifies the coordinate frame, though this is not
    required. The general pattern for spherical representations is::

      SkyCoord(COORD, [FRAME], keyword_args ...)
      SkyCoord(LON, LAT, [FRAME], keyword_args ...)
      SkyCoord(LON, LAT, [DISTANCE], frame=FRAME, unit=UNIT, keyword_args ...)
      SkyCoord([FRAME], <lon_attr>=LON, <lat_attr>=LAT, keyword_args ...)

    It is also possible to input coordinate values in other representations
    such as cartesian or cylindrical.  In this case one includes the keyword
    argument ``representation_type='cartesian'`` (for example) along with data
    in ``x``, ``y``, and ``z``.

    See also: https://docs.astropy.org/en/stable/coordinates/

    Examples
    --------
    The examples below illustrate common ways of initializing a `SkyCoord`
    object.  For a complete description of the allowed syntax see the
    full coordinates documentation.  First some imports::

      >>> from astropy.coordinates import SkyCoord  # High-level coordinates
      >>> from astropy.coordinates import ICRS, Galactic, FK4, FK5  # Low-level frames
      >>> from astropy.coordinates import Angle, Latitude, Longitude  # Angles
      >>> import astropy.units as u

    The coordinate values and frame specification can now be provided using
    positional and keyword arguments::

      >>> c = SkyCoord(10, 20, unit="deg")  # defaults to ICRS frame
      >>> c = SkyCoord([1, 2, 3], [-30, 45, 8], frame="icrs", unit="deg")  # 3 coords

      >>> coords = ["1:12:43.2 +31:12:43", "1 12 43.2 +31 12 43"]
      >>> c = SkyCoord(coords, frame=FK4, unit=(u.hourangle, u.deg), obstime="J1992.21")

      >>> c = SkyCoord("1h12m43.2s +1d12m43s", frame=Galactic)  # Units from string
      >>> c = SkyCoord(frame="galactic", l="1h12m43.2s", b="+1d12m43s")

      >>> ra = Longitude([1, 2, 3], unit=u.deg)  # Could also use Angle
      >>> dec = np.array([4.5, 5.2, 6.3]) * u.deg  # Astropy Quantity
      >>> c = SkyCoord(ra, dec, frame='icrs')
      >>> c = SkyCoord(frame=ICRS, ra=ra, dec=dec, obstime='2001-01-02T12:34:56')

      >>> c = FK4(1 * u.deg, 2 * u.deg)  # Uses defaults for obstime, equinox
      >>> c = SkyCoord(c, obstime='J2010.11', equinox='B1965')  # Override defaults

      >>> c = SkyCoord(w=0, u=1, v=2, unit='kpc', frame='galactic',
      ...              representation_type='cartesian')

      >>> c = SkyCoord([ICRS(ra=1*u.deg, dec=2*u.deg), ICRS(ra=3*u.deg, dec=4*u.deg)])

    Velocity components (proper motions or radial velocities) can also be
    provided in a similar manner::

      >>> c = SkyCoord(ra=1*u.deg, dec=2*u.deg, radial_velocity=10*u.km/u.s)

      >>> c = SkyCoord(ra=1*u.deg, dec=2*u.deg, pm_ra_cosdec=2*u.mas/u.yr, pm_dec=1*u.mas/u.yr)

    As shown, the frame can be a `~astropy.coordinates.BaseCoordinateFrame`
    class or the corresponding string alias.  The frame classes that are built in
    to astropy are `ICRS`, `FK5`, `FK4`, `FK4NoETerms`, and `Galactic`.
    The string aliases are simply lower-case versions of the class name, and
    allow for creating a `SkyCoord` object and transforming frames without
    explicitly importing the frame classes.

    Parameters
    ----------
    frame : `~astropy.coordinates.BaseCoordinateFrame` class or string, optional
        Type of coordinate frame this `SkyCoord` should represent. Defaults to
        to ICRS if not given or given as None.
    unit : `~astropy.units.Unit`, string, or tuple of :class:`~astropy.units.Unit` or str, optional
        Units for supplied coordinate values.
        If only one unit is supplied then it applies to all values.
        Note that passing only one unit might lead to unit conversion errors
        if the coordinate values are expected to have mixed physical meanings
        (e.g., angles and distances).
    obstime : time-like, optional
        Time(s) of observation.
    equinox : time-like, optional
        Coordinate frame equinox time.
    representation_type : str or Representation class
        Specifies the representation, e.g. 'spherical', 'cartesian', or
        'cylindrical'.  This affects the positional args and other keyword args
        which must correspond to the given representation.
    copy : bool, optional
        If `True` (default), a copy of any coordinate data is made.  This
        argument can only be passed in as a keyword argument.
    **keyword_args
        Other keyword arguments as applicable for user-defined coordinate frames.
        Common options include:

        ra, dec : angle-like, optional
            RA and Dec for frames where ``ra`` and ``dec`` are keys in the
            frame's ``representation_component_names``, including `ICRS`,
            `FK5`, `FK4`, and `FK4NoETerms`.
        pm_ra_cosdec, pm_dec  : `~astropy.units.Quantity` ['angular speed'], optional
            Proper motion components, in angle per time units.
        l, b : angle-like, optional
            Galactic ``l`` and ``b`` for for frames where ``l`` and ``b`` are
            keys in the frame's ``representation_component_names``, including
            the `Galactic` frame.
        pm_l_cosb, pm_b : `~astropy.units.Quantity` ['angular speed'], optional
            Proper motion components in the `Galactic` frame, in angle per time
            units.
        x, y, z : float or `~astropy.units.Quantity` ['length'], optional
            Cartesian coordinates values
        u, v, w : float or `~astropy.units.Quantity` ['length'], optional
            Cartesian coordinates values for the Galactic frame.
        radial_velocity : `~astropy.units.Quantity` ['speed'], optional
            The component of the velocity along the line-of-sight (i.e., the
            radial direction), in velocity units.
    """

    # Declare that SkyCoord can be used as a Table column by defining the
    # info property.
    info = SkyCoordInfo()

    def __init__(self, *args, copy=True, **kwargs):
        # these are frame attributes set on this SkyCoord but *not* a part of
        # the frame object this SkyCoord contains
        self._extra_frameattr_names = set()

        # If all that is passed in is a frame instance that already has data,
        # we should bypass all of the parsing and logic below. This is here
        # to make this the fastest way to create a SkyCoord instance. Many of
        # the classmethods implemented for performance enhancements will use
        # this as the initialization path
        if (
            len(args) == 1
            and len(kwargs) == 0
            and isinstance(args[0], (BaseCoordinateFrame, SkyCoord))
        ):
            coords = args[0]
            if isinstance(coords, SkyCoord):
                self._extra_frameattr_names = coords._extra_frameattr_names
                self.info = coords.info

                # Copy over any extra frame attributes
                for attr_name in self._extra_frameattr_names:
                    # Setting it will also validate it.
                    setattr(self, attr_name, getattr(coords, attr_name))

                coords = coords.frame

            if not coords.has_data:
                raise ValueError(
                    "Cannot initialize from a coordinate frame "
                    "instance without coordinate data"
                )

            if copy:
                self._sky_coord_frame = coords.copy()
            else:
                self._sky_coord_frame = coords

        else:
            # Get the frame instance without coordinate data but with all frame
            # attributes set - these could either have been passed in with the
            # frame as an instance, or passed in as kwargs here
            frame_cls, frame_kwargs = _get_frame_without_data(args, kwargs)

            # Parse the args and kwargs to assemble a sanitized and validated
            # kwargs dict for initializing attributes for this object and for
            # creating the internal self._sky_coord_frame object
            args = list(args)  # Make it mutable
            skycoord_kwargs, components, info = _parse_coordinate_data(
                frame_cls(**frame_kwargs), args, kwargs
            )

            # In the above two parsing functions, these kwargs were identified
            # as valid frame attributes for *some* frame, but not the frame that
            # this SkyCoord will have. We keep these attributes as special
            # skycoord frame attributes:
            for attr in skycoord_kwargs:
                # Setting it will also validate it.
                setattr(self, attr, skycoord_kwargs[attr])

            if info is not None:
                self.info = info

            # Finally make the internal coordinate object.
            frame_kwargs.update(components)
            self._sky_coord_frame = frame_cls(copy=copy, **frame_kwargs)

            if not self._sky_coord_frame.has_data:
                raise ValueError("Cannot create a SkyCoord without data")

    @property
    def frame(self):
        return self._sky_coord_frame

    @property
    def representation_type(self):
        return self.frame.representation_type

    @representation_type.setter
    def representation_type(self, value):
        self.frame.representation_type = value

    # TODO: remove these in future
    @property
    def representation(self):
        return self.frame.representation

    @representation.setter
    def representation(self, value):
        self.frame.representation = value

    @property
    def shape(self):
        return self.frame.shape

    def __eq__(self, value):
        """Equality operator for SkyCoord

        This implements strict equality and requires that the frames are
        equivalent, extra frame attributes are equivalent, and that the
        representation data are exactly equal.
        """

        if isinstance(value, BaseCoordinateFrame):
            if value._data is None:
                raise ValueError("Can only compare SkyCoord to Frame with data")

            return self.frame == value

        if not isinstance(value, SkyCoord):
            return NotImplemented

        # Make sure that any extra frame attribute names are equivalent.
        for attr in self._extra_frameattr_names | value._extra_frameattr_names:
            if not self.frame._frameattr_equiv(
                getattr(self, attr), getattr(value, attr)
            ):
                raise ValueError(
                    f"cannot compare: extra frame attribute '{attr}' is not equivalent"
                    " (perhaps compare the frames directly to avoid this exception)"
                )

        return self._sky_coord_frame == value._sky_coord_frame

    def __ne__(self, value):
        return np.logical_not(self == value)

    def _apply(self, method, *args, **kwargs):
        """Create a new instance, applying a method to the underlying data.

        In typical usage, the method is any of the shape-changing methods for
        `~numpy.ndarray` (``reshape``, ``swapaxes``, etc.), as well as those
        picking particular elements (``__getitem__``, ``take``, etc.), which
        are all defined in `~astropy.utils.shapes.ShapedLikeNDArray`. It will be
        applied to the underlying arrays in the representation (e.g., ``x``,
        ``y``, and ``z`` for `~astropy.coordinates.CartesianRepresentation`),
        as well as to any frame attributes that have a shape, with the results
        used to create a new instance.

        Internally, it is also used to apply functions to the above parts
        (in particular, `~numpy.broadcast_to`).

        Parameters
        ----------
        method : str or callable
            If str, it is the name of a method that is applied to the internal
            ``components``. If callable, the function is applied.
        *args
            Any positional arguments for ``method``.
        **kwargs : dict
            Any keyword arguments for ``method``.
        """

        def apply_method(value):
            if isinstance(value, ShapedLikeNDArray):
                return value._apply(method, *args, **kwargs)
            else:
                if callable(method):
                    return method(value, *args, **kwargs)
                else:
                    return getattr(value, method)(*args, **kwargs)

        # create a new but empty instance, and copy over stuff
        new = super().__new__(self.__class__)
        new._sky_coord_frame = self._sky_coord_frame._apply(method, *args, **kwargs)
        new._extra_frameattr_names = self._extra_frameattr_names.copy()
        for attr in self._extra_frameattr_names:
            value = getattr(self, attr)
            if getattr(value, "shape", ()):
                value = apply_method(value)
            elif method == "copy" or method == "flatten":
                # flatten should copy also for a single element array, but
                # we cannot use it directly for array scalars, since it
                # always returns a one-dimensional array. So, just copy.
                value = copy.copy(value)
            setattr(new, "_" + attr, value)

        # Copy other 'info' attr only if it has actually been defined.
        # See PR #3898 for further explanation and justification, along
        # with Quantity.__array_finalize__
        if "info" in self.__dict__:
            new.info = self.info

        return new

    def __setitem__(self, item, value):
        """Implement self[item] = value for SkyCoord

        The right hand ``value`` must be strictly consistent with self:
        - Identical class
        - Equivalent frames
        - Identical representation_types
        - Identical representation differentials keys
        - Identical frame attributes
        - Identical "extra" frame attributes (e.g. obstime for an ICRS coord)

        With these caveats the setitem ends up as effectively a setitem on
        the representation data.

          self.frame.data[item] = value.frame.data
        """
        if self.__class__ is not value.__class__:
            raise TypeError(
                "can only set from object of same class: "
                f"{self.__class__.__name__} vs. {value.__class__.__name__}"
            )

        # Make sure that any extra frame attribute names are equivalent.
        for attr in self._extra_frameattr_names | value._extra_frameattr_names:
            if not self.frame._frameattr_equiv(
                getattr(self, attr), getattr(value, attr)
            ):
                raise ValueError(f"attribute {attr} is not equivalent")

        # Set the frame values.  This checks frame equivalence and also clears
        # the cache to ensure that the object is not in an inconsistent state.
        self._sky_coord_frame[item] = value._sky_coord_frame

    def insert(self, obj, values, axis=0):
        """
        Insert coordinate values before the given indices in the object and
        return a new Frame object.

        The values to be inserted must conform to the rules for in-place setting
        of ``SkyCoord`` objects.

        The API signature matches the ``np.insert`` API, but is more limited.
        The specification of insert index ``obj`` must be a single integer,
        and the ``axis`` must be ``0`` for simple insertion before the index.

        Parameters
        ----------
        obj : int
            Integer index before which ``values`` is inserted.
        values : array-like
            Value(s) to insert.  If the type of ``values`` is different
            from that of quantity, ``values`` is converted to the matching type.
        axis : int, optional
            Axis along which to insert ``values``.  Default is 0, which is the
            only allowed value and will insert a row.

        Returns
        -------
        out : `~astropy.coordinates.SkyCoord` instance
            New coordinate object with inserted value(s)

        """
        # Validate inputs: obj arg is integer, axis=0, self is not a scalar, and
        # input index is in bounds.
        try:
            idx0 = operator.index(obj)
        except TypeError:
            raise TypeError("obj arg must be an integer")

        if axis != 0:
            raise ValueError("axis must be 0")

        if not self.shape:
            raise TypeError(
                f"cannot insert into scalar {self.__class__.__name__} object"
            )

        if abs(idx0) > len(self):
            raise IndexError(
                f"index {idx0} is out of bounds for axis 0 with size {len(self)}"
            )

        # Turn negative index into positive
        if idx0 < 0:
            idx0 = len(self) + idx0

        n_values = len(values) if values.shape else 1

        # Finally make the new object with the correct length and set values for the
        # three sections, before insert, the insert, and after the insert.
        out = self.__class__.info.new_like(
            [self], len(self) + n_values, name=self.info.name
        )

        # Set the output values. This is where validation of `values` takes place to ensure
        # that it can indeed be inserted.
        out[:idx0] = self[:idx0]
        out[idx0 : idx0 + n_values] = values
        out[idx0 + n_values :] = self[idx0:]

        return out

    def is_transformable_to(self, new_frame):
        """
        Determines if this coordinate frame can be transformed to another
        given frame.

        Parameters
        ----------
        new_frame : frame class, frame object, or str
            The proposed frame to transform into.

        Returns
        -------
        transformable : bool or str
            `True` if this can be transformed to ``new_frame``, `False` if
            not, or the string 'same' if ``new_frame`` is the same system as
            this object but no transformation is defined.

        Notes
        -----
        A return value of 'same' means the transformation will work, but it will
        just give back a copy of this object.  The intended usage is::

            if coord.is_transformable_to(some_unknown_frame):
                coord2 = coord.transform_to(some_unknown_frame)

        This will work even if ``some_unknown_frame``  turns out to be the same
        frame class as ``coord``.  This is intended for cases where the frame
        is the same regardless of the frame attributes (e.g. ICRS), but be
        aware that it *might* also indicate that someone forgot to define the
        transformation between two objects of the same frame class but with
        different attributes.
        """
        # TODO! like matplotlib, do string overrides for modified methods
        new_frame = (
            _get_frame_class(new_frame) if isinstance(new_frame, str) else new_frame
        )
        return self.frame.is_transformable_to(new_frame)

    def transform_to(self, frame, merge_attributes=True):
        """Transform this coordinate to a new frame.

        The precise frame transformed to depends on ``merge_attributes``.
        If `False`, the destination frame is used exactly as passed in.
        But this is often not quite what one wants.  E.g., suppose one wants to
        transform an ICRS coordinate that has an obstime attribute to FK4; in
        this case, one likely would want to use this information. Thus, the
        default for ``merge_attributes`` is `True`, in which the precedence is
        as follows: (1) explicitly set (i.e., non-default) values in the
        destination frame; (2) explicitly set values in the source; (3) default
        value in the destination frame.

        Note that in either case, any explicitly set attributes on the source
        `SkyCoord` that are not part of the destination frame's definition are
        kept (stored on the resulting `SkyCoord`), and thus one can round-trip
        (e.g., from FK4 to ICRS to FK4 without losing obstime).

        Parameters
        ----------
        frame : str, `BaseCoordinateFrame` class or instance, or `SkyCoord` instance
            The frame to transform this coordinate into.  If a `SkyCoord`, the
            underlying frame is extracted, and all other information ignored.
        merge_attributes : bool, optional
            Whether the default attributes in the destination frame are allowed
            to be overridden by explicitly set attributes in the source
            (see note above; default: `True`).

        Returns
        -------
        coord : `SkyCoord`
            A new object with this coordinate represented in the `frame` frame.

        Raises
        ------
        ValueError
            If there is no possible transformation route.

        """
        from astropy.coordinates.errors import ConvertError

        frame_kwargs = {}

        # Frame name (string) or frame class?  Coerce into an instance.
        try:
            frame = _get_frame_class(frame)()
        except Exception:
            pass

        if isinstance(frame, SkyCoord):
            frame = frame.frame  # Change to underlying coord frame instance

        if isinstance(frame, BaseCoordinateFrame):
            new_frame_cls = frame.__class__
            # Get frame attributes, allowing defaults to be overridden by
            # explicitly set attributes of the source if ``merge_attributes``.
            for attr in frame_transform_graph.frame_attributes:
                self_val = getattr(self, attr, None)
                frame_val = getattr(frame, attr, None)
                if frame_val is not None and not (
                    merge_attributes and frame.is_frame_attr_default(attr)
                ):
                    frame_kwargs[attr] = frame_val
                elif self_val is not None and not self.is_frame_attr_default(attr):
                    frame_kwargs[attr] = self_val
                elif frame_val is not None:
                    frame_kwargs[attr] = frame_val
        else:
            raise ValueError(
                "Transform `frame` must be a frame name, class, or instance"
            )

        # Get the composite transform to the new frame
        trans = frame_transform_graph.get_transform(self.frame.__class__, new_frame_cls)
        if trans is None:
            raise ConvertError(
                f"Cannot transform from {self.frame.__class__} to {new_frame_cls}"
            )

        # Make a generic frame which will accept all the frame kwargs that
        # are provided and allow for transforming through intermediate frames
        # which may require one or more of those kwargs.
        generic_frame = GenericFrame(frame_kwargs)

        # Do the transformation, returning a coordinate frame of the desired
        # final type (not generic).
        new_coord = trans(self.frame, generic_frame)

        # Finally make the new SkyCoord object from the `new_coord` and
        # remaining frame_kwargs that are not frame_attributes in `new_coord`.
        for attr in set(new_coord.frame_attributes) & set(frame_kwargs.keys()):
            frame_kwargs.pop(attr)

        # Always remove the origin frame attribute, as that attribute only makes
        # sense with a SkyOffsetFrame (in which case it will be stored on the frame).
        # See gh-11277.
        # TODO: Should it be a property of the frame attribute that it can
        # or cannot be stored on a SkyCoord?
        frame_kwargs.pop("origin", None)

        return self.__class__(new_coord, **frame_kwargs)

    def apply_space_motion(self, new_obstime=None, dt=None):
        """
        Compute the position of the source represented by this coordinate object
        to a new time using the velocities stored in this object and assuming
        linear space motion (including relativistic corrections). This is
        sometimes referred to as an "epoch transformation."

        The initial time before the evolution is taken from the ``obstime``
        attribute of this coordinate.  Note that this method currently does not
        support evolving coordinates where the *frame* has an ``obstime`` frame
        attribute, so the ``obstime`` is only used for storing the before and
        after times, not actually as an attribute of the frame. Alternatively,
        if ``dt`` is given, an ``obstime`` need not be provided at all.

        Parameters
        ----------
        new_obstime : `~astropy.time.Time`, optional
            The time at which to evolve the position to. Requires that the
            ``obstime`` attribute be present on this frame.
        dt : `~astropy.units.Quantity`, `~astropy.time.TimeDelta`, optional
            An amount of time to evolve the position of the source. Cannot be
            given at the same time as ``new_obstime``.

        Returns
        -------
        new_coord : `SkyCoord`
            A new coordinate object with the evolved location of this coordinate
            at the new time.  ``obstime`` will be set on this object to the new
            time only if ``self`` also has ``obstime``.
        """
        from .builtin_frames.icrs import ICRS

        if (new_obstime is None) == (dt is None):
            raise ValueError(
                "You must specify one of `new_obstime` or `dt`, but not both."
            )

        # Validate that we have velocity info
        if "s" not in self.frame.data.differentials:
            raise ValueError("SkyCoord requires velocity data to evolve the position.")

        if "obstime" in self.frame.frame_attributes:
            raise NotImplementedError(
                "Updating the coordinates in a frame with explicit time dependence is"
                " currently not supported. If you would like this functionality, please"
                " open an issue on github:\nhttps://github.com/astropy/astropy"
            )

        if new_obstime is not None and self.obstime is None:
            # If no obstime is already on this object, raise an error if a new
            # obstime is passed: we need to know the time / epoch at which the
            # the position / velocity were measured initially
            raise ValueError(
                "This object has no associated `obstime`. apply_space_motion() must"
                " receive a time difference, `dt`, and not a new obstime."
            )

        # Compute t1 and t2, the times used in the starpm call, which *only*
        # uses them to compute a delta-time
        t1 = self.obstime
        if dt is None:
            # self.obstime is not None and new_obstime is not None b/c of above
            # checks
            t2 = new_obstime
        else:
            # new_obstime is definitely None b/c of the above checks
            if t1 is None:
                # MAGIC NUMBER: if the current SkyCoord object has no obstime,
                # assume J2000 to do the dt offset. This is not actually used
                # for anything except a delta-t in starpm, so it's OK that it's
                # not necessarily the "real" obstime
                t1 = Time("J2000")
                new_obstime = None  # we don't actually know the initial obstime
                t2 = t1 + dt
            else:
                t2 = t1 + dt
                new_obstime = t2
        # starpm wants tdb time
        t1 = t1.tdb
        t2 = t2.tdb

        # proper motion in RA should not include the cos(dec) term, see the
        # erfa function eraStarpv, comment (4).  So we convert to the regular
        # spherical differentials.
        icrsrep = self.icrs.represent_as(SphericalRepresentation, SphericalDifferential)
        icrsvel = icrsrep.differentials["s"]

        parallax_zero = False
        try:
            plx = icrsrep.distance.to_value(u.arcsecond, u.parallax())
        except u.UnitConversionError:  # No distance: set to 0 by convention
            plx = 0.0
            parallax_zero = True

        try:
            rv = icrsvel.d_distance.to_value(u.km / u.s)
        except u.UnitConversionError:  # No RV
            rv = 0.0

        starpm = erfa.pmsafe(
            icrsrep.lon.radian,
            icrsrep.lat.radian,
            icrsvel.d_lon.to_value(u.radian / u.yr),
            icrsvel.d_lat.to_value(u.radian / u.yr),
            plx,
            rv,
            t1.jd1,
            t1.jd2,
            t2.jd1,
            t2.jd2,
        )

        if parallax_zero:
            new_distance = None
        else:
            new_distance = Distance(parallax=starpm[4] << u.arcsec)

        icrs2 = ICRS(
            ra=u.Quantity(starpm[0], u.radian, copy=False),
            dec=u.Quantity(starpm[1], u.radian, copy=False),
            pm_ra=u.Quantity(starpm[2], u.radian / u.yr, copy=False),
            pm_dec=u.Quantity(starpm[3], u.radian / u.yr, copy=False),
            distance=new_distance,
            radial_velocity=u.Quantity(starpm[5], u.km / u.s, copy=False),
            differential_type=SphericalDifferential,
        )

        # Update the obstime of the returned SkyCoord, and need to carry along
        # the frame attributes
        frattrs = {
            attrnm: getattr(self, attrnm) for attrnm in self._extra_frameattr_names
        }
        frattrs["obstime"] = new_obstime
        result = self.__class__(icrs2, **frattrs).transform_to(self.frame)

        # Without this the output might not have the right differential type.
        # Not sure if this fixes the problem or just hides it.  See #11932
        result.differential_type = self.differential_type

        return result

    def _is_name(self, string):
        """
        Returns whether a string is one of the aliases for the frame.
        """
        return self.frame.name == string or (
            isinstance(self.frame.name, list) and string in self.frame.name
        )

    def __getattr__(self, attr):
        """
        Overrides getattr to return coordinates that this can be transformed
        to, based on the alias attr in the primary transform graph.
        """
        if "_sky_coord_frame" in self.__dict__:
            if self._is_name(attr):
                return self  # Should this be a deepcopy of self?

            # Anything in the set of all possible frame_attr_names is handled
            # here. If the attr is relevant for the current frame then delegate
            # to self.frame otherwise get it from self._<attr>.
            if attr in frame_transform_graph.frame_attributes:
                if attr in self.frame.frame_attributes:
                    return getattr(self.frame, attr)
                else:
                    return getattr(self, "_" + attr, None)

            # Some attributes might not fall in the above category but still
            # are available through self._sky_coord_frame.
            if not attr.startswith("_") and hasattr(self._sky_coord_frame, attr):
                return getattr(self._sky_coord_frame, attr)

            # Try to interpret as a new frame for transforming.
            frame_cls = frame_transform_graph.lookup_name(attr)
            if frame_cls is not None and self.frame.is_transformable_to(frame_cls):
                return self.transform_to(attr)

        # Fail
        raise AttributeError(
            f"'{self.__class__.__name__}' object has no attribute '{attr}'"
        )

    def __setattr__(self, attr, val):
        # This is to make anything available through __getattr__ immutable
        if "_sky_coord_frame" in self.__dict__:
            if self._is_name(attr):
                raise AttributeError(f"'{attr}' is immutable")

            if not attr.startswith("_") and hasattr(self._sky_coord_frame, attr):
                setattr(self._sky_coord_frame, attr, val)
                return

            frame_cls = frame_transform_graph.lookup_name(attr)
            if frame_cls is not None and self.frame.is_transformable_to(frame_cls):
                raise AttributeError(f"'{attr}' is immutable")

        if attr in frame_transform_graph.frame_attributes:
            # All possible frame attributes can be set, but only via a private
            # variable.  See __getattr__ above.
            super().__setattr__("_" + attr, val)
            # Validate it
            frame_transform_graph.frame_attributes[attr].__get__(self)
            # And add to set of extra attributes
            self._extra_frameattr_names |= {attr}

        else:
            # Otherwise, do the standard Python attribute setting
            super().__setattr__(attr, val)

    def __delattr__(self, attr):
        # mirror __setattr__ above
        if "_sky_coord_frame" in self.__dict__:
            if self._is_name(attr):
                raise AttributeError(f"'{attr}' is immutable")

            if not attr.startswith("_") and hasattr(self._sky_coord_frame, attr):
                delattr(self._sky_coord_frame, attr)
                return

            frame_cls = frame_transform_graph.lookup_name(attr)
            if frame_cls is not None and self.frame.is_transformable_to(frame_cls):
                raise AttributeError(f"'{attr}' is immutable")

        if attr in frame_transform_graph.frame_attributes:
            # All possible frame attributes can be deleted, but need to remove
            # the corresponding private variable.  See __getattr__ above.
            super().__delattr__("_" + attr)
            # Also remove it from the set of extra attributes
            self._extra_frameattr_names -= {attr}

        else:
            # Otherwise, do the standard Python attribute setting
            super().__delattr__(attr)

    def __dir__(self):
        """
        Override the builtin `dir` behavior to include:
        - Transforms available by aliases
        - Attribute / methods of the underlying 
```


# astropy/coordinates/tests (the files in it)

astropy/coordinates/tests/__init__.py
astropy/coordinates/tests/accuracy/__init__.py
astropy/coordinates/tests/accuracy/data/fk4_no_e_fk4.csv
astropy/coordinates/tests/accuracy/data/fk4_no_e_fk5.csv
astropy/coordinates/tests/accuracy/data/galactic_fk4.csv
astropy/coordinates/tests/accuracy/data/icrs_fk5.csv
astropy/coordinates/tests/accuracy/data/rv.ecsv
astropy/coordinates/tests/accuracy/generate_ref_ast.py
astropy/coordinates/tests/accuracy/generate_spectralcoord_ref.py
astropy/coordinates/tests/accuracy/test_altaz_icrs.py
astropy/coordinates/tests/accuracy/test_ecliptic.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk4.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk5.py
astropy/coordinates/tests/accuracy/test_galactic_fk4.py
astropy/coordinates/tests/accuracy/test_icrs_fk5.py
astropy/coordinates/tests/helper.py
astropy/coordinates/tests/test_angle_generators.py
astropy/coordinates/tests/test_angles.py
astropy/coordinates/tests/test_angular_separation.py
astropy/coordinates/tests/test_api_ape5.py
astropy/coordinates/tests/test_arrays.py
astropy/coordinates/tests/test_atc_replacements.py
astropy/coordinates/tests/test_celestial_transformations.py
astropy/coordinates/tests/test_distance.py
astropy/coordinates/tests/test_earth.py
astropy/coordinates/tests/test_earth_orientation.py
astropy/coordinates/tests/test_erfa_astrom.py
astropy/coordinates/tests/test_finite_difference_velocities.py
astropy/coordinates/tests/test_formatting.py
astropy/coordinates/tests/test_frames.py
astropy/coordinates/tests/test_frames_with_velocity.py
astropy/coordinates/tests/test_funcs.py
astropy/coordinates/tests/test_geodetic_representations.py
astropy/coordinates/tests/test_iau_fullstack.py
astropy/coordinates/tests/test_icrs_observed_transformations.py
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
astropy/coordinates/tests/test_spectral_coordinate.py
astropy/coordinates/tests/test_spectral_quantity.py
astropy/coordinates/tests/test_transformations.py
astropy/coordinates/tests/test_unit_representation.py
astropy/coordinates/tests/test_utils.py
astropy/coordinates/tests/test_velocity_corrs.py


# The last commit

```
06c74e6ae SWE-bench



 pyproject.toml | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

```diff
diff --git a/pyproject.toml b/pyproject.toml
index 486d6b9b3..1c5f74f3a 100644
--- a/pyproject.toml
+++ b/pyproject.toml
@@ -1,5 +1,5 @@
 [build-system]
-requires = ["setuptools",
+requires = ["setuptools==68.0.0",
             "setuptools_scm>=6.2",
             "wheel",
             "cython==0.29.30",

```
````

### `direct-check.log`

```
check: python -m pytest astropy/coordinates/tests/test_sky_coord.py -q
<frozen importlib._bootstrap>:228: RuntimeWarning: numpy.ndarray size changed, may indicate binary incompatibility. Expected 80 from C header, got 96 from PyObject
Internet access disabled
[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 16%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 33%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 50%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31mF[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 66%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 83%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33mx[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[31m [100%][0m
=================================== FAILURES ===================================
[31m[1m_______________________________ test_repr_altaz ________________________________[0m

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
>           table = iers.LeapSeconds.auto_open(files)

[1m[31mastropy/time/core.py[0m:3311: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

cls = <class 'astropy.utils.iers.iers.LeapSeconds'>
files = ['erfa', '/testbed/astropy/utils/iers/data/Leap_Second.dat', 'https://hpiers.obspm.fr/iers/bul/bulc/Leap_Second.dat', 'https://www.ietf.org/timezones/data/leap-seconds.list']

    @classmethod
    def auto_open(cls, files=None):
        """Attempt to get an up-to-date leap-second list.
    
        The routine will try the files in sequence until it finds one
        whose expiration date is "good enough" (see below).  If none
        are good enough, it returns the one with the most recent expiration
        date, warning if that file is expired.
    
        For remote files that are cached already, the cached file is tried
        first before attempting to retrieve it again.
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses
            ``cls._auto_open_files``.
    
        Returns
        -------
        leap_seconds : `~astropy.utils.iers.LeapSeconds`
            Up to date leap-second table
    
        Notes
        -----
        Bulletin C is released about 10 days after a possible leap second is
        introduced, i.e., mid-January or mid-July.  Expiration days are thus
        generally at least 150 days after the present.  We look for a file
        that expires more than 180 - `~astropy.utils.iers.Conf.auto_max_age`
        after the present.
        """
        offset = 180 - (30 if conf.auto_max_age is None else conf.auto_max_age)
        good_enough = cls._today() + TimeDelta(offset, format="jd")
    
        if files is None:
            # Basic files to go over (entries in _auto_open_files can be
            # configuration items, which we want to be sure are up to date).
            files = [getattr(conf, f, f) for f in cls._auto_open_files]
    
        # Remove empty entries.
        files = [f for f in files if f]
    
        # Our trials start with normal files and remote ones that are
        # already in cache.  The bools here indicate that the cache
        # should be used.
        trials = [
            (f, True) for f in files if not urlparse(f).netloc or is_url_in_cache(f)
        ]
        # If we are allowed to download, we try downloading new versions
        # if none of the above worked.
        if conf.auto_download:
            trials += [(f, False) for f in files if urlparse(f).netloc]
    
        self = None
        err_list = []
        # Go through all entries, and return the first one that
        # is not expired, or the most up to date one.
        for f, allow_cache in trials:
            if not allow_cache:
                clear_download_cache(f)
    
            try:
                trial = cls.open(f, cache=True)
            except Exception as exc:
                err_list.append(exc)
                continue
    
            if self is None or trial.expires > self.expires:
                self = trial
                self.meta["data_url"] = str(f)
                if self.expires > good_enough:
                    break
    
        if self is None:
            raise ValueError(
                "none of the files could be read. The "
                f"following errors were raised:\n {err_list}"
            )
    
        if self.expires < self._today() and conf.auto_max_age is not None:
>           warn("leap-second file is expired.", IERSStaleWarning)
[1m[31mE           astropy.utils.iers.iers.IERSStaleWarning: leap-second file is expired.[0m

[1m[31mastropy/utils/iers/iers.py[0m:1142: IERSStaleWarning

[33mDuring handling of the above exception, another exception occurred:[0m

    def test_repr_altaz():
        sc2 = SkyCoord(1 * u.deg, 1 * u.deg, frame="icrs", distance=1 * u.kpc)
        loc = EarthLocation(-2309223 * u.m, -3695529 * u.m, -4641767 * u.m)
        time = Time("2005-03-21 00:00:00")
>       sc4 = sc2.transform_to(AltAz(location=loc, obstime=time))

[1m[31mastropy/coordinates/tests/test_sky_coord.py[0m:783: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
[1m[31mastropy/coordinates/sky_coordinate.py[0m:704: in transform_to
    new_coord = trans(self.frame, generic_frame)
[1m[31mastropy/coordinates/transformations.py[0m:1575: in __call__
    curr_coord = t(curr_coord, curr_toframe)
[1m[31mastropy/coordinates/transformations.py[0m:1144: in __call__
    return supcall(fromcoord, toframe)
[1m[31mastropy/coordinates/builtin_frames/icrs_observed_transforms.py[0m:33: in icrs_to_observed
    astrom = erfa_astrom.get().apco(observed_frame)
[1m[31mastropy/coordinates/erfa_astrom.py[0m:52: in apco
    jd1_tt, jd2_tt = get_jd12(obstime, "tt")
[1m[31mastropy/coordinates/builtin_frames/utils.py[0m:115: in get_jd12
    newtime = getattr(time, scale)
[1m[31mastropy/time/core.py[0m:1635: in __getattr__
    tm._set_scale(attr)
[1m[31mastropy/time/core.py[0m:742: in _set_scale
    _check_leapsec()
[1m[31mastropy/time/core.py[0m:3282: in _check_leapsec
    update_leap_seconds()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
            table = iers.LeapSeconds.auto_open(files)
            return erfa.leap_seconds.update(table)
    
        except Exception as exc:
>           warn(
                f"leap-second auto-update failed due to the following exception: {exc!r}",
                AstropyWarning,
            )
[1m[31mE           astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due to the following exception: IERSStaleWarning('leap-second file is expired.')[0m

[1m[31mastropy/time/core.py[0m:3315: AstropyWarning
[36m[1m=========================== short test summary info ============================[0m
[31mFAILED[0m astropy/coordinates/tests/test_sky_coord.py::[1mtest_repr_altaz[0m - astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due...
[31m[31m[1m1 failed[0m, [32m427 passed[0m, [33m3 skipped[0m, [33m1 xfailed[0m[31m in 4.51s[0m[0m

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: astropy/coordinates/sky_coordinate.py astropy/coordinates/tests
changed: astropy/coordinates/sky_coordinate.py +13 -0
changed: astropy/coordinates/tests/test_sky_coord.py +13 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/astropy/coordinates/sky_coordinate.py b/astropy/coordinates/sky_coordinate.py
index ab475f7d0..ec6250c79 100644
--- a/astropy/coordinates/sky_coordinate.py
+++ b/astropy/coordinates/sky_coordinate.py
@@ -871,6 +871,19 @@ class SkyCoord(ShapedLikeNDArray):
         Overrides getattr to return coordinates that this can be transformed
         to, based on the alias attr in the primary transform graph.
         """
+        # If ``attr`` is defined as a descriptor on the class, then normal
+        # attribute lookup failed because the descriptor itself raised an
+        # AttributeError (e.g., a property whose getter accesses a missing
+        # attribute).  Re-run the descriptor so that the original, more
+        # informative error propagates instead of being replaced below by a
+        # misleading message claiming that ``attr`` does not exist.
+        for cls in type(self).__mro__:
+            if attr in cls.__dict__:
+                descriptor = cls.__dict__[attr]
+                if hasattr(descriptor, "__get__"):
+                    return descriptor.__get__(self, type(self))
+                break
+
         if "_sky_coord_frame" in self.__dict__:
             if self._is_name(attr):
                 return self  # Should this be a deepcopy of self?
diff --git a/astropy/coordinates/tests/test_sky_coord.py b/astropy/coordinates/tests/test_sky_coord.py
index 4dcfba0d4..e41f9f03c 100644
--- a/astropy/coordinates/tests/test_sky_coord.py
+++ b/astropy/coordinates/tests/test_sky_coord.py
@@ -1464,6 +1464,19 @@ def test_immutable():
     assert c1.foo == 42
 
 
+def test_subclass_property_attribute_error():
+    """Errors from properties on subclasses should not be masked by __getattr__."""
+
+    class CustomCoord(SkyCoord):
+        @property
+        def prop(self):
+            return self.random_attr
+
+    c = CustomCoord("00h42m30s", "+41d12m00s", frame="icrs")
+    with pytest.raises(AttributeError, match="random_attr"):
+        c.prop
+
+
 @pytest.mark.skipif(not HAS_SCIPY, reason="Requires scipy")
 def test_search_around():
     """
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
check: python -m pytest astropy/coordinates/tests/test_sky_coord.py -q
<frozen importlib._bootstrap>:228: RuntimeWarning: numpy.ndarray size changed, may indicate binary incompatibility. Expected 80 from C header, got 96 from PyObject
Internet access disabled
[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 16%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 33%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 50%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31mF[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 66%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 83%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33mx[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[31m [100%][0m
=================================== FAILURES ===================================
[31m[1m_______________________________ test_repr_altaz ________________________________[0m

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
>           table = iers.LeapSeconds.auto_open(files)

[1m[31mastropy/time/core.py[0m:3311: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

cls = <class 'astropy.utils.iers.iers.LeapSeconds'>
files = ['erfa', '/testbed/astropy/utils/iers/data/Leap_Second.dat', 'https://hpiers.obspm.fr/iers/bul/bulc/Leap_Second.dat', 'https://www.ietf.org/timezones/data/leap-seconds.list']

    @classmethod
    def auto_open(cls, files=None):
        """Attempt to get an up-to-date leap-second list.
    
        The routine will try the files in sequence until it finds one
        whose expiration date is "good enough" (see below).  If none
        are good enough, it returns the one with the most recent expiration
        date, warning if that file is expired.
    
        For remote files that are cached already, the cached file is tried
        first before attempting to retrieve it again.
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses
            ``cls._auto_open_files``.
    
        Returns
        -------
        leap_seconds : `~astropy.utils.iers.LeapSeconds`
            Up to date leap-second table
    
        Notes
        -----
        Bulletin C is released about 10 days after a possible leap second is
        introduced, i.e., mid-January or mid-July.  Expiration days are thus
        generally at least 150 days after the present.  We look for a file
        that expires more than 180 - `~astropy.utils.iers.Conf.auto_max_age`
        after the present.
        """
        offset = 180 - (30 if conf.auto_max_age is None else conf.auto_max_age)
        good_enough = cls._today() + TimeDelta(offset, format="jd")
    
        if files is None:
            # Basic files to go over (entries in _auto_open_files can be
            # configuration items, which we want to be sure are up to date).
            files = [getattr(conf, f, f) for f in cls._auto_open_files]
    
        # Remove empty entries.
        files = [f for f in files if f]
    
        # Our trials start with normal files and remote ones that are
        # already in cache.  The bools here indicate that the cache
        # should be used.
        trials = [
            (f, True) for f in files if not urlparse(f).netloc or is_url_in_cache(f)
        ]
        # If we are allowed to download, we try downloading new versions
        # if none of the above worked.
        if conf.auto_download:
            trials += [(f, False) for f in files if urlparse(f).netloc]
    
        self = None
        err_list = []
        # Go through all entries, and return the first one that
        # is not expired, or the most up to date one.
        for f, allow_cache in trials:
            if not allow_cache:
                clear_download_cache(f)
    
            try:
                trial = cls.open(f, cache=True)
            except Exception as exc:
                err_list.append(exc)
                continue
    
            if self is None or trial.expires > self.expires:
                self = trial
                self.meta["data_url"] = str(f)
                if self.expires > good_enough:
                    break
    
        if self is None:
            raise ValueError(
                "none of the files could be read. The "
                f"following errors were raised:\n {err_list}"
            )
    
        if self.expires < self._today() and conf.auto_max_age is not None:
>           warn("leap-second file is expired.", IERSStaleWarning)
[1m[31mE           astropy.utils.iers.iers.IERSStaleWarning: leap-second file is expired.[0m

[1m[31mastropy/utils/iers/iers.py[0m:1142: IERSStaleWarning

[33mDuring handling of the above exception, another exception occurred:[0m

    def test_repr_altaz():
        sc2 = SkyCoord(1 * u.deg, 1 * u.deg, frame="icrs", distance=1 * u.kpc)
        loc = EarthLocation(-2309223 * u.m, -3695529 * u.m, -4641767 * u.m)
        time = Time("2005-03-21 00:00:00")
>       sc4 = sc2.transform_to(AltAz(location=loc, obstime=time))

[1m[31mastropy/coordinates/tests/test_sky_coord.py[0m:783: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
[1m[31mastropy/coordinates/sky_coordinate.py[0m:704: in transform_to
    new_coord = trans(self.frame, generic_frame)
[1m[31mastropy/coordinates/transformations.py[0m:1575: in __call__
    curr_coord = t(curr_coord, curr_toframe)
[1m[31mastropy/coordinates/transformations.py[0m:1144: in __call__
    return supcall(fromcoord, toframe)
[1m[31mastropy/coordinates/builtin_frames/icrs_observed_transforms.py[0m:33: in icrs_to_observed
    astrom = erfa_astrom.get().apco(observed_frame)
[1m[31mastropy/coordinates/erfa_astrom.py[0m:52: in apco
    jd1_tt, jd2_tt = get_jd12(obstime, "tt")
[1m[31mastropy/coordinates/builtin_frames/utils.py[0m:115: in get_jd12
    newtime = getattr(time, scale)
[1m[31mastropy/time/core.py[0m:1635: in __getattr__
    tm._set_scale(attr)
[1m[31mastropy/time/core.py[0m:742: in _set_scale
    _check_leapsec()
[1m[31mastropy/time/core.py[0m:3282: in _check_leapsec
    update_leap_seconds()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
            table = iers.LeapSeconds.auto_open(files)
            return erfa.leap_seconds.update(table)
    
        except Exception as exc:
>           warn(
                f"leap-second auto-update failed due to the following exception: {exc!r}",
                AstropyWarning,
            )
[1m[31mE           astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due to the following exception: IERSStaleWarning('leap-second file is expired.')[0m

[1m[31mastropy/time/core.py[0m:3315: AstropyWarning
[36m[1m=========================== short test summary info ============================[0m
[31mFAILED[0m astropy/coordinates/tests/test_sky_coord.py::[1mtest_repr_altaz[0m - astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due...
[31m[31m[1m1 failed[0m, [32m427 passed[0m, [33m3 skipped[0m, [33m1 xfailed[0m[31m in 4.71s[0m[0m

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: astropy/coordinates/sky_coordinate.py astropy/coordinates/tests
changed: astropy/coordinates/sky_coordinate.py +13 -0
changed: astropy/coordinates/tests/test_sky_coord.py +13 -0
```

### `final-status.txt`

```
none
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
# Notes, run 2026-11-06T171621

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Subclassed SkyCoord gives misleading attribute access message
I'm trying to subclass `SkyCoord`, and add some custom properties. This all seems to be working fine, but when I have a custom property (`prop` below) that tries to access a non-existent attribute (`random_attr`) below, the error message is misleading because it says `prop` doesn't exist, where it should say `random_attr` doesn't exist.

```python
import astropy.coordinates as coord


class custom_coord(coord.SkyCoord):
    @property
    def prop(self):
        return self.random_attr


c = custom_coord('00h42m30s', '+41d12m00s', frame='icrs')
c.prop
```

raises
```
Traceback (most recent call last):
  File "test.py", line 11, in <module>
    c.prop
  File "/Users/dstansby/miniconda3/lib/python3.7/site-packages/astropy/coordinates/sky_coordinate.py", line 600, in __getattr__
    .format(self.__class__.__name__, attr))
AttributeError: 'custom_coord' object has no attribute 'prop'
```


# The files of the project

```
.astropy-root
.circleci/config.yml
.git-blame-ignore-revs
.gitattributes
.github/CODEOWNERS
.github/ISSUE_TEMPLATE/bug_report.md
.github/ISSUE_TEMPLATE/feature_request.md
.github/PULL_REQUEST_TEMPLATE.md
.github/labeler.yml
.github/workflows/check_changelog.yml
.github/workflows/ci_cron_daily.yml
.github/workflows/ci_cron_weekly.yml
.github/workflows/ci_workflows.yml
.github/workflows/codeql-analysis.yml
.github/workflows/open_actions.yml
.github/workflows/publish.yml
.github/workflows/stalebot.yml
.github/workflows/update_iers.yml
.gitignore
.mailmap
.pep8speaks.yml
.pre-commit-config.yaml
.pyinstaller/hooks/hook-skyfield.py
.pyinstaller/run_astropy_tests.py
.readthedocs.yaml
CHANGES.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.md
GOVERNANCE.md
LICENSE.rst
MANIFEST.in
README.rst
astropy/CITATION
astropy/__init__.py
astropy/_dev/__init__.py
astropy/_dev/scm_version.py
astropy/config/__init__.py
astropy/config/configuration.py
astropy/config/paths.py
astropy/config/tests/__init__.py
astropy/config/tests/data/alias.cfg
astropy/config/tests/data/deprecated.cfg
astropy/config/tests/data/empty.cfg
astropy/config/tests/data/not_empty.cfg
astropy/config/tests/test_configs.py
astropy/conftest.py
astropy/constants/__init__.py
astropy/constants/astropyconst13.py
astropy/constants/astropyconst20.py
astropy/constants/astropyconst40.py
astropy/constants/cgs.py
astropy/constants/codata2010.py
astropy/constants/codata2014.py
astropy/constants/codata2018.py
astropy/constants/config.py
astropy/constants/constant.py
astropy/constants/iau2012.py
astropy/constants/iau2015.py
astropy/constants/si.py
astropy/constants/tests/__init__.py
astropy/constants/tests/test_constant.py
astropy/constants/tests/test_pickle.py
astropy/constants/tests/test_prior_version.py
astropy/constants/tests/test_sciencestate.py
astropy/constants/utils.py
astropy/convolution/__init__.py
astropy/convolution/_convolve.pyx
astropy/convolution/convolve.py
astropy/convolution/core.py
astropy/convolution/kernels.py
astropy/convolution/setup_package.py
astropy/convolution/src/convolve.c
astropy/convolution/src/convolve.h
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
astropy/coordinates/angle_formats.py
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
astropy/coordinates/builtin_frames/equatorial.py
astropy/coordinates/builtin_frames/fk4.py
astropy/coordinates/builtin_frames/fk4_fk5_transforms.py
astropy/coordinates/builtin_frames/fk5.py
astropy/coordinates/builtin_frames/galactic.py
astropy/coordinates/builtin_frames/galactic_transforms.py
astropy/coordinates/builtin_frames/galactocentric.py
astropy/coordinates/builtin_frames/gcrs.py
astropy/coordinates/builtin_frames/hadec.py
astropy/coordinates/builtin_frames/hcrs.py
astropy/coordinates/builtin_frames/icrs.py
astropy/coordinates/builtin_frames/icrs_cirs_transforms.py
astropy/coordinates/builtin_frames/icrs_fk5_transforms.py
astropy/coordinates/builtin_frames/icrs_observed_transforms.py
astropy/coordinates/builtin_frames/intermediate_rotation_transforms.py
astropy/coordinates/builtin_frames/itrs.py
astropy/coordinates/builtin_frames/itrs_observed_transforms.py
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
astropy/coordinates/erfa_astrom.py
astropy/coordinates/errors.py
astropy/coordinates/funcs.py
astropy/coordinates/jparser.py
astropy/coordinates/matching.py
astropy/coordinates/matrix_utilities.py
astropy/coordinates/name_resolve.py
astropy/coordinates/orbital_elements.py
astropy/coordinates/representation.py
astropy/coordinates/sites.py
astropy/coordinates/sky_coordinate.py
astropy/coordinates/sky_coordinate_parsers.py
astropy/coordinates/solar_system.py
astropy/coordinates/spectral_coordinate.py
astropy/coordinates/spectral_quantity.py
astropy/coordinates/tests/__init__.py
astropy/coordinates/tests/accuracy/__init__.py
astropy/coordinates/tests/accuracy/data/fk4_no_e_fk4.csv
astropy/coordinates/tests/accuracy/data/fk4_no_e_fk5.csv
astropy/coordinates/tests/accuracy/data/galactic_fk4.csv
astropy/coordinates/tests/accuracy/data/icrs_fk5.csv
astropy/coordinates/tests/accuracy/data/rv.ecsv
astropy/coordinates/tests/accuracy/generate_ref_ast.py
astropy/coordinates/tests/accuracy/generate_spectralcoord_ref.py
astropy/coordinates/tests/accuracy/test_altaz_icrs.py
astropy/coordinates/tests/accuracy/test_ecliptic.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk4.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk5.py
astropy/coordinates/tests/accuracy/test_galactic_fk4.py
astropy/coordinates/tests/accuracy/test_icrs_fk5.py
astropy/coordinates/tests/helper.py
astropy/coordinates/tests/test_angle_generators.py
astropy/coordinates/tests/test_angles.py
astropy/coordinates/tests/test_angular_separation.py
astropy/coordinates/tests/test_api_ape5.py
astropy/coordinates/tests/test_arrays.py
astropy/coordinates/tests/test_atc_replacements.py
astropy/coordinates/tests/test_celestial_transformations.py
astropy/coordinates/tests/test_distance.py
astropy/coordinates/tests/test_earth.py
astropy/coordinates/tests/test_earth_orientation.py
astropy/coordinates/tests/test_erfa_astrom.py
astropy/coordinates/tests/test_finite_difference_velocities.py
astropy/coordinates/tests/test_formatting.py
astropy/coordinates/tests/test_frames.py
astropy/coordinates/tests/test_frames_with_velocity.py
astropy/coordinates/tests/test_funcs.py
astropy/coordinates/tests/test_geodetic_representations.py
astropy/coordinates/tests/test_iau_fullstack.py
astropy/coordinates/tests/test_icrs_observed_transformations.py
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
astropy/coordinates/tests/test_spectral_coordinate.py
astropy/coordinates/tests/test_spectral_quantity.py
astropy/coordinates/tests/test_transformations.py
astropy/coordinates/tests/test_unit_representation.py
astropy/coordinates/tests/test_utils.py
astropy/coordinates/tests/test_velocity_corrs.py
astropy/coordinates/transformations.py
astropy/cosmology/__init__.py
astropy/cosmology/connect.py
astropy/cosmology/core.py
astropy/cosmology/data/Planck13.ecsv
astropy/cosmology/data/Planck15.ecsv
astropy/cosmology/data/Planck18.ecsv
astropy/cosmology/data/WMAP1.ecsv
astropy/cosmology/data/WMAP3.ecsv
astropy/cosmology/data/WMAP5.ecsv
astropy/cosmology/data/WMAP7.ecsv
astropy/cosmology/data/WMAP9.ecsv
astropy/cosmology/flrw/__init__.py
astropy/cosmology/flrw/base.py
astropy/cosmology/flrw/lambdacdm.py
astropy/cosmology/flrw/scalar_inv_efuncs.pyx
astropy/cosmology/flrw/tests/__init__.py
astropy/cosmology/flrw/tests/conftest.py
astropy/cosmology/flrw/tests/test_base.py
astropy/cosmology/flrw/tests/test_init.py
astropy/cosmology/flrw/tests/test_lambdacdm.py
astropy/cosmology/flrw/tests/test_w0cdm.py
astropy/cosmology/flrw/tests/test_w0wacdm.py
astropy/cosmology/flrw/tests/test_w0wzcdm.py
astropy/cosmology/flrw/tests/test_wpwazpcdm.py
astropy/cosmology/flrw/w0cdm.py
astropy/cosmology/flrw/w0wacdm.py
astropy/cosmology/flrw/w0wzcdm.py
astropy/cosmology/flrw/wpwazpcdm.py
astropy/cosmology/funcs/__init__.py
astropy/cosmology/funcs/comparison.py
astropy/cosmology/funcs/optimize.py
astropy/cosmology/funcs/tests/__init__.py
astropy/cosmology/funcs/tests/test_comparison.py
astropy/cosmology/funcs/tests/test_funcs.py
astropy/cosmology/io/__init__.py
astropy/cosmology/io/cosmology.py
astropy/cosmology/io/ecsv.py
astropy/cosmology/io/html.py
astropy/cosmology/io/mapping.py
astropy/cosmology/io/model.py
astropy/cosmology/io/row.py
astropy/cosmology/io/table.py
astropy/cosmology/io/tests/__init__.py
astropy/cosmology/io/tests/base.py
astropy/cosmology/io/tests/test_.py
astropy/cosmology/io/tests/test_cosmology.py
astropy/cosmology/io/tests/test_ecsv.py
astropy/cosmology/io/tests/test_html.py
astropy/cosmology/io/tests/test_json.py
astropy/cosmology/io/tests/test_mapping.py
astropy/cosmology/io/tests/test_model.py
astropy/cosmology/io/tests/test_row.py
astropy/cosmology/io/tests/test_table.py
astropy/cosmology/io/tests/test_yaml.py
astropy/cosmology/io/utils.py
astropy/cosmology/io/yaml.py
astropy/cosmology/parameter.py
astropy/cosmology/parameters.py
astropy/cosmology/realizations.py
astropy/cosmology/tests/__init__.py
astropy/cosmology/tests/conftest.py
astropy/cosmology/tests/helper.py
astropy/cosmology/tests/test_connect.py
astropy/cosmology/tests/test_core.py
astropy/cosmology/tests/test_cosmology.py
astropy/cosmology/tests/test_parameter.py
astropy/cosmology/tests/test_parameters.py
astropy/cosmology/tests/test_realizations.py
astropy/cosmology/tests/test_units.py
astropy/cosmology/tests/test_utils.py
astropy/cosmology/units.py
astropy/cosmology/utils.py
astropy/extern/README.rst
astropy/extern/__init__.py
astropy/extern/_strptime.py
astropy/extern/configobj/__init__.py
astropy/extern/configobj/configobj.py
astropy/extern/configobj/validate.py
astropy/extern/jquery/__init__.py
astropy/extern/jquery/data/css/jquery.dataTables.css
astropy/extern/jquery/data/images/sort_asc.png
astropy/extern/jquery/data/images/sort_asc_disabled.png
astropy/extern/jquery/data/images/sort_both.png
astropy/extern/jquery/data/images/sort_desc.png
astropy/extern/jquery/data/images/sort_desc_disabled.png
astropy/extern/jquery/data/js/jquery-3.6.0.js
astropy/extern/jquery/data/js/jquery-3.6.0.min.js
astropy/extern/jquery/data/js/jquery.dataTables.js
astropy/extern/jquery/data/js/jquery.dataTables.min.js
astropy/extern/ply/__init__.py
astropy/extern/ply/cpp.py
astropy/extern/ply/ctokens.py
astropy/extern/ply/lex.py
astropy/extern/ply/yacc.py
astropy/extern/ply/ygen.py
astropy/io/__init__.py
astropy/io/ascii/__init__.py
astropy/io/ascii/basic.py
astropy/io/ascii/cds.py
astropy/io/ascii/connect.py
astropy/io/ascii/core.py
astropy/io/ascii/cparser.pyx
astropy/io/ascii/daophot.py
astropy/io/ascii/docs.py
astropy/io/ascii/ecsv.py
astropy/io/ascii/fastbasic.py
astropy/io/ascii/fixedwidth.py
astropy/io/ascii/html.py
astropy/io/ascii/ipac.py
astropy/io/ascii/latex.py
astropy/io/ascii/misc.py
astropy/io/ascii/mrt.py
astropy/io/ascii/qdp.py
astropy/io/ascii/rst.py
astropy/io/ascii/setup_package.py
astropy/io/ascii/sextractor.py
astropy/io/ascii/src/tokenizer.c
astropy/io/ascii/src/tokenizer.h
astropy/io/ascii/tests/__init__.py
astropy/io/ascii/tests/common.py
astropy/io/ascii/tests/data/apostrophe.rdb
astropy/io/ascii/tests/data/apostrophe.tab
astropy/io/ascii/tests/data/bad.txt
astropy/io/ascii/tests/data/bars_at_ends.txt
astropy/io/ascii/tests/data/cds.dat
astropy/io/ascii/tests/data/cds/description/ReadMe
astropy/io/ascii/tests/data/cds/description/table.dat
astropy/io/ascii/tests/data/cds/glob/ReadMe
astropy/io/ascii/tests/data/cds/glob/lmxbrefs.dat
astropy/io/ascii/tests/data/cds/multi/ReadMe
astropy/io/ascii/tests/data/cds/multi/lhs2065.dat
astropy/io/ascii/tests/data/cds/multi/lp944-20.dat
astropy/io/ascii/tests/data/cds/null/ReadMe
astropy/io/ascii/tests/data/cds/null/ReadMe1
astropy/io/ascii/tests/data/cds/null/table.dat
astropy/io/ascii/tests/data/cds2.dat
astropy/io/ascii/tests/data/cdsFunctional.dat
astropy/io/ascii/tests/data/cdsFunctional2.dat
astropy/io/ascii/tests/data/cds_malformed.dat
astropy/io/ascii/tests/data/commented_header.dat
astropy/io/ascii/tests/data/commented_header2.dat
astropy/io/ascii/tests/data/conf_py.txt
astropy/io/ascii/tests/data/continuation.dat
astropy/io/ascii/tests/data/daophot.dat
astropy/io/ascii/tests/data/daophot.dat.gz
astropy/io/ascii/tests/data/daophot2.dat
astropy/io/ascii/tests/data/daophot3.dat
astropy/io/ascii/tests/data/daophot4.dat
astropy/io/ascii/tests/data/fill_values.txt
astropy/io/ascii/tests/data/fixed_width_2_line.txt
astropy/io/ascii/tests/data/html.html
astropy/io/ascii/tests/data/html2.html
astropy/io/ascii/tests/data/ipac.dat
astropy/io/ascii/tests/data/ipac.dat.bz2
astropy/io/ascii/tests/data/ipac.dat.xz
astropy/io/ascii/tests/data/latex1.tex
astropy/io/ascii/tests/data/latex1.tex.gz
astropy/io/ascii/tests/data/latex2.tex
astropy/io/ascii/tests/data/latex3.tex
astropy/io/ascii/tests/data/nls1_stackinfo.dbout
astropy/io/ascii/tests/data/no_data_cds.dat
astropy/io/ascii/tests/data/no_data_daophot.dat
astropy/io/ascii/tests/data/no_data_ipac.dat
astropy/io/ascii/tests/data/no_data_sextractor.dat
astropy/io/ascii/tests/data/no_data_with_header.dat
astropy/io/ascii/tests/data/no_data_without_header.dat
astropy/io/ascii/tests/data/sextractor.dat
astropy/io/ascii/tests/data/sextractor2.dat
astropy/io/ascii/tests/data/sextractor3.dat
astropy/io/ascii/tests/data/short.rdb
astropy/io/ascii/tests/data/short.rdb.bz2
astropy/io/ascii/tests/data/short.rdb.gz
astropy/io/ascii/tests/data/short.rdb.xz
astropy/io/ascii/tests/data/short.tab
astropy/io/ascii/tests/data/simple.txt
astropy/io/ascii/tests/data/simple2.txt
astropy/io/ascii/tests/data/simple3.txt
astropy/io/ascii/tests/data/simple4.txt
astropy/io/ascii/tests/data/simple5.txt
astropy/io/ascii/tests/data/simple_csv.csv
astropy/io/ascii/tests/data/simple_csv_missing.csv
astropy/io/ascii/tests/data/space_delim_blank_lines.txt
astropy/io/ascii/tests/data/space_delim_no_header.dat
astropy/io/ascii/tests/data/space_delim_no_names.dat
astropy/io/ascii/tests/data/subtypes.ecsv
astropy/io/ascii/tests/data/test4.dat
astropy/io/ascii/tests/data/test5.dat
astropy/io/ascii/tests/data/vizier/ReadMe
astropy/io/ascii/tests/data/vizier/table1.dat
astropy/io/ascii/tests/data/vizier/table5.dat
astropy/io/ascii/tests/data/vots_spec.dat
astropy/io/ascii/tests/data/whitespace.dat
astropy/io/ascii/tests/test_c_reader.py
astropy/io/ascii/tests/test_cds.py
astropy/io/ascii/tests/test_cds_header_from_readme.py
astropy/io/ascii/tests/test_compressed.py
astropy/io/ascii/tests/test_connect.py
astropy/io/ascii/tests/test_ecsv.py
astropy/io/ascii/tests/test_fixedwidth.py
astropy/io/ascii/tests/test_html.py
astropy/io/ascii/tests/test_ipac_definitions.py
astropy/io/ascii/tests/test_qdp.py
astropy/io/ascii/tests/test_read.py
astropy/io/ascii/tests/test_rst.py
astropy/io/ascii/tests/test_types.py
astropy/io/ascii/tests/test_write.py
astropy/io/ascii/ui.py
astropy/io/fits/__init__.py
astropy/io/fits/_utils.pyx
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
astropy/io/fits/tests/conftest.py
astropy/io/fits/tests/data/arange.fits
astropy/io/fits/tests/data/ascii.fits
astropy/io/fits/tests/data/ascii_i4-i20.fits
astropy/io/fits/tests/data/blank.fits
astropy/io/fits/tests/data/btable.fits
astropy/io/fits/tests/data/chandra_time.fits
astropy/io/fits/tests/data/checksum.fits
astropy/io/fits/tests/data/checksum_false.fits
astropy/io/fits/tests/data/comp.fits
astropy/io/fits/tests/data/compressed_float_bzero.fits
astropy/io/fits/tests/data/compressed_image.fits
astropy/io/fits/tests/data/double_ext.fits
astropy/io/fits/tests/data/fixed-1890.fits
astropy/io/fits/tests/data/group.fits
astropy/io/fits/tests/data/history_header.fits
astropy/io/fits/tests/data/invalid/group_invalid.fits
astropy/io/fits/tests/data/memtest.fits
astropy/io/fits/tests/data/o4sp040b0_raw.fits
astropy/io/fits/tests/data/random_groups.fits
astropy/io/fits/tests/data/scale.fits
astropy/io/fits/tests/data/stddata.fits
astropy/io/fits/tests/data/table.fits
astropy/io/fits/tests/data/tb.fits
astropy/io/fits/tests/data/tdim.fits
astropy/io/fits/tests/data/test0.fits
astropy/io/fits/tests/data/test1.fits
astropy/io/fits/tests/data/theap-gap.fits
astropy/io/fits/tests/data/variable_length_table.fits
astropy/io/fits/tests/data/verify.fits
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
astropy/io/fits/tests/test_fsspec.py
astropy/io/fits/tests/test_groups.py
astropy/io/fits/tests/test_hdulist.py
astropy/io/fits/tests/test_header.py
astropy/io/fits/tests/test_image.py
astropy/io/fits/tests/test_image_dask.py
astropy/io/fits/tests/test_nonstandard.py
astropy/io/fits/tests/test_structured.py
astropy/io/fits/tests/test_table.py
astropy/io/fits/tests/test_tilde_path.py
astropy/io/fits/tests/test_uint.py
astropy/io/fits/tests/test_util.py
astropy/io/fits/util.py
astropy/io/fits/verify.py
astropy/io/misc/__init__.py
astropy/io/misc/asdf/__init__.py
astropy/io/misc/asdf/conftest.py
astropy/io/misc/asdf/connect.py
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/angle-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/earthlocation-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/baseframe-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/cirs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/fk4-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/fk4noeterms-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/fk5-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/galactic-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/galactocentric-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/gcrs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/icrs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/icrs-1.1.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/itrs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/precessedgeocentric-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/latitude-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/longitude-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/representation-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/skycoord-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/spectralcoord-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/fits/fits-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/table/table-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/time/timedelta-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/transform/units_mapping-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/units/equivalency-1.0.0.yaml
astropy/io/misc/asdf/deprecation.py
astropy/io/misc/asdf/extension.py
astropy/io/misc/asdf/tags/__init__.py
astropy/io/misc/asdf/tags/coordinates/__init__.py
astropy/io/misc/asdf/tags/coordinates/angle.py
astropy/io/misc/asdf/tags/coordinates/earthlocation.py
astropy/io/misc/asdf/tags/coordinates/frames.py
astropy/io/misc/asdf/tags/coordinates/representation.py
astropy/io/misc/asdf/tags/coordinates/skycoord.py
astropy/io/misc/asdf/tags/coordinates/spectralcoord.py
astropy/io/misc/asdf/tags/coordinates/tests/__init__.py
astropy/io/misc/asdf/tags/coordinates/tests/test_angle.py
astropy/io/misc/asdf/tags/coordinates/tests/test_earthlocation.py
astropy/io/misc/asdf/tags/coordinates/tests/test_frames.py
astropy/io/misc/asdf/tags/coordinates/tests/test_representation.py
astropy/io/misc/asdf/tags/coordinates/tests/test_skycoord.py
astropy/io/misc/asdf/tags/coordinates/tests/test_spectralcoord.py
astropy/io/misc/asdf/tags/fits/__init__.py
astropy/io/misc/asdf/tags/fits/fits.py
astropy/io/misc/asdf/tags/fits/tests/__init__.py
astropy/io/misc/asdf/tags/fits/tests/data/complex.fits
astropy/io/misc/asdf/tags/fits/tests/test_fits.py
astropy/io/misc/asdf/tags/helpers.py
astropy/io/misc/asdf/tags/table/__init__.py
astropy/io/misc/asdf/tags/table/table.py
astropy/io/misc/asdf/tags/table/tests/__init__.py
astropy/io/misc/asdf/tags/table/tests/test_table.py
astropy/io/misc/asdf/tags/tests/__init__.py
astropy/io/misc/asdf/tags/tests/helpers.py
astropy/io/misc/asdf/tags/time/__init__.py
astropy/io/misc/asdf/tags/time/tests/__init__.py
astropy/io/misc/asdf/tags/time/tests/test_time.py
astropy/io/misc/asdf/tags/time/tests/test_timedelta.py
astropy/io/misc/asdf/tags/time/time.py
astropy/io/misc/asdf/tags/time/timedelta.py
astropy/io/misc/asdf/tags/transform/__init__.py
astropy/io/misc/asdf/tags/transform/basic.py
astropy/io/misc/asdf/tags/transform/compound.py
astropy/io/misc/asdf/tags/transform/functional_models.py
astropy/io/misc/asdf/tags/transform/math.py
astropy/io/misc/asdf/tags/transform/physical_models.py
astropy/io/misc/asdf/tags/transform/polynomial.py
astropy/io/misc/asdf/tags/transform/powerlaws.py
astropy/io/misc/asdf/tags/transform/projections.py
astropy/io/misc/asdf/tags/transform/spline.py
astropy/io/misc/asdf/tags/transform/tabular.py
astropy/io/misc/asdf/tags/transform/tests/__init__.py
astropy/io/misc/asdf/tags/transform/tests/test_transform.py
astropy/io/misc/asdf/tags/transform/tests/test_units_mapping.py
astropy/io/misc/asdf/tags/unit/__init__.py
astropy/io/misc/asdf/tags/unit/equivalency.py
astropy/io/misc/asdf/tags/unit/quantity.py
astropy/io/misc/asdf/tags/unit/tests/__init__.py
astropy/io/misc/asdf/tags/unit/tests/test_equivalency.py
astropy/io/misc/asdf/tags/unit/tests/test_quantity.py
astropy/io/misc/asdf/tags/unit/tests/test_unit.py
astropy/io/misc/asdf/tags/unit/unit.py
astropy/io/misc/asdf/tests/__init__.py
astropy/io/misc/asdf/tests/test_io.py
astropy/io/misc/asdf/types.py
astropy/io/misc/connect.py
astropy/io/misc/hdf5.py
astropy/io/misc/pandas/__init__.py
astropy/io/misc/pandas/connect.py
astropy/io/misc/parquet.py
astropy/io/misc/pickle_helpers.py
astropy/io/misc/tests/__init__.py
astropy/io/misc/tests/data/old_meta_example.hdf5
astropy/io/misc/tests/test_hdf5.py
astropy/io/misc/tests/test_pandas.py
astropy/io/misc/tests/test_parquet.py
astropy/io/misc/tests/test_pickle_helpers.py
astropy/io/misc/tests/test_yaml.py
astropy/io/misc/yaml.py
astropy/io/registry/__init__.py
astropy/io/registry/base.py
astropy/io/registry/compat.py
```


# The last commit

```
06c74e6ae SWE-bench



 pyproject.toml | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

```diff
diff --git a/pyproject.toml b/pyproject.toml
index 486d6b9b3..1c5f74f3a 100644
--- a/pyproject.toml
+++ b/pyproject.toml
@@ -1,5 +1,5 @@
 [build-system]
-requires = ["setuptools",
+requires = ["setuptools==68.0.0",
             "setuptools_scm>=6.2",
             "wheel",
             "cython==0.29.30",

```


# CONTRIBUTING.md (the start)

```
Contributing to Astropy
=======================

Reporting Issues
----------------

When opening an issue to report a problem, please try to provide a minimal code
example that reproduces the issue along with details of the operating
system and the Python, NumPy, and `astropy` versions you are using.

Contributing Code and Documentation
-----------------------------------

So you are interested in contributing to the Astropy Project?  Excellent!
We love contributions! Astropy is open source, built on open source, and
we'd love to have you hang out in our community.

Anti Imposter Syndrome Reassurance
----------------------------------

We want your help. No, really.

There may be a little voice inside your head that is telling you that you're not
ready to be an open source contributor; that your skills aren't nearly good
enough to contribute. What could you possibly offer a project like this one?

We assure you - the little voice in your head is wrong. If you can write code or
documentation, you can contribute code to open source.
Contributing to open source projects is a fantastic way to advance one's coding
and open source workflow skills. Writing perfect code isn't the measure of a good
developer (that would disqualify all of us!); it's trying to create something,
making mistakes, and learning from those mistakes. That's how we all improve,
and we are happy to help others learn.

Being an open source contributor doesn't just mean writing code, either. You can
help out by writing documentation, tests, or even giving feedback about the
project (and yes - that includes giving feedback about the contribution
process). Some of these contributions may be the most valuable to the project as
a whole, because you're coming to the project with fresh eyes, so you can see
the errors and assumptions that seasoned contributors have glossed over.

Note: This text was originally written by
[Adrienne Lowe](https://github.com/adriennefriend) for a
[PyCon talk](https://www.youtube.com/watch?v=6Uj746j9Heo), and was adapted by
Astropy based on its use in the README file for the
[MetPy project](https://github.com/Unidata/MetPy).

How to Contribute, Best Practices
---------------------------------

Most contributions to Astropy are done via [pull
requests](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)
from GitHub users' forks of the [astropy
repository](https://github.com/astropy/astropy). If you are new to this
style of development, you will want to read over our [development
workflow](https://docs.astropy.org/en/latest/development/workflow/development_workflow.html).

You may also/instead be interested in contributing to an
[astropy affiliated package](https://www.astropy.org/affiliated/).
Affiliated packages are astronomy-related software packages that are not a part
of the `astropy` core package, but build on it for more specialized applications
and follow the Astropy guidelines for reuse, interoperability, and interfacing.
Each affiliated package has its own developers/maintainers and its own specific
guidelines for contributions, so be sure to read their docs.

Once you open a pull request (which should be opened against the ``main``
branch, not against any of the other branches), please make sure to
include the following:

- **Code**: the code you are adding, which should follow
  our [coding guidelines](https://docs.astropy.org/en/latest/development/codeguide.html) as much as possible.

- **Tests**: these are usually tests to ensure code that previously
  failed now works (regression tests), or tests that cover as much as possible
  of the new functionality to make sure it does not break in the future and
  also returns consistent results on all platforms (since we run these tests on
  many platforms/configurations). For more information about how to write
  tests, see our [testing guidelines](https://docs.astropy.org/en/latest/development/testguide.html).

- **Documentation**: if you are adding new functionality, be sure to include a
  description in the main documentation (in ``docs/``). Again, we have some
  detailed [documentation guidelines](https://docs.astropy.org/en/latest/development/docguide.html) to help you out.

- **Performance improvements**: if you are making changes that impact `astropy`
  performance, consider adding a performance benchmark in the
  [astropy-benchmarks](https://github.com/astropy/astropy-benchmarks)
  repository. You can find out more about how to do this
  [in the README for that repository](https://github.com/astropy/astropy-benchmarks#contributing-benchmarks).

- **Changelog entry**: whether you are fixing a bug or adding new
  functionality, you should add a changelog fragment in the ``docs/changes/``
  directory. See ``docs/changes/README.rst`` for some guidance on the creation
  of this file.

  If you are opening a pull request you may not know
  the PR number yet, but you can add it once the pull request is open. If you
  are not sure where to put the changelog entry, wait until a maintainer
  has reviewed your PR and assigned it to a milestone.

  You do not need to include a changelog entry for fixes to bugs introduced in
  the developer version and therefore are not present in the stable releases. In
  general you do not need to include a changelog entry for minor documentation
  or test updates. Only user-visible changes (new features/API changes, fixed
  issues) need to be mentioned. If in doubt, ask the core maintainer reviewing
  your changes.

Checklist for Contributed Code
------------------------------

Before being merged, a pull request for a new feature will be reviewed to see if
it meets the following requirements. If you are unsure about how to meet all of these
requirements, please submit the PR and ask for help and/or guidance. An Astropy
maintainer will collaborate with you to make sure that the pull request meets the
requirements for inclusion in the package:

**Scientific Quality** (whe
```


# pyproject.toml (the start)

```
[build-system]
requires = ["setuptools==68.0.0",
            "setuptools_scm>=6.2",
            "wheel",
            "cython==0.29.30",
            "oldest-supported-numpy",
            "extension-helpers"]
build-backend = 'setuptools.build_meta'

[tool.setuptools_scm]
write_to = "astropy/_version.py"

[tool.astropy-bot]
    [tool.astropy-bot.autolabel]
        # Comment this out to re-enable but then labeler Action needs to be disabled.
        enabled = false

    [tool.astropy-bot.changelog_checker]
        enabled = false

[tool.cibuildwheel]
# We disable testing for the following wheels:
# - MacOS X ARM (no native hardware, tests are skipped anyway, this avoids a warning)
# - Linux AArch64 (no native hardware, tests take too long)
# - MuslLinux (tests hang non-deterministically)
test-skip = "*-macosx_arm64 *-manylinux_aarch64 *-musllinux_x86_64"

[[tool.cibuildwheel.overrides]]
# Python 3.11 and later is not available in manylinux2010 so we only
# set this for Python<=3.10.
select = "cp3{8,9,10}-*"
manylinux-x86_64-image = "manylinux2010"
manylinux-i686-image = "manylinux2010"

[[tool.cibuildwheel.overrides]]
# Numpy 1.22 doesn't have wheels for i386, so we pin Numpy to an older version
# that does - this pin can be removed once we drop support for 32-bit wheels.
select = "cp3{8,9}-*"
test-requires = "numpy==1.21.*"

[tool.cibuildwheel.macos]
archs = ["x86_64", "arm64"]

[tool.cibuildwheel.linux]
archs = ["auto", "aarch64"]

[tool.black]
line-length = 88
force-exclude = '''
^/(
  (
    # Directories to always exclude (.gitignore is always excluded)
      examples
    | docs/wcs/examples
    | docs/nddata/examples
    | cextern
    | astropy/extern
  )/
  # Individual files to always exclude
  | astropy/coordinates/.*tab.py
  | astropy/units/format/.*tab.py
)
'''

[tool.isort]
    profile = "black"
    extend_skip_glob = [
        "astropy/extern/*",
    ]
    known_third_party = ["erfa", "PyYAML", "packaging", "pytest", "scipy", "matplotlib"]
    known_first_party = ["astropy", "extension_helpers"]
    group_by_package = true

[tool.coverage]

    [tool.coverage.run]
        omit = [
            "astropy/__init__*",
            "astropy/conftest.py",
            "astropy/*setup*",
            "astropy/*/tests/*",
            "astropy/tests/test_*",
            "astropy/extern/*",
            "astropy/utils/compat/*",
            "astropy/version*",
            "astropy/wcs/docstrings*",
            "*/astropy/__init__*",
            "*/astropy/conftest.py",
            "*/astropy/*setup*",
            "*/astropy/*/tests/*",
            "*/astropy/tests/test_*",
            "*/astropy/extern/*",
            "*/astropy/utils/compat/*",
            "*/astropy/version*",
            "*/astropy/wcs/docstrings*",
        ]

    [tool.coverage.report]
        exclude_lines = [
            # Have to re-enable the standard pragma
            "pragma: no cover",
            # Don't complain about packages we have installed
            "except ImportError",
            # Don't complain if tests don't hit defensive assertion code:
            "raise AssertionError",
            "raise NotImplementedError",
            # Don't complain about script hooks
            "'def main(.*):'",
            # Ignore branches that don't pertain to this version of Python
            "pragma: py{ignore_python_version}",
            # Don't complain about IPython completion helper
            "def _ipython_key_completions_",
        ]

[tool.towncrier]
    package = "astropy"
    filename = "CHANGES.rst"
    directory = "docs/changes"
    underlines = "=-^"
    template = "docs/changes/template.rst"
    title_format = "Version {version} ({project_date})"

    [[tool.towncrier.type]]
        directory = "feature"
        name = "New Features"
        showcontent = true

    [[tool.towncrier.type]]
        directory = "api"
        name = "API Changes"
        showcontent = true

    [[tool.towncrier.type]]
        directory = "bugfix"
        name = "Bug Fixes"
        showcontent = true

    [[tool.towncrier.type]]
        directory = "other"
        name = "Other Changes and Additions"
        showcontent = true

    [[tool.towncrier.section]]
        name = ""
        path = ""

    [[tool.towncrier.section]]
        name = "astropy.config"
        path = "config"

    [[tool.towncrier.section]]
        name = "astropy.constants"
        path = "constants"

    [[tool.towncrier.section]]
        name = "astropy.convolution"
        path = "convolution"

    [[tool.towncrier.section]]
        name = "astropy.coordinates"
        path = "coordinates"

    [[tool.towncrier.section]]
        name = "astropy.cosmology"
        path = "cosmology"

    [[tool.towncrier.section]]
        name = "astropy.extern"
        path = "extern"

    [[tool.towncrier.section]]
        name = "astropy.io.ascii"
        path = "io.ascii"

    [[tool.towncrier.section]]
        name = "astropy.io.fits"
        path = "io.fits"

    [[tool.towncrier.section]]
        name = "astropy.io.misc"
        path = "io.misc"

    [[tool.towncrier.section]]
        name = "astropy.io.registry"
        path = "io.registry"

    [[tool.towncrier.section]]
        name = "astropy.io.votable"
        path = "io.votable"

    [[tool.towncrier.section]]
        name = "astropy.modeling"
        path = "modeling"

    [[tool.towncrier.section]]
        name = "astropy.nddata"
        path = "nddata"

    [[tool.towncrier.section]]
        name = "astropy.samp"
        path = "samp"

    [[tool.towncrier.section]]
        name = "astropy.stats"
        path = "stats"

    [[tool.towncrier.section]]
        name = "astropy.table"
        path = "table"

    [[tool.towncrier.section]]
        name = "astropy.tests"
        path = "tests"

    [[tool.towncrier.section]]
        name = "astropy.time"
        path = "time"

    [[tool.towncrier.section]]
        name = "astropy.timeseries"
        path = "timeseries"

    [[tool.towncrier.section]]
    
```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest astropy/coordinates/tests/test_sky_coord.py -q`

## Scope
`astropy/coordinates/sky_coordinate.py`
`astropy/coordinates/tests/`

## Done when
- A `SkyCoord` subclass property whose getter accesses a nonexistent attribute raises `AttributeError` naming the missing inner attribute (`random_attr`), not the property (`prop`).
- The inner exception's message is preserved through the subclass property access path.
- Accessing a genuinely nonexistent attribute on a `SkyCoord` still raises the existing `AttributeError` naming that requested attribute.
- Existing frame/representation attribute fallback in `__getattr__` continues to work.
- The coordinates tests covering `SkyCoord` attribute access pass.

## Approach
Reproduce the failure first, then fix `SkyCoord.__getattr__` so it distinguishes “attribute genuinely absent” from “attribute exists on the class but its descriptor raised `AttributeError`.” The key constraint is that the original exception is cleared before `__getattr__` is called, so it must be regenerated by re-invoking the descriptor, not by a bare `raise` or `sys.exc_info()`.

Candidate approaches:
- In `__getattr__`, before raising the misleading message, test whether `attr` exists on the class (e.g. `attr in dir(type(self))` or `hasattr(type(self), attr)`) and, if so, return `object.__getattribute__(self, attr)`. This re-runs the property getter and lets the inner `AttributeError` propagate. Tradeoff: class-level `hasattr` may invoke custom descriptors unless `inspect.getattr_static` is used.
- Use `inspect.getattr_static(type(self), attr, None)` to detect a descriptor without invoking it, then delegate to `object.__getattribute__`. Safer for exotic descriptors; slightly more code.
- Narrow the check to members of `type(self).__mro__` dictionaries rather than `dir(self)`, avoiding frame/representation dynamic names that are not ordinary class attributes.

Avoid calling `getattr(self, attr)` inside `__getattr__` (infinite recursion). After the fix, add a focused regression test under `astropy/coordinates/tests/` and run the scoped test command above.
```

### `prompt.md`

````
Subclassed SkyCoord gives misleading attribute access message
I'm trying to subclass `SkyCoord`, and add some custom properties. This all seems to be working fine, but when I have a custom property (`prop` below) that tries to access a non-existent attribute (`random_attr`) below, the error message is misleading because it says `prop` doesn't exist, where it should say `random_attr` doesn't exist.

```python
import astropy.coordinates as coord


class custom_coord(coord.SkyCoord):
    @property
    def prop(self):
        return self.random_attr


c = custom_coord('00h42m30s', '+41d12m00s', frame='icrs')
c.prop
```

raises
```
Traceback (most recent call last):
  File "test.py", line 11, in <module>
    c.prop
  File "/Users/dstansby/miniconda3/lib/python3.7/site-packages/astropy/coordinates/sky_coordinate.py", line 600, in __getattr__
    .format(self.__class__.__name__, attr))
AttributeError: 'custom_coord' object has no attribute 'prop'
```
````

### `review.md`

```
verdict: PASS

- The change re-runs a class descriptor in `SkyCoord.__getattr__` when normal lookup failed because that descriptor raised `AttributeError`, so the subclass property getter’s inner `AttributeError` naming `random_attr` propagates instead of being replaced by a misleading `prop` message.
- The added test `test_subclass_property_attribute_error` covers the reported case and is among the passing tests.
- Genuinely missing attributes still fall through to the existing `__getattr__` logic and raise the existing `AttributeError` naming the requested attribute.
- Frame/representation fallback remains intact: the new path only triggers for descriptors already present in the class MRO that raised `AttributeError`; ordinary frame/representation fallback attributes are not intercepted.
- The single pytest failure is `test_repr_altaz`, caused by an expired leap-second file (`IERSStaleWarning`/`AstropyWarning`), unrelated to this change and also present in the baseline.
```

### `scope.txt`

```
scope: astropy/coordinates/sky_coordinate.py astropy/coordinates/tests
changed: astropy/coordinates/sky_coordinate.py +13 -0
changed: astropy/coordinates/tests/test_sky_coord.py +13 -0
```

### `task.md`

````
# Task

## Prompt

Subclassed SkyCoord gives misleading attribute access message
I'm trying to subclass `SkyCoord`, and add some custom properties. This all seems to be working fine, but when I have a custom property (`prop` below) that tries to access a non-existent attribute (`random_attr`) below, the error message is misleading because it says `prop` doesn't exist, where it should say `random_attr` doesn't exist.

```python
import astropy.coordinates as coord


class custom_coord(coord.SkyCoord):
    @property
    def prop(self):
        return self.random_attr


c = custom_coord('00h42m30s', '+41d12m00s', frame='icrs')
c.prop
```

raises
```
Traceback (most recent call last):
  File "test.py", line 11, in <module>
    c.prop
  File "/Users/dstansby/miniconda3/lib/python3.7/site-packages/astropy/coordinates/sky_coordinate.py", line 600, in __getattr__
    .format(self.__class__.__name__, attr))
AttributeError: 'custom_coord' object has no attribute 'prop'
```

## Deliverable

changes to this tree

## Check

`python -m pytest astropy/coordinates/tests/test_sky_coord.py -q`

## Scope

`astropy/coordinates/sky_coordinate.py`
`astropy/coordinates/tests/`

## Done when

- A `SkyCoord` subclass property whose getter accesses a nonexistent attribute raises `AttributeError` naming the missing inner attribute (`random_attr`), not the property (`prop`).
- The inner exception's message is preserved through the subclass property access path.
- Accessing a genuinely nonexistent attribute on a `SkyCoord` still raises the existing `AttributeError` naming that requested attribute.
- Existing frame/representation attribute fallback in `__getattr__` continues to work.
- The coordinates tests covering `SkyCoord` attribute access pass.
````

### `test-output.log`

```
check: python -m pytest astropy/coordinates/tests/test_sky_coord.py -q
<frozen importlib._bootstrap>:228: RuntimeWarning: numpy.ndarray size changed, may indicate binary incompatibility. Expected 80 from C header, got 96 from PyObject
Internet access disabled
[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 16%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 33%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m [ 50%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31mF[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 66%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[31m [ 83%]
[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33mx[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[32m.[0m[33ms[0m[31m [100%][0m
=================================== FAILURES ===================================
[31m[1m_______________________________ test_repr_altaz ________________________________[0m

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
>           table = iers.LeapSeconds.auto_open(files)

[1m[31mastropy/time/core.py[0m:3311: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

cls = <class 'astropy.utils.iers.iers.LeapSeconds'>
files = ['erfa', '/testbed/astropy/utils/iers/data/Leap_Second.dat', 'https://hpiers.obspm.fr/iers/bul/bulc/Leap_Second.dat', 'https://www.ietf.org/timezones/data/leap-seconds.list']

    @classmethod
    def auto_open(cls, files=None):
        """Attempt to get an up-to-date leap-second list.
    
        The routine will try the files in sequence until it finds one
        whose expiration date is "good enough" (see below).  If none
        are good enough, it returns the one with the most recent expiration
        date, warning if that file is expired.
    
        For remote files that are cached already, the cached file is tried
        first before attempting to retrieve it again.
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses
            ``cls._auto_open_files``.
    
        Returns
        -------
        leap_seconds : `~astropy.utils.iers.LeapSeconds`
            Up to date leap-second table
    
        Notes
        -----
        Bulletin C is released about 10 days after a possible leap second is
        introduced, i.e., mid-January or mid-July.  Expiration days are thus
        generally at least 150 days after the present.  We look for a file
        that expires more than 180 - `~astropy.utils.iers.Conf.auto_max_age`
        after the present.
        """
        offset = 180 - (30 if conf.auto_max_age is None else conf.auto_max_age)
        good_enough = cls._today() + TimeDelta(offset, format="jd")
    
        if files is None:
            # Basic files to go over (entries in _auto_open_files can be
            # configuration items, which we want to be sure are up to date).
            files = [getattr(conf, f, f) for f in cls._auto_open_files]
    
        # Remove empty entries.
        files = [f for f in files if f]
    
        # Our trials start with normal files and remote ones that are
        # already in cache.  The bools here indicate that the cache
        # should be used.
        trials = [
            (f, True) for f in files if not urlparse(f).netloc or is_url_in_cache(f)
        ]
        # If we are allowed to download, we try downloading new versions
        # if none of the above worked.
        if conf.auto_download:
            trials += [(f, False) for f in files if urlparse(f).netloc]
    
        self = None
        err_list = []
        # Go through all entries, and return the first one that
        # is not expired, or the most up to date one.
        for f, allow_cache in trials:
            if not allow_cache:
                clear_download_cache(f)
    
            try:
                trial = cls.open(f, cache=True)
            except Exception as exc:
                err_list.append(exc)
                continue
    
            if self is None or trial.expires > self.expires:
                self = trial
                self.meta["data_url"] = str(f)
                if self.expires > good_enough:
                    break
    
        if self is None:
            raise ValueError(
                "none of the files could be read. The "
                f"following errors were raised:\n {err_list}"
            )
    
        if self.expires < self._today() and conf.auto_max_age is not None:
>           warn("leap-second file is expired.", IERSStaleWarning)
[1m[31mE           astropy.utils.iers.iers.IERSStaleWarning: leap-second file is expired.[0m

[1m[31mastropy/utils/iers/iers.py[0m:1142: IERSStaleWarning

[33mDuring handling of the above exception, another exception occurred:[0m

    def test_repr_altaz():
        sc2 = SkyCoord(1 * u.deg, 1 * u.deg, frame="icrs", distance=1 * u.kpc)
        loc = EarthLocation(-2309223 * u.m, -3695529 * u.m, -4641767 * u.m)
        time = Time("2005-03-21 00:00:00")
>       sc4 = sc2.transform_to(AltAz(location=loc, obstime=time))

[1m[31mastropy/coordinates/tests/test_sky_coord.py[0m:783: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
[1m[31mastropy/coordinates/sky_coordinate.py[0m:704: in transform_to
    new_coord = trans(self.frame, generic_frame)
[1m[31mastropy/coordinates/transformations.py[0m:1575: in __call__
    curr_coord = t(curr_coord, curr_toframe)
[1m[31mastropy/coordinates/transformations.py[0m:1144: in __call__
    return supcall(fromcoord, toframe)
[1m[31mastropy/coordinates/builtin_frames/icrs_observed_transforms.py[0m:33: in icrs_to_observed
    astrom = erfa_astrom.get().apco(observed_frame)
[1m[31mastropy/coordinates/erfa_astrom.py[0m:52: in apco
    jd1_tt, jd2_tt = get_jd12(obstime, "tt")
[1m[31mastropy/coordinates/builtin_frames/utils.py[0m:115: in get_jd12
    newtime = getattr(time, scale)
[1m[31mastropy/time/core.py[0m:1635: in __getattr__
    tm._set_scale(attr)
[1m[31mastropy/time/core.py[0m:742: in _set_scale
    _check_leapsec()
[1m[31mastropy/time/core.py[0m:3282: in _check_leapsec
    update_leap_seconds()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

files = None

    def update_leap_seconds(files=None):
        """If the current ERFA leap second table is out of date, try to update it.
    
        Uses `astropy.utils.iers.LeapSeconds.auto_open` to try to find an
        up-to-date table.  See that routine for the definition of "out of date".
    
        In order to make it safe to call this any time, all exceptions are turned
        into warnings,
    
        Parameters
        ----------
        files : list of path-like, optional
            List of files/URLs to attempt to open.  By default, uses defined by
            `astropy.utils.iers.LeapSeconds.auto_open`, which includes the table
            used by ERFA itself, so if that is up to date, nothing will happen.
    
        Returns
        -------
        n_update : int
            Number of items updated.
    
        """
        try:
            from astropy.utils import iers
    
            table = iers.LeapSeconds.auto_open(files)
            return erfa.leap_seconds.update(table)
    
        except Exception as exc:
>           warn(
                f"leap-second auto-update failed due to the following exception: {exc!r}",
                AstropyWarning,
            )
[1m[31mE           astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due to the following exception: IERSStaleWarning('leap-second file is expired.')[0m

[1m[31mastropy/time/core.py[0m:3315: AstropyWarning
[36m[1m=========================== short test summary info ============================[0m
[31mFAILED[0m astropy/coordinates/tests/test_sky_coord.py::[1mtest_repr_altaz[0m - astropy.utils.exceptions.AstropyWarning: leap-second auto-update failed due...
[31m[31m[1m1 failed[0m, [32m427 passed[0m, [33m3 skipped[0m, [33m1 xfailed[0m[31m in 5.97s[0m[0m

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: astropy/coordinates/sky_coordinate.py astropy/coordinates/tests
changed: astropy/coordinates/sky_coordinate.py +13 -0
changed: astropy/coordinates/tests/test_sky_coord.py +13 -0
```

### `test-status.txt`

```
none
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
The added MRO descriptor check re-runs the failing subclass property, so the inner `AttributeError` naming `random_attr` propagates instead of being replaced by the misleading `prop` message.
The new test directly covers the reported case and asserts the error matches `random_attr`.
Genuinely missing attributes are not in the class `__dict__`, so they still reach the existing `__getattr__` fallback and error naming the requested attribute.
The existing frame/representation fallback path is left intact because the new check only intercepts class-defined descriptors.
No unrelated content is removed, and the changes stay within the stated scope.
```
