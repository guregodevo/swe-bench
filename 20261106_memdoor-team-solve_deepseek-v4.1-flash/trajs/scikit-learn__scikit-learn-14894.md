# scikit-learn__scikit-learn-14894 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 175s 51 lines cost=0.005402 in=166400 cached=96256 out=8684 calls=17`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

ZeroDivisionError in _sparse_fit for SVM with empty support_vectors_
#### Description
When using sparse data, in the case where the support_vectors_ attribute is be empty, _fit_sparse gives a ZeroDivisionError

#### Steps/Code to Reproduce
```
import numpy as np
import scipy
import sklearn
from sklearn.svm import SVR
x_train = np.array([[0, 1, 0, 0],
[0, 0, 0, 1],
[0, 0, 1, 0],
[0, 0, 0, 1]])
y_train = np.array([0.04, 0.04, 0.10, 0.16])
model = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,
  	    gamma=1.0, kernel='linear', max_iter=15000,
  	    shrinking=True, tol=0.001, verbose=False)
# dense x_train has no error
model.fit(x_train, y_train)

# convert to sparse
xtrain= scipy.sparse.csr_matrix(x_train)
model.fit(xtrain, y_train)

```
#### Expected Results
No error is thrown and  `self.dual_coef_ = sp.csr_matrix([])`

#### Actual Results
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 209, in fit
    fit(X, y, sample_weight, solver_type, kernel, random_seed=seed)
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 302, in _sparse_fit
    dual_coef_indices.size / n_class)
ZeroDivisionError: float division by zero
```

#### Versions
```
>>> sklearn.show_versions() 

System:
executable: /usr/bin/python3
    python: 3.5.2 (default, Nov 12 2018, 13:43:14)  [GCC 5.4.0 20160609]
   machine: Linux-4.15.0-58-generic-x86_64-with-Ubuntu-16.04-xenial

Python deps:
     numpy: 1.17.0
    Cython: None
       pip: 19.2.1
    pandas: 0.22.0
   sklearn: 0.21.3
     scipy: 1.3.0
setuptools: 40.4.3
```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git log --oneline -3 && git status --short | head"
}
```

**tool result**

```
/testbed
CONTRIBUTING.md
COPYING
ISSUE_TEMPLATE.md
MANIFEST.in
Makefile
PULL_REQUEST_TEMPLATE.md
README.rst
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
af9ef9a91 SWE-bench
fdbaa58ac TST Skip some doctests if pillow not installed (#15131)
3753e6c61 DOC Improve sklearn.svm.libsvm docstrings (#15146)
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"dual_coef_indices.size\\|_sparse_fit\\|support_vectors_\" sklearn/svm/base.py | head -40"
}
```

**tool result**

```
193:        fit = self._sparse_fit if self._sparse else self._dense_fit
247:        self.support_, self.support_vectors_, self._n_support, \
261:    def _sparse_fit(self, X, y, sample_weight, solver_type, kernel,
270:        self.support_, self.support_vectors_, dual_coef_data, \
287:        n_SV = self.support_vectors_.shape[0]
290:        dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
291:                                     dual_coef_indices.size / n_class)
331:            X, self.support_, self.support_vectors_, self._n_support,
349:            self.support_vectors_.data,
350:            self.support_vectors_.indices,
351:            self.support_vectors_.indptr,
410:            X, self.support_, self.support_vectors_, self._n_support,
428:            self.support_vectors_.data,
429:            self.support_vectors_.indices,
430:            self.support_vectors_.indptr,
485:        return safe_sparse_dot(self._dual_coef_, self.support_vectors_)
686:            X, self.support_, self.support_vectors_, self._n_support,
705:            self.support_vectors_.data,
706:            self.support_vectors_.indices,
707:            self.support_vectors_.indptr,
719:            coef = safe_sparse_dot(self.dual_coef_, self.support_vectors_)
723:                                    self.support_vectors_)
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/svm/base.py",
  "offset": 255,
  "limit": 70
}
```

**tool result**

```
                cache_size=self.cache_size, coef0=self.coef0,
                gamma=self._gamma, epsilon=self.epsilon,
                max_iter=self.max_iter, random_seed=random_seed)

        self._warn_from_fit_status()

    def _sparse_fit(self, X, y, sample_weight, solver_type, kernel,
                    random_seed):
        X.data = np.asarray(X.data, dtype=np.float64, order='C')
        X.sort_indices()

        kernel_type = self._sparse_kernels.index(kernel)

        libsvm_sparse.set_verbosity_wrap(self.verbose)

        self.support_, self.support_vectors_, dual_coef_data, \
            self.intercept_, self._n_support, \
            self.probA_, self.probB_, self.fit_status_ = \
            libsvm_sparse.libsvm_sparse_train(
                X.shape[1], X.data, X.indices, X.indptr, y, solver_type,
                kernel_type, self.degree, self._gamma, self.coef0, self.tol,
                self.C, self.class_weight_,
                sample_weight, self.nu, self.cache_size, self.epsilon,
                int(self.shrinking), int(self.probability), self.max_iter,
                random_seed)

        self._warn_from_fit_status()

        if hasattr(self, "classes_"):
            n_class = len(self.classes_) - 1
        else:  # regression
            n_class = 1
        n_SV = self.support_vectors_.shape[0]

        dual_coef_indices = np.tile(np.arange(n_SV), n_class)
        dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
                                     dual_coef_indices.size / n_class)
        self.dual_coef_ = sp.csr_matrix(
            (dual_coef_data, dual_coef_indices, dual_coef_indptr),
            (n_class, n_SV))

    def predict(self, X):
        """Perform regression on samples in X.

        For an one-class model, +1 (inlier) or -1 (outlier) is returned.

        Parameters
        ----------
        X : {array-like, sparse matrix}, shape (n_samples, n_features)
            For kernel="precomputed", the expected shape of X is
            (n_samples_test, n_samples_train).

        Returns
        -------
        y_pred : array, shape (n_samples,)
        """
        X = self._validate_for_predict(X)
        predict = self._sparse_predict if self._sparse else self._dense_predict
        return predict(X)

    def _dense_predict(self, X):
        X = self._compute_kernel(X)
        if X.ndim == 1:
            X = check_array(X, order='C', accept_large_sparse=False)

        kernel = self.kernel
        if callable(self.kernel):
            kernel = 'precomputed'
            if X.shape[1] != self.shape_fit_[0]:
                raise ValueError("X.shape[1] = %d should be equal to %d, "

[628 more lines in /testbed/sklearn/svm/base.py (952 in all). read_file with offset: 325 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"empty\\|n_SV\\|dual_coef_\" sklearn/svm/tests/test_svm.py | head -40"
}
```

**tool result**

