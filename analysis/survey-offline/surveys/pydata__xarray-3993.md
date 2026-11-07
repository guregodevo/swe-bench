# Survey: `DataArray.integrate` uses `dim` while `Dataset.integrate` uses `coord`

One line per code path that produces or propagates the inconsistent `dim`/`coord` API described in issue.md.

- `xarray/core/dataarray.py:DataArray.integrate` — the public API the issue names: its signature is `integrate(self, dim, datetime_unit=None)`, so `da.integrate(dim="x")` is the only accepted keyword and the docstring documents `dim` as "Coordinate(s) used for the integration".
- `xarray/core/dataset.py:Dataset.integrate` — the sibling public API the issue contrasts it with: its signature is `integrate(self, coord, datetime_unit=None)`, so `ds.integrate(coord="x")` works and the docstring documents `coord`.
- `xarray/core/dataarray.py:DataArray.differentiate` — the other public API shown in the issue: it already takes `coord` (`differentiate(self, coord, ...)`), establishing the naming that `DataArray.integrate` deviates from.
- `xarray/core/dataset.py:Dataset.differentiate` — the Dataset sibling of `differentiate`, also taking `coord`, so both `differentiate` methods agree while `DataArray.integrate` is the odd one out.
- `xarray/core/dataarray.py:DataArray.integrate` (body) — forwards its `dim` argument positionally to `self._to_temp_dataset().integrate(dim, datetime_unit)`, so the wrong keyword is silently accepted and the Dataset implementation never sees a `dim` keyword.
- `xarray/core/dataset.py:Dataset.integrate` (body) — normalizes `coord` to a tuple and loops over it calling `_integrate_one`, so the actual integration work is keyed on the `coord` name.
- `xarray/core/dataset.py:Dataset._integrate_one` — the private implementation where the behaviour happens: it looks the name up in `self.variables`/`self.dims`, requires a 1-D coordinate, and calls `duck_array_ops.trapz` along that coordinate's dimension.
- `xarray/core/duck_array_ops.py:trapz` — the low-level trapezoidal integration helper that consumes the coordinate values as the `x` spacing, which is why the argument is semantically a coordinate rather than a bare dimension.
- `xarray/core/duck_array_ops.py:gradient` — the analogous low-level helper used by both `differentiate` methods, taking `coord` as the spacing argument and reinforcing the `coord` naming.
- `xarray/core/dataarray.py:DataArray._to_temp_dataset` — the adapter that wraps the DataArray as a temporary Dataset so `DataArray.integrate` can delegate to `Dataset.integrate`, carrying the `dim` argument across the boundary.
- `xarray/core/dataarray.py:DataArray._from_temp_dataset` — the reverse adapter that unwraps the integrated Dataset back into a DataArray, completing the delegation path.
- `xarray/tests/test_units.py:test_computation` (DataArray parametrization) — calls `method("integrate", dim="x")` for DataArray, encoding the inconsistent keyword in the test suite.
- `xarray/tests/test_units.py:test_computation` (Dataset parametrization) — calls `method("integrate", coord="x")` for Dataset, encoding the sibling `coord` keyword in the same test.
- `xarray/tests/test_dataset.py:test_integrate` — exercises `da.integrate("x")` and `ds.integrate("x")` positionally, so it does not pin down the keyword name.
- `xarray/tests/test_sparse.py` (computation parametrization) — invokes `do("integrate", "x")` positionally, another call site that avoids the keyword and therefore does not catch the inconsistency.
- `doc/computation.rst` (integration section) — documents `a.integrate("x")` positionally and describes integration "using their coordinates", without exposing the `dim` keyword.
- `doc/api.rst` (Dataset and DataArray method lists) — lists `Dataset.integrate` and `DataArray.integrate` as public API entries, the surface where the inconsistent signature is published.
