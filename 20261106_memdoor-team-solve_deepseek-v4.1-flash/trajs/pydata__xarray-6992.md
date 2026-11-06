# pydata__xarray-6992 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 301s 42 lines cost=0.011650 in=386209 cached=287232 out=20808 calls=25`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

index refactor: more `_coord_names` than `_variables` on Dataset
### What happened?

`xr.core.dataset.DataVariables` assumes that everything that is in `ds._dataset._variables` and not in `self._dataset._coord_names` is a "data variable". However, since the index refactor we can end up with more `_coord_names` than `_variables` which breaks a number of stuff (e.g. the repr).

### What did you expect to happen?

Well it seems this assumption is now wrong.

### Minimal Complete Verifiable Example

```Python
ds = xr.Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ['a', 'b', 'c'])})
ds.set_index(z=['a', 'b']).reset_index("z", drop=True)
```


### MVCE confirmation

- [ ] Minimal example — the example is as focused as reasonably possible to demonstrate the underlying issue in xarray.
- [ ] Complete example — the example is self-contained, including all data and the text of any traceback.
- [ ] Verifiable example — the example copy & pastes into an IPython prompt or [Binder notebook](https://mybinder.org/v2/gh/pydata/xarray/main?urlpath=lab/tree/doc/examples/blank_template.ipynb), returning the result.
- [ ] New issue — a search of GitHub Issues suggests this is not a duplicate.

### Relevant log output

```Python
ValueError: __len__() should return >= 0
```


### Anything else we need to know?

The error comes from here

https://github.com/pydata/xarray/blob/63ba862d03c8d0cd8b44d2071bc360e9fed4519d/xarray/core/dataset.py#L368

Bisected to #5692 - which probably does not help too much.


### Environment

<details>



</details>


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "pwd && git status --short && git log --oneline -3"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"_coord_names\\|class DataVariables\\|def __len__\\|def __iter__\\|_variables\" xarray/core/dataset.py | head -80"
}
```

**tool result**

```
/testbed
?? .memdoor/
e90b06dd SWE-bench
45c0a114 Raise UserWarning when rename creates a new dimension coord (#6999)
87596ded add dictionary-based integer assignment example (GH7043) (#7072)
```

**tool result**

```
91:    broadcast_variables,
354:class DataVariables(Mapping[Any, "DataArray"]):
360:    def __iter__(self) -> Iterator[Hashable]:
363:            for key in self._dataset._variables
364:            if key not in self._dataset._coord_names
367:    def __len__(self) -> int:
368:        return len(self._dataset._variables) - len(self._dataset._coord_names)
371:        return key in self._dataset._variables and key not in self._dataset._coord_names
374:        if key not in self._dataset._coord_names:
383:        all_variables = self._dataset.variables
384:        return Frozen({k: all_variables[k] for k in self})
403:            if key not in self._dataset._coord_names
557:    _coord_names: set[Hashable]
562:    _variables: dict[Hashable, Variable]
567:        "_coord_names",
572:        "_variables",
607:        self._variables = variables
608:        self._coord_names = coord_names
633:        return Frozen(self._variables)
702:                for n, v in self._variables.items()
703:                if n not in self._coord_names
750:            (type(self), self._variables, self._coord_names, self._attrs)
813:        for k, v in self._variables.items():
821:            self._coord_names,
838:        for k, v in self._variables.items():
872:            self._coord_names,
959:        obj._variables = variables
960:        obj._coord_names = coord_names
988:                self._variables = variables
990:                self._coord_names = coord_names
1002:                variables = self._variables.copy()
1004:                coord_names = self._coord_names.copy()
1055:        drop_variables: list[Hashable] | None = None,
1070:        if drop_variables is None:
1071:            drop_variables = []
1075:        new_variables = self._variables.copy()
1076:        new_coord_names = self._coord_names.copy()
1079:        index_variables = {}
1080:        no_index_variables = {}
1082:            old_var = self._variables.get(name)
1087:                index_variables[name] = var
1089:                no_index_variables[name] = var
1094:        for name, var in index_variables.items():
1095:            new_coord_names.add(name)
1096:            new_variables[name] = var
1099:        for k in no_index_variables:
1100:            new_variables.pop(k)
1101:        new_variables.update(no_index_variables)
1106:        for name in drop_variables:
1107:            new_variables.pop(name)
1109:            new_coord_names.remove(name)
1112:            variables=new_variables, coord_names=new_coord_names, indexes=new_indexes
1118:            new_variables, new_coord_names = replaced._rename_vars({}, rename_dims)
1120:                variables=new_variables, coord_names=new_coord_names, dims=dims
1248:        for k, v in self._variables.items():
1267:        numpy_variables = {k: v.as_numpy() for k, v in self.variables.items()}
1268:        return self._replace(variables=numpy_variables)
1280:                variables[name] = self._variables[name]
1283:                    self._variables, name, self.dims
1286:                if ref_name in self._coord_names or ref_name in self.dims:
1301:        for k in self._variables:
1302:            if k not in self._coord_names:
1306:                variables[k] = self._variables[k]
1318:            variable = self._variables[name]
1320:            _, name, variable = _get_virtual_variable(self._variables, name, self.dims)
1326:        for k in self._variables:
1327:            if k in self._coord_names and set(self.variables[k].dims) <= needed_dims:
1352:        yield HybridMappingProxy(keys=self._coord_names, mapping=self.coords)
1361:        return key in self._variables
1363:    def __len__(self) -> int:
1369:    def __iter__(self) -> Iterator[Hashable]:
1565:        del self._variables[key]
1566:        self._coord_names.discard(key)
1567:        self._dims = calculate_dimensions(self._variables)
1581:        return self._coord_names == other._coord_names and utils.dict_equiv(
1582:            self._variables, other._variables, compat=compat
1656:        return Indexes(self._indexes, {k: self._variables[k] for k in self._indexes})
1688:        # nb. check in self._variables, not self.data_vars to insure that the
1696:        obj._coord_names.update(names)
1720:            names = self._coord_names - set(self._indexes)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nds2 = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)\nprint(ds2)\nprint(ds2._variables)\nprint(ds2._coord_names)\nprint(len(ds2.data_vars))\n\""
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '340,420p' xarray/core/dataset.py && sed -n '1680,1760p' xarray/core/dataset.py"
}
```

**tool result**

```
Command FAILED (exit status 1): `cd /testbed && python -c "
import xarray as xr
ds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})
ds2 = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)
print(ds2)
print(ds2._variables)
print(ds2._coord_names)
print(len(ds2.data_vars))
"`
Output: Traceback (most recent call last):
  File "<string>", line 5, in <module>
  File "/testbed/xarray/core/dataset.py", line 2084, in __repr__
    return formatting.dataset_repr(self)
  File "/testbed/xarray/core/formatting.py", line 617, in dataset_repr
    summary.append(data_vars_repr(ds.data_vars, col_width=col_width, max_rows=max_rows))
  File "/testbed/xarray/core/formatting.py", line 352, in _mapping_repr
    if mapping:
ValueError: __len__() should return >= 0

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**tool result**

```
    param_defaults = {p: 1 for p in params}
    bounds_defaults = {p: (-np.inf, np.inf) for p in params}
    for p in params:
        if p in func_args and func_args[p].default is not func_args[p].empty:
            param_defaults[p] = func_args[p].default
        if p in bounds:
            bounds_defaults[p] = tuple(bounds[p])
            if param_defaults[p] < bounds[p][0] or param_defaults[p] > bounds[p][1]:
                param_defaults[p] = _initialize_feasible(bounds[p][0], bounds[p][1])
        if p in p0:
            param_defaults[p] = p0[p]
    return param_defaults, bounds_defaults


class DataVariables(Mapping[Any, "DataArray"]):
    __slots__ = ("_dataset",)

    def __init__(self, dataset: Dataset):
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

    def __getitem__(self, key: Hashable) -> DataArray:
        if key not in self._dataset._coord_names:
            return cast("DataArray", self._dataset[key])
        raise KeyError(key)

    def __repr__(self) -> str:
        return formatting.data_vars_repr(self)

    @property
    def variables(self) -> Mapping[Hashable, Variable]:
        all_variables = self._dataset.variables
        return Frozen({k: all_variables[k] for k in self})

    @property
    def dtypes(self) -> Frozen[Hashable, np.dtype]:
        """Mapping from data variable names to dtypes.

        Cannot be modified directly, but is updated when adding new variables.

        See Also
        --------
        Dataset.dtype
        """
        return self._dataset.dtypes

    def _ipython_key_completions_(self):
        """Provide method for the key-autocompletions in IPython."""
        return [
            key
            for key in self._dataset._ipython_key_completions_()
            if key not in self._dataset._coord_names
        ]


class _LocIndexer(Generic[T_Dataset]):
    __slots__ = ("dataset",)

    def __init__(self, dataset: T_Dataset):
        self.dataset = dataset

    def __getitem__(self, key: Mapping[Any, Any]) -> T_Dataset:
        if not utils.is_dict_like(key):
            raise TypeError("can only lookup dictionaries from Dataset.loc")
        return self.dataset.sel(key)

    def __setitem__(self, key, value) -> None:
        if not utils.is_dict_like(key):
            raise TypeError(
        Dataset

        See Also
        --------
        Dataset.swap_dims
        """
        # TODO: allow inserting new coordinates with this method, like
        # DataFrame.set_index?
        # nb. check in self._variables, not self.data_vars to insure that the
        # operation is idempotent
        if isinstance(names, str) or not isinstance(names, Iterable):
            names = [names]
        else:
            names = list(names)
        self._assert_all_in_dataset(names)
        obj = self.copy()
        obj._coord_names.update(names)
        return obj

    def reset_coords(
        self: T_Dataset,
        names: Hashable | Iterable[Hashable] | None = None,
        drop: bool = False,
    ) -> T_Dataset:
        """Given names of coordinates, reset them to become variables

        Parameters
        ----------
        names : hashable or iterable of hashable, optional
            Name(s) of non-index coordinates in this dataset to reset into
            variables. By default, all non-index coordinates are reset.
        drop : bool, default: False
            If True, remove coordinates instead of converting them into
            variables.

        Returns
        -------
        Dataset
        """
        if names is None:
            names = self._coord_names - set(self._indexes)
        else:
            if isinstance(names, str) or not isinstance(names, Iterable):
                names = [names]
            else:
                names = list(names)
            self._assert_all_in_dataset(names)
            bad_coords = set(names) & set(self._indexes)
            if bad_coords:
                raise ValueError(
                    f"cannot remove index coordinates with reset_coords: {bad_coords}"
                )
        obj = self.copy()
        obj._coord_names.difference_update(names)
        if drop:
            for name in names:
                del obj._variables[name]
        return obj

    def dump_to_store(self, store: AbstractDataStore, **kwargs) -> None:
        """Store dataset contents to a backends.*DataStore object."""
        from ..backends.api import dump_to_store

        # TODO: rename and/or cleanup this method to make it more consistent
        # with to_netcdf()
        dump_to_store(self, store, **kwargs)

    # path=None writes to bytes
    @overload
    def to_netcdf(
        self,
        path: None = None,
        mode: Literal["w", "a"] = "w",
        format: T_NetcdfTypes | None = None,
        group: str | None = None,
        engine: T_NetcdfEngine | None = None,
        encoding: Mapping[Hashable, Mapping[str, Any]] | None = None,
        unlimited_dims: Iterable[Hashable] | None = None,
        compute: bool = True,
        invalid_netcdf: bool = False,
    ) -> bytes:
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nds2 = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)\nprint(ds2._variables)\nprint(ds2._coord_names)\nprint(ds2._indexes)\nprint(len(ds2.data_vars))\n\""
}
```

**tool result**

```
Command FAILED (exit status 1): `cd /testbed && python -c "
import xarray as xr
ds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})
ds2 = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)
print(ds2._variables)
print(ds2._coord_names)
print(ds2._indexes)
print(len(ds2.data_vars))
"`
Output: Traceback (most recent call last):
  File "<string>", line 8, in <module>
