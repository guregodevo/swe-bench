# scikit-learn__scikit-learn-13496 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 257s 105 lines cost=0.008573 in=269929 cached=164352 out=13983 calls=20`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

Expose warm_start in Isolation forest
It seems to me that `sklearn.ensemble.IsolationForest` supports incremental addition of new trees with the `warm_start` parameter of its parent class, `sklearn.ensemble.BaseBagging`.

Even though this parameter is not exposed in `__init__()` , it gets inherited from `BaseBagging` and one can use it by changing it to `True` after initialization. To make it work, you have to also increment `n_estimators` on every iteration. 

It took me a while to notice that it actually works, and I had to inspect the source code of both `IsolationForest` and `BaseBagging`. Also, it looks to me that the behavior is in-line with `sklearn.ensemble.BaseForest` that is behind e.g. `sklearn.ensemble.RandomForestClassifier`.

To make it more easier to use, I'd suggest to:
* expose `warm_start` in `IsolationForest.__init__()`, default `False`;
* document it in the same way as it is documented for `RandomForestClassifier`, i.e. say:
```py
    warm_start : bool, optional (default=False)
        When set to ``True``, reuse the solution of the previous call to fit
        and add more estimators to the ensemble, otherwise, just fit a whole
        new forest. See :term:`the Glossary <warm_start>`.
```
* add a test to make sure it works properly;
* possibly also mention in the "IsolationForest example" documentation entry;


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --short | head -20"
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
  "command": "grep -n \"class IsolationForest\\|def __init__\\|warm_start\\|class BaseBagging\\|class BaseForest\" sklearn/ensemble/iforest.py | head -40; grep -n \"class BaseBagging\\|warm_start\\|def __init__\" sklearn/ensemble/bagging.py | head -50"
}
```

**tool result**

```
29:class IsolationForest(BaseBagging, OutlierMixin):
167:    def __init__(self,
184:class BaseBagging(BaseEnsemble, metaclass=ABCMeta):
192:    def __init__(self,
200:                 warm_start=False,
213:        self.warm_start = warm_start
331:        if self.warm_start and self.oob_score:
333:                             " if warm_start=False")
335:        if hasattr(self, "oob_score_") and self.warm_start:
338:        if not self.warm_start or not hasattr(self, 'estimators_'):
347:                             'len(estimators_)=%d when warm_start==True'
362:        if self.warm_start and len(self.estimators_) > 0:
485:    warm_start : bool, optional (default=False)
488:        a whole new ensemble. See :term:`the Glossary <warm_start>`.
491:           *warm_start* constructor parameter.
554:    def __init__(self,
562:                 warm_start=False,
575:            warm_start=warm_start,
867:    warm_start : bool, optional (default=False)
870:        a whole new ensemble. See :term:`the Glossary <warm_start>`.
925:    def __init__(self,
933:                 warm_start=False,
945:            warm_start=warm_start,
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/ensemble/iforest.py",
  "offset": 1,
  "limit": 260
}
```

**tool result**

```
# Authors: Nicolas Goix <nicolas.goix@telecom-paristech.fr>
#          Alexandre Gramfort <alexandre.gramfort@telecom-paristech.fr>
# License: BSD 3 clause


import numbers
import numpy as np
from scipy.sparse import issparse
from warnings import warn

from ..tree import ExtraTreeRegressor
from ..utils import (
    check_random_state,
    check_array,
    gen_batches,
    get_chunk_n_rows,
)
from ..utils.fixes import _joblib_parallel_args
from ..utils.validation import check_is_fitted, _num_samples
from ..base import OutlierMixin

from .bagging import BaseBagging

__all__ = ["IsolationForest"]

INTEGER_TYPES = (numbers.Integral, np.integer)


class IsolationForest(BaseBagging, OutlierMixin):
    """Isolation Forest Algorithm

    Return the anomaly score of each sample using the IsolationForest algorithm

    The IsolationForest 'isolates' observations by randomly selecting a feature
    and then randomly selecting a split value between the maximum and minimum
    values of the selected feature.

    Since recursive partitioning can be represented by a tree structure, the
    number of splittings required to isolate a sample is equivalent to the path
    length from the root node to the terminating node.

    This path length, averaged over a forest of such random trees, is a
    measure of normality and our decision function.

    Random partitioning produces noticeably shorter paths for anomalies.
    Hence, when a forest of random trees collectively produce shorter path
    lengths for particular samples, they are highly likely to be anomalies.

    Read more in the :ref:`User Guide <isolation_forest>`.

    .. versionadded:: 0.18

    Parameters
    ----------
    n_estimators : int, optional (default=100)
        The number of base estimators in the ensemble.

    max_samples : int or float, optional (default="auto")
        The number of samples to draw from X to train each base estimator.
            - If int, then draw `max_samples` samples.
            - If float, then draw `max_samples * X.shape[0]` samples.
            - If "auto", then `max_samples=min(256, n_samples)`.

        If max_samples is larger than the number of samples provided,
        all samples will be used for all trees (no sampling).

    contamination : float in (0., 0.5), optional (default=0.1)
        The amount of contamination of the data set, i.e. the proportion
        of outliers in the data set. Used when fitting to define the threshold
        on the decision function. If 'auto', the decision function threshold is
        determined as in the original paper.

        .. versionchanged:: 0.20
           The default value of ``contamination`` will change from 0.1 in 0.20
           to ``'auto'`` in 0.22.

    max_features : int or float, optional (default=1.0)
        The number of features to draw from X to train each base estimator.

            - If int, then draw `max_features` features.
            - If float, then draw `max_features * X.shape[1]` features.

    bootstrap : boolean, optional (default=False)
        If True, individual trees are fit on random subsets of the training
        data sampled with replacement. If False, sampling without replacement
        is performed.

    n_jobs : int or None, optional (default=None)
        The number of jobs to run in parallel for both `fit` and `predict`.
        ``None`` means 1 unless in a :obj:`joblib.parallel_backend` context.
        ``-1`` means using all processors. See :term:`Glossary <n_jobs>`
        for more details.

    behaviour : str, default='old'
        Behaviour of the ``decision_function`` which can be either 'old' or
        'new'. Passing ``behaviour='new'`` makes the ``decision_function``
        change to match other anomaly detection algorithm API which will be
        the default behaviour in the future. As explained in details in the
        ``offset_`` attribute documentation, the ``decision_function`` becomes
        dependent on the contamination parameter, in such a way that 0 becomes
        its natural threshold to detect outliers.

        .. versionadded:: 0.20
           ``behaviour`` is added in 0.20 for back-compatibility purpose.

        .. deprecated:: 0.20
           ``behaviour='old'`` is deprecated in 0.20 and will not be possible
           in 0.22.

        .. deprecated:: 0.22
           ``behaviour`` parameter will be deprecated in 0.22 and removed in
           0.24.

    random_state : int, RandomState instance or None, optional (default=None)
        If int, random_state is the seed used by the random number generator;
        If RandomState instance, random_state is the random number generator;
        If None, the random number generator is the RandomState instance used
        by `np.random`.

    verbose : int, optional (default=0)
        Controls the verbosity of the tree building process.


    Attributes
    ----------
    estimators_ : list of DecisionTreeClassifier
        The collection of fitted sub-estimators.

    estimators_samples_ : list of arrays
        The subset of drawn samples (i.e., the in-bag samples) for each base
        estimator.

    max_samples_ : integer
        The actual number of samples

    offset_ : float
        Offset used to define the decision function from the raw scores.
        We have the relation: ``decision_function = score_samples - offset_``.
        Assuming behaviour == 'new', ``offset_`` is defined as follows.
        When the contamination parameter is set to "auto", the offset is equal
        to -0.5 as the scores of inliers are close to 0 and the scores of
        outliers are close to -1. When a contamination parameter different
        than "auto" is provided, the offset is defined in such a way we obtain
        the expected number of outliers (samples with decision function < 0)
        in training.
        Assuming the behaviour parameter is set to 'old', we always have
        ``offset_ = -0.5``, making the decision function independent from the
        contamination parameter.

    Notes
    -----
    The implementation is based on an ensemble of ExtraTreeRegressor. The
    maximum depth of each tree is set to ``ceil(log_2(n))`` where
    :math:`n` is the number of samples used to build the tree
    (see (Liu et al., 2008) for more details).

    References
    ----------
    .. [1] Liu, Fei Tony, Ting, Kai Ming and Zhou, Zhi-Hua. "Isolation forest."
           Data Mining, 2008. ICDM'08. Eighth IEEE International Conference on.
    .. [2] Liu, Fei Tony, Ting, Kai Ming and Zhou, Zhi-Hua. "Isolation-based
           anomaly detection." ACM Transactions on Knowledge Discovery from
           Data (TKDD) 6.1 (2012): 3.

    """

    def __init__(self,
                 n_estimators=100,
                 max_samples="auto",
                 contamination="legacy",
                 max_features=1.,
                 bootstrap=False,
                 n_jobs=None,
                 behaviour='old',
                 random_state=None,
                 verbose=0):
        super().__init__(
            base_estimator=ExtraTreeRegressor(
                max_features=1,
                splitter='random',
                random_state=random_state),
            # here above max_features has no links with self.max_features
            bootstrap=bootstrap,
            bootstrap_features=False,
            n_estimators=n_estimators,
            max_samples=max_samples,
            max_features=max_features,
            n_jobs=n_jobs,
            random_state=random_state,
            verbose=verbose)

        self.behaviour = behaviour
        self.contamination = contamination

    def _set_oob_score(self, X, y):
        raise NotImplementedError("OOB score not supported by iforest")

    def _parallel_args(self):
        # ExtraTreeRegressor releases the GIL, so it's more efficient to use
        # a thread-based backend rather than a process-based backend so as
        # to avoid suffering from communication overhead and extra memory
        # copies.
        return _joblib_parallel_args(prefer='threads')

    def fit(self, X, y=None, sample_weight=None):
        """Fit estimator.

        Parameters
        ----------
        X : array-like or sparse matrix, shape (n_samples, n_features)
            The input samples. Use ``dtype=np.float32`` for maximum
            efficiency. Sparse matrices are also supported, use sparse
            ``csc_matrix`` for maximum efficiency.

        sample_weight : array-like, shape = [n_samples] or None
            Sample weights. If None, then samples are equally weighted.

        y : Ignored
            not used, present for API consistency by convention.

        Returns
        -------
        self : object
        """
        if self.contamination == "legacy":
            warn('default contamination parameter 0.1 will change '
                 'in version 0.22 to "auto". This will change the '
                 'predict method behavior.',
                 FutureWarning)
            self._contamination = 0.1
        else:
            self._contamination = self.contamination

        if self.behaviour == 'old':
            warn('behaviour="old" is deprecated and will be removed '
                 'in version 0.22. Please use behaviour="new", which '
                 'makes the decision_function change to match '
                 'other anomaly detection algorithm API.',
                 FutureWarning)

        X = check_array(X, accept_sparse=['csc'])
        if issparse(X):
            # Pre-sort indices to avoid that each individual tree of the
            # ensemble sorts the indices.
            X.sort_indices()

        rnd = check_random_state(self.random_state)
        y = rnd.uniform(size=X.shape[0])

        # ensure that max_sample is in [1, n_samples]:
        n_samples = X.shape[0]

        if isinstance(self.max_samples, str):
            if self.max_samples == 'auto':
                max_samples = min(256, n_samples)
            else:
                raise ValueError('max_samples (%s) is not supported.'
                                 'Valid choices are: "auto", int or'
                                 'float' % self.max_samples)


[250 more lines in /testbed/sklearn/ensemble/iforest.py (510 in all). read_file with offset: 261 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/ensemble/iforest.py",
  "offset": 260,
  "limit": 100
}
```

**tool result**

```

        elif isinstance(self.max_samples, INTEGER_TYPES):
            if self.max_samples > n_samples:
                warn("max_samples (%s) is greater than the "
                     "total number of samples (%s). max_samples "
                     "will be set to n_samples for estimation."
                     % (self.max_samples, n_samples))
                max_samples = n_samples
            else:
                max_samples = self.max_samples
        else:  # float
            if not (0. < self.max_samples <= 1.):
                raise ValueError("max_samples must be in (0, 1], got %r"
                                 % self.max_samples)
            max_samples = int(self.max_samples * X.shape[0])

        self.max_samples_ = max_samples
        max_depth = int(np.ceil(np.log2(max(max_samples, 2))))
        super()._fit(X, y, max_samples,
                     max_depth=max_depth,
                     sample_weight=sample_weight)

        if self.behaviour == 'old':
            # in this case, decision_function = 0.5 + self.score_samples(X):
            if self._contamination == "auto":
                raise ValueError("contamination parameter cannot be set to "
                                 "'auto' when behaviour == 'old'.")

            self.offset_ = -0.5
            self._threshold_ = np.percentile(self.decision_function(X),
                                             100. * self._contamination)

            return self

        # else, self.behaviour == 'new':
        if self._contamination == "auto":
            # 0.5 plays a special role as described in the original paper.
            # we take the opposite as we consider the opposite of their score.
            self.offset_ = -0.5
            return self

        # else, define offset_ wrt contamination parameter, so that the
        # threshold_ attribute is implicitly 0 and is not needed anymore:
        self.offset_ = np.percentile(self.score_samples(X),
                                     100. * self._contamination)

        return self

    def predict(self, X):
        """Predict if a particular sample is an outlier or not.

        Parameters
        ----------
        X : array-like or sparse matrix, shape (n_samples, n_features)
            The input samples. Internally, it will be converted to
            ``dtype=np.float32`` and if a sparse matrix is provided
            to a sparse ``csr_matrix``.

        Returns
        -------
        is_inlier : array, shape (n_samples,)
            For each observation, tells whether or not (+1 or -1) it should
            be considered as an inlier according to the fitted model.
        """
        check_is_fitted(self, ["offset_"])
        X = check_array(X, accept_sparse='csr')
        is_inlier = np.ones(X.shape[0], dtype=int)
        threshold = self.threshold_ if self.behaviour == 'old' else 0
        is_inlier[self.decision_function(X) < threshold] = -1
        return is_inlier

    def decision_function(self, X):
        """Average anomaly score of X of the base classifiers.

        The anomaly score of an input sample is computed as
        the mean anomaly score of the trees in the forest.

        The measure of normality of an observation given a tree is the depth
        of the leaf containing this observation, which is equivalent to
        the number of splittings required to isolate this point. In case of
        several observations n_left in the leaf, the average path length of
        a n_left samples isolation tree is added.

        Parameters
        ----------
        X : array-like or sparse matrix, shape (n_samples, n_features)
            The input samples. Internally, it will be converted to
            ``dtype=np.float32`` and if a sparse matrix is provided
            to a sparse ``csr_matrix``.

        Returns
        -------
        scores : array, shape (n_samples,)
            The anomaly score of the input samples.
            The lower, the more abnormal. Negative scores represent outliers,
            positive scores represent inliers.

        """
        # We subtract self.offset_ to make 0 be the threshold value for being
        # an outlier:

[151 more lines in /testbed/sklearn/ensemble/iforest.py (510 in all). read_file with offset: 360 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "sklearn/ensemble/bagging.py",
  "offset": 300,
  "limit": 170
}
```

**tool result**

```
            max_samples = self.max_samples
        elif not isinstance(max_samples, (numbers.Integral, np.integer)):
            max_samples = int(max_samples * X.shape[0])

        if not (0 < max_samples <= X.shape[0]):
            raise ValueError("max_samples must be in (0, n_samples]")

        # Store validated integer row sampling value
        self._max_samples = max_samples

        # Validate max_features
        if isinstance(self.max_features, (numbers.Integral, np.integer)):
            max_features = self.max_features
        elif isinstance(self.max_features, np.float):
            max_features = self.max_features * self.n_features_
        else:
            raise ValueError("max_features must be int or float")

        if not (0 < max_features <= self.n_features_):
            raise ValueError("max_features must be in (0, n_features]")

        max_features = max(1, int(max_features))

        # Store validated integer feature sampling value
        self._max_features = max_features

        # Other checks
        if not self.bootstrap and self.oob_score:
            raise ValueError("Out of bag estimation only available"
                             " if bootstrap=True")

        if self.warm_start and self.oob_score:
            raise ValueError("Out of bag estimate only available"
                             " if warm_start=False")

        if hasattr(self, "oob_score_") and self.warm_start:
            del self.oob_score_

        if not self.warm_start or not hasattr(self, 'estimators_'):
            # Free allocated memory, if any
            self.estimators_ = []
            self.estimators_features_ = []

        n_more_estimators = self.n_estimators - len(self.estimators_)

        if n_more_estimators < 0:
            raise ValueError('n_estimators=%d must be larger or equal to '
                             'len(estimators_)=%d when warm_start==True'
                             % (self.n_estimators, len(self.estimators_)))

        elif n_more_estimators == 0:
            warn("Warm-start fitting without increasing n_estimators does not "
                 "fit new trees.")
            return self

        # Parallel loop
        n_jobs, n_estimators, starts = _partition_estimators(n_more_estimators,
                                                             self.n_jobs)
        total_n_estimators = sum(n_estimators)

        # Advance random state to state after training
        # the first n_estimators
        if self.warm_start and len(self.estimators_) > 0:
            random_state.randint(MAX_INT, size=len(self.estimators_))

        seeds = random_state.randint(MAX_INT, size=n_more_estimators)
        self._seeds = seeds

        all_results = Parallel(n_jobs=n_jobs, verbose=self.verbose,
                               **self._parallel_args())(
            delayed(_parallel_build_estimators)(
                n_estimators[i],
                self,
                X,
                y,
                sample_weight,
                seeds[starts[i]:starts[i + 1]],
                total_n_estimators,
                verbose=self.verbose)
            for i in range(n_jobs))

        # Reduce
        self.estimators_ += list(itertools.chain.from_iterable(
            t[0] for t in all_results))
        self.estimators_features_ += list(itertools.chain.from_iterable(
            t[1] for t in all_results))

        if self.oob_score:
            self._set_oob_score(X, y)

        return self

    @abstractmethod
    def _set_oob_score(self, X, y):
        """Calculate out of bag predictions and score."""

    def _validate_y(self, y):
        if len(y.shape) == 1 or y.shape[1] == 1:
            return column_or_1d(y, warn=True)
        else:
            return y

    def _get_estimators_indices(self):
        # Get drawn indices along both sample and feature axes
        for seed in self._seeds:
            # Operations accessing random_state must be performed identically
            # to those in `_parallel_build_estimators()`
            random_state = np.random.RandomState(seed)
            feature_indices, sample_indices = _generate_bagging_indices(
                random_state, self.bootstrap_features, self.bootstrap,
                self.n_features_, self._n_samples, self._max_features,
                self._max_samples)

            yield feature_indices, sample_indices

    @property
    def estimators_samples_(self):
        """The subset of drawn samples for each base estimator.

        Returns a dynamically generated list of indices identifying
        the samples used for fitting each member of the ensemble, i.e.,
        the in-bag samples.

        Note: the list is re-created at each call to the property in order
        to reduce the object memory footprint by not storing the sampling
        data. Thus fetching the property may be slower than expected.
        """
        return [sample_indices
                for _, sample_indices in self._get_estimators_indices()]


class BaggingClassifier(BaseBagging, ClassifierMixin):
    """A Bagging classifier.

    A Bagging classifier is an ensemble meta-estimator that fits base
    classifiers each on random subsets of the original dataset and then
    aggregate their individual predictions (either by voting or by averaging)
    to form a final prediction. Such a meta-estimator can typically be used as
    a way to reduce the variance of a black-box estimator (e.g., a decision
    tree), by introducing randomization into its construction procedure and
    then making an ensemble out of it.

    This algorithm encompasses several works from the literature. When random
    subsets of the dataset are drawn as random subsets of the samples, then
    this algorithm is known as Pasting [1]_. If samples are drawn with
    replacement, then the method is known as Bagging [2]_. When random subsets
    of the dataset are drawn as random subsets of the features, then the method
    is known as Random Subspaces [3]_. Finally, when base estimators are built
    on subsets of both samples and features, then the method is known as
    Random Patches [4]_.

    Read more in the :ref:`User Guide <bagging>`.

    Parameters
    ----------
    base_estimator : object or None, optional (default=None)
        The base estimator to fit on random subsets of the dataset.
        If None, then the base estimator is a decision tree.

    n_estimators : int, optional (default=10)
        The number of base estimators in the ensemble.

    max_samples : int or float, optional (default=1.0)
        The number of samples to draw from X to train each base estimator.

        - If int, then draw `max_samples` samples.
        - If float, then draw `max_samples * X.shape[0]` samples.

    max_features : int or float, optional (default=1.0)
        The number of features to draw from X to train each base estimator.

[550 more lines in /testbed/sklearn/ensemble/bagging.py (1019 in all). read_file with offset: 470 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_\\|warm_start\\|n_estimators\" sklearn/ensemble/tests/test_iforest.py | head -60; grep -rn \"IsolationForest\" examples/ensemble/plot_isolation_forest.py | head; grep -n \"warm_start\" examples/ensemble/plot_isolation_forest.py"
}
```

**tool result**

```
52:def test_iforest():
57:    grid = ParameterGrid({"n_estimators": [3],
70:def test_iforest_sparse():
86:                n_estimators=10, random_state=1, **params).fit(X_train_sparse)
91:                n_estimators=10, random_state=1, **params).fit(X_train)
100:def test_iforest_error():
145:def test_recalculate_max_depth():
155:def test_max_samples_attribute():
173:def test_iforest_parallel_regression():
199:def test_iforest_performance():
225:def test_iforest_works(contamination):
243:def test_max_samples_consistency():
253:def test_iforest_subsampled_features():
264:def test_iforest_average_path_length():
286:def test_score_samples():
300:def test_deprecation():
323:def test_behaviour_param():
341:def test_iforest_chunks_works1(
357:def test_iforest_chunks_works2(
3:IsolationForest example
6:An example using :class:`sklearn.ensemble.IsolationForest` for anomaly
9:The IsolationForest 'isolates' observations by randomly selecting a feature
29:from sklearn.ensemble import IsolationForest
43:clf = IsolationForest(behaviour='new', max_samples=100,
55:plt.title("IsolationForest")

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,60p' sklearn/ensemble/tests/test_iforest.py; sed -n '140,200p' sklearn/ensemble/tests/test_iforest.py; sed -n '1,75p' examples/ensemble/plot_isolation_forest.py"
}
```

**tool result**

```
"""
Testing for Isolation Forest algorithm (sklearn.ensemble.iforest).
"""

# Authors: Nicolas Goix <nicolas.goix@telecom-paristech.fr>
#          Alexandre Gramfort <alexandre.gramfort@telecom-paristech.fr>
# License: BSD 3 clause

import pytest

import numpy as np

from sklearn.utils.testing import assert_array_equal
from sklearn.utils.testing import assert_array_almost_equal
from sklearn.utils.testing import assert_raises
from sklearn.utils.testing import assert_raises_regex
from sklearn.utils.testing import assert_warns_message
from sklearn.utils.testing import assert_equal
from sklearn.utils.testing import assert_greater
from sklearn.utils.testing import ignore_warnings
from sklearn.utils.testing import assert_allclose

from sklearn.model_selection import ParameterGrid
from sklearn.ensemble import IsolationForest
from sklearn.ensemble.iforest import _average_path_length
from sklearn.model_selection import train_test_split
from sklearn.datasets import load_boston, load_iris
from sklearn.utils import check_random_state
from sklearn.metrics import roc_auc_score

from scipy.sparse import csc_matrix, csr_matrix
from unittest.mock import Mock, patch

rng = check_random_state(0)

# load the iris dataset
# and randomly permute it
iris = load_iris()
perm = rng.permutation(iris.target.size)
iris.data = iris.data[perm]
iris.target = iris.target[perm]

# also load the boston dataset
# and randomly permute it
boston = load_boston()
perm = rng.permutation(boston.target.size)
boston.data = boston.data[perm]
boston.target = boston.target[perm]


@pytest.mark.filterwarnings('ignore:threshold_ attribute')
def test_iforest():
    """Check Isolation Forest for various parameter settings."""
    X_train = np.array([[0, 1], [1, 2]])
    X_test = np.array([[2, 1], [1, 1]])

    grid = ParameterGrid({"n_estimators": [3],
                          "max_samples": [0.5, 1.0, 3],
                          "bootstrap": [True, False]})

                        IsolationForest(behaviour='new'), 'threshold_')


@pytest.mark.filterwarnings('ignore:default contamination')
@pytest.mark.filterwarnings('ignore:behaviour="old"')
def test_recalculate_max_depth():
    """Check max_depth recalculation when max_samples is reset to n_samples"""
    X = iris.data
    clf = IsolationForest().fit(X)
    for est in clf.estimators_:
        assert_equal(est.max_depth, int(np.ceil(np.log2(X.shape[0]))))


@pytest.mark.filterwarnings('ignore:default contamination')
@pytest.mark.filterwarnings('ignore:behaviour="old"')
def test_max_samples_attribute():
    X = iris.data
    clf = IsolationForest().fit(X)
    assert_equal(clf.max_samples_, X.shape[0])

    clf = IsolationForest(max_samples=500)
    assert_warns_message(UserWarning,
                         "max_samples will be set to n_samples for estimation",
                         clf.fit, X)
    assert_equal(clf.max_samples_, X.shape[0])

    clf = IsolationForest(max_samples=0.4).fit(X)
    assert_equal(clf.max_samples_, 0.4*X.shape[0])


@pytest.mark.filterwarnings('ignore:default contamination')
@pytest.mark.filterwarnings('ignore:threshold_ attribute')
@pytest.mark.filterwarnings('ignore:behaviour="old"')
def test_iforest_parallel_regression():
    """Check parallel regression."""
    rng = check_random_state(0)

    X_train, X_test, y_train, y_test = train_test_split(boston.data,
                                                        boston.target,
                                                        random_state=rng)

    ensemble = IsolationForest(n_jobs=3,
                               random_state=0).fit(X_train)

    ensemble.set_params(n_jobs=1)
    y1 = ensemble.predict(X_test)
    ensemble.set_params(n_jobs=2)
    y2 = ensemble.predict(X_test)
    assert_array_almost_equal(y1, y2)

    ensemble = IsolationForest(n_jobs=1,
                               random_state=0).fit(X_train)

    y3 = ensemble.predict(X_test)
    assert_array_almost_equal(y1, y3)


@pytest.mark.filterwarnings('ignore:default contamination')
@pytest.mark.filterwarnings('ignore:behaviour="old"')
def test_iforest_performance():
    """Test Isolation Forest performs well"""
"""
==========================================
IsolationForest example
==========================================

An example using :class:`sklearn.ensemble.IsolationForest` for anomaly
detection.

The IsolationForest 'isolates' observations by randomly selecting a feature
and then randomly selecting a split value between the maximum and minimum
values of the selected feature.

Since recursive partitioning can be represented by a tree structure, the
number of splittings required to isolate a sample is equivalent to the path
length from the root node to the terminating node.

This path length, averaged over a forest of such random trees, is a measure
of normality and our decision function.

Random partitioning produces noticeable shorter paths for anomalies.
Hence, when a forest of random trees collectively produce shorter path lengths
for particular samples, they are highly likely to be anomalies.

"""
print(__doc__)

import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import IsolationForest

rng = np.random.RandomState(42)

# Generate train data
X = 0.3 * rng.randn(100, 2)
X_train = np.r_[X + 2, X - 2]
# Generate some regular novel observations
X = 0.3 * rng.randn(20, 2)
X_test = np.r_[X + 2, X - 2]
# Generate some abnormal novel observations
X_outliers = rng.uniform(low=-4, high=4, size=(20, 2))

# fit the model
clf = IsolationForest(behaviour='new', max_samples=100,
                      random_state=rng, contamination='auto')
clf.fit(X_train)
y_pred_train = clf.predict(X_train)
y_pred_test = clf.predict(X_test)
y_pred_outliers = clf.predict(X_outliers)

# plot the line, the samples, and the nearest vectors to the plane
xx, yy = np.meshgrid(np.linspace(-5, 5, 50), np.linspace(-5, 5, 50))
Z = clf.decision_function(np.c_[xx.ravel(), yy.ravel()])
Z = Z.reshape(xx.shape)

plt.title("IsolationForest")
plt.contourf(xx, yy, Z, cmap=plt.cm.Blues_r)

b1 = plt.scatter(X_train[:, 0], X_train[:, 1], c='white',
                 s=20, edgecolor='k')
b2 = plt.scatter(X_test[:, 0], X_test[:, 1], c='green',
                 s=20, edgecolor='k')
c = plt.scatter(X_outliers[:, 0], X_outliers[:, 1], c='red',
                s=20, edgecolor='k')
plt.axis('tight')
plt.xlim((-5, 5))
plt.ylim((-5, 5))
plt.legend([b1, b2, c],
           ["training observations",
            "new regular observations", "new abnormal observations"],
           loc="upper left")
plt.show()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/ensemble/iforest.py\n@@\n     verbose : int, optional (default=0)\n         Controls the verbosity of the tree building process.\n \n+    warm_start : bool, optional (default=False)\n+        When set to ``True``, reuse the solution of the previous call to fit\n+        and add more estimators to the ensemble, otherwise, just fit a whole\n+        new forest. See :term:`the Glossary <warm_start>`.\n+\n \n     Attributes\n@@\n                  n_jobs=None,\n                  behaviour='old',\n                  random_state=None,\n-                 verbose=0):\n+                 verbose=0,\n+                 warm_start=False):\n@@\n             n_jobs=n_jobs,\n             random_state=random_state,\n-            verbose=verbose)\n+            verbose=verbose,\n+            warm_start=warm_start)\n*** Update File: sklearn/ensemble/tests/test_iforest.py\n@@\n def test_max_samples_consistency():\n     \"\"\"Check max_samples consistency\"\"\"\n     X = iris.data\n     clf = IsolationForest(max_samples=0.5).fit(X)\n     assert_equal(len(clf.estimators_), len(clf.estimators_samples_))\n     assert_equal(len(clf.estimators_), len(clf.estimators_features_))\n     assert_equal(clf.max_samples_, X.shape[0] * 0.5)\n+\n+\n+def test_iforest_warm_start():\n+    \"\"\"Test warm_start parameter\"\"\"\n+    rng = check_random_state(0)\n+    X = rng.rand(30, 4)\n+\n+    clf = IsolationForest(n_estimators=5, warm_start=True, random_state=rng)\n+    clf.fit(X)\n+    assert_equal(len(clf.estimators_), 5)\n+    first_estimators = list(clf.estimators_)\n+\n+    # Increasing n_estimators should add new trees to the existing forest\n+    clf.set_params(n_estimators=10)\n+    clf.fit(X)\n+    assert_equal(len(clf.estimators_), 10)\n+    assert_equal(len(clf.estimators_samples_), 10)\n+    for old, new in zip(first_estimators, clf.estimators_[:5]):\n+        assert old is new\n+\n+    # Without warm_start, a new forest is fitted from scratch\n+    clf = IsolationForest(n_estimators=5, random_state=rng).fit(X)\n+    first_estimators = list(clf.estimators_)\n+    clf.set_params(n_estimators=10).fit(X)\n+    assert_equal(len(clf.estimators_), 10)\n+    for old, new in zip(first_estimators, clf.estimators_):\n+        assert old is not new\n*** Update File: examples/ensemble/plot_isolation_forest.py\n@@\n Random partitioning produces noticeable shorter paths for anomalies.\n Hence, when a forest of random trees collectively produce shorter path lengths\n for particular samples, they are highly likely to be anomalies.\n \n+The forest can be grown incrementally by setting ``warm_start=True`` and\n+increasing ``n_estimators`` between calls to ``fit``. This reuses the trees\n+already fitted instead of fitting a completely new forest.\n+\n \"\"\"\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update sklearn/ensemble/tests/test_iforest.py: failed to find expected lines in /testbed/sklearn/ensemble/tests/test_iforest.py:
def test_max_samples_consistency():
    """Check max_samples consistency"""
    X = iris.data
    clf = IsolationForest(max_samples=0.5).fit(X)
    assert_equal(len(clf.estimators_), len(clf.estimators_samples_))
    assert_equal(len(clf.estimators_), len(clf.estimators_features_))
    assert_equal(clf.max_samples_, X.shape[0] * 0.5)

The file's ACTUAL current content is below. Copy your context lines from THIS exact text — do not edit from memory:
1	"""
2	Testing for Isolation Forest algorithm (sklearn.ensemble.iforest).
3	"""
4	
5	# Authors: Nicolas Goix <nicolas.goix@telecom-paristech.fr>
6	#          Alexandre Gramfort <alexandre.gramfort@telecom-paristech.fr>
7	# License: BSD 3 clause
8	
9	import pytest
10	
11	import numpy as np
12	
13	from sklearn.utils.testing import assert_array_equal
14	from sklearn.utils.testing import assert_array_almost_equal
15	from sklearn.utils.testing import assert_raises
16	from sklearn.utils.testing import assert_raises_regex
17	from sklearn.utils.testing import assert_warns_message
18	from sklearn.utils.testing import assert_equal
19	from sklearn.utils.testing import assert_greater
20	from sklearn.utils.testing import ignore_warnings
21	from sklearn.utils.testing import assert_allclose
22	
23	from sklearn.model_selection import ParameterGrid
24	from sklearn.ensemble import IsolationForest
25	from sklearn.ensemble.iforest import _average_path_length
26	from sklearn.model_selection import train_test_split
27	from sklearn.datasets import load_boston, load_iris
28	from sklearn.utils import check_random_state
29	from sklearn.metrics import roc_auc_score
30	
31	from scipy.sparse import csc_matrix, csr_matrix
32	from unittest.mock import Mock, patch
33	
34	rng = check_random_state(0)
35	
36	# load the iris dataset
37	# and randomly permute it
38	iris = load_iris()
39	perm = rng.permutation(iris.target.size)
40	iris.data = iris.data[perm]
41	iris.target = iris.target[perm]
42	
43	# also load the boston dataset
44	# and randomly permute it
45	boston = load_boston()
46	perm = rng.permutation(boston.target.size)
47	boston.data = boston.data[perm]
48	boston.target = boston.target[perm]
49	
50	
51	@pytest.mark.filterwarnings('ignore:threshold_ attribute')
52	def test_iforest():
53	    """Check Isolation Forest for various parameter settings."""
54	    X_train = np.array([[0, 1], [1, 2]])
55	    X_test = np.array([[2, 1], [1, 1]])
56	
57	    grid = ParameterGrid({"n_estimators": [3],
58	                          "max_samples": [0.5, 1.0, 3],
59	                          "bootstrap": [True, False]})
60	
61	    with ignore_warnings():
62	        for params in grid:
63	            IsolationForest(random_state=rng,
64	                            **params).fit(X_train).predict(X_test)
65	
66	
67	@pytest.mark.filterwarnings('ignore:default contamination')
68	@pytest.mark.filterwarnings('ignore:threshold_ attribute')
69	@pytest.mark.filterwarnings('ignore:behaviour="old"')
70	def test_iforest_sparse():
71	    """Check IForest for various parameter settings on sparse input."""
72	    rng = check_random_state(0)
73	    X_train, X_test, y_train, y_test = train_test_split(boston.data[:50],
74	                                                        boston.target[:50],
75	                                                        random_state=rng)
76	    grid = ParameterGrid({"max_samples": [0.5, 1.0],
77	                          "bootstrap": [True, False]})
78	
79	    for sparse_format in [csc_matrix, csr_matrix]:
80	        X_train_sparse = sparse_format(X_train)
81	        X_test_sparse = sparse_format(X_test)
82	
83	        for params in grid:
84	            # Trained on sparse format
85	            sparse_classifier = IsolationForest(
86	                n_estimators=10, random_state=1, **params).fit(X_train_sparse)
87	            sparse_results = sparse_classifier.predict(X_test_sparse)
88	
89	            # Trained on dense format
90	            dense_classifier = IsolationForest(
91	                n_estimators=10, random_state=1, **params).fit(X_train)
92	            dense_results = dense_classifier.predict(X_test)
93	
94	            assert_array_equal(sparse_results, dense_results)
95	
96	
97	@pytest.mark.filterwarnings('ignore:default contamination')
98	@pytest.mark.filterwarnings('ignore:threshold_ attribute')
99	@pytest.mark.filterwarnings('ignore:behaviour="old"')
100	def test_iforest_error():
101	    """Test that it gives proper exception on deficient input."""
102	    X = iris.data
103	
104	    # Test max_samples
105	    assert_raises(ValueError,
106	                  IsolationForest(max_samples=-1).fit, X)
107	    assert_raises(ValueError,
108	                  IsolationForest(max_samples=0.0).fit, X)
109	    assert_raises(ValueError,
110	                  IsolationForest(max_samples=2.0).fit, X)
111	    # The dataset has less than 256 samples, explicitly setting
112	    # max_samples > n_samples should result in a warning. If not set
113	    # explicitly there should be no warning
114	    assert_warns_message(UserWarning,
115	                         "max_samples will be set to n_samples for estimation",
116	                         IsolationForest(max_samples=1000).fit, X)
117	    # note that assert_no_warnings does not apply since it enables a
118	    # PendingDeprecationWarning triggered by scipy.sparse's use of
119	    # np.matrix. See issue #11251.
120	    with pytest.warns(None) as record:
121	        IsolationForest(max_samples='auto').fit(X)
122	    user_warnings = [each for each in record
123	                     if issubclass(each.category, UserWarning)]
124	    assert len(user_warnings) == 0
125	    with pytest.warns(None) as record:
126	        IsolationForest(max_samples=np.int64(2)).fit(X)
127	    user_warnings = [each for each in record
128	                     if issubclass(each.category, UserWarning)]
129	    assert len(user_warnings) == 0
130	
131	    assert_raises(ValueError, IsolationForest(max_samples='foobar').fit, X)
132	    assert_raises(ValueError, IsolationForest(max_samples=1.5).fit, X)
133	
134	    # test X_test n_features match X_train one:
135	    assert_raises(ValueError, IsolationForest().fit(X).predict, X[:, 1:])
136	
137	    # test threshold_ attribute error when behaviour is not old:
138	    msg = "threshold_ attribute does not exist when behaviour != 'old'"
139	    assert_raises_regex(AttributeError, msg, getattr,
140	                        IsolationForest(behaviour='new'), 'threshold_')
141	
142	
143	@pytest.mark.filterwarnings('ignore:default contamination')
144	@pytest.mark.filterwarnings('ignore:behaviour="old"')
145	def test_recalculate_max_depth():
146	    """Check max_depth recalculation when max_samples is reset to n_samples"""
147	    X = iris.data
148	    clf = IsolationForest().fit(X)
149	    for est in clf.estimators_:
150	        assert_equal(est.max_depth, int(np.ceil(np.log2(X.shape[0]))))
151	
152	
153	@pytest.mark.filterwarnings('ignore:default contamination')
154	@pytest.mark.filterwarnings('ignore:behaviour="old"')
155	def test_max_samples_attribute():
156	    X = iris.data
157	    clf = IsolationForest().fit(X)
158	    assert_equal(clf.max_samples_, X.shape[0])
159	
160	    clf = IsolationForest(max_samples=500)
161	    assert_warns_message(UserWarning,
162	                         "max_samples will be set to n_samples for estimation",
163	                         clf.fit, X)
164	    assert_equal(clf.max_samples_, X.shape[0])
165	
166	    clf = IsolationForest(max_samples=0.4).fit(X)
167	    assert_equal(clf.max_samples_, 0.4*X.shape[0])
168	
169	
170	@pytest.mark.filterwarnings('ignore:default contamination')
171	@pytest.mark.filterwarnings('ignore:threshold_ attribute')
172	@pytest.mark.filterwarnings('ignore:behaviour="old"')
173	def test_iforest_parallel_regression():
174	    """Check parallel regression."""
175	    rng = check_random_state(0)
176	
177	    X_train, X_test, y_train, y_test = train_test_split(boston.data,
178	                                                        boston.target,
179	                                                        random_state=rng)
180	
181	    ensemble = IsolationForest(n_jobs=3,
182	                               random_state=0).fit(X_train)
183	
184	    ensemble.set_params(n_jobs=1)
185	    y1 = ensemble.predict(X_test)
186	    ensemble.set_params(n_jobs=2)
... (truncated; read_file for the rest)


Nothing in this patch was written — not sklearn/ensemble/iforest.py, sklearn/ensemble/tests/test_iforest.py, examples/ensemble/plot_isolation_forest.py. Fix it and resend the whole patch.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '238,265p' sklearn/ensemble/tests/test_iforest.py"
}
```

**tool result**

```
    assert_array_equal(pred, 6 * [1] + 2 * [-1])


@pytest.mark.filterwarnings('ignore:default contamination')
@pytest.mark.filterwarnings('ignore:behaviour="old"')
def test_max_samples_consistency():
    # Make sure validated max_samples in iforest and BaseBagging are identical
    X = iris.data
    clf = IsolationForest().fit(X)
    assert_equal(clf.max_samples_, clf._max_samples)


@pytest.mark.filterwarnings('ignore:default contamination')
@pytest.mark.filterwarnings('ignore:threshold_ attribute')
@pytest.mark.filterwarnings('ignore:behaviour="old"')
def test_iforest_subsampled_features():
    # It tests non-regression for #5732 which failed at predict.
    rng = check_random_state(0)
    X_train, X_test, y_train, y_test = train_test_split(boston.data[:50],
                                                        boston.target[:50],
                                                        random_state=rng)
    clf = IsolationForest(max_features=0.8)
    clf.fit(X_train, y_train)
    clf.predict(X_test)


def test_iforest_average_path_length():
    # It tests non-regression for #8549 which used the wrong formula
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/ensemble/iforest.py\n@@\n     verbose : int, optional (default=0)\n         Controls the verbosity of the tree building process.\n \n+    warm_start : bool, optional (default=False)\n+        When set to ``True``, reuse the solution of the previous call to fit\n+        and add more estimators to the ensemble, otherwise, just fit a whole\n+        new forest. See :term:`the Glossary <warm_start>`.\n+\n \n     Attributes\n@@\n                  n_jobs=None,\n                  behaviour='old',\n                  random_state=None,\n-                 verbose=0):\n+                 verbose=0,\n+                 warm_start=False):\n@@\n             n_jobs=n_jobs,\n             random_state=random_state,\n-            verbose=verbose)\n+            verbose=verbose,\n+            warm_start=warm_start)\n*** Update File: sklearn/ensemble/tests/test_iforest.py\n@@\n def test_max_samples_consistency():\n     # Make sure validated max_samples in iforest and BaseBagging are identical\n     X = iris.data\n     clf = IsolationForest().fit(X)\n     assert_equal(clf.max_samples_, clf._max_samples)\n \n \n+def test_iforest_warm_start():\n+    \"\"\"Test warm_start parameter\"\"\"\n+    rng = check_random_state(0)\n+    X = rng.rand(30, 4)\n+\n+    clf = IsolationForest(n_estimators=5, warm_start=True, random_state=rng)\n+    clf.fit(X)\n+    assert_equal(len(clf.estimators_), 5)\n+    first_estimators = list(clf.estimators_)\n+\n+    # Increasing n_estimators should add new trees to the existing forest\n+    clf.set_params(n_estimators=10)\n+    clf.fit(X)\n+    assert_equal(len(clf.estimators_), 10)\n+    assert_equal(len(clf.estimators_samples_), 10)\n+    for old, new in zip(first_estimators, clf.estimators_[:5]):\n+        assert old is new\n+\n+    # Without warm_start, a new forest is fitted from scratch\n+    clf = IsolationForest(n_estimators=5, random_state=rng).fit(X)\n+    first_estimators = list(clf.estimators_)\n+    clf.set_params(n_estimators=10).fit(X)\n+    assert_equal(len(clf.estimators_), 10)\n+    for old, new in zip(first_estimators, clf.estimators_):\n+        assert old is not new\n+\n+\n @pytest.mark.filterwarnings('ignore:default contamination')\n @pytest.mark.filterwarnings('ignore:threshold_ attribute')\n @pytest.mark.filterwarnings('ignore:behaviour=\"old\"')\n def test_iforest_subsampled_features():\n*** Update File: examples/ensemble/plot_isolation_forest.py\n@@\n Random partitioning produces noticeable shorter paths for anomalies.\n Hence, when a forest of random trees collectively produce shorter path lengths\n for particular samples, they are highly likely to be anomalies.\n \n+The forest can be grown incrementally by setting ``warm_start=True`` and\n+increasing ``n_estimators`` between calls to ``fit``. This reuses the trees\n+already fitted instead of fitting a completely new forest.\n+\n \"\"\"\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/ensemble/iforest.py sklearn/ensemble/tests/test_iforest.py examples/ensemble/plot_isolation_forest.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/ensemble/iforest.py now (517 lines), around the change:
119:
120:    verbose : int, optional (default=0)
121:        Controls the verbosity of the tree building process.
122:
123:    warm_start : bool, optional (default=False)
124:        When set to ``True``, reuse the solution of the previous call to fit
125:        and add more estimators to the ensemble, otherwise, just fit a whole
126:        new forest. See :term:`the Glossary <warm_start>`.
127:
128:
129:    Attributes
…
178:                 n_jobs=None,
179:                 behaviour='old',
180:                 random_state=None,
181:                 verbose=0,
182:                 warm_start=False):
183:        super().__init__(
184:            base_estimator=ExtraTreeRegressor(
185:                max_features=1,
…
193:            max_features=max_features,
194:            n_jobs=n_jobs,
195:            random_state=random_state,
196:            verbose=verbose,
197:            warm_start=warm_start)
198:
199:        self.behaviour = behaviour
200:        self.contamination = contamination

sklearn/ensemble/tests/test_iforest.py now (388 lines), around the change:
247:    assert_equal(clf.max_samples_, clf._max_samples)
248:
249:
250:def test_iforest_warm_start():
251:    """Test warm_start parameter"""
252:    rng = check_random_state(0)
253:    X = rng.rand(30, 4)
254:
255:    clf = IsolationForest(n_estimators=5, warm_start=True, random_state=rng)
256:    clf.fit(X)
257:    assert_equal(len(clf.estimators_), 5)
258:    first_estimators = list(clf.estimators_)
259:
260:    # Increasing n_estimators should add new trees to the existing forest
261:    clf.set_params(n_estimators=10)
262:    clf.fit(X)
263:    assert_equal(len(clf.estimators_), 10)
264:    assert_equal(len(clf.estimators_samples_), 10)
265:    for old, new in zip(first_estimators, clf.estimators_[:5]):
266:        assert old is new
267:
268:    # Without warm_start, a new forest is fitted from scratch
269:    clf = IsolationForest(n_estimators=5, random_state=rng).fit(X)
270:    first_estimators = list(clf.estimators_)
271:    clf.set_params(n_estimators=10).fit(X)
272:    assert_equal(len(clf.estimators_), 10)
273:    for old, new in zip(first_estimators, clf.estimators_):
274:        assert old is not new
275:
276:
277:@pytest.mark.filterwarnings('ignore:default contamination')
278:@pytest.mark.filterwarnings('ignore:threshold_ attribute')
279:@pytest.mark.filterwarnings('ignore:behaviour="old"')

examples/ensemble/plot_isolation_forest.py now (75 lines), around the change:
20:Random partitioning produces noticeable shorter paths for anomalies.
21:Hence, when a forest of random trees collectively produce shorter path lengths
22:for particular samples, they are highly likely to be anomalies.
23:
24:The forest can be grown incrementally by setting ``warm_start=True`` and
25:increasing ``n_estimators`` between calls to ``fit``. This reuses the trees
26:already fitted instead of fitting a completely new forest.
27:
28:"""
29:print(__doc__)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/ensemble/tests/test_iforest.py -q 2>&1 | tail -20"
}
```

**tool result**

```

sklearn/ensemble/tests/test_iforest.py:264: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py:829: in assertEqual
    assertion_func(first, second, msg=msg)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <sklearn.utils._unittest_backport.TestCase testMethod=__init__>
first = 5, second = 10, msg = '5 != 10'

    def _baseAssertEqual(self, first, second, msg=None):
        """The default assertEqual implementation, not type specific."""
        if not first == second:
            standardMsg = '%s != %s' % _common_shorten_repr(first, second)
            msg = self._formatMessage(msg, standardMsg)
>           raise self.failureException(msg)
E           AssertionError: 5 != 10

/opt/miniconda3/envs/testbed/lib/python3.6/unittest/case.py:822: AssertionError
1 failed, 19 passed, 4 warnings in 6.40s
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"warm_start\" sklearn/ensemble/tests/test_bagging.py | head -20; grep -n \"_seeds\" sklearn/ensemble/bagging.py"
}
```

**tool result**

```
614:def test_warm_start(random_state=42):
624:                                       warm_start=True)
631:                                  warm_start=False)
638:def test_warm_start_smaller_n_estimators():
641:    clf = BaggingClassifier(n_estimators=5, warm_start=True)
647:def test_warm_start_equal_n_estimators():
652:    clf = BaggingClassifier(n_estimators=5, warm_start=True, random_state=83)
665:def test_warm_start_equivalence():
671:    clf_ws = BaggingClassifier(n_estimators=5, warm_start=True,
678:    clf = BaggingClassifier(n_estimators=10, warm_start=False,
686:def test_warm_start_with_oob_score_fails():
687:    # Check using oob_score and warm_start simultaneously fails
689:    clf = BaggingClassifier(n_estimators=5, warm_start=True, oob_score=True)
693:def test_oob_score_removed_on_warm_start():
699:    clf.set_params(warm_start=True, oob_score=False, n_estimators=100)
366:        self._seeds = seeds
404:        for seed in self._seeds:
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '350,375p' sklearn/ensemble/bagging.py"
}
```

**tool result**

```
        elif n_more_estimators == 0:
            warn("Warm-start fitting without increasing n_estimators does not "
                 "fit new trees.")
            return self

        # Parallel loop
        n_jobs, n_estimators, starts = _partition_estimators(n_more_estimators,
                                                             self.n_jobs)
        total_n_estimators = sum(n_estimators)

        # Advance random state to state after training
        # the first n_estimators
        if self.warm_start and len(self.estimators_) > 0:
            random_state.randint(MAX_INT, size=len(self.estimators_))

        seeds = random_state.randint(MAX_INT, size=n_more_estimators)
        self._seeds = seeds

        all_results = Parallel(n_jobs=n_jobs, verbose=self.verbose,
                               **self._parallel_args())(
            delayed(_parallel_build_estimators)(
                n_estimators[i],
                self,
                X,
                y,
                sample_weight,
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: sklearn/ensemble/bagging.py\n@@\n         seeds = random_state.randint(MAX_INT, size=n_more_estimators)\n-        self._seeds = seeds\n+        if self.warm_start and hasattr(self, '_seeds'):\n+            self._seeds = np.concatenate([self._seeds, seeds])\n+        else:\n+            self._seeds = seeds\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[sklearn/ensemble/bagging.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

sklearn/ensemble/bagging.py now (1022 lines), around the change:
363:            random_state.randint(MAX_INT, size=len(self.estimators_))
364:
365:        seeds = random_state.randint(MAX_INT, size=n_more_estimators)
366:        if self.warm_start and hasattr(self, '_seeds'):
367:            self._seeds = np.concatenate([self._seeds, seeds])
368:        else:
369:            self._seeds = seeds
370:
371:        all_results = Parallel(n_jobs=n_jobs, verbose=self.verbose,
372:                               **self._parallel_args())(
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest sklearn/ensemble/tests/test_iforest.py sklearn/ensemble/tests/test_bagging.py -q 2>&1 | tail -10"
}
```

**tool result**

```
...................................................                      [100%]
51 passed, 29 warnings in 16.11s
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"IsolationForest\" doc/whats_new/v0.22.rst | head"
}
```

**tool result**

```
grep: doc/whats_new/v0.22.rst: No such file or directory
```

**assistant → tool `bash`**

```json
{
  "command": "git diff --stat && python -m pytest sklearn/ensemble/tests/test_iforest.py -q 2>&1 | tail -3"
}
```

**tool result**

```
 examples/ensemble/plot_isolation_forest.py |  4 ++++
 sklearn/ensemble/bagging.py                |  5 ++++-
 sklearn/ensemble/iforest.py                | 11 +++++++++--
 sklearn/ensemble/tests/test_iforest.py     | 27 +++++++++++++++++++++++++++
 4 files changed, 44 insertions(+), 3 deletions(-)
....................                                                     [100%]
20 passed, 8 warnings in 6.21s
```

**assistant**

```
Done. Summary of changes:

- **`sklearn/ensemble/iforest.py`**: Exposed `warm_start=False` in `IsolationForest.__init__()` and forwarded it to `BaseBagging`. Documented it with the same wording as `RandomForestClassifier`.
- **`sklearn/ensemble/bagging.py`**: Fixed warm-start seed tracking — `_seeds` is now accumulated across fits, so `estimators_samples_` stays consistent with `estimators_` after incrementally adding trees (previously only the newly generated seeds were kept).
- **`sklearn/ensemble/tests/test_iforest.py`**: Added `test_iforest_warm_start`, verifying that increasing `n_estimators` with `warm_start=True` preserves existing trees and adds new ones, that sample indices match, and that `warm_start=False` fits a fresh forest.
- **`examples/ensemble/plot_isolation_forest.py`**: Mentioned incremental growing via `warm_start=True` in the example docstring.

Verification: all 20 IsolationForest tests and all 31 bagging tests pass (51 total).
```

## Run folder `team-solve-2026-11-06T133417`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
8aeedb68b06d26bcbd1930ca68359451955ae41b
```

### `baseline-check.log`

```
check: pytest sklearn/ensemble/tests/test_iforest.py -q

==================================== ERRORS ====================================
___________ ERROR collecting sklearn/ensemble/tests/test_iforest.py ____________
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
sklearn/__init__.py:75: in <module>
    from . import __check_build
sklearn/__check_build/__init__.py:46: in <module>
    raise_build_error(e)
sklearn/__check_build/__init__.py:41: in raise_build_error
    %s""" % (e, local_dir, ''.join(dir_content).strip(), msg))
E   ImportError: No module named 'sklearn.__check_build._check_build'
E   ___________________________________________________________________________
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T133417/baseline-tree/sklearn/__check_build:
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
___________ ERROR collecting sklearn/ensemble/tests/test_iforest.py ____________
ImportError while importing test module '/testbed/.memdoor/runs/team-solve-2026-11-06T133417/baseline-tree/sklearn/ensemble/tests/test_iforest.py'.
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
E   Contents of /testbed/.memdoor/runs/team-solve-2026-11-06T133417/baseline-tree/sklearn/__check_build:
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
2 errors in 0.24s
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/examples/ensemble/plot_isolation_forest.py b/examples/ensemble/plot_isolation_forest.py
index 1b79072df..b26f156a0 100755
--- a/examples/ensemble/plot_isolation_forest.py
+++ b/examples/ensemble/plot_isolation_forest.py
@@ -21,6 +21,10 @@ Random partitioning produces noticeable shorter paths for anomalies.
 Hence, when a forest of random trees collectively produce shorter path lengths
 for particular samples, they are highly likely to be anomalies.
 
+The forest can be grown incrementally by setting ``warm_start=True`` and
+increasing ``n_estimators`` between calls to ``fit``. This reuses the trees
+already fitted instead of fitting a completely new forest.
+
 """
 print(__doc__)
 
diff --git a/sklearn/ensemble/bagging.py b/sklearn/ensemble/bagging.py
index f21fbd81b..30e562c16 100755
--- a/sklearn/ensemble/bagging.py
+++ b/sklearn/ensemble/bagging.py
@@ -363,7 +363,10 @@ class BaseBagging(BaseEnsemble, metaclass=ABCMeta):
             random_state.randint(MAX_INT, size=len(self.estimators_))
 
         seeds = random_state.randint(MAX_INT, size=n_more_estimators)
-        self._seeds = seeds
+        if self.warm_start and hasattr(self, '_seeds'):
+            self._seeds = np.concatenate([self._seeds, seeds])
+        else:
+            self._seeds = seeds
 
         all_results = Parallel(n_jobs=n_jobs, verbose=self.verbose,
                                **self._parallel_args())(
diff --git a/sklearn/ensemble/iforest.py b/sklearn/ensemble/iforest.py
index 8a1bd3625..f42c80532 100755
--- a/sklearn/ensemble/iforest.py
+++ b/sklearn/ensemble/iforest.py
@@ -120,6 +120,11 @@ class IsolationForest(BaseBagging, OutlierMixin):
     verbose : int, optional (default=0)
         Controls the verbosity of the tree building process.
 
+    warm_start : bool, optional (default=False)
+        When set to ``True``, reuse the solution of the previous call to fit
+        and add more estimators to the ensemble, otherwise, just fit a whole
+        new forest. See :term:`the Glossary <warm_start>`.
+
 
     Attributes
     ----------
@@ -173,7 +178,8 @@ class IsolationForest(BaseBagging, OutlierMixin):
                  n_jobs=None,
                  behaviour='old',
                  random_state=None,
-                 verbose=0):
+                 verbose=0,
+                 warm_start=False):
         super().__init__(
             base_estimator=ExtraTreeRegressor(
                 max_features=1,
@@ -187,7 +193,8 @@ class IsolationForest(BaseBagging, OutlierMixin):
             max_features=max_features,
             n_jobs=n_jobs,
             random_state=random_state,
-            verbose=verbose)
+            verbose=verbose,
+            warm_start=warm_start)
 
         self.behaviour = behaviour
         self.contamination = contamination
diff --git a/sklearn/ensemble/tests/test_iforest.py b/sklearn/ensemble/tests/test_iforest.py
index 67ba2d7f9..60002f116 100755
--- a/sklearn/ensemble/tests/test_iforest.py
+++ b/sklearn/ensemble/tests/test_iforest.py
@@ -247,6 +247,33 @@ def test_max_samples_consistency():
     assert_equal(clf.max_samples_, clf._max_samples)
 
 
+def test_iforest_warm_start():
+    """Test warm_start parameter"""
+    rng = check_random_state(0)
+    X = rng.rand(30, 4)
+
+    clf = IsolationForest(n_estimators=5, warm_start=True, random_state=rng)
+    clf.fit(X)
+    assert_equal(len(clf.estimators_), 5)
+    first_estimators = list(clf.estimators_)
+
+    # Increasing n_estimators should add new trees to the existing forest
+    clf.set_params(n_estimators=10)
+    clf.fit(X)
+    assert_equal(len(clf.estimators_), 10)
+    assert_equal(len(clf.estimators_samples_), 10)
+    for old, new in zip(first_estimators, clf.estimators_[:5]):
+        assert old is new
+
+    # Without warm_start, a new forest is fitted from scratch
+    clf = IsolationForest(n_estimators=5, random_state=rng).fit(X)
+    first_estimators = list(clf.estimators_)
+    clf.set_params(n_estimators=10).fit(X)
+    assert_equal(len(clf.estimators_), 10)
+    for old, new in zip(first_estimators, clf.estimators_):
+        assert old is not new
+
+
 @pytest.mark.filterwarnings('ignore:default contamination')
 @pytest.mark.filterwarnings('ignore:threshold_ attribute')
 @pytest.mark.filterwarnings('ignore:behaviour="old"')
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

Expose warm_start in Isolation forest
It seems to me that `sklearn.ensemble.IsolationForest` supports incremental addition of new trees with the `warm_start` parameter of its parent class, `sklearn.ensemble.BaseBagging`.

Even though this parameter is not exposed in `__init__()` , it gets inherited from `BaseBagging` and one can use it by changing it to `True` after initialization. To make it work, you have to also increment `n_estimators` on every iteration. 

It took me a while to notice that it actually works, and I had to inspect the source code of both `IsolationForest` and `BaseBagging`. Also, it looks to me that the behavior is in-line with `sklearn.ensemble.BaseForest` that is behind e.g. `sklearn.ensemble.RandomForestClassifier`.

To make it more easier to use, I'd suggest to:
* expose `warm_start` in `IsolationForest.__init__()`, default `False`;
* document it in the same way as it is documented for `RandomForestClassifier`, i.e. say:
```py
    warm_start : bool, optional (default=False)
        When set to ``True``, reuse the solution of the previous call to fit
        and add more estimators to the ensemble, otherwise, just fit a whole
        new forest. See :term:`the Glossary <warm_start>`.
```
* add a test to make sure it works properly;
* possibly also mention in the "IsolationForest example" documentation entry;

## Deliverable

changes to this tree

## Check

`pytest sklearn/ensemble/tests/test_iforest.py -q`

## Scope

`sklearn/ensemble/`
`examples/ensemble/plot_isolation_forest.py`

## Done when

`IsolationForest.__init__` exposes `warm_start` with default `False`.
`IsolationForest` passes `warm_start` through to `BaseBagging`, so `fit` reuses prior trees when `warm_start=True` and `n_estimators` is increased, and refits a new forest when `warm_start=False`.
The `warm_start` docstring uses the quoted RandomForestClassifier wording and the `:term:`warm_start`` glossary link.
A test verifies that warm-start fitting reuses previous estimators and adds new ones.
(inferred) The IsolationForest example documentation entry mentions `warm_start`.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest sklearn/ensemble/tests/test_iforest.py -q`

## Scope
`sklearn/ensemble/`
`examples/ensemble/plot_isolation_forest.py`

## Done when
`IsolationForest.__init__` exposes `warm_start` with default `False`.
`IsolationForest` passes `warm_start` through to `BaseBagging`, so `fit` reuses prior trees when `warm_start=True` and `n_estimators` is increased, and refits a new forest when `warm_start=False`.
The `warm_start` docstring uses the quoted RandomForestClassifier wording and the `:term:`warm_start`` glossary link.
A test verifies that warm-start fitting reuses previous estimators and adds new ones.
(inferred) The IsolationForest example documentation entry mentions `warm_start`.

## Approach
Primary approach: add `warm_start=False` to `IsolationForest.__init__`, document it in the class docstring, pass it into the `BaseBagging` initializer, add a focused test in the ensemble tests, and optionally update `examples/ensemble/plot_isolation_forest.py`. This is minimal and relies on the existing `BaseBagging` warm-start machinery.

If that fails:
- Check `BaseBagging.__init__` in this branch and, if needed, extend its signature/attribute handling; tradeoff is touching shared bagging code used by other ensembles.
- Override `fit` in `IsolationForest` to manage tree reuse manually; tradeoff is duplicating base behavior and adding maintenance risk.
- Keep the inherited-attribute workaround only; rejected because the prompt requires exposing the constructor parameter and documenting it.

Test approach: use a small deterministic dataset, fit with `warm_start=True`, record `estimators_`, increase `n_estimators`, fit again, and assert that the original estimators are preserved while the ensemble grows.


# sklearn/ensemble (the files in it)

sklearn/ensemble/__init__.py
sklearn/ensemble/_gb_losses.py
sklearn/ensemble/_gradient_boosting.pyx
sklearn/ensemble/bagging.py
sklearn/ensemble/base.py
sklearn/ensemble/forest.py
sklearn/ensemble/gradient_boosting.py
sklearn/ensemble/iforest.py
sklearn/ensemble/partial_dependence.py
sklearn/ensemble/setup.py
sklearn/ensemble/tests/__init__.py
sklearn/ensemble/tests/test_bagging.py
sklearn/ensemble/tests/test_base.py
sklearn/ensemble/tests/test_forest.py
sklearn/ensemble/tests/test_gradient_boosting.py
sklearn/ensemble/tests/test_gradient_boosting_loss_functions.py
sklearn/ensemble/tests/test_iforest.py
sklearn/ensemble/tests/test_partial_dependence.py
sklearn/ensemble/tests/test_voting_classifier.py
sklearn/ensemble/tests/test_weight_boosting.py
sklearn/ensemble/voting_classifier.py
sklearn/ensemble/weight_boosting.py


# examples/ensemble/plot_isolation_forest.py

```
"""
==========================================
IsolationForest example
==========================================

An example using :class:`sklearn.ensemble.IsolationForest` for anomaly
detection.

The IsolationForest 'isolates' observations by randomly selecting a feature
and then randomly selecting a split value between the maximum and minimum
values of the selected feature.

Since recursive partitioning can be represented by a tree structure, the
number of splittings required to isolate a sample is equivalent to the path
length from the root node to the terminating node.

This path length, averaged over a forest of such random trees, is a measure
of normality and our decision function.

Random partitioning produces noticeable shorter paths for anomalies.
Hence, when a forest of random trees collectively produce shorter path lengths
for particular samples, they are highly likely to be anomalies.

The forest can be grown incrementally by setting ``warm_start=True`` and
increasing ``n_estimators`` between calls to ``fit``. This reuses the trees
already fitted instead of fitting a completely new forest.

"""
print(__doc__)

import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import IsolationForest

rng = np.random.RandomState(42)

# Generate train data
X = 0.3 * rng.randn(100, 2)
X_train = np.r_[X + 2, X - 2]
# Generate some regular novel observations
X = 0.3 * rng.randn(20, 2)
X_test = np.r_[X + 2, X - 2]
# Generate some abnormal novel observations
X_outliers = rng.uniform(low=-4, high=4, size=(20, 2))

# fit the model
clf = IsolationForest(behaviour='new', max_samples=100,
                      random_state=rng, contamination='auto')
clf.fit(X_train)
y_pred_train = clf.predict(X_train)
y_pred_test = clf.predict(X_test)
y_pred_outliers = clf.predict(X_outliers)

# plot the line, the samples, and the nearest vectors to the plane
xx, yy = np.meshgrid(np.linspace(-5, 5, 50), np.linspace(-5, 5, 50))
Z = clf.decision_function(np.c_[xx.ravel(), yy.ravel()])
Z = Z.reshape(xx.shape)

plt.title("IsolationForest")
plt.contourf(xx, yy, Z, cmap=plt.cm.Blues_r)

b1 = plt.scatter(X_train[:, 0], X_train[:, 1], c='white',
                 s=20, edgecolor='k')
b2 = plt.scatter(X_test[:, 0], X_test[:, 1], c='green',
                 s=20, edgecolor='k')
c = plt.scatter(X_outliers[:, 0], X_outliers[:, 1], c='red',
                s=20, edgecolor='k')
plt.axis('tight')
plt.xlim((-5, 5))
plt.ylim((-5, 5))
plt.legend([b1, b2, c],
           ["training observations",
            "new regular observations", "new abnormal observations"],
           loc="upper left")
plt.show()

```


# The last commit

```
8aeedb68b SWE-bench



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
check: pytest sklearn/ensemble/tests/test_iforest.py -q
....................                                                     [100%]
20 passed, 8 warnings in 6.15s
scope: sklearn/ensemble examples/ensemble/plot_isolation_forest.py
changed: examples/ensemble/plot_isolation_forest.py +4 -0
changed: sklearn/ensemble/bagging.py +4 -1
changed: sklearn/ensemble/iforest.py +9 -2
changed: sklearn/ensemble/tests/test_iforest.py +27 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/examples/ensemble/plot_isolation_forest.py b/examples/ensemble/plot_isolation_forest.py
index 1b79072df..b26f156a0 100755
--- a/examples/ensemble/plot_isolation_forest.py
+++ b/examples/ensemble/plot_isolation_forest.py
@@ -21,6 +21,10 @@ Random partitioning produces noticeable shorter paths for anomalies.
 Hence, when a forest of random trees collectively produce shorter path lengths
 for particular samples, they are highly likely to be anomalies.
 
+The forest can be grown incrementally by setting ``warm_start=True`` and
+increasing ``n_estimators`` between calls to ``fit``. This reuses the trees
+already fitted instead of fitting a completely new forest.
+
 """
 print(__doc__)
 
diff --git a/sklearn/ensemble/bagging.py b/sklearn/ensemble/bagging.py
index f21fbd81b..30e562c16 100755
--- a/sklearn/ensemble/bagging.py
+++ b/sklearn/ensemble/bagging.py
@@ -363,7 +363,10 @@ class BaseBagging(BaseEnsemble, metaclass=ABCMeta):
             random_state.randint(MAX_INT, size=len(self.estimators_))
 
         seeds = random_state.randint(MAX_INT, size=n_more_estimators)
-        self._seeds = seeds
+        if self.warm_start and hasattr(self, '_seeds'):
+            self._seeds = np.concatenate([self._seeds, seeds])
+        else:
+            self._seeds = seeds
 
         all_results = Parallel(n_jobs=n_jobs, verbose=self.verbose,
                                **self._parallel_args())(
diff --git a/sklearn/ensemble/iforest.py b/sklearn/ensemble/iforest.py
index 8a1bd3625..f42c80532 100755
--- a/sklearn/ensemble/iforest.py
+++ b/sklearn/ensemble/iforest.py
@@ -120,6 +120,11 @@ class IsolationForest(BaseBagging, OutlierMixin):
     verbose : int, optional (default=0)
         Controls the verbosity of the tree building process.
 
+    warm_start : bool, optional (default=False)
+        When set to ``True``, reuse the solution of the previous call to fit
+        and add more estimators to the ensemble, otherwise, just fit a whole
+        new forest. See :term:`the Glossary <warm_start>`.
+
 
     Attributes
     ----------
@@ -173,7 +178,8 @@ class IsolationForest(BaseBagging, OutlierMixin):
                  n_jobs=None,
                  behaviour='old',
                  random_state=None,
-                 verbose=0):
+                 verbose=0,
+                 warm_start=False):
         super().__init__(
             base_estimator=ExtraTreeRegressor(
                 max_features=1,
@@ -187,7 +193,8 @@ class IsolationForest(BaseBagging, OutlierMixin):
             max_features=max_features,
             n_jobs=n_jobs,
             random_state=random_state,
-            verbose=verbose)
+            verbose=verbose,
+            warm_start=warm_start)
 
         self.behaviour = behaviour
         self.contamination = contamination
diff --git a/sklearn/ensemble/tests/test_iforest.py b/sklearn/ensemble/tests/test_iforest.py
index 67ba2d7f9..60002f116 100755
--- a/sklearn/ensemble/tests/test_iforest.py
+++ b/sklearn/ensemble/tests/test_iforest.py
@@ -247,6 +247,33 @@ def test_max_samples_consistency():
     assert_equal(clf.max_samples_, clf._max_samples)
 
 
+def test_iforest_warm_start():
+    """Test warm_start parameter"""
+    rng = check_random_state(0)
+    X = rng.rand(30, 4)
+
+    clf = IsolationForest(n_estimators=5, warm_start=True, random_state=rng)
+    clf.fit(X)
+    assert_equal(len(clf.estimators_), 5)
+    first_estimators = list(clf.estimators_)
+
+    # Increasing n_estimators should add new trees to the existing forest
+    clf.set_params(n_estimators=10)
+    clf.fit(X)
+    assert_equal(len(clf.estimators_), 10)
+    assert_equal(len(clf.estimators_samples_), 10)
+    for old, new in zip(first_estimators, clf.estimators_[:5]):
+        assert old is new
+
+    # Without warm_start, a new forest is fitted from scratch
+    clf = IsolationForest(n_estimators=5, random_state=rng).fit(X)
+    first_estimators = list(clf.estimators_)
+    clf.set_params(n_estimators=10).fit(X)
+    assert_equal(len(clf.estimators_), 10)
+    for old, new in zip(first_estimators, clf.estimators_):
+        assert old is not new
+
+
 @pytest.mark.filterwarnings('ignore:default contamination')
 @pytest.mark.filterwarnings('ignore:threshold_ attribute')
 @pytest.mark.filterwarnings('ignore:behaviour="old"')
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
check: pytest sklearn/ensemble/tests/test_iforest.py -q
....................                                                     [100%]
20 passed, 8 warnings in 6.93s
scope: sklearn/ensemble examples/ensemble/plot_isolation_forest.py
changed: examples/ensemble/plot_isolation_forest.py +4 -0
changed: sklearn/ensemble/bagging.py +4 -1
changed: sklearn/ensemble/iforest.py +9 -2
changed: sklearn/ensemble/tests/test_iforest.py +27 -0
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
# Notes, run 2026-11-06T133417

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Expose warm_start in Isolation forest
It seems to me that `sklearn.ensemble.IsolationForest` supports incremental addition of new trees with the `warm_start` parameter of its parent class, `sklearn.ensemble.BaseBagging`.

Even though this parameter is not exposed in `__init__()` , it gets inherited from `BaseBagging` and one can use it by changing it to `True` after initialization. To make it work, you have to also increment `n_estimators` on every iteration. 

It took me a while to notice that it actually works, and I had to inspect the source code of both `IsolationForest` and `BaseBagging`. Also, it looks to me that the behavior is in-line with `sklearn.ensemble.BaseForest` that is behind e.g. `sklearn.ensemble.RandomForestClassifier`.

To make it more easier to use, I'd suggest to:
* expose `warm_start` in `IsolationForest.__init__()`, default `False`;
* document it in the same way as it is documented for `RandomForestClassifier`, i.e. say:
```py
    warm_start : bool, optional (default=False)
        When set to ``True``, reuse the solution of the previous call to fit
        and add more estimators to the ensemble, otherwise, just fit a whole
        new forest. See :term:`the Glossary <warm_start>`.
```
* add a test to make sure it works properly;
* possibly also mention in the "IsolationForest example" documentation entry;


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
8aeedb68b SWE-bench



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
`pytest sklearn/ensemble/tests/test_iforest.py -q`

## Scope
`sklearn/ensemble/`
`examples/ensemble/plot_isolation_forest.py`

## Done when
`IsolationForest.__init__` exposes `warm_start` with default `False`.
`IsolationForest` passes `warm_start` through to `BaseBagging`, so `fit` reuses prior trees when `warm_start=True` and `n_estimators` is increased, and refits a new forest when `warm_start=False`.
The `warm_start` docstring uses the quoted RandomForestClassifier wording and the `:term:`warm_start`` glossary link.
A test verifies that warm-start fitting reuses previous estimators and adds new ones.
(inferred) The IsolationForest example documentation entry mentions `warm_start`.

## Approach
Primary approach: add `warm_start=False` to `IsolationForest.__init__`, document it in the class docstring, pass it into the `BaseBagging` initializer, add a focused test in the ensemble tests, and optionally update `examples/ensemble/plot_isolation_forest.py`. This is minimal and relies on the existing `BaseBagging` warm-start machinery.

If that fails:
- Check `BaseBagging.__init__` in this branch and, if needed, extend its signature/attribute handling; tradeoff is touching shared bagging code used by other ensembles.
- Override `fit` in `IsolationForest` to manage tree reuse manually; tradeoff is duplicating base behavior and adding maintenance risk.
- Keep the inherited-attribute workaround only; rejected because the prompt requires exposing the constructor parameter and documenting it.

Test approach: use a small deterministic dataset, fit with `warm_start=True`, record `estimators_`, increase `n_estimators`, fit again, and assert that the original estimators are preserved while the ensemble grows.
```

### `prompt.md`

````
Expose warm_start in Isolation forest
It seems to me that `sklearn.ensemble.IsolationForest` supports incremental addition of new trees with the `warm_start` parameter of its parent class, `sklearn.ensemble.BaseBagging`.

Even though this parameter is not exposed in `__init__()` , it gets inherited from `BaseBagging` and one can use it by changing it to `True` after initialization. To make it work, you have to also increment `n_estimators` on every iteration. 

It took me a while to notice that it actually works, and I had to inspect the source code of both `IsolationForest` and `BaseBagging`. Also, it looks to me that the behavior is in-line with `sklearn.ensemble.BaseForest` that is behind e.g. `sklearn.ensemble.RandomForestClassifier`.

To make it more easier to use, I'd suggest to:
* expose `warm_start` in `IsolationForest.__init__()`, default `False`;
* document it in the same way as it is documented for `RandomForestClassifier`, i.e. say:
```py
    warm_start : bool, optional (default=False)
        When set to ``True``, reuse the solution of the previous call to fit
        and add more estimators to the ensemble, otherwise, just fit a whole
        new forest. See :term:`the Glossary <warm_start>`.
```
* add a test to make sure it works properly;
* possibly also mention in the "IsolationForest example" documentation entry;
````

### `review.md`

```
verdict: PASS
- `IsolationForest.__init__` now exposes `warm_start=False` and forwards it to `BaseBagging`.
- Warm-start fitting retains prior estimators and adds new ones when `n_estimators` increases; non-warm-start fitting creates a fresh forest.
- The `warm_start` docstring uses the requested RandomForestClassifier wording and `:term:`warm_start`` glossary link.
- `test_iforest_warm_start` explicitly verifies estimator reuse with `warm_start=True` and refitting with `warm_start=False`.
- The IsolationForest example documentation mentions `warm_start`.
- The check reports `20 passed`; changed files are within scope, and no unrelated content was removed.
```

### `scope.txt`

```
scope: sklearn/ensemble examples/ensemble/plot_isolation_forest.py
changed: examples/ensemble/plot_isolation_forest.py +4 -0
changed: sklearn/ensemble/bagging.py +4 -1
changed: sklearn/ensemble/iforest.py +9 -2
changed: sklearn/ensemble/tests/test_iforest.py +27 -0
```

### `task.md`

````
# Task

## Prompt

Expose warm_start in Isolation forest
It seems to me that `sklearn.ensemble.IsolationForest` supports incremental addition of new trees with the `warm_start` parameter of its parent class, `sklearn.ensemble.BaseBagging`.

Even though this parameter is not exposed in `__init__()` , it gets inherited from `BaseBagging` and one can use it by changing it to `True` after initialization. To make it work, you have to also increment `n_estimators` on every iteration. 

It took me a while to notice that it actually works, and I had to inspect the source code of both `IsolationForest` and `BaseBagging`. Also, it looks to me that the behavior is in-line with `sklearn.ensemble.BaseForest` that is behind e.g. `sklearn.ensemble.RandomForestClassifier`.

To make it more easier to use, I'd suggest to:
* expose `warm_start` in `IsolationForest.__init__()`, default `False`;
* document it in the same way as it is documented for `RandomForestClassifier`, i.e. say:
```py
    warm_start : bool, optional (default=False)
        When set to ``True``, reuse the solution of the previous call to fit
        and add more estimators to the ensemble, otherwise, just fit a whole
        new forest. See :term:`the Glossary <warm_start>`.
```
* add a test to make sure it works properly;
* possibly also mention in the "IsolationForest example" documentation entry;

## Deliverable

changes to this tree

## Check

`pytest sklearn/ensemble/tests/test_iforest.py -q`

## Scope

`sklearn/ensemble/`
`examples/ensemble/plot_isolation_forest.py`

## Done when

`IsolationForest.__init__` exposes `warm_start` with default `False`.
`IsolationForest` passes `warm_start` through to `BaseBagging`, so `fit` reuses prior trees when `warm_start=True` and `n_estimators` is increased, and refits a new forest when `warm_start=False`.
The `warm_start` docstring uses the quoted RandomForestClassifier wording and the `:term:`warm_start`` glossary link.
A test verifies that warm-start fitting reuses previous estimators and adds new ones.
(inferred) The IsolationForest example documentation entry mentions `warm_start`.
````

### `test-output.log`

```
check: pytest sklearn/ensemble/tests/test_iforest.py -q
....................                                                     [100%]
20 passed, 8 warnings in 6.13s
scope: sklearn/ensemble examples/ensemble/plot_isolation_forest.py
changed: examples/ensemble/plot_isolation_forest.py +4 -0
changed: sklearn/ensemble/bagging.py +4 -1
changed: sklearn/ensemble/iforest.py +9 -2
changed: sklearn/ensemble/tests/test_iforest.py +27 -0
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
