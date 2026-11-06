# scikit-learn__scikit-learn-13779 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 54s 31 lines cost=0.001185 in=83566 cached=63488 out=1224 calls=12`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

Voting estimator will fail at fit if weights are passed and an estimator is None
Because we don't check for an estimator to be `None` in `sample_weight` support, `fit` is failing`.

```python
    X, y = load_iris(return_X_y=True)
    voter = VotingClassifier(
        estimators=[('lr', LogisticRegression()),
                    ('rf', RandomForestClassifier())]
    )
    voter.fit(X, y, sample_weight=np.ones(y.shape))
    voter.set_params(lr=None)
    voter.fit(X, y, sample_weight=np.ones(y.shape))
```

```
AttributeError: 'NoneType' object has no attribute 'fit'
```

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --porcelain | head -50"
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
?? .memdoor/
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"sample_weight\" sklearn/ensemble/_voting.py | head -50"
}
```

**tool result**

```
grep: sklearn/ensemble/_voting.py: No such file or directory
```

**assistant → tool `bash`**

```json
{
  "command": "ls sklearn/ensemble/ | head -40 && grep -rln \"class VotingClassifier\" sklearn/"
}
```

**tool result**

```
__init__.py
__pycache__
_gb_losses.py
_gradient_boosting.c
_gradient_boosting.cpython-36m-x86_64-linux-gnu.so
_gradient_boosting.pyx
_hist_gradient_boosting
bagging.py
base.py
forest.py
gradient_boosting.py
iforest.py
partial_dependence.py
setup.py
tests
voting.py
weight_boosting.py
sklearn/ensemble/voting.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"sample_weight\\|def fit\\|def _fit\\|estimators_\\|named_estimators\" sklearn/ensemble/voting.py | head -80"
}
```

**tool result**

```
30:def _parallel_fit_estimator(estimator, X, y, sample_weight=None):
32:    if sample_weight is not None:
33:        estimator.fit(X, y, sample_weight=sample_weight)
48:    def named_estimators(self):
61:        return np.asarray([clf.predict(X) for clf in self.estimators_]).T
64:    def fit(self, X, y, sample_weight=None):
79:        if sample_weight is not None:
81:                if not has_fit_parameter(step, 'sample_weight'):
93:        self.estimators_ = Parallel(n_jobs=self.n_jobs)(
95:                                                 sample_weight=sample_weight)
98:        self.named_estimators_ = Bunch()
99:        for k, e in zip(self.estimators, self.estimators_):
100:            self.named_estimators_[k[0]] = e
150:        ``self.estimators_``. An estimator can be set to `None` using
179:    estimators_ : list of classifiers
183:    named_estimators_ : Bunch object, a dictionary with attribute access
208:    >>> np.array_equal(eclf1.named_estimators_.lr.predict(X),
209:    ...                eclf1.named_estimators_['lr'].predict(X))
240:    def fit(self, X, y, sample_weight=None):
252:        sample_weight : array-like, shape (n_samples,) or None
273:        return super().fit(X, transformed_y, sample_weight)
289:        check_is_fitted(self, 'estimators_')
306:        return np.asarray([clf.predict_proba(X) for clf in self.estimators_])
313:        check_is_fitted(self, 'estimators_')
356:        check_is_fitted(self, 'estimators_')
384:        attribute ``self.estimators_``. An estimator can be set to `None`
399:    estimators_ : list of regressors
403:    named_estimators_ : Bunch object, a dictionary with attribute access
430:    def fit(self, X, y, sample_weight=None):
442:        sample_weight : array-like, shape (n_samples,) or None
451:        return super().fit(X, y, sample_weight)
469:        check_is_fitted(self, "estimators_")
487:        check_is_fitted(self, 'estimators_')
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/ensemble/voting.py",
  "offset": 25,
  "limit": 85
}
```

**tool result**

```
from ..utils.validation import has_fit_parameter, check_is_fitted
from ..utils.metaestimators import _BaseComposition
from ..utils import Bunch


