# scikit-learn__scikit-learn-12973 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 79s 74 lines cost=0.004099 in=115496 cached=73728 out=7214 calls=14`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

LassoLarsIC: unintuitive copy_X behaviour
Hi, I would like to report what seems to be a bug in the treatment of the `copy_X` parameter of the `LassoLarsIC` class. Because it's a simple bug, it's much easier to see in the code directly than in the execution, so I am not posting steps to reproduce it.

As you can see here, LassoLarsIC accepts a copy_X parameter.
https://github.com/scikit-learn/scikit-learn/blob/7389dbac82d362f296dc2746f10e43ffa1615660/sklearn/linear_model/least_angle.py#L1487

However, it also takes a copy_X parameter a few lines below, in the definition of ```fit```.
    ```def fit(self, X, y, copy_X=True):```

Now there are two values (potentially contradicting each other) for copy_X and each one is used once. Therefore ```fit``` can have a mixed behaviour. Even worse, this can be completely invisible to the user, since copy_X has a default value of True. Let's assume that I'd like it to be False, and have set it to False in the initialization, `my_lasso = LassoLarsIC(copy_X=False)`. I then call ```my_lasso.fit(X, y)``` and my choice will be silently overwritten. 

Ideally I think that copy_X should be removed as an argument in ```fit```. No other estimator seems to have a duplication in class parameters and fit arguments (I've checked more than ten in the linear models module). However, this would break existing code. Therefore I propose that ```fit``` takes a default value of `None` and only overwrites the existing value if the user has explicitly passed it as an argument to ```fit```. I will submit a PR to that effect.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --short && git log -1 --oneline && ls"
}
```

**assistant → tool `glob`**

```json
{
  "pattern": "**/least_angle.py"
}
```

**tool result**

```
/testbed
?? .memdoor/
aae1ee060 SWE-bench
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
```

**tool result**

```
/testbed/sklearn/linear_model/least_angle.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"copy_X\" sklearn/linear_model/least_angle.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"copy_X\" sklearn/linear_model/tests/test_least_angle.py"
}
```

**tool result**

```
32:              alpha_min=0, method='lar', copy_X=True,
76:    copy_X : bool, optional (default=True)
176:        if copy_X:
530:    copy_X : boolean, optional, default True
578:    Lars(copy_X=True, eps=..., fit_intercept=True, fit_path=True,
594:                 eps=np.finfo(np.float).eps, copy_X=True, fit_path=True,
603:        self.copy_X = copy_X
621:            X, y, self.fit_intercept, self.normalize, self.copy_X)
640:                    X, y[:, k], Gram=Gram, Xy=this_Xy, copy_X=self.copy_X,
660:                    X, y[:, k], Gram=Gram, Xy=this_Xy, copy_X=self.copy_X,
761:    copy_X : boolean, optional, default True
812:    LassoLars(alpha=0.01, copy_X=True, eps=..., fit_intercept=True,
833:                 eps=np.finfo(np.float).eps, copy_X=True, fit_path=True,
842:        self.copy_X = copy_X
960:        X_train, y_train, Gram=Gram, copy_X=False, copy_Gram=False,
1035:    copy_X : boolean, optional, default True
1095:                 copy_X=True, positive=False):
1104:                         eps=eps, copy_X=copy_X, fit_path=True,
1124:        X = as_float_array(X, copy=self.copy_X)
1125:        y = as_float_array(y, copy=self.copy_X)
1258:    copy_X : boolean, optional, default True
1335:                 copy_X=True, positive=False):
1345:        self.copy_X = copy_X
1403:    copy_X : boolean, optional, default True
1447:    LassoLarsIC(copy_X=True, criterion='bic', eps=..., fit_intercept=True,
1470:                 eps=np.finfo(np.float).eps, copy_X=True, positive=False):
1477:        self.copy_X = copy_X
1482:    def fit(self, X, y, copy_X=True):
1493:        copy_X : boolean, optional, default True
1504:            X, y, self.fit_intercept, self.normalize, self.copy_X)
1510:            X, y, Gram=Gram, copy_X=copy_X, copy_Gram=True, alpha_min=0.0,
```

**tool result**

```
131:    _, _, coef_path_ = linear_model.lars_path(X, y, Gram='auto', copy_X=False,
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/linear_model/least_angle.py",
  "offset": 1390,
  "limit": 150
}
```

**tool result**

```
        matrix can also be passed as argument.

    max_iter : integer, optional
        Maximum number of iterations to perform. Can be used for
        early stopping.

    eps : float, optional
        The machine-precision regularization in the computation of the
        Cholesky diagonal factors. Increase this for very ill-conditioned
        systems. Unlike the ``tol`` parameter in some iterative
        optimization-based algorithms, this parameter does not control
        the tolerance of the optimization.

    copy_X : boolean, optional, default True
        If True, X will be copied; else, it may be overwritten.

    positive : boolean (default=False)
        Restrict coefficients to be >= 0. Be aware that you might want to
        remove fit_intercept which is set True by default.
        Under the positive restriction the model coefficients do not converge
        to the ordinary-least-squares solution for small values of alpha.
        Only coefficients up to the smallest alpha value (``alphas_[alphas_ >
        0.].min()`` when fit_path=True) reached by the stepwise Lars-Lasso
        algorithm are typically in congruence with the solution of the
        coordinate descent Lasso estimator.
        As a consequence using LassoLarsIC only makes sense for problems where
        a sparse solution is expected and/or reached.


    Attributes
    ----------
    coef_ : array, shape (n_features,)
        parameter vector (w in the formulation formula)

    intercept_ : float
        independent term in decision function.

    alpha_ : float
        the alpha parameter chosen by the information criterion

    n_iter_ : int
        number of iterations run by lars_path to find the grid of
        alphas.

    criterion_ : array, shape (n_alphas,)
        The value of the information criteria ('aic', 'bic') across all
        alphas. The alpha which has the smallest information criterion is
        chosen. This value is larger by a factor of ``n_samples`` compared to
        Eqns. 2.15 and 2.16 in (Zou et al, 2007).


    Examples
    --------
    >>> from sklearn import linear_model
    >>> reg = linear_model.LassoLarsIC(criterion='bic')
    >>> reg.fit([[-1, 1], [0, 0], [1, 1]], [-1.1111, 0, -1.1111])
    ... # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
    LassoLarsIC(copy_X=True, criterion='bic', eps=..., fit_intercept=True,
          max_iter=500, normalize=True, positive=False, precompute='auto',
          verbose=False)
    >>> print(reg.coef_) # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
    [ 0.  -1.11...]

    Notes
    -----
    The estimation of the number of degrees of freedom is given by:

    "On the degrees of freedom of the lasso"
    Hui Zou, Trevor Hastie, and Robert Tibshirani
    Ann. Statist. Volume 35, Number 5 (2007), 2173-2192.

    https://en.wikipedia.org/wiki/Akaike_information_criterion
    https://en.wikipedia.org/wiki/Bayesian_information_criterion

    See also
    --------
    lars_path, LassoLars, LassoLarsCV
    """
    def __init__(self, criterion='aic', fit_intercept=True, verbose=False,
                 normalize=True, precompute='auto', max_iter=500,
                 eps=np.finfo(np.float).eps, copy_X=True, positive=False):
        self.criterion = criterion
        self.fit_intercept = fit_intercept
        self.positive = positive
        self.max_iter = max_iter
        self.verbose = verbose
        self.normalize = normalize
        self.copy_X = copy_X
        self.precompute = precompute
        self.eps = eps
        self.fit_path = True

    def fit(self, X, y, copy_X=True):
        """Fit the model using X, y as training data.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)
            training data.

        y : array-like, shape (n_samples,)
            target values. Will be cast to X's dtype if necessary

        copy_X : boolean, optional, default True
            If ``True``, X will be copied; else, it may be overwritten.

        Returns
        -------
        self : object
            returns an instance of self.
        """
        X, y = check_X_y(X, y, y_numeric=True)

        X, y, Xmean, ymean, Xstd = LinearModel._preprocess_data(
            X, y, self.fit_intercept, self.normalize, self.copy_X)
        max_iter = self.max_iter

        Gram = self.precompute

        alphas_, active_, coef_path_, self.n_iter_ = lars_path(
            X, y, Gram=Gram, copy_X=copy_X, copy_Gram=True, alpha_min=0.0,
            method='lasso', verbose=self.verbose, max_iter=max_iter,
            eps=self.eps, return_n_iter=True, positive=self.positive)

        n_samples = X.shape[0]

        if self.criterion == 'aic':
            K = 2  # AIC
        elif self.criterion == 'bic':
            K = log(n_samples)  # BIC
        else:
            raise ValueError('criterion should be either bic or aic')

        R = y[:, np.newaxis] - np.dot(X, coef_path_)  # residuals
        mean_squared_error = np.mean(R ** 2, axis=0)
        sigma2 = np.var(y)

        df = np.zeros(coef_path_.shape[1], dtype=np.int)  # Degrees of freedom
        for k, coef in enumerate(coef_path_.T):
            mask = np.abs(coef) > np.finfo(coef.dtype).eps
            if not np.any(mask):
                continue
            # get the number of degrees of freedom equal to:
            # Xc = X[:, mask]
            # Trace(Xc * inv(Xc.T, Xc) * Xc.T) ie the number of non-zero coefs
            df[k] = np.sum(mask)

        self.alphas_ = alphas_
        eps64 = np.finfo('float64').eps
        self.criterion_ = (n_samples * mean_squared_error / (sigma2 + eps64) +

[7 more lines in /testbed/sklearn/linear_model/least_angle.py (1546 in all). read_file with offset: 1540 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sklearn/linear_model/least_angle.py\n@@\n-    def fit(self, X, y, copy_X=True):\n+    def fit(self, X, y, copy_X=None):\n         \"\"\"Fit the model using X, y as training data.\n \n         Parameters\n         ----------\n         X : array-like, shape (n_samples, n_features)\n             training data.\n \n         y : array-like, shape (n_samples,)\n             target values. Will be cast to X's dtype if necessary\n \n-        copy_X : boolean, optional, default True\n-            If ``True``, X will be copied; else, it may be overwritten.\n+        copy_X : boolean, optional, default None\n+            If ``True``, X will be copied; else, it may be overwritten.\n+            If None, the value of the constructor parameter ``copy_X`` is\n+            used.\n@@\n-        X, y = check_X_y(X, y, y_numeric=True)\n+        if copy_X is None:\n+            copy_X = self.copy_X\n+\n+        X, y = check_X_y(X, y, y_numeric=True)\n \n         X, y, Xmean, ymean, Xstd = LinearModel._preprocess_data(\n-            X, y, self.fit_intercept, self.normalize, self.copy_X)\n+            X, y, self.fit_intercept, self.normalize, copy_X)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sklearn/linear_model/least_angle.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sklearn/linear_model/least_angle.py now (1551 lines), around the change:
1479:        self.eps = eps
1480:        self.fit_path = True
1481:
1482:    def fit(self, X, y, copy_X=None):
1483:        """Fit the model using X, y as training data.
1484:
1485:        Parameters
…
1490:        y : array-like, shape (n_samples,)
1491:            target values. Will be cast to X's dtype if necessary
1492:
1493:        copy_X : boolean, optional, default None
1494:            If ``True``, X will be copied; else, it may be overwritten.
1495:            If None, the value of the constructor parameter ``copy_X`` is
1496:            used.
1497:
1498:        Returns
1499:        -------
1500:        self : object
1501:            returns an instance of self.
1502:        """
1503:        if copy_X is None:
1504:            copy_X = self.copy_X
1505:
1506:        X, y = check_X_y(X, y, y_numeric=True)
1507:
1508:        X, y, Xmean, ymean, Xstd = LinearModel._preprocess_data(
1509:            X, y, self.fit_intercept, self.normalize, copy_X)
1510:        max_iter = self.max_iter
1511:
1512:        Gram = self.precompute
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/linear_model/tests/test_least_angle.py -q 2>&1 | tail -20"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"def fit(.*copy_X\" sklearn/linear_model | head -30"
}
```

**tool result**

```
..............................                                           [100%]
30 passed, 4 warnings in 2.87s
```

**tool result**

```
sklearn/linear_model/least_angle.py:1482:    def fit(self, X, y, copy_X=None):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,40p' sklearn/linear_model/tests/test_least_angle.py && grep -n \"LassoLarsIC\" sklearn/linear_model/tests/test_least_angle.py"
}
```

**tool result**

```
import warnings

from distutils.version import LooseVersion

import numpy as np
from scipy import linalg

import pytest

from sklearn.model_selection import train_test_split
from sklearn.utils.testing import assert_equal
from sklearn.utils.testing import assert_array_almost_equal
from sklearn.utils.testing import assert_less
from sklearn.utils.testing import assert_greater
from sklearn.utils.testing import assert_raises
from sklearn.utils.testing import ignore_warnings
from sklearn.utils.testing import assert_warns
from sklearn.utils.testing import TempMemmap
from sklearn.exceptions import ConvergenceWarning
from sklearn import linear_model, datasets
from sklearn.linear_model.least_angle import _lars_path_residues

diabetes = datasets.load_diabetes()
X, y = diabetes.data, diabetes.target

# TODO: use another dataset that has multiple drops


def test_simple():
    # Principle of Lars is to keep covariances tied and decreasing

    # also test verbose output
    from io import StringIO
    import sys
    old_stdout = sys.stdout
    try:
        sys.stdout = StringIO()

        alphas_, active, coef_path_ = linear_model.lars_path(
            diabetes.data, diabetes.target, method="lar", verbose=10)
185:        [linear_model.Lars, linear_model.LarsCV, linear_model.LassoLarsIC])
449:    # Test the LassoLarsIC object by checking that
453:    lars_bic = linear_model.LassoLarsIC('bic')
454:    lars_aic = linear_model.LassoLarsIC('aic')
468:    lars_broken = linear_model.LassoLarsIC('<unknown>')
523:                           'LassoLarsIC': {}}
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/linear_model/tests/test_least_angle.py",
  "offset": 440,
  "limit": 50
}
```

**tool result**

```
        rng = np.random.RandomState(42)
        x = rng.randn(len(y))
        X = np.c_[X, x, x]  # add correlated features
        lars_cv = linear_model.LassoLarsCV(max_iter=5)
        lars_cv.fit(X, y)
    assert len(w) == 0


def test_lasso_lars_ic():
    # Test the LassoLarsIC object by checking that
    # - some good features are selected.
    # - alpha_bic > alpha_aic
    # - n_nonzero_bic < n_nonzero_aic
    lars_bic = linear_model.LassoLarsIC('bic')
    lars_aic = linear_model.LassoLarsIC('aic')
    rng = np.random.RandomState(42)
    X = diabetes.data
    y = diabetes.target
    X = np.c_[X, rng.randn(X.shape[0], 5)]  # add 5 bad features
    lars_bic.fit(X, y)
    lars_aic.fit(X, y)
    nonzero_bic = np.where(lars_bic.coef_)[0]
    nonzero_aic = np.where(lars_aic.coef_)[0]
    assert_greater(lars_bic.alpha_, lars_aic.alpha_)
    assert_less(len(nonzero_bic), len(nonzero_aic))
    assert_less(np.max(nonzero_bic), diabetes.data.shape[1])

    # test error on unknown IC
    lars_broken = linear_model.LassoLarsIC('<unknown>')
    assert_raises(ValueError, lars_broken.fit, X, y)


def test_lars_path_readonly_data():
    # When using automated memory mapping on large input, the
    # fold data is in read-only mode
    # This is a non-regression test for:
    # https://github.com/scikit-learn/scikit-learn/issues/4597
    splitted_data = train_test_split(X, y, random_state=42)
    with TempMemmap(splitted_data) as (X_train, X_test, y_train, y_test):
        # The following should not fail despite copy=False
        _lars_path_residues(X_train, y_train, X_test, y_test, copy=False)


@pytest.mark.filterwarnings('ignore: The default of the `iid`')  # 0.22
def test_lars_path_positive_constraint():
    # this is the main test for the positive parameter on the lars_path method
    # the estimator classes just make use of this function

    # we do the test on the diabetes dataset


[199 more lines in /testbed/sklearn/linear_model/tests/test_least_angle.py (688 in all). read_file with offset: 490 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sklearn/linear_model/tests/test_least_angle.py\n@@\n def test_lasso_lars_ic():\n@@\n     lars_broken = linear_model.LassoLarsIC('<unknown>')\n     assert_raises(ValueError, lars_broken.fit, X, y)\n \n \n+def test_lasso_lars_ic_copy_X():\n+    # Test that copy_X set in the constructor is used by fit, and that\n+    # an explicit copy_X passed to fit takes precedence.\n+    from sklearn.linear_model import least_angle\n+\n+    calls = []\n+    original_lars_path = least_angle.lars_path\n+\n+    def recording_lars_path(*args, **kwargs):\n+        calls.append(kwargs['copy_X'])\n+        return original_lars_path(*args, **kwargs)\n+\n+    least_angle.lars_path = recording_lars_path\n+    try:\n+        lars = linear_model.LassoLarsIC(copy_X=False)\n+        lars.fit(X, y)\n+        assert_equal(calls[-1], False)\n+\n+        lars.fit(X, y, copy_X=True)\n+        assert_equal(calls[-1], True)\n+    finally:\n+        least_angle.lars_path = original_lars_path\n+\n+\n def test_lars_path_readonly_data():\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sklearn/linear_model/tests/test_least_angle.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sklearn/linear_model/tests/test_least_angle.py now (712 lines), around the change:
469:    assert_raises(ValueError, lars_broken.fit, X, y)
470:
471:
472:def test_lasso_lars_ic_copy_X():
473:    # Test that copy_X set in the constructor is used by fit, and that
474:    # an explicit copy_X passed to fit takes precedence.
475:    from sklearn.linear_model import least_angle
476:
477:    calls = []
478:    original_lars_path = least_angle.lars_path
479:
480:    def recording_lars_path(*args, **kwargs):
481:        calls.append(kwargs['copy_X'])
482:        return original_lars_path(*args, **kwargs)
483:
484:    least_angle.lars_path = recording_lars_path
485:    try:
486:        lars = linear_model.LassoLarsIC(copy_X=False)
487:        lars.fit(X, y)
488:        assert_equal(calls[-1], False)
489:
490:        lars.fit(X, y, copy_X=True)
491:        assert_equal(calls[-1], True)
492:    finally:
493:        least_angle.lars_path = original_lars_path
494:
495:
496:def test_lars_path_readonly_data():
497:    # When using automated memory mapping on large input, the
498:    # fold data is in read-only mode
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/linear_model/tests/test_least_angle.py -q 2>&1 | tail -15"
}
```

**tool result**

```
...............................                                          [100%]
31 passed, 4 warnings in 1.68s
```

**assistant → tool `bash`**

```json
{
  "command": "git diff --stat && git diff sklearn/linear_model/least_angle.py"
}
```

**tool result**

```
 sklearn/linear_model/least_angle.py            | 11 ++++++++---
 sklearn/linear_model/tests/test_least_angle.py | 24 ++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 3 deletions(-)
diff --git a/sklearn/linear_model/least_angle.py b/sklearn/linear_model/least_angle.py
index 03b34a0dc..9772c12f5 100644
--- a/sklearn/linear_model/least_angle.py
+++ b/sklearn/linear_model/least_angle.py
@@ -1479,7 +1479,7 @@ class LassoLarsIC(LassoLars):
         self.eps = eps
         self.fit_path = True
 
-    def fit(self, X, y, copy_X=True):
+    def fit(self, X, y, copy_X=None):
         """Fit the model using X, y as training data.
 
         Parameters