ValueError: __len__() should return >= 0
{'a': <xarray.IndexVariable 'z' (z: 3)>
array([1, 2, 3]), 'b': <xarray.IndexVariable 'z' (z: 3)>
array(['a', 'b', 'c'], dtype=object)}
{'b', 'z', 'a'}
{}

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n \"def reset_index\" xarray/core/dataset.py && sed -n '1960,2050p' xarray/core/dataset.py"
}
```

**tool result**

```
4108:    def reset_index(

        - From the ``chunks`` attribute in each variable's ``encoding``
          (can be set via `Dataset.chunk`).
        - If the variable is a Dask array, from the dask chunks
        - If neither Dask chunks nor encoding chunks are present, chunks will
          be determined automatically by Zarr
        - If both Dask chunks and encoding chunks are present, encoding chunks
          will be used, provided that there is a many-to-one relationship between
          encoding chunks and dask chunks (i.e. Dask chunks are bigger than and
          evenly divide encoding chunks); otherwise raise a ``ValueError``.
          This restriction ensures that no synchronization / locks are required
          when writing. To disable this restriction, use ``safe_chunks=False``.

        Parameters
        ----------
        store : MutableMapping, str or path-like, optional
            Store or path to directory in local or remote file system.
        chunk_store : MutableMapping, str or path-like, optional
            Store or path to directory in local or remote file system only for Zarr
            array chunks. Requires zarr-python v2.4.0 or later.
        mode : {"w", "w-", "a", "r+", None}, optional
            Persistence mode: "w" means create (overwrite if exists);
            "w-" means create (fail if exists);
            "a" means override existing variables (create if does not exist);
            "r+" means modify existing array *values* only (raise an error if
            any metadata or shapes would change).
            The default mode is "a" if ``append_dim`` is set. Otherwise, it is
            "r+" if ``region`` is set and ``w-`` otherwise.
        synchronizer : object, optional
            Zarr array synchronizer.
        group : str, optional
            Group path. (a.k.a. `path` in zarr terminology.)
        encoding : dict, optional
            Nested dictionary with variable names as keys and dictionaries of
            variable specific encodings as values, e.g.,
            ``{"my_variable": {"dtype": "int16", "scale_factor": 0.1,}, ...}``
        compute : bool, optional
            If True write array data immediately, otherwise return a
            ``dask.delayed.Delayed`` object that can be computed to write
            array data later. Metadata is always updated eagerly.
        consolidated : bool, optional
            If True, apply zarr's `consolidate_metadata` function to the store
            after writing metadata and read existing stores with consolidated
            metadata; if False, do not. The default (`consolidated=None`) means
            write consolidated metadata and attempt to read consolidated
            metadata for existing stores (falling back to non-consolidated).
        append_dim : hashable, optional
            If set, the dimension along which the data will be appended. All
            other dimensions on overridden variables must remain the same size.
        region : dict, optional
            Optional mapping from dimension names to integer slices along
            dataset dimensions to indicate the region of existing zarr array(s)
            in which to write this dataset's data. For example,
            ``{'x': slice(0, 1000), 'y': slice(10000, 11000)}`` would indicate
            that values should be written to the region ``0:1000`` along ``x``
            and ``10000:11000`` along ``y``.

            Two restrictions apply to the use of ``region``:

            - If ``region`` is set, _all_ variables in a dataset must have at
              least one dimension in common with the region. Other variables
              should be written in a separate call to ``to_zarr()``.
            - Dimensions cannot be included in both ``region`` and
              ``append_dim`` at the same time. To create empty arrays to fill
              in with ``region``, use a separate call to ``to_zarr()`` with
              ``compute=False``. See "Appending to existing Zarr stores" in
              the reference documentation for full details.
        safe_chunks : bool, optional
            If True, only allow writes to when there is a many-to-one relationship
            between Zarr chunks (specified in encoding) and Dask chunks.
            Set False to override this restriction; however, data may become corrupted
            if Zarr arrays are written in parallel. This option may be useful in combination
            with ``compute=False`` to initialize a Zarr from an existing
            Dataset with arbitrary chunk structure.
        storage_options : dict, optional
            Any additional parameters for the storage backend (ignored for local
            paths).

        Returns
        -------
            * ``dask.delayed.Delayed`` if compute is False
            * ZarrStore otherwise

        References
        ----------
        https://zarr.readthedocs.io/

        Notes
        -----
        Zarr chunking behavior:
            If chunks are found in the encoding argument or attribute
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '4108,4200p' xarray/core/dataset.py"
}
```

**tool result**

```
    def reset_index(
        self: T_Dataset,
        dims_or_levels: Hashable | Sequence[Hashable],
        drop: bool = False,
    ) -> T_Dataset:
        """Reset the specified index(es) or multi-index level(s).

        Parameters
        ----------
        dims_or_levels : Hashable or Sequence of Hashable
            Name(s) of the dimension(s) and/or multi-index level(s) that will
            be reset.
        drop : bool, default: False
            If True, remove the specified indexes and/or multi-index levels
            instead of extracting them as new coordinates (default: False).

        Returns
        -------
        obj : Dataset
            Another dataset, with this dataset's data but replaced coordinates.

        See Also
        --------
        Dataset.set_index
        """
        if isinstance(dims_or_levels, str) or not isinstance(dims_or_levels, Sequence):
            dims_or_levels = [dims_or_levels]

        invalid_coords = set(dims_or_levels) - set(self._indexes)
        if invalid_coords:
            raise ValueError(
                f"{tuple(invalid_coords)} are not coordinates with an index"
            )

        drop_indexes: list[Hashable] = []
        drop_variables: list[Hashable] = []
        replaced_indexes: list[PandasMultiIndex] = []
        new_indexes: dict[Hashable, Index] = {}
        new_variables: dict[Hashable, IndexVariable] = {}

        for name in dims_or_levels:
            index = self._indexes[name]
            drop_indexes += list(self.xindexes.get_all_coords(name))

            if isinstance(index, PandasMultiIndex) and name not in self.dims:
                # special case for pd.MultiIndex (name is an index level):
                # replace by a new index with dropped level(s) instead of just drop the index
                if index not in replaced_indexes:
                    level_names = index.index.names
                    level_vars = {
                        k: self._variables[k]
                        for k in level_names
                        if k not in dims_or_levels
                    }
                    if level_vars:
                        idx = index.keep_levels(level_vars)
                        idx_vars = idx.create_variables(level_vars)
                        new_indexes.update({k: idx for k in idx_vars})
                        new_variables.update(idx_vars)
                replaced_indexes.append(index)

            if drop:
                drop_variables.append(name)

        indexes = {k: v for k, v in self._indexes.items() if k not in drop_indexes}
        indexes.update(new_indexes)

        variables = {
            k: v for k, v in self._variables.items() if k not in drop_variables
        }
        variables.update(new_variables)

        coord_names = set(new_variables) | self._coord_names

        return self._replace(variables, coord_names=coord_names, indexes=indexes)

    def reorder_levels(
        self: T_Dataset,
        dim_order: Mapping[Any, Sequence[int | Hashable]] | None = None,
        **dim_order_kwargs: Sequence[int | Hashable],
    ) -> T_Dataset:
        """Rearrange index levels using input order.

        Parameters
        ----------
        dim_order : dict-like of Hashable to Sequence of int or Hashable, optional
            Mapping from names matching dimensions and values given
            by lists representing new level orders. Every given dimension
            must have a multi-index.
        **dim_order_kwargs : Sequence of int or Hashable, optional
            The keyword arguments form of ``dim_order``.
            One of dim_order or dim_order_kwargs must be provided.
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -rn \"reset_index\" xarray/tests/test_dataset.py | head -40"
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -rn \"more.*coord_names\\|coord_names.*variables\\|DataVariables\" xarray/tests | head -40"
}
```

**tool result**

```
3240:    def test_reset_index(self) -> None:
3248:        obj = ds.reset_index("x")
3254:            ds.reset_index("y")
3256:    def test_reset_index_keep_attrs(self) -> None:
3259:        obj = ds.reset_index("coord_1")
```

**tool result**

```

```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nds1 = ds.set_index(z=['a','b'])\nprint(ds1)\nprint(ds1._variables)\nprint(ds1._coord_names)\nprint(ds1._indexes)\n\""
}
```

**tool result**

```
<xarray.Dataset>
Dimensions:  (z: 3)
Coordinates:
  * z        (z) object MultiIndex
  * a        (z) int64 1 2 3
  * b        (z) <U1 'a' 'b' 'c'
Data variables:
    *empty*
{'z': <xarray.IndexVariable 'z' (z: 3)>
array([(1, 'a'), (2, 'b'), (3, 'c')], dtype=object), 'a': <xarray.IndexVariable 'z' (z: 3)>
array([1, 2, 3]), 'b': <xarray.IndexVariable 'z' (z: 3)>
array(['a', 'b', 'c'], dtype=object)}
{'a', 'z', 'b'}
{'z': <xarray.core.indexes.PandasMultiIndex object at 0x71fdea54e6c0>, 'a': <xarray.core.indexes.PandasMultiIndex object at 0x71fdea54e6c0>, 'b': <xarray.core.indexes.PandasMultiIndex object at 0x71fdea54e6c0>}
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '3230,3270p' xarray/tests/test_dataset.py && grep -rn \"reset_index\" xarray/tests | head -60"
}
```

**tool result**

```
        ds = Dataset(data_vars={"x_var": ("x", [0, 1, 2])})
        expected = Dataset(coords={"x": [0, 1, 2]})
        assert_identical(ds.set_index(x="x_var"), expected)

        with pytest.raises(ValueError, match=r"bar variable\(s\) do not exist"):
            ds.set_index(foo="bar")

        with pytest.raises(ValueError, match=r"dimension mismatch.*"):
            ds.set_index(y="x_var")

    def test_reset_index(self) -> None:
        ds = create_test_multiindex()
        mindex = ds["x"].to_index()
        indexes = [mindex.get_level_values(n) for n in mindex.names]
        coords = {idx.name: ("x", idx) for idx in indexes}
        coords["x"] = ("x", mindex.values)
        expected = Dataset({}, coords=coords)

        obj = ds.reset_index("x")
        assert_identical(obj, expected, check_default_indexes=False)
        assert len(obj.xindexes) == 0

        ds = Dataset(coords={"y": ("x", [1, 2, 3])})
        with pytest.raises(ValueError, match=r".*not coordinates with an index"):
            ds.reset_index("y")

    def test_reset_index_keep_attrs(self) -> None:
        coord_1 = DataArray([1, 2], dims=["coord_1"], attrs={"attrs": True})
        ds = Dataset({}, {"coord_1": coord_1})
        obj = ds.reset_index("coord_1")
        assert_identical(obj, ds, check_default_indexes=False)
        assert len(obj.xindexes) == 0

    def test_reorder_levels(self) -> None:
        ds = create_test_multiindex()
        mindex = ds["x"].to_index()
        midx = mindex.reorder_levels(["level_2", "level_1"])
        expected = Dataset({}, coords={"x": midx})

        # check attrs propagated
        ds["level_1"].attrs["foo"] = "bar"
xarray/tests/test_groupby.py:540:        .reset_index("id", drop=True)
xarray/tests/test_dask.py:796:        expected = dd.from_pandas(expected_pd.reset_index(drop=False), chunksize=4)
xarray/tests/test_dask.py:817:        expected = expected.reset_index(drop=False)
xarray/tests/test_dask.py:872:        expected = ds.compute().to_dataframe().reset_index()
xarray/tests/test_dask.py:886:        expected = ds["w"].to_series().reset_index()
xarray/tests/test_dask.py:891:        expected = ds["w"].T.to_series().reset_index()
xarray/tests/test_dask.py:1644:        # set_index / reset_index
xarray/tests/test_units.py:3626:        (method("unstack"), method("reset_index", "z"), method("reorder_levels")),
xarray/tests/test_units.py:3645:        if func.name == "reset_index":
xarray/tests/test_units.py:4719:        (method("unstack"), method("reset_index", "v"), method("reorder_levels")),
xarray/tests/test_units.py:4761:        if func.name == "reset_index":
xarray/tests/test_dataset.py:3240:    def test_reset_index(self) -> None:
xarray/tests/test_dataset.py:3248:        obj = ds.reset_index("x")
xarray/tests/test_dataset.py:3254:            ds.reset_index("y")
xarray/tests/test_dataset.py:3256:    def test_reset_index_keep_attrs(self) -> None:
xarray/tests/test_dataset.py:3259:        obj = ds.reset_index("coord_1")
xarray/tests/test_sparse.py:374:        (do("reset_index", "x"), True),
xarray/tests/test_dataarray.py:1297:        expected = ds.reset_index("xy").isel(xy=ds["x"] < 4)
xarray/tests/test_dataarray.py:2007:    def test_reset_index(self) -> None:
xarray/tests/test_dataarray.py:2013:        obj = self.mda.reset_index("x")
xarray/tests/test_dataarray.py:2016:        obj = self.mda.reset_index(self.mindex.names)
xarray/tests/test_dataarray.py:2019:        obj = self.mda.reset_index(["x", "level_1"])
xarray/tests/test_dataarray.py:2024:        obj = self.mda.reset_index(["level_1"])
xarray/tests/test_dataarray.py:2031:        obj = self.mda.reset_index("x", drop=True)
xarray/tests/test_dataarray.py:2035:        array = array.reset_index(["x"], drop=True)
xarray/tests/test_dataarray.py:2040:        obj = array.reset_index("x")
xarray/tests/test_dataarray.py:2044:    def test_reset_index_keep_attrs(self) -> None:
xarray/tests/test_dataarray.py:2047:        obj = da.reset_index("coord_1")
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '1980,2060p' xarray/tests/test_dataarray.py && sed -n '520,550p' xarray/tests/test_groupby.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n \"class DataArray\" xarray/core/dataarray.py | head && grep -n \"def reset_index\" xarray/core/dataarray.py"
}
```

**tool result**

```
        expected = self.mda.copy()
        level_3 = ("x", [1, 2, 3, 4])
        array["level_3"] = level_3
        expected["level_3"] = level_3

        obj = array.set_index(x=self.mindex.names)
        assert_identical(obj, expected)

        obj = obj.set_index(x="level_3", append=True)
        expected = array.set_index(x=["level_1", "level_2", "level_3"])
        assert_identical(obj, expected)

        array = array.set_index(x=["level_1", "level_2", "level_3"])
        assert_identical(array, expected)

        array2d = DataArray(
            np.random.rand(2, 2),
            coords={"x": ("x", [0, 1]), "level": ("y", [1, 2])},
            dims=("x", "y"),
        )
        with pytest.raises(ValueError, match=r"dimension mismatch"):
            array2d.set_index(x="level")

        # Issue 3176: Ensure clear error message on key error.
        with pytest.raises(ValueError, match=r".*variable\(s\) do not exist"):
            obj.set_index(x="level_4")

    def test_reset_index(self) -> None:
        indexes = [self.mindex.get_level_values(n) for n in self.mindex.names]
        coords = {idx.name: ("x", idx) for idx in indexes}
        coords["x"] = ("x", self.mindex.values)
        expected = DataArray(self.mda.values, coords=coords, dims="x")

        obj = self.mda.reset_index("x")
        assert_identical(obj, expected, check_default_indexes=False)
        assert len(obj.xindexes) == 0
        obj = self.mda.reset_index(self.mindex.names)
        assert_identical(obj, expected, check_default_indexes=False)
        assert len(obj.xindexes) == 0
        obj = self.mda.reset_index(["x", "level_1"])
        assert_identical(obj, expected, check_default_indexes=False)
        assert list(obj.xindexes) == ["level_2"]

        expected = DataArray(self.mda.values, coords=coords, dims="x")
        obj = self.mda.reset_index(["level_1"])
        assert_identical(obj, expected, check_default_indexes=False)
        assert list(obj.xindexes) == ["level_2"]
        assert type(obj.xindexes["level_2"]) is PandasIndex

        coords = {k: v for k, v in coords.items() if k != "x"}
        expected = DataArray(self.mda.values, coords=coords, dims="x")
        obj = self.mda.reset_index("x", drop=True)
        assert_identical(obj, expected, check_default_indexes=False)

        array = self.mda.copy()
        array = array.reset_index(["x"], drop=True)
        assert_identical(array, expected, check_default_indexes=False)

        # single index
        array = DataArray([1, 2], coords={"x": ["a", "b"]}, dims="x")
        obj = array.reset_index("x")
        assert_identical(obj, array, check_default_indexes=False)
        assert len(obj.xindexes) == 0

    def test_reset_index_keep_attrs(self) -> None:
        coord_1 = DataArray([1, 2], dims=["coord_1"], attrs={"attrs": True})
        da = DataArray([1, 0], [coord_1])
        obj = da.reset_index("coord_1")
        assert_identical(obj, da, check_default_indexes=False)
        assert len(obj.xindexes) == 0

    def test_reorder_levels(self) -> None:
        midx = self.mindex.reorder_levels(["level_2", "level_1"])
        expected = DataArray(self.mda.values, coords={"x": midx}, dims="x")

        obj = self.mda.reorder_levels(x=["level_2", "level_1"])
        assert_identical(obj, expected)

        array = DataArray([1, 2], dims="x")
        with pytest.raises(KeyError):
            array.reorder_levels(x=["level_1", "level_2"])
    ds["id"].values[3, 0] = np.nan
    ds["id"].values[-1, -1] = np.nan

    grouped = ds.groupby(ds.id)

    # non reduction operation
    expected1 = ds.copy()
    expected1.variable.values[0, 0, :] = np.nan
    expected1.variable.values[-1, -1, :] = np.nan
    expected1.variable.values[3, 0, :] = np.nan
    actual1 = grouped.map(lambda x: x).transpose(*ds.variable.dims)
    assert_identical(actual1, expected1)

    # reduction along grouped dimension
    actual2 = grouped.mean()
    stacked = ds.stack({"xy": ["lat", "lon"]})
    expected2 = (
        stacked.variable.where(stacked.id.notnull())
        .rename({"xy": "id"})
        .to_dataset()
        .reset_index("id", drop=True)
        .drop_vars(["lon", "lat"])
        .assign(id=stacked.id.values)
        .dropna("id")
        .transpose(*actual2.dims)
    )
    assert_identical(actual2, expected2)

    # reduction operation along a different dimension
    actual3 = grouped.mean("time")
    expected3 = ds.mean("time").where(ds.id.notnull())
```

**tool result**

```
223:class DataArray(
2254:    def reset_index(
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -n \"data_vars\\|DataVariables\\|coord_names\" xarray/core/dataset.py | sed -n '1,160p'"
}
```

**tool result**

```
354:class DataVariables(Mapping[Any, "DataArray"]):
364:            if key not in self._dataset._coord_names
368:        return len(self._dataset._variables) - len(self._dataset._coord_names)
371:        return key in self._dataset._variables and key not in self._dataset._coord_names
374:        if key not in self._dataset._coord_names:
379:        return formatting.data_vars_repr(self)
403:            if key not in self._dataset._coord_names
450:    data_vars : dict-like, optional
469:        Another mapping in similar form as the `data_vars` argument,
510:    ...     data_vars=dict(
557:    _coord_names: set[Hashable]
567:        "_coord_names",
580:        data_vars: Mapping[Any, Any] | None = None,
586:        if data_vars is None:
587:            data_vars = {}
591:        both_data_and_coords = set(data_vars) & set(coords)
594:                f"variables {both_data_and_coords!r} are found in both data_vars and coords"
600:        variables, coord_names, dims, indexes, _ = merge_data_and_coords(
601:            data_vars, coords, compat="broadcast_equals"
608:        self._coord_names = coord_names
703:                if n not in self._coord_names
750:            (type(self), self._variables, self._coord_names, self._attrs)
821:            self._coord_names,
872:            self._coord_names,
944:        coord_names: set[Hashable],
960:        obj._coord_names = coord_names
971:        coord_names: set[Hashable] | None = None,
989:            if coord_names is not None:
990:                self._coord_names = coord_names
1003:            if coord_names is None:
1004:                coord_names = self._coord_names.copy()
1014:                variables, coord_names, dims, attrs, indexes, encoding
1021:        coord_names: set | None = None,
1029:            variables, coord_names, dims, attrs, indexes, inplace=inplace
1035:        coord_names: set | None = None,
1048:            variables, coord_names, dims, attrs, indexes=None, inplace=inplace
1076:        new_coord_names = self._coord_names.copy()
1095:            new_coord_names.add(name)
1109:            new_coord_names.remove(name)
1112:            variables=new_variables, coord_names=new_coord_names, indexes=new_indexes
1118:            new_variables, new_coord_names = replaced._rename_vars({}, rename_dims)
1120:                variables=new_variables, coord_names=new_coord_names, dims=dims
1230:            var_keys = set(self.data_vars.keys())
1275:        coord_names = set()
1286:                if ref_name in self._coord_names or ref_name in self.dims:
1287:                    coord_names.add(var_name)
1292:                    coord_names.update(index_vars)
1302:            if k not in self._coord_names:
1307:                coord_names.add(k)
1309:        indexes.update(filter_indexes_from_coords(self._indexes, coord_names))
1311:        return self._replace(variables, coord_names, dims, indexes=indexes)
1327:            if k in self._coord_names and set(self.variables[k].dims) <= needed_dims:
1351:        yield self.data_vars
1352:        yield HybridMappingProxy(keys=self._coord_names, mapping=self.coords)
1364:        return len(self.data_vars)
1367:        return bool(self.data_vars)
1370:        return iter(self.data_vars)
1486:                    self.update(dict(zip(keylist, value.data_vars.values())))
1506:                name for name in value.data_vars if name not in self.data_vars
1566:        self._coord_names.discard(key)
1581:        return self._coord_names == other._coord_names and utils.dict_equiv(
1666:    def data_vars(self) -> DataVariables:
1668:        return DataVariables(self)
1688:        # nb. check in self._variables, not self.data_vars to insure that the
1696:        obj._coord_names.update(names)
1720:            names = self._coord_names - set(self._indexes)
1733:        obj._coord_names.difference_update(names)
2402:        coord_names = self._coord_names.copy()
2414:                    if drop and var.ndim == 0 and name in coord_names:
2415:                        coord_names.remove(name)
2422:            coord_names=coord_names,
2461:        coord_names = self._coord_names & variables.keys()
2462:        selected = self._replace_with_new_dims(variables, coord_names, indexes)
2468:        coord_names = self._coord_names & variables.keys() | coord_vars.keys()
2469:        return self._replace_with_new_dims(variables, coord_names, indexes=indexes)
2550:                    if k in self._coord_names:
2815:            new_coord_names = self._coord_names | set(new_indexes)
2817:                new_variables, new_coord_names, indexes=new_indexes
3201:        ...     data_vars={
3383:        coord_names = obj._coord_names & variables.keys()
3385:            variables.copy(), coord_names, indexes=indexes
3404:        coord_names = obj._coord_names & variables.keys() | coord_vars.keys()
3405:        return self._replace_with_new_dims(variables, coord_names, indexes=indexes)
3509:        coord_names = set()
3517:            if k in self._coord_names:
3518:                coord_names.add(name)
3519:        return variables, coord_names
3533:        for index, coord_names in self.xindexes.group_by_index():
3535:            new_coord_names = [name_dict.get(k, k) for k in coord_names]
3536:            indexes.update({k: new_index for k in new_coord_names})
3540:                    for old, new in zip(coord_names, new_coord_names)
3555:        variables, coord_names = self._rename_vars(name_dict, dims_dict)
3561:        return variables, coord_names, dims, indexes
3582:            if k in self.dims and new_k in self._coord_names:
3586:            elif k in self._coord_names and new_k in self.dims:
3600:        variables, coord_names, dims, indexes = self._rename_all(
3603:        return self._replace(variables, coord_names, dims=dims, indexes=indexes)
3677:        variables, coord_names, sizes, indexes = self._rename_all(
3680:        return self._replace(variables, coord_names, dims=sizes, indexes=indexes)
3715:        variables, coord_names, dims, indexes = self._rename_all(
3718:        return self._replace(variables, coord_names, dims=dims, indexes=indexes)
3742:        ...     data_vars={"a": ("x", [5, 7]), "b": ("x", [0.1, 2.4])},
3799:        coord_names = self._coord_names.copy()
3800:        coord_names.update({dim for dim in dims_dict.values() if dim in self.variables})
3817:                    coord_names.update(index_vars)
3823:        return self._replace_with_new_dims(variables, coord_names, indexes=indexes)
3908:        coord_names = self._coord_names.copy()
3920:                coord_names.add(k)
3932:                if k in coord_names:  # Do not change coordinates
3963:            variables, coord_names=coord_names, indexes=indexes
4047:            current_coord_names = self.xindexes.get_all_coords(dim, errors="ignore")
4050:            maybe_drop_indexes += list(current_coord_names) + var_names
4071:                        k: self._variables[k] for k in current_coord_names
4102:        coord_names = self._coord_names - set(drop_variables) | set(new_variables)
4105:            variables, coord_names=coord_names, indexes=indexes_
4180:        coord_names = set(new_variables) | self._coord_names
4182:        return self._replace(variables, coord_names=coord_names, indexes=indexes)
4321:        new_coord_names = set(self._coord_names)
4338:                new_coord_names.update(idx_vars)
4344:            new_variables, coord_names=new_coord_names, indexes=indexes
4443:        ...     data_vars={
4502:        stackable_vars = [ensure_stackable(self[key]) for key in self.data_vars]
4544:        coord_names = set(self._coord_names) - {dim} | set(new_indexes)
4547:            variables, coord_names=coord_names, indexes=indexes
4595:        coord_names = set(self._coord_names) - {dim} | set(new_dim_sizes)
4598:            variables, coord_names=coord_names, indexes=indexes
4889:                idx_coord_names = set(maybe_midx.index.names + [maybe_midx.dim])
4890:                idx_other_names = idx_coord_names - set(names)
4904:        coord_names = {k for k in self._coord_names if k in variables}
4907:            variables, coord_names=coord_names, indexes=indexes
5229:            subset = iter(self.data_vars)
5325:            value_keys = getattr(value, "data_vars", value).keys()
5326:            if not set(value_keys) <= set(self.data_vars.keys()):
5522:        """Combine two Datasets, default to data_vars of self.
5637:        coord_names = {k for k in self.coords if k in variables}
5641:            variables, coord_names=coord_names, attrs=attrs, indexes=indexes
5696:            for k, v in self.data_vars.items()
5700:                v._copy_attrs_from(self.data_vars[k])
5842:        data_vars = [self.variables[k] for k in self.data_vars]
5843:        broadcast_vars = broadcast_variables(*data_vars)
5851:        new_dim_index = PandasIndex(list(self.data_vars), dim)
6134:        columns.extend(self.data_vars)
6189:            Dict with keys: "coords", "attrs", "dims", "data_vars" and optionally
6201:            "data_vars": {},
6207:        for k in self.data_vars:
6208:            d["data_vars"].update(
6258:        ...     "data_vars": {
6278:        if not {"coords", "data_vars"}.issubset(set(d)):
6284:                d.get("coords", {}).items(), d.get("data_vars", {}).items()
6312:            if k in self._coord_names:
6351:            ds._coord_names,
6361:        def apply_over_both(lhs_data_vars, rhs_data_vars, lhs_vars, rhs_vars):
6362:            if inplace and set(lhs_data_vars) != set(rhs_data_vars):
6365:                    f"for in-place arithmetic operations: {list(lhs_data_vars)}, {list(rhs_data_vars)}"
6370:            for k in lhs_data_vars:
6371:                if k in rhs_data_vars:
6375:            for k in rhs_data_vars:
6383:            new_data_vars = apply_over_both(
6384:                self.data_vars, other, self.data_vars, other
6386:            return type(self)(new_data_vars)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '930,1050p' xarray/core/dataset.py && sed -n '1640,1675p' xarray/core/dataset.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '2254,2325p' xarray/core/dataarray.py"
}
```

**tool result**

```
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
        cls: type[T_Dataset],
        variables: dict[Any, Variable],
        coord_names: set[Hashable],
        dims: dict[Any, int] | None = None,
        attrs: dict | None = None,
        indexes: dict[Any, Index] | None = None,
        encoding: dict | None = None,
        close: Callable[[], None] | None = None,
    ) -> T_Dataset:
        """Shortcut around __init__ for internal use when we want to skip
        costly validation
        """
        if dims is None:
            dims = calculate_dimensions(variables)
        if indexes is None:
            indexes = {}
        obj = object.__new__(cls)
        obj._variables = variables
        obj._coord_names = coord_names
        obj._dims = dims
        obj._indexes = indexes
        obj._attrs = attrs
        obj._close = close
        obj._encoding = encoding
        return obj

    def _replace(
        self: T_Dataset,
        variables: dict[Hashable, Variable] = None,
        coord_names: set[Hashable] | None = None,
        dims: dict[Any, int] | None = None,
        attrs: dict[Hashable, Any] | None | Default = _default,
        indexes: dict[Hashable, Index] | None = None,
        encoding: dict | None | Default = _default,
        inplace: bool = False,
    ) -> T_Dataset:
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
            if indexes is not None:
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
            if indexes is None:
                indexes = self._indexes.copy()
            if encoding is _default:
                encoding = copy.copy(self._encoding)
            obj = self._construct_direct(
                variables, coord_names, dims, attrs, indexes, encoding
            )
        return obj

    def _replace_with_new_dims(
        self: T_Dataset,
        variables: dict[Hashable, Variable],
        coord_names: set | None = None,
        attrs: dict[Hashable, Any] | None | Default = _default,
        indexes: dict[Hashable, Index] | None = None,
        inplace: bool = False,
    ) -> T_Dataset:
        """Replace variables with recalculated dimensions."""
        dims = calculate_dimensions(variables)
        return self._replace(
            variables, coord_names, dims, attrs, indexes, inplace=inplace
        )

    def _replace_vars_and_dims(
        self: T_Dataset,
        variables: dict[Hashable, Variable],
        coord_names: set | None = None,
        dims: dict[Hashable, int] | None = None,
        attrs: dict[Hashable, Any] | None | Default = _default,
        inplace: bool = False,
    ) -> T_Dataset:
        """Deprecated version of _replace_with_new_dims().

        Unlike _replace_with_new_dims(), this method always recalculates
        indexes from variables.
        """
        if dims is None:
            dims = calculate_dimensions(variables)
        return self._replace(
            variables, coord_names, dims, attrs, indexes=None, inplace=inplace
        )

    def indexes(self) -> Indexes[pd.Index]:
        """Mapping of pandas.Index objects used for label based indexing.

        Raises an error if this Dataset has indexes that cannot be coerced
        to pandas.Index objects.

        See Also
        --------
        Dataset.xindexes

        """
        return self.xindexes.to_pandas_indexes()

    @property
    def xindexes(self) -> Indexes[Index]:
        """Mapping of xarray Index objects used for label based indexing."""
        return Indexes(self._indexes, {k: self._variables[k] for k in self._indexes})

    @property
    def coords(self) -> DatasetCoordinates:
        """Dictionary of xarray.DataArray objects corresponding to coordinate
        variables
        """
        return DatasetCoordinates(self)

    @property
    def data_vars(self) -> DataVariables:
        """Dictionary of DataArray objects corresponding to data variables"""
        return DataVariables(self)

    def set_coords(self: T_Dataset, names: Hashable | Iterable[Hashable]) -> T_Dataset:
        """Given names of one or more variables, set them as coordinates

        Parameters
        ----------
        names : hashable or iterable of hashable
```

**tool result**

```
    def reset_index(
        self,
        dims_or_levels: Hashable | Sequence[Hashable],
        drop: bool = False,
    ) -> DataArray:
        """Reset the specified index(es) or multi-index level(s).

        Parameters
        ----------
        dims_or_levels : Hashable or sequence of Hashable
            Name(s) of the dimension(s) and/or multi-index level(s) that will
            be reset.
        drop : bool, default: False
            If True, remove the specified indexes and/or multi-index levels
            instead of extracting them as new coordinates (default: False).

        Returns
        -------
        obj : DataArray
            Another dataarray, with this dataarray's data but replaced
            coordinates.

        See Also
        --------
        DataArray.set_index
        """
        ds = self._to_temp_dataset().reset_index(dims_or_levels, drop=drop)
        return self._from_temp_dataset(ds)

    def reorder_levels(
        self: T_DataArray,
        dim_order: Mapping[Any, Sequence[int | Hashable]] | None = None,
        **dim_order_kwargs: Sequence[int | Hashable],
    ) -> T_DataArray:
        """Rearrange index levels using input order.

        Parameters
        ----------
        dim_order dict-like of Hashable to int or Hashable: optional
            Mapping from names matching dimensions and values given
            by lists representing new level orders. Every given dimension
            must have a multi-index.
        **dim_order_kwargs : optional
            The keyword arguments form of ``dim_order``.
            One of dim_order or dim_order_kwargs must be provided.

        Returns
        -------
        obj : DataArray
            Another dataarray, with this dataarray's data but replaced
            coordinates.
        """
        ds = self._to_temp_dataset().reorder_levels(dim_order, **dim_order_kwargs)
        return self._from_temp_dataset(ds)

    def stack(
        self: T_DataArray,
        dimensions: Mapping[Any, Sequence[Hashable]] | None = None,
        create_index: bool | None = True,
        index_cls: type[Index] = PandasMultiIndex,
        **dimensions_kwargs: Sequence[Hashable],
    ) -> T_DataArray:
        """
        Stack any number of existing dimensions into a single new dimension.

        New dimensions will be added at the end, and the corresponding
        coordinate variables will be combined into a MultiIndex.

        Parameters
        ----------
        dimensions : mapping of Hashable to sequence of Hashable
            Mapping of the form `new_name=(dim1, dim2, ...)`.
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nfor drop in [False, True]:\n ds2 = ds.set_index(z=['a', 'b']).reset_index('z', drop=drop)\n print('drop',drop)\n print(ds2._variables.keys(), ds2._coord_names)\n print(ds2)\n\""
}
```

**tool result**

```
Command FAILED (exit status 1): `cd /testbed && python -c "
import xarray as xr
ds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})
for drop in [False, True]:
 ds2 = ds.set_index(z=['a', 'b']).reset_index('z', drop=drop)
 print('drop',drop)
 print(ds2._variables.keys(), ds2._coord_names)
 print(ds2)
"`
Output: Traceback (most recent call last):
  File "<string>", line 8, in <module>
  File "/testbed/xarray/core/dataset.py", line 2084, in __repr__
    return formatting.dataset_repr(self)
  File "/testbed/xarray/core/formatting.py", line 617, in dataset_repr
    summary.append(data_vars_repr(ds.data_vars, col_width=col_width, max_rows=max_rows))
  File "/testbed/xarray/core/formatting.py", line 352, in _mapping_repr
    if mapping:
ValueError: __len__() should return >= 0
drop False
dict_keys(['z', 'a', 'b']) {'z', 'a', 'b'}
<xarray.Dataset>
Dimensions:  (z: 3)
Coordinates:
    z        (z) object MultiIndex
    a        (z) int64 1 2 3
    b        (z) <U1 'a' 'b' 'c'
Data variables:
    *empty*
drop True
dict_keys(['a', 'b']) {'z', 'a', 'b'}

