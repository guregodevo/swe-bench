# pydata__xarray-3677 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 375s 71 lines cost=0.008635 in=110597 cached=70144 out=18661 calls=11`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

Merging dataArray into dataset using dataset method fails
While it's possible to merge a dataset and a dataarray object using the top-level `merge()` function, if you try the same thing with the `ds.merge()` method it fails.

```python
import xarray as xr

ds = xr.Dataset({'a': 0})
da = xr.DataArray(1, name='b')

expected = xr.merge([ds, da])  # works fine
print(expected)

ds.merge(da)  # fails
```

Output:
```
<xarray.Dataset>
Dimensions:  ()
Data variables:
    a        int64 0
    b        int64 1

Traceback (most recent call last):
  File "mwe.py", line 6, in <module>
    actual = ds.merge(da)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/dataset.py", line 3591, in merge
    fill_value=fill_value,
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 835, in dataset_merge_method
    objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 548, in merge_core
    coerced = coerce_pandas_values(objects)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 394, in coerce_pandas_values
    for k, v in obj.items():
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/common.py", line 233, in __getattr__
    "{!r} object has no attribute {!r}".format(type(self).__name__, name)
AttributeError: 'DataArray' object has no attribute 'items'
```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --short && git log -1 --oneline"
}
```

**assistant → tool `read_file`**

```json
{
  "path": "xarray/core/merge.py",
  "offset": 360,
  "limit": 80
}
```

**tool result**

```
CODE_OF_CONDUCT.md
HOW_TO_RELEASE.md
LICENSE
MANIFEST.in
README.rst
__pycache__
asv_bench
azure-pipelines.yml
ci
conftest.py
doc
licenses
properties
readthedocs.yml
setup.cfg
setup.py
versioneer.py
xarray
xarray.egg-info
?? .memdoor/
deda502c SWE-bench
```

**tool result**

```
                if isinstance(var, DataArray):
                    coords = set(var._coords)  # use private API for speed
                    # explicitly overwritten variables should take precedence
                    coords.discard(name)
                    coord_names.update(coords)

    return coord_names, noncoord_names


def coerce_pandas_values(objects: Iterable["CoercibleMapping"]) -> List["DatasetLike"]:
    """Convert pandas values found in a list of labeled objects.

    Parameters
    ----------
    objects : list of Dataset or mappings
        The mappings may contain any sort of objects coercible to
        xarray.Variables as keys, including pandas objects.

    Returns
    -------
    List of Dataset or dictionary objects. Any inputs or values in the inputs
    that were pandas objects have been converted into native xarray objects.
    """
    from .dataarray import DataArray
    from .dataset import Dataset

    out = []
    for obj in objects:
        if isinstance(obj, Dataset):
            variables: "DatasetLike" = obj
        else:
            variables = {}
            if isinstance(obj, PANDAS_TYPES):
                obj = dict(obj.iteritems())
            for k, v in obj.items():
                if isinstance(v, PANDAS_TYPES):
                    v = DataArray(v)
                variables[k] = v
        out.append(variables)
    return out


def _get_priority_vars_and_indexes(
    objects: List["DatasetLike"], priority_arg: Optional[int], compat: str = "equals"
) -> Dict[Hashable, MergeElement]:
    """Extract the priority variable from a list of mappings.

    We need this method because in some cases the priority argument itself
    might have conflicting values (e.g., if it is a dict with two DataArray
    values with conflicting coordinate values).

    Parameters
    ----------
    objects : list of dictionaries of variables
        Dictionaries in which to find the priority variables.
    priority_arg : int or None
        Integer object whose variable should take priority.
    compat : {'identical', 'equals', 'broadcast_equals', 'no_conflicts'}, optional
        Compatibility checks to use when merging variables.

    Returns
    -------
    A dictionary of variables and associated indexes (if any) to prioritize.
    """
    if priority_arg is None:
        return {}

    collected = collect_variables_and_indexes([objects[priority_arg]])
    variables, indexes = merge_collected(collected, compat=compat)
    grouped: Dict[Hashable, MergeElement] = {}
    for name, variable in variables.items():
        grouped[name] = (variable, indexes.get(name))
    return grouped