@@ -1490,18 +1490,23 @@ class LassoLarsIC(LassoLars):
         y : array-like, shape (n_samples,)
             target values. Will be cast to X's dtype if necessary
 
-        copy_X : boolean, optional, default True
+        copy_X : boolean, optional, default None
             If ``True``, X will be copied; else, it may be overwritten.
+            If None, the value of the constructor parameter ``copy_X`` is
+            used.
 
         Returns
         -------
         self : object
             returns an instance of self.
         """
+        if copy_X is None:
+            copy_X = self.copy_X
+
         X, y = check_X_y(X, y, y_numeric=True)
 
         X, y, Xmean, ymean, Xstd = LinearModel._preprocess_data(
-            X, y, self.fit_intercept, self.normalize, self.copy_X)
+            X, y, self.fit_intercept, self.normalize, copy_X)
         max_iter = self.max_iter
 
         Gram = self.precompute
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/linear_model/tests/test_least_angle.py sklearn/tests/test_common.py -q -k \"lars or LassoLars\" 2>&1 | tail -20"
}
```

**tool result**

```
........................................................................ [ 35%]
........................................................................ [ 70%]
............................................................             [100%]
204 passed, 4929 deselected, 5 warnings in 7.81s
```

**assistant**

```
Implemented the fix.

**Change in `sklearn/linear_model/least_angle.py` (`LassoLarsIC.fit`):**
- Default signature changed from `fit(self, X, y, copy_X=True)` to `fit(self, X, y, copy_X=None)`.
- `None` means "unspecified": it resolves to `self.copy_X` (the constructor parameter) before any preprocessing.
- An explicit `copy_X` passed to `fit` still takes precedence, preserving existing behavior for callers who relied on the fit argument.
- Both uses (`_preprocess_data` and `lars_path`) now use the resolved single value, so the two can no longer disagree.
- Docstring updated to describe the `None` default.

**Test added in `test_least_angle.py` (`test_lasso_lars_ic_copy_X`):**
- Confirms `LassoLarsIC(copy_X=False).fit(X, y)` actually passes `copy_X=False` to `lars_path` (previously silently became `True`).
- Confirms an explicit `fit(..., copy_X=True)` overrides the constructor value.

Verification: full `test_least_angle.py` passes (31 tests), plus the common-estimator checks for Lars/LassoLars (204 passed).
```

## Run folder `team-solve-2026-11-06T115855`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
aae1ee060f3dc674573859f2f7cc2eba796786cd
```

### `baseline-check.log`

```
check: pytest sklearn/linear_model/tests/test_least_angle.py
============================= test session starts ==============================
platform linux -- Python 3.6.13, pytest-6.2.4, py-1.11.0, pluggy-0.13.1
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T115855/baseline-tree, configfile: setup.cfg
collected 0 items / 2 errors

==================================== ERRORS ====================================
_______ ERROR collecting sklearn/linear_model/tests/test_least_angle.py ________
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
sklearn/__init__.py:63: in <module>
    from . import __check_build
sklearn/__check_build/__init__.py:46: in <module>
    raise_build_error(e)
sklearn/__check_build/__init__.py:41: in raise_build_error
    %s""" % (e, local_dir, ''.join(dir_content).strip(), msg))