The command line above is exactly what ran — fix IT (wrong subcommand, missing flag, wrong path) and retry; do not repeat it unchanged.
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -rn \"coord_names -\\|coord_names =\\|_coord_names\" xarray/core/dataset.py | grep -n \"variables\\|set\" | head -60 && grep -rn \"reset_index.*drop\" doc/whats-new.rst | head"
}
```

**tool result**

```
1:364:            if key not in self._dataset._coord_names
2:368:        return len(self._dataset._variables) - len(self._dataset._coord_names)
3:371:        return key in self._dataset._variables and key not in self._dataset._coord_names
4:374:        if key not in self._dataset._coord_names:
5:403:            if key not in self._dataset._coord_names
6:557:    _coord_names: set[Hashable]
10:750:            (type(self), self._variables, self._coord_names, self._attrs)
19:1112:            variables=new_variables, coord_names=new_coord_names, indexes=new_indexes
20:1118:            new_variables, new_coord_names = replaced._rename_vars({}, rename_dims)
21:1120:                variables=new_variables, coord_names=new_coord_names, dims=dims
22:1275:        coord_names = set()
25:1327:            if k in self._coord_names and set(self.variables[k].dims) <= needed_dims:
30:1720:            names = self._coord_names - set(self._indexes)
33:2461:        coord_names = self._coord_names & variables.keys()
34:2468:        coord_names = self._coord_names & variables.keys() | coord_vars.keys()
36:2815:            new_coord_names = self._coord_names | set(new_indexes)
37:2817:                new_variables, new_coord_names, indexes=new_indexes
38:3383:        coord_names = obj._coord_names & variables.keys()
39:3404:        coord_names = obj._coord_names & variables.keys() | coord_vars.keys()
40:3509:        coord_names = set()
45:3555:        variables, coord_names = self._rename_vars(name_dict, dims_dict)
52:4071:                        k: self._variables[k] for k in current_coord_names
53:4102:        coord_names = self._coord_names - set(drop_variables) | set(new_variables)
54:4180:        coord_names = set(new_variables) | self._coord_names
55:4321:        new_coord_names = set(self._coord_names)
57:4344:            new_variables, coord_names=new_coord_names, indexes=indexes
58:4544:        coord_names = set(self._coord_names) - {dim} | set(new_indexes)
59:4595:        coord_names = set(self._coord_names) - {dim} | set(new_dim_sizes)
60:4889:                idx_coord_names = set(maybe_midx.index.names + [maybe_midx.dim])
61:4890:                idx_other_names = idx_coord_names - set(names)
62:4904:        coord_names = {k for k in self._coord_names if k in variables}
63:5637:        coord_names = {k for k in self.coords if k in variables}
66:6903:        coord_names = {k for k in self.coords if k in variables}
67:6963:        coord_names = set(self.coords)
68:7125:        coord_names = set()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/xarray/core/dataset.py\n@@\n     def __len__(self) -> int:\n-        return len(self._dataset._variables) - len(self._dataset._coord_names)\n+        return sum(1 for _ in self)\n@@\n-        coord_names = set(new_variables) | self._coord_names\n+        coord_names = (set(new_variables) | self._coord_names) - set(drop_variables)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/xarray/core/dataset.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/xarray/core/dataset.py now (8935 lines), around the change:
365:        )
366:
367:    def __len__(self) -> int:
368:        return sum(1 for _ in self)
369:
370:    def __contains__(self, key: Hashable) -> bool:
371:        return key in self._dataset._variables and key not in self._dataset._coord_names
…
4177:        }
4178:        variables.update(new_variables)
4179:
4180:        coord_names = (set(new_variables) | self._coord_names) - set(drop_variables)
4181:
4182:        return self._replace(variables, coord_names=coord_names, indexes=indexes)
4183:
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nfor d in [False, True]:\n ds2 = ds.set_index(z=['a', 'b']).reset_index('z', drop=d)\n print('drop',d)\n print(ds2)\n print(ds2._variables.keys(), ds2._coord_names, list(ds2.xindexes))\n print(len(ds2.data_vars))\n\""
}
```

**tool result**

```
drop False
<xarray.Dataset>
Dimensions:  (z: 3)
Coordinates:
    z        (z) object MultiIndex
    a        (z) int64 1 2 3
    b        (z) <U1 'a' 'b' 'c'
Data variables:
    *empty*
dict_keys(['z', 'a', 'b']) {'z', 'a', 'b'} []
0
drop True
<xarray.Dataset>
Dimensions:  (z: 3)
Coordinates:
    a        (z) int64 1 2 3
    b        (z) <U1 'a' 'b' 'c'
Dimensions without coordinates: z
Data variables:
    *empty*
dict_keys(['a', 'b']) {'a', 'b'} []
0


(this is the fourth time you have made nearly this same bash call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -n '3200,3265p' xarray/tests/test_dataset.py"
}
```

**tool result**

```
                    ),
                    dims=["e", "b", "a"],
                ),
            },
            coords={"c": np.linspace(0, 1, 5)},
            attrs={"key": "entry"},
        )
        assert_identical(other_way_expected, other_way)

    def test_set_index(self) -> None:
        expected = create_test_multiindex()
        mindex = expected["x"].to_index()
        indexes = [mindex.get_level_values(n) for n in mindex.names]
        coords = {idx.name: ("x", idx) for idx in indexes}
        ds = Dataset({}, coords=coords)

        obj = ds.set_index(x=mindex.names)
        assert_identical(obj, expected)

        # ensure pre-existing indexes involved are removed
        # (level_2 should be a coordinate with no index)
        ds = create_test_multiindex()
        coords = {"x": coords["level_1"], "level_2": coords["level_2"]}
        expected = Dataset({}, coords=coords)

        obj = ds.set_index(x="level_1")
        assert_identical(obj, expected)

        # ensure set_index with no existing index and a single data var given
        # doesn't return multi-index
        ds = Dataset(data_vars={"x_var": ("x", [0, 1, 2])})
        expected = Dataset(coords={"x": [0, 1, 2]})
        assert_identical(ds.set_index(x="x_var"), expected)

        with pytest.raises(ValueError, match=r"bar variable\(s\) do not exist"):
            ds.set_index(foo="bar")

        with pytest.raises(ValueError, match=r"dimension mismatch.*"):
            ds.set_index(y="x_var")

    def test_reset_index(self) -> None:
        ds = create_test_multiindex()
        mindex = ds["x"].to_index()
        indexes = [mindex.get_level_values(n) for n in mindex.names]
        coords = {idx.name: ("x", idx) for idx in indexes}
        coords["x"] = ("x", mindex.values)
        expected = Dataset({}, coords=coords)

        obj = ds.reset_index("x")
        assert_identical(obj, expected, check_default_indexes=False)
        assert len(obj.xindexes) == 0

        ds = Dataset(coords={"y": ("x", [1, 2, 3])})
        with pytest.raises(ValueError, match=r".*not coordinates with an index"):
            ds.reset_index("y")

    def test_reset_index_keep_attrs(self) -> None:
        coord_1 = DataArray([1, 2], dims=["coord_1"], attrs={"attrs": True})
        ds = Dataset({}, {"coord_1": coord_1})
        obj = ds.reset_index("coord_1")
        assert_identical(obj, ds, check_default_indexes=False)
        assert len(obj.xindexes) == 0

    def test_reorder_levels(self) -> None:
        ds = create_test_multiindex()
        mindex = ds["x"].to_index()
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && grep -rn \"len(.*_variables).*len(.*_coord_names)\\|_variables) - len\" xarray | head -20"
}
```

**tool result**

```

```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/xarray/tests/test_dataset.py\n@@\n         obj = ds.reset_index(\"x\")\n         assert_identical(obj, expected, check_default_indexes=False)\n         assert len(obj.xindexes) == 0\n \n+        # regression test for GH7105: drop=True must also drop the index\n+        # coordinate names, not only the variables\n+        ds = Dataset(coords={\"a\": (\"x\", [1, 2, 3]), \"b\": (\"x\", [\"a\", \"b\", \"c\"])})\n+        obj = ds.set_index(z=[\"a\", \"b\"]).reset_index(\"z\", drop=True)\n+        expected = Dataset(coords={\"a\": (\"x\", [1, 2, 3]), \"b\": (\"x\", [\"a\", \"b\", \"c\"])})\n+        assert_identical(obj, expected, check_default_indexes=False)\n+        assert len(obj.data_vars) == 0\n+\n         ds = Dataset(coords={\"y\": (\"x\", [1, 2, 3])})\n         with pytest.raises(ValueError, match=r\".*not coordinates with an index\"):\n             ds.reset_index(\"y\")\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/xarray/tests/test_dataset.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/xarray/tests/test_dataset.py now (6673 lines), around the change:
3248:        obj = ds.reset_index("x")
3249:        assert_identical(obj, expected, check_default_indexes=False)
3250:        assert len(obj.xindexes) == 0
3251:
3252:        # regression test for GH7105: drop=True must also drop the index
3253:        # coordinate names, not only the variables
3254:        ds = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
3255:        obj = ds.set_index(z=["a", "b"]).reset_index("z", drop=True)
3256:        expected = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
3257:        assert_identical(obj, expected, check_default_indexes=False)
3258:        assert len(obj.data_vars) == 0
3259:
3260:        ds = Dataset(coords={"y": ("x", [1, 2, 3])})
3261:        with pytest.raises(ValueError, match=r".*not coordinates with an index"):
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest xarray/tests/test_dataset.py -q -k \"reset_index or set_index or data_vars\" 2>&1 | tail -20"
}
```

**tool result**

```
    
        # regression test for GH7105: drop=True must also drop the index
        # coordinate names, not only the variables
        ds = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
        obj = ds.set_index(z=["a", "b"]).reset_index("z", drop=True)
        expected = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
>       assert_identical(obj, expected, check_default_indexes=False)
E       AssertionError: Left and right Dataset objects are not identical
E       Differing dimensions:
E           (z: 3) != (x: 3)
E       Differing coordinates:
E       L   a        (z) int64 1 2 3
E       R   a        (x) int64 1 2 3
E       L   b        (z) <U1 'a' 'b' 'c'
E       R   b        (x) <U1 'a' 'b' 'c'

/testbed/xarray/tests/test_dataset.py:3257: AssertionError
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_reset_index - Assertio...
1 failed, 3 passed, 369 deselected in 1.88s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/xarray/tests/test_dataset.py\n@@\n         ds = Dataset(coords={\"a\": (\"x\", [1, 2, 3]), \"b\": (\"x\", [\"a\", \"b\", \"c\"])})\n         obj = ds.set_index(z=[\"a\", \"b\"]).reset_index(\"z\", drop=True)\n-        expected = Dataset(coords={\"a\": (\"x\", [1, 2, 3]), \"b\": (\"x\", [\"a\", \"b\", \"c\"])})\n-        assert_identical(obj, expected, check_default_indexes=False)\n+        assert list(obj.coords) == [\"a\", \"b\"]\n+        assert obj._coord_names == {\"a\", \"b\"}\n         assert len(obj.data_vars) == 0\n+        assert list(obj.data_vars) == []\n \n         ds = Dataset(coords={\"y\": (\"x\", [1, 2, 3])})\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/xarray/tests/test_dataset.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/xarray/tests/test_dataset.py now (6674 lines), around the change:
3253:        # coordinate names, not only the variables
3254:        ds = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
3255:        obj = ds.set_index(z=["a", "b"]).reset_index("z", drop=True)
3256:        assert list(obj.coords) == ["a", "b"]
3257:        assert obj._coord_names == {"a", "b"}
3258:        assert len(obj.data_vars) == 0
3259:        assert list(obj.data_vars) == []
3260:
3261:        ds = Dataset(coords={"y": ("x", [1, 2, 3])})
3262:        with pytest.raises(ValueError, match=r".*not coordinates with an index"):
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest xarray/tests/test_dataset.py -q -k \"reset_index or set_index or data_vars\" 2>&1 | tail -8 && python -m pytest xarray/tests/test_dataarray.py -q -k \"reset_index or set_index or data_vars\" 2>&1 | tail -8"
}
```

**tool result**

```
....                                                                     [100%]
4 passed, 369 deselected in 1.24s
...                                                                      [100%]
3 passed, 447 deselected in 1.22s
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest xarray/tests/test_dataset.py xarray/tests/test_dataarray.py -q 2>&1 | tail -15"
}
```

**tool result**

```
    original.rename({"x": "a"})

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/xarray/tests/test_dataset.py:2923: UserWarning: rename 'a' to 'x' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"a": "x"})

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/ma/core.py:7939: DeprecationWarning: elementwise comparison failed; this will raise an error in the future.
    if not np.all(xinf == filled(np.isinf(y), False)):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
812 passed, 2 skipped, 7 xfailed, 2 xpassed, 7 warnings in 31.33s
```

**assistant**

````
Implemented the fix.

### Changes

**`xarray/core/dataset.py`**

1. `DataVariables.__len__` no longer assumes `len(variables) >= len(coord_names)`. It now counts the actual data variables:
   ```python
   def __len__(self) -> int:
       return sum(1 for _ in self)
   ```
   This removes the `ValueError: __len__() should return >= 0` and makes the mapping robust to stale/invalid coordinate-name bookkeeping.

2. `Dataset.reset_index(..., drop=True)` now removes the dropped names from `_coord_names` as well as from `_variables`:
   ```python
   coord_names = (set(new_variables) | self._coord_names) - set(drop_variables)
   ```
   Previously only the variable was deleted, leaving `z` in `_coord_names` even though it no longer existed in `_variables`.

**`xarray/tests/test_dataset.py`**

Added a regression test using the issue's MVCE, asserting that:
- only `a` and `b` remain as coordinates,
- `z` is gone from `_coord_names`,
- `data_vars` is empty and iterable.

### Verification

- `test_dataset.py` and `test_dataarray.py`: **812 passed, 2 skipped, 7 xfailed, 2 xpassed**.
````

## Run folder `team-solve-2026-11-06T114756`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
e90b06ddb16347185454e6ed9768dcbb57e95c4d
```

### `baseline-check.log`

```
check: python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q
........................................................................ [ 16%]
..................................xX.................................... [ 32%]
........................................................................ [ 48%]
........................................................................ [ 65%]
........................................................................ [ 81%]
..........s............................................................. [ 97%]
.........                                                                [100%]
=============================== warnings summary ===============================
xarray/tests/test_dataset.py::TestDataset::test_rename_same_name
  /testbed/.memdoor/runs/team-solve-2026-11-06T114756/baseline-tree/xarray/tests/test_dataset.py:2842: UserWarning: rename 'dim2' to 'dim2' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    renamed = data.rename(newnames)

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/.memdoor/runs/team-solve-2026-11-06T114756/baseline-tree/xarray/tests/test_dataset.py:2921: UserWarning: rename 'x' to 'a' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"x": "a"})

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/.memdoor/runs/team-solve-2026-11-06T114756/baseline-tree/xarray/tests/test_dataset.py:2923: UserWarning: rename 'a' to 'x' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"a": "x"})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
438 passed, 1 skipped, 1 xfailed, 1 xpassed, 3 warnings in 10.95s
```

### `baseline-status.txt`

```
0
```

### `changes.diff`

```diff
diff --git a/xarray/core/dataset.py b/xarray/core/dataset.py
index 620f32f8..d9adfcc5 100644
--- a/xarray/core/dataset.py
+++ b/xarray/core/dataset.py
@@ -365,7 +365,7 @@ class DataVariables(Mapping[Any, "DataArray"]):
         )
 
     def __len__(self) -> int:
-        return len(self._dataset._variables) - len(self._dataset._coord_names)
+        return sum(1 for _ in self)
 
     def __contains__(self, key: Hashable) -> bool:
         return key in self._dataset._variables and key not in self._dataset._coord_names
@@ -4177,7 +4177,7 @@ class Dataset(
         }
         variables.update(new_variables)
 
-        coord_names = set(new_variables) | self._coord_names
+        coord_names = (set(new_variables) | self._coord_names) - set(drop_variables)
 
         return self._replace(variables, coord_names=coord_names, indexes=indexes)
 
diff --git a/xarray/tests/test_dataset.py b/xarray/tests/test_dataset.py
index fc2806c7..ef2ade2c 100644
--- a/xarray/tests/test_dataset.py
+++ b/xarray/tests/test_dataset.py
@@ -3249,6 +3249,15 @@ class TestDataset:
         assert_identical(obj, expected, check_default_indexes=False)
         assert len(obj.xindexes) == 0
 
+        # regression test for GH7105: drop=True must also drop the index
+        # coordinate names, not only the variables
+        ds = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
+        obj = ds.set_index(z=["a", "b"]).reset_index("z", drop=True)
+        assert list(obj.coords) == ["a", "b"]
+        assert obj._coord_names == {"a", "b"}
+        assert len(obj.data_vars) == 0
+        assert list(obj.data_vars) == []
+
         ds = Dataset(coords={"y": ("x", [1, 2, 3])})
         with pytest.raises(ValueError, match=r".*not coordinates with an index"):
             ds.reset_index("y")
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

index refactor: more `_coord_names` than `_variables` on Dataset
### What happened?

`xr.core.dataset.DataVariables` assumes that everything that is in `ds._dataset._variables` and not in `self._dataset._coord_names` is a "data variable". However, since the index refactor we can end up with more `_coord_names` than `_variables` which breaks a number of stuff (e.g. the repr).

### What did you expect to happen?

Well it seems this assumption is now wrong.

### Minimal Complete Verifiable Example

```Python
ds = xr.Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ['a', 'b', 'c'])})
ds.set_index(z=['a', 'b']).reset_index("z", drop=True)
```


### MVCE confirmation

- [ ] Minimal example — the example is as focused as reasonably possible to demonstrate the underlying issue in xarray.
- [ ] Complete example — the example is self-contained, including all data and the text of any traceback.
- [ ] Verifiable example — the example copy & pastes into an IPython prompt or [Binder notebook](https://mybinder.org/v2/gh/pydata/xarray/main?urlpath=lab/tree/doc/examples/blank_template.ipynb), returning the result.
- [ ] New issue — a search of GitHub Issues suggests this is not a duplicate.

### Relevant log output

```Python
ValueError: __len__() should return >= 0
```


### Anything else we need to know?

The error comes from here

https://github.com/pydata/xarray/blob/63ba862d03c8d0cd8b44d2071bc360e9fed4519d/xarray/core/dataset.py#L368

Bisected to #5692 - which probably does not help too much.


### Environment

<details>



</details>

## Deliverable

changes to this tree

## Check

`python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q`

## Scope

`xarray/core/dataset.py`
`xarray/tests/test_dataset.py`
`xarray/tests/test_indexes.py`

## Done when

- `Dataset.data_vars` tolerates `_coord_names` containing names not present in `_variables`, and its length is never negative.
- The supplied MVCE `ds.set_index(z=['a','b']).reset_index("z", drop=True)` completes, and `repr(ds)` no longer raises `ValueError: __len__() should return >= 0`.
- `Dataset.data_vars` still counts only variables that are not coordinate names.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q`

## Scope
`xarray/core/dataset.py`
`xarray/tests/test_dataset.py`
`xarray/tests/test_indexes.py`

## Done when
- `Dataset.data_vars` tolerates `_coord_names` containing names not present in `_variables`, and its length is never negative.
- The supplied MVCE `ds.set_index(z=['a','b']).reset_index("z", drop=True)` completes, and `repr(ds)` no longer raises `ValueError: __len__() should return >= 0`.
- `Dataset.data_vars` still counts only variables that are not coordinate names.

## Approach
First, fix the assumption directly in `DataVariables.__len__` by subtracting only the intersection `_coord_names & _variables`, matching the existing filtering in `DataVariables.__iter__` and `__contains__`. This is the minimal, low-risk fix and directly removes the negative length.

If the MVCE still fails after that, inspect `Dataset.reset_index(..., drop=True)`: it may leave stale names in `_coord_names` after removing dropped variables. Root-cause candidate: update `_coord_names` when dropping index/level variables so `_coord_names ⊆ _variables` is restored; tradeoff is a slightly larger behavioral change to `reset_index`.

A broader defensive alternative is to make `Coordinates` and formatting also ignore names absent from `_variables`; tradeoff is that it hides inconsistent dataset state rather than fixing or tolerating the stated assumption. Prefer the intersection fix, plus stale-coordinate cleanup only if required by the MVCE or repr.


# xarray/core/dataset.py

```
from __future__ import annotations

import copy
import datetime
import inspect
import itertools
import math
import sys
import warnings
from collections import defaultdict
from html import escape
from numbers import Number
from operator import methodcaller
from os import PathLike
from typing import (
    IO,
    TYPE_CHECKING,
    Any,
    Callable,
    Collection,
    Generic,
    Hashable,
    Iterable,
    Iterator,
    Literal,
    Mapping,
    MutableMapping,
    Sequence,
    cast,
    overload,
)

import numpy as np
import pandas as pd

from ..coding.calendar_ops import convert_calendar, interp_calendar
from ..coding.cftimeindex import CFTimeIndex, _parse_array_of_cftime_strings
from ..plot.dataset_plot import _Dataset_PlotMethods
from . import alignment
from . import dtypes as xrdtypes
from . import duck_array_ops, formatting, formatting_html, ops, utils
from ._reductions import DatasetReductions
from .alignment import _broadcast_helper, _get_broadcast_dims_map_common_coords, align
from .arithmetic import DatasetArithmetic
from .common import DataWithCoords, _contains_datetime_like_objects, get_chunksizes
from .computation import unify_chunks
from .coordinates import DatasetCoordinates, assert_coordinate_consistent
from .duck_array_ops import datetime_to_numeric
from .indexes import (
    Index,
    Indexes,
    PandasIndex,
    PandasMultiIndex,
    assert_no_index_corrupted,
    create_default_index_implicit,
    filter_indexes_from_coords,
    isel_indexes,
    remove_unused_levels_categories,
    roll_indexes,
)
from .indexing import is_fancy_indexer, map_index_queries
from .merge import (
    dataset_merge_method,
    dataset_update_method,
    merge_coordinates_without_align,
    merge_data_and_coords,
)
from .missing import get_clean_interp_index
from .npcompat import QUANTILE_METHODS, ArrayLike
from .options import OPTIONS, _get_keep_attrs
from .pycompat import is_duck_dask_array, sparse_array_type
from .types import T_Dataset
from .utils import (
    Default,
    Frozen,
    HybridMappingProxy,
    OrderedSet,
    _default,
    decode_numpy_dict_values,
    drop_dims_from_indexers,
    either_dict_or_kwargs,
    infix_dims,
    is_dict_like,
    is_scalar,
    maybe_wrap_array,
)
from .variable import (
    IndexVariable,
    Variable,
    as_variable,
    broadcast_variables,
    calculate_dimensions,
)

if TYPE_CHECKING:
    from ..backends import AbstractDataStore, ZarrStore
    from ..backends.api import T_NetcdfEngine, T_NetcdfTypes
    from .coordinates import Coordinates
    from .dataarray import DataArray
    from .groupby import DatasetGroupBy
    from .merge import CoercibleMapping
    from .resample import DatasetResample
    from .rolling import DatasetCoarsen, DatasetRolling
    from .types import (
        CFCalendar,
        CoarsenBoundaryOptions,
        CombineAttrsOptions,
        CompatOptions,
        DatetimeUnitOptions,
        Ellipsis,
        ErrorOptions,
        ErrorOptionsWithWarn,
        InterpOptions,
        JoinOptions,
        PadModeOptions,
        PadReflectOptions,
        QueryEngineOptions,
        QueryParserOptions,
        ReindexMethodOptions,
        SideOptions,
        T_Xarray,
    )
    from .weighted import DatasetWeighted

    try:
        from dask.delayed import Delayed
    except ImportError:
        Delayed = None  # type: ignore
    try:
        from dask.dataframe import DataFrame as DaskDataFrame
    except ImportError:
        DaskDataFrame = None  # type: ignore


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
    variables, key: Hashable, dim_sizes: Mapping = None
) -> tuple[Hashable, Hashable, Variable]:
    """Get a virtual variable (e.g., 'time.year') from a dict of xarray.Variable
    objects (if possible)

    """
    from .dataarray import DataArray

    if dim_sizes is None:
        dim_sizes = {}

    if key in dim_sizes:
        data = pd.Index(range(dim_sizes[key]), name=key)
        variable = IndexVariable((key,), data)
        return key, key, variable

    if not isinstance(key, str):
        raise KeyError(key)

    split_key = key.split(".", 1)
    if len(split_key) != 2:
        raise KeyError(key)

    ref_name, var_name = split_key
    ref_var = variables[ref_name]

    if _contains_datetime_like_objects(ref_var):
        ref_var = DataArray(ref_var)
        data = getattr(ref_var.dt, var_name).data
    else:
        data = getattr(ref_var, var_name).data
    virtual_var = Variable(ref_var.dims, data)

    return ref_name, var_name, virtual_var


def _assert_empty(args: tuple, msg: str = "%s") -> None:
    if args:
        raise ValueError(msg % args)


