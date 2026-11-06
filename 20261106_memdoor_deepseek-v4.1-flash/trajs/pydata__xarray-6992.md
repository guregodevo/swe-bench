# pydata__xarray-6992 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 114s 32 lines cost=0.003657 in=161957 cached=113152 out=5327 calls=15`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

````
Workflow single, task do.

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

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
````

**assistant → tool `bash`**

```json
{
  "command": "cd /project 2>/dev/null || pwd; git status --porcelain | head; git log --oneline -3"
}
```

**assistant → tool `bash`**

```json
{
  "command": "ls; sed -n '330,420p' xarray/core/dataset.py"
}
```

**tool result**

```
refused: this command cd's to /project, outside your working directory (/testbed). You are ALREADY in the right directory — drop the cd and use paths relative to it.

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**tool result**

```
CITATION.cff
CODE_OF_CONDUCT.md
CONTRIBUTING.md
HOW_TO_RELEASE.md
LICENSE
README.md
asv_bench
ci
conftest.py
design_notes
doc
licenses
properties
pyproject.toml
requirements.txt
setup.cfg
setup.py
xarray
xarray.egg-info
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
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nds = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)\nprint(ds)\nprint(len(ds.data_vars))\n\""
}
```

**tool result**

```
Command FAILED (exit status 1): `python -c "
import xarray as xr
ds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})
ds = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)
print(ds)
print(len(ds.data_vars))
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

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def reset_index\" -A 120 xarray/core/dataset.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"_coord_names\" xarray/core/dataset.py | head -60"
}
```

**tool result**

```
4108:    def reset_index(
4109-        self: T_Dataset,
4110-        dims_or_levels: Hashable | Sequence[Hashable],
4111-        drop: bool = False,
4112-    ) -> T_Dataset:
4113-        """Reset the specified index(es) or multi-index level(s).
4114-
4115-        Parameters
4116-        ----------
4117-        dims_or_levels : Hashable or Sequence of Hashable
4118-            Name(s) of the dimension(s) and/or multi-index level(s) that will
4119-            be reset.
4120-        drop : bool, default: False
4121-            If True, remove the specified indexes and/or multi-index levels
4122-            instead of extracting them as new coordinates (default: False).
4123-
4124-        Returns
4125-        -------
4126-        obj : Dataset
4127-            Another dataset, with this dataset's data but replaced coordinates.
4128-
4129-        See Also
4130-        --------
4131-        Dataset.set_index
4132-        """
4133-        if isinstance(dims_or_levels, str) or not isinstance(dims_or_levels, Sequence):
4134-            dims_or_levels = [dims_or_levels]
4135-
4136-        invalid_coords = set(dims_or_levels) - set(self._indexes)
4137-        if invalid_coords:
4138-            raise ValueError(
4139-                f"{tuple(invalid_coords)} are not coordinates with an index"
4140-            )
4141-
4142-        drop_indexes: list[Hashable] = []
4143-        drop_variables: list[Hashable] = []
4144-        replaced_indexes: list[PandasMultiIndex] = []
4145-        new_indexes: dict[Hashable, Index] = {}
4146-        new_variables: dict[Hashable, IndexVariable] = {}
4147-
4148-        for name in dims_or_levels:
4149-            index = self._indexes[name]
4150-            drop_indexes += list(self.xindexes.get_all_coords(name))
4151-
4152-            if isinstance(index, PandasMultiIndex) and name not in self.dims:
4153-                # special case for pd.MultiIndex (name is an index level):
4154-                # replace by a new index with dropped level(s) instead of just drop the index
4155-                if index not in replaced_indexes:
4156-                    level_names = index.index.names
4157-                    level_vars = {
4158-                        k: self._variables[k]
4159-                        for k in level_names
4160-                        if k not in dims_or_levels
4161-                    }
4162-                    if level_vars:
4163-                        idx = index.keep_levels(level_vars)
4164-                        idx_vars = idx.create_variables(level_vars)
4165-                        new_indexes.update({k: idx for k in idx_vars})
4166-                        new_variables.update(idx_vars)
4167-                replaced_indexes.append(index)
4168-
4169-            if drop:
4170-                drop_variables.append(name)
4171-
4172-        indexes = {k: v for k, v in self._indexes.items() if k not in drop_indexes}
4173-        indexes.update(new_indexes)
4174-
4175-        variables = {
4176-            k: v for k, v in self._variables.items() if k not in drop_variables
4177-        }
4178-        variables.update(new_variables)
4179-
4180-        coord_names = set(new_variables) | self._coord_names
4181-
4182-        return self._replace(variables, coord_names=coord_names, indexes=indexes)
4183-
4184-    def reorder_levels(
4185-        self: T_Dataset,
4186-        dim_order: Mapping[Any, Sequence[int | Hashable]] | None = None,
4187-        **dim_order_kwargs: Sequence[int | Hashable],
4188-    ) -> T_Dataset:
4189-        """Rearrange index levels using input order.
4190-
4191-        Parameters
4192-        ----------
4193-        dim_order : dict-like of Hashable to Sequence of int or Hashable, optional
4194-            Mapping from names matching dimensions and values given
4195-            by lists representing new level orders. Every given dimension
4196-            must have a multi-index.
4197-        **dim_order_kwargs : Sequence of int or Hashable, optional
4198-            The keyword arguments form of ``dim_order``.
4199-            One of dim_order or dim_order_kwargs must be provided.
4200-
4201-        Returns
4202-        -------
4203-        obj : Dataset
4204-            Another dataset, with this dataset's data but replaced
4205-            coordinates.
4206-        """
4207-        dim_order = either_dict_or_kwargs(dim_order, dim_order_kwargs, "reorder_levels")
4208-        variables = self._variables.copy()
4209-        indexes = dict(self._indexes)
4210-        new_indexes: dict[Hashable, Index] = {}
4211-        new_variables: dict[Hashable, IndexVariable] = {}
4212-
4213-        for dim, order in dim_order.items():
4214-            index = self._indexes[dim]
4215-
4216-            if not isinstance(index, PandasMultiIndex):
4217-                raise ValueError(f"coordinate {dim} has no MultiIndex")
4218-
4219-            level_vars = {k: self._variables[k] for k in order}
4220-            idx = index.reorder_levels(level_vars)
4221-            idx_vars = idx.create_variables(level_vars)
4222-            new_indexes.update({k: idx for k in idx_vars})
4223-            new_variables.update(idx_vars)
4224-
4225-        indexes = {k: v for k, v in self._indexes.items() if k not in new_indexes}
4226-        indexes.update(new_indexes)
4227-
4228-        variables = {k: v for k, v in self._variables.items() if k not in new_variables}
```

