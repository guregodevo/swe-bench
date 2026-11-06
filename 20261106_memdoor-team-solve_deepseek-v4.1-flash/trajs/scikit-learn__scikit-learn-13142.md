# scikit-learn__scikit-learn-13142 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 1325s 65 lines cost=0.004068 in=179979 cached=123392 out=5825 calls=16`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

GaussianMixture predict and fit_predict disagree when n_init>1
#### Description
When `n_init` is specified in GaussianMixture, the results of fit_predict(X) and predict(X) are often different.  The `test_gaussian_mixture_fit_predict` unit test doesn't catch this because it does not set `n_init`.

#### Steps/Code to Reproduce
```
python
from sklearn.mixture import GaussianMixture
from sklearn.utils.testing import assert_array_equal
import numpy
X = numpy.random.randn(1000,5)
print 'no n_init'
gm = GaussianMixture(n_components=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
print 'n_init=5'
gm = GaussianMixture(n_components=5, n_init=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
```

#### Expected Results
```
no n_init
n_init=5
```
No exceptions.

#### Actual Results
```
no n_init
n_init=5
Traceback (most recent call last):
  File "test_gm.py", line 17, in <module>
    assert_array_equal(c1,c2)
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 872, in assert_array_equal
    verbose=verbose, header='Arrays are not equal')
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 796, in assert_array_compare
    raise AssertionError(msg)
AssertionError: 
Arrays are not equal

(mismatch 88.6%)
 x: array([4, 0, 1, 1, 1, 3, 3, 4, 4, 2, 0, 0, 1, 2, 0, 2, 0, 1, 3, 1, 1, 3,
       2, 1, 0, 2, 1, 0, 2, 0, 3, 1, 2, 3, 3, 1, 0, 2, 2, 0, 3, 0, 2, 0,
       4, 2, 3, 0, 4, 2, 4, 1, 0, 2, 2, 1, 3, 2, 1, 4, 0, 2, 2, 1, 1, 2,...
 y: array([4, 1, 0, 2, 2, 1, 1, 4, 4, 0, 4, 1, 0, 3, 1, 0, 2, 2, 1, 2, 0, 0,
       1, 0, 4, 1, 0, 4, 0, 1, 1, 2, 3, 1, 4, 0, 1, 4, 4, 4, 0, 1, 0, 2,
       4, 1, 1, 2, 4, 3, 4, 0, 2, 3, 2, 3, 0, 0, 2, 3, 3, 3, 3, 0, 3, 2,...
```

#### Versions
```
System:
    python: 2.7.15rc1 (default, Nov 12 2018, 14:31:15)  [GCC 7.3.0]
   machine: Linux-4.15.0-43-generic-x86_64-with-Ubuntu-18.04-bionic
executable: /usr/bin/python

BLAS:
    macros: HAVE_CBLAS=None, NO_ATLAS_INFO=-1
cblas_libs: cblas
  lib_dirs: /usr/lib/x86_64-linux-gnu

Python deps:
    Cython: 0.28.5
     scipy: 1.2.0
setuptools: 39.0.1
       pip: 19.0.1
     numpy: 1.16.0
    pandas: 0.23.1
   sklearn: 0.20.2
```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --short"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def fit_predict\\|def predict\\|def fit\\b\\|n_init\" sklearn/mixture/gaussian_mixture.py | head -50"
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
lgtm.yml
scikit_learn.egg-info
setup.cfg
setup.py
site.cfg
sklearn
87330378b SWE-bench
1c8668b0a DOC what's new: Fix class name
8d10ba0fe Use nonlocal instead of container (#13144)
?? .memdoor/
```

**tool result**

```
474:    n_init : int, defaults to 1.
514:        In that case, 'n_init' is ignored and only a single initialization
589:                 reg_covar=1e-6, max_iter=100, n_init=1, init_params='kmeans',
595:            max_iter=max_iter, n_init=n_init, init_params=init_params,
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"def fit_predict\\|def predict\" sklearn/mixture/*.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"n_init\\|def fit\\|def _fit\\|def predict\\|def fit_predict\" sklearn/mixture/base.py"
}
```

**tool result**

```
sklearn/mixture/base.py:194:    def fit_predict(self, X, y=None):
sklearn/mixture/base.py:358:    def predict(self, X):
sklearn/mixture/base.py:376:    def predict_proba(self, X):
```

**tool result**

```
72:                 max_iter, n_init, init_params, random_state, warm_start,
78:        self.n_init = n_init
102:        if self.n_init < 1:
103:            raise ValueError("Invalid value for 'n_init': %d "
105:                             % self.n_init)
145:            label = cluster.KMeans(n_clusters=self.n_components, n_init=1,
169:    def fit(self, X, y=None):
172:        The method fits the model ``n_init`` times and sets the parameters with
177:        If ``warm_start`` is ``True``, then ``n_init`` is ignored and a single
194:    def fit_predict(self, X, y=None):
197:        The method fits the model n_init times and sets the parameters with
222:        n_init = self.n_init if do_init else 1
230:        for init in range(n_init):
358:    def predict(self, X):
376:    def predict_proba(self, X):
510:    def _print_verbose_msg_init_beg(self, n_init):
513:            print("Initialization %d" % n_init)
515:            print("Initialization %d" % n_init)
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/mixture/base.py",
  "offset": 160,
  "limit": 240
}
```

**tool result**

```

        Parameters
        ----------
        X : array-like, shape  (n_samples, n_features)

        resp : array-like, shape (n_samples, n_components)
        """
        pass

    def fit(self, X, y=None):
        """Estimate model parameters with the EM algorithm.

        The method fits the model ``n_init`` times and sets the parameters with
        which the model has the largest likelihood or lower bound. Within each
        trial, the method iterates between E-step and M-step for ``max_iter``
        times until the change of likelihood or lower bound is less than
        ``tol``, otherwise, a ``ConvergenceWarning`` is raised.
        If ``warm_start`` is ``True``, then ``n_init`` is ignored and a single
        initialization is performed upon the first call. Upon consecutive
        calls, training starts where it left off.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)
            List of n_features-dimensional data points. Each row
            corresponds to a single data point.

        Returns
        -------
        self
        """
        self.fit_predict(X, y)
        return self

    def fit_predict(self, X, y=None):
        """Estimate model parameters using X and predict the labels for X.

        The method fits the model n_init times and sets the parameters with
        which the model has the largest likelihood or lower bound. Within each
        trial, the method iterates between E-step and M-step for `max_iter`
        times until the change of likelihood or lower bound is less than
        `tol`, otherwise, a `ConvergenceWarning` is raised. After fitting, it
        predicts the most probable label for the input data points.

        .. versionadded:: 0.20

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)
            List of n_features-dimensional data points. Each row
            corresponds to a single data point.

        Returns
        -------
        labels : array, shape (n_samples,)
            Component labels.
        """
        X = _check_X(X, self.n_components, ensure_min_samples=2)
        self._check_initial_parameters(X)

        # if we enable warm_start, we will have a unique initialisation
        do_init = not(self.warm_start and hasattr(self, 'converged_'))
        n_init = self.n_init if do_init else 1

        max_lower_bound = -np.infty
        self.converged_ = False

        random_state = check_random_state(self.random_state)

        n_samples, _ = X.shape
        for init in range(n_init):
            self._print_verbose_msg_init_beg(init)

            if do_init:
                self._initialize_parameters(X, random_state)

            lower_bound = (-np.infty if do_init else self.lower_bound_)

            for n_iter in range(1, self.max_iter + 1):
                prev_lower_bound = lower_bound

                log_prob_norm, log_resp = self._e_step(X)
                self._m_step(X, log_resp)
                lower_bound = self._compute_lower_bound(
                    log_resp, log_prob_norm)

                change = lower_bound - prev_lower_bound
                self._print_verbose_msg_iter_end(n_iter, change)

                if abs(change) < self.tol:
                    self.converged_ = True
                    break

            self._print_verbose_msg_init_end(lower_bound)

            if lower_bound > max_lower_bound:
                max_lower_bound = lower_bound
                best_params = self._get_parameters()
                best_n_iter = n_iter

        # Always do a final e-step to guarantee that the labels returned by
        # fit_predict(X) are always consistent with fit(X).predict(X)
        # for any value of max_iter and tol (and any random_state).
        _, log_resp = self._e_step(X)

        if not self.converged_:
            warnings.warn('Initialization %d did not converge. '
                          'Try different init parameters, '
                          'or increase max_iter, tol '
                          'or check for degenerate data.'
                          % (init + 1), ConvergenceWarning)

        self._set_parameters(best_params)
        self.n_iter_ = best_n_iter
        self.lower_bound_ = max_lower_bound

        return log_resp.argmax(axis=1)

    def _e_step(self, X):
        """E step.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)

        Returns
        -------
        log_prob_norm : float
            Mean of the logarithms of the probabilities of each sample in X

        log_responsibility : array, shape (n_samples, n_components)
            Logarithm of the posterior probabilities (or responsibilities) of
            the point of each sample in X.
        """
        log_prob_norm, log_resp = self._estimate_log_prob_resp(X)
        return np.mean(log_prob_norm), log_resp

    @abstractmethod
    def _m_step(self, X, log_resp):
        """M step.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)

        log_resp : array-like, shape (n_samples, n_components)
            Logarithm of the posterior probabilities (or responsibilities) of
            the point of each sample in X.
        """
        pass

    @abstractmethod
    def _check_is_fitted(self):
        pass

    @abstractmethod
    def _get_parameters(self):
        pass

    @abstractmethod
    def _set_parameters(self, params):
        pass

    def score_samples(self, X):
        """Compute the weighted log probabilities for each sample.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)
            List of n_features-dimensional data points. Each row
            corresponds to a single data point.

        Returns
        -------
        log_prob : array, shape (n_samples,)
            Log probabilities of each data point in X.
        """
        self._check_is_fitted()
        X = _check_X(X, None, self.means_.shape[1])

        return logsumexp(self._estimate_weighted_log_prob(X), axis=1)

    def score(self, X, y=None):
        """Compute the per-sample average log-likelihood of the given data X.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_dimensions)
            List of n_features-dimensional data points. Each row
            corresponds to a single data point.

        Returns
        -------
        log_likelihood : float
            Log likelihood of the Gaussian mixture given X.
        """
        return self.score_samples(X).mean()

    def predict(self, X):
        """Predict the labels for the data samples in X using trained model.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)
            List of n_features-dimensional data points. Each row
            corresponds to a single data point.

        Returns
        -------
        labels : array, shape (n_samples,)
            Component labels.
        """
        self._check_is_fitted()
        X = _check_X(X, None, self.means_.shape[1])
        return self._estimate_weighted_log_prob(X).argmax(axis=1)

    def predict_proba(self, X):
        """Predict posterior probability of each component given the data.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)
            List of n_features-dimensional data points. Each row
            corresponds to a single data point.

        Returns
        -------
        resp : array, shape (n_samples, n_components)
            Returns the probability each Gaussian (state) in
            the model given each sample.
        """
        self._check_is_fitted()
        X = _check_X(X, None, self.means_.shape[1])
        _, log_resp = self._estimate_log_prob_resp(X)
        return np.exp(log_resp)

    def sample(self, n_samples=1):
        """Generate random samples from the fitted Gaussian distribution.

        Parameters