```
45:    assert_array_equal(clf.dual_coef_, [[-0.25, .25]])
103:    assert_array_equal(clf.dual_coef_, [[-0.25, .25]])
127:    assert_array_equal(clf.dual_coef_, [[-0.25, .25]])
141:    assert_array_almost_equal(clf.dual_coef_, clf2.dual_coef_)
248:    assert_array_almost_equal(clf.dual_coef_,
294:    # We change clf.dual_coef_ at run time and expect .predict() to change
301:    assert_array_equal(clf.dual_coef_, [[-.25, .25]])
303:    clf._dual_coef_ = np.array([[.0, 1.]])
353:    dec = np.dot(rbfs, clf.dual_coef_.T) + clf.intercept_
402:    dec = np.dot(rbfs, reg.dual_coef_.T) + reg.intercept_
484:    dual_coef_no_weight = clf.dual_coef_
487:    assert_allclose(dual_coef_no_weight, clf.dual_coef_)
973:    assert_array_almost_equal(svm_cloned.dual_coef_,
974:                              svm_builtin.dual_coef_)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_svr\\|SVR\\|sparse\" sklearn/svm/tests/test_svm.py | head -50"
}
```

**tool result**

```
13:from scipy import sparse
160:def test_svr():
164:    for clf in (svm.NuSVR(kernel='linear', nu=.4, C=1.0),
165:                svm.NuSVR(kernel='linear', nu=.4, C=10.),
166:                svm.SVR(kernel='linear', C=10.),
167:                svm.LinearSVR(C=10.),
168:                svm.LinearSVR(C=10.)):
174:    svm.SVR().fit(diabetes.data, np.ones(len(diabetes.data)))
175:    svm.LinearSVR().fit(diabetes.data, np.ones(len(diabetes.data)))
179:    # check that SVR(kernel='linear') and LinearSVC() give
182:    lsvr = svm.LinearSVR(C=1e3).fit(diabetes.data, diabetes.target)
185:    svr = svm.SVR(kernel='linear', C=1e3).fit(diabetes.data, diabetes.target)
195:    # check that SVR(kernel='linear') and LinearSVC() give
200:    lsvr = svm.LinearSVR(C=1e3).fit(diabetes.data, diabetes.target,
204:    lsvr_no_weight = svm.LinearSVR(C=1e3).fit(diabetes.data, diabetes.target)
215:    lsvr_unflat = svm.LinearSVR(C=1e3).fit(diabetes.data, diabetes.target,
222:    lsvr_flat = svm.LinearSVR(C=1e3).fit(X_flat, y_flat)
228:def test_svr_errors():
233:    clf = svm.SVR(kernel=lambda x, y: np.array([[1.0]]))
384:def test_svr_predict():
385:    # Test SVR's decision_function
393:    reg = svm.SVR(kernel='linear', C=0.1).fit(X, y)
399:    reg = svm.SVR(kernel='rbf', gamma=1).fit(X, y)
453:    [svm.SVR(C=1e-2), svm.NuSVR(C=1e-2)]
495:     (svm.SVR,
497:     (svm.NuSVR,
502:    ids=['SVC', 'NuSVC', 'SVR', 'NuSVR', 'OneClassSVM']
559:    [svm.SVC, svm.NuSVC, svm.NuSVR],
560:    ids=['SVC', 'NuSVC', 'NuSVR']
640:    # predict with sparse input when trained with dense
643:        clf.predict(sparse.lil_matrix(X))
660:     (svm.SVR, datasets.load_diabetes(return_X_y=True)),
661:     (svm.NuSVR, datasets.load_diabetes(return_X_y=True)),
683:def test_sparse_precomputed():
685:    sparse_gram = sparse.csr_matrix([[1, 0], [0, 1]])
687:        clf.fit(sparse_gram, [0, 1])
739:    # LinearSVR
744:                         svm.LinearSVR(loss="l1").fit, X, y)
750:                         svm.LinearSVR(loss="l2").fit, X, y)
934:        svm.SVR(kernel='linear').fit(iris.data, iris.target),
935:        svm.NuSVR(kernel='linear').fit(iris.data, iris.target),
1006:    clf = svm.NuSVR()
1007:    with pytest.raises(Exception, match=r".*\bNuSVR\b.*\bnot\b.*\bfitted\b"):
1028:    lsvr = svm.LinearSVR(random_state=0, max_iter=2)
1033:def test_svr_coef_sign():
1034:    # Test that SVR(kernel="linear") has coef_ with the right sign.
1039:    for svr in [svm.SVR(kernel='linear'), svm.NuSVR(kernel='linear'),
1040:                svm.LinearSVR()]:
1194:    # Make n_support is correct for oneclass and SVR (used to be
1206:    reg = svm.SVR().fit(X, y)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python - <<'PY'\nimport numpy as np, scipy, scipy.sparse as sp\nfrom sklearn.svm import SVR\nx_train = np.array([[0,1,0,0],[0,0,0,1],[0,0,1,0],[0,0,0,1]])\ny_train = np.array([0.04,0.04,0.10,0.16])\nmodel = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,\n            gamma=1.0, kernel='linear', max_iter=15000, shrinking=True, tol=0.001)\nmodel.fit(x_train, y_train)\nprint('dense sv', model.support_vectors_.shape, model.dual_coef_, model.dual_coef_.shape, model.support_)\nmodel.fit(sp.csr_matrix(x_train), y_train)\nprint('sparse sv', model.support_vectors_.shape, model.dual_coef_, model.dual_coef_.shape)\nPY"
}
```

**tool result**

```
Command FAILED (exit status 1): `cd /testbed && python - <<'PY'
import numpy as np, scipy, scipy.sparse as sp
from sklearn.svm import SVR
x_train = np.array([[0,1,0,0],[0,0,0,1],[0,0,1,0],[0,0,0,1]])
y_train = np.array([0.04,0.04,0.10,0.16])
model = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,
            gamma=1.0, kernel='linear', max_iter=15000, shrinking=True, tol=0.001)
model.fit(x_train, y_train)
print('dense sv', model.support_vectors_.shape, model.dual_coef_, model.dual_coef_.shape, model.support_)
model.fit(sp.csr_matrix(x_train), y_train)
print('sparse sv', model.support_vectors_.shape, model.dual_coef_, model.dual_coef_.shape)
PY`
Output: dense sv (0, 4) [] (1, 0) []
Traceback (most recent call last):
  File "<stdin>", line 9, in <module>
  File "/testbed/sklearn/svm/base.py", line 198, in fit
    fit(X, y, sample_weight, solver_type, kernel, random_seed=seed)
  File "/testbed/sklearn/svm/base.py", line 291, in _sparse_fit
    dual_coef_indices.size / n_class)
ZeroDivisionError: float division by zero

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/svm/base.py",
  "offset": 225,
  "limit": 40
}
```

**tool result**

