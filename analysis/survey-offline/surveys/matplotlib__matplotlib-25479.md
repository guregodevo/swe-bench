# Survey: colormap lookup uses `Colormap.name` instead of the registered name

One line per code path; the paths the issue names come first.

- `lib/matplotlib/pyplot.py:set_cmap` — resolves the argument to a `Colormap` with `get_cmap` and then stores `cmap.name` (the object's internal name, e.g. `some_cmap_name`) into `rcParams["image.cmap"]` instead of the name it was registered under, which is the root of the reported `imshow` failure.
- `lib/matplotlib/pyplot.py:imshow` — thin wrapper that forwards `cmap=None` to `gca().imshow`, so the bad rc value is never surfaced here and the failure happens later.
- `lib/matplotlib/axes/_axes.py:Axes.imshow` — passes the (defaulted) `cmap=None` straight into `mimage.AxesImage`, again deferring the name lookup.
- `lib/matplotlib/image.py:_ImageBase.__init__` — calls `cm.ScalarMappable.__init__(self, norm, cmap)` with the still-`None` cmap, making the rc default the thing that gets resolved.
- `lib/matplotlib/cm.py:ScalarMappable.__init__` — calls `self.set_cmap(cmap)` during construction, so the rc-derived name is resolved through the ordinary cmap setter.
- `lib/matplotlib/cm.py:ScalarMappable.set_cmap` — calls `_ensure_cmap(cmap)`, the single conversion point where the string from rc is turned back into a colormap.
- `lib/matplotlib/cm.py:_ensure_cmap` — when `cmap is None`, reads `rcParams["image.cmap"]` (the internal `cmap.name` written by `set_cmap`) and looks it up in `mpl.colormaps`, raising the "not recognized" error when the internal and registered names differ.
- `lib/matplotlib/cm.py:ColormapRegistry.__getitem__` — the actual name-to-colormap table lookup that fails with `KeyError`/the "is not a known colormap name" error for the internal name.
- `lib/matplotlib/cm.py:ColormapRegistry.get_cmap` — the other lookup entry point (`mpl.colormaps.get_cmap`), which takes the same names and therefore has the same two-names-one-object ambiguity.
- `lib/matplotlib/cm.py:_get_cmap` — legacy/modern `get_cmap` implementation; it validates the name against `_colormaps` and returns `_colormaps[name]`, which is why `cm.get_cmap('my_cmap_name')` succeeds while the rc lookup of `some_cmap_name` does not.
- `lib/matplotlib/cm.py:ColormapRegistry.register` — registers the copy under `name = name or cmap.name` but leaves `cmap.name` untouched, creating the duplicate name tables the issue describes.
- `lib/matplotlib/cm.py:register_cmap` — deprecated public registration API; resolves `name = cmap.name` when no name is given, and otherwise stores an object whose `.name` still differs from the registered key.
- `lib/matplotlib/cm.py:unregister_cmap` — removes by registry key only, so the internal `.name` of an already-fetched colormap can still point at a name that is no longer registered.
- `lib/matplotlib/rcsetup.py:_validate_cmap` — accepts any `str` (including an internal `cmap.name` that is not a registry key) without checking `mpl.colormaps`, so `rc('image', cmap=...)`/`set_cmap` can install an unresolvable default.
- `lib/matplotlib/colors.py:Colormap.__init__` — sets `self.name` independently of any registry, the object-level half of the "double internal name lookup tables".
- `lib/matplotlib/colors.py:Colormap.copy` / `Colormap.__copy__` — copies `.name` verbatim, so the registry's snapshot keeps the original internal name even when registered under another.
- `lib/matplotlib/colors.py:Colormap.reversed` (and `LinearSegmentedColormap.reversed`, `ListedColormap.reversed`) — derive a new name from `self.name`, propagating the internal (rather than registered) name to reversed copies.
- `lib/matplotlib/colors.py:ListedColormap.resampled` — rebuilds a colormap with `name=self.name`, another place the internal name is carried forward instead of the registry key.
- `lib/matplotlib/pyplot.py:get_cmap` — pyplot alias of `cm._get_cmap`, looking names up in the registry only; it confirms the registered name resolves but does not fix the rc name mismatch.
- `lib/matplotlib/pyplot.py:autumn` (and the sibling `bone`, `cool`, `copper`, `flag`, `gray`, `hot`, `hsv`, `jet`, `pink`, `prism`, `spring`, `summer`, `winter`, `magma`, `inferno`, `plasma`, `viridis`, `nipy_spectral` functions) — each just calls `set_cmap("<name>")` and therefore goes through the same `cmap.name`-to-rc path.
- `lib/matplotlib/figure.py:Figure.colorbar` — builds `cm.ScalarMappable(norm=norm, cmap=cmap)` for a cmap/norm pair, so a string cmap follows the same `_ensure_cmap`/registry path (and its `cmap.name` is what the colorbar later shows).
- `lib/matplotlib/colorbar.py:Colorbar.__init__` — constructs `cm.ScalarMappable(norm=norm, cmap=cmap)` when no mappable is supplied, a parallel user of the same resolution path.
- `lib/matplotlib/contour.py:ContourSet.__init__` — builds `cm.ScalarMappable(cmap=cmap, norm=...)` for labeling, again resolving/cmap-name via the shared setter.
- `lib/matplotlib/image.py:imsave` — builds `cm.ScalarMappable(cmap=cmap)` and calls `to_rgba`, so a registered-name-vs-internal-name mismatch is resolved (or not) by the same machinery.
- `lib/matplotlib/streamplot.py:streamplot` — calls `cm._ensure_cmap(cmap)` directly (line ~190) and then `lc.set_cmap(cmap)`, duplicating the `_ensure_cmap` name-resolution path for multicolored streamlines.
- `lib/matplotlib/image.py:AxesImage.set_cmap` — overrides `ScalarMappable.set_cmap` but only adds a data-loaded guard before calling `super().set_cmap(cmap)`, so it inherits the same name handling.
- `lib/matplotlib/backends/qt_editor/figureoptions.py:figure_edit` — lists registered cmaps as `(cmap, name)` but labels unmatched mappables with `cmap.name`, the GUI-side sibling that conflates the registry key with the object's internal name.