E   ImportError: No module named 'sklearn.__check_build._check_build'
E   ___________________________________________________________________________
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T115855/baseline-tree/sklearn/__check_build:
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
_______ ERROR collecting sklearn/linear_model/tests/test_least_angle.py ________
ImportError while importing test module '/testbed/.memdoor/runs/team-solve-2026-11-06T115855/baseline-tree/sklearn/linear_model/tests/test_least_angle.py'.
Hint: make sure your test modules/packages have valid Python names.
Traceback:
sklearn/__check_build/__init__.py:44: in <module>
    from ._check_build import check_build  # noqa
E   ModuleNotFoundError: No module named 'sklearn.__check_build._check_build'

During handling of the above exception, another exception occurred:
/opt/miniconda3/envs/testbed/lib/python3.6/importlib/__init__.py:126: in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
sklearn/__init__.py:63: in <module>
    from . import __check_build
sklearn/__check_build/__init__.py:46: in <module>
    raise_build_error(e)
sklearn/__check_build/__init__.py:41: in raise_build_error
    %s""" % (e, local_dir, ''.join(dir_content).strip(), msg))
E   ImportError: No module named 'sklearn.__check_build._check_build'
E   ___________________________________________________________________________
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T115855/baseline-tree/sklearn/__check_build:
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
============================== 2 errors in 0.27s ===============================
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/sklearn/linear_model/least_angle.py b/sklearn/linear_model/least_angle.py
index 03b34a0dc..9772c12f5 100644
--- a/sklearn/linear_model/least_angle.py
+++ b/sklearn/linear_model/least_angle.py
@@ -1479,7 +1479,7 @@ class LassoLarsIC(LassoLars):
         self.eps = eps
         self.fit_path = True
 
-    def fit(self, X, y, copy_X=True):
+    def fit(self, X, y, copy_X=None):
         """Fit the model using X, y as training data.
 
         Parameters
@@ -1490,18 +1490,23 @@ class LassoLarsIC(LassoLars):
         y : array-like, shape (n_samples,)
             target values. Will be cast to X's dtype if necessary
 
-        copy_X : boolean, optional, default True
+        copy_X : boolean, optional, default None
             If ``True``, X will be copied; else, it may be overwritten.