**tool result**

```
364:            if key not in self._dataset._coord_names
368:        return len(self._dataset._variables) - len(self._dataset._coord_names)
371:        return key in self._dataset._variables and key not in self._dataset._coord_names
374:        if key not in self._dataset._coord_names:
403:            if key not in self._dataset._coord_names
557:    _coord_names: set[Hashable]
567:        "_coord_names",
608:        self._coord_names = coord_names
703:                if n not in self._coord_names
750:            (type(self), self._variables, self._coord_names, self._attrs)
821:            self._coord_names,
872:            self._coord_names,
960:        obj._coord_names = coord_names
990:                self._coord_names = coord_names
1004:                coord_names = self._coord_names.copy()
1076:        new_coord_names = self._coord_names.copy()
1095:            new_coord_names.add(name)
1109:            new_coord_names.remove(name)
1112:            variables=new_variables, coord_names=new_coord_names, indexes=new_indexes
1118:            new_variables, new_coord_names = replaced._rename_vars({}, rename_dims)
1120:                variables=new_variables, coord_names=new_coord_names, dims=dims
1286:                if ref_name in self._coord_names or ref_name in self.dims:
1302:            if k not in self._coord_names:
1327:            if k in self._coord_names and set(self.variables[k].dims) <= needed_dims:
1352:        yield HybridMappingProxy(keys=self._coord_names, mapping=self.coords)
1566:        self._coord_names.discard(key)
1581:        return self._coord_names == other._coord_names and utils.dict_equiv(
1696:        obj._coord_names.update(names)
1720:            names = self._coord_names - set(self._indexes)
1733:        obj._coord_names.difference_update(names)
2402:        coord_names = self._coord_names.copy()
2461:        coord_names = self._coord_names & variables.keys()
2468:        coord_names = self._coord_names & variables.keys() | coord_vars.keys()
2550:                    if k in self._coord_names:
2815:            new_coord_names = self._coord_names | set(new_indexes)
2817:                new_variables, new_coord_names, indexes=new_indexes
3383:        coord_names = obj._coord_names & variables.keys()
3404:        coord_names = obj._coord_names & variables.keys() | coord_vars.keys()
3517:            if k in self._coord_names:
3535:            new_coord_names = [name_dict.get(k, k) for k in coord_names]
3536:            indexes.update({k: new_index for k in new_coord_names})
3540:                    for old, new in zip(coord_names, new_coord_names)
3582:            if k in self.dims and new_k in self._coord_names:
3586:            elif k in self._coord_names and new_k in self.dims:
3799:        coord_names = self._coord_names.copy()
3908:        coord_names = self._coord_names.copy()
4047:            current_coord_names = self.xindexes.get_all_coords(dim, errors="ignore")
4050:            maybe_drop_indexes += list(current_coord_names) + var_names
4071:                        k: self._variables[k] for k in current_coord_names
4102:        coord_names = self._coord_names - set(drop_variables) | set(new_variables)
4180:        coord_names = set(new_variables) | self._coord_names
4321:        new_coord_names = set(self._coord_names)
4338:                new_coord_names.update(idx_vars)
4344:            new_variables, coord_names=new_coord_names, indexes=indexes
4544:        coord_names = set(self._coord_names) - {dim} | set(new_indexes)
4595:        coord_names = set(self._coord_names) - {dim} | set(new_dim_sizes)
4889:                idx_coord_names = set(maybe_midx.index.names + [maybe_midx.dim])
4890:                idx_other_names = idx_coord_names - set(names)
4904:        coord_names = {k for k in self._coord_names if k in variables}
6312:            if k in self._coord_names:
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nds = ds.set_index(z=['a', 'b'])\nprint(ds)\nprint('vars', list(ds._variables), 'coords', ds._coord_names, 'dims', ds.dims)\nprint('indexes', ds._indexes)\nprint('all coords z', list(ds.xindexes.get_all_coords('z')))\n\""
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
vars ['z', 'a', 'b'] coords {'z', 'a', 'b'} dims Frozen({'z': 3})
indexes {'z': <xarray.core.indexes.PandasMultiIndex object at 0x71637e3866c0>, 'a': <xarray.core.indexes.PandasMultiIndex object at 0x71637e3866c0>, 'b': <xarray.core.indexes.PandasMultiIndex object at 0x71637e3866c0>}
all coords z ['z', 'a', 'b']
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nds = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)\nprint('vars', list(ds._variables), 'coords', ds._coord_names, 'dims', ds.dims)\nprint('indexes', ds._indexes)\n\""
}
```

