# scikit-learn__scikit-learn-13439 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 78s 37 lines cost=0.002152 in=65149 cached=35840 out=3409 calls=9`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

Pipeline should implement __len__
#### Description

With the new indexing support `pipe[:len(pipe)]` raises an error.

#### Steps/Code to Reproduce

```python
from sklearn import svm
from sklearn.datasets import samples_generator
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression
from sklearn.pipeline import Pipeline

# generate some data to play with
X, y = samples_generator.make_classification(
    n_informative=5, n_redundant=0, random_state=42)

anova_filter = SelectKBest(f_regression, k=5)
clf = svm.SVC(kernel='linear')
pipe = Pipeline([('anova', anova_filter), ('svc', clf)])

len(pipe)
```

#### Versions

```
System:
    python: 3.6.7 | packaged by conda-forge | (default, Feb 19 2019, 18:37:23)  [GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]
executable: /Users/krisz/.conda/envs/arrow36/bin/python
   machine: Darwin-18.2.0-x86_64-i386-64bit

BLAS:
    macros: HAVE_CBLAS=None
  lib_dirs: /Users/krisz/.conda/envs/arrow36/lib
cblas_libs: openblas, openblas

Python deps:
       pip: 19.0.3
setuptools: 40.8.0
   sklearn: 0.21.dev0
     numpy: 1.16.2
     scipy: 1.2.1
    Cython: 0.29.6
    pandas: 0.24.1
```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && grep -n \"__getitem__\\|def __len__\\|class Pipeline\" sklearn/pipeline.py | head -50"
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
azure-pipelines.yml
benchmarks
build
build_tools
conftest.py
doc
examples
lgtm.yml
maint_tools
scikit_learn.egg-info
setup.cfg
setup.py
site.cfg
sklearn
29:class Pipeline(_BaseComposition):
202:    def __getitem__(self, ind):
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/pipeline.py",
  "offset": 190,
  "limit": 130
}
```

**tool result**

```
    def _iter(self, with_final=True):
        """
        Generate (name, trans) tuples excluding 'passthrough' transformers
        """
        stop = len(self.steps)
        if not with_final:
            stop -= 1

        for idx, (name, trans) in enumerate(islice(self.steps, 0, stop)):
            if trans is not None and trans != 'passthrough':
                yield idx, name, trans

    def __getitem__(self, ind):
        """Returns a sub-pipeline or a single esimtator in the pipeline

        Indexing with an integer will return an estimator; using a slice
        returns another Pipeline instance which copies a slice of this
        Pipeline. This copy is shallow: modifying (or fitting) estimators in
        the sub-pipeline will affect the larger pipeline and vice-versa.
        However, replacing a value in `step` will not affect a copy.
        """
        if isinstance(ind, slice):
            if ind.step not in (1, None):
                raise ValueError('Pipeline slicing only supports a step of 1')
            return self.__class__(self.steps[ind])
        try:
            name, est = self.steps[ind]
        except TypeError:
            # Not an int, try get step by name
            return self.named_steps[ind]
        return est

    @property
    def _estimator_type(self):
        return self.steps[-1][1]._estimator_type

    @property
    def named_steps(self):
        # Use Bunch object to improve autocomplete
        return Bunch(**dict(self.steps))

    @property
    def _final_estimator(self):
        estimator = self.steps[-1][1]
        return 'passthrough' if estimator is None else estimator

    # Estimator interface

    def _fit(self, X, y=None, **fit_params):
        # shallow copy of steps - this should really be steps_
        self.steps = list(self.steps)
        self._validate_steps()
        # Setup the memory
        memory = check_memory(self.memory)

        fit_transform_one_cached = memory.cache(_fit_transform_one)

        fit_params_steps = {name: {} for name, step in self.steps
                            if step is not None}
        for pname, pval in fit_params.items():
            step, param = pname.split('__', 1)
            fit_params_steps[step][param] = pval
        Xt = X
        for step_idx, name, transformer in self._iter(with_final=False):
            if hasattr(memory, 'location'):
                # joblib >= 0.12
                if memory.location is None:
                    # we do not clone when caching is disabled to
                    # preserve backward compatibility
                    cloned_transformer = transformer
                else:
                    cloned_transformer = clone(transformer)
            elif hasattr(memory, 'cachedir'):
                # joblib < 0.11
                if memory.cachedir is None:
                    # we do not clone when caching is disabled to
                    # preserve backward compatibility
                    cloned_transformer = transformer
                else:
                    cloned_transformer = clone(transformer)
            else:
                cloned_transformer = clone(transformer)
            # Fit or load from cache the current transfomer
            Xt, fitted_transformer = fit_transform_one_cached(
                cloned_transformer, Xt, y, None,
                **fit_params_steps[name])
            # Replace the transformer of the step with the fitted
            # transformer. This is necessary when loading the transformer
            # from the cache.
            self.steps[step_idx] = (name, fitted_transformer)
        if self._final_estimator == 'passthrough':
            return Xt, {}
        return Xt, fit_params_steps[self.steps[-1][0]]

    def fit(self, X, y=None, **fit_params):
        """Fit the model

        Fit all the transforms one after the other and transform the
        data, then fit the transformed data using the final estimator.

        Parameters
        ----------
        X : iterable
            Training data. Must fulfill input requirements of first step of the
            pipeline.

        y : iterable, default=None
            Training targets. Must fulfill label requirements for all steps of
            the pipeline.

        **fit_params : dict of string -> object
            Parameters passed to the ``fit`` method of each step, where
            each parameter name is prefixed such that parameter ``p`` for step
            ``s`` has key ``s__p``.

        Returns
        -------
        self : Pipeline
            This estimator
        """
        Xt, fit_params = self._fit(X, y, **fit_params)
        if self._final_estimator != 'passthrough':
            self._final_estimator.fit(Xt, y, **fit_params)
        return self

    def fit_transform(self, X, y=None, **fit_params):
        """Fit the model and transform with the final estimator

        Fits all the transforms one after the other and transforms the
        data, then uses fit_transform on transformed data with the final

[612 more lines in /testbed/sklearn/pipeline.py (931 in all). read_file with offset: 320 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_pipeline\\|__getitem__\\|slice\\|len(pipe\\|len(pipeline\" sklearn/tests/test_pipeline.py | head -40"
}
```

**tool result**

```
157:def test_pipeline_init():
224:def test_pipeline_init_tuple():
238:def test_pipeline_methods_anova():
254:def test_pipeline_fit_params():
271:def test_pipeline_sample_weight_supported():
282:def test_pipeline_sample_weight_unsupported():
296:def test_pipeline_raise_set_params_error():
317:def test_pipeline_methods_pca_svm():
333:def test_pipeline_methods_preprocessing_svm():
498:def test_pipeline_transform():
518:def test_pipeline_fit_transform():
532:def test_pipeline_slice():
539:    assert 2 == len(pipe2.named_steps)
543:def test_pipeline_index():
581:def test_pipeline_named_steps():
599:def test_pipeline_correctly_adjusts_steps(passthrough):
690:def test_pipeline_ducktyping():
958:def test_pipeline_wrong_memory():
982:def test_pipeline_with_cache_attribute():
995:def test_pipeline_memory():
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/tests/test_pipeline.py",
  "offset": 525,
  "limit": 60
}
```

**tool result**

```

    # test fit_transform:
    X_trans = pipeline.fit_transform(X, y)
    X_trans2 = transf.fit(X, y).transform(X)
    assert_array_almost_equal(X_trans, X_trans2)


def test_pipeline_slice():
    pipe = Pipeline([('transf1', Transf()),
                     ('transf2', Transf()),
                     ('clf', FitParamT())])
    pipe2 = pipe[:-1]
    assert isinstance(pipe2, Pipeline)
    assert pipe2.steps == pipe.steps[:-1]
    assert 2 == len(pipe2.named_steps)
    assert_raises(ValueError, lambda: pipe[::-1])


def test_pipeline_index():
    transf = Transf()
    clf = FitParamT()
    pipe = Pipeline([('transf', transf), ('clf', clf)])
    assert pipe[0] == transf
    assert pipe['transf'] == transf
    assert pipe[-1] == clf
    assert pipe['clf'] == clf
    assert_raises(IndexError, lambda: pipe[3])
    assert_raises(KeyError, lambda: pipe['foobar'])


def test_set_pipeline_steps():
    transf1 = Transf()
    transf2 = Transf()
    pipeline = Pipeline([('mock', transf1)])
    assert pipeline.named_steps['mock'] is transf1

    # Directly setting attr
    pipeline.steps = [('mock2', transf2)]
    assert 'mock' not in pipeline.named_steps
    assert pipeline.named_steps['mock2'] is transf2
    assert_equal([('mock2', transf2)], pipeline.steps)

    # Using set_params
    pipeline.set_params(steps=[('mock', transf1)])
    assert_equal([('mock', transf1)], pipeline.steps)

    # Using set_params to replace single step
    pipeline.set_params(mock=transf2)
    assert_equal([('mock', transf2)], pipeline.steps)

    # With invalid data
    pipeline.set_params(steps=[('junk', ())])
    assert_raises(TypeError, pipeline.fit, [[1]], [1])
    assert_raises(TypeError, pipeline.fit_transform, [[1]], [1])


def test_pipeline_named_steps():
    transf = Transf()
    mult2 = Mult(mult=2)
    pipeline = Pipeline([('mock', transf), ("mult", mult2)])

[489 more lines in /testbed/sklearn/tests/test_pipeline.py (1073 in all). read_file with offset: 585 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/pipeline.py\n@@\n     def __getitem__(self, ind):\n         \"\"\"Returns a sub-pipeline or a single esimtator in the pipeline\n@@\n         except TypeError:\n             # Not an int, try get step by name\n             return self.named_steps[ind]\n         return est\n+\n+    def __len__(self):\n+        \"\"\"Returns the length of the pipeline\n+        \"\"\"\n+        return len(self.steps)\n \n     @property\n     def _estimator_type(self):\n*** Update File: sklearn/tests/test_pipeline.py\n@@\n def test_pipeline_slice():\n     pipe = Pipeline([('transf1', Transf()),\n                      ('transf2', Transf()),\n                      ('clf', FitParamT())])\n     pipe2 = pipe[:-1]\n     assert isinstance(pipe2, Pipeline)\n     assert pipe2.steps == pipe.steps[:-1]\n     assert 2 == len(pipe2.named_steps)\n+    pipe3 = pipe[:len(pipe)]\n+    assert pipe3.steps == pipe.steps\n     assert_raises(ValueError, lambda: pipe[::-1])\n \n \n def test_pipeline_index():\n@@\n     assert pipe['clf'] == clf\n     assert_raises(IndexError, lambda: pipe[3])\n     assert_raises(KeyError, lambda: pipe['foobar'])\n+    assert len(pipe) == 2\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/pipeline.py sklearn/tests/test_pipeline.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/pipeline.py now (936 lines), around the change:
219:            return self.named_steps[ind]
220:        return est
221:
222:    def __len__(self):
223:        """Returns the length of the pipeline
224:        """
225:        return len(self.steps)
226:
227:    @property
228:    def _estimator_type(self):
229:        return self.steps[-1][1]._estimator_type

sklearn/tests/test_pipeline.py now (1076 lines), around the change:
537:    assert isinstance(pipe2, Pipeline)
538:    assert pipe2.steps == pipe.steps[:-1]
539:    assert 2 == len(pipe2.named_steps)
540:    pipe3 = pipe[:len(pipe)]
541:    assert pipe3.steps == pipe.steps
542:    assert_raises(ValueError, lambda: pipe[::-1])
543:
544:
…
552:    assert pipe['clf'] == clf
553:    assert_raises(IndexError, lambda: pipe[3])
554:    assert_raises(KeyError, lambda: pipe['foobar'])
555:    assert len(pipe) == 2
556:
557:
558:def test_set_pipeline_steps():
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/tests/test_pipeline.py -q 2>&1 | tail -15"
}
```

**tool result**

```
.........................................                                [100%]
41 passed, 2 warnings in 15.41s
```

**assistant**

```
Implemented `Pipeline.__len__` and added test coverage.

- `sklearn/pipeline.py`: `__len__` returns `len(self.steps)`, so `pipe[:len(pipe)]` now works.
- `sklearn/tests/test_pipeline.py`: added assertions for `len(pipe)` and slicing with `pipe[:len(pipe)]`.

Verification: `python -m pytest sklearn/tests/test_pipeline.py -q` → **41 passed**. No commits or tree changes beyond the task edits.
```

## Run folder `team-solve-2026-11-06T131501`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
d74b6a76ebf523d73ab5bda9b5c14b09f3cd6fab
```

### `baseline-check.log`

```
check: pytest sklearn/tests/test_pipeline.py -q

==================================== ERRORS ====================================
_______________ ERROR collecting sklearn/tests/test_pipeline.py ________________
sklearn/__check_build/__init__.py:44: in <module>
    from ._check_build import check_build  # noqa
E   ModuleNotFoundError: No module named 'sklearn.__check_build._check_build'

During handling of the above exception, another exception occurred:
/opt/miniconda3/envs/testbed/lib/python3.6/importlib/__init__.py:126: in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
<frozen importlib._bootstrap>:994: in _gcd_import
    ???
<frozen importlib._bootstrap>:971: in _find_and_load
    ???
<frozen importlib._bootstrap>:941: in _find_and_load_unlocked
    ???
<frozen importlib._bootstrap>:219: in _call_with_frames_removed
    ???
<frozen importlib._bootstrap>:994: in _gcd_import
    ???
<frozen importlib._bootstrap>:971: in _find_and_load
    ???
<frozen importlib._bootstrap>:941: in _find_and_load_unlocked
    ???
<frozen importlib._bootstrap>:219: in _call_with_frames_removed
    ???
<frozen importlib._bootstrap>:994: in _gcd_import
    ???
<frozen importlib._bootstrap>:971: in _find_and_load
    ???
<frozen importlib._bootstrap>:955: in _find_and_load_unlocked
    ???
<frozen importlib._bootstrap>:665: in _load_unlocked
    ???
<frozen importlib._bootstrap_external>:678: in exec_module
    ???
<frozen importlib._bootstrap>:219: in _call_with_frames_removed
    ???
sklearn/__init__.py:75: in <module>
    from . import __check_build
sklearn/__check_build/__init__.py:46: in <module>
    raise_build_error(e)
sklearn/__check_build/__init__.py:41: in raise_build_error
    %s""" % (e, local_dir, ''.join(dir_content).strip(), msg))
