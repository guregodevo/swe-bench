# scikit-learn__scikit-learn-12973 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 42s 64 lines cost=0.001625 in=85802 cached=61952 out=2130 calls=11`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

LassoLarsIC: unintuitive copy_X behaviour
Hi, I would like to report what seems to be a bug in the treatment of the `copy_X` parameter of the `LassoLarsIC` class. Because it's a simple bug, it's much easier to see in the code directly than in the execution, so I am not posting steps to reproduce it.

As you can see here, LassoLarsIC accepts a copy_X parameter.
https://github.com/scikit-learn/scikit-learn/blob/7389dbac82d362f296dc2746f10e43ffa1615660/sklearn/linear_model/least_angle.py#L1487

However, it also takes a copy_X parameter a few lines below, in the definition of ```fit```.
    ```def fit(self, X, y, copy_X=True):```

Now there are two values (potentially contradicting each other) for copy_X and each one is used once. Therefore ```fit``` can have a mixed behaviour. Even worse, this can be completely invisible to the user, since copy_X has a default value of True. Let's assume that I'd like it to be False, and have set it to False in the initialization, `my_lasso = LassoLarsIC(copy_X=False)`. I then call ```my_lasso.fit(X, y)``` and my choice will be silently overwritten. 

Ideally I think that copy_X should be removed as an argument in ```fit```. No other estimator seems to have a duplication in class parameters and fit arguments (I've checked more than ten in the linear models module). However, this would break existing code. Therefore I propose that ```fit``` takes a default value of `None` and only overwrites the existing value if the user has explicitly passed it as an argument to ```fit```. I will submit a PR to that effect.

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "git status --porcelain -- . ':(exclude).memdoor'; echo \"---\"; git log --oneline -3"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"copy_X\\|class LassoLarsIC\\|def fit\" sklearn/linear_model/least_angle.py | head -80"
}
```

**tool result**

```
---
aae1ee060 SWE-bench
a7b8b9e9e MAINT Removes total_seconds completely in benchmarks (#12969)
98baafb64 MNT Inelegant failure of RandomTreesEmbedding.transform when not fitted (#12965)
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
674:    def fit(self, X, y, Xy=None):
761:    copy_X : boolean, optional, default True
812:    LassoLars(alpha=0.01, copy_X=True, eps=..., fit_intercept=True,
833:                 eps=np.finfo(np.float).eps, copy_X=True, fit_path=True,
842:        self.copy_X = copy_X
960:        X_train, y_train, Gram=Gram, copy_X=False, copy_Gram=False,
1035:    copy_X : boolean, optional, default True
1095:                 copy_X=True, positive=False):
1104:                         eps=eps, copy_X=copy_X, fit_path=True,
1107:    def fit(self, X, y):
1124:        X = as_float_array(X, copy=self.copy_X)
1125:        y = as_float_array(y, copy=self.copy_X)
1258:    copy_X : boolean, optional, default True
1335:                 copy_X=True, positive=False):
1345:        self.copy_X = copy_X
1351:class LassoLarsIC(LassoLars):
1403:    copy_X : boolean, optional, default True
1447:    LassoLarsIC(copy_X=True, criterion='bic', eps=..., fit_intercept=True,
1470:                 eps=np.finfo(np.float).eps, copy_X=True, positive=False):
1477:        self.copy_X = copy_X
1482:    def fit(self, X, y, copy_X=True):
1493:        copy_X : boolean, optional, default True
1504:            X, y, self.fit_intercept, self.normalize, self.copy_X)
1510:            X, y, Gram=Gram, copy_X=copy_X, copy_Gram=True, alpha_min=0.0,
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1482,1545p' sklearn/linear_model/least_angle.py"
}
```

**tool result**

```
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
                           K * df)  # Eqns. 2.15--16 in (Zou et al, 2007)
        n_best = np.argmin(self.criterion_)

        self.alpha_ = alphas_[n_best]
        self.coef_ = coef_path_[:, n_best]
        self._set_intercept(Xmean, ymean, Xstd)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/linear_model/least_angle.py\n@@\n-    def fit(self, X, y, copy_X=True):\n+    def fit(self, X, y, copy_X=None):\n@@\n-        copy_X : boolean, optional, default True\n+        copy_X : boolean, optional, default None\n             If ``True``, X will be copied; else, it may be overwritten.\n+            If ``None``, the value of the ``copy_X`` parameter of the\n+            estimator is used.\n@@\n-        X, y = check_X_y(X, y, y_numeric=True)\n+        if copy_X is None:\n+            copy_X = self.copy_X\n+\n+        X, y = check_X_y(X, y, y_numeric=True)\n \n         X, y, Xmean, ymean, Xstd = LinearModel._preprocess_data(\n-            X, y, self.fit_intercept, self.normalize, self.copy_X)\n+            X, y, self.fit_intercept, self.normalize, copy_X)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/linear_model/least_angle.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/linear_model/least_angle.py now (1551 lines), around the change:
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
1495:            If ``None``, the value of the ``copy_X`` parameter of the
1496:            estimator is used.
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

**tool result**