+            If None, the value of the constructor parameter ``copy_X`` is
+            used.
 
         Returns
         -------
         self : object
             returns an instance of self.
         """
+        if copy_X is None:
+            copy_X = self.copy_X
+
         X, y = check_X_y(X, y, y_numeric=True)
 
         X, y, Xmean, ymean, Xstd = LinearModel._preprocess_data(
-            X, y, self.fit_intercept, self.normalize, self.copy_X)
+            X, y, self.fit_intercept, self.normalize, copy_X)
         max_iter = self.max_iter
 
         Gram = self.precompute
diff --git a/sklearn/linear_model/tests/test_least_angle.py b/sklearn/linear_model/tests/test_least_angle.py
index 21496efa6..8d243ab12 100644
--- a/sklearn/linear_model/tests/test_least_angle.py
+++ b/sklearn/linear_model/tests/test_least_angle.py
@@ -469,6 +469,30 @@ def test_lasso_lars_ic():
     assert_raises(ValueError, lars_broken.fit, X, y)
 
 
+def test_lasso_lars_ic_copy_X():
+    # Test that copy_X set in the constructor is used by fit, and that
+    # an explicit copy_X passed to fit takes precedence.
+    from sklearn.linear_model import least_angle
+
+    calls = []
+    original_lars_path = least_angle.lars_path
+
+    def recording_lars_path(*args, **kwargs):
+        calls.append(kwargs['copy_X'])
+        return original_lars_path(*args, **kwargs)
+
+    least_angle.lars_path = recording_lars_path
+    try:
+        lars = linear_model.LassoLarsIC(copy_X=False)
+        lars.fit(X, y)
+        assert_equal(calls[-1], False)
+
+        lars.fit(X, y, copy_X=True)
+        assert_equal(calls[-1], True)
+    finally:
+        least_angle.lars_path = original_lars_path
+
+
 def test_lars_path_readonly_data():
     # When using automated memory mapping on large input, the
     # fold data is in read-only mode
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

LassoLarsIC: unintuitive copy_X behaviour
Hi, I would like to report what seems to be a bug in the treatment of the `copy_X` parameter of the `LassoLarsIC` class. Because it's a simple bug, it's much easier to see in the code directly than in the execution, so I am not posting steps to reproduce it.

As you can see here, LassoLarsIC accepts a copy_X parameter.
https://github.com/scikit-learn/scikit-learn/blob/7389dbac82d362f296dc2746f10e43ffa1615660/sklearn/linear_model/least_angle.py#L1487

However, it also takes a copy_X parameter a few lines below, in the definition of ```fit```.
    ```def fit(self, X, y, copy_X=True):```

Now there are two values (potentially contradicting each other) for copy_X and each one is used once. Therefore ```fit``` can have a mixed behaviour. Even worse, this can be completely invisible to the user, since copy_X has a default value of True. Let's assume that I'd like it to be False, and have set it to False in the initialization, `my_lasso = LassoLarsIC(copy_X=False)`. I then call ```my_lasso.fit(X, y)``` and my choice will be silently overwritten. 

Ideally I think that copy_X should be removed as an argument in ```fit```. No other estimator seems to have a duplication in class parameters and fit arguments (I've checked more than ten in the linear models module). However, this would break existing code. Therefore I propose that ```fit``` takes a default value of `None` and only overwrites the existing value if the user has explicitly passed it as an argument to ```fit```. I will submit a PR to that effect.

## Deliverable

Changes to this tree.

## Check

`pytest sklearn/linear_model/tests/test_least_angle.py`

## Scope

`sklearn/linear_model/least_angle.py`
`sklearn/linear_model/tests/`

## Done when

- `LassoLarsIC.fit` uses `copy_X=None` as its default instead of `True`.
- `LassoLarsIC(copy_X=False).fit(X, y)` keeps and uses the constructor’s `copy_X=False` value.
- Passing `copy_X` explicitly to `fit` still takes precedence for that fit.
- (inferred) The `fit` docstring reflects the `None` sentinel and precedence rules.
- (inferred) A regression test covers constructor-versus-fit `copy_X` precedence.



# plan.md

## Deliverable
Changes to this tree.

## Check
`pytest sklearn/linear_model/tests/test_least_angle.py`

## Scope
`sklearn/linear_model/least_angle.py`
`sklearn/linear_model/tests/`

## Done when
- `LassoLarsIC.fit` uses `copy_X=None` as its default instead of `True`.
- `LassoLarsIC(copy_X=False).fit(X, y)` keeps and uses the constructor’s `copy_X=False` value.
- Passing `copy_X` explicitly to `fit` still takes precedence for that fit.
- (inferred) The `fit` docstring reflects the `None` sentinel and precedence rules.
- (inferred) A regression test covers constructor-versus-fit `copy_X` precedence.

## Approach
Change `least_angle.py` so `fit` resolves `copy_X` locally: use the explicit `fit` argument when it is not `None`, otherwise fall back to `self.copy_X`, then pass the resolved value to the internal fit path. Add a focused regression test in the existing least-angle tests.

Candidate fallbacks:
1. Remove `copy_X` from `fit` entirely and use only `self.copy_X`; cleaner API, but breaks callers passing `fit(..., copy_X=...)`.
2. Use a private sentinel instead of `None`; avoids ambiguity if `None` ever becomes meaningful, but is unnecessary for a boolean option.
3. Deprecate the `fit` argument first; safest for API compatibility but does not fix the silent override immediately.


# sklearn/linear_model/least_angle.py

```
"""
Least Angle Regression algorithm. See the documentation on the
Generalized Linear Model for a complete discussion.
"""
from __future__ import print_function

# Author: Fabian Pedregosa <fabian.pedregosa@inria.fr>
#         Alexandre Gramfort <alexandre.gramfort@inria.fr>
#         Gael Varoquaux
#
# License: BSD 3 clause

from math import log
import sys
import warnings

import numpy as np
from scipy import linalg, interpolate
from scipy.linalg.lapack import get_lapack_funcs

from .base import LinearModel
from ..base import RegressorMixin
from ..utils import arrayfuncs, as_float_array, check_X_y
from ..model_selection import check_cv
from ..exceptions import ConvergenceWarning
from ..utils._joblib import Parallel, delayed

solve_triangular_args = {'check_finite': False}


def lars_path(X, y, Xy=None, Gram=None, max_iter=500,
              alpha_min=0, method='lar', copy_X=True,
              eps=np.finfo(np.float).eps,
              copy_Gram=True, verbose=0, return_path=True,
              return_n_iter=False, positive=False):
    """Compute Least Angle Regression or Lasso path using LARS algorithm [1]

    The optimization objective for the case method='lasso' is::

    (1 / (2 * n_samples)) * ||y - Xw||^2_2 + alpha * ||w||_1

    in the case of method='lars', the objective function is only known in
    the form of an implicit equation (see discussion in [1])

    Read more in the :ref:`User Guide <least_angle_regression>`.

    Parameters
    -----------
    X : array, shape: (n_samples, n_features)
        Input data.

    y : array, shape: (n_samples)
        Input targets.

    Xy : array-like, shape (n_samples,) or (n_samples, n_targets), \
            optional
        Xy = np.dot(X.T, y) that can be precomputed. It is useful
        only when the Gram matrix is precomputed.

    Gram : None, 'auto', array, shape: (n_features, n_features), optional
        Precomputed Gram matrix (X' * X), if ``'auto'``, the Gram
        matrix is precomputed from the given X, if there are more samples
        than features.

    max_iter : integer, optional (default=500)
        Maximum number of iterations to perform, set to infinity for no limit.

    alpha_min : float, optional (default=0)
        Minimum correlation along the path. It corresponds to the
        regularization parameter alpha parameter in the Lasso.

    method : {'lar', 'lasso'}, optional (default='lar')
        Specifies the returned model. Select ``'lar'`` for Least Angle
        Regression, ``'lasso'`` for the Lasso.

    copy_X : bool, optional (default=True)
        If ``False``, ``X`` is overwritten.

    eps : float, optional (default=``np.finfo(np.float).eps``)
        The machine-precision regularization in the computation of the
        Cholesky diagonal factors. Increase this for very ill-conditioned
        systems.

    copy_Gram : bool, optional (default=True)
        If ``False``, ``Gram`` is overwritten.

    verbose : int (default=0)
        Controls output verbosity.

    return_path : bool, optional (default=True)
        If ``return_path==True`` returns the entire path, else returns only the
        last point of the path.

    return_n_iter : bool, optional (default=False)
        Whether to return the number of iterations.

    positive : boolean (default=False)
        Restrict coefficients to be >= 0.
        This option is only allowed with method 'lasso'. Note that the model
        coefficients will not converge to the ordinary-least-squares solution
        for small values of alpha. Only coefficients up to the smallest alpha
        value (``alphas_[alphas_ > 0.].min()`` when fit_path=True) reached by
        the stepwise Lars-Lasso algorithm are typically in congruence with the
        solution of the coordinate descent lasso_path function.

    Returns
    --------
    alphas : array, shape: [n_alphas + 1]
        Maximum of covariances (in absolute value) at each iteration.
        ``n_alphas`` is either ``max_iter``, ``n_features`` or the
        number of nodes in the path with ``alpha >= alpha_min``, whichever
        is smaller.

    active : array, shape [n_alphas]
        Indices of active variables at the end of the path.

    coefs : array, shape (n_features, n_alphas + 1)
        Coefficients along the path

    n_iter : int
        Number of iterations run. Returned only if return_n_iter is set
        to True.

    See also
    --------
    lasso_path
    LassoLars
    Lars
    LassoLarsCV
    LarsCV
    sklearn.decomposition.sparse_encode

    References
    ----------
    .. [1] "Least Angle Regression", Effron et al.
           https://statweb.stanford.edu/~tibs/ftp/lars.pdf

    .. [2] `Wikipedia entry on the Least-angle regression
           <https://en.wikipedia.org/wiki/Least-angle_regression>`_

    .. [3] `Wikipedia entry on the Lasso
           <https://en.wikipedia.org/wiki/Lasso_(statistics)>`_

    """
    if method == 'lar' and positive:
        warnings.warn('positive option is broken for Least'
                      ' Angle Regression (LAR). Use method="lasso".'
                      ' This option will be removed in version 0.22.',
                      DeprecationWarning)

    n_features = X.shape[1]
    n_samples = y.size
    max_features = min(max_iter, n_features)

    if return_path:
        coefs = np.zeros((max_features + 1, n_features))
        alphas = np.zeros(max_features + 1)
    else:
        coef, prev_coef = np.zeros(n_features), np.zeros(n_features)
        alpha, prev_alpha = np.array([0.]), np.array([0.])  # better ideas?

    n_iter, n_active = 0, 0
    active, indices = list(), np.arange(n_features)
    # holds the sign of covariance
    sign_active = np.empty(max_features, dtype=np.int8)
    drop = False

    # will hold the cholesky factorization. Only lower part is
    # referenced.
    L = np.empty((max_features, max_features), dtype=X.dtype)
    swap, nrm2 = linalg.get_blas_funcs(('swap', 'nrm2'), (X,))
    solve_cholesky, = get_lapack_funcs(('potrs',), (X,))

    if Gram is None or Gram is False:
        Gram = None
        if copy_X:
            # force copy. setting the array to be fortran-ordered
            # speeds up the calculation of the (partial) Gram matrix
            # and allows to easily swap columns
            X = X.copy('F')

    elif isinstance(Gram, str) and Gram == 'auto' or Gram is True:
        if Gram is True or X.shape[0] > X.shape[1]:
            Gram = np.dot(X.T, X)
        else:
            Gram = None
    elif copy_Gram:
        Gram = Gram.copy()

    if Xy is None:
        Cov = np.dot(X.T, y)
    else:
        Cov = Xy.copy()

    if verbose:
        if verbose > 1:
            print("Step\t\tAdded\t\tDropped\t\tActive set size\t\tC")
        else:
            sys.stdout.write('.')
            sys.stdout.flush()

    tiny32 = np.finfo(np.float32).tiny  # to avoid division by 0 warning
    equality_tolerance = np.finfo(np.float32).eps

    while True:
        if Cov.size:
            if positive:
                C_idx = np.argmax(Cov)
            else:
                C_idx = np.argmax(np.abs(Cov))

            C_ = Cov[C_idx]

            if positive:
                C = C_
            else:
                C = np.fabs(C_)
        else:
            C = 0.

        if return_path:
            alpha = alphas[n_iter, np.newaxis]
            coef = coefs[n_iter]
            prev_alpha = alphas[n_iter - 1, np.newaxis]
            prev_coef = coefs[n_iter - 1]

        alpha[0] = C / n_samples
        if alpha[0] <= alpha_min + equality_tolerance:  # early stopping
            if abs(alpha[0] - alpha_min) > equality_tolerance:
                # interpolation factor 0 <= ss < 1
                if n_iter > 0:
                    # In the first iteration, all alphas are zero, the formula
                    # below would make ss a NaN
                    ss = ((prev_alpha[0] - alpha_min) /
                          (prev_alpha[0] - alpha[0]))
                    coef[:] = prev_coef + ss * (coef - prev_coef)
                alpha[0] = alpha_min
            if return_path:
                coefs[n_iter] = coef
            break

        if n_iter >= max_iter or n_active >= n_features:
            break

        if not drop:

            ##########################################################
            # Append x_j to the Cholesky factorization of (Xa * Xa') #
            #                                                        #
            #            ( L   0 )                                   #
            #     L  ->  (       )  , where L * w = Xa' x_j          #
            #            ( w   z )    and z = ||x_j||                #
            #                                                        #
            ##########################################################

            if positive:
                sign_active[n_active] = np.ones_like(C_)
            else:
                sign_active[n_active] = np.sign(C_)
            m, n = n_active, C_idx + n_active

            Cov[C_idx], Cov[0] = swap(Cov[C_idx], Cov[0])
            indices[n], indices[m] = indices[m], indices[n]
            Cov_not_shortened = Cov
            Cov = Cov[1:]  # remove Cov[0]

            if Gram is None:
                X.T[n], X.T[m] = swap(X.T[n], X.T[m])
                c = nrm2(X.T[n_active]) ** 2
                L[n_active, :n_active] = \
                    np.dot(X.T[n_active], X.T[:n_active].T)
            else:
                # swap does only work inplace if matrix is fortran
                # contiguous ...
                Gram[m], Gram[n] = swap(Gram[m], Gram[n])
                Gram[:, m], Gram[:, n] = swap(Gram[:, m], Gram[:, n])
                c = Gram[n_active, n_active]
                L[n_active, :n_active] = Gram[n_active, :n_active]

            # Update the cholesky decomposition for the Gram matrix
            if n_active:
                linalg.solve_triangular(L[:n_active, :n_active],
                                        L[n_active, :n_active],
                                        trans=0, lower=1,
                                        overwrite_b=True,
                                        **solve_triangular_args)

            v = np.dot(L[n_active, :n_active], L[n_active, :n_active])
            diag = max(np.sqrt(np.abs(c - v)), eps)
            L[n_active, n_active] = diag

            if diag < 1e-7:
                # The system is becoming too ill-conditioned.
                # We have degenerate vectors in our active set.
                # We'll 'drop for good' the last regressor added.

                # Note: this case is very rare. It is no longer triggered by
                # the test suite. The `equality_tolerance` margin added in 0.16
                # to get early stopping to work consistently on all versions of
                # Python including 32 bit Python under Windows seems to make it
                # very difficult to trigger the 'drop for good' strategy.
                warnings.warn('Regressors in active set degenerate. '
                              'Dropping a regressor, after %i iterations, '
                              'i.e. alpha=%.3e, '
                              'with an active set of %i regressors, and '
                              'the smallest cholesky pivot element being %.3e.'
                              ' Reduce max_iter or increase eps parameters.'
                              % (n_iter, alpha, n_active, diag),
                              ConvergenceWarning)

                # XXX: need to figure a 'drop for good' way
                Cov = Cov_not_shortened
                Cov[0] = 0
                Cov[C_idx], Cov[0] = swap(Cov[C_idx], Cov[0])
                continue

            active.append(indices[n_active])
            n_active += 1

            if verbose > 1:
                print("%s\t\t%s\t\t%s\t\t%s\t\t%s" % (n_iter, active[-1], '',
                                                      n_active, C))

        if method == 'lasso' and n_iter > 0 and prev_alpha[0] < alpha[0]:
            # alpha is increasing. This is because the updates of Cov are
            # bringing in too much numerical error that is greater than
            # than the remaining correlation with the
            # regressors. Time to bail out
            warnings.warn('Early stopping the lars path, as the residues '
                          'are small and the current value of alpha is no '
                          'longer well controlled. %i iterations, alpha=%.3e, '
                          'previous alpha=%.3e, with an active set of %i '
                          'regressors.'
                          % (n_iter, alpha, prev_alpha, n_active),
                          ConvergenceWarning)
            break

        # least squares solution
        least_squares, info = solve_cholesky(L[:n_active, :n_active],
                                             sign_active[:n_active],
                                             lower=True)

        if least_squares.size == 1 and least_squares == 0:
            # This happens because sign_active[:n_active] = 0
            least_squares[...] = 1
            AA = 1.
        else:
            # is this really needed ?
            AA = 1. / np.sqrt(np.sum(least_squares * sign_active[:n_active]))

            if not np.isfinite(AA):
                # L is too ill-conditioned
                i = 0
                L_ = L[:n_active, :n_active].copy()
                while not np.isfinite(AA):
                    L_.flat[::n_active + 1] += (2 ** i) * eps
                    least_squares, info = solve_cholesky(
                        L_, sign_active[:n_active], lower=True)
                    tmp = max(np.sum(least_squares * sign_active[:n_active]),
                              eps)
                    AA = 1. / np.sqrt(tmp)
                    i += 1
            least_squares *= AA

        if Gram is None:
            # equiangular direction of variables in the active set
            eq_dir = np.dot(X.T[:n_active].T, least_squares)
            # correlation between each unactive variables and
            # eqiangular vector
            corr_eq_dir = np.dot(X.T[n_active:], eq_dir)
        else:
            # if huge number of features, this takes 50% of time, I
            # think could be avoided if we just update it using an
            # orthogonal (QR) decomposition of X
            corr_eq_dir = np.dot(Gram[:n_active, n_active:].T,
                                 least_squares)

        g1 = arrayfuncs.min_pos((C - Cov) / (AA - corr_eq_dir + tiny32))
        if positive:
            gamma_ = min(g1, C / AA)
        else:
            g2 = arrayfuncs.min_pos((C + Cov) / (AA + corr_eq_dir + tiny32))
            gamma_ = min(g1, g2, C / AA)

        # TODO: better names for these variables: z
        drop = False
        z = -coef[active] / (least_squares + tiny32)
        z_pos = arrayfuncs.min_pos(z)
        if z_pos < gamma_:
            # some coefficients have changed sign
            idx = np.where(z == z_pos)[0][::-1]

            # update the sign, important for LAR
            sign_active[idx] = -sign_active[idx]

            if method == 'lasso':
                gamma_ = z_pos
            drop = True

        n_iter += 1

        if return_path:
            if n_iter >= coefs.shape[0]:
                del coef, alpha, prev_alpha, prev_coef
                # resize the coefs and alphas array
                add_features = 2 * max(1, (max_features - n_active))
                coefs = np.resize(coefs, (n_iter + add_features, n_features))
                coefs[-add_features:] = 0
                alphas = np.resize(alphas, n_iter + add_features)
                alphas[-add_features:] = 0
            coef = coefs[n_iter]
            prev_coef = coefs[n_iter - 1]
        else:
            # mimic the effect of incrementing n_iter on the array references
            prev_coef = coef
            prev_alpha[0] = alpha[0]
            coef = np.zeros_like(coef)

        coef[active] = prev_coef[active] + gamma_ * least_squares

        # update correlations
        Cov -= gamma_ * corr_eq_dir

        # See if any coefficient has changed sign
        if drop and method == 'lasso':

            # handle the case when idx is not length of 1
            [arrayfuncs.cholesky_delete(L[:n_active, :n_active], ii) for ii in
                idx]

            n_active -= 1
            # handle the case when idx is not length of 1
            drop_idx = [active.pop(ii) for ii in idx]

            if Gram is None:
                # propagate dropped variable
                for ii in idx:
                    for i in range(ii, n_active):
                        X.T[i], X.T[i + 1] = swap(X.T[i], X.T[i + 1])
                        # yeah this is stupid
                        indices[i], indices[i + 1] = indices[i + 1], indices[i]

                # TODO: this could be updated
                residual = y - np.dot(X[:, :n_active], coef[active])
                temp = np.dot(X.T[n_active], residual)

                Cov = np.r_[temp, Cov]
            else:
                for ii in idx:
                    for i in range(ii, n_active):
                        indices[i], indices[i + 1] = indices[i + 1], indices[i]
                        Gram[i], Gram[i + 1] = swap(Gram[i], Gram[i + 1])
                        Gram[:, i], Gram[:, i + 1] = swap(Gram[:, i],
                                                          Gram[:, i + 1])

                # Cov_n = Cov_j + x_j * X + increment(betas) TODO:
                # will this still work with multiple drops ?

                # recompute covariance. Probably could be done better
                # wrong as Xy is not swapped with the rest of variables

                # TODO: this could be updated
                residual = y - np.dot(X, coef)
                temp = np.dot(X.T[drop_idx], residual)
                Cov = np.r_[temp, Cov]

            sign_active = np.delete(sign_active, idx)
            sign_active = np.append(sign_active, 0.)  # just to maintain size
            if verbose > 1:
                print("%s\t\t%s\t\t%s\t\t%s\t\t%s" % (n_iter, '', drop_idx,
                                                      n_active, abs(temp)))

    if return_path:
        # resize coefs in case of early stop
        alphas = alphas[:n_iter + 1]
        coefs = coefs[:n_iter + 1]

        if return_n_iter:
            return alphas, active, coefs.T, n_iter
        else:
            return alphas, active, coefs.T
    else:
        if return_n_iter:
            return alpha, active, coef, n_iter
        else:
            return alpha, active, coef


###############################################################################
# Estimator classes

class Lars(LinearModel, RegressorMixin):
    """Least Angle Regression model a.k.a. LAR

    Read more in the :ref:`User Guide <least_angle_regression>`.

    Parameters
    ----------
    fit_intercept : boolean
        Whether to calculate the intercept for this model. If set
        to false, no intercept will be used in calculations
        (e.g. data is expected to be already centered).

    verbose : boolean or integer, optional
        Sets the verbosity amount

    normalize : boolean, optional, default True
        This parameter is ignored when ``fit_intercept`` is set to False.
        If True, the regressors X will be normalized before regression by
        subtracting the mean and dividing by the l2-norm.
        If you wish to standardize, please use
        :class:`sklearn.preprocessing.StandardScaler` before calling ``fit``
        on an estimator with ``normalize=False``.

    precompute : True | False | 'auto' | array-like
        Whether to use a precomputed Gram matrix to speed up
        calculations. If set to ``'auto'`` let us decide. The Gram
        matrix can also be passed as argument.

    n_nonzero_coefs : int, optional
        Target number of non-zero coefficients. Use ``np.inf`` for no limit.

    eps : float, optional
        The machine-precision regularization in the computation of the
        Cholesky diagonal factors. Increase this for very ill-conditioned
        systems. Unlike the ``tol`` parameter in some iterative
        optimization-based algorithms, this parameter does not control
        the tolerance of the optimization.

    copy_X : boolean, optional, default True
        If ``True``, X will be copied; else, it may be overwritten.

    fit_path : boolean
        If True the full path is stored in the ``coef_path_`` attribute.
        If you compute the solution for a large problem or many targets,
        setting ``fit_path`` to ``False`` will lead to a speedup, especially
        with a small alpha.

    positive : boolean (default=False)
        Restrict coefficients to be >= 0. Be aware that you might want to
        remove fit_intercept which is set True by default.

        .. deprecated:: 0.20

            The option is broken and deprecated. It will be removed in v0.22.

    Attributes
    ----------
    alphas_ : array, shape (n_alphas + 1,) | list of n_targets such arrays
        Maximum of covariances (in absolute value) at each iteration. \
        ``n_alphas`` is either ``n_nonzero_coefs`` or ``n_features``, \
        whichever is smaller.

    active_ : list, length = n_alphas | list of n_targets such lists
        Indices of active variables at the end of the path.

    coef_path_ : array, shape (n_features, n_alphas + 1) \
        | list of n_targets such arrays
        The varying values of the coefficients along the path. It is not
        present if the ``fit_path`` parameter is ``False``.

    coef_ : array, shape (n_features,) or (n_targets, n_features)
        Parameter vector (w in the formulation formula).

    intercept_ : float | array, shape (n_targets,)
        Independent term in decision function.

    n_iter_ : array-like or int
        The number of iterations taken by lars_path to find the
        grid of alphas for each target.

    Examples
    --------
    >>> from sklearn import linear_model
    >>> reg = linear_model.Lars(n_nonzero_coefs=1)
    >>> reg.fit([[-1, 1], [0, 0], [1, 1]], [-1.1111, 0, -1.1111])
    ... # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
    Lars(copy_X=True, eps=..., fit_intercept=True, fit_path=True,
       n_nonzero_coefs=1, normalize=True, positive=False, precompute='auto',
       verbose=False)
    >>> print(reg.coef_) # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
    [ 0. -1.11...]

    See also
    --------
    lars_path, LarsCV
    sklearn.decomposition.sparse_encode

    """
    method = 'lar'

    def __init__(self, fit_intercept=True, verbose=False, normalize=True,
                 precompute='auto', n_nonzero_coefs=500,
                 eps=np.finfo(np.float).eps, copy_X=True, fit_path=True,
                 positive=False):
        self.fit_intercept = fit_intercept
        self.verbose = verbose
        self.normalize = normalize
        self.precompute = precompute
        self.n_nonzero_coefs = n_nonzero_coefs
        self.positive = positive
        self.eps = eps
        self.copy_X = copy_X
        self.fit_path = fit_path

    @staticmethod
    def _get_gram(precompute, X, y):
        if (not hasattr(precompute, '__array__')) and (
                (precompute is True) or
                (precompute == 'auto' and X.shape[0] > X.shape[1]) or
                (precompute == 'auto' and y.shape[1] > 1)):
            precompute = np.dot(X.T, X)

        return precompute

    def _fit(self, X, y, max_iter, alpha, fit_path, Xy=None):
        """Auxiliary method to fit the model using X, y as training data"""
        n_features = X.shape[1]

        X, y, X_offset, y_offset, X_scale = self._preprocess_data(
            X, y, self.fit_intercept, self.normalize, self.copy_X)

        if y.ndim == 1:
            y = y[:, np.newaxis]

        n_targets = y.shape[1]

        Gram = self._get_gram(self.precompute, X, y)

        self.alphas_ = []
        self.n_iter_ = []
        self.coef_ = np.empty((n_targets, n_features))

        if fit_path:
            self.active_ = []
            self.coef_path_ = []
            for k in range(n_targets):
                this_Xy = None if Xy is None else Xy[:, k]
                alphas, active, coef_path, n_iter_ = lars_path(
                    X, y[:, k], Gram=Gram, Xy=this_Xy, copy_X=self.copy_X,
                    copy_Gram=True, alpha_min=alpha, method=self.method,
                    verbose=max(0, self.verbose - 1), max_iter=max_iter,
                    eps=self.eps, return_path=True,
                    return_n_iter=True, positive=self.positive)
                self.alphas_.append(alphas)
                self.active_.append(active)
                self.n_iter_.append(n_iter_)
                self.coef_path_.append(coef_path)
                self.coef_[k] = coef_path[:, -1]

            if n_targets == 1:
                self.alphas_, self.active_, self.coef_path_, self.coef_ = [
                    a[0] for a in (self.alphas_, self.active_, self.coef_path_,
                                   self.coef_)]
                self.n_iter_ = self.n_iter_[0]
        else:
            for k in range(n_targets):
                this_Xy = None if Xy is None else Xy[:, k]
                alphas, _, self.coef_[k], n_iter_ = lars_path(
                    X, y[:, k], Gram=Gram, Xy=this_Xy, copy_X=self.copy_X,
                    copy_Gram=True, alpha_min=alpha, method=self.method,
                    verbose=max(0, self.verbose - 1), max_iter=max_iter,
                    eps=self.eps, return_path=False, return_n_iter=True,
                    positive=self.positive)
                self.alphas_.append(alphas)
                self.n_iter_.append(n_iter_)
            if n_targets == 1:
                self.alphas_ = self.alphas_[0]
                self.n_iter_ = self.n_iter_[0]

        self._set_intercept(X_offset, y_offset, X_scale)
        return self

    def fit(self, X, y, Xy=None):
        """Fit the model using X, y as training data.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)
            Training data.

        y : array-like, shape (n_samples,) or (n_samples, n_targets)
            Target values.

        Xy : array-like, shape (n_samples,) or (n_samples, n_targets), \
                optional
            Xy = np.dot(X.T, y) that can be precomputed. It is useful
            only when the Gram matrix is precomputed.

        Returns
        -------
        self : object
            returns an instance of self.
        """
        X, y = check_X_y(X, y, y_numeric=True, multi_output=True)

        alpha = getattr(self, 'alpha', 0.)
        if hasattr(self, 'n_nonzero_coefs'):
            alpha = 0.  # n_nonzero_coefs parametrization takes priority
            max_iter = self.n_nonzero_coefs
        else:
            max_iter = self.max_iter

        self._fit(X, y, max_iter=max_iter, alpha=alpha, fit_path=self.fit_path,
                  Xy=Xy)

        return self


class LassoLars(Lars):
    """Lasso model fit with Least Angle Regression a.k.a. Lars

    It is a Linear Model trained with an L1 prior as regularizer.

    The optimization objective for Lasso is::

    (1 / (2 * n_samples)) * ||y - Xw||^2_2 + alpha * ||w||_1

    Read more in the :ref:`User Guide <least_angle_regression>`.

    Parameters
    ----------
    alpha : float
        Constant that multiplies the penalty term. Defaults to 1.0.
        ``alpha = 0`` is equivalent to an ordinary least square, solved
        by :class:`LinearRegression`. For numerical reasons, using
        ``alpha = 0`` with the LassoLars object is not advised and you
        should prefer the LinearRegression object.

    fit_intercept : boolean
        whether to calculate the intercept for this model. If set
        to false, no intercept will be used in calculations
        (e.g. data is expected to be already centered).

    verbose : boolean or integer, optional
        Sets the verbosity amount

    normalize : boolean, optional, default True
        This parameter is ignored when ``fit_intercept`` is set to False.
        If True, the regressors X will be normalized before regression by
        subtracting the mean and dividing by the l2-norm.
        If you wish to standardize, please use
        :class:`sklearn.preprocessing.StandardScaler` before calling ``fit``
        on an estimator with ``normalize=False``.

    precompute : True | False | 'auto' | array-like
        Whether to use a precomputed Gram matrix to speed up
        calculations. If set to ``'auto'`` let us decide. The Gram
        matrix can also be passed as argument.

    max_iter : integer, optional
        Maximum number of iterations to perform.

    eps : float, optional
        The machine-precision regularization in the computation of the
        Cholesky diagonal factors. Increase this for very ill-conditioned
        systems. Unlike the ``tol`` parameter in some iterative
        optimization-based algorithms, this parameter does not control
        the tolerance of the optimization.

    copy_X : boolean, optional, default True
        If True, X will be copied; else, it may be overwritten.

    fit_path : boolean
        If ``True`` the full path is stored in the ``coef_path_`` attribute.
        If you compute the solution for a large problem or many targets,
        setting ``fit_path`` to ``False`` will lead to a speedup, especially
        with a small alpha.

    positive : boolean (default=False)
        Restrict coefficients to be >= 0. Be aware that you might want to
        remove fit_intercept which is set True by default.
        Under the positive restriction the model coefficients will not converge
        to the ordinary-least-squares solution for small values of alpha.
        Only coefficients up to the smallest alpha value (``alphas_[alphas_ >
        0.].min()`` when fit_path=True) reached by the stepwise Lars-Lasso
        algorithm are typically in congruence with the solution of the
        coordinate descent Lasso estimator.

    Attributes
    ----------
    alphas_ : array, shape (n_alphas + 1,) | list of n_targets such arrays
        Maximum of covariances (in absolute value) at each iteration. \
        ``n_alphas`` is either ``max_iter``, ``n_features``, or the number of \
        nodes in the path with correlation greater than ``alpha``, whichever \
        is smaller.

    active_ : list, length = n_alphas | list of n_targets such lists
        Indices of active variables at the end of the path.

    coef_path_ : array, shape (n_features, n_alphas + 1) or list
        If a list is passed it's expected to be one of n_targets such arrays.
        The varying values of the coefficients along the path. It is not
        present if the ``fit_path`` parameter is ``False``.

    coef_ : array, shape (n_features,) or (n_targets, n_features)
        Parameter vector (w in the formulation formula).

    intercept_ : float | array, shape (n_targets,)
        Independent term in decision function.

    n_iter_ : array-like or int.
        The number of iterations taken by lars_path to find the
        grid of alphas for each target.

    Examples
    --------
    >>> from sklearn import linear_model
    >>> reg = linear_model.LassoLars(alpha=0.01)
    >>> reg.fit([[-1, 1], [0, 0], [1, 1]], [-1, 0, -1])
    ... # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
    LassoLars(alpha=0.01, copy_X=True, eps=..., fit_intercept=True,
         fit_path=True, max_iter=500, normalize=True, positive=False,
         precompute='auto', verbose=False)
    >>> print(reg.coef_) # doctest: +ELLIPSIS, +NORMALIZE_WHITESPACE
    [ 0.         -0.963257...]

    See also
    --------
    lars_path
    lasso_path
    Lasso
    LassoCV
    LassoLarsCV
    LassoLarsIC
    sklearn.decomposition.sparse_encode

    """
    method = 'lasso'

    def __init__(self, alpha=1.0, fit_intercept=True, verbose=False,
                 normalize=True, precompute='auto', max_iter=500,
                 eps=np.finfo(np.float).eps, copy_X=True, fit_path=True,
                 positive=False):
        self.alpha = alpha
        self.fit_intercept = fit_intercept
        self.max_iter = max_iter
        self.verbose = verbose
        self.normalize = normalize
        self.positive = positive
        self.precompute = precompute
        self.copy_X = copy_X
        self.eps = eps
        self.fit_path = fit_path


###############################################################################
# Cross-validated estimator classes

def _check_copy_and_writeable(array, copy=False):
    if copy or not array.flags.writeable:
        return array.copy()
    return array


def _lars_path_residues(X_train, y_train, X_test, y_test, Gram=None,
                        copy=True, method='lars', verbose=False,
                        fit_intercept=True, normalize=True, max_iter=500,
                        eps=np.finfo(np.float).eps, positive=False):
    """Compute the residues on left-out data for a full LARS path

    Parameters
    -----------
    X_train : array, shape (n_samples, n_features)
        The data to fit the LARS on

    y_train : array, shape (n_samples)
        The target variable to fit LARS on

    X_test : array, shape (n_samples, n_features)
        The data to compute the residues on

    y_test : array, shape (n_samples)
        The target variable to compute the residues on

    Gram : None, 'auto', array, shape: (n_features, n_features), optional
        Precomputed Gram matrix (X' * X), if ``'auto'``, the Gram
        matrix is precomputed from the given X, if there are more samples
        than features

    copy : boolean, optional
        Whether X_train, X_test, y_train and y_test should be copied;
        if False, they may be overwritten.

    method : 'lar' | 'lasso'
        Specifies the returned model. Select ``'lar'`` for Least Angle
        Regression, ``'lasso'`` for the Lasso.

    verbose : integer, optional
        Sets the amount of verbosity

    fit_intercept : boolean
        whether to calculate the intercept for this model. If set
        to false, no intercept will be used in calculations
        (e.g. data is expected to be already centered).

    positive : boolean (default=False)
        Restrict coefficients to be >= 0. Be aware that you might want to
        remove fit_intercept which is set True by default.
        See reservations for using this option in combination with method
        'lasso' for expected small values of alpha in the doc of LassoLarsCV
        and LassoLarsIC.

    normalize : boolean, optional, default True
        This parameter is ignored when ``fit_intercept`` is set to False.
        If True, the regressors X will be normalized before regression by
        subtracting the mean and dividing by the l2-norm.
        If you wish to standardize, please use
        :class:`sklearn.preprocessing.StandardScaler` before calling ``fit``
        on an estimator with ``normalize=False``.

    max_iter : integer, optional
        Maximum number of iterations to perform.

    eps : float, optional
        The machine-precision regularization in the computation of the
        Cholesky diagonal factors. Increase this for very ill-conditioned
        systems. Unlike the ``tol`` parameter in some iterative
        optimization-based algorithms, this parameter does not control
        the tolerance of the optimization.


    Returns
    --------
    alphas : array, shape (n_alphas,)
        Maximum of covariances (in absolute value) at each iteration.
        ``n_alphas`` is either ``max_iter`` or ``n_features``, whichever
        is smaller.

    active : list
        Indices of active variables at the end of the path.

    coefs : array, shape (n_features, n_alphas)
        Coefficients along the path

    residues : array, shape (n_alphas, n_samples)
        Residues of the prediction on the test data
    """
    X_train = _check_copy_and_writeable(X_train, copy)
    y_train = _check_copy_and_writeable(y_train, copy)
    X_test = _check_copy_and_writeable(X_test, copy)
    y_test = _check_copy_and_writeable(y_test, copy)

    if fit_intercept:
        X_mean = X_train.mean(axis=0)
        X_train -= X_mean
        X_test -= X_mean
        y_mean = y_train.mean(axis=0)
        y_train = as_float_array(y_train, copy=False)
        y_train -= y_mean
        y_test = as_float_array(y_test, copy=False)
        y_test -= y_mean

    if normalize:
        norms = np.sqrt(np.sum(X_train ** 2, axis=0))
        nonzeros = np.flatnonzero(norms)
        X_train[:, nonzeros] /= norms[nonzeros]

    alphas, active, coefs = lars_path(
        X_train, y_train, Gram=Gram, copy_X=False, copy_Gram=False,
        method=method, verbose=max(0, verbose - 1), max_iter=max_iter, eps=eps,
        positive=positive)
    if normalize:
        coefs[nonzeros] /= norms[nonzeros][:, np.newaxis]
    residues = np.dot(X_test, coefs) - y_test[:, np.newaxis]
    return alphas, active, coefs, residues.T


class LarsCV(Lars):
    """Cross-validated Least Angle Regression model.

    See glossary entry for :term:`cross-validation estimator`.

    Read more in the :ref:`User Guide <least_angle_regression>`.

    Parameters
    ----------
    fit_intercept : boolean
        whether to calculate the intercept for this model. If set
        to false, no intercept will be used in calculations
        (e.g. data is expected to be already centered).

    verbose : boolean or integer, optional
        Sets the verbosity amount

    max_iter : integer, optional
        Maximum number of iterations to perform.

    normalize : boolean, optional, default True
        This parameter is ignored when ``fit_intercept`` is set to False.
        If True, the regressors X will be normalized before regression by
        subtracting the mean and dividing by the l2-norm.
        If you wish to standardize, please use
        :class:`sklearn.preprocessing.StandardScaler` before calling ``fit``
        on an estimator with ``normalize=False``.

    precompute : True | False | 'auto' | array-like
        Whether to use a precomputed Gram matrix to speed up
        calculations. If set to ``'auto'`` let us decide. The Gram matrix
        cannot be passed as argument since we will use only subsets of X.

    cv : int, cross-validation generator or an iterable, optional
        Determines the cross-validation splitting strategy.
        Possible inputs for cv are:

        - None, to use the default 3-fold cross-validation,
        - integer, to specify the number of folds.
        - :term:`CV splitter`,
        - An iterable yielding (train, test) splits as arrays of indices.

        For integer/None inputs, :class:`KFold` is used.

        Refer :ref:`User Guide <cross_validation>` for the various
        cross-validation strategies that can be used here.

        .. versionchanged:: 0.20
            ``cv`` default value if None will change from 3-fold to 5-fold
            in v0.22.

    max_n_alphas : integer, optional
        The maximum number of points on the path used to compute the
        residuals in the cross-validation

    n_jobs : int or None, optional (default=None)
        Number of CPUs to use during the cross validation.
        ``None`` means 1 unless in a :obj:`joblib.parallel_backend` context.
        ``-1`` means using all processors. See :term:`Glossary <n_jobs>`
        for more details.

    eps : float, optional
        The machine-precision regularization in the computation of the
        Cholesky diagonal factors. Increase this for very ill-conditioned
        systems.

    copy_X : boolean, optional, default True
        If ``True``, X will be copied; else, it may be overwritten.

    positive : boolean (default=False)
        Restrict coefficients to be >= 0. Be aware t
```


# sklearn/linear_model/tests (the files in it)

sklearn/linear_model/tests/__init__.py
sklearn/linear_model/tests/test_base.py
sklearn/linear_model/tests/test_bayes.py
sklearn/linear_model/tests/test_coordinate_descent.py
sklearn/linear_model/tests/test_huber.py
sklearn/linear_model/tests/test_least_angle.py
sklearn/linear_model/tests/test_logistic.py
sklearn/linear_model/tests/test_omp.py
sklearn/linear_model/tests/test_passive_aggressive.py
sklearn/linear_model/tests/test_perceptron.py
sklearn/linear_model/tests/test_ransac.py
sklearn/linear_model/tests/test_ridge.py
sklearn/linear_model/tests/test_sag.py
sklearn/linear_model/tests/test_sgd.py
sklearn/linear_model/tests/test_sparse_coordinate_descent.py
sklearn/linear_model/tests/test_theil_sen.py


# The last commit

```
aae1ee060 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: pytest sklearn/linear_model/tests/test_least_angle.py
============================= test session starts ==============================
platform linux -- Python 3.6.13, pytest-6.2.4, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: setup.cfg
collected 31 items

sklearn/linear_model/tests/test_least_angle.py ......................... [ 80%]
......                                                                   [100%]

======================== 31 passed, 4 warnings in 1.66s ========================
scope: sklearn/linear_model/least_angle.py sklearn/linear_model/tests
changed: sklearn/linear_model/least_angle.py +8 -3
changed: sklearn/linear_model/tests/test_least_angle.py +24 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sklearn/linear_model/least_angle.py b/sklearn/linear_model/least_angle.py
index 03b34a0dc..9772c12f5 100644
--- a/sklearn/linear_model/least_angle.py
+++ b/sklearn/linear_model/least_angle.py
@@ -1479,7 +1479,7 @@ class LassoLarsIC(LassoLars):
         self.eps = eps
         self.fit_path = True
 
-    def fit(self, X, y, copy_X=True):
+    def fit(self, X, y, copy_X=None):
         """Fit the model using X, y as training data.
 
         Parameters
@@ -1490,18 +1490,23 @@ class LassoLarsIC(LassoLars):
         y : array-like, shape (n_samples,)
             target values. Will be cast to X's dtype if necessary
 
-        copy_X : boolean, optional, default True
+        copy_X : boolean, optional, default None
             If ``True``, X will be copied; else, it may be overwritten.
+            If None, the value of the constructor parameter ``copy_X`` is
+            used.
 
         Returns
         -------
         self : object
             returns an instance of self.
         """
+        if copy_X is None:
+            copy_X = self.copy_X
+
         X, y = check_X_y(X, y, y_numeric=True)
 
         X, y, Xmean, ymean, Xstd = LinearModel._preprocess_data(
-            X, y, self.fit_intercept, self.normalize, self.copy_X)
+            X, y, self.fit_intercept, self.normalize, copy_X)
         max_iter = self.max_iter
 
         Gram = self.precompute
