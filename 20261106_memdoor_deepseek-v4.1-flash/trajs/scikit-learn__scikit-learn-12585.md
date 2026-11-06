# scikit-learn__scikit-learn-12585 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 33s 35 lines cost=0.001004 in=58317 cached=41472 out=1169 calls=8`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

clone fails for parameters that are estimator types
#### Description

`clone` fails when one or more instance parameters are estimator types (i.e. not instances, but classes). 

I know this is a somewhat unusual use case, but I'm working on a project that provides wrappers for sklearn estimators (https://github.com/phausamann/sklearn-xarray) and I'd like to store the wrapped estimators as their classes - not their instances - as a parameter inside of a wrapper that behaves like an estimator itself. 

#### Steps/Code to Reproduce

    from sklearn.preprocessing import StandardScaler
    from sklearn.base import clone
    clone(StandardScaler(with_mean=StandardScaler))

#### Expected Results

No error.

#### Actual Results
```
Traceback (most recent call last):
...
  File "...\lib\site-packages\sklearn\base.py", line 62, in clone
    new_object_params[name] = clone(param, safe=False)
  File "...\lib\site-packages\sklearn\base.py", line 60, in clone
    new_object_params = estimator.get_params(deep=False)
TypeError: get_params() missing 1 required positional argument: 'self'
```

#### Possible fix

Change `base.py`, line 51 to: 

    elif not hasattr(estimator, 'get_params') or isinstance(estimator, type):

I'm not sure whether this might break stuff in other places, however. I'd happily submit a PR if this change is desired.

#### Versions

    sklearn: 0.20.0

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain && sed -n '1,120p' sklearn/base.py"
}
```

**tool result**

```
CONTRIBUTING.md
COPYING
ISSUE_TEMPLATE.md
MANIFEST.in
Makefile
PULL_REQUEST_TEMPLATE.md
README.rst
appveyor.yml
benchmarks
build
build_tools
conftest.py
doc
examples
scikit_learn.egg-info
setup.cfg
setup.py
site.cfg
sklearn
?? .memdoor/
"""Base classes for all estimators."""

# Author: Gael Varoquaux <gael.varoquaux@normalesup.org>
# License: BSD 3 clause

import copy
import warnings
from collections import defaultdict

import numpy as np
from scipy import sparse
from .externals import six
from .utils.fixes import signature
from . import __version__


##############################################################################
def _first_and_last_element(arr):
    """Returns first and last element of numpy array or sparse matrix."""
    if isinstance(arr, np.ndarray) or hasattr(arr, 'data'):
        # numpy array or sparse matrix with .data attribute
        data = arr.data if sparse.issparse(arr) else arr
        return data.flat[0], data.flat[-1]
    else:
        # Sparse matrices without .data attribute. Only dok_matrix at
        # the time of writing, in this case indexing is fast
        return arr[0, 0], arr[-1, -1]


def clone(estimator, safe=True):
    """Constructs a new estimator with the same parameters.

    Clone does a deep copy of the model in an estimator
    without actually copying attached data. It yields a new estimator
    with the same parameters that has not been fit on any data.

    Parameters
    ----------
    estimator : estimator object, or list, tuple or set of objects
        The estimator or group of estimators to be cloned

    safe : boolean, optional
        If safe is false, clone will fall back to a deep copy on objects
        that are not estimators.

    """
    estimator_type = type(estimator)
    # XXX: not handling dictionaries
    if estimator_type in (list, tuple, set, frozenset):
        return estimator_type([clone(e, safe=safe) for e in estimator])
    elif not hasattr(estimator, 'get_params'):
        if not safe:
            return copy.deepcopy(estimator)
        else:
            raise TypeError("Cannot clone object '%s' (type %s): "
                            "it does not seem to be a scikit-learn estimator "
                            "as it does not implement a 'get_params' methods."
                            % (repr(estimator), type(estimator)))
    klass = estimator.__class__
    new_object_params = estimator.get_params(deep=False)
    for name, param in six.iteritems(new_object_params):
        new_object_params[name] = clone(param, safe=False)
    new_object = klass(**new_object_params)
    params_set = new_object.get_params(deep=False)

    # quick sanity check of the parameters of the clone
    for name in new_object_params:
        param1 = new_object_params[name]
        param2 = params_set[name]
        if param1 is not param2:
            raise RuntimeError('Cannot clone object %s, as the constructor '
                               'either does not set or modifies parameter %s' %
                               (estimator, name))
    return new_object