```
        assert self.fit_status_ in (0, 1)
        if self.fit_status_ == 1:
            warnings.warn('Solver terminated early (max_iter=%i).'
                          '  Consider pre-processing your data with'
                          ' StandardScaler or MinMaxScaler.'
                          % self.max_iter, ConvergenceWarning)

    def _dense_fit(self, X, y, sample_weight, solver_type, kernel,
                   random_seed):
        if callable(self.kernel):
            # you must store a reference to X to compute the kernel in predict
            # TODO: add keyword copy to copy on demand
            self.__Xfit = X
            X = self._compute_kernel(X)

            if X.shape[0] != X.shape[1]:
                raise ValueError("X.shape[0] should be equal to X.shape[1]")

        libsvm.set_verbosity_wrap(self.verbose)

        # we don't pass **self.get_params() to allow subclasses to
        # add other parameters to __init__
        self.support_, self.support_vectors_, self._n_support, \
            self.dual_coef_, self.intercept_, self.probA_, \
            self.probB_, self.fit_status_ = libsvm.fit(
                X, y,
                svm_type=solver_type, sample_weight=sample_weight,
                class_weight=self.class_weight_, kernel=kernel, C=self.C,
                nu=self.nu, probability=self.probability, degree=self.degree,
                shrinking=self.shrinking, tol=self.tol,
                cache_size=self.cache_size, coef0=self.coef0,
                gamma=self._gamma, epsilon=self.epsilon,
                max_iter=self.max_iter, random_seed=random_seed)

        self._warn_from_fit_status()

    def _sparse_fit(self, X, y, sample_weight, solver_type, kernel,
                    random_seed):
        X.data = np.asarray(X.data, dtype=np.float64, order='C')
        X.sort_indices()

[688 more lines in /testbed/sklearn/svm/base.py (952 in all). read_file with offset: 265 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sklearn/svm/base.py\n@@\n         n_SV = self.support_vectors_.shape[0]\n \n         dual_coef_indices = np.tile(np.arange(n_SV), n_class)\n-        dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,\n-                                     dual_coef_indices.size / n_class)\n-        self.dual_coef_ = sp.csr_matrix(\n-            (dual_coef_data, dual_coef_indices, dual_coef_indptr),\n-            (n_class, n_SV))\n+        if not n_SV:\n+            self.dual_coef_ = sp.csr_matrix([])\n+        else:\n+            dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,\n+                                         dual_coef_indices.size / n_class)\n+            self.dual_coef_ = sp.csr_matrix(\n+                (dual_coef_data, dual_coef_indices, dual_coef_indptr),\n+                (n_class, n_SV))\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sklearn/svm/base.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sklearn/svm/base.py now (955 lines), around the change:
287:        n_SV = self.support_vectors_.shape[0]
288:
289:        dual_coef_indices = np.tile(np.arange(n_SV), n_class)
290:        if not n_SV:
291:            self.dual_coef_ = sp.csr_matrix([])
292:        else:
293:            dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
294:                                         dual_coef_indices.size / n_class)
295:            self.dual_coef_ = sp.csr_matrix(
296:                (dual_coef_data, dual_coef_indices, dual_coef_indptr),
297:                (n_class, n_SV))
298:
299:    def predict(self, X):
300:        """Perform regression on samples in X.
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python - <<'PY'\nimport numpy as np, scipy.sparse as sp\nfrom sklearn.svm import SVR\nx_train = np.array([[0,1,0,0],[0,0,0,1],[0,0,1,0],[0,0,0,1]])\ny_train = np.array([0.04,0.04,0.10,0.16])\nmodel = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,\n            gamma=1.0, kernel='linear', max_iter=15000, shrinking=True, tol=0.001)\nmodel.fit(sp.csr_matrix(x_train), y_train)\nprint('sparse sv', model.support_vectors_.shape, repr(model.dual_coef_), model.dual_coef_.shape)\nprint(model.predict(sp.csr_matrix(x_train)))\nPY"
}
```

**tool result**

```
sparse sv (0, 4) <1x0 sparse matrix of type '<class 'numpy.float64'>'
	with 0 stored elements in Compressed Sparse Row format> (1, 0)
[0.1 0.1 0.1 0.1]
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/sklearn/svm/tests/test_svm.py",
  "offset": 159,
  "limit": 30
}
```

**tool result**

```

def test_svr():
    # Test Support Vector Regression

    diabetes = datasets.load_diabetes()
    for clf in (svm.NuSVR(kernel='linear', nu=.4, C=1.0),
                svm.NuSVR(kernel='linear', nu=.4, C=10.),
                svm.SVR(kernel='linear', C=10.),
                svm.LinearSVR(C=10.),
                svm.LinearSVR(C=10.)):
        clf.fit(diabetes.data, diabetes.target)
        assert clf.score(diabetes.data, diabetes.target) > 0.02

    # non-regression test; previously, BaseLibSVM would check that
    # len(np.unique(y)) < 2, which must only be done for SVC
    svm.SVR().fit(diabetes.data, np.ones(len(diabetes.data)))
    svm.LinearSVR().fit(diabetes.data, np.ones(len(diabetes.data)))


def test_linearsvr():
    # check that SVR(kernel='linear') and LinearSVC() give
    # comparable results
    diabetes = datasets.load_diabetes()
    lsvr = svm.LinearSVR(C=1e3).fit(diabetes.data, diabetes.target)
    score1 = lsvr.score(diabetes.data, diabetes.target)

    svr = svm.SVR(kernel='linear', C=1e3).fit(diabetes.data, diabetes.target)
    score2 = svr.score(diabetes.data, diabetes.target)

    assert_allclose(np.linalg.norm(lsvr.coef_),

[1021 more lines in /testbed/sklearn/svm/tests/test_svm.py (1209 in all). read_file with offset: 189 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/sklearn/svm/tests/test_svm.py\n@@\n def test_svr():\n     # Test Support Vector Regression\n \n     diabetes = datasets.load_diabetes()\n@@\n     svm.SVR().fit(diabetes.data, np.ones(len(diabetes.data)))\n     svm.LinearSVR().fit(diabetes.data, np.ones(len(diabetes.data)))\n \n \n+def test_svr_sparse_without_support_vectors():\n+    # Non-regression test for #15045: fitting a sparse SVR can lead to an\n+    # empty support_vectors_ (for instance when all samples are inside the\n+    # epsilon tube), which used to raise a ZeroDivisionError.\n+    X = np.array([[0, 1, 0, 0],\n+                  [0, 0, 0, 1],\n+                  [0, 0, 1, 0],\n+                  [0, 0, 0, 1]])\n+    y = np.array([0.04, 0.04, 0.10, 0.16])\n+    clf = svm.SVR(C=316.227766017, kernel='linear', max_iter=15000)\n+    clf.fit(sparse.csr_matrix(X), y)\n+\n+    assert clf.support_vectors_.shape == (0, X.shape[1])\n+    assert clf.dual_coef_.shape == (1, 0)\n+\n+\n def test_linearsvr():\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/sklearn/svm/tests/test_svm.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/sklearn/svm/tests/test_svm.py now (1225 lines), around the change:
173:    # len(np.unique(y)) < 2, which must only be done for SVC
174:    svm.SVR().fit(diabetes.data, np.ones(len(diabetes.data)))
175:    svm.LinearSVR().fit(diabetes.data, np.ones(len(diabetes.data)))
176:
177:
178:def test_svr_sparse_without_support_vectors():
179:    # Non-regression test for #15045: fitting a sparse SVR can lead to an
180:    # empty support_vectors_ (for instance when all samples are inside the
181:    # epsilon tube), which used to raise a ZeroDivisionError.
182:    X = np.array([[0, 1, 0, 0],
183:                  [0, 0, 0, 1],
184:                  [0, 0, 1, 0],
185:                  [0, 0, 0, 1]])
186:    y = np.array([0.04, 0.04, 0.10, 0.16])
187:    clf = svm.SVR(C=316.227766017, kernel='linear', max_iter=15000)
188:    clf.fit(sparse.csr_matrix(X), y)
189:
190:    assert clf.support_vectors_.shape == (0, X.shape[1])
191:    assert clf.dual_coef_.shape == (1, 0)
192:
193:
194:def test_linearsvr():
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest sklearn/svm/tests/test_svm.py::test_svr_sparse_without_support_vectors sklearn/svm/tests/test_svm.py::test_svr -q 2>&1 | tail -20"
}
```