diff --git a/sklearn/linear_model/tests/test_least_angle.py b/sklearn/linear_model/tests/test_least_angle.py
index 21496efa6..8d243ab12 100644
--- a/sklearn/linear_model/tests/test_least_angle.py
+++ b/sklearn/linear_model/tests/test_least_angle.py
@@ -469,6 +469,30 @@ def test_lasso_lars_ic():
     assert_raises(ValueError, lars_broken.fit, X, y)
 
 
+def test_lasso_lars_ic_copy_X():
+    # Test that copy_X set in the constructor is used by fit, and that
+    # an explicit copy_X passed to fit takes precedence.
+    from sklearn.linear_model import least_angle
+
+    calls = []
+    original_lars_path = least_angle.lars_path
+
+    def recording_lars_path(*args, **kwargs):
+        calls.append(kwargs['copy_X'])
+        return original_lars_path(*args, **kwargs)
+
+    least_angle.lars_path = recording_lars_path
+    try:
+        lars = linear_model.LassoLarsIC(copy_X=False)
+        lars.fit(X, y)
+        assert_equal(calls[-1], False)
+
+        lars.fit(X, y, copy_X=True)
+        assert_equal(calls[-1], True)
+    finally:
+        least_angle.lars_path = original_lars_path
+
+
 def test_lars_path_readonly_data():
     # When using automated memory mapping on large input, the
     # fold data is in read-only mode
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
check: pytest sklearn/linear_model/tests/test_least_angle.py
============================= test session starts ==============================
platform linux -- Python 3.6.13, pytest-6.2.4, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: setup.cfg
collected 31 items

