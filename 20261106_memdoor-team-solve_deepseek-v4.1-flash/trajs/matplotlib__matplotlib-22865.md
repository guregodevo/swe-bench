# matplotlib__matplotlib-22865 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 432s 50 lines cost=0.016975 in=455473 cached=350720 out=33169 calls=31`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

[Bug]: Colorbar with drawedges=True and extend='both' does not draw edges at extremities
### Bug summary

When creating a matplotlib colorbar, it is possible to set drawedges to True which separates the colors of the colorbar with black lines. However, when the colorbar is extended using extend='both', the black lines at the extremities do not show up.

### Code for reproduction

```python
import matplotlib as mpl
import numpy as np
import matplotlib.pyplot as plt  
from matplotlib.colors import from_levels_and_colors

my_cmap = mpl.cm.viridis
bounds = np.arange(10)
nb_colors = len(bounds) + 1
colors = my_cmap(np.linspace(100, 255, nb_colors).astype(int))
my_cmap, my_norm = from_levels_and_colors(bounds, colors, extend='both')

plt.figure(figsize=(5, 1))
ax = plt.subplot(111)
cbar = mpl.colorbar.ColorbarBase(ax, cmap=my_cmap, norm=my_norm, orientation='horizontal', drawedges=True)
plt.subplots_adjust(left=0.05, bottom=0.4, right=0.95, top=0.9)
plt.show()
```


### Actual outcome

![image](https://user-images.githubusercontent.com/34058459/164254401-7516988d-1efb-4887-a631-de9a68357685.png)


### Expected outcome

![image](https://user-images.githubusercontent.com/34058459/164254881-92c167b7-aa13-4972-9955-48221b38b866.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.5.1

### Matplotlib Backend

_No response_

### Python version

_No response_

### Jupyter version

_No response_

### Installation

_No response_


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --short"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"drawedges\" lib/matplotlib/colorbar.py | head -50"
}
```

**tool result**

```
CITATION.bib
CODE_OF_CONDUCT.md
INSTALL.rst
LICENSE
README.rst
SECURITY.md
__pycache__
azure-pipelines.yml
build
ci
doc
environment.yml
examples
extern
lib
mplsetup.cfg.template
plot_types
pytest.ini
requirements
setup.cfg
setup.py
setupext.py
src
tests.py
tmp
tools
tox.ini
tutorials
98ae845d67 SWE-bench
c6c7ec1978 Merge pull request #22609 from anntzer/dvifonthelpers
89a7e19210 Improve usability of dviread.Text by third parties.
?? .memdoor/
```

**tool result**

```
105:drawedges : bool
294:        A LineCollection (empty if *drawedges* is ``False``).
328:    drawedges : bool
348:                 drawedges=False,
416:        self.drawedges = drawedges
651:            if not self.drawedges:
655:            np.dstack([X, Y])[1:-1] if self.drawedges else [])
```

**assistant → tool `read_file`**

```json
{
  "path": "lib/matplotlib/colorbar.py",
  "offset": 570,
  "limit": 120
}
```

**tool result**

```
            if not CS.filled:
                self.add_lines(CS)
        self.stale = True

    @_api.deprecated("3.6", alternative="fig.draw_without_rendering()")
    def draw_all(self):
        """
        Calculate any free parameters based on the current cmap and norm,
        and do all the drawing.
        """
        self._draw_all()

    def _draw_all(self):
        """
        Calculate any free parameters based on the current cmap and norm,
        and do all the drawing.
        """
        if self.orientation == 'vertical':
            if mpl.rcParams['ytick.minor.visible']:
                self.minorticks_on()
        else:
            if mpl.rcParams['xtick.minor.visible']:
                self.minorticks_on()
        self._long_axis().set(label_position=self.ticklocation,
                              ticks_position=self.ticklocation)
        self._short_axis().set_ticks([])
        self._short_axis().set_ticks([], minor=True)

        # Set self._boundaries and self._values, including extensions.
        # self._boundaries are the edges of each square of color, and
        # self._values are the value to map into the norm to get the
        # color:
        self._process_values()
        # Set self.vmin and self.vmax to first and last boundary, excluding
        # extensions:
        self.vmin, self.vmax = self._boundaries[self._inside][[0, -1]]
        # Compute the X/Y mesh.
        X, Y = self._mesh()
        # draw the extend triangles, and shrink the inner axes to accommodate.
        # also adds the outline path to self.outline spine:
        self._do_extends()
        lower, upper = self.vmin, self.vmax
        if self._long_axis().get_inverted():
            # If the axis is inverted, we need to swap the vmin/vmax
            lower, upper = upper, lower
        if self.orientation == 'vertical':
            self.ax.set_xlim(0, 1)
            self.ax.set_ylim(lower, upper)
        else:
            self.ax.set_ylim(0, 1)
            self.ax.set_xlim(lower, upper)

        # set up the tick locators and formatters.  A bit complicated because
        # boundary norms + uniform spacing requires a manual locator.
        self.update_ticks()

        if self._filled:
            ind = np.arange(len(self._values))
            if self._extend_lower():
                ind = ind[1:]
            if self._extend_upper():
                ind = ind[:-1]
            self._add_solids(X, Y, self._values[ind, np.newaxis])

    def _add_solids(self, X, Y, C):
        """Draw the colors; optionally add separators."""
        # Cleanup previously set artists.
        if self.solids is not None:
            self.solids.remove()
        for solid in self.solids_patches:
            solid.remove()
        # Add new artist(s), based on mappable type.  Use individual patches if
        # hatching is needed, pcolormesh otherwise.
        mappable = getattr(self, 'mappable', None)
        if (isinstance(mappable, contour.ContourSet)
                and any(hatch is not None for hatch in mappable.hatches)):
            self._add_solids_patches(X, Y, C, mappable)
        else:
            self.solids = self.ax.pcolormesh(
                X, Y, C, cmap=self.cmap, norm=self.norm, alpha=self.alpha,
                edgecolors='none', shading='flat')
            if not self.drawedges:
                if len(self._y) >= self.n_rasterize:
                    self.solids.set_rasterized(True)
        self.dividers.set_segments(
            np.dstack([X, Y])[1:-1] if self.drawedges else [])

    def _add_solids_patches(self, X, Y, C, mappable):
        hatches = mappable.hatches * len(C)  # Have enough hatches.
        patches = []
        for i in range(len(X) - 1):
            xy = np.array([[X[i, 0], Y[i, 0]],
                           [X[i, 1], Y[i, 0]],
                           [X[i + 1, 1], Y[i + 1, 0]],
                           [X[i + 1, 0], Y[i + 1, 1]]])
            patch = mpatches.PathPatch(mpath.Path(xy),
                                       facecolor=self.cmap(self.norm(C[i][0])),
                                       hatch=hatches[i], linewidth=0,
                                       antialiased=False, alpha=self.alpha)
            self.ax.add_patch(patch)
            patches.append(patch)
        self.solids_patches = patches

    def _do_extends(self, ax=None):
        """
        Add the extend tri/rectangles on the outside of the axes.

        ax is unused, but required due to the callbacks on xlim/ylim changed
        """
        # Clean up any previous extend patches
        for patch in self._extend_patches:
            patch.remove()
        self._extend_patches = []
        # extend lengths are fraction of the *inner* part of colorbar,
        # not the total colorbar:
        _, extendlen = self._proportional_y()
        bot = 0 - (extendlen[0] if self._extend_lower() else 0)
        top = 1 + (extendlen[1] if self._extend_upper() else 0)

        # xyout is the outline of the colorbar including the extend patches:

[948 more lines in /testbed/lib/matplotlib/colorbar.py (1637 in all). read_file with offset: 690 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def _mesh\\|def _process_values\\|def _proportional_y\\|_boundaries\\|_values\" lib/matplotlib/colorbar.py | head -60"
}
```

**tool result**

```
598:        # Set self._boundaries and self._values, including extensions.
599:        # self._boundaries are the edges of each square of color, and
600:        # self._values are the value to map into the norm to get the
602:        self._process_values()
605:        self.vmin, self.vmax = self._boundaries[self._inside][[0, -1]]
627:            ind = np.arange(len(self._values))
632:            self._add_solids(X, Y, self._values[ind, np.newaxis])
728:            color = self.cmap(self.norm(self._values[val]))
749:            color = self.cmap(self.norm(self._values[val]))
873:                nv = len(self._values)
877:            b = self._boundaries[self._inside]
1103:            intv = self._values[0], self._values[-1]
1123:    def _process_values(self):
1125:        Set `_boundaries` and `_values` based on the self.boundaries and
1130:            # set self._boundaries from the values...
1131:            self._values = np.array(self.values)
1135:                b[1:-1] = 0.5 * (self._values[:-1] + self._values[1:])
1138:                self._boundaries = b
1140:            self._boundaries = np.array(self.boundaries)
1171:        self._boundaries = np.asarray(b, dtype=float)
1172:        self._values = 0.5 * (self._boundaries[:-1] + self._boundaries[1:])
1174:            self._values = (self._values + 0.00001).astype(np.int16)
1176:    def _mesh(self):
1208:    def _forward_boundaries(self, x):
1210:        b = self._boundaries
1220:    def _inverse_boundaries(self, x):
1222:        b = self._boundaries
1231:        self._process_values()
1239:                funcs = (self._forward_boundaries, self._inverse_boundaries)
1261:            b = self._boundaries
1266:            b = self.norm(self._boundaries, clip=False).filled()
1289:    def _proportional_y(self):
1296:            y = (self._boundaries - self._boundaries[self._inside][0])
1297:            y = y / (self._boundaries[self._inside][-1] -
1298:                     self._boundaries[self._inside][0])
1302:                yscaled = self._forward_boundaries(self._boundaries)
1306:            y = self.norm(self._boundaries.copy())
```

**assistant → tool `read_file`**

```json
{
  "path": "lib/matplotlib/colorbar.py",
  "offset": 1123,
  "limit": 200
}
```

**tool result**

```
    def _process_values(self):
        """
        Set `_boundaries` and `_values` based on the self.boundaries and
        self.values if not None, or based on the size of the colormap and
        the vmin/vmax of the norm.
        """
        if self.values is not None:
            # set self._boundaries from the values...
            self._values = np.array(self.values)
            if self.boundaries is None:
                # bracket values by 1/2 dv:
                b = np.zeros(len(self.values) + 1)
                b[1:-1] = 0.5 * (self._values[:-1] + self._values[1:])
                b[0] = 2.0 * b[1] - b[2]
                b[-1] = 2.0 * b[-2] - b[-3]
                self._boundaries = b
                return
            self._boundaries = np.array(self.boundaries)
            return

        # otherwise values are set from the boundaries
        if isinstance(self.norm, colors.BoundaryNorm):
            b = self.norm.boundaries
        elif isinstance(self.norm, colors.NoNorm):
            # NoNorm has N blocks, so N+1 boundaries, centered on integers:
            b = np.arange(self.cmap.N + 1) - .5
        elif self.boundaries is not None:
            b = self.boundaries
        else:
            # otherwise make the boundaries from the size of the cmap:
            N = self.cmap.N + 1
            b, _ = self._uniform_y(N)
        # add extra boundaries if needed:
        if self._extend_lower():
            b = np.hstack((b[0] - 1, b))
        if self._extend_upper():
            b = np.hstack((b, b[-1] + 1))

        # transform from 0-1 to vmin-vmax:
        if not self.norm.scaled():
            self.norm.vmin = 0
            self.norm.vmax = 1
        self.norm.vmin, self.norm.vmax = mtransforms.nonsingular(
            self.norm.vmin, self.norm.vmax, expander=0.1)
        if (not isinstance(self.norm, colors.BoundaryNorm) and
                (self.boundaries is None)):
            b = self.norm.inverse(b)

        self._boundaries = np.asarray(b, dtype=float)
        self._values = 0.5 * (self._boundaries[:-1] + self._boundaries[1:])
        if isinstance(self.norm, colors.NoNorm):
            self._values = (self._values + 0.00001).astype(np.int16)

    def _mesh(self):
        """
        Return the coordinate arrays for the colorbar pcolormesh/patches.

        These are scaled between vmin and vmax, and already handle colorbar
        orientation.
        """
        y, _ = self._proportional_y()
        # Use the vmin and vmax of the colorbar, which may not be the same
        # as the norm. There are situations where the colormap has a
        # narrower range than the colorbar and we want to accommodate the
        # extra contours.
        if (isinstance(self.norm, (colors.BoundaryNorm, colors.NoNorm))
                or self.boundaries is not None):
            # not using a norm.
            y = y * (self.vmax - self.vmin) + self.vmin
        else:
            # Update the norm values in a context manager as it is only
            # a temporary change and we don't want to propagate any signals
            # attached to the norm (callbacks.blocked).
            with self.norm.callbacks.blocked(), \
                    cbook._setattr_cm(self.norm,
                                      vmin=self.vmin,
                                      vmax=self.vmax):
                y = self.norm.inverse(y)
        self._y = y
        X, Y = np.meshgrid([0., 1.], y)
        if self.orientation == 'vertical':
            return (X, Y)
        else:
            return (Y, X)

    def _forward_boundaries(self, x):
        # map boundaries equally between 0 and 1...
        b = self._boundaries
        y = np.interp(x, b, np.linspace(0, 1, len(b)))
        # the following avoids ticks in the extends:
        eps = (b[-1] - b[0]) * 1e-6
        # map these _well_ out of bounds to keep any ticks out
        # of the extends region...
        y[x < b[0]-eps] = -1
        y[x > b[-1]+eps] = 2
        return y

    def _inverse_boundaries(self, x):
        # invert the above...
        b = self._boundaries
        return np.interp(x, np.linspace(0, 1, len(b)), b)

    def _reset_locator_formatter_scale(self):
        """
        Reset the locator et al to defaults.  Any user-hardcoded changes
        need to be re-entered if this gets called (either at init, or when
        the mappable normal gets changed: Colorbar.update_normal)
        """
        self._process_values()
        self._locator = None
        self._minorlocator = None
        self._formatter = None
        self._minorformatter = None
        if (self.boundaries is not None or
                isinstance(self.norm, colors.BoundaryNorm)):
            if self.spacing == 'uniform':
                funcs = (self._forward_boundaries, self._inverse_boundaries)
                self._set_scale('function', functions=funcs)
            elif self.spacing == 'proportional':
                self._set_scale('linear')
        elif getattr(self.norm, '_scale', None):
            # use the norm's scale (if it exists and is not None):
            self._set_scale(self.norm._scale)
        elif type(self.norm) is colors.Normalize:
            # plain Normalize:
            self._set_scale('linear')
        else:
            # norm._scale is None or not an attr: derive the scale from
            # the Norm:
            funcs = (self.norm, self.norm.inverse)
            self._set_scale('function', functions=funcs)

    def _locate(self, x):
        """
        Given a set of color data values, return their
        corresponding colorbar data coordinates.
        """
        if isinstance(self.norm, (colors.NoNorm, colors.BoundaryNorm)):
            b = self._boundaries
            xn = x
        else:
            # Do calculations using normalized coordinates so
            # as to make the interpolation more accurate.
            b = self.norm(self._boundaries, clip=False).filled()
            xn = self.norm(x, clip=False).filled()

        bunique = b[self._inside]
        yunique = self._y

        z = np.interp(xn, bunique, yunique)
        return z

    # trivial helpers

    def _uniform_y(self, N):
        """
        Return colorbar data coordinates for *N* uniformly
        spaced boundaries, plus extension lengths if required.
        """
        automin = automax = 1. / (N - 1.)
        extendlength = self._get_extension_lengths(self.extendfrac,
                                                   automin, automax,
                                                   default=0.05)
        y = np.linspace(0, 1, N)
        return y, extendlength

    def _proportional_y(self):
        """
        Return colorbar data coordinates for the boundaries of
        a proportional colorbar, plus extension lengths if required:
        """
        if (isinstance(self.norm, colors.BoundaryNorm) or
                self.boundaries is not None):
            y = (self._boundaries - self._boundaries[self._inside][0])
            y = y / (self._boundaries[self._inside][-1] -
                     self._boundaries[self._inside][0])
            # need yscaled the same as the axes scale to get
            # the extend lengths.
            if self.spacing == 'uniform':
                yscaled = self._forward_boundaries(self._boundaries)
            else:
                yscaled = y
        else:
            y = self.norm(self._boundaries.copy())
            y = np.ma.filled(y, np.nan)
            # the norm and the scale should be the same...
            yscaled = y
        y = y[self._inside]
        yscaled = yscaled[self._inside]
        # normalize from 0..1:
        norm = colors.Normalize(y[0], y[-1])
        y = np.ma.filled(norm(y), np.nan)
        norm = colors.Normalize(yscaled[0], yscaled[-1])
        yscaled = np.ma.filled(norm(yscaled), np.nan)
        # make the lower and upper extend lengths proportional to the lengths
        # of the first and last boundary spacing (if extendfrac='auto'):
        automin = yscaled[1] - yscaled[0]
        automax = yscaled[-1] - yscaled[-2]
        extendlength = [0, 0]
        if self._extend_lower() or self._extend_upper():