def _get_chunk(var, chunks):
    """
    Return map from each dim to chunk sizes, accounting for backend's preferred chunks.
    """

    import dask.array as da

    if isinstance(var, IndexVariable):
        return {}
    dims = var.dims
    shape = var.shape

    # Determine the explicit requested chunks.
    preferred_chunks = var.encoding.get("preferred_chunks", {})
    preferred_chunk_shape = tuple(
        preferred_chunks.get(dim, size) for dim, size in zip(dims, shape)
    )
    if isinstance(chunks, Number) or (chunks == "auto"):
        chunks = dict.fromkeys(dims, chunks)
    chunk_shape = tuple(
        chunks.get(dim, None) or preferred_chunk_sizes
        for dim, preferred_chunk_sizes in zip(dims, preferred_chunk_shape)
    )
    chunk_shape = da.core.normalize_chunks(
        chunk_shape, shape=shape, dtype=var.dtype, previous_chunks=preferred_chunk_shape
    )

    # Warn where requested chunks break preferred chunks, provided that the variable
    # contains data.
    if var.size:
        for dim, size, chunk_sizes in zip(dims, shape, chunk_shape):
            try:
                preferred_chunk_sizes = preferred_chunks[dim]
            except KeyError:
                continue
            # Determine the stop indices of the preferred chunks, but omit the last stop
            # (equal to the dim size).  In particular, assume that when a sequence
            # expresses the preferred chunks, the sequence sums to the size.
            preferred_stops = (
                range(preferred_chunk_sizes, size, preferred_chunk_sizes)
                if isinstance(preferred_chunk_sizes, Number)
                else itertools.accumulate(preferred_chunk_sizes[:-1])
            )
            # Gather any stop indices of the specified chunks that are not a stop index
            # of a preferred chunk.  Again, omit the last stop, assuming that it equals
            # the dim size.
            breaks = set(itertools.accumulate(chunk_sizes[:-1])).difference(
                preferred_stops
            )
            if breaks:
                warnings.warn(
                    "The specified Dask chunks separate the stored chunks along "
                    f'dimension "{dim}" starting at index {min(breaks)}. This could '
                    "degrade performance. Instead, consider rechunking after loading."
                )

    return dict(zip(dims, chunk_shape))


def _maybe_chunk(
    name,
    var,
    chunks,
    token=None,
    lock=None,
    name_prefix="xarray-",
    overwrite_encoded_chunks=False,
    inline_array=False,
):
    from dask.base import tokenize

    if chunks is not None:
        chunks = {dim: chunks[dim] for dim in var.dims if dim in chunks}
    if var.ndim:
        # when rechunking by different amounts, make sure dask names change
        # by provinding chunks as an input to tokenize.
        # subtle bugs result otherwise. see GH3350
        token2 = tokenize(name, token if token else var._data, chunks)
        name2 = f"{name_prefix}{name}-{token2}"
        var = var.chunk(chunks, name=name2, lock=lock, inline_array=inline_array)

        if overwrite_encoded_chunks and var.chunks is not None:
            var.encoding["chunks"] = tuple(x[0] for x in var.chunks)
        return var
    else:
        return var


def as_dataset(obj: Any) -> Dataset:
    """Cast the given object to a Dataset.

    Handles Datasets, DataArrays and dictionaries of variables. A new Dataset
    object is only created if the provided object is not already one.
    """
    if hasattr(obj, "to_dataset"):
        obj = obj.to_dataset()
    if not isinstance(obj, Dataset):
        obj = Dataset(obj)
    return obj


def _get_func_args(func, param_names):
    """Use `inspect.signature` to try accessing `func` args. Otherwise, ensure
    they are provided by user.
    """
    try:
        func_args = inspect.signature(func).parameters
    except ValueError:
        func_args = {}
        if not param_names:
            raise ValueError(
                "Unable to inspect `func` signature, and `param_names` was not provided."
            )
    if param_names:
        params = param_names
    else:
        params = list(func_args)[1:]
        if any(
            [(p.kind in [p.VAR_POSITIONAL, p.VAR_KEYWORD]) for p in func_args.values()]
        ):
            raise ValueError(
                "`param_names` must be provided because `func` takes variable length arguments."
            )
    return params, func_args


def _initialize_curvefit_params(params, p0, bounds, func_args):
    """Set initial guess and bounds for curvefit.
    Priority: 1) passed args 2) func signature 3) scipy defaults
    """

    def _initialize_feasible(lb, ub):
        # Mimics functionality of scipy.optimize.minpack._initialize_feasible
        lb_finite = np.isfinite(lb)
        ub_finite = np.isfinite(ub)
        p0 = np.nansum(
            [
                0.5 * (lb + ub) * int(lb_finite & ub_finite),
                (lb + 1) * int(lb_finite & ~ub_finite),
                (ub - 1) * int(~lb_finite & ub_finite),
            ]
        )
        return p0

    param_defaults = {p: 1 for p in params}
    bounds_defaults = {p: (-np.inf, np.inf) for p in params}
    for p in params:
        if p in func_args and func_args[p].default is not func_args[p].empty:
            param_defaults[p] = func_args[p].default
        if p in bounds:
            bounds_defaults[p] = tuple(bounds[p])
            if param_defaults[p] < bounds[p][0] or param_defaults[p] > bounds[p][1]:
                param_defaults[p] = _initialize_feasible(bounds[p][0], bounds[p][1])
        if p in p0:
            param_defaults[p] = p0[p]
    return param_defaults, bounds_defaults


class DataVariables(Mapping[Any, "DataArray"]):
    __slots__ = ("_dataset",)

    def __init__(self, dataset: Dataset):
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

    def __getitem__(self, key: Hashable) -> DataArray:
        if key not in self._dataset._coord_names:
            return cast("DataArray", self._dataset[key])
        raise KeyError(key)

    def __repr__(self) -> str:
        return formatting.data_vars_repr(self)

    @property
    def variables(self) -> Mapping[Hashable, Variable]:
        all_variables = self._dataset.variables
        return Frozen({k: all_variables[k] for k in self})

    @property
    def dtypes(self) -> Frozen[Hashable, np.dtype]:
        """Mapping from data variable names to dtypes.

        Cannot be modified directly, but is updated when adding new variables.

        See Also
        --------
        Dataset.dtype
        """
        return self._dataset.dtypes

    def _ipython_key_completions_(self):
        """Provide method for the key-autocompletions in IPython."""
        return [
            key
            for key in self._dataset._ipython_key_completions_()
            if key not in self._dataset._coord_names
        ]


class _LocIndexer(Generic[T_Dataset]):
    __slots__ = ("dataset",)

    def __init__(self, dataset: T_Dataset):
        self.dataset = dataset

    def __getitem__(self, key: Mapping[Any, Any]) -> T_Dataset:
        if not utils.is_dict_like(key):
            raise TypeError("can only lookup dictionaries from Dataset.loc")
        return self.dataset.sel(key)

    def __setitem__(self, key, value) -> None:
        if not utils.is_dict_like(key):
            raise TypeError(
                "can only set locations defined by dictionaries from Dataset.loc."
                f" Got: {key}"
            )

        # set new values
        dim_indexers = map_index_queries(self.dataset, key).dim_indexers
        self.dataset[dim_indexers] = value


class Dataset(
    DataWithCoords, DatasetReductions, DatasetArithmetic, Mapping[Hashable, "DataArray"]
):
    """A multi-dimensional, in memory, array database.

    A dataset resembles an in-memory representation of a NetCDF file,
    and consists of variables, coordinates and attributes which
    together form a self describing dataset.

    Dataset implements the mapping interface with keys given by variable
    names and values given by DataArray objects for each variable name.

    One dimensional variables with name equal to their dimension are
    index coordinates used for label based indexing.

    To load data from a file or file-like object, use the `open_dataset`
    function.

    Parameters
    ----------
    data_vars : dict-like, optional
        A mapping from variable names to :py:class:`~xarray.DataArray`
        objects, :py:class:`~xarray.Variable` objects or to tuples of
        the form ``(dims, data[, attrs])`` which can be used as
        arguments to create a new ``Variable``. Each dimension must
        have the same length in all variables in which it appears.

        The following notations are accepted:

        - mapping {var name: DataArray}
        - mapping {var name: Variable}
        - mapping {var name: (dimension name, array-like)}
        - mapping {var name: (tuple of dimension names, array-like)}
        - mapping {dimension name: array-like}
          (it will be automatically moved to coords, see below)

        Each dimension must have the same length in all variables in
        which it appears.
    coords : dict-like, optional
        Another mapping in similar form as the `data_vars` argument,
        except the each item is saved on the dataset as a "coordinate".
        These variables have an associated meaning: they describe
        constant/fixed/independent quantities, unlike the
        varying/measured/dependent quantities that belong in
        `variables`. Coordinates values may be given by 1-dimensional
        arrays or scalars, in which case `dims` do not need to be
        supplied: 1D arrays will be assumed to give index values along
        the dimension with the same name.

        The following notations are accepted:

        - mapping {coord name: DataArray}
        - mapping {coord name: Variable}
        - mapping {coord name: (dimension name, array-like)}
        - mapping {coord name: (tuple of dimension names, array-like)}
        - mapping {dimension name: array-like}
          (the dimension name is implicitly set to be the same as the
          coord name)

        The last notation implies that the coord name is the same as
        the dimension name.

    attrs : dict-like, optional
        Global attributes to save on this dataset.

    Examples
    --------
    Create data:

    >>> np.random.seed(0)
    >>> temperature = 15 + 8 * np.random.randn(2, 2, 3)
    >>> precipitation = 10 * np.random.rand(2, 2, 3)
    >>> lon = [[-99.83, -99.32], [-99.79, -99.23]]
    >>> lat = [[42.25, 42.21], [42.63, 42.59]]
    >>> time = pd.date_range("2014-09-06", periods=3)
    >>> reference_time = pd.Timestamp("2014-09-05")

    Initialize a dataset with multiple dimensions:

    >>> ds = xr.Dataset(
    ...     data_vars=dict(
    ...         temperature=(["x", "y", "time"], temperature),
    ...         precipitation=(["x", "y", "time"], precipitation),
    ...     ),
    ...     coords=dict(
    ...         lon=(["x", "y"], lon),
    ...         lat=(["x", "y"], lat),
    ...         time=time,
    ...         reference_time=reference_time,
    ...     ),
    ...     attrs=dict(description="Weather related data."),
    ... )
    >>> ds
    <xarray.Dataset>
    Dimensions:         (x: 2, y: 2, time: 3)
    Coordinates:
        lon             (x, y) float64 -99.83 -99.32 -99.79 -99.23
        lat             (x, y) float64 42.25 42.21 42.63 42.59
      * time            (time) datetime64[ns] 2014-09-06 2014-09-07 2014-09-08
        reference_time  datetime64[ns] 2014-09-05
    Dimensions without coordinates: x, y
    Data variables:
        temperature     (x, y, time) float64 29.11 18.2 22.83 ... 18.28 16.15 26.63
        precipitation   (x, y, time) float64 5.68 9.256 0.7104 ... 7.992 4.615 7.805
    Attributes:
        description:  Weather related data.

    Find out where the coldest temperature was and what values the
    other variables had:

    >>> ds.isel(ds.temperature.argmin(...))
    <xarray.Dataset>
    Dimensions:         ()
    Coordinates:
        lon             float64 -99.32
        lat             float64 42.21
        time            datetime64[ns] 2014-09-08
        reference_time  datetime64[ns] 2014-09-05
    Data variables:
        temperature     float64 7.182
        precipitation   float64 8.326
    Attributes:
        description:  Weather related data.
    """

    _attrs: dict[Hashable, Any] | None
    _cache: dict[str, Any]
    _coord_names: set[Hashable]
    _dims: dict[Hashable, int]
    _encoding: dict[Hashable, Any] | None
    _close: Callable[[], None] | None
    _indexes: dict[Hashable, Index]
    _variables: dict[Hashable, Variable]

    __slots__ = (
        "_attrs",
        "_cache",
        "_coord_names",
        "_dims",
        "_encoding",
        "_close",
        "_indexes",
        "_variables",
        "__weakref__",
    )

    def __init__(
        self,
        # could make a VariableArgs to use more generally, and refine these
        # categories
        data_vars: Mapping[Any, Any] | None = None,
        coords: Mapping[Any, Any] | None = None,
        attrs: Mapping[Any, Any] | None = None,
    ) -> None:
        # TODO(shoyer): expose indexes as a public argument in __init__

        if data_vars is None:
            data_vars = {}
        if coords is None:
            coords = {}

        both_data_and_coords = set(data_vars) & set(coords)
        if both_data_and_coords:
            raise ValueError(
                f"variables {both_data_and_coords!r} are found in both data_vars and coords"
            )

        if isinstance(coords, Dataset):
            coords = coords.variables

        variables, coord_names, dims, indexes, _ = merge_data_and_coords(
            data_vars, coords, compat="broadcast_equals"
        )

        self._attrs = dict(attrs) if attrs is not None else None
        self._close = None
        self._encoding = None
        self._variables = variables
        self._coord_names = coord_names
        self._dims = dims
        self._indexes = indexes

    @classmethod
    def load_store(cls: type[T_Dataset], store, decoder=None) -> T_Dataset:
        """Create a new dataset from the contents of a backends.*DataStore
        object
        """
        variables, attributes = store.load()
        if decoder:
            variables, attributes = decoder(variables, attributes)
        obj = cls(variables, attrs=attributes)
        obj.set_close(store.close)
        return obj

    @property
    def variables(self) -> Frozen[Hashable, Variable]:
        """Low level interface to Dataset contents as dict of Variable objects.

        This ordered dictionary is frozen to prevent mutation that could
        violate Dataset invariants. It contains all variable objects
        constituting the Dataset, including both data variables and
        coordinates.
        """
        return Frozen(self._variables)

    @property
    def attrs(self) -> dict[Hashable, Any]:
        """Dictionary of global attributes on this dataset"""
        if self._attrs is None:
            self._attrs = {}
        return self._attrs

    @attrs.setter
    def attrs(self, value: Mapping[Any, Any]) -> None:
        self._attrs = dict(value)

    @property
    def encoding(self) -> dict[Hashable, Any]:
        """Dictionary of global encoding attributes on this dataset"""
        if self._encoding is None:
            self._encoding = {}
        return self._encoding

    @encoding.setter
    def encoding(self, value: Mapping[Any, Any]) -> None:
        self._encoding = dict(value)

    @property
    def dims(self) -> Frozen[Hashable, int]:
        """Mapping from dimension names to lengths.

        Cannot be modified directly, but is updated when adding new variables.

        Note that type of this object differs from `DataArray.dims`.
        See `Dataset.sizes` and `DataArray.sizes` for consistently named
        properties.

        See Also
        --------
        Dataset.sizes
        DataArray.dims
        """
        return Frozen(self._dims)

    @property
    def sizes(self) -> Frozen[Hashable, int]:
        """Mapping from dimension names to lengths.

        Cannot be modified directly, but is updated when adding new variables.

        This is an alias for `Dataset.dims` provided for the benefit of
        consistency with `DataArray.sizes`.

        See Also
        --------
        DataArray.sizes
        """
        return self.dims

    @property
    def dtypes(self) -> Frozen[Hashable, np.dtype]:
        """Mapping from data variable names to dtypes.

        Cannot be modified directly, but is updated when adding new variables.

        See Also
        --------
        DataArray.dtype
        """
        return Frozen(
            {
                n: v.dtype
                for n, v in self._variables.items()
                if n not in self._coord_names
            }
        )

    def load(self: T_Dataset, **kwargs) -> T_Dataset:
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
            Additional keyword arguments passed on to ``dask.compute``.

        See Also
        --------
        dask.compute
        """
        # access .data to coerce everything to numpy or dask arrays
        lazy_data = {
            k: v._data for k, v in self.variables.items() if is_duck_dask_array(v._data)
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
            (
                v.__dask_layers__()
                for v in self.variables.values()
                if dask.is_dask_collection(v)
            ),
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
        return self._dask_postcompute, ()

    def __dask_postpersist__(self):
        return self._dask_postpersist, ()

    def _dask_postcompute(self: T_Dataset, results: Iterable[Variable]) -> T_Dataset:
        import dask

        variables = {}
        results_iter = iter(results)

        for k, v in self._variables.items():
            if dask.is_dask_collection(v):
                rebuild, args = v.__dask_postcompute__()
                v = rebuild(next(results_iter), *args)
            variables[k] = v

        return type(self)._construct_direct(
            variables,
            self._coord_names,
            self._dims,
            self._attrs,
            self._indexes,
            self._encoding,
            self._close,
        )

    def _dask_postpersist(
        self: T_Dataset, dsk: Mapping, *, rename: Mapping[str, str] = None
    ) -> T_Dataset:
        from dask import is_dask_collection
        from dask.highlevelgraph import HighLevelGraph
        from dask.optimization import cull

        variables = {}

        for k, v in self._variables.items():
            if not is_dask_collection(v):
                variables[k] = v
                continue

            if isinstance(dsk, HighLevelGraph):
                # dask >= 2021.3
                # __dask_postpersist__() was called by dask.highlevelgraph.
                # Don't use dsk.cull(), as we need to prevent partial layers:
                # https://github.com/dask/dask/issues/7137
                layers = v.__dask_layers__()
                if rename:
                    layers = [rename.get(k, k) for k in layers]
                dsk2 = dsk.cull_layers(layers)
            elif rename:  # pragma: nocover
                # At the moment of writing, this is only for forward compatibility.
                # replace_name_in_key requires dask >= 2021.3.
                from dask.base import flatten, replace_name_in_key

                keys = [
                    replace_name_in_key(k, rename) for k in flatten(v.__dask_keys__())
                ]
                dsk2, _ = cull(dsk, keys)
            else:
                # __dask_postpersist__() was called by dask.optimize or dask.persist
                dsk2, _ = cull(dsk, v.__dask_keys__())

            rebuild, args = v.__dask_postpersist__()
            # rename was added in dask 2021.3
            kwargs = {"rename": rename} if rename else {}
            variables[k] = rebuild(dsk2, *args, **kwargs)

        return type(self)._construct_direct(
            variables,
            self._coord_names,
            self._dims,
            self._attrs,
            self._indexes,
            self._encoding,
            self._close,
        )

    def compute(self: T_Dataset, **kwargs) -> T_Dataset:
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
            Additional keyword arguments passed on to ``dask.compute``.

        See Also
        --------
        dask.compute
        """
        new = self.copy(deep=False)
        return new.load(**kwargs)

    def _persist_inplace(self: T_Dataset, **kwargs) -> T_Dataset:
        """Persist all Dask arrays in memory"""
        # access .data to coerce everything to numpy or dask arrays
        lazy_data = {
            k: v._data for k, v in self.variables.items() if is_duck_dask_array(v._data)
        }
        if lazy_data:
            import dask

            # evaluate all the dask arrays simultaneously
            evaluated_data = dask.persist(*lazy_data.values(), **kwargs)

            for k, data in zip(lazy_data, evaluated_data):
                self.variables[k].data = data

        return self

    def persist(self: T_Dataset, **kwargs) -> T_Dataset:
        """Trigger computation, keeping data as dask arrays

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
        cls: type[T_Dataset],
        variables: dict[Any, Variable],
        coord_names: set[Hashable],
        dims: dict[Any, int] | None = None,
        attrs: dict | None = None,
        indexes: dict[Any, Index] | None = None,
        encoding: dict | None = None,
        close: Callable[[], None] | None = None,
    ) -> T_Dataset:
        """Shortcut around __init__ for internal use when we want to skip
        costly validation
        """
        if dims is None:
            dims = calculate_dimensions(variables)
        if indexes is None:
            indexes = {}
        obj = object.__new__(cls)
        obj._variables = variables
        obj._coord_names = coord_names
        obj._dims = dims
        obj._indexes = indexes
        obj._attrs = attrs
        obj._close = close
        obj._encoding = encoding
        return obj

    def _replace(
        self: T_Dataset,
        variables: dict[Hashable, Variable] = None,
        coord_names: set[Hashable] | None = None,
        dims: dict[Any, int] | None = None,
        attrs: dict[Hashable, Any] | None | Default = _default,
        indexes: dict[Hashable, Index] | None = None,
        encoding: dict | None | Default = _default,
        inplace: bool = False,
    ) -> T_Dataset:
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
            if indexes is not None:
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
            if indexes is None:
                indexes = self._indexes.copy()
            if encoding is _default:
                encoding = copy.copy(self._encoding)
            obj = self._construct_direct(
                variables, coord_names, dims, attrs, indexes, encoding
            )
        return obj

    def _replace_with_new_dims(
        self: T_Dataset,
        variables: dict[Hashable, Variable],
        coord_names: set | None = None,
        attrs: dict[Hashable, Any] | None | Default = _default,
        indexes: dict[Hashable, Index] | None = None,
        inplace: bool = False,
    ) -> T_Dataset:
        """Replace variables with recalculated dimensions."""
        dims = calculate_dimensions(variables)
        return self._replace(
            variables, coord_names, dims, attrs, indexes, inplace=inplace
        )

    def _replace_vars_and_dims(
        self: T_Dataset,
        variables: dict[Hashable, Variable],
        coord_names: set | None = None,
        dims: dict[Hashable, int] | None = None,
        attrs: dict[Hashable, Any] | None | Default = _default,
        inplace: bool = False,
    ) -> T_Dataset:
        """Deprecated version of _replace_with_new_dims().

        Unlike _replace_with_new_dims(), this method always recalculates
        indexes from variables.
        """
        if dims is None:
            dims = calculate_dimensions(variables)
        return self._replace(
            variables, coord_names, dims, attrs, indexes=None, inplace=inplace
        )

    def _overwrite_indexes(
        self: T_Dataset,
        indexes: Mapping[Hashable, Index],
        variables: Mapping[Hashable, Variable] | None = None,
        drop_variables: list[Hashable] | None = None,
        drop_indexes: list[Hashable] | None = None,
        rename_dims: Mapping[Hashable, Hashable] | None = None,
    ) -> T_Dataset:
        """Maybe replace indexes.

        This function may do a lot more depending on index query
        results.

        """
        if not indexes:
            return self

        if variables is None:
            variables = {}
        if drop_variables is None:
            drop_variables = []
        if drop_indexes is None:
            drop_indexes = []

        new_variables = self._variables.copy()
        new_coord_names = self._coord_names.copy()
        new_indexes = dict(self._indexes)

        index_variables = {}
        no_index_variables = {}
        for name, var in variables.items():
            old_var = self._variables.get(name)
            if old_var is not None:
                var.attrs.update(old_var.attrs)
                var.encoding.update(old_var.encoding)
            if name in indexes:
                index_variables[name] = var
            else:
                no_index_variables[name] = var

        for name in indexes:
            new_indexes[name] = indexes[name]

        for name, var in index_variables.items():
            new_coord_names.add(name)
            new_variables[name] = var

        # append no-index variables at the end
        for k in no_index_variables:
            new_variables.pop(k)
        new_variables.update(no_index_variables)

        for name in drop_indexes:
            new_indexes.pop(name)

        for name in drop_variables:
            new_variables.pop(name)
            new_indexes.pop(name, None)
            new_coord_names.remove(name)

        replaced = self._replace(
            variables=new_variables, coord_names=new_coord_names, indexes=new_indexes
        )

        if rename_dims:
            # skip rename indexes: they should already have the right name(s)
            dims = replaced._rename_dims(rename_dims)
            new_variables, new_coord_names = replaced._rename_vars({}, rename_dims)
            return replaced._replace(
                variables=new_variables, coord_names=new_coord_names, dims=dims
            )
        else:
            return replaced

    def copy(
        self: T_Dataset, deep: bool = False, data: Mapping | None = None
    ) -> T_Dataset:
        """Returns a copy of this dataset.

        If `deep=True`, a deep copy is made of each of the component variables.
        Otherwise, a shallow copy of each of the component variable is made, so
        that the underlying memory region of the new dataset is the same as in
        the original dataset.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, default: False
            Whether each component variable is loaded into memory and copied onto
            the new object. Default is False.
        data : dict-like or None, optional
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
        ...     {"foo": da, "bar": ("x", [-1, 2])},
        ...     coords={"x": ["one", "two"]},
        ... )
        >>> ds.copy()
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
          * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 1.764 0.4002 0.9787 2.241 1.868 -0.9773
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
            foo      (dim_0, dim_1) float64 7.0 0.4002 0.9787 2.241 1.868 -0.9773
            bar      (x) int64 -1 2

        >>> ds
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
          * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 7.0 0.4002 0.9787 2.241 1.868 -0.9773
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
        Dimensions without coordina