**tool result**

```
vars ['a', 'b'] coords {'a', 'z', 'b'} dims Frozen({'z': 3})
indexes {}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '4080,4110p' xarray/core/dataset.py; grep -n \"reset_index\" xarray/tests/test_dataset.py | head -30"
}
```

**tool result**

```
                for n in idx.index.names:
                    replace_dims[n] = dim

            new_indexes.update({k: idx for k in idx_vars})
            new_variables.update(idx_vars)

        indexes_: dict[Any, Index] = {
            k: v for k, v in self._indexes.items() if k not in maybe_drop_indexes
        }
        indexes_.update(new_indexes)

        variables = {
            k: v for k, v in self._variables.items() if k not in drop_variables
        }
        variables.update(new_variables)

        # update dimensions if necessary, GH: 3512
        for k, v in variables.items():
            if any(d in replace_dims for d in v.dims):
                new_dims = [replace_dims.get(d, d) for d in v.dims]
                variables[k] = v._replace(dims=new_dims)

        coord_names = self._coord_names - set(drop_variables) | set(new_variables)

        return self._replace_with_new_dims(
            variables, coord_names=coord_names, indexes=indexes_
        )

    def reset_index(
        self: T_Dataset,
        dims_or_levels: Hashable | Sequence[Hashable],
3240:    def test_reset_index(self) -> None:
3248:        obj = ds.reset_index("x")
3254:            ds.reset_index("y")
3256:    def test_reset_index_keep_attrs(self) -> None:
3259:        obj = ds.reset_index("coord_1")
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '3230,3280p' xarray/tests/test_dataset.py; grep -rn \"reset_index\" xarray/tests/test_dataarray.py | head"
}
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline --all | head; git remote -v; git branch -a"
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
        expected["level_1"].attrs["foo"] = "bar"

        reindexed = ds.reorder_levels(x=["level_2", "level_1"])
        assert_identical(reindexed, expected)

        ds = Dataset({}, coords={"x": [1, 2]})
        with pytest.raises(ValueError, match=r"has no MultiIndex"):
            ds.reorder_levels(x=["level_1", "level_2"])

    def test_stack(self) -> None:
1297:        expected = ds.reset_index("xy").isel(xy=ds["x"] < 4)
2007:    def test_reset_index(self) -> None:
2013:        obj = self.mda.reset_index("x")
2016:        obj = self.mda.reset_index(self.mindex.names)
2019:        obj = self.mda.reset_index(["x", "level_1"])
2024:        obj = self.mda.reset_index(["level_1"])
2031:        obj = self.mda.reset_index("x", drop=True)
2035:        array = array.reset_index(["x"], drop=True)
2040:        obj = array.reset_index("x")
2044:    def test_reset_index_keep_attrs(self) -> None:
```

