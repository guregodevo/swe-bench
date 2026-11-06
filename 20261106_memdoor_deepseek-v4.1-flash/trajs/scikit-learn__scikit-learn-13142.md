# scikit-learn__scikit-learn-13142 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 52s 41 lines cost=0.001129 in=85253 cached=70144 out=1289 calls=9`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

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

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "git status --porcelain -- . ':(exclude).memdoor'; echo \"---\"; ls"
}
```

**assistant → tool `locate`**

```json
{
  "query": "GaussianMixture fit_predict and predict implementation n_init"
}
```

**tool result**

```
---
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
```

**tool result**

```
Where "GaussianMixture fit_predict and predict implementation n_init" lives (judged: 6 of 40 sections kept), most relevant first:
1. sklearn/mixture/base.py:181-218  p=0.92
2. sklearn/mixture/gaussian_mixture.py:582-619  p=0.79
3. sklearn/mixture/tests/test_gaussian_mixture.py:139-174  p=0.56
4. doc/whats_new/v0.20.rst:1062-1079  p=0.53

== sklearn/mixture/base.py:181-218 (p=0.92)
  181          Parameters
  182          ----------
  183          X : array-like, shape (n_samples, n_features)
  184              List of n_features-dimensional data points. Each row
  185              corresponds to a single data point.
  186  
  187          Returns
  188          -------
  189          self
  190          """
  191          self.fit_predict(X, y)
  192          return self
  193  
  194      def fit_predict(self, X, y=None):
  195          """Estimate model parameters using X and predict the labels for X.
  196  
  197          The method fits the model n_init times and sets the parameters with
  198          which the model has the largest likelihood or lower bound. Within each
  199          trial, the method iterates between E-step and M-step for `max_iter`
  200          times until the change of likelihood or lower bound is less than
  201          `tol`, otherwise, a `ConvergenceWarning` is raised. After fitting, it
  202          predicts the most probable label for the input data points.
  203  
  204          .. versionadded:: 0.20
  205  
  206          Parameters
  207          ----------
  208          X : array-like, shape (n_samples, n_features)
  209              List of n_features-dimensional data points. Each row
  210              corresponds to a single data point.
  211  
  212          Returns
  213          -------
  214          labels : array, shape (n_samples,)
  215              Component labels.
  216          """
  217          X = _check_X(X, self.n_components, ensure_min_samples=2)
  218          self._check_initial_parameters(X)

== sklearn/mixture/gaussian_mixture.py:582-619 (p=0.79)
  582      See Also
  583      --------
  584      BayesianGaussianMixture : Gaussian mixture model fit with a variational
  585          inference.
  586      """
  587  
  588      def __init__(self, n_components=1, covariance_type='full', tol=1e-3,
  589                   reg_covar=1e-6, max_iter=100, n_init=1, init_params='kmeans',
  590                   weights_init=None, means_init=None, precisions_init=None,
  591                   random_state=None, warm_start=False,
  592                   verbose=0, verbose_interval=10):
  593          super().__init__(
  594              n_components=n_components, tol=tol, reg_covar=reg_covar,
  595              max_iter=max_iter, n_init=n_init, init_params=init_params,
  596              random_state=random_state, warm_start=warm_start,
  597              verbose=verbose, verbose_interval=verbose_interval)
  598  
  599          self.covariance_type = covariance_type
  600          self.weights_init = weights_init
  601          self.means_init = means_init
  602          self.precisions_init = precisions_init
  603  
  604      def _check_parameters(self, X):
  605          """Check the Gaussian mixture parameters are well defined."""
  606          _, n_features = X.shape
  607          if self.covariance_type not in ['spherical', 'tied', 'diag', 'full']:
  608              raise ValueError("Invalid value for 'covariance_type': %s "
  609                               "'covariance_type' should be in "
  610                               "['spherical', 'tied', 'diag', 'full']"
  611                               % self.covariance_type)
  612  
  613          if self.weights_init is not None:
  614              self.weights_init = _check_weights(self.weights_init,
  615                                                 self.n_components)
  616  
  617          if self.means_init is not None:
  618              self.means_init = _check_means(self.means_init,
  619                                             self.n_components, n_features)