```


# xarray/tests/test_dataset.py

```
from __future__ import annotations

import pickle
import sys
import warnings
from copy import copy, deepcopy
from io import StringIO
from textwrap import dedent
from typing import Any, Hashable

import numpy as np
import pandas as pd
import pytest
from pandas.core.indexes.datetimes import DatetimeIndex

import xarray as xr
from xarray import (
    DataArray,
    Dataset,
    IndexVariable,
    MergeError,
    Variable,
    align,
    backends,
    broadcast,
    open_dataset,
    set_options,
)
from xarray.coding.cftimeindex import CFTimeIndex
from xarray.core import dtypes, indexing, utils
from xarray.core.common import duck_array_ops, full_like
from xarray.core.coordinates import DatasetCoordinates
from xarray.core.indexes import Index
from xarray.core.pycompat import integer_types, sparse_array_type
from xarray.core.utils import is_scalar

from . import (
    InaccessibleArray,
    UnexpectedDataAccess,
    assert_allclose,
    assert_array_equal,
    assert_equal,
    assert_identical,
    assert_no_warnings,
    create_test_data,
    has_cftime,
    has_dask,
    requires_bottleneck,
    requires_cftime,
    requires_cupy,
    requires_dask,
    requires_numexpr,
    requires_pint,
    requires_scipy,
    requires_sparse,
    source_ndarray,
)

try:
    from pandas.errors import UndefinedVariableError
except ImportError:
    # TODO: remove once we stop supporting pandas<1.4.3
    from pandas.core.computation.ops import UndefinedVariableError


try:
    import dask.array as da
except ImportError:
    pass

pytestmark = [
    pytest.mark.filterwarnings("error:Mean of empty slice"),
    pytest.mark.filterwarnings("error:All-NaN (slice|axis) encountered"),
]


def create_append_test_data(seed=None) -> tuple[Dataset, Dataset, Dataset]:
    rs = np.random.RandomState(seed)

    lat = [2, 1, 0]
    lon = [0, 1, 2]
    nt1 = 3
    nt2 = 2
    time1 = pd.date_range("2000-01-01", periods=nt1)
    time2 = pd.date_range("2000-02-01", periods=nt2)
    string_var = np.array(["ae", "bc", "df"], dtype=object)
    string_var_to_append = np.array(["asdf", "asdfg"], dtype=object)
    string_var_fixed_length = np.array(["aa", "bb", "cc"], dtype="|S2")
    string_var_fixed_length_to_append = np.array(["dd", "ee"], dtype="|S2")
    unicode_var = ["áó", "áó", "áó"]
    datetime_var = np.array(
        ["2019-01-01", "2019-01-02", "2019-01-03"], dtype="datetime64[s]"
    )
    datetime_var_to_append = np.array(
        ["2019-01-04", "2019-01-05"], dtype="datetime64[s]"
    )
    bool_var = np.array([True, False, True], dtype=bool)
    bool_var_to_append = np.array([False, True], dtype=bool)

    ds = xr.Dataset(
        data_vars={
            "da": xr.DataArray(
                rs.rand(3, 3, nt1),
                coords=[lat, lon, time1],
                dims=["lat", "lon", "time"],
            ),
            "string_var": xr.DataArray(string_var, coords=[time1], dims=["time"]),
            "string_var_fixed_length": xr.DataArray(
                string_var_fixed_length, coords=[time1], dims=["time"]
            ),
            "unicode_var": xr.DataArray(
                unicode_var, coords=[time1], dims=["time"]
            ).astype(np.unicode_),
            "datetime_var": xr.DataArray(datetime_var, coords=[time1], dims=["time"]),
            "bool_var": xr.DataArray(bool_var, coords=[time1], dims=["time"]),
        }
    )

    ds_to_append = xr.Dataset(
        data_vars={
            "da": xr.DataArray(
                rs.rand(3, 3, nt2),
                coords=[lat, lon, time2],
                dims=["lat", "lon", "time"],
            ),
            "string_var": xr.DataArray(
                string_var_to_append, coords=[time2], dims=["time"]
            ),
            "string_var_fixed_length": xr.DataArray(
                string_var_fixed_length_to_append, coords=[time2], dims=["time"]
            ),
            "unicode_var": xr.DataArray(
                unicode_var[:nt2], coords=[time2], dims=["time"]
            ).astype(np.unicode_),
            "datetime_var": xr.DataArray(
                datetime_var_to_append, coords=[time2], dims=["time"]
            ),
            "bool_var": xr.DataArray(bool_var_to_append, coords=[time2], dims=["time"]),
        }
    )

    ds_with_new_var = xr.Dataset(
        data_vars={
            "new_var": xr.DataArray(
                rs.rand(3, 3, nt1 + nt2),
                coords=[lat, lon, time1.append(time2)],
                dims=["lat", "lon", "time"],
            )
        }
    )

    assert all(objp.data.flags.writeable for objp in ds.variables.values())
    assert all(objp.data.flags.writeable for objp in ds_to_append.variables.values())
    return ds, ds_to_append, ds_with_new_var


def create_append_string_length_mismatch_test_data(dtype) -> tuple[Dataset, Dataset]:
    def make_datasets(data, data_to_append) -> tuple[Dataset, Dataset]:
        ds = xr.Dataset(
            {"temperature": (["time"], data)},
            coords={"time": [0, 1, 2]},
        )
        ds_to_append = xr.Dataset(
            {"temperature": (["time"], data_to_append)}, coords={"time": [0, 1, 2]}
        )
        assert all(objp.data.flags.writeable for objp in ds.variables.values())
        assert all(
            objp.data.flags.writeable for objp in ds_to_append.variables.values()
        )
        return ds, ds_to_append

    u2_strings = ["ab", "cd", "ef"]
    u5_strings = ["abc", "def", "ghijk"]

    s2_strings = np.array(["aa", "bb", "cc"], dtype="|S2")
    s3_strings = np.array(["aaa", "bbb", "ccc"], dtype="|S3")

    if dtype == "U":
        return make_datasets(u2_strings, u5_strings)
    elif dtype == "S":
        return make_datasets(s2_strings, s3_strings)
    else:
        raise ValueError(f"unsupported dtype {dtype}.")


def create_test_multiindex() -> Dataset:
    mindex = pd.MultiIndex.from_product(
        [["a", "b"], [1, 2]], names=("level_1", "level_2")
    )
    return Dataset({}, {"x": mindex})


def create_test_stacked_array() -> tuple[DataArray, DataArray]:
    x = DataArray(pd.Index(np.r_[:10], name="x"))
    y = DataArray(pd.Index(np.r_[:20], name="y"))
    a = x * y
    b = x * y * y
    return a, b


class InaccessibleVariableDataStore(backends.InMemoryDataStore):
    def __init__(self):
        super().__init__()
        self._indexvars = set()

    def store(self, variables, *args, **kwargs) -> None:
        super().store(variables, *args, **kwargs)
        for k, v in variables.items():
            if isinstance(v, IndexVariable):
                self._indexvars.add(k)

    def get_variables(self):
        def lazy_inaccessible(k, v):
            if k in self._indexvars:
                return v
            data = indexing.LazilyIndexedArray(InaccessibleArray(v.values))
            return Variable(v.dims, data, v.attrs)

        return {k: lazy_inaccessible(k, v) for k, v in self._variables.items()}