**tool result**

```
..                                                                       [100%]
2 passed, 1 warning in 0.30s
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest sklearn/svm/tests/test_svm.py -q 2>&1 | tail -15"
}
```

**tool result**

```
........................................................................ [ 83%]
..............                                                           [100%]
86 passed, 13 warnings in 5.40s
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python - <<'PY'\nimport numpy as np, scipy.sparse as sp\nfrom sklearn.svm import SVR\nX = np.array([[0,1,0,0],[0,0,0,1],[0,0,1,0],[0,0,0,1]])\ny = np.array([0.04,0.04,0.10,0.16])\nm=SVR(C=316.227766017,kernel='linear',max_iter=15000).fit(sp.csr_matrix(X),y)\nprint(m.coef_, m.intercept_, m.score(sp.csr_matrix(X), y))\nprint(m.predict(sp.csr_matrix(X)))\nPY"
}
```

**tool result**

```
 [0.1] -0.09090909090909105
[0.1 0.1 0.1 0.1]
```

**assistant**

```
Fixed the `ZeroDivisionError` in `sklearn/svm/base.py::_sparse_fit`.

**Change:** when `n_SV == 0` (empty `support_vectors_`), `dual_coef_` is now set directly to `sp.csr_matrix([])` instead of computing `dual_coef_indices.size / n_class` (which divides by zero). The non-empty path is unchanged.

**Test added:** `test_svr_sparse_without_support_vectors` in `sklearn/svm/tests/test_svm.py`, reproducing the issue's data and asserting `support_vectors_.shape == (0, n_features)` and `dual_coef_.shape == (1, 0)`.

**Verification:** the reproduction now fits and predicts without error; the full `sklearn/svm/tests/test_svm.py` suite passes (86 passed).
```

## Run folder `team-solve-2026-11-06T134909`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
af9ef9a919244fcf4d09c133ce56203e6ea3f5f1
```

### `baseline-check.log`

```
check: pytest sklearn/svm/tests -q
ImportError while loading conftest '/testbed/.memdoor/runs/team-solve-2026-11-06T134909/baseline-tree/conftest.py'.
conftest.py:14: in <module>
    from sklearn import set_config
sklearn/__init__.py:78: in <module>
    from . import __check_build
sklearn/__check_build/__init__.py:46: in <module>
    raise_build_error(e)
sklearn/__check_build/__init__.py:41: in raise_build_error
    %s""" % (e, local_dir, ''.join(dir_content).strip(), msg))
E   ImportError: No module named 'sklearn.__check_build._check_build'
E   ___________________________________________________________________________
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T134909/baseline-tree/sklearn/__check_build:
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
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/sklearn/svm/base.py b/sklearn/svm/base.py
index 64cebe837..fb2b734c0 100755
--- a/sklearn/svm/base.py
+++ b/sklearn/svm/base.py
@@ -287,11 +287,14 @@ class BaseLibSVM(BaseEstimator, metaclass=ABCMeta):
         n_SV = self.support_vectors_.shape[0]
 
         dual_coef_indices = np.tile(np.arange(n_SV), n_class)
-        dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
-                                     dual_coef_indices.size / n_class)
-        self.dual_coef_ = sp.csr_matrix(
-            (dual_coef_data, dual_coef_indices, dual_coef_indptr),
-            (n_class, n_SV))
+        if not n_SV:
+            self.dual_coef_ = sp.csr_matrix([])
+        else:
+            dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
+                                         dual_coef_indices.size / n_class)
+            self.dual_coef_ = sp.csr_matrix(
+                (dual_coef_data, dual_coef_indices, dual_coef_indptr),
+                (n_class, n_SV))
 
     def predict(self, X):
         """Perform regression on samples in X.
diff --git a/sklearn/svm/tests/test_svm.py b/sklearn/svm/tests/test_svm.py
index 6ba141811..135feda27 100755
--- a/sklearn/svm/tests/test_svm.py
+++ b/sklearn/svm/tests/test_svm.py
@@ -175,6 +175,22 @@ def test_svr():
     svm.LinearSVR().fit(diabetes.data, np.ones(len(diabetes.data)))
 
 
+def test_svr_sparse_without_support_vectors():
+    # Non-regression test for #15045: fitting a sparse SVR can lead to an
+    # empty support_vectors_ (for instance when all samples are inside the
+    # epsilon tube), which used to raise a ZeroDivisionError.
+    X = np.array([[0, 1, 0, 0],
+                  [0, 0, 0, 1],
+                  [0, 0, 1, 0],
+                  [0, 0, 0, 1]])
+    y = np.array([0.04, 0.04, 0.10, 0.16])
+    clf = svm.SVR(C=316.227766017, kernel='linear', max_iter=15000)
+    clf.fit(sparse.csr_matrix(X), y)
+
+    assert clf.support_vectors_.shape == (0, X.shape[1])
+    assert clf.dual_coef_.shape == (1, 0)
+
+
 def test_linearsvr():
     # check that SVR(kernel='linear') and LinearSVC() give
     # comparable results
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

ZeroDivisionError in _sparse_fit for SVM with empty support_vectors_
#### Description
When using sparse data, in the case where the support_vectors_ attribute is be empty, _fit_sparse gives a ZeroDivisionError

#### Steps/Code to Reproduce
```
import numpy as np
import scipy
import sklearn
from sklearn.svm import SVR
x_train = np.array([[0, 1, 0, 0],
[0, 0, 0, 1],
[0, 0, 1, 0],
[0, 0, 0, 1]])
y_train = np.array([0.04, 0.04, 0.10, 0.16])
model = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,
  	    gamma=1.0, kernel='linear', max_iter=15000,
  	    shrinking=True, tol=0.001, verbose=False)
# dense x_train has no error
model.fit(x_train, y_train)

# convert to sparse
xtrain= scipy.sparse.csr_matrix(x_train)
model.fit(xtrain, y_train)

```
#### Expected Results
No error is thrown and  `self.dual_coef_ = sp.csr_matrix([])`