###############################################################################
def _pprint(params, offset=0, printer=repr):
    """Pretty print the dictionary 'params'

    Parameters
    ----------
    params : dict
        The dictionary to pretty print

    offset : int
        The offset in characters to add at the begin of each line.

    printer : callable
        The function to convert entries to strings, typically
        the builtin str or repr

    """
    # Do a multi-line justified repr:
    options = np.get_printoptions()
    np.set_printoptions(precision=5, threshold=64, edgeitems=2)
    params_list = list()
    this_line_length = offset
    line_sep = ',\n' + (1 + offset // 2) * ' '
    for i, (k, v) in enumerate(sorted(six.iteritems(params))):
        if type(v) is float:
            # use str for representing floating point numbers
            # this way we get consistent representation across
            # architectures and versions.
            this_repr = '%s=%s' % (k, str(v))
        else:
            # use repr of the rest
            this_repr = '%s=%s' % (k, printer(v))
        if len(this_repr) > 500:
            this_repr = this_repr[:300] + '...' + this_repr[-100:]
        if i > 0:
            if (this_line_length + len(this_repr) >= 75 or '\n' in this_repr):
                params_list.append(line_sep)
                this_line_length = len(line_sep)
            else:
                params_list.append(', ')
                this_line_length += 2
        params_list.append(this_repr)
        this_line_length += len(this_repr)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_clone\\|clone(\" sklearn/tests/test_base.py | head -40 && sed -n '1,60p' sklearn/tests/test_base.py"
}
```

**tool result**

```
90:def test_clone():
99:    new_selector = clone(selector)
104:    new_selector = clone(selector)
108:def test_clone_2():
118:    new_selector = clone(selector)
122:def test_clone_buggy():
138:def test_clone_empty_array():
141:    clf2 = clone(clf)
145:    clf2 = clone(clf)
149:def test_clone_nan():
152:    clf2 = clone(clf)
157:def test_clone_sparse_matrices():
165:        clf_cloned = clone(clf)
271:def test_clone_pandas_dataframe():
302:    cloned_e = clone(e)
# Author: Gael Varoquaux
# License: BSD 3 clause

import numpy as np
import scipy.sparse as sp

import sklearn
from sklearn.utils.testing import assert_array_equal
from sklearn.utils.testing import assert_true
from sklearn.utils.testing import assert_false
from sklearn.utils.testing import assert_equal
from sklearn.utils.testing import assert_not_equal
from sklearn.utils.testing import assert_raises
from sklearn.utils.testing import assert_no_warnings
from sklearn.utils.testing import assert_warns_message
from sklearn.utils.testing import assert_dict_equal
from sklearn.utils.testing import ignore_warnings

from sklearn.base import BaseEstimator, clone, is_classifier
from sklearn.svm import SVC
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV

from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import DecisionTreeRegressor
from sklearn import datasets

from sklearn.base import TransformerMixin
from sklearn.utils.mocking import MockDataFrame
import pickle


#############################################################################
# A few test classes
class MyEstimator(BaseEstimator):

    def __init__(self, l1=0, empty=None):
        self.l1 = l1
        self.empty = empty


class K(BaseEstimator):
    def __init__(self, c=None, d=None):
        self.c = c
        self.d = d


class T(BaseEstimator):
    def __init__(self, a=None, b=None):
        self.a = a
        self.b = b


class ModifyInitParams(BaseEstimator):
    """Deprecated behavior.
    Equal parameters but with a type cast.
    Doesn't fulfill a is a
    """
    def __init__(self, a=np.array([0])):
        self.a = a.copy()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/base.py\n@@\n-    elif not hasattr(estimator, 'get_params'):\n+    elif not hasattr(estimator, 'get_params') or isinstance(estimator, type):\n*** Update File: sklearn/tests/test_base.py\n@@\n def test_clone():\n     # Tests that clone creates a correct deep copy.\n@@\n     new_selector = clone(selector)\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update sklearn/tests/test_base.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file test_base.py and REWRITE it with *** Add File: test_base.py using its ACTUAL content plus your change

Nothing in this patch was written — not sklearn/base.py, sklearn/tests/test_base.py. Fix it and resend the whole patch.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '88,125p' sklearn/tests/test_base.py"
}
```

**tool result**

```
# The tests

def test_clone():
    # Tests that clone creates a correct deep copy.
    # We create an estimator, make a copy of its original state
    # (which, in this case, is the current state of the estimator),
    # and check that the obtained copy is a correct deep copy.

    from sklearn.feature_selection import SelectFpr, f_classif

    selector = SelectFpr(f_classif, alpha=0.1)
    new_selector = clone(selector)
    assert selector is not new_selector
    assert_equal(selector.get_params(), new_selector.get_params())

    selector = SelectFpr(f_classif, alpha=np.zeros((10, 2)))
    new_selector = clone(selector)
    assert selector is not new_selector


