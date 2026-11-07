# Survey: unpicklable figure after `align_labels()`

The issue: `Figure.align_labels()` stores `Axes` in `cbook.Grouper` objects, which hold
`weakref.ref` keys/values; `Figure.__getstate__` never removes or converts
`_align_label_groups`, so `pickle.dumps(fig)` hits `TypeError: cannot pickle
'weakref.ReferenceType' object`.

## Paths the issue names

- `lib/matplotlib/figure.py:FigureBase.align_labels` — public entry point from the reproducer; just calls `align_xlabels` then `align_ylabels`, which is what populates the unpicklable groupers.
- `lib/matplotlib/figure.py:FigureBase.align_xlabels` — joins each Axes into `self._align_label_groups['x']` via `Grouper.join`, creating the weakrefs that later break pickling.
- `lib/matplotlib/figure.py:FigureBase.align_ylabels` — same as above for `self._align_label_groups['y']`, the second half of the weakref state left on the figure.
- `lib/matplotlib/figure.py:FigureBase.__init__` — creates `self._align_label_groups = {"x": cbook.Grouper(), "y": cbook.Grouper()}` on every Figure/SubFigure, so the groupers are always part of the pickled state.
- `lib/matplotlib/cbook.py:Grouper.__init__` — builds `_mapping` as `{weakref.ref(x): [weakref.ref(x)]}`, the actual `weakref.ReferenceType` objects pickle refuses.
- `lib/matplotlib/cbook.py:Grouper.join` — inserts `weakref.ref(a)`/`weakref.ref(arg)` into `_mapping`; called by both align methods and is where the unpicklable entries are added.
- `lib/matplotlib/cbook.py:Grouper.get_siblings` — reads `_mapping` by `weakref.ref(a)`; the consumer side of the same weakref structure.
- `lib/matplotlib/figure.py:Figure.__getstate__` — the pickle path that fails: it pops `canvas` and fixes `_dpi` but leaves `_align_label_groups` (with its weakrefs) in the state.
- `lib/matplotlib/figure.py:Figure.__setstate__` — the matching restore path; it would need to rebuild any pruned/replaced align-label groupers, and currently just assigns `self.__dict__ = state`.

## Other places that do the same thing the same way

- `lib/matplotlib/axis.py:Axis._get_tick_boxes_siblings` — reads `self.figure._align_label_groups[name]` and calls `get_siblings`, the draw-time consumer of the weakref groupers created by `align_*labels`.
- `lib/matplotlib/axis.py:XAxis._update_label_position` — uses `_get_tick_boxes_siblings` to align x labels, the behaviour that makes the groupers necessary.
- `lib/matplotlib/axis.py:YAxis._update_label_position` — parallel y-axis implementation of the same sibling-bbox alignment.
- `lib/matplotlib/axis.py:Axis.draw` — calls `_update_label_position` on every draw, so the align-label groupers are consulted after unpickling too.
- `lib/matplotlib/axes/_base.py:_AxesBase.__getstate__` — sibling pickling fix: prunes the class-level `_shared_axes`/`_twinned_axes` groupers down to plain sibling lists before pickling, exactly the treatment `_align_label_groups` lacks.
- `lib/matplotlib/axes/_base.py:_AxesBase.__setstate__` — sibling restore: re-joins the pruned shared/twinned siblings into the global groupers, the pattern a Figure fix would mirror.
- `lib/matplotlib/axes/_base.py:_AxesBase._shared_axes` — class-level `cbook.Grouper()` instances for shared axes, another weakref-holding grouper that had to be handled for pickling.
- `lib/matplotlib/axes/_base.py:_AxesBase._twinned_axes` — class-level `cbook.Grouper()` for twinned axes, same weakref structure and same getstate/setstate workaround.
- `lib/matplotlib/axes/_base.py:_AxesBase.get_shared_x_axes` — public accessor returning `cbook.GrouperView(self._shared_axes["x"])`, the read-only wrapper over a weakref grouper.
- `lib/matplotlib/axes/_base.py:_AxesBase.get_shared_y_axes` — parallel public accessor for the y shared-axes grouper.
- `lib/matplotlib/cbook.py:GrouperView` — immutable view over a `Grouper`; it forwards `get_siblings`/`joined` to the same weakref-backed mapping.
- `lib/matplotlib/cbook.py:CallbackRegistry.__getstate__` — sibling pickling pattern that deliberately drops unpicklable callback state and rebuilds it in `__setstate__`, the model for handling weakrefs at pickle time.
- `lib/matplotlib/cbook.py:CallbackRegistry.__setstate__` — rebuilds the weakref proxies dropped by `__getstate__`, the restore half of that pattern.
- `lib/matplotlib/artist.py:Artist.__getstate__` — base pickling hook that strips the unpicklable `stale_callback`; `Figure.__getstate__` calls it via `super()` before the align-label groupers are (not) handled.
- `lib/mpl_toolkits/mplot3d/axes3d.py:Axes3D` — adds `Axes._shared_axes["z"] = cbook.Grouper()`, extending the same weakref-grouper pickling concern to 3D axes.