E   ImportError: No module named 'sklearn.__check_build._check_build'
E   ___________________________________________________________________________
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T131501/baseline-tree/sklearn/__check_build:
E   __init__.py               __pycache__               setup.py
E   _check_build.pyx
E   ___________________________________________________________________________
E   It seems that scikit-learn has not been built correctly.
E   
E   If you have installed scikit-learn from source, please do not forget
E   to build the package before using it: run `python setup.py install` or
E   `make` in the source directory.
E   
E   If you have used an installer, please check that it is suited for your
E   Python version, your operating system and your platform.
_______________ ERROR collecting sklearn/tests/test_pipeline.py ________________
ImportError while importing test module '/testbed/.memdoor/runs/team-solve-2026-11-06T131501/baseline-tree/sklearn/tests/test_pipeline.py'.
Hint: make sure your test modules/packages have valid Python names.
Traceback:
sklearn/__check_build/__init__.py:44: in <module>
    from ._check_build import check_build  # noqa
E   ModuleNotFoundError: No module named 'sklearn.__check_build._check_build'

During handling of the above exception, another exception occurred:
/opt/miniconda3/envs/testbed/lib/python3.6/importlib/__init__.py:126: in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
sklearn/__init__.py:75: in <module>
    from . import __check_build
sklearn/__check_build/__init__.py:46: in <module>
    raise_build_error(e)
