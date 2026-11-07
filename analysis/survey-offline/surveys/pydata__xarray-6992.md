# Survey: `_coord_names` outnumbering `_variables` on `Dataset`

The issue: `DataVariables` treats every name in `_variables` that is not in
`_coord_names` as a data variable, and computes its length as
`len(_variables) - len(_coord_names)`. After the index refactor, `set_index` /
`reset_index` can leave names in `_coord_names` with no matching variable, so
that subtraction goes negative and `len()` raises `ValueError: __len__() should
return >= 0` (and the repr misreports data variables). Paths the issue names
come first.

## Paths named by the issue

- `xarray/core/dataset.py:DataVariables.__len__` — returns `len(_variables) - len(_coord_names)`, the exact line the issue links and the source of the negative length / `ValueError`.
- `xarray/core/dataset.py:DataVariables.__iter__` — yields keys of `_variables` not in `_coord_names`, the same "everything not a coord is a data var" assumption in iteration form.
- `xarray/core/dataset.py:DataVariables.__contains__` — tests membership as "in `_variables` and not in `_coord_names`", the same assumption for `in`.
- `xarray/core/dataset.py:DataVariables.__getitem__` — returns `self._dataset[key]` whenever the key is not in `_coord_names`, so a stale coord name can be served as a data variable.
- `xarray/core/dataset.py:DataVariables.variables` — builds a `Frozen` mapping by iterating `self` (the same filtered view) over `dataset.variables`.
- `xarray/core/dataset.py:DataVariables.dtypes` — delegates to `Dataset.dtypes`, which filters `_variables` by `_coord_names` with the same assumption.
- `xarray/core/dataset.py:DataVariables._ipython_key_completions_` — filters completions by `_coord_names`, so stale coord names are hidden from completion.
- `xarray/core/dataset.py:DataVariables.__repr__` — calls `formatting.data_vars_repr(self)`, which calls `len(self)` and therefore triggers the negative-length error.
- `xarray/core/dataset.py:Dataset.__repr__` — calls `formatting.dataset_repr(self)`, the repr path the issue says breaks.
- `xarray/core/dataset.py:Dataset._repr_html_` — calls `formatting_html.dataset_repr(self)`, the HTML sibling of the text repr.
- `xarray/core/dataset.py:Dataset.data_vars` — constructs the `DataVariables` view over `self`, the entry point for all of the above.
- `xarray/core/dataset.py:Dataset.set_index` — builds `coord_names = self._coord_names - drop_variables | set(new_variables)` and can leave coord names whose variables were dropped, creating the inconsistent state.
- `xarray/core/dataset.py:Dataset.reset_index` — builds `coord_names = self._coord_names - drop_variables` and drops variables without pruning their names, the operation in the MVCE that produces more `_coord_names` than `_variables`.

## Repr / formatting siblings

- `xarray/core/formatting.py:_mapping_repr` — calls `len(mapping)` and `mapping.items()` on the `DataVariables` view, so it inherits the bad length and the filtered iteration.
- `xarray/core/formatting.py:data_vars_repr` — the `functools.partial` used for the "Data variables" section, the direct caller of `_mapping_repr` for `DataVariables`.
- `xarray/core/formatting.py:dataset_repr` — assembles the text repr and calls `data_vars_repr(ds.data_vars, ...)`, the top of the text-repr path.
- `xarray/core/formatting.py:coords_repr` — the parallel "Coordinates" section built on the same `_mapping_repr`, formatting the other side of the same `_coord_names` split.
- `xarray/core/formatting.py:diff_data_vars_repr` — the diff-repr partial over `a.data_vars`/`b.data_vars`, a second formatter of the same data-variable view.
- `xarray/core/formatting.py:diff_dataset_repr` — calls `diff_data_vars_repr(a.data_vars, b.data_vars, ...)`, the diff counterpart of `dataset_repr`.
- `xarray/core/formatting.py:_diff_mapping_repr` — iterates `set(a_mapping)`/`set(b_mapping)` and indexes them, the diff analogue of `_mapping_repr`.
- `xarray/core/formatting_html.py:dataset_repr` — builds the HTML repr and calls `datavar_section(ds.data_vars)`, the HTML sibling of the text repr.
- `xarray/core/formatting_html.py:_mapping_section` — calls `len(mapping)` for the section count, so the HTML "Data variables" section also hits the bad length.
- `xarray/core/formatting_html.py:datavar_section` — the partial that renders the "Data variables" section from `ds.data_vars`.
- `xarray/core/formatting_html.py:summarize_vars` — iterates `variables.items()` for the data-variable list, the HTML analogue of `data_vars_repr`.
- `xarray/core/formatting_html.py:summarize_coords` — the coordinate-section sibling iterating the coordinate view.

## Dataset-level consumers of the same assumption