def _parallel_fit_estimator(estimator, X, y, sample_weight=None):
    """Private function used to fit an estimator within a job."""
    if sample_weight is not None:
        estimator.fit(X, y, sample_weight=sample_weight)
    else:
        estimator.fit(X, y)
    return estimator


class _BaseVoting(_BaseComposition, TransformerMixin):
    """Base class for voting.

    Warning: This class should not be used directly. Use derived classes
    instead.
    """
    _required_parameters = ['estimators']

    @property
    def named_estimators(self):
        return Bunch(**dict(self.estimators))

    @property
    def _weights_not_none(self):
        """Get the weights of not `None` estimators"""
        if self.weights is None:
            return None
        return [w for est, w in zip(self.estimators,
                                    self.weights) if est[1] is not None]

    def _predict(self, X):
        """Collect results from clf.predict calls. """
        return np.asarray([clf.predict(X) for clf in self.estimators_]).T

    @abstractmethod
    def fit(self, X, y, sample_weight=None):
        """
        common fit operations.
        """
        if self.estimators is None or len(self.estimators) == 0:
            raise AttributeError('Invalid `estimators` attribute, `estimators`'
                                 ' should be a list of (string, estimator)'
                                 ' tuples')

        if (self.weights is not None and
                len(self.weights) != len(self.estimators)):
            raise ValueError('Number of `estimators` and weights must be equal'
                             '; got %d weights, %d estimators'
                             % (len(self.weights), len(self.estimators)))

        if sample_weight is not None:
            for name, step in self.estimators:
                if not has_fit_parameter(step, 'sample_weight'):
                    raise ValueError('Underlying estimator \'%s\' does not'
                                     ' support sample weights.' % name)

        names, clfs = zip(*self.estimators)
        self._validate_names(names)

        n_isnone = np.sum([clf is None for _, clf in self.estimators])
        if n_isnone == len(self.estimators):
            raise ValueError('All estimators are None. At least one is '
                             'required!')

        self.estimators_ = Parallel(n_jobs=self.n_jobs)(
                delayed(_parallel_fit_estimator)(clone(clf), X, y,
                                                 sample_weight=sample_weight)
                for clf in clfs if clf is not None)

        self.named_estimators_ = Bunch()
        for k, e in zip(self.estimators, self.estimators_):
            self.named_estimators_[k[0]] = e
        return self

    def set_params(self, **params):
        """ Setting the parameters for the ensemble estimator

        Valid parameter keys can be listed with get_params().

        Parameters
        ----------

[379 more lines in /testbed/sklearn/ensemble/voting.py (488 in all). read_file with offset: 110 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/ensemble/voting.py\n@@\n         if sample_weight is not None:\n             for name, step in self.estimators:\n+                if step is None:\n+                    continue\n                 if not has_fit_parameter(step, 'sample_weight'):\n                     raise ValueError('Underlying estimator \\'%s\\' does not'\n                                      ' support sample weights.' % name)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/ensemble/voting.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/ensemble/voting.py now (490 lines), around the change:
78:
79:        if sample_weight is not None:
80:            for name, step in self.estimators:
81:                if step is None:
82:                    continue
83:                if not has_fit_parameter(step, 'sample_weight'):
84:                    raise ValueError('Underlying estimator \'%s\' does not'
85:                                     ' support sample weights.' % name)
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'PY'\nimport numpy as np\nfrom sklearn.datasets import load_iris\nfrom sklearn.linear_model import LogisticRegression\nfrom sklearn.ensemble import RandomForestClassifier, VotingClassifier\nX, y = load_iris(return_X_y=True)\nvoter = VotingClassifier(estimators=[('lr', LogisticRegression()), ('rf', RandomForestClassifier())])\nvoter.fit(X, y, sample_weight=np.ones(y.shape))\nvoter.set_params(lr=None)\nvoter.fit(X, y, sample_weight=np.ones(y.shape))\nprint('ok')\nPY"
}
```

**tool result**

```
/testbed/sklearn/linear_model/logistic.py:432: FutureWarning: Default solver will be changed to 'lbfgs' in 0.22. Specify a solver to silence this warning.
  FutureWarning)
/testbed/sklearn/linear_model/logistic.py:469: FutureWarning: Default multi_class will be changed to 'auto' in 0.22. Specify the multi_class option to silence this warning.
  "this warning.", FutureWarning)
/testbed/sklearn/ensemble/forest.py:245: FutureWarning: The default value of n_estimators will change from 10 in version 0.20 to 100 in 0.22.
  "10 in version 0.20 to 100 in 0.22.", FutureWarning)
/testbed/sklearn/ensemble/forest.py:245: FutureWarning: The default value of n_estimators will change from 10 in version 0.20 to 100 in 0.22.
  "10 in version 0.20 to 100 in 0.22.", FutureWarning)
ok
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"sample_weight\\|None\" sklearn/ensemble/tests/test_voting.py | head -40"
}
```

**tool result**

```
163:                                         ('quantile', reg3)], weights=None)
322:def test_sample_weight():
323:    """Tests sample_weight parameter of VotingClassifier"""
329:        voting='soft').fit(X, y, sample_weight=np.ones((len(y),)))
336:    sample_weight = np.random.RandomState(123).uniform(size=(len(y),))
338:    eclf3.fit(X, y, sample_weight)
339:    clf1.fit(X, y, sample_weight)
348:    assert_raise_message(ValueError, msg, eclf3.fit, X, y, sample_weight)
351:def test_sample_weight_kwargs():
352:    """Check that VotingClassifier passes sample_weight as kwargs"""
354:        """Mock Classifier to check that sample_weight is received as kwargs"""
355:        def fit(self, X, y, *args, **sample_weight):
356:            assert 'sample_weight' in sample_weight
362:    eclf.fit(X, y, sample_weight=np.ones((len(y),)))
371:    clf2 = RandomForestClassifier(random_state=123, max_depth=None)
406:    """VotingClassifier set_params should be able to set estimators as None"""
418:    eclf2.set_params(rf=None).fit(X, y)
421:    assert dict(eclf2.estimators)["rf"] is None
425:    assert eclf2.get_params()["rf"] is None
431:    msg = 'All estimators are None. At least one is required!'
433:        ValueError, msg, eclf2.set_params(lr=None, rf=None, nb=None).fit, X, y)
445:    eclf2.set_params(rf=None).fit(X1, y1)
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/ensemble/tests/test_voting.py",
  "offset": 318,
  "limit": 55
}
```

**tool result**

```

@pytest.mark.filterwarnings('ignore: Default solver will be changed')  # 0.22
@pytest.mark.filterwarnings('ignore: Default multi_class will')  # 0.22
@pytest.mark.filterwarnings('ignore:The default value of n_estimators')
def test_sample_weight():
    """Tests sample_weight parameter of VotingClassifier"""
    clf1 = LogisticRegression(random_state=123)
    clf2 = RandomForestClassifier(random_state=123)
    clf3 = SVC(gamma='scale', probability=True, random_state=123)
    eclf1 = VotingClassifier(estimators=[
        ('lr', clf1), ('rf', clf2), ('svc', clf3)],
        voting='soft').fit(X, y, sample_weight=np.ones((len(y),)))
    eclf2 = VotingClassifier(estimators=[
        ('lr', clf1), ('rf', clf2), ('svc', clf3)],
        voting='soft').fit(X, y)
    assert_array_equal(eclf1.predict(X), eclf2.predict(X))
    assert_array_almost_equal(eclf1.predict_proba(X), eclf2.predict_proba(X))

    sample_weight = np.random.RandomState(123).uniform(size=(len(y),))
    eclf3 = VotingClassifier(estimators=[('lr', clf1)], voting='soft')
    eclf3.fit(X, y, sample_weight)
    clf1.fit(X, y, sample_weight)
    assert_array_equal(eclf3.predict(X), clf1.predict(X))
    assert_array_almost_equal(eclf3.predict_proba(X), clf1.predict_proba(X))

    clf4 = KNeighborsClassifier()
    eclf3 = VotingClassifier(estimators=[
        ('lr', clf1), ('svc', clf3), ('knn', clf4)],
        voting='soft')
    msg = ('Underlying estimator \'knn\' does not support sample weights.')
    assert_raise_message(ValueError, msg, eclf3.fit, X, y, sample_weight)


def test_sample_weight_kwargs():
    """Check that VotingClassifier passes sample_weight as kwargs"""
    class MockClassifier(BaseEstimator, ClassifierMixin):
        """Mock Classifier to check that sample_weight is received as kwargs"""
        def fit(self, X, y, *args, **sample_weight):
            assert 'sample_weight' in sample_weight

    clf = MockClassifier()
    eclf = VotingClassifier(estimators=[('mock', clf)], voting='soft')

    # Should not raise an error.
    eclf.fit(X, y, sample_weight=np.ones((len(y),)))


@pytest.mark.filterwarnings('ignore: Default solver will be changed')  # 0.22
@pytest.mark.filterwarnings('ignore: Default multi_class will')  # 0.22
@pytest.mark.filterwarnings('ignore:The default value of n_estimators')
def test_set_params():
    """set_params should be able to set estimators"""
    clf1 = LogisticRegression(random_state=123, C=1.0)
    clf2 = RandomForestClassifier(random_state=123, max_depth=None)
    clf3 = GaussianNB()

[137 more lines in /testbed/sklearn/ensemble/tests/test_voting.py (509 in all). read_file with offset: 373 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/ensemble/tests/test_voting.py\n@@\n     msg = ('Underlying estimator \\'knn\\' does not support sample weights.')\n     assert_raise_message(ValueError, msg, eclf3.fit, X, y, sample_weight)\n \n+    # Check that a `None` estimator is skipped when validating sample_weight\n+    # support (non-regression test for gh-13010).\n+    eclf4 = VotingClassifier(estimators=[('lr', clf1), ('rf', clf2)])\n+    eclf4.fit(X, y, sample_weight=np.ones((len(y),)))\n+    eclf4.set_params(rf=None)\n+    eclf4.fit(X, y, sample_weight=np.ones((len(y),)))\n+\n \n def test_sample_weight_kwargs():\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/ensemble/tests/test_voting.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/ensemble/tests/test_voting.py now (516 lines), around the change:
347:    msg = ('Underlying estimator \'knn\' does not support sample weights.')
348:    assert_raise_message(ValueError, msg, eclf3.fit, X, y, sample_weight)
349:
350:    # Check that a `None` estimator is skipped when validating sample_weight
351:    # support (non-regression test for gh-13010).
352:    eclf4 = VotingClassifier(estimators=[('lr', clf1), ('rf', clf2)])
353:    eclf4.fit(X, y, sample_weight=np.ones((len(y),)))
354:    eclf4.set_params(rf=None)
355:    eclf4.fit(X, y, sample_weight=np.ones((len(y),)))
356:
357:
358:def test_sample_weight_kwargs():
359:    """Check that VotingClassifier passes sample_weight as kwargs"""
```

**assistant → tool `bash`**

```json
{
  "command": "pytest -q sklearn/ensemble/tests/test_voting.py 2>&1 | tail -15; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo DONE"
}
```

**tool result**

```
..................                                                       [100%]
18 passed, 1 warning in 2.68s
DONE
```

**assistant**

```
Fixed in `sklearn/ensemble/voting.py`: the `sample_weight` support check now skips `None` estimators, so setting an estimator to `None` no longer raises `AttributeError` during `fit`.

Also added a regression test in `sklearn/ensemble/tests/test_voting.py`. All 18 voting tests pass, and the completion command exits 0.
```

## Run folder `single-2026-11-06T131455`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
Voting estimator will fail at fit if weights are passed and an estimator is None
Because we don't check for an estimator to be `None` in `sample_weight` support, `fit` is failing`.

```python
    X, y = load_iris(return_X_y=True)
    voter = VotingClassifier(
        estimators=[('lr', LogisticRegression()),
                    ('rf', RandomForestClassifier())]
    )
    voter.fit(X, y, sample_weight=np.ones(y.shape))
    voter.set_params(lr=None)
    voter.fit(X, y, sample_weight=np.ones(y.shape))
```

```
AttributeError: 'NoneType' object has no attribute 'fit'
```
````