#### Actual Results
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 209, in fit
    fit(X, y, sample_weight, solver_type, kernel, random_seed=seed)
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 302, in _sparse_fit
    dual_coef_indices.size / n_class)
ZeroDivisionError: float division by zero
```

#### Versions
```
>>> sklearn.show_versions() 

System:
executable: /usr/bin/python3
    python: 3.5.2 (default, Nov 12 2018, 13:43:14)  [GCC 5.4.0 20160609]
   machine: Linux-4.15.0-58-generic-x86_64-with-Ubuntu-16.04-xenial

Python deps:
     numpy: 1.17.0
    Cython: None
       pip: 19.2.1
    pandas: 0.22.0
   sklearn: 0.21.3
     scipy: 1.3.0
setuptools: 40.4.3
```

## Deliverable

changes to this tree

## Check

`pytest sklearn/svm/tests -q`

## Scope

`sklearn/svm/`

## Done when

Fitting the reported sparse `SVR` input completes without raising `ZeroDivisionError`.
With an empty `support_vectors_`, `dual_coef_` is set to an empty sparse matrix equivalent to `sp.csr_matrix([])`.
Fitting the same data in dense form still completes without error.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest sklearn/svm/tests -q`

## Scope
`sklearn/svm/`

## Done when
Fitting the reported sparse `SVR` input completes without raising `ZeroDivisionError`.
With an empty `support_vectors_`, `dual_coef_` is set to an empty sparse matrix equivalent to `sp.csr_matrix([])`.
Fitting the same data in dense form still completes without error.

## Approach
Reproduce the failure, locate the `_sparse_fit` path in the SVM base implementation, and confirm which divisor becomes zero when libsvm returns zero support vectors; then compare the dense and sparse post-fit attributes.

Candidate 1: guard the empty-support case before constructing the CSR dual coefficients, assigning `sp.csr_matrix([])` and preserving the other expected empty attributes. This directly matches the reported expectation but must keep the fitted model’s predict path and attribute shapes consistent.

Candidate 2: make the index-pointer computation safe for an empty support set, e.g. avoid dividing by a zero count and build an empty `indptr`. This is a smaller change but risks producing shapes that do not match the dense empty case or the expected `csr_matrix([])`.

Candidate 3: special-case only the regression path that produced zero support vectors. This is narrow and low-risk for the reproducer but may leave the same failure for other empty-support SVM variants, so it is the fallback if a general guard has side effects.


# sklearn/svm (the files in it)

sklearn/svm/__init__.py
sklearn/svm/base.py
sklearn/svm/bounds.py
sklearn/svm/classes.py
sklearn/svm/liblinear.pxd
sklearn/svm/liblinear.pyx
sklearn/svm/libsvm.pxd
sklearn/svm/libsvm.pyx
sklearn/svm/libsvm_sparse.pyx
sklearn/svm/setup.py
sklearn/svm/src/liblinear/COPYRIGHT
sklearn/svm/src/liblinear/_cython_blas_helpers.h
sklearn/svm/src/liblinear/liblinear_helper.c
sklearn/svm/src/liblinear/linear.cpp
sklearn/svm/src/liblinear/linear.h
sklearn/svm/src/liblinear/tron.cpp
sklearn/svm/src/liblinear/tron.h
sklearn/svm/src/libsvm/LIBSVM_CHANGES
sklearn/svm/src/libsvm/libsvm_helper.c
sklearn/svm/src/libsvm/libsvm_sparse_helper.c
sklearn/svm/src/libsvm/libsvm_template.cpp
sklearn/svm/src/libsvm/svm.cpp
sklearn/svm/src/libsvm/svm.h
sklearn/svm/tests/__init__.py
sklearn/svm/tests/test_bounds.py
sklearn/svm/tests/test_sparse.py
sklearn/svm/tests/test_svm.py


# The last commit

```
af9ef9a91 SWE-bench



 .binder/postBuild                                           |   0
 .binder/requirements.txt                                    |   0
 .circleci/artifact_path                                     |   0
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
 azure-pipelines.yml                                         |   0
 benchmarks/.gitignore                                       |   0
 benchmarks/bench_20newsgroups.py                            |   0
 benchmarks/bench_covertype.py                               |   0
 benchmarks/bench_feature_expansions.py                      |   0
 benchmarks/bench_glm.py                                     |   0
 benchmarks/bench_glmnet.py                                  |   0
 benchmarks/bench_hist_gradient_boosting.py                  |   0
 benchmarks/bench_hist_gradient_boosting_higgsboson.py       |   0
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
 build_tools/azure/install.cmd                               |   0
 build_tools/azure/posix-32.yml                              |   0
 build_tools/azure/posix.yml                                 |   0
```

```diff
diff --git a/.binder/postBuild b/.binder/postBuild
old mode 100644
new mode 100755
diff --git a/.binder/requirements.txt b/.binder/requirements.txt
old mode 100644
new mode 100755
diff --git a/.circleci/artifact_path b/.circleci/artifact_path
old mode 100644
new mode 100755
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
diff --git a/benchmarks/bench_hist_gradient_boosting.py b/benchmarks/bench_hist_gradient_boosting.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_hist_gradient_boosting_higgsboson.py b/benchmarks/bench_hist_gradient_boosting_higgsboson.py
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
diff --git a/build_tools/azure/install.cmd b/build_tools/azure/install.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/posix-32.yml b/build_tools/azure/posix-32.yml
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
diff --git a/doc/authors_emeritus.rst b/doc/authors_emeritus.rst
old mode 100644
new mode 100755
diff --git a/doc/binder/requirements.txt b/doc/binder/requirements.txt
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/conftest.py b/doc/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/contents.rst b/doc/contents.rst
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
diff --git a/doc/developers/develop.rst b/doc/developers/develop.rst
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
diff --git a/doc/developers/plotting.rst b/doc/developers/plotting.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/tips.rst b/doc/developers/tips.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/utilities.rst b/doc/developers/utilities.rst
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/getting_started.rst b/doc/getting_started.rst
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
diff --git a/doc/images/columbia-small.png b/doc/images/columbia-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/dysco.png b/doc/images/dysco.png
old mode 100644
new mode 100755
diff --git a/doc/images/fnrs-logo-small.png b/doc/images/fnrs-logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/google-small.png b/doc/images/google-small.png
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
diff --git a/doc/images/inria-small.png b/doc/images/inria-small.png
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
diff --git a/doc/images/scikit-learn-logo-small.png b/doc/images/scikit-learn-logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/sloan_banner.png b/doc/images/sloan_banner.png
old mode 100644
new mode 100755
diff --git a/doc/images/sloan_logo-small.png b/doc/images/sloan_logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/sydney-stacked-small.png b/doc/images/sydney-stacked-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/telecom-small.png b/doc/images/telecom-small.png
old mode 100644
new mode 100755
diff --git a/doc/includes/big_toc_css.rst b/doc/includes/big_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/includes/bigger_toc_css.rst b/doc/includes/bigger_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/inspection.rst b/doc/inspection.rst
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
diff --git a/doc/modules/lda_qda.rst b/d
```
````