- `xarray/core/dataset.py:Dataset.__len__` — returns `len(self.data_vars)`, so `len(ds)` inherits the negative/incorrect count.
- `xarray/core/dataset.py:Dataset.__bool__` — returns `bool(self.data_vars)`, so truthiness of a dataset depends on the same filtered view.
- `xarray/core/dataset.py:Dataset.__iter__` — returns `iter(self.data_vars)`, iterating the same filtered keys.
- `xarray/core/dataset.py:Dataset.dtypes` — filters `_variables` by `_coord_names` to build data-variable dtypes, the same "not a coord means data var" rule.
- `xarray/core/dataset.py:Dataset._item_sources` — yields `self.data_vars` for attribute/key lookup, so stale coord names affect attribute access.
- `xarray/core/dataset.py:Dataset._construct_dataarray` — selects coords by `k in self._coord_names` over `_variables`, the coordinate-side counterpart of the same split.
- `xarray/core/dataset.py:Dataset._copy_listed` — copies variables whose names are in `_coord_names`, assuming every coord name has a variable.
- `xarray/core/dataset.py:Dataset._rename_vars` — rebuilds `coord_names` from `k in self._coord_names` while iterating `self.variables`, so stale names are silently dropped or carried depending on the path.
- `xarray/core/dataset.py:Dataset._overwrite_indexes` — adds index variables to `new_coord_names` and removes dropped names, another place coord names and variables can diverge.
- `xarray/core/dataset.py:Dataset._replace` — installs `variables` and `coord_names` independently with no consistency check, the low-level door through which the mismatch survives.
- `xarray/core/dataset.py:Dataset._construct_direct` — assigns `_variables` and `_coord_names` directly with no validation, the fastpath that can persist an inconsistent pair.
- `xarray/core/dataset.py:Dataset._replace_with_new_dims` — recomputes dims but passes `coord_names` through unchanged, so it does not repair the mismatch.
- `xarray/core/dataset.py:Dataset.__delitem__` — deletes from `_variables` and discards from `_coord_names`, the in-place path that keeps them in sync (contrast with `reset_index`).
- `xarray/core/dataset.py:Dataset.set_coords` — updates `_coord_names` from names asserted to be in `_variables`, the operation that can add coord names.
- `xarray/core/dataset.py:Dataset.reset_coords` — removes names from `_coord_names` and optionally deletes variables, the sibling of `reset_index` for non-index coords.
- `xarray/core/dataset.py:Dataset.drop_vars` — prunes `coord_names` to names still in `variables`, the correct pattern that `reset_index` does not follow.
- `xarray/core/dataset.py:Dataset.swap_dims` — copies `_coord_names` and adds new dimension names, another coord-name mutation site.
- `xarray/core/dataset.py:Dataset.stack` — starts from `set(self._coord_names)` and adds index variables, another place the two structures are updated separately.
- `xarray/core/dataset.py:Dataset.unstack` — computes `set(self._coord_names) - {dim} | set(new_indexes)`, the same set arithmetic pattern as `set_index`/`reset_index`.
- `xarray/core/dataset.py:Dataset.reindex` — unions `_coord_names` with new index names, another coord-name/variable divergence site.
- `xarray/core/dataset.py:Dataset._unary_op` — branches on `k in self._coord_names` while iterating `_variables`, the same coord/data split for arithmetic.
- `xarray/core/dataset.py:Dataset._calculate_binary_op` — iterates `self.data_vars` and writes into `ds._variables`, so a bad data-variable view propagates into arithmetic results.
- `xarray/core/dataset.py:Dataset.to_array` — builds the stacked array from `[self.variables[k] for k in self.data_vars]`, so a stale view changes the result.
- `xarray/core/dataset.py:Dataset.to_dict` — emits `data_vars` by iterating `self.data_vars`, the serialization sibling of the repr.
- `xarray/core/dataset.py:Dataset.to_dataframe` — selects columns as `k for k in self.variables if k not in self.dims`, a parallel "not a dim" filter rather than the coord filter.
- `xarray/core/dataset.py:Dataset.to_dask_dataframe` — extends columns with `self.data_vars`, the dask sibling of `to_dataframe`.
- `xarray/core/dataset.py:Dataset.info` — iterates `self.variables` and prints all variables, a summary that bypasses the data-var filter.
- `xarray/core/dataset.py:Dataset.dropna` — defaults `subset` to `iter(self.data_vars)`, so the bad view changes which variables are checked.
- `xarray/core/dataset.py:Dataset.fillna` — validates keys against `set(self.data_vars.keys())`, the same view used for validation.
- `xarray/core/dataset.py:Dataset.rank` — branches on `name in self.data_vars` while iterating `self.variables`, the same split.
- `xarray/core/dataset.py:Dataset.pad` — branches on `name in self.data_vars` while iterating `self.variables`, the same split.
- `xarray/core/dataset.py:Dataset.curvefit` — iterates `self.data_vars.items()`, another consumer of the filtered view.