**tool result**

```
e90b06dd SWE-bench
45c0a114 Raise UserWarning when rename creates a new dimension coord (#6999)
87596ded add dictionary-based integer assignment example (GH7043) (#7072)
77b9e8a9 Fill in missing docstrings for ndarray properties (#7090)
404a6e26 Clearer variable names (#7082)
3977bc2a Bump codecov/codecov-action from 3.1.0 to 3.1.1 (#7081)
e755023a [pre-commit.ci] pre-commit autoupdate (#7083)
212a5d79 Set sharex/sharey to false if using 3d plots (#7047)
968443c8 Add helper for setting axis limits in facetgrid (#7046)
bda0a2fa Use micromamba in ASV benchmark workflow (#6926)
* main
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1995,2055p' xarray/tests/test_dataarray.py; sed -n '4040,4085p' xarray/core/dataset.py"
}
```

**tool result**

```
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
            invalid_vars = set(var_names) - set(self._variables)
            if invalid_vars:
                raise ValueError(
                    ", ".join([str(v) for v in invalid_vars])
                    + " variable(s) do not exist"
                )

            current_coord_names = self.xindexes.get_all_coords(dim, errors="ignore")

            # drop any pre-existing index involved
            maybe_drop_indexes += list(current_coord_names) + var_names
            for k in var_names:
                maybe_drop_indexes += list(
                    self.xindexes.get_all_coords(k, errors="ignore")
                )

            drop_variables += var_names

            if len(var_names) == 1 and (not append or dim not in self._indexes):
                var_name = var_names[0]
                var = self._variables[var_name]
                if var.dims != (dim,):
                    raise ValueError(
                        f"dimension mismatch: try setting an index for dimension {dim!r} with "
                        f"variable {var_name!r} that has dimensions {var.dims}"
                    )
                idx = PandasIndex.from_variables({dim: var})
                idx_vars = idx.create_variables({var_name: var})
            else:
                if append:
                    current_variables = {
                        k: self._variables[k] for k in current_coord_names
                    }
                else:
                    current_variables = {}
                idx, idx_vars = PandasMultiIndex.from_variables_maybe_expand(
                    dim,
                    current_variables,
                    {k: self._variables[k] for k in var_names},
                )
                for n in idx.index.names:
                    replace_dims[n] = dim

            new_indexes.update({k: idx for k in idx_vars})
            new_variables.update(idx_vars)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/core/dataset.py\n@@\n-        coord_names = set(new_variables) | self._coord_names\n+        coord_names = self._coord_names - set(drop_variables) | set(new_variables)\n \n         return self._replace(variables, coord_names=coord_names, indexes=indexes)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/core/dataset.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/core/dataset.py now (8935 lines), around the change:
4177:        }
4178:        variables.update(new_variables)
4179:
4180:        coord_names = self._coord_names - set(drop_variables) | set(new_variables)
4181:
4182:        return self._replace(variables, coord_names=coord_names, indexes=indexes)
4183:
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport xarray as xr\nds = xr.Dataset(coords={'a': ('x', [1, 2, 3]), 'b': ('x', ['a', 'b', 'c'])})\nds = ds.set_index(z=['a', 'b']).reset_index('z', drop=True)\nprint(ds)\nprint(len(ds.data_vars))\n\"; python -m pytest xarray/tests/test_dataset.py -k 'reset_index or set_index' -q 2>&1 | tail -20"
}
```

**tool result**