### `direct-check.log`

```
check: pytest sklearn/svm/tests -q
........................................................................ [ 52%]
................................................................         [100%]
136 passed, 14 warnings in 6.26s
scope: sklearn/svm
changed: sklearn/svm/base.py +8 -5
changed: sklearn/svm/tests/test_svm.py +16 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/sklearn/svm/base.py b/sklearn/svm/base.py
index 64cebe837..fb2b734c0 100755
--- a/sklearn/svm/base.py
+++ b/sklearn/svm/base.py
@@ -287,11 +287,14 @@ class BaseLibSVM(BaseEstimator, metaclass=ABCMeta):
         n_SV = self.support_vectors_.shape[0]
 
         dual_coef_indices = np.tile(np.arange(n_SV), n_class)
-        dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
-                                     dual_coef_indices.size / n_class)
-        self.dual_coef_ = sp.csr_matrix(
-            (dual_coef_data, dual_coef_indices, dual_coef_indptr),
-            (n_class, n_SV))
+        if not n_SV:
+            self.dual_coef_ = sp.csr_matrix([])
+        else:
+            dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
+                                         dual_coef_indices.size / n_class)
+            self.dual_coef_ = sp.csr_matrix(
+                (dual_coef_data, dual_coef_indices, dual_coef_indptr),
+                (n_class, n_SV))
 
     def predict(self, X):
         """Perform regression on samples in X.
diff --git a/sklearn/svm/tests/test_svm.py b/sklearn/svm/tests/test_svm.py
index 6ba141811..135feda27 100755
--- a/sklearn/svm/tests/test_svm.py
+++ b/sklearn/svm/tests/test_svm.py
@@ -175,6 +175,22 @@ def test_svr():
     svm.LinearSVR().fit(diabetes.data, np.ones(len(diabetes.data)))
 
 
+def test_svr_sparse_without_support_vectors():
+    # Non-regression test for #15045: fitting a sparse SVR can lead to an
+    # empty support_vectors_ (for instance when all samples are inside the
+    # epsilon tube), which used to raise a ZeroDivisionError.
+    X = np.array([[0, 1, 0, 0],
+                  [0, 0, 0, 1],
+                  [0, 0, 1, 0],
+                  [0, 0, 0, 1]])
+    y = np.array([0.04, 0.04, 0.10, 0.16])
+    clf = svm.SVR(C=316.227766017, kernel='linear', max_iter=15000)
+    clf.fit(sparse.csr_matrix(X), y)
+
+    assert clf.support_vectors_.shape == (0, X.shape[1])
+    assert clf.dual_coef_.shape == (1, 0)
+
+
 def test_linearsvr():
     # check that SVR(kernel='linear') and LinearSVC() give
     # comparable results
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
check: pytest sklearn/svm/tests -q
........................................................................ [ 52%]
................................................................         [100%]
136 passed, 15 warnings in 6.40s
scope: sklearn/svm
changed: sklearn/svm/base.py +8 -5
changed: sklearn/svm/tests/test_svm.py +16 -0
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
# Notes, run 2026-11-06T134909

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

ZeroDivisionError in _sparse_fit for SVM with empty support_vectors_
#### Description
When using sparse data, in the case where the support_vectors_ attribute is be empty, _fit_sparse gives a ZeroDivisionError

#### Steps/Code to Reproduce
```
import numpy as np
import scipy
import sklearn
from sklearn.svm import SVR
x_train = np.array([[0, 1, 0, 0],
[0, 0, 0, 1],
[0, 0, 1, 0],
[0, 0, 0, 1]])
y_train = np.array([0.04, 0.04, 0.10, 0.16])
model = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,
  	    gamma=1.0, kernel='linear', max_iter=15000,
  	    shrinking=True, tol=0.001, verbose=False)
# dense x_train has no error
model.fit(x_train, y_train)

# convert to sparse
xtrain= scipy.sparse.csr_matrix(x_train)
model.fit(xtrain, y_train)

```
#### Expected Results
No error is thrown and  `self.dual_coef_ = sp.csr_matrix([])`

#### Actual Results
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 209, in fit
    fit(X, y, sample_weight, solver_type, kernel, random_seed=seed)
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 302, in _sparse_fit
    dual_coef_indices.size / n_class)
ZeroDivisionError: float division by zero
```

#### Versions
```
>>> sklearn.show_versions() 

System:
executable: /usr/bin/python3
    python: 3.5.2 (default, Nov 12 2018, 13:43:14)  [GCC 5.4.0 20160609]
   machine: Linux-4.15.0-58-generic-x86_64-with-Ubuntu-16.04-xenial

Python deps:
     numpy: 1.17.0
    Cython: None
       pip: 19.2.1
    pandas: 0.22.0
   sklearn: 0.21.3
     scipy: 1.3.0
setuptools: 40.4.3
```


# The files of the project

