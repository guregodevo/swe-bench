# Repair

## Changes
- `xarray/core/dataarray.py`: removed the `ValueError` raised when `coord is None`;
  `coord=None` now integrates over all of `self.dims`, preserving the old
  all-coordinate behavior of `da.integrate()`. Changed the deprecated `dim`
  warning from `DeprecationWarning` to the user-visible `FutureWarning`, and
  dropped the now-wrong `Raises` docstring section.
- `xarray/tests/test_dataset.py`: replaced the incorrect
  `with pytest.raises(ValueError): da.integrate()` with an assertion that
  `da.integrate()` equals the independently computed all-coordinate integral
  and `da.integrate(("y", "x"))`; updated the `dim=` deprecation test to expect
  `FutureWarning`.

## Check
Command: `python -m pytest xarray/tests/test_dataarray.py xarray/tests/test_dataset.py`

Result: exit 1, `6 failed, 1800 passed, 17 skipped, 7 xfailed, 4 xpassed`.
The same 6 failures exist in the baseline (`baseline-check.log`):
`test_from_series_multiindex`, `test_sel_categorical`,
`test_sel_categorical_error`, `test_categorical_multiindex`,
`test_from_dataframe_categorical`, `test_polyfit_warnings`. The repaired
`test_integrate` passes (both parameters).
