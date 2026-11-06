# pydata__xarray-4356 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 348s 62 lines cost=0.006547 in=428306 cached=347136 out=8431 calls=33`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

sum: min_count is not available for reduction with more than one dimensions
**Is your feature request related to a problem? Please describe.**

`sum` with `min_count` errors when passing more than one dim:

```python
import xarray as xr
da = xr.DataArray([[1., 2, 3], [4, 5, 6]])
da.sum(["dim_0", "dim_1"], min_count=1)
```

**Describe the solution you'd like**
The logic to calculate the number of valid elements is here:
https://github.com/pydata/xarray/blob/1be777fe725a85b8cc0f65a2bc41f4bc2ba18043/xarray/core/nanops.py#L35

I *think* this can be fixed by replacing

`mask.shape[axis]` with `np.take(a.shape, axis).prod()`

**Additional context**
Potentially relevant for #4351

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain && git log --oneline -3"
}
```

**tool result**

```
/testbed
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
?? .memdoor/
e88eb916 SWE-bench
e05fddea Recreate @gajomi's #2070 to keep attrs when calling astype() (#4314)
68d0e0d2 annotate concat (#4346)
```

**assistant → tool `read_file`**

```json
{
  "path": "xarray/core/nanops.py",
  "limit": 220
}
```

**tool result**

```
import numpy as np

from . import dtypes, nputils, utils
from .duck_array_ops import _dask_or_eager_func, count, fillna, isnull, where_method
from .pycompat import dask_array_type

try:
    import dask.array as dask_array

    from . import dask_array_compat
except ImportError:
    dask_array = None
    dask_array_compat = None  # type: ignore


def _replace_nan(a, val):
    """
    replace nan in a by val, and returns the replaced array and the nan
    position
    """
    mask = isnull(a)
    return where_method(val, mask, a), mask


def _maybe_null_out(result, axis, mask, min_count=1):
    """
    xarray version of pandas.core.nanops._maybe_null_out
    """
    if hasattr(axis, "__len__"):  # if tuple or list
        raise ValueError(
            "min_count is not available for reduction with more than one dimensions."
        )

    if axis is not None and getattr(result, "ndim", False):
        null_mask = (mask.shape[axis] - mask.sum(axis) - min_count) < 0
        if null_mask.any():
            dtype, fill_value = dtypes.maybe_promote(result.dtype)
            result = result.astype(dtype)
            result[null_mask] = fill_value

    elif getattr(result, "dtype", None) not in dtypes.NAT_TYPES:
        null_mask = mask.size - mask.sum()
        if null_mask < min_count:
            result = np.nan

    return result


def _nan_argminmax_object(func, fill_value, value, axis=None, **kwargs):
    """ In house nanargmin, nanargmax for object arrays. Always return integer
    type
    """
    valid_count = count(value, axis=axis)
    value = fillna(value, fill_value)
    data = _dask_or_eager_func(func)(value, axis=axis, **kwargs)

    # TODO This will evaluate dask arrays and might be costly.
    if (valid_count == 0).any():
        raise ValueError("All-NaN slice encountered")

    return data


def _nan_minmax_object(func, fill_value, value, axis=None, **kwargs):
    """ In house nanmin and nanmax for object array """
    valid_count = count(value, axis=axis)
    filled_value = fillna(value, fill_value)
    data = getattr(np, func)(filled_value, axis=axis, **kwargs)
    if not hasattr(data, "dtype"):  # scalar case
        data = fill_value if valid_count == 0 else data
        # we've computed a single min, max value of type object.
        # don't let np.array turn a tuple back into an array
        return utils.to_0d_object_array(data)
    return where_method(data, valid_count != 0)


def nanmin(a, axis=None, out=None):
    if a.dtype.kind == "O":
        return _nan_minmax_object("min", dtypes.get_pos_infinity(a.dtype), a, axis)

    module = dask_array if isinstance(a, dask_array_type) else nputils
    return module.nanmin(a, axis=axis)


def nanmax(a, axis=None, out=None):
    if a.dtype.kind == "O":
        return _nan_minmax_object("max", dtypes.get_neg_infinity(a.dtype), a, axis)

    module = dask_array if isinstance(a, dask_array_type) else nputils
    return module.nanmax(a, axis=axis)


def nanargmin(a, axis=None):
    if a.dtype.kind == "O":
        fill_value = dtypes.get_pos_infinity(a.dtype)
        return _nan_argminmax_object("argmin", fill_value, a, axis=axis)

    module = dask_array if isinstance(a, dask_array_type) else nputils
    return module.nanargmin(a, axis=axis)


def nanargmax(a, axis=None):
    if a.dtype.kind == "O":
        fill_value = dtypes.get_neg_infinity(a.dtype)
        return _nan_argminmax_object("argmax", fill_value, a, axis=axis)

    module = dask_array if isinstance(a, dask_array_type) else nputils
    return module.nanargmax(a, axis=axis)


def nansum(a, axis=None, dtype=None, out=None, min_count=None):
    a, mask = _replace_nan(a, 0)
    result = _dask_or_eager_func("sum")(a, axis=axis, dtype=dtype)
    if min_count is not None:
        return _maybe_null_out(result, axis, mask, min_count)
    else:
        return result


def _nanmean_ddof_object(ddof, value, axis=None, dtype=None, **kwargs):
    """ In house nanmean. ddof argument will be used in _nanvar method """
    from .duck_array_ops import _dask_or_eager_func, count, fillna, where_method

    valid_count = count(value, axis=axis)
    value = fillna(value, 0)
    # As dtype inference is impossible for object dtype, we assume float
    # https://github.com/dask/dask/issues/3162
    if dtype is None and value.dtype.kind == "O":
        dtype = value.dtype if value.dtype.kind in ["cf"] else float

    data = _dask_or_eager_func("sum")(value, axis=axis, dtype=dtype, **kwargs)
    data = data / (valid_count - ddof)
    return where_method(data, valid_count != 0)


def nanmean(a, axis=None, dtype=None, out=None):
    if a.dtype.kind == "O":
        return _nanmean_ddof_object(0, a, axis=axis, dtype=dtype)

    if isinstance(a, dask_array_type):
        return dask_array.nanmean(a, axis=axis, dtype=dtype)

    return np.nanmean(a, axis=axis, dtype=dtype)


def nanmedian(a, axis=None, out=None):
    # The dask algorithm works by rechunking to one chunk along axis
    # Make sure we trigger the dask error when passing all dimensions
    # so that we don't rechunk the entire array to one chunk and
    # possibly blow memory
    if axis is not None and len(np.atleast_1d(axis)) == a.ndim:
        axis = None
    return _dask_or_eager_func(
        "nanmedian", dask_module=dask_array_compat, eager_module=nputils
    )(a, axis=axis)


def _nanvar_object(value, axis=None, ddof=0, keepdims=False, **kwargs):
    value_mean = _nanmean_ddof_object(
        ddof=0, value=value, axis=axis, keepdims=True, **kwargs
    )
    squared = (value.astype(value_mean.dtype) - value_mean) ** 2
    return _nanmean_ddof_object(ddof, squared, axis=axis, keepdims=keepdims, **kwargs)


def nanvar(a, axis=None, dtype=None, out=None, ddof=0):
    if a.dtype.kind == "O":
        return _nanvar_object(a, axis=axis, dtype=dtype, ddof=ddof)

    return _dask_or_eager_func("nanvar", eager_module=nputils)(
        a, axis=axis, dtype=dtype, ddof=ddof
    )


def nanstd(a, axis=None, dtype=None, out=None, ddof=0):
    return _dask_or_eager_func("nanstd", eager_module=nputils)(
        a, axis=axis, dtype=dtype, ddof=ddof
    )


def nanprod(a, axis=None, dtype=None, out=None, min_count=None):
    a, mask = _replace_nan(a, 1)
    result = _dask_or_eager_func("nanprod")(a, axis=axis, dtype=dtype, out=out)
    if min_count is not None:
        return _maybe_null_out(result, axis, mask, min_count)
    else:
        return result


def nancumsum(a, axis=None, dtype=None, out=None):
    return _dask_or_eager_func("nancumsum", eager_module=nputils)(
        a, axis=axis, dtype=dtype
    )


def nancumprod(a, axis=None, dtype=None, out=None):
    return _dask_or_eager_func("nancumprod", eager_module=nputils)(
        a, axis=axis, dtype=dtype
    )
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"min_count\" xarray/tests | head -50"
}
```

**tool result**

```
xarray/tests/test_duck_array_ops.py:585:def test_min_count(dim_num, dtype, dask, func, aggdim):
xarray/tests/test_duck_array_ops.py:590:    min_count = 3
xarray/tests/test_duck_array_ops.py:592:    actual = getattr(da, func)(dim=aggdim, skipna=True, min_count=min_count)
xarray/tests/test_duck_array_ops.py:593:    expected = series_reduce(da, func, skipna=True, dim=aggdim, min_count=min_count)
xarray/tests/test_duck_array_ops.py:599:def test_min_count_dataset(func):
xarray/tests/test_duck_array_ops.py:602:    actual = getattr(ds, func)(dim="x", skipna=True, min_count=3)["var1"]
xarray/tests/test_duck_array_ops.py:603:    expected = getattr(ds["var1"], func)(dim="x", skipna=True, min_count=3)
xarray/tests/test_duck_array_ops.py:621:    # with min_count
xarray/tests/test_duck_array_ops.py:640:        min_count : int, default: None
xarray/tests/test_duck_array_ops.py:642:            If fewer than min_count non-NA values are present the result will
xarray/tests/test_duck_array_ops.py:661:    # without min_count
xarray/tests/test_dataset.py:3731:    def test_resample_min_count(self):
xarray/tests/test_dataset.py:3743:        actual = ds.resample(time="1D").sum(min_count=1)
xarray/tests/test_dataset.py:3746:                ds.isel(time=slice(i * 4, (i + 1) * 4)).sum("time", min_count=1)
xarray/tests/test_dataset.py:5944:            ds[key].values, window=7, axis=0, min_count=min_periods
xarray/tests/test_dataarray.py:6239:        da.values, window=7, axis=1, min_count=min_periods
```

**assistant → tool `read_file`**

```json
{
  "path": "xarray/tests/test_duck_array_ops.py",
  "offset": 540,
  "limit": 140
}
```

**tool result**

```
@pytest.mark.parametrize("center", [True, False])
def test_dask_rolling(axis, window, center):
    import dask.array as da

    x = np.array(np.random.randn(100, 40), dtype=float)
    dx = da.from_array(x, chunks=[(6, 30, 30, 20, 14), 8])

    expected = rolling_window(
        x, axis=axis, window=window, center=center, fill_value=np.nan
    )
    actual = rolling_window(
        dx, axis=axis, window=window, center=center, fill_value=np.nan
    )
    assert isinstance(actual, da.Array)
    assert_array_equal(actual, expected)
    assert actual.shape == expected.shape

    # we need to take care of window size if chunk size is small
    # window/2 should be smaller than the smallest chunk size.
    with pytest.raises(ValueError):
        rolling_window(dx, axis=axis, window=100, center=center, fill_value=np.nan)