sklearn/linear_model/tests/test_least_angle.py ......................... [ 80%]
......                                                                   [100%]

======================== 31 passed, 4 warnings in 1.87s ========================
scope: sklearn/linear_model/least_angle.py sklearn/linear_model/tests
changed: sklearn/linear_model/least_angle.py +8 -3
changed: sklearn/linear_model/tests/test_least_angle.py +24 -0
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
# Notes, run 2026-11-06T115855

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

LassoLarsIC: unintuitive copy_X behaviour
Hi, I would like to report what seems to be a bug in the treatment of the `copy_X` parameter of the `LassoLarsIC` class. Because it's a simple bug, it's much easier to see in the code directly than in the execution, so I am not posting steps to reproduce it.

As you can see here, LassoLarsIC accepts a copy_X parameter.
https://github.com/scikit-learn/scikit-learn/blob/7389dbac82d362f296dc2746f10e43ffa1615660/sklearn/linear_model/least_angle.py#L1487

However, it also takes a copy_X parameter a few lines below, in the definition of ```fit```.
    ```def fit(self, X, y, copy_X=True):```

Now there are two values (potentially contradicting each other) for copy_X and each one is used once. Therefore ```fit``` can have a mixed behaviour. Even worse, this can be completely invisible to the user, since copy_X has a default value of True. Let's assume that I'd like it to be False, and have set it to False in the initialization, `my_lasso = LassoLarsIC(copy_X=False)`. I then call ```my_lasso.fit(X, y)``` and my choice will be silently overwritten. 