[315 more lines in /testbed/lib/matplotlib/colorbar.py (1637 in all). read_file with offset: 1323 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"_inside\" lib/matplotlib/colorbar.py"
}
```

**assistant → tool `read_file`**

```json
{
  "path": "lib/matplotlib/colorbar.py",
  "offset": 690,
  "limit": 120
}
```

**tool result**

```
410:        self._inside = _api.check_getitem(
605:        self.vmin, self.vmax = self._boundaries[self._inside][[0, -1]]
877:            b = self._boundaries[self._inside]
1269:        bunique = b[self._inside]
1296:            y = (self._boundaries - self._boundaries[self._inside][0])
1297:            y = y / (self._boundaries[self._inside][-1] -
1298:                     self._boundaries[self._inside][0])
1310:        y = y[self._inside]
1311:        yscaled = yscaled[self._inside]
```

**tool result**

```
        if not self.extendrect:
            # triangle:
            xyout = np.array([[0, 0], [0.5, bot], [1, 0],
                              [1, 1], [0.5, top], [0, 1], [0, 0]])
        else:
            # rectangle:
            xyout = np.array([[0, 0], [0, bot], [1, bot], [1, 0],
                              [1, 1], [1, top], [0, top], [0, 1],
                              [0, 0]])

        if self.orientation == 'horizontal':
            xyout = xyout[:, ::-1]

        # xyout is the path for the spine:
        self.outline.set_xy(xyout)
        if not self._filled:
            return

        # Make extend triangles or rectangles filled patches.  These are
        # defined in the outer parent axes' coordinates:
        mappable = getattr(self, 'mappable', None)
        if (isinstance(mappable, contour.ContourSet)
                and any(hatch is not None for hatch in mappable.hatches)):
            hatches = mappable.hatches
        else:
            hatches = [None]

        if self._extend_lower():
            if not self.extendrect:
                # triangle
                xy = np.array([[0, 0], [0.5, bot], [1, 0]])
            else:
                # rectangle
                xy = np.array([[0, 0], [0, bot], [1., bot], [1, 0]])
            if self.orientation == 'horizontal':
                xy = xy[:, ::-1]
            # add the patch
            val = -1 if self._long_axis().get_inverted() else 0
            color = self.cmap(self.norm(self._values[val]))
            patch = mpatches.PathPatch(
                mpath.Path(xy), facecolor=color, linewidth=0,
                antialiased=False, transform=self.ax.transAxes,
                hatch=hatches[0], clip_on=False,
                # Place it right behind the standard patches, which is
                # needed if we updated the extends
                zorder=np.nextafter(self.ax.patch.zorder, -np.inf))
            self.ax.add_patch(patch)
            self._extend_patches.append(patch)
        if self._extend_upper():
            if not self.extendrect:
                # triangle
                xy = np.array([[0, 1], [0.5, top], [1, 1]])
            else:
                # rectangle
                xy = np.array([[0, 1], [0, top], [1, top], [1, 1]])
            if self.orientation == 'horizontal':
                xy = xy[:, ::-1]
            # add the patch
            val = 0 if self._long_axis().get_inverted() else -1
            color = self.cmap(self.norm(self._values[val]))
            patch = mpatches.PathPatch(
                mpath.Path(xy), facecolor=color,
                linewidth=0, antialiased=False,
                transform=self.ax.transAxes, hatch=hatches[-1], clip_on=False,
                # Place it right behind the standard patches, which is
                # needed if we updated the extends
                zorder=np.nextafter(self.ax.patch.zorder, -np.inf))
            self.ax.add_patch(patch)
            self._extend_patches.append(patch)
        return

    def add_lines(self, *args, **kwargs):
        """
        Draw lines on the colorbar.

        The lines are appended to the list :attr:`lines`.

        Parameters
        ----------
        levels : array-like
            The positions of the lines.
        colors : color or list of colors
            Either a single color applying to all lines or one color value for
            each line.
        linewidths : float or array-like
            Either a single linewidth applying to all lines or one linewidth
            for each line.
        erase : bool, default: True
            Whether to remove any previously added lines.

        Notes
        -----
        Alternatively, this method can also be called with the signature
        ``colorbar.add_lines(contour_set, erase=True)``, in which case
        *levels*, *colors*, and *linewidths* are taken from *contour_set*.
        """
        params = _api.select_matching_signature(
            [lambda self, CS, erase=True: locals(),
             lambda self, levels, colors, linewidths, erase=True: locals()],
            self, *args, **kwargs)
        if "CS" in params:
            self, CS, erase = params.values()
            if not isinstance(CS, contour.ContourSet) or CS.filled:
                raise ValueError("If a single artist is passed to add_lines, "
                                 "it must be a ContourSet of lines")
            # TODO: Make colorbar lines auto-follow changes in contour lines.
            return self.add_lines(
                CS.levels,
                [c[0] for c in CS.tcolors],
                [t[0] for t in CS.tlinewidths],
                erase=erase)
        else:
            self, levels, colors, linewidths, erase = params.values()

        y = self._locate(levels)
        rtol = (self._y[-1] - self._y[0]) * 1e-10
        igood = (y < self._y[-1] + rtol) & (y > self._y[0] - rtol)
        y = y[igood]
        if np.iterable(colors):
            colors = np.asarray(colors)[igood]

[828 more lines in /testbed/lib/matplotlib/colorbar.py (1637 in all). read_file with offset: 810 to continue]
```

**assistant → tool `read_file`**

```json
{
  "path": "lib/matplotlib/colorbar.py",
  "offset": 395,
  "limit": 30
}
```

**assistant → tool `read_file`**

```json
{
  "path": "lib/matplotlib/colorbar.py",
  "offset": 1318,
  "limit": 30
}
```

**tool result**

```
            if (not isinstance(mappable, contour.ContourSet)
                    and getattr(cmap, 'colorbar_extend', False) is not False):
                extend = cmap.colorbar_extend
            elif hasattr(norm, 'extend'):
                extend = norm.extend
            else:
                extend = 'neither'
        self.alpha = None
        # Call set_alpha to handle array-like alphas properly
        self.set_alpha(alpha)
        self.cmap = cmap
        self.norm = norm
        self.values = values
        self.boundaries = boundaries
        self.extend = extend
        self._inside = _api.check_getitem(
            {'neither': slice(0, None), 'both': slice(1, -1),
             'min': slice(1, None), 'max': slice(0, -1)},
            extend=extend)
        self.spacing = spacing
        self.orientation = orientation
        self.drawedges = drawedges
        self._filled = filled
        self.extendfrac = extendfrac
        self.extendrect = extendrect
        self._extend_patches = []
        self.solids = None
        self.solids_patches = []
        self.lines = []


[1213 more lines in /testbed/lib/matplotlib/colorbar.py (1637 in all). read_file with offset: 425 to continue]
```

**tool result**

```
        # of the first and last boundary spacing (if extendfrac='auto'):
        automin = yscaled[1] - yscaled[0]
        automax = yscaled[-1] - yscaled[-2]
        extendlength = [0, 0]
        if self._extend_lower() or self._extend_upper():
            extendlength = self._get_extension_lengths(
                    self.extendfrac, automin, automax, default=0.05)
        return y, extendlength

    def _get_extension_lengths(self, frac, automin, automax, default=0.05):
        """
        Return the lengths of colorbar extensions.

        This is a helper method for _uniform_y and _proportional_y.
        """
        # Set the default value.
        extendlength = np.array([default, default])
        if isinstance(frac, str):
            _api.check_in_list(['auto'], extendfrac=frac.lower())
            # Use the provided values when 'auto' is required.
            extendlength[:] = [automin, automax]
        elif frac is not None:
            try:
                # Try to set min and max extension fractions directly.
                extendlength[:] = frac
                # If frac is a sequence containing None then NaN may
                # be encountered. This is an error.
                if np.isnan(extendlength).any():
                    raise ValueError()
            except (TypeError, ValueError) as err:

[290 more lines in /testbed/lib/matplotlib/colorbar.py (1637 in all). read_file with offset: 1348 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"dividers\" lib/matplotlib/colorbar.py"
}
```

**tool result**

```
293:    dividers : `.LineCollection`
435:        self.dividers = collections.LineCollection(
439:        self.ax.add_collection(self.dividers)
654:        self.dividers.set_segments(
```

**assistant → tool `read_file`**

```json
{
  "path": "lib/matplotlib/colorbar.py",
  "offset": 425,
  "limit": 20
}
```

**tool result**

```
        for spine in self.ax.spines.values():
            spine.set_visible(False)
        self.outline = self.ax.spines['outline'] = _ColorbarSpine(self.ax)
        self._short_axis().set_visible(False)
        # Only kept for backcompat; remove after deprecation of .patch elapses.
        self._patch = mpatches.Polygon(
            np.empty((0, 2)),
            color=mpl.rcParams['axes.facecolor'], linewidth=0.01, zorder=-1)
        ax.add_artist(self._patch)

        self.dividers = collections.LineCollection(
            [],
            colors=[mpl.rcParams['axes.edgecolor']],
            linewidths=[0.5 * mpl.rcParams['axes.linewidth']])
        self.ax.add_collection(self.dividers)

        self._locator = None
        self._minorlocator = None
        self._formatter = None
        self._minorformatter = None

[1193 more lines in /testbed/lib/matplotlib/colorbar.py (1637 in all). read_file with offset: 445 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"drawedges\\|dividers\" lib/matplotlib/tests/test_colorbar.py | head -40"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"import matplotlib; print(matplotlib.__version__, matplotlib.__file__)\""
}
```

**tool result**

```

```

**tool result**

```
3.6.0.dev2064+g98ae845d67 /testbed/lib/matplotlib/__init__.py
```

**assistant → tool `bash`**

```json
{
  "command": "find / -path /proc -prune -o -name colorbar.py -print 2>/dev/null | head"
}
```

**tool result**

```
/testbed/lib/matplotlib/colorbar.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"extend\\|drawedges\\|dividers\" lib/matplotlib/tests/test_colorbar.py | head -60"
}
```

**tool result**

```
21:    possible settings of the extend keyword.
61:                 extend=extension_type, extendrect=True,
87:        for j, extendfrac in enumerate((None, 'auto', 0.1)):
93:                     extend=extension_type, extendfrac=extendfrac,
128:@pytest.mark.parametrize("extend,expected", [("min", (0, 0, 0, 1)),
131:def test_colorbar_extension_inverted_axis(orientation, extend, expected):
138:    cbar = fig.colorbar(im, orientation=orientation, extend=extend)
143:    assert cbar._extend_patches[0].get_facecolor() == expected
144:    if extend == "both":
145:        assert len(cbar._extend_patches) == 2
146:        assert cbar._extend_patches[1].get_facecolor() == (0, 0, 0, 1)
148:        assert len(cbar._extend_patches) == 1
185:    color_mappable = plt.contourf(data, levels=levels, extend='both')
186:    # test extend frac here
188:                                  hatches=['/', 'o', '+'], extend='max')
227:    CS = ax.contour(data, levels=levels, extend='both')
228:    fig.colorbar(CS, orientation='horizontal', extend='both')
330:        plt.colorbar(im, cax=ax2, extend='both', extendfrac=0.5, **cbar_kw)
331:        plt.colorbar(im, cax=ax3, extend='both', **cbar_kw)
332:        plt.colorbar(im, cax=ax4, extend='both', extendrect=True, **cbar_kw)
333:        plt.colorbar(im, cax=ax5, extend='neither', **cbar_kw)
345:    cs = ax.contourf(X, Y, Z, clevs, colors=colors, extend='neither')
360:        cbar = fig.colorbar(im, extend='both')
410:    don't overflow into the extend regions of the colorbar.
420:    cbar = fig.colorbar(im, extend='both', orientation='vertical')
424:    cbar = fig.colorbar(im, extend='both', orientation='horizontal')
440:        cbar = fig.colorbar(pcm, ax=ax[0], extend='both',
444:        cbar2 = fig.colorbar(pcm, ax=ax[1], extend='both',
464:        cbar = fig.colorbar(pcm, ax=ax[0], extend='both',
468:        cbar2 = fig.colorbar(pcm, ax=ax[1], extend='both',
512:    cbar = fig.colorbar(pcm, ax=ax, extend='both',
519:@pytest.mark.parametrize("extend", ['both', 'min', 'max'])
520:def test_colorbar_lognorm_extension(extend):
521:    # Test that colorbar with lognorm is extended correctly
524:                  orientation='vertical', extend=extend)
529:    # Test that colorbar with powernorm is extended correctly
532:                  orientation='vertical', extend='both')
645:    cbar = fig.colorbar(pc, ax=ax, extend='both')
652:    cbar = fig.colorbar(pc, ax=ax, extend='both')
801:    cb = fig.colorbar(pc, ax=ax[0], extend='both')
805:    cb = fig.colorbar(pc, ax=ax[1], extend='both')
865:    extends = ['neither', 'both', 'both']
868:        for mm, (aspect, extend) in enumerate(zip(aspects, extends)):
871:                                      aspect=aspect, extend=extend)
873:    # check the extends are right ratio:
912:    extends = ['neither', 'both']
918:                                     extend=extends[i])
1020:    cb = fig.colorbar(pc, location='right', extend='max')
1033:    cb = fig.colorbar(pc, location='right', extend='max')
1037:    # colorbar axes, including its extend triangles....
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline -- lib/matplotlib/colorbar.py | head -20; git branch -a | head"
}
```

**tool result**

```
357979ebd5 Fix colorbar stealing from a single axes and with panchor=False.
52df591338 Deprecate docstring and update references
ec374f5148 FIX: Handle inverted colorbar axes with extensions
23cd7dd8c4 Merge pull request #22523 from greglucas/cbar-rm-norm-deepcopy
2d2425b129 FIX: Colorbars check for subplotspec attribute before using
fdb4ad372a MNT: Use a context manager to change the norm in colorbar code
7277386c56 FIX: minorformatter None
29ef83e2c7 DOC: fix property docstrings
10247eff85 FIX: small fixes
20ddebd043 DOC: improve crosslinking for docs
60a9cad49b TST: test setters and getters in colorbar
6010bb43ed MNT: make colorbars locators and formatters properties
4b3d5134e5 Merge pull request #22251 from anntzer/cbd
6b4e640ee5 Merge pull request #21933 from jklymak/mnt-privatize-colorbar-attr
17cc7fc8fc Numpydocify _colormap_kw_doc and use it in Colorbar too.
2b2ce9b457 Merge main and "other" params docs in colorbar.make_axes.
849c5dbe06 Merge pull request #22081 from anntzer/cbar36
c151e71d39 Fix list creation
7058cd83f3 Expire colorbar-related deprecations.
c20ce5322a FIX: squash memory leak in colorbar
* main
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"drawedges\" lib/matplotlib/tests/ | head -30"
}
```

**tool result**

```

```

**assistant → tool `read_file`**

```json
{
  "path": "lib/matplotlib/tests/test_colorbar.py",
  "limit": 160
}
```

**tool result**

```
import numpy as np
import pytest

from matplotlib import cm
import matplotlib.colors as mcolors

from matplotlib import rc_context
from matplotlib.testing.decorators import image_comparison
import matplotlib.pyplot as plt
from matplotlib.colors import (
    BoundaryNorm, LogNorm, PowerNorm, Normalize, NoNorm
)
from matplotlib.colorbar import Colorbar
from matplotlib.ticker import FixedLocator, LogFormatter
from matplotlib.testing.decorators import check_figures_equal


def _get_cmap_norms():
    """
    Define a colormap and appropriate norms for each of the four
    possible settings of the extend keyword.

    Helper function for _colorbar_extension_shape and
    colorbar_extension_length.
    """
    # Create a colormap and specify the levels it represents.
    cmap = cm.get_cmap("RdBu", lut=5)
    clevs = [-5., -2.5, -.5, .5, 1.5, 3.5]
    # Define norms for the colormaps.
    norms = dict()
    norms['neither'] = BoundaryNorm(clevs, len(clevs) - 1)
    norms['min'] = BoundaryNorm([-10] + clevs[1:], len(clevs) - 1)
    norms['max'] = BoundaryNorm(clevs[:-1] + [10], len(clevs) - 1)
    norms['both'] = BoundaryNorm([-10] + clevs[1:-1] + [10], len(clevs) - 1)
    return cmap, norms


def _colorbar_extension_shape(spacing):
    """
    Produce 4 colorbars with rectangular extensions for either uniform
    or proportional spacing.

    Helper function for test_colorbar_extension_shape.
    """
    # Get a colormap and appropriate norms for each extension type.
    cmap, norms = _get_cmap_norms()
    # Create a figure and adjust whitespace for subplots.
    fig = plt.figure()
    fig.subplots_adjust(hspace=4)
    for i, extension_type in enumerate(('neither', 'min', 'max', 'both')):
        # Get the appropriate norm and use it to get colorbar boundaries.
        norm = norms[extension_type]
        boundaries = values = norm.boundaries
        # note that the last value was silently dropped pre 3.3:
        values = values[:-1]
        # Create a subplot.
        cax = fig.add_subplot(4, 1, i + 1)
        # Generate the colorbar.
        Colorbar(cax, cmap=cmap, norm=norm,
                 boundaries=boundaries, values=values,
                 extend=extension_type, extendrect=True,
                 orientation='horizontal', spacing=spacing)
        # Turn off text and ticks.
        cax.tick_params(left=False, labelleft=False,
                        bottom=False, labelbottom=False)
    # Return the figure to the caller.
    return fig


def _colorbar_extension_length(spacing):
    """
    Produce 12 colorbars with variable length extensions for either
    uniform or proportional spacing.

    Helper function for test_colorbar_extension_length.
    """
    # Get a colormap and appropriate norms for each extension type.
    cmap, norms = _get_cmap_norms()
    # Create a figure and adjust whitespace for subplots.
    fig = plt.figure()
    fig.subplots_adjust(hspace=.6)
    for i, extension_type in enumerate(('neither', 'min', 'max', 'both')):
        # Get the appropriate norm and use it to get colorbar boundaries.
        norm = norms[extension_type]
        boundaries = values = norm.boundaries
        values = values[:-1]
        for j, extendfrac in enumerate((None, 'auto', 0.1)):
            # Create a subplot.
            cax = fig.add_subplot(12, 1, i*3 + j + 1)
            # Generate the colorbar.
            Colorbar(cax, cmap=cmap, norm=norm,
                     boundaries=boundaries, values=values,
                     extend=extension_type, extendfrac=extendfrac,
                     orientation='horizontal', spacing=spacing)
            # Turn off text and ticks.
            cax.tick_params(left=False, labelleft=False,
                              bottom=False, labelbottom=False)
    # Return the figure to the caller.
    return fig


@image_comparison(['colorbar_extensions_shape_uniform.png',
                   'colorbar_extensions_shape_proportional.png'])
def test_colorbar_extension_shape():
    """Test rectangular colorbar extensions."""
    # Remove this line when this test image is regenerated.
    plt.rcParams['pcolormesh.snap'] = False

    # Create figures for uniform and proportionally spaced colorbars.
    _colorbar_extension_shape('uniform')
    _colorbar_extension_shape('proportional')


@image_comparison(['colorbar_extensions_uniform.png',
                   'colorbar_extensions_proportional.png'],
                  tol=1.0)
def test_colorbar_extension_length():
    """Test variable length colorbar extensions."""
    # Remove this line when this test image is regenerated.
    plt.rcParams['pcolormesh.snap'] = False

    # Create figures for uniform and proportionally spaced colorbars.
    _colorbar_extension_length('uniform')
    _colorbar_extension_length('proportional')


@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
@pytest.mark.parametrize("extend,expected", [("min", (0, 0, 0, 1)),
                                             ("max", (1, 1, 1, 1)),
                                             ("both", (1, 1, 1, 1))])
def test_colorbar_extension_inverted_axis(orientation, extend, expected):
    """Test extension color with an inverted axis"""
    data = np.arange(12).reshape(3, 4)
    fig, ax = plt.subplots()
    cmap = plt.get_cmap("viridis").with_extremes(under=(0, 0, 0, 1),
                                                 over=(1, 1, 1, 1))
    im = ax.imshow(data, cmap=cmap)
    cbar = fig.colorbar(im, orientation=orientation, extend=extend)
    if orientation == "horizontal":
        cbar.ax.invert_xaxis()
    else:
        cbar.ax.invert_yaxis()
    assert cbar._extend_patches[0].get_facecolor() == expected
    if extend == "both":
        assert len(cbar._extend_patches) == 2
        assert cbar._extend_patches[1].get_facecolor() == (0, 0, 0, 1)
    else:
        assert len(cbar._extend_patches) == 1


@pytest.mark.parametrize('use_gridspec', [True, False])
@image_comparison(['cbar_with_orientation',
                   'cbar_locationing',
                   'double_cbar',
                   'cbar_sharing',
                   ],
                  extensions=['png'], remove_text=True,
                  savefig_kwarg={'dpi': 40})
def test_colorbar_positioning(use_gridspec):
    # Remove this line when this test image is regenerated.

[879 more lines in /testbed/lib/matplotlib/tests/test_colorbar.py (1039 in all). read_file with offset: 161 to continue]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/colorbar.py\n@@\n-        self.dividers.set_segments(\n-            np.dstack([X, Y])[1:-1] if self.drawedges else [])\n+        if self.drawedges:\n+            # The interior dividers are at the boundaries between the color\n+            # blocks.  If the colorbar has extensions, also draw a divider at\n+            # the boundary between each extension and the first/last block.\n+            start = 0 if self._extend_lower() else 1\n+            end = None if self._extend_upper() else -1\n+            self.dividers.set_segments(np.dstack([X, Y])[start:end])\n+        else:\n+            self.dividers.set_segments([])\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/colorbar.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/colorbar.py now (1644 lines), around the change:
651:            if not self.drawedges:
652:                if len(self._y) >= self.n_rasterize:
653:                    self.solids.set_rasterized(True)
654:        if self.drawedges:
655:            # The interior dividers are at the boundaries between the color
656:            # blocks.  If the colorbar has extensions, also draw a divider at
657:            # the boundary between each extension and the first/last block.
658:            start = 0 if self._extend_lower() else 1
659:            end = None if self._extend_upper() else -1
660:            self.dividers.set_segments(np.dstack([X, Y])[start:end])
661:        else:
662:            self.dividers.set_segments([])
663:
664:    def _add_solids_patches(self, X, Y, C, mappable):
665:        hatches = mappable.hatches * len(C)  # Have enough hatches.
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python - <<'EOF'\nimport matplotlib as mpl\nmpl.use('Agg')\nimport numpy as np\nimport matplotlib.pyplot as plt\nfrom matplotlib.colors import from_levels_and_colors\n\nmy_cmap = mpl.cm.viridis\nbounds = np.arange(10)\nnb_colors = len(bounds) + 1\ncolors = my_cmap(np.linspace(100, 255, nb_colors).astype(int))\nmy_cmap, my_norm = from_levels_and_colors(bounds, colors, extend='both')\nfig = plt.figure(figsize=(5, 1))\nax = plt.subplot(111)\ncbar = mpl.colorbar.ColorbarBase(ax, cmap=my_cmap, norm=my_norm, orientation='horizontal', drawedges=True)\nfig.savefig('/tmp/cbar.png')\nprint(len(cbar.dividers.get_segments()))\nprint(cbar.dividers.get_segments()[0], cbar.dividers.get_segments()[-1])\nEOF"
}
```

**tool result**

```
10
[[0. 0.]
 [0. 1.]] [[9. 0.]
 [9. 1.]]
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest lib/matplotlib/tests/test_colorbar.py -q -x 2>&1 | tail -30"
}
```

**tool result**

```
...................................................s.....                [100%]
56 passed, 1 skipped in 17.20s
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_colorbar_extension_inverted_axis\" -A 25 lib/matplotlib/tests/test_colorbar.py"
}
```

**tool result**

```
131:def test_colorbar_extension_inverted_axis(orientation, extend, expected):
132-    """Test extension color with an inverted axis"""
133-    data = np.arange(12).reshape(3, 4)
134-    fig, ax = plt.subplots()
135-    cmap = plt.get_cmap("viridis").with_extremes(under=(0, 0, 0, 1),
136-                                                 over=(1, 1, 1, 1))
137-    im = ax.imshow(data, cmap=cmap)
138-    cbar = fig.colorbar(im, orientation=orientation, extend=extend)
139-    if orientation == "horizontal":
140-        cbar.ax.invert_xaxis()
141-    else:
142-        cbar.ax.invert_yaxis()
143-    assert cbar._extend_patches[0].get_facecolor() == expected
144-    if extend == "both":
145-        assert len(cbar._extend_patches) == 2
146-        assert cbar._extend_patches[1].get_facecolor() == (0, 0, 0, 1)
147-    else:
148-        assert len(cbar._extend_patches) == 1
149-
150-
151-@pytest.mark.parametrize('use_gridspec', [True, False])
152-@image_comparison(['cbar_with_orientation',
153-                   'cbar_locationing',
154-                   'double_cbar',
155-                   'cbar_sharing',
156-                   ],
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/tests/test_colorbar.py\n@@\n def test_colorbar_extension_inverted_axis(orientation, extend, expected):\n@@\n     else:\n         assert len(cbar._extend_patches) == 1\n \n \n+@pytest.mark.parametrize(\"orientation\", [\"horizontal\", \"vertical\"])\n+@pytest.mark.parametrize(\"extend,expected\", [(\"neither\", 8),\n+                                             (\"min\", 8),\n+                                             (\"max\", 8),\n+                                             (\"both\", 8)])\n+def test_colorbar_drawedges_extension(orientation, extend, expected):\n+    \"\"\"Test that dividers are drawn at the extension boundaries.\"\"\"\n+    data = np.arange(12).reshape(3, 4)\n+    fig, ax = plt.subplots()\n+    im = ax.imshow(data)\n+    cbar = fig.colorbar(im, orientation=orientation, extend=extend,\n+                        drawedges=True)\n+    # The colorbar has 9 color blocks (8 boundaries), plus one boundary at\n+    # each extension for a total of 10 dividers.\n+    n_dividers = 8 + (extend in (\"min\", \"both\")) + (\n+        extend in (\"max\", \"both\"))\n+    assert len(cbar.dividers.get_segments()) == n_dividers\n+\n+\n @pytest.mark.parametrize('use_gridspec', [True, False])\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/tests/test_colorbar.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/tests/test_colorbar.py now (1058 lines), around the change:
146:        assert cbar._extend_patches[1].get_facecolor() == (0, 0, 0, 1)
147:    else:
148:        assert len(cbar._extend_patches) == 1
149:
150:
151:@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
152:@pytest.mark.parametrize("extend,expected", [("neither", 8),
153:                                             ("min", 8),
154:                                             ("max", 8),
155:                                             ("both", 8)])
156:def test_colorbar_drawedges_extension(orientation, extend, expected):
157:    """Test that dividers are drawn at the extension boundaries."""
158:    data = np.arange(12).reshape(3, 4)
159:    fig, ax = plt.subplots()
160:    im = ax.imshow(data)
161:    cbar = fig.colorbar(im, orientation=orientation, extend=extend,
162:                        drawedges=True)
163:    # The colorbar has 9 color blocks (8 boundaries), plus one boundary at
164:    # each extension for a total of 10 dividers.
165:    n_dividers = 8 + (extend in ("min", "both")) + (
166:        extend in ("max", "both"))
167:    assert len(cbar.dividers.get_segments()) == n_dividers
168:
169:
170:@pytest.mark.parametrize('use_gridspec', [True, False])
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/tests/test_colorbar.py\n@@\n @pytest.mark.parametrize(\"orientation\", [\"horizontal\", \"vertical\"])\n-@pytest.mark.parametrize(\"extend,expected\", [(\"neither\", 8),\n-                                             (\"min\", 8),\n-                                             (\"max\", 8),\n-                                             (\"both\", 8)])\n-def test_colorbar_drawedges_extension(orientation, extend, expected):\n+@pytest.mark.parametrize(\"extend\", [\"neither\", \"min\", \"max\", \"both\"])\n+def test_colorbar_drawedges_extension(orientation, extend):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/tests/test_colorbar.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/tests/test_colorbar.py now (1055 lines), around the change:
149:
150:
151:@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
152:@pytest.mark.parametrize("extend", ["neither", "min", "max", "both"])
153:def test_colorbar_drawedges_extension(orientation, extend):
154:    """Test that dividers are drawn at the extension boundaries."""
155:    data = np.arange(12).reshape(3, 4)
156:    fig, ax = plt.subplots()
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python - <<'EOF'\nimport matplotlib as mpl\nmpl.use('Agg')\nimport numpy as np, matplotlib.pyplot as plt\nfrom matplotlib.colors import BoundaryNorm\ncmap = plt.get_cmap('viridis', 8)\nnorm = BoundaryNorm(np.arange(9), 8)\nfig, ax = plt.subplots()\nfor i, ext in enumerate(['neither','min','max','both']):\n    cax = fig.add_axes([0.1, 0.1+i*0.2, 0.8, 0.15])\n    cbar = mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm, orientation='horizontal', extend=ext, drawedges=True)\n    print(ext, len(cbar.dividers.get_segments()), cbar.dividers.get_segments()[0], cbar.dividers.get_segments()[-1])\nEOF"
}
```

**tool result**

```
neither 7 [[1. 0.]
 [1. 1.]] [[7. 0.]
 [7. 1.]]
min 8 [[0. 0.]
 [0. 1.]] [[7. 0.]
 [7. 1.]]
max 8 [[1. 0.]
 [1. 1.]] [[8. 0.]
 [8. 1.]]
both 9 [[0. 0.]
 [0. 1.]] [[8. 0.]
 [8. 1.]]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/tests/test_colorbar.py\n@@\n def test_colorbar_drawedges_extension(orientation, extend):\n     \"\"\"Test that dividers are drawn at the extension boundaries.\"\"\"\n     data = np.arange(12).reshape(3, 4)\n     fig, ax = plt.subplots()\n-    im = ax.imshow(data)\n-    cbar = fig.colorbar(im, orientation=orientation, extend=extend,\n-                        drawedges=True)\n-    # The colorbar has 9 color blocks (8 boundaries), plus one boundary at\n-    # each extension for a total of 10 dividers.\n-    n_dividers = 8 + (extend in (\"min\", \"both\")) + (\n-        extend in (\"max\", \"both\"))\n+    cmap = plt.get_cmap(\"viridis\", 8)\n+    norm = BoundaryNorm(np.arange(9), 8)\n+    cbar = fig.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap),\n+                        orientation=orientation, extend=extend,\n+                        drawedges=True)\n+    # The colorbar has 8 color blocks (7 interior boundaries), plus one\n+    # boundary at each extension.\n+    n_dividers = 7 + (extend in (\"min\", \"both\")) + (\n+        extend in (\"max\", \"both\"))\n     assert len(cbar.dividers.get_segments()) == n_dividers\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/tests/test_colorbar.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/tests/test_colorbar.py now (1057 lines), around the change:
154:    """Test that dividers are drawn at the extension boundaries."""
155:    data = np.arange(12).reshape(3, 4)
156:    fig, ax = plt.subplots()
157:    cmap = plt.get_cmap("viridis", 8)
158:    norm = BoundaryNorm(np.arange(9), 8)
159:    cbar = fig.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap),
160:                        orientation=orientation, extend=extend,
161:                        drawedges=True)
162:    # The colorbar has 8 color blocks (7 interior boundaries), plus one
163:    # boundary at each extension.
164:    n_dividers = 7 + (extend in ("min", "both")) + (
165:        extend in ("max", "both"))
166:    assert len(cbar.dividers.get_segments()) == n_dividers
167:
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && sed -i '/    data = np.arange(12).reshape(3, 4)/d' lib/matplotlib/tests/test_colorbar.py && sed -n '150,168p' lib/matplotlib/tests/test_colorbar.py && python -m pytest lib/matplotlib/tests/test_colorbar.py -q 2>&1 | tail -5"
}
```

**tool result**

```
@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
@pytest.mark.parametrize("extend", ["neither", "min", "max", "both"])
def test_colorbar_drawedges_extension(orientation, extend):
    """Test that dividers are drawn at the extension boundaries."""
    fig, ax = plt.subplots()
    cmap = plt.get_cmap("viridis", 8)
    norm = BoundaryNorm(np.arange(9), 8)
    cbar = fig.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap),
                        orientation=orientation, extend=extend,
                        drawedges=True)
    # The colorbar has 8 color blocks (7 interior boundaries), plus one
    # boundary at each extension.
    n_dividers = 7 + (extend in ("min", "both")) + (
        extend in ("max", "both"))
    assert len(cbar.dividers.get_segments()) == n_dividers