```
..............................                                           [100%]
30 passed, 4 warnings in 2.22s
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"copy_X\\|def test_lasso_lars\" sklearn/linear_model/tests/test_least_angle.py | head -30"
}
```

**tool result**

```
131:    _, _, coef_path_ = linear_model.lars_path(X, y, Gram='auto', copy_X=False,
233:def test_lasso_lars_vs_lasso_cd(verbose=False):
270:def test_lasso_lars_vs_lasso_cd_early_stopping(verbose=False):
297:def test_lasso_lars_path_length():
308:def test_lasso_lars_vs_lasso_cd_ill_conditioned():
340:def test_lasso_lars_vs_lasso_cd_ill_conditioned2():
448:def test_lasso_lars_ic():
542:def test_lasso_lars_vs_lasso_cd_positive(verbose=False):
594:def test_lasso_lars_vs_R_implementation():
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '448,510p' sklearn/linear_model/tests/test_least_angle.py"
}
```

**tool result**

```
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

    # ensure that we get negative coefficients when positive=False
    # and all positive when positive=True
    # for method 'lar' (default) and lasso

    # Once deprecation of LAR + positive option is done use these:
    # assert_raises(ValueError, linear_model.lars_path, diabetes['data'],
    #               diabetes['target'], method='lar', positive=True)

    with pytest.warns(DeprecationWarning, match="broken"):
        linear_model.lars_path(diabetes['data'], diabetes['target'],
                               return_path=True, method='lar',
                               positive=True)

    method = 'lasso'
    alpha, active, coefs = \
        linear_model.lars_path(diabetes['data'], diabetes['target'],
                               return_path=True, method=method,
                               positive=False)
    assert coefs.min() < 0

    alpha, active, coefs = \
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,30p' sklearn/linear_model/tests/test_least_angle.py"
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
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np\nfrom sklearn import linear_model, datasets\nX,y = datasets.load_diabetes(return_X_y=True)\nX0=X.copy()\nm=linear_model.LassoLarsIC(copy_X=False)\nm.fit(X,y)\nprint(\"fit overwrote:\", not np.array_equal(X,X0))\nX=X0.copy()\nm.fit(X,y,copy_X=True)\nprint(\"fit copy True overwrote:\", not np.array_equal(X,X0))\nEOF"
}
```

**tool result**

```
fit overwrote: True
fit copy True overwrote: False
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/linear_model/tests/test_least_angle.py\n@@\n def test_lasso_lars_ic():\n@@\n     lars_broken = linear_model.LassoLarsIC('<unknown>')\n     assert_raises(ValueError, lars_broken.fit, X, y)\n \n \n+def test_lasso_lars_ic_copy_X():\n+    # Test that the copy_X parameter of the estimator is respected by fit,\n+    # and that an explicit copy_X argument to fit takes precedence.\n+    X_original = X.copy()\n+\n+    lars = linear_model.LassoLarsIC(copy_X=False)\n+    lars.fit(X, y)\n+    assert not np.array_equal(X, X_original)\n+\n+    X[:] = X_original\n+    lars.fit(X, y, copy_X=True)\n+    assert_array_almost_equal(X, X_original)\n+\n+\n def test_lars_path_readonly_data():\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/linear_model/tests/test_least_angle.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/linear_model/tests/test_least_angle.py now (702 lines), around the change:
469:    assert_raises(ValueError, lars_broken.fit, X, y)
470:
471:
472:def test_lasso_lars_ic_copy_X():
473:    # Test that the copy_X parameter of the estimator is respected by fit,
474:    # and that an explicit copy_X argument to fit takes precedence.
475:    X_original = X.copy()
476:
477:    lars = linear_model.LassoLarsIC(copy_X=False)
478:    lars.fit(X, y)
479:    assert not np.array_equal(X, X_original)
480:
481:    X[:] = X_original
482:    lars.fit(X, y, copy_X=True)
483:    assert_array_almost_equal(X, X_original)
484:
485:
486:def test_lars_path_readonly_data():
487:    # When using automated memory mapping on large input, the
488:    # fold data is in read-only mode
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/linear_model/tests/test_least_angle.py -q 2>&1 | tail -8 && git status --porcelain -- . ':(exclude).memdoor' && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```
...............................                                          [100%]
31 passed, 4 warnings in 2.16s
 M sklearn/linear_model/least_angle.py
 M sklearn/linear_model/tests/test_least_angle.py
TASK_OK
```

**assistant**

```
Done. The `fit` method of `LassoLarsIC` now defaults `copy_X` to `None`, and only uses an explicitly passed value when provided; otherwise it falls back to the estimator's `self.copy_X`. Both `_preprocess_data` and `lars_path` use the resolved value, so constructor and fit can no longer conflict.

Added a regression test verifying:
- `LassoLarsIC(copy_X=False).fit(X, y)` leaves `X` overwritten.
- `fit(X, y, copy_X=True)` takes precedence and preserves `X`.

All 31 tests in `test_least_angle.py` pass, and the completion command exits 0.
```

## Run folder `single-2026-11-06T115840`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

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
