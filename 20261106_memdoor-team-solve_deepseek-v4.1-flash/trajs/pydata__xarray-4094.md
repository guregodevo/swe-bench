# pydata__xarray-4094 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 300s 37 lines cost=0.010268 in=195974 cached=130560 out=20767 calls=19`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

to_unstacked_dataset broken for single-dim variables
<!-- A short summary of the issue, if appropriate -->


#### MCVE Code Sample

```python
arr = xr.DataArray(
     np.arange(3),
     coords=[("x", [0, 1, 2])],
 )
data = xr.Dataset({"a": arr, "b": arr})
stacked = data.to_stacked_array('y', sample_dims=['x'])
unstacked = stacked.to_unstacked_dataset('y')
# MergeError: conflicting values for variable 'y' on objects to be combined. You can skip this check by specifying compat='override'.
```

#### Expected Output
A working roundtrip.

#### Problem Description
I need to stack a bunch of variables and later unstack them again, however this doesn't work if the variables only have a single dimension.

#### Versions

<details><summary>Output of <tt>xr.show_versions()</tt></summary>

INSTALLED VERSIONS
------------------
commit: None
python: 3.7.3 (default, Mar 27 2019, 22:11:17) 
[GCC 7.3.0]
python-bits: 64
OS: Linux
OS-release: 4.15.0-96-generic
machine: x86_64
processor: x86_64
byteorder: little
LC_ALL: None
LANG: en_GB.UTF-8
LOCALE: en_GB.UTF-8
libhdf5: 1.10.4
libnetcdf: 4.6.2

xarray: 0.15.1
pandas: 1.0.3
numpy: 1.17.3
scipy: 1.3.1
netCDF4: 1.4.2
pydap: None
h5netcdf: None
h5py: 2.10.0
Nio: None
zarr: None
cftime: 1.0.4.2
nc_time_axis: None
PseudoNetCDF: None
rasterio: None
cfgrib: None
iris: None
bottleneck: None
dask: 2.10.1
distributed: 2.10.0
matplotlib: 3.1.1
cartopy: None
seaborn: 0.10.0
numbagg: None
setuptools: 41.0.0
pip: 19.0.3
conda: 4.8.3
pytest: 5.3.5
IPython: 7.9.0
sphinx: None


</details>


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -1 && grep -rn \"to_unstacked_dataset\" xarray --include=*.py | head -20"
}
```

**tool result**

```
CODE_OF_CONDUCT.md
CONTRIBUTING.md
HOW_TO_RELEASE.md
LICENSE
MANIFEST.in
README.rst
asv_bench
azure-pipelines.yml
ci
conftest.py
doc
licenses
properties
readthedocs.yml
requirements.txt
setup.cfg
setup.py
xarray
xarray.egg-info
58761b01 SWE-bench
xarray/core/dataset.py:3410:        DataArray.to_unstacked_dataset
xarray/core/dataarray.py:1901:    def to_unstacked_dataset(self, dim, level=0):
xarray/core/dataarray.py:1944:        >>> roundtripped = stacked.to_unstacked_dataset(dim="z")
xarray/tests/test_units.py:3481:    def test_to_unstacked_dataset(self, dtype):
xarray/tests/test_units.py:3493:        func = method("to_unstacked_dataset", dim="z")
xarray/tests/test_dataset.py:3033:    def test_to_stacked_array_to_unstacked_dataset(self):
xarray/tests/test_dataset.py:3040:        x = y.to_unstacked_dataset("features")
xarray/tests/test_dataset.py:3044:        x0 = y[0].to_unstacked_dataset("features")
xarray/tests/test_dataset.py:3048:    def test_to_stacked_array_to_unstacked_dataset_different_dimension(self):
xarray/tests/test_dataset.py:3055:        x = y.to_unstacked_dataset("features")
xarray/tests/test_dataarray.py:2132:    def test_to_unstacked_dataset_raises_value_error(self):
xarray/tests/test_dataarray.py:2135:            data.to_unstacked_dataset("x", 0)
```

**assistant → tool `read_file`**

```json
{
  "path": "xarray/core/dataarray.py",
  "offset": 1890,
  "limit": 90
}
```

**tool result**

```
        >>> roundtripped = stacked.unstack()
        >>> arr.identical(roundtripped)
        True

        See Also
        --------
        DataArray.stack
        """
        ds = self._to_temp_dataset().unstack(dim, fill_value, sparse)
        return self._from_temp_dataset(ds)

    def to_unstacked_dataset(self, dim, level=0):
        """Unstack DataArray expanding to Dataset along a given level of a
        stacked coordinate.

        This is the inverse operation of Dataset.to_stacked_array.

        Parameters
        ----------
        dim : str
            Name of existing dimension to unstack
        level : int or str
            The MultiIndex level to expand to a dataset along. Can either be
            the integer index of the level or its name.
        label : int, default 0
            Label of the level to expand dataset along. Overrides the label
            argument if given.

        Returns
        -------
        unstacked: Dataset

        Examples
        --------
        >>> import xarray as xr
        >>> arr = xr.DataArray(
        ...     np.arange(6).reshape(2, 3),
        ...     coords=[("x", ["a", "b"]), ("y", [0, 1, 2])],
        ... )
        >>> data = xr.Dataset({"a": arr, "b": arr.isel(y=0)})
        >>> data
        <xarray.Dataset>
        Dimensions:  (x: 2, y: 3)
        Coordinates:
          * x        (x) <U1 'a' 'b'
          * y        (y) int64 0 1 2
        Data variables:
            a        (x, y) int64 0 1 2 3 4 5
            b        (x) int64 0 3
        >>> stacked = data.to_stacked_array("z", ["y"])
        >>> stacked.indexes["z"]
        MultiIndex(levels=[['a', 'b'], [0, 1, 2]],
                labels=[[0, 0, 0, 1], [0, 1, 2, -1]],
                names=['variable', 'y'])
        >>> roundtripped = stacked.to_unstacked_dataset(dim="z")
        >>> data.identical(roundtripped)
        True

        See Also
        --------
        Dataset.to_stacked_array
        """

        idx = self.indexes[dim]
        if not isinstance(idx, pd.MultiIndex):
            raise ValueError(f"'{dim}' is not a stacked coordinate")

        level_number = idx._get_level_number(level)
        variables = idx.levels[level_number]
        variable_dim = idx.names[level_number]

        # pull variables out of datarray
        data_dict = {}
        for k in variables:
            data_dict[k] = self.sel({variable_dim: k}).squeeze(drop=True)

        # unstacked dataset
        return Dataset(data_dict)

    def transpose(self, *dims: Hashable, transpose_coords: bool = True) -> "DataArray":
        """Return a new DataArray object with transposed dimensions.

        Parameters
        ----------
        *dims : hashable, optional
            By default, reverse the dimensions. Otherwise, reorder the
            dimensions to this order.
        transpose_coords : boolean, default True
            If True, also transpose the coordinates of this DataArray.