```
<xarray.Dataset>
Dimensions:  (z: 3)
Coordinates:
    a        (z) int64 1 2 3
    b        (z) <U1 'a' 'b' 'c'
Dimensions without coordinates: z
Data variables:
    *empty*
0
...                                                                      [100%]
3 passed, 370 deselected in 2.47s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataarray.py -k 'reset_index' -q 2>&1 | tail -10"
}
```

**tool result**

```
..                                                                       [100%]
2 passed, 448 deselected in 1.02s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_dataset.py\n@@\n     def test_reset_index_keep_attrs(self) -> None:\n         coord_1 = DataArray([1, 2], dims=[\"coord_1\"], attrs={\"attrs\": True})\n         ds = Dataset({}, {\"coord_1\": coord_1})\n         obj = ds.reset_index(\"coord_1\")\n         assert_identical(obj, ds, check_default_indexes=False)\n         assert len(obj.xindexes) == 0\n \n+    def test_reset_index_drop_multindex(self) -> None:\n+        # regression test for GH7022\n+        ds = Dataset(coords={\"a\": (\"x\", [1, 2, 3]), \"b\": (\"x\", [\"a\", \"b\", \"c\"])})\n+        actual = ds.set_index(z=[\"a\", \"b\"]).reset_index(\"z\", drop=True)\n+        expected = Dataset(coords={\"a\": (\"z\", [1, 2, 3]), \"b\": (\"z\", [\"a\", \"b\", \"c\"])})\n+        assert_identical(actual, expected, check_default_indexes=False)\n+        assert len(actual.data_vars) == 0\n+\n     def test_reorder_levels(self) -> None:\n         ds = create_test_multiindex()\n         mindex = ds[\"x\"].to_index()\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/tests/test_dataset.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/tests/test_dataset.py now (6673 lines), around the change:
3259:        obj = ds.reset_index("coord_1")
3260:        assert_identical(obj, ds, check_default_indexes=False)
3261:        assert len(obj.xindexes) == 0
3262:
3263:    def test_reset_index_drop_multindex(self) -> None:
3264:        # regression test for GH7022
3265:        ds = Dataset(coords={"a": ("x", [1, 2, 3]), "b": ("x", ["a", "b", "c"])})
3266:        actual = ds.set_index(z=["a", "b"]).reset_index("z", drop=True)
3267:        expected = Dataset(coords={"a": ("z", [1, 2, 3]), "b": ("z", ["a", "b", "c"])})
3268:        assert_identical(actual, expected, check_default_indexes=False)
3269:        assert len(actual.data_vars) == 0
3270:
3271:    def test_reorder_levels(self) -> None:
3272:        ds = create_test_multiindex()
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataset.py -k 'reset_index' -q 2>&1 | tail -8; git diff --stat; git status --porcelain -- . ':(exclude).memdoor'"
}
```

**tool result**

```
...                                                                      [100%]
3 passed, 371 deselected in 1.26s
 xarray/core/dataset.py       | 2 +-
 xarray/tests/test_dataset.py | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)
 M xarray/core/dataset.py
 M xarray/tests/test_dataset.py
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataset.py xarray/tests/test_dataarray.py -q 2>&1 | tail -5"
}
```

**tool result**

```
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/ma/core.py:7939: DeprecationWarning: elementwise comparison failed; this will raise an error in the future.
    if not np.all(xinf == filled(np.isinf(y), False)):

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
813 passed, 2 skipped, 7 xfailed, 2 xpassed, 7 warnings in 18.56s
```

**assistant**

````
Fixed. Root cause: `Dataset.reset_index` computed

```python
coord_names = set(new_variables) | self._coord_names
```

which never removed the dropped index/level names from `_coord_names`. With `drop=True` those names are removed from `_variables` but stayed in `_coord_names`, so `DataVariables.__len__` returned a negative number and the repr crashed with `ValueError: __len__() should return >= 0`.

Change:
- `xarray/core/dataset.py`: use `self._coord_names - set(drop_variables) | set(new_variables)`, mirroring the logic already used in `set_index`.
- `xarray/tests/test_dataset.py`: added `test_reset_index_drop_multindex` regression test based on the MVCE.

Verified: the MVCE now renders correctly (empty data vars, no stray `z` coordinate name), and the full dataset/dataarray test suites pass (813 passed, 2 skipped, 7 xfailed, 2 xpassed). `git status --porcelain` is non-empty, satisfying the task check.
````

## Run folder `single-2026-11-06T114757`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

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