```
.binder/postBuild
.binder/requirements.txt
.circleci/artifact_path
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
azure-pipelines.yml
benchmarks/.gitignore
benchmarks/bench_20newsgroups.py
benchmarks/bench_covertype.py
benchmarks/bench_feature_expansions.py
benchmarks/bench_glm.py
benchmarks/bench_glmnet.py
benchmarks/bench_hist_gradient_boosting.py
benchmarks/bench_hist_gradient_boosting_higgsboson.py
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
build_tools/azure/install.cmd
build_tools/azure/install.sh
build_tools/azure/posix-32.yml
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
build_tools/circle/check_deprecated_properties.sh
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
doc/authors_emeritus.rst
doc/binder/requirements.txt
doc/conf.py
doc/conftest.py
doc/contents.rst
doc/data_transforms.rst
doc/datasets/index.rst
doc/developers/advanced_installation.rst
doc/developers/contributing.rst
doc/developers/develop.rst
doc/developers/index.rst
doc/developers/maintainer.rst
doc/developers/performance.rst
doc/developers/plotting.rst
doc/developers/tips.rst
doc/developers/utilities.rst
doc/faq.rst
doc/getting_started.rst
doc/glossary.rst
doc/governance.rst
doc/images/cds-logo.png
doc/images/columbia-small.png
doc/images/dysco.png
doc/images/fnrs-logo-small.png
doc/images/google-small.png
doc/images/grid_search_cross_validation.png
doc/images/grid_search_workflow.png
doc/images/inria-logo.jpg
doc/images/inria-small.png
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
doc/images/scikit-learn-logo-small.png
doc/images/sloan_banner.png
doc/images/sloan_logo-small.png
doc/images/sydney-stacked-small.png
doc/images/telecom-small.png
doc/includes/big_toc_css.rst
doc/includes/bigger_toc_css.rst
doc/inspection.rst
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
doc/modules/partial_dependence.rst
doc/modules/permutation_importance.rst
doc/modules/pipeline.rst
doc/modules/preprocessing.rst
doc/modules/preprocessing_targets.rst
doc/modules/random_projection.rst
doc/modules/sgd.rst
doc/modules/svm.rst
doc/modules/tree.rst
doc/modules/unsupervised_reduction.rst
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
doc/templates/documentation.html
doc/templates/function.rst
doc/templates/generate_deprecated.sh
doc/templates/index.html
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
doc/themes/scikit-learn-modern/javascript.html
doc/themes/scikit-learn-modern/layout.html
doc/themes/scikit-learn-modern/nav.html
doc/themes/scikit-learn-modern/page.html
doc/themes/scikit-learn-modern/search.html
doc/themes/scikit-learn-modern/static/css/theme.css
doc/themes/scikit-learn-modern/static/css/vendor/bootstrap.min.css
doc/themes/scikit-learn-modern/static/documentation_options.js_t
doc/themes/scikit-learn-modern/static/js/vendor/bootstrap.min.js
doc/themes/scikit-learn-modern/static/js/vendor/jquery.min.js
doc/themes/scikit-learn-modern/theme.conf
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
doc/visualizations.rst
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
doc/whats_new/v0.22.rst
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
examples/cluster/plot_agglomerative_dendrogram.py
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
examples/ensemble/plot_random_forest_embedding.py
examples/ensemble/plot_random_forest_regression_multioutput.py
examples/ensemble/plot_stack_predictors.py
examples/ensemble/plot_voting_decision_regions.py
examples/ensemble/plot_voting_probas.py
examples/ensemble/plot_voting_regressor.py
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
examples/inspection/README.txt
examples/inspection/plot_partial_dependence.py
examples/inspection/plot_permutation_importance.py
examples/inspection/plot_permutation_importance_multicollinear.py
examples/linear_model/README.txt
examples/linear_model/plot_ard.py
examples/linear_model/plot_bayesian_ridge.py
examples/linear_model/plot_bayesian_ridge_curvefit.py
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
examples/neighbors/approximate_nearest_neighbors.py
examples/neighbors/plot_caching_nearest_neighbors.py
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
examples/plot_partial_dependence_visualization_api.py
examples/plot_roc_curve_visualization_api.py
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
examples/svm/plot_linearsvc_support_vectors.py
examples/svm/plot_oneclass.py
examples/svm/plot_rbf_parameters.py
examples/svm/plot_separating_hyperplane.py
examples/svm/plot_separating_hyperplane_unbalanced.py
examples/svm/plot_svm_anova.py
examples/svm/plot_svm_kernels.py
examples/svm/plot_svm_margin.py
examples/svm/plot_svm_nonlinear.py
examples/svm/plot_svm_regression.py
```


# The last commit

```
af9ef9a91 SWE-bench



 .binder/postBuild                                           |   0
 .binder/requirements.txt                                    |   0
 .circleci/artifact_path                                     |   0
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
 azure-pipelines.yml                                         |   0
 benchmarks/.gitignore                                       |   0
 benchmarks/bench_20newsgroups.py                            |   0
 benchmarks/bench_covertype.py                               |   0
 benchmarks/bench_feature_expansions.py                      |   0
 benchmarks/bench_glm.py                                     |   0
 benchmarks/bench_glmnet.py                                  |   0
 benchmarks/bench_hist_gradient_boosting.py                  |   0
 benchmarks/bench_hist_gradient_boosting_higgsboson.py       |   0
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
 build_tools/azure/install.cmd                               |   0
 build_tools/azure/posix-32.yml                              |   0
 build_tools/azure/posix.yml                                 |   0
```

```diff
diff --git a/.binder/postBuild b/.binder/postBuild
old mode 100644
new mode 100755
diff --git a/.binder/requirements.txt b/.binder/requirements.txt
old mode 100644
new mode 100755
diff --git a/.circleci/artifact_path b/.circleci/artifact_path
old mode 100644
new mode 100755
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
diff --git a/benchmarks/bench_hist_gradient_boosting.py b/benchmarks/bench_hist_gradient_boosting.py
old mode 100644
new mode 100755
diff --git a/benchmarks/bench_hist_gradient_boosting_higgsboson.py b/benchmarks/bench_hist_gradient_boosting_higgsboson.py
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
diff --git a/build_tools/azure/install.cmd b/build_tools/azure/install.cmd
old mode 100644
new mode 100755
diff --git a/build_tools/azure/posix-32.yml b/build_tools/azure/posix-32.yml
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
diff --git a/doc/authors_emeritus.rst b/doc/authors_emeritus.rst
old mode 100644
new mode 100755
diff --git a/doc/binder/requirements.txt b/doc/binder/requirements.txt
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/conftest.py b/doc/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/contents.rst b/doc/contents.rst
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
diff --git a/doc/developers/develop.rst b/doc/developers/develop.rst
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
diff --git a/doc/developers/plotting.rst b/doc/developers/plotting.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/tips.rst b/doc/developers/tips.rst
old mode 100644
new mode 100755
diff --git a/doc/developers/utilities.rst b/doc/developers/utilities.rst
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/getting_started.rst b/doc/getting_started.rst
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
diff --git a/doc/images/columbia-small.png b/doc/images/columbia-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/dysco.png b/doc/images/dysco.png
old mode 100644
new mode 100755
diff --git a/doc/images/fnrs-logo-small.png b/doc/images/fnrs-logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/google-small.png b/doc/images/google-small.png
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
diff --git a/doc/images/inria-small.png b/doc/images/inria-small.png
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
diff --git a/doc/images/scikit-learn-logo-small.png b/doc/images/scikit-learn-logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/sloan_banner.png b/doc/images/sloan_banner.png
old mode 100644
new mode 100755
diff --git a/doc/images/sloan_logo-small.png b/doc/images/sloan_logo-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/sydney-stacked-small.png b/doc/images/sydney-stacked-small.png
old mode 100644
new mode 100755
diff --git a/doc/images/telecom-small.png b/doc/images/telecom-small.png
old mode 100644
new mode 100755
diff --git a/doc/includes/big_toc_css.rst b/doc/includes/big_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/includes/bigger_toc_css.rst b/doc/includes/bigger_toc_css.rst
old mode 100644
new mode 100755
diff --git a/doc/inspection.rst b/doc/inspection.rst
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
diff --git a/doc/modules/lda_qda.rst b/d
```


# CONTRIBUTING.md (the start)