[1849 more lines in /testbed/xarray/core/dataarray.py (3828 in all). read_file with offset: 1980 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np, xarray as xr\narr = xr.DataArray(np.arange(3), coords=[(\"x\",[0,1,2])])\ndata = xr.Dataset({\"a\":arr,\"b\":arr})\ns = data.to_stacked_array('y', sample_dims=['x'])\nprint(s)\nprint(s.indexes['y'])\nprint(s.coords)\ntry:\n print(s.to_unstacked_dataset('y'))\nexcept Exception as e:\n import traceback; traceback.print_exc()\nEOF"
}
```

**tool result**

```
Traceback (most recent call last):
  File "<stdin>", line 9, in <module>
  File "/testbed/xarray/core/dataarray.py", line 1967, in to_unstacked_dataset
    return Dataset(data_dict)
  File "/testbed/xarray/core/dataset.py", line 543, in __init__
    variables, coord_names, dims, indexes, _ = merge_data_and_coords(
  File "/testbed/xarray/core/merge.py", line 466, in merge_data_and_coords
    return merge_core(
  File "/testbed/xarray/core/merge.py", line 597, in merge_core
    variables, out_indexes = merge_collected(collected, prioritized, compat=compat)
  File "/testbed/xarray/core/merge.py", line 228, in merge_collected
    merged_vars[name] = unique_variable(name, variables, compat)
  File "/testbed/xarray/core/merge.py", line 142, in unique_variable
    raise MergeError(
xarray.core.merge.MergeError: conflicting values for variable 'y' on objects to be combined. You can skip this check by specifying compat='override'.
<xarray.DataArray 'a' (x: 3, y: 2)>
array([[0, 0],
       [1, 1],
       [2, 2]])
Coordinates:
  * x         (x) int64 0 1 2
  * y         (y) MultiIndex
  - variable  (y) object 'a' 'b'
MultiIndex([('a',),
            ('b',)],
           names=['variable'])
Coordinates:
  * x         (x) int64 0 1 2
  * y         (y) MultiIndex
  - variable  (y) object 'a' 'b'
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '3010,3070p' xarray/tests/test_dataset.py && sed -n '2110,2145p' xarray/tests/test_dataarray.py && grep -n \"def to_stacked_array\" -A120 xarray/core/dataset.py | head -150"
}
```

**tool result**

```
        with pytest.raises(ValueError):
            data.to_stacked_array("features", sample_dims=["y"])

    def test_to_stacked_array_name(self):
        name = "adf9d"

        # make a two dimensional dataset
        a, b = create_test_stacked_array()
        D = xr.Dataset({"a": a, "b": b})
        sample_dims = ["x"]

        y = D.to_stacked_array("features", sample_dims, name=name)
        assert y.name == name

    def test_to_stacked_array_dtype_dims(self):
        # make a two dimensional dataset
        a, b = create_test_stacked_array()
        D = xr.Dataset({"a": a, "b": b})
        sample_dims = ["x"]
        y = D.to_stacked_array("features", sample_dims)
        assert y.indexes["features"].levels[1].dtype == D.y.dtype
        assert y.dims == ("x", "features")

    def test_to_stacked_array_to_unstacked_dataset(self):
        # make a two dimensional dataset
        a, b = create_test_stacked_array()
        D = xr.Dataset({"a": a, "b": b})
        sample_dims = ["x"]
        y = D.to_stacked_array("features", sample_dims).transpose("x", "features")

        x = y.to_unstacked_dataset("features")
        assert_identical(D, x)

        # test on just one sample
        x0 = y[0].to_unstacked_dataset("features")
        d0 = D.isel(x=0)
        assert_identical(d0, x0)

    def test_to_stacked_array_to_unstacked_dataset_different_dimension(self):
        # test when variables have different dimensionality
        a, b = create_test_stacked_array()
        sample_dims = ["x"]
        D = xr.Dataset({"a": a, "b": b.isel(y=0)})

        y = D.to_stacked_array("features", sample_dims)
        x = y.to_unstacked_dataset("features")
        assert_identical(D, x)

    def test_update(self):
        data = create_test_data(seed=0)
        expected = data.copy()
        var2 = Variable("dim1", np.arange(8))
        actual = data.update({"var2": var2})
        expected["var2"] = var2
        assert_identical(expected, actual)

        actual = data.copy()
        actual_result = actual.update(data)
        assert actual_result is actual
        assert_identical(expected, actual)

            dims=("y", "x"),
            coords={"x": np.arange(4), "y": np.arange(3, 0, -1)},
        )
        stacked = orig.stack(allpoints=["y", "x"])
        actual = stacked.unstack("allpoints")
        assert_identical(orig, actual)

    def test_unstack_pandas_consistency(self):
        df = pd.DataFrame({"foo": range(3), "x": ["a", "b", "b"], "y": [0, 0, 1]})
        s = df.set_index(["x", "y"])["foo"]
        expected = DataArray(s.unstack(), name="foo")
        actual = DataArray(s, dims="z").unstack("z")
        assert_identical(expected, actual)

    def test_stack_nonunique_consistency(self):
        orig = DataArray(
            [[0, 1], [2, 3]], dims=["x", "y"], coords={"x": [0, 1], "y": [0, 0]}
        )
        actual = orig.stack(z=["x", "y"])
        expected = DataArray(orig.to_pandas().stack(), dims="z")
        assert_identical(expected, actual)

    def test_to_unstacked_dataset_raises_value_error(self):
        data = DataArray([0, 1], dims="x", coords={"x": [0, 1]})
        with pytest.raises(ValueError, match="'x' is not a stacked coordinate"):
            data.to_unstacked_dataset("x", 0)

    def test_transpose(self):
        da = DataArray(
            np.random.randn(3, 4, 5),
            dims=("x", "y", "z"),
            coords={
                "x": range(3),
                "y": range(4),
                "z": range(5),
                "xy": (("x", "y"), np.random.randn(3, 4)),
3370:    def to_stacked_array(
3371-        self,
3372-        new_dim: Hashable,
3373-        sample_dims: Sequence[Hashable],
3374-        variable_dim: str = "variable",
3375-        name: Hashable = None,
3376-    ) -> "DataArray":
3377-        """Combine variables of differing dimensionality into a DataArray
3378-        without broadcasting.
3379-
3380-        This method is similar to Dataset.to_array but does not broadcast the
3381-        variables.
3382-
3383-        Parameters
3384-        ----------
3385-        new_dim : Hashable
3386-            Name of the new stacked coordinate
3387-        sample_dims : Sequence[Hashable]
3388-            Dimensions that **will not** be stacked. Each array in the dataset
3389-            must share these dimensions. For machine learning applications,
3390-            these define the dimensions over which samples are drawn.
3391-        variable_dim : str, optional
3392-            Name of the level in the stacked coordinate which corresponds to
3393-            the variables.
3394-        name : str, optional
3395-            Name of the new data array.
3396-
3397-        Returns
3398-        -------
3399-        stacked : DataArray
3400-            DataArray with the specified dimensions and data variables
3401-            stacked together. The stacked coordinate is named ``new_dim``
3402-            and represented by a MultiIndex object with a level containing the
3403-            data variable names. The name of this level is controlled using
3404-            the ``variable_dim`` argument.
3405-
3406-        See Also
3407-        --------
3408-        Dataset.to_array
3409-        Dataset.stack
3410-        DataArray.to_unstacked_dataset
3411-
3412-        Examples
3413-        --------
3414-        >>> data = xr.Dataset(
3415-        ...     data_vars={
3416-        ...         "a": (("x", "y"), [[0, 1, 2], [3, 4, 5]]),
3417-        ...         "b": ("x", [6, 7]),
3418-        ...     },
3419-        ...     coords={"y": ["u", "v", "w"]},
3420-        ... )
3421-
3422-        >>> data
3423-        <xarray.Dataset>
3424-        Dimensions:  (x: 2, y: 3)
3425-        Coordinates:
3426-        * y        (y) <U1 'u' 'v' 'w'
3427-        Dimensions without coordinates: x
3428-        Data variables:
3429-            a        (x, y) int64 0 1 2 3 4 5
3430-            b        (x) int64 6 7
3431-
3432-        >>> data.to_stacked_array("z", sample_dims=["x"])
3433-        <xarray.DataArray (x: 2, z: 4)>
3434-        array([[0, 1, 2, 6],
3435-            [3, 4, 5, 7]])
3436-        Coordinates:
3437-        * z         (z) MultiIndex
3438-        - variable  (z) object 'a' 'a' 'a' 'b'
3439-        - y         (z) object 'u' 'v' 'w' nan
3440-        Dimensions without coordinates: x
3441-
3442-        """
3443-        stacking_dims = tuple(dim for dim in self.dims if dim not in sample_dims)
3444-
3445-        for variable in self:
3446-            dims = self[variable].dims
3447-            dims_include_sample_dims = set(sample_dims) <= set(dims)
3448-            if not dims_include_sample_dims:
3449-                raise ValueError(
3450-                    "All variables in the dataset must contain the "
3451-                    "dimensions {}.".format(dims)
3452-                )
3453-
3454-        def ensure_stackable(val):
3455-            assign_coords = {variable_dim: val.name}
3456-            for dim in stacking_dims:
3457-                if dim not in val.dims:
3458-                    assign_coords[dim] = None
3459-
3460-            expand_dims = set(stacking_dims).difference(set(val.dims))
3461-            expand_dims.add(variable_dim)
3462-            # must be list for .expand_dims
3463-            expand_dims = list(expand_dims)
3464-
3465-            return (
3466-                val.assign_coords(**assign_coords)
3467-                .expand_dims(expand_dims)
3468-                .stack({new_dim: (variable_dim,) + stacking_dims})
3469-            )
3470-
3471-        # concatenate the arrays
3472-        stackable_vars = [ensure_stackable(self[key]) for key in self.data_vars]
3473-        data_array = xr.concat(stackable_vars, dim=new_dim)
3474-
3475-        # coerce the levels of the MultiIndex to have the same type as the
3476-        # input dimensions. This code is messy, so it might be better to just
3477-        # input a dummy value for the singleton dimension.
3478-        idx = data_array.indexes[new_dim]
3479-        levels = [idx.levels[0]] + [
3480-            level.astype(self[level.name].dtype) for level in idx.levels[1:]
3481-        ]
3482-        new_idx = idx.set_levels(levels)
3483-        data_array[new_dim] = IndexVariable(new_dim, new_idx)
3484-
3485-        if name is not None:
3486-            data_array.name = name
3487-
3488-        return data_array
3489-
3490-    def _unstack_once(self, dim: Hashable, fill_value, sparse) -> "Dataset":
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np, xarray as xr\narr = xr.DataArray(np.arange(3), coords=[(\"x\",[0,1,2])])\ndata = xr.Dataset({\"a\":arr,\"b\":arr})\ns = data.to_stacked_array('y', sample_dims=['x'])\nidx=s.indexes['y']; vn=idx.names[0]; vd=idx.levels[0]\nfor k in vd:\n x=s.sel({'variable':k}).squeeze(drop=True)\n print(repr(k)); print(x); print('coords',x.coords)\nEOF"
}
```

**tool result**

```
'a'
<xarray.DataArray 'a' (x: 3)>
array([0, 1, 2])
Coordinates:
  * x        (x) int64 0 1 2
    y        object ('a',)
coords Coordinates:
  * x        (x) int64 0 1 2
    y        object ('a',)
'b'
<xarray.DataArray 'a' (x: 3)>
array([0, 1, 2])
Coordinates:
  * x        (x) int64 0 1 2
    y        object ('b',)
coords Coordinates:
  * x        (x) int64 0 1 2
    y        object ('b',)
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np, xarray as xr\narr=xr.DataArray(np.arange(6).reshape(2,3),coords=[(\"x\",[\"a\",\"b\"]),(\"y\",[0,1,2])])\ndata=xr.Dataset({\"a\":arr,\"b\":arr.isel(y=0)})\ns=data.to_stacked_array(\"z\",[\"y\"])\nprint(s)\nidx=s.indexes['z']\nfor k in idx.levels[0]:\n x=s.sel({'variable':k}).squeeze(drop=True)\n print(x)\n print('coords',x.coords)\nEOF"
}
```

**tool result**

```
Command FAILED (exit status 1): `python - <<'EOF'
import numpy as np, xarray as xr
arr=xr.DataArray(np.arange(6).reshape(2,3),coords=[("x",["a","b"]),("y",[0,1,2])])
data=xr.Dataset({"a":arr,"b":arr.isel(y=0)})
s=data.to_stacked_array("z",["y"])
print(s)
idx=s.indexes['z']
for k in idx.levels[0]:
 x=s.sel({'variable':k}).squeeze(drop=True)
 print(x)
 print('coords',x.coords)
EOF`
Output: Traceback (most recent call last):
  File "<stdin>", line 4, in <module>
  File "/testbed/xarray/core/dataset.py", line 3449, in to_stacked_array
    raise ValueError(
ValueError: All variables in the dataset must contain the dimensions ('x',).

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np, xarray as xr\narr=xr.DataArray(np.arange(6).reshape(2,3),coords=[(\"x\",[\"a\",\"b\"]),(\"y\",[0,1,2])])\ndata=xr.Dataset({\"a\":arr,\"b\":arr.isel(y=0)})\ns=data.to_stacked_array(\"z\",[\"x\"])\nprint(s)\nidx=s.indexes['z']\nfor k in idx.levels[0]:\n x=s.sel({'variable':k}).squeeze(drop=True)\n print(x)\n print('coords',x.coords)\nEOF"
}
```

**tool result**

```
<xarray.DataArray 'a' (x: 2, z: 4)>
array([[0, 1, 2, 0],
       [3, 4, 5, 3]])
Coordinates:
  * x         (x) <U1 'a' 'b'
  * z         (z) MultiIndex
  - variable  (z) object 'a' 'a' 'a' 'b'
  - y         (z) float64 0.0 1.0 2.0 nan
<xarray.DataArray 'a' (x: 2, y: 3)>
array([[0, 1, 2],
       [3, 4, 5]])
Coordinates:
  * x        (x) <U1 'a' 'b'
  * y        (y) int64 0 1 2
coords Coordinates:
  * x        (x) <U1 'a' 'b'
  * y        (y) int64 0 1 2
<xarray.DataArray 'a' (x: 2)>
array([0, 3])
Coordinates:
  * x        (x) <U1 'a' 'b'
coords Coordinates:
  * x        (x) <U1 'a' 'b'
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def drop_vars\\|def drop(\" xarray/core/dataarray.py | head"
}
```

**tool result**

```
2012:    def drop_vars(
2034:    def drop(
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '2012,2045p' xarray/core/dataarray.py; grep -n \"def reset_index\\|def _replace\" xarray/core/dataarray.py | head; grep -n \"def _to_temp_dataset\\|def _from_temp_dataset\" xarray/core/dataarray.py"
}
```

**tool result**

```
    def drop_vars(
        self, names: Union[Hashable, Iterable[Hashable]], *, errors: str = "raise"
    ) -> "DataArray":
        """Drop variables from this DataArray.

        Parameters
        ----------
        names : hashable or iterable of hashables
            Name(s) of variables to drop.
        errors: {'raise', 'ignore'}, optional
            If 'raise' (default), raises a ValueError error if any of the variable
            passed are not in the dataset. If 'ignore', any given names that are in the
            DataArray are dropped and no error is raised.

        Returns
        -------
        dropped : Dataset

        """
        ds = self._to_temp_dataset().drop_vars(names, errors=errors)
        return self._from_temp_dataset(ds)

    def drop(
        self,
        labels: Mapping = None,
        dim: Hashable = None,
        *,
        errors: str = "raise",
        **labels_kwargs,
    ) -> "DataArray":
        """Backward compatible method based on `drop_vars` and `drop_sel`

        Using either `drop_vars` or `drop_sel` is encouraged

361:    def _replace(
376:    def _replace_maybe_drop_dims(
1722:    def reset_index(
421:    def _to_temp_dataset(self) -> Dataset:
424:    def _from_temp_dataset(
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np, xarray as xr\narr = xr.DataArray(np.arange(3), coords=[(\"x\",[0,1,2])])\ndata = xr.Dataset({\"a\":arr,\"b\":arr})\ns = data.to_stacked_array('y', sample_dims=['x'])\nidx=s.indexes['y']; vd=idx.levels[0]\nd={}\nfor k in vd:\n x=s.sel({'variable':k}).squeeze(drop=True).drop_vars('y')\n print(x)\n d[k]=x\nprint(xr.Dataset(d))\nprint(data.identical(xr.Dataset(d)))\nEOF"
}
```

**tool result**

```
<xarray.DataArray 'a' (x: 3)>
array([0, 1, 2])
Coordinates:
  * x        (x) int64 0 1 2
<xarray.DataArray 'a' (x: 3)>
array([0, 1, 2])
Coordinates:
  * x        (x) int64 0 1 2
<xarray.Dataset>
Dimensions:  (x: 3)
Coordinates:
  * x        (x) int64 0 1 2
Data variables:
    a        (x) int64 0 1 2
    b        (x) int64 0 1 2
True


(this is the fourth time you have made nearly this same bash call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np, xarray as xr\narr=xr.DataArray(np.arange(6).reshape(2,3),coords=[(\"x\",[\"a\",\"b\"]),(\"y\",[0,1,2])])\ndata=xr.Dataset({\"a\":arr,\"b\":arr.isel(y=0)})\ns=data.to_stacked_array(\"z\",[\"x\"])\nidx=s.indexes['z']\nfor k in idx.levels[0]:\n x=s.sel({'variable':k}).squeeze(drop=True)\n print(x.coords)\n print('z' in x.coords, 'variable' in x.coords, 'y' in x.coords)\nEOF"
}
```

**tool result**

```
Coordinates:
  * x        (x) <U1 'a' 'b'
  * y        (y) int64 0 1 2
False False True
Coordinates:
  * x        (x) <U1 'a' 'b'
False False False


(this is the fifth time you have made nearly this same bash call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/xarray/core/dataarray.py\n@@\n         # pull variables out of datarray\n         data_dict = {}\n         for k in variables:\n-            data_dict[k] = self.sel({variable_dim: k}).squeeze(drop=True)\n+            data_dict[k] = (\n+                self.sel({variable_dim: k})\n+                .squeeze(drop=True)\n+                .drop_vars(dim, errors=\"ignore\")\n+            )\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/xarray/core/dataarray.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/xarray/core/dataarray.py now (3832 lines), around the change:
1961:        # pull variables out of datarray
1962:        data_dict = {}
1963:        for k in variables:
1964:            data_dict[k] = (
1965:                self.sel({variable_dim: k})
1966:                .squeeze(drop=True)
1967:                .drop_vars(dim, errors="ignore")
1968:            )
1969:
1970:        # unstacked dataset
1971:        return Dataset(data_dict)
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport numpy as np, xarray as xr\narr = xr.DataArray(np.arange(3), coords=[(\"x\",[0,1,2])])\ndata = xr.Dataset({\"a\":arr,\"b\":arr})\ns = data.to_stacked_array('y', sample_dims=['x'])\nu=s.to_unstacked_dataset('y')\nprint(u)\nprint(data.identical(u))\n# multidim existing\narr=xr.DataArray(np.arange(6).reshape(2,3),coords=[(\"x\",[\"a\",\"b\"]),(\"y\",[0,1,2])])\ndata=xr.Dataset({\"a\":arr,\"b\":arr.isel(y=0)})\ns=data.to_stacked_array(\"z\",[\"x\"])\nprint(data.identical(s.to_unstacked_dataset(\"z\")))\nEOF\npython -m pytest xarray/tests/test_dataset.py -k \"stacked_array or unstacked\" -q xarray/tests/test_dataarray.py 2>&1 | tail -10"
}
```

**tool result**

```
<xarray.Dataset>
Dimensions:  (x: 3)
Coordinates:
  * x        (x) int64 0 1 2
Data variables:
    a        (x) int64 0 1 2
    b        (x) int64 0 1 2
True
True
xarray/tests/test_dask.py:611
  /testbed/xarray/tests/test_dask.py:611: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dask.py:629
  /testbed/xarray/tests/test_dask.py:629: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
6 passed, 1702 deselected, 25 warnings in 6.68s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/xarray/tests/test_dataset.py\n@@\n     def test_to_stacked_array_to_unstacked_dataset_different_dimension(self):\n         # test when variables have different dimensionality\n         a, b = create_test_stacked_array()\n         sample_dims = [\"x\"]\n         D = xr.Dataset({\"a\": a, \"b\": b.isel(y=0)})\n \n         y = D.to_stacked_array(\"features\", sample_dims)\n         x = y.to_unstacked_dataset(\"features\")\n         assert_identical(D, x)\n \n+    def test_to_stacked_array_to_unstacked_dataset_single_dim(self):\n+        # test when variables only have a single (sample) dimension\n+        arr = xr.DataArray(np.arange(3), coords=[(\"x\", [0, 1, 2])])\n+        D = xr.Dataset({\"a\": arr, \"b\": arr})\n+\n+        y = D.to_stacked_array(\"features\", sample_dims=[\"x\"])\n+        x = y.to_unstacked_dataset(\"features\")\n+        assert_identical(D, x)\n+\n     def test_update(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/xarray/tests/test_dataset.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/xarray/tests/test_dataset.py now (6230 lines), around the change:
3055:        x = y.to_unstacked_dataset("features")
3056:        assert_identical(D, x)
3057:
3058:    def test_to_stacked_array_to_unstacked_dataset_single_dim(self):
3059:        # test when variables only have a single (sample) dimension
3060:        arr = xr.DataArray(np.arange(3), coords=[("x", [0, 1, 2])])
3061:        D = xr.Dataset({"a": arr, "b": arr})
3062:
3063:        y = D.to_stacked_array("features", sample_dims=["x"])
3064:        x = y.to_unstacked_dataset("features")
3065:        assert_identical(D, x)
3066:
3067:    def test_update(self):
3068:        data = create_test_data(seed=0)
3069:        expected = data.copy()
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataset.py -k \"stacked_array or unstacked\" -q 2>&1 | tail -3 && git diff --stat"
}
```

**tool result**

```

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
6 passed, 884 deselected, 11 warnings in 6.27s
 xarray/core/dataarray.py     | 6 +++++-
 xarray/tests/test_dataset.py | 9 +++++++++
 2 files changed, 14 insertions(+), 1 deletion(-)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataarray.py -k \"unstacked or stack\" -q 2>&1 | tail -3"
}
```

**tool result**

```

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
6 passed, 813 deselected, 28 warnings in 3.37s
```

**assistant**

````
Fixed.

**Cause:** `DataArray.to_unstacked_dataset` pulled each variable out of the MultiIndex with `.sel(...).squeeze(drop=True)`. For single-dim variables the MultiIndex has only the `variable` level, leaving a scalar coordinate `features` (the tuple `('a',)` / `('b',)`). Each extracted array carried a different scalar value for that coordinate, so `Dataset(data_dict)` failed with `MergeError: conflicting values for variable ...`.

**Fix** (`xarray/core/dataarray.py`): drop the now-unneeded stacked dimension coordinate from each extracted variable (using `errors="ignore"`, since for multi-level stacks the coordinate has already disappeared):

```python
data_dict[k] = (
    self.sel({variable_dim: k})
    .squeeze(drop=True)
    .drop_vars(dim, errors="ignore")
)
```

Added a regression test `test_to_stacked_array_to_unstacked_dataset_single_dim` in `xarray/tests/test_dataset.py` covering the MCVE roundtrip. Existing stacked/unstacked tests still pass.
````

## Run folder `team-solve-2026-11-06T123736`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
58761b01d75edf12556fbc9d0056af31e38c86b2
```

### `baseline-check.log`

```
check: pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"
============================= test session starts ==============================
platform linux -- Python 3.10.15, pytest-7.4.0, pluggy-1.5.0
rootdir: /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree
configfile: setup.cfg
plugins: cov-5.0.0, hypothesis-6.114.0, xdist-3.6.1, env-1.1.5
collected 1708 items / 1690 deselected / 18 selected

xarray/tests/test_dataarray.py ......                                    [ 33%]
xarray/tests/test_dataset.py ............                                [100%]

=============================== warnings summary ===============================
xarray/__init__.py:1
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/__init__.py:1: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/dask_array_compat.py:16
xarray/core/dask_array_compat.py:16
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/core/dask_array_compat.py:16: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:149
xarray/core/dask_array_compat.py:149
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/core/dask_array_compat.py:149: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:186
xarray/core/dask_array_compat.py:186
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/core/dask_array_compat.py:186: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/pdcompat.py:45
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/tests/__init__.py:54: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dask.py:593
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/tests/test_dask.py:593: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) >= "2.0", reason="no meta")

xarray/tests/test_dask.py:611
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/tests/test_dask.py:611: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dask.py:629
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/tests/test_dask.py:629: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/.memdoor/runs/team-solve-2026-11-06T123736/baseline-tree/xarray/tests/test_dataarray.py:2082: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    levels=[pd.Int64Index([]), pd.Int64Index([0])],

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
============== 18 passed, 1690 deselected, 28 warnings in 14.12s ===============
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/xarray/core/dataarray.py b/xarray/core/dataarray.py
index b0df8749..9dda6e8a 100755
--- a/xarray/core/dataarray.py
+++ b/xarray/core/dataarray.py
@@ -1961,7 +1961,11 @@ class DataArray(AbstractArray, DataWithCoords):
         # pull variables out of datarray
         data_dict = {}
         for k in variables:
-            data_dict[k] = self.sel({variable_dim: k}).squeeze(drop=True)
+            data_dict[k] = (
+                self.sel({variable_dim: k})
+                .squeeze(drop=True)
+                .drop_vars(dim, errors="ignore")
+            )
 
         # unstacked dataset
         return Dataset(data_dict)
diff --git a/xarray/tests/test_dataset.py b/xarray/tests/test_dataset.py
index 9c8d4072..64751620 100755
--- a/xarray/tests/test_dataset.py
+++ b/xarray/tests/test_dataset.py
@@ -3055,6 +3055,15 @@ class TestDataset:
         x = y.to_unstacked_dataset("features")
         assert_identical(D, x)
 
+    def test_to_stacked_array_to_unstacked_dataset_single_dim(self):
+        # test when variables only have a single (sample) dimension
+        arr = xr.DataArray(np.arange(3), coords=[("x", [0, 1, 2])])
+        D = xr.Dataset({"a": arr, "b": arr})
+
+        y = D.to_stacked_array("features", sample_dims=["x"])
+        x = y.to_unstacked_dataset("features")
+        assert_identical(D, x)
+
     def test_update(self):
         data = create_test_data(seed=0)
         expected = data.copy()
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

to_unstacked_dataset broken for single-dim variables
<!-- A short summary of the issue, if appropriate -->


#### MCVE Code Sample

```python
arr = xr.DataArray(
     np.arange(3),
     coords=[("x", [0, 1, 2])],
 )
data = xr.Dataset({"a": arr, "b": arr})
stacked = data.to_stacked_array('y', sample_dims=['x'])
unstacked = stacked.to_unstacked_dataset('y')
# MergeError: conflicting values for variable 'y' on objects to be combined. You can skip this check by specifying compat='override'.
```

#### Expected Output
A working roundtrip.

#### Problem Description
I need to stack a bunch of variables and later unstack them again, however this doesn't work if the variables only have a single dimension.

#### Versions

<details><summary>Output of <tt>xr.show_versions()</tt></summary>

INSTALLED VERSIONS
------------------
commit: None
python: 3.7.3 (default, Mar 27 2019, 22:11:17) 
[GCC 7.3.0]
python-bits: 64
OS: Linux
OS-release: 4.15.0-96-generic
machine: x86_64
processor: x86_64
byteorder: little
LC_ALL: None
LANG: en_GB.UTF-8
LOCALE: en_GB.UTF-8
libhdf5: 1.10.4
libnetcdf: 4.6.2

xarray: 0.15.1
pandas: 1.0.3
numpy: 1.17.3
scipy: 1.3.1
netCDF4: 1.4.2
pydap: None
h5netcdf: None
h5py: 2.10.0
Nio: None
zarr: None
cftime: 1.0.4.2
nc_time_axis: None
PseudoNetCDF: None
rasterio: None
cfgrib: None
iris: None
bottleneck: None
dask: 2.10.1
distributed: 2.10.0
matplotlib: 3.1.1
cartopy: None
seaborn: 0.10.0
numbagg: None
setuptools: 41.0.0
pip: 19.0.3
conda: 4.8.3
pytest: 5.3.5
IPython: 7.9.0
sphinx: None


</details>

## Deliverable

changes to this tree

## Check

`pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"`

## Scope

`xarray/core/dataarray.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when

- The MCVE runs to completion: stacking `{"a": arr, "b": arr}` over sample dim `x` and calling `to_unstacked_dataset("y")` raises no `MergeError`.
- The unstacked Dataset equals the original Dataset for variables that only have the sample dimension.
- (inferred) The existing roundtrip still works for variables that also have non-sample dimensions.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"`

## Scope
`xarray/core/dataarray.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when
- The MCVE runs to completion: stacking `{"a": arr, "b": arr}` over sample dim `x` and calling `to_unstacked_dataset("y")` raises no `MergeError`.
- The unstacked Dataset equals the original Dataset for variables that only have the sample dimension.
- (inferred) The existing roundtrip still works for variables that also have non-sample dimensions.

## Approach
Decomposition: reproduce the MCVE against the checked-out tree; find `to_unstacked_dataset` (the consuming half of the `to_stacked_array` / `to_unstacked_dataset` pair, implemented alongside `DataArray`/`Dataset`); identify where the per-variable selections are merged; make the selection drop the scalar coordinate along the stacked dimension (and any MultiIndex level coordinates) before merging; then run the scoped tests.

Root cause to confirm first: the loop selects `self.sel({dim: name})` for each variable name. For single-dim variables the only remaining coordinate on each selection is the scalar stacked-dim coordinate itself (e.g. `y`), whose value differs per selection, so the final merge sees conflicting values for `y`. Multi-dim variables happen to carry other coordinates that mask this.

Candidate approaches:
1. Minimal: add `drop=True` to each selection (`self.sel({dim: name}, drop=True)`), removing the offending scalar index coordinate; lowest risk, but may leave MultiIndex level scalars that still conflict or pollute the result.
2. Explicit: select, then `drop_vars` the stacked dim and its level coordinates, and transpose to the original dimension order before constructing the Dataset; slightly more code but robust to nested levels.
3. Reconstruct without merge: split the data by the `variable` level of the MultiIndex (or unstack and index out the variable level), building `Variable` objects/dict directly instead of `Dataset(variables)`; most robust against coordinate conflicts but a larger rewrite and more chance of changing dim order or attributes.

If the first attempt still fails, check whether the conflict moved to a level coordinate (`variable` or extra non-sample levels), whether the result has the right dims order for `assert_identical`, and whether `sel` on a single-level MultiIndex needs level-based indexing rather than raw value selection.


# xarray/core/dataarray.py

```
import datetime
import functools
from numbers import Number
from typing import (
    TYPE_CHECKING,
    Any,
    Callable,
    Dict,
    Hashable,
    Iterable,
    List,
    Mapping,
    Optional,
    Sequence,
    Tuple,
    TypeVar,
    Union,
    cast,
)

import numpy as np
import pandas as pd

from ..plot.plot import _PlotMethods
from . import (
    computation,
    dtypes,
    groupby,
    indexing,
    ops,
    pdcompat,
    resample,
    rolling,
    utils,
    weighted,
)
from .accessor_dt import CombinedDatetimelikeAccessor
from .accessor_str import StringAccessor
from .alignment import (
    _broadcast_helper,
    _get_broadcast_dims_map_common_coords,
    align,
    reindex_like_indexers,
)
from .common import AbstractArray, DataWithCoords
from .coordinates import (
    DataArrayCoordinates,
    LevelCoordinatesSource,
    assert_coordinate_consistent,
    remap_label_indexers,
)
from .dataset import Dataset, split_indexes
from .formatting import format_item
from .indexes import Indexes, default_indexes, propagate_indexes
from .indexing import is_fancy_indexer
from .merge import PANDAS_TYPES, MergeError, _extract_indexes_from_coords
from .options import OPTIONS
from .utils import Default, ReprObject, _check_inplace, _default, either_dict_or_kwargs
from .variable import (
    IndexVariable,
    Variable,
    as_compatible_data,
    as_variable,
    assert_unique_multiindex_level_names,
)

if TYPE_CHECKING:
    T_DSorDA = TypeVar("T_DSorDA", "DataArray", Dataset)

    try:
        from dask.delayed import Delayed
    except ImportError:
        Delayed = None
    try:
        from cdms2 import Variable as cdms2_Variable
    except ImportError:
        cdms2_Variable = None
    try:
        from iris.cube import Cube as iris_Cube
    except ImportError:
        iris_Cube = None


def _infer_coords_and_dims(
    shape, coords, dims
) -> "Tuple[Dict[Any, Variable], Tuple[Hashable, ...]]":
    """All the logic for creating a new DataArray"""

    if (
        coords is not None
        and not utils.is_dict_like(coords)
        and len(coords) != len(shape)
    ):
        raise ValueError(
            "coords is not dict-like, but it has %s items, "
            "which does not match the %s dimensions of the "
            "data" % (len(coords), len(shape))
        )

    if isinstance(dims, str):
        dims = (dims,)

    if dims is None:
        dims = ["dim_%s" % n for n in range(len(shape))]
        if coords is not None and len(coords) == len(shape):
            # try to infer dimensions from coords
            if utils.is_dict_like(coords):
                # deprecated in GH993, removed in GH1539
                raise ValueError(
                    "inferring DataArray dimensions from "
                    "dictionary like ``coords`` is no longer "
                    "supported. Use an explicit list of "
                    "``dims`` instead."
                )
            for n, (dim, coord) in enumerate(zip(dims, coords)):
                coord = as_variable(coord, name=dims[n]).to_index_variable()
                dims[n] = coord.name
        dims = tuple(dims)
    elif len(dims) != len(shape):
        raise ValueError(
            "different number of dimensions on data "
            "and dims: %s vs %s" % (len(shape), len(dims))
        )
    else:
        for d in dims:
            if not isinstance(d, str):
                raise TypeError("dimension %s is not a string" % d)

    new_coords: Dict[Any, Variable] = {}

    if utils.is_dict_like(coords):
        for k, v in coords.items():
            new_coords[k] = as_variable(v, name=k)
    elif coords is not None:
        for dim, coord in zip(dims, coords):
            var = as_variable(coord, name=dim)
            var.dims = (dim,)
            new_coords[dim] = var.to_index_variable()

    sizes = dict(zip(dims, shape))
    for k, v in new_coords.items():
        if any(d not in dims for d in v.dims):
            raise ValueError(
                "coordinate %s has dimensions %s, but these "
                "are not a subset of the DataArray "
                "dimensions %s" % (k, v.dims, dims)
            )

        for d, s in zip(v.dims, v.shape):
            if s != sizes[d]:
                raise ValueError(
                    "conflicting sizes for dimension %r: "
                    "length %s on the data but length %s on "
                    "coordinate %r" % (d, sizes[d], s, k)
                )

        if k in sizes and v.shape != (sizes[k],):
            raise ValueError(
                "coordinate %r is a DataArray dimension, but "
                "it has shape %r rather than expected shape %r "
                "matching the dimension size" % (k, v.shape, (sizes[k],))
            )

    assert_unique_multiindex_level_names(new_coords)

    return new_coords, dims


def _check_data_shape(data, coords, dims):
    if data is dtypes.NA:
        data = np.nan
    if coords is not None and utils.is_scalar(data, include_0d=False):
        if utils.is_dict_like(coords):
            if dims is None:
                return data
            else:
                data_shape = tuple(
                    as_variable(coords[k], k).size if k in coords.keys() else 1
                    for k in dims
                )
        else:
            data_shape = tuple(as_variable(coord, "foo").size for coord in coords)
        data = np.full(data_shape, data)
    return data


class _LocIndexer:
    __slots__ = ("data_array",)

    def __init__(self, data_array: "DataArray"):
        self.data_array = data_array

    def __getitem__(self, key) -> "DataArray":
        if not utils.is_dict_like(key):
            # expand the indexer so we can handle Ellipsis
            labels = indexing.expanded_indexer(key, self.data_array.ndim)
            key = dict(zip(self.data_array.dims, labels))
        return self.data_array.sel(**key)

    def __setitem__(self, key, value) -> None:
        if not utils.is_dict_like(key):
            # expand the indexer so we can handle Ellipsis
            labels = indexing.expanded_indexer(key, self.data_array.ndim)
            key = dict(zip(self.data_array.dims, labels))

        pos_indexers, _ = remap_label_indexers(self.data_array, key)
        self.data_array[pos_indexers] = value


# Used as the key corresponding to a DataArray's variable when converting
# arbitrary DataArray objects to datasets
_THIS_ARRAY = ReprObject("<this-array>")


class DataArray(AbstractArray, DataWithCoords):
    """N-dimensional array with labeled coordinates and dimensions.

    DataArray provides a wrapper around numpy ndarrays that uses labeled
    dimensions and coordinates to support metadata aware operations. The API is
    similar to that for the pandas Series or DataFrame, but DataArray objects
    can have any number of dimensions, and their contents have fixed data
    types.

    Additional features over raw numpy arrays:

    - Apply operations over dimensions by name: ``x.sum('time')``.
    - Select or assign values by integer location (like numpy): ``x[:10]``
      or by label (like pandas): ``x.loc['2014-01-01']`` or
      ``x.sel(time='2014-01-01')``.
    - Mathematical operations (e.g., ``x - y``) vectorize across multiple
      dimensions (known in numpy as "broadcasting") based on dimension names,
      regardless of their original order.
    - Keep track of arbitrary metadata in the form of a Python dictionary:
      ``x.attrs``
    - Convert to a pandas Series: ``x.to_series()``.

    Getting items from or doing mathematical operations with a DataArray
    always returns another DataArray.
    """

    _cache: Dict[str, Any]
    _coords: Dict[Any, Variable]
    _indexes: Optional[Dict[Hashable, pd.Index]]
    _name: Optional[Hashable]
    _variable: Variable

    __slots__ = (
        "_cache",
        "_coords",
        "_file_obj",
        "_indexes",
        "_name",
        "_variable",
        "__weakref__",
    )

    _groupby_cls = groupby.DataArrayGroupBy
    _rolling_cls = rolling.DataArrayRolling
    _coarsen_cls = rolling.DataArrayCoarsen
    _resample_cls = resample.DataArrayResample
    _weighted_cls = weighted.DataArrayWeighted

    dt = utils.UncachedAccessor(CombinedDatetimelikeAccessor)

    def __init__(
        self,
        data: Any = dtypes.NA,
        coords: Union[Sequence[Tuple], Mapping[Hashable, Any], None] = None,
        dims: Union[Hashable, Sequence[Hashable], None] = None,
        name: Hashable = None,
        attrs: Mapping = None,
        # internal parameters
        indexes: Dict[Hashable, pd.Index] = None,
        fastpath: bool = False,
    ):
        """
        Parameters
        ----------
        data : array_like
            Values for this array. Must be an ``numpy.ndarray``, ndarray like,
            or castable to an ``ndarray``. If a self-described xarray or pandas
            object, attempts are made to use this array's metadata to fill in
            other unspecified arguments. A view of the array's data is used
            instead of a copy if possible.
        coords : sequence or dict of array_like objects, optional
            Coordinates (tick labels) to use for indexing along each dimension.
            The following notations are accepted:

            - mapping {dimension name: array-like}
            - sequence of tuples that are valid arguments for xarray.Variable()
              - (dims, data)
              - (dims, data, attrs)
              - (dims, data, attrs, encoding)

            Additionally, it is possible to define a coord whose name
            does not match the dimension name, or a coord based on multiple
            dimensions, with one of the following notations:

            - mapping {coord name: DataArray}
            - mapping {coord name: Variable}
            - mapping {coord name: (dimension name, array-like)}
            - mapping {coord name: (tuple of dimension names, array-like)}

        dims : hashable or sequence of hashable, optional
            Name(s) of the data dimension(s). Must be either a hashable (only
            for 1D data) or a sequence of hashables with length equal to the
            number of dimensions. If this argument is omitted, dimension names
            default to ``['dim_0', ... 'dim_n']``.
        name : str or None, optional
            Name of this array.
        attrs : dict_like or None, optional
            Attributes to assign to the new instance. By default, an empty
            attribute dictionary is initialized.
        """
        if fastpath:
            variable = data
            assert dims is None
            assert attrs is None
        else:
            # try to fill in arguments from data if they weren't supplied
            if coords is None:

                if isinstance(data, DataArray):
                    coords = data.coords
                elif isinstance(data, pd.Series):
                    coords = [data.index]
                elif isinstance(data, pd.DataFrame):
                    coords = [data.index, data.columns]
                elif isinstance(data, (pd.Index, IndexVariable)):
                    coords = [data]
                elif isinstance(data, pdcompat.Panel):
                    coords = [data.items, data.major_axis, data.minor_axis]

            if dims is None:
                dims = getattr(data, "dims", getattr(coords, "dims", None))
            if name is None:
                name = getattr(data, "name", None)
            if attrs is None and not isinstance(data, PANDAS_TYPES):
                attrs = getattr(data, "attrs", None)

            data = _check_data_shape(data, coords, dims)
            data = as_compatible_data(data)
            coords, dims = _infer_coords_and_dims(data.shape, coords, dims)
            variable = Variable(dims, data, attrs, fastpath=True)
            indexes = dict(
                _extract_indexes_from_coords(coords)
            )  # needed for to_dataset

        # These fully describe a DataArray
        self._variable = variable
        assert isinstance(coords, dict)
        self._coords = coords
        self._name = name

        # TODO(shoyer): document this argument, once it becomes part of the
        # public interface.
        self._indexes = indexes

        self._file_obj = None

    def _replace(
        self,
        variable: Variable = None,
        coords=None,
        name: Union[Hashable, None, Default] = _default,
        indexes=None,
    ) -> "DataArray":
        if variable is None:
            variable = self.variable
        if coords is None:
            coords = self._coords
        if name is _default:
            name = self.name
        return type(self)(variable, coords, name=name, fastpath=True, indexes=indexes)

    def _replace_maybe_drop_dims(
        self, variable: Variable, name: Union[Hashable, None, Default] = _default
    ) -> "DataArray":
        if variable.dims == self.dims and variable.shape == self.shape:
            coords = self._coords.copy()
            indexes = self._indexes
        elif variable.dims == self.dims:
            # Shape has changed (e.g. from reduce(..., keepdims=True)
            new_sizes = dict(zip(self.dims, variable.shape))
            coords = {
                k: v
                for k, v in self._coords.items()
                if v.shape == tuple(new_sizes[d] for d in v.dims)
            }
            changed_dims = [
                k for k in variable.dims if variable.sizes[k] != self.sizes[k]
            ]
            indexes = propagate_indexes(self._indexes, exclude=changed_dims)
        else:
            allowed_dims = set(variable.dims)
            coords = {
                k: v for k, v in self._coords.items() if set(v.dims) <= allowed_dims
            }
            indexes = propagate_indexes(
                self._indexes, exclude=(set(self.dims) - allowed_dims)
            )
        return self._replace(variable, coords, name, indexes=indexes)

    def _overwrite_indexes(self, indexes: Mapping[Hashable, Any]) -> "DataArray":
        if not len(indexes):
            return self
        coords = self._coords.copy()
        for name, idx in indexes.items():
            coords[name] = IndexVariable(name, idx)
        obj = self._replace(coords=coords)

        # switch from dimension to level names, if necessary
        dim_names: Dict[Any, str] = {}
        for dim, idx in indexes.items():
            if not isinstance(idx, pd.MultiIndex) and idx.name != dim:
                dim_names[dim] = idx.name
        if dim_names:
            obj = obj.rename(dim_names)
        return obj

    def _to_temp_dataset(self) -> Dataset:
        return self._to_dataset_whole(name=_THIS_ARRAY, shallow_copy=False)

    def _from_temp_dataset(
        self, dataset: Dataset, name: Hashable = _default
    ) -> "DataArray":
        variable = dataset._variables.pop(_THIS_ARRAY)
        coords = dataset._variables
        indexes = dataset._indexes
        return self._replace(variable, coords, name, indexes=indexes)

    def _to_dataset_split(self, dim: Hashable) -> Dataset:
        """ splits dataarray along dimension 'dim' """

        def subset(dim, label):
            array = self.loc[{dim: label}]
            array.attrs = {}
            return as_variable(array)

        variables = {label: subset(dim, label) for label in self.get_index(dim)}
        variables.update({k: v for k, v in self._coords.items() if k != dim})
        indexes = propagate_indexes(self._indexes, exclude=dim)
        coord_names = set(self._coords) - set([dim])
        dataset = Dataset._construct_direct(
            variables, coord_names, indexes=indexes, attrs=self.attrs
        )
        return dataset

    def _to_dataset_whole(
        self, name: Hashable = None, shallow_copy: bool = True
    ) -> Dataset:
        if name is None:
            name = self.name
        if name is None:
            raise ValueError(
                "unable to convert unnamed DataArray to a "
                "Dataset without providing an explicit name"
            )
        if name in self.coords:
            raise ValueError(
                "cannot create a Dataset from a DataArray with "
                "the same name as one of its coordinates"
            )
        # use private APIs for speed: this is called by _to_temp_dataset(),
        # which is used in the guts of a lot of operations (e.g., reindex)
        variables = self._coords.copy()
        variables[name] = self.variable
        if shallow_copy:
            for k in variables:
                variables[k] = variables[k].copy(deep=False)
        indexes = self._indexes

        coord_names = set(self._coords)
        dataset = Dataset._construct_direct(variables, coord_names, indexes=indexes)
        return dataset

    def to_dataset(
        self,
        dim: Hashable = None,
        *,
        name: Hashable = None,
        promote_attrs: bool = False,
    ) -> Dataset:
        """Convert a DataArray to a Dataset.

        Parameters
        ----------
        dim : hashable, optional
            Name of the dimension on this array along which to split this array
            into separate variables. If not provided, this array is converted
            into a Dataset of one variable.
        name : hashable, optional
            Name to substitute for this array's name. Only valid if ``dim`` is
            not provided.
        promote_attrs : bool, default False
            Set to True to shallow copy attrs of DataArray to returned Dataset.

        Returns
        -------
        dataset : Dataset
        """
        if dim is not None and dim not in self.dims:
            raise TypeError(
                f"{dim} is not a dim. If supplying a ``name``, pass as a kwarg."
            )

        if dim is not None:
            if name is not None:
                raise TypeError("cannot supply both dim and name arguments")
            result = self._to_dataset_split(dim)
        else:
            result = self._to_dataset_whole(name)

        if promote_attrs:
            result.attrs = dict(self.attrs)

        return result

    @property
    def name(self) -> Optional[Hashable]:
        """The name of this array.
        """
        return self._name

    @name.setter
    def name(self, value: Optional[Hashable]) -> None:
        self._name = value

    @property
    def variable(self) -> Variable:
        """Low level interface to the Variable object for this DataArray."""
        return self._variable

    @property
    def dtype(self) -> np.dtype:
        return self.variable.dtype

    @property
    def shape(self) -> Tuple[int, ...]:
        return self.variable.shape

    @property
    def size(self) -> int:
        return self.variable.size

    @property
    def nbytes(self) -> int:
        return self.variable.nbytes

    @property
    def ndim(self) -> int:
        return self.variable.ndim

    def __len__(self) -> int:
        return len(self.variable)

    @property
    def data(self) -> Any:
        """The array's data as a dask or numpy array
        """
        return self.variable.data

    @data.setter
    def data(self, value: Any) -> None:
        self.variable.data = value

    @property
    def values(self) -> np.ndarray:
        """The array's data as a numpy.ndarray"""
        return self.variable.values

    @values.setter
    def values(self, value: Any) -> None:
        self.variable.values = value

    @property
    def _in_memory(self) -> bool:
        return self.variable._in_memory

    def to_index(self) -> pd.Index:
        """Convert this variable to a pandas.Index. Only possible for 1D
        arrays.
        """
        return self.variable.to_index()

    @property
    def dims(self) -> Tuple[Hashable, ...]:
        """Tuple of dimension names associated with this array.

        Note that the type of this property is inconsistent with
        `Dataset.dims`.  See `Dataset.sizes` and `DataArray.sizes` for
        consistently named properties.
        """
        return self.variable.dims

    @dims.setter
    def dims(self, value):
        raise AttributeError(
            "you cannot assign dims on a DataArray. Use "
            ".rename() or .swap_dims() instead."
        )

    def _item_key_to_dict(self, key: Any) -> Mapping[Hashable, Any]:
        if utils.is_dict_like(key):
            return key
        else:
            key = indexing.expanded_indexer(key, self.ndim)
            return dict(zip(self.dims, key))

    @property
    def _level_coords(self) -> Dict[Hashable, Hashable]:
        """Return a mapping of all MultiIndex levels and their corresponding
        coordinate name.
        """
        level_coords: Dict[Hashable, Hashable] = {}

        for cname, var in self._coords.items():
            if var.ndim == 1 and isinstance(var, IndexVariable):
                level_names = var.level_names
                if level_names is not None:
                    (dim,) = var.dims
                    level_coords.update({lname: dim for lname in level_names})
        return level_coords

    def _getitem_coord(self, key):
        from .dataset import _get_virtual_variable

        try:
            var = self._coords[key]
        except KeyError:
            dim_sizes = dict(zip(self.dims, self.shape))
            _, key, var = _get_virtual_variable(
                self._coords, key, self._level_coords, dim_sizes
            )

        return self._replace_maybe_drop_dims(var, name=key)

    def __getitem__(self, key: Any) -> "DataArray":
        if isinstance(key, str):
            return self._getitem_coord(key)
        else:
            # xarray-style array indexing
            return self.isel(indexers=self._item_key_to_dict(key))

    def __setitem__(self, key: Any, value: Any) -> None:
        if isinstance(key, str):
            self.coords[key] = value
        else:
            # Coordinates in key, value and self[key] should be consistent.
            # TODO Coordinate consistency in key is checked here, but it
            # causes unnecessary indexing. It should be optimized.
            obj = self[key]
            if isinstance(value, DataArray):
                assert_coordinate_consistent(value, obj.coords.variables)
            # DataArray key -> Variable key
            key = {
                k: v.variable if isinstance(v, DataArray) else v
                for k, v in self._item_key_to_dict(key).items()
            }
            self.variable[key] = value

    def __delitem__(self, key: Any) -> None:
        del self.coords[key]

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
            self.coords,
            {d: self.coords[d] for d in self.dims},
            LevelCoordinatesSource(self),
        ]

    def __contains__(self, key: Any) -> bool:
        return key in self.data

    @property
    def loc(self) -> _LocIndexer:
        """Attribute for location based indexing like pandas.
        """
        return _LocIndexer(self)

    @property
    def attrs(self) -> Dict[Hashable, Any]:
        """Dictionary storing arbitrary metadata with this array."""
        return self.variable.attrs

    @attrs.setter
    def attrs(self, value: Mapping[Hashable, Any]) -> None:
        # Disable type checking to work around mypy bug - see mypy#4167
        self.variable.attrs = value  # type: ignore

    @property
    def encoding(self) -> Dict[Hashable, Any]:
        """Dictionary of format-specific settings for how this array should be
        serialized."""
        return self.variable.encoding

    @encoding.setter
    def encoding(self, value: Mapping[Hashable, Any]) -> None:
        self.variable.encoding = value

    @property
    def indexes(self) -> Indexes:
        """Mapping of pandas.Index objects used for label based indexing
        """
        if self._indexes is None:
            self._indexes = default_indexes(self._coords, self.dims)
        return Indexes(self._indexes)

    @property
    def coords(self) -> DataArrayCoordinates:
        """Dictionary-like container of coordinate arrays.
        """
        return DataArrayCoordinates(self)

    def reset_coords(
        self,
        names: Union[Iterable[Hashable], Hashable, None] = None,
        drop: bool = False,
        inplace: bool = None,
    ) -> Union[None, "DataArray", Dataset]:
        """Given names of coordinates, reset them to become variables.

        Parameters
        ----------
        names : hashable or iterable of hashables, optional
            Name(s) of non-index coordinates in this dataset to reset into
            variables. By default, all non-index coordinates are reset.
        drop : bool, optional
            If True, remove coordinates instead of converting them into
            variables.

        Returns
        -------
        Dataset, or DataArray if ``drop == True``
        """
        _check_inplace(inplace)
        if names is None:
            names = set(self.coords) - set(self.dims)
        dataset = self.coords.to_dataset().reset_coords(names, drop)
        if drop:
            return self._replace(coords=dataset._variables)
        else:
            if self.name is None:
                raise ValueError(
                    "cannot reset_coords with drop=False on an unnamed DataArrray"
                )
            dataset[self.name] = self.variable
            return dataset

    def __dask_tokenize__(self):
        from dask.base import normalize_token

        return normalize_token((type(self), self._variable, self._coords, self._name))

    def __dask_graph__(self):
        return self._to_temp_dataset().__dask_graph__()

    def __dask_keys__(self):
        return self._to_temp_dataset().__dask_keys__()

    def __dask_layers__(self):
        return self._to_temp_dataset().__dask_layers__()

    @property
    def __dask_optimize__(self):
        return self._to_temp_dataset().__dask_optimize__

    @property
    def __dask_scheduler__(self):
        return self._to_temp_dataset().__dask_scheduler__

    def __dask_postcompute__(self):
        func, args = self._to_temp_dataset().__dask_postcompute__()
        return self._dask_finalize, (func, args, self.name)

    def __dask_postpersist__(self):
        func, args = self._to_temp_dataset().__dask_postpersist__()
        return self._dask_finalize, (func, args, self.name)

    @staticmethod
    def _dask_finalize(results, func, args, name):
        ds = func(results, *args)
        variable = ds._variables.pop(_THIS_ARRAY)
        coords = ds._variables
        return DataArray(variable, coords, name=name, fastpath=True)

    def load(self, **kwargs) -> "DataArray":
        """Manually trigger loading of this array's data from disk or a
        remote source into memory and return this array.

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
        ds = self._to_temp_dataset().load(**kwargs)
        new = self._from_temp_dataset(ds)
        self._variable = new._variable
        self._coords = new._coords
        return self

    def compute(self, **kwargs) -> "DataArray":
        """Manually trigger loading of this array's data from disk or a
        remote source into memory and return a new array. The original is
        left unaltered.

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

    def persist(self, **kwargs) -> "DataArray":
        """ Trigger computation in constituent dask arrays

        This keeps them as dask arrays but encourages them to keep data in
        memory.  This is particularly useful when on a distributed machine.
        When on a single machine consider using ``.compute()`` instead.

        Parameters
        ----------
        **kwargs : dict
            Additional keyword arguments passed on to ``dask.persist``.

        See Also
        --------
        dask.persist
        """
        ds = self._to_temp_dataset().persist(**kwargs)
        return self._from_temp_dataset(ds)

    def copy(self, deep: bool = True, data: Any = None) -> "DataArray":
        """Returns a copy of this array.

        If `deep=True`, a deep copy is made of the data array.
        Otherwise, a shallow copy is made, so each variable in the new
        array's dataset is also a variable in this array's dataset.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, optional
            Whether the data array and its coordinates are loaded into memory
            and copied onto the new object. Default is True.
        data : array_like, optional
            Data to use in the new object. Must have same shape as original.
            When `data` is used, `deep` is ignored for all data variables,
            and only used for coords.

        Returns
        -------
        object : DataArray
            New object with dimensions, attributes, coordinates, name,
            encoding, and optionally data copied from original.

        Examples
        --------

        Shallow versus deep copy

        >>> array = xr.DataArray([1, 2, 3], dims="x", coords={"x": ["a", "b", "c"]})
        >>> array.copy()
        <xarray.DataArray (x: 3)>
        array([1, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'
        >>> array_0 = array.copy(deep=False)
        >>> array_0[0] = 7
        >>> array_0
        <xarray.DataArray (x: 3)>
        array([7, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'
        >>> array
        <xarray.DataArray (x: 3)>
        array([7, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'

        Changing the data using the ``data`` argument maintains the
        structure of the original object, but with the new data. Original
        object is unaffected.

        >>> array.copy(data=[0.1, 0.2, 0.3])
        <xarray.DataArray (x: 3)>
        array([ 0.1,  0.2,  0.3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'
        >>> array
        <xarray.DataArray (x: 3)>
        array([1, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'

        See Also
        --------
        pandas.DataFrame.copy
        """
        variable = self.variable.copy(deep=deep, data=data)
        coords = {k: v.copy(deep=deep) for k, v in self._coords.items()}
        if self._indexes is None:
            indexes = self._indexes
        else:
            indexes = {k: v.copy(deep=deep) for k, v in self._indexes.items()}
        return self._replace(variable, coords, indexes=indexes)

    def __copy__(self) -> "DataArray":
        return self.copy(deep=False)

    def __deepcopy__(self, memo=None) -> "DataArray":
        # memo does nothing but is required for compatibility with
        # copy.deepcopy
        return self.copy(deep=True)

    # mutable objects should not be hashable
    # https://github.com/python/mypy/issues/4266
    __hash__ = None  # type: ignore

    @property
    def chunks(self) -> Optional[Tuple[Tuple[int, ...], ...]]:
        """Block dimensions for this array's data or None if it's not a dask
        array.
        """
        return self.variable.chunks

    def chunk(
        self,
        chunks: Union[
            None,
            Number,
            Tuple[Number, ...],
            Tuple[Tuple[Number, ...], ...],
            Mapping[Hashable, Union[None, Number, Tuple[Number, ...]]],
        ] = None,
        name_prefix: str = "xarray-",
        token: str = None,
        lock: bool = False,
    ) -> "DataArray":
        """Coerce this array's data into a dask arrays with the given chunks.

        If this variable is a non-dask array, it will be converted to dask
        array. If it's a dask array, it will be rechunked to the given chunk
        sizes.

        If neither chunks is not provided for one or more dimensions, chunk
        sizes along that dimension will not be updated; non-dask arrays will be
        converted into dask arrays with a single block.

        Parameters
        ----------
        chunks : int, tuple or mapping, optional
            Chunk sizes along each dimension, e.g., ``5``, ``(5, 5)`` or
            ``{'x': 5, 'y': 5}``.
        name_prefix : str, optional
            Prefix for the name of the new dask array.
        token : str, optional
            Token uniquely identifying this array.
        lock : optional
            Passed on to :py:func:`dask.array.from_array`, if the array is not
            already as dask array.

        Returns
        -------
        chunked : xarray.DataArray
        """
        if isinstance(chunks, (tuple, list)):
            chunks = dict(zip(self.dims, chunks))

        ds = self._to_temp_dataset().chunk(
            chunks, name_prefix=name_prefix, token=token, lock=lock
        )
        return self._from_temp_dataset(ds)

    def isel(
        self,
        indexers: Mapping[Hashable, Any] = None,
        drop: bool = False,
        missing_dims: str = "raise",
        **indexers_kwargs: Any,
    ) -> "DataArray":
        """Return a new DataArray whose data is given by integer indexing
        along the specified dimension(s).

        Parameters
        ----------
        indexers : dict, optional
            A dict with keys matching dimensions and values given
            by integers, slice objects or arrays.
            indexer can be a integer, slice, array-like or DataArray.
            If DataArrays are passed as indexers, xarray-style indexing will be
            carried out. See :ref:`indexing` for the details.
            One of indexers or indexers_kwargs must be provided.
        drop : bool, optional
            If ``drop=True``, drop coordinates variables indexed by integers
            instead of making them scalar.
        missing_dims : {"raise", "warn", "ignore"}, default "raise"
            What to do if dimensions that should be selected from are not present in the
            DataArray:
            - "exception": raise an exception
            - "warning": raise a warning, and ignore the missing dimensions
            - "ignore": ignore the missing dimensions
        **indexers_kwargs : {dim: indexer, ...}, optional
            The keyword arguments form of ``indexers``.

        See Also
        --------
        Dataset.isel
        DataArray.sel
        """

        indexers = either_dict_or_kwargs(indexers, indexers_kwargs, "isel")

        if any(is_fancy_indexer(idx) for idx in indexers.values()):
            ds = self._to_temp_dataset()._isel_fancy(
                indexers, drop=drop, missing_dims=missing_dims
            )
            return self._from_temp_dataset(ds)

        # Much faster algorithm for when all indexers are ints, slices, one-dimensional
        # lists, or zero or one-dimensional np.ndarray's

        variable = self._variable.isel(indexers, missing_dims=missing_dims)

        coords = {}
        for coord_name, coord_value in self._coords.items():
            coord_indexers = {
                k: v for k, v in indexers.items() if k in coord_value.dims
            }
            if coord_indexers:
                coord_value = coord_value.isel(coord_indexers)
                if drop and coord_value.ndim == 0:
                    continue
            coords[coord_name] = coord_value

        return self._replace(variable=variable, coords=coords)

    def sel(
        self,
        indexers: Mapping[Hashable, Any] = None,
        method: str = None,
        tolerance=None,
        drop: bool = False,
        **indexers_kwargs: Any,
    ) -> "DataArray":
        """Return a new DataArray whose data is given by selecting index
        labels along the specified dimension(s).

        In contrast to `DataArray.isel`, indexers for this method should use
        labels instead of integers.

        Under the hood, this method is powered by using pandas's powerful Index
        objects. This makes label based indexing essentially just as fast as
        using integer indexing.

        It also means this method uses pandas's (well documented) logic for
        indexing. This means you can use string shortcuts for datetime indexes
        (e.g., '2000-01' to select all values in January 2000). It also means
        that slices are treated as inclusive of both the start and stop values,
        unlike normal Python indexing.

        .. warning::

          Do not try to assign values when using any of the indexing methods
          ``isel`` or ``sel``::

            da = xr.DataArray([0, 1, 2, 3], dims=['x'])
            # DO NOT do this
            da.isel(x=[0, 1, 2])[1] = -1

          Assigning values with the chained indexing using ``.sel`` or
          ``.isel`` fails silently.

        Parameters
        ----------
        indexers : dict, optional
            A dict with keys matching dimensions and values given
            by scalars, slices or arrays of tick labels. For dimensions with
            multi-index, the indexer may also be a dict-like object with keys
            matching index level names.
            If DataArrays are passed as indexers, xarray-style indexing will be
            carried out. See :ref:`indexing` for the details.
            One of indexers or indexers_kwargs must be provided.
        method : {None, 'nearest', 'pad'/'ffill', 'backfill'/'bfill'}, optional
            Method to use for inexact matches:

            * None (default): only exact matches
            * pad / ffill: propagate last valid index value forward
            * backfill / bfill: propagate next valid index value backward
            * nearest: use nearest valid index value
        tolerance : optional
            Maximum distance between original and new labels for inexact
            matches. The values of the index at the matching locations must
            satisfy the equation ``abs(index[indexer] - target) <= tolerance``.
        drop : bool, optional
            If ``drop=True``, drop coordinates variables in `indexers` instead
            of making them scalar.
        **indexers_kwargs : {dim: indexer, ...}, optional
            The keyword arguments form of ``indexers``.
            One of indexers or indexers_kwargs must be provided.

        Returns
        -------
        obj : DataArray
            A new DataArray with the same contents as this DataArray, except the
            data and each dimension is indexed by the appropriate indexers.
            If indexer DataArrays have coordinates that do not conflict with
            this object, then these coordinates will be attached.
            In general, each array's data will be a view of the array's data
            in this DataArray, u
```


# xarray/core/dataset.py

```
import copy
import datetime
import functools
import sys
import warnings
from collections import defaultdict
from html import escape
from numbers import Number
from operator import methodcaller
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
    overload,
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
    weighted,
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
    remove_unused_levels_categories,
    roll_index,
)
from .indexing import is_fancy_indexer
from .merge import (
    dataset_merge_method,
    dataset_update_method,
    merge_coordinates_without_align,
    merge_data_and_coords,
)
from .missing import get_clean_interp_index
from .options import OPTIONS, _get_keep_attrs
from .pycompat import dask_array_type
from .utils import (
    Default,
    Frozen,
    SortedKeysDict,
    _check_inplace,
    _default,
    decode_numpy_dict_values,
    drop_dims_from_indexers,
    either_dict_or_kwargs,
    hashable,
    infix_dims,
    is_dict_like,
    is_scalar,
    maybe_wrap_array,
)
from .variable import (
    IndexVariable,
    Variable,
    as_variable,
    assert_unique_multiindex_level_names,
    broadcast_variables,
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
                vars_to_create[str(d) + "_"] = Variable(d, index, variables[d].attrs)

    for d, levs in dim_levels.items():
        index = variables[d].to_index()
        if len(levs) == index.nlevels:
            vars_to_remove.append(d)
        else:
            vars_to_replace[d] = IndexVariable(d, index.droplevel(levs))

        if not drop:
            for lev in levs:
                idx = index.get_level_values(lev)
                vars_to_create[idx.name] = Variable(d, idx, variables[d].attrs)

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
    _weighted_cls = weighted.DatasetWeighted

    def __init__(
        self,
        # could make a VariableArgs to use more generally, and refine these
        # categories
        data_vars: Mapping[Hashable, Any] = None,
        coords: Mapping[Hashable, Any] = None,
        attrs: Mapping[Hashable, Any] = None,
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
        """

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

        variables, coord_names, dims, indexes, _ = merge_data_and_coords(
            data_vars, coords, compat="broadcast_equals"
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
                self._attrs = attrs
            if indexes is not _default:
                self._indexes = indexes
            if encoding is not _default:
                self._encoding = encoding
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
        >>> ds = xr.Dataset(
        ...     {"foo": da, "bar": ("x", [-1, 2])}, coords={"x": ["one", "two"]},
        ... )
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
        >>> ds_0["foo"][0, 0] = 7
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

        >>> ds.copy(data={"foo": np.arange(6).reshape(2, 3), "bar": ["a", "b"]})
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

    def __iter__(self) -> Iterator[Hashable]:
        return iter(self.data_vars)

    def __array__(self, dtype=None):
        raise TypeError(
            "cannot directly convert an xarray.Dataset into a "
            "numpy array. Instead, create an xarray
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
xarray/tests/test_weighted.py


# The last commit

```
58761b01 SWE-bench



 .binder/environment.yml                           |   0
 .codecov.yml                                      |   0
 .coveragerc                                       |   0
 .deepsource.toml                                  |   0
 .gitattributes                                    |   0
 .github/FUNDING.yml                               |   0
 .github/ISSUE_TEMPLATE/bug-report.md              |   0
 .github/ISSUE_TEMPLATE/config.yml                 |   0
 .github/ISSUE_TEMPLATE/feature-request.md         |   0
 .github/PULL_REQUEST_TEMPLATE.md                  |   0
 .github/stale.yml                                 |   0
 .gitignore                                        |   0
 .landscape.yml                                    |   0
 .pep8speaks.yml                                   |   0
 .pre-commit-config.yaml                           |   0
 CODE_OF_CONDUCT.md                                |   0
 CONTRIBUTING.md                                   |   0
 HOW_TO_RELEASE.md                                 |   0
 LICENSE                                           |   0
 MANIFEST.in                                       |   0
 README.rst                                        |   0
 asv_bench/asv.conf.json                           |   0
 asv_bench/benchmarks/__init__.py                  |   0
 asv_bench/benchmarks/combine.py                   |   0
 asv_bench/benchmarks/dataarray_missing.py         |   0
 asv_bench/benchmarks/dataset_io.py                |   0
 asv_bench/benchmarks/indexing.py                  |   0
 asv_bench/benchmarks/interp.py                    |   0
 asv_bench/benchmarks/reindexing.py                |   0
 asv_bench/benchmarks/rolling.py                   |   0
 asv_bench/benchmarks/unstacking.py                |   0
 azure-pipelines.yml                               |   0
 ci/azure/add-conda-to-path.yml                    |   0
 ci/azure/install.yml                              |   0
 ci/azure/unit-tests.yml                           |   0
 ci/requirements/doc.yml                           |   0
 ci/requirements/py36-bare-minimum.yml             |   0
 ci/requirements/py36-min-all-deps.yml             |   0
 ci/requirements/py36-min-nep18.yml                |   0
 ci/requirements/py36.yml                          |   0
 ci/requirements/py37-windows.yml                  |   0
 ci/requirements/py37.yml                          |   0
 ci/requirements/py38-all-but-dask.yml             |   0
 ci/requirements/py38.yml                          |   0
 conftest.py                                       |   0
 doc/Makefile                                      |   0
 doc/README.rst                                    |   0
 doc/_static/.gitignore                            |   0
 doc/_static/advanced_selection_interpolation.svg  |   0
 doc/_static/ci.png                                | Bin
 doc/_static/dask_array.png                        | Bin
 doc/_static/dataset-diagram-logo.png              | Bin
 doc/_static/dataset-diagram-logo.tex              |   0
 doc/_static/dataset-diagram-square-logo.png       | Bin
 doc/_static/dataset-diagram-square-logo.tex       |   0
 doc/_static/dataset-diagram.png                   | Bin
```

```diff
diff --git a/.binder/environment.yml b/.binder/environment.yml
old mode 100644
new mode 100755
diff --git a/.codecov.yml b/.codecov.yml
old mode 100644
new mode 100755
diff --git a/.coveragerc b/.coveragerc
old mode 100644
new mode 100755
diff --git a/.deepsource.toml b/.deepsource.toml
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.github/FUNDING.yml b/.github/FUNDING.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/bug-report.md b/.github/ISSUE_TEMPLATE/bug-report.md
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/config.yml b/.github/ISSUE_TEMPLATE/config.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/feature-request.md b/.github/ISSUE_TEMPLATE/feature-request.md
old mode 100644
new mode 100755
diff --git a/.github/PULL_REQUEST_TEMPLATE.md b/.github/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/stale.yml b/.github/stale.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.landscape.yml b/.landscape.yml
old mode 100644
new mode 100755
diff --git a/.pep8speaks.yml b/.pep8speaks.yml
old mode 100644
new mode 100755
diff --git a/.pre-commit-config.yaml b/.pre-commit-config.yaml
old mode 100644
new mode 100755
diff --git a/CODE_OF_CONDUCT.md b/CODE_OF_CONDUCT.md
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.md b/CONTRIBUTING.md
old mode 100644
new mode 100755
diff --git a/HOW_TO_RELEASE.md b/HOW_TO_RELEASE.md
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/asv_bench/asv.conf.json b/asv_bench/asv.conf.json
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/__init__.py b/asv_bench/benchmarks/__init__.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/combine.py b/asv_bench/benchmarks/combine.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/dataarray_missing.py b/asv_bench/benchmarks/dataarray_missing.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/dataset_io.py b/asv_bench/benchmarks/dataset_io.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/indexing.py b/asv_bench/benchmarks/indexing.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/interp.py b/asv_bench/benchmarks/interp.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/reindexing.py b/asv_bench/benchmarks/reindexing.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/rolling.py b/asv_bench/benchmarks/rolling.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/unstacking.py b/asv_bench/benchmarks/unstacking.py
old mode 100644
new mode 100755
diff --git a/azure-pipelines.yml b/azure-pipelines.yml
old mode 100644
new mode 100755
diff --git a/ci/azure/add-conda-to-path.yml b/ci/azure/add-conda-to-path.yml
old mode 100644
new mode 100755
diff --git a/ci/azure/install.yml b/ci/azure/install.yml
old mode 100644
new mode 100755
diff --git a/ci/azure/unit-tests.yml b/ci/azure/unit-tests.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/doc.yml b/ci/requirements/doc.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36-bare-minimum.yml b/ci/requirements/py36-bare-minimum.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36-min-all-deps.yml b/ci/requirements/py36-min-all-deps.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36-min-nep18.yml b/ci/requirements/py36-min-nep18.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36.yml b/ci/requirements/py36.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py37-windows.yml b/ci/requirements/py37-windows.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py37.yml b/ci/requirements/py37.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py38-all-but-dask.yml b/ci/requirements/py38-all-but-dask.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py38.yml b/ci/requirements/py38.yml
old mode 100644
new mode 100755
diff --git a/conftest.py b/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/Makefile b/doc/Makefile
old mode 100644
new mode 100755
diff --git a/doc/README.rst b/doc/README.rst
old mode 100644
new mode 100755
diff --git a/doc/_static/.gitignore b/doc/_static/.gitignore
old mode 100644
new mode 100755
diff --git a/doc/_static/advanced_selection_interpolation.svg b/doc/_static/advanced_selection_interpolation.svg
old mode 100644
new mode 100755
diff --git a/doc/_static/ci.png b/doc/_static/ci.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dask_array.png b/doc/_static/dask_array.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-logo.png b/doc/_static/dataset-diagram-logo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-logo.tex b/doc/_static/dataset-diagram-logo.tex
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-square-logo.png b/doc/_static/dataset-diagram-square-logo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-square-logo.tex b/doc/_static/dataset-diagram-square-logo.tex
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram.png b/doc/_static/dataset-diagram.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram.tex b/doc/_static/dataset-diagram.tex
old mode 100644
new mode 100755
diff --git a/doc/_static/favicon.ico b/doc/_static/favicon.ico
old mode 100644
new mode 100755
diff --git a/doc/_static/numfocus_logo.png b/doc/_static/numfocus_logo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/opendap-prism-tmax.png b/doc/_static/opendap-prism-tmax.png
old mode 100644
new mode 100755
diff --git a/doc/_static/style.css b/doc/_static/style.css
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor.rst b/doc/_templates/autosummary/accessor.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor_attribute.rst b/doc/_templates/autosummary/accessor_attribute.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor_callable.rst b/doc/_templates/autosummary/accessor_callable.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor_method.rst b/doc/_templates/autosummary/accessor_method.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/layout.html b/doc/_templates/layout.html
old mode 100644
new mode 100755
diff --git a/doc/api-hidden.rst b/doc/api-hidden.rst
old mode 100644
new mode 100755
diff --git a/doc/api.rst b/doc/api.rst
old mode 100644
new mode 100755
diff --git a/doc/combining.rst b/doc/combining.rst
old mode 100644
new mode 100755
diff --git a/doc/computation.rst b/doc/computation.rst
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/contributing.rst b/doc/contributing.rst
old mode 100644
new mode 100755
diff --git a/doc/dask.rst b/doc/dask.rst
old mode 100644
new mode 100755
diff --git a/doc/data-structures.rst b/doc/data-structures.rst
old mode 100644
new mode 100755
diff --git a/doc/examples.rst b/doc/examples.rst
old mode 100644
new mode 100755
diff --git a/doc/examples/ERA5-GRIB-example.ipynb b/doc/examples/ERA5-GRIB-example.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/ROMS_ocean_model.ipynb b/doc/examples/ROMS_ocean_model.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/_code/accessor_example.py b/doc/examples/_code/accessor_example.py
old mode 100644
new mode 100755
diff --git a/doc/examples/apply_ufunc_vectorize_1d.ipynb b/doc/examples/apply_ufunc_vectorize_1d.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/area_weighted_temperature.ipynb b/doc/examples/area_weighted_temperature.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/monthly-means.ipynb b/doc/examples/monthly-means.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/monthly_means_output.png b/doc/examples/monthly_means_output.png
old mode 100644
new mode 100755
diff --git a/doc/examples/multidimensional-coords.ipynb b/doc/examples/multidimensional-coords.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/visualization_gallery.ipynb b/doc/examples/visualization_gallery.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/weather-data.ipynb b/doc/examples/weather-data.ipynb
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/gallery/README.txt b/doc/gallery/README.txt
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_cartopy_facetgrid.py b/doc/gallery/plot_cartopy_facetgrid.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_colorbar_center.py b/doc/gallery/plot_colorbar_center.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_control_colorbar.py b/doc/gallery/plot_control_colorbar.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_lines_from_2d.py b/doc/gallery/plot_lines_from_2d.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_rasterio.py b/doc/gallery/plot_rasterio.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_rasterio_rgb.py b/doc/gallery/plot_rasterio_rgb.py
old mode 100644
new mode 100755
diff --git a/doc/groupby.rst b/doc/groupby.rst
old mode 100644
new mode 100755
diff --git a/doc/howdoi.rst b/doc/howdoi.rst
old mode 100644
new mode 100755
diff --git a/doc/index.rst b/doc/index.rst
old mode 100644
new mode 100755
diff --git a/doc/indexing.rst b/doc/indexing.rst
old mode 100644
new mode 100755
diff --git a/doc/installing.rst b/doc/installing.rst
old mode 100644
new mode 100755
diff --git a/doc/internals.rst b/doc/internals.rst
old mode 100644
new mode 100755
diff --git a/doc/interpolation.rst b/doc/interpolation.rst
old mode 100644
new mode 100755
diff --git a/doc/io.rst b/doc/io.rst
old mode 100644
new mode 100755
diff --git a/doc/pandas.rst b/doc/pandas.rst
old mode 100644
new mode 100755
diff --git a/doc/plotting.rst b/doc/plotting.rst
old mode 100644
new mode 100755
diff --git a/doc/quick-overview.rst b/doc/quick-overview.rst
old mode 100644
new mode 100755
diff --git a/doc/related-projects.rst b/doc/related-projects.rst
old mode 100644
new mode 100755
diff --git a/doc/reshaping.rst b/doc/reshaping.rst
old mode 100644
new mode 100755
diff --git a/doc/roadmap.rst b/doc/roadmap.rst
old mode 100644
new mode 100755
diff --git a/doc/terminology.rst b/doc/terminology.rst
old mode 100644
new mode 100755
diff --git a/doc/time-series.rst b/doc/time-series.rst
old mode 100644
new mode 100755
diff --git a/doc/weather-climate.rst b/doc/weather-climate.rst
old mode 100644
new mode 100755
diff --git a/doc/whats-new.rst b/doc/whats-new.rst
old mode 100644
new mode 100755
diff --git a/doc/why-xarray.rst b/doc/why-xarray.rst
old mode 100644
new mode 100755
diff --git a/licenses/DASK_LICENSE b/licenses/DASK_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/ICOMOON_LICENSE b/licenses/ICOMOON_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/NUMPY_LICENSE b/licenses/NUMPY_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/PANDAS_LICENSE b/licenses/PANDAS_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/PYTHON_LICENSE b/licenses/PYTHON_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/SEABORN_LICENSE b/licenses/SEABORN_LICENSE
old mode 100644
new mode 100755
diff --git a/properties/README.md b/properties/README.md
old mode 100644
new mode 100755
diff --git a/properties/conftest.py b/properties/conftest.py
old mode 100644
new mode 100755
diff --git a/properties/test_encode_decode.py b/properties/test_encode_decode.py
old mode 100644
new mode 100755
diff --git a/properties/test_pandas_roundtrip.py b/properties/test_pandas_roundtrip.py
old mode 100644
new mode 100755
diff --git a/readthedocs.yml b/readthedocs.yml
old mode 100644
new mode 100755
diff --git a/requirements.txt b/requirements.txt
old mode 100644
new mode 100755
diff --git a/setup.cfg b/setup.cfg
old mode 100644
new mode 100755
diff --git a/xarray/__init__.py b/xarray/__init__.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/__init__.py b/xarray/backends/__init__.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/api.py b/xarray/backends/api.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/cfgrib_.py b/xarray/backends/cfgrib_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/common.py b/xarray/backends/common.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/file_manager.py b/xarray/backends/file_manager.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/h5netcdf_.py b/xarray/backends/h5netcdf_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/locks.py b/xarray/backends/locks.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/lru_cache.py b/xarray/backends/lru_cache.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/memory.py b/xarray/backends/memory.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/netCDF4_.py b/xarray/backends/netCDF4_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/netcdf3.py b/xarray/backends/netcdf3.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/pseudonetcdf_.py b/xarray/backends/pseudonetcdf_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/pydap_.py b/xarray/backends/pydap_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/pynio_.py b/xarray/backends/pynio_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/rasterio_.py b/xarray/backends/rasterio_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/scipy_.py b/xarray/backends/scipy_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/zarr.py b/xarray/backends/zarr.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/__init__.py b/xarray/coding/__init__.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/cftime_offsets.py b/xarray/coding/cftime_offsets.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/cftimeindex.py b/xarray/coding/cftimeindex.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/frequencies.py b/xarray/coding/frequencies.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/strings.py b/xarray/coding/strings.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/times.py b/xarray/coding/times.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/variables.py b/xarray/coding/variables.py
old mode 100644
new mode 100755
diff --git a/xarray/conventions.py b/xarray/conventions.py
old mode 100644
```
````

### `direct-check.log`

```
check: pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"
============================= test session starts ==============================
platform linux -- Python 3.10.15, pytest-7.4.0, pluggy-1.5.0
rootdir: /testbed
configfile: setup.cfg
plugins: cov-5.0.0, hypothesis-6.114.0, xdist-3.6.1, env-1.1.5
collected 1709 items / 1690 deselected / 19 selected

xarray/tests/test_dataarray.py ......                                    [ 31%]
xarray/tests/test_dataset.py .............                               [100%]

=============================== warnings summary ===============================
xarray/__init__.py:1
  /testbed/xarray/__init__.py:1: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/dask_array_compat.py:16
xarray/core/dask_array_compat.py:16
  /testbed/xarray/core/dask_array_compat.py:16: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:149
xarray/core/dask_array_compat.py:149
  /testbed/xarray/core/dask_array_compat.py:149: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:186
xarray/core/dask_array_compat.py:186
  /testbed/xarray/core/dask_array_compat.py:186: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
  /testbed/xarray/tests/__init__.py:54: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dask.py:593
  /testbed/xarray/tests/test_dask.py:593: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) >= "2.0", reason="no meta")

xarray/tests/test_dask.py:611
  /testbed/xarray/tests/test_dask.py:611: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dask.py:629
  /testbed/xarray/tests/test_dask.py:629: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
  /testbed/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/xarray/tests/test_dataarray.py:2082: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    levels=[pd.Int64Index([]), pd.Int64Index([0])],

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=============== 19 passed, 1690 deselected, 28 warnings in 9.50s ===============
scope: xarray/core/dataarray.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataarray.py +5 -1
changed: xarray/tests/test_dataset.py +9 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/xarray/core/dataarray.py b/xarray/core/dataarray.py
index b0df8749..9dda6e8a 100755
--- a/xarray/core/dataarray.py
+++ b/xarray/core/dataarray.py
@@ -1961,7 +1961,11 @@ class DataArray(AbstractArray, DataWithCoords):
         # pull variables out of datarray
         data_dict = {}
         for k in variables:
-            data_dict[k] = self.sel({variable_dim: k}).squeeze(drop=True)
+            data_dict[k] = (
+                self.sel({variable_dim: k})
+                .squeeze(drop=True)
+                .drop_vars(dim, errors="ignore")
+            )
 
         # unstacked dataset
         return Dataset(data_dict)
diff --git a/xarray/tests/test_dataset.py b/xarray/tests/test_dataset.py
index 9c8d4072..64751620 100755
--- a/xarray/tests/test_dataset.py
+++ b/xarray/tests/test_dataset.py
@@ -3055,6 +3055,15 @@ class TestDataset:
         x = y.to_unstacked_dataset("features")
         assert_identical(D, x)
 
+    def test_to_stacked_array_to_unstacked_dataset_single_dim(self):
+        # test when variables only have a single (sample) dimension
+        arr = xr.DataArray(np.arange(3), coords=[("x", [0, 1, 2])])
+        D = xr.Dataset({"a": arr, "b": arr})
+
+        y = D.to_stacked_array("features", sample_dims=["x"])
+        x = y.to_unstacked_dataset("features")
+        assert_identical(D, x)
+
     def test_update(self):
         data = create_test_data(seed=0)
         expected = data.copy()
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
check: pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"
============================= test session starts ==============================
platform linux -- Python 3.10.15, pytest-7.4.0, pluggy-1.5.0
rootdir: /testbed
configfile: setup.cfg
plugins: cov-5.0.0, hypothesis-6.114.0, xdist-3.6.1, env-1.1.5
collected 1709 items / 1690 deselected / 19 selected

xarray/tests/test_dataarray.py ......                                    [ 31%]
xarray/tests/test_dataset.py .............                               [100%]

=============================== warnings summary ===============================
xarray/__init__.py:1
  /testbed/xarray/__init__.py:1: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/dask_array_compat.py:16
xarray/core/dask_array_compat.py:16
  /testbed/xarray/core/dask_array_compat.py:16: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:149
xarray/core/dask_array_compat.py:149
  /testbed/xarray/core/dask_array_compat.py:149: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:186
xarray/core/dask_array_compat.py:186
  /testbed/xarray/core/dask_array_compat.py:186: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
  /testbed/xarray/tests/__init__.py:54: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dask.py:593
  /testbed/xarray/tests/test_dask.py:593: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) >= "2.0", reason="no meta")

xarray/tests/test_dask.py:611
  /testbed/xarray/tests/test_dask.py:611: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dask.py:629
  /testbed/xarray/tests/test_dask.py:629: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
  /testbed/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/xarray/tests/test_dataarray.py:2082: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    levels=[pd.Int64Index([]), pd.Int64Index([0])],

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=============== 19 passed, 1690 deselected, 28 warnings in 7.33s ===============
scope: xarray/core/dataarray.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataarray.py +5 -1
changed: xarray/tests/test_dataset.py +9 -0
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
# Notes, run 2026-11-06T123736

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

to_unstacked_dataset broken for single-dim variables
<!-- A short summary of the issue, if appropriate -->


#### MCVE Code Sample

```python
arr = xr.DataArray(
     np.arange(3),
     coords=[("x", [0, 1, 2])],
 )
data = xr.Dataset({"a": arr, "b": arr})
stacked = data.to_stacked_array('y', sample_dims=['x'])
unstacked = stacked.to_unstacked_dataset('y')
# MergeError: conflicting values for variable 'y' on objects to be combined. You can skip this check by specifying compat='override'.
```

#### Expected Output
A working roundtrip.

#### Problem Description
I need to stack a bunch of variables and later unstack them again, however this doesn't work if the variables only have a single dimension.

#### Versions

<details><summary>Output of <tt>xr.show_versions()</tt></summary>

INSTALLED VERSIONS
------------------
commit: None
python: 3.7.3 (default, Mar 27 2019, 22:11:17) 
[GCC 7.3.0]
python-bits: 64
OS: Linux
OS-release: 4.15.0-96-generic
machine: x86_64
processor: x86_64
byteorder: little
LC_ALL: None
LANG: en_GB.UTF-8
LOCALE: en_GB.UTF-8
libhdf5: 1.10.4
libnetcdf: 4.6.2

xarray: 0.15.1
pandas: 1.0.3
numpy: 1.17.3
scipy: 1.3.1
netCDF4: 1.4.2
pydap: None
h5netcdf: None
h5py: 2.10.0
Nio: None
zarr: None
cftime: 1.0.4.2
nc_time_axis: None
PseudoNetCDF: None
rasterio: None
cfgrib: None
iris: None
bottleneck: None
dask: 2.10.1
distributed: 2.10.0
matplotlib: 3.1.1
cartopy: None
seaborn: 0.10.0
numbagg: None
setuptools: 41.0.0
pip: 19.0.3
conda: 4.8.3
pytest: 5.3.5
IPython: 7.9.0
sphinx: None


</details>


# The files of the project

```
.binder/environment.yml
.codecov.yml
.coveragerc
.deepsource.toml
.gitattributes
.github/FUNDING.yml
.github/ISSUE_TEMPLATE/bug-report.md
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/feature-request.md
.github/PULL_REQUEST_TEMPLATE.md
.github/stale.yml
.gitignore
.landscape.yml
.pep8speaks.yml
.pre-commit-config.yaml
CODE_OF_CONDUCT.md
CONTRIBUTING.md
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
ci/requirements/py38-all-but-dask.yml
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
doc/_templates/autosummary/accessor.rst
doc/_templates/autosummary/accessor_attribute.rst
doc/_templates/autosummary/accessor_callable.rst
doc/_templates/autosummary/accessor_method.rst
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
doc/examples/apply_ufunc_vectorize_1d.ipynb
doc/examples/area_weighted_temperature.ipynb
doc/examples/monthly-means.ipynb
doc/examples/monthly_means_output.png
doc/examples/multidimensional-coords.ipynb
doc/examples/visualization_gallery.ipynb
doc/examples/weather-data.ipynb
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
requirements.txt
setup.cfg
setup.py
xarray/__init__.py
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
xarray/coding/frequencies.py
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
xarray/core/weighted.py
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
xarray/tests/test_weighted.py
xarray/tutorial.py
xarray/ufuncs.py
xarray/util/__init__.py
xarray/util/print_versions.py
```


# The last commit

```
58761b01 SWE-bench



 .binder/environment.yml                           |   0
 .codecov.yml                                      |   0
 .coveragerc                                       |   0
 .deepsource.toml                                  |   0
 .gitattributes                                    |   0
 .github/FUNDING.yml                               |   0
 .github/ISSUE_TEMPLATE/bug-report.md              |   0
 .github/ISSUE_TEMPLATE/config.yml                 |   0
 .github/ISSUE_TEMPLATE/feature-request.md         |   0
 .github/PULL_REQUEST_TEMPLATE.md                  |   0
 .github/stale.yml                                 |   0
 .gitignore                                        |   0
 .landscape.yml                                    |   0
 .pep8speaks.yml                                   |   0
 .pre-commit-config.yaml                           |   0
 CODE_OF_CONDUCT.md                                |   0
 CONTRIBUTING.md                                   |   0
 HOW_TO_RELEASE.md                                 |   0
 LICENSE                                           |   0
 MANIFEST.in                                       |   0
 README.rst                                        |   0
 asv_bench/asv.conf.json                           |   0
 asv_bench/benchmarks/__init__.py                  |   0
 asv_bench/benchmarks/combine.py                   |   0
 asv_bench/benchmarks/dataarray_missing.py         |   0
 asv_bench/benchmarks/dataset_io.py                |   0
 asv_bench/benchmarks/indexing.py                  |   0
 asv_bench/benchmarks/interp.py                    |   0
 asv_bench/benchmarks/reindexing.py                |   0
 asv_bench/benchmarks/rolling.py                   |   0
 asv_bench/benchmarks/unstacking.py                |   0
 azure-pipelines.yml                               |   0
 ci/azure/add-conda-to-path.yml                    |   0
 ci/azure/install.yml                              |   0
 ci/azure/unit-tests.yml                           |   0
 ci/requirements/doc.yml                           |   0
 ci/requirements/py36-bare-minimum.yml             |   0
 ci/requirements/py36-min-all-deps.yml             |   0
 ci/requirements/py36-min-nep18.yml                |   0
 ci/requirements/py36.yml                          |   0
 ci/requirements/py37-windows.yml                  |   0
 ci/requirements/py37.yml                          |   0
 ci/requirements/py38-all-but-dask.yml             |   0
 ci/requirements/py38.yml                          |   0
 conftest.py                                       |   0
 doc/Makefile                                      |   0
 doc/README.rst                                    |   0
 doc/_static/.gitignore                            |   0
 doc/_static/advanced_selection_interpolation.svg  |   0
 doc/_static/ci.png                                | Bin
 doc/_static/dask_array.png                        | Bin
 doc/_static/dataset-diagram-logo.png              | Bin
 doc/_static/dataset-diagram-logo.tex              |   0
 doc/_static/dataset-diagram-square-logo.png       | Bin
 doc/_static/dataset-diagram-square-logo.tex       |   0
 doc/_static/dataset-diagram.png                   | Bin
```

```diff
diff --git a/.binder/environment.yml b/.binder/environment.yml
old mode 100644
new mode 100755
diff --git a/.codecov.yml b/.codecov.yml
old mode 100644
new mode 100755
diff --git a/.coveragerc b/.coveragerc
old mode 100644
new mode 100755
diff --git a/.deepsource.toml b/.deepsource.toml
old mode 100644
new mode 100755
diff --git a/.gitattributes b/.gitattributes
old mode 100644
new mode 100755
diff --git a/.github/FUNDING.yml b/.github/FUNDING.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/bug-report.md b/.github/ISSUE_TEMPLATE/bug-report.md
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/config.yml b/.github/ISSUE_TEMPLATE/config.yml
old mode 100644
new mode 100755
diff --git a/.github/ISSUE_TEMPLATE/feature-request.md b/.github/ISSUE_TEMPLATE/feature-request.md
old mode 100644
new mode 100755
diff --git a/.github/PULL_REQUEST_TEMPLATE.md b/.github/PULL_REQUEST_TEMPLATE.md
old mode 100644
new mode 100755
diff --git a/.github/stale.yml b/.github/stale.yml
old mode 100644
new mode 100755
diff --git a/.gitignore b/.gitignore
old mode 100644
new mode 100755
diff --git a/.landscape.yml b/.landscape.yml
old mode 100644
new mode 100755
diff --git a/.pep8speaks.yml b/.pep8speaks.yml
old mode 100644
new mode 100755
diff --git a/.pre-commit-config.yaml b/.pre-commit-config.yaml
old mode 100644
new mode 100755
diff --git a/CODE_OF_CONDUCT.md b/CODE_OF_CONDUCT.md
old mode 100644
new mode 100755
diff --git a/CONTRIBUTING.md b/CONTRIBUTING.md
old mode 100644
new mode 100755
diff --git a/HOW_TO_RELEASE.md b/HOW_TO_RELEASE.md
old mode 100644
new mode 100755
diff --git a/LICENSE b/LICENSE
old mode 100644
new mode 100755
diff --git a/MANIFEST.in b/MANIFEST.in
old mode 100644
new mode 100755
diff --git a/README.rst b/README.rst
old mode 100644
new mode 100755
diff --git a/asv_bench/asv.conf.json b/asv_bench/asv.conf.json
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/__init__.py b/asv_bench/benchmarks/__init__.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/combine.py b/asv_bench/benchmarks/combine.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/dataarray_missing.py b/asv_bench/benchmarks/dataarray_missing.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/dataset_io.py b/asv_bench/benchmarks/dataset_io.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/indexing.py b/asv_bench/benchmarks/indexing.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/interp.py b/asv_bench/benchmarks/interp.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/reindexing.py b/asv_bench/benchmarks/reindexing.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/rolling.py b/asv_bench/benchmarks/rolling.py
old mode 100644
new mode 100755
diff --git a/asv_bench/benchmarks/unstacking.py b/asv_bench/benchmarks/unstacking.py
old mode 100644
new mode 100755
diff --git a/azure-pipelines.yml b/azure-pipelines.yml
old mode 100644
new mode 100755
diff --git a/ci/azure/add-conda-to-path.yml b/ci/azure/add-conda-to-path.yml
old mode 100644
new mode 100755
diff --git a/ci/azure/install.yml b/ci/azure/install.yml
old mode 100644
new mode 100755
diff --git a/ci/azure/unit-tests.yml b/ci/azure/unit-tests.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/doc.yml b/ci/requirements/doc.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36-bare-minimum.yml b/ci/requirements/py36-bare-minimum.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36-min-all-deps.yml b/ci/requirements/py36-min-all-deps.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36-min-nep18.yml b/ci/requirements/py36-min-nep18.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py36.yml b/ci/requirements/py36.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py37-windows.yml b/ci/requirements/py37-windows.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py37.yml b/ci/requirements/py37.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py38-all-but-dask.yml b/ci/requirements/py38-all-but-dask.yml
old mode 100644
new mode 100755
diff --git a/ci/requirements/py38.yml b/ci/requirements/py38.yml
old mode 100644
new mode 100755
diff --git a/conftest.py b/conftest.py
old mode 100644
new mode 100755
diff --git a/doc/Makefile b/doc/Makefile
old mode 100644
new mode 100755
diff --git a/doc/README.rst b/doc/README.rst
old mode 100644
new mode 100755
diff --git a/doc/_static/.gitignore b/doc/_static/.gitignore
old mode 100644
new mode 100755
diff --git a/doc/_static/advanced_selection_interpolation.svg b/doc/_static/advanced_selection_interpolation.svg
old mode 100644
new mode 100755
diff --git a/doc/_static/ci.png b/doc/_static/ci.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dask_array.png b/doc/_static/dask_array.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-logo.png b/doc/_static/dataset-diagram-logo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-logo.tex b/doc/_static/dataset-diagram-logo.tex
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-square-logo.png b/doc/_static/dataset-diagram-square-logo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram-square-logo.tex b/doc/_static/dataset-diagram-square-logo.tex
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram.png b/doc/_static/dataset-diagram.png
old mode 100644
new mode 100755
diff --git a/doc/_static/dataset-diagram.tex b/doc/_static/dataset-diagram.tex
old mode 100644
new mode 100755
diff --git a/doc/_static/favicon.ico b/doc/_static/favicon.ico
old mode 100644
new mode 100755
diff --git a/doc/_static/numfocus_logo.png b/doc/_static/numfocus_logo.png
old mode 100644
new mode 100755
diff --git a/doc/_static/opendap-prism-tmax.png b/doc/_static/opendap-prism-tmax.png
old mode 100644
new mode 100755
diff --git a/doc/_static/style.css b/doc/_static/style.css
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor.rst b/doc/_templates/autosummary/accessor.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor_attribute.rst b/doc/_templates/autosummary/accessor_attribute.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor_callable.rst b/doc/_templates/autosummary/accessor_callable.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/autosummary/accessor_method.rst b/doc/_templates/autosummary/accessor_method.rst
old mode 100644
new mode 100755
diff --git a/doc/_templates/layout.html b/doc/_templates/layout.html
old mode 100644
new mode 100755
diff --git a/doc/api-hidden.rst b/doc/api-hidden.rst
old mode 100644
new mode 100755
diff --git a/doc/api.rst b/doc/api.rst
old mode 100644
new mode 100755
diff --git a/doc/combining.rst b/doc/combining.rst
old mode 100644
new mode 100755
diff --git a/doc/computation.rst b/doc/computation.rst
old mode 100644
new mode 100755
diff --git a/doc/conf.py b/doc/conf.py
old mode 100644
new mode 100755
diff --git a/doc/contributing.rst b/doc/contributing.rst
old mode 100644
new mode 100755
diff --git a/doc/dask.rst b/doc/dask.rst
old mode 100644
new mode 100755
diff --git a/doc/data-structures.rst b/doc/data-structures.rst
old mode 100644
new mode 100755
diff --git a/doc/examples.rst b/doc/examples.rst
old mode 100644
new mode 100755
diff --git a/doc/examples/ERA5-GRIB-example.ipynb b/doc/examples/ERA5-GRIB-example.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/ROMS_ocean_model.ipynb b/doc/examples/ROMS_ocean_model.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/_code/accessor_example.py b/doc/examples/_code/accessor_example.py
old mode 100644
new mode 100755
diff --git a/doc/examples/apply_ufunc_vectorize_1d.ipynb b/doc/examples/apply_ufunc_vectorize_1d.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/area_weighted_temperature.ipynb b/doc/examples/area_weighted_temperature.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/monthly-means.ipynb b/doc/examples/monthly-means.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/monthly_means_output.png b/doc/examples/monthly_means_output.png
old mode 100644
new mode 100755
diff --git a/doc/examples/multidimensional-coords.ipynb b/doc/examples/multidimensional-coords.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/visualization_gallery.ipynb b/doc/examples/visualization_gallery.ipynb
old mode 100644
new mode 100755
diff --git a/doc/examples/weather-data.ipynb b/doc/examples/weather-data.ipynb
old mode 100644
new mode 100755
diff --git a/doc/faq.rst b/doc/faq.rst
old mode 100644
new mode 100755
diff --git a/doc/gallery/README.txt b/doc/gallery/README.txt
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_cartopy_facetgrid.py b/doc/gallery/plot_cartopy_facetgrid.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_colorbar_center.py b/doc/gallery/plot_colorbar_center.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_control_colorbar.py b/doc/gallery/plot_control_colorbar.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_lines_from_2d.py b/doc/gallery/plot_lines_from_2d.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_rasterio.py b/doc/gallery/plot_rasterio.py
old mode 100644
new mode 100755
diff --git a/doc/gallery/plot_rasterio_rgb.py b/doc/gallery/plot_rasterio_rgb.py
old mode 100644
new mode 100755
diff --git a/doc/groupby.rst b/doc/groupby.rst
old mode 100644
new mode 100755
diff --git a/doc/howdoi.rst b/doc/howdoi.rst
old mode 100644
new mode 100755
diff --git a/doc/index.rst b/doc/index.rst
old mode 100644
new mode 100755
diff --git a/doc/indexing.rst b/doc/indexing.rst
old mode 100644
new mode 100755
diff --git a/doc/installing.rst b/doc/installing.rst
old mode 100644
new mode 100755
diff --git a/doc/internals.rst b/doc/internals.rst
old mode 100644
new mode 100755
diff --git a/doc/interpolation.rst b/doc/interpolation.rst
old mode 100644
new mode 100755
diff --git a/doc/io.rst b/doc/io.rst
old mode 100644
new mode 100755
diff --git a/doc/pandas.rst b/doc/pandas.rst
old mode 100644
new mode 100755
diff --git a/doc/plotting.rst b/doc/plotting.rst
old mode 100644
new mode 100755
diff --git a/doc/quick-overview.rst b/doc/quick-overview.rst
old mode 100644
new mode 100755
diff --git a/doc/related-projects.rst b/doc/related-projects.rst
old mode 100644
new mode 100755
diff --git a/doc/reshaping.rst b/doc/reshaping.rst
old mode 100644
new mode 100755
diff --git a/doc/roadmap.rst b/doc/roadmap.rst
old mode 100644
new mode 100755
diff --git a/doc/terminology.rst b/doc/terminology.rst
old mode 100644
new mode 100755
diff --git a/doc/time-series.rst b/doc/time-series.rst
old mode 100644
new mode 100755
diff --git a/doc/weather-climate.rst b/doc/weather-climate.rst
old mode 100644
new mode 100755
diff --git a/doc/whats-new.rst b/doc/whats-new.rst
old mode 100644
new mode 100755
diff --git a/doc/why-xarray.rst b/doc/why-xarray.rst
old mode 100644
new mode 100755
diff --git a/licenses/DASK_LICENSE b/licenses/DASK_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/ICOMOON_LICENSE b/licenses/ICOMOON_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/NUMPY_LICENSE b/licenses/NUMPY_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/PANDAS_LICENSE b/licenses/PANDAS_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/PYTHON_LICENSE b/licenses/PYTHON_LICENSE
old mode 100644
new mode 100755
diff --git a/licenses/SEABORN_LICENSE b/licenses/SEABORN_LICENSE
old mode 100644
new mode 100755
diff --git a/properties/README.md b/properties/README.md
old mode 100644
new mode 100755
diff --git a/properties/conftest.py b/properties/conftest.py
old mode 100644
new mode 100755
diff --git a/properties/test_encode_decode.py b/properties/test_encode_decode.py
old mode 100644
new mode 100755
diff --git a/properties/test_pandas_roundtrip.py b/properties/test_pandas_roundtrip.py
old mode 100644
new mode 100755
diff --git a/readthedocs.yml b/readthedocs.yml
old mode 100644
new mode 100755
diff --git a/requirements.txt b/requirements.txt
old mode 100644
new mode 100755
diff --git a/setup.cfg b/setup.cfg
old mode 100644
new mode 100755
diff --git a/xarray/__init__.py b/xarray/__init__.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/__init__.py b/xarray/backends/__init__.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/api.py b/xarray/backends/api.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/cfgrib_.py b/xarray/backends/cfgrib_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/common.py b/xarray/backends/common.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/file_manager.py b/xarray/backends/file_manager.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/h5netcdf_.py b/xarray/backends/h5netcdf_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/locks.py b/xarray/backends/locks.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/lru_cache.py b/xarray/backends/lru_cache.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/memory.py b/xarray/backends/memory.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/netCDF4_.py b/xarray/backends/netCDF4_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/netcdf3.py b/xarray/backends/netcdf3.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/pseudonetcdf_.py b/xarray/backends/pseudonetcdf_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/pydap_.py b/xarray/backends/pydap_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/pynio_.py b/xarray/backends/pynio_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/rasterio_.py b/xarray/backends/rasterio_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/scipy_.py b/xarray/backends/scipy_.py
old mode 100644
new mode 100755
diff --git a/xarray/backends/zarr.py b/xarray/backends/zarr.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/__init__.py b/xarray/coding/__init__.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/cftime_offsets.py b/xarray/coding/cftime_offsets.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/cftimeindex.py b/xarray/coding/cftimeindex.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/frequencies.py b/xarray/coding/frequencies.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/strings.py b/xarray/coding/strings.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/times.py b/xarray/coding/times.py
old mode 100644
new mode 100755
diff --git a/xarray/coding/variables.py b/xarray/coding/variables.py
old mode 100644
new mode 100755
diff --git a/xarray/conventions.py b/xarray/conventions.py
old mode 100644
```


# CONTRIBUTING.md (the start)

```
Xarray's contributor guidelines [can be found in our online documentation](http://xarray.pydata.org/en/stable/contributing.html)

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"`

## Scope
`xarray/core/dataarray.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when
- The MCVE runs to completion: stacking `{"a": arr, "b": arr}` over sample dim `x` and calling `to_unstacked_dataset("y")` raises no `MergeError`.
- The unstacked Dataset equals the original Dataset for variables that only have the sample dimension.
- (inferred) The existing roundtrip still works for variables that also have non-sample dimensions.

## Approach
Decomposition: reproduce the MCVE against the checked-out tree; find `to_unstacked_dataset` (the consuming half of the `to_stacked_array` / `to_unstacked_dataset` pair, implemented alongside `DataArray`/`Dataset`); identify where the per-variable selections are merged; make the selection drop the scalar coordinate along the stacked dimension (and any MultiIndex level coordinates) before merging; then run the scoped tests.

Root cause to confirm first: the loop selects `self.sel({dim: name})` for each variable name. For single-dim variables the only remaining coordinate on each selection is the scalar stacked-dim coordinate itself (e.g. `y`), whose value differs per selection, so the final merge sees conflicting values for `y`. Multi-dim variables happen to carry other coordinates that mask this.

Candidate approaches:
1. Minimal: add `drop=True` to each selection (`self.sel({dim: name}, drop=True)`), removing the offending scalar index coordinate; lowest risk, but may leave MultiIndex level scalars that still conflict or pollute the result.
2. Explicit: select, then `drop_vars` the stacked dim and its level coordinates, and transpose to the original dimension order before constructing the Dataset; slightly more code but robust to nested levels.
3. Reconstruct without merge: split the data by the `variable` level of the MultiIndex (or unstack and index out the variable level), building `Variable` objects/dict directly instead of `Dataset(variables)`; most robust against coordinate conflicts but a larger rewrite and more chance of changing dim order or attributes.

If the first attempt still fails, check whether the conflict moved to a level coordinate (`variable` or extra non-sample levels), whether the result has the right dims order for `assert_identical`, and whether `sel` on a single-level MultiIndex needs level-based indexing rather than raw value selection.
```

### `prompt.md`

````
to_unstacked_dataset broken for single-dim variables
<!-- A short summary of the issue, if appropriate -->


#### MCVE Code Sample

```python
arr = xr.DataArray(
     np.arange(3),
     coords=[("x", [0, 1, 2])],
 )
data = xr.Dataset({"a": arr, "b": arr})
stacked = data.to_stacked_array('y', sample_dims=['x'])
unstacked = stacked.to_unstacked_dataset('y')
# MergeError: conflicting values for variable 'y' on objects to be combined. You can skip this check by specifying compat='override'.
```

#### Expected Output
A working roundtrip.

#### Problem Description
I need to stack a bunch of variables and later unstack them again, however this doesn't work if the variables only have a single dimension.

#### Versions

<details><summary>Output of <tt>xr.show_versions()</tt></summary>

INSTALLED VERSIONS
------------------
commit: None
python: 3.7.3 (default, Mar 27 2019, 22:11:17) 
[GCC 7.3.0]
python-bits: 64
OS: Linux
OS-release: 4.15.0-96-generic
machine: x86_64
processor: x86_64
byteorder: little
LC_ALL: None
LANG: en_GB.UTF-8
LOCALE: en_GB.UTF-8
libhdf5: 1.10.4
libnetcdf: 4.6.2

xarray: 0.15.1
pandas: 1.0.3
numpy: 1.17.3
scipy: 1.3.1
netCDF4: 1.4.2
pydap: None
h5netcdf: None
h5py: 2.10.0
Nio: None
zarr: None
cftime: 1.0.4.2
nc_time_axis: None
PseudoNetCDF: None
rasterio: None
cfgrib: None
iris: None
bottleneck: None
dask: 2.10.1
distributed: 2.10.0
matplotlib: 3.1.1
cartopy: None
seaborn: 0.10.0
numbagg: None
setuptools: 41.0.0
pip: 19.0.3
conda: 4.8.3
pytest: 5.3.5
IPython: 7.9.0
sphinx: None


</details>
````

### `review.md`

```
verdict: PASS
The check status is 0; all 19 selected stack-related tests passed, including the new single-dimension roundtrip test.
The fix removes the stale scalar coordinate on the unstacked variable dimension before constructing the Dataset, directly addressing the reported MergeError.
The new test reproduces the MCVE and asserts `assert_identical(D, x)`, covering the single-sample-dimension roundtrip requirement.
Existing stack/unstack tests still passed, covering the inferred non-sample-dimension roundtrip behavior.
No out-of-scope file changes or content removal are indicated; `dataset.py` was not modified.
```

### `scope.txt`

```
scope: xarray/core/dataarray.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataarray.py +5 -1
changed: xarray/tests/test_dataset.py +9 -0
```

### `task.md`

````
# Task

## Prompt

to_unstacked_dataset broken for single-dim variables
<!-- A short summary of the issue, if appropriate -->


#### MCVE Code Sample

```python
arr = xr.DataArray(
     np.arange(3),
     coords=[("x", [0, 1, 2])],
 )
data = xr.Dataset({"a": arr, "b": arr})
stacked = data.to_stacked_array('y', sample_dims=['x'])
unstacked = stacked.to_unstacked_dataset('y')
# MergeError: conflicting values for variable 'y' on objects to be combined. You can skip this check by specifying compat='override'.
```

#### Expected Output
A working roundtrip.

#### Problem Description
I need to stack a bunch of variables and later unstack them again, however this doesn't work if the variables only have a single dimension.

#### Versions

<details><summary>Output of <tt>xr.show_versions()</tt></summary>

INSTALLED VERSIONS
------------------
commit: None
python: 3.7.3 (default, Mar 27 2019, 22:11:17) 
[GCC 7.3.0]
python-bits: 64
OS: Linux
OS-release: 4.15.0-96-generic
machine: x86_64
processor: x86_64
byteorder: little
LC_ALL: None
LANG: en_GB.UTF-8
LOCALE: en_GB.UTF-8
libhdf5: 1.10.4
libnetcdf: 4.6.2

xarray: 0.15.1
pandas: 1.0.3
numpy: 1.17.3
scipy: 1.3.1
netCDF4: 1.4.2
pydap: None
h5netcdf: None
h5py: 2.10.0
Nio: None
zarr: None
cftime: 1.0.4.2
nc_time_axis: None
PseudoNetCDF: None
rasterio: None
cfgrib: None
iris: None
bottleneck: None
dask: 2.10.1
distributed: 2.10.0
matplotlib: 3.1.1
cartopy: None
seaborn: 0.10.0
numbagg: None
setuptools: 41.0.0
pip: 19.0.3
conda: 4.8.3
pytest: 5.3.5
IPython: 7.9.0
sphinx: None


</details>

## Deliverable

changes to this tree

## Check

`pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"`

## Scope

`xarray/core/dataarray.py`
`xarray/core/dataset.py`
`xarray/tests/`

## Done when

- The MCVE runs to completion: stacking `{"a": arr, "b": arr}` over sample dim `x` and calling `to_unstacked_dataset("y")` raises no `MergeError`.
- The unstacked Dataset equals the original Dataset for variables that only have the sample dimension.
- (inferred) The existing roundtrip still works for variables that also have non-sample dimensions.
````

### `test-output.log`

```
check: pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -k "stack"
============================= test session starts ==============================
platform linux -- Python 3.10.15, pytest-7.4.0, pluggy-1.5.0
rootdir: /testbed
configfile: setup.cfg
plugins: cov-5.0.0, hypothesis-6.114.0, xdist-3.6.1, env-1.1.5
collected 1709 items / 1690 deselected / 19 selected

xarray/tests/test_dataarray.py ......                                    [ 31%]
xarray/tests/test_dataset.py .............                               [100%]

=============================== warnings summary ===============================
xarray/__init__.py:1
  /testbed/xarray/__init__.py:1: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
    import pkg_resources

xarray/core/dask_array_compat.py:16
xarray/core/dask_array_compat.py:16
  /testbed/xarray/core/dask_array_compat.py:16: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.0.0"):

xarray/core/dask_array_compat.py:149
xarray/core/dask_array_compat.py:149
  /testbed/xarray/core/dask_array_compat.py:149: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) >= LooseVersion("2.8.1"):

xarray/core/dask_array_compat.py:186
xarray/core/dask_array_compat.py:186
  /testbed/xarray/core/dask_array_compat.py:186: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
xarray/tests/__init__.py:54
  /testbed/xarray/tests/__init__.py:54: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_dask.py:593
  /testbed/xarray/tests/test_dask.py:593: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) >= "2.0", reason="no meta")

xarray/tests/test_dask.py:611
  /testbed/xarray/tests/test_dask.py:611: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dask.py:629
  /testbed/xarray/tests/test_dask.py:629: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    @pytest.mark.skipif(LooseVersion(dask.__version__) < "2.0", reason="needs meta")

xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
xarray/tests/test_dataarray.py::TestDataArray::test_stack_groupby_unsorted_coord
  /testbed/xarray/core/groupby.py:208: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/xarray/tests/test_dataarray.py:2082: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    levels=[pd.Int64Index([]), pd.Int64Index([0])],

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=============== 19 passed, 1690 deselected, 28 warnings in 8.74s ===============
scope: xarray/core/dataarray.py xarray/core/dataset.py xarray/tests
changed: xarray/core/dataarray.py +5 -1
changed: xarray/tests/test_dataset.py +9 -0
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