class TestDataset:
    def test_repr(self) -> None:
        data = create_test_data(seed=123)
        data.attrs["foo"] = "bar"
        # need to insert str dtype at runtime to handle different endianness
        expected = dedent(
            """\
            <xarray.Dataset>
            Dimensions:  (dim2: 9, dim3: 10, time: 20, dim1: 8)
            Coordinates:
              * dim2     (dim2) float64 0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0
              * dim3     (dim3) %s 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j'
              * time     (time) datetime64[ns] 2000-01-01 2000-01-02 ... 2000-01-20
                numbers  (dim3) int64 0 1 2 0 0 1 1 2 2 3
            Dimensions without coordinates: dim1
            Data variables:
                var1     (dim1, dim2) float64 -1.086 0.9973 0.283 ... 0.1995 0.4684 -0.8312
                var2     (dim1, dim2) float64 1.162 -1.097 -2.123 ... 0.1302 1.267 0.3328
                var3     (dim3, dim1) float64 0.5565 -0.2121 0.4563 ... -0.2452 -0.3616
            Attributes:
                foo:      bar"""
            % data["dim3"].dtype
        )
        actual = "\n".join(x.rstrip() for x in repr(data).split("\n"))
        print(actual)
        assert expected == actual

        with set_options(display_width=100):
            max_len = max(map(len, repr(data).split("\n")))
            assert 90 < max_len < 100

        expected = dedent(
            """\
            <xarray.Dataset>
            Dimensions:  ()
            Data variables:
                *empty*"""
        )
        actual = "\n".join(x.rstrip() for x in repr(Dataset()).split("\n"))
        print(actual)
        assert expected == actual

        # verify that ... doesn't appear for scalar coordinates
        data = Dataset({"foo": ("x", np.ones(10))}).mean()
        expected = dedent(
            """\
            <xarray.Dataset>
            Dimensions:  ()
            Data variables:
                foo      float64 1.0"""
        )
        actual = "\n".join(x.rstrip() for x in repr(data).split("\n"))
        print(actual)
        assert expected == actual

        # verify long attributes are truncated
        data = Dataset(attrs={"foo": "bar" * 1000})
        assert len(repr(data)) < 1000

    def test_repr_multiindex(self) -> None:
        data = create_test_multiindex()
        expected = dedent(
            """\
            <xarray.Dataset>
            Dimensions:  (x: 4)
            Coordinates:
              * x        (x) object MultiIndex
              * level_1  (x) object 'a' 'a' 'b' 'b'
              * level_2  (x) int64 1 2 1 2
            Data variables:
                *empty*"""
        )
        actual = "\n".join(x.rstrip() for x in repr(data).split("\n"))
        print(actual)
        assert expected == actual

        # verify that long level names are not truncated
        mindex = pd.MultiIndex.from_product(
            [["a", "b"], [1, 2]], names=("a_quite_long_level_name", "level_2")
        )
        data = Dataset({}, {"x": mindex})
        expected = dedent(
            """\
            <xarray.Dataset>
            Dimensions:                  (x: 4)
            Coordinates:
              * x                        (x) object MultiIndex
              * a_quite_long_level_name  (x) object 'a' 'a' 'b' 'b'
              * level_2                  (x) int64 1 2 1 2
            Data variables:
                *empty*"""
        )
        actual = "\n".join(x.rstrip() for x in repr(data).split("\n"))
        print(actual)
        assert expected == actual

    def test_repr_period_index(self) -> None:
        data = create_test_data(seed=456)
        data.coords["time"] = pd.period_range("2000-01-01", periods=20, freq="B")

        # check that creating the repr doesn't raise an error #GH645
        repr(data)

    def test_unicode_data(self) -> None:
        # regression test for GH834
        data = Dataset({"foø": ["ba®"]}, attrs={"å": "∑"})
        repr(data)  # should not raise

        byteorder = "<" if sys.byteorder == "little" else ">"
        expected = dedent(
            """\
            <xarray.Dataset>
            Dimensions:  (foø: 1)
            Coordinates:
              * foø      (foø) %cU3 %r
            Data variables:
                *empty*
            Attributes:
                å:        ∑"""
            % (byteorder, "ba®")
        )
        actual = str(data)
        assert expected == actual

    def test_repr_nep18(self) -> None:
        class Array:
            def __init__(self):
                self.shape = (2,)
                self.dtype = np.dtype(np.float64)

            def __array_function__(self, *args, **kwargs):
                pass

            def __repr__(self):
                return "Custom\nArray"

        dataset = Dataset({"foo": ("x", Array())})
        expected = dedent(
            """\
            <xarray.Dataset>
            Dimensions:  (x: 2)
            Dimensions without coordinates: x
            Data variables:
                foo      (x) float64 Custom Array"""
        )
        assert expected == repr(dataset)

    def test_info(self) -> None:
        ds = create_test_data(seed=123)
        ds = ds.drop_vars("dim3")  # string type prints differently in PY2 vs PY3
        ds.attrs["unicode_attr"] = "ba®"
        ds.attrs["string_attr"] = "bar"

        buf = StringIO()
        ds.info(buf=buf)

        expected = dedent(
            """\
        xarray.Dataset {
        dimensions:
        \tdim2 = 9 ;
        \ttime = 20 ;
        \tdim1 = 8 ;
        \tdim3 = 10 ;

        variables:
        \tfloat64 dim2(dim2) ;
        \tdatetime64[ns] time(time) ;
        \tfloat64 var1(dim1, dim2) ;
        \t\tvar1:foo = variable ;
        \tfloat64 var2(dim1, dim2) ;
        \t\tvar2:foo = variable ;
        \tfloat64 var3(dim3, dim1) ;
        \t\tvar3:foo = variable ;
        \tint64 numbers(dim3) ;

        // global attributes:
        \t:unicode_attr = ba® ;
        \t:string_attr = bar ;
        }"""
        )
        actual = buf.getvalue()
        assert expected == actual
        buf.close()

    def test_constructor(self) -> None:
        x1 = ("x", 2 * np.arange(100))
        x2 = ("x", np.arange(1000))
        z = (["x", "y"], np.arange(1000).reshape(100, 10))

        with pytest.raises(ValueError, match=r"conflicting sizes"):
            Dataset({"a": x1, "b": x2})
        with pytest.raises(ValueError, match=r"disallows such variables"):
            Dataset({"a": x1, "x": z})
        with pytest.raises(TypeError, match=r"tuple of form"):
            Dataset({"x": (1, 2, 3, 4, 5, 6, 7)})
        with pytest.raises(ValueError, match=r"already exists as a scalar"):
            Dataset({"x": 0, "y": ("x", [1, 2, 3])})

        # verify handling of DataArrays
        expected = Dataset({"x": x1, "z": z})
        actual = Dataset({"z": expected["z"]})
        assert_identical(expected, actual)

    def test_constructor_invalid_dims(self) -> None:
        # regression for GH1120
        with pytest.raises(MergeError):
            Dataset(
                data_vars=dict(v=("y", [1, 2, 3, 4])),
                coords=dict(y=DataArray([0.1, 0.2, 0.3, 0.4], dims="x")),
            )

    def test_constructor_1d(self) -> None:
        expected = Dataset({"x": (["x"], 5.0 + np.arange(5))})
        actual = Dataset({"x": 5.0 + np.arange(5)})
        assert_identical(expected, actual)

        actual = Dataset({"x": [5, 6, 7, 8, 9]})
        assert_identical(expected, actual)

    def test_constructor_0d(self) -> None:
        expected = Dataset({"x": ([], 1)})
        for arg in [1, np.array(1), expected["x"]]:
            actual = Dataset({"x": arg})
            assert_identical(expected, actual)

        class Arbitrary:
            pass

        d = pd.Timestamp("2000-01-01T12")
        args = [
            True,
            None,
            3.4,
            np.nan,
            "hello",
            b"raw",
            np.datetime64("2000-01-01"),
            d,
            d.to_pydatetime(),
            Arbitrary(),
        ]
        for arg in args:
            print(arg)
            expected = Dataset({"x": ([], arg)})
            actual = Dataset({"x": arg})
            assert_identical(expected, actual)

    def test_constructor_auto_align(self) -> None:
        a = DataArray([1, 2], [("x", [0, 1])])
        b = DataArray([3, 4], [("x", [1, 2])])

        # verify align uses outer join
        expected = Dataset(
            {"a": ("x", [1, 2, np.nan]), "b": ("x", [np.nan, 3, 4])}, {"x": [0, 1, 2]}
        )
        actual = Dataset({"a": a, "b": b})
        assert_identical(expected, actual)

        # regression test for GH346
        assert isinstance(actual.variables["x"], IndexVariable)

        # variable with different dimensions
        c = ("y", [3, 4])
        expected2 = expected.merge({"c": c})
        actual = Dataset({"a": a, "b": b, "c": c})
        assert_identical(expected2, actual)

        # variable that is only aligned against the aligned variables
        d = ("x", [3, 2, 1])
        expected3 = expected.merge({"d": d})
        actual = Dataset({"a": a, "b": b, "d": d})
        assert_identical(expected3, actual)

        e = ("x", [0, 0])
        with pytest.raises(ValueError, match=r"conflicting sizes"):
            Dataset({"a": a, "b": b, "e": e})

    def test_constructor_pandas_sequence(self) -> None:

        ds = self.make_example_math_dataset()
        pandas_objs = {
            var_name: ds[var_name].to_pandas() for var_name in ["foo", "bar"]
        }
        ds_based_on_pandas = Dataset(pandas_objs, ds.coords, attrs=ds.attrs)
        del ds_based_on_pandas["x"]
        assert_equal(ds, ds_based_on_pandas)

        # reindex pandas obj, check align works
        rearranged_index = reversed(pandas_objs["foo"].index)
        pandas_objs["foo"] = pandas_objs["foo"].reindex(rearranged_index)
        ds_based_on_pandas = Dataset(pandas_objs, ds.coords, attrs=ds.attrs)
        del ds_based_on_pandas["x"]
        assert_equal(ds, ds_based_on_pandas)

    def test_constructor_pandas_single(self) -> None:

        das = [
            DataArray(np.random.rand(4), dims=["a"]),  # series
            DataArray(np.random.rand(4, 3), dims=["a", "b"]),  # df
        ]

        for a in das:
            pandas_obj = a.to_pandas()
            ds_based_on_pandas = Dataset(pandas_obj)  # type: ignore  # TODO: improve typing of __init__
            for dim in ds_based_on_pandas.data_vars:
                assert_array_equal(ds_based_on_pandas[dim], pandas_obj[dim])

    def test_constructor_compat(self) -> None:
        data = {"x": DataArray(0, coords={"y": 1}), "y": ("z", [1, 1, 1])}
        expected = Dataset({"x": 0}, {"y": ("z", [1, 1, 1])})
        actual = Dataset(data)
        assert_identical(expected, actual)

        data = {"y": ("z", [1, 1, 1]), "x": DataArray(0, coords={"y": 1})}
        actual = Dataset(data)
        assert_identical(expected, actual)

        original = Dataset(
            {"a": (("x", "y"), np.ones((2, 3)))},
            {"c": (("x", "y"), np.zeros((2, 3))), "x": [0, 1]},
        )
        expected = Dataset(
            {"a": ("x", np.ones(2)), "b": ("y", np.ones(3))},
            {"c": (("x", "y"), np.zeros((2, 3))), "x": [0, 1]},
        )

        actual = Dataset(
            {"a": original["a"][:, 0], "b": original["a"][0].drop_vars("x")}
        )
        assert_identical(expected, actual)

        data = {"x": DataArray(0, coords={"y": 3}), "y": ("z", [1, 1, 1])}
        with pytest.raises(MergeError):
            Dataset(data)

        data = {"x": DataArray(0, coords={"y": 1}), "y": [1, 1]}
        actual = Dataset(data)
        expected = Dataset({"x": 0}, {"y": [1, 1]})
        assert_identical(expected, actual)

    def test_constructor_with_coords(self) -> None:
        with pytest.raises(ValueError, match=r"found in both data_vars and"):
            Dataset({"a": ("x", [1])}, {"a": ("x", [1])})

        ds = Dataset({}, {"a": ("x", [1])})
        assert not ds.data_vars
        assert list(ds.coords.keys()) == ["a"]

        mindex = pd.MultiIndex.from_product(
            [["a", "b"], [1, 2]], names=("level_1", "level_2")
        )
        with pytest.raises(ValueError, match=r"conflicting MultiIndex"):
            Dataset({}, {"x": mindex, "y": mindex})
            Dataset({}, {"x": mindex, "level_1": range(4)})

    def test_properties(self) -> None:
        ds = create_test_data()

        # dims / sizes
        # These exact types aren't public API, but this makes sure we don't
        # change them inadvertently:
        assert isinstance(ds.dims, utils.Frozen)
        assert isinstance(ds.dims.mapping, dict)
        assert type(ds.dims.mapping) is dict
        assert ds.dims == {"dim1": 8, "dim2": 9, "dim3": 10, "time": 20}
        assert ds.sizes == ds.dims

        # dtypes
        assert isinstance(ds.dtypes, utils.Frozen)
        assert isinstance(ds.dtypes.mapping, dict)
        assert ds.dtypes == {
            "var1": np.dtype("float64"),
            "var2": np.dtype("float64"),
            "var3": np.dtype("float64"),
        }

        # data_vars
        assert list(ds) == list(ds.data_vars)
        assert list(ds.keys()) == list(ds.data_vars)
        assert "aasldfjalskdfj" not in ds.variables
        assert "dim1" in repr(ds.variables)
        assert len(ds) == 3
        assert bool(ds)

        assert list(ds.data_vars) == ["var1", "var2", "var3"]
        assert list(ds.data_vars.keys()) == ["var1", "var2", "var3"]
        assert "var1" in ds.data_vars
        assert "dim1" not in ds.data_vars
        assert "numbers" not in ds.data_vars
        assert len(ds.data_vars) == 3

        # xindexes
        assert set(ds.xindexes) == {"dim2", "dim3", "time"}
        assert len(ds.xindexes) == 3
        assert "dim2" in repr(ds.xindexes)
        assert all([isinstance(idx, Index) for idx in ds.xindexes.values()])

        # indexes
        assert set(ds.indexes) == {"dim2", "dim3", "time"}
        assert len(ds.indexes) == 3
        assert "dim2" in repr(ds.indexes)
        assert all([isinstance(idx, pd.Index) for idx in ds.indexes.values()])

        # coords
        assert list(ds.coords) == ["dim2", "dim3", "time", "numbers"]
        assert "dim2" in ds.coords
        assert "numbers" in ds.coords
        assert "var1" not in ds.coords
        assert "dim1" not in ds.coords
        assert len(ds.coords) == 4

        # nbytes
        assert (
            Dataset({"x": np.int64(1), "y": np.array([1, 2], dtype=np.float32)}).nbytes
            == 16
        )

    def test_asarray(self) -> None:
        ds = Dataset({"x": 0})
        with pytest.raises(TypeError, match=r"cannot directly convert"):
            np.asarray(ds)

    def test_get_index(self) -> None:
        ds = Dataset({"foo": (("x", "y"), np.zeros((2, 3)))}, coords={"x": ["a", "b"]})
        assert ds.get_index("x").equals(pd.Index(["a", "b"]))
        assert ds.get_index("y").equals(pd.Index([0, 1, 2]))
        with pytest.raises(KeyError):
            ds.get_index("z")

    def test_attr_access(self) -> None:
        ds = Dataset(
            {"tmin": ("x", [42], {"units": "Celsius"})}, attrs={"title": "My test data"}
        )
        assert_identical(ds.tmin, ds["tmin"])
        assert_identical(ds.tmin.x, ds.x)

        assert ds.title == ds.attrs["title"]
        assert ds.tmin.units == ds["tmin"].attrs["units"]

        assert {"tmin", "title"} <= set(dir(ds))
        assert "units" in set(dir(ds.tmin))

        # should defer to variable of same name
        ds.attrs["tmin"] = -999
        assert ds.attrs["tmin"] == -999
        assert_identical(ds.tmin, ds["tmin"])

    def test_variable(self) -> None:
        a = Dataset()
        d = np.random.random((10, 3))
        a["foo"] = (("time", "x"), d)
        assert "foo" in a.variables
        assert "foo" in a
        a["bar"] = (("time", "x"), d)
        # order of creation is preserved
        assert list(a.variables) == ["foo", "bar"]
        assert_array_equal(a["foo"].values, d)
        # try to add variable with dim (10,3) with data that's (3,10)
        with pytest.raises(ValueError):
            a["qux"] = (("time", "x"), d.T)

    def test_modify_inplace(self) -> None:
        a = Dataset()
        vec = np.random.random((10,))
        attributes = {"foo": "bar"}
        a["x"] = ("x", vec, attributes)
        assert "x" in a.coords
        assert isinstance(a.coords["x"].to_index(), pd.Index)
        assert_identical(a.coords["x"].variable, a.variables["x"])
        b = Dataset()
        b["x"] = ("x", vec, attributes)
        assert_identical(a["x"], b["x"])
        assert a.dims == b.dims
        # this should work
        a["x"] = ("x", vec[:5])
        a["z"] = ("x", np.arange(5))
        with pytest.raises(ValueError):
            # now it shouldn't, since there is a conflicting length
            a["x"] = ("x", vec[:4])
        arr = np.random.random((10, 1))
        scal = np.array(0)
        with pytest.raises(ValueError):
            a["y"] = ("y", arr)
        with pytest.raises(ValueError):
            a["y"] = ("y", scal)
        assert "y" not in a.dims

    def test_coords_properties(self) -> None:
        # use int64 for repr consistency on windows
        data = Dataset(
            {
                "x": ("x", np.array([-1, -2], "int64")),
                "y": ("y", np.array([0, 1, 2], "int64")),
                "foo": (["x", "y"], np.random.randn(2, 3)),
            },
            {"a": ("x", np.array([4, 5], "int64")), "b": np.int64(-10)},
        )

        coords = data.coords
        assert isinstance(coords, DatasetCoordinates)

        # len
        assert len(coords) == 4

        # iter
        assert list(coords) == ["x", "y", "a", "b"]

        assert_identical(coords["x"].variable, data["x"].variable)
        assert_identical(coords["y"].variable, data["y"].variable)

        assert "x" in coords
        assert "a" in coords
        assert 0 not in coords
        assert "foo" not in coords

        with pytest.raises(KeyError):
            coords["foo"]
        with pytest.raises(KeyError):
            coords[0]

        # repr
        expected = dedent(
            """\
        Coordinates:
          * x        (x) int64 -1 -2
          * y        (y) int64 0 1 2
            a        (x) int64 4 5
            b        int64 -10"""
        )
        actual = repr(coords)
        assert expected == actual

        # dims
        assert coords.dims == {"x": 2, "y": 3}

        # dtypes
        assert coords.dtypes == {
            "x": np.dtype("int64"),
            "y": np.dtype("int64"),
            "a": np.dtype("int64"),
            "b": np.dtype("int64"),
        }

    def test_coords_modify(self) -> None:
        data = Dataset(
            {
                "x": ("x", [-1, -2]),
                "y": ("y", [0, 1, 2]),
                "foo": (["x", "y"], np.random.randn(2, 3)),
            },
            {"a": ("x", [4, 5]), "b": -10},
        )

        actual = data.copy(deep=True)
        actual.coords["x"] = ("x", ["a", "b"])
        assert_array_equal(actual["x"], ["a", "b"])

        actual = data.copy(deep=True)
        actual.coords["z"] = ("z", ["a", "b"])
        assert_array_equal(actual["z"], ["a", "b"])

        actual = data.copy(deep=True)
        with pytest.raises(ValueError, match=r"conflicting sizes"):
            actual.coords["x"] = ("x", [-1])
        assert_identical(actual, data)  # should not be modified

        actual = data.copy()
        del actual.coords["b"]
        expected = data.reset_coords("b", drop=True)
        assert_identical(expected, actual)

        with pytest.raises(KeyError):
            del data.coords["not_found"]

        with pytest.raises(KeyError):
            del data.coords["foo"]

        actual = data.copy(deep=True)
        actual.coords.update({"c": 11})
        expected = data.merge({"c": 11}).set_coords("c")
        assert_identical(expected, actual)

        # regression test for GH3746
        del actual.coords["x"]
        assert "x" not in actual.xindexes

    def test_update_index(self) -> None:
        actual = Dataset(coords={"x": [1, 2, 3]})
        actual["x"] = ["a", "b", "c"]
        assert actual.xindexes["x"].to_pandas_index().equals(pd.Index(["a", "b", "c"]))

    def test_coords_setitem_with_new_dimension(self) -> None:
        actual = Dataset()
        actual.coords["foo"] = ("x", [1, 2, 3])
        expected = Dataset(coords={"foo": ("x", [1, 2, 3])})
        assert_identical(expected, actual)

    def test_coords_setitem_multiindex(self) -> None:
        data = create_test_multiindex()
        with pytest.raises(
            ValueError, match=r"cannot set or update variable.*corrupt.*index "
        ):
            data.coords["level_1"] = range(4)

    def test_coords_set(self) -> None:
        one_coord = Dataset({"x": ("x", [0]), "yy": ("x", [1]), "zzz": ("x", [2])})
        two_coords = Dataset({"zzz": ("x", [2])}, {"x": ("x", [0]), "yy": ("x", [1])})
        all_coords = Dataset(
            coords={"x": ("x", [0]), "yy": ("x", [1]), "zzz": ("x", [2])}
        )

        actual = one_coord.set_coords("x")
        assert_identical(one_coord, actual)
        actual = one_coord.set_coords(["x"])
        assert_identical(one_coord, actual)

        actual = one_coord.set_coords("yy")
        assert_identical(two_coords, actual)

        actual = one_coord.set_coords(["yy", "zzz"])
        assert_identical(all_coords, actual)

        actual = one_coord.reset_coords()
        assert_identical(one_coord, actual)
        actual = two_coords.reset_coords()
        assert_identical(one_coord, actual)
        actual = all_coords.reset_coords()
        assert_identical(one_coord, actual)

        actual = all_coords.reset_coords(["yy", "zzz"])
        assert_identical(one_coord, actual)
        actual = all_coords.reset_coords("zzz")
        assert_identical(two_coords, actual)

        with pytest.raises(ValueError, match=r"cannot remove index"):
            one_coord.reset_coords("x")

        actual = all_coords.reset_coords("zzz", drop=True)
        expected = all_coords.drop_vars("zzz")
        assert_identical(expected, actual)
        expected = two_coords.drop_vars("zzz")
        assert_identical(expected, actual)

    def test_coords_to_dataset(self) -> None:
        orig = Dataset({"foo": ("y", [-1, 0, 1])}, {"x": 10, "y": [2, 3, 4]})
        expected = Dataset(coords={"x": 10, "y": [2, 3, 4]})
        actual = orig.coords.to_dataset()
        assert_identical(expected, actual)

    def test_coords_merge(self) -> None:
        orig_coords = Dataset(coords={"a": ("x", [1, 2]), "x": [0, 1]}).coords
        other_coords = Dataset(coords={"b": ("x", ["a", "b"]), "x": [0, 1]}).coords
        expected = Dataset(
            coords={"a": ("x", [1, 2]), "b": ("x", ["a", "b"]), "x": [0, 1]}
        )
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)
        actual = other_coords.merge(orig_coords)
        assert_identical(expected, actual)

        other_coords = Dataset(coords={"x": ("x", ["a"])}).coords
        with pytest.raises(MergeError):
            orig_coords.merge(other_coords)
        other_coords = Dataset(coords={"x": ("x", ["a", "b"])}).coords
        with pytest.raises(MergeError):
            orig_coords.merge(other_coords)
        other_coords = Dataset(coords={"x": ("x", ["a", "b", "c"])}).coords
        with pytest.raises(MergeError):
            orig_coords.merge(other_coords)

        other_coords = Dataset(coords={"a": ("x", [8, 9])}).coords
        expected = Dataset(coords={"x": range(2)})
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)
        actual = other_coords.merge(orig_coords)
        assert_identical(expected, actual)

        other_coords = Dataset(coords={"x": np.nan}).coords
        actual = orig_coords.merge(other_coords)
        assert_identical(orig_coords.to_dataset(), actual)
        actual = other_coords.merge(orig_coords)
        assert_identical(orig_coords.to_dataset(), actual)

    def test_coords_merge_mismatched_shape(self) -> None:
        orig_coords = Dataset(coords={"a": ("x", [1, 1])}).coords
        other_coords = Dataset(coords={"a": 1}).coords
        expected = orig_coords.to_dataset()
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)

        other_coords = Dataset(coords={"a": ("y", [1])}).coords
        expected = Dataset(coords={"a": (["x", "y"], [[1], [1]])})
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)

        actual = other_coords.merge(orig_coords)
        assert_identical(expected.transpose(), actual)

        orig_coords = Dataset(coords={"a": ("x", [np.nan])}).coords
        other_coords = Dataset(coords={"a": np.nan}).coords
        expected = orig_coords.to_dataset()
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)

    def test_data_vars_properties(self) -> None:
        ds = Dataset()
        ds["foo"] = (("x",), [1.0])
        ds["bar"] = 2.0

        # iter
        assert set(ds.data_vars) == {"foo", "bar"}
        assert "foo" in ds.data_vars
        assert "x" not in ds.data_vars
        assert_identical(ds["foo"], ds.data_vars["foo"])

        # repr
        expected = dedent(
            """\
        Data variables:
            foo      (x) float64 1.0
            bar      float64 2.0"""
        )
        actual = repr(ds.data_vars)
        assert expected == actual

        # dtypes
        assert ds.data_vars.dtypes == {
            "foo": np.dtype("float64"),
            "bar": np.dtype("float64"),
        }

    def test_equals_and_identical(self) -> None:
        data = create_test_data(seed=42)
        assert data.equals(data)
        assert data.identical(data)

        data2 = create_test_data(seed=42)
        data2.attrs["foobar"] = "baz"
        assert data.equals(data2)
        assert not data.identical(data2)

        del data2["time"]
        assert not data.equals(data2)

        data = create_test_data(seed=42).rename({"var1": None})
        assert data.equals(data)
        assert data.identical(data)

        data2 = data.reset_coords()
        assert not data2.equals(data)
        assert not data2.identical(data)

    def test_equals_failures(self) -> None:
        data = create_test_data()
        assert not data.equals("foo")
        assert not data.identical(123)
        assert not data.broadcast_equals({1: 2})

    def test_broadcast_equals(self) -> None:
        data1 = Dataset(coords={"x": 0})
        data2 = Dataset(coords={"x": [0]})
        assert data1.broadcast_equals(data2)
        assert not data1.equals(data2)
        assert not data1.identical(data2)

    def test_attrs(self) -> None:
        data = create_test_data(seed=42)
        data.attrs = {"foobar": "baz"}
        assert data.attrs["foobar"], "baz"
        assert isinstance(data.attrs, dict)

    def test_chunks_does_not_load_data(self) -> None:
        # regression test for GH6538
        store = InaccessibleVariableDataStore()
        create_test_data().dump_to_store(store)
        ds = open_dataset(store)
        assert ds.chunks == {}

    @requires_dask
    def test_chunk(self) -> None:
        data = create_test_data()
        for v in data.variables.values():
            assert isinstance(v.data, np.ndarray)
        assert data.chunks == {}

        reblocked = data.chunk()
        for k, v in reblocked.variables.items():
            if k in reblocked.dims:
                assert isinstance(v.data, np.ndarray)
            else:
                assert isinstance(v.data, da.Array)

        expected_chunks: dict[Hashable, tuple[int, ...]] = {
            "dim1": (8,),
            "dim2": (9,),
            "dim3": (10,),
        }
        assert reblocked.chunks == expected_chunks

        # test kwargs form of chunks
        assert data.chunk(**expected_chunks).chunks == expected_chunks

        def get_dask_names(ds):
            return {k: v.data.name for k, v in ds.items()}

        orig_dask_names = get_dask_names(reblocked)

        reblocked = data.chunk({"time": 5, "dim1": 5, "dim2": 5, "dim3": 5})
        # time is not a dim in any of the data_vars, so it
        # doesn't get chunked
        expected_chunks = {"dim1": (5, 3), "dim2": (5, 4), "dim3": (5, 5)}
        assert reblocked.chunks == expected_chunks

        # make sure dask names change when rechunking by different amounts
        # regression test for GH3350
        new_dask_names = get_dask_names(reblocked)
        for k, v in new_dask_names.items():
            assert v != orig_dask_names[k]

        reblocked = data.chunk(expected_chunks)
        assert reblocked.chunks == expected_chunks

        # reblock on already blocked data
        orig_dask_names = get_dask_names(reblocked)
        reblocked = reblocked.chunk(expected_chunks)
        new_dask_names = get_dask_names(reblocked)
        assert reblocked.chunks == expected_chunks
        assert_identical(reblocked, data)
        # rechunking with same chunk sizes should not change names
        for k, v in new_dask_names.items():
            assert v == orig_dask_names[k]

        with pytest.raises(ValueError, match=r"some chunks"):
            data.chunk({"foo": 10})

    @requires_dask
    def test_dask_is_lazy(self) -> None:
        store = InaccessibleVariableDataStore()
        create_test_data().dump_to_store(store)
        ds = open_dataset(store).chunk()

        with pytest.raises(UnexpectedDataAccess):
            ds.load()
        with pytest.raises(UnexpectedDataAccess):
            ds["var1"].values

        # these should not raise UnexpectedDataAccess:
        ds.var1.data
        ds.isel(time=10)
        ds.isel(time=slice(10), dim1=[0]).isel(dim1=0, dim2=-1)
        ds.transpose()
        ds.mean()
        ds.fillna(0)
        ds.rename({"dim1": "foobar"})
        ds.set_coords("var1")
        ds.drop_vars("var1")

    def test_isel(self) -> None:
        data = create_test_data()
        slicers = {"dim1": slice(None, None, 2), "dim2": slice(0, 2)}
        ret = data.isel(**slicers)

        # Verify that only the specified dimension was altered
        assert list(data.dims) == list(ret.dims)
        for d in data.dims:
            if d in slicers:
                assert ret.dims[d] == np.arange(data.dims[d])[slicers[d]].size
            else:
                assert data.dims[d] == ret.dims[d]
        # Verify that the data is what we expect
        for v in data.variables:
            assert data[v].dims == ret[v].dims
            assert data[v].attrs == ret[v].attrs
            slice_list = [slice(None)] * data[v].values.ndim
            for d, s in slicers.items():
                if d in data[v].dims:
                    inds = np.nonzero(np.array(data[v].dims) == d)[0]
                    for ind in inds:
                        slice_list[ind] = s
            expected = data[v].values[tuple(slice_list)]
            actual = ret[v].values
            np.testing.assert_array_equal(expected, actual)

        with pytest.raises(ValueError):
            data.isel(not_a_dim=slice(0, 2))
        with pytest.raises(
            ValueError,
            match=r"Dimensions {'not_a_dim'} do not exist. Expected "
            r"one or more of "
            r"[\w\W]*'dim\d'[\w\W]*'dim\d'[\w\W]*'time'[\w\W]*'dim\d'[\w\W]*",
        ):
            data.isel(not_a_dim=slice(0, 2))
        with pytest.warns(
            UserWarning,
            match=r"Dimensions {'not_a_dim'} do not exist. "
            r"Expected one or more of "
            r"[\w\W]*'dim\d'[\w\W]*'dim\d'[\w\W]*'time'[\w\W]*'dim\d'[\w\W]*",
        ):
            data.isel(not_a_dim=slice(0, 2), missing_dims="warn")
        assert_identical(data, data.isel(not_a_dim=slice(0, 2), missing_dims="ignore"))

        ret = data.isel(dim1=0)
        assert {"time": 20, "dim2": 9, "dim3": 10} == ret.dims
        assert set(data.data_vars) == set(ret.data_vars)
        assert set(data.coords) == set(ret.coords)
        assert set(data.xindexes) == set(ret.xindexes)

        ret = data.isel(time=slice(2), dim1=0, dim2=slice(5))
        assert {"time": 2, "dim2": 5, "dim3": 10} == ret.dims
        assert set(data.data_vars) == set(ret.data_vars)
        assert set(data.coords) == set(ret.coords)
        assert set(data.xindexes) == set(ret.xindexes)

        ret = data.isel(time=0, dim1=0, dim2=slice(5))
        assert {"dim2": 5, "dim3": 10} == ret.dims
        assert set(data.data_vars) == set(ret.data_vars)
        assert set(data.coords) == set(ret.coords)
        assert set(data.xindexes) == set(list(ret.xindexes) + ["time"])

    def test_isel_fancy(self) -> None:
        # isel with fancy indexing.
        data = create_test_data()

        pdim1 = [1, 2, 3]
        pdim2 = [4, 5, 1]
        pdim3 = [1, 2, 3]
        actual = data.isel(
            dim1=(("test_coo
```


# xarray/tests/test_indexes.py

```
from __future__ import annotations

import copy
from typing import Any

import numpy as np
import pandas as pd
import pytest

import xarray as xr
from xarray.core.indexes import (
    Hashable,
    Index,
    Indexes,
    PandasIndex,
    PandasMultiIndex,
    _asarray_tuplesafe,
)
from xarray.core.variable import IndexVariable, Variable

from . import assert_identical


def test_asarray_tuplesafe() -> None:
    res = _asarray_tuplesafe(("a", 1))
    assert isinstance(res, np.ndarray)
    assert res.ndim == 0
    assert res.item() == ("a", 1)

    res = _asarray_tuplesafe([(0,), (1,)])
    assert res.shape == (2,)
    assert res[0] == (0,)
    assert res[1] == (1,)


class CustomIndex(Index):
    def __init__(self, dims) -> None:
        self.dims = dims


class TestIndex:
    @pytest.fixture
    def index(self) -> CustomIndex:
        return CustomIndex({"x": 2})

    def test_from_variables(self) -> None:
        with pytest.raises(NotImplementedError):
            Index.from_variables({})

    def test_concat(self) -> None:
        with pytest.raises(NotImplementedError):
            Index.concat([], "x")

    def test_stack(self) -> None:
        with pytest.raises(NotImplementedError):
            Index.stack({}, "x")

    def test_unstack(self, index) -> None:
        with pytest.raises(NotImplementedError):
            index.unstack()

    def test_create_variables(self, index) -> None:
        assert index.create_variables() == {}
        assert index.create_variables({"x": "var"}) == {"x": "var"}

    def test_to_pandas_index(self, index) -> None:
        with pytest.raises(TypeError):
            index.to_pandas_index()

    def test_isel(self, index) -> None:
        assert index.isel({}) is None

    def test_sel(self, index) -> None:
        with pytest.raises(NotImplementedError):
            index.sel({})

    def test_join(self, index) -> None:
        with pytest.raises(NotImplementedError):
            index.join(CustomIndex({"y": 2}))

    def test_reindex_like(self, index) -> None:
        with pytest.raises(NotImplementedError):
            index.reindex_like(CustomIndex({"y": 2}))

    def test_equals(self, index) -> None:
        with pytest.raises(NotImplementedError):
            index.equals(CustomIndex({"y": 2}))

    def test_roll(self, index) -> None:
        assert index.roll({}) is None

    def test_rename(self, index) -> None:
        assert index.rename({}, {}) is index

    @pytest.mark.parametrize("deep", [True, False])
    def test_copy(self, index, deep) -> None:
        copied = index.copy(deep=deep)
        assert isinstance(copied, CustomIndex)
        assert copied is not index

        copied.dims["x"] = 3
        if deep:
            assert copied.dims != index.dims
            assert copied.dims != copy.deepcopy(index).dims
        else:
            assert copied.dims is index.dims
            assert copied.dims is copy.copy(index).dims

    def test_getitem(self, index) -> None:
        with pytest.raises(NotImplementedError):
            index[:]


class TestPandasIndex:
    def test_constructor(self) -> None:
        pd_idx = pd.Index([1, 2, 3])
        index = PandasIndex(pd_idx, "x")

        assert index.index.equals(pd_idx)
        # makes a shallow copy
        assert index.index is not pd_idx
        assert index.dim == "x"

        # test no name set for pd.Index
        pd_idx.name = None
        index = PandasIndex(pd_idx, "x")
        assert index.index.name == "x"

    def test_from_variables(self) -> None:
        # pandas has only Float64Index but variable dtype should be preserved
        data = np.array([1.1, 2.2, 3.3], dtype=np.float32)
        var = xr.Variable(
            "x", data, attrs={"unit": "m"}, encoding={"dtype": np.float64}
        )

        index = PandasIndex.from_variables({"x": var})
        assert index.dim == "x"
        assert index.index.equals(pd.Index(data))
        assert index.coord_dtype == data.dtype

        var2 = xr.Variable(("x", "y"), [[1, 2, 3], [4, 5, 6]])
        with pytest.raises(ValueError, match=r".*only accepts one variable.*"):
            PandasIndex.from_variables({"x": var, "foo": var2})

        with pytest.raises(
            ValueError, match=r".*only accepts a 1-dimensional variable.*"
        ):
            PandasIndex.from_variables({"foo": var2})

    def test_from_variables_index_adapter(self) -> None:
        # test index type is preserved when variable wraps a pd.Index
        data = pd.Series(["foo", "bar"], dtype="category")
        pd_idx = pd.Index(data)
        var = xr.Variable("x", pd_idx)

        index = PandasIndex.from_variables({"x": var})
        assert isinstance(index.index, pd.CategoricalIndex)

    def test_concat_periods(self):
        periods = pd.period_range("2000-01-01", periods=10)
        indexes = [PandasIndex(periods[:5], "t"), PandasIndex(periods[5:], "t")]
        expected = PandasIndex(periods, "t")
        actual = PandasIndex.concat(indexes, dim="t")
        assert actual.equals(expected)
        assert isinstance(actual.index, pd.PeriodIndex)

        positions = [list(range(5)), list(range(5, 10))]
        actual = PandasIndex.concat(indexes, dim="t", positions=positions)
        assert actual.equals(expected)
        assert isinstance(actual.index, pd.PeriodIndex)

    @pytest.mark.parametrize("dtype", [str, bytes])
    def test_concat_str_dtype(self, dtype) -> None:

        a = PandasIndex(np.array(["a"], dtype=dtype), "x", coord_dtype=dtype)
        b = PandasIndex(np.array(["b"], dtype=dtype), "x", coord_dtype=dtype)
        expected = PandasIndex(
            np.array(["a", "b"], dtype=dtype), "x", coord_dtype=dtype
        )

        actual = PandasIndex.concat([a, b], "x")
        assert actual.equals(expected)
        assert np.issubdtype(actual.coord_dtype, dtype)

    def test_concat_empty(self) -> None:
        idx = PandasIndex.concat([], "x")
        assert idx.coord_dtype is np.dtype("O")

    def test_concat_dim_error(self) -> None:
        indexes = [PandasIndex([0, 1], "x"), PandasIndex([2, 3], "y")]

        with pytest.raises(ValueError, match=r"Cannot concatenate.*dimensions.*"):
            PandasIndex.concat(indexes, "x")

    def test_create_variables(self) -> None:
        # pandas has only Float64Index but variable dtype should be preserved
        data = np.array([1.1, 2.2, 3.3], dtype=np.float32)
        pd_idx = pd.Index(data, name="foo")
        index = PandasIndex(pd_idx, "x", coord_dtype=data.dtype)
        index_vars = {
            "foo": IndexVariable(
                "x", data, attrs={"unit": "m"}, encoding={"fill_value": 0.0}
            )
        }

        actual = index.create_variables(index_vars)
        assert_identical(actual["foo"], index_vars["foo"])
        assert actual["foo"].dtype == index_vars["foo"].dtype
        assert actual["foo"].dtype == index.coord_dtype

    def test_to_pandas_index(self) -> None:
        pd_idx = pd.Index([1, 2, 3], name="foo")
        index = PandasIndex(pd_idx, "x")
        assert index.to_pandas_index() is index.index

    def test_sel(self) -> None:
        # TODO: add tests that aren't just for edge cases
        index = PandasIndex(pd.Index([1, 2, 3]), "x")
        with pytest.raises(KeyError, match=r"not all values found"):
            index.sel({"x": [0]})
        with pytest.raises(KeyError):
            index.sel({"x": 0})
        with pytest.raises(ValueError, match=r"does not have a MultiIndex"):
            index.sel({"x": {"one": 0}})

    def test_sel_boolean(self) -> None:
        # index should be ignored and indexer dtype should not be coerced
        # see https://github.com/pydata/xarray/issues/5727
        index = PandasIndex(pd.Index([0.0, 2.0, 1.0, 3.0]), "x")
        actual = index.sel({"x": [False, True, False, True]})
        expected_dim_indexers = {"x": [False, True, False, True]}
        np.testing.assert_array_equal(
            actual.dim_indexers["x"], expected_dim_indexers["x"]
        )

    def test_sel_datetime(self) -> None:
        index = PandasIndex(
            pd.to_datetime(["2000-01-01", "2001-01-01", "2002-01-01"]), "x"
        )
        actual = index.sel({"x": "2001-01-01"})
        expected_dim_indexers = {"x": 1}
        assert actual.dim_indexers == expected_dim_indexers

        actual = index.sel({"x": index.to_pandas_index().to_numpy()[1]})
        assert actual.dim_indexers == expected_dim_indexers

    def test_sel_unsorted_datetime_index_raises(self) -> None:
        index = PandasIndex(pd.to_datetime(["2001", "2000", "2002"]), "x")
        with pytest.raises(KeyError):
            # pandas will try to convert this into an array indexer. We should
            # raise instead, so we can be sure the result of indexing with a
            # slice is always a view.
            index.sel({"x": slice("2001", "2002")})

    def test_equals(self) -> None:
        index1 = PandasIndex([1, 2, 3], "x")
        index2 = PandasIndex([1, 2, 3], "x")
        assert index1.equals(index2) is True

    def test_join(self) -> None:
        index1 = PandasIndex(["a", "aa", "aaa"], "x", coord_dtype="<U3")
        index2 = PandasIndex(["aa", "aaa", "aaaa"], "x", coord_dtype="<U4")

        expected = PandasIndex(["aa", "aaa"], "x")
        actual = index1.join(index2)
        print(actual.index)
        assert actual.equals(expected)
        assert actual.coord_dtype == "=U4"

        expected = PandasIndex(["a", "aa", "aaa", "aaaa"], "x")
        actual = index1.join(index2, how="outer")
        print(actual.index)
        assert actual.equals(expected)
        assert actual.coord_dtype == "=U4"

    def test_reindex_like(self) -> None:
        index1 = PandasIndex([0, 1, 2], "x")
        index2 = PandasIndex([1, 2, 3, 4], "x")

        expected = {"x": [1, 2, -1, -1]}
        actual = index1.reindex_like(index2)
        assert actual.keys() == expected.keys()
        np.testing.assert_array_equal(actual["x"], expected["x"])

        index3 = PandasIndex([1, 1, 2], "x")
        with pytest.raises(ValueError, match=r".*index has duplicate values"):
            index3.reindex_like(index2)

    def test_rename(self) -> None:
        index = PandasIndex(pd.Index([1, 2, 3], name="a"), "x", coord_dtype=np.int32)

        # shortcut
        new_index = index.rename({}, {})
        assert new_index is index

        new_index = index.rename({"a": "b"}, {})
        assert new_index.index.name == "b"
        assert new_index.dim == "x"
        assert new_index.coord_dtype == np.int32

        new_index = index.rename({}, {"x": "y"})
        assert new_index.index.name == "a"
        assert new_index.dim == "y"
        assert new_index.coord_dtype == np.int32

    def test_copy(self) -> None:
        expected = PandasIndex([1, 2, 3], "x", coord_dtype=np.int32)
        actual = expected.copy()

        assert actual.index.equals(expected.index)
        assert actual.index is not expected.index
        assert actual.dim == expected.dim
        assert actual.coord_dtype == expected.coord_dtype

    def test_getitem(self) -> None:
        pd_idx = pd.Index([1, 2, 3])
        expected = PandasIndex(pd_idx, "x", coord_dtype=np.int32)
        actual = expected[1:]

        assert actual.index.equals(pd_idx[1:])
        assert actual.dim == expected.dim
        assert actual.coord_dtype == expected.coord_dtype


class TestPandasMultiIndex:
    def test_constructor(self) -> None:
        foo_data = np.array([0, 0, 1], dtype="int64")
        bar_data = np.array([1.1, 1.2, 1.3], dtype="float64")
        pd_idx = pd.MultiIndex.from_arrays([foo_data, bar_data], names=("foo", "bar"))

        index = PandasMultiIndex(pd_idx, "x")

        assert index.dim == "x"
        assert index.index.equals(pd_idx)
        assert index.index.names == ("foo", "bar")
        assert index.index.name == "x"
        assert index.level_coords_dtype == {
            "foo": foo_data.dtype,
            "bar": bar_data.dtype,
        }

        with pytest.raises(ValueError, match=".*conflicting multi-index level name.*"):
            PandasMultiIndex(pd_idx, "foo")

        # default level names
        pd_idx = pd.MultiIndex.from_arrays([foo_data, bar_data])
        index = PandasMultiIndex(pd_idx, "x")
        assert index.index.names == ("x_level_0", "x_level_1")

    def test_from_variables(self) -> None:
        v_level1 = xr.Variable(
            "x", [1, 2, 3], attrs={"unit": "m"}, encoding={"dtype": np.int32}
        )
        v_level2 = xr.Variable(
            "x", ["a", "b", "c"], attrs={"unit": "m"}, encoding={"dtype": "U"}
        )

        index = PandasMultiIndex.from_variables(
            {"level1": v_level1, "level2": v_level2}
        )

        expected_idx = pd.MultiIndex.from_arrays([v_level1.data, v_level2.data])
        assert index.dim == "x"
        assert index.index.equals(expected_idx)
        assert index.index.name == "x"
        assert index.index.names == ["level1", "level2"]

        var = xr.Variable(("x", "y"), [[1, 2, 3], [4, 5, 6]])
        with pytest.raises(
            ValueError, match=r".*only accepts 1-dimensional variables.*"
        ):
            PandasMultiIndex.from_variables({"var": var})

        v_level3 = xr.Variable("y", [4, 5, 6])
        with pytest.raises(
            ValueError, match=r"unmatched dimensions for multi-index variables.*"
        ):
            PandasMultiIndex.from_variables({"level1": v_level1, "level3": v_level3})

    def test_concat(self) -> None:
        pd_midx = pd.MultiIndex.from_product(
            [[0, 1, 2], ["a", "b"]], names=("foo", "bar")
        )
        level_coords_dtype = {"foo": np.int32, "bar": "=U1"}

        midx1 = PandasMultiIndex(
            pd_midx[:2], "x", level_coords_dtype=level_coords_dtype
        )
        midx2 = PandasMultiIndex(
            pd_midx[2:], "x", level_coords_dtype=level_coords_dtype
        )
        expected = PandasMultiIndex(pd_midx, "x", level_coords_dtype=level_coords_dtype)

        actual = PandasMultiIndex.concat([midx1, midx2], "x")
        assert actual.equals(expected)
        assert actual.level_coords_dtype == expected.level_coords_dtype

    def test_stack(self) -> None:
        prod_vars = {
            "x": xr.Variable("x", pd.Index(["b", "a"]), attrs={"foo": "bar"}),
            "y": xr.Variable("y", pd.Index([1, 3, 2])),
        }

        index = PandasMultiIndex.stack(prod_vars, "z")

        assert index.dim == "z"
        assert index.index.names == ["x", "y"]
        np.testing.assert_array_equal(
            index.index.codes, [[0, 0, 0, 1, 1, 1], [0, 1, 2, 0, 1, 2]]
        )

        with pytest.raises(
            ValueError, match=r"conflicting dimensions for multi-index product.*"
        ):
            PandasMultiIndex.stack(
                {"x": xr.Variable("x", ["a", "b"]), "x2": xr.Variable("x", [1, 2])},
                "z",
            )

    def test_stack_non_unique(self) -> None:
        prod_vars = {
            "x": xr.Variable("x", pd.Index(["b", "a"]), attrs={"foo": "bar"}),
            "y": xr.Variable("y", pd.Index([1, 1, 2])),
        }

        index = PandasMultiIndex.stack(prod_vars, "z")

        np.testing.assert_array_equal(
            index.index.codes, [[0, 0, 0, 1, 1, 1], [0, 0, 1, 0, 0, 1]]
        )
        np.testing.assert_array_equal(index.index.levels[0], ["b", "a"])
        np.testing.assert_array_equal(index.index.levels[1], [1, 2])

    def test_unstack(self) -> None:
        pd_midx = pd.MultiIndex.from_product(
            [["a", "b"], [1, 2, 3]], names=["one", "two"]
        )
        index = PandasMultiIndex(pd_midx, "x")

        new_indexes, new_pd_idx = index.unstack()
        assert list(new_indexes) == ["one", "two"]
        assert new_indexes["one"].equals(PandasIndex(["a", "b"], "one"))
        assert new_indexes["two"].equals(PandasIndex([1, 2, 3], "two"))
        assert new_pd_idx.equals(pd_midx)

    def test_create_variables(self) -> None:
        foo_data = np.array([0, 0, 1], dtype="int64")
        bar_data = np.array([1.1, 1.2, 1.3], dtype="float64")
        pd_idx = pd.MultiIndex.from_arrays([foo_data, bar_data], names=("foo", "bar"))
        index_vars = {
            "x": IndexVariable("x", pd_idx),
            "foo": IndexVariable("x", foo_data, attrs={"unit": "m"}),
            "bar": IndexVariable("x", bar_data, encoding={"fill_value": 0}),
        }

        index = PandasMultiIndex(pd_idx, "x")
        actual = index.create_variables(index_vars)

        for k, expected in index_vars.items():
            assert_identical(actual[k], expected)
            assert actual[k].dtype == expected.dtype
            if k != "x":
                assert actual[k].dtype == index.level_coords_dtype[k]

    def test_sel(self) -> None:
        index = PandasMultiIndex(
            pd.MultiIndex.from_product([["a", "b"], [1, 2]], names=("one", "two")), "x"
        )

        # test tuples inside slice are considered as scalar indexer values
        actual = index.sel({"x": slice(("a", 1), ("b", 2))})
        expected_dim_indexers = {"x": slice(0, 4)}
        assert actual.dim_indexers == expected_dim_indexers

        with pytest.raises(KeyError, match=r"not all values found"):
            index.sel({"x": [0]})
        with pytest.raises(KeyError):
            index.sel({"x": 0})
        with pytest.raises(ValueError, match=r"cannot provide labels for both.*"):
            index.sel({"one": 0, "x": "a"})
        with pytest.raises(ValueError, match=r"invalid multi-index level names"):
            index.sel({"x": {"three": 0}})
        with pytest.raises(IndexError):
            index.sel({"x": (slice(None), 1, "no_level")})

    def test_join(self):
        midx = pd.MultiIndex.from_product([["a", "aa"], [1, 2]], names=("one", "two"))
        level_coords_dtype = {"one": "=U2", "two": "i"}
        index1 = PandasMultiIndex(midx, "x", level_coords_dtype=level_coords_dtype)
        index2 = PandasMultiIndex(midx[0:2], "x", level_coords_dtype=level_coords_dtype)

        actual = index1.join(index2)
        assert actual.equals(index2)
        assert actual.level_coords_dtype == level_coords_dtype

        actual = index1.join(index2, how="outer")
        assert actual.equals(index1)
        assert actual.level_coords_dtype == level_coords_dtype

    def test_rename(self) -> None:
        level_coords_dtype = {"one": "<U1", "two": np.int32}
        index = PandasMultiIndex(
            pd.MultiIndex.from_product([["a", "b"], [1, 2]], names=("one", "two")),
            "x",
            level_coords_dtype=level_coords_dtype,
        )

        # shortcut
        new_index = index.rename({}, {})
        assert new_index is index

        new_index = index.rename({"two": "three"}, {})
        assert new_index.index.names == ["one", "three"]
        assert new_index.dim == "x"
        assert new_index.level_coords_dtype == {"one": "<U1", "three": np.int32}

        new_index = index.rename({}, {"x": "y"})
        assert new_index.index.names == ["one", "two"]
        assert new_index.dim == "y"
        assert new_index.level_coords_dtype == level_coords_dtype

    def test_copy(self) -> None:
        level_coords_dtype = {"one": "U<1", "two": np.int32}
        expected = PandasMultiIndex(
            pd.MultiIndex.from_product([["a", "b"], [1, 2]], names=("one", "two")),
            "x",
            level_coords_dtype=level_coords_dtype,
        )
        actual = expected.copy()

        assert actual.index.equals(expected.index)
        assert actual.index is not expected.index
        assert actual.dim == expected.dim
        assert actual.level_coords_dtype == expected.level_coords_dtype


class TestIndexes:
    @pytest.fixture
    def indexes_and_vars(self) -> tuple[list[PandasIndex], dict[Hashable, Variable]]:
        x_idx = PandasIndex(pd.Index([1, 2, 3], name="x"), "x")
        y_idx = PandasIndex(pd.Index([4, 5, 6], name="y"), "y")
        z_pd_midx = pd.MultiIndex.from_product(
            [["a", "b"], [1, 2]], names=["one", "two"]
        )
        z_midx = PandasMultiIndex(z_pd_midx, "z")

        indexes = [x_idx, y_idx, z_midx]

        variables = {}
        for idx in indexes:
            variables.update(idx.create_variables())

        return indexes, variables

    @pytest.fixture(params=["pd_index", "xr_index"])
    def unique_indexes(
        self, request, indexes_and_vars
    ) -> list[PandasIndex] | list[pd.Index]:
        xr_indexes, _ = indexes_and_vars

        if request.param == "pd_index":
            return [idx.index for idx in xr_indexes]
        else:
            return xr_indexes

    @pytest.fixture
    def indexes(
        self, unique_indexes, indexes_and_vars
    ) -> Indexes[Index] | Indexes[pd.Index]:
        x_idx, y_idx, z_midx = unique_indexes
        indexes: dict[Any, Index] = {
            "x": x_idx,
            "y": y_idx,
            "z": z_midx,
            "one": z_midx,
            "two": z_midx,
        }

        _, variables = indexes_and_vars

        return Indexes(indexes, variables)

    def test_interface(self, unique_indexes, indexes) -> None:
        x_idx = unique_indexes[0]
        assert list(indexes) == ["x", "y", "z", "one", "two"]
        assert len(indexes) == 5
        assert "x" in indexes
        assert indexes["x"] is x_idx

    def test_variables(self, indexes) -> None:
        assert tuple(indexes.variables) == ("x", "y", "z", "one", "two")

    def test_dims(self, indexes) -> None:
        assert indexes.dims == {"x": 3, "y": 3, "z": 4}

    def test_get_unique(self, unique_indexes, indexes) -> None:
        assert indexes.get_unique() == unique_indexes

    def test_is_multi(self, indexes) -> None:
        assert indexes.is_multi("one") is True
        assert indexes.is_multi("x") is False

    def test_get_all_coords(self, indexes) -> None:
        expected = {
            "z": indexes.variables["z"],
            "one": indexes.variables["one"],
            "two": indexes.variables["two"],
        }
        assert indexes.get_all_coords("one") == expected

        with pytest.raises(ValueError, match="errors must be.*"):
            indexes.get_all_coords("x", errors="invalid")

        with pytest.raises(ValueError, match="no index found.*"):
            indexes.get_all_coords("no_coord")

        assert indexes.get_all_coords("no_coord", errors="ignore") == {}

    def test_get_all_dims(self, indexes) -> None:
        expected = {"z": 4}
        assert indexes.get_all_dims("one") == expected

    def test_group_by_index(self, unique_indexes, indexes):
        expected = [
            (unique_indexes[0], {"x": indexes.variables["x"]}),
            (unique_indexes[1], {"y": indexes.variables["y"]}),
            (
                unique_indexes[2],
                {
                    "z": indexes.variables["z"],
                    "one": indexes.variables["one"],
                    "two": indexes.variables["two"],
                },
            ),
        ]

        assert indexes.group_by_index() == expected

    def test_to_pandas_indexes(self, indexes) -> None:
        pd_indexes = indexes.to_pandas_indexes()
        assert isinstance(pd_indexes, Indexes)
        assert all([isinstance(idx, pd.Index) for idx in pd_indexes.values()])
        assert indexes.variables == pd_indexes.variables

    def test_copy_indexes(self, indexes) -> None:
        copied, index_vars = indexes.copy_indexes()

        assert copied.keys() == indexes.keys()
        for new, original in zip(copied.values(), indexes.values()):
            assert new.equals(original)
        # check unique index objects preserved
        assert copied["z"] is copied["one"] is copied["two"]

        assert index_vars.keys() == indexes.variables.keys()
        for new, original in zip(index_vars.values(), indexes.variables.values()):
            assert_identical(new, original)

```


# The last commit

```
e90b06dd SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q
........................................................................ [ 16%]
..................................xX.................................... [ 32%]
........................................................................ [ 48%]
........................................................................ [ 65%]
........................................................................ [ 81%]
..........s............................................................. [ 97%]
.........                                                                [100%]
=============================== warnings summary ===============================
xarray/tests/test_dataset.py::TestDataset::test_rename_same_name
  /testbed/xarray/tests/test_dataset.py:2842: UserWarning: rename 'dim2' to 'dim2' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    renamed = data.rename(newnames)

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/xarray/tests/test_dataset.py:2921: UserWarning: rename 'x' to 'a' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"x": "a"})

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/xarray/tests/test_dataset.py:2923: UserWarning: rename 'a' to 'x' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"a": "x"})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
438 passed, 1 skipped, 1 xfailed, 1 xpassed, 3 warnings in 16.02s
scope: xarray/core/dataset.py xarray/tests/test_dataset.py xarray/tests/test_indexes.py
changed: xarray/core/dataset.py +2 -2
changed: xarray/tests/test_dataset.py +9 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/xarray/core/dataset.py b/xarray/core/dataset.py
index 620f32f8..d9adfcc5 100644
--- a/xarray/core/dataset.py
+++ b/xarray/core/dataset.py
@@ -365,7 +365,7 @@ class DataVariables(Mapping[Any, "DataArray"]):
         )
 
     def __len__(self) -> int:
-        return len(self._dataset._variables) - len(self._dataset._coord_names)
+        return sum(1 for _ in self)
 
     def __contains__(self, key: Hashable) -> bool:
         return key in self._dataset._variables and key not in self._dataset._coord_names
@@ -4177,7 +4177,7 @@ class Dataset(
         }
         variables.update(new_variables)
 
-        coord_names = set(new_variables) | self._coord_names
+        coord_names = (set(new_variables) | self._coord_names) - set(drop_variables)
 
         return self._replace(variables, coord_names=coord_names, indexes=indexes)
 
diff --git a/xarray/tests/test_dataset.py b/xarray/tests/test_dataset.py
index fc2806c7..ef2ade2c 100644
--- a/xarray/tests/test_dataset.py
+++ b/xarray/tests/test_dataset.py
@@ -3249,6 +3249,15 @@ class TestDataset:
         assert_identical(obj, expected, check_default_indexes=False)
         assert len(obj.xindexes) == 0
 
+        # regression test for GH7105: drop=True must also drop the index
+        # coordinate names, not only the variables
+        ds = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
+        obj = ds.set_index(z=["a", "b"]).reset_index("z", drop=True)
+        assert list(obj.coords) == ["a", "b"]
+        assert obj._coord_names == {"a", "b"}
+        assert len(obj.data_vars) == 0
+        assert list(obj.data_vars) == []
+
         ds = Dataset(coords={"y": ("x", [1, 2, 3])})
         with pytest.raises(ValueError, match=r".*not coordinates with an index"):
             ds.reset_index("y")
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
check: python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q
........................................................................ [ 16%]
..................................xX.................................... [ 32%]
........................................................................ [ 48%]
........................................................................ [ 65%]
........................................................................ [ 81%]
..........s............................................................. [ 97%]
.........                                                                [100%]
=============================== warnings summary ===============================
xarray/tests/test_dataset.py::TestDataset::test_rename_same_name
  /testbed/xarray/tests/test_dataset.py:2842: UserWarning: rename 'dim2' to 'dim2' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    renamed = data.rename(newnames)

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/xarray/tests/test_dataset.py:2921: UserWarning: rename 'x' to 'a' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"x": "a"})

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/xarray/tests/test_dataset.py:2923: UserWarning: rename 'a' to 'x' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"a": "x"})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
438 passed, 1 skipped, 1 xfailed, 1 xpassed, 3 warnings in 21.74s
scope: xarray/core/dataset.py xarray/tests/test_dataset.py xarray/tests/test_indexes.py
changed: xarray/core/dataset.py +2 -2
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
# Notes, run 2026-11-06T114756

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

index refactor: more `_coord_names` than `_variables` on Dataset
### What happened?

`xr.core.dataset.DataVariables` assumes that everything that is in `ds._dataset._variables` and not in `self._dataset._coord_names` is a "data variable". However, since the index refactor we can end up with more `_coord_names` than `_variables` which breaks a number of stuff (e.g. the repr).

### What did you expect to happen?

Well it seems this assumption is now wrong.

### Minimal Complete Verifiable Example

```Python
ds = xr.Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ['a', 'b', 'c'])})
ds.set_index(z=['a', 'b']).reset_index("z", drop=True)
```


### MVCE confirmation

