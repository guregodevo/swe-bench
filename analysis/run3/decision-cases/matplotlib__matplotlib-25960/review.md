verdict: FAIL
- The change regresses existing subfigure tests: `test_subfigure_spanning` fails because `sub_figs[0].bbox.min` is `[0, 338.82]` instead of `[0, 320]`; `test_subfigure[png]`, `test_subfigure_double[png]`, and `test_subfigure_scatter_size[png]` also fail.
- In `lib/matplotlib/figure.py`, `SubFigure._redo_transform_rel_fig` takes `self._subplotspec.get_position(self._parent)` and then divides by `params.left/right/bottom/top`. That re-normalizes an already parent-relative position to the subplot area, shrinking/shifting subfigures and breaking spanning/full-parent layouts.
- The requested `wspace`/`hspace` should be honored via the GridSpec position, but the result must remain in the parent figure’s relative coordinates; the subplot-params normalization must be removed.

Repair instructions:
- In `lib/matplotlib/figure.py`, change `SubFigure._redo_transform_rel_fig` to use the `Bbox` returned by `self._subplotspec.get_position(self._parent)` directly as `bbox_relative` (or convert it to parent-relative coordinates using the parent bbox, not `gs.get_subplot_params`). Remove the `params = gs.get_subplot_params(...)` and the `(bbox.x0 - params.left) / ...` rescaling.
- Keep the existing `bbox_relative` update path (`p0`/`p1`) and ensure zero `wspace`/`hspace` still tiles the parent as before.
- Re-run `pytest lib/matplotlib/tests/test_figure.py -k subfigure`; `test_subfigure_spanning` must pass with the original full-parent tiling, and image tests should only be updated if the new spacing is the intended behavior.