## Coordinate containers and merge/concat siblings

- `xarray/core/coordinates.py:Coordinates.__len__` — returns `len(self._names)`, the coordinate-side length that can exceed the number of variables.
- `xarray/core/coordinates.py:Coordinates.__iter__` — yields names from `self.variables` that are in `_names`, the coordinate analogue of `DataVariables.__iter__`.
- `xarray/core/coordinates.py:DatasetCoordinates._names` — returns `self._data._coord_names` directly, the raw set that can contain names with no variable.
- `xarray/core/coordinates.py:DatasetCoordinates.variables` — filters `_data.variables` by `_names`, so stale coord names simply vanish from the mapping.
- `xarray/core/coordinates.py:DatasetCoordinates.dtypes` — filters `_variables` by `_coord_names`, the coordinate-side twin of `Dataset.dtypes`.
- `xarray/core/coordinates.py:DatasetCoordinates.to_dataset` — selects `[name for name in _variables if name in _names]`, silently dropping stale coord names.
- `xarray/core/coordinates.py:DatasetCoordinates._update_coords` — updates `_variables` and `_coord_names` in place without pruning, another divergence site.
- `xarray/core/coordinates.py:Coordinates.__repr__` — calls `formatting.coords_repr(self)`, the coordinate repr sibling of the data-variable repr.
- `xarray/core/coordinates.py:DataArrayCoordinates._names` — returns `set(self._data._coords)`, the DataArray analogue where names and variables cannot diverge.
- `xarray/core/coordinates.py:DataArrayCoordinates.to_dataset` — constructs a Dataset with `set(coords)` as coord names, the DataArray-to-Dataset sibling.
- `xarray/core/merge.py:determine_coords` — collects `coord_names` from `mapping.coords` and `noncoord_names` from `mapping.data_vars`, the same split used when merging.
- `xarray/core/merge.py:merge_core` — builds `coord_names` from `determine_coords` and adds dims, the merge path that can leave coord names without variables (issue #7588).
- `xarray/core/merge.py:merge_data_and_coords` — the `Dataset.__init__` path that produces the initial `coord_names`/`variables` pair.
- `xarray/core/concat.py:_calc_concat_over` — accumulates `all_coord_names` and `data_vars` from `ds.coords`/`ds.data_vars`, the concat analogue of the split.
- `xarray/core/concat.py:_dataset_concat` — checks `coord_names - set(result.variables)` and calls `set_coords`, a place that explicitly guards against the mismatch.
- `xarray/core/parallel.py:dataset_to_dataarray` — uses `len(obj.data_vars)` and `next(iter(obj.data_vars.values()))`, so the bad view can raise or pick the wrong variable.
- `xarray/core/parallel.py:map_blocks` — partitions variables by `name in dataset._coord_names` and later calls `result.set_coords(template._coord_names)`, the dask sibling of the coord/data split.
- `xarray/core/alignment.py:_broadcast_dataset` — rebuilds a Dataset from `{k: ... for k in ds.data_vars}` plus `ds.coords`, the alignment consumer of the same view.
- `xarray/core/groupby.py:_dummy_copy` — iterates `xarray_obj.data_vars.items()` to build fill values, a groupby consumer of the filtered view.
- `xarray/core/groupby.py:GroupBy._flox_reduce` — iterates `obj.data_vars.items()` to find non-numeric variables, another consumer of the filtered view.
- `xarray/core/missing.py:_apply_over_vars_with_dim` — iterates `self.data_vars.items()` for interpolation, the missing-value sibling.
- `xarray/core/rolling.py:DatasetRolling.__init__` — iterates `self.obj.data_vars.items()` to build rolling variables, the rolling consumer of the same view.
- `xarray/backends/api.py:open_dataarray` — checks `len(dataset.data_vars) != 1` and unpacks `dataset.data_vars.values()`, a backend consumer that depends on the count.
- `xarray/backends/api.py:_validate_datatypes_for_zarr_append` — iterates `dataset.data_vars.items()` to validate dtypes, another backend consumer.
- `xarray/core/dataarray.py:DataArray.set_index` — delegates to `self._to_temp_dataset().set_index(...)`, the DataArray entry point into the same `set_index` logic.
- `xarray/core/dataarray.py:DataArray.reset_index` — delegates to `self._to_temp_dataset().reset_index(...)`, the DataArray entry point into the same `reset_index` logic.
- `xarray/core/dataarray.py:DataArray._from_temp_dataset` — pops `_THIS_ARRAY` and treats the remaining `_variables` as coords, the round-trip that can inherit an inconsistent coord set.