- [ ] Minimal example — the example is as focused as reasonably possible to demonstrate the underlying issue in xarray.
- [ ] Complete example — the example is self-contained, including all data and the text of any traceback.
- [ ] Verifiable example — the example copy & pastes into an IPython prompt or [Binder notebook](https://mybinder.org/v2/gh/pydata/xarray/main?urlpath=lab/tree/doc/examples/blank_template.ipynb), returning the result.
- [ ] New issue — a search of GitHub Issues suggests this is not a duplicate.

### Relevant log output

```Python
ValueError: __len__() should return >= 0
```


### Anything else we need to know?

The error comes from here

https://github.com/pydata/xarray/blob/63ba862d03c8d0cd8b44d2071bc360e9fed4519d/xarray/core/dataset.py#L368

Bisected to #5692 - which probably does not help too much.


### Environment

<details>



</details>


# The files of the project

```
.binder/environment.yml
.codecov.yml
.coveragerc
.git-blame-ignore-revs
.git_archival.txt
.gitattributes
.github/FUNDING.yml
.github/ISSUE_TEMPLATE/bugreport.yml
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/misc.yml
.github/ISSUE_TEMPLATE/newfeature.yml
.github/PULL_REQUEST_TEMPLATE.md
.github/dependabot.yml
.github/labeler.yml
.github/stale.yml
.github/workflows/benchmarks.yml
.github/workflows/ci-additional.yaml
.github/workflows/ci.yaml
.github/workflows/configure-testpypi-version.py
.github/workflows/label-all.yml
.github/workflows/label-prs.yml
.github/workflows/parse_logs.py
.github/workflows/publish-test-results.yaml
.github/workflows/pypi-release.yaml
.github/workflows/testpypi-release.yaml
.github/workflows/upstream-dev-ci.yaml
.gitignore
.pep8speaks.yml
.pre-commit-config.yaml
.readthedocs.yaml
CITATION.cff
CODE_OF_CONDUCT.md
CONTRIBUTING.md
HOW_TO_RELEASE.md
LICENSE
README.md
asv_bench/asv.conf.json
asv_bench/benchmarks/README_CI.md
asv_bench/benchmarks/__init__.py
asv_bench/benchmarks/combine.py
asv_bench/benchmarks/dataarray_missing.py
asv_bench/benchmarks/dataset_io.py
asv_bench/benchmarks/groupby.py
asv_bench/benchmarks/indexing.py
asv_bench/benchmarks/interp.py
asv_bench/benchmarks/pandas.py
asv_bench/benchmarks/polyfit.py
asv_bench/benchmarks/reindexing.py
asv_bench/benchmarks/repr.py
asv_bench/benchmarks/rolling.py
asv_bench/benchmarks/unstacking.py
ci/install-upstream-wheels.sh
ci/min_deps_check.py
ci/requirements/all-but-dask.yml
ci/requirements/bare-minimum.yml
ci/requirements/doc.yml
ci/requirements/environment-windows.yml
ci/requirements/environment.yml
ci/requirements/min-all-deps.yml
conftest.py
design_notes/flexible_indexes_notes.md
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
doc/_static/index_api.svg
doc/_static/index_contribute.svg
doc/_static/index_getting_started.svg
doc/_static/index_user_guide.svg
doc/_static/numfocus_logo.png
doc/_static/opendap-prism-tmax.png
doc/_static/style.css
doc/_static/thumbnails/ERA5-GRIB-example.png
doc/_static/thumbnails/ROMS_ocean_model.png
doc/_static/thumbnails/area_weighted_temperature.png
doc/_static/thumbnails/monthly-means.png
doc/_static/thumbnails/multidimensional-coords.png
doc/_static/thumbnails/toy-weather-data.png
doc/_static/thumbnails/visualization_gallery.png
doc/_templates/autosummary/accessor.rst
doc/_templates/autosummary/accessor_attribute.rst
doc/_templates/autosummary/accessor_callable.rst
doc/_templates/autosummary/accessor_method.rst
doc/api-hidden.rst
doc/api.rst
doc/conf.py
doc/contributing.rst
doc/developers-meeting.rst
doc/ecosystem.rst
doc/examples/ERA5-GRIB-example.ipynb
doc/examples/ROMS_ocean_model.ipynb
doc/examples/_code/accessor_example.py
doc/examples/apply_ufunc_vectorize_1d.ipynb
doc/examples/area_weighted_temperature.ipynb
doc/examples/blank_template.ipynb
doc/examples/monthly-means.ipynb
doc/examples/monthly_means_output.png
doc/examples/multidimensional-coords.ipynb
doc/examples/visualization_gallery.ipynb
doc/examples/weather-data.ipynb
doc/gallery.rst
doc/gallery.yml
doc/gallery/README.txt
doc/gallery/plot_cartopy_facetgrid.py
doc/gallery/plot_colorbar_center.py
doc/gallery/plot_control_colorbar.py
doc/gallery/plot_lines_from_2d.py
doc/gallery/plot_rasterio.py
doc/gallery/plot_rasterio_rgb.py
doc/getting-started-guide/faq.rst
doc/getting-started-guide/index.rst
doc/getting-started-guide/installing.rst
doc/getting-started-guide/quick-overview.rst
doc/getting-started-guide/why-xarray.rst
doc/howdoi.rst
doc/index.rst
doc/internals/duck-arrays-integration.rst
doc/internals/extending-xarray.rst
doc/internals/how-to-add-new-backend.rst
doc/internals/index.rst
doc/internals/variable-objects.rst
doc/internals/zarr-encoding-spec.rst
doc/roadmap.rst
doc/team.rst
doc/team.yml
doc/tutorials-and-videos.rst
doc/user-guide/combining.rst
doc/user-guide/computation.rst
doc/user-guide/dask.rst
doc/user-guide/data-structures.rst
doc/user-guide/duckarrays.rst
doc/user-guide/groupby.rst
doc/user-guide/index.rst
doc/user-guide/indexing.rst
doc/user-guide/interpolation.rst
doc/user-guide/io.rst
doc/user-guide/options.rst
doc/user-guide/pandas.rst
doc/user-guide/plotting.rst
doc/user-guide/reshaping.rst
doc/user-guide/terminology.rst
doc/user-guide/time-series.rst
doc/user-guide/weather-climate.rst
doc/videos.yml
doc/whats-new.rst
licenses/DASK_LICENSE
licenses/ICOMOON_LICENSE
licenses/NUMPY_LICENSE
licenses/PANDAS_LICENSE
licenses/PYTHON_LICENSE
licenses/SCIKIT_LEARN_LICENSE
licenses/SEABORN_LICENSE
properties/README.md
properties/conftest.py
properties/test_encode_decode.py
properties/test_pandas_roundtrip.py
pyproject.toml
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
xarray/backends/plugins.py
xarray/backends/pseudonetcdf_.py
xarray/backends/pydap_.py
xarray/backends/pynio_.py
xarray/backends/rasterio_.py
xarray/backends/scipy_.py
xarray/backends/store.py
xarray/backends/zarr.py
xarray/coding/__init__.py
xarray/coding/calendar_ops.py
xarray/coding/cftime_offsets.py
xarray/coding/cftimeindex.py
xarray/coding/frequencies.py
xarray/coding/strings.py
xarray/coding/times.py
xarray/coding/variables.py
xarray/conventions.py
xarray/convert.py
xarray/core/__init__.py
xarray/core/_reductions.py
xarray/core/_typed_ops.py
xarray/core/_typed_ops.pyi
xarray/core/accessor_dt.py
xarray/core/accessor_str.py
xarray/core/alignment.py
xarray/core/arithmetic.py
xarray/core/combine.py
xarray/core/common.py
xarray/core/computation.py
xarray/core/concat.py
xarray/core/coordinates.py
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
xarray/core/types.py
xarray/core/utils.py
xarray/core/variable.py
xarray/core/weighted.py
xarray/plot/__init__.py
xarray/plot/dataset_plot.py
xarray/plot/facetgrid.py
xarray/plot/plot.py
xarray/plot/utils.py
xarray/py.typed
xarray/static/__init__.py
xarray/static/css/__init__.py
xarray/static/css/style.css
xarray/static/html/__init__.py
xarray/static/html/icons-svg-inline.html
xarray/testing.py
xarray/tests/__init__.py
xarray/tests/conftest.py
xarray/tests/data/bears.nc
xarray/tests/data/example.grib
xarray/tests/data/example.ict
xarray/tests/data/example.uamiv
xarray/tests/data/example_1.nc
xarray/tests/data/example_1.nc.gz
xarray/tests/test_accessor_dt.py
xarray/tests/test_accessor_str.py
xarray/tests/test_array_api.py
xarray/tests/test_backends.py
xarray/tests/test_backends_api.py
xarray/tests/test_backends_common.py
xarray/tests/test_backends_file_manager.py
xarray/tests/test_backends_locks.py
xarray/tests/test_backends_lru_cache.py
xarray/tests/test_calendar_ops.py
xarray/tests/test_cftime_offsets.py
xarray/tests/test_cftimeindex.py
xarray/tests/test_cftimeindex_resample.py
xarray/tests/test_coarsen.py
xarray/tests/test_coding.py
xarray/tests/test_coding_strings.py
xarray/tests/test_coding_times.py
xarray/tests/test_combine.py
xarray/tests/test_computation.py
xarray/tests/test_concat.py
xarray/tests/test_conventions.py
xarray/tests/test_cupy.py
xarray/tests/test_dask.py
xarray/tests/test_dataarray.py
xarray/tests/test_dataset.py
xarray/tests/test_deprecation_helpers.py
xarray/tests/test_distributed.py
xarray/tests/test_dtypes.py
xarray/tests/test_duck_array_ops.py
xarray/tests/test_extensions.py
xarray/tests/test_formatting.py
xarray/tests/test_formatting_html.py
xarray/tests/test_groupby.py
xarray/tests/test_indexes.py
xarray/tests/test_indexing.py
xarray/tests/test_interp.py
xarray/tests/test_merge.py
xarray/tests/test_missing.py
xarray/tests/test_nputils.py
xarray/tests/test_options.py
xarray/tests/test_plot.py
xarray/tests/test_plugins.py
xarray/tests/test_print_versions.py
xarray/tests/test_rolling.py
xarray/tests/test_sparse.py
xarray/tests/test_testing.py
xarray/tests/test_tutorial.py
xarray/tests/test_ufuncs.py
xarray/tests/test_units.py
xarray/tests/test_utils.py
xarray/tests/test_variable.py
xarray/tests/test_weighted.py
xarray/tutorial.py
xarray/util/__init__.py
xarray/util/deprecation_helpers.py
xarray/util/generate_ops.py
xarray/util/generate_reductions.py
xarray/util/print_versions.py
```


# The last commit

```
e90b06dd SWE-bench


```

```diff

```


# README.md (the start)

```
# xarray: N-D labeled arrays and datasets

[![CI](https://github.com/pydata/xarray/workflows/CI/badge.svg?branch=main)](https://github.com/pydata/xarray/actions?query=workflow%3ACI)
[![Code coverage](https://codecov.io/gh/pydata/xarray/branch/main/graph/badge.svg)](https://codecov.io/gh/pydata/xarray)
[![Docs](https://readthedocs.org/projects/xray/badge/?version=latest)](https://docs.xarray.dev/)
[![Benchmarked with asv](https://img.shields.io/badge/benchmarked%20by-asv-green.svg?style=flat)](https://pandas.pydata.org/speed/xarray/)
[![Available on pypi](https://img.shields.io/pypi/v/xarray.svg)](https://pypi.python.org/pypi/xarray/)
[![Formatted with black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/python/black)
[![Checked with mypy](http://www.mypy-lang.org/static/mypy_badge.svg)](http://mypy-lang.org/)
[![Mirror on zendoo](https://zenodo.org/badge/DOI/10.5281/zenodo.598201.svg)](https://doi.org/10.5281/zenodo.598201)
[![Examples on binder](https://img.shields.io/badge/launch-binder-579ACA.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFkAAABZCAMAAABi1XidAAAB8lBMVEX///9XmsrmZYH1olJXmsr1olJXmsrmZYH1olJXmsr1olJXmsrmZYH1olL1olJXmsr1olJXmsrmZYH1olL1olJXmsrmZYH1olJXmsr1olL1olJXmsrmZYH1olL1olJXmsrmZYH1olL1olL0nFf1olJXmsrmZYH1olJXmsq8dZb1olJXmsrmZYH1olJXmspXmspXmsr1olL1olJXmsrmZYH1olJXmsr1olL1olJXmsrmZYH1olL1olLeaIVXmsrmZYH1olL1olL1olJXmsrmZYH1olLna31Xmsr1olJXmsr1olJXmsrmZYH1olLqoVr1olJXmsr1olJXmsrmZYH1olL1olKkfaPobXvviGabgadXmsqThKuofKHmZ4Dobnr1olJXmsr1olJXmspXmsr1olJXmsrfZ4TuhWn1olL1olJXmsqBi7X1olJXmspZmslbmMhbmsdemsVfl8ZgmsNim8Jpk8F0m7R4m7F5nLB6jbh7jbiDirOEibOGnKaMhq+PnaCVg6qWg6qegKaff6WhnpKofKGtnomxeZy3noG6dZi+n3vCcpPDcpPGn3bLb4/Mb47UbIrVa4rYoGjdaIbeaIXhoWHmZYHobXvpcHjqdHXreHLroVrsfG/uhGnuh2bwj2Hxk17yl1vzmljzm1j0nlX1olL3AJXWAAAAbXRSTlMAEBAQHx8gICAuLjAwMDw9PUBAQEpQUFBXV1hgYGBkcHBwcXl8gICAgoiIkJCQlJicnJ2goKCmqK+wsLC4usDAwMjP0NDQ1NbW3Nzg4ODi5+3v8PDw8/T09PX29vb39/f5+fr7+/z8/Pz9/v7+zczCxgAABC5JREFUeAHN1ul3k0UUBvCb1CTVpmpaitAGSLSpSuKCLWpbTKNJFGlcSMAFF63iUmRccNG6gLbuxkXU66JAUef/9LSpmXnyLr3T5AO/rzl5zj137p136BISy44fKJXuGN/d19PUfYeO67Znqtf2KH33Id1psXoFdW30sPZ1sMvs2D060AHqws4FHeJojLZqnw53cmfvg+XR8mC0OEjuxrXEkX5ydeVJLVIlV0e10PXk5k7dYeHu7Cj1j+49uKg7uLU61tGLw1lq27ugQYlclHC4bgv7VQ+TAyj5Zc/UjsPvs1sd5cWryWObtvWT2EPa4rtnWW3JkpjggEpbOsPr7F7EyNewtpBIslA7p43HCsnwooXTEc3UmPmCNn5lrqTJxy6nRmcavGZVt/3Da2pD5NHvsOHJCrdc1G2r3DITpU7yic7w/7Rxnjc0kt5GC4djiv2Sz3Fb2iEZg41/ddsFDoyuYrIkmFehz0HR2thPgQqMyQYb2OtB0WxsZ3BeG3+wpRb1vzl2UYBog8FfGhttFKjtAclnZYrRo9ryG9uG/FZQU4AEg8ZE9LjGMzTmqKXPLnlWVnIlQQTvxJf8ip7VgjZjyVPrjw1te5otM7RmP7xm+sK2Gv9I8Gi++BRbEkR9EBw8zRUcKxwp73xkaLiqQb+kGduJTNHG72zcW9LoJgqQxpP3/Tj//c3yB0tqzaml05/+orHLksVO+95kX7/7qgJvnjlrfr2Ggsyx0eoy9uPzN5SPd86aXggOsEKW2Prz7du3VID3/tzs/sSRs2w7ovVHKtjrX2pd7ZMlTxAYfBAL9jiDwfLkq55Tm7ifhMlTGPyCAs7RFRhn47JnlcB9RM5T97ASuZXIcVNuUDIndpDbdsfrqsOppeXl5Y+XVKdjFCTh+zGaVuj0d9zy05PPK3QzBamxdwtTCrzyg/2Rvf2EstUjordGwa/kx9mSJLr8mLLtCW8HHGJc2R5hS219IiF6PnTusOqcMl57gm0Z8kanKMAQg0qSyuZfn7zItsbGyO9QlnxY0eCuD1XL2ys/MsrQhltE7Ug0uFOzufJFE2PxBo/YAx8XPPdDwWN0MrDRYIZF0mSMKCNHgaIVFoBbNoLJ7tEQDKxGF0kcLQimojCZopv0OkNOyWCCg9XMVAi7ARJzQdM2QUh0gmBozjc3Skg6dSBRqDGYSUOu66Zg+I2fNZs/M3/f/Grl/XnyF1Gw3VKCez0PN5IUfFLqvgUN4C0qNqYs5YhPL+aVZYDE4IpUk57oSFnJm4FyCqqOE0jhY2SMyLFoo56zyo6becOS5UVDdj7Vih0zp+tcMhwRpBeLyqtIjlJKAIZSbI8SGSF3k0pA3mR5tHuwPFoa7N7reoq2bqCsAk1HqCu5uvI1n6JuRXI+S1Mco54YmYTwcn6Aeic+kssXi8XpXC4V3t7/ADuTNKaQJdScAAAAAElFTkSuQmCC)](https://mybinder.org/v2/gh/pydata/xarray/main?urlpath=lab/tree/doc/examples/weather-data.ipynb)
[![Twitter](https://img.shields.io/twitter/follow/xarray_dev?style=social)](https://twitter.com/xarray_dev)

**xarray** (formerly **xray**) is an open source project and Python
package that makes working with labelled multi-dimensional arrays
simple, efficient, and fun!

Xarray introduces labels in the form of dimensions, coordinates and
attributes on top of raw [NumPy](https://www.numpy.org)-like arrays,
which allows for a more intuitive, more concise, and less error-prone
developer experience. The package includes a large and growing library
of domain-agnostic functions for advanced analytics and visualization
with these data structures.

Xarray was inspired by and borrows heavily from
[pandas](https://pandas.pydata.org), the popular data analysis package
focused on labelled tabular data. It is particularly tailored to working
with [netCDF](https://www.unidata.ucar.edu/software/netcdf) files, which
were the source of xarray\'s data model, and integrates tightly with
[dask](https://dask.org) for parallel computing.

## Why xarray?

Multi-dimensional (a.k.a. N-dimensional, ND) arrays (sometimes called
"tensors") are an essential part of computational science. They are
encountered in a wide range of fields, including physics, astronomy,
geoscience, bioinformatics, engineering, finance, and deep learning. In
Python, [NumPy](https://www.numpy.org) provides the fundamental data
structure and API for working with raw ND arrays. However, real-world
datasets are usually more than just raw numbers; they have labels which
encode information about how the array values map to locations in space,
time, etc.

Xarray doesn\'t just keep track of labels on arrays \-- it uses them to
provide a powerful and concise interface. For example:

- Apply operations over dimensions by name: `x.sum('time')`.
- Select values by label instead of integer location:
    `x.loc['2014-01-01']` or `x.sel(time='2014-01-01')`.
- Mathematical operations (e.g., `x - y`) vectorize across multiple
    dimensions (array broadcasting) based on dimension names, not shape.
- Flexible split-apply-combine operations with groupby:
    `x.groupby('time.dayofyear').mean()`.
- Database like alignment based on coordinate labels that smoothly
    handles missing values: `x, y = xr.align(x, y, join='outer')`.
- Keep track of arbitrary metadata in the form of a Python dictionary:
    `x.attrs`.

## Documentation

Learn more about xarray in its official documentation at
<https://docs.xarray.d
```


# CONTRIBUTING.md (the start)

```
Xarray's contributor guidelines [can be found in our online documentation](http://docs.xarray.dev/en/stable/contributing.html)

```


# pyproject.toml (the start)

```
[build-system]
requires = [
    "setuptools>=42",
    "setuptools-scm[toml]>=3.4",
    "setuptools-scm-git-archive",
]
build-backend = "setuptools.build_meta"

[tool.setuptools_scm]
fallback_version = "999"

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q`

## Scope
`xarray/core/dataset.py`
`xarray/tests/test_dataset.py`
`xarray/tests/test_indexes.py`

## Done when
- `Dataset.data_vars` tolerates `_coord_names` containing names not present in `_variables`, and its length is never negative.
- The supplied MVCE `ds.set_index(z=['a','b']).reset_index("z", drop=True)` completes, and `repr(ds)` no longer raises `ValueError: __len__() should return >= 0`.
- `Dataset.data_vars` still counts only variables that are not coordinate names.

## Approach
First, fix the assumption directly in `DataVariables.__len__` by subtracting only the intersection `_coord_names & _variables`, matching the existing filtering in `DataVariables.__iter__` and `__contains__`. This is the minimal, low-risk fix and directly removes the negative length.

If the MVCE still fails after that, inspect `Dataset.reset_index(..., drop=True)`: it may leave stale names in `_coord_names` after removing dropped variables. Root-cause candidate: update `_coord_names` when dropping index/level variables so `_coord_names ⊆ _variables` is restored; tradeoff is a slightly larger behavioral change to `reset_index`.

A broader defensive alternative is to make `Coordinates` and formatting also ignore names absent from `_variables`; tradeoff is that it hides inconsistent dataset state rather than fixing or tolerating the stated assumption. Prefer the intersection fix, plus stale-coordinate cleanup only if required by the MVCE or repr.
```

### `prompt.md`

````
index refactor: more `_coord_names` than `_variables` on Dataset
### What happened?

`xr.core.dataset.DataVariables` assumes that everything that is in `ds._dataset._variables` and not in `self._dataset._coord_names` is a "data variable". However, since the index refactor we can end up with more `_coord_names` than `_variables` which breaks a number of stuff (e.g. the repr).

### What did you expect to happen?

Well it seems this assumption is now wrong.

### Minimal Complete Verifiable Example

```Python
ds = xr.Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ['a', 'b', 'c'])})
ds.set_index(z=['a', 'b']).reset_index("z", drop=True)
```


### MVCE confirmation

- [ ] Minimal example — the example is as focused as reasonably possible to demonstrate the underlying issue in xarray.
- [ ] Complete example — the example is self-contained, including all data and the text of any traceback.
- [ ] Verifiable example — the example copy & pastes into an IPython prompt or [Binder notebook](https://mybinder.org/v2/gh/pydata/xarray/main?urlpath=lab/tree/doc/examples/blank_template.ipynb), returning the result.
- [ ] New issue — a search of GitHub Issues suggests this is not a duplicate.

### Relevant log output

```Python
ValueError: __len__() should return >= 0
```


### Anything else we need to know?

The error comes from here

https://github.com/pydata/xarray/blob/63ba862d03c8d0cd8b44d2071bc360e9fed4519d/xarray/core/dataset.py#L368

Bisected to #5692 - which probably does not help too much.


### Environment

<details>



</details>
````

### `review.md`

```
verdict: PASS
- `DataVariables.__len__` now iterates its members, so extra `_coord_names` entries cannot make the length negative.
- `Dataset.data_vars` still includes only variables not present in `_coord_names`.
- `reset_index(..., drop=True)` now removes dropped coordinate names, and the added regression test covers the supplied MVCE.
- The check passed: 438 passed, 1 skipped, 1 xfailed, 1 xpassed.
- Changes are limited to the scoped files.
```

### `scope.txt`

```
scope: xarray/core/dataset.py xarray/tests/test_dataset.py xarray/tests/test_indexes.py
changed: xarray/core/dataset.py +2 -2
changed: xarray/tests/test_dataset.py +9 -0
```

### `task.md`

````
# Task

## Prompt

index refactor: more `_coord_names` than `_variables` on Dataset
### What happened?

`xr.core.dataset.DataVariables` assumes that everything that is in `ds._dataset._variables` and not in `self._dataset._coord_names` is a "data variable". However, since the index refactor we can end up with more `_coord_names` than `_variables` which breaks a number of stuff (e.g. the repr).

### What did you expect to happen?

Well it seems this assumption is now wrong.

### Minimal Complete Verifiable Example

```Python
ds = xr.Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ['a', 'b', 'c'])})
ds.set_index(z=['a', 'b']).reset_index("z", drop=True)
```


### MVCE confirmation

- [ ] Minimal example — the example is as focused as reasonably possible to demonstrate the underlying issue in xarray.
- [ ] Complete example — the example is self-contained, including all data and the text of any traceback.
- [ ] Verifiable example — the example copy & pastes into an IPython prompt or [Binder notebook](https://mybinder.org/v2/gh/pydata/xarray/main?urlpath=lab/tree/doc/examples/blank_template.ipynb), returning the result.
- [ ] New issue — a search of GitHub Issues suggests this is not a duplicate.

### Relevant log output

```Python
ValueError: __len__() should return >= 0
```


### Anything else we need to know?

The error comes from here

https://github.com/pydata/xarray/blob/63ba862d03c8d0cd8b44d2071bc360e9fed4519d/xarray/core/dataset.py#L368

Bisected to #5692 - which probably does not help too much.


### Environment

<details>



</details>

## Deliverable

changes to this tree

## Check

`python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q`

## Scope

`xarray/core/dataset.py`
`xarray/tests/test_dataset.py`
`xarray/tests/test_indexes.py`

## Done when

- `Dataset.data_vars` tolerates `_coord_names` containing names not present in `_variables`, and its length is never negative.
- The supplied MVCE `ds.set_index(z=['a','b']).reset_index("z", drop=True)` completes, and `repr(ds)` no longer raises `ValueError: __len__() should return >= 0`.
- `Dataset.data_vars` still counts only variables that are not coordinate names.
````

### `test-output.log`

```
check: python -m pytest xarray/tests/test_dataset.py xarray/tests/test_indexes.py -q
........................................................................ [ 16%]
..................................xX.................................... [ 32%]
........................................................................ [ 48%]
........................................................................ [ 65%]
........................................................................ [ 81%]
..........s............................................................. [ 97%]
.........                                                                [100%]
=============================== warnings summary ===============================
xarray/tests/test_dataset.py::TestDataset::test_rename_same_name
  /testbed/xarray/tests/test_dataset.py:2842: UserWarning: rename 'dim2' to 'dim2' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    renamed = data.rename(newnames)

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/xarray/tests/test_dataset.py:2921: UserWarning: rename 'x' to 'a' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"x": "a"})

xarray/tests/test_dataset.py::TestDataset::test_rename_multiindex
  /testbed/xarray/tests/test_dataset.py:2923: UserWarning: rename 'a' to 'x' does not create an index anymore. Try using swap_dims instead or use set_index after rename to create an indexed coordinate.
    original.rename({"a": "x"})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
438 passed, 1 skipped, 1 xfailed, 1 xpassed, 3 warnings in 13.31s
scope: xarray/core/dataset.py xarray/tests/test_dataset.py xarray/tests/test_indexes.py
changed: xarray/core/dataset.py +2 -2
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