Ideally I think that copy_X should be removed as an argument in ```fit```. No other estimator seems to have a duplication in class parameters and fit arguments (I've checked more than ten in the linear models module). However, this would break existing code. Therefore I propose that ```fit``` takes a default value of `None` and only overwrites the existing value if the user has explicitly passed it as an argument to ```fit```. I will submit a PR to that effect.


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
build_tools/windows/windows_testing_downloader.ps1
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
examples/cluster/plot_kmeans_assumptions.py
examples/cluster/plot_kmeans_digits.py
examples/cluster/plot_kmeans_silhouette_analysis.py
examples/cluster/plot_kmeans_stability_low_dim_dense.py
examples/cluster/plot_linkage_comparison.py
examples/cluster/plot_mean_shift.py
examples/cluster/plot_mini_batch_kmeans.py
examples/cluster/plot_optics.py
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
examples/plot_missing_values.py
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
examples/svm/plot_iris.py
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
examples/tree/plot_iris.py
examples/tree/plot_tree_regression.py
examples/tree/plot_tree_regression_multioutput.py
examples/tree/plot_unveil_tree_structure.py
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
sklearn/cluster/tests/test_bicluster.py
sklearn/cluster/tests/test_birch.py
sklearn/cluster/tests/test_dbscan.py
sklearn/cluster/tests/test_feature_agglomeration.py
sklearn/cluster/tests/test_hierarchical.py
sklearn/cluster/tests/test_k_means.py
sklearn/cluster/tests/test_mean_shift.py
sklearn/cluster/tests/test_optics.py
sklearn/cluster/tests/test_spectral.py
sklearn/compose/__init__.py
sklearn/compose/_column_transformer.py
sklearn/compose/_target.py
sklearn/compose/tests/__init__.py
sklearn/compose/tests/test_column_transformer.py
sklearn/compose/tests/test_target.py
sklearn/covariance/__init__.py
sklearn/covariance/elliptic_envelope.py
sklearn/covariance/empirical_covariance_.py
sklearn/covariance/graph_lasso_.py
sklearn/covariance/robust_covariance.py
sklearn/covariance/shrunk_covariance_.py
```


# The last commit

```
aae1ee060 SWE-bench


```

```diff

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
	./build_tools/travis/flake8_diff.sh

```
````

### `plan.md`

```
## Deliverable
Changes to this tree.

## Check
`pytest sklearn/linear_model/tests/test_least_angle.py`

## Scope
`sklearn/linear_model/least_angle.py`
`sklearn/linear_model/tests/`

## Done when
- `LassoLarsIC.fit` uses `copy_X=None` as its default instead of `True`.
- `LassoLarsIC(copy_X=False).fit(X, y)` keeps and uses the constructor’s `copy_X=False` value.
- Passing `copy_X` explicitly to `fit` still takes precedence for that fit.
- (inferred) The `fit` docstring reflects the `None` sentinel and precedence rules.
- (inferred) A regression test covers constructor-versus-fit `copy_X` precedence.

## Approach
Change `least_angle.py` so `fit` resolves `copy_X` locally: use the explicit `fit` argument when it is not `None`, otherwise fall back to `self.copy_X`, then pass the resolved value to the internal fit path. Add a focused regression test in the existing least-angle tests.

Candidate fallbacks:
1. Remove `copy_X` from `fit` entirely and use only `self.copy_X`; cleaner API, but breaks callers passing `fit(..., copy_X=...)`.
2. Use a private sentinel instead of `None`; avoids ambiguity if `None` ever becomes meaningful, but is unnecessary for a boolean option.
3. Deprecate the `fit` argument first; safest for API compatibility but does not fix the silent override immediately.
```

### `prompt.md`

````
LassoLarsIC: unintuitive copy_X behaviour
Hi, I would like to report what seems to be a bug in the treatment of the `copy_X` parameter of the `LassoLarsIC` class. Because it's a simple bug, it's much easier to see in the code directly than in the execution, so I am not posting steps to reproduce it.

As you can see here, LassoLarsIC accepts a copy_X parameter.
https://github.com/scikit-learn/scikit-learn/blob/7389dbac82d362f296dc2746f10e43ffa1615660/sklearn/linear_model/least_angle.py#L1487

However, it also takes a copy_X parameter a few lines below, in the definition of ```fit```.
    ```def fit(self, X, y, copy_X=True):```

Now there are two values (potentially contradicting each other) for copy_X and each one is used once. Therefore ```fit``` can have a mixed behaviour. Even worse, this can be completely invisible to the user, since copy_X has a default value of True. Let's assume that I'd like it to be False, and have set it to False in the initialization, `my_lasso = LassoLarsIC(copy_X=False)`. I then call ```my_lasso.fit(X, y)``` and my choice will be silently overwritten. 

Ideally I think that copy_X should be removed as an argument in ```fit```. No other estimator seems to have a duplication in class parameters and fit arguments (I've checked more than ten in the linear models module). However, this would break existing code. Therefore I propose that ```fit``` takes a default value of `None` and only overwrites the existing value if the user has explicitly passed it as an argument to ```fit```. I will submit a PR to that effect.
````

### `review.md`

```
verdict: PASS

- `LassoLarsIC.fit` now defaults to `copy_X=None` and resolves it from `self.copy_X`, so `LassoLarsIC(copy_X=False).fit(X, y)` keeps the constructor's value; the `_preprocess_data` call now uses the resolved value rather than `self.copy_X`, and the existing `lars_path(..., copy_X=copy_X, ...)` call receives the resolved value too.
- An explicit `copy_X` passed to `fit` still overrides, because only `None` triggers the fallback.
- The docstring documents the `None` sentinel and the precedence rule, matching the inferred requirement.
- The added `test_lasso_lars_ic_copy_X` directly checks both precedence directions (constructor value used; explicit fit argument wins) and is within the stated test scope.
- All 31 tests in `sklearn/linear_model/tests/test_least_angle.py` pass; only the two scoped files changed, with no removed content beyond the intended signature default.
```

### `scope.txt`

```
scope: sklearn/linear_model/least_angle.py sklearn/linear_model/tests
changed: sklearn/linear_model/least_angle.py +8 -3
changed: sklearn/linear_model/tests/test_least_angle.py +24 -0
```

### `task.md`

````
# Task

## Prompt

LassoLarsIC: unintuitive copy_X behaviour
Hi, I would like to report what seems to be a bug in the treatment of the `copy_X` parameter of the `LassoLarsIC` class. Because it's a simple bug, it's much easier to see in the code directly than in the execution, so I am not posting steps to reproduce it.

As you can see here, LassoLarsIC accepts a copy_X parameter.
https://github.com/scikit-learn/scikit-learn/blob/7389dbac82d362f296dc2746f10e43ffa1615660/sklearn/linear_model/least_angle.py#L1487

However, it also takes a copy_X parameter a few lines below, in the definition of ```fit```.
    ```def fit(self, X, y, copy_X=True):```

Now there are two values (potentially contradicting each other) for copy_X and each one is used once. Therefore ```fit``` can have a mixed behaviour. Even worse, this can be completely invisible to the user, since copy_X has a default value of True. Let's assume that I'd like it to be False, and have set it to False in the initialization, `my_lasso = LassoLarsIC(copy_X=False)`. I then call ```my_lasso.fit(X, y)``` and my choice will be silently overwritten. 

Ideally I think that copy_X should be removed as an argument in ```fit```. No other estimator seems to have a duplication in class parameters and fit arguments (I've checked more than ten in the linear models module). However, this would break existing code. Therefore I propose that ```fit``` takes a default value of `None` and only overwrites the existing value if the user has explicitly passed it as an argument to ```fit```. I will submit a PR to that effect.

## Deliverable

Changes to this tree.

## Check

`pytest sklearn/linear_model/tests/test_least_angle.py`

## Scope

`sklearn/linear_model/least_angle.py`
`sklearn/linear_model/tests/`

## Done when

- `LassoLarsIC.fit` uses `copy_X=None` as its default instead of `True`.
- `LassoLarsIC(copy_X=False).fit(X, y)` keeps and uses the constructor’s `copy_X=False` value.
- Passing `copy_X` explicitly to `fit` still takes precedence for that fit.
- (inferred) The `fit` docstring reflects the `None` sentinel and precedence rules.
- (inferred) A regression test covers constructor-versus-fit `copy_X` precedence.
````

### `test-output.log`

```
check: pytest sklearn/linear_model/tests/test_least_angle.py
============================= test session starts ==============================
platform linux -- Python 3.6.13, pytest-6.2.4, py-1.11.0, pluggy-0.13.1
rootdir: /testbed, configfile: setup.cfg
collected 31 items

sklearn/linear_model/tests/test_least_angle.py ......................... [ 80%]
......                                                                   [100%]

======================== 31 passed, 4 warnings in 1.66s ========================
scope: sklearn/linear_model/least_angle.py sklearn/linear_model/tests
changed: sklearn/linear_model/least_angle.py +8 -3
changed: sklearn/linear_model/tests/test_least_angle.py +24 -0
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