sklearn/__check_build/__init__.py:41: in raise_build_error
    %s""" % (e, local_dir, ''.join(dir_content).strip(), msg))
E   ImportError: No module named 'sklearn.__check_build._check_build'
E   ___________________________________________________________________________
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T131501/baseline-tree/sklearn/__check_build:
E   __init__.py               __pycache__               setup.py
E   _check_build.pyx
E   ___________________________________________________________________________
E   It seems that scikit-learn has not been built correctly.
E   
E   If you have installed scikit-learn from source, please do not forget
E   to build the package before using it: run `python setup.py install` or
E   `make` in the source directory.
E   
E   If you have used an installer, please check that it is suited for your
E   Python version, your operating system and your platform.
!!!!!!!!!!!!!!!!!!! Interrupted: 2 errors during collection !!!!!!!!!!!!!!!!!!!!
2 errors in 1.19s
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/sklearn/pipeline.py b/sklearn/pipeline.py
index 7eaf9a46f..dfe70a8cc 100755
--- a/sklearn/pipeline.py
+++ b/sklearn/pipeline.py
@@ -219,6 +219,11 @@ class Pipeline(_BaseComposition):
             return self.named_steps[ind]
         return est
 
+    def __len__(self):
+        """Returns the length of the pipeline
+        """
+        return len(self.steps)
+
     @property
     def _estimator_type(self):
         return self.steps[-1][1]._estimator_type
diff --git a/sklearn/tests/test_pipeline.py b/sklearn/tests/test_pipeline.py
index 8d6fe8f70..0fb5b6840 100755
--- a/sklearn/tests/test_pipeline.py
+++ b/sklearn/tests/test_pipeline.py
@@ -537,6 +537,8 @@ def test_pipeline_slice():
     assert isinstance(pipe2, Pipeline)
     assert pipe2.steps == pipe.steps[:-1]
     assert 2 == len(pipe2.named_steps)
+    pipe3 = pipe[:len(pipe)]
+    assert pipe3.steps == pipe.steps
     assert_raises(ValueError, lambda: pipe[::-1])
 
 
@@ -550,6 +552,7 @@ def test_pipeline_index():
     assert pipe['clf'] == clf
     assert_raises(IndexError, lambda: pipe[3])
     assert_raises(KeyError, lambda: pipe['foobar'])
+    assert len(pipe) == 2
 
 
 def test_set_pipeline_steps():
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

Pipeline should implement __len__
#### Description

With the new indexing support `pipe[:len(pipe)]` raises an error.

#### Steps/Code to Reproduce

```python
from sklearn import svm
from sklearn.datasets import samples_generator
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression
from sklearn.pipeline import Pipeline

# generate some data to play with
X, y = samples_generator.make_classification(
    n_informative=5, n_redundant=0, random_state=42)

anova_filter = SelectKBest(f_regression, k=5)
clf = svm.SVC(kernel='linear')
pipe = Pipeline([('anova', anova_filter), ('svc', clf)])

len(pipe)
```

#### Versions

```
System:
    python: 3.6.7 | packaged by conda-forge | (default, Feb 19 2019, 18:37:23)  [GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]
executable: /Users/krisz/.conda/envs/arrow36/bin/python
   machine: Darwin-18.2.0-x86_64-i386-64bit

BLAS:
    macros: HAVE_CBLAS=None
  lib_dirs: /Users/krisz/.conda/envs/arrow36/lib
cblas_libs: openblas, openblas

Python deps:
       pip: 19.0.3
setuptools: 40.8.0
   sklearn: 0.21.dev0
     numpy: 1.16.2
     scipy: 1.2.1
    Cython: 0.29.6
    pandas: 0.24.1
```

## Deliverable

changes to this tree

## Check

`pytest sklearn/tests/test_pipeline.py -q`

## Scope

`sklearn/pipeline.py`
`sklearn/tests/`

## Done when

- `len(pipe)` returns the number of steps in the `Pipeline`.
- `pipe[:len(pipe)]` no longer raises and returns a `Pipeline` containing all the original steps.
- Existing `Pipeline` indexing/slicing behavior continues to work.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest sklearn/tests/test_pipeline.py -q`

## Scope
`sklearn/pipeline.py`
`sklearn/tests/`

## Done when
- `len(pipe)` returns the number of steps in the `Pipeline`.
- `pipe[:len(pipe)]` no longer raises and returns a `Pipeline` containing all the original steps.
- Existing `Pipeline` indexing/slicing behavior continues to work.

## Approach
Add `__len__` to `Pipeline` returning `len(self.steps)`, which is the list of `(name, estimator)` pairs, so the existing `__getitem__`/slice logic and `pipe[:len(pipe)]` work unchanged.

Candidate approaches:
1. Minimal: define `__len__` only on `Pipeline`; smallest diff, matches the issue literally.
2. Upstream-style: define `__len__` on both `Pipeline` and `FeatureUnion` in `sklearn/pipeline.py` (returning `len(self.steps)` and `len(self.transformer_list)` respectively); slightly larger but consistent and likely what the tests exercise.
3. Broad: define `__len__` on `_BaseComposition` in `sklearn/base.py`; covers both subclasses automatically but changes shared base-class behavior beyond the prompt.

If the first attempt fails, verify the test expects the length of `steps` (and possibly `transformer_list` for `FeatureUnion`), and check that slicing still uses the same step sequence.


# sklearn/pipeline.py

```
"""
The :mod:`sklearn.pipeline` module implements utilities to build a composite
estimator, as a chain of transforms and estimators.
"""
# Author: Edouard Duchesnay
#         Gael Varoquaux
#         Virgile Fritsch
#         Alexandre Gramfort
#         Lars Buitinck
# License: BSD

from collections import defaultdict
from itertools import islice

import numpy as np
from scipy import sparse

from .base import clone, TransformerMixin
from .utils._joblib import Parallel, delayed
from .utils.metaestimators import if_delegate_has_method
from .utils import Bunch
from .utils.validation import check_memory

from .utils.metaestimators import _BaseComposition

__all__ = ['Pipeline', 'FeatureUnion', 'make_pipeline', 'make_union']


class Pipeline(_BaseComposition):
    """Pipeline of transforms with a final estimator.

    Sequentially apply a list of transforms and a final estimator.
    Intermediate steps of the pipeline must be 'transforms', that is, they
    must implement fit and transform methods.
    The final estimator only needs to implement fit.
    The transformers in the pipeline can be cached using ``memory`` argument.

    The purpose of the pipeline is to assemble several steps that can be
    cross-validated together while setting different parameters.
    For this, it enables setting parameters of the various steps using their
    names and the parameter name separated by a '__', as in the example below.
    A step's estimator may be replaced entirely by setting the parameter
    with its name to another estimator, or a transformer removed by setting
    it to 'passthrough' or ``None``.

    Read more in the :ref:`User Guide <pipeline>`.

    Parameters
    ----------
    steps : list
        List of (name, transform) tuples (implementing fit/transform) that are
        chained, in the order in which they are chained, with the last object
        an estimator.

    memory : None, str or object with the joblib.Memory interface, optional
        Used to cache the fitted transformers of the pipeline. By default,
        no caching is performed. If a string is given, it is the path to
        the caching directory. Enabling caching triggers a clone of
        the transformers before fitting. Therefore, the transformer
        instance given to the pipeline cannot be inspected
        directly. Use the attribute ``named_steps`` or ``steps`` to
        inspect estimators within the pipeline. Caching the
        transformers is advantageous when fitting is time consuming.

    Attributes
    ----------
    named_steps : bunch object, a dictionary with attribute access
        Read-only attribute to access any step parameter by user given name.
        Keys are step names and values are steps parameters.

    See also
    --------
    sklearn.pipeline.make_pipeline : convenience function for simplified
        pipeline construction.

    Examples
    --------
    >>> from sklearn import svm
    >>> from sklearn.datasets import samples_generator
    >>> from sklearn.feature_selection import SelectKBest
    >>> from sklearn.feature_selection import f_regression
    >>> from sklearn.pipeline import Pipeline
    >>> # generate some data to play with
    >>> X, y = samples_generator.make_classification(
    ...     n_informative=5, n_redundant=0, random_state=42)
    >>> # ANOVA SVM-C
    >>> anova_filter = SelectKBest(f_regression, k=5)
    >>> clf = svm.SVC(kernel='linear')
    >>> anova_svm = Pipeline([('anova', anova_filter), ('svc', clf)])
    >>> # You can set the parameters using the names issued
    >>> # For instance, fit using a k of 10 in the SelectKBest
    >>> # and a parameter 'C' of the svm
    >>> anova_svm.set_params(anova__k=10, svc__C=.1).fit(X, y)
    ...                      # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
    Pipeline(memory=None,
             steps=[('anova', SelectKBest(...)),
                    ('svc', SVC(...))])
    >>> prediction = anova_svm.predict(X)
    >>> anova_svm.score(X, y)                        # doctest: +ELLIPSIS
    0.83
    >>> # getting the selected features chosen by anova_filter
    >>> anova_svm['anova'].get_support()
    ... # doctest: +NORMALIZE_WHITESPACE
    array([False, False,  True,  True, False, False,  True,  True, False,
           True, False,  True,  True, False,  True, False,  True,  True,
           False, False])
    >>> # Another way to get selected features chosen by anova_filter
    >>> anova_svm.named_steps.anova.get_support()
    ... # doctest: +NORMALIZE_WHITESPACE
    array([False, False,  True,  True, False, False,  True,  True, False,
           True, False,  True,  True, False,  True, False,  True,  True,
           False, False])
    >>> # Indexing can also be used to extract a sub-pipeline.
    >>> sub_pipeline = anova_svm[:1]
    >>> sub_pipeline  # doctest: +ELLIPSIS +NORMALIZE_WHITESPACE
    Pipeline(memory=None, steps=[('anova', ...)])
    >>> coef = anova_svm[-1].coef_
    >>> anova_svm['svc'] is anova_svm[-1]
    True
    >>> coef.shape
    (1, 10)
    >>> sub_pipeline.inverse_transform(coef).shape
    (1, 20)
    """

    # BaseEstimator interface
    _required_parameters = ['steps']

    def __init__(self, steps, memory=None):
        self.steps = steps
        self._validate_steps()
        self.memory = memory

    def get_params(self, deep=True):
        """Get parameters for this estimator.

        Parameters
        ----------
        deep : boolean, optional
            If True, will return the parameters for this estimator and
            contained subobjects that are estimators.

        Returns
        -------
        params : mapping of string to any
            Parameter names mapped to their values.
        """
        return self._get_params('steps', deep=deep)

    def set_params(self, **kwargs):
        """Set the parameters of this estimator.

        Valid parameter keys can be listed with ``get_params()``.

        Returns
        -------
        self
        """
        self._set_params('steps', **kwargs)
        return self

    def _validate_steps(self):
        names, estimators = zip(*self.steps)

        # validate names
        self._validate_names(names)

        # validate estimators
        transformers = estimators[:-1]
        estimator = estimators[-1]

        for t in transformers:
            if t is None or t == 'passthrough':
                continue
            if (not (hasattr(t, "fit") or hasattr(t, "fit_transform")) or not
                    hasattr(t, "transform")):
                raise TypeError("All intermediate steps should be "
                                "transformers and implement fit and transform "
                                "or be the string 'passthrough' "
                                "'%s' (type %s) doesn't" % (t, type(t)))

        # We allow last estimator to be None as an identity transformation
        if (estimator is not None and estimator != 'passthrough'
                and not hasattr(estimator, "fit")):
            raise TypeError(
                "Last step of Pipeline should implement fit "
                "or be the string 'passthrough'. "
                "'%s' (type %s) doesn't" % (estimator, type(estimator)))

    def _iter(self, with_final=True):
        """
        Generate (name, trans) tuples excluding 'passthrough' transformers
        """
        stop = len(self.steps)
        if not with_final:
            stop -= 1

        for idx, (name, trans) in enumerate(islice(self.steps, 0, stop)):
            if trans is not None and trans != 'passthrough':
                yield idx, name, trans

    def __getitem__(self, ind):
        """Returns a sub-pipeline or a single esimtator in the pipeline

        Indexing with an integer will return an estimator; using a slice
        returns another Pipeline instance which copies a slice of this
        Pipeline. This copy is shallow: modifying (or fitting) estimators in
        the sub-pipeline will affect the larger pipeline and vice-versa.
        However, replacing a value in `step` will not affect a copy.
        """
        if isinstance(ind, slice):
            if ind.step not in (1, None):
                raise ValueError('Pipeline slicing only supports a step of 1')
            return self.__class__(self.steps[ind])
        try:
            name, est = self.steps[ind]
        except TypeError:
            # Not an int, try get step by name
            return self.named_steps[ind]
        return est

    def __len__(self):
        """Returns the length of the pipeline
        """
        return len(self.steps)

    @property
    def _estimator_type(self):
        return self.steps[-1][1]._estimator_type

    @property
    def named_steps(self):
        # Use Bunch object to improve autocomplete
        return Bunch(**dict(self.steps))

    @property
    def _final_estimator(self):
        estimator = self.steps[-1][1]
        return 'passthrough' if estimator is None else estimator

    # Estimator interface

    def _fit(self, X, y=None, **fit_params):
        # shallow copy of steps - this should really be steps_
        self.steps = list(self.steps)
        self._validate_steps()
        # Setup the memory
        memory = check_memory(self.memory)

        fit_transform_one_cached = memory.cache(_fit_transform_one)

        fit_params_steps = {name: {} for name, step in self.steps
                            if step is not None}
        for pname, pval in fit_params.items():
            step, param = pname.split('__', 1)
            fit_params_steps[step][param] = pval
        Xt = X
        for step_idx, name, transformer in self._iter(with_final=False):
            if hasattr(memory, 'location'):
                # joblib >= 0.12
                if memory.location is None:
                    # we do not clone when caching is disabled to
                    # preserve backward compatibility
                    cloned_transformer = transformer
                else:
                    cloned_transformer = clone(transformer)
            elif hasattr(memory, 'cachedir'):
                # joblib < 0.11
                if memory.cachedir is None:
                    # we do not clone when caching is disabled to
                    # preserve backward compatibility
                    cloned_transformer = transformer
                else:
                    cloned_transformer = clone(transformer)
            else:
                cloned_transformer = clone(transformer)
            # Fit or load from cache the current transfomer
            Xt, fitted_transformer = fit_transform_one_cached(
                cloned_transformer, Xt, y, None,
                **fit_params_steps[name])
            # Replace the transformer of the step with the fitted
            # transformer. This is necessary when loading the transformer
            # from the cache.
            self.steps[step_idx] = (name, fitted_transformer)
        if self._final_estimator == 'passthrough':
            return Xt, {}
        return Xt, fit_params_steps[self.steps[-1][0]]

    def fit(self, X, y=None, **fit_params):
        """Fit the model

        Fit all the transforms one after the other and transform the
        data, then fit the transformed data using the final estimator.

        Parameters
        ----------
        X : iterable
            Training data. Must fulfill input requirements of first step of the
            pipeline.

        y : iterable, default=None
            Training targets. Must fulfill label requirements for all steps of
            the pipeline.

        **fit_params : dict of string -> object
            Parameters passed to the ``fit`` method of each step, where
            each parameter name is prefixed such that parameter ``p`` for step
            ``s`` has key ``s__p``.

        Returns
        -------
        self : Pipeline
            This estimator
        """
        Xt, fit_params = self._fit(X, y, **fit_params)
        if self._final_estimator != 'passthrough':
            self._final_estimator.fit(Xt, y, **fit_params)
        return self

    def fit_transform(self, X, y=None, **fit_params):
        """Fit the model and transform with the final estimator

        Fits all the transforms one after the other and transforms the
        data, then uses fit_transform on transformed data with the final
        estimator.

        Parameters
        ----------
        X : iterable
            Training data. Must fulfill input requirements of first step of the
            pipeline.

        y : iterable, default=None
            Training targets. Must fulfill label requirements for all steps of
            the pipeline.

        **fit_params : dict of string -> object
            Parameters passed to the ``fit`` method of each step, where
            each parameter name is prefixed such that parameter ``p`` for step
            ``s`` has key ``s__p``.

        Returns
        -------
        Xt : array-like, shape = [n_samples, n_transformed_features]
            Transformed samples
        """
        last_step = self._final_estimator
        Xt, fit_params = self._fit(X, y, **fit_params)
        if hasattr(last_step, 'fit_transform'):
            return last_step.fit_transform(Xt, y, **fit_params)
        elif last_step == 'passthrough':
            return Xt
        else:
            return last_step.fit(Xt, y, **fit_params).transform(Xt)

    @if_delegate_has_method(delegate='_final_estimator')
    def predict(self, X, **predict_params):
        """Apply transforms to the data, and predict with the final estimator

        Parameters
        ----------
        X : iterable
            Data to predict on. Must fulfill input requirements of first step
            of the pipeline.

        **predict_params : dict of string -> object
            Parameters to the ``predict`` called at the end of all
            transformations in the pipeline. Note that while this may be
            used to return uncertainties from some models with return_std
            or return_cov, uncertainties that are generated by the
            transformations in the pipeline are not propagated to the
            final estimator.

        Returns
        -------
        y_pred : array-like
        """
        Xt = X
        for _, name, transform in self._iter(with_final=False):
            Xt = transform.transform(Xt)
        return self.steps[-1][-1].predict(Xt, **predict_params)

    @if_delegate_has_method(delegate='_final_estimator')
    def fit_predict(self, X, y=None, **fit_params):
        """Applies fit_predict of last step in pipeline after transforms.

        Applies fit_transforms of a pipeline to the data, followed by the
        fit_predict method of the final estimator in the pipeline. Valid
        only if the final estimator implements fit_predict.

        Parameters
        ----------
        X : iterable
            Training data. Must fulfill input requirements of first step of
            the pipeline.

        y : iterable, default=None
            Training targets. Must fulfill label requirements for all steps
            of the pipeline.

        **fit_params : dict of string -> object
            Parameters passed to the ``fit`` method of each step, where
            each parameter name is prefixed such that parameter ``p`` for step
            ``s`` has key ``s__p``.

        Returns
        -------
        y_pred : array-like
        """
        Xt, fit_params = self._fit(X, y, **fit_params)
        return self.steps[-1][-1].fit_predict(Xt, y, **fit_params)

    @if_delegate_has_method(delegate='_final_estimator')
    def predict_proba(self, X):
        """Apply transforms, and predict_proba of the final estimator

        Parameters
        ----------
        X : iterable
            Data to predict on. Must fulfill input requirements of first step
            of the pipeline.

        Returns
        -------
        y_proba : array-like, shape = [n_samples, n_classes]
        """
        Xt = X
        for _, name, transform in self._iter(with_final=False):
            Xt = transform.transform(Xt)
        return self.steps[-1][-1].predict_proba(Xt)

    @if_delegate_has_method(delegate='_final_estimator')
    def decision_function(self, X):
        """Apply transforms, and decision_function of the final estimator

        Parameters
        ----------
        X : iterable
            Data to predict on. Must fulfill input requirements of first step
            of the pipeline.

        Returns
        -------
        y_score : array-like, shape = [n_samples, n_classes]
        """
        Xt = X
        for _, name, transform in self._iter(with_final=False):
            Xt = transform.transform(Xt)
        return self.steps[-1][-1].decision_function(Xt)

    @if_delegate_has_method(delegate='_final_estimator')
    def predict_log_proba(self, X):
        """Apply transforms, and predict_log_proba of the final estimator

        Parameters
        ----------
        X : iterable
            Data to predict on. Must fulfill input requirements of first step
            of the pipeline.

        Returns
        -------
        y_score : array-like, shape = [n_samples, n_classes]
        """
        Xt = X
        for _, name, transform in self._iter(with_final=False):
            Xt = transform.transform(Xt)
        return self.steps[-1][-1].predict_log_proba(Xt)

    @property
    def transform(self):
        """Apply transforms, and transform with the final estimator

        This also works where final estimator is ``None``: all prior
        transformations are applied.

        Parameters
        ----------
        X : iterable
            Data to transform. Must fulfill input requirements of first step
            of the pipeline.

        Returns
        -------
        Xt : array-like, shape = [n_samples, n_transformed_features]
        """
        # _final_estimator is None or has transform, otherwise attribute error
        # XXX: Handling the None case means we can't use if_delegate_has_method
        if self._final_estimator != 'passthrough':
            self._final_estimator.transform
        return self._transform

    def _transform(self, X):
        Xt = X
        for _, _, transform in self._iter():
            Xt = transform.transform(Xt)
        return Xt

    @property
    def inverse_transform(self):
        """Apply inverse transformations in reverse order

        All estimators in the pipeline must support ``inverse_transform``.

        Parameters
        ----------
        Xt : array-like, shape = [n_samples, n_transformed_features]
            Data samples, where ``n_samples`` is the number of samples and
            ``n_features`` is the number of features. Must fulfill
            input requirements of last step of pipeline's
            ``inverse_transform`` method.

        Returns
        -------
        Xt : array-like, shape = [n_samples, n_features]
        """
        # raise AttributeError if necessary for hasattr behaviour
        # XXX: Handling the None case means we can't use if_delegate_has_method
        for _, _, transform in self._iter():
            transform.inverse_transform
        return self._inverse_transform

    def _inverse_transform(self, X):
        Xt = X
        reverse_iter = reversed(list(self._iter()))
        for _, _, transform in reverse_iter:
            Xt = transform.inverse_transform(Xt)
        return Xt

    @if_delegate_has_method(delegate='_final_estimator')
    def score(self, X, y=None, sample_weight=None):
        """Apply transforms, and score with the final estimator

        Parameters
        ----------
        X : iterable
            Data to predict on. Must fulfill input requirements of first step
            of the pipeline.

        y : iterable, default=None
            Targets used for scoring. Must fulfill label requirements for all
            steps of the pipeline.

        sample_weight : array-like, default=None
            If not None, this argument is passed as ``sample_weight`` keyword
            argument to the ``score`` method of the final estimator.

        Returns
        -------
        score : float
        """
        Xt = X
        for _, name, transform in self._iter(with_final=False):
            Xt = transform.transform(Xt)
        score_params = {}
        if sample_weight is not None:
            score_params['sample_weight'] = sample_weight
        return self.steps[-1][-1].score(Xt, y, **score_params)

    @property
    def classes_(self):
        return self.steps[-1][-1].classes_

    @property
    def _pairwise(self):
        # check if first estimator expects pairwise input
        return getattr(self.steps[0][1], '_pairwise', False)


def _name_estimators(estimators):
    """Generate names for estimators."""

    names = [
        estimator
        if isinstance(estimator, str) else type(estimator).__name__.lower()
        for estimator in estimators
    ]
    namecount = defaultdict(int)
    for est, name in zip(estimators, names):
        namecount[name] += 1

    for k, v in list(namecount.items()):
        if v == 1:
            del namecount[k]

    for i in reversed(range(len(estimators))):
        name = names[i]
        if name in namecount:
            names[i] += "-%d" % namecount[name]
            namecount[name] -= 1

    return list(zip(names, estimators))


def make_pipeline(*steps, **kwargs):
    """Construct a Pipeline from the given estimators.

    This is a shorthand for the Pipeline constructor; it does not require, and
    does not permit, naming the estimators. Instead, their names will be set
    to the lowercase of their types automatically.

    Parameters
    ----------
    *steps : list of estimators.

    memory : None, str or object with the joblib.Memory interface, optional
        Used to cache the fitted transformers of the pipeline. By default,
        no caching is performed. If a string is given, it is the path to
        the caching directory. Enabling caching triggers a clone of
        the transformers before fitting. Therefore, the transformer
        instance given to the pipeline cannot be inspected
        directly. Use the attribute ``named_steps`` or ``steps`` to
        inspect estimators within the pipeline. Caching the
        transformers is advantageous when fitting is time consuming.

    See also
    --------
    sklearn.pipeline.Pipeline : Class for creating a pipeline of
        transforms with a final estimator.

    Examples
    --------
    >>> from sklearn.naive_bayes import GaussianNB
    >>> from sklearn.preprocessing import StandardScaler
    >>> make_pipeline(StandardScaler(), GaussianNB(priors=None))
    ...     # doctest: +NORMALIZE_WHITESPACE
    Pipeline(memory=None,
             steps=[('standardscaler',
                     StandardScaler(copy=True, with_mean=True, with_std=True)),
                    ('gaussiannb',
                     GaussianNB(priors=None, var_smoothing=1e-09))])

    Returns
    -------
    p : Pipeline
    """
    memory = kwargs.pop('memory', None)
    if kwargs:
        raise TypeError('Unknown keyword arguments: "{}"'
                        .format(list(kwargs.keys())[0]))
    return Pipeline(_name_estimators(steps), memory=memory)


# weight and fit_params are not used but it allows _fit_one_transformer,
# _transform_one and _fit_transform_one to have the same signature to
#  factorize the code in ColumnTransformer
def _fit_one_transformer(transformer, X, y, weight=None, **fit_params):
    return transformer.fit(X, y)


def _transform_one(transformer, X, y, weight, **fit_params):
    res = transformer.transform(X)
    # if we have a weight for this transformer, multiply output
    if weight is None:
        return res
    return res * weight


def _fit_transform_one(transformer, X, y, weight, **fit_params):
    if hasattr(transformer, 'fit_transform'):
        res = transformer.fit_transform(X, y, **fit_params)
    else:
        res = transformer.fit(X, y, **fit_params).transform(X)
    # if we have a weight for this transformer, multiply output
    if weight is None:
        return res, transformer
    return res * weight, transformer


class FeatureUnion(_BaseComposition, TransformerMixin):
    """Concatenates results of multiple transformer objects.

    This estimator applies a list of transformer objects in parallel to the
    input data, then concatenates the results. This is useful to combine
    several feature extraction mechanisms into a single transformer.

    Parameters of the transformers may be set using its name and the parameter
    name separated by a '__'. A transformer may be replaced entirely by
    setting the parameter with its name to another transformer,
    or removed by setting to 'drop' or ``None``.

    Read more in the :ref:`User Guide <feature_union>`.

    Parameters
    ----------
    transformer_list : list of (string, transformer) tuples
        List of transformer objects to be applied to the data. The first
        half of each tuple is the name of the transformer.

    n_jobs : int or None, optional (default=None)
        Number of jobs to run in parallel.
        ``None`` means 1 unless in a :obj:`joblib.parallel_backend` context.
        ``-1`` means using all processors. See :term:`Glossary <n_jobs>`
        for more details.

    transformer_weights : dict, optional
        Multiplicative weights for features per transformer.
        Keys are transformer names, values the weights.

    See also
    --------
    sklearn.pipeline.make_union : convenience function for simplified
        feature union construction.

    Examples
    --------
    >>> from sklearn.pipeline import FeatureUnion
    >>> from sklearn.decomposition import PCA, TruncatedSVD
    >>> union = FeatureUnion([("pca", PCA(n_components=1)),
    ...                       ("svd", TruncatedSVD(n_components=2))])
    >>> X = [[0., 1., 3], [2., 2., 5]]
    >>> union.fit_transform(X)    # doctest: +NORMALIZE_WHITESPACE +ELLIPSIS
    array([[ 1.5       ,  3.0...,  0.8...],
           [-1.5       ,  5.7..., -0.4...]])
    """
    _required_parameters = ["transformer_list"]

    def __init__(self, transformer_list, n_jobs=None,
                 transformer_weights=None):
        self.transformer_list = transformer_list
        self.n_jobs = n_jobs
        self.transformer_weights = transformer_weights
        self._validate_transformers()

    def get_params(self, deep=True):
        """Get parameters for this estimator.

        Parameters
        ----------
        deep : boolean, optional
            If True, will return the parameters for this estimator and
            contained subobjects that are estimators.

        Returns
        -------
        params : mapping of string to any
            Parameter names mapped to their values.
        """
        return self._get_params('transformer_list', deep=deep)

    def set_params(self, **kwargs):
        """Set the parameters of this estimator.

        Valid parameter keys can be listed with ``get_params()``.

        Returns
        -------
        self
        """
        self._set_params('transformer_list', **kwargs)
        return self

    def _validate_transformers(self):
        names, transformers = zip(*self.transformer_list)

        # validate names
        self._validate_names(names)

        # validate estimators
        for t in transformers:
            if t is None or t == 'drop':
                continue
            if (not (hasattr(t, "fit") or hasattr(t, "fit_transform")) or not
                    hasattr(t, "transform")):
                raise TypeError("All estimators should implement fit and "
                                "transform. '%s' (type %s) doesn't" %
                                (t, type(t)))

    def _iter(self):
        """
        Generate (name, trans, weight) tuples excluding None and
        'drop' transformers.
        """
        get_weight = (self.transformer_weights or {}).get
        return ((name, trans, get_weight(name))
                for name, trans in self.transformer_list
                if trans is not None and trans != 'drop')

    def get_feature_names(self):
        """Get feature names from all transformers.

        Returns
        -------
        feature_names : list of strings
            Names of the features produced by transform.
        """
        feature_names = []
        for name, trans, weight in self._iter():
            if not hasattr(trans, 'get_feature_names'):
                raise AttributeError("Transformer %s (type %s) does not "
                                     "provide get_feature_names."
                                     % (str(name), type(trans).__name__))
            feature_names.extend([name + "__" + f for f in
                                  trans.get_feature_names()])
        return feature_names

    def fit(self, X, y=None):
        """Fit all transformers using X.

        Parameters
        ----------
        X : iterable or array-like, depending on transformers
            Input data, used to fit transformers.

        y : array-like, shape (n_samples, ...), optional
            Targets for supervised learning.

        Returns
        -------
        self : FeatureUnion
            This estimator
        """
        self.transformer_list = list(self.transformer_list)
        self._validate_transformers()
        transformers = Parallel(n_jobs=self.n_jobs)(
            delayed(_fit_one_transformer)(trans, X, y)
            for _, trans, _ in self._iter())
        self._update_transformer_list(transformers)
        return self

    def fit_transform(self, X, y=None, **fit_params):
        """Fit all transformers, transform the data and concatenate results.

        Parameters
        ----------
        X : iterable or array-like, depending on transformers
            Input data to be transformed.

        y : array-like, shape (n_samples, ...), optional
            Targets for supervised learning.

        Returns
        -------
        X_t : array-like or sparse matrix, shape (n_samples, sum_n_components)
            hstack of results of transformers. sum_n_components is the
            sum of n_components (output dimension) over transformers.
        """
        self._validate_transformers()
        result = Parallel(n_jobs=self.n_jobs)(
            delayed(_fit_transform_one)(trans, X, y, weight,
                                        **fit_params)
            for name, trans, weight in self._iter())

        if not result:
            # All transformers are None
            return np.zeros((X.shape[0], 0))
        Xs, transformers = zip(*result)
        self._update_transformer_list(transformers)
        if any(sparse.issparse(f) for f in Xs):
            Xs = sparse.hstack(Xs).tocsr()
        else:
            Xs = np.hstack(Xs)
        return Xs

    def transform(self, X):
        """Transform X separately by each transformer, concatenate results.

        Parameters
        ----------
        X : iterable or array-like, depending on transformers
            Input data to be transformed.

        Returns
        -------
        X_t : array-like or sparse matrix, shape (n_samples, sum_n_components)
            hstack of results of transformers. sum_n_components is the
            sum of n_components (output dimension) over transformers.
        """
        Xs = Parallel(n_jobs=self.n_jobs)(
            delayed(_transform_one)(trans, X, None, weight)
            for name, trans, weight in self._iter())
        if not Xs:
            # All transformers are None
            return np.zeros((X.shape[0], 0))
        if any(sparse.issparse(f) for f in Xs):
            Xs = sparse.hstack(Xs).tocsr()
        else:
            Xs = np.hstack(Xs)
        return Xs

    def _update_transformer_list(self, transformers):
        transformers = iter(transformers)
        self.transformer_list[:] = [(name, old if old is None or old == 'drop'
                                     else next(transformers))
                                    for name, old in self.transformer_list]


def make_union(*transformers, **kwargs):
    """Construct a FeatureUnion from the given transformers.

    This is a shorthand for the FeatureUnion constructor; it does not require,
    and does not permit, naming the transformers. Instead, they will be given
    names automatically based on their types. It also does not allow weighting.

    Parameters
    ----------
    *transformers : list of estimators

    n_jobs : int or None, optional (default=None)
        Number of jobs to run in parallel.
        ``None`` means 1 unless in a :obj:`joblib.parallel_backend` context.
        ``-1`` means using all processors. See :term:`Glossary <n_jobs>`
        for more details.

    Returns
    -------
    f : FeatureUnion

    See also
    --------
    sklearn.pipeline.FeatureUnion : Class for concatenating the results
        of multiple transformer objects.

    Examples
    --------
    >>> from sklearn.decomposition import PCA, TruncatedSVD
    >>> from sklearn.pipeline import make_union
    >>> make_union(PCA(), TruncatedSVD())    # doctest: +NORMALIZE_WHITESPACE
    FeatureUnion(n_jobs=None,
           transformer_list=[('pca',
                              PCA(copy=True, iterated_power='auto',
                                  n_components=None, random_state=None,
                                  svd_solver='auto', tol=0.0, whiten=False)),
                             ('truncatedsvd',
                              TruncatedSVD(algorithm='randomized',
                              n_components=2, n_iter=5,
                              random_state=None, tol=0.0))],
           transformer_weights=None)
    """
    n_jobs = kwargs.pop('n_jobs', None)
    if kwargs:
        # We do not currently support `transformer_weights` as we may want to
        # change its type spec in make_union
        raise TypeError('Unknown keyword arguments: "{}"'
                        .format(list(kwargs.keys())[0]))
    return FeatureUnion(_name_estimators(transformers), n_jobs=n_jobs)

```


# sklearn/tests (the files in it)

sklearn/tests/__init__.py
sklearn/tests/test_base.py
sklearn/tests/test_calibration.py
sklearn/tests/test_check_build.py
sklearn/tests/test_common.py
sklearn/tests/test_config.py
sklearn/tests/test_discriminant_analysis.py
sklearn/tests/test_docstring_parameters.py
sklearn/tests/test_dummy.py
sklearn/tests/test_impute.py
sklearn/tests/test_init.py
sklearn/tests/test_isotonic.py
sklearn/tests/test_kernel_approximation.py
sklearn/tests/test_kernel_ridge.py
sklearn/tests/test_metaestimators.py
sklearn/tests/test_multiclass.py
sklearn/tests/test_multioutput.py
sklearn/tests/test_naive_bayes.py
sklearn/tests/test_pipeline.py
sklearn/tests/test_random_projection.py
sklearn/tests/test_site_joblib.py


# The last commit

```
d74b6a76e SWE-bench



 .circleci/config.yml                                        |   0
 .codecov.yml                                                |   0
 .coveragerc                                                 |   0
 .gitattributes                                              |   0
 .gitignore                                                  |   0
 .landscape.yml                                              |   0
 .mailmap                                                    |   0
 .travis.yml                                                 |   0
 CONTRIBUTING.md                                             |   0
 COPYING                                                     |   0
 ISSUE_TEMPLATE.md                                           |   0
 MANIFEST.in                                                 |   0
 Makefile                                                    |   0
 PULL_REQUEST_TEMPLATE.md                                    |   0
 README.rst                                                  |   0
 appveyor.yml                                                |   0
 azure-pipelines.yml                                         |   0
 benchmarks/.gitignore                                       |   0
 benchmarks/bench_20newsgroups.py                            |   0
 benchmarks/bench_covertype.py                               |   0
 benchmarks/bench_feature_expansions.py                      |   0
 benchmarks/bench_glm.py                                     |   0
 benchmarks/bench_glmnet.py                                  |   0
 benchmarks/bench_isolation_forest.py                        |   0
 benchmarks/bench_isotonic.py                                |   0
 benchmarks/bench_lasso.py                                   |   0
 benchmarks/bench_lof.py                                     |   0
 benchmarks/bench_mnist.py                                   |   0
 benchmarks/bench_plot_fastkmeans.py                         |   0
 benchmarks/bench_plot_incremental_pca.py                    |   0
 benchmarks/bench_plot_lasso_path.py                         |   0
 benchmarks/bench_plot_neighbors.py                          |   0
 benchmarks/bench_plot_nmf.py                                |   0
 benchmarks/bench_plot_omp_lars.py                           |   0
 benchmarks/bench_plot_parallel_pairwise.py                  |   0
 benchmarks/bench_plot_randomized_svd.py                     |   0
 benchmarks/bench_plot_svd.py                                |   0
 benchmarks/bench_plot_ward.py                               |   0
 benchmarks/bench_random_projections.py                      |   0
 benchmarks/bench_rcv1_logreg_convergence.py                 |   0
 benchmarks/bench_saga.py                                    |   0
 benchmarks/bench_sample_without_replacement.py              |   0
 benchmarks/bench_sgd_regression.py                          |   0
 benchmarks/bench_sparsify.py                                |   0
 benchmarks/bench_text_vectorizers.py                        |   0
 benchmarks/bench_tree.py                                    |   0
 benchmarks/bench_tsne_mnist.py                              |   0
 benchmarks/plot_tsne_mnist.py                               |   0
 build_tools/Makefile                                        |   0
 build_tools/appveyor/install.ps1                            |   0
 build_tools/appveyor/requirements.txt                       |   0
 build_tools/appveyor/run_with_env.cmd                       |   0
 build_tools/azure/install.cmd                               |   0
 build_tools/azure/posix.yml                                 |   0
 build_tools/azure/test_script.cmd                           |   0
 build_tools/azure/upload_codecov.cmd                        |   0
```

```diff
diff --git a/.circleci/config.yml b/.circleci/config.yml
old mode 100644
new mode 100755
diff --git a/.codecov.yml b/.codecov.yml
old mode 100644
new mode 100755
diff --git a/.coveragerc b/.coveragerc
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.landscape.yml b/.landscape.yml
old mode 100644
new mode 100755
diff --git a/.mailmap b/.mailmap
old mode 100644
new mode 100755
diff --git a/.travis.yml b/.travis.yml
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.md b/CONTRIBUTING.md
old mode 100644
new mode 100755
diff --git a/COPYING b/COPYING
old mode 100644
new mode 100755
diff --git a/ISSUE_TEMPLATE.md b/ISSUE_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/Makefile b/Makefile
old mode 100644
new mode 100755
diff --git a/PULL_REQUEST_TEMPLATE.md b/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/appveyor.yml b/appveyor.yml
old mode 100644
new mode 100755
diff --git a/azure-pipelines.yml b/azure-pipelines.yml
old mode 100644
new mode 100755
diff --git a/benchmarks/.gitignore b/benchmarks/.gitignore
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_20newsgroups.py b/benchmarks/bench_20newsgroups.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_covertype.py b/benchmarks/bench_covertype.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_feature_expansions.py b/benchmarks/bench_feature_expansions.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_glm.py b/benchmarks/bench_glm.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_glmnet.py b/benchmarks/bench_glmnet.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_isolation_forest.py b/benchmarks/bench_isolation_forest.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_isotonic.py b/benchmarks/bench_isotonic.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_lasso.py b/benchmarks/bench_lasso.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_lof.py b/benchmarks/bench_lof.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_mnist.py b/benchmarks/bench_mnist.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_fastkmeans.py b/benchmarks/bench_plot_fastkmeans.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_incremental_pca.py b/benchmarks/bench_plot_incremental_pca.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_lasso_path.py b/benchmarks/bench_plot_lasso_path.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_neighbors.py b/benchmarks/bench_plot_neighbors.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_nmf.py b/benchmarks/bench_plot_nmf.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_omp_lars.py b/benchmarks/bench_plot_omp_lars.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_parallel_pairwise.py b/benchmarks/bench_plot_parallel_pairwise.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_randomized_svd.py b/benchmarks/bench_plot_randomized_svd.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_svd.py b/benchmarks/bench_plot_svd.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_ward.py b/benchmarks/bench_plot_ward.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_random_projections.py b/benchmarks/bench_random_projections.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_rcv1_logreg_convergence.py b/benchmarks/bench_rcv1_logreg_convergence.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_saga.py b/benchmarks/bench_saga.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_sample_without_replacement.py b/benchmarks/bench_sample_without_replacement.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_sgd_regression.py b/benchmarks/bench_sgd_regression.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_sparsify.py b/benchmarks/bench_sparsify.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_text_vectorizers.py b/benchmarks/bench_text_vectorizers.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_tree.py b/benchmarks/bench_tree.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_tsne_mnist.py b/benchmarks/bench_tsne_mnist.py
old mode 100644
new mode 100755
diff --git a/benchmarks/plot_tsne_mnist.py b/benchmarks/plot_tsne_mnist.py
old mode 100644
new mode 100755
diff --git a/build_tools/Makefile b/build_tools/Makefile
old mode 100644
new mode 100755
diff --git a/build_tools/appveyor/install.ps1 b/build_tools/appveyor/install.ps1
old mode 100644
new mode 100755
diff --git a/build_tools/appveyor/requirements.txt b/build_tools/appveyor/requirements.txt
old mode 100644
new mode 100755
diff --git a/build_tools/appveyor/run_with_env.cmd b/build_tools/appveyor/run_with_env.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/install.cmd b/build_tools/azure/install.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/posix.yml b/build_tools/azure/posix.yml
old mode 100644
new mode 100755
diff --git a/build_tools/azure/test_script.cmd b/build_tools/azure/test_script.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/upload_codecov.cmd b/build_tools/azure/upload_codecov.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/windows.yml b/build_tools/azure/windows.yml
old mode 100644
new mode 100755
diff --git a/build_tools/generate_authors_table.py b/build_tools/generate_authors_table.py
old mode 100644
new mode 100755
diff --git a/conftest.py b/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/Makefile b/doc/Makefile
old mode 100644
new mode 100755
diff --git a/doc/README.md b/doc/README.md
old mode 100644
new mode 100755
diff --git a/doc/about.rst b/doc/about.rst
old mode 100644
new mode 100755
diff --git a/doc/authors.rst b/doc/authors.rst
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/conftest.py b/doc/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/data_transforms.rst b/doc/data_transforms.rst
old mode 100644
new mode 100755
diff --git a/doc/datasets/index.rst b/doc/datasets/index.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/advanced_installation.rst b/doc/developers/advanced_installation.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/contributing.rst b/doc/developers/contributing.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/index.rst b/doc/developers/index.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/maintainer.rst b/doc/developers/maintainer.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/performance.rst b/doc/developers/performance.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/tips.rst b/doc/developers/tips.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/utilities.rst b/doc/developers/utilities.rst
old mode 100644
new mode 100755
diff --git a/doc/documentation.rst b/doc/documentation.rst
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/glossary.rst b/doc/glossary.rst
old mode 100644
new mode 100755
diff --git a/doc/governance.rst b/doc/governance.rst
old mode 100644
new mode 100755
diff --git a/doc/images/cds-logo.png b/doc/images/cds-logo.png
old mode 100644
new mode 100755
diff --git a/doc/images/dysco.png b/doc/images/dysco.png
old mode 100644
new mode 100755
diff --git a/doc/images/grid_search_cross_validation.png b/doc/images/grid_search_cross_validation.png
old mode 100644
new mode 100755
diff --git a/doc/images/grid_search_workflow.png b/doc/images/grid_search_workflow.png
old mode 100644
new mode 100755
diff --git a/doc/images/inria-logo.jpg b/doc/images/inria-logo.jpg
old mode 100644
new mode 100755
diff --git a/doc/images/iris.pdf b/doc/images/iris.pdf
old mode 100644
new mode 100755
diff --git a/doc/images/iris.svg b/doc/images/iris.svg
old mode 100644
new mode 100755
diff --git a/doc/images/last_digit.png b/doc/images/last_digit.png
old mode 100644
new mode 100755
diff --git a/doc/images/lda_model_graph.png b/doc/images/lda_model_graph.png
old mode 100644
new mode 100755
diff --git a/doc/images/ml_map.png b/doc/images/ml_map.png
old mode 100644
new mode 100755
diff --git a/doc/images/multilayerperceptron_network.png b/doc/images/multilayerperceptron_network.png
old mode 100644
new mode 100755
diff --git a/doc/images/no_image.png b/doc/images/no_image.png
old mode 100644
new mode 100755
diff --git a/doc/images/nyu_short_color.png b/doc/images/nyu_short_color.png
old mode 100644
new mode 100755
diff --git a/doc/images/plot_digits_classification.png b/doc/images/plot_digits_classification.png
old mode 100644
new mode 100755
diff --git a/doc/images/plot_face_recognition_1.png b/doc/images/plot_face_recognition_1.png
old mode 100644
new mode 100755
diff --git a/doc/images/plot_face_recognition_2.png b/doc/images/plot_face_recognition_2.png
old mode 100644
new mode 100755
diff --git a/doc/images/rbm_graph.png b/doc/images/rbm_graph.png
old mode 100644
new mode 100755
diff --git a/doc/images/scikit-learn-logo-notext.png b/doc/images/scikit-learn-logo-notext.png
old mode 100644
new mode 100755
diff --git a/doc/images/sloan_banner.png b/doc/images/sloan_banner.png
old mode 100644
new mode 100755
diff --git a/doc/includes/big_toc_css.rst b/doc/includes/big_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/includes/bigger_toc_css.rst b/doc/includes/bigger_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/index.rst b/doc/index.rst
old mode 100644
new mode 100755
diff --git a/doc/install.rst b/doc/install.rst
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo-notext.png b/doc/logos/scikit-learn-logo-notext.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo-small.png b/doc/logos/scikit-learn-logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo-thumb.png b/doc/logos/scikit-learn-logo-thumb.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo.bmp b/doc/logos/scikit-learn-logo.bmp
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo.png b/doc/logos/scikit-learn-logo.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo.svg b/doc/logos/scikit-learn-logo.svg
old mode 100644
new mode 100755
diff --git a/doc/make.bat b/doc/make.bat
old mode 100644
new mode 100755
diff --git a/doc/model_selection.rst b/doc/model_selection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/biclustering.rst b/doc/modules/biclustering.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/calibration.rst b/doc/modules/calibration.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/classes.rst b/doc/modules/classes.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/clustering.rst b/doc/modules/clustering.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/compose.rst b/doc/modules/compose.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/computing.rst b/doc/modules/computing.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/covariance.rst b/doc/modules/covariance.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/cross_decomposition.rst b/doc/modules/cross_decomposition.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/cross_validation.rst b/doc/modules/cross_validation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/decomposition.rst b/doc/modules/decomposition.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/density.rst b/doc/modules/density.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/ensemble.rst b/doc/modules/ensemble.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/feature_extraction.rst b/doc/modules/feature_extraction.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/feature_selection.rst b/doc/modules/feature_selection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/gaussian_process.rst b/doc/modules/gaussian_process.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/glm_data/lasso_enet_coordinate_descent.png b/doc/modules/glm_data/lasso_enet_coordinate_descent.png
old mode 100644
new mode 100755
diff --git a/doc/modules/grid_search.rst b/doc/modules/grid_search.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/impute.rst b/doc/modules/impute.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/isotonic.rst b/doc/modules/isotonic.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/kernel_approximation.rst b/doc/modules/kernel_approximation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/kernel_ridge.rst b/doc/modules/kernel_ridge.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/label_propagation.rst b/doc/modules/label_propagation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/lda_qda.rst b/doc/modules/lda_qda.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/learning_curve.rst b/doc/modules/learning_curve.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/linear_model.rst b/doc/modules/linear_model.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/manifold.rst b/doc/modules/manifold.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/metrics.rst b/doc/modules/metrics.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/mixture.rst b/doc/modules/mixture.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/model_evaluation.rst b/doc/modules/model_evaluation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/model_persistence.rst b/doc/modules/model_persistence.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/multiclass.rst b/doc/modules/multiclass.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/naive_bayes.rst b/doc/modules/naive_bayes.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/neighbors.rst b/doc/modules/neighbors.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/neural_networks_supervised.rst b/doc/modules/neural_networks_supervised.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/neural_networks_unsupervised.rst b/doc/modules/neural_networks_unsupervised.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/outlier_detection.rst b/doc/modules/outlier_detection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/pipeline.rst b/doc/modules/pipeline.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/preprocessing.rst b/doc/m
```
````

### `direct-check.log`

```
check: pytest sklearn/tests/test_pipeline.py -q
.........................................                                [100%]
41 passed, 2 warnings in 2.19s
scope: sklearn/pipeline.py sklearn/tests
changed: sklearn/pipeline.py +5 -0
changed: sklearn/tests/test_pipeline.py +3 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sklearn/pipeline.py b/sklearn/pipeline.py
index 7eaf9a46f..dfe70a8cc 100755
--- a/sklearn/pipeline.py
+++ b/sklearn/pipeline.py
@@ -219,6 +219,11 @@ class Pipeline(_BaseComposition):
             return self.named_steps[ind]
         return est
 
+    def __len__(self):
+        """Returns the length of the pipeline
+        """
+        return len(self.steps)
+
     @property
     def _estimator_type(self):
         return self.steps[-1][1]._estimator_type
diff --git a/sklearn/tests/test_pipeline.py b/sklearn/tests/test_pipeline.py
index 8d6fe8f70..0fb5b6840 100755
--- a/sklearn/tests/test_pipeline.py
+++ b/sklearn/tests/test_pipeline.py
@@ -537,6 +537,8 @@ def test_pipeline_slice():
     assert isinstance(pipe2, Pipeline)
     assert pipe2.steps == pipe.steps[:-1]
     assert 2 == len(pipe2.named_steps)
+    pipe3 = pipe[:len(pipe)]
+    assert pipe3.steps == pipe.steps
     assert_raises(ValueError, lambda: pipe[::-1])
 
 
@@ -550,6 +552,7 @@ def test_pipeline_index():
     assert pipe['clf'] == clf
     assert_raises(IndexError, lambda: pipe[3])
     assert_raises(KeyError, lambda: pipe['foobar'])
+    assert len(pipe) == 2
 
 
 def test_set_pipeline_steps():
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
check: pytest sklearn/tests/test_pipeline.py -q
.........................................                                [100%]
41 passed, 2 warnings in 1.63s
scope: sklearn/pipeline.py sklearn/tests
changed: sklearn/pipeline.py +5 -0
changed: sklearn/tests/test_pipeline.py +3 -0
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
# Notes, run 2026-11-06T131501

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Pipeline should implement __len__
#### Description

With the new indexing support `pipe[:len(pipe)]` raises an error.

#### Steps/Code to Reproduce

```python
from sklearn import svm
from sklearn.datasets import samples_generator
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression
from sklearn.pipeline import Pipeline

# generate some data to play with
X, y = samples_generator.make_classification(
    n_informative=5, n_redundant=0, random_state=42)

anova_filter = SelectKBest(f_regression, k=5)
clf = svm.SVC(kernel='linear')
pipe = Pipeline([('anova', anova_filter), ('svc', clf)])

len(pipe)
```

#### Versions

```
System:
    python: 3.6.7 | packaged by conda-forge | (default, Feb 19 2019, 18:37:23)  [GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]
executable: /Users/krisz/.conda/envs/arrow36/bin/python
   machine: Darwin-18.2.0-x86_64-i386-64bit

BLAS:
    macros: HAVE_CBLAS=None
  lib_dirs: /Users/krisz/.conda/envs/arrow36/lib
cblas_libs: openblas, openblas

Python deps:
       pip: 19.0.3
setuptools: 40.8.0
   sklearn: 0.21.dev0
     numpy: 1.16.2
     scipy: 1.2.1
    Cython: 0.29.6
    pandas: 0.24.1
```


# The files of the project

```
.circleci/config.yml
.codecov.yml
.coveragerc
.gitattributes
.gitignore
.landscape.yml
.mailmap
.travis.yml
CONTRIBUTING.md
COPYING
ISSUE_TEMPLATE.md
MANIFEST.in
Makefile
PULL_REQUEST_TEMPLATE.md
README.rst
appveyor.yml
azure-pipelines.yml
benchmarks/.gitignore
benchmarks/bench_20newsgroups.py
benchmarks/bench_covertype.py
benchmarks/bench_feature_expansions.py
benchmarks/bench_glm.py
benchmarks/bench_glmnet.py
benchmarks/bench_isolation_forest.py
benchmarks/bench_isotonic.py
benchmarks/bench_lasso.py
benchmarks/bench_lof.py
benchmarks/bench_mnist.py
benchmarks/bench_multilabel_metrics.py
benchmarks/bench_plot_fastkmeans.py
benchmarks/bench_plot_incremental_pca.py
benchmarks/bench_plot_lasso_path.py
benchmarks/bench_plot_neighbors.py
benchmarks/bench_plot_nmf.py
benchmarks/bench_plot_omp_lars.py
benchmarks/bench_plot_parallel_pairwise.py
benchmarks/bench_plot_randomized_svd.py
benchmarks/bench_plot_svd.py
benchmarks/bench_plot_ward.py
benchmarks/bench_random_projections.py
benchmarks/bench_rcv1_logreg_convergence.py
benchmarks/bench_saga.py
benchmarks/bench_sample_without_replacement.py
benchmarks/bench_sgd_regression.py
benchmarks/bench_sparsify.py
benchmarks/bench_text_vectorizers.py
benchmarks/bench_tree.py
benchmarks/bench_tsne_mnist.py
benchmarks/plot_tsne_mnist.py
build_tools/Makefile
build_tools/appveyor/install.ps1
build_tools/appveyor/requirements.txt
build_tools/appveyor/run_with_env.cmd
build_tools/azure/install.cmd
build_tools/azure/install.sh
build_tools/azure/posix.yml
build_tools/azure/test_docs.sh
build_tools/azure/test_pytest_soft_dependency.sh
build_tools/azure/test_script.cmd
build_tools/azure/test_script.sh
build_tools/azure/upload_codecov.cmd
build_tools/azure/upload_codecov.sh
build_tools/azure/windows.yml
build_tools/circle/build_doc.sh
build_tools/circle/build_test_pypy.sh
build_tools/circle/checkout_merge_commit.sh
build_tools/circle/flake8_diff.sh
build_tools/circle/list_versions.py
build_tools/circle/push_doc.sh
build_tools/generate_authors_table.py
build_tools/travis/after_success.sh
build_tools/travis/install.sh
build_tools/travis/test_docs.sh
build_tools/travis/test_pytest_soft_dependency.sh
build_tools/travis/test_script.sh
build_tools/travis/travis_fastfail.sh
conftest.py
doc/Makefile
doc/README.md
doc/about.rst
doc/authors.rst
doc/conf.py
doc/conftest.py
doc/data_transforms.rst
doc/datasets/index.rst
doc/developers/advanced_installation.rst
doc/developers/contributing.rst
doc/developers/index.rst
doc/developers/maintainer.rst
doc/developers/performance.rst
doc/developers/tips.rst
doc/developers/utilities.rst
doc/documentation.rst
doc/faq.rst
doc/glossary.rst
doc/governance.rst
doc/images/cds-logo.png
doc/images/dysco.png
doc/images/grid_search_cross_validation.png
doc/images/grid_search_workflow.png
doc/images/inria-logo.jpg
doc/images/iris.pdf
doc/images/iris.svg
doc/images/last_digit.png
doc/images/lda_model_graph.png
doc/images/ml_map.png
doc/images/multilayerperceptron_network.png
doc/images/no_image.png
doc/images/nyu_short_color.png
doc/images/plot_digits_classification.png
doc/images/plot_face_recognition_1.png
doc/images/plot_face_recognition_2.png
doc/images/rbm_graph.png
doc/images/scikit-learn-logo-notext.png
doc/images/sloan_banner.png
doc/includes/big_toc_css.rst
doc/includes/bigger_toc_css.rst
doc/index.rst
doc/install.rst
doc/logos/favicon.ico
doc/logos/identity.pdf
doc/logos/scikit-learn-logo-notext.png
doc/logos/scikit-learn-logo-small.png
doc/logos/scikit-learn-logo-thumb.png
doc/logos/scikit-learn-logo.bmp
doc/logos/scikit-learn-logo.png
doc/logos/scikit-learn-logo.svg
doc/make.bat
doc/model_selection.rst
doc/modules/biclustering.rst
doc/modules/calibration.rst
doc/modules/classes.rst
doc/modules/clustering.rst
doc/modules/compose.rst
doc/modules/computing.rst
doc/modules/covariance.rst
doc/modules/cross_decomposition.rst
doc/modules/cross_validation.rst
doc/modules/decomposition.rst
doc/modules/density.rst
doc/modules/ensemble.rst
doc/modules/feature_extraction.rst
doc/modules/feature_selection.rst
doc/modules/gaussian_process.rst
doc/modules/glm_data/lasso_enet_coordinate_descent.png
doc/modules/grid_search.rst
doc/modules/impute.rst
doc/modules/isotonic.rst
doc/modules/kernel_approximation.rst
doc/modules/kernel_ridge.rst
doc/modules/label_propagation.rst
doc/modules/lda_qda.rst
doc/modules/learning_curve.rst
doc/modules/linear_model.rst
doc/modules/manifold.rst
doc/modules/metrics.rst
doc/modules/mixture.rst
doc/modules/model_evaluation.rst
doc/modules/model_persistence.rst
doc/modules/multiclass.rst
doc/modules/naive_bayes.rst
doc/modules/neighbors.rst
doc/modules/neural_networks_supervised.rst
doc/modules/neural_networks_unsupervised.rst
doc/modules/outlier_detection.rst
doc/modules/pipeline.rst
doc/modules/preprocessing.rst
doc/modules/preprocessing_targets.rst
doc/modules/random_projection.rst
doc/modules/sgd.rst
doc/modules/svm.rst
doc/modules/tree.rst
doc/modules/unsupervised_reduction.rst
doc/other_distributions.rst
doc/preface.rst
doc/presentations.rst
doc/related_projects.rst
doc/roadmap.rst
doc/sphinxext/MANIFEST.in
doc/sphinxext/custom_references_resolver.py
doc/sphinxext/github_link.py
doc/sphinxext/sphinx_issues.py
doc/supervised_learning.rst
doc/support.rst
doc/templates/class.rst
doc/templates/class_with_call.rst
doc/templates/class_without_init.rst
doc/templates/deprecated_class.rst
doc/templates/deprecated_class_with_call.rst
doc/templates/deprecated_class_without_init.rst
doc/templates/deprecated_function.rst
doc/templates/function.rst
doc/templates/generate_deprecated.sh
doc/templates/numpydoc_docstring.rst
doc/testimonials/README.txt
doc/testimonials/images/Makefile
doc/testimonials/images/aweber.png
doc/testimonials/images/bestofmedia-logo.png
doc/testimonials/images/betaworks.png
doc/testimonials/images/birchbox.jpg
doc/testimonials/images/booking.png
doc/testimonials/images/change-logo.png
doc/testimonials/images/dataiku_logo.png
doc/testimonials/images/datapublica.png
doc/testimonials/images/datarobot.png
doc/testimonials/images/evernote.png
doc/testimonials/images/howaboutwe.png
doc/testimonials/images/huggingface.png
doc/testimonials/images/infonea.jpg
doc/testimonials/images/inria.png
doc/testimonials/images/jpmorgan.png
doc/testimonials/images/lovely.png
doc/testimonials/images/machinalis.png
doc/testimonials/images/mars.png
doc/testimonials/images/okcupid.png
doc/testimonials/images/ottogroup_logo.png
doc/testimonials/images/peerindex.png
doc/testimonials/images/phimeca.png
doc/testimonials/images/rangespan.png
doc/testimonials/images/solido_logo.png
doc/testimonials/images/spotify.png
doc/testimonials/images/telecomparistech.jpg
doc/testimonials/images/yhat.png
doc/testimonials/images/zopa.png
doc/testimonials/testimonials.rst
doc/themes/scikit-learn/layout.html
doc/themes/scikit-learn/static/ML_MAPS_README.rst
doc/themes/scikit-learn/static/css/bootstrap-responsive.css
doc/themes/scikit-learn/static/css/bootstrap-responsive.min.css
doc/themes/scikit-learn/static/css/bootstrap.css
doc/themes/scikit-learn/static/css/bootstrap.min.css
doc/themes/scikit-learn/static/css/examples.css
doc/themes/scikit-learn/static/img/FNRS-logo.png
doc/themes/scikit-learn/static/img/columbia.png
doc/themes/scikit-learn/static/img/digicosme.png
doc/themes/scikit-learn/static/img/forkme.png
doc/themes/scikit-learn/static/img/glyphicons-halflings-white.png
doc/themes/scikit-learn/static/img/glyphicons-halflings.png
doc/themes/scikit-learn/static/img/google.png
doc/themes/scikit-learn/static/img/inria-small.jpg
doc/themes/scikit-learn/static/img/inria-small.png
doc/themes/scikit-learn/static/img/nyu_short_color.png
doc/themes/scikit-learn/static/img/plot_classifier_comparison_1.png
doc/themes/scikit-learn/static/img/plot_manifold_sphere_1.png
doc/themes/scikit-learn/static/img/scikit-learn-logo-notext.png
doc/themes/scikit-learn/static/img/scikit-learn-logo-small.png
doc/themes/scikit-learn/static/img/scikit-learn-logo.png
doc/themes/scikit-learn/static/img/scikit-learn-logo.svg
doc/themes/scikit-learn/static/img/sloan_logo.jpg
doc/themes/scikit-learn/static/img/sydney-primary.jpeg
doc/themes/scikit-learn/static/img/sydney-stacked.jpeg
doc/themes/scikit-learn/static/img/telecom.png
doc/themes/scikit-learn/static/jquery.js
doc/themes/scikit-learn/static/jquery.maphilight.js
doc/themes/scikit-learn/static/jquery.maphilight.min.js
doc/themes/scikit-learn/static/js/bootstrap.js
doc/themes/scikit-learn/static/js/bootstrap.min.js
doc/themes/scikit-learn/static/js/copybutton.js
doc/themes/scikit-learn/static/js/extra.js
doc/themes/scikit-learn/static/nature.css_t
doc/themes/scikit-learn/theme.conf
doc/tune_toc.rst
doc/tutorial/basic/tutorial.rst
doc/tutorial/common_includes/info.txt
doc/tutorial/index.rst
doc/tutorial/machine_learning_map/ML_MAPS_README.txt
doc/tutorial/machine_learning_map/index.rst
doc/tutorial/machine_learning_map/parse_path.py
doc/tutorial/machine_learning_map/pyparsing.py
doc/tutorial/machine_learning_map/svg2imagemap.py
doc/tutorial/statistical_inference/finding_help.rst
doc/tutorial/statistical_inference/index.rst
doc/tutorial/statistical_inference/model_selection.rst
doc/tutorial/statistical_inference/putting_together.rst
doc/tutorial/statistical_inference/settings.rst
doc/tutorial/statistical_inference/supervised_learning.rst
doc/tutorial/statistical_inference/unsupervised_learning.rst
doc/tutorial/text_analytics/.gitignore
doc/tutorial/text_analytics/data/languages/fetch_data.py
doc/tutorial/text_analytics/data/movie_reviews/fetch_data.py
doc/tutorial/text_analytics/data/twenty_newsgroups/fetch_data.py
doc/tutorial/text_analytics/skeletons/exercise_01_language_train_model.py
doc/tutorial/text_analytics/skeletons/exercise_02_sentiment.py
doc/tutorial/text_analytics/solutions/exercise_01_language_train_model.py
doc/tutorial/text_analytics/solutions/exercise_02_sentiment.py
doc/tutorial/text_analytics/solutions/generate_skeletons.py
doc/tutorial/text_analytics/working_with_text_data.rst
doc/unsupervised_learning.rst
doc/user_guide.rst
doc/whats_new.rst
doc/whats_new/_contributors.rst
doc/whats_new/older_versions.rst
doc/whats_new/v0.13.rst
doc/whats_new/v0.14.rst
doc/whats_new/v0.15.rst
doc/whats_new/v0.16.rst
doc/whats_new/v0.17.rst
doc/whats_new/v0.18.rst
doc/whats_new/v0.19.rst
doc/whats_new/v0.20.rst
doc/whats_new/v0.21.rst
examples/.flake8
examples/README.txt
examples/applications/README.txt
examples/applications/plot_face_recognition.py
examples/applications/plot_model_complexity_influence.py
examples/applications/plot_out_of_core_classification.py
examples/applications/plot_outlier_detection_housing.py
examples/applications/plot_prediction_latency.py
examples/applications/plot_species_distribution_modeling.py
examples/applications/plot_stock_market.py
examples/applications/plot_tomography_l1_reconstruction.py
examples/applications/plot_topics_extraction_with_nmf_lda.py
examples/applications/svm_gui.py
examples/applications/wikipedia_principal_eigenvector.py
examples/bicluster/README.txt
examples/bicluster/plot_bicluster_newsgroups.py
examples/bicluster/plot_spectral_biclustering.py
examples/bicluster/plot_spectral_coclustering.py
examples/calibration/README.txt
examples/calibration/plot_calibration.py
examples/calibration/plot_calibration_curve.py
examples/calibration/plot_calibration_multiclass.py
examples/calibration/plot_compare_calibration.py
examples/classification/README.txt
examples/classification/plot_classification_probability.py
examples/classification/plot_classifier_comparison.py
examples/classification/plot_digits_classification.py
examples/classification/plot_lda.py
examples/classification/plot_lda_qda.py
examples/cluster/README.txt
examples/cluster/plot_adjusted_for_chance_measures.py
examples/cluster/plot_affinity_propagation.py
examples/cluster/plot_agglomerative_clustering.py
examples/cluster/plot_agglomerative_clustering_metrics.py
examples/cluster/plot_birch_vs_minibatchkmeans.py
examples/cluster/plot_cluster_comparison.py
examples/cluster/plot_cluster_iris.py
examples/cluster/plot_coin_segmentation.py
examples/cluster/plot_coin_ward_segmentation.py
examples/cluster/plot_color_quantization.py
examples/cluster/plot_dbscan.py
examples/cluster/plot_dict_face_patches.py
examples/cluster/plot_digits_agglomeration.py
examples/cluster/plot_digits_linkage.py
examples/cluster/plot_face_compress.py
examples/cluster/plot_feature_agglomeration_vs_univariate_selection.py
examples/cluster/plot_inductive_clustering.py
examples/cluster/plot_kmeans_assumptions.py
examples/cluster/plot_kmeans_digits.py
examples/cluster/plot_kmeans_silhouette_analysis.py
examples/cluster/plot_kmeans_stability_low_dim_dense.py
examples/cluster/plot_linkage_comparison.py
examples/cluster/plot_mean_shift.py
examples/cluster/plot_mini_batch_kmeans.py
examples/cluster/plot_segmentation_toy.py
examples/cluster/plot_ward_structured_vs_unstructured.py
examples/compose/README.txt
examples/compose/plot_column_transformer.py
examples/compose/plot_column_transformer_mixed_types.py
examples/compose/plot_compare_reduction.py
examples/compose/plot_digits_pipe.py
examples/compose/plot_feature_union.py
examples/compose/plot_transformed_target.py
examples/covariance/README.txt
examples/covariance/plot_covariance_estimation.py
examples/covariance/plot_lw_vs_oas.py
examples/covariance/plot_mahalanobis_distances.py
examples/covariance/plot_robust_vs_empirical_covariance.py
examples/covariance/plot_sparse_cov.py
examples/cross_decomposition/README.txt
examples/cross_decomposition/plot_compare_cross_decomposition.py
examples/datasets/README.txt
examples/datasets/plot_digits_last_image.py
examples/datasets/plot_iris_dataset.py
examples/datasets/plot_random_dataset.py
examples/datasets/plot_random_multilabel_dataset.py
examples/decomposition/README.txt
examples/decomposition/plot_beta_divergence.py
examples/decomposition/plot_faces_decomposition.py
examples/decomposition/plot_ica_blind_source_separation.py
examples/decomposition/plot_ica_vs_pca.py
examples/decomposition/plot_image_denoising.py
examples/decomposition/plot_incremental_pca.py
examples/decomposition/plot_kernel_pca.py
examples/decomposition/plot_pca_3d.py
examples/decomposition/plot_pca_iris.py
examples/decomposition/plot_pca_vs_fa_model_selection.py
examples/decomposition/plot_pca_vs_lda.py
examples/decomposition/plot_sparse_coding.py
examples/ensemble/README.txt
examples/ensemble/plot_adaboost_hastie_10_2.py
examples/ensemble/plot_adaboost_multiclass.py
examples/ensemble/plot_adaboost_regression.py
examples/ensemble/plot_adaboost_twoclass.py
examples/ensemble/plot_bias_variance.py
examples/ensemble/plot_ensemble_oob.py
examples/ensemble/plot_feature_transformation.py
examples/ensemble/plot_forest_importances.py
examples/ensemble/plot_forest_importances_faces.py
examples/ensemble/plot_forest_iris.py
examples/ensemble/plot_gradient_boosting_early_stopping.py
examples/ensemble/plot_gradient_boosting_oob.py
examples/ensemble/plot_gradient_boosting_quantile.py
examples/ensemble/plot_gradient_boosting_regression.py
examples/ensemble/plot_gradient_boosting_regularization.py
examples/ensemble/plot_isolation_forest.py
examples/ensemble/plot_partial_dependence.py
examples/ensemble/plot_random_forest_embedding.py
examples/ensemble/plot_random_forest_regression_multioutput.py
examples/ensemble/plot_voting_decision_regions.py
examples/ensemble/plot_voting_probas.py
examples/exercises/README.txt
examples/exercises/plot_cv_diabetes.py
examples/exercises/plot_cv_digits.py
examples/exercises/plot_digits_classification_exercise.py
examples/exercises/plot_iris_exercise.py
examples/feature_selection/README.txt
examples/feature_selection/plot_f_test_vs_mi.py
examples/feature_selection/plot_feature_selection.py
examples/feature_selection/plot_feature_selection_pipeline.py
examples/feature_selection/plot_permutation_test_for_classification.py
examples/feature_selection/plot_rfe_digits.py
examples/feature_selection/plot_rfe_with_cross_validation.py
examples/feature_selection/plot_select_from_model_boston.py
examples/gaussian_process/README.txt
examples/gaussian_process/plot_compare_gpr_krr.py
examples/gaussian_process/plot_gpc.py
examples/gaussian_process/plot_gpc_iris.py
examples/gaussian_process/plot_gpc_isoprobability.py
examples/gaussian_process/plot_gpc_xor.py
examples/gaussian_process/plot_gpr_co2.py
examples/gaussian_process/plot_gpr_noisy.py
examples/gaussian_process/plot_gpr_noisy_targets.py
examples/gaussian_process/plot_gpr_prior_posterior.py
examples/impute/README.txt
examples/impute/plot_iterative_imputer_variants_comparison.py
examples/impute/plot_missing_values.py
examples/linear_model/README.txt
examples/linear_model/plot_ard.py
examples/linear_model/plot_bayesian_ridge.py
examples/linear_model/plot_huber_vs_ridge.py
examples/linear_model/plot_iris_logistic.py
examples/linear_model/plot_lasso_and_elasticnet.py
examples/linear_model/plot_lasso_coordinate_descent_path.py
examples/linear_model/plot_lasso_dense_vs_sparse_data.py
examples/linear_model/plot_lasso_lars.py
examples/linear_model/plot_lasso_model_selection.py
examples/linear_model/plot_logistic.py
examples/linear_model/plot_logistic_l1_l2_sparsity.py
examples/linear_model/plot_logistic_multinomial.py
examples/linear_model/plot_logistic_path.py
examples/linear_model/plot_multi_task_lasso_support.py
examples/linear_model/plot_ols.py
examples/linear_model/plot_ols_3d.py
examples/linear_model/plot_ols_ridge_variance.py
examples/linear_model/plot_omp.py
examples/linear_model/plot_polynomial_interpolation.py
examples/linear_model/plot_ransac.py
examples/linear_model/plot_ridge_coeffs.py
examples/linear_model/plot_ridge_path.py
examples/linear_model/plot_robust_fit.py
examples/linear_model/plot_sgd_comparison.py
examples/linear_model/plot_sgd_early_stopping.py
examples/linear_model/plot_sgd_iris.py
examples/linear_model/plot_sgd_loss_functions.py
examples/linear_model/plot_sgd_penalties.py
examples/linear_model/plot_sgd_separating_hyperplane.py
examples/linear_model/plot_sgd_weighted_samples.py
examples/linear_model/plot_sparse_logistic_regression_20newsgroups.py
examples/linear_model/plot_sparse_logistic_regression_mnist.py
examples/linear_model/plot_theilsen.py
examples/manifold/README.txt
examples/manifold/plot_compare_methods.py
examples/manifold/plot_lle_digits.py
examples/manifold/plot_manifold_sphere.py
examples/manifold/plot_mds.py
examples/manifold/plot_swissroll.py
examples/manifold/plot_t_sne_perplexity.py
examples/mixture/README.txt
examples/mixture/plot_concentration_prior.py
examples/mixture/plot_gmm.py
examples/mixture/plot_gmm_covariances.py
examples/mixture/plot_gmm_pdf.py
examples/mixture/plot_gmm_selection.py
examples/mixture/plot_gmm_sin.py
examples/model_selection/README.txt
examples/model_selection/grid_search_text_feature_extraction.py
examples/model_selection/plot_confusion_matrix.py
examples/model_selection/plot_cv_indices.py
examples/model_selection/plot_cv_predict.py
examples/model_selection/plot_grid_search_digits.py
examples/model_selection/plot_grid_search_refit_callable.py
examples/model_selection/plot_learning_curve.py
examples/model_selection/plot_multi_metric_evaluation.py
examples/model_selection/plot_nested_cross_validation_iris.py
examples/model_selection/plot_precision_recall.py
examples/model_selection/plot_randomized_search.py
examples/model_selection/plot_roc.py
examples/model_selection/plot_roc_crossval.py
examples/model_selection/plot_train_error_vs_test_error.py
examples/model_selection/plot_underfitting_overfitting.py
examples/model_selection/plot_validation_curve.py
examples/multioutput/README.txt
examples/multioutput/plot_classifier_chain_yeast.py
examples/neighbors/README.txt
examples/neighbors/plot_classification.py
examples/neighbors/plot_digits_kde_sampling.py
examples/neighbors/plot_kde_1d.py
examples/neighbors/plot_lof_novelty_detection.py
examples/neighbors/plot_lof_outlier_detection.py
examples/neighbors/plot_nca_classification.py
examples/neighbors/plot_nca_dim_reduction.py
examples/neighbors/plot_nca_illustration.py
examples/neighbors/plot_nearest_centroid.py
examples/neighbors/plot_regression.py
examples/neighbors/plot_species_kde.py
examples/neural_networks/README.txt
examples/neural_networks/plot_mlp_alpha.py
examples/neural_networks/plot_mlp_training_curves.py
examples/neural_networks/plot_mnist_filters.py
examples/neural_networks/plot_rbm_logistic_classification.py
examples/plot_anomaly_comparison.py
examples/plot_changed_only_pprint_parameter.py
examples/plot_isotonic_regression.py
examples/plot_johnson_lindenstrauss_bound.py
examples/plot_kernel_approximation.py
examples/plot_kernel_ridge_regression.py
examples/plot_multilabel.py
examples/plot_multioutput_face_completion.py
examples/preprocessing/README.txt
examples/preprocessing/plot_all_scaling.py
examples/preprocessing/plot_discretization.py
examples/preprocessing/plot_discretization_classification.py
examples/preprocessing/plot_discretization_strategies.py
examples/preprocessing/plot_function_transformer.py
examples/preprocessing/plot_map_data_to_normal.py
examples/preprocessing/plot_scaling_importance.py
examples/semi_supervised/README.txt
examples/semi_supervised/plot_label_propagation_digits.py
examples/semi_supervised/plot_label_propagation_digits_active_learning.py
examples/semi_supervised/plot_label_propagation_structure.py
examples/semi_supervised/plot_label_propagation_versus_svm_iris.py
examples/svm/README.txt
examples/svm/plot_custom_kernel.py
examples/svm/plot_iris_svc.py
examples/svm/plot_oneclass.py
examples/svm/plot_rbf_parameters.py
examples/svm/plot_separating_hyperplane.py
examples/svm/plot_separating_hyperplane_unbalanced.py
examples/svm/plot_svm_anova.py
examples/svm/plot_svm_kernels.py
examples/svm/plot_svm_margin.py
examples/svm/plot_svm_nonlinear.py
examples/svm/plot_svm_regression.py
examples/svm/plot_svm_scale_c.py
examples/svm/plot_weighted_samples.py
examples/text/README.txt
examples/text/plot_document_classification_20newsgroups.py
examples/text/plot_document_clustering.py
examples/text/plot_hashing_vs_dict_vectorizer.py
examples/tree/README.txt
examples/tree/plot_iris_dtc.py
examples/tree/plot_tree_regression.py
examples/tree/plot_tree_regression_multioutput.py
examples/tree/plot_unveil_tree_structure.py
lgtm.yml
maint_tools/sort_whats_new.py
maint_tools/whats_missing.sh
setup.cfg
setup.py
site.cfg
sklearn/__check_build/__init__.py
sklearn/__check_build/_check_build.pyx
sklearn/__check_build/setup.py
sklearn/__init__.py
sklearn/_build_utils/__init__.py
sklearn/_config.py
sklearn/_isotonic.pyx
sklearn/base.py
sklearn/calibration.py
sklearn/cluster/__init__.py
sklearn/cluster/_dbscan_inner.pyx
sklearn/cluster/_feature_agglomeration.py
sklearn/cluster/_hierarchical.pyx
sklearn/cluster/_k_means.pyx
sklearn/cluster/_k_means_elkan.pyx
sklearn/cluster/affinity_propagation_.py
sklearn/cluster/bicluster.py
sklearn/cluster/birch.py
sklearn/cluster/dbscan_.py
sklearn/cluster/hierarchical.py
sklearn/cluster/k_means_.py
sklearn/cluster/mean_shift_.py
sklearn/cluster/optics_.py
sklearn/cluster/setup.py
sklearn/cluster/spectral.py
sklearn/cluster/tests/__init__.py
sklearn/cluster/tests/common.py
sklearn/cluster/tests/test_affinity_propagation.py
```


# The last commit

```
d74b6a76e SWE-bench



 .circleci/config.yml                                        |   0
 .codecov.yml                                                |   0
 .coveragerc                                                 |   0
 .gitattributes                                              |   0
 .gitignore                                                  |   0
 .landscape.yml                                              |   0
 .mailmap                                                    |   0
 .travis.yml                                                 |   0
 CONTRIBUTING.md                                             |   0
 COPYING                                                     |   0
 ISSUE_TEMPLATE.md                                           |   0
 MANIFEST.in                                                 |   0
 Makefile                                                    |   0
 PULL_REQUEST_TEMPLATE.md                                    |   0
 README.rst                                                  |   0
 appveyor.yml                                                |   0
 azure-pipelines.yml                                         |   0
 benchmarks/.gitignore                                       |   0
 benchmarks/bench_20newsgroups.py                            |   0
 benchmarks/bench_covertype.py                               |   0
 benchmarks/bench_feature_expansions.py                      |   0
 benchmarks/bench_glm.py                                     |   0
 benchmarks/bench_glmnet.py                                  |   0
 benchmarks/bench_isolation_forest.py                        |   0
 benchmarks/bench_isotonic.py                                |   0
 benchmarks/bench_lasso.py                                   |   0
 benchmarks/bench_lof.py                                     |   0
 benchmarks/bench_mnist.py                                   |   0
 benchmarks/bench_plot_fastkmeans.py                         |   0
 benchmarks/bench_plot_incremental_pca.py                    |   0
 benchmarks/bench_plot_lasso_path.py                         |   0
 benchmarks/bench_plot_neighbors.py                          |   0
 benchmarks/bench_plot_nmf.py                                |   0
 benchmarks/bench_plot_omp_lars.py                           |   0
 benchmarks/bench_plot_parallel_pairwise.py                  |   0
 benchmarks/bench_plot_randomized_svd.py                     |   0
 benchmarks/bench_plot_svd.py                                |   0
 benchmarks/bench_plot_ward.py                               |   0
 benchmarks/bench_random_projections.py                      |   0
 benchmarks/bench_rcv1_logreg_convergence.py                 |   0
 benchmarks/bench_saga.py                                    |   0
 benchmarks/bench_sample_without_replacement.py              |   0
 benchmarks/bench_sgd_regression.py                          |   0
 benchmarks/bench_sparsify.py                                |   0
 benchmarks/bench_text_vectorizers.py                        |   0
 benchmarks/bench_tree.py                                    |   0
 benchmarks/bench_tsne_mnist.py                              |   0
 benchmarks/plot_tsne_mnist.py                               |   0
 build_tools/Makefile                                        |   0
 build_tools/appveyor/install.ps1                            |   0
 build_tools/appveyor/requirements.txt                       |   0
 build_tools/appveyor/run_with_env.cmd                       |   0
 build_tools/azure/install.cmd                               |   0
 build_tools/azure/posix.yml                                 |   0
 build_tools/azure/test_script.cmd                           |   0
 build_tools/azure/upload_codecov.cmd                        |   0
```

```diff
diff --git a/.circleci/config.yml b/.circleci/config.yml
old mode 100644
new mode 100755
diff --git a/.codecov.yml b/.codecov.yml
old mode 100644
new mode 100755
diff --git a/.coveragerc b/.coveragerc
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.landscape.yml b/.landscape.yml
old mode 100644
new mode 100755
diff --git a/.mailmap b/.mailmap
old mode 100644
new mode 100755
diff --git a/.travis.yml b/.travis.yml
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.md b/CONTRIBUTING.md
old mode 100644
new mode 100755
diff --git a/COPYING b/COPYING
old mode 100644
new mode 100755
diff --git a/ISSUE_TEMPLATE.md b/ISSUE_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/Makefile b/Makefile
old mode 100644
new mode 100755
diff --git a/PULL_REQUEST_TEMPLATE.md b/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/appveyor.yml b/appveyor.yml
old mode 100644
new mode 100755
diff --git a/azure-pipelines.yml b/azure-pipelines.yml
old mode 100644
new mode 100755
diff --git a/benchmarks/.gitignore b/benchmarks/.gitignore
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_20newsgroups.py b/benchmarks/bench_20newsgroups.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_covertype.py b/benchmarks/bench_covertype.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_feature_expansions.py b/benchmarks/bench_feature_expansions.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_glm.py b/benchmarks/bench_glm.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_glmnet.py b/benchmarks/bench_glmnet.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_isolation_forest.py b/benchmarks/bench_isolation_forest.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_isotonic.py b/benchmarks/bench_isotonic.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_lasso.py b/benchmarks/bench_lasso.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_lof.py b/benchmarks/bench_lof.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_mnist.py b/benchmarks/bench_mnist.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_fastkmeans.py b/benchmarks/bench_plot_fastkmeans.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_incremental_pca.py b/benchmarks/bench_plot_incremental_pca.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_lasso_path.py b/benchmarks/bench_plot_lasso_path.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_neighbors.py b/benchmarks/bench_plot_neighbors.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_nmf.py b/benchmarks/bench_plot_nmf.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_omp_lars.py b/benchmarks/bench_plot_omp_lars.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_parallel_pairwise.py b/benchmarks/bench_plot_parallel_pairwise.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_randomized_svd.py b/benchmarks/bench_plot_randomized_svd.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_svd.py b/benchmarks/bench_plot_svd.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_plot_ward.py b/benchmarks/bench_plot_ward.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_random_projections.py b/benchmarks/bench_random_projections.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_rcv1_logreg_convergence.py b/benchmarks/bench_rcv1_logreg_convergence.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_saga.py b/benchmarks/bench_saga.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_sample_without_replacement.py b/benchmarks/bench_sample_without_replacement.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_sgd_regression.py b/benchmarks/bench_sgd_regression.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_sparsify.py b/benchmarks/bench_sparsify.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_text_vectorizers.py b/benchmarks/bench_text_vectorizers.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_tree.py b/benchmarks/bench_tree.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_tsne_mnist.py b/benchmarks/bench_tsne_mnist.py
old mode 100644
new mode 100755
diff --git a/benchmarks/plot_tsne_mnist.py b/benchmarks/plot_tsne_mnist.py
old mode 100644
new mode 100755
diff --git a/build_tools/Makefile b/build_tools/Makefile
old mode 100644
new mode 100755
diff --git a/build_tools/appveyor/install.ps1 b/build_tools/appveyor/install.ps1
old mode 100644
new mode 100755
diff --git a/build_tools/appveyor/requirements.txt b/build_tools/appveyor/requirements.txt
old mode 100644
new mode 100755
diff --git a/build_tools/appveyor/run_with_env.cmd b/build_tools/appveyor/run_with_env.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/install.cmd b/build_tools/azure/install.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/posix.yml b/build_tools/azure/posix.yml
old mode 100644
new mode 100755
diff --git a/build_tools/azure/test_script.cmd b/build_tools/azure/test_script.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/upload_codecov.cmd b/build_tools/azure/upload_codecov.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/windows.yml b/build_tools/azure/windows.yml
old mode 100644
new mode 100755
diff --git a/build_tools/generate_authors_table.py b/build_tools/generate_authors_table.py
old mode 100644
new mode 100755
diff --git a/conftest.py b/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/Makefile b/doc/Makefile
old mode 100644
new mode 100755
diff --git a/doc/README.md b/doc/README.md
old mode 100644
new mode 100755
diff --git a/doc/about.rst b/doc/about.rst
old mode 100644
new mode 100755
diff --git a/doc/authors.rst b/doc/authors.rst
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/conftest.py b/doc/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/data_transforms.rst b/doc/data_transforms.rst
old mode 100644
new mode 100755
diff --git a/doc/datasets/index.rst b/doc/datasets/index.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/advanced_installation.rst b/doc/developers/advanced_installation.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/contributing.rst b/doc/developers/contributing.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/index.rst b/doc/developers/index.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/maintainer.rst b/doc/developers/maintainer.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/performance.rst b/doc/developers/performance.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/tips.rst b/doc/developers/tips.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/utilities.rst b/doc/developers/utilities.rst
old mode 100644
new mode 100755
diff --git a/doc/documentation.rst b/doc/documentation.rst
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/glossary.rst b/doc/glossary.rst
old mode 100644
new mode 100755
diff --git a/doc/governance.rst b/doc/governance.rst
old mode 100644
new mode 100755
diff --git a/doc/images/cds-logo.png b/doc/images/cds-logo.png
old mode 100644
new mode 100755
diff --git a/doc/images/dysco.png b/doc/images/dysco.png
old mode 100644
new mode 100755
diff --git a/doc/images/grid_search_cross_validation.png b/doc/images/grid_search_cross_validation.png
old mode 100644
new mode 100755
diff --git a/doc/images/grid_search_workflow.png b/doc/images/grid_search_workflow.png
old mode 100644
new mode 100755
diff --git a/doc/images/inria-logo.jpg b/doc/images/inria-logo.jpg
old mode 100644
new mode 100755
diff --git a/doc/images/iris.pdf b/doc/images/iris.pdf
old mode 100644
new mode 100755
diff --git a/doc/images/iris.svg b/doc/images/iris.svg
old mode 100644
new mode 100755
diff --git a/doc/images/last_digit.png b/doc/images/last_digit.png
old mode 100644
new mode 100755
diff --git a/doc/images/lda_model_graph.png b/doc/images/lda_model_graph.png
old mode 100644
new mode 100755
diff --git a/doc/images/ml_map.png b/doc/images/ml_map.png
old mode 100644
new mode 100755
diff --git a/doc/images/multilayerperceptron_network.png b/doc/images/multilayerperceptron_network.png
old mode 100644
new mode 100755
diff --git a/doc/images/no_image.png b/doc/images/no_image.png
old mode 100644
new mode 100755
diff --git a/doc/images/nyu_short_color.png b/doc/images/nyu_short_color.png
old mode 100644
new mode 100755
diff --git a/doc/images/plot_digits_classification.png b/doc/images/plot_digits_classification.png
old mode 100644
new mode 100755
diff --git a/doc/images/plot_face_recognition_1.png b/doc/images/plot_face_recognition_1.png
old mode 100644
new mode 100755
diff --git a/doc/images/plot_face_recognition_2.png b/doc/images/plot_face_recognition_2.png
old mode 100644
new mode 100755
diff --git a/doc/images/rbm_graph.png b/doc/images/rbm_graph.png
old mode 100644
new mode 100755
diff --git a/doc/images/scikit-learn-logo-notext.png b/doc/images/scikit-learn-logo-notext.png
old mode 100644
new mode 100755
diff --git a/doc/images/sloan_banner.png b/doc/images/sloan_banner.png
old mode 100644
new mode 100755
diff --git a/doc/includes/big_toc_css.rst b/doc/includes/big_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/includes/bigger_toc_css.rst b/doc/includes/bigger_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/index.rst b/doc/index.rst
old mode 100644
new mode 100755
diff --git a/doc/install.rst b/doc/install.rst
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo-notext.png b/doc/logos/scikit-learn-logo-notext.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo-small.png b/doc/logos/scikit-learn-logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo-thumb.png b/doc/logos/scikit-learn-logo-thumb.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo.bmp b/doc/logos/scikit-learn-logo.bmp
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo.png b/doc/logos/scikit-learn-logo.png
old mode 100644
new mode 100755
diff --git a/doc/logos/scikit-learn-logo.svg b/doc/logos/scikit-learn-logo.svg
old mode 100644
new mode 100755
diff --git a/doc/make.bat b/doc/make.bat
old mode 100644
new mode 100755
diff --git a/doc/model_selection.rst b/doc/model_selection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/biclustering.rst b/doc/modules/biclustering.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/calibration.rst b/doc/modules/calibration.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/classes.rst b/doc/modules/classes.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/clustering.rst b/doc/modules/clustering.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/compose.rst b/doc/modules/compose.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/computing.rst b/doc/modules/computing.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/covariance.rst b/doc/modules/covariance.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/cross_decomposition.rst b/doc/modules/cross_decomposition.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/cross_validation.rst b/doc/modules/cross_validation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/decomposition.rst b/doc/modules/decomposition.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/density.rst b/doc/modules/density.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/ensemble.rst b/doc/modules/ensemble.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/feature_extraction.rst b/doc/modules/feature_extraction.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/feature_selection.rst b/doc/modules/feature_selection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/gaussian_process.rst b/doc/modules/gaussian_process.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/glm_data/lasso_enet_coordinate_descent.png b/doc/modules/glm_data/lasso_enet_coordinate_descent.png
old mode 100644
new mode 100755
diff --git a/doc/modules/grid_search.rst b/doc/modules/grid_search.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/impute.rst b/doc/modules/impute.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/isotonic.rst b/doc/modules/isotonic.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/kernel_approximation.rst b/doc/modules/kernel_approximation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/kernel_ridge.rst b/doc/modules/kernel_ridge.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/label_propagation.rst b/doc/modules/label_propagation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/lda_qda.rst b/doc/modules/lda_qda.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/learning_curve.rst b/doc/modules/learning_curve.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/linear_model.rst b/doc/modules/linear_model.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/manifold.rst b/doc/modules/manifold.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/metrics.rst b/doc/modules/metrics.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/mixture.rst b/doc/modules/mixture.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/model_evaluation.rst b/doc/modules/model_evaluation.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/model_persistence.rst b/doc/modules/model_persistence.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/multiclass.rst b/doc/modules/multiclass.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/naive_bayes.rst b/doc/modules/naive_bayes.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/neighbors.rst b/doc/modules/neighbors.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/neural_networks_supervised.rst b/doc/modules/neural_networks_supervised.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/neural_networks_unsupervised.rst b/doc/modules/neural_networks_unsupervised.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/outlier_detection.rst b/doc/modules/outlier_detection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/pipeline.rst b/doc/modules/pipeline.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/preprocessing.rst b/doc/m
```


# CONTRIBUTING.md (the start)

```

Contributing to scikit-learn
============================

There are many ways to contribute to scikit-learn, with the most common ones
being contribution of code or documentation to the project. Improving the
documentation is no less important than improving the library itself. If you
find a typo in the documentation, or have made improvements, do not hesitate to
send an email to the mailing list or preferably submit a GitHub pull request.
Documentation can be found under the
[doc/](https://github.com/scikit-learn/scikit-learn/tree/master/doc) directory.

But there are many other ways to help. In particular answering queries on the
[issue tracker](https://github.com/scikit-learn/scikit-learn/issues),
investigating bugs, and [reviewing other developers' pull
requests](http://scikit-learn.org/dev/developers/contributing.html#code-review-guidelines)
are very valuable contributions that decrease the burden on the project
maintainers.

Another way to contribute is to report issues you're facing, and give a "thumbs
up" on issues that others reported and that are relevant to you. It also helps
us if you spread the word: reference the project from your blog and articles,
link to it from your website, or simply star it in GitHub to say "I use it".

Guideline
---------

Full contribution guidelines are available in the repository at
`doc/developers/contributing.rst`, or online at:

http://scikit-learn.org/dev/developers/contributing.html

Quick links to:
* [Submitting a bug report or feature request](http://scikit-learn.org/dev/developers/contributing.html#submitting-a-bug-report-or-a-feature-request)
* [Contributing code](http://scikit-learn.org/dev/developers/contributing.html#contributing-code)
* [Coding guidelines](http://scikit-learn.org/dev/developers/contributing.html#coding-guidelines)
* [Tips to read current code](http://scikit-learn.org/dev/developers/contributing.html#reading-code)

Code of Conduct
---------------

We abide by the principles of openness, respect, and consideration of others
of the Python Software Foundation: https://www.python.org/psf/codeofconduct/.

```


# Makefile (the start)

```
# simple makefile to simplify repetitive build env management tasks under posix

# caution: testing won't work on windows, see README

PYTHON ?= python
CYTHON ?= cython
PYTEST ?= pytest
CTAGS ?= ctags

# skip doctests on 32bit python
BITS := $(shell python -c 'import struct; print(8 * struct.calcsize("P"))')

all: clean inplace test

clean-ctags:
	rm -f tags

clean: clean-ctags
	$(PYTHON) setup.py clean
	rm -rf dist

in: inplace # just a shortcut
inplace:
	$(PYTHON) setup.py build_ext -i

test-code: in
	$(PYTEST) --showlocals -v sklearn --durations=20
test-sphinxext:
	$(PYTEST) --showlocals -v doc/sphinxext/
test-doc:
ifeq ($(BITS),64)
	$(PYTEST) $(shell find doc -name '*.rst' | sort)
endif

test-coverage:
	rm -rf coverage .coverage
	$(PYTEST) sklearn --showlocals -v --cov=sklearn --cov-report=html:coverage

test: test-code test-sphinxext test-doc

trailing-spaces:
	find sklearn -name "*.py" -exec perl -pi -e 's/[ \t]*$$//' {} \;

cython:
	python setup.py build_src

ctags:
	# make tags for symbol based navigation in emacs and vim
	# Install with: sudo apt-get install exuberant-ctags
	$(CTAGS) --python-kinds=-i -R sklearn

doc: inplace
	$(MAKE) -C doc html

doc-noplot: inplace
	$(MAKE) -C doc html-noplot

code-analysis:
	flake8 sklearn | grep -v __init__ | grep -v external
	pylint -E -i y sklearn/ -d E1103,E0611,E1101

flake8-diff:
	./build_tools/circle/flake8_diff.sh

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`pytest sklearn/tests/test_pipeline.py -q`

## Scope
`sklearn/pipeline.py`
`sklearn/tests/`

## Done when
- `len(pipe)` returns the number of steps in the `Pipeline`.
- `pipe[:len(pipe)]` no longer raises and returns a `Pipeline` containing all the original steps.
- Existing `Pipeline` indexing/slicing behavior continues to work.

## Approach
Add `__len__` to `Pipeline` returning `len(self.steps)`, which is the list of `(name, estimator)` pairs, so the existing `__getitem__`/slice logic and `pipe[:len(pipe)]` work unchanged.

Candidate approaches:
1. Minimal: define `__len__` only on `Pipeline`; smallest diff, matches the issue literally.
2. Upstream-style: define `__len__` on both `Pipeline` and `FeatureUnion` in `sklearn/pipeline.py` (returning `len(self.steps)` and `len(self.transformer_list)` respectively); slightly larger but consistent and likely what the tests exercise.
3. Broad: define `__len__` on `_BaseComposition` in `sklearn/base.py`; covers both subclasses automatically but changes shared base-class behavior beyond the prompt.

If the first attempt fails, verify the test expects the length of `steps` (and possibly `transformer_list` for `FeatureUnion`), and check that slicing still uses the same step sequence.
```

### `prompt.md`

````
Pipeline should implement __len__
#### Description

With the new indexing support `pipe[:len(pipe)]` raises an error.

#### Steps/Code to Reproduce

```python
from sklearn import svm
from sklearn.datasets import samples_generator
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression
from sklearn.pipeline import Pipeline

# generate some data to play with
X, y = samples_generator.make_classification(
    n_informative=5, n_redundant=0, random_state=42)

anova_filter = SelectKBest(f_regression, k=5)
clf = svm.SVC(kernel='linear')
pipe = Pipeline([('anova', anova_filter), ('svc', clf)])

len(pipe)
```

#### Versions

```
System:
    python: 3.6.7 | packaged by conda-forge | (default, Feb 19 2019, 18:37:23)  [GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]
executable: /Users/krisz/.conda/envs/arrow36/bin/python
   machine: Darwin-18.2.0-x86_64-i386-64bit

BLAS:
    macros: HAVE_CBLAS=None
  lib_dirs: /Users/krisz/.conda/envs/arrow36/lib
cblas_libs: openblas, openblas

Python deps:
       pip: 19.0.3
setuptools: 40.8.0
   sklearn: 0.21.dev0
     numpy: 1.16.2
     scipy: 1.2.1
    Cython: 0.29.6
    pandas: 0.24.1
```
````

### `review.md`

```
verdict: PASS

- `__len__` added to `Pipeline` in `sklearn/pipeline.py`, returning `len(self.steps)` — satisfies "len(pipe) returns the number of steps".
- `pipe[:len(pipe)]` now returns a `Pipeline` with all original steps (asserted `pipe3.steps == pipe.steps` in `test_pipeline_slice`); slicing no longer raises.
- Existing indexing/slicing behavior retained: the prior assertions (`pipe2`, `pipe['clf']`, IndexError/KeyError, reversed-slice ValueError) are untouched and still pass.
- Changes are confined to the scoped files (`sklearn/pipeline.py`, `sklearn/tests/test_pipeline.py`); no content removed, no unrelated behavior altered.
- Check `pytest sklearn/tests/test_pipeline.py -q` reports 41 passed, status 0.
```

### `scope.txt`

```
scope: sklearn/pipeline.py sklearn/tests
changed: sklearn/pipeline.py +5 -0
changed: sklearn/tests/test_pipeline.py +3 -0
```

### `task.md`

````
# Task

## Prompt

Pipeline should implement __len__
#### Description

With the new indexing support `pipe[:len(pipe)]` raises an error.

#### Steps/Code to Reproduce

```python
from sklearn import svm
from sklearn.datasets import samples_generator
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression
from sklearn.pipeline import Pipeline

# generate some data to play with
X, y = samples_generator.make_classification(
    n_informative=5, n_redundant=0, random_state=42)

anova_filter = SelectKBest(f_regression, k=5)
clf = svm.SVC(kernel='linear')
pipe = Pipeline([('anova', anova_filter), ('svc', clf)])

len(pipe)
```

#### Versions

```
System:
    python: 3.6.7 | packaged by conda-forge | (default, Feb 19 2019, 18:37:23)  [GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]
executable: /Users/krisz/.conda/envs/arrow36/bin/python
   machine: Darwin-18.2.0-x86_64-i386-64bit

BLAS:
    macros: HAVE_CBLAS=None
  lib_dirs: /Users/krisz/.conda/envs/arrow36/lib
cblas_libs: openblas, openblas

Python deps:
       pip: 19.0.3
setuptools: 40.8.0
   sklearn: 0.21.dev0
     numpy: 1.16.2
     scipy: 1.2.1
    Cython: 0.29.6
    pandas: 0.24.1
```

## Deliverable

changes to this tree

## Check

`pytest sklearn/tests/test_pipeline.py -q`

## Scope

`sklearn/pipeline.py`
`sklearn/tests/`

## Done when

- `len(pipe)` returns the number of steps in the `Pipeline`.
- `pipe[:len(pipe)]` no longer raises and returns a `Pipeline` containing all the original steps.
- Existing `Pipeline` indexing/slicing behavior continues to work.
````

### `test-output.log`

```
check: pytest sklearn/tests/test_pipeline.py -q
.........................................                                [100%]
41 passed, 2 warnings in 2.06s
scope: sklearn/pipeline.py sklearn/tests
changed: sklearn/pipeline.py +5 -0
changed: sklearn/tests/test_pipeline.py +3 -0
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