@pytest.mark.skipif(not has_dask, reason="This is for dask.")
@pytest.mark.parametrize("axis", [0, -1, 1])
@pytest.mark.parametrize("edge_order", [1, 2])
def test_dask_gradient(axis, edge_order):
    import dask.array as da

    array = np.array(np.random.randn(100, 5, 40))
    x = np.exp(np.linspace(0, 1, array.shape[axis]))

    darray = da.from_array(array, chunks=[(6, 30, 30, 20, 14), 5, 8])
    expected = gradient(array, x, axis=axis, edge_order=edge_order)
    actual = gradient(darray, x, axis=axis, edge_order=edge_order)

    assert isinstance(actual, da.Array)
    assert_array_equal(actual, expected)


@pytest.mark.parametrize("dim_num", [1, 2])
@pytest.mark.parametrize("dtype", [float, int, np.float32, np.bool_])
@pytest.mark.parametrize("dask", [False, True])
@pytest.mark.parametrize("func", ["sum", "prod"])
@pytest.mark.parametrize("aggdim", [None, "x"])
def test_min_count(dim_num, dtype, dask, func, aggdim):
    if dask and not has_dask:
        pytest.skip("requires dask")

    da = construct_dataarray(dim_num, dtype, contains_nan=True, dask=dask)
    min_count = 3

    actual = getattr(da, func)(dim=aggdim, skipna=True, min_count=min_count)
    expected = series_reduce(da, func, skipna=True, dim=aggdim, min_count=min_count)
    assert_allclose(actual, expected)
    assert_dask_array(actual, dask)