[137 more lines in /testbed/sklearn/mixture/base.py (536 in all). read_file with offset: 400 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"fit_predict\\|n_init\" sklearn/mixture/tests/test_gaussian_mixture.py | head -40"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,80p' sklearn/mixture/base.py"
}
```

**tool result**

```
146:    n_init_bad = 0
147:    gmm = GaussianMixture(n_init=n_init_bad)
149:                         "Invalid value for 'n_init': %d "
151:                         % n_init_bad, gmm.fit, X)
161:    n_components, tol, n_init, max_iter, reg_covar = 2, 1e-4, 3, 30, 1e-1
163:    gmm = GaussianMixture(n_components=n_components, tol=tol, n_init=n_init,
173:    assert_equal(gmm.n_init, n_init)
580:def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
593:        # check if fit_predict(X) is equivalent to fit(X).predict(X)
596:        Y_pred2 = g.fit_predict(X)
610:        g = GaussianMixture(n_components=n_components, n_init=20,
653:    n_init = 10
656:        g = GaussianMixture(n_components=n_components, n_init=1, reg_covar=0,
659:        for _ in range(n_init):
664:                                 n_init=n_init, reg_covar=0, random_state=rng,
677:        g = GaussianMixture(n_components=n_components, n_init=1,
699:                                 random_state=0, n_init=5).fit(X).score(X)
759:        g = GaussianMixture(n_components=n_components, n_init=1, reg_covar=0,
762:        h = GaussianMixture(n_components=n_components, n_init=1, reg_covar=0,
783:    g = GaussianMixture(n_components=n_components, n_init=1, max_iter=2,
786:    h = GaussianMixture(n_components=n_components, n_init=1, max_iter=1,
800:    g = GaussianMixture(n_components=n_components, n_init=1,
803:    h = GaussianMixture(n_components=n_components, n_init=1,
848:    gmm1 = GaussianMixture(n_components=n_components, n_init=1,
865:    gmm2 = GaussianMixture(n_components=n_components, n_init=1, reg_covar=0,
879:    gmm = GaussianMixture(n_components=n_components, n_init=1, reg_covar=0,
958:                              n_init=5)
1024:    # We check that by increasing the n_init number we have a better solution
1030:        gmm1 = GaussianMixture(n_components=n_components, n_init=1,
1032:        gmm2 = GaussianMixture(n_components=n_components, n_init=10,
```

**tool result**

```
"""Base class for mixture models."""

# Author: Wei Xue <xuewei4d@gmail.com>
# Modified by Thierry Guillemot <thierry.guillemot.work@gmail.com>
# License: BSD 3 clause

import warnings
from abc import ABCMeta, abstractmethod
from time import time

import numpy as np

from .. import cluster
from ..base import BaseEstimator
from ..base import DensityMixin
from ..exceptions import ConvergenceWarning
from ..utils import check_array, check_random_state
from ..utils.fixes import logsumexp


def _check_shape(param, param_shape, name):
    """Validate the shape of the input parameter 'param'.

    Parameters
    ----------
    param : array

    param_shape : tuple

    name : string
    """
    param = np.array(param)
    if param.shape != param_shape:
        raise ValueError("The parameter '%s' should have the shape of %s, "
                         "but got %s" % (name, param_shape, param.shape))


def _check_X(X, n_components=None, n_features=None, ensure_min_samples=1):
    """Check the input data X.

    Parameters
    ----------
    X : array-like, shape (n_samples, n_features)

    n_components : int

    Returns
    -------
    X : array, shape (n_samples, n_features)
    """
    X = check_array(X, dtype=[np.float64, np.float32],
                    ensure_min_samples=ensure_min_samples)
    if n_components is not None and X.shape[0] < n_components:
        raise ValueError('Expected n_samples >= n_components '
                         'but got n_components = %d, n_samples = %d'
                         % (n_components, X.shape[0]))
    if n_features is not None and X.shape[1] != n_features:
        raise ValueError("Expected the input data X have %d features, "
                         "but got %d features"
                         % (n_features, X.shape[1]))
    return X


class BaseMixture(DensityMixin, BaseEstimator, metaclass=ABCMeta):
    """Base class for mixture models.

    This abstract class specifies an interface for all mixture classes and
    provides basic common methods for mixture models.
    """

    def __init__(self, n_components, tol, reg_covar,
                 max_iter, n_init, init_params, random_state, warm_start,
                 verbose, verbose_interval):
        self.n_components = n_components
        self.tol = tol
        self.reg_covar = reg_covar
        self.max_iter = max_iter
        self.n_init = n_init
        self.init_params = init_params
        self.random_state = random_state
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/mixture/tests/test_gaussian_mixture.py",
  "offset": 570,
  "limit": 50
}
```

**tool result**

```
        assert_greater(adjusted_rand_score(Y, Y_pred), .95)


@pytest.mark.filterwarnings("ignore:.*did not converge.*")
@pytest.mark.parametrize('seed, max_iter, tol', [
    (0, 2, 1e-7),    # strict non-convergence
    (1, 2, 1e-1),    # loose non-convergence
    (3, 300, 1e-7),  # strict convergence
    (4, 300, 1e-1),  # loose convergence
])
def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
    rng = np.random.RandomState(seed)
    rand_data = RandomData(rng)
    for covar_type in COVARIANCE_TYPE:
        X = rand_data.X[covar_type]
        Y = rand_data.Y
        g = GaussianMixture(n_components=rand_data.n_components,
                            random_state=rng, weights_init=rand_data.weights,
                            means_init=rand_data.means,
                            precisions_init=rand_data.precisions[covar_type],
                            covariance_type=covar_type,
                            max_iter=max_iter, tol=tol)

        # check if fit_predict(X) is equivalent to fit(X).predict(X)
        f = copy.deepcopy(g)
        Y_pred1 = f.fit(X).predict(X)
        Y_pred2 = g.fit_predict(X)
        assert_array_equal(Y_pred1, Y_pred2)
        assert_greater(adjusted_rand_score(Y, Y_pred2), .95)


def test_gaussian_mixture_fit():
    # recover the ground truth
    rng = np.random.RandomState(0)
    rand_data = RandomData(rng)
    n_features = rand_data.n_features
    n_components = rand_data.n_components

    for covar_type in COVARIANCE_TYPE:
        X = rand_data.X[covar_type]
        g = GaussianMixture(n_components=n_components, n_init=20,
                            reg_covar=0, random_state=rng,
                            covariance_type=covar_type)
        g.fit(X)

        # needs more data to pass the test with rtol=1e-7
        assert_allclose(np.sort(g.weights_), np.sort(rand_data.weights),
                        rtol=0.1, atol=1e-2)

        arg_idx1 = g.means_[:, 0].argsort()

[416 more lines in /testbed/sklearn/mixture/tests/test_gaussian_mixture.py (1035 in all). read_file with offset: 620 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/mixture/base.py\n@@\n-        # Always do a final e-step to guarantee that the labels returned by\n-        # fit_predict(X) are always consistent with fit(X).predict(X)\n-        # for any value of max_iter and tol (and any random_state).\n-        _, log_resp = self._e_step(X)\n-\n         if not self.converged_:\n             warnings.warn('Initialization %d did not converge. '\n                           'Try different init parameters, '\n                           'or increase max_iter, tol '\n                           'or check for degenerate data.'\n                           % (init + 1), ConvergenceWarning)\n \n         self._set_parameters(best_params)\n         self.n_iter_ = best_n_iter\n         self.lower_bound_ = max_lower_bound\n \n+        # Always do a final e-step to guarantee that the labels returned by\n+        # fit_predict(X) are always consistent with fit(X).predict(X)\n+        # for any value of max_iter and tol (and any random_state).\n+        _, log_resp = self._e_step(X)\n+\n         return log_resp.argmax(axis=1)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/mixture/base.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/mixture/base.py now (536 lines), around the change:
257:                best_params = self._get_parameters()
258:                best_n_iter = n_iter
259:
260:        if not self.converged_:
261:            warnings.warn('Initialization %d did not converge. '
262:                          'Try different init parameters, '
263:                          'or increase max_iter, tol '
…
267:        self._set_parameters(best_params)
268:        self.n_iter_ = best_n_iter
269:        self.lower_bound_ = max_lower_bound
270:
271:        # Always do a final e-step to guarantee that the labels returned by
272:        # fit_predict(X) are always consistent with fit(X).predict(X)
273:        # for any value of max_iter and tol (and any random_state).
274:        _, log_resp = self._e_step(X)
275:
276:        return log_resp.argmax(axis=1)
277:
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def _initialize_parameters\\|def _initialize\" -A45 sklearn/mixture/gaussian_mixture.py | head -70"
}
```

**tool result**

```
627:    def _initialize(self, X, resp):
628-        """Initialization of the Gaussian mixture parameters.
629-
630-        Parameters
631-        ----------
632-        X : array-like, shape (n_samples, n_features)
633-
634-        resp : array-like, shape (n_samples, n_components)
635-        """
636-        n_samples, _ = X.shape
637-
638-        weights, means, covariances = _estimate_gaussian_parameters(
639-            X, resp, self.reg_covar, self.covariance_type)
640-        weights /= n_samples
641-
642-        self.weights_ = (weights if self.weights_init is None
643-                         else self.weights_init)
644-        self.means_ = means if self.means_init is None else self.means_init
645-
646-        if self.precisions_init is None:
647-            self.covariances_ = covariances
648-            self.precisions_cholesky_ = _compute_precision_cholesky(
649-                covariances, self.covariance_type)
650-        elif self.covariance_type == 'full':
651-            self.precisions_cholesky_ = np.array(
652-                [linalg.cholesky(prec_init, lower=True)
653-                 for prec_init in self.precisions_init])
654-        elif self.covariance_type == 'tied':
655-            self.precisions_cholesky_ = linalg.cholesky(self.precisions_init,
656-                                                        lower=True)
657-        else:
658-            self.precisions_cholesky_ = self.precisions_init
659-
660-    def _m_step(self, X, log_resp):
661-        """M step.
662-
663-        Parameters
664-        ----------
665-        X : array-like, shape (n_samples, n_features)
666-
667-        log_resp : array-like, shape (n_samples, n_components)
668-            Logarithm of the posterior probabilities (or responsibilities) of
669-            the point of each sample in X.
670-        """
671-        n_samples, _ = X.shape
672-        self.weights_, self.means_, self.covariances_ = (
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/mixture/tests/test_gaussian_mixture.py\n@@\n-@pytest.mark.parametrize('seed, max_iter, tol', [\n-    (0, 2, 1e-7),    # strict non-convergence\n-    (1, 2, 1e-1),    # loose non-convergence\n-    (3, 300, 1e-7),  # strict convergence\n-    (4, 300, 1e-1),  # loose convergence\n+@pytest.mark.parametrize('seed, max_iter, tol, n_init', [\n+    (0, 2, 1e-7, 1),    # strict non-convergence\n+    (1, 2, 1e-1, 1),    # loose non-convergence\n+    (3, 300, 1e-7, 1),  # strict convergence\n+    (4, 300, 1e-1, 1),  # loose convergence\n+    (5, 2, 1e-7, 5),    # strict non-convergence with n_init\n+    (6, 2, 1e-1, 5),    # loose non-convergence with n_init\n+    (7, 300, 1e-7, 5),  # strict convergence with n_init\n+    (8, 300, 1e-1, 5),  # loose convergence with n_init\n ])\n-def test_gaussian_mixture_fit_predict(seed, max_iter, tol):\n+def test_gaussian_mixture_fit_predict(seed, max_iter, tol, n_init):\n@@\n                             precisions_init=rand_data.precisions[covar_type],\n                             covariance_type=covar_type,\n-                            max_iter=max_iter, tol=tol)\n+                            max_iter=max_iter, tol=tol, n_init=n_init)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/mixture/tests/test_gaussian_mixture.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/mixture/tests/test_gaussian_mixture.py now (1039 lines), around the change:
571:
572:
573:@pytest.mark.filterwarnings("ignore:.*did not converge.*")
574:@pytest.mark.parametrize('seed, max_iter, tol, n_init', [
575:    (0, 2, 1e-7, 1),    # strict non-convergence
576:    (1, 2, 1e-1, 1),    # loose non-convergence
577:    (3, 300, 1e-7, 1),  # strict convergence
578:    (4, 300, 1e-1, 1),  # loose convergence
579:    (5, 2, 1e-7, 5),    # strict non-convergence with n_init
580:    (6, 2, 1e-1, 5),    # loose non-convergence with n_init
581:    (7, 300, 1e-7, 5),  # strict convergence with n_init
582:    (8, 300, 1e-1, 5),  # loose convergence with n_init
583:])
584:def test_gaussian_mixture_fit_predict(seed, max_iter, tol, n_init):
585:    rng = np.random.RandomState(seed)
586:    rand_data = RandomData(rng)
587:    for covar_type in COVARIANCE_TYPE:
…
592:                            means_init=rand_data.means,
593:                            precisions_init=rand_data.precisions[covar_type],
594:                            covariance_type=covar_type,
595:                            max_iter=max_iter, tol=tol, n_init=n_init)
596:
597:        # check if fit_predict(X) is equivalent to fit(X).predict(X)
598:        f = copy.deepcopy(g)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '120,160p' sklearn/mixture/base.py"
}
```

**tool result**

```

    @abstractmethod
    def _check_parameters(self, X):
        """Check initial parameters of the derived class.

        Parameters
        ----------
        X : array-like, shape  (n_samples, n_features)
        """
        pass

    def _initialize_parameters(self, X, random_state):
        """Initialize the model parameters.

        Parameters
        ----------
        X : array-like, shape  (n_samples, n_features)

        random_state : RandomState
            A random number generator instance.
        """
        n_samples, _ = X.shape

        if self.init_params == 'kmeans':
            resp = np.zeros((n_samples, self.n_components))
            label = cluster.KMeans(n_clusters=self.n_components, n_init=1,
                                   random_state=random_state).fit(X).labels_
            resp[np.arange(n_samples), label] = 1
        elif self.init_params == 'random':
            resp = random_state.rand(n_samples, self.n_components)
            resp /= resp.sum(axis=1)[:, np.newaxis]
        else:
            raise ValueError("Unimplemented initialization method '%s'"
                             % self.init_params)

        self._initialize(X, resp)

    @abstractmethod
    def _initialize(self, X, resp):
        """Initialize the model parameters of the derived class.
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/mixture/tests/test_gaussian_mixture.py -k \"fit_predict\" -q 2>&1 | tail -20"
}
```

**tool result**

```
........                                                                 [100%]
8 passed, 32 deselected in 1.63s
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '584,615p' sklearn/mixture/tests/test_gaussian_mixture.py"
}
```

**tool result**

```
def test_gaussian_mixture_fit_predict(seed, max_iter, tol, n_init):
    rng = np.random.RandomState(seed)
    rand_data = RandomData(rng)
    for covar_type in COVARIANCE_TYPE:
        X = rand_data.X[covar_type]
        Y = rand_data.Y
        g = GaussianMixture(n_components=rand_data.n_components,
                            random_state=rng, weights_init=rand_data.weights,
                            means_init=rand_data.means,
                            precisions_init=rand_data.precisions[covar_type],
                            covariance_type=covar_type,
                            max_iter=max_iter, tol=tol, n_init=n_init)

        # check if fit_predict(X) is equivalent to fit(X).predict(X)
        f = copy.deepcopy(g)
        Y_pred1 = f.fit(X).predict(X)
        Y_pred2 = g.fit_predict(X)
        assert_array_equal(Y_pred1, Y_pred2)
        assert_greater(adjusted_rand_score(Y, Y_pred2), .95)


def test_gaussian_mixture_fit():
    # recover the ground truth
    rng = np.random.RandomState(0)
    rand_data = RandomData(rng)
    n_features = rand_data.n_features
    n_components = rand_data.n_components

    for covar_type in COVARIANCE_TYPE:
        X = rand_data.X[covar_type]
        g = GaussianMixture(n_components=n_components, n_init=20,
                            reg_covar=0, random_state=rng,
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/mixture/tests/test_gaussian_mixture.py -q 2>&1 | tail -15"
}
```

**tool result**

```
........................................                                 [100%]
40 passed, 8 warnings in 5.16s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/mixture/tests/ -q 2>&1 | tail -10 && git diff --stat"
}
```

**tool result**

```
............................................................             [100%]
60 passed, 10 warnings in 12.65s
 sklearn/mixture/base.py                        | 10 +++++-----
 sklearn/mixture/tests/test_gaussian_mixture.py | 18 +++++++++++-------
 2 files changed, 16 insertions(+), 12 deletions(-)
```

**assistant**

```
Fixed the disagreement between `GaussianMixture.fit_predict(X)` and `predict(X)` when `n_init > 1`.

**Root cause:** In `BaseMixture.fit_predict` (`sklearn/mixture/base.py`), the final E-step used to compute the returned labels ran *before* `self._set_parameters(best_params)`. With `n_init > 1`, that final E-step therefore used the parameters left over from the *last* initialization trial, while `predict(X)` used the *best* trial's parameters — so after `fit_predict` mutated the model, subsequent `predict` calls could label points differently.

**Fix:** Moved the final E-step to after `_set_parameters(best_params)` (and after `n_iter_`/`lower_bound_` are set), so `fit_predict` returns labels from the same best parameters that `predict` will use. This also covers `max_iter`/`tol` edge cases as intended by the existing comment.

**Test:** Extended `test_gaussian_mixture_fit_predict` to parametrize over `n_init` (1 and 5) across convergence/non-convergence cases, all covariance types.

Verification: full `sklearn/mixture/tests/` suite passes — **60 passed**. No commits or git state changes made.
```

## Run folder `team-solve-2026-11-06T131054`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
87330378b3f14804aecc3eb9eacc8b0e1d41cf5a
```

### `baseline-check.log`

```
check: pytest sklearn/mixture/tests/test_gaussian_mixture.py -q

==================================== ERRORS ====================================
_______ ERROR collecting sklearn/mixture/tests/test_gaussian_mixture.py ________
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
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T131054/baseline-tree/sklearn/__check_build:
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
_______ ERROR collecting sklearn/mixture/tests/test_gaussian_mixture.py ________
ImportError while importing test module '/testbed/.memdoor/runs/team-solve-2026-11-06T131054/baseline-tree/sklearn/mixture/tests/test_gaussian_mixture.py'.
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
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T131054/baseline-tree/sklearn/__check_build:
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
2 errors in 2.54s
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/sklearn/mixture/base.py b/sklearn/mixture/base.py
index bd34333c0..8920bef18 100755
--- a/sklearn/mixture/base.py
+++ b/sklearn/mixture/base.py
@@ -257,11 +257,6 @@ class BaseMixture(DensityMixin, BaseEstimator, metaclass=ABCMeta):
                 best_params = self._get_parameters()
                 best_n_iter = n_iter
 
-        # Always do a final e-step to guarantee that the labels returned by
-        # fit_predict(X) are always consistent with fit(X).predict(X)
-        # for any value of max_iter and tol (and any random_state).
-        _, log_resp = self._e_step(X)
-
         if not self.converged_:
             warnings.warn('Initialization %d did not converge. '
                           'Try different init parameters, '
@@ -273,6 +268,11 @@ class BaseMixture(DensityMixin, BaseEstimator, metaclass=ABCMeta):
         self.n_iter_ = best_n_iter
         self.lower_bound_ = max_lower_bound
 
+        # Always do a final e-step to guarantee that the labels returned by
+        # fit_predict(X) are always consistent with fit(X).predict(X)
+        # for any value of max_iter and tol (and any random_state).
+        _, log_resp = self._e_step(X)
+
         return log_resp.argmax(axis=1)
 
     def _e_step(self, X):
diff --git a/sklearn/mixture/tests/test_gaussian_mixture.py b/sklearn/mixture/tests/test_gaussian_mixture.py
index 4d549ccd7..f949cadf0 100755
--- a/sklearn/mixture/tests/test_gaussian_mixture.py
+++ b/sklearn/mixture/tests/test_gaussian_mixture.py
@@ -571,13 +571,17 @@ def test_gaussian_mixture_predict_predict_proba():
 
 
 @pytest.mark.filterwarnings("ignore:.*did not converge.*")
-@pytest.mark.parametrize('seed, max_iter, tol', [
-    (0, 2, 1e-7),    # strict non-convergence
-    (1, 2, 1e-1),    # loose non-convergence
-    (3, 300, 1e-7),  # strict convergence
-    (4, 300, 1e-1),  # loose convergence
+@pytest.mark.parametrize('seed, max_iter, tol, n_init', [
+    (0, 2, 1e-7, 1),    # strict non-convergence
+    (1, 2, 1e-1, 1),    # loose non-convergence
+    (3, 300, 1e-7, 1),  # strict convergence
+    (4, 300, 1e-1, 1),  # loose convergence
+    (5, 2, 1e-7, 5),    # strict non-convergence with n_init
+    (6, 2, 1e-1, 5),    # loose non-convergence with n_init
+    (7, 300, 1e-7, 5),  # strict convergence with n_init
+    (8, 300, 1e-1, 5),  # loose convergence with n_init
 ])
-def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
+def test_gaussian_mixture_fit_predict(seed, max_iter, tol, n_init):
     rng = np.random.RandomState(seed)
     rand_data = RandomData(rng)
     for covar_type in COVARIANCE_TYPE:
@@ -588,7 +592,7 @@ def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
                             means_init=rand_data.means,
                             precisions_init=rand_data.precisions[covar_type],
                             covariance_type=covar_type,
-                            max_iter=max_iter, tol=tol)
+                            max_iter=max_iter, tol=tol, n_init=n_init)
 
         # check if fit_predict(X) is equivalent to fit(X).predict(X)
         f = copy.deepcopy(g)
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

GaussianMixture predict and fit_predict disagree when n_init>1
#### Description
When `n_init` is specified in GaussianMixture, the results of fit_predict(X) and predict(X) are often different.  The `test_gaussian_mixture_fit_predict` unit test doesn't catch this because it does not set `n_init`.

#### Steps/Code to Reproduce
```
python
from sklearn.mixture import GaussianMixture
from sklearn.utils.testing import assert_array_equal
import numpy
X = numpy.random.randn(1000,5)
print 'no n_init'
gm = GaussianMixture(n_components=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
print 'n_init=5'
gm = GaussianMixture(n_components=5, n_init=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
```

#### Expected Results
```
no n_init
n_init=5
```
No exceptions.

#### Actual Results
```
no n_init
n_init=5
Traceback (most recent call last):
  File "test_gm.py", line 17, in <module>
    assert_array_equal(c1,c2)
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 872, in assert_array_equal
    verbose=verbose, header='Arrays are not equal')
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 796, in assert_array_compare
    raise AssertionError(msg)
AssertionError: 
Arrays are not equal

(mismatch 88.6%)
 x: array([4, 0, 1, 1, 1, 3, 3, 4, 4, 2, 0, 0, 1, 2, 0, 2, 0, 1, 3, 1, 1, 3,
       2, 1, 0, 2, 1, 0, 2, 0, 3, 1, 2, 3, 3, 1, 0, 2, 2, 0, 3, 0, 2, 0,
       4, 2, 3, 0, 4, 2, 4, 1, 0, 2, 2, 1, 3, 2, 1, 4, 0, 2, 2, 1, 1, 2,...
 y: array([4, 1, 0, 2, 2, 1, 1, 4, 4, 0, 4, 1, 0, 3, 1, 0, 2, 2, 1, 2, 0, 0,
       1, 0, 4, 1, 0, 4, 0, 1, 1, 2, 3, 1, 4, 0, 1, 4, 4, 4, 0, 1, 0, 2,
       4, 1, 1, 2, 4, 3, 4, 0, 2, 3, 2, 3, 0, 0, 2, 3, 3, 3, 3, 0, 3, 2,...
```

#### Versions
```
System:
    python: 2.7.15rc1 (default, Nov 12 2018, 14:31:15)  [GCC 7.3.0]
   machine: Linux-4.15.0-43-generic-x86_64-with-Ubuntu-18.04-bionic
executable: /usr/bin/python

BLAS:
    macros: HAVE_CBLAS=None, NO_ATLAS_INFO=-1
cblas_libs: cblas
  lib_dirs: /usr/lib/x86_64-linux-gnu

Python deps:
    Cython: 0.28.5
     scipy: 1.2.0
setuptools: 39.0.1
       pip: 19.0.1
     numpy: 1.16.0
    pandas: 0.23.1
   sklearn: 0.20.2
```

## Deliverable

Changes to this tree: fix `GaussianMixture` so `fit_predict(X)` and `predict(X)` agree when `n_init > 1`, plus a regression test under `sklearn/mixture/tests/`.

## Check

`pytest sklearn/mixture/tests/test_gaussian_mixture.py -q`

## Scope

`sklearn/mixture/gaussian_mixture.py`
`sklearn/mixture/tests/`

## Done when

- `GaussianMixture(n_components=5, n_init=5).fit_predict(X)` equals `GaussianMixture(...).fit(X).predict(X)` / subsequent `.predict(X)` for the same fitted model.
- The labels returned by `fit_predict` are computed from the same best-of-`n_init` parameters stored as the fitted attributes.
- A regression test in `sklearn/mixture/tests/` exercises `fit_predict` vs `predict` with `n_init > 1`.
- The existing `test_gaussian_mixture_fit_predict` still passes.



# plan.md

## Deliverable
Changes to this tree: fix `GaussianMixture` so `fit_predict(X)` and `predict(X)` agree when `n_init > 1`, plus a regression test under `sklearn/mixture/tests/`.

## Check
`pytest sklearn/mixture/tests/test_gaussian_mixture.py -q`

## Scope
`sklearn/mixture/gaussian_mixture.py`
`sklearn/mixture/tests/`

## Done when
- `GaussianMixture(n_components=5, n_init=5).fit_predict(X)` equals `GaussianMixture(...).fit(X).predict(X)` / subsequent `.predict(X)` for the same fitted model.
- The labels returned by `fit_predict` are computed from the same best-of-`n_init` parameters stored as the fitted attributes.
- A regression test in `sklearn/mixture/tests/` exercises `fit_predict` vs `predict` with `n_init > 1`.
- The existing `test_gaussian_mixture_fit_predict` still passes.

## Approach
Root cause: `fit_predict` returns labels from the low-level `_fit`/`fit` path for one initialization, while `predict` uses the stored best parameters; with `n_init > 1` these can diverge because final attributes are not set from the same selected run before labels are derived. Candidate approaches: (1) make `fit_predict` literally `self.fit(X).predict(X)` — simplest and guarantees agreement; (2) fix the internal `_fit`/`fit_predict` so the best initialization's parameters are assigned to the estimator before labels are computed, keeping a single code path; (3) make `predict` reuse the `fit_predict` code path. Preferred is (1) plus/or (2): ensure the best-init selection sets `weights_`, `means_`, `covariances_`, `precisions_`, `precisions_cholesky_` before labels are produced. Add the regression test with `n_init=5` and `assert_array_equal(c1, c2)`.


# sklearn/mixture/gaussian_mixture.py

```
"""Gaussian Mixture Model."""

# Author: Wei Xue <xuewei4d@gmail.com>
# Modified by Thierry Guillemot <thierry.guillemot.work@gmail.com>
# License: BSD 3 clause

import numpy as np

from scipy import linalg

from .base import BaseMixture, _check_shape
from ..utils import check_array
from ..utils.validation import check_is_fitted
from ..utils.extmath import row_norms


###############################################################################
# Gaussian mixture shape checkers used by the GaussianMixture class

def _check_weights(weights, n_components):
    """Check the user provided 'weights'.

    Parameters
    ----------
    weights : array-like, shape (n_components,)
        The proportions of components of each mixture.

    n_components : int
        Number of components.

    Returns
    -------
    weights : array, shape (n_components,)
    """
    weights = check_array(weights, dtype=[np.float64, np.float32],
                          ensure_2d=False)
    _check_shape(weights, (n_components,), 'weights')

    # check range
    if (any(np.less(weights, 0.)) or
            any(np.greater(weights, 1.))):
        raise ValueError("The parameter 'weights' should be in the range "
                         "[0, 1], but got max value %.5f, min value %.5f"
                         % (np.min(weights), np.max(weights)))

    # check normalization
    if not np.allclose(np.abs(1. - np.sum(weights)), 0.):
        raise ValueError("The parameter 'weights' should be normalized, "
                         "but got sum(weights) = %.5f" % np.sum(weights))
    return weights


def _check_means(means, n_components, n_features):
    """Validate the provided 'means'.

    Parameters
    ----------
    means : array-like, shape (n_components, n_features)
        The centers of the current components.

    n_components : int
        Number of components.

    n_features : int
        Number of features.

    Returns
    -------
    means : array, (n_components, n_features)
    """
    means = check_array(means, dtype=[np.float64, np.float32], ensure_2d=False)
    _check_shape(means, (n_components, n_features), 'means')
    return means


def _check_precision_positivity(precision, covariance_type):
    """Check a precision vector is positive-definite."""
    if np.any(np.less_equal(precision, 0.0)):
        raise ValueError("'%s precision' should be "
                         "positive" % covariance_type)


def _check_precision_matrix(precision, covariance_type):
    """Check a precision matrix is symmetric and positive-definite."""
    if not (np.allclose(precision, precision.T) and
            np.all(linalg.eigvalsh(precision) > 0.)):
        raise ValueError("'%s precision' should be symmetric, "
                         "positive-definite" % covariance_type)


def _check_precisions_full(precisions, covariance_type):
    """Check the precision matrices are symmetric and positive-definite."""
    for prec in precisions:
        _check_precision_matrix(prec, covariance_type)


def _check_precisions(precisions, covariance_type, n_components, n_features):
    """Validate user provided precisions.

    Parameters
    ----------
    precisions : array-like
        'full' : shape of (n_components, n_features, n_features)
        'tied' : shape of (n_features, n_features)
        'diag' : shape of (n_components, n_features)
        'spherical' : shape of (n_components,)

    covariance_type : string

    n_components : int
        Number of components.

    n_features : int
        Number of features.

    Returns
    -------
    precisions : array
    """
    precisions = check_array(precisions, dtype=[np.float64, np.float32],
                             ensure_2d=False,
                             allow_nd=covariance_type == 'full')

    precisions_shape = {'full': (n_components, n_features, n_features),
                        'tied': (n_features, n_features),
                        'diag': (n_components, n_features),
                        'spherical': (n_components,)}
    _check_shape(precisions, precisions_shape[covariance_type],
                 '%s precision' % covariance_type)

    _check_precisions = {'full': _check_precisions_full,
                         'tied': _check_precision_matrix,
                         'diag': _check_precision_positivity,
                         'spherical': _check_precision_positivity}
    _check_precisions[covariance_type](precisions, covariance_type)
    return precisions


###############################################################################
# Gaussian mixture parameters estimators (used by the M-Step)

def _estimate_gaussian_covariances_full(resp, X, nk, means, reg_covar):
    """Estimate the full covariance matrices.

    Parameters
    ----------
    resp : array-like, shape (n_samples, n_components)

    X : array-like, shape (n_samples, n_features)

    nk : array-like, shape (n_components,)

    means : array-like, shape (n_components, n_features)

    reg_covar : float

    Returns
    -------
    covariances : array, shape (n_components, n_features, n_features)
        The covariance matrix of the current components.
    """
    n_components, n_features = means.shape
    covariances = np.empty((n_components, n_features, n_features))
    for k in range(n_components):
        diff = X - means[k]
        covariances[k] = np.dot(resp[:, k] * diff.T, diff) / nk[k]
        covariances[k].flat[::n_features + 1] += reg_covar
    return covariances


def _estimate_gaussian_covariances_tied(resp, X, nk, means, reg_covar):
    """Estimate the tied covariance matrix.

    Parameters
    ----------
    resp : array-like, shape (n_samples, n_components)

    X : array-like, shape (n_samples, n_features)

    nk : array-like, shape (n_components,)

    means : array-like, shape (n_components, n_features)

    reg_covar : float

    Returns
    -------
    covariance : array, shape (n_features, n_features)
        The tied covariance matrix of the components.
    """
    avg_X2 = np.dot(X.T, X)
    avg_means2 = np.dot(nk * means.T, means)
    covariance = avg_X2 - avg_means2
    covariance /= nk.sum()
    covariance.flat[::len(covariance) + 1] += reg_covar
    return covariance


def _estimate_gaussian_covariances_diag(resp, X, nk, means, reg_covar):
    """Estimate the diagonal covariance vectors.

    Parameters
    ----------
    responsibilities : array-like, shape (n_samples, n_components)

    X : array-like, shape (n_samples, n_features)

    nk : array-like, shape (n_components,)

    means : array-like, shape (n_components, n_features)

    reg_covar : float

    Returns
    -------
    covariances : array, shape (n_components, n_features)
        The covariance vector of the current components.
    """
    avg_X2 = np.dot(resp.T, X * X) / nk[:, np.newaxis]
    avg_means2 = means ** 2
    avg_X_means = means * np.dot(resp.T, X) / nk[:, np.newaxis]
    return avg_X2 - 2 * avg_X_means + avg_means2 + reg_covar


def _estimate_gaussian_covariances_spherical(resp, X, nk, means, reg_covar):
    """Estimate the spherical variance values.

    Parameters
    ----------
    responsibilities : array-like, shape (n_samples, n_components)

    X : array-like, shape (n_samples, n_features)

    nk : array-like, shape (n_components,)

    means : array-like, shape (n_components, n_features)

    reg_covar : float

    Returns
    -------
    variances : array, shape (n_components,)
        The variance values of each components.
    """
    return _estimate_gaussian_covariances_diag(resp, X, nk,
                                               means, reg_covar).mean(1)


def _estimate_gaussian_parameters(X, resp, reg_covar, covariance_type):
    """Estimate the Gaussian distribution parameters.

    Parameters
    ----------
    X : array-like, shape (n_samples, n_features)
        The input data array.

    resp : array-like, shape (n_samples, n_components)
        The responsibilities for each data sample in X.

    reg_covar : float
        The regularization added to the diagonal of the covariance matrices.

    covariance_type : {'full', 'tied', 'diag', 'spherical'}
        The type of precision matrices.

    Returns
    -------
    nk : array-like, shape (n_components,)
        The numbers of data samples in the current components.

    means : array-like, shape (n_components, n_features)
        The centers of the current components.

    covariances : array-like
        The covariance matrix of the current components.
        The shape depends of the covariance_type.
    """
    nk = resp.sum(axis=0) + 10 * np.finfo(resp.dtype).eps
    means = np.dot(resp.T, X) / nk[:, np.newaxis]
    covariances = {"full": _estimate_gaussian_covariances_full,
                   "tied": _estimate_gaussian_covariances_tied,
                   "diag": _estimate_gaussian_covariances_diag,
                   "spherical": _estimate_gaussian_covariances_spherical
                   }[covariance_type](resp, X, nk, means, reg_covar)
    return nk, means, covariances


def _compute_precision_cholesky(covariances, covariance_type):
    """Compute the Cholesky decomposition of the precisions.

    Parameters
    ----------
    covariances : array-like
        The covariance matrix of the current components.
        The shape depends of the covariance_type.

    covariance_type : {'full', 'tied', 'diag', 'spherical'}
        The type of precision matrices.

    Returns
    -------
    precisions_cholesky : array-like
        The cholesky decomposition of sample precisions of the current
        components. The shape depends of the covariance_type.
    """
    estimate_precision_error_message = (
        "Fitting the mixture model failed because some components have "
        "ill-defined empirical covariance (for instance caused by singleton "
        "or collapsed samples). Try to decrease the number of components, "
        "or increase reg_covar.")

    if covariance_type in 'full':
        n_components, n_features, _ = covariances.shape
        precisions_chol = np.empty((n_components, n_features, n_features))
        for k, covariance in enumerate(covariances):
            try:
                cov_chol = linalg.cholesky(covariance, lower=True)
            except linalg.LinAlgError:
                raise ValueError(estimate_precision_error_message)
            precisions_chol[k] = linalg.solve_triangular(cov_chol,
                                                         np.eye(n_features),
                                                         lower=True).T
    elif covariance_type == 'tied':
        _, n_features = covariances.shape
        try:
            cov_chol = linalg.cholesky(covariances, lower=True)
        except linalg.LinAlgError:
            raise ValueError(estimate_precision_error_message)
        precisions_chol = linalg.solve_triangular(cov_chol, np.eye(n_features),
                                                  lower=True).T
    else:
        if np.any(np.less_equal(covariances, 0.0)):
            raise ValueError(estimate_precision_error_message)
        precisions_chol = 1. / np.sqrt(covariances)
    return precisions_chol


###############################################################################
# Gaussian mixture probability estimators
def _compute_log_det_cholesky(matrix_chol, covariance_type, n_features):
    """Compute the log-det of the cholesky decomposition of matrices.

    Parameters
    ----------
    matrix_chol : array-like
        Cholesky decompositions of the matrices.
        'full' : shape of (n_components, n_features, n_features)
        'tied' : shape of (n_features, n_features)
        'diag' : shape of (n_components, n_features)
        'spherical' : shape of (n_components,)

    covariance_type : {'full', 'tied', 'diag', 'spherical'}

    n_features : int
        Number of features.

    Returns
    -------
    log_det_precision_chol : array-like, shape (n_components,)
        The determinant of the precision matrix for each component.
    """
    if covariance_type == 'full':
        n_components, _, _ = matrix_chol.shape
        log_det_chol = (np.sum(np.log(
            matrix_chol.reshape(
                n_components, -1)[:, ::n_features + 1]), 1))

    elif covariance_type == 'tied':
        log_det_chol = (np.sum(np.log(np.diag(matrix_chol))))

    elif covariance_type == 'diag':
        log_det_chol = (np.sum(np.log(matrix_chol), axis=1))

    else:
        log_det_chol = n_features * (np.log(matrix_chol))

    return log_det_chol


def _estimate_log_gaussian_prob(X, means, precisions_chol, covariance_type):
    """Estimate the log Gaussian probability.

    Parameters
    ----------
    X : array-like, shape (n_samples, n_features)

    means : array-like, shape (n_components, n_features)

    precisions_chol : array-like
        Cholesky decompositions of the precision matrices.
        'full' : shape of (n_components, n_features, n_features)
        'tied' : shape of (n_features, n_features)
        'diag' : shape of (n_components, n_features)
        'spherical' : shape of (n_components,)

    covariance_type : {'full', 'tied', 'diag', 'spherical'}

    Returns
    -------
    log_prob : array, shape (n_samples, n_components)
    """
    n_samples, n_features = X.shape
    n_components, _ = means.shape
    # det(precision_chol) is half of det(precision)
    log_det = _compute_log_det_cholesky(
        precisions_chol, covariance_type, n_features)

    if covariance_type == 'full':
        log_prob = np.empty((n_samples, n_components))
        for k, (mu, prec_chol) in enumerate(zip(means, precisions_chol)):
            y = np.dot(X, prec_chol) - np.dot(mu, prec_chol)
            log_prob[:, k] = np.sum(np.square(y), axis=1)

    elif covariance_type == 'tied':
        log_prob = np.empty((n_samples, n_components))
        for k, mu in enumerate(means):
            y = np.dot(X, precisions_chol) - np.dot(mu, precisions_chol)
            log_prob[:, k] = np.sum(np.square(y), axis=1)

    elif covariance_type == 'diag':
        precisions = precisions_chol ** 2
        log_prob = (np.sum((means ** 2 * precisions), 1) -
                    2. * np.dot(X, (means * precisions).T) +
                    np.dot(X ** 2, precisions.T))

    elif covariance_type == 'spherical':
        precisions = precisions_chol ** 2
        log_prob = (np.sum(means ** 2, 1) * precisions -
                    2 * np.dot(X, means.T * precisions) +
                    np.outer(row_norms(X, squared=True), precisions))
    return -.5 * (n_features * np.log(2 * np.pi) + log_prob) + log_det


class GaussianMixture(BaseMixture):
    """Gaussian Mixture.

    Representation of a Gaussian mixture model probability distribution.
    This class allows to estimate the parameters of a Gaussian mixture
    distribution.

    Read more in the :ref:`User Guide <gmm>`.

    .. versionadded:: 0.18

    Parameters
    ----------
    n_components : int, defaults to 1.
        The number of mixture components.

    covariance_type : {'full' (default), 'tied', 'diag', 'spherical'}
        String describing the type of covariance parameters to use.
        Must be one of:

        'full'
            each component has its own general covariance matrix
        'tied'
            all components share the same general covariance matrix
        'diag'
            each component has its own diagonal covariance matrix
        'spherical'
            each component has its own single variance

    tol : float, defaults to 1e-3.
        The convergence threshold. EM iterations will stop when the
        lower bound average gain is below this threshold.

    reg_covar : float, defaults to 1e-6.
        Non-negative regularization added to the diagonal of covariance.
        Allows to assure that the covariance matrices are all positive.

    max_iter : int, defaults to 100.
        The number of EM iterations to perform.

    n_init : int, defaults to 1.
        The number of initializations to perform. The best results are kept.

    init_params : {'kmeans', 'random'}, defaults to 'kmeans'.
        The method used to initialize the weights, the means and the
        precisions.
        Must be one of::

            'kmeans' : responsibilities are initialized using kmeans.
            'random' : responsibilities are initialized randomly.

    weights_init : array-like, shape (n_components, ), optional
        The user-provided initial weights, defaults to None.
        If it None, weights are initialized using the `init_params` method.

    means_init : array-like, shape (n_components, n_features), optional
        The user-provided initial means, defaults to None,
        If it None, means are initialized using the `init_params` method.

    precisions_init : array-like, optional.
        The user-provided initial precisions (inverse of the covariance
        matrices), defaults to None.
        If it None, precisions are initialized using the 'init_params' method.
        The shape depends on 'covariance_type'::

            (n_components,)                        if 'spherical',
            (n_features, n_features)               if 'tied',
            (n_components, n_features)             if 'diag',
            (n_components, n_features, n_features) if 'full'

    random_state : int, RandomState instance or None, optional (default=None)
        If int, random_state is the seed used by the random number generator;
        If RandomState instance, random_state is the random number generator;
        If None, the random number generator is the RandomState instance used
        by `np.random`.

    warm_start : bool, default to False.
        If 'warm_start' is True, the solution of the last fitting is used as
        initialization for the next call of fit(). This can speed up
        convergence when fit is called several times on similar problems.
        In that case, 'n_init' is ignored and only a single initialization
        occurs upon the first call.
        See :term:`the Glossary <warm_start>`.

    verbose : int, default to 0.
        Enable verbose output. If 1 then it prints the current
        initialization and each iteration step. If greater than 1 then
        it prints also the log probability and the time needed
        for each step.

    verbose_interval : int, default to 10.
        Number of iteration done before the next print.

    Attributes
    ----------
    weights_ : array-like, shape (n_components,)
        The weights of each mixture components.

    means_ : array-like, shape (n_components, n_features)
        The mean of each mixture component.

    covariances_ : array-like
        The covariance of each mixture component.
        The shape depends on `covariance_type`::

            (n_components,)                        if 'spherical',
            (n_features, n_features)               if 'tied',
            (n_components, n_features)             if 'diag',
            (n_components, n_features, n_features) if 'full'

    precisions_ : array-like
        The precision matrices for each component in the mixture. A precision
        matrix is the inverse of a covariance matrix. A covariance matrix is
        symmetric positive definite so the mixture of Gaussian can be
        equivalently parameterized by the precision matrices. Storing the
        precision matrices instead of the covariance matrices makes it more
        efficient to compute the log-likelihood of new samples at test time.
        The shape depends on `covariance_type`::

            (n_components,)                        if 'spherical',
            (n_features, n_features)               if 'tied',
            (n_components, n_features)             if 'diag',
            (n_components, n_features, n_features) if 'full'

    precisions_cholesky_ : array-like
        The cholesky decomposition of the precision matrices of each mixture
        component. A precision matrix is the inverse of a covariance matrix.
        A covariance matrix is symmetric positive definite so the mixture of
        Gaussian can be equivalently parameterized by the precision matrices.
        Storing the precision matrices instead of the covariance matrices makes
        it more efficient to compute the log-likelihood of new samples at test
        time. The shape depends on `covariance_type`::

            (n_components,)                        if 'spherical',
            (n_features, n_features)               if 'tied',
            (n_components, n_features)             if 'diag',
            (n_components, n_features, n_features) if 'full'

    converged_ : bool
        True when convergence was reached in fit(), False otherwise.

    n_iter_ : int
        Number of step used by the best fit of EM to reach the convergence.

    lower_bound_ : float
        Lower bound value on the log-likelihood (of the training data with
        respect to the model) of the best fit of EM.

    See Also
    --------
    BayesianGaussianMixture : Gaussian mixture model fit with a variational
        inference.
    """

    def __init__(self, n_components=1, covariance_type='full', tol=1e-3,
                 reg_covar=1e-6, max_iter=100, n_init=1, init_params='kmeans',
                 weights_init=None, means_init=None, precisions_init=None,
                 random_state=None, warm_start=False,
                 verbose=0, verbose_interval=10):
        super().__init__(
            n_components=n_components, tol=tol, reg_covar=reg_covar,
            max_iter=max_iter, n_init=n_init, init_params=init_params,
            random_state=random_state, warm_start=warm_start,
            verbose=verbose, verbose_interval=verbose_interval)

        self.covariance_type = covariance_type
        self.weights_init = weights_init
        self.means_init = means_init
        self.precisions_init = precisions_init

    def _check_parameters(self, X):
        """Check the Gaussian mixture parameters are well defined."""
        _, n_features = X.shape
        if self.covariance_type not in ['spherical', 'tied', 'diag', 'full']:
            raise ValueError("Invalid value for 'covariance_type': %s "
                             "'covariance_type' should be in "
                             "['spherical', 'tied', 'diag', 'full']"
                             % self.covariance_type)

        if self.weights_init is not None:
            self.weights_init = _check_weights(self.weights_init,
                                               self.n_components)

        if self.means_init is not None:
            self.means_init = _check_means(self.means_init,
                                           self.n_components, n_features)

        if self.precisions_init is not None:
            self.precisions_init = _check_precisions(self.precisions_init,
                                                     self.covariance_type,
                                                     self.n_components,
                                                     n_features)

    def _initialize(self, X, resp):
        """Initialization of the Gaussian mixture parameters.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)

        resp : array-like, shape (n_samples, n_components)
        """
        n_samples, _ = X.shape

        weights, means, covariances = _estimate_gaussian_parameters(
            X, resp, self.reg_covar, self.covariance_type)
        weights /= n_samples

        self.weights_ = (weights if self.weights_init is None
                         else self.weights_init)
        self.means_ = means if self.means_init is None else self.means_init

        if self.precisions_init is None:
            self.covariances_ = covariances
            self.precisions_cholesky_ = _compute_precision_cholesky(
                covariances, self.covariance_type)
        elif self.covariance_type == 'full':
            self.precisions_cholesky_ = np.array(
                [linalg.cholesky(prec_init, lower=True)
                 for prec_init in self.precisions_init])
        elif self.covariance_type == 'tied':
            self.precisions_cholesky_ = linalg.cholesky(self.precisions_init,
                                                        lower=True)
        else:
            self.precisions_cholesky_ = self.precisions_init

    def _m_step(self, X, log_resp):
        """M step.

        Parameters
        ----------
        X : array-like, shape (n_samples, n_features)

        log_resp : array-like, shape (n_samples, n_components)
            Logarithm of the posterior probabilities (or responsibilities) of
            the point of each sample in X.
        """
        n_samples, _ = X.shape
        self.weights_, self.means_, self.covariances_ = (
            _estimate_gaussian_parameters(X, np.exp(log_resp), self.reg_covar,
                                          self.covariance_type))
        self.weights_ /= n_samples
        self.precisions_cholesky_ = _compute_precision_cholesky(
            self.covariances_, self.covariance_type)

    def _estimate_log_prob(self, X):
        return _estimate_log_gaussian_prob(
            X, self.means_, self.precisions_cholesky_, self.covariance_type)

    def _estimate_log_weights(self):
        return np.log(self.weights_)

    def _compute_lower_bound(self, _, log_prob_norm):
        return log_prob_norm

    def _check_is_fitted(self):
        check_is_fitted(self, ['weights_', 'means_', 'precisions_cholesky_'])

    def _get_parameters(self):
        return (self.weights_, self.means_, self.covariances_,
                self.precisions_cholesky_)

    def _set_parameters(self, params):
        (self.weights_, self.means_, self.covariances_,
         self.precisions_cholesky_) = params

        # Attributes computation
        _, n_features = self.means_.shape

        if self.covariance_type == 'full':
            self.precisions_ = np.empty(self.precisions_cholesky_.shape)
            for k, prec_chol in enumerate(self.precisions_cholesky_):
                self.precisions_[k] = np.dot(prec_chol, prec_chol.T)

        elif self.covariance_type == 'tied':
            self.precisions_ = np.dot(self.precisions_cholesky_,
                                      self.precisions_cholesky_.T)
        else:
            self.precisions_ = self.precisions_cholesky_ ** 2

    def _n_parameters(self):
        """Return the number of free parameters in the model."""
        _, n_features = self.means_.shape
        if self.covariance_type == 'full':
            cov_params = self.n_components * n_features * (n_features + 1) / 2.
        elif self.covariance_type == 'diag':
            cov_params = self.n_components * n_features
        elif self.covariance_type == 'tied':
            cov_params = n_features * (n_features + 1) / 2.
        elif self.covariance_type == 'spherical':
            cov_params = self.n_components
        mean_params = n_features * self.n_components
        return int(cov_params + mean_params + self.n_components - 1)

    def bic(self, X):
        """Bayesian information criterion for the current model on the input X.

        Parameters
        ----------
        X : array of shape (n_samples, n_dimensions)

        Returns
        -------
        bic : float
            The lower the better.
        """
        return (-2 * self.score(X) * X.shape[0] +
                self._n_parameters() * np.log(X.shape[0]))

    def aic(self, X):
        """Akaike information criterion for the current model on the input X.

        Parameters
        ----------
        X : array of shape (n_samples, n_dimensions)

        Returns
        -------
        aic : float
            The lower the better.
        """
        return -2 * self.score(X) * X.shape[0] + 2 * self._n_parameters()

```


# sklearn/mixture/tests (the files in it)

sklearn/mixture/tests/__init__.py
sklearn/mixture/tests/test_bayesian_mixture.py
sklearn/mixture/tests/test_gaussian_mixture.py
sklearn/mixture/tests/test_mixture.py


# The last commit

```
87330378b SWE-bench



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
 build_tools/generate_authors_table.py                       |   0
 conftest.py                                                 |   0
 doc/Makefile                                                |   0
 doc/README.md                                               |   0
 doc/about.rst                                               |   0
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
diff --git a/doc/modules/preprocessing.rst b/doc/modules/preprocessing.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/preprocessing_targets.rst b/doc/modules/preprocessing_targets.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/random_projection.rst b/doc/modules/random_projection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/sgd.rst b/doc/modules/sgd.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/svm.rst b/doc/modules/svm.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/tree.rst b/doc/modules/tree.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/unsupervised_reduction.rst b/doc/modules/unsupervised_reduction.rst
old mode 100644
new mode 100755
diff --git a/doc/other_distributions.rst b
```
````

### `direct-check.log`

```
check: pytest sklearn/mixture/tests/test_gaussian_mixture.py -q
........................................                                 [100%]
40 passed, 8 warnings in 18.02s
scope: sklearn/mixture/gaussian_mixture.py sklearn/mixture/tests
OUTSIDE THE SCOPE: sklearn/mixture/base.py +5 -5 (undo it: git checkout the file, or delete it when the run made it)
changed: sklearn/mixture/tests/test_gaussian_mixture.py +11 -7
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sklearn/mixture/base.py b/sklearn/mixture/base.py
index bd34333c0..8920bef18 100755
--- a/sklearn/mixture/base.py
+++ b/sklearn/mixture/base.py
@@ -257,11 +257,6 @@ class BaseMixture(DensityMixin, BaseEstimator, metaclass=ABCMeta):
                 best_params = self._get_parameters()
                 best_n_iter = n_iter
 
-        # Always do a final e-step to guarantee that the labels returned by
-        # fit_predict(X) are always consistent with fit(X).predict(X)
-        # for any value of max_iter and tol (and any random_state).
-        _, log_resp = self._e_step(X)
-
         if not self.converged_:
             warnings.warn('Initialization %d did not converge. '
                           'Try different init parameters, '
@@ -273,6 +268,11 @@ class BaseMixture(DensityMixin, BaseEstimator, metaclass=ABCMeta):
         self.n_iter_ = best_n_iter
         self.lower_bound_ = max_lower_bound
 
+        # Always do a final e-step to guarantee that the labels returned by
+        # fit_predict(X) are always consistent with fit(X).predict(X)
+        # for any value of max_iter and tol (and any random_state).
+        _, log_resp = self._e_step(X)
+
         return log_resp.argmax(axis=1)
 
     def _e_step(self, X):
diff --git a/sklearn/mixture/tests/test_gaussian_mixture.py b/sklearn/mixture/tests/test_gaussian_mixture.py
index 4d549ccd7..f949cadf0 100755
--- a/sklearn/mixture/tests/test_gaussian_mixture.py
+++ b/sklearn/mixture/tests/test_gaussian_mixture.py
@@ -571,13 +571,17 @@ def test_gaussian_mixture_predict_predict_proba():
 
 
 @pytest.mark.filterwarnings("ignore:.*did not converge.*")
-@pytest.mark.parametrize('seed, max_iter, tol', [
-    (0, 2, 1e-7),    # strict non-convergence
-    (1, 2, 1e-1),    # loose non-convergence
-    (3, 300, 1e-7),  # strict convergence
-    (4, 300, 1e-1),  # loose convergence
+@pytest.mark.parametrize('seed, max_iter, tol, n_init', [
+    (0, 2, 1e-7, 1),    # strict non-convergence
+    (1, 2, 1e-1, 1),    # loose non-convergence
+    (3, 300, 1e-7, 1),  # strict convergence
+    (4, 300, 1e-1, 1),  # loose convergence
+    (5, 2, 1e-7, 5),    # strict non-convergence with n_init
+    (6, 2, 1e-1, 5),    # loose non-convergence with n_init
+    (7, 300, 1e-7, 5),  # strict convergence with n_init
+    (8, 300, 1e-1, 5),  # loose convergence with n_init
 ])
-def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
+def test_gaussian_mixture_fit_predict(seed, max_iter, tol, n_init):
     rng = np.random.RandomState(seed)
     rand_data = RandomData(rng)
     for covar_type in COVARIANCE_TYPE:
@@ -588,7 +592,7 @@ def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
                             means_init=rand_data.means,
                             precisions_init=rand_data.precisions[covar_type],
                             covariance_type=covar_type,
-                            max_iter=max_iter, tol=tol)
+                            max_iter=max_iter, tol=tol, n_init=n_init)
 
         # check if fit_predict(X) is equivalent to fit(X).predict(X)
         f = copy.deepcopy(g)
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
check: pytest sklearn/mixture/tests/test_gaussian_mixture.py -q
........................................                                 [100%]
40 passed, 8 warnings in 7.83s
scope: sklearn/mixture/gaussian_mixture.py sklearn/mixture/tests
OUTSIDE THE SCOPE: sklearn/mixture/base.py +5 -5 (undo it: git checkout the file, or delete it when the run made it)
changed: sklearn/mixture/tests/test_gaussian_mixture.py +11 -7
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
# Notes, run 2026-11-06T131054

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

GaussianMixture predict and fit_predict disagree when n_init>1
#### Description
When `n_init` is specified in GaussianMixture, the results of fit_predict(X) and predict(X) are often different.  The `test_gaussian_mixture_fit_predict` unit test doesn't catch this because it does not set `n_init`.

#### Steps/Code to Reproduce
```
python
from sklearn.mixture import GaussianMixture
from sklearn.utils.testing import assert_array_equal
import numpy
X = numpy.random.randn(1000,5)
print 'no n_init'
gm = GaussianMixture(n_components=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
print 'n_init=5'
gm = GaussianMixture(n_components=5, n_init=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
```

#### Expected Results
```
no n_init
n_init=5
```
No exceptions.

#### Actual Results
```
no n_init
n_init=5
Traceback (most recent call last):
  File "test_gm.py", line 17, in <module>
    assert_array_equal(c1,c2)
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 872, in assert_array_equal
    verbose=verbose, header='Arrays are not equal')
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 796, in assert_array_compare
    raise AssertionError(msg)
AssertionError: 
Arrays are not equal

(mismatch 88.6%)
 x: array([4, 0, 1, 1, 1, 3, 3, 4, 4, 2, 0, 0, 1, 2, 0, 2, 0, 1, 3, 1, 1, 3,
       2, 1, 0, 2, 1, 0, 2, 0, 3, 1, 2, 3, 3, 1, 0, 2, 2, 0, 3, 0, 2, 0,
       4, 2, 3, 0, 4, 2, 4, 1, 0, 2, 2, 1, 3, 2, 1, 4, 0, 2, 2, 1, 1, 2,...
 y: array([4, 1, 0, 2, 2, 1, 1, 4, 4, 0, 4, 1, 0, 3, 1, 0, 2, 2, 1, 2, 0, 0,
       1, 0, 4, 1, 0, 4, 0, 1, 1, 2, 3, 1, 4, 0, 1, 4, 4, 4, 0, 1, 0, 2,
       4, 1, 1, 2, 4, 3, 4, 0, 2, 3, 2, 3, 0, 0, 2, 3, 3, 3, 3, 0, 3, 2,...
```

#### Versions
```
System:
    python: 2.7.15rc1 (default, Nov 12 2018, 14:31:15)  [GCC 7.3.0]
   machine: Linux-4.15.0-43-generic-x86_64-with-Ubuntu-18.04-bionic
executable: /usr/bin/python

BLAS:
    macros: HAVE_CBLAS=None, NO_ATLAS_INFO=-1
cblas_libs: cblas
  lib_dirs: /usr/lib/x86_64-linux-gnu

Python deps:
    Cython: 0.28.5
     scipy: 1.2.0
setuptools: 39.0.1
       pip: 19.0.1
     numpy: 1.16.0
    pandas: 0.23.1
   sklearn: 0.20.2
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
examples/cluster/plot_inductive_clustering.py
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
```


# The last commit

```
87330378b SWE-bench



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
 build_tools/generate_authors_table.py                       |   0
 conftest.py                                                 |   0
 doc/Makefile                                                |   0
 doc/README.md                                               |   0
 doc/about.rst                                               |   0
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
diff --git a/doc/modules/preprocessing.rst b/doc/modules/preprocessing.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/preprocessing_targets.rst b/doc/modules/preprocessing_targets.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/random_projection.rst b/doc/modules/random_projection.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/sgd.rst b/doc/modules/sgd.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/svm.rst b/doc/modules/svm.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/tree.rst b/doc/modules/tree.rst
old mode 100644
new mode 100755
diff --git a/doc/modules/unsupervised_reduction.rst b/doc/modules/unsupervised_reduction.rst
old mode 100644
new mode 100755
diff --git a/doc/other_distributions.rst b
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
Changes to this tree: fix `GaussianMixture` so `fit_predict(X)` and `predict(X)` agree when `n_init > 1`, plus a regression test under `sklearn/mixture/tests/`.

## Check
`pytest sklearn/mixture/tests/test_gaussian_mixture.py -q`

## Scope
`sklearn/mixture/gaussian_mixture.py`
`sklearn/mixture/tests/`

## Done when
- `GaussianMixture(n_components=5, n_init=5).fit_predict(X)` equals `GaussianMixture(...).fit(X).predict(X)` / subsequent `.predict(X)` for the same fitted model.
- The labels returned by `fit_predict` are computed from the same best-of-`n_init` parameters stored as the fitted attributes.
- A regression test in `sklearn/mixture/tests/` exercises `fit_predict` vs `predict` with `n_init > 1`.
- The existing `test_gaussian_mixture_fit_predict` still passes.

## Approach
Root cause: `fit_predict` returns labels from the low-level `_fit`/`fit` path for one initialization, while `predict` uses the stored best parameters; with `n_init > 1` these can diverge because final attributes are not set from the same selected run before labels are derived. Candidate approaches: (1) make `fit_predict` literally `self.fit(X).predict(X)` — simplest and guarantees agreement; (2) fix the internal `_fit`/`fit_predict` so the best initialization's parameters are assigned to the estimator before labels are computed, keeping a single code path; (3) make `predict` reuse the `fit_predict` code path. Preferred is (1) plus/or (2): ensure the best-init selection sets `weights_`, `means_`, `covariances_`, `precisions_`, `precisions_cholesky_` before labels are produced. Add the regression test with `n_init=5` and `assert_array_equal(c1, c2)`.
```

### `prompt.md`

````
GaussianMixture predict and fit_predict disagree when n_init>1
#### Description
When `n_init` is specified in GaussianMixture, the results of fit_predict(X) and predict(X) are often different.  The `test_gaussian_mixture_fit_predict` unit test doesn't catch this because it does not set `n_init`.

#### Steps/Code to Reproduce
```
python
from sklearn.mixture import GaussianMixture
from sklearn.utils.testing import assert_array_equal
import numpy
X = numpy.random.randn(1000,5)
print 'no n_init'
gm = GaussianMixture(n_components=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
print 'n_init=5'
gm = GaussianMixture(n_components=5, n_init=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
```

#### Expected Results
```
no n_init
n_init=5
```
No exceptions.

#### Actual Results
```
no n_init
n_init=5
Traceback (most recent call last):
  File "test_gm.py", line 17, in <module>
    assert_array_equal(c1,c2)
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 872, in assert_array_equal
    verbose=verbose, header='Arrays are not equal')
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 796, in assert_array_compare
    raise AssertionError(msg)
AssertionError: 
Arrays are not equal

(mismatch 88.6%)
 x: array([4, 0, 1, 1, 1, 3, 3, 4, 4, 2, 0, 0, 1, 2, 0, 2, 0, 1, 3, 1, 1, 3,
       2, 1, 0, 2, 1, 0, 2, 0, 3, 1, 2, 3, 3, 1, 0, 2, 2, 0, 3, 0, 2, 0,
       4, 2, 3, 0, 4, 2, 4, 1, 0, 2, 2, 1, 3, 2, 1, 4, 0, 2, 2, 1, 1, 2,...
 y: array([4, 1, 0, 2, 2, 1, 1, 4, 4, 0, 4, 1, 0, 3, 1, 0, 2, 2, 1, 2, 0, 0,
       1, 0, 4, 1, 0, 4, 0, 1, 1, 2, 3, 1, 4, 0, 1, 4, 4, 4, 0, 1, 0, 2,
       4, 1, 1, 2, 4, 3, 4, 0, 2, 3, 2, 3, 0, 0, 2, 3, 3, 3, 3, 0, 3, 2,...
```

#### Versions
```
System:
    python: 2.7.15rc1 (default, Nov 12 2018, 14:31:15)  [GCC 7.3.0]
   machine: Linux-4.15.0-43-generic-x86_64-with-Ubuntu-18.04-bionic
executable: /usr/bin/python

BLAS:
    macros: HAVE_CBLAS=None, NO_ATLAS_INFO=-1
cblas_libs: cblas
  lib_dirs: /usr/lib/x86_64-linux-gnu

Python deps:
    Cython: 0.28.5
     scipy: 1.2.0
setuptools: 39.0.1
       pip: 19.0.1
     numpy: 1.16.0
    pandas: 0.23.1
   sklearn: 0.20.2
```
````

### `review.md`

```
verdict: PASS
- The bug is in `sklearn/mixture/base.py`: the final e-step that computes `fit_predict` labels ran before `self._set_parameters(best_params)`, so when `n_init > 1` it used the parameters of the *last* init run rather than the best ones. Moving the e-step after the fitted attributes are restored is exactly what makes `fit_predict(X)` agree with `predict(X)` for any `n_init`.
- Although the report flags `sklearn/mixture/base.py` as OUTSIDE THE SCOPE, the fix cannot be made anywhere else: the bug is in the shared base class the task's scope file inherits from. A change outside the guessed scope that the fix needs is not a failure reason.
- The regression test change in `sklearn/mixture/tests/test_gaussian_mixture.py` extends the parametrization with `n_init=5` cases (strict/loose, converged/non-converged), so `fit_predict` vs `fit().predict()` is exercised with `n_init > 1`, satisfying the Done-when item.
- The existing `test_gaussian_mixture_fit_predict` still passes; the check ran 40 passed.
- No content was removed from the task's scope files (only the test parametrization was extended, losing nothing), and no unrelated behaviour was changed.
```

### `scope.txt`

```
scope: sklearn/mixture/gaussian_mixture.py sklearn/mixture/tests
OUTSIDE THE SCOPE: sklearn/mixture/base.py +5 -5 (undo it: git checkout the file, or delete it when the run made it)
changed: sklearn/mixture/tests/test_gaussian_mixture.py +11 -7
```

### `task.md`

````
# Task

## Prompt

GaussianMixture predict and fit_predict disagree when n_init>1
#### Description
When `n_init` is specified in GaussianMixture, the results of fit_predict(X) and predict(X) are often different.  The `test_gaussian_mixture_fit_predict` unit test doesn't catch this because it does not set `n_init`.

#### Steps/Code to Reproduce
```
python
from sklearn.mixture import GaussianMixture
from sklearn.utils.testing import assert_array_equal
import numpy
X = numpy.random.randn(1000,5)
print 'no n_init'
gm = GaussianMixture(n_components=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
print 'n_init=5'
gm = GaussianMixture(n_components=5, n_init=5)
c1 = gm.fit_predict(X)
c2 = gm.predict(X)
assert_array_equal(c1,c2)
```

#### Expected Results
```
no n_init
n_init=5
```
No exceptions.

#### Actual Results
```
no n_init
n_init=5
Traceback (most recent call last):
  File "test_gm.py", line 17, in <module>
    assert_array_equal(c1,c2)
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 872, in assert_array_equal
    verbose=verbose, header='Arrays are not equal')
  File "/home/scott/.local/lib/python2.7/site-packages/numpy/testing/_private/utils.py", line 796, in assert_array_compare
    raise AssertionError(msg)
AssertionError: 
Arrays are not equal

(mismatch 88.6%)
 x: array([4, 0, 1, 1, 1, 3, 3, 4, 4, 2, 0, 0, 1, 2, 0, 2, 0, 1, 3, 1, 1, 3,
       2, 1, 0, 2, 1, 0, 2, 0, 3, 1, 2, 3, 3, 1, 0, 2, 2, 0, 3, 0, 2, 0,
       4, 2, 3, 0, 4, 2, 4, 1, 0, 2, 2, 1, 3, 2, 1, 4, 0, 2, 2, 1, 1, 2,...
 y: array([4, 1, 0, 2, 2, 1, 1, 4, 4, 0, 4, 1, 0, 3, 1, 0, 2, 2, 1, 2, 0, 0,
       1, 0, 4, 1, 0, 4, 0, 1, 1, 2, 3, 1, 4, 0, 1, 4, 4, 4, 0, 1, 0, 2,
       4, 1, 1, 2, 4, 3, 4, 0, 2, 3, 2, 3, 0, 0, 2, 3, 3, 3, 3, 0, 3, 2,...
```

#### Versions
```
System:
    python: 2.7.15rc1 (default, Nov 12 2018, 14:31:15)  [GCC 7.3.0]
   machine: Linux-4.15.0-43-generic-x86_64-with-Ubuntu-18.04-bionic
executable: /usr/bin/python

BLAS:
    macros: HAVE_CBLAS=None, NO_ATLAS_INFO=-1
cblas_libs: cblas
  lib_dirs: /usr/lib/x86_64-linux-gnu

Python deps:
    Cython: 0.28.5
     scipy: 1.2.0
setuptools: 39.0.1
       pip: 19.0.1
     numpy: 1.16.0
    pandas: 0.23.1
   sklearn: 0.20.2
```

## Deliverable

Changes to this tree: fix `GaussianMixture` so `fit_predict(X)` and `predict(X)` agree when `n_init > 1`, plus a regression test under `sklearn/mixture/tests/`.

## Check

`pytest sklearn/mixture/tests/test_gaussian_mixture.py -q`

## Scope

`sklearn/mixture/gaussian_mixture.py`
`sklearn/mixture/tests/`

## Done when

- `GaussianMixture(n_components=5, n_init=5).fit_predict(X)` equals `GaussianMixture(...).fit(X).predict(X)` / subsequent `.predict(X)` for the same fitted model.
- The labels returned by `fit_predict` are computed from the same best-of-`n_init` parameters stored as the fitted attributes.
- A regression test in `sklearn/mixture/tests/` exercises `fit_predict` vs `predict` with `n_init > 1`.
- The existing `test_gaussian_mixture_fit_predict` still passes.
````

### `test-output.log`

```
check: pytest sklearn/mixture/tests/test_gaussian_mixture.py -q
........................................                                 [100%]
40 passed, 8 warnings in 9.76s
scope: sklearn/mixture/gaussian_mixture.py sklearn/mixture/tests
OUTSIDE THE SCOPE: sklearn/mixture/base.py +5 -5 (undo it: git checkout the file, or delete it when the run made it)
changed: sklearn/mixture/tests/test_gaussian_mixture.py +11 -7
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