def merge_coords(
    objects: Iterable["CoercibleMapping"],
    compat: str = "minimal",
    join: str = "outer",
    priority_arg: Optional[int] = None,

[425 more lines in /testbed/xarray/core/merge.py (864 in all). read_file with offset: 440 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def dataset_merge_method\\|def merge_core\\|def merge(\" xarray/core/merge.py && sed -n '500,620p' xarray/core/merge.py && sed -n '800,860p' xarray/core/merge.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def merge\" xarray/core/dataset.py | head && sed -n '3540,3610p' xarray/core/dataset.py"
}
```

**tool result**

```
501:def merge_core(
577:def merge(
798:def dataset_merge_method(

def merge_core(
    objects: Iterable["CoercibleMapping"],
    compat: str = "broadcast_equals",
    join: str = "outer",
    priority_arg: Optional[int] = None,
    explicit_coords: Optional[Sequence] = None,
    indexes: Optional[Mapping[Hashable, pd.Index]] = None,
    fill_value: object = dtypes.NA,
) -> _MergeResult:
    """Core logic for merging labeled objects.

    This is not public API.

    Parameters
    ----------
    objects : list of mappings
        All values must be convertable to labeled arrays.
    compat : {'identical', 'equals', 'broadcast_equals', 'no_conflicts', 'override'}, optional
        Compatibility checks to use when merging variables.
    join : {'outer', 'inner', 'left', 'right'}, optional
        How to combine objects with different indexes.
    priority_arg : integer, optional
        Optional argument in `objects` that takes precedence over the others.
    explicit_coords : set, optional
        An explicit list of variables from `objects` that are coordinates.
    indexes : dict, optional
        Dictionary with values given by pandas.Index objects.
    fill_value : scalar, optional
        Value to use for newly missing values

    Returns
    -------
    variables : dict
        Dictionary of Variable objects.
    coord_names : set
        Set of coordinate names.
    dims : dict
        Dictionary mapping from dimension names to sizes.

    Raises
    ------
    MergeError if the merge cannot be done successfully.
    """
    from .dataset import calculate_dimensions

    _assert_compat_valid(compat)

    coerced = coerce_pandas_values(objects)
    aligned = deep_align(
        coerced, join=join, copy=False, indexes=indexes, fill_value=fill_value
    )
    collected = collect_variables_and_indexes(aligned)

    prioritized = _get_priority_vars_and_indexes(aligned, priority_arg, compat=compat)
    variables, out_indexes = merge_collected(collected, prioritized, compat=compat)
    assert_unique_multiindex_level_names(variables)

    dims = calculate_dimensions(variables)

    coord_names, noncoord_names = determine_coords(coerced)
    if explicit_coords is not None:
        assert_valid_explicit_coords(variables, dims, explicit_coords)
        coord_names.update(explicit_coords)
    for dim, size in dims.items():
        if dim in variables:
            coord_names.add(dim)
    ambiguous_coords = coord_names.intersection(noncoord_names)
    if ambiguous_coords:
        raise MergeError(
            "unable to determine if these variables should be "
            "coordinates or not in the merged result: %s" % ambiguous_coords
        )

    return _MergeResult(variables, coord_names, dims, out_indexes)


def merge(
    objects: Iterable[Union["DataArray", "CoercibleMapping"]],
    compat: str = "no_conflicts",
    join: str = "outer",
    fill_value: object = dtypes.NA,
) -> "Dataset":
    """Merge any number of xarray objects into a single Dataset as variables.

    Parameters
    ----------
    objects : Iterable[Union[xarray.Dataset, xarray.DataArray, dict]]
        Merge together all variables from these objects. If any of them are
        DataArray objects, they must have a name.
    compat : {'identical', 'equals', 'broadcast_equals', 'no_conflicts', 'override'}, optional
        String indicating how to compare variables of the same name for
        potential conflicts:

        - 'broadcast_equals': all values must be equal when variables are
          broadcast against each other to ensure common dimensions.
        - 'equals': all values and dimensions must be the same.
        - 'identical': all values, dimensions and attributes must be the
          same.
        - 'no_conflicts': only values which are not null in both datasets
          must be equal. The returned dataset then contains the combination
          of all non-null values.
        - 'override': skip comparing and pick variable from first dataset
    join : {'outer', 'inner', 'left', 'right', 'exact'}, optional
        String indicating how to combine differing indexes in objects.

        - 'outer': use the union of object indexes
        - 'inner': use the intersection of object indexes
        - 'left': use indexes from the first object with each dimension
        - 'right': use indexes from the last object with each dimension
        - 'exact': instead of aligning, raise `ValueError` when indexes to be
          aligned are not equal
        - 'override': if indexes are of same size, rewrite indexes to be
          those of the first object with that dimension. Indexes for the same
          dimension must have the same size in all objects.
    fill_value : scalar, optional
        Value to use for newly missing values

    Returns
    -------
    Dataset
    other: "CoercibleMapping",
    overwrite_vars: Union[Hashable, Iterable[Hashable]],
    compat: str,
    join: str,
    fill_value: Any,
) -> _MergeResult:
    """Guts of the Dataset.merge method.
    """
    # we are locked into supporting overwrite_vars for the Dataset.merge
    # method due for backwards compatibility
    # TODO: consider deprecating it?

    if isinstance(overwrite_vars, Iterable) and not isinstance(overwrite_vars, str):
        overwrite_vars = set(overwrite_vars)
    else:
        overwrite_vars = {overwrite_vars}

    if not overwrite_vars:
        objs = [dataset, other]
        priority_arg = None
    elif overwrite_vars == set(other):
        objs = [dataset, other]
        priority_arg = 1
    else:
        other_overwrite: Dict[Hashable, CoercibleValue] = {}
        other_no_overwrite: Dict[Hashable, CoercibleValue] = {}
        for k, v in other.items():
            if k in overwrite_vars:
                other_overwrite[k] = v
            else:
                other_no_overwrite[k] = v
        objs = [dataset, other_no_overwrite, other_overwrite]
        priority_arg = 2

    return merge_core(
        objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
    )


def dataset_update_method(
    dataset: "Dataset", other: "CoercibleMapping"
) -> _MergeResult:
    """Guts of the Dataset.update method.

    This drops a duplicated coordinates from `other` if `other` is not an
    `xarray.Dataset`, e.g., if it's a dict with DataArray values (GH2068,
    GH2180).
    """
    from .dataarray import DataArray
    from .dataset import Dataset

    if not isinstance(other, Dataset):
        other = dict(other)
        for key, value in other.items():
            if isinstance(value, DataArray):
                # drop conflicting coordinates
                coord_names = [
                    c
                    for c in value.coords
                    if c not in value.dims and c in dataset.coords
                ]
```

**tool result**

```
207:def merge_indexes(
3548:    def merge(
        ValueError
            If any dimensions would have inconsistent sizes in the updated
            dataset.
        """
        _check_inplace(inplace)
        merge_result = dataset_update_method(self, other)
        return self._replace(inplace=True, **merge_result._asdict())

    def merge(
        self,
        other: "CoercibleMapping",
        inplace: bool = None,
        overwrite_vars: Union[Hashable, Iterable[Hashable]] = frozenset(),
        compat: str = "no_conflicts",
        join: str = "outer",
        fill_value: Any = dtypes.NA,
    ) -> "Dataset":
        """Merge the arrays of two datasets into a single dataset.

        This method generally does not allow for overriding data, with the
        exception of attributes, which are ignored on the second dataset.
        Variables with the same name are checked for conflicts via the equals
        or identical methods.

        Parameters
        ----------
        other : Dataset or castable to Dataset
            Dataset or variables to merge with this dataset.
        overwrite_vars : Hashable or iterable of Hashable, optional
            If provided, update variables of these name(s) without checking for
            conflicts in this dataset.
        compat : {'broadcast_equals', 'equals', 'identical',
                  'no_conflicts'}, optional
            String indicating how to compare variables of the same name for
            potential conflicts:

            - 'broadcast_equals': all values must be equal when variables are
              broadcast against each other to ensure common dimensions.
            - 'equals': all values and dimensions must be the same.
            - 'identical': all values, dimensions and attributes must be the
              same.
            - 'no_conflicts': only values which are not null in both datasets
              must be equal. The returned dataset then contains the combination
              of all non-null values.

        join : {'outer', 'inner', 'left', 'right', 'exact'}, optional
            Method for joining ``self`` and ``other`` along shared dimensions:

            - 'outer': use the union of the indexes
            - 'inner': use the intersection of the indexes
            - 'left': use indexes from ``self``
            - 'right': use indexes from ``other``
            - 'exact': error instead of aligning non-equal indexes
        fill_value: scalar, optional
            Value to use for newly missing values

        Returns
        -------
        merged : Dataset
            Merged dataset.

        Raises
        ------
        MergeError
            If any variables conflict (see ``compat``).
        """
        _check_inplace(inplace)
        merge_result = dataset_merge_method(
            self,
            other,
            overwrite_vars=overwrite_vars,
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,80p' xarray/core/merge.py && sed -n '780,840p' xarray/core/merge.py && grep -n \"dataset_merge_method\\|merge(da\\|merge.*DataArray\" xarray/tests/test_merge.py | head -40"
}
```

**tool result**

```
from typing import (
    TYPE_CHECKING,
    AbstractSet,
    Any,
    Dict,
    Hashable,
    Iterable,
    List,
    Mapping,
    NamedTuple,
    Optional,
    Sequence,
    Set,
    Tuple,
    Union,
)

import pandas as pd

from . import dtypes, pdcompat
from .alignment import deep_align
from .duck_array_ops import lazy_array_equiv
from .utils import Frozen, dict_equiv
from .variable import Variable, as_variable, assert_unique_multiindex_level_names

if TYPE_CHECKING:
    from .coordinates import Coordinates
    from .dataarray import DataArray
    from .dataset import Dataset

    DimsLike = Union[Hashable, Sequence[Hashable]]
    ArrayLike = Any
    VariableLike = Union[
        ArrayLike,
        Tuple[DimsLike, ArrayLike],
        Tuple[DimsLike, ArrayLike, Mapping],
        Tuple[DimsLike, ArrayLike, Mapping, Mapping],
    ]
    XarrayValue = Union[DataArray, Variable, VariableLike]
    DatasetLike = Union[Dataset, Mapping[Hashable, XarrayValue]]
    CoercibleValue = Union[XarrayValue, pd.Series, pd.DataFrame]
    CoercibleMapping = Union[Dataset, Mapping[Hashable, CoercibleValue]]


PANDAS_TYPES = (pd.Series, pd.DataFrame, pdcompat.Panel)

_VALID_COMPAT = Frozen(
    {
        "identical": 0,
        "equals": 1,
        "broadcast_equals": 2,
        "minimal": 3,
        "no_conflicts": 4,
        "override": 5,
    }
)


def broadcast_dimension_size(variables: List[Variable],) -> Dict[Hashable, int]:
    """Extract dimension sizes from a dictionary of variables.

    Raises ValueError if any dimensions have different sizes.
    """
    dims: Dict[Hashable, int] = {}
    for var in variables:
        for dim, size in zip(var.dims, var.shape):
            if dim in dims and size != dims[dim]:
                raise ValueError("index %r not aligned" % dim)
            dims[dim] = size
    return dims


class MergeError(ValueError):
    """Error class for merge failures due to incompatible arguments.
    """

    # inherits from ValueError for backward compatibility
    # TODO: move this to an xarray.exceptions module?


    from .dataset import Dataset

    dict_like_objects = list()
    for obj in objects:
        if not isinstance(obj, (DataArray, Dataset, dict)):
            raise TypeError(
                "objects must be an iterable containing only "
                "Dataset(s), DataArray(s), and dictionaries."
            )

        obj = obj.to_dataset() if isinstance(obj, DataArray) else obj
        dict_like_objects.append(obj)

    merge_result = merge_core(dict_like_objects, compat, join, fill_value=fill_value)
    merged = Dataset._construct_direct(**merge_result._asdict())
    return merged


def dataset_merge_method(
    dataset: "Dataset",
    other: "CoercibleMapping",
    overwrite_vars: Union[Hashable, Iterable[Hashable]],
    compat: str,
    join: str,
    fill_value: Any,
) -> _MergeResult:
    """Guts of the Dataset.merge method.
    """
    # we are locked into supporting overwrite_vars for the Dataset.merge
    # method due for backwards compatibility
    # TODO: consider deprecating it?

    if isinstance(overwrite_vars, Iterable) and not isinstance(overwrite_vars, str):
        overwrite_vars = set(overwrite_vars)
    else:
        overwrite_vars = {overwrite_vars}

    if not overwrite_vars:
        objs = [dataset, other]
        priority_arg = None
    elif overwrite_vars == set(other):
        objs = [dataset, other]
        priority_arg = 1
    else:
        other_overwrite: Dict[Hashable, CoercibleValue] = {}
        other_no_overwrite: Dict[Hashable, CoercibleValue] = {}
        for k, v in other.items():
            if k in overwrite_vars:
                other_overwrite[k] = v
            else:
                other_no_overwrite[k] = v
        objs = [dataset, other_no_overwrite, other_overwrite]
        priority_arg = 2

    return merge_core(
        objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
    )


def dataset_update_method(
    dataset: "Dataset", other: "CoercibleMapping"
127:        actual = xr.merge(datasets)
132:        actual = xr.merge(datasets)
148:        actual = data.merge(data)
150:        actual = data.reset_coords(drop=True).merge(data)
152:        actual = data.merge(data.reset_coords(drop=True))
158:            data.reset_coords().merge(data)
160:            data.merge(data.reset_coords())
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"merge.*DataArray\\|DataArray.*merge\" xarray/tests/test_merge.py xarray/tests/test_dataset.py | head -40 && sed -n '100,180p' xarray/tests/test_merge.py"
}
```

**tool result**

```
            xr.merge([ds1, ds3], compat="no_conflicts")

    def test_merge_no_conflicts_multi_var(self):
        data = create_test_data()
        data1 = data.copy(deep=True)
        data2 = data.copy(deep=True)

        expected = data[["var1", "var2"]]
        actual = xr.merge([data1.var1, data2.var2], compat="no_conflicts")
        assert expected.identical(actual)

        data1["var1"][:, :5] = np.nan
        data2["var1"][:, 5:] = np.nan
        data1["var2"][:4, :] = np.nan
        data2["var2"][4:, :] = np.nan
        del data2["var3"]

        actual = xr.merge([data1, data2], compat="no_conflicts")
        assert data.equals(actual)

    def test_merge_no_conflicts_preserve_attrs(self):
        data = xr.Dataset({"x": ([], 0, {"foo": "bar"})})
        actual = xr.merge([data, data])
        assert data.identical(actual)

    def test_merge_no_conflicts_broadcast(self):
        datasets = [xr.Dataset({"x": ("y", [0])}), xr.Dataset({"x": np.nan})]
        actual = xr.merge(datasets)
        expected = xr.Dataset({"x": ("y", [0])})
        assert expected.identical(actual)

        datasets = [xr.Dataset({"x": ("y", [np.nan])}), xr.Dataset({"x": 0})]
        actual = xr.merge(datasets)
        assert expected.identical(actual)


class TestMergeMethod:
    def test_merge(self):
        data = create_test_data()
        ds1 = data[["var1"]]
        ds2 = data[["var3"]]
        expected = data[["var1", "var3"]]
        actual = ds1.merge(ds2)
        assert expected.identical(actual)

        actual = ds2.merge(ds1)
        assert expected.identical(actual)

        actual = data.merge(data)
        assert data.identical(actual)
        actual = data.reset_coords(drop=True).merge(data)
        assert data.identical(actual)
        actual = data.merge(data.reset_coords(drop=True))
        assert data.identical(actual)

        with pytest.raises(ValueError):
            ds1.merge(ds2.rename({"var3": "var1"}))
        with raises_regex(ValueError, "should be coordinates or not"):
            data.reset_coords().merge(data)
        with raises_regex(ValueError, "should be coordinates or not"):
            data.merge(data.reset_coords())

    def test_merge_broadcast_equals(self):
        ds1 = xr.Dataset({"x": 0})
        ds2 = xr.Dataset({"x": ("y", [0, 0])})
        actual = ds1.merge(ds2)
        assert ds2.identical(actual)

        actual = ds2.merge(ds1)
        assert ds2.identical(actual)

        actual = ds1.copy()
        actual.update(ds2)
        assert ds2.identical(actual)

        ds1 = xr.Dataset({"x": np.nan})
        ds2 = xr.Dataset({"x": ("y", [np.nan, np.nan])})
        actual = ds1.merge(ds2)
        assert ds2.identical(actual)

    def test_merge_compat(self):
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/core/merge.py\n@@\n def dataset_merge_method(\n     dataset: \"Dataset\",\n-    other: \"CoercibleMapping\",\n+    other: Union[\"Dataset\", \"DataArray\", \"CoercibleMapping\"],\n     overwrite_vars: Union[Hashable, Iterable[Hashable]],\n     compat: str,\n     join: str,\n     fill_value: Any,\n ) -> _MergeResult:\n     \"\"\"Guts of the Dataset.merge method.\n     \"\"\"\n+    from .dataarray import DataArray\n+\n+    if isinstance(other, DataArray):\n+        other = other.to_dataset()\n+\n     # we are locked into supporting overwrite_vars for the Dataset.merge\n     # method due for backwards compatibility\n     # TODO: consider deprecating it?\n*** Update File: xarray/core/dataset.py\n@@\n     def merge(\n         self,\n-        other: \"CoercibleMapping\",\n+        other: Union[\"Dataset\", \"DataArray\", \"CoercibleMapping\"],\n         inplace: bool = None,\n         overwrite_vars: Union[Hashable, Iterable[Hashable]] = frozenset(),\n         compat: str = \"no_conflicts\",\n@@\n-        other : Dataset or castable to Dataset\n-            Dataset or variables to merge with this dataset.\n+        other : Dataset, DataArray or castable to Dataset\n+            Dataset, DataArray or variables to merge with this dataset.\n*** Update File: xarray/tests/test_merge.py\n@@\n class TestMergeMethod:\n     def test_merge(self):\n         data = create_test_data()\n@@\n         with raises_regex(ValueError, \"should be coordinates or not\"):\n             data.merge(data.reset_coords())\n \n+    def test_merge_dataarray(self):\n+        ds = xr.Dataset({\"a\": 0})\n+        da = xr.DataArray(1, name=\"b\")\n+        expected = xr.merge([ds, da])\n+        actual = ds.merge(da)\n+        assert expected.identical(actual)\n+\n+        # an unnamed DataArray cannot be merged as a variable\n+        with raises_regex(ValueError, \"unable to convert unnamed DataArray\"):\n+            ds.merge(xr.DataArray(1))\n+\n     def test_merge_broadcast_equals(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/core/merge.py xarray/core/dataset.py xarray/tests/test_merge.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/core/merge.py now (869 lines), around the change:
797:
798:def dataset_merge_method(
799:    dataset: "Dataset",
800:    other: Union["Dataset", "DataArray", "CoercibleMapping"],
801:    overwrite_vars: Union[Hashable, Iterable[Hashable]],
802:    compat: str,
803:    join: str,
…
805:) -> _MergeResult:
806:    """Guts of the Dataset.merge method.
807:    """
808:    from .dataarray import DataArray
809:
810:    if isinstance(other, DataArray):
811:        other = other.to_dataset()
812:
813:    # we are locked into supporting overwrite_vars for the Dataset.merge
814:    # method due for backwards compatibility
815:    # TODO: consider deprecating it?

xarray/core/dataset.py now (5700 lines), around the change:
3547:
3548:    def merge(
3549:        self,
3550:        other: Union["Dataset", "DataArray", "CoercibleMapping"],
3551:        inplace: bool = None,
3552:        overwrite_vars: Union[Hashable, Iterable[Hashable]] = frozenset(),
3553:        compat: str = "no_conflicts",
…
3563:
3564:        Parameters
3565:        ----------
3566:        other : Dataset, DataArray or castable to Dataset
3567:            Dataset, DataArray or variables to merge with this dataset.
3568:        overwrite_vars : Hashable or iterable of Hashable, optional
3569:            If provided, update variables of these name(s) without checking for
3570:            conflicts in this dataset.

xarray/tests/test_merge.py now (266 lines), around the change:
159:        with raises_regex(ValueError, "should be coordinates or not"):
160:            data.merge(data.reset_coords())
161:
162:    def test_merge_dataarray(self):
163:        ds = xr.Dataset({"a": 0})
164:        da = xr.DataArray(1, name="b")
165:        expected = xr.merge([ds, da])
166:        actual = ds.merge(da)
167:        assert expected.identical(actual)
168:
169:        # an unnamed DataArray cannot be merged as a variable
170:        with raises_regex(ValueError, "unable to convert unnamed DataArray"):
171:            ds.merge(xr.DataArray(1))
172:
173:    def test_merge_broadcast_equals(self):
174:        ds1 = xr.Dataset({"x": 0})
175:        ds2 = xr.Dataset({"x": ("y", [0, 0])})
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_merge.py::TestMergeMethod -q 2>&1 | tail -30"
}
```

**tool result**

```

xarray/core/dask_array_compat.py:137
xarray/core/dask_array_compat.py:137
  /testbed/xarray/core/dask_array_compat.py:137: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/formatting_html.py:6
  /testbed/xarray/core/formatting_html.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/test_merge.py: 14 warnings
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_merge.py::TestMergeMethod::test_merge_auto_align
xarray/tests/test_merge.py::TestMergeMethod::test_merge_auto_align
xarray/tests/test_merge.py::TestMergeMethod::test_merge_no_conflicts
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
9 passed, 26 warnings in 59.11s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_merge.py -q 2>&1 | tail -5 && python - <<'EOF'\nimport xarray as xr\nds = xr.Dataset({'a': 0})\nda = xr.DataArray(1, name='b')\nprint(ds.merge(da))\nprint(ds.merge(da, overwrite_vars=['a']))\nEOF"
}
```

**tool result**

```
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
22 passed, 30 warnings in 4.02s
<xarray.Dataset>
Dimensions:  ()
Data variables:
    a        int64 0
    b        int64 1
<xarray.Dataset>
Dimensions:  ()
Data variables:
    a        int64 0
    b        int64 1
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataset.py -q -k merge 2>&1 | tail -5 && git diff --stat"
}
```

**tool result**

```
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
3 passed, 870 deselected, 9 warnings in 3.32s
 xarray/core/dataset.py     |  6 +++---
 xarray/core/merge.py       |  7 ++++++-
 xarray/tests/test_merge.py | 11 +++++++++++
 3 files changed, 20 insertions(+), 4 deletions(-)
```

**assistant**

```
Fixed. `Dataset.merge()` now accepts a `DataArray` by converting it to a dataset before merging, matching the behavior of the top-level `xr.merge()`.

Changes:
- `xarray/core/merge.py`: `dataset_merge_method` converts a `DataArray` argument via `to_dataset()` (which raises a clear `ValueError` for unnamed arrays).
- `xarray/core/dataset.py`: updated the `merge` type annotation and docstring to document `DataArray` support.
- `xarray/tests/test_merge.py`: added `test_merge_dataarray` covering the reported case and the unnamed-array error.

Verification: `xarray/tests/test_merge.py` (22 passed) and merge-related `test_dataset.py` tests (3 passed) all pass; the original reproducer now prints the expected dataset. No commits or tree changes beyond the working-tree edits.
```

## Run folder `team-solve-2026-11-06T125852`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
deda502c985dd986597ace798a2340cf9e8381f3
```

### `baseline-check.log`

```
check: python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q
........................................................................ [  8%]
...................................xX........F.......................... [ 16%]
........................................................................ [ 24%]
........................................................................ [ 32%]
.............F.......................................................... [ 40%]
........................................................................ [ 48%]
........................................................................ [ 56%]
....................................................ssssssssssssssss.... [ 64%]
........................................................................ [ 72%]
........................................................................ [ 80%]
........................................................................ [ 88%]
........................................................................ [ 96%]
...................FF....FF...                                           [100%]
=================================== FAILURES ===================================
___________ TestDataset.test_rename_does_not_change_CFTimeIndex_type ___________

self = <xarray.tests.test_dataset.TestDataset object at 0x7c3423460ac0>

    @requires_cftime
    def test_rename_does_not_change_CFTimeIndex_type(self):
        # make sure CFTimeIndex is not converted to DatetimeIndex #3522
    
        time = xr.cftime_range(start="2000", periods=6, freq="2MS", calendar="noleap")
>       orig = Dataset(coords={"time": time})

xarray/tests/test_dataset.py:2480: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataset.py:547: in __init__
    variables, coord_names, dims, indexes = merge_data_and_coords(
xarray/core/merge.py:465: in merge_data_and_coords
    indexes = dict(_extract_indexes_from_coords(coords))
xarray/core/merge.py:476: in _extract_indexes_from_coords
    yield name, variable.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-03-01 00:00:00, 2000-05-01 00:00:00,
             2000-07-01 00:00:00, 2000-09-01 00:00:00, 2000-11-01 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
        times = xr.cftime_range("2000", periods=6)
>       da = xr.DataArray(range(6), [("time", times)])

xarray/tests/test_dataset.py:5566: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-02 00:00:00, 2000-01-03 00:00:00,
             2000-01-04 00:00:00, 2000-01-05 00:00:00, 2000-01-06 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
=============================== warnings summary ===============================
xarray/core/dask_array_compat.py:13
xarray/core/dask_array_compat.py:13
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/dask_array_compat.py:13: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:100
xarray/core/dask_array_compat.py:100
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/dask_array_compat.py:100: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:137
xarray/core/dask_array_compat.py:137
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/dask_array_compat.py:137: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/formatting_html.py:6
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/formatting_html.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/pdcompat.py:45
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/test_merge.py: 17 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/alignment.py:298: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_merge.py: 4 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/alignment.py:298: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataset.py: 349 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/formatting.py:142: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/tests/__init__.py:55: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/merge.py:393: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = dict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/variable.py:986: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) < "2.0.0":

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/indexing.py:179: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    indexer = index.get_loc(

xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataset.py: 12 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/coding/cftimeindex.py:112: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py: 54 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/coding/cftime_offsets.py:243: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/tests/test_dataset.py:2824: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds.unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/tests/test_dataset.py:2825: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    assert actual["var"].dtype == np.int

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/tests/test_dataset.py:2829: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds["var"].unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataset.py: 11 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/common.py:1044: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py: 11 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/groupby.py:347: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/common.py:1044: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/tests/test_dataset.py:3656: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    ds.bar.to_series().resample("24H", loffset="-12H").mean()

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/missing.py:535: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method="nearest")

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/missing.py:536: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method="nearest")

xarray/tests/test_dataset.py: 63 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/core/variable.py:1751: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    return np.moveaxis(np.nanpercentile(npa, **kwargs), 0, -1)

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/.memdoor/runs/team-solve-2026-11-06T125852/baseline-tree/xarray/tests/test_dataset.py:5558: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={"time": pd.date_range("15/12/1999", periods=364)},

xarray/tests/test_dataset.py::test_trapz_datetime[np-True]
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/array/core.py:1706: FutureWarning: The `numpy.trapz` function is not implemented by Dask array. You may want to use the da.map_blocks function or something similar to silence this warning. Your code may stop working in a future release.
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_rename_does_not_change_CFTimeIndex_type
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - AttributeEr...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - Attrib...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Attr...
6 failed, 870 passed, 16 skipped, 1 xfailed, 1 xpassed, 586 warnings in 21.62s
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/xarray/core/dataset.py b/xarray/core/dataset.py
index ac0a923d..b7156937 100644
--- a/xarray/core/dataset.py
+++ b/xarray/core/dataset.py
@@ -3547,7 +3547,7 @@ class Dataset(Mapping, ImplementsDatasetReduce, DataWithCoords):
 
     def merge(
         self,
-        other: "CoercibleMapping",
+        other: Union["Dataset", "DataArray", "CoercibleMapping"],
         inplace: bool = None,
         overwrite_vars: Union[Hashable, Iterable[Hashable]] = frozenset(),
         compat: str = "no_conflicts",
@@ -3563,8 +3563,8 @@ class Dataset(Mapping, ImplementsDatasetReduce, DataWithCoords):
 
         Parameters
         ----------
-        other : Dataset or castable to Dataset
-            Dataset or variables to merge with this dataset.
+        other : Dataset, DataArray or castable to Dataset
+            Dataset, DataArray or variables to merge with this dataset.
         overwrite_vars : Hashable or iterable of Hashable, optional
             If provided, update variables of these name(s) without checking for
             conflicts in this dataset.
diff --git a/xarray/core/merge.py b/xarray/core/merge.py
index 10c7804d..e2eae24c 100644
--- a/xarray/core/merge.py
+++ b/xarray/core/merge.py
@@ -797,7 +797,7 @@ def merge(
 
 def dataset_merge_method(
     dataset: "Dataset",
-    other: "CoercibleMapping",
+    other: Union["Dataset", "DataArray", "CoercibleMapping"],
     overwrite_vars: Union[Hashable, Iterable[Hashable]],
     compat: str,
     join: str,
@@ -805,6 +805,11 @@ def dataset_merge_method(
 ) -> _MergeResult:
     """Guts of the Dataset.merge method.
     """
+    from .dataarray import DataArray
+
+    if isinstance(other, DataArray):
+        other = other.to_dataset()
+
     # we are locked into supporting overwrite_vars for the Dataset.merge
     # method due for backwards compatibility
     # TODO: consider deprecating it?
diff --git a/xarray/tests/test_merge.py b/xarray/tests/test_merge.py
index c1e6c7a5..55332ca4 100644
--- a/xarray/tests/test_merge.py
+++ b/xarray/tests/test_merge.py
@@ -159,6 +159,17 @@ class TestMergeMethod:
         with raises_regex(ValueError, "should be coordinates or not"):
             data.merge(data.reset_coords())
 
+    def test_merge_dataarray(self):
+        ds = xr.Dataset({"a": 0})
+        da = xr.DataArray(1, name="b")
+        expected = xr.merge([ds, da])
+        actual = ds.merge(da)
+        assert expected.identical(actual)
+
+        # an unnamed DataArray cannot be merged as a variable
+        with raises_regex(ValueError, "unable to convert unnamed DataArray"):
+            ds.merge(xr.DataArray(1))
+
     def test_merge_broadcast_equals(self):
         ds1 = xr.Dataset({"x": 0})
         ds2 = xr.Dataset({"x": ("y", [0, 0])})
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

Merging dataArray into dataset using dataset method fails
While it's possible to merge a dataset and a dataarray object using the top-level `merge()` function, if you try the same thing with the `ds.merge()` method it fails.

```python
import xarray as xr

ds = xr.Dataset({'a': 0})
da = xr.DataArray(1, name='b')

expected = xr.merge([ds, da])  # works fine
print(expected)

ds.merge(da)  # fails
```

Output:
```
<xarray.Dataset>
Dimensions:  ()
Data variables:
    a        int64 0
    b        int64 1

Traceback (most recent call last):
  File "mwe.py", line 6, in <module>
    actual = ds.merge(da)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/dataset.py", line 3591, in merge
    fill_value=fill_value,
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 835, in dataset_merge_method
    objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 548, in merge_core
    coerced = coerce_pandas_values(objects)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 394, in coerce_pandas_values
    for k, v in obj.items():
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/common.py", line 233, in __getattr__
    "{!r} object has no attribute {!r}".format(type(self).__name__, name)
AttributeError: 'DataArray' object has no attribute 'items'
```

## Deliverable

changes to this tree

## Check

`python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q`

## Scope

`xarray/core/merge.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when

`ds.merge(da)` with a named `DataArray` no longer raises `AttributeError: 'DataArray' object has no attribute 'items'`.
The result of `ds.merge(da)` is identical to `xr.merge([ds, da])` for the prompt’s example, containing both `a` and `b`.
Existing `Dataset.merge` and top-level `merge` behavior for mappings and `Dataset` inputs still passes the merge tests.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q`

## Scope
`xarray/core/merge.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when
`ds.merge(da)` with a named `DataArray` no longer raises `AttributeError: 'DataArray' object has no attribute 'items'`.
The result of `ds.merge(da)` is identical to `xr.merge([ds, da])` for the prompt’s example, containing both `a` and `b`.
Existing `Dataset.merge` and top-level `merge` behavior for mappings and `Dataset` inputs still passes the merge tests.

## Approach
Work is in `dataset_merge_method` in `xarray/core/merge.py`: unlike top-level `merge`, it passes `other` straight into `merge_core`, so a `DataArray` reaches `coerce_pandas_values`, which calls `.items()`. Normalize a `DataArray` argument before building the merge objects, mirroring top-level `merge`’s conversion of a `DataArray` into a one-entry mapping.

Candidate approaches:
1. Normalize `other` at the top of `dataset_merge_method`: `if isinstance(other, DataArray): other = {other.name: other}`. Smallest change, mirrors top-level `merge`, and covers all `overwrite_vars` branches; requires a local import to avoid the circular import.
2. Convert in `Dataset.merge` in `xarray/core/dataset.py` before calling `dataset_merge_method`. Equally small and keeps merge.py unchanged, but puts normalization in the method layer rather than in the shared merge logic.
3. Teach `coerce_pandas_values` and `collect_variables_and_indexes` to pass through or convert `DataArray` natively. More invasive and risks changing alignment, priority, and attribute handling; do this only if normalization alone fails on some `overwrite_vars` path.

If option 1 breaks the `overwrite_vars` branch because that branch assumes `other` is a `Dataset`, convert with `other.to_dataset()` inside that branch only, or normalize at the point where `objs` is passed to `merge_core`. Then reproduce the MWE and run the scoped tests.


# xarray/core/merge.py

```
from typing import (
    TYPE_CHECKING,
    AbstractSet,
    Any,
    Dict,
    Hashable,
    Iterable,
    List,
    Mapping,
    NamedTuple,
    Optional,
    Sequence,
    Set,
    Tuple,
    Union,
)

import pandas as pd

from . import dtypes, pdcompat
from .alignment import deep_align
from .duck_array_ops import lazy_array_equiv
from .utils import Frozen, dict_equiv
from .variable import Variable, as_variable, assert_unique_multiindex_level_names

if TYPE_CHECKING:
    from .coordinates import Coordinates
    from .dataarray import DataArray
    from .dataset import Dataset

    DimsLike = Union[Hashable, Sequence[Hashable]]
    ArrayLike = Any
    VariableLike = Union[
        ArrayLike,
        Tuple[DimsLike, ArrayLike],
        Tuple[DimsLike, ArrayLike, Mapping],
        Tuple[DimsLike, ArrayLike, Mapping, Mapping],
    ]
    XarrayValue = Union[DataArray, Variable, VariableLike]
    DatasetLike = Union[Dataset, Mapping[Hashable, XarrayValue]]
    CoercibleValue = Union[XarrayValue, pd.Series, pd.DataFrame]
    CoercibleMapping = Union[Dataset, Mapping[Hashable, CoercibleValue]]


PANDAS_TYPES = (pd.Series, pd.DataFrame, pdcompat.Panel)

_VALID_COMPAT = Frozen(
    {
        "identical": 0,
        "equals": 1,
        "broadcast_equals": 2,
        "minimal": 3,
        "no_conflicts": 4,
        "override": 5,
    }
)


def broadcast_dimension_size(variables: List[Variable],) -> Dict[Hashable, int]:
    """Extract dimension sizes from a dictionary of variables.

    Raises ValueError if any dimensions have different sizes.
    """
    dims: Dict[Hashable, int] = {}
    for var in variables:
        for dim, size in zip(var.dims, var.shape):
            if dim in dims and size != dims[dim]:
                raise ValueError("index %r not aligned" % dim)
            dims[dim] = size
    return dims


class MergeError(ValueError):
    """Error class for merge failures due to incompatible arguments.
    """

    # inherits from ValueError for backward compatibility
    # TODO: move this to an xarray.exceptions module?


def unique_variable(
    name: Hashable,
    variables: List[Variable],
    compat: str = "broadcast_equals",
    equals: bool = None,
) -> Variable:
    """Return the unique variable from a list of variables or raise MergeError.

    Parameters
    ----------
    name : hashable
        Name for this variable.
    variables : list of xarray.Variable
        List of Variable objects, all of which go by the same name in different
        inputs.
    compat : {'identical', 'equals', 'broadcast_equals', 'no_conflicts', 'override'}, optional
        Type of equality check to use.
    equals: None or bool,
        corresponding to result of compat test

    Returns
    -------
    Variable to use in the result.

    Raises
    ------
    MergeError: if any of the variables are not equal.
    """
    out = variables[0]

    if len(variables) == 1 or compat == "override":
        return out

    combine_method = None

    if compat == "minimal":
        compat = "broadcast_equals"

    if compat == "broadcast_equals":
        dim_lengths = broadcast_dimension_size(variables)
        out = out.set_dims(dim_lengths)

    if compat == "no_conflicts":
        combine_method = "fillna"

    if equals is None:
        # first check without comparing values i.e. no computes
        for var in variables[1:]:
            equals = getattr(out, compat)(var, equiv=lazy_array_equiv)
            if equals is not True:
                break

        if equals is None:
            # now compare values with minimum number of computes
            out = out.compute()
            for var in variables[1:]:
                equals = getattr(out, compat)(var)
                if not equals:
                    break

    if not equals:
        raise MergeError(
            f"conflicting values for variable {name!r} on objects to be combined. "
            "You can skip this check by specifying compat='override'."
        )

    if combine_method:
        for var in variables[1:]:
            out = getattr(out, combine_method)(var)

    return out


def _assert_compat_valid(compat):
    if compat not in _VALID_COMPAT:
        raise ValueError(
            "compat={!r} invalid: must be {}".format(compat, set(_VALID_COMPAT))
        )


MergeElement = Tuple[Variable, Optional[pd.Index]]


def merge_collected(
    grouped: Dict[Hashable, List[MergeElement]],
    prioritized: Mapping[Hashable, MergeElement] = None,
    compat: str = "minimal",
) -> Tuple[Dict[Hashable, Variable], Dict[Hashable, pd.Index]]:
    """Merge dicts of variables, while resolving conflicts appropriately.

    Parameters
    ----------

        Type of equality check to use when checking for conflicts.

    Returns
    -------
    Dict with keys taken by the union of keys on list_of_mappings,
    and Variable values corresponding to those that should be found on the
    merged result.
    """
    if prioritized is None:
        prioritized = {}

    _assert_compat_valid(compat)

    merged_vars: Dict[Hashable, Variable] = {}
    merged_indexes: Dict[Hashable, pd.Index] = {}

    for name, elements_list in grouped.items():
        if name in prioritized:
            variable, index = prioritized[name]
            merged_vars[name] = variable
            if index is not None:
                merged_indexes[name] = index
        else:
            indexed_elements = [
                (variable, index)
                for variable, index in elements_list
                if index is not None
            ]

            if indexed_elements:
                # TODO(shoyer): consider adjusting this logic. Are we really
                # OK throwing away variable without an index in favor of
                # indexed variables, without even checking if values match?
                variable, index = indexed_elements[0]
                for _, other_index in indexed_elements[1:]:
                    if not index.equals(other_index):
                        raise MergeError(
                            "conflicting values for index %r on objects to be "
                            "combined:\nfirst value: %r\nsecond value: %r"
                            % (name, index, other_index)
                        )
                if compat == "identical":
                    for other_variable, _ in indexed_elements[1:]:
                        if not dict_equiv(variable.attrs, other_variable.attrs):
                            raise MergeError(
                                "conflicting attribute values on combined "
                                "variable %r:\nfirst value: %r\nsecond value: %r"
                                % (name, variable.attrs, other_variable.attrs)
                            )
                merged_vars[name] = variable
                merged_indexes[name] = index
            else:
                variables = [variable for variable, _ in elements_list]
                try:
                    merged_vars[name] = unique_variable(name, variables, compat)
                except MergeError:
                    if compat != "minimal":
                        # we need more than "minimal" compatibility (for which
                        # we drop conflicting coordinates)
                        raise

    return merged_vars, merged_indexes


def collect_variables_and_indexes(
    list_of_mappings: "List[DatasetLike]",
) -> Dict[Hashable, List[MergeElement]]:
    """Collect variables and indexes from list of mappings of xarray objects.

    Mappings must either be Dataset objects, or have values of one of the
    following types:
    - an xarray.Variable
    - a tuple `(dims, data[, attrs[, encoding]])` that can be converted in
      an xarray.Variable
    - or an xarray.DataArray
    """
    from .dataarray import DataArray
    from .dataset import Dataset

    grouped: Dict[Hashable, List[Tuple[Variable, pd.Index]]] = {}

    def append(name, variable, index):
        values = grouped.setdefault(name, [])
        values.append((variable, index))

    def append_all(variables, indexes):
        for name, variable in variables.items():
            append(name, variable, indexes.get(name))

    for mapping in list_of_mappings:
        if isinstance(mapping, Dataset):
            append_all(mapping.variables, mapping.indexes)
            continue

        for name, variable in mapping.items():
            if isinstance(variable, DataArray):
                coords = variable._coords.copy()  # use private API for speed
                indexes = dict(variable.indexes)
                # explicitly overwritten variables should take precedence
                coords.pop(name, None)
                indexes.pop(name, None)
                append_all(coords, indexes)

            variable = as_variable(variable, name=name)
            if variable.dims == (name,):
                variable = variable.to_index_variable()
                index = variable.to_index()
            else:
                index = None
            append(name, variable, index)

    return grouped


def collect_from_coordinates(
    list_of_coords: "List[Coordinates]",
) -> Dict[Hashable, List[MergeElement]]:
    """Collect variables and indexes to be merged from Coordinate objects."""
    grouped: Dict[Hashable, List[Tuple[Variable, pd.Index]]] = {}

    for coords in list_of_coords:
        variables = coords.variables
        indexes = coords.indexes
        for name, variable in variables.items():
            value = grouped.setdefault(name, [])
            value.append((variable, indexes.get(name)))
    return grouped


def merge_coordinates_without_align(
    objects: "List[Coordinates]",
    prioritized: Mapping[Hashable, MergeElement] = None,
    exclude_dims: AbstractSet = frozenset(),
) -> Tuple[Dict[Hashable, Variable], Dict[Hashable, pd.Index]]:
    """Merge variables/indexes from coordinates without automatic alignments.

    This function is used for merging coordinate from pre-existing xarray
    objects.
    """
    collected = collect_from_coordinates(objects)

    if exclude_dims:
        filtered: Dict[Hashable, List[MergeElement]] = {}
        for name, elements in collected.items():
            new_elements = [
                (variable, index)
                for variable, index in elements
                if exclude_dims.isdisjoint(variable.dims)
            ]
            if new_elements:
                filtered[name] = new_elements
    else:
        filtered = collected

    return merge_collected(filtered, prioritized)


def determine_coords(
    list_of_mappings: Iterable["DatasetLike"],
) -> Tuple[Set[Hashable], Set[Hashable]]:
    """Given a list of dicts with xarray object values, identify coordinates.

    Parameters
    ----------
    list_of_mappings : list of dict or Dataset objects
        Of the same form as the arguments to expand_variable_dicts.

    Returns
    -------
    coord_names : set of variable names
    noncoord_names : set of variable names
        All variable found in the input should appear in either the set of
        coordinate or non-coordinate names.
    """
    from .dataarray import DataArray
    from .dataset import Dataset

    coord_names: Set[Hashable] = set()
    noncoord_names: Set[Hashable] = set()

    for mapping in list_of_mappings:
        if isinstance(mapping, Dataset):
            coord_names.update(mapping.coords)
            noncoord_names.update(mapping.data_vars)
        else:
            for name, var in mapping.items():
                if isinstance(var, DataArray):
                    coords = set(var._coords)  # use private API for speed
                    # explicitly overwritten variables should take precedence
                    coords.discard(name)
                    coord_names.update(coords)

    return coord_names, noncoord_names


def coerce_pandas_values(objects: Iterable["CoercibleMapping"]) -> List["DatasetLike"]:
    """Convert pandas values found in a list of labeled objects.

    Parameters
    ----------
    objects : list of Dataset or mappings
        The mappings may contain any sort of objects coercible to
        xarray.Variables as keys, including pandas objects.

    Returns
    -------
    List of Dataset or dictionary objects. Any inputs or values in the inputs
    that were pandas objects have been converted into native xarray objects.
    """
    from .dataarray import DataArray
    from .dataset import Dataset

    out = []
    for obj in objects:
        if isinstance(obj, Dataset):
            variables: "DatasetLike" = obj
        else:
            variables = {}
            if isinstance(obj, PANDAS_TYPES):
                obj = dict(obj.iteritems())
            for k, v in obj.items():
                if isinstance(v, PANDAS_TYPES):
                    v = DataArray(v)
                variables[k] = v
        out.append(variables)
    return out


def _get_priority_vars_and_indexes(
    objects: List["DatasetLike"], priority_arg: Optional[int], compat: str = "equals"
) -> Dict[Hashable, MergeElement]:
    """Extract the priority variable from a list of mappings.

    We need this method because in some cases the priority argument itself
    might have conflicting values (e.g., if it is a dict with two DataArray
    values with conflicting coordinate values).

    Parameters
    ----------
    objects : list of dictionaries of variables
        Dictionaries in which to find the priority variables.
    priority_arg : int or None
        Integer object whose variable should take priority.
    compat : {'identical', 'equals', 'broadcast_equals', 'no_conflicts'}, optional
        Compatibility checks to use when merging variables.

    Returns
    -------
    A dictionary of variables and associated indexes (if any) to prioritize.
    """
    if priority_arg is None:
        return {}

    collected = collect_variables_and_indexes([objects[priority_arg]])
    variables, indexes = merge_collected(collected, compat=compat)
    grouped: Dict[Hashable, MergeElement] = {}
    for name, variable in variables.items():
        grouped[name] = (variable, indexes.get(name))
    return grouped


def merge_coords(
    objects: Iterable["CoercibleMapping"],
    compat: str = "minimal",
    join: str = "outer",
    priority_arg: Optional[int] = None,
    indexes: Optional[Mapping[Hashable, pd.Index]] = None,
    fill_value: object = dtypes.NA,
) -> Tuple[Dict[Hashable, Variable], Dict[Hashable, pd.Index]]:
    """Merge coordinate variables.

    See merge_core below for argument descriptions. This works similarly to
    merge_core, except everything we don't worry about whether variables are
    coordinates or not.
    """
    _assert_compat_valid(compat)
    coerced = coerce_pandas_values(objects)
    aligned = deep_align(
        coerced, join=join, copy=False, indexes=indexes, fill_value=fill_value
    )
    collected = collect_variables_and_indexes(aligned)
    prioritized = _get_priority_vars_and_indexes(aligned, priority_arg, compat=compat)
    variables, out_indexes = merge_collected(collected, prioritized, compat=compat)
    assert_unique_multiindex_level_names(variables)
    return variables, out_indexes


def merge_data_and_coords(data, coords, compat="broadcast_equals", join="outer"):
    """Used in Dataset.__init__."""
    objects = [data, coords]
    explicit_coords = coords.keys()
    indexes = dict(_extract_indexes_from_coords(coords))
    return merge_core(
        objects, compat, join, explicit_coords=explicit_coords, indexes=indexes
    )


def _extract_indexes_from_coords(coords):
    """Yields the name & index of valid indexes from a mapping of coords"""
    for name, variable in coords.items():
        variable = as_variable(variable, name=name)
        if variable.dims == (name,):
            yield name, variable.to_index()


def assert_valid_explicit_coords(variables, dims, explicit_coords):
    """Validate explicit coordinate names/dims.

    Raise a MergeError if an explicit coord shares a name with a dimension
    but is comprised of arbitrary dimensions.
    """
    for coord_name in explicit_coords:
        if coord_name in dims and variables[coord_name].dims != (coord_name,):
            raise MergeError(
                "coordinate %s shares a name with a dataset dimension, but is "
                "not a 1D variable along that dimension. This is disallowed "
                "by the xarray data model." % coord_name
            )


class _MergeResult(NamedTuple):
    variables: Dict[Hashable, Variable]
    coord_names: Set[Hashable]
    dims: Dict[Hashable, int]
    indexes: Dict[Hashable, pd.Index]


def merge_core(
    objects: Iterable["CoercibleMapping"],
    compat: str = "broadcast_equals",
    join: str = "outer",
    priority_arg: Optional[int] = None,
    explicit_coords: Optional[Sequence] = None,
    indexes: Optional[Mapping[Hashable, pd.Index]] = None,
    fill_value: object = dtypes.NA,
) -> _MergeResult:
    """Core logic for merging labeled objects.

    This is not public API.

    Parameters
    ----------
    objects : list of mappings
        All values must be convertable to labeled arrays.
    compat : {'identical', 'equals', 'broadcast_equals', 'no_conflicts', 'override'}, optional
        Compatibility checks to use when merging variables.
    join : {'outer', 'inner', 'left', 'right'}, optional
        How to combine objects with different indexes.
    priority_arg : integer, optional
        Optional argument in `objects` that takes precedence over the others.
    explicit_coords : set, optional
        An explicit list of variables from `objects` that are coordinates.
    indexes : dict, optional
        Dictionary with values given by pandas.Index objects.
    fill_value : scalar, optional
        Value to use for newly missing values

    Returns
    -------
    variables : dict
        Dictionary of Variable objects.
    coord_names : set
        Set of coordinate names.
    dims : dict
        Dictionary mapping from dimension names to sizes.

    Raises
    ------
    MergeError if the merge cannot be done successfully.
    """
    from .dataset import calculate_dimensions

    _assert_compat_valid(compat)

    coerced = coerce_pandas_values(objects)
    aligned = deep_align(
        coerced, join=join, copy=False, indexes=indexes, fill_value=fill_value
    )
    collected = collect_variables_and_indexes(aligned)

    prioritized = _get_priority_vars_and_indexes(aligned, priority_arg, compat=compat)
    variables, out_indexes = merge_collected(collected, prioritized, compat=compat)
    assert_unique_multiindex_level_names(variables)

    dims = calculate_dimensions(variables)

    coord_names, noncoord_names = determine_coords(coerced)
    if explicit_coords is not None:
        assert_valid_explicit_coords(variables, dims, explicit_coords)
        coord_names.update(explicit_coords)
    for dim, size in dims.items():
        if dim in variables:
            coord_names.add(dim)
    ambiguous_coords = coord_names.intersection(noncoord_names)
    if ambiguous_coords:
        raise MergeError(
            "unable to determine if these variables should be "
            "coordinates or not in the merged result: %s" % ambiguous_coords
        )

    return _MergeResult(variables, coord_names, dims, out_indexes)


def merge(
    objects: Iterable[Union["DataArray", "CoercibleMapping"]],
    compat: str = "no_conflicts",
    join: str = "outer",
    fill_value: object = dtypes.NA,
) -> "Dataset":
    """Merge any number of xarray objects into a single Dataset as variables.

    Parameters
    ----------
    objects : Iterable[Union[xarray.Dataset, xarray.DataArray, dict]]
        Merge together all variables from these objects. If any of them are
        DataArray objects, they must have a name.
    compat : {'identical', 'equals', 'broadcast_equals', 'no_conflicts', 'override'}, optional
        String indicating how to compare variables of the same name for
        potential conflicts:

        - 'broadcast_equals': all values must be equal when variables are
          broadcast against each other to ensure common dimensions.
        - 'equals': all values and dimensions must be the same.
        - 'identical': all values, dimensions and attributes must be the
          same.
        - 'no_conflicts': only values which are not null in both datasets
          must be equal. The returned dataset then contains the combination
          of all non-null values.
        - 'override': skip comparing and pick variable from first dataset
    join : {'outer', 'inner', 'left', 'right', 'exact'}, optional
        String indicating how to combine differing indexes in objects.

        - 'outer': use the union of object indexes
        - 'inner': use the intersection of object indexes
        - 'left': use indexes from the first object with each dimension
        - 'right': use indexes from the last object with each dimension
        - 'exact': instead of aligning, raise `ValueError` when indexes to be
          aligned are not equal
        - 'override': if indexes are of same size, rewrite indexes to be
          those of the first object with that dimension. Indexes for the same
          dimension must have the same size in all objects.
    fill_value : scalar, optional
        Value to use for newly missing values

    Returns
    -------
    Dataset
        Dataset with combined variables from each object.

    Examples
    --------
    >>> import xarray as xr
    >>> x = xr.DataArray(
    ...     [[1.0, 2.0], [3.0, 5.0]],
    ...     dims=("lat", "lon"),
    ...     coords={"lat": [35.0, 40.0], "lon": [100.0, 120.0]},
    ...     name="var1",
    ... )
    >>> y = xr.DataArray(
    ...     [[5.0, 6.0], [7.0, 8.0]],
    ...     dims=("lat", "lon"),
    ...     coords={"lat": [35.0, 42.0], "lon": [100.0, 150.0]},
    ...     name="var2",
    ... )
    >>> z = xr.DataArray(
    ...     [[0.0, 3.0], [4.0, 9.0]],
    ...     dims=("time", "lon"),
    ...     coords={"time": [30.0, 60.0], "lon": [100.0, 150.0]},
    ...     name="var3",
    ... )

    >>> x
    <xarray.DataArray 'var1' (lat: 2, lon: 2)>
    array([[1., 2.],
           [3., 5.]])
    Coordinates:
    * lat      (lat) float64 35.0 40.0
    * lon      (lon) float64 100.0 120.0

    >>> y
    <xarray.DataArray 'var2' (lat: 2, lon: 2)>
    array([[5., 6.],
           [7., 8.]])
    Coordinates:
    * lat      (lat) float64 35.0 42.0
    * lon      (lon) float64 100.0 150.0

    >>> z
    <xarray.DataArray 'var3' (time: 2, lon: 2)>
    array([[0., 3.],
           [4., 9.]])
    Coordinates:
    * time     (time) float64 30.0 60.0
    * lon      (lon) float64 100.0 150.0

    >>> xr.merge([x, y, z])
    <xarray.Dataset>
    Dimensions:  (lat: 3, lon: 3, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0 40.0 42.0
    * lon      (lon) float64 100.0 120.0 150.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0 2.0 nan 3.0 5.0 nan nan nan nan
        var2     (lat, lon) float64 5.0 nan 6.0 nan nan nan 7.0 nan 8.0
        var3     (time, lon) float64 0.0 nan 3.0 4.0 nan 9.0

    >>> xr.merge([x, y, z], compat='identical')
    <xarray.Dataset>
    Dimensions:  (lat: 3, lon: 3, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0 40.0 42.0
    * lon      (lon) float64 100.0 120.0 150.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0 2.0 nan 3.0 5.0 nan nan nan nan
        var2     (lat, lon) float64 5.0 nan 6.0 nan nan nan 7.0 nan 8.0
        var3     (time, lon) float64 0.0 nan 3.0 4.0 nan 9.0

    >>> xr.merge([x, y, z], compat='equals')
    <xarray.Dataset>
    Dimensions:  (lat: 3, lon: 3, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0 40.0 42.0
    * lon      (lon) float64 100.0 120.0 150.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0 2.0 nan 3.0 5.0 nan nan nan nan
        var2     (lat, lon) float64 5.0 nan 6.0 nan nan nan 7.0 nan 8.0
        var3     (time, lon) float64 0.0 nan 3.0 4.0 nan 9.0

    >>> xr.merge([x, y, z], compat='equals', fill_value=-999.)
    <xarray.Dataset>
    Dimensions:  (lat: 3, lon: 3, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0 40.0 42.0
    * lon      (lon) float64 100.0 120.0 150.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0 2.0 -999.0 3.0 ... -999.0 -999.0 -999.0
        var2     (lat, lon) float64 5.0 -999.0 6.0 -999.0 ... -999.0 7.0 -999.0 8.0
        var3     (time, lon) float64 0.0 -999.0 3.0 4.0 -999.0 9.0

    >>> xr.merge([x, y, z], join='override')
    <xarray.Dataset>
    Dimensions:  (lat: 2, lon: 2, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0 40.0
    * lon      (lon) float64 100.0 120.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0 2.0 3.0 5.0
        var2     (lat, lon) float64 5.0 6.0 7.0 8.0
        var3     (time, lon) float64 0.0 3.0 4.0 9.0

    >>> xr.merge([x, y, z], join='inner')
    <xarray.Dataset>
    Dimensions:  (lat: 1, lon: 1, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0
    * lon      (lon) float64 100.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0
        var2     (lat, lon) float64 5.0
        var3     (time, lon) float64 0.0 4.0

    >>> xr.merge([x, y, z], compat='identical', join='inner')
    <xarray.Dataset>
    Dimensions:  (lat: 1, lon: 1, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0
    * lon      (lon) float64 100.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0
        var2     (lat, lon) float64 5.0
        var3     (time, lon) float64 0.0 4.0

    >>> xr.merge([x, y, z], compat='broadcast_equals', join='outer')
    <xarray.Dataset>
    Dimensions:  (lat: 3, lon: 3, time: 2)
    Coordinates:
    * lat      (lat) float64 35.0 40.0 42.0
    * lon      (lon) float64 100.0 120.0 150.0
    * time     (time) float64 30.0 60.0
    Data variables:
        var1     (lat, lon) float64 1.0 2.0 nan 3.0 5.0 nan nan nan nan
        var2     (lat, lon) float64 5.0 nan 6.0 nan nan nan 7.0 nan 8.0
        var3     (time, lon) float64 0.0 nan 3.0 4.0 nan 9.0

    >>> xr.merge([x, y, z], join='exact')
    Traceback (most recent call last):
    ...
    ValueError: indexes along dimension 'lat' are not equal

    Raises
    ------
    xarray.MergeError
        If any variables with the same name have conflicting values.

    See also
    --------
    concat
    """
    from .dataarray import DataArray
    from .dataset import Dataset

    dict_like_objects = list()
    for obj in objects:
        if not isinstance(obj, (DataArray, Dataset, dict)):
            raise TypeError(
                "objects must be an iterable containing only "
                "Dataset(s), DataArray(s), and dictionaries."
            )

        obj = obj.to_dataset() if isinstance(obj, DataArray) else obj
        dict_like_objects.append(obj)

    merge_result = merge_core(dict_like_objects, compat, join, fill_value=fill_value)
    merged = Dataset._construct_direct(**merge_result._asdict())
    return merged


def dataset_merge_method(
    dataset: "Dataset",
    other: Union["Dataset", "DataArray", "CoercibleMapping"],
    overwrite_vars: Union[Hashable, Iterable[Hashable]],
    compat: str,
    join: str,
    fill_value: Any,
) -> _MergeResult:
    """Guts of the Dataset.merge method.
    """
    from .dataarray import DataArray

    if isinstance(other, DataArray):
        other = other.to_dataset()

    # we are locked into supporting overwrite_vars for the Dataset.merge
    # method due for backwards compatibility
    # TODO: consider deprecating it?

    if isinstance(overwrite_vars, Iterable) and not isinstance(overwrite_vars, str):
        overwrite_vars = set(overwrite_vars)
    else:
        overwrite_vars = {overwrite_vars}

    if not overwrite_vars:
        objs = [dataset, other]
        priority_arg = None
    elif overwrite_vars == set(other):
        objs = [dataset, other]
        priority_arg = 1
    else:
        other_overwrite: Dict[Hashable, CoercibleValue] = {}
        other_no_overwrite: Dict[Hashable, CoercibleValue] = {}
        for k, v in other.items():
            if k in overwrite_vars:
                other_overwrite[k] = v
            else:
                other_no_overwrite[k] = v
        objs = [dataset, other_no_overwrite, other_overwrite]
        priority_arg = 2

    return merge_core(
        objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
    )


def dataset_update_method(
    dataset: "Dataset", other: "CoercibleMapping"
) -> _MergeResult:
    """Guts of the Dataset.update method.

    This drops a duplicated coordinates from `other` if `other` is not an
    `xarray.Dataset`, e.g., if it's a dict with DataArray values (GH2068,
    GH2180).
    """
    from .dataarray import DataArray
    from .dataset import Dataset

    if not isinstance(other, Dataset):
        other = dict(other)
        for key, value in other.items():
            if isinstance(value, DataArray):
                # drop conflicting coordinates
                coord_names = [
                    c
                    for c in value.coords
                    if c not in value.dims and c in dataset.coords
                ]
                if coord_names:
                    other[key] = value.drop_vars(coord_names)

    return merge_core([dataset, other], priority_arg=1, indexes=dataset.indexes)

```


# xarray/core/dataset.py

```
import copy
import functools
import sys
import warnings
from collections import defaultdict
from html import escape
from numbers import Number
from pathlib import Path
from typing import (
    TYPE_CHECKING,
    Any,
    Callable,
    DefaultDict,
    Dict,
    Hashable,
    Iterable,
    Iterator,
    List,
    Mapping,
    MutableMapping,
    Optional,
    Sequence,
    Set,
    Tuple,
    TypeVar,
    Union,
    cast,
)

import numpy as np
import pandas as pd

import xarray as xr

from ..coding.cftimeindex import _parse_array_of_cftime_strings
from ..plot.dataset_plot import _Dataset_PlotMethods
from . import (
    alignment,
    dtypes,
    duck_array_ops,
    formatting,
    formatting_html,
    groupby,
    ops,
    resample,
    rolling,
    utils,
)
from .alignment import _broadcast_helper, _get_broadcast_dims_map_common_coords, align
from .common import (
    DataWithCoords,
    ImplementsDatasetReduce,
    _contains_datetime_like_objects,
)
from .coordinates import (
    DatasetCoordinates,
    LevelCoordinatesSource,
    assert_coordinate_consistent,
    remap_label_indexers,
)
from .duck_array_ops import datetime_to_numeric
from .indexes import (
    Indexes,
    default_indexes,
    isel_variable_and_index,
    propagate_indexes,
    roll_index,
)
from .indexing import is_fancy_indexer
from .merge import (
    dataset_merge_method,
    dataset_update_method,
    merge_coordinates_without_align,
    merge_data_and_coords,
)
from .options import OPTIONS, _get_keep_attrs
from .pycompat import dask_array_type
from .utils import (
    Default,
    Frozen,
    SortedKeysDict,
    _check_inplace,
    _default,
    decode_numpy_dict_values,
    either_dict_or_kwargs,
    hashable,
    is_dict_like,
    is_list_like,
    is_scalar,
    maybe_wrap_array,
)
from .variable import (
    IndexVariable,
    Variable,
    as_variable,
    broadcast_variables,
    assert_unique_multiindex_level_names,
)

if TYPE_CHECKING:
    from ..backends import AbstractDataStore, ZarrStore
    from .dataarray import DataArray
    from .merge import CoercibleMapping

    T_DSorDA = TypeVar("T_DSorDA", DataArray, "Dataset")

    try:
        from dask.delayed import Delayed
    except ImportError:
        Delayed = None


# list of attributes of pd.DatetimeIndex that are ndarrays of time info
_DATETIMEINDEX_COMPONENTS = [
    "year",
    "month",
    "day",
    "hour",
    "minute",
    "second",
    "microsecond",
    "nanosecond",
    "date",
    "time",
    "dayofyear",
    "weekofyear",
    "dayofweek",
    "quarter",
]


def _get_virtual_variable(
    variables, key: Hashable, level_vars: Mapping = None, dim_sizes: Mapping = None
) -> Tuple[Hashable, Hashable, Variable]:
    """Get a virtual variable (e.g., 'time.year' or a MultiIndex level)
    from a dict of xarray.Variable objects (if possible)
    """
    if level_vars is None:
        level_vars = {}
    if dim_sizes is None:
        dim_sizes = {}

    if key in dim_sizes:
        data = pd.Index(range(dim_sizes[key]), name=key)
        variable = IndexVariable((key,), data)
        return key, key, variable

    if not isinstance(key, str):
        raise KeyError(key)

    split_key = key.split(".", 1)
    var_name: Optional[str]
    if len(split_key) == 2:
        ref_name, var_name = split_key
    elif len(split_key) == 1:
        ref_name, var_name = key, None
    else:
        raise KeyError(key)

    if ref_name in level_vars:
        dim_var = variables[level_vars[ref_name]]
        ref_var = dim_var.to_index_variable().get_level_variable(ref_name)
    else:
        ref_var = variables[ref_name]

    if var_name is None:
        virtual_var = ref_var
        var_name = key
    else:
        if _contains_datetime_like_objects(ref_var):
            ref_var = xr.DataArray(ref_var)
            data = getattr(ref_var.dt, var_name).data
        else:
            data = getattr(ref_var, var_name).data
        virtual_var = Variable(ref_var.dims, data)

    return ref_name, var_name, virtual_var


def calculate_dimensions(variables: Mapping[Hashable, Variable]) -> Dict[Hashable, int]:
    """Calculate the dimensions corresponding to a set of variables.

    Returns dictionary mapping from dimension names to sizes. Raises ValueError
    if any of the dimension sizes conflict.
    """
    dims: Dict[Hashable, int] = {}
    last_used = {}
    scalar_vars = {k for k, v in variables.items() if not v.dims}
    for k, var in variables.items():
        for dim, size in zip(var.dims, var.shape):
            if dim in scalar_vars:
                raise ValueError(
                    "dimension %r already exists as a scalar " "variable" % dim
                )
            if dim not in dims:
                dims[dim] = size
                last_used[dim] = k
            elif dims[dim] != size:
                raise ValueError(
                    "conflicting sizes for dimension %r: "
                    "length %s on %r and length %s on %r"
                    % (dim, size, k, dims[dim], last_used[dim])
                )
    return dims


def merge_indexes(
    indexes: Mapping[Hashable, Union[Hashable, Sequence[Hashable]]],
    variables: Mapping[Hashable, Variable],
    coord_names: Set[Hashable],
    append: bool = False,
) -> Tuple[Dict[Hashable, Variable], Set[Hashable]]:
    """Merge variables into multi-indexes.

    Not public API. Used in Dataset and DataArray set_index
    methods.
    """
    vars_to_replace: Dict[Hashable, Variable] = {}
    vars_to_remove: List[Hashable] = []
    dims_to_replace: Dict[Hashable, Hashable] = {}
    error_msg = "{} is not the name of an existing variable."

    for dim, var_names in indexes.items():
        if isinstance(var_names, str) or not isinstance(var_names, Sequence):
            var_names = [var_names]

        names: List[Hashable] = []
        codes: List[List[int]] = []
        levels: List[List[int]] = []
        current_index_variable = variables.get(dim)

        for n in var_names:
            try:
                var = variables[n]
            except KeyError:
                raise ValueError(error_msg.format(n))
            if (
                current_index_variable is not None
                and var.dims != current_index_variable.dims
            ):
                raise ValueError(
                    "dimension mismatch between %r %s and %r %s"
                    % (dim, current_index_variable.dims, n, var.dims)
                )

        if current_index_variable is not None and append:
            current_index = current_index_variable.to_index()
            if isinstance(current_index, pd.MultiIndex):
                names.extend(current_index.names)
                codes.extend(current_index.codes)
                levels.extend(current_index.levels)
            else:
                names.append("%s_level_0" % dim)
                cat = pd.Categorical(current_index.values, ordered=True)
                codes.append(cat.codes)
                levels.append(cat.categories)

        if not len(names) and len(var_names) == 1:
            idx = pd.Index(variables[var_names[0]].values)

        else:  # MultiIndex
            for n in var_names:
                try:
                    var = variables[n]
                except KeyError:
                    raise ValueError(error_msg.format(n))
                names.append(n)
                cat = pd.Categorical(var.values, ordered=True)
                codes.append(cat.codes)
                levels.append(cat.categories)

            idx = pd.MultiIndex(levels, codes, names=names)
            for n in names:
                dims_to_replace[n] = dim

        vars_to_replace[dim] = IndexVariable(dim, idx)
        vars_to_remove.extend(var_names)

    new_variables = {k: v for k, v in variables.items() if k not in vars_to_remove}
    new_variables.update(vars_to_replace)

    # update dimensions if necessary  GH: 3512
    for k, v in new_variables.items():
        if any(d in dims_to_replace for d in v.dims):
            new_dims = [dims_to_replace.get(d, d) for d in v.dims]
            new_variables[k] = v._replace(dims=new_dims)
    new_coord_names = coord_names | set(vars_to_replace)
    new_coord_names -= set(vars_to_remove)
    return new_variables, new_coord_names


def split_indexes(
    dims_or_levels: Union[Hashable, Sequence[Hashable]],
    variables: Mapping[Hashable, Variable],
    coord_names: Set[Hashable],
    level_coords: Mapping[Hashable, Hashable],
    drop: bool = False,
) -> Tuple[Dict[Hashable, Variable], Set[Hashable]]:
    """Extract (multi-)indexes (levels) as variables.

    Not public API. Used in Dataset and DataArray reset_index
    methods.
    """
    if isinstance(dims_or_levels, str) or not isinstance(dims_or_levels, Sequence):
        dims_or_levels = [dims_or_levels]

    dim_levels: DefaultDict[Any, List[Hashable]] = defaultdict(list)
    dims = []
    for k in dims_or_levels:
        if k in level_coords:
            dim_levels[level_coords[k]].append(k)
        else:
            dims.append(k)

    vars_to_replace = {}
    vars_to_create: Dict[Hashable, Variable] = {}
    vars_to_remove = []

    for d in dims:
        index = variables[d].to_index()
        if isinstance(index, pd.MultiIndex):
            dim_levels[d] = index.names
        else:
            vars_to_remove.append(d)
            if not drop:
                vars_to_create[str(d) + "_"] = Variable(d, index)

    for d, levs in dim_levels.items():
        index = variables[d].to_index()
        if len(levs) == index.nlevels:
            vars_to_remove.append(d)
        else:
            vars_to_replace[d] = IndexVariable(d, index.droplevel(levs))

        if not drop:
            for lev in levs:
                idx = index.get_level_values(lev)
                vars_to_create[idx.name] = Variable(d, idx)

    new_variables = dict(variables)
    for v in set(vars_to_remove):
        del new_variables[v]
    new_variables.update(vars_to_replace)
    new_variables.update(vars_to_create)
    new_coord_names = (coord_names | set(vars_to_create)) - set(vars_to_remove)

    return new_variables, new_coord_names


def _assert_empty(args: tuple, msg: str = "%s") -> None:
    if args:
        raise ValueError(msg % args)


def as_dataset(obj: Any) -> "Dataset":
    """Cast the given object to a Dataset.

    Handles Datasets, DataArrays and dictionaries of variables. A new Dataset
    object is only created if the provided object is not already one.
    """
    if hasattr(obj, "to_dataset"):
        obj = obj.to_dataset()
    if not isinstance(obj, Dataset):
        obj = Dataset(obj)
    return obj


class DataVariables(Mapping[Hashable, "DataArray"]):
    __slots__ = ("_dataset",)

    def __init__(self, dataset: "Dataset"):
        self._dataset = dataset

    def __iter__(self) -> Iterator[Hashable]:
        return (
            key
            for key in self._dataset._variables
            if key not in self._dataset._coord_names
        )

    def __len__(self) -> int:
        return len(self._dataset._variables) - len(self._dataset._coord_names)

    def __contains__(self, key: Hashable) -> bool:
        return key in self._dataset._variables and key not in self._dataset._coord_names

    def __getitem__(self, key: Hashable) -> "DataArray":
        if key not in self._dataset._coord_names:
            return cast("DataArray", self._dataset[key])
        raise KeyError(key)

    def __repr__(self) -> str:
        return formatting.data_vars_repr(self)

    @property
    def variables(self) -> Mapping[Hashable, Variable]:
        all_variables = self._dataset.variables
        return Frozen({k: all_variables[k] for k in self})

    def _ipython_key_completions_(self):
        """Provide method for the key-autocompletions in IPython. """
        return [
            key
            for key in self._dataset._ipython_key_completions_()
            if key not in self._dataset._coord_names
        ]


class _LocIndexer:
    __slots__ = ("dataset",)

    def __init__(self, dataset: "Dataset"):
        self.dataset = dataset

    def __getitem__(self, key: Mapping[Hashable, Any]) -> "Dataset":
        if not utils.is_dict_like(key):
            raise TypeError("can only lookup dictionaries from Dataset.loc")
        return self.dataset.sel(key)


class Dataset(Mapping, ImplementsDatasetReduce, DataWithCoords):
    """A multi-dimensional, in memory, array database.

    A dataset resembles an in-memory representation of a NetCDF file, and
    consists of variables, coordinates and attributes which together form a
    self describing dataset.

    Dataset implements the mapping interface with keys given by variable names
    and values given by DataArray objects for each variable name.

    One dimensional variables with name equal to their dimension are index
    coordinates used for label based indexing.
    """

    _attrs: Optional[Dict[Hashable, Any]]
    _cache: Dict[str, Any]
    _coord_names: Set[Hashable]
    _dims: Dict[Hashable, int]
    _encoding: Optional[Dict[Hashable, Any]]
    _indexes: Optional[Dict[Hashable, pd.Index]]
    _variables: Dict[Hashable, Variable]

    __slots__ = (
        "_attrs",
        "_cache",
        "_coord_names",
        "_dims",
        "_encoding",
        "_file_obj",
        "_indexes",
        "_variables",
        "__weakref__",
    )

    _groupby_cls = groupby.DatasetGroupBy
    _rolling_cls = rolling.DatasetRolling
    _coarsen_cls = rolling.DatasetCoarsen
    _resample_cls = resample.DatasetResample

    def __init__(
        self,
        # could make a VariableArgs to use more generally, and refine these
        # categories
        data_vars: Mapping[Hashable, Any] = None,
        coords: Mapping[Hashable, Any] = None,
        attrs: Mapping[Hashable, Any] = None,
        compat=None,
    ):
        """To load data from a file or file-like object, use the `open_dataset`
        function.

        Parameters
        ----------
        data_vars : dict-like, optional
            A mapping from variable names to :py:class:`~xarray.DataArray`
            objects, :py:class:`~xarray.Variable` objects or to tuples of the
            form ``(dims, data[, attrs])`` which can be used as arguments to
            create a new ``Variable``. Each dimension must have the same length
            in all variables in which it appears.

            The following notations are accepted:

            - mapping {var name: DataArray}
            - mapping {var name: Variable}
            - mapping {var name: (dimension name, array-like)}
            - mapping {var name: (tuple of dimension names, array-like)}
            - mapping {dimension name: array-like}
              (it will be automatically moved to coords, see below)

            Each dimension must have the same length in all variables in which
            it appears.
        coords : dict-like, optional
            Another mapping in similar form as the `data_vars` argument,
            except the each item is saved on the dataset as a "coordinate".
            These variables have an associated meaning: they describe
            constant/fixed/independent quantities, unlike the
            varying/measured/dependent quantities that belong in `variables`.
            Coordinates values may be given by 1-dimensional arrays or scalars,
            in which case `dims` do not need to be supplied: 1D arrays will be
            assumed to give index values along the dimension with the same
            name.

            The following notations are accepted:

            - mapping {coord name: DataArray}
            - mapping {coord name: Variable}
            - mapping {coord name: (dimension name, array-like)}
            - mapping {coord name: (tuple of dimension names, array-like)}
            - mapping {dimension name: array-like}
              (the dimension name is implicitly set to be the same as the coord name)

            The last notation implies that the coord name is the same as the
            dimension name.

        attrs : dict-like, optional
            Global attributes to save on this dataset.
        compat : deprecated
        """
        if compat is not None:
            warnings.warn(
                "The `compat` argument to Dataset is deprecated and will be "
                "removed in 0.15."
                "Instead, use `merge` to control how variables are combined",
                FutureWarning,
                stacklevel=2,
            )
        else:
            compat = "broadcast_equals"

        # TODO(shoyer): expose indexes as a public argument in __init__

        if data_vars is None:
            data_vars = {}
        if coords is None:
            coords = {}

        both_data_and_coords = set(data_vars) & set(coords)
        if both_data_and_coords:
            raise ValueError(
                "variables %r are found in both data_vars and coords"
                % both_data_and_coords
            )

        if isinstance(coords, Dataset):
            coords = coords.variables

        variables, coord_names, dims, indexes = merge_data_and_coords(
            data_vars, coords, compat=compat
        )

        self._attrs = dict(attrs) if attrs is not None else None
        self._file_obj = None
        self._encoding = None
        self._variables = variables
        self._coord_names = coord_names
        self._dims = dims
        self._indexes = indexes

    @classmethod
    def load_store(cls, store, decoder=None) -> "Dataset":
        """Create a new dataset from the contents of a backends.*DataStore
        object
        """
        variables, attributes = store.load()
        if decoder:
            variables, attributes = decoder(variables, attributes)
        obj = cls(variables, attrs=attributes)
        obj._file_obj = store
        return obj

    @property
    def variables(self) -> Mapping[Hashable, Variable]:
        """Low level interface to Dataset contents as dict of Variable objects.

        This ordered dictionary is frozen to prevent mutation that could
        violate Dataset invariants. It contains all variable objects
        constituting the Dataset, including both data variables and
        coordinates.
        """
        return Frozen(self._variables)

    @property
    def attrs(self) -> Dict[Hashable, Any]:
        """Dictionary of global attributes on this dataset
        """
        if self._attrs is None:
            self._attrs = {}
        return self._attrs

    @attrs.setter
    def attrs(self, value: Mapping[Hashable, Any]) -> None:
        self._attrs = dict(value)

    @property
    def encoding(self) -> Dict:
        """Dictionary of global encoding attributes on this dataset
        """
        if self._encoding is None:
            self._encoding = {}
        return self._encoding

    @encoding.setter
    def encoding(self, value: Mapping) -> None:
        self._encoding = dict(value)

    @property
    def dims(self) -> Mapping[Hashable, int]:
        """Mapping from dimension names to lengths.

        Cannot be modified directly, but is updated when adding new variables.

        Note that type of this object differs from `DataArray.dims`.
        See `Dataset.sizes` and `DataArray.sizes` for consistently named
        properties.
        """
        return Frozen(SortedKeysDict(self._dims))

    @property
    def sizes(self) -> Mapping[Hashable, int]:
        """Mapping from dimension names to lengths.

        Cannot be modified directly, but is updated when adding new variables.

        This is an alias for `Dataset.dims` provided for the benefit of
        consistency with `DataArray.sizes`.

        See also
        --------
        DataArray.sizes
        """
        return self.dims

    def load(self, **kwargs) -> "Dataset":
        """Manually trigger loading and/or computation of this dataset's data
        from disk or a remote source into memory and return this dataset.
        Unlike compute, the original dataset is modified and returned.

        Normally, it should not be necessary to call this method in user code,
        because all xarray functions should either work on deferred data or
        load data automatically. However, this method can be necessary when
        working with many file objects on disk.

        Parameters
        ----------
        **kwargs : dict
            Additional keyword arguments passed on to ``dask.array.compute``.

        See Also
        --------
        dask.array.compute
        """
        # access .data to coerce everything to numpy or dask arrays
        lazy_data = {
            k: v._data
            for k, v in self.variables.items()
            if isinstance(v._data, dask_array_type)
        }
        if lazy_data:
            import dask.array as da

            # evaluate all the dask arrays simultaneously
            evaluated_data = da.compute(*lazy_data.values(), **kwargs)

            for k, data in zip(lazy_data, evaluated_data):
                self.variables[k].data = data

        # load everything else sequentially
        for k, v in self.variables.items():
            if k not in lazy_data:
                v.load()

        return self

    def __dask_tokenize__(self):
        from dask.base import normalize_token

        return normalize_token(
            (type(self), self._variables, self._coord_names, self._attrs)
        )

    def __dask_graph__(self):
        graphs = {k: v.__dask_graph__() for k, v in self.variables.items()}
        graphs = {k: v for k, v in graphs.items() if v is not None}
        if not graphs:
            return None
        else:
            try:
                from dask.highlevelgraph import HighLevelGraph

                return HighLevelGraph.merge(*graphs.values())
            except ImportError:
                from dask import sharedict

                return sharedict.merge(*graphs.values())

    def __dask_keys__(self):
        import dask

        return [
            v.__dask_keys__()
            for v in self.variables.values()
            if dask.is_dask_collection(v)
        ]

    def __dask_layers__(self):
        import dask

        return sum(
            [
                v.__dask_layers__()
                for v in self.variables.values()
                if dask.is_dask_collection(v)
            ],
            (),
        )

    @property
    def __dask_optimize__(self):
        import dask.array as da

        return da.Array.__dask_optimize__

    @property
    def __dask_scheduler__(self):
        import dask.array as da

        return da.Array.__dask_scheduler__

    def __dask_postcompute__(self):
        import dask

        info = [
            (True, k, v.__dask_postcompute__())
            if dask.is_dask_collection(v)
            else (False, k, v)
            for k, v in self._variables.items()
        ]
        args = (
            info,
            self._coord_names,
            self._dims,
            self._attrs,
            self._indexes,
            self._encoding,
            self._file_obj,
        )
        return self._dask_postcompute, args

    def __dask_postpersist__(self):
        import dask

        info = [
            (True, k, v.__dask_postpersist__())
            if dask.is_dask_collection(v)
            else (False, k, v)
            for k, v in self._variables.items()
        ]
        args = (
            info,
            self._coord_names,
            self._dims,
            self._attrs,
            self._indexes,
            self._encoding,
            self._file_obj,
        )
        return self._dask_postpersist, args

    @staticmethod
    def _dask_postcompute(results, info, *args):
        variables = {}
        results2 = list(results[::-1])
        for is_dask, k, v in info:
            if is_dask:
                func, args2 = v
                r = results2.pop()
                result = func(r, *args2)
            else:
                result = v
            variables[k] = result

        final = Dataset._construct_direct(variables, *args)
        return final

    @staticmethod
    def _dask_postpersist(dsk, info, *args):
        variables = {}
        for is_dask, k, v in info:
            if is_dask:
                func, args2 = v
                result = func(dsk, *args2)
            else:
                result = v
            variables[k] = result

        return Dataset._construct_direct(variables, *args)

    def compute(self, **kwargs) -> "Dataset":
        """Manually trigger loading and/or computation of this dataset's data
        from disk or a remote source into memory and return a new dataset.
        Unlike load, the original dataset is left unaltered.

        Normally, it should not be necessary to call this method in user code,
        because all xarray functions should either work on deferred data or
        load data automatically. However, this method can be necessary when
        working with many file objects on disk.

        Parameters
        ----------
        **kwargs : dict
            Additional keyword arguments passed on to ``dask.array.compute``.

        See Also
        --------
        dask.array.compute
        """
        new = self.copy(deep=False)
        return new.load(**kwargs)

    def _persist_inplace(self, **kwargs) -> "Dataset":
        """Persist all Dask arrays in memory
        """
        # access .data to coerce everything to numpy or dask arrays
        lazy_data = {
            k: v._data
            for k, v in self.variables.items()
            if isinstance(v._data, dask_array_type)
        }
        if lazy_data:
            import dask

            # evaluate all the dask arrays simultaneously
            evaluated_data = dask.persist(*lazy_data.values(), **kwargs)

            for k, data in zip(lazy_data, evaluated_data):
                self.variables[k].data = data

        return self

    def persist(self, **kwargs) -> "Dataset":
        """ Trigger computation, keeping data as dask arrays

        This operation can be used to trigger computation on underlying dask
        arrays, similar to ``.compute()`` or ``.load()``.  However this
        operation keeps the data as dask arrays. This is particularly useful
        when using the dask.distributed scheduler and you want to load a large
        amount of data into distributed memory.

        Parameters
        ----------
        **kwargs : dict
            Additional keyword arguments passed on to ``dask.persist``.

        See Also
        --------
        dask.persist
        """
        new = self.copy(deep=False)
        return new._persist_inplace(**kwargs)

    @classmethod
    def _construct_direct(
        cls,
        variables,
        coord_names,
        dims=None,
        attrs=None,
        indexes=None,
        encoding=None,
        file_obj=None,
    ):
        """Shortcut around __init__ for internal use when we want to skip
        costly validation
        """
        if dims is None:
            dims = calculate_dimensions(variables)
        obj = object.__new__(cls)
        obj._variables = variables
        obj._coord_names = coord_names
        obj._dims = dims
        obj._indexes = indexes
        obj._attrs = attrs
        obj._file_obj = file_obj
        obj._encoding = encoding
        return obj

    def _replace(
        self,
        variables: Dict[Hashable, Variable] = None,
        coord_names: Set[Hashable] = None,
        dims: Dict[Any, int] = None,
        attrs: Union[Dict[Hashable, Any], None, Default] = _default,
        indexes: Union[Dict[Any, pd.Index], None, Default] = _default,
        encoding: Union[dict, None, Default] = _default,
        inplace: bool = False,
    ) -> "Dataset":
        """Fastpath constructor for internal use.

        Returns an object with optionally with replaced attributes.

        Explicitly passed arguments are *not* copied when placed on the new
        dataset. It is up to the caller to ensure that they have the right type
        and are not used elsewhere.
        """
        if inplace:
            if variables is not None:
                self._variables = variables
            if coord_names is not None:
                self._coord_names = coord_names
            if dims is not None:
                self._dims = dims
            if attrs is not _default:
                self._attrs = attrs  # type: ignore # FIXME need mypy 0.750
            if indexes is not _default:
                self._indexes = indexes  # type: ignore # FIXME need mypy 0.750
            if encoding is not _default:
                self._encoding = encoding  # type: ignore # FIXME need mypy 0.750
            obj = self
        else:
            if variables is None:
                variables = self._variables.copy()
            if coord_names is None:
                coord_names = self._coord_names.copy()
            if dims is None:
                dims = self._dims.copy()
            if attrs is _default:
                attrs = copy.copy(self._attrs)
            if indexes is _default:
                indexes = copy.copy(self._indexes)
            if encoding is _default:
                encoding = copy.copy(self._encoding)
            obj = self._construct_direct(
                variables, coord_names, dims, attrs, indexes, encoding
            )
        return obj

    def _replace_with_new_dims(
        self,
        variables: Dict[Hashable, Variable],
        coord_names: set = None,
        attrs: Union[Dict[Hashable, Any], None, Default] = _default,
        indexes: Union[Dict[Hashable, pd.Index], None, Default] = _default,
        inplace: bool = False,
    ) -> "Dataset":
        """Replace variables with recalculated dimensions."""
        dims = calculate_dimensions(variables)
        return self._replace(
            variables, coord_names, dims, attrs, indexes, inplace=inplace
        )

    def _replace_vars_and_dims(
        self,
        variables: Dict[Hashable, Variable],
        coord_names: set = None,
        dims: Dict[Hashable, int] = None,
        attrs: Union[Dict[Hashable, Any], None, Default] = _default,
        inplace: bool = False,
    ) -> "Dataset":
        """Deprecated version of _replace_with_new_dims().

        Unlike _replace_with_new_dims(), this method always recalculates
        indexes from variables.
        """
        if dims is None:
            dims = calculate_dimensions(variables)
        return self._replace(
            variables, coord_names, dims, attrs, indexes=None, inplace=inplace
        )

    def _overwrite_indexes(self, indexes: Mapping[Any, pd.Index]) -> "Dataset":
        if not indexes:
            return self

        variables = self._variables.copy()
        new_indexes = dict(self.indexes)
        for name, idx in indexes.items():
            variables[name] = IndexVariable(name, idx)
            new_indexes[name] = idx
        obj = self._replace(variables, indexes=new_indexes)

        # switch from dimension to level names, if necessary
        dim_names: Dict[Hashable, str] = {}
        for dim, idx in indexes.items():
            if not isinstance(idx, pd.MultiIndex) and idx.name != dim:
                dim_names[dim] = idx.name
        if dim_names:
            obj = obj.rename(dim_names)
        return obj

    def copy(self, deep: bool = False, data: Mapping = None) -> "Dataset":
        """Returns a copy of this dataset.

        If `deep=True`, a deep copy is made of each of the component variables.
        Otherwise, a shallow copy of each of the component variable is made, so
        that the underlying memory region of the new dataset is the same as in
        the original dataset.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, optional
            Whether each component variable is loaded into memory and copied onto
            the new object. Default is False.
        data : dict-like, optional
            Data to use in the new object. Each item in `data` must have same
            shape as corresponding data variable in original. When `data` is
            used, `deep` is ignored for the data variables and only used for
            coords.

        Returns
        -------
        object : Dataset
            New object with dimensions, attributes, coordinates, name, encoding,
            and optionally data copied from original.

        Examples
        --------

        Shallow copy versus deep copy

        >>> da = xr.DataArray(np.random.randn(2, 3))
        >>> ds = xr.Dataset({'foo': da, 'bar': ('x', [-1, 2])},
                            coords={'x': ['one', 'two']})
        >>> ds.copy()
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 -0.8079 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2
        >>> ds_0 = ds.copy(deep=False)
        >>> ds_0['foo'][0, 0] = 7
        >>> ds_0
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 7.0 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2
        >>> ds
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 7.0 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2

        Changing the data using the ``data`` argument maintains the
        structure of the original object, but with the new data. Original
        object is unaffected.

        >>> ds.copy(data={'foo': np.arange(6).reshape(2, 3), 'bar': ['a', 'b']})
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) int64 0 1 2 3 4 5
            bar      (x) <U1 'a' 'b'
        >>> ds
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 7.0 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2

        See Also
        --------
        pandas.DataFrame.copy
        """
        if data is None:
            variables = {k: v.copy(deep=deep) for k, v in self._variables.items()}
        elif not utils.is_dict_like(data):
            raise ValueError("Data must be dict-like")
        else:
            var_keys = set(self.data_vars.keys())
            data_keys = set(data.keys())
            keys_not_in_vars = data_keys - var_keys
            if keys_not_in_vars:
                raise ValueError(
                    "Data must only contain variables in original "
                    "dataset. Extra variables: {}".format(keys_not_in_vars)
                )
            keys_missing_from_data = var_keys - data_keys
            if keys_missing_from_data:
                raise ValueError(
                    "Data must contain all variables in original "
                    "dataset. Data is missing {}".format(keys_missing_from_data)
                )
            variables = {
                k: v.copy(deep=deep, data=data.get(k))
                for k, v in self._variables.items()
            }

        attrs = copy.deepcopy(self._attrs) if deep else copy.copy(self._attrs)

        return self._replace(variables, attrs=attrs)

    @property
    def _level_coords(self) -> Dict[str, Hashable]:
        """Return a mapping of all MultiIndex levels and their corresponding
        coordinate name.
        """
        level_coords: Dict[str, Hashable] = {}
        for name, index in self.indexes.items():
            if isinstance(index, pd.MultiIndex):
                level_names = index.names
                (dim,) = self.variables[name].dims
                level_coords.update({lname: dim for lname in level_names})
        return level_coords

    def _copy_listed(self, names: Iterable[Hashable]) -> "Dataset":
        """Create a new Dataset with the listed variables from this dataset and
        the all relevant coordinates. Skips all validation.
        """
        variables: Dict[Hashable, Variable] = {}
        coord_names = set()
        indexes: Dict[Hashable, pd.Index] = {}

        for name in names:
            try:
                variables[name] = self._variables[name]
            except KeyError:
                ref_name, var_name, var = _get_virtual_variable(
                    self._variables, name, self._level_coords, self.dims
                )
                variables[var_name] = var
                if ref_name in self._coord_names or ref_name in self.dims:
                    coord_names.add(var_name)
                if (var_name,) == var.dims:
                    indexes[var_name] = var.to_index()

        needed_dims: Set[Hashable] = set()
        for v in variables.values():
            needed_dims.update(v.dims)

        dims = {k: self.dims[k] for k in needed_dims}

        for k in self._coord_names:
            if set(self.variables[k].dims) <= needed_dims:
                variables[k] = self._variables[k]
                coord_names.add(k)
                if k in self.indexes:
                    indexes[k] = self.indexes[k]

        return self._replace(variables, coord_names, dims, indexes=indexes)

    def _construct_dataarray(self, name: Hashable) -> "DataArray":
        """Construct a DataArray by indexing this dataset
        """
        from .dataarray import DataArray

        try:
            variable = self._variables[name]
        except KeyError:
            _, name, variable = _get_virtual_variable(
                self._variables, name, self._level_coords, self.dims
            )

        needed_dims = set(variable.dims)

        coords: Dict[Hashable, Variable] = {}
        for k in self.coords:
            if set(self.variables[k].dims) <= needed_dims:
                coords[k] = self.variables[k]

        if self._indexes is None:
            indexes = None
        else:
            indexes = {k: v for k, v in self._indexes.items() if k in coords}

        return DataArray(variable, coords, name=name, indexes=indexes, fastpath=True)

    def __copy__(self) -> "Dataset":
        return self.copy(deep=False)

    def __deepcopy__(self, memo=None) -> "Dataset":
        # memo does nothing but is required for compatibility with
        # copy.deepcopy
        return self.copy(deep=True)

    @property
    def _attr_sources(self) -> List[Mapping[Hashable, Any]]:
        """List of places to look-up items for attribute-style access
        """
        return self._item_sources + [self.attrs]

    @property
    def _item_sources(self) -> List[Mapping[Hashable, Any]]:
        """List of places to look-up items for key-completion
        """
        return [
            self.data_vars,
            self.coords,
            {d: self[d] for d in self.dims},
            LevelCoordinatesSource(self),
        ]

    def __contains__(self, key: object) -> bool:
        """The 'in' operator will return true or false depending on whether
        'key' is an array in the dataset or not.
        """
        return key in self._variables

    def __len__(self) -> int:
        return len(self.data_vars)

    def __bool__(self) -> bool:
        return bool(self.data_vars)

    d
```


# xarray/tests (the files in it)

xarray/tests/__init__.py
xarray/tests/data/bears.nc
xarray/tests/data/example.grib
xarray/tests/data/example.ict
xarray/tests/data/example.uamiv
xarray/tests/data/example_1.nc
xarray/tests/data/example_1.nc.gz
xarray/tests/test_accessor_dt.py
xarray/tests/test_accessor_str.py
xarray/tests/test_backends.py
xarray/tests/test_backends_api.py
xarray/tests/test_backends_common.py
xarray/tests/test_backends_file_manager.py
xarray/tests/test_backends_locks.py
xarray/tests/test_backends_lru_cache.py
xarray/tests/test_cftime_offsets.py
xarray/tests/test_cftimeindex.py
xarray/tests/test_cftimeindex_resample.py
xarray/tests/test_coding.py
xarray/tests/test_coding_strings.py
xarray/tests/test_coding_times.py
xarray/tests/test_combine.py
xarray/tests/test_computation.py
xarray/tests/test_concat.py
xarray/tests/test_conventions.py
xarray/tests/test_dask.py
xarray/tests/test_dataarray.py
xarray/tests/test_dataset.py
xarray/tests/test_distributed.py
xarray/tests/test_dtypes.py
xarray/tests/test_duck_array_ops.py
xarray/tests/test_extensions.py
xarray/tests/test_formatting.py
xarray/tests/test_formatting_html.py
xarray/tests/test_groupby.py
xarray/tests/test_indexing.py
xarray/tests/test_interp.py
xarray/tests/test_merge.py
xarray/tests/test_missing.py
xarray/tests/test_nputils.py
xarray/tests/test_options.py
xarray/tests/test_plot.py
xarray/tests/test_print_versions.py
xarray/tests/test_sparse.py
xarray/tests/test_testing.py
xarray/tests/test_tutorial.py
xarray/tests/test_ufuncs.py
xarray/tests/test_units.py
xarray/tests/test_utils.py
xarray/tests/test_variable.py


# The last commit

```
deda502c SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q
........................................................................ [  8%]
....................................xX........F......................... [ 16%]
........................................................................ [ 24%]
........................................................................ [ 32%]
..............F......................................................... [ 40%]
........................................................................ [ 48%]
........................................................................ [ 56%]
.....................................................ssssssssssssssss... [ 64%]
........................................................................ [ 72%]
........................................................................ [ 80%]
........................................................................ [ 88%]
........................................................................ [ 96%]
....................FF....FF...                                          [100%]
=================================== FAILURES ===================================
___________ TestDataset.test_rename_does_not_change_CFTimeIndex_type ___________

self = <xarray.tests.test_dataset.TestDataset object at 0x70ab0fcf0730>

    @requires_cftime
    def test_rename_does_not_change_CFTimeIndex_type(self):
        # make sure CFTimeIndex is not converted to DatetimeIndex #3522
    
        time = xr.cftime_range(start="2000", periods=6, freq="2MS", calendar="noleap")
>       orig = Dataset(coords={"time": time})

xarray/tests/test_dataset.py:2480: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataset.py:547: in __init__
    variables, coord_names, dims, indexes = merge_data_and_coords(
xarray/core/merge.py:465: in merge_data_and_coords
    indexes = dict(_extract_indexes_from_coords(coords))
xarray/core/merge.py:476: in _extract_indexes_from_coords
    yield name, variable.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-03-01 00:00:00, 2000-05-01 00:00:00,
             2000-07-01 00:00:00, 2000-09-01 00:00:00, 2000-11-01 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
        times = xr.cftime_range("2000", periods=6)
>       da = xr.DataArray(range(6), [("time", times)])

xarray/tests/test_dataset.py:5566: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-02 00:00:00, 2000-01-03 00:00:00,
             2000-01-04 00:00:00, 2000-01-05 00:00:00, 2000-01-06 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
=============================== warnings summary ===============================
xarray/core/dask_array_compat.py:13
xarray/core/dask_array_compat.py:13
  /testbed/xarray/core/dask_array_compat.py:13: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:100
xarray/core/dask_array_compat.py:100
  /testbed/xarray/core/dask_array_compat.py:100: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:137
xarray/core/dask_array_compat.py:137
  /testbed/xarray/core/dask_array_compat.py:137: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/formatting_html.py:6
  /testbed/xarray/core/formatting_html.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/test_merge.py: 17 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_merge.py: 4 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataset.py: 349 warnings
  /testbed/xarray/core/formatting.py:142: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/tests/__init__.py:55: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/core/merge.py:393: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = dict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /testbed/xarray/core/variable.py:986: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) < "2.0.0":

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/xarray/core/indexing.py:179: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    indexer = index.get_loc(

xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataset.py: 12 warnings
  /testbed/xarray/coding/cftimeindex.py:112: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py: 54 warnings
  /testbed/xarray/coding/cftime_offsets.py:243: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2824: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds.unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2825: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    assert actual["var"].dtype == np.int

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2829: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds["var"].unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
  /testbed/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataset.py: 11 warnings
  /testbed/xarray/core/common.py:1044: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py: 11 warnings
  /testbed/xarray/core/groupby.py:347: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/core/common.py:1044: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/tests/test_dataset.py:3656: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    ds.bar.to_series().resample("24H", loffset="-12H").mean()

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:535: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method="nearest")

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:536: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method="nearest")

xarray/tests/test_dataset.py: 63 warnings
  /testbed/xarray/core/variable.py:1751: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    return np.moveaxis(np.nanpercentile(npa, **kwargs), 0, -1)

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/xarray/tests/test_dataset.py:5558: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={"time": pd.date_range("15/12/1999", periods=364)},

xarray/tests/test_dataset.py::test_trapz_datetime[np-True]
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/array/core.py:1706: FutureWarning: The `numpy.trapz` function is not implemented by Dask array. You may want to use the da.map_blocks function or something similar to silence this warning. Your code may stop working in a future release.
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_rename_does_not_change_CFTimeIndex_type
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - AttributeEr...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - Attrib...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Attr...
6 failed, 871 passed, 16 skipped, 1 xfailed, 1 xpassed, 586 warnings in 25.86s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: xarray/core/merge.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataset.py +3 -3
changed: xarray/core/merge.py +6 -1
changed: xarray/tests/test_merge.py +11 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/xarray/core/dataset.py b/xarray/core/dataset.py
index ac0a923d..b7156937 100644
--- a/xarray/core/dataset.py
+++ b/xarray/core/dataset.py
@@ -3547,7 +3547,7 @@ class Dataset(Mapping, ImplementsDatasetReduce, DataWithCoords):
 
     def merge(
         self,
-        other: "CoercibleMapping",
+        other: Union["Dataset", "DataArray", "CoercibleMapping"],
         inplace: bool = None,
         overwrite_vars: Union[Hashable, Iterable[Hashable]] = frozenset(),
         compat: str = "no_conflicts",
@@ -3563,8 +3563,8 @@ class Dataset(Mapping, ImplementsDatasetReduce, DataWithCoords):
 
         Parameters
         ----------
-        other : Dataset or castable to Dataset
-            Dataset or variables to merge with this dataset.
+        other : Dataset, DataArray or castable to Dataset
+            Dataset, DataArray or variables to merge with this dataset.
         overwrite_vars : Hashable or iterable of Hashable, optional
             If provided, update variables of these name(s) without checking for
             conflicts in this dataset.
diff --git a/xarray/core/merge.py b/xarray/core/merge.py
index 10c7804d..e2eae24c 100644
--- a/xarray/core/merge.py
+++ b/xarray/core/merge.py
@@ -797,7 +797,7 @@ def merge(
 
 def dataset_merge_method(
     dataset: "Dataset",
-    other: "CoercibleMapping",
+    other: Union["Dataset", "DataArray", "CoercibleMapping"],
     overwrite_vars: Union[Hashable, Iterable[Hashable]],
     compat: str,
     join: str,
@@ -805,6 +805,11 @@ def dataset_merge_method(
 ) -> _MergeResult:
     """Guts of the Dataset.merge method.
     """
+    from .dataarray import DataArray
+
+    if isinstance(other, DataArray):
+        other = other.to_dataset()
+
     # we are locked into supporting overwrite_vars for the Dataset.merge
     # method due for backwards compatibility
     # TODO: consider deprecating it?
diff --git a/xarray/tests/test_merge.py b/xarray/tests/test_merge.py
index c1e6c7a5..55332ca4 100644
--- a/xarray/tests/test_merge.py
+++ b/xarray/tests/test_merge.py
@@ -159,6 +159,17 @@ class TestMergeMethod:
         with raises_regex(ValueError, "should be coordinates or not"):
             data.merge(data.reset_coords())
 
+    def test_merge_dataarray(self):
+        ds = xr.Dataset({"a": 0})
+        da = xr.DataArray(1, name="b")
+        expected = xr.merge([ds, da])
+        actual = ds.merge(da)
+        assert expected.identical(actual)
+
+        # an unnamed DataArray cannot be merged as a variable
+        with raises_regex(ValueError, "unable to convert unnamed DataArray"):
+            ds.merge(xr.DataArray(1))
+
     def test_merge_broadcast_equals(self):
         ds1 = xr.Dataset({"x": 0})
         ds2 = xr.Dataset({"x": ("y", [0, 0])})
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
check: python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q
........................................................................ [  8%]
....................................xX........F......................... [ 16%]
........................................................................ [ 24%]
........................................................................ [ 32%]
..............F......................................................... [ 40%]
........................................................................ [ 48%]
........................................................................ [ 56%]
.....................................................ssssssssssssssss... [ 64%]
........................................................................ [ 72%]
........................................................................ [ 80%]
........................................................................ [ 88%]
........................................................................ [ 96%]
....................FF....FF...                                          [100%]
=================================== FAILURES ===================================
___________ TestDataset.test_rename_does_not_change_CFTimeIndex_type ___________

self = <xarray.tests.test_dataset.TestDataset object at 0x7cf919d70640>

    @requires_cftime
    def test_rename_does_not_change_CFTimeIndex_type(self):
        # make sure CFTimeIndex is not converted to DatetimeIndex #3522
    
        time = xr.cftime_range(start="2000", periods=6, freq="2MS", calendar="noleap")
>       orig = Dataset(coords={"time": time})

xarray/tests/test_dataset.py:2480: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataset.py:547: in __init__
    variables, coord_names, dims, indexes = merge_data_and_coords(
xarray/core/merge.py:465: in merge_data_and_coords
    indexes = dict(_extract_indexes_from_coords(coords))
xarray/core/merge.py:476: in _extract_indexes_from_coords
    yield name, variable.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-03-01 00:00:00, 2000-05-01 00:00:00,
             2000-07-01 00:00:00, 2000-09-01 00:00:00, 2000-11-01 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
        times = xr.cftime_range("2000", periods=6)
>       da = xr.DataArray(range(6), [("time", times)])

xarray/tests/test_dataset.py:5566: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-02 00:00:00, 2000-01-03 00:00:00,
             2000-01-04 00:00:00, 2000-01-05 00:00:00, 2000-01-06 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
=============================== warnings summary ===============================
xarray/core/dask_array_compat.py:13
xarray/core/dask_array_compat.py:13
  /testbed/xarray/core/dask_array_compat.py:13: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:100
xarray/core/dask_array_compat.py:100
  /testbed/xarray/core/dask_array_compat.py:100: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:137
xarray/core/dask_array_compat.py:137
  /testbed/xarray/core/dask_array_compat.py:137: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/formatting_html.py:6
  /testbed/xarray/core/formatting_html.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/test_merge.py: 17 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_merge.py: 4 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataset.py: 349 warnings
  /testbed/xarray/core/formatting.py:142: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/tests/__init__.py:55: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/core/merge.py:393: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = dict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /testbed/xarray/core/variable.py:986: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) < "2.0.0":

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/xarray/core/indexing.py:179: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    indexer = index.get_loc(

xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataset.py: 12 warnings
  /testbed/xarray/coding/cftimeindex.py:112: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py: 54 warnings
  /testbed/xarray/coding/cftime_offsets.py:243: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2824: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds.unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2825: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    assert actual["var"].dtype == np.int

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2829: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds["var"].unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
  /testbed/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataset.py: 11 warnings
  /testbed/xarray/core/common.py:1044: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py: 11 warnings
  /testbed/xarray/core/groupby.py:347: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/core/common.py:1044: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/tests/test_dataset.py:3656: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    ds.bar.to_series().resample("24H", loffset="-12H").mean()

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:535: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method="nearest")

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:536: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method="nearest")

xarray/tests/test_dataset.py: 63 warnings
  /testbed/xarray/core/variable.py:1751: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    return np.moveaxis(np.nanpercentile(npa, **kwargs), 0, -1)

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/xarray/tests/test_dataset.py:5558: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={"time": pd.date_range("15/12/1999", periods=364)},

xarray/tests/test_dataset.py::test_trapz_datetime[np-True]
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/array/core.py:1706: FutureWarning: The `numpy.trapz` function is not implemented by Dask array. You may want to use the da.map_blocks function or something similar to silence this warning. Your code may stop working in a future release.
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_rename_does_not_change_CFTimeIndex_type
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - AttributeEr...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - Attrib...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Attr...
6 failed, 871 passed, 16 skipped, 1 xfailed, 1 xpassed, 586 warnings in 21.21s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: xarray/core/merge.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataset.py +3 -3
changed: xarray/core/merge.py +6 -1
changed: xarray/tests/test_merge.py +11 -0
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
# Notes, run 2026-11-06T125852

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Merging dataArray into dataset using dataset method fails
While it's possible to merge a dataset and a dataarray object using the top-level `merge()` function, if you try the same thing with the `ds.merge()` method it fails.

```python
import xarray as xr

ds = xr.Dataset({'a': 0})
da = xr.DataArray(1, name='b')

expected = xr.merge([ds, da])  # works fine
print(expected)

ds.merge(da)  # fails
```

Output:
```
<xarray.Dataset>
Dimensions:  ()
Data variables:
    a        int64 0
    b        int64 1

Traceback (most recent call last):
  File "mwe.py", line 6, in <module>
    actual = ds.merge(da)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/dataset.py", line 3591, in merge
    fill_value=fill_value,
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 835, in dataset_merge_method
    objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 548, in merge_core
    coerced = coerce_pandas_values(objects)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 394, in coerce_pandas_values
    for k, v in obj.items():
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/common.py", line 233, in __getattr__
    "{!r} object has no attribute {!r}".format(type(self).__name__, name)
AttributeError: 'DataArray' object has no attribute 'items'
```


# The files of the project

```
.binder/environment.yml
.codecov.yml
.coveragerc
.gitattributes
.github/FUNDING.yml
.github/ISSUE_TEMPLATE/bug_report.md
.github/PULL_REQUEST_TEMPLATE.md
.github/stale.yml
.gitignore
.landscape.yml
.pep8speaks.yml
.pre-commit-config.yaml
CODE_OF_CONDUCT.md
HOW_TO_RELEASE.md
LICENSE
MANIFEST.in
README.rst
asv_bench/asv.conf.json
asv_bench/benchmarks/__init__.py
asv_bench/benchmarks/combine.py
asv_bench/benchmarks/dataarray_missing.py
asv_bench/benchmarks/dataset_io.py
asv_bench/benchmarks/indexing.py
asv_bench/benchmarks/interp.py
asv_bench/benchmarks/reindexing.py
asv_bench/benchmarks/rolling.py
asv_bench/benchmarks/unstacking.py
azure-pipelines.yml
ci/azure/add-conda-to-path.yml
ci/azure/install.yml
ci/azure/unit-tests.yml
ci/min_deps_check.py
ci/requirements/doc.yml
ci/requirements/py36-bare-minimum.yml
ci/requirements/py36-min-all-deps.yml
ci/requirements/py36-min-nep18.yml
ci/requirements/py36.yml
ci/requirements/py37-windows.yml
ci/requirements/py37.yml
ci/requirements/py38.yml
conftest.py
doc/Makefile
doc/README.rst
doc/_static/.gitignore
doc/_static/advanced_selection_interpolation.svg
doc/_static/ci.png
doc/_static/dask_array.png
doc/_static/dataset-diagram-build.sh
doc/_static/dataset-diagram-logo.png
doc/_static/dataset-diagram-logo.tex
doc/_static/dataset-diagram-square-logo.png
doc/_static/dataset-diagram-square-logo.tex
doc/_static/dataset-diagram.png
doc/_static/dataset-diagram.tex
doc/_static/favicon.ico
doc/_static/numfocus_logo.png
doc/_static/opendap-prism-tmax.png
doc/_static/style.css
doc/_templates/layout.html
doc/api-hidden.rst
doc/api.rst
doc/combining.rst
doc/computation.rst
doc/conf.py
doc/contributing.rst
doc/dask.rst
doc/data-structures.rst
doc/examples.rst
doc/examples/ERA5-GRIB-example.ipynb
doc/examples/ROMS_ocean_model.ipynb
doc/examples/_code/accessor_example.py
doc/examples/_code/weather_data_setup.py
doc/examples/monthly-means.ipynb
doc/examples/monthly_means_output.png
doc/examples/multidimensional-coords.ipynb
doc/examples/visualization_gallery.ipynb
doc/examples/weather-data.rst
doc/faq.rst
doc/gallery/README.txt
doc/gallery/plot_cartopy_facetgrid.py
doc/gallery/plot_colorbar_center.py
doc/gallery/plot_control_colorbar.py
doc/gallery/plot_lines_from_2d.py
doc/gallery/plot_rasterio.py
doc/gallery/plot_rasterio_rgb.py
doc/groupby.rst
doc/howdoi.rst
doc/index.rst
doc/indexing.rst
doc/installing.rst
doc/internals.rst
doc/interpolation.rst
doc/io.rst
doc/pandas.rst
doc/plotting.rst
doc/quick-overview.rst
doc/related-projects.rst
doc/reshaping.rst
doc/roadmap.rst
doc/terminology.rst
doc/time-series.rst
doc/weather-climate.rst
doc/whats-new.rst
doc/why-xarray.rst
licenses/DASK_LICENSE
licenses/ICOMOON_LICENSE
licenses/NUMPY_LICENSE
licenses/PANDAS_LICENSE
licenses/PYTHON_LICENSE
licenses/SEABORN_LICENSE
properties/README.md
properties/conftest.py
properties/test_encode_decode.py
properties/test_pandas_roundtrip.py
readthedocs.yml
setup.cfg
setup.py
versioneer.py
xarray/__init__.py
xarray/_version.py
xarray/backends/__init__.py
xarray/backends/api.py
xarray/backends/cfgrib_.py
xarray/backends/common.py
xarray/backends/file_manager.py
xarray/backends/h5netcdf_.py
xarray/backends/locks.py
xarray/backends/lru_cache.py
xarray/backends/memory.py
xarray/backends/netCDF4_.py
xarray/backends/netcdf3.py
xarray/backends/pseudonetcdf_.py
xarray/backends/pydap_.py
xarray/backends/pynio_.py
xarray/backends/rasterio_.py
xarray/backends/scipy_.py
xarray/backends/zarr.py
xarray/coding/__init__.py
xarray/coding/cftime_offsets.py
xarray/coding/cftimeindex.py
xarray/coding/strings.py
xarray/coding/times.py
xarray/coding/variables.py
xarray/conventions.py
xarray/convert.py
xarray/core/__init__.py
xarray/core/accessor_dt.py
xarray/core/accessor_str.py
xarray/core/alignment.py
xarray/core/arithmetic.py
xarray/core/combine.py
xarray/core/common.py
xarray/core/computation.py
xarray/core/concat.py
xarray/core/coordinates.py
xarray/core/dask_array_compat.py
xarray/core/dask_array_ops.py
xarray/core/dataarray.py
xarray/core/dataset.py
xarray/core/dtypes.py
xarray/core/duck_array_ops.py
xarray/core/extensions.py
xarray/core/formatting.py
xarray/core/formatting_html.py
xarray/core/groupby.py
xarray/core/indexes.py
xarray/core/indexing.py
xarray/core/merge.py
xarray/core/missing.py
xarray/core/nanops.py
xarray/core/npcompat.py
xarray/core/nputils.py
xarray/core/ops.py
xarray/core/options.py
xarray/core/parallel.py
xarray/core/pdcompat.py
xarray/core/pycompat.py
xarray/core/resample.py
xarray/core/resample_cftime.py
xarray/core/rolling.py
xarray/core/rolling_exp.py
xarray/core/utils.py
xarray/core/variable.py
xarray/plot/__init__.py
xarray/plot/dataset_plot.py
xarray/plot/facetgrid.py
xarray/plot/plot.py
xarray/plot/utils.py
xarray/py.typed
xarray/static/css/style.css
xarray/static/html/icons-svg-inline.html
xarray/testing.py
xarray/tests/__init__.py
xarray/tests/data/bears.nc
xarray/tests/data/example.grib
xarray/tests/data/example.ict
xarray/tests/data/example.uamiv
xarray/tests/data/example_1.nc
xarray/tests/data/example_1.nc.gz
xarray/tests/test_accessor_dt.py
xarray/tests/test_accessor_str.py
xarray/tests/test_backends.py
xarray/tests/test_backends_api.py
xarray/tests/test_backends_common.py
xarray/tests/test_backends_file_manager.py
xarray/tests/test_backends_locks.py
xarray/tests/test_backends_lru_cache.py
xarray/tests/test_cftime_offsets.py
xarray/tests/test_cftimeindex.py
xarray/tests/test_cftimeindex_resample.py
xarray/tests/test_coding.py
xarray/tests/test_coding_strings.py
xarray/tests/test_coding_times.py
xarray/tests/test_combine.py
xarray/tests/test_computation.py
xarray/tests/test_concat.py
xarray/tests/test_conventions.py
xarray/tests/test_dask.py
xarray/tests/test_dataarray.py
xarray/tests/test_dataset.py
xarray/tests/test_distributed.py
xarray/tests/test_dtypes.py
xarray/tests/test_duck_array_ops.py
xarray/tests/test_extensions.py
xarray/tests/test_formatting.py
xarray/tests/test_formatting_html.py
xarray/tests/test_groupby.py
xarray/tests/test_indexing.py
xarray/tests/test_interp.py
xarray/tests/test_merge.py
xarray/tests/test_missing.py
xarray/tests/test_nputils.py
xarray/tests/test_options.py
xarray/tests/test_plot.py
xarray/tests/test_print_versions.py
xarray/tests/test_sparse.py
xarray/tests/test_testing.py
xarray/tests/test_tutorial.py
xarray/tests/test_ufuncs.py
xarray/tests/test_units.py
xarray/tests/test_utils.py
xarray/tests/test_variable.py
xarray/tutorial.py
xarray/ufuncs.py
xarray/util/__init__.py
xarray/util/print_versions.py
```


# The last commit

```
deda502c SWE-bench


```

```diff

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q`

## Scope
`xarray/core/merge.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when
`ds.merge(da)` with a named `DataArray` no longer raises `AttributeError: 'DataArray' object has no attribute 'items'`.
The result of `ds.merge(da)` is identical to `xr.merge([ds, da])` for the prompt’s example, containing both `a` and `b`.
Existing `Dataset.merge` and top-level `merge` behavior for mappings and `Dataset` inputs still passes the merge tests.

## Approach
Work is in `dataset_merge_method` in `xarray/core/merge.py`: unlike top-level `merge`, it passes `other` straight into `merge_core`, so a `DataArray` reaches `coerce_pandas_values`, which calls `.items()`. Normalize a `DataArray` argument before building the merge objects, mirroring top-level `merge`’s conversion of a `DataArray` into a one-entry mapping.

Candidate approaches:
1. Normalize `other` at the top of `dataset_merge_method`: `if isinstance(other, DataArray): other = {other.name: other}`. Smallest change, mirrors top-level `merge`, and covers all `overwrite_vars` branches; requires a local import to avoid the circular import.
2. Convert in `Dataset.merge` in `xarray/core/dataset.py` before calling `dataset_merge_method`. Equally small and keeps merge.py unchanged, but puts normalization in the method layer rather than in the shared merge logic.
3. Teach `coerce_pandas_values` and `collect_variables_and_indexes` to pass through or convert `DataArray` natively. More invasive and risks changing alignment, priority, and attribute handling; do this only if normalization alone fails on some `overwrite_vars` path.

If option 1 breaks the `overwrite_vars` branch because that branch assumes `other` is a `Dataset`, convert with `other.to_dataset()` inside that branch only, or normalize at the point where `objs` is passed to `merge_core`. Then reproduce the MWE and run the scoped tests.
```

### `prompt.md`

````
Merging dataArray into dataset using dataset method fails
While it's possible to merge a dataset and a dataarray object using the top-level `merge()` function, if you try the same thing with the `ds.merge()` method it fails.

```python
import xarray as xr

ds = xr.Dataset({'a': 0})
da = xr.DataArray(1, name='b')

expected = xr.merge([ds, da])  # works fine
print(expected)

ds.merge(da)  # fails
```

Output:
```
<xarray.Dataset>
Dimensions:  ()
Data variables:
    a        int64 0
    b        int64 1

Traceback (most recent call last):
  File "mwe.py", line 6, in <module>
    actual = ds.merge(da)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/dataset.py", line 3591, in merge
    fill_value=fill_value,
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 835, in dataset_merge_method
    objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 548, in merge_core
    coerced = coerce_pandas_values(objects)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 394, in coerce_pandas_values
    for k, v in obj.items():
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/common.py", line 233, in __getattr__
    "{!r} object has no attribute {!r}".format(type(self).__name__, name)
AttributeError: 'DataArray' object has no attribute 'items'
```
````

### `review.md`

```
verdict: PASS
- `dataset_merge_method` now converts a `DataArray` to a `Dataset` via `to_dataset()` before the merge, so `ds.merge(named_da)` follows the same path as `xr.merge([ds, named_da])` and produces both `a` and `b`.
- The added test checks the named-`DataArray` identity against `xr.merge` and the unnamed-`DataArray` `ValueError`, covering the requested behavior.
- The six failing tests in the check are unrelated pre-existing `CFTimeIndex`/pandas `_cache` failures; the evidence says the baseline check fails the same way, and no merge test is added to the failing set.
- The change is confined to `xarray/core/merge.py`, `xarray/core/dataset.py`, and `xarray/tests/test_merge.py`; existing `Dataset`/mapping merge behavior remains covered by the passing merge tests.
```

### `scope.txt`

```
scope: xarray/core/merge.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataset.py +3 -3
changed: xarray/core/merge.py +6 -1
changed: xarray/tests/test_merge.py +11 -0
```

### `task.md`

````
# Task

## Prompt

Merging dataArray into dataset using dataset method fails
While it's possible to merge a dataset and a dataarray object using the top-level `merge()` function, if you try the same thing with the `ds.merge()` method it fails.

```python
import xarray as xr

ds = xr.Dataset({'a': 0})
da = xr.DataArray(1, name='b')

expected = xr.merge([ds, da])  # works fine
print(expected)

ds.merge(da)  # fails
```

Output:
```
<xarray.Dataset>
Dimensions:  ()
Data variables:
    a        int64 0
    b        int64 1

Traceback (most recent call last):
  File "mwe.py", line 6, in <module>
    actual = ds.merge(da)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/dataset.py", line 3591, in merge
    fill_value=fill_value,
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 835, in dataset_merge_method
    objs, compat, join, priority_arg=priority_arg, fill_value=fill_value
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 548, in merge_core
    coerced = coerce_pandas_values(objects)
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/merge.py", line 394, in coerce_pandas_values
    for k, v in obj.items():
  File "/home/tegn500/Documents/Work/Code/xarray/xarray/core/common.py", line 233, in __getattr__
    "{!r} object has no attribute {!r}".format(type(self).__name__, name)
AttributeError: 'DataArray' object has no attribute 'items'
```

## Deliverable

changes to this tree

## Check

`python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q`

## Scope

`xarray/core/merge.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when

`ds.merge(da)` with a named `DataArray` no longer raises `AttributeError: 'DataArray' object has no attribute 'items'`.
The result of `ds.merge(da)` is identical to `xr.merge([ds, da])` for the prompt’s example, containing both `a` and `b`.
Existing `Dataset.merge` and top-level `merge` behavior for mappings and `Dataset` inputs still passes the merge tests.
````

### `test-output.log`

```
check: python -m pytest xarray/tests/test_merge.py xarray/tests/test_dataset.py -q
........................................................................ [  8%]
....................................xX........F......................... [ 16%]
........................................................................ [ 24%]
........................................................................ [ 32%]
..............F......................................................... [ 40%]
........................................................................ [ 48%]
........................................................................ [ 56%]
.....................................................ssssssssssssssss... [ 64%]
........................................................................ [ 72%]
........................................................................ [ 80%]
........................................................................ [ 88%]
........................................................................ [ 96%]
....................FF....FF...                                          [100%]
=================================== FAILURES ===================================
___________ TestDataset.test_rename_does_not_change_CFTimeIndex_type ___________

self = <xarray.tests.test_dataset.TestDataset object at 0x7433696d8700>

    @requires_cftime
    def test_rename_does_not_change_CFTimeIndex_type(self):
        # make sure CFTimeIndex is not converted to DatetimeIndex #3522
    
        time = xr.cftime_range(start="2000", periods=6, freq="2MS", calendar="noleap")
>       orig = Dataset(coords={"time": time})

xarray/tests/test_dataset.py:2480: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataset.py:547: in __init__
    variables, coord_names, dims, indexes = merge_data_and_coords(
xarray/core/merge.py:465: in merge_data_and_coords
    indexes = dict(_extract_indexes_from_coords(coords))
xarray/core/merge.py:476: in _extract_indexes_from_coords
    yield name, variable.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-03-01 00:00:00, 2000-05-01 00:00:00,
             2000-07-01 00:00:00, 2000-09-01 00:00:00, 2000-11-01 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
        times = xr.cftime_range("2000", periods=6)
>       da = xr.DataArray(range(6), [("time", times)])

xarray/tests/test_dataset.py:5566: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-02 00:00:00, 2000-01-03 00:00:00,
             2000-01-04 00:00:00, 2000-01-05 00:00:00, 2000-01-06 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason="Test requires cftime.")
    @pytest.mark.parametrize("dask", [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
        coord = xr.cftime_range("2000", periods=8, freq="2M")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5810: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-31 00:00:00, 2000-03-31 00:00:00, 2000-05-31 00:00:00,
             2000-07-31 00:00:00, 2000-09-30 00:00:00, 2000-11-30 00:00:00,
             2001-01-31 00:00:00, 2001-03-31 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize("dask", [True, False])
    @pytest.mark.parametrize("which_datetime", ["np", "cftime"])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == "np":
            coord = np.array(
                [
                    "2004-07-13",
                    "2006-01-13",
                    "2010-08-13",
                    "2010-09-13",
                    "2010-10-11",
                    "2010-12-13",
                    "2011-02-13",
                    "2012-08-13",
                ],
                dtype="datetime64",
            )
        else:
            if not has_cftime:
                pytest.skip("Test requires cftime.")
            coord = xr.cftime_range("2000", periods=8, freq="2D")
    
>       da = xr.DataArray(
            rs.randn(8, 6),
            coords={"time": coord, "z": 3, "t2d": (("time", "y"), rs.randn(8, 6))},
            dims=["time", "y"],
        )

xarray/tests/test_dataset.py:5910: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/core/dataarray.py:356: in __init__
    coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
xarray/core/dataarray.py:163: in _infer_coords_and_dims
    assert_unique_multiindex_level_names(new_coords)
xarray/core/variable.py:2349: in assert_unique_multiindex_level_names
    idx_level_names = var.to_index_variable().level_names
xarray/core/variable.py:2211: in level_names
    index = self.to_index()
xarray/core/variable.py:2203: in to_index
    index = index.set_names(self.name)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/_decorators.py:331: in wrapper
    return func(*args, **kwargs)
/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:1957: in set_names
    idx = self._view()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = CFTimeIndex([2000-01-01 00:00:00, 2000-01-03 00:00:00, 2000-01-05 00:00:00,
             2000-01-07 00:00:00, 2000-01-09 00:00:00, 2000-01-11 00:00:00,
             2000-01-13 00:00:00, 2000-01-15 00:00:00],
            dtype='object')

    def _view(self: _IndexT) -> _IndexT:
        """
        fastpath to make a shallow copy, i.e. new object with same data.
        """
        result = self._simple_new(self._values, name=self._name)
    
>       result._cache = self._cache
E       AttributeError: 'CFTimeIndex' object has no attribute '_cache'

/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/core/indexes/base.py:827: AttributeError
=============================== warnings summary ===============================
xarray/core/dask_array_compat.py:13
xarray/core/dask_array_compat.py:13
  /testbed/xarray/core/dask_array_compat.py:13: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:100
xarray/core/dask_array_compat.py:100
  /testbed/xarray/core/dask_array_compat.py:100: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:137
xarray/core/dask_array_compat.py:137
  /testbed/xarray/core/dask_array_compat.py:137: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/formatting_html.py:6
  /testbed/xarray/core/formatting_html.py:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/test_merge.py: 17 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_merge.py: 4 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/xarray/core/alignment.py:298: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataset.py: 349 warnings
  /testbed/xarray/core/formatting.py:142: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/tests/__init__.py:55: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/core/merge.py:393: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = dict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
xarray/tests/test_dataset.py::TestDataset::test_dask_is_lazy
  /testbed/xarray/core/variable.py:986: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) < "2.0.0":

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/xarray/core/indexing.py:179: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    indexer = index.get_loc(

xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataset.py: 12 warnings
  /testbed/xarray/coding/cftimeindex.py:112: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py: 54 warnings
  /testbed/xarray/coding/cftime_offsets.py:243: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(cftime.__version__) < LooseVersion("1.0.4"):

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2824: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds.unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2825: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    assert actual["var"].dtype == np.int

xarray/tests/test_dataset.py::TestDataset::test_unstack_fill_value
  /testbed/xarray/tests/test_dataset.py:2829: DeprecationWarning: `np.int` is a deprecated alias for the builtin `int`. To silence this warning, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    expected = ds["var"].unstack("index").fillna(-1).astype(np.int)

xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
xarray/tests/test_dataset.py::TestDataset::test_groupby_math
  /testbed/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataset.py: 11 warnings
  /testbed/xarray/core/common.py:1044: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py: 11 warnings
  /testbed/xarray/core/groupby.py:347: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/core/common.py:1044: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/tests/test_dataset.py:3656: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    ds.bar.to_series().resample("24H", loffset="-12H").mean()

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:535: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method="nearest")

xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:536: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method="nearest")

xarray/tests/test_dataset.py: 63 warnings
  /testbed/xarray/core/variable.py:1751: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    return np.moveaxis(np.nanpercentile(npa, **kwargs), 0, -1)

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/xarray/tests/test_dataset.py:5558: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={"time": pd.date_range("15/12/1999", periods=364)},

xarray/tests/test_dataset.py::test_trapz_datetime[np-True]
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/array/core.py:1706: FutureWarning: The `numpy.trapz` function is not implemented by Dask array. You may want to use the da.map_blocks function or something similar to silence this warning. Your code may stop working in a future release.
    warnings.warn(

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_rename_does_not_change_CFTimeIndex_type
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - AttributeEr...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - Attrib...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Attri...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Attr...
6 failed, 871 passed, 16 skipped, 1 xfailed, 1 xpassed, 586 warnings in 28.48s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: xarray/core/merge.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataset.py +3 -3
changed: xarray/core/merge.py +6 -1
changed: xarray/tests/test_merge.py +11 -0
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