@pytest.mark.parametrize("func", ["sum", "prod"])
def test_min_count_dataset(func):
    da = construct_dataarray(2, dtype=float, contains_nan=True, dask=False)
    ds = Dataset({"var1": da}, coords={"scalar": 0})
    actual = getattr(ds, func)(dim="x", skipna=True, min_count=3)["var1"]
    expected = getattr(ds["var1"], func)(dim="x", skipna=True, min_count=3)
    assert_allclose(actual, expected)


@pytest.mark.parametrize("dtype", [float, int, np.float32, np.bool_])
@pytest.mark.parametrize("dask", [False, True])
@pytest.mark.parametrize("func", ["sum", "prod"])
def test_multiple_dims(dtype, dask, func):
    if dask and not has_dask:
        pytest.skip("requires dask")
    da = construct_dataarray(3, dtype, contains_nan=True, dask=dask)

    actual = getattr(da, func)(("x", "y"))
    expected = getattr(getattr(da, func)("x"), func)("y")
    assert_allclose(actual, expected)


def test_docs():
    # with min_count
    actual = DataArray.sum.__doc__
    expected = dedent(
        """\
        Reduce this DataArray's data by applying `sum` along some dimension(s).

        Parameters
        ----------
        dim : str or sequence of str, optional
            Dimension(s) over which to apply `sum`.
        axis : int or sequence of int, optional
            Axis(es) over which to apply `sum`. Only one of the 'dim'
            and 'axis' arguments can be supplied. If neither are supplied, then
            `sum` is calculated over axes.
        skipna : bool, optional
            If True, skip missing values (as marked by NaN). By default, only
            skips missing values for float dtypes; other dtypes either do not
            have a sentinel missing value (int) or skipna=True has not been
            implemented (object, datetime64 or timedelta64).
        min_count : int, default: None
            The required number of valid values to perform the operation.
            If fewer than min_count non-NA values are present the result will
            be NA. New in version 0.10.8: Added with the default being None.
        keep_attrs : bool, optional
            If True, the attributes (`attrs`) will be copied from the original
            object to the new one.  If False (default), the new object will be
            returned without attributes.
        **kwargs : dict
            Additional keyword arguments passed on to the appropriate array
            function for calculating `sum` on this object's data.

        Returns
        -------
        reduced : DataArray
            New DataArray object with `sum` applied to its data and the
            indicated dimension(s) removed.
        """
    )
    assert actual == expected

    # without min_count
    actual = DataArray.std.__doc__
    expected = dedent(
        """\
        Reduce this DataArray's data by applying `std` along some dimension(s).

        Parameters
        ----------
        dim : str or sequence of str, optional
            Dimension(s) over which to apply `std`.
        axis : int or sequence of int, optional
            Axis(es) over which to apply `std`. Only one of the 'dim'
            and 'axis' arguments can be supplied. If neither are supplied, then
            `std` is calculated over axes.
        skipna : bool, optional
            If True, skip missing values (as marked by NaN). By default, only
            skips missing values for float dtypes; other dtypes either do not
            have a sentinel missing value (int) or skipna=True has not been
            implemented (object, datetime64 or timedelta64).

[137 more lines in /testbed/xarray/tests/test_duck_array_ops.py (816 in all). read_file with offset: 680 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/core/nanops.py\n@@\n def _maybe_null_out(result, axis, mask, min_count=1):\n     \"\"\"\n     xarray version of pandas.core.nanops._maybe_null_out\n     \"\"\"\n-    if hasattr(axis, \"__len__\"):  # if tuple or list\n-        raise ValueError(\n-            \"min_count is not available for reduction with more than one dimensions.\"\n-        )\n+    if axis is None:\n+        axis = tuple(range(mask.ndim))\n+    if not hasattr(axis, \"__len__\"):\n+        axis = (axis,)\n \n-    if axis is not None and getattr(result, \"ndim\", False):\n-        null_mask = (mask.shape[axis] - mask.sum(axis) - min_count) < 0\n+    if getattr(result, \"ndim\", False):\n+        null_mask = (np.take(mask.shape, axis).prod() - mask.sum(axis) - min_count) < 0\n         if null_mask.any():\n             dtype, fill_value = dtypes.maybe_promote(result.dtype)\n             result = result.astype(dtype)\n             result[null_mask] = fill_value\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/core/nanops.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/core/nanops.py now (199 lines), around the change:
26:    """
27:    xarray version of pandas.core.nanops._maybe_null_out
28:    """
29:    if axis is None:
30:        axis = tuple(range(mask.ndim))
31:    if not hasattr(axis, "__len__"):
32:        axis = (axis,)
33:
34:    if getattr(result, "ndim", False):
35:        null_mask = (np.take(mask.shape, axis).prod() - mask.sum(axis) - min_count) < 0
36:        if null_mask.any():
37:            dtype, fill_value = dtypes.maybe_promote(result.dtype)
38:            result = result.astype(dtype)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_duck_array_ops.py -k \"min_count or multiple_dims\" -q 2>&1 | tail -30"
}
```

**tool result**

```
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
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:58
xarray/tests/__init__.py:58
  /testbed/xarray/tests/__init__.py:58: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
82 passed, 706 deselected, 11 warnings in 60.47s (0:01:00)
```

**assistant → tool `bash`**

```json
{
  "command": "python -c 'import xarray as xr; da=xr.DataArray([[1.,2,3],[4,5,6]]); print(da.sum([\"dim_0\",\"dim_1\"], min_count=1)); print(da.sum([\"dim_0\",\"dim_1\"], min_count=7))' && git diff --stat && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo OK"
}
```

**tool result**

```
<xarray.DataArray ()>
array(21.)
<xarray.DataArray ()>
array(21.)
 xarray/core/nanops.py | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)
OK
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport numpy as np\nfrom xarray.core import nanops\na=np.array([[1.,2,3],[4,5,6]])\nprint(nanops.nansum(a, axis=(0,1), min_count=7), type(nanops.nansum(a, axis=(0,1), min_count=7)))\nprint(nanops.nansum(a, axis=(0,1), min_count=6))\nimport xarray as xr\nda=xr.DataArray(a)\nprint(da.sum([\"dim_0\",\"dim_1\"], min_count=7))\n'"
}
```

**tool result**

```
21.0 <class 'numpy.float64'>
21.0
<xarray.DataArray ()>
array(21.)
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport numpy as np\nfrom xarray.core import nanops\na=np.array([[1.,2,3],[4,5,6]])\nr=nanops._replace_nan(a,0)\nprint(r[1].size, r[1].sum())\nprint(nanops._maybe_null_out(np.sum(a,axis=(0,1)), (0,1), r[1], 7))\nprint(nanops.nansum(a, axis=(0,1), min_count=7))\n'"
}
```

**tool result**

```
6 0
21.0
21.0
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport numpy as np\nfrom xarray.core import dtypes, nanops\nprint(dtypes.NAT_TYPES)\na=np.array([[1.,2,3],[4,5,6]])\n_,m=nanops._replace_nan(a,0)\nprint(np.float64(21).dtype in dtypes.NAT_TYPES)\nprint(getattr(np.float64(21), \"dtype\", None))\n'"
}
```

**tool result**

```
(numpy.datetime64('NaT'), numpy.timedelta64('NaT'))
True
float64
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport numpy as np\nfrom xarray.core import dtypes\nfor x in [np.dtype(\"float64\"), np.float64, float, np.dtype(\"M8[ns]\")]:\n    print(x, x in dtypes.NAT_TYPES)\nprint(np.dtype(\"float64\")==np.datetime64(\"NaT\"))\n'"
}
```

**tool result**

```
<string>:5: DeprecationWarning: elementwise comparison failed; this will raise an error in the future.
float64 True
<class 'numpy.float64'> False
<class 'float'> False
datetime64[ns] False
False
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport numpy as np\nprint(np.dtype(\"float64\")==np.datetime64(\"NaT\"))\nprint(np.dtype(\"float64\")==np.timedelta64(\"NaT\"))\n'"
}
```

**tool result**

```
False
False
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"NAT_TYPES\" -n xarray/core/dtypes.py && python -c '\nimport numpy as np\nfrom xarray.core import dtypes\nprint(dtypes.NAT_TYPES)\nx=np.dtype(\"float64\")\nfor t in dtypes.NAT_TYPES:\n print(repr(t), x==t, hash(x), hash(t))\n'"
}
```

**tool result**

```
81:NAT_TYPES = (np.datetime64("NaT"), np.timedelta64("NaT"))
(numpy.datetime64('NaT'), numpy.timedelta64('NaT'))
numpy.datetime64('NaT') False -2304909299807985907 -9223372036854775808
numpy.timedelta64('NaT') False -2304909299807985907 -9223372036854775808
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport numpy as np\nfrom xarray.core import dtypes\nr=np.float64(21)\nprint(r.dtype not in dtypes.NAT_TYPES)\nprint(bool(r.dtype in dtypes.NAT_TYPES))\nprint(r.dtype == dtypes.NAT_TYPES[0])\n'"
}
```

**tool result**

```
False
True
False
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/core/nanops.py\n@@\n-    elif getattr(result, \"dtype\", None) not in dtypes.NAT_TYPES:\n+    elif getattr(getattr(result, \"dtype\", None), \"kind\", None) not in \"mM\":\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/core/nanops.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/core/nanops.py now (199 lines), around the change:
38:            result = result.astype(dtype)
39:            result[null_mask] = fill_value
40:
41:    elif getattr(getattr(result, "dtype", None), "kind", None) not in "mM":
42:        null_mask = mask.size - mask.sum()
43:        if null_mask < min_count:
44:            result = np.nan
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport numpy as np\nfrom xarray.core import nanops\na=np.array([[1.,2,3],[4,5,6]])\nprint(nanops.nansum(a, axis=(0,1), min_count=7))\nprint(nanops.nansum(a, axis=(0,1), min_count=6))\nprint(nanops.nansum(a, axis=None, min_count=7))\nprint(nanops.nansum(a, axis=0, min_count=3))\nprint(nanops.nansum(a, axis=0, min_count=2))\n'"
}
```

**tool result**

```
nan
21.0
nan
[nan nan nan]
[5. 7. 9.]
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_duck_array_ops.py -k \"min_count or multiple_dims\" -q 2>&1 | tail -5 && git diff"
}
```

**tool result**

```
FAILED xarray/tests/test_duck_array_ops.py::test_min_count[None-prod-False-bool_-1]
FAILED xarray/tests/test_duck_array_ops.py::test_min_count[None-prod-False-bool_-2]
FAILED xarray/tests/test_duck_array_ops.py::test_min_count[x-sum-False-bool_-1]
FAILED xarray/tests/test_duck_array_ops.py::test_min_count[x-prod-False-bool_-1]
6 failed, 76 passed, 706 deselected, 11 warnings in 5.61s
diff --git a/xarray/core/nanops.py b/xarray/core/nanops.py
index 41c8d258..61977add 100644
--- a/xarray/core/nanops.py
+++ b/xarray/core/nanops.py
@@ -26,19 +26,19 @@ def _maybe_null_out(result, axis, mask, min_count=1):
     """
     xarray version of pandas.core.nanops._maybe_null_out
     """
-    if hasattr(axis, "__len__"):  # if tuple or list
-        raise ValueError(
-            "min_count is not available for reduction with more than one dimensions."
-        )
+    if axis is None:
+        axis = tuple(range(mask.ndim))
+    if not hasattr(axis, "__len__"):
+        axis = (axis,)
 
-    if axis is not None and getattr(result, "ndim", False):
-        null_mask = (mask.shape[axis] - mask.sum(axis) - min_count) < 0
+    if getattr(result, "ndim", False):
+        null_mask = (np.take(mask.shape, axis).prod() - mask.sum(axis) - min_count) < 0
         if null_mask.any():
             dtype, fill_value = dtypes.maybe_promote(result.dtype)
             result = result.astype(dtype)
             result[null_mask] = fill_value
 
-    elif getattr(result, "dtype", None) not in dtypes.NAT_TYPES:
+    elif getattr(getattr(result, "dtype", None), "kind", None) not in "mM":
         null_mask = mask.size - mask.sum()
         if null_mask < min_count:
             result = np.nan
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest \"xarray/tests/test_duck_array_ops.py::test_min_count[None-prod-False-bool_-1]\" -q 2>&1 | tail -40"
}
```

**tool result**

```
E       TypeError: 'in <string>' requires string as left operand, not NoneType

xarray/core/nanops.py:41: TypeError
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
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:58
xarray/tests/__init__.py:58
  /testbed/xarray/tests/__init__.py:58: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_duck_array_ops.py::test_min_count[None-prod-False-bool_-1]
1 failed, 11 warnings in 3.45s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/core/nanops.py\n@@\n-    elif getattr(getattr(result, \"dtype\", None), \"kind\", None) not in \"mM\":\n+    elif getattr(getattr(result, \"dtype\", None), \"kind\", \"\") not in \"mM\":\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/core/nanops.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/core/nanops.py now (199 lines), around the change:
38:            result = result.astype(dtype)
39:            result[null_mask] = fill_value
40:
41:    elif getattr(getattr(result, "dtype", None), "kind", "") not in "mM":
42:        null_mask = mask.size - mask.sum()
43:        if null_mask < min_count:
44:            result = np.nan
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_duck_array_ops.py -k \"min_count or multiple_dims\" -q 2>&1 | tail -5"
}
```

**tool result**

```
  /testbed/xarray/tests/__init__.py:58: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
82 passed, 706 deselected, 11 warnings in 4.41s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_duck_array_ops.py -q 2>&1 | tail -5"
}
```

**tool result**

```
  /testbed/xarray/core/variable.py:1043: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) < "2.0.0":

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
580 passed, 208 skipped, 21 warnings in 12.17s
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport xarray as xr, numpy as np\nda=xr.DataArray([[1.,2,np.nan],[4,5,6]], dims=(\"a\",\"b\"))\nprint(da.sum([\"a\",\"b\"], min_count=6))\nprint(da.sum([\"a\",\"b\"], min_count=5))\nprint(da.sum(axis=[0,1], min_count=6))\nprint(da.prod([\"a\",\"b\"], min_count=6))\n' && test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```
Command FAILED (exit status 1): `python -c '
import xarray as xr, numpy as np
da=xr.DataArray([[1.,2,np.nan],[4,5,6]], dims=("a","b"))
print(da.sum(["a","b"], min_count=6))
print(da.sum(["a","b"], min_count=5))
print(da.sum(axis=[0,1], min_count=6))
print(da.prod(["a","b"], min_count=6))
' && test -n "$(git status --porcelain -- . ':(exclude).memdoor')" && echo TASK_OK`
Output: Traceback (most recent call last):
  File "<string>", line 6, in <module>
  File "/testbed/xarray/core/common.py", line 46, in wrapped_func
    return self.reduce(func, dim, axis, skipna=skipna, **kwargs)
  File "/testbed/xarray/core/dataarray.py", line 2347, in reduce
    var = self.variable.reduce(func, dim, axis, keep_attrs, keepdims, **kwargs)
  File "/testbed/xarray/core/variable.py", line 1640, in reduce
    data = func(input_data, axis=axis, **kwargs)
  File "/testbed/xarray/core/duck_array_ops.py", line 335, in f
    return func(values, axis=axis, **kwargs)
  File "/testbed/xarray/core/nanops.py", line 113, in nansum
    result = _dask_or_eager_func("sum")(a, axis=axis, dtype=dtype)
  File "/testbed/xarray/core/duck_array_ops.py", line 49, in f
    return wrapped(*args, **kwargs)
  File "<__array_function__ internals>", line 180, in sum
  File "/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/core/fromnumeric.py", line 2298, in sum
    return _wrapreduction(a, np.add, 'sum', axis, dtype, out, keepdims=keepdims,
  File "/opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/core/fromnumeric.py", line 86, in _wrapreduction
    return ufunc.reduce(obj, axis, dtype, out, **passkwargs)
TypeError: 'list' object cannot be interpreted as an integer
<xarray.DataArray ()>
array(nan)
<xarray.DataArray ()>
array(18.)

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport xarray as xr, numpy as np\nda=xr.DataArray([[1.,2,np.nan],[4,5,6]], dims=(\"a\",\"b\"))\ntry:\n print(da.sum(axis=[0,1]))\nexcept Exception as e: print(type(e), e)\nprint(da.sum([\"a\",\"b\"], min_count=6))\nprint(da.sum([\"a\",\"b\"], min_count=5))\nprint(da.prod([\"a\",\"b\"], min_count=6))\n'"
}
```

**tool result**

```
<class 'TypeError'> 'list' object cannot be interpreted as an integer
<xarray.DataArray ()>
array(nan)
<xarray.DataArray ()>
array(18.)
<xarray.DataArray ()>
array(nan)
```

**assistant → tool `bash`**

```json
{
  "command": "python -c '\nimport xarray as xr, numpy as np\ntry:\n import dask.array as dask\n da=xr.DataArray(dask.from_array(np.array([[1.,2,np.nan],[4,5,6]]), chunks=1), dims=(\"a\",\"b\"))\n print(da.sum([\"a\",\"b\"], min_count=6).compute())\n print(da.sum([\"a\",\"b\"], min_count=5).compute())\nexcept ImportError: print(\"no dask\")\n'"
}
```

**tool result**

```
<xarray.DataArray 'array-1d351fab8cab08498c8d6e5a0b47e509' ()>
array(nan)
<xarray.DataArray 'array-1d351fab8cab08498c8d6e5a0b47e509' ()>
array(18.)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_duck_array_ops.py\n@@\n @pytest.mark.parametrize(\"func\", [\"sum\", \"prod\"])\n def test_min_count_dataset(func):\n     da = construct_dataarray(2, dtype=float, contains_nan=True, dask=False)\n     ds = Dataset({\"var1\": da}, coords={\"scalar\": 0})\n     actual = getattr(ds, func)(dim=\"x\", skipna=True, min_count=3)[\"var1\"]\n     expected = getattr(ds[\"var1\"], func)(dim=\"x\", skipna=True, min_count=3)\n     assert_allclose(actual, expected)\n \n \n+@pytest.mark.parametrize(\"dtype\", [float, int, np.float32, np.bool_])\n+@pytest.mark.parametrize(\"dask\", [False, True])\n+@pytest.mark.parametrize(\"func\", [\"sum\", \"prod\"])\n+@pytest.mark.parametrize(\"aggdim\", [(\"x\", \"y\"), (\"y\", \"z\")])\n+def test_min_count_multiple_dims(dtype, dask, func, aggdim):\n+    if dask and not has_dask:\n+        pytest.skip(\"requires dask\")\n+    da = construct_dataarray(3, dtype, contains_nan=True, dask=dask)\n+    min_count = 3\n+\n+    actual = getattr(da, func)(dim=aggdim, skipna=True, min_count=min_count)\n+    expected = series_reduce(\n+        da, func, skipna=True, dim=aggdim, min_count=min_count\n+    )\n+    assert_allclose(actual, expected)\n+    assert_dask_array(actual, dask)\n+\n+\n @pytest.mark.parametrize(\"dtype\", [float, int, np.float32, np.bool_])\n @pytest.mark.parametrize(\"dask\", [False, True])\n @pytest.mark.parametrize(\"func\", [\"sum\", \"prod\"])\n def test_multiple_dims(dtype, dask, func):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/tests/test_duck_array_ops.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/tests/test_duck_array_ops.py now (834 lines), around the change:
602:    actual = getattr(ds, func)(dim="x", skipna=True, min_count=3)["var1"]
603:    expected = getattr(ds["var1"], func)(dim="x", skipna=True, min_count=3)
604:    assert_allclose(actual, expected)
605:
606:
607:@pytest.mark.parametrize("dtype", [float, int, np.float32, np.bool_])
608:@pytest.mark.parametrize("dask", [False, True])
609:@pytest.mark.parametrize("func", ["sum", "prod"])
610:@pytest.mark.parametrize("aggdim", [("x", "y"), ("y", "z")])
611:def test_min_count_multiple_dims(dtype, dask, func, aggdim):
612:    if dask and not has_dask:
613:        pytest.skip("requires dask")
614:    da = construct_dataarray(3, dtype, contains_nan=True, dask=dask)
615:    min_count = 3
616:
617:    actual = getattr(da, func)(dim=aggdim, skipna=True, min_count=min_count)
618:    expected = series_reduce(
619:        da, func, skipna=True, dim=aggdim, min_count=min_count
620:    )
621:    assert_allclose(actual, expected)
622:    assert_dask_array(actual, dask)
623:
624:
625:@pytest.mark.parametrize("dtype", [float, int, np.float32, np.bool_])
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def series_reduce\" -A 25 xarray/tests/test_duck_array_ops.py"
}
```

**tool result**

```
259:def series_reduce(da, func, dim, **kwargs):
260-    """ convert DataArray to pd.Series, apply pd.func, then convert back to
261-    a DataArray. Multiple dims cannot be specified."""
262-    if dim is None or da.ndim == 1:
263-        se = da.to_series()
264-        return from_series_or_scalar(getattr(se, func)(**kwargs))
265-    else:
266-        da1 = []
267-        dims = list(da.dims)
268-        dims.remove(dim)
269-        d = dims[0]
270-        for i in range(len(da[d])):
271-            da1.append(series_reduce(da.isel(**{d: i}), func, dim, **kwargs))
272-
273-        if d in da.coords:
274-            return concat(da1, dim=da[d])
275-        return concat(da1, dim=d)
276-
277-
278-def assert_dask_array(da, dask):
279-    if dask and da.ndim > 0:
280-        assert isinstance(da.data, dask_array_type)
281-
282-
283-@arm_xfail
284-@pytest.mark.filterwarnings("ignore::RuntimeWarning")
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_duck_array_ops.py\n@@\n     da = construct_dataarray(3, dtype, contains_nan=True, dask=dask)\n     min_count = 3\n \n     actual = getattr(da, func)(dim=aggdim, skipna=True, min_count=min_count)\n-    expected = series_reduce(\n-        da, func, skipna=True, dim=aggdim, min_count=min_count\n-    )\n+    expected = da\n+    for dim in aggdim:\n+        expected = series_reduce(\n+            expected, func, skipna=True, dim=dim, min_count=min_count\n+        )\n     assert_allclose(actual, expected)\n     assert_dask_array(actual, dask)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/tests/test_duck_array_ops.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/tests/test_duck_array_ops.py now (836 lines), around the change:
615:    min_count = 3
616:
617:    actual = getattr(da, func)(dim=aggdim, skipna=True, min_count=min_count)
618:    expected = da
619:    for dim in aggdim:
620:        expected = series_reduce(
621:            expected, func, skipna=True, dim=dim, min_count=min_count
622:        )
623:    assert_allclose(actual, expected)
624:    assert_dask_array(actual, dask)
625:
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_duck_array_ops.py -k \"min_count\" -q 2>&1 | tail -20"
}
```

**tool result**

```
xarray/core/dask_array_compat.py:186
xarray/core/dask_array_compat.py:186
  /testbed/xarray/core/dask_array_compat.py:186: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion("2.9.0"):

xarray/core/pdcompat.py:45
  /testbed/xarray/core/pdcompat.py:45: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < "0.25.0":

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:58
xarray/tests/__init__.py:58
  /testbed/xarray/tests/__init__.py:58: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
98 passed, 722 deselected, 11 warnings in 7.67s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_duck_array_ops.py xarray/tests/test_variable.py -q 2>&1 | tail -5"
}
```

**tool result**

```
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
972 passed, 208 skipped, 68 xfailed, 22 xpassed, 162 warnings in 44.21s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m black --check xarray/core/nanops.py xarray/tests/test_duck_array_ops.py 2>&1; python -m flake8 xarray/core/nanops.py xarray/tests/test_duck_array_ops.py 2>&1 | head; git diff --stat; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo TASK_OK"
}
```

**tool result**

```
/opt/miniconda3/envs/testbed/bin/python: No module named black
/opt/miniconda3/envs/testbed/bin/python: No module named flake8
 xarray/core/nanops.py               | 14 +++++++-------
 xarray/tests/test_duck_array_ops.py | 20 ++++++++++++++++++++
 2 files changed, 27 insertions(+), 7 deletions(-)
TASK_OK
```

**assistant → tool `bash`**

```json
{
  "command": "awk 'length>88 {print FILENAME\":\"FNR\": \"length}' xarray/core/nanops.py xarray/tests/test_duck_array_ops.py"
}
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '22,50p' xarray/core/nanops.py && python -c 'import xarray as xr; da=xr.DataArray([[1.,2,3],[4,5,6]]); print(da.sum([\"dim_0\",\"dim_1\"], min_count=1).values); print(da.sum([\"dim_0\",\"dim_1\"], min_count=7).values)'"
}
```

**tool result**

```
    return where_method(val, mask, a), mask


def _maybe_null_out(result, axis, mask, min_count=1):
    """
    xarray version of pandas.core.nanops._maybe_null_out
    """
    if axis is None:
        axis = tuple(range(mask.ndim))
    if not hasattr(axis, "__len__"):
        axis = (axis,)

    if getattr(result, "ndim", False):
        null_mask = (np.take(mask.shape, axis).prod() - mask.sum(axis) - min_count) < 0
        if null_mask.any():
            dtype, fill_value = dtypes.maybe_promote(result.dtype)
            result = result.astype(dtype)
            result[null_mask] = fill_value

    elif getattr(getattr(result, "dtype", None), "kind", "") not in "mM":
        null_mask = mask.size - mask.sum()
        if null_mask < min_count:
            result = np.nan

    return result


def _nan_argminmax_object(func, fill_value, value, axis=None, **kwargs):
    """ In house nanargmin, nanargmax for object arrays. Always return integer
21.0
nan
```

**assistant**

```
Implemented the fix.

**Changes:**
- `xarray/core/nanops.py` — `_maybe_null_out` now normalizes `axis` (handling `None` and scalar axes) and computes the reduced element count with `np.take(mask.shape, axis).prod()` instead of `mask.shape[axis]`, so `min_count` works with multiple reduction dimensions. Also made the scalar/single-element date-type check robust (`dtype.kind not in "mM"`).
- `xarray/tests/test_duck_array_ops.py` — added `test_min_count_multiple_dims` covering multiple dim combinations, dtypes, eager/dask, and both `sum`/`prod`.

**Verification:**
- The reported reproducer now returns `21.0` with `min_count=1`; `min_count=7` correctly returns `nan`.
- `test_duck_array_ops.py`: 580 passed, 208 skipped.
- `test_duck_array_ops.py` + `test_variable.py`: 972 passed, 208 skipped, 68 xfailed.
- Task command (`git status` non-empty excluding `.memdoor`) exits 0.
```

## Run folder `single-2026-11-06T125853`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

````
sum: min_count is not available for reduction with more than one dimensions
**Is your feature request related to a problem? Please describe.**

`sum` with `min_count` errors when passing more than one dim:

```python
import xarray as xr
da = xr.DataArray([[1., 2, 3], [4, 5, 6]])
da.sum(["dim_0", "dim_1"], min_count=1)
```

**Describe the solution you'd like**
The logic to calculate the number of valid elements is here:
https://github.com/pydata/xarray/blob/1be777fe725a85b8cc0f65a2bc41f4bc2ba18043/xarray/core/nanops.py#L35

I *think* this can be fixed by replacing

`mask.shape[axis]` with `np.take(a.shape, axis).prod()`

**Additional context**
Potentially relevant for #4351
````