@pytest.mark.parametrize('use_gridspec', [True, False])
@image_comparison(['cbar_with_orientation',
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[max-expected1-horizontal]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[max-expected1-vertical]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[both-expected2-horizontal]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[both-expected2-vertical]
6 failed, 58 passed, 1 skipped in 13.75s
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest \"lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis\" -q 2>&1 | tail -40"
}
```

**tool result**

```
orientation = 'horizontal', extend = 'both', expected = (1, 1, 1, 1)

    @pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
    @pytest.mark.parametrize("extend,expected", [("min", (0, 0, 0, 1)),
                                                 ("max", (1, 1, 1, 1)),
                                                 ("both", (1, 1, 1, 1))])
    def test_colorbar_extension_inverted_axis(orientation, extend, expected):
        """Test extension color with an inverted axis"""
        fig, ax = plt.subplots()
        cmap = plt.get_cmap("viridis").with_extremes(under=(0, 0, 0, 1),
                                                     over=(1, 1, 1, 1))
>       im = ax.imshow(data, cmap=cmap)
E       NameError: name 'data' is not defined

lib/matplotlib/tests/test_colorbar.py:136: NameError
________ test_colorbar_extension_inverted_axis[both-expected2-vertical] ________

orientation = 'vertical', extend = 'both', expected = (1, 1, 1, 1)

    @pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
    @pytest.mark.parametrize("extend,expected", [("min", (0, 0, 0, 1)),
                                                 ("max", (1, 1, 1, 1)),
                                                 ("both", (1, 1, 1, 1))])
    def test_colorbar_extension_inverted_axis(orientation, extend, expected):
        """Test extension color with an inverted axis"""
        fig, ax = plt.subplots()
        cmap = plt.get_cmap("viridis").with_extremes(under=(0, 0, 0, 1),
                                                     over=(1, 1, 1, 1))
>       im = ax.imshow(data, cmap=cmap)
E       NameError: name 'data' is not defined

lib/matplotlib/tests/test_colorbar.py:136: NameError
=========================== short test summary info ============================
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[min-expected0-horizontal]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[min-expected0-vertical]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[max-expected1-horizontal]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[max-expected1-vertical]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[both-expected2-horizontal]
FAILED lib/matplotlib/tests/test_colorbar.py::test_colorbar_extension_inverted_axis[both-expected2-vertical]
6 failed in 1.10s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/tests/test_colorbar.py\n@@\n def test_colorbar_extension_inverted_axis(orientation, extend, expected):\n     \"\"\"Test extension color with an inverted axis\"\"\"\n+    data = np.arange(12).reshape(3, 4)\n     fig, ax = plt.subplots()\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/tests/test_colorbar.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/tests/test_colorbar.py now (1056 lines), around the change:
130:                                             ("both", (1, 1, 1, 1))])
131:def test_colorbar_extension_inverted_axis(orientation, extend, expected):
132:    """Test extension color with an inverted axis"""
133:    data = np.arange(12).reshape(3, 4)
134:    fig, ax = plt.subplots()
135:    cmap = plt.get_cmap("viridis").with_extremes(under=(0, 0, 0, 1),
136:                                                 over=(1, 1, 1, 1))
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python -m pytest lib/matplotlib/tests/test_colorbar.py -q 2>&1 | tail -5"
}
```

**tool result**

```
...........................................................s.....        [100%]
64 passed, 1 skipped in 11.15s
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && python - <<'EOF'\nimport matplotlib as mpl\nmpl.use('Agg')\nimport numpy as np, matplotlib.pyplot as plt\nfrom matplotlib.colors import from_levels_and_colors\nmy_cmap = mpl.cm.viridis\nbounds = np.arange(10)\ncolors = my_cmap(np.linspace(100, 255, len(bounds)+1).astype(int))\nmy_cmap, my_norm = from_levels_and_colors(bounds, colors, extend='both')\nfig = plt.figure(figsize=(5, 1))\nax = plt.subplot(111)\ncbar = mpl.colorbar.ColorbarBase(ax, cmap=my_cmap, norm=my_norm, orientation='horizontal', drawedges=True)\nfig.savefig('/tmp/cbar.png', dpi=120)\nprint(cbar.dividers.get_segments())\nEOF"
}
```

**tool result**

```
[array([[0., 0.],
       [0., 1.]]), array([[1., 0.],
       [1., 1.]]), array([[2., 0.],
       [2., 1.]]), array([[3., 0.],
       [3., 1.]]), array([[4., 0.],
       [4., 1.]]), array([[5., 0.],
       [5., 1.]]), array([[6., 0.],
       [6., 1.]]), array([[7., 0.],
       [7., 1.]]), array([[8., 0.],
       [8., 1.]]), array([[9., 0.],
       [9., 1.]])]
```

**assistant → tool `bash`**

```json
{
  "command": "cd /testbed && git diff --stat && git diff lib/matplotlib/colorbar.py lib/matplotlib/tests/test_colorbar.py"
}
```

**tool result**

```
 lib/matplotlib/colorbar.py            | 11 +++++++++--
 lib/matplotlib/tests/test_colorbar.py | 17 +++++++++++++++++
 2 files changed, 26 insertions(+), 2 deletions(-)
diff --git a/lib/matplotlib/colorbar.py b/lib/matplotlib/colorbar.py
index c59b0ac815..3bde9740f3 100644
--- a/lib/matplotlib/colorbar.py
+++ b/lib/matplotlib/colorbar.py
@@ -651,8 +651,15 @@ class Colorbar:
             if not self.drawedges:
                 if len(self._y) >= self.n_rasterize:
                     self.solids.set_rasterized(True)
-        self.dividers.set_segments(
-            np.dstack([X, Y])[1:-1] if self.drawedges else [])
+        if self.drawedges:
+            # The interior dividers are at the boundaries between the color
+            # blocks.  If the colorbar has extensions, also draw a divider at
+            # the boundary between each extension and the first/last block.
+            start = 0 if self._extend_lower() else 1
+            end = None if self._extend_upper() else -1
+            self.dividers.set_segments(np.dstack([X, Y])[start:end])
+        else:
+            self.dividers.set_segments([])
 
     def _add_solids_patches(self, X, Y, C, mappable):
         hatches = mappable.hatches * len(C)  # Have enough hatches.
diff --git a/lib/matplotlib/tests/test_colorbar.py b/lib/matplotlib/tests/test_colorbar.py
index ae3ab92c0d..ce2a5f3005 100644
--- a/lib/matplotlib/tests/test_colorbar.py
+++ b/lib/matplotlib/tests/test_colorbar.py
@@ -148,6 +148,23 @@ def test_colorbar_extension_inverted_axis(orientation, extend, expected):
         assert len(cbar._extend_patches) == 1
 
 