def test_clone_2():
    # Tests that clone doesn't copy everything.
    # We first create an estimator, give it an own attribute, and
    # make a copy of its original state. Then we check that the copy doesn't
    # have the specific attribute we manually added to the initial estimator.

    from sklearn.feature_selection import SelectFpr, f_classif

    selector = SelectFpr(f_classif, alpha=0.1)
    selector.own_attribute = "test"
    new_selector = clone(selector)
    assert_false(hasattr(new_selector, "own_attribute"))


def test_clone_buggy():
    # Check that clone raises an error on buggy estimators.
    buggy = Buggy()
    buggy.a = 2
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/base.py\n@@\n-    elif not hasattr(estimator, 'get_params'):\n+    elif not hasattr(estimator, 'get_params') or isinstance(estimator, type):\n*** Update File: sklearn/tests/test_base.py\n@@\n     selector = SelectFpr(f_classif, alpha=np.zeros((10, 2)))\n     new_selector = clone(selector)\n     assert selector is not new_selector\n \n \n+def test_clone_estimator_class():\n+    # Check that cloning an estimator class does not call get_params on the\n+    # class itself (which would fail as get_params is an instance method).\n+    from sklearn.preprocessing import StandardScaler\n+\n+    scaler = StandardScaler(with_mean=StandardScaler)\n+    cloned = clone(scaler)\n+    assert isinstance(cloned, StandardScaler)\n+    assert cloned.with_mean is StandardScaler\n+\n+\n def test_clone_2():\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/base.py sklearn/tests/test_base.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/base.py now (565 lines), around the change:
48:    # XXX: not handling dictionaries
49:    if estimator_type in (list, tuple, set, frozenset):
50:        return estimator_type([clone(e, safe=safe) for e in estimator])
51:    elif not hasattr(estimator, 'get_params') or isinstance(estimator, type):
52:        if not safe:
53:            return copy.deepcopy(estimator)
54:        else:

sklearn/tests/test_base.py now (455 lines), around the change:
105:    assert selector is not new_selector
106:
107:
108:def test_clone_estimator_class():
109:    # Check that cloning an estimator class does not call get_params on the
110:    # class itself (which would fail as get_params is an instance method).
111:    from sklearn.preprocessing import StandardScaler
112:
113:    scaler = StandardScaler(with_mean=StandardScaler)
114:    cloned = clone(scaler)
115:    assert isinstance(cloned, StandardScaler)
116:    assert cloned.with_mean is StandardScaler
117:
118:
119:def test_clone_2():
120:    # Tests that clone doesn't copy everything.
121:    # We first create an estimator, give it an own attribute, and
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/tests/test_base.py -q 2>&1 | tail -20"
}
```

**tool result**

```
.......................                                                  [100%]
23 passed, 1 warning in 0.55s
```

**assistant → tool `bash`**

```json
{
  "command": "test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\"; echo $?; git diff --stat"
}
```

**tool result**

```
0
 sklearn/base.py            |  2 +-
 sklearn/tests/test_base.py | 11 +++++++++++
 2 files changed, 12 insertions(+), 1 deletion(-)
```

**assistant**

```
Done. `clone` now treats classes as non-estimators even if they expose `get_params` (which is an instance method), falling back to `copy.deepcopy` when `safe=False`:

- `sklearn/base.py`: condition changed to `not hasattr(estimator, 'get_params') or isinstance(estimator, type)`
- `sklearn/tests/test_base.py`: added `test_clone_estimator_class` covering `clone(StandardScaler(with_mean=StandardScaler))`

All 23 tests in `sklearn/tests/test_base.py` pass, and the completion command exits 0.
```

## Run folder `single-2026-11-06T132405`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
clone fails for parameters that are estimator types
#### Description

`clone` fails when one or more instance parameters are estimator types (i.e. not instances, but classes). 

I know this is a somewhat unusual use case, but I'm working on a project that provides wrappers for sklearn estimators (https://github.com/phausamann/sklearn-xarray) and I'd like to store the wrapped estimators as their classes - not their instances - as a parameter inside of a wrapper that behaves like an estimator itself. 

#### Steps/Code to Reproduce

    from sklearn.preprocessing import StandardScaler
    from sklearn.base import clone
    clone(StandardScaler(with_mean=StandardScaler))

#### Expected Results

No error.

#### Actual Results
```
Traceback (most recent call last):
...
  File "...\lib\site-packages\sklearn\base.py", line 62, in clone
    new_object_params[name] = clone(param, safe=False)
  File "...\lib\site-packages\sklearn\base.py", line 60, in clone
    new_object_params = estimator.get_params(deep=False)
TypeError: get_params() missing 1 required positional argument: 'self'
```

#### Possible fix

Change `base.py`, line 51 to: 

    elif not hasattr(estimator, 'get_params') or isinstance(estimator, type):

I'm not sure whether this might break stuff in other places, however. I'd happily submit a PR if this change is desired.

#### Versions

    sklearn: 0.20.0
````