== sklearn/mixture/tests/test_gaussian_mixture.py:139-174 (p=0.56)
  139      max_iter_bad = 0
  140      gmm = GaussianMixture(max_iter=max_iter_bad)
  141      assert_raise_message(ValueError,
  142                           "Invalid value for 'max_iter': %d "
  143                           "Estimation requires at least one iteration"
  144                           % max_iter_bad, gmm.fit, X)
  145  
  146      n_init_bad = 0
  147      gmm = GaussianMixture(n_init=n_init_bad)
  148      assert_raise_message(ValueError,
  149                           "Invalid value for 'n_init': %d "
  150                           "Estimation requires at least one run"
  151                           % n_init_bad, gmm.fit, X)
  152  
  153      init_params_bad = 'bad_method'
  154      gmm = GaussianMixture(init_params=init_params_bad)
  155      assert_raise_message(ValueError,
  156                           "Unimplemented initialization method '%s'"
  157                           % init_params_bad,
  158                           gmm.fit, X)
  159  
  160      # test good parameters
  161      n_components, tol, n_init, max_iter, reg_covar = 2, 1e-4, 3, 30, 1e-1
  162      covariance_type, init_params = 'full', 'random'
  163      gmm = GaussianMixture(n_components=n_components, tol=tol, n_init=n_init,
  164                            max_iter=max_iter, reg_covar=reg_covar,
  165                            covariance_type=covariance_type,
  166                            init_params=init_params).fit(X)
  167  
  168      assert_equal(gmm.n_components, n_components)
  169      assert_equal(gmm.covariance_type, covariance_type)
  170      assert_equal(gmm.tol, tol)
  171      assert_equal(gmm.reg_covar, reg_covar)
  172      assert_equal(gmm.max_iter, max_iter)
  173      assert_equal(gmm.n_init, n_init)
  174      assert_equal(gmm.init_params, init_params)

read_file or jread a file to see more; locate again with file set to rank one file's sections.
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/mixture/base.py",
  "offset": 190,
  "limit": 200
}
```

**tool result**

```
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

[147 more lines in /testbed/sklearn/mixture/base.py (536 in all). read_file with offset: 390 to continue]
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

**assistant → tool `grep`**

```json
{
  "pattern": "def test_gaussian_mixture_fit_predict",
  "path": "sklearn/mixture/tests/test_gaussian_mixture.py",
  "output_mode": "content",
  "head_limit": 5
}
```

**tool result**

```
/testbed/sklearn/mixture/tests/test_gaussian_mixture.py:def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n -A30 \"def test_gaussian_mixture_fit_predict\" sklearn/mixture/tests/test_gaussian_mixture.py"
}
```

**tool result**

```
580:def test_gaussian_mixture_fit_predict(seed, max_iter, tol):
581-    rng = np.random.RandomState(seed)
582-    rand_data = RandomData(rng)
583-    for covar_type in COVARIANCE_TYPE:
584-        X = rand_data.X[covar_type]
585-        Y = rand_data.Y
586-        g = GaussianMixture(n_components=rand_data.n_components,
587-                            random_state=rng, weights_init=rand_data.weights,
588-                            means_init=rand_data.means,
589-                            precisions_init=rand_data.precisions[covar_type],
590-                            covariance_type=covar_type,
591-                            max_iter=max_iter, tol=tol)
592-
593-        # check if fit_predict(X) is equivalent to fit(X).predict(X)
594-        f = copy.deepcopy(g)
595-        Y_pred1 = f.fit(X).predict(X)
596-        Y_pred2 = g.fit_predict(X)
597-        assert_array_equal(Y_pred1, Y_pred2)
598-        assert_greater(adjusted_rand_score(Y, Y_pred2), .95)
599-
600-
601-def test_gaussian_mixture_fit():
602-    # recover the ground truth
603-    rng = np.random.RandomState(0)
604-    rand_data = RandomData(rng)
605-    n_features = rand_data.n_features
606-    n_components = rand_data.n_components
607-
608-    for covar_type in COVARIANCE_TYPE:
609-        X = rand_data.X[covar_type]
610-        g = GaussianMixture(n_components=n_components, n_init=20,
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/mixture/tests/test_gaussian_mixture.py\n@@\n                             precisions_init=rand_data.precisions[covar_type],\n                             covariance_type=covar_type,\n-                            max_iter=max_iter, tol=tol)\n+                            max_iter=max_iter, tol=tol, n_init=5)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/mixture/tests/test_gaussian_mixture.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/mixture/tests/test_gaussian_mixture.py now (1035 lines), around the change:
588:                            means_init=rand_data.means,
589:                            precisions_init=rand_data.precisions[covar_type],
590:                            covariance_type=covar_type,
591:                            max_iter=max_iter, tol=tol, n_init=5)
592:
593:        # check if fit_predict(X) is equivalent to fit(X).predict(X)
594:        f = copy.deepcopy(g)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/mixture/tests/test_gaussian_mixture.py -q -k \"fit_predict\" 2>&1 | tail -20"
}
```

**tool result**

```
....                                                                     [100%]
4 passed, 32 deselected in 1.81s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/mixture/tests/ -q 2>&1 | tail -15; echo \"---\"; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo OK"
}
```

**tool result**

```
........................................................                 [100%]
56 passed, 10 warnings in 9.59s
---
OK
```

**assistant**

```
Fixed. The bug was in `sklearn/mixture/base.py`: `fit_predict` performed its final E-step *before* `_set_parameters(best_params)`, so the returned labels came from the last initialization's parameters rather than the best ones. Moved the final E-step after setting the best parameters, guaranteeing consistency with `predict(X)`.

Also updated `test_gaussian_mixture_fit_predict` to use `n_init=5` so the regression is covered. All 56 mixture tests pass, and the completion command exits 0.
```

## Run folder `single-2026-11-06T131039`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

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