+@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
+@pytest.mark.parametrize("extend", ["neither", "min", "max", "both"])
+def test_colorbar_drawedges_extension(orientation, extend):
+    """Test that dividers are drawn at the extension boundaries."""
+    fig, ax = plt.subplots()
+    cmap = plt.get_cmap("viridis", 8)
+    norm = BoundaryNorm(np.arange(9), 8)
+    cbar = fig.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap),
+                        orientation=orientation, extend=extend,
+                        drawedges=True)
+    # The colorbar has 8 color blocks (7 interior boundaries), plus one
+    # boundary at each extension.
+    n_dividers = 7 + (extend in ("min", "both")) + (
+        extend in ("max", "both"))
+    assert len(cbar.dividers.get_segments()) == n_dividers
+
+
 @pytest.mark.parametrize('use_gridspec', [True, False])
 @image_comparison(['cbar_with_orientation',
                    'cbar_locationing',
```

**assistant**

````
Fixed the colorbar edge-drawing bug.

## Change

In `lib/matplotlib/colorbar.py`, `Colorbar._add_solids` previously always dropped the first and last mesh boundaries:

```python
self.dividers.set_segments(np.dstack([X, Y])[1:-1] ...)
```

That is correct for a colorbar without extensions (the outer ends are the axes outline), but when an extension exists, the first/last mesh boundary is the boundary between the extension and the first/last color block, which needs a divider.

The new logic keeps the outer boundary only on sides that have an extension:

```python
start = 0 if self._extend_lower() else 1
end = None if self._extend_upper() else -1
self.dividers.set_segments(np.dstack([X, Y])[start:end])
```

## Tests

Added `test_colorbar_drawedges_extension`, parametrized over orientation (`horizontal`/`vertical`) and `extend` (`neither`/`min`/`max`/`both`), asserting the correct number of divider segments (interior boundaries plus one per extension).

All colorbar tests pass: **64 passed, 1 skipped**.
````

## Run folder `team-solve-2026-11-06T113317`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
98ae845d67f018d14544934f2a85be258debdd89
```

### `baseline-check.log`

```
check: python -m pytest lib/matplotlib/tests/test_colorbar.py -q
ImportError while loading conftest '/testbed/.memdoor/runs/team-solve-2026-11-06T113317/baseline-tree/lib/matplotlib/tests/conftest.py'.
lib/matplotlib/__init__.py:113: in <module>
    from . import _api, _version, cbook, _docstring, rcsetup
lib/matplotlib/cbook/__init__.py:31: in <module>
    from matplotlib import _api, _c_internal_utils
E   ImportError: cannot import name '_c_internal_utils' from partially initialized module 'matplotlib' (most likely due to a circular import) (/testbed/.memdoor/runs/team-solve-2026-11-06T113317/baseline-tree/lib/matplotlib/__init__.py)
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/lib/matplotlib/colorbar.py b/lib/matplotlib/colorbar.py
index c59b0ac815..3bde9740f3 100644
--- a/lib/matplotlib/colorbar.py
+++ b/lib/matplotlib/colorbar.py
@@ -651,8 +651,15 @@ class Colorbar:
             if not self.drawedges:
                 if len(self._y) >= self.n_rasterize:
                     self.solids.set_rasterized(True)
-        self.dividers.set_segments(
-            np.dstack([X, Y])[1:-1] if self.drawedges else [])
+        if self.drawedges:
+            # The interior dividers are at the boundaries between the color
+            # blocks.  If the colorbar has extensions, also draw a divider at
+            # the boundary between each extension and the first/last block.
+            start = 0 if self._extend_lower() else 1
+            end = None if self._extend_upper() else -1
+            self.dividers.set_segments(np.dstack([X, Y])[start:end])
+        else:
+            self.dividers.set_segments([])
 
     def _add_solids_patches(self, X, Y, C, mappable):
         hatches = mappable.hatches * len(C)  # Have enough hatches.
diff --git a/lib/matplotlib/tests/test_colorbar.py b/lib/matplotlib/tests/test_colorbar.py
index ae3ab92c0d..ce2a5f3005 100644
--- a/lib/matplotlib/tests/test_colorbar.py
+++ b/lib/matplotlib/tests/test_colorbar.py
@@ -148,6 +148,23 @@ def test_colorbar_extension_inverted_axis(orientation, extend, expected):
         assert len(cbar._extend_patches) == 1
 
 
+@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
+@pytest.mark.parametrize("extend", ["neither", "min", "max", "both"])
+def test_colorbar_drawedges_extension(orientation, extend):
+    """Test that dividers are drawn at the extension boundaries."""
+    fig, ax = plt.subplots()
+    cmap = plt.get_cmap("viridis", 8)
+    norm = BoundaryNorm(np.arange(9), 8)
+    cbar = fig.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap),
+                        orientation=orientation, extend=extend,
+                        drawedges=True)
+    # The colorbar has 8 color blocks (7 interior boundaries), plus one
+    # boundary at each extension.
+    n_dividers = 7 + (extend in ("min", "both")) + (
+        extend in ("max", "both"))
+    assert len(cbar.dividers.get_segments()) == n_dividers
+
+
 @pytest.mark.parametrize('use_gridspec', [True, False])
 @image_comparison(['cbar_with_orientation',
                    'cbar_locationing',
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

[Bug]: Colorbar with drawedges=True and extend='both' does not draw edges at extremities
### Bug summary

When creating a matplotlib colorbar, it is possible to set drawedges to True which separates the colors of the colorbar with black lines. However, when the colorbar is extended using extend='both', the black lines at the extremities do not show up.

### Code for reproduction

```python
import matplotlib as mpl
import numpy as np
import matplotlib.pyplot as plt  
from matplotlib.colors import from_levels_and_colors

my_cmap = mpl.cm.viridis
bounds = np.arange(10)
nb_colors = len(bounds) + 1
colors = my_cmap(np.linspace(100, 255, nb_colors).astype(int))
my_cmap, my_norm = from_levels_and_colors(bounds, colors, extend='both')

plt.figure(figsize=(5, 1))
ax = plt.subplot(111)
cbar = mpl.colorbar.ColorbarBase(ax, cmap=my_cmap, norm=my_norm, orientation='horizontal', drawedges=True)
plt.subplots_adjust(left=0.05, bottom=0.4, right=0.95, top=0.9)
plt.show()
```


### Actual outcome

![image](https://user-images.githubusercontent.com/34058459/164254401-7516988d-1efb-4887-a631-de9a68357685.png)


### Expected outcome

![image](https://user-images.githubusercontent.com/34058459/164254881-92c167b7-aa13-4972-9955-48221b38b866.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.5.1

### Matplotlib Backend

_No response_

### Python version

_No response_

### Jupyter version

_No response_

### Installation

_No response_

## Deliverable

changes to this tree

## Check

`python -m pytest lib/matplotlib/tests/test_colorbar.py -q`

## Scope

`lib/matplotlib/colorbar.py`
`lib/matplotlib/tests/test_colorbar.py`
`lib/matplotlib/tests/baseline_images/test_colorbar/`

## Done when

A colorbar created with `drawedges=True` and `extend='both'` draws black separator lines at both extremities, including the outer ends of the extension triangles.
The reproduction code from the bug report produces the expected image with edges at the left and right ends.
`(inferred)` Existing edge drawing for `extend='neither'`, `'min'`, and `'max'` is not regressed.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest lib/matplotlib/tests/test_colorbar.py -q`

## Scope
`lib/matplotlib/colorbar.py`
`lib/matplotlib/tests/test_colorbar.py`
`lib/matplotlib/tests/baseline_images/test_colorbar/`

## Done when
A colorbar created with `drawedges=True` and `extend='both'` draws black separator lines at both extremities, including the outer ends of the extension triangles.
The reproduction code from the bug report produces the expected image with edges at the left and right ends.
`(inferred)` Existing edge drawing for `extend='neither'`, `'min'`, and `'max'` is not regressed.

## Approach
Reproduce the issue, then inspect `Colorbar._add_solids` and the edge-coordinate construction used when `drawedges=True`. The likely fault is that the `LineCollection` for edges is built from `_boundaries` after duplicating the first/last boundary for extensions, which places lines at the inner extension boundaries rather than the outer extremities.

Candidate approaches:
1. Localized fix in `_add_solids`: build the edge segment coordinates from `_boundaries` plus the extension endpoints when `_extend_lower()`/`_extend_upper()` is true. Tradeoff: smallest change, but must handle both orientations and avoid mutating `_boundaries` used elsewhere.
2. Separate `edge_boundaries` array: leave `_boundaries` untouched for mesh/ticks and construct a dedicated array for the `LineCollection`. Tradeoff: safer against side effects, slightly more code.
3. Add extra line artists at the extremities when `drawedges` and extension are active. Tradeoff: simple, but may duplicate artists and fail to respect later colorbar property updates.

Add a regression test in `lib/matplotlib/tests/test_colorbar.py` that checks the edge segments include the extremities, or use a figure-comparison test if that matches the surrounding tests, then run the scoped test command.


# lib/matplotlib/colorbar.py

```
"""
Colorbars are a visualization of the mapping from scalar values to colors.
In Matplotlib they are drawn into a dedicated `~.axes.Axes`.

.. note::
   Colorbars are typically created through `.Figure.colorbar` or its pyplot
   wrapper `.pyplot.colorbar`, which internally use `.Colorbar` together with
   `.make_axes_gridspec` (for `.GridSpec`-positioned axes) or `.make_axes` (for
   non-`.GridSpec`-positioned axes).

   End-users most likely won't need to directly use this module's API.
"""

import logging
import textwrap

import numpy as np

import matplotlib as mpl
from matplotlib import _api, cbook, collections, cm, colors, contour, ticker
import matplotlib.artist as martist
import matplotlib.patches as mpatches
import matplotlib.path as mpath
import matplotlib.scale as mscale
import matplotlib.spines as mspines
import matplotlib.transforms as mtransforms
from matplotlib import _docstring

_log = logging.getLogger(__name__)

_make_axes_kw_doc = """
location : None or {'left', 'right', 'top', 'bottom'}
    The location, relative to the parent axes, where the colorbar axes
    is created.  It also determines the *orientation* of the colorbar
    (colorbars on the left and right are vertical, colorbars at the top
    and bottom are horizontal).  If None, the location will come from the
    *orientation* if it is set (vertical colorbars on the right, horizontal
    ones at the bottom), or default to 'right' if *orientation* is unset.

orientation : None or {'vertical', 'horizontal'}
    The orientation of the colorbar.  It is preferable to set the *location*
    of the colorbar, as that also determines the *orientation*; passing
    incompatible values for *location* and *orientation* raises an exception.

fraction : float, default: 0.15
    Fraction of original axes to use for colorbar.

shrink : float, default: 1.0
    Fraction by which to multiply the size of the colorbar.

aspect : float, default: 20
    Ratio of long to short dimensions.

pad : float, default: 0.05 if vertical, 0.15 if horizontal
    Fraction of original axes between colorbar and new image axes.

anchor : (float, float), optional
    The anchor point of the colorbar axes.
    Defaults to (0.0, 0.5) if vertical; (0.5, 1.0) if horizontal.

panchor : (float, float), or *False*, optional
    The anchor point of the colorbar parent axes. If *False*, the parent
    axes' anchor will be unchanged.
    Defaults to (1.0, 0.5) if vertical; (0.5, 0.0) if horizontal.
"""

_colormap_kw_doc = """
extend : {'neither', 'both', 'min', 'max'}
    Make pointed end(s) for out-of-range values (unless 'neither').  These are
    set for a given colormap using the colormap set_under and set_over methods.

extendfrac : {*None*, 'auto', length, lengths}
    If set to *None*, both the minimum and maximum triangular colorbar
    extensions will have a length of 5% of the interior colorbar length (this
    is the default setting).

    If set to 'auto', makes the triangular colorbar extensions the same lengths
    as the interior boxes (when *spacing* is set to 'uniform') or the same
    lengths as the respective adjacent interior boxes (when *spacing* is set to
    'proportional').

    If a scalar, indicates the length of both the minimum and maximum
    triangular colorbar extensions as a fraction of the interior colorbar
    length.  A two-element sequence of fractions may also be given, indicating
    the lengths of the minimum and maximum colorbar extensions respectively as
    a fraction of the interior colorbar length.

extendrect : bool
    If *False* the minimum and maximum colorbar extensions will be triangular
    (the default).  If *True* the extensions will be rectangular.

spacing : {'uniform', 'proportional'}
    For discrete colorbars (`.BoundaryNorm` or contours), 'uniform' gives each
    color the same space; 'proportional' makes the space proportional to the
    data interval.

ticks : None or list of ticks or Locator
    If None, ticks are determined automatically from the input.

format : None or str or Formatter
    If None, `~.ticker.ScalarFormatter` is used.
    Format strings, e.g., ``"%4.2e"`` or ``"{x:.2e}"``, are supported.
    An alternative `~.ticker.Formatter` may be given instead.

drawedges : bool
    Whether to draw lines at color boundaries.

label : str
    The label on the colorbar's long axis.

boundaries, values : None or a sequence
    If unset, the colormap will be displayed on a 0-1 scale.
    If sequences, *values* must have a length 1 less than *boundaries*.  For
    each region delimited by adjacent entries in *boundaries*, the color mapped
    to the corresponding value in values will be used.
    Normally only useful for indexed colors (i.e. ``norm=NoNorm()``) or other
    unusual circumstances.
"""

_docstring.interpd.update(colorbar_doc="""
Add a colorbar to a plot.

Parameters
----------
mappable
    The `matplotlib.cm.ScalarMappable` (i.e., `~matplotlib.image.AxesImage`,
    `~matplotlib.contour.ContourSet`, etc.) described by this colorbar.
    This argument is mandatory for the `.Figure.colorbar` method but optional
    for the `.pyplot.colorbar` function, which sets the default to the current
    image.

    Note that one can create a `.ScalarMappable` "on-the-fly" to generate
    colorbars not attached to a previously drawn artist, e.g. ::

        fig.colorbar(cm.ScalarMappable(norm=norm, cmap=cmap), ax=ax)

cax : `~matplotlib.axes.Axes`, optional
    Axes into which the colorbar will be drawn.

ax : `~matplotlib.axes.Axes`, list of Axes, optional
    One or more parent axes from which space for a new colorbar axes will be
    stolen, if *cax* is None.  This has no effect if *cax* is set.

use_gridspec : bool, optional
    If *cax* is ``None``, a new *cax* is created as an instance of Axes.  If
    *ax* is an instance of Subplot and *use_gridspec* is ``True``, *cax* is
    created as an instance of Subplot using the :mod:`.gridspec` module.

Returns
-------
colorbar : `~matplotlib.colorbar.Colorbar`

Notes
-----
Additional keyword arguments are of two kinds:

  axes properties:
%s
  colorbar properties:
%s

If *mappable* is a `~.contour.ContourSet`, its *extend* kwarg is included
automatically.

The *shrink* kwarg provides a simple way to scale the colorbar with respect
to the axes. Note that if *cax* is specified, it determines the size of the
colorbar and *shrink* and *aspect* kwargs are ignored.

For more precise control, you can manually specify the positions of
the axes objects in which the mappable and the colorbar are drawn.  In
this case, do not use any of the axes properties kwargs.

It is known that some vector graphics viewers (svg and pdf) renders white gaps
between segments of the colorbar.  This is due to bugs in the viewers, not
Matplotlib.  As a workaround, the colorbar can be rendered with overlapping
segments::

    cbar = colorbar()
    cbar.solids.set_edgecolor("face")
    draw()

However this has negative consequences in other circumstances, e.g. with
semi-transparent images (alpha < 1) and colorbar extensions; therefore, this
workaround is not used by default (see issue #1188).
""" % (textwrap.indent(_make_axes_kw_doc, "    "),
       textwrap.indent(_colormap_kw_doc, "    ")))


def _set_ticks_on_axis_warn(*args, **kwargs):
    # a top level function which gets put in at the axes'
    # set_xticks and set_yticks by Colorbar.__init__.
    _api.warn_external("Use the colorbar set_ticks() method instead.")


class _ColorbarSpine(mspines.Spine):
    def __init__(self, axes):
        self._ax = axes
        super().__init__(axes, 'colorbar',
                         mpath.Path(np.empty((0, 2)), closed=True))
        mpatches.Patch.set_transform(self, axes.transAxes)

    def get_window_extent(self, renderer=None):
        # This Spine has no Axis associated with it, and doesn't need to adjust
        # its location, so we can directly get the window extent from the
        # super-super-class.
        return mpatches.Patch.get_window_extent(self, renderer=renderer)

    def set_xy(self, xy):
        self._path = mpath.Path(xy, closed=True)
        self._xy = xy
        self.stale = True

    def draw(self, renderer):
        ret = mpatches.Patch.draw(self, renderer)
        self.stale = False
        return ret


class _ColorbarAxesLocator:
    """
    Shrink the axes if there are triangular or rectangular extends.
    """
    def __init__(self, cbar):
        self._cbar = cbar
        self._orig_locator = cbar.ax._axes_locator

    def __call__(self, ax, renderer):
        if self._orig_locator is not None:
            pos = self._orig_locator(ax, renderer)
        else:
            pos = ax.get_position(original=True)
        if self._cbar.extend == 'neither':
            return pos

        y, extendlen = self._cbar._proportional_y()
        if not self._cbar._extend_lower():
            extendlen[0] = 0
        if not self._cbar._extend_upper():
            extendlen[1] = 0
        len = sum(extendlen) + 1
        shrink = 1 / len
        offset = extendlen[0] / len
        # we need to reset the aspect ratio of the axes to account
        # of the extends...
        if hasattr(ax, '_colorbar_info'):
            aspect = ax._colorbar_info['aspect']
        else:
            aspect = False
        # now shrink and/or offset to take into account the
        # extend tri/rectangles.
        if self._cbar.orientation == 'vertical':
            if aspect:
                self._cbar.ax.set_box_aspect(aspect*shrink)
            pos = pos.shrunk(1, shrink).translated(0, offset * pos.height)
        else:
            if aspect:
                self._cbar.ax.set_box_aspect(1/(aspect * shrink))
            pos = pos.shrunk(shrink, 1).translated(offset * pos.width, 0)
        return pos

    def get_subplotspec(self):
        # make tight_layout happy..
        ss = getattr(self._cbar.ax, 'get_subplotspec', None)
        if ss is None:
            if not hasattr(self._orig_locator, "get_subplotspec"):
                return None
            ss = self._orig_locator.get_subplotspec
        return ss()


@_docstring.Substitution(_colormap_kw_doc)
class Colorbar:
    r"""
    Draw a colorbar in an existing axes.

    Typically, colorbars are created using `.Figure.colorbar` or
    `.pyplot.colorbar` and associated with `.ScalarMappable`\s (such as an
    `.AxesImage` generated via `~.axes.Axes.imshow`).

    In order to draw a colorbar not associated with other elements in the
    figure, e.g. when showing a colormap by itself, one can create an empty
    `.ScalarMappable`, or directly pass *cmap* and *norm* instead of *mappable*
    to `Colorbar`.

    Useful public methods are :meth:`set_label` and :meth:`add_lines`.

    Attributes
    ----------
    ax : `~matplotlib.axes.Axes`
        The `~.axes.Axes` instance in which the colorbar is drawn.
    lines : list
        A list of `.LineCollection` (empty if no lines were drawn).
    dividers : `.LineCollection`
        A LineCollection (empty if *drawedges* is ``False``).

    Parameters
    ----------
    ax : `~matplotlib.axes.Axes`
        The `~.axes.Axes` instance in which the colorbar is drawn.

    mappable : `.ScalarMappable`
        The mappable whose colormap and norm will be used.

        To show the under- and over- value colors, the mappable's norm should
        be specified as ::

            norm = colors.Normalize(clip=False)

        To show the colors versus index instead of on a 0-1 scale, use::

            norm=colors.NoNorm()

    cmap : `~matplotlib.colors.Colormap`, default: :rc:`image.cmap`
        The colormap to use.  This parameter is ignored, unless *mappable* is
        None.

    norm : `~matplotlib.colors.Normalize`
        The normalization to use.  This parameter is ignored, unless *mappable*
        is None.

    alpha : float
        The colorbar transparency between 0 (transparent) and 1 (opaque).

    orientation : {'vertical', 'horizontal'}

    ticklocation : {'auto', 'left', 'right', 'top', 'bottom'}

    drawedges : bool

    filled : bool
    %s
    """

    n_rasterize = 50  # rasterize solids if number of colors >= n_rasterize

    @_api.delete_parameter("3.6", "filled")
    def __init__(self, ax, mappable=None, *, cmap=None,
                 norm=None,
                 alpha=None,
                 values=None,
                 boundaries=None,
                 orientation='vertical',
                 ticklocation='auto',
                 extend=None,
                 spacing='uniform',  # uniform or proportional
                 ticks=None,
                 format=None,
                 drawedges=False,
                 filled=True,
                 extendfrac=None,
                 extendrect=False,
                 label='',
                 ):

        if mappable is None:
            mappable = cm.ScalarMappable(norm=norm, cmap=cmap)

        # Ensure the given mappable's norm has appropriate vmin and vmax
        # set even if mappable.draw has not yet been called.
        if mappable.get_array() is not None:
            mappable.autoscale_None()

        self.mappable = mappable
        cmap = mappable.cmap
        norm = mappable.norm

        if isinstance(mappable, contour.ContourSet):
            cs = mappable
            alpha = cs.get_alpha()
            boundaries = cs._levels
            values = cs.cvalues
            extend = cs.extend
            filled = cs.filled
            if ticks is None:
                ticks = ticker.FixedLocator(cs.levels, nbins=10)
        elif isinstance(mappable, martist.Artist):
            alpha = mappable.get_alpha()

        mappable.colorbar = self
        mappable.colorbar_cid = mappable.callbacks.connect(
            'changed', self.update_normal)

        _api.check_in_list(
            ['vertical', 'horizontal'], orientation=orientation)
        _api.check_in_list(
            ['auto', 'left', 'right', 'top', 'bottom'],
            ticklocation=ticklocation)
        _api.check_in_list(
            ['uniform', 'proportional'], spacing=spacing)

        self.ax = ax
        self.ax._axes_locator = _ColorbarAxesLocator(self)

        if extend is None:
            if (not isinstance(mappable, contour.ContourSet)
                    and getattr(cmap, 'colorbar_extend', False) is not False):
                extend = cmap.colorbar_extend
            elif hasattr(norm, 'extend'):
                extend = norm.extend
            else:
                extend = 'neither'
        self.alpha = None
        # Call set_alpha to handle array-like alphas properly
        self.set_alpha(alpha)
        self.cmap = cmap
        self.norm = norm
        self.values = values
        self.boundaries = boundaries
        self.extend = extend
        self._inside = _api.check_getitem(
            {'neither': slice(0, None), 'both': slice(1, -1),
             'min': slice(1, None), 'max': slice(0, -1)},
            extend=extend)
        self.spacing = spacing
        self.orientation = orientation
        self.drawedges = drawedges
        self._filled = filled
        self.extendfrac = extendfrac
        self.extendrect = extendrect
        self._extend_patches = []
        self.solids = None
        self.solids_patches = []
        self.lines = []

        for spine in self.ax.spines.values():
            spine.set_visible(False)
        self.outline = self.ax.spines['outline'] = _ColorbarSpine(self.ax)
        self._short_axis().set_visible(False)
        # Only kept for backcompat; remove after deprecation of .patch elapses.
        self._patch = mpatches.Polygon(
            np.empty((0, 2)),
            color=mpl.rcParams['axes.facecolor'], linewidth=0.01, zorder=-1)
        ax.add_artist(self._patch)

        self.dividers = collections.LineCollection(
            [],
            colors=[mpl.rcParams['axes.edgecolor']],
            linewidths=[0.5 * mpl.rcParams['axes.linewidth']])
        self.ax.add_collection(self.dividers)

        self._locator = None
        self._minorlocator = None
        self._formatter = None
        self._minorformatter = None
        self.__scale = None  # linear, log10 for now.  Hopefully more?

        if ticklocation == 'auto':
            ticklocation = 'bottom' if orientation == 'horizontal' else 'right'
        self.ticklocation = ticklocation

        self.set_label(label)
        self._reset_locator_formatter_scale()

        if np.iterable(ticks):
            self._locator = ticker.FixedLocator(ticks, nbins=len(ticks))
        else:
            self._locator = ticks  # Handle default in _ticker()

        if isinstance(format, str):
            # Check format between FormatStrFormatter and StrMethodFormatter
            try:
                self._formatter = ticker.FormatStrFormatter(format)
                _ = self._formatter(0)
            except TypeError:
                self._formatter = ticker.StrMethodFormatter(format)
        else:
            self._formatter = format  # Assume it is a Formatter or None
        self._draw_all()

        if isinstance(mappable, contour.ContourSet) and not mappable.filled:
            self.add_lines(mappable)

        # Link the Axes and Colorbar for interactive use
        self.ax._colorbar = self
        # Don't navigate on any of these types of mappables
        if (isinstance(self.norm, (colors.BoundaryNorm, colors.NoNorm)) or
                isinstance(self.mappable, contour.ContourSet)):
            self.ax.set_navigate(False)

        # These are the functions that set up interactivity on this colorbar
        self._interactive_funcs = ["_get_view", "_set_view",
                                   "_set_view_from_bbox", "drag_pan"]
        for x in self._interactive_funcs:
            setattr(self.ax, x, getattr(self, x))
        # Set the cla function to the cbar's method to override it
        self.ax.cla = self._cbar_cla
        # Callbacks for the extend calculations to handle inverting the axis
        self._extend_cid1 = self.ax.callbacks.connect(
            "xlim_changed", self._do_extends)
        self._extend_cid2 = self.ax.callbacks.connect(
            "ylim_changed", self._do_extends)

    @property
    def locator(self):
        """Major tick `.Locator` for the colorbar."""
        return self._long_axis().get_major_locator()

    @locator.setter
    def locator(self, loc):
        self._long_axis().set_major_locator(loc)
        self._locator = loc

    @property
    def minorlocator(self):
        """Minor tick `.Locator` for the colorbar."""
        return self._long_axis().get_minor_locator()

    @minorlocator.setter
    def minorlocator(self, loc):
        self._long_axis().set_minor_locator(loc)
        self._minorlocator = loc

    @property
    def formatter(self):
        """Major tick label `.Formatter` for the colorbar."""
        return self._long_axis().get_major_formatter()

    @formatter.setter
    def formatter(self, fmt):
        self._long_axis().set_major_formatter(fmt)
        self._formatter = fmt

    @property
    def minorformatter(self):
        """Minor tick `.Formatter` for the colorbar."""
        return self._long_axis().get_minor_formatter()

    @minorformatter.setter
    def minorformatter(self, fmt):
        self._long_axis().set_minor_formatter(fmt)
        self._minorformatter = fmt

    def _cbar_cla(self):
        """Function to clear the interactive colorbar state."""
        for x in self._interactive_funcs:
            delattr(self.ax, x)
        # We now restore the old cla() back and can call it directly
        del self.ax.cla
        self.ax.cla()

    # Also remove ._patch after deprecation elapses.
    patch = _api.deprecate_privatize_attribute("3.5", alternative="ax")

    filled = _api.deprecate_privatize_attribute("3.6")

    def update_normal(self, mappable):
        """
        Update solid patches, lines, etc.

        This is meant to be called when the norm of the image or contour plot
        to which this colorbar belongs changes.

        If the norm on the mappable is different than before, this resets the
        locator and formatter for the axis, so if these have been customized,
        they will need to be customized again.  However, if the norm only
        changes values of *vmin*, *vmax* or *cmap* then the old formatter
        and locator will be preserved.
        """
        _log.debug('colorbar update normal %r %r', mappable.norm, self.norm)
        self.mappable = mappable
        self.set_alpha(mappable.get_alpha())
        self.cmap = mappable.cmap
        if mappable.norm != self.norm:
            self.norm = mappable.norm
            self._reset_locator_formatter_scale()

        self._draw_all()
        if isinstance(self.mappable, contour.ContourSet):
            CS = self.mappable
            if not CS.filled:
                self.add_lines(CS)
        self.stale = True

    @_api.deprecated("3.6", alternative="fig.draw_without_rendering()")
    def draw_all(self):
        """
        Calculate any free parameters based on the current cmap and norm,
        and do all the drawing.
        """
        self._draw_all()

    def _draw_all(self):
        """
        Calculate any free parameters based on the current cmap and norm,
        and do all the drawing.
        """
        if self.orientation == 'vertical':
            if mpl.rcParams['ytick.minor.visible']:
                self.minorticks_on()
        else:
            if mpl.rcParams['xtick.minor.visible']:
                self.minorticks_on()
        self._long_axis().set(label_position=self.ticklocation,
                              ticks_position=self.ticklocation)
        self._short_axis().set_ticks([])
        self._short_axis().set_ticks([], minor=True)

        # Set self._boundaries and self._values, including extensions.
        # self._boundaries are the edges of each square of color, and
        # self._values are the value to map into the norm to get the
        # color:
        self._process_values()
        # Set self.vmin and self.vmax to first and last boundary, excluding
        # extensions:
        self.vmin, self.vmax = self._boundaries[self._inside][[0, -1]]
        # Compute the X/Y mesh.
        X, Y = self._mesh()
        # draw the extend triangles, and shrink the inner axes to accommodate.
        # also adds the outline path to self.outline spine:
        self._do_extends()
        lower, upper = self.vmin, self.vmax
        if self._long_axis().get_inverted():
            # If the axis is inverted, we need to swap the vmin/vmax
            lower, upper = upper, lower
        if self.orientation == 'vertical':
            self.ax.set_xlim(0, 1)
            self.ax.set_ylim(lower, upper)
        else:
            self.ax.set_ylim(0, 1)
            self.ax.set_xlim(lower, upper)

        # set up the tick locators and formatters.  A bit complicated because
        # boundary norms + uniform spacing requires a manual locator.
        self.update_ticks()

        if self._filled:
            ind = np.arange(len(self._values))
            if self._extend_lower():
                ind = ind[1:]
            if self._extend_upper():
                ind = ind[:-1]
            self._add_solids(X, Y, self._values[ind, np.newaxis])

    def _add_solids(self, X, Y, C):
        """Draw the colors; optionally add separators."""
        # Cleanup previously set artists.
        if self.solids is not None:
            self.solids.remove()
        for solid in self.solids_patches:
            solid.remove()
        # Add new artist(s), based on mappable type.  Use individual patches if
        # hatching is needed, pcolormesh otherwise.
        mappable = getattr(self, 'mappable', None)
        if (isinstance(mappable, contour.ContourSet)
                and any(hatch is not None for hatch in mappable.hatches)):
            self._add_solids_patches(X, Y, C, mappable)
        else:
            self.solids = self.ax.pcolormesh(
                X, Y, C, cmap=self.cmap, norm=self.norm, alpha=self.alpha,
                edgecolors='none', shading='flat')
            if not self.drawedges:
                if len(self._y) >= self.n_rasterize:
                    self.solids.set_rasterized(True)
        self.dividers.set_segments(
            np.dstack([X, Y])[1:-1] if self.drawedges else [])

    def _add_solids_patches(self, X, Y, C, mappable):
        hatches = mappable.hatches * len(C)  # Have enough hatches.
        patches = []
        for i in range(len(X) - 1):
            xy = np.array([[X[i, 0], Y[i, 0]],
                           [X[i, 1], Y[i, 0]],
                           [X[i + 1, 1], Y[i + 1, 0]],
                           [X[i + 1, 0], Y[i + 1, 1]]])
            patch = mpatches.PathPatch(mpath.Path(xy),
                                       facecolor=self.cmap(self.norm(C[i][0])),
                                       hatch=hatches[i], linewidth=0,
                                       antialiased=False, alpha=self.alpha)
            self.ax.add_patch(patch)
            patches.append(patch)
        self.solids_patches = patches

    def _do_extends(self, ax=None):
        """
        Add the extend tri/rectangles on the outside of the axes.

        ax is unused, but required due to the callbacks on xlim/ylim changed
        """
        # Clean up any previous extend patches
        for patch in self._extend_patches:
            patch.remove()
        self._extend_patches = []
        # extend lengths are fraction of the *inner* part of colorbar,
        # not the total colorbar:
        _, extendlen = self._proportional_y()
        bot = 0 - (extendlen[0] if self._extend_lower() else 0)
        top = 1 + (extendlen[1] if self._extend_upper() else 0)

        # xyout is the outline of the colorbar including the extend patches:
        if not self.extendrect:
            # triangle:
            xyout = np.array([[0, 0], [0.5, bot], [1, 0],
                              [1, 1], [0.5, top], [0, 1], [0, 0]])
        else:
            # rectangle:
            xyout = np.array([[0, 0], [0, bot], [1, bot], [1, 0],
                              [1, 1], [1, top], [0, top], [0, 1],
                              [0, 0]])

        if self.orientation == 'horizontal':
            xyout = xyout[:, ::-1]

        # xyout is the path for the spine:
        self.outline.set_xy(xyout)
        if not self._filled:
            return

        # Make extend triangles or rectangles filled patches.  These are
        # defined in the outer parent axes' coordinates:
        mappable = getattr(self, 'mappable', None)
        if (isinstance(mappable, contour.ContourSet)
                and any(hatch is not None for hatch in mappable.hatches)):
            hatches = mappable.hatches
        else:
            hatches = [None]

        if self._extend_lower():
            if not self.extendrect:
                # triangle
                xy = np.array([[0, 0], [0.5, bot], [1, 0]])
            else:
                # rectangle
                xy = np.array([[0, 0], [0, bot], [1., bot], [1, 0]])
            if self.orientation == 'horizontal':
                xy = xy[:, ::-1]
            # add the patch
            val = -1 if self._long_axis().get_inverted() else 0
            color = self.cmap(self.norm(self._values[val]))
            patch = mpatches.PathPatch(
                mpath.Path(xy), facecolor=color, linewidth=0,
                antialiased=False, transform=self.ax.transAxes,
                hatch=hatches[0], clip_on=False,
                # Place it right behind the standard patches, which is
                # needed if we updated the extends
                zorder=np.nextafter(self.ax.patch.zorder, -np.inf))
            self.ax.add_patch(patch)
            self._extend_patches.append(patch)
        if self._extend_upper():
            if not self.extendrect:
                # triangle
                xy = np.array([[0, 1], [0.5, top], [1, 1]])
            else:
                # rectangle
                xy = np.array([[0, 1], [0, top], [1, top], [1, 1]])
            if self.orientation == 'horizontal':
                xy = xy[:, ::-1]
            # add the patch
            val = 0 if self._long_axis().get_inverted() else -1
            color = self.cmap(self.norm(self._values[val]))
            patch = mpatches.PathPatch(
                mpath.Path(xy), facecolor=color,
                linewidth=0, antialiased=False,
                transform=self.ax.transAxes, hatch=hatches[-1], clip_on=False,
                # Place it right behind the standard patches, which is
                # needed if we updated the extends
                zorder=np.nextafter(self.ax.patch.zorder, -np.inf))
            self.ax.add_patch(patch)
            self._extend_patches.append(patch)
        return

    def add_lines(self, *args, **kwargs):
        """
        Draw lines on the colorbar.

        The lines are appended to the list :attr:`lines`.

        Parameters
        ----------
        levels : array-like
            The positions of the lines.
        colors : color or list of colors
            Either a single color applying to all lines or one color value for
            each line.
        linewidths : float or array-like
            Either a single linewidth applying to all lines or one linewidth
            for each line.
        erase : bool, default: True
            Whether to remove any previously added lines.

        Notes
        -----
        Alternatively, this method can also be called with the signature
        ``colorbar.add_lines(contour_set, erase=True)``, in which case
        *levels*, *colors*, and *linewidths* are taken from *contour_set*.
        """
        params = _api.select_matching_signature(
            [lambda self, CS, erase=True: locals(),
             lambda self, levels, colors, linewidths, erase=True: locals()],
            self, *args, **kwargs)
        if "CS" in params:
            self, CS, erase = params.values()
            if not isinstance(CS, contour.ContourSet) or CS.filled:
                raise ValueError("If a single artist is passed to add_lines, "
                                 "it must be a ContourSet of lines")
            # TODO: Make colorbar lines auto-follow changes in contour lines.
            return self.add_lines(
                CS.levels,
                [c[0] for c in CS.tcolors],
                [t[0] for t in CS.tlinewidths],
                erase=erase)
        else:
            self, levels, colors, linewidths, erase = params.values()

        y = self._locate(levels)
        rtol = (self._y[-1] - self._y[0]) * 1e-10
        igood = (y < self._y[-1] + rtol) & (y > self._y[0] - rtol)
        y = y[igood]
        if np.iterable(colors):
            colors = np.asarray(colors)[igood]
        if np.iterable(linewidths):
            linewidths = np.asarray(linewidths)[igood]
        X, Y = np.meshgrid([0, 1], y)
        if self.orientation == 'vertical':
            xy = np.stack([X, Y], axis=-1)
        else:
            xy = np.stack([Y, X], axis=-1)
        col = collections.LineCollection(xy, linewidths=linewidths,
                                         colors=colors)

        if erase and self.lines:
            for lc in self.lines:
                lc.remove()
            self.lines = []
        self.lines.append(col)

        # make a clip path that is just a linewidth bigger than the axes...
        fac = np.max(linewidths) / 72
        xy = np.array([[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]])
        inches = self.ax.get_figure().dpi_scale_trans
        # do in inches:
        xy = inches.inverted().transform(self.ax.transAxes.transform(xy))
        xy[[0, 1, 4], 1] -= fac
        xy[[2, 3], 1] += fac
        # back to axes units...
        xy = self.ax.transAxes.inverted().transform(inches.transform(xy))
        col.set_clip_path(mpath.Path(xy, closed=True),
                          self.ax.transAxes)
        self.ax.add_collection(col)
        self.stale = True

    def update_ticks(self):
        """
        Setup the ticks and ticklabels. This should not be needed by users.
        """
        # Get the locator and formatter; defaults to self._locator if not None.
        self._get_ticker_locator_formatter()
        self._long_axis().set_major_locator(self._locator)
        self._long_axis().set_minor_locator(self._minorlocator)
        self._long_axis().set_major_formatter(self._formatter)

    def _get_ticker_locator_formatter(self):
        """
        Return the ``locator`` and ``formatter`` of the colorbar.

        If they have not been defined (i.e. are *None*), the formatter and
        locator are retrieved from the axis, or from the value of the
        boundaries for a boundary norm.

        Called by update_ticks...
        """
        locator = self._locator
        formatter = self._formatter
        minorlocator = self._minorlocator
        if isinstance(self.norm, colors.BoundaryNorm):
            b = self.norm.boundaries
            if locator is None:
                locator = ticker.FixedLocator(b, nbins=10)
            if minorlocator is None:
                minorlocator = ticker.FixedLocator(b)
        elif isinstance(self.norm, colors.NoNorm):
            if locator is None:
                # put ticks on integers between the boundaries of NoNorm
                nv = len(self._values)
                base = 1 + int(nv / 10)
                locator = ticker.IndexLocator(base=base, offset=.5)
        elif self.boundaries is not None:
            b = self._boundaries[self._inside]
            if locator is None:
                locator = ticker.FixedLocator(b, nbins=10)
        else:  # most cases:
            if locator is None:
                # we haven't set the locator explicitly, so use the default
                # for this axis:
                locator = self._long_axis().get_major_locator()
            if minorlocator is None:
                minorlocator = self._long_axis().get_minor_locator()

        if minorlocator is None:
            minorlocator = ticker.NullLocator()

        if formatter is None:
            formatter = self._long_axis().get_major_formatter()

        self._locator = locator
        self._formatter = formatter
        self._minorlocator = minorlocator
        _log.debug('locator: %r', locator)

    @_api.delete_parameter("3.5", "update_ticks")
    def set_ticks(self, ticks, update_ticks=True, labels=None, *,
                  minor=False, **kwargs):
        """
        Set tick locations.

        Parameters
        ----------
        ticks : list of floats
            List of tick locations.
        labels : list of str, optional
            List of tick labels. If not set, the labels show the data value.
        minor : bool, default: False
            If ``False``, set the major ticks; if ``True``, the minor ticks.
        **kwargs
            `.Text` properties for the labels. These take effect only if you
            pass *labels*. In other cases, please use `~.Axes.tick_params`.
        """
        if np.iterable(ticks):
            self._long_axis().set_ticks(ticks, labels=labels, minor=minor,
                                        **kwargs)
            self._locator = self._long_axis().get_major_locator()
        else:
            self._locator = ticks
            self._long_axis().set_major_locator(self._locator)
        self.stale = True

    def get_ticks(self, minor=False):
        """
        Return the ticks as a list of locations.

        Parameters
        ----------
        minor : boolean, default: False
            if True return the minor ticks.
        """
        if minor:
            return self._long_axis().get_minorticklocs()
        else:
            return self._long_axis().get_majorticklocs()

    @_api.delete_parameter("3.5", "update_ticks")
    def set_ticklabels(self, ticklabels, update_ticks=True, *, minor=False,
                       **kwargs):
        """
        Set tick labels.

        .. admonition:: Discouraged

            The use of this method is discouraged, because of the dependency
            on tick positions. In most cases, you'll want to use
            ``set_ticks(positions, labels=labels)`` instead.

            If you are using this method, you should always fix the tick
            positions before, e.g. by using `.Colorbar.set_ticks` or by
            explicitly setting a `~.ticker.FixedLocator` on the long axis
            of the colorbar. Otherwise, ticks are free to move and the
            labels may end up in unexpected positions.

        Parameters
        ----------
        ticklabels : sequence of str or of `.Text`
            Texts for labeling each tick location in the sequence set by
            `.Colorbar.set_ticks`; the number of labels must match the number
            of locations.

        update_ticks : bool, default: True
            This keyword argument is ignored and will be be removed.
            Deprecated

         minor : bool
            If True, set minor ticks instead of major ticks.

        **kwargs
            `.Text` properties for the labels.
        """
        self._long_axis().set_ticklabels(ticklabels, minor=minor, **kwargs)

    def minorticks_on(self):
        """
        Turn on colorbar minor ticks.
        """
        self.ax.minorticks_on()
        self._short_axis().set_minor_locator(ticker.NullLocator())

    def minorticks_off(self):
        """Turn the minor ticks of the colorbar off."""
        self._minorlocator = ticker.NullLocator()
        self._long_axis().set_minor_locator(self._minorlocator)

    def set_label(self, label, *, loc=None, **kwargs):
        """
        Add a label to the long axis of the colorbar.

        Parameters
        ----------
        label : str
            The label text.
        loc : str, optional
            The location of the label.

            - For horizontal orientation one of {'left', 'center', 'right'}
            - For vertical orientation one of {'bottom', 'center', 'top'}

            Defaults to :rc:`xaxis.labellocation` or :rc:`yaxis.labellocation`
            depending on the orientation.
        **kwargs
            Keyword arguments are passed to `~.Axes.set_xlabel` /
            `~.Axes.set_ylabel`.
            Supported keywords are *labelpad* and `.Text` properties.
        """
        if self.orientation == "vertical":
            self.ax.set_ylabel(label, loc=loc, **kwargs)
        else:
            self.ax.set_xlabel(label, loc=loc, **kwargs)
        self.stale = True

    def set_alpha(self, alpha):
        """
        Set the transparency between 0 (transparent) and 1 (opaque).

        If an array is provided, *alpha* will be set to None to use the
        transparency values associated with the colormap.
        """
        self.alpha = None if isinstance(alpha, np.ndarray) else alpha

    def _set_scale(self, scale, **kwargs):
        """
        Set the colorbar long axis scale.

        Parameters
        ----------
        value : {"linear", "log", "symlog", "logit", ...} or `.ScaleBase`
            The axis scale type to apply.

        **kwargs
            Different keyword arguments are accepted, depending on the scale.
            See the respective class keyword arguments:

            - `matplotlib.scale.LinearScale`
            - `matplotlib.scale.LogScale`
            - `matplotlib.scale.SymmetricalLogScale`
            - `matplotlib.scale.LogitScale`
            - `matplotlib.scale.FuncScale`

        Notes
        -----
        By default, Matplotlib supports the above mentioned scales.
        Additionally, custom scales may be registered using
        `matplotlib.scale.register_scale`. These scales can then also
        be used here.
        """
        if self.orientation == 'vertical':
            self.ax.set_yscale(scale, **kwargs)
        else:
            self.ax.set_xscale(scale, **kwargs)
        if isinstance(scale, mscale.Scal
```


# lib/matplotlib/tests/test_colorbar.py

```
import numpy as np
import pytest

from matplotlib import cm
import matplotlib.colors as mcolors

from matplotlib import rc_context
from matplotlib.testing.decorators import image_comparison
import matplotlib.pyplot as plt
from matplotlib.colors import (
    BoundaryNorm, LogNorm, PowerNorm, Normalize, NoNorm
)
from matplotlib.colorbar import Colorbar
from matplotlib.ticker import FixedLocator, LogFormatter
from matplotlib.testing.decorators import check_figures_equal


def _get_cmap_norms():
    """
    Define a colormap and appropriate norms for each of the four
    possible settings of the extend keyword.

    Helper function for _colorbar_extension_shape and
    colorbar_extension_length.
    """
    # Create a colormap and specify the levels it represents.
    cmap = cm.get_cmap("RdBu", lut=5)
    clevs = [-5., -2.5, -.5, .5, 1.5, 3.5]
    # Define norms for the colormaps.
    norms = dict()
    norms['neither'] = BoundaryNorm(clevs, len(clevs) - 1)
    norms['min'] = BoundaryNorm([-10] + clevs[1:], len(clevs) - 1)
    norms['max'] = BoundaryNorm(clevs[:-1] + [10], len(clevs) - 1)
    norms['both'] = BoundaryNorm([-10] + clevs[1:-1] + [10], len(clevs) - 1)
    return cmap, norms


def _colorbar_extension_shape(spacing):
    """
    Produce 4 colorbars with rectangular extensions for either uniform
    or proportional spacing.

    Helper function for test_colorbar_extension_shape.
    """
    # Get a colormap and appropriate norms for each extension type.
    cmap, norms = _get_cmap_norms()
    # Create a figure and adjust whitespace for subplots.
    fig = plt.figure()
    fig.subplots_adjust(hspace=4)
    for i, extension_type in enumerate(('neither', 'min', 'max', 'both')):
        # Get the appropriate norm and use it to get colorbar boundaries.
        norm = norms[extension_type]
        boundaries = values = norm.boundaries
        # note that the last value was silently dropped pre 3.3:
        values = values[:-1]
        # Create a subplot.
        cax = fig.add_subplot(4, 1, i + 1)
        # Generate the colorbar.
        Colorbar(cax, cmap=cmap, norm=norm,
                 boundaries=boundaries, values=values,
                 extend=extension_type, extendrect=True,
                 orientation='horizontal', spacing=spacing)
        # Turn off text and ticks.
        cax.tick_params(left=False, labelleft=False,
                        bottom=False, labelbottom=False)
    # Return the figure to the caller.
    return fig


def _colorbar_extension_length(spacing):
    """
    Produce 12 colorbars with variable length extensions for either
    uniform or proportional spacing.

    Helper function for test_colorbar_extension_length.
    """
    # Get a colormap and appropriate norms for each extension type.
    cmap, norms = _get_cmap_norms()
    # Create a figure and adjust whitespace for subplots.
    fig = plt.figure()
    fig.subplots_adjust(hspace=.6)
    for i, extension_type in enumerate(('neither', 'min', 'max', 'both')):
        # Get the appropriate norm and use it to get colorbar boundaries.
        norm = norms[extension_type]
        boundaries = values = norm.boundaries
        values = values[:-1]
        for j, extendfrac in enumerate((None, 'auto', 0.1)):
            # Create a subplot.
            cax = fig.add_subplot(12, 1, i*3 + j + 1)
            # Generate the colorbar.
            Colorbar(cax, cmap=cmap, norm=norm,
                     boundaries=boundaries, values=values,
                     extend=extension_type, extendfrac=extendfrac,
                     orientation='horizontal', spacing=spacing)
            # Turn off text and ticks.
            cax.tick_params(left=False, labelleft=False,
                              bottom=False, labelbottom=False)
    # Return the figure to the caller.
    return fig


@image_comparison(['colorbar_extensions_shape_uniform.png',
                   'colorbar_extensions_shape_proportional.png'])
def test_colorbar_extension_shape():
    """Test rectangular colorbar extensions."""
    # Remove this line when this test image is regenerated.
    plt.rcParams['pcolormesh.snap'] = False

    # Create figures for uniform and proportionally spaced colorbars.
    _colorbar_extension_shape('uniform')
    _colorbar_extension_shape('proportional')


@image_comparison(['colorbar_extensions_uniform.png',
                   'colorbar_extensions_proportional.png'],
                  tol=1.0)
def test_colorbar_extension_length():
    """Test variable length colorbar extensions."""
    # Remove this line when this test image is regenerated.
    plt.rcParams['pcolormesh.snap'] = False

    # Create figures for uniform and proportionally spaced colorbars.
    _colorbar_extension_length('uniform')
    _colorbar_extension_length('proportional')


@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
@pytest.mark.parametrize("extend,expected", [("min", (0, 0, 0, 1)),
                                             ("max", (1, 1, 1, 1)),
                                             ("both", (1, 1, 1, 1))])
def test_colorbar_extension_inverted_axis(orientation, extend, expected):
    """Test extension color with an inverted axis"""
    data = np.arange(12).reshape(3, 4)
    fig, ax = plt.subplots()
    cmap = plt.get_cmap("viridis").with_extremes(under=(0, 0, 0, 1),
                                                 over=(1, 1, 1, 1))
    im = ax.imshow(data, cmap=cmap)
    cbar = fig.colorbar(im, orientation=orientation, extend=extend)
    if orientation == "horizontal":
        cbar.ax.invert_xaxis()
    else:
        cbar.ax.invert_yaxis()
    assert cbar._extend_patches[0].get_facecolor() == expected
    if extend == "both":
        assert len(cbar._extend_patches) == 2
        assert cbar._extend_patches[1].get_facecolor() == (0, 0, 0, 1)
    else:
        assert len(cbar._extend_patches) == 1


@pytest.mark.parametrize('use_gridspec', [True, False])
@image_comparison(['cbar_with_orientation',
                   'cbar_locationing',
                   'double_cbar',
                   'cbar_sharing',
                   ],
                  extensions=['png'], remove_text=True,
                  savefig_kwarg={'dpi': 40})
def test_colorbar_positioning(use_gridspec):
    # Remove this line when this test image is regenerated.
    plt.rcParams['pcolormesh.snap'] = False

    data = np.arange(1200).reshape(30, 40)
    levels = [0, 200, 400, 600, 800, 1000, 1200]

    # -------------------
    plt.figure()
    plt.contourf(data, levels=levels)
    plt.colorbar(orientation='horizontal', use_gridspec=use_gridspec)

    locations = ['left', 'right', 'top', 'bottom']
    plt.figure()
    for i, location in enumerate(locations):
        plt.subplot(2, 2, i + 1)
        plt.contourf(data, levels=levels)
        plt.colorbar(location=location, use_gridspec=use_gridspec)

    # -------------------
    plt.figure()
    # make some other data (random integers)
    data_2nd = np.array([[2, 3, 2, 3], [1.5, 2, 2, 3], [2, 3, 3, 4]])
    # make the random data expand to the shape of the main data
    data_2nd = np.repeat(np.repeat(data_2nd, 10, axis=1), 10, axis=0)

    color_mappable = plt.contourf(data, levels=levels, extend='both')
    # test extend frac here
    hatch_mappable = plt.contourf(data_2nd, levels=[1, 2, 3], colors='none',
                                  hatches=['/', 'o', '+'], extend='max')
    plt.contour(hatch_mappable, colors='black')

    plt.colorbar(color_mappable, location='left', label='variable 1',
                 use_gridspec=use_gridspec)
    plt.colorbar(hatch_mappable, location='right', label='variable 2',
                 use_gridspec=use_gridspec)

    # -------------------
    plt.figure()
    ax1 = plt.subplot(211, anchor='NE', aspect='equal')
    plt.contourf(data, levels=levels)
    ax2 = plt.subplot(223)
    plt.contourf(data, levels=levels)
    ax3 = plt.subplot(224)
    plt.contourf(data, levels=levels)

    plt.colorbar(ax=[ax2, ax3, ax1], location='right', pad=0.0, shrink=0.5,
                 panchor=False, use_gridspec=use_gridspec)
    plt.colorbar(ax=[ax2, ax3, ax1], location='left', shrink=0.5,
                 panchor=False, use_gridspec=use_gridspec)
    plt.colorbar(ax=[ax1], location='bottom', panchor=False,
                 anchor=(0.8, 0.5), shrink=0.6, use_gridspec=use_gridspec)


def test_colorbar_single_ax_panchor_false():
    # Just smoketesting that this doesn't crash.  Note that this differs from
    # the tests above with panchor=False because there use_gridspec is actually
    # ineffective: passing *ax* as lists always disable use_gridspec.
    plt.imshow([[0, 1]])
    plt.colorbar(panchor=False)


@image_comparison(['contour_colorbar.png'], remove_text=True)
def test_contour_colorbar():
    fig, ax = plt.subplots(figsize=(4, 2))
    data = np.arange(1200).reshape(30, 40) - 500
    levels = np.array([0, 200, 400, 600, 800, 1000, 1200]) - 500

    CS = ax.contour(data, levels=levels, extend='both')
    fig.colorbar(CS, orientation='horizontal', extend='both')
    fig.colorbar(CS, orientation='vertical')


@image_comparison(['cbar_with_subplots_adjust.png'], remove_text=True,
                  savefig_kwarg={'dpi': 40})
def test_gridspec_make_colorbar():
    plt.figure()
    data = np.arange(1200).reshape(30, 40)
    levels = [0, 200, 400, 600, 800, 1000, 1200]

    plt.subplot(121)
    plt.contourf(data, levels=levels)
    plt.colorbar(use_gridspec=True, orientation='vertical')

    plt.subplot(122)
    plt.contourf(data, levels=levels)
    plt.colorbar(use_gridspec=True, orientation='horizontal')

    plt.subplots_adjust(top=0.95, right=0.95, bottom=0.2, hspace=0.25)


@image_comparison(['colorbar_single_scatter.png'], remove_text=True,
                  savefig_kwarg={'dpi': 40})
def test_colorbar_single_scatter():
    # Issue #2642: if a path collection has only one entry,
    # the norm scaling within the colorbar must ensure a
    # finite range, otherwise a zero denominator will occur in _locate.
    plt.figure()
    x = y = [0]
    z = [50]
    cmap = plt.get_cmap('jet', 16)
    cs = plt.scatter(x, y, z, c=z, cmap=cmap)
    plt.colorbar(cs)


@pytest.mark.parametrize('use_gridspec', [False, True],
                         ids=['no gridspec', 'with gridspec'])
def test_remove_from_figure(use_gridspec):
    """
    Test `remove` with the specified ``use_gridspec`` setting
    """
    fig, ax = plt.subplots()
    sc = ax.scatter([1, 2], [3, 4], cmap="spring")
    sc.set_array(np.array([5, 6]))
    pre_position = ax.get_position()
    cb = fig.colorbar(sc, use_gridspec=use_gridspec)
    fig.subplots_adjust()
    cb.remove()
    fig.subplots_adjust()
    post_position = ax.get_position()
    assert (pre_position.get_points() == post_position.get_points()).all()


def test_remove_from_figure_cl():
    """
    Test `remove` with constrained_layout
    """
    fig, ax = plt.subplots(constrained_layout=True)
    sc = ax.scatter([1, 2], [3, 4], cmap="spring")
    sc.set_array(np.array([5, 6]))
    fig.draw_without_rendering()
    pre_position = ax.get_position()
    cb = fig.colorbar(sc)
    cb.remove()
    fig.draw_without_rendering()
    post_position = ax.get_position()
    np.testing.assert_allclose(pre_position.get_points(),
                               post_position.get_points())


def test_colorbarbase():
    # smoke test from #3805
    ax = plt.gca()
    Colorbar(ax, cmap=plt.cm.bone)


@image_comparison(['colorbar_closed_patch.png'], remove_text=True)
def test_colorbar_closed_patch():
    # Remove this line when this test image is regenerated.
    plt.rcParams['pcolormesh.snap'] = False

    fig = plt.figure(figsize=(8, 6))
    ax1 = fig.add_axes([0.05, 0.85, 0.9, 0.1])
    ax2 = fig.add_axes([0.1, 0.65, 0.75, 0.1])
    ax3 = fig.add_axes([0.05, 0.45, 0.9, 0.1])
    ax4 = fig.add_axes([0.05, 0.25, 0.9, 0.1])
    ax5 = fig.add_axes([0.05, 0.05, 0.9, 0.1])

    cmap = cm.get_cmap("RdBu", lut=5)

    im = ax1.pcolormesh(np.linspace(0, 10, 16).reshape((4, 4)), cmap=cmap)

    # The use of a "values" kwarg here is unusual.  It works only
    # because it is matched to the data range in the image and to
    # the number of colors in the LUT.
    values = np.linspace(0, 10, 5)
    cbar_kw = dict(orientation='horizontal', values=values, ticks=[])

    # The wide line is to show that the closed path is being handled
    # correctly.  See PR #4186.
    with rc_context({'axes.linewidth': 16}):
        plt.colorbar(im, cax=ax2, extend='both', extendfrac=0.5, **cbar_kw)
        plt.colorbar(im, cax=ax3, extend='both', **cbar_kw)
        plt.colorbar(im, cax=ax4, extend='both', extendrect=True, **cbar_kw)
        plt.colorbar(im, cax=ax5, extend='neither', **cbar_kw)


def test_colorbar_ticks():
    # test fix for #5673
    fig, ax = plt.subplots()
    x = np.arange(-3.0, 4.001)
    y = np.arange(-4.0, 3.001)
    X, Y = np.meshgrid(x, y)
    Z = X * Y
    clevs = np.array([-12, -5, 0, 5, 12], dtype=float)
    colors = ['r', 'g', 'b', 'c']
    cs = ax.contourf(X, Y, Z, clevs, colors=colors, extend='neither')
    cbar = fig.colorbar(cs, ax=ax, orientation='horizontal', ticks=clevs)
    assert len(cbar.ax.xaxis.get_ticklocs()) == len(clevs)


def test_colorbar_minorticks_on_off():
    # test for github issue #11510 and PR #11584
    np.random.seed(seed=12345)
    data = np.random.randn(20, 20)
    with rc_context({'_internal.classic_mode': False}):
        fig, ax = plt.subplots()
        # purposefully setting vmin and vmax to odd fractions
        # so as to check for the correct locations of the minor ticks
        im = ax.pcolormesh(data, vmin=-2.3, vmax=3.3)

        cbar = fig.colorbar(im, extend='both')
        # testing after minorticks_on()
        cbar.minorticks_on()
        np.testing.assert_almost_equal(
            cbar.ax.yaxis.get_minorticklocs(),
            [-2.2, -1.8, -1.6, -1.4, -1.2, -0.8, -0.6, -0.4, -0.2,
             0.2, 0.4, 0.6, 0.8, 1.2, 1.4, 1.6, 1.8, 2.2, 2.4, 2.6, 2.8, 3.2])
        # testing after minorticks_off()
        cbar.minorticks_off()
        np.testing.assert_almost_equal(cbar.ax.yaxis.get_minorticklocs(), [])

        im.set_clim(vmin=-1.2, vmax=1.2)
        cbar.minorticks_on()
        np.testing.assert_almost_equal(
            cbar.ax.yaxis.get_minorticklocs(),
            [-1.1, -0.9, -0.8, -0.7, -0.6, -0.4, -0.3, -0.2, -0.1,
             0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9, 1.1, 1.2, 1.3])

    # tests for github issue #13257 and PR #13265
    data = np.random.uniform(low=1, high=10, size=(20, 20))

    fig, ax = plt.subplots()
    im = ax.pcolormesh(data, norm=LogNorm())
    cbar = fig.colorbar(im)
    fig.canvas.draw()
    default_minorticklocks = cbar.ax.yaxis.get_minorticklocs()
    # test that minorticks turn off for LogNorm
    cbar.minorticks_off()
    np.testing.assert_equal(cbar.ax.yaxis.get_minorticklocs(), [])

    # test that minorticks turn back on for LogNorm
    cbar.minorticks_on()
    np.testing.assert_equal(cbar.ax.yaxis.get_minorticklocs(),
                            default_minorticklocks)

    # test issue #13339: minorticks for LogNorm should stay off
    cbar.minorticks_off()
    cbar.set_ticks([3, 5, 7, 9])
    np.testing.assert_equal(cbar.ax.yaxis.get_minorticklocs(), [])


def test_cbar_minorticks_for_rc_xyminortickvisible():
    """
    issue gh-16468.

    Making sure that minor ticks on the colorbar are turned on
    (internally) using the cbar.minorticks_on() method when
    rcParams['xtick.minor.visible'] = True (for horizontal cbar)
    rcParams['ytick.minor.visible'] = True (for vertical cbar).
    Using cbar.minorticks_on() ensures that the minor ticks
    don't overflow into the extend regions of the colorbar.
    """

    plt.rcParams['ytick.minor.visible'] = True
    plt.rcParams['xtick.minor.visible'] = True

    vmin, vmax = 0.4, 2.6
    fig, ax = plt.subplots()
    im = ax.pcolormesh([[1, 2]], vmin=vmin, vmax=vmax)

    cbar = fig.colorbar(im, extend='both', orientation='vertical')
    assert cbar.ax.yaxis.get_minorticklocs()[0] >= vmin
    assert cbar.ax.yaxis.get_minorticklocs()[-1] <= vmax

    cbar = fig.colorbar(im, extend='both', orientation='horizontal')
    assert cbar.ax.xaxis.get_minorticklocs()[0] >= vmin
    assert cbar.ax.xaxis.get_minorticklocs()[-1] <= vmax


def test_colorbar_autoticks():
    # Test new autotick modes. Needs to be classic because
    # non-classic doesn't go this route.
    with rc_context({'_internal.classic_mode': False}):
        fig, ax = plt.subplots(2, 1)
        x = np.arange(-3.0, 4.001)
        y = np.arange(-4.0, 3.001)
        X, Y = np.meshgrid(x, y)
        Z = X * Y
        Z = Z[:-1, :-1]
        pcm = ax[0].pcolormesh(X, Y, Z)
        cbar = fig.colorbar(pcm, ax=ax[0], extend='both',
                            orientation='vertical')

        pcm = ax[1].pcolormesh(X, Y, Z)
        cbar2 = fig.colorbar(pcm, ax=ax[1], extend='both',
                             orientation='vertical', shrink=0.4)
        # note only -10 to 10 are visible,
        np.testing.assert_almost_equal(cbar.ax.yaxis.get_ticklocs(),
                                       np.arange(-15, 16, 5))
        # note only -10 to 10 are visible
        np.testing.assert_almost_equal(cbar2.ax.yaxis.get_ticklocs(),
                                       np.arange(-20, 21, 10))


def test_colorbar_autotickslog():
    # Test new autotick modes...
    with rc_context({'_internal.classic_mode': False}):
        fig, ax = plt.subplots(2, 1)
        x = np.arange(-3.0, 4.001)
        y = np.arange(-4.0, 3.001)
        X, Y = np.meshgrid(x, y)
        Z = X * Y
        Z = Z[:-1, :-1]
        pcm = ax[0].pcolormesh(X, Y, 10**Z, norm=LogNorm())
        cbar = fig.colorbar(pcm, ax=ax[0], extend='both',
                            orientation='vertical')

        pcm = ax[1].pcolormesh(X, Y, 10**Z, norm=LogNorm())
        cbar2 = fig.colorbar(pcm, ax=ax[1], extend='both',
                             orientation='vertical', shrink=0.4)
        # note only -12 to +12 are visible
        np.testing.assert_almost_equal(cbar.ax.yaxis.get_ticklocs(),
                                       10**np.arange(-16., 16.2, 4.))
        # note only -24 to +24 are visible
        np.testing.assert_almost_equal(cbar2.ax.yaxis.get_ticklocs(),
                                       10**np.arange(-24., 25., 12.))


def test_colorbar_get_ticks():
    # test feature for #5792
    plt.figure()
    data = np.arange(1200).reshape(30, 40)
    levels = [0, 200, 400, 600, 800, 1000, 1200]

    plt.contourf(data, levels=levels)

    # testing getter for user set ticks
    userTicks = plt.colorbar(ticks=[0, 600, 1200])
    assert userTicks.get_ticks().tolist() == [0, 600, 1200]

    # testing for getter after calling set_ticks
    userTicks.set_ticks([600, 700, 800])
    assert userTicks.get_ticks().tolist() == [600, 700, 800]

    # testing for getter after calling set_ticks with some ticks out of bounds
    # removed #20054: other axes don't trim fixed lists, so colorbars
    # should not either:
    # userTicks.set_ticks([600, 1300, 1400, 1500])
    # assert userTicks.get_ticks().tolist() == [600]

    # testing getter when no ticks are assigned
    defTicks = plt.colorbar(orientation='horizontal')
    np.testing.assert_allclose(defTicks.get_ticks().tolist(), levels)

    # test normal ticks and minor ticks
    fig, ax = plt.subplots()
    x = np.arange(-3.0, 4.001)
    y = np.arange(-4.0, 3.001)
    X, Y = np.meshgrid(x, y)
    Z = X * Y
    Z = Z[:-1, :-1]
    pcm = ax.pcolormesh(X, Y, Z)
    cbar = fig.colorbar(pcm, ax=ax, extend='both',
                        orientation='vertical')
    ticks = cbar.get_ticks()
    np.testing.assert_allclose(ticks, np.arange(-15, 16, 5))
    assert len(cbar.get_ticks(minor=True)) == 0


@pytest.mark.parametrize("extend", ['both', 'min', 'max'])
def test_colorbar_lognorm_extension(extend):
    # Test that colorbar with lognorm is extended correctly
    f, ax = plt.subplots()
    cb = Colorbar(ax, norm=LogNorm(vmin=0.1, vmax=1000.0),
                  orientation='vertical', extend=extend)
    assert cb._values[0] >= 0.0


def test_colorbar_powernorm_extension():
    # Test that colorbar with powernorm is extended correctly
    f, ax = plt.subplots()
    cb = Colorbar(ax, norm=PowerNorm(gamma=0.5, vmin=0.0, vmax=1.0),
                  orientation='vertical', extend='both')
    assert cb._values[0] >= 0.0


def test_colorbar_axes_kw():
    # test fix for #8493: This does only test, that axes-related keywords pass
    # and do not raise an exception.
    plt.figure()
    plt.imshow([[1, 2], [3, 4]])
    plt.colorbar(orientation='horizontal', fraction=0.2, pad=0.2, shrink=0.5,
                 aspect=10, anchor=(0., 0.), panchor=(0., 1.))


def test_colorbar_log_minortick_labels():
    with rc_context({'_internal.classic_mode': False}):
        fig, ax = plt.subplots()
        pcm = ax.imshow([[10000, 50000]], norm=LogNorm())
        cb = fig.colorbar(pcm)
        fig.canvas.draw()
        lb = [l.get_text() for l in cb.ax.yaxis.get_ticklabels(which='both')]
        expected = [r'$\mathdefault{10^{4}}$',
                    r'$\mathdefault{2\times10^{4}}$',
                    r'$\mathdefault{3\times10^{4}}$',
                    r'$\mathdefault{4\times10^{4}}$']
        for exp in expected:
            assert exp in lb


def test_colorbar_renorm():
    x, y = np.ogrid[-4:4:31j, -4:4:31j]
    z = 120000*np.exp(-x**2 - y**2)

    fig, ax = plt.subplots()
    im = ax.imshow(z)
    cbar = fig.colorbar(im)
    np.testing.assert_allclose(cbar.ax.yaxis.get_majorticklocs(),
                               np.arange(0, 120000.1, 20000))

    cbar.set_ticks([1, 2, 3])
    assert isinstance(cbar.locator, FixedLocator)

    norm = LogNorm(z.min(), z.max())
    im.set_norm(norm)
    np.testing.assert_allclose(cbar.ax.yaxis.get_majorticklocs(),
                               np.logspace(-10, 7, 18))
    # note that set_norm removes the FixedLocator...
    assert np.isclose(cbar.vmin, z.min())
    cbar.set_ticks([1, 2, 3])
    assert isinstance(cbar.locator, FixedLocator)
    np.testing.assert_allclose(cbar.ax.yaxis.get_majorticklocs(),
                               [1.0, 2.0, 3.0])

    norm = LogNorm(z.min() * 1000, z.max() * 1000)
    im.set_norm(norm)
    assert np.isclose(cbar.vmin, z.min() * 1000)
    assert np.isclose(cbar.vmax, z.max() * 1000)


@pytest.mark.parametrize('fmt', ['%4.2e', '{x:.2e}'])
def test_colorbar_format(fmt):
    # make sure that format is passed properly
    x, y = np.ogrid[-4:4:31j, -4:4:31j]
    z = 120000*np.exp(-x**2 - y**2)

    fig, ax = plt.subplots()
    im = ax.imshow(z)
    cbar = fig.colorbar(im, format=fmt)
    fig.canvas.draw()
    assert cbar.ax.yaxis.get_ticklabels()[4].get_text() == '8.00e+04'

    # make sure that if we change the clim of the mappable that the
    # formatting is *not* lost:
    im.set_clim([4, 200])
    fig.canvas.draw()
    assert cbar.ax.yaxis.get_ticklabels()[4].get_text() == '2.00e+02'

    # but if we change the norm:
    im.set_norm(LogNorm(vmin=0.1, vmax=10))
    fig.canvas.draw()
    assert (cbar.ax.yaxis.get_ticklabels()[0].get_text() ==
            '$\\mathdefault{10^{\N{Minus Sign}2}}$')


def test_colorbar_scale_reset():
    x, y = np.ogrid[-4:4:31j, -4:4:31j]
    z = 120000*np.exp(-x**2 - y**2)

    fig, ax = plt.subplots()
    pcm = ax.pcolormesh(z, cmap='RdBu_r', rasterized=True)
    cbar = fig.colorbar(pcm, ax=ax)
    cbar.outline.set_edgecolor('red')
    assert cbar.ax.yaxis.get_scale() == 'linear'

    pcm.set_norm(LogNorm(vmin=1, vmax=100))
    assert cbar.ax.yaxis.get_scale() == 'log'
    pcm.set_norm(Normalize(vmin=-20, vmax=20))
    assert cbar.ax.yaxis.get_scale() == 'linear'

    assert cbar.outline.get_edgecolor() == mcolors.to_rgba('red')


def test_colorbar_get_ticks_2():
    plt.rcParams['_internal.classic_mode'] = False
    fig, ax = plt.subplots()
    pc = ax.pcolormesh([[.05, .95]])
    cb = fig.colorbar(pc)
    np.testing.assert_allclose(cb.get_ticks(), [0., 0.2, 0.4, 0.6, 0.8, 1.0])


def test_colorbar_inverted_ticks():
    fig, axs = plt.subplots(2)
    ax = axs[0]
    pc = ax.pcolormesh(10**np.arange(1, 5).reshape(2, 2), norm=LogNorm())
    cbar = fig.colorbar(pc, ax=ax, extend='both')
    ticks = cbar.get_ticks()
    cbar.ax.invert_yaxis()
    np.testing.assert_allclose(ticks, cbar.get_ticks())

    ax = axs[1]
    pc = ax.pcolormesh(np.arange(1, 5).reshape(2, 2))
    cbar = fig.colorbar(pc, ax=ax, extend='both')
    cbar.minorticks_on()
    ticks = cbar.get_ticks()
    minorticks = cbar.get_ticks(minor=True)
    assert isinstance(minorticks, np.ndarray)
    cbar.ax.invert_yaxis()
    np.testing.assert_allclose(ticks, cbar.get_ticks())
    np.testing.assert_allclose(minorticks, cbar.get_ticks(minor=True))


def test_mappable_no_alpha():
    fig, ax = plt.subplots()
    sm = cm.ScalarMappable(norm=mcolors.Normalize(), cmap='viridis')
    fig.colorbar(sm)
    sm.set_cmap('plasma')
    plt.draw()


def test_mappable_2d_alpha():
    fig, ax = plt.subplots()
    x = np.arange(1, 5).reshape(2, 2)/4
    pc = ax.pcolormesh(x, alpha=x)
    cb = fig.colorbar(pc, ax=ax)
    # The colorbar's alpha should be None and the mappable should still have
    # the original alpha array
    assert cb.alpha is None
    assert pc.get_alpha() is x
    fig.draw_without_rendering()


def test_colorbar_label():
    """
    Test the label parameter. It should just be mapped to the xlabel/ylabel of
    the axes, depending on the orientation.
    """
    fig, ax = plt.subplots()
    im = ax.imshow([[1, 2], [3, 4]])
    cbar = fig.colorbar(im, label='cbar')
    assert cbar.ax.get_ylabel() == 'cbar'
    cbar.set_label(None)
    assert cbar.ax.get_ylabel() == ''
    cbar.set_label('cbar 2')
    assert cbar.ax.get_ylabel() == 'cbar 2'

    cbar2 = fig.colorbar(im, label=None)
    assert cbar2.ax.get_ylabel() == ''

    cbar3 = fig.colorbar(im, orientation='horizontal', label='horizontal cbar')
    assert cbar3.ax.get_xlabel() == 'horizontal cbar'


@pytest.mark.parametrize("clim", [(-20000, 20000), (-32768, 0)])
def test_colorbar_int(clim):
    # Check that we cast to float early enough to not
    # overflow ``int16(20000) - int16(-20000)`` or
    # run into ``abs(int16(-32768)) == -32768``.
    fig, ax = plt.subplots()
    im = ax.imshow([[*map(np.int16, clim)]])
    fig.colorbar(im)
    assert (im.norm.vmin, im.norm.vmax) == clim


def test_anchored_cbar_position_using_specgrid():
    data = np.arange(1200).reshape(30, 40)
    levels = [0, 200, 400, 600, 800, 1000, 1200]
    shrink = 0.5
    anchor_y = 0.3
    # right
    fig, ax = plt.subplots()
    cs = ax.contourf(data, levels=levels)
    cbar = plt.colorbar(
            cs, ax=ax, use_gridspec=True,
            location='right', anchor=(1, anchor_y), shrink=shrink)

    # the bottom left corner of one ax is (x0, y0)
    # the top right corner of one ax is (x1, y1)
    # p0: the vertical / horizontal position of anchor
    x0, y0, x1, y1 = ax.get_position().extents
    cx0, cy0, cx1, cy1 = cbar.ax.get_position().extents
    p0 = (y1 - y0) * anchor_y + y0

    np.testing.assert_allclose(
            [cy1, cy0],
            [y1 * shrink + (1 - shrink) * p0, p0 * (1 - shrink) + y0 * shrink])

    # left
    fig, ax = plt.subplots()
    cs = ax.contourf(data, levels=levels)
    cbar = plt.colorbar(
            cs, ax=ax, use_gridspec=True,
            location='left', anchor=(1, anchor_y), shrink=shrink)

    # the bottom left corner of one ax is (x0, y0)
    # the top right corner of one ax is (x1, y1)
    # p0: the vertical / horizontal position of anchor
    x0, y0, x1, y1 = ax.get_position().extents
    cx0, cy0, cx1, cy1 = cbar.ax.get_position().extents
    p0 = (y1 - y0) * anchor_y + y0

    np.testing.assert_allclose(
            [cy1, cy0],
            [y1 * shrink + (1 - shrink) * p0, p0 * (1 - shrink) + y0 * shrink])

    # top
    shrink = 0.5
    anchor_x = 0.3
    fig, ax = plt.subplots()
    cs = ax.contourf(data, levels=levels)
    cbar = plt.colorbar(
            cs, ax=ax, use_gridspec=True,
            location='top', anchor=(anchor_x, 1), shrink=shrink)

    # the bottom left corner of one ax is (x0, y0)
    # the top right corner of one ax is (x1, y1)
    # p0: the vertical / horizontal position of anchor
    x0, y0, x1, y1 = ax.get_position().extents
    cx0, cy0, cx1, cy1 = cbar.ax.get_position().extents
    p0 = (x1 - x0) * anchor_x + x0

    np.testing.assert_allclose(
            [cx1, cx0],
            [x1 * shrink + (1 - shrink) * p0, p0 * (1 - shrink) + x0 * shrink])

    # bottom
    shrink = 0.5
    anchor_x = 0.3
    fig, ax = plt.subplots()
    cs = ax.contourf(data, levels=levels)
    cbar = plt.colorbar(
            cs, ax=ax, use_gridspec=True,
            location='bottom', anchor=(anchor_x, 1), shrink=shrink)

    # the bottom left corner of one ax is (x0, y0)
    # the top right corner of one ax is (x1, y1)
    # p0: the vertical / horizontal position of anchor
    x0, y0, x1, y1 = ax.get_position().extents
    cx0, cy0, cx1, cy1 = cbar.ax.get_position().extents
    p0 = (x1 - x0) * anchor_x + x0

    np.testing.assert_allclose(
            [cx1, cx0],
            [x1 * shrink + (1 - shrink) * p0, p0 * (1 - shrink) + x0 * shrink])


@image_comparison(['colorbar_change_lim_scale.png'], remove_text=True,
                  style='mpl20')
def test_colorbar_change_lim_scale():
    fig, ax = plt.subplots(1, 2, constrained_layout=True)
    pc = ax[0].pcolormesh(np.arange(100).reshape(10, 10)+1)
    cb = fig.colorbar(pc, ax=ax[0], extend='both')
    cb.ax.set_yscale('log')

    pc = ax[1].pcolormesh(np.arange(100).reshape(10, 10)+1)
    cb = fig.colorbar(pc, ax=ax[1], extend='both')
    cb.ax.set_ylim([20, 90])


@check_figures_equal(extensions=["png"])
def test_axes_handles_same_functions(fig_ref, fig_test):
    # prove that cax and cb.ax are functionally the same
    for nn, fig in enumerate([fig_ref, fig_test]):
        ax = fig.add_subplot()
        pc = ax.pcolormesh(np.ones(300).reshape(10, 30))
        cax = fig.add_axes([0.9, 0.1, 0.03, 0.8])
        cb = fig.colorbar(pc, cax=cax)
        if nn == 0:
            caxx = cax
        else:
            caxx = cb.ax
        caxx.set_yticks(np.arange(0, 20))
        caxx.set_yscale('log')
        caxx.set_position([0.92, 0.1, 0.02, 0.7])


def test_inset_colorbar_layout():
    fig, ax = plt.subplots(constrained_layout=True, figsize=(3, 6))
    pc = ax.imshow(np.arange(100).reshape(10, 10))
    cax = ax.inset_axes([1.02, 0.1, 0.03, 0.8])
    cb = fig.colorbar(pc, cax=cax)

    fig.draw_without_rendering()
    # make sure this is in the figure. In the colorbar swapping
    # it was being dropped from the list of children...
    np.testing.assert_allclose(cb.ax.get_position().bounds,
                               [0.87, 0.342, 0.0237, 0.315], atol=0.01)
    assert cb.ax in ax.child_axes


@image_comparison(['colorbar_twoslope.png'], remove_text=True,
                  style='mpl20')
def test_twoslope_colorbar():
    # Note that the second tick = 20, and should be in the middle
    # of the colorbar (white)
    # There should be no tick right at the bottom, nor at the top.
    fig, ax = plt.subplots()

    norm = mcolors.TwoSlopeNorm(20, 5, 95)
    pc = ax.pcolormesh(np.arange(1, 11), np.arange(1, 11),
                       np.arange(100).reshape(10, 10),
                       norm=norm, cmap='RdBu_r')
    fig.colorbar(pc)


@check_figures_equal(extensions=["png"])
def test_remove_cb_whose_mappable_has_no_figure(fig_ref, fig_test):
    ax = fig_test.add_subplot()
    cb = fig_test.colorbar(cm.ScalarMappable(), cax=ax)
    cb.remove()


def test_aspects():
    fig, ax = plt.subplots(3, 2, figsize=(8, 8))
    aspects = [20, 20, 10]
    extends = ['neither', 'both', 'both']
    cb = [[None, None, None], [None, None, None]]
    for nn, orient in enumerate(['vertical', 'horizontal']):
        for mm, (aspect, extend) in enumerate(zip(aspects, extends)):
            pc = ax[mm, nn].pcolormesh(np.arange(100).reshape(10, 10))
            cb[nn][mm] = fig.colorbar(pc, ax=ax[mm, nn], orientation=orient,
                                      aspect=aspect, extend=extend)
    fig.draw_without_rendering()
    # check the extends are right ratio:
    np.testing.assert_almost_equal(cb[0][1].ax.get_position().height,
                                   cb[0][0].ax.get_position().height * 0.9,
                                   decimal=2)
    # horizontal
    np.testing.assert_almost_equal(cb[1][1].ax.get_position().width,
                                   cb[1][0].ax.get_position().width * 0.9,
                                   decimal=2)
    # check correct aspect:
    pos = cb[0][0].ax.get_position(original=False)
    np.testing.assert_almost_equal(pos.height, pos.width * 20, decimal=2)
    pos = cb[1][0].ax.get_position(original=False)
    np.testing.assert_almost_equal(pos.height * 20, pos.width, decimal=2)
    # check twice as wide if aspect is 10 instead of 20
    np.testing.assert_almost_equal(
        cb[0][0].ax.get_position(original=False).width * 2,
        cb[0][2].ax.get_position(original=False).width, decimal=2)
    np.testing.assert_almost_equal(
        cb[1][0].ax.get_position(original=False).height * 2,
        cb[1][2].ax.get_position(original=False).height, decimal=2)


@image_comparison(['proportional_colorbars.png'], remove_text=True,
                  style='mpl20')
def test_proportional_colorbars():

    x = y = np.arange(-3.0, 3.01, 0.025)
    X, Y = np.meshgrid(x, y)
    Z1 = np.exp(-X**2 - Y**2)
    Z2 = np.exp(-(X - 1)**2 - (Y - 1)**2)
    Z = (Z1 - Z2) * 2

    levels = [-1.25, -0.5, -0.125, 0.125, 0.5, 1.25]
    cmap = mcolors.ListedColormap(
        ['0.3', '0.5', 'white', 'lightblue', 'steelblue'])
    cmap.set_under('darkred')
    cmap.set_over('crimson')
    norm = mcolors.BoundaryNorm(levels, cmap.N)

    extends = ['neither', 'both']
    spacings = ['uniform', 'proportional']
    fig, axs = plt.subplots(2, 2)
    for i in range(2):
        for j in range(2):
            CS3 = axs[i, j].contourf(X, Y, Z, levels, cmap=cmap, norm=norm,
                                     extend=extends[i])
            fig.colorbar(CS3, spacing=spacings[j], ax=axs[i, j])


def test_negative_boundarynorm():
    fig, ax = plt.subplots(figsize=(1, 3))
    cmap = plt.get_cmap("viridis")

    clevs = np.arange(-94, -85)
    norm = BoundaryNorm(clevs, cmap.N)
    cb = fig.colorbar(cm.ScalarMappable(cmap=cmap, norm=norm), cax=ax)
    np.testing.assert_allclose(cb.ax.get_ylim(), [clevs[0], clevs[-1]])
    np.testing.assert_allclose(cb.ax.get_yticks(), clevs)

    clevs = np.arange(85, 94)
    norm = BoundaryNorm(clevs, cmap.N)
    cb = fig.colorbar(cm.ScalarMappable(cmap=cmap, norm=norm), cax=ax)
    np.testing.assert_allclose(cb.ax.get_ylim(), [clevs[0], clevs[-1]])
    np.testing.assert_allclose(cb.ax.get_yticks(), clevs)

    clevs = np.arange(-3, 3)
    norm = BoundaryNorm(clevs, cmap.N)
    cb = fig.colorbar(cm.ScalarMappable(cmap=cmap, norm=norm), cax=ax)
    np.testing.assert_allclose(cb.ax.get_ylim(), [clevs[0], clevs[-1]])
    np.testing.assert_allclose(cb.ax.get_yticks(), clevs)

    clevs = np.arange(-8, 1)
    norm = BoundaryNorm(clevs, cmap.N)
    cb = fig.colorbar(cm.ScalarMappable(cmap=cmap, norm=norm), cax=ax)
    np.testing.assert_allclose(cb.ax.get_ylim(), [clevs[0], clevs[-1]])
    np.testing.assert_allclose(cb.ax.get_yticks(), clevs)


@image_comparison(['nonorm_colorbars.svg'], style='mpl20')
def test_nonorm():
    plt.rcParams['svg.fonttype'] = 'none'
    data = [1, 2, 3, 4, 5]

    fig, ax = plt.subplots(figsize=(6, 1))
    fig.subplots_adjust(bottom=0.5)

    norm = NoNorm(vmin=min(data), vmax=max(data))
    cmap = cm.get_cmap("viridis", len(data))
    mappable = cm.ScalarMappable(norm=norm, cmap=cmap)
    cbar = fig.colorbar(mappable, cax=ax, orientation="horizontal")


@image_comparison(['test_boundaries.png'], remove_text=True,
                  style='mpl20')
def test_boundaries():
    np.random.seed(seed=19680808)
    fig, ax = plt.subplots(figsize=(2, 2))
    pc = ax.pcolormesh(np.random.randn(10, 10), cmap='RdBu_r')
    cb = fig.colorbar(pc, ax=ax, boundaries=np.linspace(-3, 3, 7))


def test_colorbar_no_warning_rcparams_grid_true():
    # github issue #21723 - If mpl style has 'axes.grid' = True,
    # fig.colorbar raises a warning about Auto-removal of grids
    # by pcolor() and pcolormesh(). This is fixed by PR #22216.
    plt.rcParams['axes.grid'] = True
    fig, ax = plt.subplots()
    ax.grid(False)
    im = ax.pcolormesh([0, 1], [0, 1], [[1]])
    # make sure that no warning is raised by fig.colorbar
    fig.colorbar(im)


def test_colorbar_set_formatter_locator():
    # check that the locator properties echo what is on the axis:
    fig, ax = plt.subplots()
    pc = ax.pcolormesh(np.random.randn(10, 10))
    cb = fig.colorbar(pc)
    cb.ax.yaxis.set_major_locator(FixedLocator(np.arange(10)))
    cb.ax.yaxis.set_minor_locator(FixedLocator(np.arange(0, 10, 0.2)))
    assert cb.locator is cb.ax.yaxis.get_major_locator()
    assert cb.minorlocator is cb.ax.yaxis.get_minor_locator()
    cb.ax.yaxis.set_major_formatter(LogFormatter())
    cb.ax.yaxis.set_minor_formatter(LogFormatter())
    assert cb.formatter is cb.ax.yaxis.get_major_formatter()
    assert cb.minorformatter is cb.ax.yaxis.get_minor_formatter()

    # check that the setter works as expected:
    loc = FixedLocator(np.arange(7))
    cb.locator = loc
    assert cb.ax.yaxis.get_major_locator() is loc
    loc = FixedLocator(np.arange(0, 7, 0.1))
    cb.minorlocator = loc
    assert cb.ax.yaxis.get_minor_locator() is loc
    fmt = LogFormatter()
    cb.formatter = fmt
    assert cb.ax.yaxis.get_major_formatter() is fmt
    fmt = LogFormatter()
    cb.minorformatter = fmt
    assert cb.ax.yaxis.get_minor_formatter() is fmt


def test_offset_text_loc():
    plt.style.use('mpl20')
    fig, ax = plt.subplots()
    np.random.seed(seed=19680808)
    pc = ax.pcolormesh(np.random.randn(10, 10)*1e6)
    cb = fig.colorbar(pc, location='right', extend='max')
    fig.draw_without_rendering()
    # check that the offsetText is in the proper place above the
    # colorbar axes.  In this case the colorbar axes is the same
    # height as the parent, so use the parents bbox.
    assert cb.ax.yaxis.offsetText.get_position()[1] > ax.bbox.y1


def test_title_text_loc():
    plt.style.use('mpl20')
    fig, ax = plt.subplots()
    np.random.seed(seed=19680808)
    pc = ax.pcolormesh(np.random.randn(10, 10))
    cb = fig.colorbar(pc, location='right', extend='max')
    cb.ax.set_title('Aardvark')
    fig.draw_without_rendering()
    # check that the title is in the proper place above the
    # colorbar axes, including its extend triangles....
    assert (cb.ax.title.get_window_extent(fig.canvas.get_renderer()).ymax >
            cb.ax.spines['outline'].get_window_extent().ymax)

```


# lib/matplotlib/tests/baseline_images/test_colorbar (the files in it)

lib/matplotlib/tests/baseline_images/test_colorbar/cbar_locationing.png
lib/matplotlib/tests/baseline_images/test_colorbar/cbar_sharing.png
lib/matplotlib/tests/baseline_images/test_colorbar/cbar_with_orientation.png
lib/matplotlib/tests/baseline_images/test_colorbar/cbar_with_subplots_adjust.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_change_lim_scale.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_closed_patch.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_extensions_proportional.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_extensions_shape_proportional.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_extensions_shape_uniform.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_extensions_uniform.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_single_scatter.png
lib/matplotlib/tests/baseline_images/test_colorbar/colorbar_twoslope.png
lib/matplotlib/tests/baseline_images/test_colorbar/contour_colorbar.png
lib/matplotlib/tests/baseline_images/test_colorbar/double_cbar.png
lib/matplotlib/tests/baseline_images/test_colorbar/nonorm_colorbars.svg
lib/matplotlib/tests/baseline_images/test_colorbar/proportional_colorbars.png
lib/matplotlib/tests/baseline_images/test_colorbar/test_boundaries.png


# The last commit

```
98ae845d67 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest lib/matplotlib/tests/test_colorbar.py -q
...........................................................s.....        [100%]
64 passed, 1 skipped in 10.69s
scope: lib/matplotlib/colorbar.py lib/matplotlib/tests/test_colorbar.py lib/matplotlib/tests/baseline_images/test_colorbar
changed: lib/matplotlib/colorbar.py +9 -2
changed: lib/matplotlib/tests/test_colorbar.py +17 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/lib/matplotlib/colorbar.py b/lib/matplotlib/colorbar.py
index c59b0ac815..3bde9740f3 100644
--- a/lib/matplotlib/colorbar.py
+++ b/lib/matplotlib/colorbar.py
@@ -651,8 +651,15 @@ class Colorbar:
             if not self.drawedges:
                 if len(self._y) >= self.n_rasterize:
                     self.solids.set_rasterized(True)
-        self.dividers.set_segments(
-            np.dstack([X, Y])[1:-1] if self.drawedges else [])
+        if self.drawedges:
+            # The interior dividers are at the boundaries between the color
+            # blocks.  If the colorbar has extensions, also draw a divider at
+            # the boundary between each extension and the first/last block.
+            start = 0 if self._extend_lower() else 1
+            end = None if self._extend_upper() else -1
+            self.dividers.set_segments(np.dstack([X, Y])[start:end])
+        else:
+            self.dividers.set_segments([])
 
     def _add_solids_patches(self, X, Y, C, mappable):
         hatches = mappable.hatches * len(C)  # Have enough hatches.
diff --git a/lib/matplotlib/tests/test_colorbar.py b/lib/matplotlib/tests/test_colorbar.py
index ae3ab92c0d..ce2a5f3005 100644
--- a/lib/matplotlib/tests/test_colorbar.py
+++ b/lib/matplotlib/tests/test_colorbar.py
@@ -148,6 +148,23 @@ def test_colorbar_extension_inverted_axis(orientation, extend, expected):
         assert len(cbar._extend_patches) == 1
 
 
+@pytest.mark.parametrize("orientation", ["horizontal", "vertical"])
+@pytest.mark.parametrize("extend", ["neither", "min", "max", "both"])
+def test_colorbar_drawedges_extension(orientation, extend):
+    """Test that dividers are drawn at the extension boundaries."""
+    fig, ax = plt.subplots()
+    cmap = plt.get_cmap("viridis", 8)
+    norm = BoundaryNorm(np.arange(9), 8)
+    cbar = fig.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap),
+                        orientation=orientation, extend=extend,
+                        drawedges=True)
+    # The colorbar has 8 color blocks (7 interior boundaries), plus one
+    # boundary at each extension.
+    n_dividers = 7 + (extend in ("min", "both")) + (
+        extend in ("max", "both"))
+    assert len(cbar.dividers.get_segments()) == n_dividers
+
+
 @pytest.mark.parametrize('use_gridspec', [True, False])
 @image_comparison(['cbar_with_orientation',
                    'cbar_locationing',
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
check: python -m pytest lib/matplotlib/tests/test_colorbar.py -q
...........................................................s.....        [100%]
64 passed, 1 skipped in 11.17s
scope: lib/matplotlib/colorbar.py lib/matplotlib/tests/test_colorbar.py lib/matplotlib/tests/baseline_images/test_colorbar
changed: lib/matplotlib/colorbar.py +9 -2
changed: lib/matplotlib/tests/test_colorbar.py +17 -0
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
# Notes, run 2026-11-06T113317

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

[Bug]: Colorbar with drawedges=True and extend='both' does not draw edges at extremities
### Bug summary

When creating a matplotlib colorbar, it is possible to set drawedges to True which separates the colors of the colorbar with black lines. However, when the colorbar is extended using extend='both', the black lines at the extremities do not show up.

### Code for reproduction

```python
import matplotlib as mpl
import numpy as np
import matplotlib.pyplot as plt  
from matplotlib.colors import from_levels_and_colors

my_cmap = mpl.cm.viridis
bounds = np.arange(10)
nb_colors = len(bounds) + 1
colors = my_cmap(np.linspace(100, 255, nb_colors).astype(int))
my_cmap, my_norm = from_levels_and_colors(bounds, colors, extend='both')

plt.figure(figsize=(5, 1))
ax = plt.subplot(111)
cbar = mpl.colorbar.ColorbarBase(ax, cmap=my_cmap, norm=my_norm, orientation='horizontal', drawedges=True)
plt.subplots_adjust(left=0.05, bottom=0.4, right=0.95, top=0.9)
plt.show()
```


### Actual outcome

![image](https://user-images.githubusercontent.com/34058459/164254401-7516988d-1efb-4887-a631-de9a68357685.png)


### Expected outcome

![image](https://user-images.githubusercontent.com/34058459/164254881-92c167b7-aa13-4972-9955-48221b38b866.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.5.1

### Matplotlib Backend

_No response_

### Python version

_No response_

### Jupyter version

_No response_

### Installation

_No response_


# The files of the project

```
.appveyor.yml
.circleci/config.yml
.circleci/deploy-docs.sh
.coveragerc
.flake8
.git-blame-ignore-revs
.git_archival.txt
.gitattributes
.github/CONTRIBUTING.md
.github/FUNDING.yml
.github/ISSUE_TEMPLATE/bug_report.yml
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/documentation.yml
.github/ISSUE_TEMPLATE/feature_request.yml
.github/ISSUE_TEMPLATE/maintenance.yml
.github/PULL_REQUEST_TEMPLATE.md
.github/codecov.yml
.github/dependabot.yml
.github/workflows/cibuildwheel.yml
.github/workflows/circleci.yml
.github/workflows/clean_pr.yml
.github/workflows/nightlies.yml
.github/workflows/pr_welcome.yml
.github/workflows/reviewdog.yml
.github/workflows/tests.yml
.gitignore
.lgtm.yml
.mailmap
.meeseeksdev.yml
.pre-commit-config.yaml
CITATION.bib
CODE_OF_CONDUCT.md
INSTALL.rst
LICENSE/LICENSE
LICENSE/LICENSE_AMSFONTS
LICENSE/LICENSE_BAKOMA
LICENSE/LICENSE_CARLOGO
LICENSE/LICENSE_COLORBREWER
LICENSE/LICENSE_COURIERTEN
LICENSE/LICENSE_JSXTOOLS_RESIZE_OBSERVER
LICENSE/LICENSE_QT4_EDITOR
LICENSE/LICENSE_SOLARIZED
LICENSE/LICENSE_STIX
LICENSE/LICENSE_YORICK
README.rst
SECURITY.md
azure-pipelines.yml
ci/check_wheel_licenses.py
ci/silence
doc/Makefile
doc/README.txt
doc/_static/.gitignore
doc/_static/John-hunter-crop-2.jpg
doc/_static/adjustText.png
doc/_static/anatomy.png
doc/_static/animatplot.png
doc/_static/basemap_contour1.png
doc/_static/blume_table_example.png
doc/_static/brokenaxes.png
doc/_static/cartopy_hurricane_katrina_01_00.png
doc/_static/color_zorder_A.png
doc/_static/color_zorder_B.png
doc/_static/contents.png
doc/_static/demo_axes_grid.png
doc/_static/demo_mplot3d.png
doc/_static/dna_features_viewer_screenshot.png
doc/_static/eeg_large.png
doc/_static/eeg_small.png
doc/_static/fa/LICENSE
doc/_static/fa/discourse-brands.svg
doc/_static/fa/envelope-regular.svg
doc/_static/fa/github-brands.svg
doc/_static/fa/gitter-brands.svg
doc/_static/fa/hashtag-solid.svg
doc/_static/fa/plus-square-regular.svg
doc/_static/fa/question-circle-regular.svg
doc/_static/fa/stack-overflow-brands.svg
doc/_static/favicon.ico
doc/_static/figpager.png
doc/_static/geoplot_nyc_traffic_tickets.png
doc/_static/ggplot.png
doc/_static/gif_attachment_example.png
doc/_static/gold_on_carbon.jpg
doc/_static/highlight_text_examples.png
doc/_static/holoviews.png
doc/_static/icon.png
doc/_static/logo2.png
doc/_static/logo2.svg
doc/_static/logo2_compressed.svg
doc/_static/logo_sidebar.png
doc/_static/logo_sidebar_horiz.png
doc/_static/markers/m00.png
doc/_static/markers/m01.png
doc/_static/markers/m02.png
doc/_static/markers/m03.png
doc/_static/markers/m04.png
doc/_static/markers/m05.png
doc/_static/markers/m06.png
doc/_static/markers/m07.png
doc/_static/markers/m08.png
doc/_static/markers/m09.png
doc/_static/markers/m10.png
doc/_static/markers/m11.png
doc/_static/markers/m12.png
doc/_static/markers/m13.png
doc/_static/markers/m14.png
doc/_static/markers/m15.png
doc/_static/markers/m16.png
doc/_static/markers/m17.png
doc/_static/markers/m18.png
doc/_static/markers/m19.png
doc/_static/markers/m20.png
doc/_static/markers/m21.png
doc/_static/markers/m22.png
doc/_static/markers/m23.png
doc/_static/markers/m24.png
doc/_static/markers/m25.png
doc/_static/markers/m26.png
doc/_static/markers/m27.png
doc/_static/markers/m28.png
doc/_static/markers/m29.png
doc/_static/markers/m30.png
doc/_static/markers/m31.png
doc/_static/markers/m32.png
doc/_static/markers/m33.png
doc/_static/markers/m34.png
doc/_static/markers/m35.png
doc/_static/markers/m36.png
doc/_static/markers/m37.png
doc/_static/matplotlib-icon.svg
doc/_static/matplotlib_iterm2_demo.png
doc/_static/mpl-interactions-slider-animated.png
doc/_static/mpl-scatter-density.png
doc/_static/mpl.css
doc/_static/mpl_cheatsheet1.png
doc/_static/mpl_cheatsheet1_2x.png
doc/_static/mpl_template_example.png
doc/_static/navigation.png
doc/_static/numfocus_badge.png
doc/_static/numpngw_animated_example.png
doc/_static/pgf_fonts.pdf
doc/_static/pgf_fonts.png
doc/_static/pgf_preamble.pdf
doc/_static/pgf_preamble.png
doc/_static/pgf_texsystem.pdf
doc/_static/pgf_texsystem.png
doc/_static/plotnine.png
doc/_static/probscale_demo.png
doc/_static/quiver_sizes.svg
doc/_static/readme_preview.png
doc/_static/ridge_map_white_mountains.png
doc/_static/seaborn.png
doc/_static/stinkbug.png
doc/_static/sviewgui_sample.png
doc/_static/switcher.json
doc/_static/toolbar.png
doc/_static/transforms.png
doc/_static/wcsaxes.jpg
doc/_static/webagg_screenshot.png
doc/_static/yellowbrick.png
doc/_static/zenodo_cache/1004650.svg
doc/_static/zenodo_cache/1098480.svg
doc/_static/zenodo_cache/11451.svg
doc/_static/zenodo_cache/1154287.svg
doc/_static/zenodo_cache/1189358.svg
doc/_static/zenodo_cache/1202050.svg
doc/_static/zenodo_cache/1202077.svg
doc/_static/zenodo_cache/12287.svg
doc/_static/zenodo_cache/12400.svg
doc/_static/zenodo_cache/1343133.svg
doc/_static/zenodo_cache/1420605.svg
doc/_static/zenodo_cache/1482098.svg
doc/_static/zenodo_cache/1482099.svg
doc/_static/zenodo_cache/15423.svg
doc/_static/zenodo_cache/248351.svg
doc/_static/zenodo_cache/2577644.svg
doc/_static/zenodo_cache/2669103.svg
doc/_static/zenodo_cache/2893252.svg
doc/_static/zenodo_cache/3264781.svg
doc/_static/zenodo_cache/32914.svg
doc/_static/zenodo_cache/3563226.svg
doc/_static/zenodo_cache/3633833.svg
doc/_static/zenodo_cache/3633844.svg
doc/_static/zenodo_cache/3695547.svg
doc/_static/zenodo_cache/3714460.svg
doc/_static/zenodo_cache/3898017.svg
doc/_static/zenodo_cache/3948793.svg
doc/_static/zenodo_cache/3984190.svg
doc/_static/zenodo_cache/4030140.svg
doc/_static/zenodo_cache/4268928.svg
doc/_static/zenodo_cache/44579.svg
doc/_static/zenodo_cache/4475376.svg
doc/_static/zenodo_cache/4638398.svg
doc/_static/zenodo_cache/4649959.svg
doc/_static/zenodo_cache/4743323.svg
doc/_static/zenodo_cache/5194481.svg
doc/_static/zenodo_cache/56926.svg
doc/_static/zenodo_cache/570311.svg
doc/_static/zenodo_cache/5706396.svg
doc/_static/zenodo_cache/573577.svg
doc/_static/zenodo_cache/5773480.svg
doc/_static/zenodo_cache/61948.svg
doc/_templates/autofunctions.rst
doc/_templates/automodule.rst
doc/_templates/autosummary.rst
doc/_templates/cheatsheet_sidebar.html
doc/_templates/donate_sidebar.html
doc/_templates/function.rst
doc/_templates/pagesource.html
doc/_templates/search.html
doc/_templates/sidebar_announcement.html
doc/_templates/sidebar_versions.html
doc/api/_api_api.rst
doc/api/_enums_api.rst
doc/api/afm_api.rst
doc/api/animation_api.rst
doc/api/artist_api.rst
doc/api/axes_api.rst
doc/api/axis_api.rst
doc/api/backend_agg_api.rst
doc/api/backend_bases_api.rst
doc/api/backend_cairo_api.rst
doc/api/backend_gtk3_api.rst
doc/api/backend_gtk4_api.rst
doc/api/backend_managers_api.rst
doc/api/backend_mixed_api.rst
doc/api/backend_nbagg_api.rst
doc/api/backend_pdf_api.rst
doc/api/backend_pgf_api.rst
doc/api/backend_ps_api.rst
doc/api/backend_qt_api.rst
doc/api/backend_svg_api.rst
doc/api/backend_template_api.rst
doc/api/backend_tk_api.rst
doc/api/backend_tools_api.rst
doc/api/backend_webagg_api.rst
doc/api/backend_wx_api.rst
doc/api/bezier_api.rst
doc/api/blocking_input_api.rst
doc/api/category_api.rst
doc/api/cbook_api.rst
doc/api/cm_api.rst
doc/api/collections_api.rst
doc/api/colorbar_api.rst
doc/api/colors_api.rst
doc/api/container_api.rst
doc/api/contour_api.rst
doc/api/dates_api.rst
doc/api/docstring_api.rst
doc/api/dviread.rst
doc/api/figure_api.rst
doc/api/font_manager_api.rst
doc/api/fontconfig_pattern_api.rst
doc/api/gridspec_api.rst
doc/api/hatch_api.rst
doc/api/image_api.rst
doc/api/index.rst
doc/api/index_backend_api.rst
doc/api/layout_engine_api.rst
doc/api/legend_api.rst
doc/api/legend_handler_api.rst
doc/api/lines_api.rst
doc/api/markers_api.rst
doc/api/mathtext_api.rst
doc/api/matplotlib_configuration_api.rst
doc/api/mlab_api.rst
doc/api/next_api_changes.rst
doc/api/next_api_changes/README.rst
doc/api/next_api_changes/behavior/00001-ABC.rst
doc/api/next_api_changes/behavior/19214-DS.rst
doc/api/next_api_changes/behavior/19368-DS.rst
doc/api/next_api_changes/behavior/20426-JK.rst
doc/api/next_api_changes/behavior/20715-JKS.rst
doc/api/next_api_changes/behavior/21026-DS.rst
doc/api/next_api_changes/behavior/21042-AL.rst
doc/api/next_api_changes/behavior/21238-AL.rst
doc/api/next_api_changes/behavior/21983-AL.rst
doc/api/next_api_changes/behavior/22013-AL.rst
doc/api/next_api_changes/behavior/22063-SR.rst
doc/api/next_api_changes/behavior/22204-AL.rst
doc/api/next_api_changes/behavior/22229-TAC.rst
doc/api/next_api_changes/behavior/22485-TH.rst
doc/api/next_api_changes/behavior/22639-RA.rst
doc/api/next_api_changes/behavior/22691-JMK.rst
doc/api/next_api_changes/deprecations/00001-ABC.rst
doc/api/next_api_changes/deprecations/20071-AL.rst
doc/api/next_api_changes/deprecations/20839-EP.rst
doc/api/next_api_changes/deprecations/20995-AL.rst
doc/api/next_api_changes/deprecations/21056-AL.rst
doc/api/next_api_changes/deprecations/21187-AL.rst
doc/api/next_api_changes/deprecations/21356-AL.rst
doc/api/next_api_changes/deprecations/21412-AL.rst
doc/api/next_api_changes/deprecations/21425-AL.rst
doc/api/next_api_changes/deprecations/21962-AL.rst
doc/api/next_api_changes/deprecations/21965-AL.rst
doc/api/next_api_changes/deprecations/21981-AL.rst
doc/api/next_api_changes/deprecations/21982-AL.rst
doc/api/next_api_changes/deprecations/21992-AL.rst
doc/api/next_api_changes/deprecations/21995-AL.rst
doc/api/next_api_changes/deprecations/22021-AL.rst
doc/api/next_api_changes/deprecations/22025-AL.rst
doc/api/next_api_changes/deprecations/22050-AL.rst
doc/api/next_api_changes/deprecations/22051-AL.rst
doc/api/next_api_changes/deprecations/22084-SS.rst
doc/api/next_api_changes/deprecations/22097-AL.rst
doc/api/next_api_changes/deprecations/22098-AL.rst
doc/api/next_api_changes/deprecations/22123-TH.rst
doc/api/next_api_changes/deprecations/22133-OG.rst
doc/api/next_api_changes/deprecations/22134-OG.rst
doc/api/next_api_changes/deprecations/22148-OG.rst
doc/api/next_api_changes/deprecations/22245-AL.rst
doc/api/next_api_changes/deprecations/22268-OG.rst
doc/api/next_api_changes/deprecations/22317-AL.rst
doc/api/next_api_changes/deprecations/22323-GL.rst
doc/api/next_api_changes/deprecations/22345-JK.rst
doc/api/next_api_changes/deprecations/22415-AL.rst
doc/api/next_api_changes/deprecations/22418-AL.rst
doc/api/next_api_changes/deprecations/22421-AL.rst
doc/api/next_api_changes/deprecations/22422-AL.rst
doc/api/next_api_changes/deprecations/22490-AL.rst
doc/api/next_api_changes/deprecations/22503-AL.rst
doc/api/next_api_changes/deprecations/22509-AL.rst
doc/api/next_api_changes/deprecations/22539-AL.rst
doc/api/next_api_changes/deprecations/22547-AL.rst
doc/api/next_api_changes/deprecations/22554-AL.rst
doc/api/next_api_changes/deprecations/22697-OG.rst
doc/api/next_api_changes/deprecations/22725-AL.rst
doc/api/next_api_changes/deprecations/22797-OG.rst
doc/api/next_api_changes/deprecations/22813-GL.rst
doc/api/next_api_changes/deprecations/ZZZZZ-AL.rst
doc/api/next_api_changes/development/00001-ABC.rst
doc/api/next_api_changes/development/21415-AL.rst
doc/api/next_api_changes/development/22205-ES.rst
doc/api/next_api_changes/development/22550-AL.rst
doc/api/next_api_changes/removals/00001-ABC.rst
doc/api/next_api_changes/removals/00001-DS.rst
doc/api/next_api_changes/removals/20990-AL.rst
doc/api/next_api_changes/removals/21395-AL.rst
doc/api/next_api_changes/removals/21591-AL.rst
doc/api/next_api_changes/removals/21980-CC.rst
doc/api/next_api_changes/removals/22081-AL.rst
doc/api/next_api_changes/removals/22107-OG.rst
doc/api/next_api_changes/removals/22365-OG.rst
doc/api/next_api_changes/removals/22465-AL.rst
doc/api/next_api_changes/removals/22486-OG.rst
doc/api/next_api_changes/removals/22514-OG.rst
doc/api/next_api_changes/removals/22516-OG.rst
doc/api/next_api_changes/removals/22738-JL.rst
doc/api/offsetbox_api.rst
doc/api/patches_api.rst
doc/api/path_api.rst
doc/api/patheffects_api.rst
doc/api/prev_api_changes/api_changes_0.40.rst
doc/api/prev_api_changes/api_changes_0.42.rst
doc/api/prev_api_changes/api_changes_0.50.rst
doc/api/prev_api_changes/api_changes_0.54.3.rst
doc/api/prev_api_changes/api_changes_0.54.rst
doc/api/prev_api_changes/api_changes_0.60.rst
doc/api/prev_api_changes/api_changes_0.61.rst
doc/api/prev_api_changes/api_changes_0.63.rst
doc/api/prev_api_changes/api_changes_0.65.1.rst
doc/api/prev_api_changes/api_changes_0.65.rst
doc/api/prev_api_changes/api_changes_0.70.rst
doc/api/prev_api_changes/api_changes_0.71.rst
doc/api/prev_api_changes/api_changes_0.72.rst
doc/api/prev_api_changes/api_changes_0.73.rst
doc/api/prev_api_changes/api_changes_0.80.rst
doc/api/prev_api_changes/api_changes_0.81.rst
doc/api/prev_api_changes/api_changes_0.82.rst
doc/api/prev_api_changes/api_changes_0.83.rst
doc/api/prev_api_changes/api_changes_0.84.rst
doc/api/prev_api_changes/api_changes_0.85.rst
doc/api/prev_api_changes/api_changes_0.86.rst
doc/api/prev_api_changes/api_changes_0.87.7.rst
doc/api/prev_api_changes/api_changes_0.90.0.rst
doc/api/prev_api_changes/api_changes_0.90.1.rst
doc/api/prev_api_changes/api_changes_0.91.0.rst
doc/api/prev_api_changes/api_changes_0.91.2.rst
doc/api/prev_api_changes/api_changes_0.98.0.rst
doc/api/prev_api_changes/api_changes_0.98.1.rst
doc/api/prev_api_changes/api_changes_0.98.x.rst
doc/api/prev_api_changes/api_changes_0.99.rst
doc/api/prev_api_changes/api_changes_0.99.x.rst
doc/api/prev_api_changes/api_changes_1.1.x.rst
doc/api/prev_api_changes/api_changes_1.2.x.rst
doc/api/prev_api_changes/api_changes_1.3.x.rst
doc/api/prev_api_changes/api_changes_1.4.x.rst
doc/api/prev_api_changes/api_changes_1.5.0.rst
doc/api/prev_api_changes/api_changes_1.5.2.rst
doc/api/prev_api_changes/api_changes_1.5.3.rst
doc/api/prev_api_changes/api_changes_2.0.0.rst
doc/api/prev_api_changes/api_changes_2.0.1.rst
doc/api/prev_api_changes/api_changes_2.1.0.rst
doc/api/prev_api_changes/api_changes_2.1.1.rst
doc/api/prev_api_changes/api_changes_2.1.2.rst
doc/api/prev_api_changes/api_changes_2.2.0.rst
doc/api/prev_api_changes/api_changes_3.0.0.rst
doc/api/prev_api_changes/api_changes_3.0.1.rst
doc/api/prev_api_changes/api_changes_3.1.0.rst
doc/api/prev_api_changes/api_changes_3.1.1.rst
doc/api/prev_api_changes/api_changes_3.2.0.rst
doc/api/prev_api_changes/api_changes_3.2.0/behavior.rst
doc/api/prev_api_changes/api_changes_3.2.0/deprecations.rst
doc/api/prev_api_changes/api_changes_3.2.0/development.rst
doc/api/prev_api_changes/api_changes_3.2.0/removals.rst
doc/api/prev_api_changes/api_changes_3.3.0.rst
doc/api/prev_api_changes/api_changes_3.3.0/behaviour.rst
doc/api/prev_api_changes/api_changes_3.3.0/deprecations.rst
doc/api/prev_api_changes/api_changes_3.3.0/development.rst
doc/api/prev_api_changes/api_changes_3.3.0/removals.rst
doc/api/prev_api_changes/api_changes_3.3.1.rst
doc/api/prev_api_changes/api_changes_3.4.0.rst
doc/api/prev_api_changes/api_changes_3.4.0/behaviour.rst
doc/api/prev_api_changes/api_changes_3.4.0/deprecations.rst
doc/api/prev_api_changes/api_changes_3.4.0/development.rst
doc/api/prev_api_changes/api_changes_3.4.0/removals.rst
doc/api/prev_api_changes/api_changes_3.4.2.rst
doc/api/prev_api_changes/api_changes_3.5.0.rst
doc/api/prev_api_changes/api_changes_3.5.0/behaviour.rst
doc/api/prev_api_changes/api_changes_3.5.0/deprecations.rst
doc/api/prev_api_changes/api_changes_3.5.0/development.rst
doc/api/prev_api_changes/api_changes_3.5.0/removals.rst
doc/api/projections_api.rst
doc/api/pyplot_summary.rst
doc/api/quiver_api.rst
doc/api/rcsetup_api.rst
doc/api/sankey_api.rst
doc/api/scale_api.rst
doc/api/sphinxext_mathmpl_api.rst
doc/api/sphinxext_plot_directive_api.rst
doc/api/spines_api.rst
doc/api/style_api.rst
doc/api/table_api.rst
doc/api/testing_api.rst
doc/api/texmanager_api.rst
doc/api/text_api.rst
doc/api/textpath_api.rst
doc/api/ticker_api.rst
doc/api/tight_bbox_api.rst
doc/api/tight_layout_api.rst
doc/api/toolkits/axes_grid.rst
doc/api/toolkits/axes_grid1.rst
doc/api/toolkits/axisartist.rst
doc/api/toolkits/mplot3d.rst
doc/api/toolkits/mplot3d/faq.rst
doc/api/transformations.rst
doc/api/tri_api.rst
doc/api/type1font.rst
doc/api/units_api.rst
doc/api/widgets_api.rst
doc/conf.py
doc/devel/MEP/MEP08.rst
doc/devel/MEP/MEP09.rst
doc/devel/MEP/MEP10.rst
doc/devel/MEP/MEP11.rst
doc/devel/MEP/MEP12.rst
doc/devel/MEP/MEP13.rst
doc/devel/MEP/MEP14.rst
doc/devel/MEP/MEP15.rst
doc/devel/MEP/MEP19.rst
doc/devel/MEP/MEP21.rst
doc/devel/MEP/MEP22.rst
doc/devel/MEP/MEP23.rst
doc/devel/MEP/MEP24.rst
doc/devel/MEP/MEP25.rst
doc/devel/MEP/MEP26.rst
doc/devel/MEP/MEP27.rst
doc/devel/MEP/MEP28.rst
doc/devel/MEP/MEP29.rst
doc/devel/MEP/README.rst
doc/devel/MEP/index.rst
doc/devel/MEP/template.rst
doc/devel/README.txt
doc/devel/coding_guide.rst
doc/devel/color_changes.rst
doc/devel/contributing.rst
doc/devel/dependencies.rst
doc/devel/development_setup.rst
doc/devel/documenting_mpl.rst
doc/devel/gitwash/branch_dropdown.png
doc/devel/gitwash/configure_git.rst
doc/devel/gitwash/development_workflow.rst
doc/devel/gitwash/dot2_dot3.rst
doc/devel/gitwash/following_latest.rst
doc/devel/gitwash/forking_button.png
doc/devel/gitwash/forking_hell.rst
doc/devel/gitwash/git_development.rst
doc/devel/gitwash/git_install.rst
doc/devel/gitwash/git_intro.rst
doc/devel/gitwash/git_links.inc
doc/devel/gitwash/git_resources.rst
doc/devel/gitwash/index.rst
doc/devel/gitwash/known_projects.inc
doc/devel/gitwash/links.inc
doc/devel/gitwash/maintainer_workflow.rst
doc/devel/gitwash/patching.rst
doc/devel/gitwash/pull_button.png
doc/devel/gitwash/set_up_fork.rst
doc/devel/gitwash/this_project.inc
doc/devel/index.rst
doc/devel/license.rst
doc/devel/min_dep_policy.rst
doc/devel/release_guide.rst
doc/devel/style_guide.rst
doc/devel/testing.rst
doc/devel/triage.rst
doc/docutils.conf
doc/index.rst
doc/make.bat
doc/matplotlibrc
doc/missing-references.json
doc/sphinxext/__init__.py
doc/sphinxext/custom_roles.py
doc/sphinxext/gallery_order.py
doc/sphinxext/github.py
doc/sphinxext/math_symbol_table.py
doc/sphinxext/missing_references.py
doc/sphinxext/mock_gui_toolkits.py
doc/sphinxext/redirect_from.py
doc/sphinxext/skip_deprecated.py
doc/thirdpartypackages/index.rst
doc/users/explain/api_interfaces.rst
doc/users/explain/backends.rst
doc/users/explain/event_handling.rst
doc/users/explain/fonts.rst
doc/users/explain/index.rst
doc/users/explain/interactive.rst
doc/users/explain/interactive_guide.rst
doc/users/explain/performance.rst
doc/users/faq/environment_variables_faq.rst
doc/users/faq/howto_faq.rst
doc/users/faq/index.rst
doc/users/faq/troubleshooting_faq.rst
doc/users/generate_credits.py
doc/users/getting_started/index.rst
doc/users/github_stats.rst
doc/users/index.rst
doc/users/installing/index.rst
doc/users/next_whats_new.rst
doc/users/next_whats_new/3d_plot_focal_length.rst
doc/users/next_whats_new/3d_plot_roll_angle.rst
doc/users/next_whats_new/README.rst
doc/users/next_whats_new/asinh_scale.rst
doc/users/next_whats_new/color_support_for_math_to_image.rst
doc/users/next_whats_new/custom_cap_widths.rst
doc/users/next_whats_new/double_quotes_matplolibrc.rst
doc/users/next_whats_new/extending_MarkerStyle.rst
doc/users/next_whats_new/inset_axes_improvements.rst
doc/users/next_whats_new/layout_engine.rst
doc/users/next_whats_new/list_font_names.rst
doc/users/next_whats_new/marker_none.rst
doc/users/next_whats_new/min_macos_version.rst
doc/users/next_whats_new/modify_stairs_fill_edge_behaviour.rst
doc/users/next_whats_new/no_broken_streamlines.rst
doc/users/next_whats_new/polygon_selector_box.rst
doc/users/next_whats_new/polygon_vert_setter.rst
doc/users/next_whats_new/rectangle_patch_rotation.rst
doc/users/next_whats_new/selector_improvement.rst
doc/users/next_whats_new/windows_arm64.rst
doc/users/prev_whats_new/changelog.rst
doc/users/prev_whats_new/dflt_style_changes.rst
doc/users/prev_whats_new/github_stats_3.0.0.rst
doc/users/prev_whats_new/github_stats_3.0.1.rst
doc/users/prev_whats_new/github_stats_3.0.2.rst
doc/users/prev_whats_new/github_stats_3.0.3.rst
doc/users/prev_whats_new/github_stats_3.1.0.rst
doc/users/prev_whats_new/github_stats_3.1.1.rst
doc/users/prev_whats_new/github_stats_3.1.2.rst
doc/users/prev_whats_new/github_stats_3.1.3.rst
doc/users/prev_whats_new/github_stats_3.2.0.rst
doc/users/prev_whats_new/github_stats_3.2.1.rst
doc/users/prev_whats_new/github_stats_3.2.2.rst
doc/users/prev_whats_new/github_stats_3.3.0.rst
doc/users/prev_whats_new/github_stats_3.3.1.rst
doc/users/prev_whats_new/github_stats_3.3.2.rst
doc/users/prev_whats_new/github_stats_3.3.3.rst
doc/users/prev_whats_new/github_stats_3.3.4.rst
doc/users/prev_whats_new/github_stats_3.4.0.rst
doc/users/prev_whats_new/github_stats_3.4.1.rst
doc/users/prev_whats_new/github_stats_3.4.2.rst
doc/users/prev_whats_new/github_stats_3.4.3.rst
doc/users/prev_whats_new/github_stats_3.5.0.rst
doc/users/prev_whats_new/whats_new_0.98.4.rst
doc/users/prev_whats_new/whats_new_0.99.rst
doc/users/prev_whats_new/whats_new_1.0.rst
doc/users/prev_whats_new/whats_new_1.1.rst
doc/users/prev_whats_new/whats_new_1.2.2.rst
doc/users/prev_whats_new/whats_new_1.2.rst
doc/users/prev_whats_new/whats_new_1.3.rst
doc/users/prev_whats_new/whats_new_1.4.rst
doc/users/prev_whats_new/whats_new_1.5.rst
doc/users/prev_whats_new/whats_new_2.0.0.rst
doc/users/prev_whats_new/whats_new_2.1.0.rst
doc/users/prev_whats_new/whats_new_2.2.rst
doc/users/prev_whats_new/whats_new_3.0.rst
doc/users/prev_whats_new/whats_new_3.1.0.rst
doc/users/prev_whats_new/whats_new_3.2.0.rst
doc/users/prev_whats_new/whats_new_3.3.0.rst
doc/users/prev_whats_new/whats_new_3.4.0.rst
doc/users/prev_whats_new/whats_new_3.5.0.rst
```


# The last commit

```
98ae845d67 SWE-bench


```

```diff

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest lib/matplotlib/tests/test_colorbar.py -q`

## Scope
`lib/matplotlib/colorbar.py`
`lib/matplotlib/tests/test_colorbar.py`
`lib/matplotlib/tests/baseline_images/test_colorbar/`

## Done when
A colorbar created with `drawedges=True` and `extend='both'` draws black separator lines at both extremities, including the outer ends of the extension triangles.
The reproduction code from the bug report produces the expected image with edges at the left and right ends.
`(inferred)` Existing edge drawing for `extend='neither'`, `'min'`, and `'max'` is not regressed.

## Approach
Reproduce the issue, then inspect `Colorbar._add_solids` and the edge-coordinate construction used when `drawedges=True`. The likely fault is that the `LineCollection` for edges is built from `_boundaries` after duplicating the first/last boundary for extensions, which places lines at the inner extension boundaries rather than the outer extremities.

Candidate approaches:
1. Localized fix in `_add_solids`: build the edge segment coordinates from `_boundaries` plus the extension endpoints when `_extend_lower()`/`_extend_upper()` is true. Tradeoff: smallest change, but must handle both orientations and avoid mutating `_boundaries` used elsewhere.
2. Separate `edge_boundaries` array: leave `_boundaries` untouched for mesh/ticks and construct a dedicated array for the `LineCollection`. Tradeoff: safer against side effects, slightly more code.
3. Add extra line artists at the extremities when `drawedges` and extension are active. Tradeoff: simple, but may duplicate artists and fail to respect later colorbar property updates.

Add a regression test in `lib/matplotlib/tests/test_colorbar.py` that checks the edge segments include the extremities, or use a figure-comparison test if that matches the surrounding tests, then run the scoped test command.
```

### `prompt.md`

````
[Bug]: Colorbar with drawedges=True and extend='both' does not draw edges at extremities
### Bug summary

When creating a matplotlib colorbar, it is possible to set drawedges to True which separates the colors of the colorbar with black lines. However, when the colorbar is extended using extend='both', the black lines at the extremities do not show up.

### Code for reproduction

```python
import matplotlib as mpl
import numpy as np
import matplotlib.pyplot as plt  
from matplotlib.colors import from_levels_and_colors

my_cmap = mpl.cm.viridis
bounds = np.arange(10)
nb_colors = len(bounds) + 1
colors = my_cmap(np.linspace(100, 255, nb_colors).astype(int))
my_cmap, my_norm = from_levels_and_colors(bounds, colors, extend='both')

plt.figure(figsize=(5, 1))
ax = plt.subplot(111)
cbar = mpl.colorbar.ColorbarBase(ax, cmap=my_cmap, norm=my_norm, orientation='horizontal', drawedges=True)
plt.subplots_adjust(left=0.05, bottom=0.4, right=0.95, top=0.9)
plt.show()
```


### Actual outcome

![image](https://user-images.githubusercontent.com/34058459/164254401-7516988d-1efb-4887-a631-de9a68357685.png)


### Expected outcome

![image](https://user-images.githubusercontent.com/34058459/164254881-92c167b7-aa13-4972-9955-48221b38b866.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.5.1

### Matplotlib Backend

_No response_

### Python version

_No response_

### Jupyter version

_No response_

### Installation

_No response_
````

### `review.md`

```
verdict: PASS

- `lib/matplotlib/colorbar.py` now includes the first/last divider only when the corresponding extension exists, fixing the missing separator lines at extended extremities.
- Existing `extend='neither'`, `'min'`, and `'max'` edge behavior is preserved.
- The added parametrized test covers horizontal/vertical orientations and all extend modes, and the full colorbar test check passes.
- No out-of-scope files were changed.
```

### `scope.txt`

```
scope: lib/matplotlib/colorbar.py lib/matplotlib/tests/test_colorbar.py lib/matplotlib/tests/baseline_images/test_colorbar
changed: lib/matplotlib/colorbar.py +9 -2
changed: lib/matplotlib/tests/test_colorbar.py +17 -0
```

### `task.md`

````
# Task

## Prompt

[Bug]: Colorbar with drawedges=True and extend='both' does not draw edges at extremities
### Bug summary

When creating a matplotlib colorbar, it is possible to set drawedges to True which separates the colors of the colorbar with black lines. However, when the colorbar is extended using extend='both', the black lines at the extremities do not show up.

### Code for reproduction

```python
import matplotlib as mpl
import numpy as np
import matplotlib.pyplot as plt  
from matplotlib.colors import from_levels_and_colors

my_cmap = mpl.cm.viridis
bounds = np.arange(10)
nb_colors = len(bounds) + 1
colors = my_cmap(np.linspace(100, 255, nb_colors).astype(int))
my_cmap, my_norm = from_levels_and_colors(bounds, colors, extend='both')

plt.figure(figsize=(5, 1))
ax = plt.subplot(111)
cbar = mpl.colorbar.ColorbarBase(ax, cmap=my_cmap, norm=my_norm, orientation='horizontal', drawedges=True)
plt.subplots_adjust(left=0.05, bottom=0.4, right=0.95, top=0.9)
plt.show()
```


### Actual outcome

![image](https://user-images.githubusercontent.com/34058459/164254401-7516988d-1efb-4887-a631-de9a68357685.png)


### Expected outcome

![image](https://user-images.githubusercontent.com/34058459/164254881-92c167b7-aa13-4972-9955-48221b38b866.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.5.1

### Matplotlib Backend

_No response_

### Python version

_No response_

### Jupyter version

_No response_

### Installation

_No response_

## Deliverable

changes to this tree

## Check

`python -m pytest lib/matplotlib/tests/test_colorbar.py -q`

## Scope

`lib/matplotlib/colorbar.py`
`lib/matplotlib/tests/test_colorbar.py`
`lib/matplotlib/tests/baseline_images/test_colorbar/`

## Done when

A colorbar created with `drawedges=True` and `extend='both'` draws black separator lines at both extremities, including the outer ends of the extension triangles.
The reproduction code from the bug report produces the expected image with edges at the left and right ends.
`(inferred)` Existing edge drawing for `extend='neither'`, `'min'`, and `'max'` is not regressed.
````

### `test-output.log`

```
check: python -m pytest lib/matplotlib/tests/test_colorbar.py -q
...........................................................s.....        [100%]
64 passed, 1 skipped in 10.79s
scope: lib/matplotlib/colorbar.py lib/matplotlib/tests/test_colorbar.py lib/matplotlib/tests/baseline_images/test_colorbar
changed: lib/matplotlib/colorbar.py +9 -2
changed: lib/matplotlib/tests/test_colorbar.py +17 -0
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