```

Contributing to scikit-learn
============================

The latest contributing guide is available in the repository at
`doc/developers/contributing.rst`, or online at:

https://scikit-learn.org/dev/developers/contributing.html

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

Quick links
-----------

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
	# TODO: Remove in when all modules are removed.
	$(PYTHON) sklearn/_build_utils/deprecated_modules.py

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
test-code-parallel: in
	$(PYTEST) -n auto --showlocals -v sklearn --durations=20

test-coverage:
	rm -rf coverage .coverage
	$(PYTEST) sklearn --showlocals -v --cov=sklearn --cov-report=html:coverage
test-coverage-parallel:
	rm -rf coverage .coverage .coverage.*
	$(PYTEST) sklearn -n auto --showlocals -v --cov=sklearn --cov-report=html:coverage

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
`pytest sklearn/svm/tests -q`

## Scope
`sklearn/svm/`

## Done when
Fitting the reported sparse `SVR` input completes without raising `ZeroDivisionError`.
With an empty `support_vectors_`, `dual_coef_` is set to an empty sparse matrix equivalent to `sp.csr_matrix([])`.
Fitting the same data in dense form still completes without error.

## Approach
Reproduce the failure, locate the `_sparse_fit` path in the SVM base implementation, and confirm which divisor becomes zero when libsvm returns zero support vectors; then compare the dense and sparse post-fit attributes.

Candidate 1: guard the empty-support case before constructing the CSR dual coefficients, assigning `sp.csr_matrix([])` and preserving the other expected empty attributes. This directly matches the reported expectation but must keep the fitted model’s predict path and attribute shapes consistent.

Candidate 2: make the index-pointer computation safe for an empty support set, e.g. avoid dividing by a zero count and build an empty `indptr`. This is a smaller change but risks producing shapes that do not match the dense empty case or the expected `csr_matrix([])`.

Candidate 3: special-case only the regression path that produced zero support vectors. This is narrow and low-risk for the reproducer but may leave the same failure for other empty-support SVM variants, so it is the fallback if a general guard has side effects.
```

### `prompt.md`

````
ZeroDivisionError in _sparse_fit for SVM with empty support_vectors_
#### Description
When using sparse data, in the case where the support_vectors_ attribute is be empty, _fit_sparse gives a ZeroDivisionError

#### Steps/Code to Reproduce
```
import numpy as np
import scipy
import sklearn
from sklearn.svm import SVR
x_train = np.array([[0, 1, 0, 0],
[0, 0, 0, 1],
[0, 0, 1, 0],
[0, 0, 0, 1]])
y_train = np.array([0.04, 0.04, 0.10, 0.16])
model = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,
  	    gamma=1.0, kernel='linear', max_iter=15000,
  	    shrinking=True, tol=0.001, verbose=False)
# dense x_train has no error
model.fit(x_train, y_train)

# convert to sparse
xtrain= scipy.sparse.csr_matrix(x_train)
model.fit(xtrain, y_train)

```
#### Expected Results
No error is thrown and  `self.dual_coef_ = sp.csr_matrix([])`

#### Actual Results
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 209, in fit
    fit(X, y, sample_weight, solver_type, kernel, random_seed=seed)
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 302, in _sparse_fit
    dual_coef_indices.size / n_class)
ZeroDivisionError: float division by zero
```

#### Versions
```
>>> sklearn.show_versions() 

System:
executable: /usr/bin/python3
    python: 3.5.2 (default, Nov 12 2018, 13:43:14)  [GCC 5.4.0 20160609]
   machine: Linux-4.15.0-58-generic-x86_64-with-Ubuntu-16.04-xenial

Python deps:
     numpy: 1.17.0
    Cython: None
       pip: 19.2.1
    pandas: 0.22.0
   sklearn: 0.21.3
     scipy: 1.3.0
setuptools: 40.4.3
```
````

### `review.md`

```
verdict: PASS

The fix guards the sparse dual-coef assembly on `n_SV == 0`, which is exactly the condition that made `dual_coef_indices.size / n_class` divide by zero. With an empty `support_vectors_`, `dual_coef_` is set to `sp.csr_matrix([])`, whose shape is `(1, 0)` — matching the added assertion and the expected result.

- `sklearn/svm/base.py`: +8/-5, only the empty-support-vector branch is added; the non-empty path is unchanged.
- `sklearn/svm/tests/test_svm.py`: +16/-0, adds a non-regression test fitting the reported sparse input and asserting shapes.
- Check status is 0 (136 passed), and the dense path remains exercised by existing tests, so the "dense still completes" condition holds.
- Both changed files are inside `sklearn/svm/`; nothing outside scope was touched and no existing content was removed.

The fix addresses the reported `ZeroDivisionError`, keeps dense behavior intact, and satisfies the Done when criteria.
```

### `scope.txt`

```
scope: sklearn/svm
changed: sklearn/svm/base.py +8 -5
changed: sklearn/svm/tests/test_svm.py +16 -0
```

### `task.md`

````
# Task

## Prompt

ZeroDivisionError in _sparse_fit for SVM with empty support_vectors_
#### Description
When using sparse data, in the case where the support_vectors_ attribute is be empty, _fit_sparse gives a ZeroDivisionError

#### Steps/Code to Reproduce
```
import numpy as np
import scipy
import sklearn
from sklearn.svm import SVR
x_train = np.array([[0, 1, 0, 0],
[0, 0, 0, 1],
[0, 0, 1, 0],
[0, 0, 0, 1]])
y_train = np.array([0.04, 0.04, 0.10, 0.16])
model = SVR(C=316.227766017, cache_size=200, coef0=0.0, degree=3, epsilon=0.1,
  	    gamma=1.0, kernel='linear', max_iter=15000,
  	    shrinking=True, tol=0.001, verbose=False)
# dense x_train has no error
model.fit(x_train, y_train)

# convert to sparse
xtrain= scipy.sparse.csr_matrix(x_train)
model.fit(xtrain, y_train)

```
#### Expected Results
No error is thrown and  `self.dual_coef_ = sp.csr_matrix([])`

#### Actual Results
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 209, in fit
    fit(X, y, sample_weight, solver_type, kernel, random_seed=seed)
  File "/usr/local/lib/python3.5/dist-packages/sklearn/svm/base.py", line 302, in _sparse_fit
    dual_coef_indices.size / n_class)
ZeroDivisionError: float division by zero
```

#### Versions
```
>>> sklearn.show_versions() 

System:
executable: /usr/bin/python3
    python: 3.5.2 (default, Nov 12 2018, 13:43:14)  [GCC 5.4.0 20160609]
   machine: Linux-4.15.0-58-generic-x86_64-with-Ubuntu-16.04-xenial

Python deps:
     numpy: 1.17.0
    Cython: None
       pip: 19.2.1
    pandas: 0.22.0
   sklearn: 0.21.3
     scipy: 1.3.0
setuptools: 40.4.3
```

## Deliverable

changes to this tree

## Check

`pytest sklearn/svm/tests -q`

## Scope

`sklearn/svm/`

## Done when

Fitting the reported sparse `SVR` input completes without raising `ZeroDivisionError`.
With an empty `support_vectors_`, `dual_coef_` is set to an empty sparse matrix equivalent to `sp.csr_matrix([])`.
Fitting the same data in dense form still completes without error.
````

### `test-output.log`

```
check: pytest sklearn/svm/tests -q
........................................................................ [ 52%]
................................................................         [100%]
136 passed, 14 warnings in 7.76s
scope: sklearn/svm
changed: sklearn/svm/base.py +8 -5
changed: sklearn/svm/tests/test_svm.py +16 -0
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
