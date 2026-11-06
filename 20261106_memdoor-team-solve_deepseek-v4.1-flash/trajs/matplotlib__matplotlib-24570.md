# matplotlib__matplotlib-24570 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 466s 75 lines cost=0.010381 in=323206 cached=256000 out=19697 calls=23`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

[Bug]: `align` in `HPacker` is reversed
### Bug summary

For the `align` parameter in `HPacker`, the options `top` and `bottom` seems reversed

### Code for reproduction

```python
import matplotlib.pyplot as plt
from matplotlib.offsetbox import DrawingArea, HPacker, VPacker, AnchoredOffsetbox, TextArea
from matplotlib.patches import Rectangle

da1 = DrawingArea(10, 20)
rect1 = Rectangle((0, 0), 10, 20)
da1.add_artist(rect1)

da2 = DrawingArea(10, 30)
rect2 = Rectangle((0, 0), 10, 30)
da2.add_artist(rect2)

align = "bottom"

pack = HPacker(children=[da1, da2], pad=10, sep=10, align=align)
title = TextArea(f"align='{align}'")
pack = VPacker(children=[title, pack], sep=10, pad=10, align="center")

box = AnchoredOffsetbox(child=pack, loc="center")

_, ax = plt.subplots()
ax.add_artist(box)
```


### Actual outcome

![download](https://user-images.githubusercontent.com/23433306/200162888-702626bf-ad47-40e2-8751-7dffe91df85c.png)


### Expected outcome

![download](https://user-images.githubusercontent.com/23433306/200162908-e0e9dfd5-6f8b-4aac-975e-bb363d809c41.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.6.2

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
  "command": "ls && grep -rn \"class HPacker\\|def _get_aligned_offsets\\|class VPacker\" lib/matplotlib/offsetbox.py | head -50"
}
```

**tool result**

```
CITATION.bib
CODE_OF_CONDUCT.md
INSTALL.rst
LICENSE
README.md
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
pyproject.toml
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
130:def _get_aligned_offsets(hd_list, height, align="baseline"):
418:class VPacker(PackerBase):
459:class HPacker(PackerBase):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '110,200p' lib/matplotlib/offsetbox.py; echo ---; sed -n '280,540p' lib/matplotlib/offsetbox.py"
}
```

**tool result**

```
            sep = (total - sum(widths)) / (len(widths) - 1)
        else:
            sep = 0
        offsets_ = np.cumsum([0] + [w + sep for w in widths])
        offsets = offsets_[:-1]
        return total, offsets

    elif mode == "equal":
        maxh = max(widths)
        if total is None:
            if sep is None:
                raise ValueError("total and sep cannot both be None when "
                                 "using layout mode 'equal'")
            total = (maxh + sep) * len(widths)
        else:
            sep = total / len(widths) - maxh
        offsets = (maxh + sep) * np.arange(len(widths))
        return total, offsets


def _get_aligned_offsets(hd_list, height, align="baseline"):
    """
    Align boxes each specified by their ``(height, descent)`` pair.

    For simplicity of the description, the terminology used here assumes a
    horizontal layout (i.e., vertical alignment), but the function works
    equally for a vertical layout.

    Parameters
    ----------
    hd_list
        List of (height, xdescent) of boxes to be aligned.
    height : float or None
        Intended total height. If None, the maximum of the heights in *hd_list*
        is used.
    align : {'baseline', 'left', 'top', 'right', 'bottom', 'center'}
        The alignment anchor of the boxes.

    Returns
    -------
    height
        The total height of the packing (if a value was originally passed in,
        it is returned without checking that it is actually large enough).
    descent
        The descent of the packing.
    offsets
        The bottom offsets of the boxes.
    """

    if height is None:
        height = max(h for h, d in hd_list)
    _api.check_in_list(
        ["baseline", "left", "top", "right", "bottom", "center"], align=align)

    if align == "baseline":
        height_descent = max(h - d for h, d in hd_list)
        descent = max(d for h, d in hd_list)
        height = height_descent + descent
        offsets = [0. for h, d in hd_list]
    elif align in ["left", "top"]:
        descent = 0.
        offsets = [d for h, d in hd_list]
    elif align in ["right", "bottom"]:
        descent = 0.
        offsets = [height - h + d for h, d in hd_list]
    elif align == "center":
        descent = 0.
        offsets = [(height - h) * .5 + d for h, d in hd_list]

    return height, descent, offsets


class OffsetBox(martist.Artist):
    """
    The OffsetBox is a simple container artist.

    The child artists are meant to be drawn at a relative position to its
    parent.

    Being an artist itself, all parameters are passed on to `.Artist`.
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args)
        self._internal_update(kwargs)
        # Clipping has not been implemented in the OffsetBox family, so
        # disable the clip flag for consistency. It can always be turned back
        # on to zero effect.
        self.set_clip_on(False)
        self._children = []
        self._offset = (0, 0)

---
        Parameters
        ----------
        width, height, xdescent, ydescent
            Extent parameters.
        renderer : `.RendererBase` subclass

        """
        return (self._offset(width, height, xdescent, ydescent, renderer)
                if callable(self._offset)
                else self._offset)

    def set_width(self, width):
        """
        Set the width of the box.

        Parameters
        ----------
        width : float
        """
        self.width = width
        self.stale = True

    def set_height(self, height):
        """
        Set the height of the box.

        Parameters
        ----------
        height : float
        """
        self.height = height
        self.stale = True

    def get_visible_children(self):
        r"""Return a list of the visible child `.Artist`\s."""
        return [c for c in self._children if c.get_visible()]

    def get_children(self):
        r"""Return a list of the child `.Artist`\s."""
        return self._children

    def get_extent_offsets(self, renderer):
        """
        Update offset of the children and return the extent of the box.

        Parameters
        ----------
        renderer : `.RendererBase` subclass

        Returns
        -------
        width
        height
        xdescent
        ydescent
        list of (xoffset, yoffset) pairs
        """
        raise NotImplementedError(
            "get_extent_offsets must be overridden in derived classes.")

    def get_extent(self, renderer):
        """Return a tuple ``width, height, xdescent, ydescent`` of the box."""
        w, h, xd, yd, offsets = self.get_extent_offsets(renderer)
        return w, h, xd, yd

    def get_window_extent(self, renderer=None):
        # docstring inherited
        if renderer is None:
            renderer = self.figure._get_renderer()
        w, h, xd, yd = self.get_extent(renderer)
        # Some subclasses redefine get_offset to take no args.
        try:
            px, py = self.get_offset(w, h, xd, yd, renderer)
        except TypeError:
            px, py = self.get_offset()
        return mtransforms.Bbox.from_bounds(px - xd, py - yd, w, h)

    def draw(self, renderer):
        """
        Update the location of children if necessary and draw them
        to the given *renderer*.
        """
        w, h, xdescent, ydescent, offsets = self.get_extent_offsets(renderer)
        px, py = self.get_offset(w, h, xdescent, ydescent, renderer)
        for c, (ox, oy) in zip(self.get_visible_children(), offsets):
            c.set_offset((px + ox, py + oy))
            c.draw(renderer)
        bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class PackerBase(OffsetBox):
    def __init__(self, pad=None, sep=None, width=None, height=None,
                 align="baseline", mode="fixed", children=None):
        """
        Parameters
        ----------
        pad : float, optional
            The boundary padding in points.

        sep : float, optional
            The spacing between items in points.

        width, height : float, optional
            Width and height of the container box in pixels, calculated if
            *None*.

        align : {'top', 'bottom', 'left', 'right', 'center', 'baseline'}, \
default: 'baseline'
            Alignment of boxes.

        mode : {'fixed', 'expand', 'equal'}, default: 'fixed'
            The packing mode.

            - 'fixed' packs the given `.Artist`\\s tight with *sep* spacing.
            - 'expand' uses the maximal available space to distribute the
              artists with equal spacing in between.
            - 'equal': Each artist an equal fraction of the available space
              and is left-aligned (or top-aligned) therein.

        children : list of `.Artist`
            The artists to pack.

        Notes
        -----
        *pad* and *sep* are in points and will be scaled with the renderer
        dpi, while *width* and *height* are in pixels.
        """
        super().__init__()
        self.height = height
        self.width = width
        self.sep = sep
        self.pad = pad
        self.mode = mode
        self.align = align
        self._children = children


class VPacker(PackerBase):
    """
    VPacker packs its children vertically, automatically adjusting their
    relative positions at draw time.
    """

    def get_extent_offsets(self, renderer):
        # docstring inherited
        dpicor = renderer.points_to_pixels(1.)
        pad = self.pad * dpicor
        sep = self.sep * dpicor

        if self.width is not None:
            for c in self.get_visible_children():
                if isinstance(c, PackerBase) and c.mode == "expand":
                    c.set_width(self.width)

        whd_list = [c.get_extent(renderer)
                    for c in self.get_visible_children()]
        whd_list = [(w, h, xd, (h - yd)) for w, h, xd, yd in whd_list]

        wd_list = [(w, xd) for w, h, xd, yd in whd_list]
        width, xdescent, xoffsets = _get_aligned_offsets(wd_list,
                                                         self.width,
                                                         self.align)

        pack_list = [h for w, h, xd, yd in whd_list]
        height, yoffsets_ = _get_packed_offsets(pack_list, self.height,
                                                sep, self.mode)

        yoffsets = yoffsets_ + [yd for w, h, xd, yd in whd_list]
        ydescent = height - yoffsets[0]
        yoffsets = height - yoffsets

        yoffsets = yoffsets - ydescent

        return (width + 2 * pad, height + 2 * pad,
                xdescent + pad, ydescent + pad,
                list(zip(xoffsets, yoffsets)))


class HPacker(PackerBase):
    """
    HPacker packs its children horizontally, automatically adjusting their
    relative positions at draw time.
    """

    def get_extent_offsets(self, renderer):
        # docstring inherited
        dpicor = renderer.points_to_pixels(1.)
        pad = self.pad * dpicor
        sep = self.sep * dpicor

        whd_list = [c.get_extent(renderer)
                    for c in self.get_visible_children()]

        if not whd_list:
            return 2 * pad, 2 * pad, pad, pad, []

        hd_list = [(h, yd) for w, h, xd, yd in whd_list]
        height, ydescent, yoffsets = _get_aligned_offsets(hd_list,
                                                          self.height,
                                                          self.align)

        pack_list = [w for w, h, xd, yd in whd_list]
        width, xoffsets_ = _get_packed_offsets(pack_list, self.width,
                                               sep, self.mode)

        xoffsets = xoffsets_ + [xd for w, h, xd, yd in whd_list]

        xdescent = whd_list[0][2]
        xoffsets = xoffsets - xdescent

        return (width + 2 * pad, height + 2 * pad,
                xdescent + pad, ydescent + pad,
                list(zip(xoffsets, yoffsets)))


class PaddedBox(OffsetBox):
    """
    A container to add a padding around an `.Artist`.

    The `.PaddedBox` contains a `.FancyBboxPatch` that is used to visualize
    it when rendering.
    """

    @_api.make_keyword_only("3.6", name="draw_frame")
    def __init__(self, child, pad=None, draw_frame=False, patch_attrs=None):
        """
        Parameters
        ----------
        child : `~matplotlib.artist.Artist`
            The contained `.Artist`.
        pad : float
            The padding in points. This will be scaled with the renderer dpi.
            In contrast, *width* and *height* are in *pixels* and thus not
            scaled.
        draw_frame : bool
            Whether to draw the contained `.FancyBboxPatch`.
        patch_attrs : dict or None
            Additional parameters passed to the contained `.FancyBboxPatch`.
        """
        super().__init__()
        self.pad = pad
        self._children = [child]
        self.patch = FancyBboxPatch(
            xy=(0.0, 0.0), width=1., height=1.,
            facecolor='w', edgecolor='k',
            mutation_scale=1,  # self.prop.get_size_in_points(),
            snap=True,
            visible=draw_frame,
            boxstyle="square,pad=0",
        )
        if patch_attrs is not None:
            self.patch.update(patch_attrs)

    def get_extent_offsets(self, renderer):
        # docstring inherited.
        dpicor = renderer.points_to_pixels(1.)
        pad = self.pad * dpicor
        w, h, xd, yd = self._children[0].get_extent(renderer)
        return (w + 2 * pad, h + 2 * pad, xd + pad, yd + pad,
                [(0, 0)])
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class TextArea\\|class DrawingArea\\|def draw\\|def get_extent\" lib/matplotlib/offsetbox.py | sed -n '1,80p'; echo ---; sed -n '540,760p' lib/matplotlib/offsetbox.py"
}
```

**tool result**

```
321:    def get_extent_offsets(self, renderer):
340:    def get_extent(self, renderer):
357:    def draw(self, renderer):
424:    def get_extent_offsets(self, renderer):
465:    def get_extent_offsets(self, renderer):
534:    def get_extent_offsets(self, renderer):
542:    def draw(self, renderer):
562:    def draw_frame(self, renderer):
568:class DrawingArea(OffsetBox):
638:    def get_extent(self, renderer):
655:    def draw(self, renderer):
679:class TextArea(OffsetBox):
766:    def get_extent(self, renderer):
794:    def draw(self, renderer):
861:    def get_extent(self, renderer):
876:    def draw(self, renderer):
990:    def get_extent(self, renderer):
1052:    def draw(self, renderer):
1185:    def get_extent(self, renderer):
1198:    def draw(self, renderer):
1443:    def draw(self, renderer):
---
                [(0, 0)])

    def draw(self, renderer):
        # docstring inherited
        w, h, xdescent, ydescent, offsets = self.get_extent_offsets(renderer)
        px, py = self.get_offset(w, h, xdescent, ydescent, renderer)
        for c, (ox, oy) in zip(self.get_visible_children(), offsets):
            c.set_offset((px + ox, py + oy))

        self.draw_frame(renderer)

        for c in self.get_visible_children():
            c.draw(renderer)

        self.stale = False

    def update_frame(self, bbox, fontsize=None):
        self.patch.set_bounds(bbox.bounds)
        if fontsize:
            self.patch.set_mutation_scale(fontsize)
        self.stale = True

    def draw_frame(self, renderer):
        # update the location and size of the legend
        self.update_frame(self.get_window_extent(renderer))
        self.patch.draw(renderer)


class DrawingArea(OffsetBox):
    """
    The DrawingArea can contain any Artist as a child. The DrawingArea
    has a fixed width and height. The position of children relative to
    the parent is fixed. The children can be clipped at the
    boundaries of the parent.
    """

    def __init__(self, width, height, xdescent=0., ydescent=0., clip=False):
        """
        Parameters
        ----------
        width, height : float
            Width and height of the container box.
        xdescent, ydescent : float
            Descent of the box in x- and y-direction.
        clip : bool
            Whether to clip the children to the box.
        """
        super().__init__()
        self.width = width
        self.height = height
        self.xdescent = xdescent
        self.ydescent = ydescent
        self._clip_children = clip
        self.offset_transform = mtransforms.Affine2D()
        self.dpi_transform = mtransforms.Affine2D()

    @property
    def clip_children(self):
        """
        If the children of this DrawingArea should be clipped
        by DrawingArea bounding box.
        """
        return self._clip_children

    @clip_children.setter
    def clip_children(self, val):
        self._clip_children = bool(val)
        self.stale = True

    def get_transform(self):
        """
        Return the `~matplotlib.transforms.Transform` applied to the children.
        """
        return self.dpi_transform + self.offset_transform

    def set_transform(self, t):
        """
        set_transform is ignored.
        """

    def set_offset(self, xy):
        """
        Set the offset of the container.

        Parameters
        ----------
        xy : (float, float)
            The (x, y) coordinates of the offset in display units.
        """
        self._offset = xy
        self.offset_transform.clear()
        self.offset_transform.translate(xy[0], xy[1])
        self.stale = True

    def get_offset(self):
        """Return offset of the container."""
        return self._offset

    def get_extent(self, renderer):
        """Return width, height, xdescent, ydescent of box."""
        dpi_cor = renderer.points_to_pixels(1.)
        return (self.width * dpi_cor, self.height * dpi_cor,
                self.xdescent * dpi_cor, self.ydescent * dpi_cor)

    def add_artist(self, a):
        """Add an `.Artist` to the container box."""
        self._children.append(a)
        if not a.is_transform_set():
            a.set_transform(self.get_transform())
        if self.axes is not None:
            a.axes = self.axes
        fig = self.figure
        if fig is not None:
            a.set_figure(fig)

    def draw(self, renderer):
        # docstring inherited

        dpi_cor = renderer.points_to_pixels(1.)
        self.dpi_transform.clear()
        self.dpi_transform.scale(dpi_cor)

        # At this point the DrawingArea has a transform
        # to the display space so the path created is
        # good for clipping children
        tpath = mtransforms.TransformedPath(
            mpath.Path([[0, 0], [0, self.height],
                        [self.width, self.height],
                        [self.width, 0]]),
            self.get_transform())
        for c in self._children:
            if self._clip_children and not (c.clipbox or c._clippath):
                c.set_clip_path(tpath)
            c.draw(renderer)

        bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class TextArea(OffsetBox):
    """
    The TextArea is a container artist for a single Text instance.

    The text is placed at (0, 0) with baseline+left alignment, by default. The
    width and height of the TextArea instance is the width and height of its
    child text.
    """

    @_api.make_keyword_only("3.6", name="textprops")
    def __init__(self, s,
                 textprops=None,
                 multilinebaseline=False,
                 ):
        """
        Parameters
        ----------
        s : str
            The text to be displayed.
        textprops : dict, default: {}
            Dictionary of keyword parameters to be passed to the `.Text`
            instance in the TextArea.
        multilinebaseline : bool, default: False
            Whether the baseline for multiline text is adjusted so that it
            is (approximately) center-aligned with single-line text.
        """
        if textprops is None:
            textprops = {}
        self._text = mtext.Text(0, 0, s, **textprops)
        super().__init__()
        self._children = [self._text]
        self.offset_transform = mtransforms.Affine2D()
        self._baseline_transform = mtransforms.Affine2D()
        self._text.set_transform(self.offset_transform +
                                 self._baseline_transform)
        self._multilinebaseline = multilinebaseline

    def set_text(self, s):
        """Set the text of this area as a string."""
        self._text.set_text(s)
        self.stale = True

    def get_text(self):
        """Return the string representation of this area's text."""
        return self._text.get_text()

    def set_multilinebaseline(self, t):
        """
        Set multilinebaseline.

        If True, the baseline for multiline text is adjusted so that it is
        (approximately) center-aligned with single-line text.  This is used
        e.g. by the legend implementation so that single-line labels are
        baseline-aligned, but multiline labels are "center"-aligned with them.
        """
        self._multilinebaseline = t
        self.stale = True

    def get_multilinebaseline(self):
        """
        Get multilinebaseline.
        """
        return self._multilinebaseline

    def set_transform(self, t):
        """
        set_transform is ignored.
        """

    def set_offset(self, xy):
        """
        Set the offset of the container.

        Parameters
        ----------
        xy : (float, float)
            The (x, y) coordinates of the offset in display units.
        """
        self._offset = xy
        self.offset_transform.clear()
        self.offset_transform.translate(xy[0], xy[1])
        self.stale = True
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"HPacker\\|_get_aligned_offsets\\|align=\\\"top\\\"\\|align='top'\" lib/matplotlib/tests/test_offsetbox.py | head -60; echo ---; git log --oneline -5"
}
```

**tool result**

```
---
31b1ec1d58 SWE-bench
8f0003ae90 Merge pull request #23812 from tacaswell/ci_add_codeql
9b7c902fd7 Merge pull request #24556 from leejjoon/fix-axesimage-window-extent
50218d16b8 Add test for AxesImage.get_window_extent w/ transAxes
5044b59a55 Merge pull request #24566 from anntzer/xticksargscheck
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"Packer\\|align\" lib/matplotlib/tests/test_offsetbox.py | head -80"
}
```

**tool result**

```
244:@image_comparison(['anchoredtext_align.png'], remove_text=True, style='mpl20')
245:def test_anchoredtext_horizontal_alignment():
274:                         boxcoords="axes fraction", box_alignment=(0., .5),
334:                        boxcoords="axes fraction", box_alignment=(0., .5),
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '760,820p' lib/matplotlib/offsetbox.py; grep -rn \"align=\\\"top\\\"\\|align='top'\\|align=\\\"bottom\\\"\\|align='bottom'\\|HPacker\\|VPacker\" lib/matplotlib | grep -v offsetbox.py | head -60"
}
```

**tool result**

```
        self.stale = True

    def get_offset(self):
        """Return offset of the container."""
        return self._offset

    def get_extent(self, renderer):
        _, h_, d_ = renderer.get_text_width_height_descent(
            "lp", self._text._fontproperties,
            ismath="TeX" if self._text.get_usetex() else False)

        bbox, info, yd = self._text._get_layout(renderer)
        w, h = bbox.size

        self._baseline_transform.clear()

        if len(info) > 1 and self._multilinebaseline:
            yd_new = 0.5 * h - 0.5 * (h_ - d_)
            self._baseline_transform.translate(0, yd - yd_new)
            yd = yd_new
        else:  # single line
            h_d = max(h_ - d_, h - yd)
            h = h_d + yd

        ha = self._text.get_horizontalalignment()
        if ha == 'left':
            xd = 0
        elif ha == 'center':
            xd = w / 2
        elif ha == 'right':
            xd = w

        return w, h, xd, yd

    def draw(self, renderer):
        # docstring inherited
        self._text.draw(renderer)
        bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class AuxTransformBox(OffsetBox):
    """
    Offset Box with the aux_transform. Its children will be
    transformed with the aux_transform first then will be
    offsetted. The absolute coordinate of the aux_transform is meaning
    as it will be automatically adjust so that the left-lower corner
    of the bounding box of children will be set to (0, 0) before the
    offset transform.

    It is similar to drawing area, except that the extent of the box
    is not predetermined but calculated from the window extent of its
    children. Furthermore, the extent of the children will be
    calculated in the transformed coordinate.
    """
    def __init__(self, aux_transform):
        self.aux_transform = aux_transform
        super().__init__()
        self.offset_transform = mtransforms.Affine2D()
        # ref_offset_transform makes offset_transform always relative to the
        # lower-left corner of the bbox of its children.
lib/matplotlib/legend.py:46:    HPacker, VPacker,
lib/matplotlib/legend.py:450:        # _legend_box is a VPacker instance that contains all
lib/matplotlib/legend.py:753:        # legend_box is a HPacker, horizontally packed with columns.
lib/matplotlib/legend.py:754:        # Each column is a VPacker, vertically packed with legend items.
lib/matplotlib/legend.py:755:        # Each legend item is a HPacker packed with:
lib/matplotlib/legend.py:814:            itemboxes = [HPacker(pad=0,
lib/matplotlib/legend.py:821:            columnbox.append(VPacker(pad=0,
lib/matplotlib/legend.py:828:        self._legend_handle_box = HPacker(pad=0,
lib/matplotlib/legend.py:833:        self._legend_box = VPacker(pad=self.borderpad * fontsize,
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '800,845p' lib/matplotlib/legend.py; cat > /tmp/repro.py <<'EOF'\nimport matplotlib\nmatplotlib.use('Agg')\nimport matplotlib.pyplot as plt\nfrom matplotlib.offsetbox import DrawingArea, HPacker, VPacker, AnchoredOffsetbox, TextArea\nfrom matplotlib.patches import Rectangle\n\nfor align in [\"top\",\"bottom\",\"center\",\"baseline\"]:\n    da1 = DrawingArea(10, 20); da1.add_artist(Rectangle((0,0),10,20))\n    da2 = DrawingArea(10, 30); da2.add_artist(Rectangle((0,0),10,30))\n    pack = HPacker(children=[da1,da2], pad=10, sep=10, align=align)\n    title = TextArea(f\"align='{align}'\")\n    pack = VPacker(children=[title,pack], sep=10, pad=10, align=\"center\")\n    box = AnchoredOffsetbox(child=pack, loc=\"center\")\n    fig, ax = plt.subplots()\n    ax.add_artist(box)\n    fig.savefig(f'/tmp/out_{align}.png')\nEOF\npython /tmp/repro.py && echo done"
}
```

**tool result**

```
                # Create the artist for the legend which represents the
                # original artist/handle.
                handle_list.append(handler.legend_artist(self, orig_handle,
                                                         fontsize, handlebox))
                handles_and_labels.append((handlebox, textbox))

        columnbox = []
        # array_split splits n handles_and_labels into ncols columns, with the
        # first n%ncols columns having an extra entry.  filter(len, ...)
        # handles the case where n < ncols: the last ncols-n columns are empty
        # and get filtered out.
        for handles_and_labels_column in filter(
                len, np.array_split(handles_and_labels, self._ncols)):
            # pack handlebox and labelbox into itembox
            itemboxes = [HPacker(pad=0,
                                 sep=self.handletextpad * fontsize,
                                 children=[h, t] if markerfirst else [t, h],
                                 align="baseline")
                         for h, t in handles_and_labels_column]
            # pack columnbox
            alignment = "baseline" if markerfirst else "right"
            columnbox.append(VPacker(pad=0,
                                     sep=self.labelspacing * fontsize,
                                     align=alignment,
                                     children=itemboxes))

        mode = "expand" if self._mode == "expand" else "fixed"
        sep = self.columnspacing * fontsize
        self._legend_handle_box = HPacker(pad=0,
                                          sep=sep, align="baseline",
                                          mode=mode,
                                          children=columnbox)
        self._legend_title_box = TextArea("")
        self._legend_box = VPacker(pad=self.borderpad * fontsize,
                                   sep=self.labelspacing * fontsize,
                                   align=self._alignment,
                                   children=[self._legend_title_box,
                                             self._legend_handle_box])
        self._legend_box.set_figure(self.figure)
        self._legend_box.axes = self.axes
        self.texts = text_list
        self.legendHandles = handle_list

    def _auto_legend_data(self):
        """
        Return display coordinates for hit testing for "best" positioning.
done
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_\\|Packer\" lib/matplotlib/tests/test_offsetbox.py | sed -n '1,120p'; sed -n '1,40p' lib/matplotlib/tests/test_offsetbox.py"
}
```

**tool result**

```
20:def test_offsetbox_clipping():
54:def test_offsetbox_clip_children():
91:def test_offsetbox_loc_codes():
112:def test_expand_with_tight_layout():
130:def test_get_packed_offsets(widths, total, sep, mode):
150:def test_get_packed_offsets_fixed(widths, total, sep, expected):
164:def test_get_packed_offsets_expand(widths, total, sep, expected):
179:def test_get_packed_offsets_equal(widths, total, sep, expected):
185:def test_get_packed_offsets_equal_total_none_sep_none():
194:def test_picking(child_type, boxcoords):
245:def test_anchoredtext_horizontal_alignment():
259:def test_annotationbbox_extents():
326:def test_zorder():
330:def test_arrowprops_copied():
from collections import namedtuple
import io

import numpy as np
from numpy.testing import assert_allclose
import pytest

from matplotlib.testing.decorators import image_comparison
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.lines as mlines
from matplotlib.backend_bases import MouseButton, MouseEvent

from matplotlib.offsetbox import (
    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, OffsetBox,
    OffsetImage, TextArea, _get_packed_offsets)


@image_comparison(['offsetbox_clipping'], remove_text=True)
def test_offsetbox_clipping():
    # - create a plot
    # - put an AnchoredOffsetbox with a child DrawingArea
    #   at the center of the axes
    # - give the DrawingArea a gray background
    # - put a black line across the bounds of the DrawingArea
    # - see that the black line is clipped to the edges of
    #   the DrawingArea.
    fig, ax = plt.subplots()
    size = 100
    da = DrawingArea(size, size, clip=True)
    bg = mpatches.Rectangle((0, 0), size, size,
                            facecolor='#CCCCCC',
                            edgecolor='None',
                            linewidth=0)
    line = mlines.Line2D([-size*.5, size*1.5], [size/2, size/2],
                         color='black',
                         linewidth=10)
    anchored_box = AnchoredOffsetbox(
        loc='center',
        child=da,
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'EOF'\nimport matplotlib, inspect\nprint(matplotlib.__version__, matplotlib.__file__)\nimport matplotlib.offsetbox as o\nprint(inspect.getsource(o._get_aligned_offsets))\nprint(inspect.getsource(o.HPacker.get_extent_offsets))\nEOF"
}
```

**tool result**

```
3.7.0.dev822+g31b1ec1d58 /testbed/lib/matplotlib/__init__.py
def _get_aligned_offsets(hd_list, height, align="baseline"):
    """
    Align boxes each specified by their ``(height, descent)`` pair.

    For simplicity of the description, the terminology used here assumes a
    horizontal layout (i.e., vertical alignment), but the function works
    equally for a vertical layout.

    Parameters
    ----------
    hd_list
        List of (height, xdescent) of boxes to be aligned.
    height : float or None
        Intended total height. If None, the maximum of the heights in *hd_list*
        is used.
    align : {'baseline', 'left', 'top', 'right', 'bottom', 'center'}
        The alignment anchor of the boxes.

    Returns
    -------
    height
        The total height of the packing (if a value was originally passed in,
        it is returned without checking that it is actually large enough).
    descent
        The descent of the packing.
    offsets
        The bottom offsets of the boxes.
    """

    if height is None:
        height = max(h for h, d in hd_list)
    _api.check_in_list(
        ["baseline", "left", "top", "right", "bottom", "center"], align=align)

    if align == "baseline":
        height_descent = max(h - d for h, d in hd_list)
        descent = max(d for h, d in hd_list)
        height = height_descent + descent
        offsets = [0. for h, d in hd_list]
    elif align in ["left", "top"]:
        descent = 0.
        offsets = [d for h, d in hd_list]
    elif align in ["right", "bottom"]:
        descent = 0.
        offsets = [height - h + d for h, d in hd_list]
    elif align == "center":
        descent = 0.
        offsets = [(height - h) * .5 + d for h, d in hd_list]

    return height, descent, offsets

    def get_extent_offsets(self, renderer):
        # docstring inherited
        dpicor = renderer.points_to_pixels(1.)
        pad = self.pad * dpicor
        sep = self.sep * dpicor

        whd_list = [c.get_extent(renderer)
                    for c in self.get_visible_children()]

        if not whd_list:
            return 2 * pad, 2 * pad, pad, pad, []

        hd_list = [(h, yd) for w, h, xd, yd in whd_list]
        height, ydescent, yoffsets = _get_aligned_offsets(hd_list,
                                                          self.height,
                                                          self.align)

        pack_list = [w for w, h, xd, yd in whd_list]
        width, xoffsets_ = _get_packed_offsets(pack_list, self.width,
                                               sep, self.mode)

        xoffsets = xoffsets_ + [xd for w, h, xd, yd in whd_list]

        xdescent = whd_list[0][2]
        xoffsets = xoffsets - xdescent

        return (width + 2 * pad, height + 2 * pad,
                xdescent + pad, ydescent + pad,
                list(zip(xoffsets, yoffsets)))
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class AnchoredOffsetbox\" lib/matplotlib/offsetbox.py; sed -n '900,1080p' lib/matplotlib/offsetbox.py"
}
```

**tool result**

```
884:class AnchoredOffsetbox(OffsetBox):
             'right': 5,
             'center left': 6,
             'center right': 7,
             'lower center': 8,
             'upper center': 9,
             'center': 10,
             }

    @_api.make_keyword_only("3.6", name="pad")
    def __init__(self, loc,
                 pad=0.4, borderpad=0.5,
                 child=None, prop=None, frameon=True,
                 bbox_to_anchor=None,
                 bbox_transform=None,
                 **kwargs):
        """
        Parameters
        ----------
        loc : str
            The box location.  Valid locations are
            'upper left', 'upper center', 'upper right',
            'center left', 'center', 'center right',
            'lower left', 'lower center', 'lower right'.
            For backward compatibility, numeric values are accepted as well.
            See the parameter *loc* of `.Legend` for details.
        pad : float, default: 0.4
            Padding around the child as fraction of the fontsize.
        borderpad : float, default: 0.5
            Padding between the offsetbox frame and the *bbox_to_anchor*.
        child : `.OffsetBox`
            The box that will be anchored.
        prop : `.FontProperties`
            This is only used as a reference for paddings. If not given,
            :rc:`legend.fontsize` is used.
        frameon : bool
            Whether to draw a frame around the box.
        bbox_to_anchor : `.BboxBase`, 2-tuple, or 4-tuple of floats
            Box that is used to position the legend in conjunction with *loc*.
        bbox_transform : None or :class:`matplotlib.transforms.Transform`
            The transform for the bounding box (*bbox_to_anchor*).
        **kwargs
            All other parameters are passed on to `.OffsetBox`.

        Notes
        -----
        See `.Legend` for a detailed description of the anchoring mechanism.
        """
        super().__init__(**kwargs)

        self.set_bbox_to_anchor(bbox_to_anchor, bbox_transform)
        self.set_child(child)

        if isinstance(loc, str):
            loc = _api.check_getitem(self.codes, loc=loc)

        self.loc = loc
        self.borderpad = borderpad
        self.pad = pad

        if prop is None:
            self.prop = FontProperties(size=mpl.rcParams["legend.fontsize"])
        else:
            self.prop = FontProperties._from_any(prop)
            if isinstance(prop, dict) and "size" not in prop:
                self.prop.set_size(mpl.rcParams["legend.fontsize"])

        self.patch = FancyBboxPatch(
            xy=(0.0, 0.0), width=1., height=1.,
            facecolor='w', edgecolor='k',
            mutation_scale=self.prop.get_size_in_points(),
            snap=True,
            visible=frameon,
            boxstyle="square,pad=0",
        )

    def set_child(self, child):
        """Set the child to be anchored."""
        self._child = child
        if child is not None:
            child.axes = self.axes
        self.stale = True

    def get_child(self):
        """Return the child."""
        return self._child

    def get_children(self):
        """Return the list of children."""
        return [self._child]

    def get_extent(self, renderer):
        """
        Return the extent of the box as (width, height, x, y).

        This is the extent of the child plus the padding.
        """
        w, h, xd, yd = self.get_child().get_extent(renderer)
        fontsize = renderer.points_to_pixels(self.prop.get_size_in_points())
        pad = self.pad * fontsize

        return w + 2 * pad, h + 2 * pad, xd + pad, yd + pad

    def get_bbox_to_anchor(self):
        """Return the bbox that the box is anchored to."""
        if self._bbox_to_anchor is None:
            return self.axes.bbox
        else:
            transform = self._bbox_to_anchor_transform
            if transform is None:
                return self._bbox_to_anchor
            else:
                return TransformedBbox(self._bbox_to_anchor, transform)

    def set_bbox_to_anchor(self, bbox, transform=None):
        """
        Set the bbox that the box is anchored to.

        *bbox* can be a Bbox instance, a list of [left, bottom, width,
        height], or a list of [left, bottom] where the width and
        height will be assumed to be zero. The bbox will be
        transformed to display coordinate by the given transform.
        """
        if bbox is None or isinstance(bbox, BboxBase):
            self._bbox_to_anchor = bbox
        else:
            try:
                l = len(bbox)
            except TypeError as err:
                raise ValueError(f"Invalid bbox: {bbox}") from err

            if l == 2:
                bbox = [bbox[0], bbox[1], 0, 0]

            self._bbox_to_anchor = Bbox.from_bounds(*bbox)

        self._bbox_to_anchor_transform = transform
        self.stale = True

    def get_offset(self, width, height, xdescent, ydescent, renderer):
        # docstring inherited
        bbox = Bbox.from_bounds(0, 0, width, height)
        pad = (self.borderpad
               * renderer.points_to_pixels(self.prop.get_size_in_points()))
        bbox_to_anchor = self.get_bbox_to_anchor()
        x0, y0 = _get_anchored_bbox(self.loc, bbox, bbox_to_anchor, pad)
        return x0 + xdescent, y0 + ydescent

    def update_frame(self, bbox, fontsize=None):
        self.patch.set_bounds(bbox.bounds)
        if fontsize:
            self.patch.set_mutation_scale(fontsize)

    def draw(self, renderer):
        # docstring inherited
        if not self.get_visible():
            return

        # update the location and size of the legend
        bbox = self.get_window_extent(renderer)
        fontsize = renderer.points_to_pixels(self.prop.get_size_in_points())
        self.update_frame(bbox, fontsize)
        self.patch.draw(renderer)

        width, height, xdescent, ydescent = self.get_extent(renderer)

        px, py = self.get_offset(width, height, xdescent, ydescent, renderer)

        self.get_child().set_offset((px, py))
        self.get_child().draw(renderer)
        self.stale = False


def _get_anchored_bbox(loc, bbox, parentbbox, borderpad):
    """
    Return the (x, y) position of the *bbox* anchored at the *parentbbox* with
    the *loc* code with the *borderpad*.
    """
    # This is only called internally and *loc* should already have been
    # validated.  If 0 (None), we just let ``bbox.anchored`` raise.
    c = [None, "NE", "NW", "SW", "SE", "E", "W", "E", "S", "N", "C"][loc]
    container = parentbbox.padded(-borderpad)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/offsetbox.py\n@@\n-    elif align in [\"left\", \"top\"]:\n+    elif align in [\"left\", \"bottom\"]:\n         descent = 0.\n         offsets = [d for h, d in hd_list]\n-    elif align in [\"right\", \"bottom\"]:\n+    elif align in [\"right\", \"top\"]:\n         descent = 0.\n         offsets = [height - h + d for h, d in hd_list]\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/offsetbox.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/offsetbox.py now (1607 lines), around the change:
166:        descent = max(d for h, d in hd_list)
167:        height = height_descent + descent
168:        offsets = [0. for h, d in hd_list]
169:    elif align in ["left", "bottom"]:
170:        descent = 0.
171:        offsets = [d for h, d in hd_list]
172:    elif align in ["right", "top"]:
173:        descent = 0.
174:        offsets = [height - h + d for h, d in hd_list]
175:    elif align == "center":
```

**assistant → tool `bash`**

```json
{
  "command": "python /tmp/repro.py && python - <<'EOF'\nimport matplotlib\nmatplotlib.use('Agg')\nimport matplotlib.pyplot as plt\nfrom matplotlib.offsetbox import DrawingArea, HPacker\nfrom matplotlib.patches import Rectangle\n\nfor align in [\"top\",\"bottom\",\"center\",\"baseline\"]:\n    da1 = DrawingArea(10, 20); da1.add_artist(Rectangle((0,0),10,20))\n    da2 = DrawingArea(10, 30); da2.add_artist(Rectangle((0,0),10,30))\n    pack = HPacker(children=[da1,da2], pad=10, sep=10, align=align)\n    fig, ax = plt.subplots()\n    ax.add_artist(pack)\n    fig.canvas.draw()\n    r = fig.canvas.get_renderer()\n    print(align, [c.get_window_extent(r).bounds for c in pack.get_visible_children()])\nEOF"
}
```

**tool result**

```
top [(0.0, 13.888888888888886, 13.88888888888889, 27.77777777777778), (27.77777777777778, 0.0, 13.888888888888893, 41.666666666666664)]
bottom [(0.0, 0.0, 13.88888888888889, 27.77777777777778), (27.77777777777778, 0.0, 13.888888888888893, 41.666666666666664)]
center [(0.0, 6.944444444444443, 13.88888888888889, 27.77777777777778), (27.77777777777778, 0.0, 13.888888888888893, 41.666666666666664)]
baseline [(0.0, 0.0, 13.88888888888889, 27.77777777777778), (27.77777777777778, 0.0, 13.888888888888893, 41.666666666666664)]
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '120,200p' lib/matplotlib/tests/test_offsetbox.py"
}
```

**tool result**

```
    ax.legend(ncols=2, mode='expand')

    fig.tight_layout()  # where the crash used to happen


@pytest.mark.parametrize('widths',
                         ([150], [150, 150, 150], [0.1], [0.1, 0.1]))
@pytest.mark.parametrize('total', (250, 100, 0, -1, None))
@pytest.mark.parametrize('sep', (250, 1, 0, -1))
@pytest.mark.parametrize('mode', ("expand", "fixed", "equal"))
def test_get_packed_offsets(widths, total, sep, mode):
    # Check a (rather arbitrary) set of parameters due to successive similar
    # issue tickets (at least #10476 and #10784) related to corner cases
    # triggered inside this function when calling higher-level functions
    # (e.g. `Axes.legend`).
    # These are just some additional smoke tests. The output is untested.
    _get_packed_offsets(widths, total, sep, mode=mode)


_Params = namedtuple('_params', 'wd_list, total, sep, expected')


@pytest.mark.parametrize('widths, total, sep, expected', [
    _Params(  # total=None
        [3, 1, 2], total=None, sep=1, expected=(8, [0, 4, 6])),
    _Params(  # total larger than required
        [3, 1, 2], total=10, sep=1, expected=(10, [0, 4, 6])),
    _Params(  # total smaller than required
        [3, 1, 2], total=5, sep=1, expected=(5, [0, 4, 6])),
])
def test_get_packed_offsets_fixed(widths, total, sep, expected):
    result = _get_packed_offsets(widths, total, sep, mode='fixed')
    assert result[0] == expected[0]
    assert_allclose(result[1], expected[1])


@pytest.mark.parametrize('widths, total, sep, expected', [
    _Params(  # total=None (implicit 1)
        [.1, .1, .1], total=None, sep=None, expected=(1, [0, .45, .9])),
    _Params(  # total larger than sum of widths
        [3, 1, 2], total=10, sep=1, expected=(10, [0, 5, 8])),
    _Params(  # total smaller sum of widths: overlapping boxes
        [3, 1, 2], total=5, sep=1, expected=(5, [0, 2.5, 3])),
])
def test_get_packed_offsets_expand(widths, total, sep, expected):
    result = _get_packed_offsets(widths, total, sep, mode='expand')
    assert result[0] == expected[0]
    assert_allclose(result[1], expected[1])


@pytest.mark.parametrize('widths, total, sep, expected', [
    _Params(  # total larger than required
        [3, 2, 1], total=6, sep=None, expected=(6, [0, 2, 4])),
    _Params(  # total smaller sum of widths: overlapping boxes
        [3, 2, 1, .5], total=2, sep=None, expected=(2, [0, 0.5, 1, 1.5])),
    _Params(  # total larger than required
        [.5, 1, .2], total=None, sep=1, expected=(6, [0, 2, 4])),
    # the case total=None, sep=None is tested separately below
])
def test_get_packed_offsets_equal(widths, total, sep, expected):
    result = _get_packed_offsets(widths, total, sep, mode='equal')
    assert result[0] == expected[0]
    assert_allclose(result[1], expected[1])


def test_get_packed_offsets_equal_total_none_sep_none():
    with pytest.raises(ValueError):
        _get_packed_offsets([1, 1, 1], total=None, sep=None, mode='equal')


@pytest.mark.parametrize('child_type', ['draw', 'image', 'text'])
@pytest.mark.parametrize('boxcoords',
                         ['axes fraction', 'axes pixels', 'axes points',
                          'data'])
def test_picking(child_type, boxcoords):
    # These all take up approximately the same area.
    if child_type == 'draw':
        picking_child = DrawingArea(5, 5)
        picking_child.add_artist(mpatches.Rectangle((0, 0), 5, 5, linewidth=0))
    elif child_type == 'image':
        im = np.ones((5, 5))
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/tests/test_offsetbox.py\n@@\n from matplotlib.offsetbox import (\n     AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, OffsetBox,\n-    OffsetImage, TextArea, _get_packed_offsets)\n+    OffsetImage, TextArea, _get_aligned_offsets, _get_packed_offsets)\n@@\n def test_get_packed_offsets_equal_total_none_sep_none():\n     with pytest.raises(ValueError):\n         _get_packed_offsets([1, 1, 1], total=None, sep=None, mode='equal')\n \n \n+@pytest.mark.parametrize('align, expected_offsets', [\n+    ('baseline', [0, 0]),\n+    ('bottom', [2, 1]),\n+    ('left', [2, 1]),\n+    ('top', [2, 6]),\n+    ('right', [2, 6]),\n+    ('center', [2, 3.5]),\n+])\n+def test_get_aligned_offsets(align, expected_offsets):\n+    # The boxes have heights 10 and 5, and descents 2 and 1.\n+    height, descent, offsets = _get_aligned_offsets(\n+        [(10, 2), (5, 1)], None, align)\n+    assert height == 10\n+    assert descent == (2 if align == \"baseline\" else 0)\n+    assert_allclose(offsets, expected_offsets)\n+\n+\n+@pytest.mark.parametrize('align, anchored', [\n+    ('top', 'top'),\n+    ('bottom', 'bottom'),\n+])\n+def test_hpacker_align(align, anchored):\n+    fig, ax = plt.subplots()\n+    child1 = DrawingArea(10, 20)\n+    child2 = DrawingArea(10, 30)\n+    packer = HPacker(children=[child1, child2], pad=0, sep=0, align=align)\n+    ax.add_artist(packer)\n+    fig.canvas.draw()\n+    renderer = fig.canvas.get_renderer()\n+    bbox1 = child1.get_window_extent(renderer)\n+    bbox2 = child2.get_window_extent(renderer)\n+    assert getattr(bbox1, anchored) == pytest.approx(\n+        getattr(bbox2, anchored))\n+\n+\n @pytest.mark.parametrize('child_type', ['draw', 'image', 'text'])\n @pytest.mark.parametrize('boxcoords',\n                          ['axes fraction', 'axes pixels', 'axes points',\n                           'data'])\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/tests/test_offsetbox.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/tests/test_offsetbox.py now (372 lines), around the change:
13:
14:from matplotlib.offsetbox import (
15:    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, OffsetBox,
16:    OffsetImage, TextArea, _get_aligned_offsets, _get_packed_offsets)
17:
18:
19:@image_comparison(['offsetbox_clipping'], remove_text=True)
…
187:        _get_packed_offsets([1, 1, 1], total=None, sep=None, mode='equal')
188:
189:
190:@pytest.mark.parametrize('align, expected_offsets', [
191:    ('baseline', [0, 0]),
192:    ('bottom', [2, 1]),
193:    ('left', [2, 1]),
194:    ('top', [2, 6]),
195:    ('right', [2, 6]),
196:    ('center', [2, 3.5]),
197:])
198:def test_get_aligned_offsets(align, expected_offsets):
199:    # The boxes have heights 10 and 5, and descents 2 and 1.
200:    height, descent, offsets = _get_aligned_offsets(
201:        [(10, 2), (5, 1)], None, align)
202:    assert height == 10
203:    assert descent == (2 if align == "baseline" else 0)
204:    assert_allclose(offsets, expected_offsets)
205:
206:
207:@pytest.mark.parametrize('align, anchored', [
208:    ('top', 'top'),
209:    ('bottom', 'bottom'),
210:])
211:def test_hpacker_align(align, anchored):
212:    fig, ax = plt.subplots()
213:    child1 = DrawingArea(10, 20)
214:    child2 = DrawingArea(10, 30)
215:    packer = HPacker(children=[child1, child2], pad=0, sep=0, align=align)
216:    ax.add_artist(packer)
217:    fig.canvas.draw()
218:    renderer = fig.canvas.get_renderer()
219:    bbox1 = child1.get_window_extent(renderer)
220:    bbox2 = child2.get_window_extent(renderer)
221:    assert getattr(bbox1, anchored) == pytest.approx(
222:        getattr(bbox2, anchored))
223:
224:
225:@pytest.mark.parametrize('child_type', ['draw', 'image', 'text'])
226:@pytest.mark.parametrize('boxcoords',
227:                         ['axes fraction', 'axes pixels', 'axes points',
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest lib/matplotlib/tests/test_offsetbox.py -q 2>&1 | tail -30"
}
```

**tool result**

```
        ('bottom', 'bottom'),
    ])
    def test_hpacker_align(align, anchored):
        fig, ax = plt.subplots()
        child1 = DrawingArea(10, 20)
        child2 = DrawingArea(10, 30)
>       packer = HPacker(children=[child1, child2], pad=0, sep=0, align=align)
E       NameError: name 'HPacker' is not defined

lib/matplotlib/tests/test_offsetbox.py:215: NameError
______________________ test_hpacker_align[bottom-bottom] _______________________

align = 'bottom', anchored = 'bottom'

    @pytest.mark.parametrize('align, anchored', [
        ('top', 'top'),
        ('bottom', 'bottom'),
    ])
    def test_hpacker_align(align, anchored):
        fig, ax = plt.subplots()
        child1 = DrawingArea(10, 20)
        child2 = DrawingArea(10, 30)
>       packer = HPacker(children=[child1, child2], pad=0, sep=0, align=align)
E       NameError: name 'HPacker' is not defined

lib/matplotlib/tests/test_offsetbox.py:215: NameError
=========================== short test summary info ============================
FAILED lib/matplotlib/tests/test_offsetbox.py::test_hpacker_align[top-top] - ...
FAILED lib/matplotlib/tests/test_offsetbox.py::test_hpacker_align[bottom-bottom]
2 failed, 277 passed, 1 skipped in 46.00s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/tests/test_offsetbox.py\n@@\n from matplotlib.offsetbox import (\n-    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, OffsetBox,\n-    OffsetImage, TextArea, _get_aligned_offsets, _get_packed_offsets)\n+    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, HPacker,\n+    OffsetBox, OffsetImage, TextArea, _get_aligned_offsets,\n+    _get_packed_offsets)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/tests/test_offsetbox.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/tests/test_offsetbox.py now (373 lines), around the change:
12:from matplotlib.backend_bases import MouseButton, MouseEvent
13:
14:from matplotlib.offsetbox import (
15:    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, HPacker,
16:    OffsetBox, OffsetImage, TextArea, _get_aligned_offsets,
17:    _get_packed_offsets)
18:
19:
20:@image_comparison(['offsetbox_clipping'], remove_text=True)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest lib/matplotlib/tests/test_offsetbox.py -q 2>&1 | tail -8"
}
```

**tool result**

```
            getattr(bbox2, anchored))
E       AttributeError: 'Bbox' object has no attribute 'bottom'

lib/matplotlib/tests/test_offsetbox.py:222: AttributeError
=========================== short test summary info ============================
FAILED lib/matplotlib/tests/test_offsetbox.py::test_hpacker_align[top-top] - ...
FAILED lib/matplotlib/tests/test_offsetbox.py::test_hpacker_align[bottom-bottom]
2 failed, 277 passed, 1 skipped in 6.03s
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: lib/matplotlib/tests/test_offsetbox.py\n@@\n-@pytest.mark.parametrize('align, anchored', [\n-    ('top', 'top'),\n-    ('bottom', 'bottom'),\n+@pytest.mark.parametrize('align, anchored', [\n+    ('top', 'y1'),\n+    ('bottom', 'y0'),\n ])\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[lib/matplotlib/tests/test_offsetbox.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

lib/matplotlib/tests/test_offsetbox.py now (373 lines), around the change:
206:
207:
208:@pytest.mark.parametrize('align, anchored', [
209:    ('top', 'y1'),
210:    ('bottom', 'y0'),
211:])
212:def test_hpacker_align(align, anchored):
213:    fig, ax = plt.subplots()
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest lib/matplotlib/tests/test_offsetbox.py -q 2>&1 | tail -8"
}
```

**tool result**

```
..s..................................................................... [ 25%]
........................................................................ [ 51%]
........................................................................ [ 77%]
................................................................         [100%]
279 passed, 1 skipped in 15.42s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest lib/matplotlib/tests/test_legend.py -q 2>&1 | tail -8; git diff --stat"
}
```

**tool result**

```
...s..s..s..s.......s..s..s..s..s....................................... [ 58%]
..................................................s                      [100%]
113 passed, 10 skipped in 105.89s (0:01:45)
 lib/matplotlib/offsetbox.py            |  4 ++--
 lib/matplotlib/tests/test_offsetbox.py | 40 ++++++++++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 4 deletions(-)
```

**assistant**

````
Fixed the reversed `align` semantics in `HPacker`.

## Root cause

`_get_aligned_offsets` in `lib/matplotlib/offsetbox.py` grouped the alignment anchors incorrectly:

```python
elif align in ["left", "top"]:      # top was treated like bottom
    offsets = [d for h, d in hd_list]
elif align in ["right", "bottom"]:  # bottom was treated like top
    offsets = [height - h + d for h, d in hd_list]
```

For a horizontal packer, `top` should push each child up so its top edge aligns (`height - h + d`), while `bottom` should keep its bottom edge aligned (`d`). The two branches were swapped.

## Change

- Swapped the groups to `["left", "bottom"]` and `["right", "top"]`, preserving the vertical-layout meanings (`left`/`right` are unchanged).
- Added regression tests in `lib/matplotlib/tests/test_offsetbox.py`:
  - `test_get_aligned_offsets` checks the computed offsets/descent for every anchor.
  - `test_hpacker_align` verifies that `HPacker` children share the same top edge for `align="top"` and the same bottom edge for `align="bottom"`.

## Verification

- `test_offsetbox.py`: 279 passed, 1 skipped
- `test_legend.py`: 113 passed, 10 skipped (legend uses `HPacker`/`VPacker` extensively, so this guards against regressions)
````

## Run folder `team-solve-2026-11-06T120155`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
31b1ec1d5811aae91b9b783c97ff01a56e7c2694
```

### `baseline-check.log`

```
check: python -m pytest lib/matplotlib/tests/test_offsetbox.py -q
ImportError while loading conftest '/testbed/.memdoor/runs/team-solve-2026-11-06T120155/baseline-tree/lib/matplotlib/tests/conftest.py'.
lib/matplotlib/__init__.py:131: in <module>
    from . import _api, _version, cbook, _docstring, rcsetup
lib/matplotlib/cbook/__init__.py:30: in <module>
    from matplotlib import _api, _c_internal_utils
E   ImportError: cannot import name '_c_internal_utils' from partially initialized module 'matplotlib' (most likely due to a circular import) (/testbed/.memdoor/runs/team-solve-2026-11-06T120155/baseline-tree/lib/matplotlib/__init__.py)
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/lib/matplotlib/offsetbox.py b/lib/matplotlib/offsetbox.py
index 3a506543ac..059a6c8ae3 100644
--- a/lib/matplotlib/offsetbox.py
+++ b/lib/matplotlib/offsetbox.py
@@ -166,10 +166,10 @@ def _get_aligned_offsets(hd_list, height, align="baseline"):
         descent = max(d for h, d in hd_list)
         height = height_descent + descent
         offsets = [0. for h, d in hd_list]
-    elif align in ["left", "top"]:
+    elif align in ["left", "bottom"]:
         descent = 0.
         offsets = [d for h, d in hd_list]
-    elif align in ["right", "bottom"]:
+    elif align in ["right", "top"]:
         descent = 0.
         offsets = [height - h + d for h, d in hd_list]
     elif align == "center":
diff --git a/lib/matplotlib/tests/test_offsetbox.py b/lib/matplotlib/tests/test_offsetbox.py
index 02756ff559..a445c653dd 100644
--- a/lib/matplotlib/tests/test_offsetbox.py
+++ b/lib/matplotlib/tests/test_offsetbox.py
@@ -12,8 +12,9 @@ import matplotlib.lines as mlines
 from matplotlib.backend_bases import MouseButton, MouseEvent
 
 from matplotlib.offsetbox import (
-    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, OffsetBox,
-    OffsetImage, TextArea, _get_packed_offsets)
+    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, HPacker,
+    OffsetBox, OffsetImage, TextArea, _get_aligned_offsets,
+    _get_packed_offsets)
 
 
 @image_comparison(['offsetbox_clipping'], remove_text=True)
@@ -187,6 +188,41 @@ def test_get_packed_offsets_equal_total_none_sep_none():
         _get_packed_offsets([1, 1, 1], total=None, sep=None, mode='equal')
 
 
+@pytest.mark.parametrize('align, expected_offsets', [
+    ('baseline', [0, 0]),
+    ('bottom', [2, 1]),
+    ('left', [2, 1]),
+    ('top', [2, 6]),
+    ('right', [2, 6]),
+    ('center', [2, 3.5]),
+])
+def test_get_aligned_offsets(align, expected_offsets):
+    # The boxes have heights 10 and 5, and descents 2 and 1.
+    height, descent, offsets = _get_aligned_offsets(
+        [(10, 2), (5, 1)], None, align)
+    assert height == 10
+    assert descent == (2 if align == "baseline" else 0)
+    assert_allclose(offsets, expected_offsets)
+
+
+@pytest.mark.parametrize('align, anchored', [
+    ('top', 'y1'),
+    ('bottom', 'y0'),
+])
+def test_hpacker_align(align, anchored):
+    fig, ax = plt.subplots()
+    child1 = DrawingArea(10, 20)
+    child2 = DrawingArea(10, 30)
+    packer = HPacker(children=[child1, child2], pad=0, sep=0, align=align)
+    ax.add_artist(packer)
+    fig.canvas.draw()
+    renderer = fig.canvas.get_renderer()
+    bbox1 = child1.get_window_extent(renderer)
+    bbox2 = child2.get_window_extent(renderer)
+    assert getattr(bbox1, anchored) == pytest.approx(
+        getattr(bbox2, anchored))
+
+
 @pytest.mark.parametrize('child_type', ['draw', 'image', 'text'])
 @pytest.mark.parametrize('boxcoords',
                          ['axes fraction', 'axes pixels', 'axes points',
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

[Bug]: `align` in `HPacker` is reversed
### Bug summary

For the `align` parameter in `HPacker`, the options `top` and `bottom` seems reversed

### Code for reproduction

```python
import matplotlib.pyplot as plt
from matplotlib.offsetbox import DrawingArea, HPacker, VPacker, AnchoredOffsetbox, TextArea
from matplotlib.patches import Rectangle

da1 = DrawingArea(10, 20)
rect1 = Rectangle((0, 0), 10, 20)
da1.add_artist(rect1)

da2 = DrawingArea(10, 30)
rect2 = Rectangle((0, 0), 10, 30)
da2.add_artist(rect2)

align = "bottom"

pack = HPacker(children=[da1, da2], pad=10, sep=10, align=align)
title = TextArea(f"align='{align}'")
pack = VPacker(children=[title, pack], sep=10, pad=10, align="center")

box = AnchoredOffsetbox(child=pack, loc="center")

_, ax = plt.subplots()
ax.add_artist(box)
```


### Actual outcome

![download](https://user-images.githubusercontent.com/23433306/200162888-702626bf-ad47-40e2-8751-7dffe91df85c.png)


### Expected outcome

![download](https://user-images.githubusercontent.com/23433306/200162908-e0e9dfd5-6f8b-4aac-975e-bb363d809c41.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.6.2

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

`python -m pytest lib/matplotlib/tests/test_offsetbox.py -q`

## Scope

`lib/matplotlib/offsetbox.py`
`lib/matplotlib/tests/`

## Done when

`HPacker` with `align="bottom"` aligns child boxes by their bottom edges against the tallest child.
`HPacker` with `align="top"` aligns child boxes by their top edges against the tallest child.
(inferred) `HPacker` `center`/`baseline` behavior and `VPacker` alignment are unchanged.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest lib/matplotlib/tests/test_offsetbox.py -q`

## Scope
`lib/matplotlib/offsetbox.py`
`lib/matplotlib/tests/`

## Done when
`HPacker` with `align="bottom"` aligns child boxes by their bottom edges against the tallest child.
`HPacker` with `align="top"` aligns child boxes by their top edges against the tallest child.
(inferred) `HPacker` `center`/`baseline` behavior and `VPacker` alignment are unchanged.

## Approach
Fix the vertical offset mapping in `HPacker` inside `lib/matplotlib/offsetbox.py`: inspect `HPacker.get_extent_offsets` and the helper that converts `align` into child y-offsets, then make `top` and `bottom` map to the correct bottom-origin offsets. Candidate A: swap the `top`/`bottom` branches in the alignment helper, which is the smallest change but must be checked for shared use. Candidate B: invert only at the `HPacker` call site so other packers are unaffected, at the cost of a misleading shared helper. Candidate C: add a dedicated `HPacker` vertical-alignment helper if shared logic makes the fix too broad. Verify with a minimal `DrawingArea` reproduction and the offsetbox tests.


# lib/matplotlib/offsetbox.py

```
r"""
Container classes for `.Artist`\s.

`OffsetBox`
    The base of all container artists defined in this module.

`AnchoredOffsetbox`, `AnchoredText`
    Anchor and align an arbitrary `.Artist` or a text relative to the parent
    axes or a specific anchor point.

`DrawingArea`
    A container with fixed width and height. Children have a fixed position
    inside the container and may be clipped.

`HPacker`, `VPacker`
    Containers for layouting their children vertically or horizontally.

`PaddedBox`
    A container to add a padding around an `.Artist`.

`TextArea`
    Contains a single `.Text` instance.
"""

import numpy as np

import matplotlib as mpl
from matplotlib import _api, _docstring
import matplotlib.artist as martist
import matplotlib.path as mpath
import matplotlib.text as mtext
import matplotlib.transforms as mtransforms
from matplotlib.font_manager import FontProperties
from matplotlib.image import BboxImage
from matplotlib.patches import (
    FancyBboxPatch, FancyArrowPatch, bbox_artist as mbbox_artist)
from matplotlib.transforms import Bbox, BboxBase, TransformedBbox


DEBUG = False


# for debugging use
def bbox_artist(*args, **kwargs):
    if DEBUG:
        mbbox_artist(*args, **kwargs)


def _get_packed_offsets(widths, total, sep, mode="fixed"):
    r"""
    Pack boxes specified by their *widths*.

    For simplicity of the description, the terminology used here assumes a
    horizontal layout, but the function works equally for a vertical layout.

    There are three packing *mode*\s:

    - 'fixed': The elements are packed tight to the left with a spacing of
      *sep* in between. If *total* is *None* the returned total will be the
      right edge of the last box. A non-*None* total will be passed unchecked
      to the output. In particular this means that right edge of the last
      box may be further to the right than the returned total.

    - 'expand': Distribute the boxes with equal spacing so that the left edge
      of the first box is at 0, and the right edge of the last box is at
      *total*. The parameter *sep* is ignored in this mode. A total of *None*
      is accepted and considered equal to 1. The total is returned unchanged
      (except for the conversion *None* to 1). If the total is smaller than
      the sum of the widths, the laid out boxes will overlap.

    - 'equal': If *total* is given, the total space is divided in N equal
      ranges and each box is left-aligned within its subspace.
      Otherwise (*total* is *None*), *sep* must be provided and each box is
      left-aligned in its subspace of width ``(max(widths) + sep)``. The
      total width is then calculated to be ``N * (max(widths) + sep)``.

    Parameters
    ----------
    widths : list of float
        Widths of boxes to be packed.
    total : float or None
        Intended total length. *None* if not used.
    sep : float
        Spacing between boxes.
    mode : {'fixed', 'expand', 'equal'}
        The packing mode.

    Returns
    -------
    total : float
        The total width needed to accommodate the laid out boxes.
    offsets : array of float
        The left offsets of the boxes.
    """
    _api.check_in_list(["fixed", "expand", "equal"], mode=mode)

    if mode == "fixed":
        offsets_ = np.cumsum([0] + [w + sep for w in widths])
        offsets = offsets_[:-1]
        if total is None:
            total = offsets_[-1] - sep
        return total, offsets

    elif mode == "expand":
        # This is a bit of a hack to avoid a TypeError when *total*
        # is None and used in conjugation with tight layout.
        if total is None:
            total = 1
        if len(widths) > 1:
            sep = (total - sum(widths)) / (len(widths) - 1)
        else:
            sep = 0
        offsets_ = np.cumsum([0] + [w + sep for w in widths])
        offsets = offsets_[:-1]
        return total, offsets

    elif mode == "equal":
        maxh = max(widths)
        if total is None:
            if sep is None:
                raise ValueError("total and sep cannot both be None when "
                                 "using layout mode 'equal'")
            total = (maxh + sep) * len(widths)
        else:
            sep = total / len(widths) - maxh
        offsets = (maxh + sep) * np.arange(len(widths))
        return total, offsets


def _get_aligned_offsets(hd_list, height, align="baseline"):
    """
    Align boxes each specified by their ``(height, descent)`` pair.

    For simplicity of the description, the terminology used here assumes a
    horizontal layout (i.e., vertical alignment), but the function works
    equally for a vertical layout.

    Parameters
    ----------
    hd_list
        List of (height, xdescent) of boxes to be aligned.
    height : float or None
        Intended total height. If None, the maximum of the heights in *hd_list*
        is used.
    align : {'baseline', 'left', 'top', 'right', 'bottom', 'center'}
        The alignment anchor of the boxes.

    Returns
    -------
    height
        The total height of the packing (if a value was originally passed in,
        it is returned without checking that it is actually large enough).
    descent
        The descent of the packing.
    offsets
        The bottom offsets of the boxes.
    """

    if height is None:
        height = max(h for h, d in hd_list)
    _api.check_in_list(
        ["baseline", "left", "top", "right", "bottom", "center"], align=align)

    if align == "baseline":
        height_descent = max(h - d for h, d in hd_list)
        descent = max(d for h, d in hd_list)
        height = height_descent + descent
        offsets = [0. for h, d in hd_list]
    elif align in ["left", "top"]:
        descent = 0.
        offsets = [d for h, d in hd_list]
    elif align in ["right", "bottom"]:
        descent = 0.
        offsets = [height - h + d for h, d in hd_list]
    elif align == "center":
        descent = 0.
        offsets = [(height - h) * .5 + d for h, d in hd_list]

    return height, descent, offsets


class OffsetBox(martist.Artist):
    """
    The OffsetBox is a simple container artist.

    The child artists are meant to be drawn at a relative position to its
    parent.

    Being an artist itself, all parameters are passed on to `.Artist`.
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args)
        self._internal_update(kwargs)
        # Clipping has not been implemented in the OffsetBox family, so
        # disable the clip flag for consistency. It can always be turned back
        # on to zero effect.
        self.set_clip_on(False)
        self._children = []
        self._offset = (0, 0)

    def set_figure(self, fig):
        """
        Set the `.Figure` for the `.OffsetBox` and all its children.

        Parameters
        ----------
        fig : `~matplotlib.figure.Figure`
        """
        super().set_figure(fig)
        for c in self.get_children():
            c.set_figure(fig)

    @martist.Artist.axes.setter
    def axes(self, ax):
        # TODO deal with this better
        martist.Artist.axes.fset(self, ax)
        for c in self.get_children():
            if c is not None:
                c.axes = ax

    def contains(self, mouseevent):
        """
        Delegate the mouse event contains-check to the children.

        As a container, the `.OffsetBox` does not respond itself to
        mouseevents.

        Parameters
        ----------
        mouseevent : `matplotlib.backend_bases.MouseEvent`

        Returns
        -------
        contains : bool
            Whether any values are within the radius.
        details : dict
            An artist-specific dictionary of details of the event context,
            such as which points are contained in the pick radius. See the
            individual Artist subclasses for details.

        See Also
        --------
        .Artist.contains
        """
        inside, info = self._default_contains(mouseevent)
        if inside is not None:
            return inside, info
        for c in self.get_children():
            a, b = c.contains(mouseevent)
            if a:
                return a, b
        return False, {}

    def set_offset(self, xy):
        """
        Set the offset.

        Parameters
        ----------
        xy : (float, float) or callable
            The (x, y) coordinates of the offset in display units. These can
            either be given explicitly as a tuple (x, y), or by providing a
            function that converts the extent into the offset. This function
            must have the signature::

                def offset(width, height, xdescent, ydescent, renderer) \
-> (float, float)
        """
        self._offset = xy
        self.stale = True

    def get_offset(self, width, height, xdescent, ydescent, renderer):
        """
        Return the offset as a tuple (x, y).

        The extent parameters have to be provided to handle the case where the
        offset is dynamically determined by a callable (see
        `~.OffsetBox.set_offset`).

        Parameters
        ----------
        width, height, xdescent, ydescent
            Extent parameters.
        renderer : `.RendererBase` subclass

        """
        return (self._offset(width, height, xdescent, ydescent, renderer)
                if callable(self._offset)
                else self._offset)

    def set_width(self, width):
        """
        Set the width of the box.

        Parameters
        ----------
        width : float
        """
        self.width = width
        self.stale = True

    def set_height(self, height):
        """
        Set the height of the box.

        Parameters
        ----------
        height : float
        """
        self.height = height
        self.stale = True

    def get_visible_children(self):
        r"""Return a list of the visible child `.Artist`\s."""
        return [c for c in self._children if c.get_visible()]

    def get_children(self):
        r"""Return a list of the child `.Artist`\s."""
        return self._children

    def get_extent_offsets(self, renderer):
        """
        Update offset of the children and return the extent of the box.

        Parameters
        ----------
        renderer : `.RendererBase` subclass

        Returns
        -------
        width
        height
        xdescent
        ydescent
        list of (xoffset, yoffset) pairs
        """
        raise NotImplementedError(
            "get_extent_offsets must be overridden in derived classes.")

    def get_extent(self, renderer):
        """Return a tuple ``width, height, xdescent, ydescent`` of the box."""
        w, h, xd, yd, offsets = self.get_extent_offsets(renderer)
        return w, h, xd, yd

    def get_window_extent(self, renderer=None):
        # docstring inherited
        if renderer is None:
            renderer = self.figure._get_renderer()
        w, h, xd, yd = self.get_extent(renderer)
        # Some subclasses redefine get_offset to take no args.
        try:
            px, py = self.get_offset(w, h, xd, yd, renderer)
        except TypeError:
            px, py = self.get_offset()
        return mtransforms.Bbox.from_bounds(px - xd, py - yd, w, h)

    def draw(self, renderer):
        """
        Update the location of children if necessary and draw them
        to the given *renderer*.
        """
        w, h, xdescent, ydescent, offsets = self.get_extent_offsets(renderer)
        px, py = self.get_offset(w, h, xdescent, ydescent, renderer)
        for c, (ox, oy) in zip(self.get_visible_children(), offsets):
            c.set_offset((px + ox, py + oy))
            c.draw(renderer)
        bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class PackerBase(OffsetBox):
    def __init__(self, pad=None, sep=None, width=None, height=None,
                 align="baseline", mode="fixed", children=None):
        """
        Parameters
        ----------
        pad : float, optional
            The boundary padding in points.

        sep : float, optional
            The spacing between items in points.

        width, height : float, optional
            Width and height of the container box in pixels, calculated if
            *None*.

        align : {'top', 'bottom', 'left', 'right', 'center', 'baseline'}, \
default: 'baseline'
            Alignment of boxes.

        mode : {'fixed', 'expand', 'equal'}, default: 'fixed'
            The packing mode.

            - 'fixed' packs the given `.Artist`\\s tight with *sep* spacing.
            - 'expand' uses the maximal available space to distribute the
              artists with equal spacing in between.
            - 'equal': Each artist an equal fraction of the available space
              and is left-aligned (or top-aligned) therein.

        children : list of `.Artist`
            The artists to pack.

        Notes
        -----
        *pad* and *sep* are in points and will be scaled with the renderer
        dpi, while *width* and *height* are in pixels.
        """
        super().__init__()
        self.height = height
        self.width = width
        self.sep = sep
        self.pad = pad
        self.mode = mode
        self.align = align
        self._children = children


class VPacker(PackerBase):
    """
    VPacker packs its children vertically, automatically adjusting their
    relative positions at draw time.
    """

    def get_extent_offsets(self, renderer):
        # docstring inherited
        dpicor = renderer.points_to_pixels(1.)
        pad = self.pad * dpicor
        sep = self.sep * dpicor

        if self.width is not None:
            for c in self.get_visible_children():
                if isinstance(c, PackerBase) and c.mode == "expand":
                    c.set_width(self.width)

        whd_list = [c.get_extent(renderer)
                    for c in self.get_visible_children()]
        whd_list = [(w, h, xd, (h - yd)) for w, h, xd, yd in whd_list]

        wd_list = [(w, xd) for w, h, xd, yd in whd_list]
        width, xdescent, xoffsets = _get_aligned_offsets(wd_list,
                                                         self.width,
                                                         self.align)

        pack_list = [h for w, h, xd, yd in whd_list]
        height, yoffsets_ = _get_packed_offsets(pack_list, self.height,
                                                sep, self.mode)

        yoffsets = yoffsets_ + [yd for w, h, xd, yd in whd_list]
        ydescent = height - yoffsets[0]
        yoffsets = height - yoffsets

        yoffsets = yoffsets - ydescent

        return (width + 2 * pad, height + 2 * pad,
                xdescent + pad, ydescent + pad,
                list(zip(xoffsets, yoffsets)))


class HPacker(PackerBase):
    """
    HPacker packs its children horizontally, automatically adjusting their
    relative positions at draw time.
    """

    def get_extent_offsets(self, renderer):
        # docstring inherited
        dpicor = renderer.points_to_pixels(1.)
        pad = self.pad * dpicor
        sep = self.sep * dpicor

        whd_list = [c.get_extent(renderer)
                    for c in self.get_visible_children()]

        if not whd_list:
            return 2 * pad, 2 * pad, pad, pad, []

        hd_list = [(h, yd) for w, h, xd, yd in whd_list]
        height, ydescent, yoffsets = _get_aligned_offsets(hd_list,
                                                          self.height,
                                                          self.align)

        pack_list = [w for w, h, xd, yd in whd_list]
        width, xoffsets_ = _get_packed_offsets(pack_list, self.width,
                                               sep, self.mode)

        xoffsets = xoffsets_ + [xd for w, h, xd, yd in whd_list]

        xdescent = whd_list[0][2]
        xoffsets = xoffsets - xdescent

        return (width + 2 * pad, height + 2 * pad,
                xdescent + pad, ydescent + pad,
                list(zip(xoffsets, yoffsets)))


class PaddedBox(OffsetBox):
    """
    A container to add a padding around an `.Artist`.

    The `.PaddedBox` contains a `.FancyBboxPatch` that is used to visualize
    it when rendering.
    """

    @_api.make_keyword_only("3.6", name="draw_frame")
    def __init__(self, child, pad=None, draw_frame=False, patch_attrs=None):
        """
        Parameters
        ----------
        child : `~matplotlib.artist.Artist`
            The contained `.Artist`.
        pad : float
            The padding in points. This will be scaled with the renderer dpi.
            In contrast, *width* and *height* are in *pixels* and thus not
            scaled.
        draw_frame : bool
            Whether to draw the contained `.FancyBboxPatch`.
        patch_attrs : dict or None
            Additional parameters passed to the contained `.FancyBboxPatch`.
        """
        super().__init__()
        self.pad = pad
        self._children = [child]
        self.patch = FancyBboxPatch(
            xy=(0.0, 0.0), width=1., height=1.,
            facecolor='w', edgecolor='k',
            mutation_scale=1,  # self.prop.get_size_in_points(),
            snap=True,
            visible=draw_frame,
            boxstyle="square,pad=0",
        )
        if patch_attrs is not None:
            self.patch.update(patch_attrs)

    def get_extent_offsets(self, renderer):
        # docstring inherited.
        dpicor = renderer.points_to_pixels(1.)
        pad = self.pad * dpicor
        w, h, xd, yd = self._children[0].get_extent(renderer)
        return (w + 2 * pad, h + 2 * pad, xd + pad, yd + pad,
                [(0, 0)])

    def draw(self, renderer):
        # docstring inherited
        w, h, xdescent, ydescent, offsets = self.get_extent_offsets(renderer)
        px, py = self.get_offset(w, h, xdescent, ydescent, renderer)
        for c, (ox, oy) in zip(self.get_visible_children(), offsets):
            c.set_offset((px + ox, py + oy))

        self.draw_frame(renderer)

        for c in self.get_visible_children():
            c.draw(renderer)

        self.stale = False

    def update_frame(self, bbox, fontsize=None):
        self.patch.set_bounds(bbox.bounds)
        if fontsize:
            self.patch.set_mutation_scale(fontsize)
        self.stale = True

    def draw_frame(self, renderer):
        # update the location and size of the legend
        self.update_frame(self.get_window_extent(renderer))
        self.patch.draw(renderer)


class DrawingArea(OffsetBox):
    """
    The DrawingArea can contain any Artist as a child. The DrawingArea
    has a fixed width and height. The position of children relative to
    the parent is fixed. The children can be clipped at the
    boundaries of the parent.
    """

    def __init__(self, width, height, xdescent=0., ydescent=0., clip=False):
        """
        Parameters
        ----------
        width, height : float
            Width and height of the container box.
        xdescent, ydescent : float
            Descent of the box in x- and y-direction.
        clip : bool
            Whether to clip the children to the box.
        """
        super().__init__()
        self.width = width
        self.height = height
        self.xdescent = xdescent
        self.ydescent = ydescent
        self._clip_children = clip
        self.offset_transform = mtransforms.Affine2D()
        self.dpi_transform = mtransforms.Affine2D()

    @property
    def clip_children(self):
        """
        If the children of this DrawingArea should be clipped
        by DrawingArea bounding box.
        """
        return self._clip_children

    @clip_children.setter
    def clip_children(self, val):
        self._clip_children = bool(val)
        self.stale = True

    def get_transform(self):
        """
        Return the `~matplotlib.transforms.Transform` applied to the children.
        """
        return self.dpi_transform + self.offset_transform

    def set_transform(self, t):
        """
        set_transform is ignored.
        """

    def set_offset(self, xy):
        """
        Set the offset of the container.

        Parameters
        ----------
        xy : (float, float)
            The (x, y) coordinates of the offset in display units.
        """
        self._offset = xy
        self.offset_transform.clear()
        self.offset_transform.translate(xy[0], xy[1])
        self.stale = True

    def get_offset(self):
        """Return offset of the container."""
        return self._offset

    def get_extent(self, renderer):
        """Return width, height, xdescent, ydescent of box."""
        dpi_cor = renderer.points_to_pixels(1.)
        return (self.width * dpi_cor, self.height * dpi_cor,
                self.xdescent * dpi_cor, self.ydescent * dpi_cor)

    def add_artist(self, a):
        """Add an `.Artist` to the container box."""
        self._children.append(a)
        if not a.is_transform_set():
            a.set_transform(self.get_transform())
        if self.axes is not None:
            a.axes = self.axes
        fig = self.figure
        if fig is not None:
            a.set_figure(fig)

    def draw(self, renderer):
        # docstring inherited

        dpi_cor = renderer.points_to_pixels(1.)
        self.dpi_transform.clear()
        self.dpi_transform.scale(dpi_cor)

        # At this point the DrawingArea has a transform
        # to the display space so the path created is
        # good for clipping children
        tpath = mtransforms.TransformedPath(
            mpath.Path([[0, 0], [0, self.height],
                        [self.width, self.height],
                        [self.width, 0]]),
            self.get_transform())
        for c in self._children:
            if self._clip_children and not (c.clipbox or c._clippath):
                c.set_clip_path(tpath)
            c.draw(renderer)

        bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class TextArea(OffsetBox):
    """
    The TextArea is a container artist for a single Text instance.

    The text is placed at (0, 0) with baseline+left alignment, by default. The
    width and height of the TextArea instance is the width and height of its
    child text.
    """

    @_api.make_keyword_only("3.6", name="textprops")
    def __init__(self, s,
                 textprops=None,
                 multilinebaseline=False,
                 ):
        """
        Parameters
        ----------
        s : str
            The text to be displayed.
        textprops : dict, default: {}
            Dictionary of keyword parameters to be passed to the `.Text`
            instance in the TextArea.
        multilinebaseline : bool, default: False
            Whether the baseline for multiline text is adjusted so that it
            is (approximately) center-aligned with single-line text.
        """
        if textprops is None:
            textprops = {}
        self._text = mtext.Text(0, 0, s, **textprops)
        super().__init__()
        self._children = [self._text]
        self.offset_transform = mtransforms.Affine2D()
        self._baseline_transform = mtransforms.Affine2D()
        self._text.set_transform(self.offset_transform +
                                 self._baseline_transform)
        self._multilinebaseline = multilinebaseline

    def set_text(self, s):
        """Set the text of this area as a string."""
        self._text.set_text(s)
        self.stale = True

    def get_text(self):
        """Return the string representation of this area's text."""
        return self._text.get_text()

    def set_multilinebaseline(self, t):
        """
        Set multilinebaseline.

        If True, the baseline for multiline text is adjusted so that it is
        (approximately) center-aligned with single-line text.  This is used
        e.g. by the legend implementation so that single-line labels are
        baseline-aligned, but multiline labels are "center"-aligned with them.
        """
        self._multilinebaseline = t
        self.stale = True

    def get_multilinebaseline(self):
        """
        Get multilinebaseline.
        """
        return self._multilinebaseline

    def set_transform(self, t):
        """
        set_transform is ignored.
        """

    def set_offset(self, xy):
        """
        Set the offset of the container.

        Parameters
        ----------
        xy : (float, float)
            The (x, y) coordinates of the offset in display units.
        """
        self._offset = xy
        self.offset_transform.clear()
        self.offset_transform.translate(xy[0], xy[1])
        self.stale = True

    def get_offset(self):
        """Return offset of the container."""
        return self._offset

    def get_extent(self, renderer):
        _, h_, d_ = renderer.get_text_width_height_descent(
            "lp", self._text._fontproperties,
            ismath="TeX" if self._text.get_usetex() else False)

        bbox, info, yd = self._text._get_layout(renderer)
        w, h = bbox.size

        self._baseline_transform.clear()

        if len(info) > 1 and self._multilinebaseline:
            yd_new = 0.5 * h - 0.5 * (h_ - d_)
            self._baseline_transform.translate(0, yd - yd_new)
            yd = yd_new
        else:  # single line
            h_d = max(h_ - d_, h - yd)
            h = h_d + yd

        ha = self._text.get_horizontalalignment()
        if ha == 'left':
            xd = 0
        elif ha == 'center':
            xd = w / 2
        elif ha == 'right':
            xd = w

        return w, h, xd, yd

    def draw(self, renderer):
        # docstring inherited
        self._text.draw(renderer)
        bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class AuxTransformBox(OffsetBox):
    """
    Offset Box with the aux_transform. Its children will be
    transformed with the aux_transform first then will be
    offsetted. The absolute coordinate of the aux_transform is meaning
    as it will be automatically adjust so that the left-lower corner
    of the bounding box of children will be set to (0, 0) before the
    offset transform.

    It is similar to drawing area, except that the extent of the box
    is not predetermined but calculated from the window extent of its
    children. Furthermore, the extent of the children will be
    calculated in the transformed coordinate.
    """
    def __init__(self, aux_transform):
        self.aux_transform = aux_transform
        super().__init__()
        self.offset_transform = mtransforms.Affine2D()
        # ref_offset_transform makes offset_transform always relative to the
        # lower-left corner of the bbox of its children.
        self.ref_offset_transform = mtransforms.Affine2D()

    def add_artist(self, a):
        """Add an `.Artist` to the container box."""
        self._children.append(a)
        a.set_transform(self.get_transform())
        self.stale = True

    def get_transform(self):
        """
        Return the :class:`~matplotlib.transforms.Transform` applied
        to the children
        """
        return (self.aux_transform
                + self.ref_offset_transform
                + self.offset_transform)

    def set_transform(self, t):
        """
        set_transform is ignored.
        """

    def set_offset(self, xy):
        """
        Set the offset of the container.

        Parameters
        ----------
        xy : (float, float)
            The (x, y) coordinates of the offset in display units.
        """
        self._offset = xy
        self.offset_transform.clear()
        self.offset_transform.translate(xy[0], xy[1])
        self.stale = True

    def get_offset(self):
        """Return offset of the container."""
        return self._offset

    def get_extent(self, renderer):
        # clear the offset transforms
        _off = self.offset_transform.get_matrix()  # to be restored later
        self.ref_offset_transform.clear()
        self.offset_transform.clear()
        # calculate the extent
        bboxes = [c.get_window_extent(renderer) for c in self._children]
        ub = mtransforms.Bbox.union(bboxes)
        # adjust ref_offset_transform
        self.ref_offset_transform.translate(-ub.x0, -ub.y0)
        # restore offset transform
        self.offset_transform.set_matrix(_off)

        return ub.width, ub.height, 0., 0.

    def draw(self, renderer):
        # docstring inherited
        for c in self._children:
            c.draw(renderer)
        bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class AnchoredOffsetbox(OffsetBox):
    """
    An offset box placed according to location *loc*.

    AnchoredOffsetbox has a single child.  When multiple children are needed,
    use an extra OffsetBox to enclose them.  By default, the offset box is
    anchored against its parent axes. You may explicitly specify the
    *bbox_to_anchor*.
    """
    zorder = 5  # zorder of the legend

    # Location codes
    codes = {'upper right': 1,
             'upper left': 2,
             'lower left': 3,
             'lower right': 4,
             'right': 5,
             'center left': 6,
             'center right': 7,
             'lower center': 8,
             'upper center': 9,
             'center': 10,
             }

    @_api.make_keyword_only("3.6", name="pad")
    def __init__(self, loc,
                 pad=0.4, borderpad=0.5,
                 child=None, prop=None, frameon=True,
                 bbox_to_anchor=None,
                 bbox_transform=None,
                 **kwargs):
        """
        Parameters
        ----------
        loc : str
            The box location.  Valid locations are
            'upper left', 'upper center', 'upper right',
            'center left', 'center', 'center right',
            'lower left', 'lower center', 'lower right'.
            For backward compatibility, numeric values are accepted as well.
            See the parameter *loc* of `.Legend` for details.
        pad : float, default: 0.4
            Padding around the child as fraction of the fontsize.
        borderpad : float, default: 0.5
            Padding between the offsetbox frame and the *bbox_to_anchor*.
        child : `.OffsetBox`
            The box that will be anchored.
        prop : `.FontProperties`
            This is only used as a reference for paddings. If not given,
            :rc:`legend.fontsize` is used.
        frameon : bool
            Whether to draw a frame around the box.
        bbox_to_anchor : `.BboxBase`, 2-tuple, or 4-tuple of floats
            Box that is used to position the legend in conjunction with *loc*.
        bbox_transform : None or :class:`matplotlib.transforms.Transform`
            The transform for the bounding box (*bbox_to_anchor*).
        **kwargs
            All other parameters are passed on to `.OffsetBox`.

        Notes
        -----
        See `.Legend` for a detailed description of the anchoring mechanism.
        """
        super().__init__(**kwargs)

        self.set_bbox_to_anchor(bbox_to_anchor, bbox_transform)
        self.set_child(child)

        if isinstance(loc, str):
            loc = _api.check_getitem(self.codes, loc=loc)

        self.loc = loc
        self.borderpad = borderpad
        self.pad = pad

        if prop is None:
            self.prop = FontProperties(size=mpl.rcParams["legend.fontsize"])
        else:
            self.prop = FontProperties._from_any(prop)
            if isinstance(prop, dict) and "size" not in prop:
                self.prop.set_size(mpl.rcParams["legend.fontsize"])

        self.patch = FancyBboxPatch(
            xy=(0.0, 0.0), width=1., height=1.,
            facecolor='w', edgecolor='k',
            mutation_scale=self.prop.get_size_in_points(),
            snap=True,
            visible=frameon,
            boxstyle="square,pad=0",
        )

    def set_child(self, child):
        """Set the child to be anchored."""
        self._child = child
        if child is not None:
            child.axes = self.axes
        self.stale = True

    def get_child(self):
        """Return the child."""
        return self._child

    def get_children(self):
        """Return the list of children."""
        return [self._child]

    def get_extent(self, renderer):
        """
        Return the extent of the box as (width, height, x, y).

        This is the extent of the child plus the padding.
        """
        w, h, xd, yd = self.get_child().get_extent(renderer)
        fontsize = renderer.points_to_pixels(self.prop.get_size_in_points())
        pad = self.pad * fontsize

        return w + 2 * pad, h + 2 * pad, xd + pad, yd + pad

    def get_bbox_to_anchor(self):
        """Return the bbox that the box is anchored to."""
        if self._bbox_to_anchor is None:
            return self.axes.bbox
        else:
            transform = self._bbox_to_anchor_transform
            if transform is None:
                return self._bbox_to_anchor
            else:
                return TransformedBbox(self._bbox_to_anchor, transform)

    def set_bbox_to_anchor(self, bbox, transform=None):
        """
        Set the bbox that the box is anchored to.

        *bbox* can be a Bbox instance, a list of [left, bottom, width,
        height], or a list of [left, bottom] where the width and
        height will be assumed to be zero. The bbox will be
        transformed to display coordinate by the given transform.
        """
        if bbox is None or isinstance(bbox, BboxBase):
            self._bbox_to_anchor = bbox
        else:
            try:
                l = len(bbox)
            except TypeError as err:
                raise ValueError(f"Invalid bbox: {bbox}") from err

            if l == 2:
                bbox = [bbox[0], bbox[1], 0, 0]

            self._bbox_to_anchor = Bbox.from_bounds(*bbox)

        self._bbox_to_anchor_transform = transform
        self.stale = True

    def get_offset(self, width, height, xdescent, ydescent, renderer):
        # docstring inherited
        bbox = Bbox.from_bounds(0, 0, width, height)
        pad = (self.borderpad
               * renderer.points_to_pixels(self.prop.get_size_in_points()))
        bbox_to_anchor = self.get_bbox_to_anchor()
        x0, y0 = _get_anchored_bbox(self.loc, bbox, bbox_to_anchor, pad)
        return x0 + xdescent, y0 + ydescent

    def update_frame(self, bbox, fontsize=None):
        self.patch.set_bounds(bbox.bounds)
        if fontsize:
            self.patch.set_mutation_scale(fontsize)

    def draw(self, renderer):
        # docstring inherited
        if not self.get_visible():
            return

        # update the location and size of the legend
        bbox = self.get_window_extent(renderer)
        fontsize = renderer.points_to_pixels(self.prop.get_size_in_points())
        self.update_frame(bbox, fontsize)
        self.patch.draw(renderer)

        width, height, xdescent, ydescent = self.get_extent(renderer)

        px, py = self.get_offset(width, height, xdescent, ydescent, renderer)

        self.get_child().set_offset((px, py))
        self.get_child().draw(renderer)
        self.stale = False


def _get_anchored_bbox(loc, bbox, parentbbox, borderpad):
    """
    Return the (x, y) position of the *bbox* anchored at the *parentbbox* with
    the *loc* code with the *borderpad*.
    """
    # This is only called internally and *loc* should already have been
    # validated.  If 0 (None), we just let ``bbox.anchored`` raise.
    c = [None, "NE", "NW", "SW", "SE", "E", "W", "E", "S", "N", "C"][loc]
    container = parentbbox.padded(-borderpad)
    return bbox.anchored(c, container=container).p0


class AnchoredText(AnchoredOffsetbox):
    """
    AnchoredOffsetbox with Text.
    """

    @_api.make_keyword_only("3.6", name="pad")
    def __init__(self, s, loc, pad=0.4, borderpad=0.5, prop=None, **kwargs):
        """
        Parameters
        ----------
        s : str
            Text.

        loc : str
            Location code. See `AnchoredOffsetbox`.

        pad : float, default: 0.4
            Padding around the text as fraction of the fontsize.

        borderpad : float, default: 0.5
            Spacing between the offsetbox frame and the *bbox_to_anchor*.

        prop : dict, optional
            Dictionary of keyword parameters to be passed to the
            `~matplotlib.text.Text` instance contained inside AnchoredText.

        **kwargs
            All other parameters are passed to `AnchoredOffsetbox`.
        """

        if prop is None:
            prop = {}
        badkwargs = {'va', 'verticalalignment'}
        if badkwargs & set(prop):
            raise ValueError(
                'Mixing verticalalignment with AnchoredText is not supported.')

        self.txt = TextArea(s, textprops=prop)
        fp = self.txt._text.get_fontproperties()
        super().__init__(
            loc, pad=pad, borderpad=borderpad, child=self.txt, prop=fp,
            **kwargs)


class OffsetImage(OffsetBox):

    @_api.make_keyword_only("3.6", name="zoom")
    def __init__(self, arr,
                 zoom=1,
                 cmap=None,
                 norm=None,
                 interpolation=None,
                 origin=None,
                 filternorm=True,
                 filterrad=4.0,
                 resample=False,
                 dpi_cor=True,
                 **kwargs
                 ):

        super().__init__()
        self._dpi_cor = dpi_cor

        self.image = BboxImage(bbox=self.get_window_extent,
                               cmap=cmap,
                               norm=norm,
                               interpolation=interpolation,
                               origin=origin,
                               filternorm=filternorm,
                               filterrad=filterrad,
                               resample=resample,
                               **kwargs
                               )

        self._children = [self.image]

        self.set_zoom(zoom)
        self.set_data(arr)

    def set_data(self, arr):
        self._data = np.asarray(arr)
        self.image.set_data(self._data)
        self.stale = True

    def get_data(self):
        return self._data

    def set_zoom(self, zoom):
        self._zoom = zoom
        self.stale = True

    def get_zoom(self):
        return self._zoom

    def get_offset(self):
        """Return offset of the container."""
        return self._offset

    def get_children(self):
        return [self.image]

    def get_extent(self, renderer):
        if self._dpi_cor:  # True, do correction
            dpi_cor = renderer.points_to_pixels(1.)
        else:
            dpi_cor = 1.

        zoom = self.get_zoom()
        data = self.get_data()
        ny, nx = data.shape[:2]
        w, h = dpi_cor * nx * zoom, dpi_cor * ny * zoom

        return w, h, 0, 0

    def draw(self, renderer):
        # docstring inherited
        self.image.draw(renderer)
        # bbox_artist(self, renderer, fill=False, props=dict(pad=0.))
        self.stale = False


class AnnotationBbox(martist.Artist, mtext._AnnotationBase):
    """
    Container for an `OffsetBox` referring to a specific position *xy*.

    Optionally an arrow pointing from the offsetbox to *xy* can be drawn.

    This is like `.Annotation`, but with `OffsetBox` instead of `.Text`.
    """

    zorder = 3

    def __str__(self):
        return "AnnotationBbox(%g,%g)" % (self.xy[0], self.xy[1])

    @_docstring.dedent_interpd
    @_api.make_keyword_only("3.6", name="xycoords")
    def __init__(self, offsetbox, xy,
                 xybox=None,
                 xycoords='data',
                 boxcoords=None,
                 frameon=True, pad=0.4,  # FancyBboxPatch boxstyle.
                 annotation_clip=None,
                 box_alignment=(
```


# lib/matplotlib/tests (the files in it)

lib/matplotlib/tests/Courier10PitchBT-Bold.pfb
lib/matplotlib/tests/README
lib/matplotlib/tests/__init__.py
lib/matplotlib/tests/baseline_images/dviread/test.dvi
lib/matplotlib/tests/baseline_images/dviread/test.json
lib/matplotlib/tests/baseline_images/dviread/test.map
lib/matplotlib/tests/baseline_images/dviread/test.tex
lib/matplotlib/tests/baseline_images/pngsuite/basn0g01.png
lib/matplotlib/tests/baseline_images/pngsuite/basn0g02.png
lib/matplotlib/tests/baseline_images/pngsuite/basn0g04.png
lib/matplotlib/tests/baseline_images/pngsuite/basn0g08.png
lib/matplotlib/tests/baseline_images/pngsuite/basn0g16.png
lib/matplotlib/tests/baseline_images/pngsuite/basn2c08.png
lib/matplotlib/tests/baseline_images/pngsuite/basn2c16.png
lib/matplotlib/tests/baseline_images/pngsuite/basn3p01.png
lib/matplotlib/tests/baseline_images/pngsuite/basn3p02.png
lib/matplotlib/tests/baseline_images/pngsuite/basn3p04.png
lib/matplotlib/tests/baseline_images/pngsuite/basn3p08.png
lib/matplotlib/tests/baseline_images/pngsuite/basn4a08.png
lib/matplotlib/tests/baseline_images/pngsuite/basn4a16.png
lib/matplotlib/tests/baseline_images/pngsuite/basn6a08.png
lib/matplotlib/tests/baseline_images/pngsuite/basn6a16.png
lib/matplotlib/tests/baseline_images/test_agg/agg_filter.png
lib/matplotlib/tests/baseline_images/test_agg_filter/agg_filter_alpha.pdf
lib/matplotlib/tests/baseline_images/test_agg_filter/agg_filter_alpha.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/arrow_styles.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/boxarrow_test_image.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/connection_styles.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/fancyarrow_dash.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/fancyarrow_dpi_cor_100dpi.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/fancyarrow_dpi_cor_200dpi.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/fancyarrow_test_image.pdf
lib/matplotlib/tests/baseline_images/test_arrow_patches/fancyarrow_test_image.png
lib/matplotlib/tests/baseline_images/test_arrow_patches/fancyarrow_test_image.svg
lib/matplotlib/tests/baseline_images/test_artist/clip_path_clipping.pdf
lib/matplotlib/tests/baseline_images/test_artist/clip_path_clipping.png
lib/matplotlib/tests/baseline_images/test_artist/clip_path_clipping.svg
lib/matplotlib/tests/baseline_images/test_artist/default_edges.png
lib/matplotlib/tests/baseline_images/test_artist/hatching.pdf
lib/matplotlib/tests/baseline_images/test_artist/hatching.png
lib/matplotlib/tests/baseline_images/test_artist/hatching.svg
lib/matplotlib/tests/baseline_images/test_axes/aitoff_proj.png
lib/matplotlib/tests/baseline_images/test_axes/angle_spectrum_freqs.png
lib/matplotlib/tests/baseline_images/test_axes/angle_spectrum_noise.png
lib/matplotlib/tests/baseline_images/test_axes/annotate_across_transforms.png
lib/matplotlib/tests/baseline_images/test_axes/arc_angles.png
lib/matplotlib/tests/baseline_images/test_axes/arc_ellipse.pdf
lib/matplotlib/tests/baseline_images/test_axes/arc_ellipse.png
lib/matplotlib/tests/baseline_images/test_axes/arc_ellipse.svg
lib/matplotlib/tests/baseline_images/test_axes/arrow_simple.png
lib/matplotlib/tests/baseline_images/test_axes/autoscale_tiny_range.pdf
lib/matplotlib/tests/baseline_images/test_axes/autoscale_tiny_range.png
lib/matplotlib/tests/baseline_images/test_axes/autoscale_tiny_range.svg
lib/matplotlib/tests/baseline_images/test_axes/axhspan_epoch.pdf
lib/matplotlib/tests/baseline_images/test_axes/axhspan_epoch.png
lib/matplotlib/tests/baseline_images/test_axes/axhspan_epoch.svg
lib/matplotlib/tests/baseline_images/test_axes/axisbelow.png
lib/matplotlib/tests/baseline_images/test_axes/axvspan_epoch.pdf
lib/matplotlib/tests/baseline_images/test_axes/axvspan_epoch.png
lib/matplotlib/tests/baseline_images/test_axes/axvspan_epoch.svg
lib/matplotlib/tests/baseline_images/test_axes/bar_tick_label_multiple.png
lib/matplotlib/tests/baseline_images/test_axes/bar_tick_label_multiple_old_label_alignment.png
lib/matplotlib/tests/baseline_images/test_axes/bar_tick_label_single.png
lib/matplotlib/tests/baseline_images/test_axes/barh_tick_label.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot.pdf
lib/matplotlib/tests/baseline_images/test_axes/boxplot.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot.svg
lib/matplotlib/tests/baseline_images/test_axes/boxplot_autorange_false_whiskers.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_autorange_true_whiskers.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_custom_capwidths.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_mod_artists_after_plotting.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_no_inverted_whisker.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_rc_parameters.pdf
lib/matplotlib/tests/baseline_images/test_axes/boxplot_rc_parameters.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_rc_parameters.svg
lib/matplotlib/tests/baseline_images/test_axes/boxplot_sym.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_sym2.png
lib/matplotlib/tests/baseline_images/test_axes/boxplot_with_CIarray.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_baseline.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_custom_capwidth.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_custom_capwidths.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_custombox.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_customcap.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_custommedian.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_customoutlier.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_custompatchartist.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_custompositions.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_customwhisker.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_customwidths.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_horizontal.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_no_flier_stats.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_nobox.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_nocaps.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_patchartist.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_percentilewhis.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_rangewhis.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_scalarwidth.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_with_xlabels.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_with_ylabels.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_withmean_custompoint.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_withmean_line.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_withmean_point.png
lib/matplotlib/tests/baseline_images/test_axes/bxp_withnotch.png
lib/matplotlib/tests/baseline_images/test_axes/canonical.pdf
lib/matplotlib/tests/baseline_images/test_axes/canonical.png
lib/matplotlib/tests/baseline_images/test_axes/canonical.svg
lib/matplotlib/tests/baseline_images/test_axes/contour_colorbar.pdf
lib/matplotlib/tests/baseline_images/test_axes/contour_colorbar.png
lib/matplotlib/tests/baseline_images/test_axes/contour_colorbar.svg
lib/matplotlib/tests/baseline_images/test_axes/contour_hatching.pdf
lib/matplotlib/tests/baseline_images/test_axes/contour_hatching.png
lib/matplotlib/tests/baseline_images/test_axes/contour_hatching.svg
lib/matplotlib/tests/baseline_images/test_axes/csd_freqs.png
lib/matplotlib/tests/baseline_images/test_axes/csd_noise.png
lib/matplotlib/tests/baseline_images/test_axes/dash_offset.pdf
lib/matplotlib/tests/baseline_images/test_axes/dash_offset.png
lib/matplotlib/tests/baseline_images/test_axes/dash_offset.svg
lib/matplotlib/tests/baseline_images/test_axes/date_timezone_x.png
lib/matplotlib/tests/baseline_images/test_axes/date_timezone_x_and_y.png
lib/matplotlib/tests/baseline_images/test_axes/date_timezone_y.png
lib/matplotlib/tests/baseline_images/test_axes/errorbar_basic.pdf
lib/matplotlib/tests/baseline_images/test_axes/errorbar_basic.png
lib/matplotlib/tests/baseline_images/test_axes/errorbar_basic.svg
lib/matplotlib/tests/baseline_images/test_axes/errorbar_limits.pdf
lib/matplotlib/tests/baseline_images/test_axes/errorbar_limits.png
lib/matplotlib/tests/baseline_images/test_axes/errorbar_limits.svg
lib/matplotlib/tests/baseline_images/test_axes/errorbar_mixed.pdf
lib/matplotlib/tests/baseline_images/test_axes/errorbar_mixed.png
lib/matplotlib/tests/baseline_images/test_axes/errorbar_mixed.svg
lib/matplotlib/tests/baseline_images/test_axes/errorbar_zorder.pdf
lib/matplotlib/tests/baseline_images/test_axes/errorbar_zorder.png
lib/matplotlib/tests/baseline_images/test_axes/errorbar_zorder.svg
lib/matplotlib/tests/baseline_images/test_axes/eventplot.pdf
lib/matplotlib/tests/baseline_images/test_axes/eventplot.png
lib/matplotlib/tests/baseline_images/test_axes/eventplot.svg
lib/matplotlib/tests/baseline_images/test_axes/extent_units.png
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate.pdf
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate.png
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate.svg
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate_decreasing.pdf
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate_decreasing.png
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate_decreasing.svg
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate_nan.pdf
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate_nan.png
lib/matplotlib/tests/baseline_images/test_axes/fill_between_interpolate_nan.svg
lib/matplotlib/tests/baseline_images/test_axes/fill_units.png
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_001.pdf
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_001.png
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_001.svg
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_002.pdf
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_002.png
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_002.svg
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_003.pdf
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_003.png
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_003.svg
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_004.pdf
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_004.png
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_004.svg
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_005.pdf
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_005.png
lib/matplotlib/tests/baseline_images/test_axes/formatter_ticker_005.svg
lib/matplotlib/tests/baseline_images/test_axes/hexbin_empty.png
lib/matplotlib/tests/baseline_images/test_axes/hexbin_extent.png
lib/matplotlib/tests/baseline_images/test_axes/hexbin_linear.png
lib/matplotlib/tests/baseline_images/test_axes/hexbin_log.png
lib/matplotlib/tests/baseline_images/test_axes/hist2d.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist2d.png
lib/matplotlib/tests/baseline_images/test_axes/hist2d.svg
lib/matplotlib/tests/baseline_images/test_axes/hist2d_transpose.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist2d_transpose.png
lib/matplotlib/tests/baseline_images/test_axes/hist2d_transpose.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_bar_empty.png
lib/matplotlib/tests/baseline_images/test_axes/hist_density.png
lib/matplotlib/tests/baseline_images/test_axes/hist_log.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_log.png
lib/matplotlib/tests/baseline_images/test_axes/hist_log.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_offset.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_offset.png
lib/matplotlib/tests/baseline_images/test_axes/hist_offset.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked.png
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_bar.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_bar.png
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_bar.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_normed.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_normed.png
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_normed.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_step.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_step.png
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_step.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_stepfilled.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_stepfilled.png
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_stepfilled.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_stepfilled_alpha.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_stepfilled_alpha.png
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_stepfilled_alpha.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_weights.pdf
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_weights.png
lib/matplotlib/tests/baseline_images/test_axes/hist_stacked_weights.svg
lib/matplotlib/tests/baseline_images/test_axes/hist_step.png
lib/matplotlib/tests/baseline_images/test_axes/hist_step_bottom.png
lib/matplotlib/tests/baseline_images/test_axes/hist_step_empty.png
lib/matplotlib/tests/baseline_images/test_axes/hist_step_filled.png
lib/matplotlib/tests/baseline_images/test_axes/hist_step_horiz.png
lib/matplotlib/tests/baseline_images/test_axes/hlines_basic.png
lib/matplotlib/tests/baseline_images/test_axes/hlines_masked.png
lib/matplotlib/tests/baseline_images/test_axes/hlines_with_nan.png
lib/matplotlib/tests/baseline_images/test_axes/imshow.pdf
lib/matplotlib/tests/baseline_images/test_axes/imshow.png
lib/matplotlib/tests/baseline_images/test_axes/imshow.svg
lib/matplotlib/tests/baseline_images/test_axes/imshow_clip.pdf
lib/matplotlib/tests/baseline_images/test_axes/imshow_clip.png
lib/matplotlib/tests/baseline_images/test_axes/imshow_clip.svg
lib/matplotlib/tests/baseline_images/test_axes/inset_polar.png
lib/matplotlib/tests/baseline_images/test_axes/loglog.png
lib/matplotlib/tests/baseline_images/test_axes/magnitude_spectrum_freqs_dB.png
lib/matplotlib/tests/baseline_images/test_axes/magnitude_spectrum_freqs_linear.png
lib/matplotlib/tests/baseline_images/test_axes/magnitude_spectrum_noise_dB.png
lib/matplotlib/tests/baseline_images/test_axes/magnitude_spectrum_noise_linear.png
lib/matplotlib/tests/baseline_images/test_axes/marker_edges.pdf
lib/matplotlib/tests/baseline_images/test_axes/marker_edges.png
lib/matplotlib/tests/baseline_images/test_axes/marker_edges.svg
lib/matplotlib/tests/baseline_images/test_axes/marker_styles.png
lib/matplotlib/tests/baseline_images/test_axes/markevery.pdf
lib/matplotlib/tests/baseline_images/test_axes/markevery.png
lib/matplotlib/tests/baseline_images/test_axes/markevery.svg
lib/matplotlib/tests/baseline_images/test_axes/markevery_line.pdf
lib/matplotlib/tests/baseline_images/test_axes/markevery_line.png
lib/matplotlib/tests/baseline_images/test_axes/markevery_line.svg
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales.pdf
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales.png
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales.svg
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales_nans.pdf
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales_nans.png
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales_nans.svg
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales_zoomed.pdf
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales_zoomed.png
lib/matplotlib/tests/baseline_images/test_axes/markevery_linear_scales_zoomed.svg
lib/matplotlib/tests/baseline_images/test_axes/markevery_log_scales.pdf
lib/matplotlib/tests/baseline_images/test_axes/markevery_log_scales.png
lib/matplotlib/tests/baseline_images/test_axes/markevery_log_scales.svg
lib/matplotlib/tests/baseline_images/test_axes/markevery_polar.pdf
lib/matplotlib/tests/baseline_images/test_axes/markevery_polar.png
lib/matplotlib/tests/baseline_images/test_axes/markevery_polar.svg
lib/matplotlib/tests/baseline_images/test_axes/mixed_collection.pdf
lib/matplotlib/tests/baseline_images/test_axes/mixed_collection.png
lib/matplotlib/tests/baseline_images/test_axes/mixed_collection.svg
lib/matplotlib/tests/baseline_images/test_axes/mixed_errorbar_polar_caps.png
lib/matplotlib/tests/baseline_images/test_axes/mollweide_grid.pdf
lib/matplotlib/tests/baseline_images/test_axes/mollweide_grid.png
lib/matplotlib/tests/baseline_images/test_axes/mollweide_grid.svg
lib/matplotlib/tests/baseline_images/test_axes/nonfinite_limits.pdf
lib/matplotlib/tests/baseline_images/test_axes/nonfinite_limits.png
lib/matplotlib/tests/baseline_images/test_axes/nonfinite_limits.svg
lib/matplotlib/tests/baseline_images/test_axes/o_marker_path_snap.png
lib/matplotlib/tests/baseline_images/test_axes/offset_points.pdf
lib/matplotlib/tests/baseline_images/test_axes/offset_points.png
lib/matplotlib/tests/baseline_images/test_axes/offset_points.svg
lib/matplotlib/tests/baseline_images/test_axes/pcolor_datetime_axis.png
lib/matplotlib/tests/baseline_images/test_axes/pcolormesh.pdf
lib/matplotlib/tests/baseline_images/test_axes/pcolormesh.png
lib/matplotlib/tests/baseline_images/test_axes/pcolormesh.svg
lib/matplotlib/tests/baseline_images/test_axes/pcolormesh_alpha.pdf
lib/matplotlib/tests/baseline_images/test_axes/pcolormesh_alpha.png
lib/matplotlib/tests/baseline_images/test_axes/pcolormesh_datetime_axis.png
lib/matplotlib/tests/baseline_images/test_axes/pcolormesh_small.eps
lib/matplotlib/tests/baseline_images/test_axes/phase_spectrum_freqs.png
lib/matplotlib/tests/baseline_images/test_axes/phase_spectrum_noise.png
lib/matplotlib/tests/baseline_images/test_axes/pie_ccw_true.png
lib/matplotlib/tests/baseline_images/test_axes/pie_center_radius.png
lib/matplotlib/tests/baseline_images/test_axes/pie_default.png
lib/matplotlib/tests/baseline_images/test_axes/pie_frame_grid.png
lib/matplotlib/tests/baseline_images/test_axes/pie_linewidth_0.png
lib/matplotlib/tests/baseline_images/test_axes/pie_linewidth_2.png
lib/matplotlib/tests/baseline_images/test_axes/pie_no_label.png
lib/matplotlib/tests/baseline_images/test_axes/pie_rotatelabels_true.png
lib/matplotlib/tests/baseline_images/test_axes/polycollection_joinstyle.pdf
lib/matplotlib/tests/baseline_images/test_axes/polycollection_joinstyle.png
lib/matplotlib/tests/baseline_images/test_axes/polycollection_joinstyle.svg
lib/matplotlib/tests/baseline_images/test_axes/psd_freqs.png
lib/matplotlib/tests/baseline_images/test_axes/psd_noise.png
lib/matplotlib/tests/baseline_images/test_axes/rc_grid.png
lib/matplotlib/tests/baseline_images/test_axes/rc_markerfill.png
lib/matplotlib/tests/baseline_images/test_axes/rc_spines.png
lib/matplotlib/tests/baseline_images/test_axes/retain_tick_visibility.png
lib/matplotlib/tests/baseline_images/test_axes/rgba_markers.pdf
lib/matplotlib/tests/baseline_images/test_axes/rgba_markers.png
lib/matplotlib/tests/baseline_images/test_axes/rgba_markers.svg
lib/matplotlib/tests/baseline_images/test_axes/scatter.pdf
lib/matplotlib/tests/baseline_images/test_axes/scatter.png
lib/matplotlib/tests/baseline_images/test_axes/scatter.svg
lib/matplotlib/tests/baseline_images/test_axes/scatter_2D.png
lib/matplotlib/tests/baseline_images/test_axes/scatter_marker.png
lib/matplotlib/tests/baseline_images/test_axes/secondary_xy.png
lib/matplotlib/tests/baseline_images/test_axes/set_get_ticklabels.png
lib/matplotlib/tests/baseline_images/test_axes/single_date.png
lib/matplotlib/tests/baseline_images/test_axes/single_point.pdf
lib/matplotlib/tests/baseline_images/test_axes/single_point.png
lib/matplotlib/tests/baseline_images/test_axes/single_point.svg
lib/matplotlib/tests/baseline_images/test_axes/specgram_angle_freqs.png
lib/matplotlib/tests/baseline_images/test_axes/specgram_angle_noise.png


# The last commit

```
31b1ec1d58 SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest lib/matplotlib/tests/test_offsetbox.py -q
..s..................................................................... [ 25%]
........................................................................ [ 51%]
........................................................................ [ 77%]
................................................................         [100%]
279 passed, 1 skipped in 3.57s
scope: lib/matplotlib/offsetbox.py lib/matplotlib/tests
changed: lib/matplotlib/offsetbox.py +2 -2
changed: lib/matplotlib/tests/test_offsetbox.py +38 -2
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/lib/matplotlib/offsetbox.py b/lib/matplotlib/offsetbox.py
index 3a506543ac..059a6c8ae3 100644
--- a/lib/matplotlib/offsetbox.py
+++ b/lib/matplotlib/offsetbox.py
@@ -166,10 +166,10 @@ def _get_aligned_offsets(hd_list, height, align="baseline"):
         descent = max(d for h, d in hd_list)
         height = height_descent + descent
         offsets = [0. for h, d in hd_list]
-    elif align in ["left", "top"]:
+    elif align in ["left", "bottom"]:
         descent = 0.
         offsets = [d for h, d in hd_list]
-    elif align in ["right", "bottom"]:
+    elif align in ["right", "top"]:
         descent = 0.
         offsets = [height - h + d for h, d in hd_list]
     elif align == "center":
diff --git a/lib/matplotlib/tests/test_offsetbox.py b/lib/matplotlib/tests/test_offsetbox.py
index 02756ff559..a445c653dd 100644
--- a/lib/matplotlib/tests/test_offsetbox.py
+++ b/lib/matplotlib/tests/test_offsetbox.py
@@ -12,8 +12,9 @@ import matplotlib.lines as mlines
 from matplotlib.backend_bases import MouseButton, MouseEvent
 
 from matplotlib.offsetbox import (
-    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, OffsetBox,
-    OffsetImage, TextArea, _get_packed_offsets)
+    AnchoredOffsetbox, AnnotationBbox, AnchoredText, DrawingArea, HPacker,
+    OffsetBox, OffsetImage, TextArea, _get_aligned_offsets,
+    _get_packed_offsets)
 
 
 @image_comparison(['offsetbox_clipping'], remove_text=True)
@@ -187,6 +188,41 @@ def test_get_packed_offsets_equal_total_none_sep_none():
         _get_packed_offsets([1, 1, 1], total=None, sep=None, mode='equal')
 
 
+@pytest.mark.parametrize('align, expected_offsets', [
+    ('baseline', [0, 0]),
+    ('bottom', [2, 1]),
+    ('left', [2, 1]),
+    ('top', [2, 6]),
+    ('right', [2, 6]),
+    ('center', [2, 3.5]),
+])
+def test_get_aligned_offsets(align, expected_offsets):
+    # The boxes have heights 10 and 5, and descents 2 and 1.
+    height, descent, offsets = _get_aligned_offsets(
+        [(10, 2), (5, 1)], None, align)
+    assert height == 10
+    assert descent == (2 if align == "baseline" else 0)
+    assert_allclose(offsets, expected_offsets)
+
+
+@pytest.mark.parametrize('align, anchored', [
+    ('top', 'y1'),
+    ('bottom', 'y0'),
+])
+def test_hpacker_align(align, anchored):
+    fig, ax = plt.subplots()
+    child1 = DrawingArea(10, 20)
+    child2 = DrawingArea(10, 30)
+    packer = HPacker(children=[child1, child2], pad=0, sep=0, align=align)
+    ax.add_artist(packer)
+    fig.canvas.draw()
+    renderer = fig.canvas.get_renderer()
+    bbox1 = child1.get_window_extent(renderer)
+    bbox2 = child2.get_window_extent(renderer)
+    assert getattr(bbox1, anchored) == pytest.approx(
+        getattr(bbox2, anchored))
+
+
 @pytest.mark.parametrize('child_type', ['draw', 'image', 'text'])
 @pytest.mark.parametrize('boxcoords',
                          ['axes fraction', 'axes pixels', 'axes points',
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
check: python -m pytest lib/matplotlib/tests/test_offsetbox.py -q
..s..................................................................... [ 25%]
........................................................................ [ 51%]
........................................................................ [ 77%]
................................................................         [100%]
279 passed, 1 skipped in 3.82s
scope: lib/matplotlib/offsetbox.py lib/matplotlib/tests
changed: lib/matplotlib/offsetbox.py +2 -2
changed: lib/matplotlib/tests/test_offsetbox.py +38 -2
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
# Notes, run 2026-11-06T120155

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

[Bug]: `align` in `HPacker` is reversed
### Bug summary

For the `align` parameter in `HPacker`, the options `top` and `bottom` seems reversed

### Code for reproduction

```python
import matplotlib.pyplot as plt
from matplotlib.offsetbox import DrawingArea, HPacker, VPacker, AnchoredOffsetbox, TextArea
from matplotlib.patches import Rectangle

da1 = DrawingArea(10, 20)
rect1 = Rectangle((0, 0), 10, 20)
da1.add_artist(rect1)

da2 = DrawingArea(10, 30)
rect2 = Rectangle((0, 0), 10, 30)
da2.add_artist(rect2)

align = "bottom"

pack = HPacker(children=[da1, da2], pad=10, sep=10, align=align)
title = TextArea(f"align='{align}'")
pack = VPacker(children=[title, pack], sep=10, pad=10, align="center")

box = AnchoredOffsetbox(child=pack, loc="center")

_, ax = plt.subplots()
ax.add_artist(box)
```


### Actual outcome

![download](https://user-images.githubusercontent.com/23433306/200162888-702626bf-ad47-40e2-8751-7dffe91df85c.png)


### Expected outcome

![download](https://user-images.githubusercontent.com/23433306/200162908-e0e9dfd5-6f8b-4aac-975e-bb363d809c41.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.6.2

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
.github/workflows/cibuildsdist.yml
.github/workflows/cibuildwheel.yml
.github/workflows/circleci.yml
.github/workflows/clean_pr.yml
.github/workflows/codeql-analysis.yml
.github/workflows/conflictcheck.yml
.github/workflows/nightlies.yml
.github/workflows/pr_welcome.yml
.github/workflows/reviewdog.yml
.github/workflows/tests.yml
.gitignore
.lgtm.yml
.mailmap
.matplotlib-repo
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
README.md
SECURITY.md
azure-pipelines.yml
ci/check_version_number.py
ci/check_wheel_licenses.py
ci/codespell-ignore-words.txt
ci/silence
doc/Makefile
doc/README.txt
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
doc/_static/mplot3d_view_angles.png
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
doc/_static/zenodo_cache/6513224.svg
doc/_static/zenodo_cache/6982547.svg
doc/_static/zenodo_cache/7084615.svg
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
doc/api/ft2font.rst
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
doc/api/next_api_changes/behavior/23573-AL.rst
doc/api/next_api_changes/behavior/23579-AL.rst
doc/api/next_api_changes/behavior/23710-ES.rst
doc/api/next_api_changes/behavior/24062-tb.rst
doc/api/next_api_changes/behavior/24132-GL.rst
doc/api/next_api_changes/behavior/24189-JB.rst
doc/api/next_api_changes/deprecations/00001-ABC.rst
doc/api/next_api_changes/deprecations/23449-SS.rst
doc/api/next_api_changes/deprecations/23720-RS.rst
doc/api/next_api_changes/deprecations/23735-ES.rst
doc/api/next_api_changes/deprecations/23824-OG.rst
doc/api/next_api_changes/deprecations/24000-TH.rst
doc/api/next_api_changes/deprecations/24013-TH.rst
doc/api/next_api_changes/deprecations/24088-JMK.rst
doc/api/next_api_changes/deprecations/24140-AL.rst
doc/api/next_api_changes/deprecations/24144-AL.rst
doc/api/next_api_changes/deprecations/24198-AL.rst
doc/api/next_api_changes/deprecations/24208-AL.rst
doc/api/next_api_changes/deprecations/24220-AL.rst
doc/api/next_api_changes/deprecations/24221-AL.rst
doc/api/next_api_changes/deprecations/24224-OG.rst
doc/api/next_api_changes/deprecations/24240-OG.rst
doc/api/next_api_changes/deprecations/24305-AL.rst
doc/api/next_api_changes/deprecations/24455-AL.rst
doc/api/next_api_changes/development/00001-ABC.rst
doc/api/next_api_changes/development/23683-AL.rst
doc/api/next_api_changes/development/24257-AL.rst
doc/api/next_api_changes/removals/00001-ABC.rst
doc/api/next_api_changes/removals/24125-OG.rst
doc/api/next_api_changes/removals/24128-OG.rst
doc/api/next_api_changes/removals/24129-OG.rst
doc/api/next_api_changes/removals/24251-OG.rst
doc/api/next_api_changes/removals/24253-OG.rst
doc/api/next_api_changes/removals/24257-AL.rst
doc/api/next_api_changes/removals/24355-OG.rst
doc/api/next_api_changes/removals/24356-OG.rst
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
doc/api/prev_api_changes/api_changes_3.5.2.rst
doc/api/prev_api_changes/api_changes_3.5.3.rst
doc/api/prev_api_changes/api_changes_3.6.0.rst
doc/api/prev_api_changes/api_changes_3.6.0/behaviour.rst
doc/api/prev_api_changes/api_changes_3.6.0/deprecations.rst
doc/api/prev_api_changes/api_changes_3.6.0/development.rst
doc/api/prev_api_changes/api_changes_3.6.0/removals.rst
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
doc/api/toolkits/axes_grid1.rst
doc/api/toolkits/axisartist.rst
doc/api/toolkits/mplot3d.rst
doc/api/toolkits/mplot3d/axes3d.rst
doc/api/toolkits/mplot3d/faq.rst
doc/api/toolkits/mplot3d/view_angles.rst
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
doc/users/explain/writing_a_backend_pyplot_interface.rst
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
doc/users/next_whats_new/3d_pane_color_rcparams.rst
doc/users/next_whats_new/3d_plot_aspects_adjustable_keyword.rst
doc/users/next_whats_new/3d_plot_pan_zoom.rst
doc/users/next_whats_new/README.rst
doc/users/next_whats_new/bar_label_formatting.rst
doc/users/next_whats_new/colorbar_has_location_argument.rst
doc/users/next_whats_new/imshow_extent_units.rst
doc/users/next_whats_new/polar_errorbar_caps.rst
doc/users/next_whats_new/shade_poly3dcollection.rst
doc/users/next_whats_new/show_source_links_directive_option.rst
doc/users/next_whats_new/styles_from_packages.rst
doc/users/next_whats_new/view_current_axis_format.rst
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
doc/users/prev_whats_new/github_stats_3.5.1.rst
doc/users/prev_whats_new/github_stats_3.5.2.rst
doc/users/prev_whats_new/github_stats_3.5.3.rst
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
doc/users/prev_whats_new/whats_new_3.5.2.rst
doc/users/prev_whats_new/whats_new_3.6.0.rst
doc/users/project/citing.rst
doc/users/project/credits.rst
doc/users/project/history.rst
doc/users/project/index.rst
doc/users/project/license.rst
doc/users/project/mission.rst
doc/users/release_notes.rst
doc/users/release_notes_next.rst
doc/users/resources/index.rst
environment.yml
examples/README.txt
examples/animation/README.txt
examples/animation/animate_decay.py
examples/animation/animated_histogram.py
examples/animation/animation_demo.py
examples/animation/bayes_update.py
examples/animation/double_pendulum.py
examples/animation/dynamic_image.py
examples/animation/frame_grabbing_sgskip.py
examples/animation/multiple_axes.py
examples/animation/pause_resume.py
examples/animation/rain.py
examples/animation/random_walk.py
examples/animation/simple_anim.py
examples/animation/simple_scatter.py
examples/animation/strip_chart.py
examples/animation/unchained.py
examples/axes_grid1/README.txt
examples/axes_grid1/demo_anchored_direction_arrows.py
```


# The last commit

```
31b1ec1d58 SWE-bench


```

```diff

```


# README.md (the start)

```
[![PyPi](https://badge.fury.io/py/matplotlib.svg)](https://badge.fury.io/py/matplotlib)
[![Downloads](https://pepy.tech/badge/matplotlib/month)](https://pepy.tech/project/matplotlib)
[![NUMFocus](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](https://numfocus.org)

[![DiscourseBadge](https://img.shields.io/badge/help_forum-discourse-blue.svg)](https://discourse.matplotlib.org)
[![Gitter](https://badges.gitter.im/matplotlib/matplotlib.svg)](https://gitter.im/matplotlib/matplotlib)
[![GitHubIssues](https://img.shields.io/badge/issue_tracking-github-blue.svg)](https://github.com/matplotlib/matplotlib/issues)
[![GitTutorial](https://img.shields.io/badge/PR-Welcome-%23FF8300.svg?)](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project)

[![GitHubActions](https://github.com/matplotlib/matplotlib/workflows/Tests/badge.svg)](https://github.com/matplotlib/matplotlib/actions?query=workflow%3ATests)
[![AzurePipelines](https://dev.azure.com/matplotlib/matplotlib/_apis/build/status/matplotlib.matplotlib?branchName=main)](https://dev.azure.com/matplotlib/matplotlib/_build/latest?definitionId=1&branchName=main)
[![AppVeyor](https://ci.appveyor.com/api/projects/status/github/matplotlib/matplotlib?branch=main&svg=true)](https://ci.appveyor.com/project/matplotlib/matplotlib)
[![Codecov](https://codecov.io/github/matplotlib/matplotlib/badge.svg?branch=main&service=github)](https://codecov.io/github/matplotlib/matplotlib?branch=main)
[![LGTM](https://img.shields.io/lgtm/grade/python/github/matplotlib/matplotlib.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/matplotlib/matplotlib)

![image](https://matplotlib.org/_static/logo2.svg)

Matplotlib is a comprehensive library for creating static, animated, and
interactive visualizations in Python.

Check out our [home page](https://matplotlib.org/) for more information.

![image](https://matplotlib.org/_static/readme_preview.png)

Matplotlib produces publication-quality figures in a variety of hardcopy
formats and interactive environments across platforms. Matplotlib can be
used in Python scripts, Python/IPython shells, web application servers,
and various graphical user interface toolkits.

## Install

See the [install
documentation](https://matplotlib.org/stable/users/installing/index.html),
which is generated from `/doc/users/installing/index.rst`

## Contribute

You've discovered a bug or something else you want to change -
excellent!

You've worked out a way to fix it -- even better!

You want to tell us about it -- best of all!

Start at the [contributing
guide](https://matplotlib.org/devdocs/devel/contributing.html)!

## Contact

[Discourse](https://discourse.matplotlib.org/) is the discussion forum
for general questions and discussions and our recommended starting
point.

Our active mailing lists (which are mirrored on Discourse) are:

-   [Users](https://mail.python.org/mailman/listinfo/matplotlib-users)
    mailing list: <matplotlib-users@python.org>
-   [Announcement](https://mail.python.org/mailman/listinfo/matplotlib-announce)
    mailing list: <matplotlib-announce@python.org>
-   [Development](https://mail.python.org/mailman/listinfo/matplotlib-devel)
    mailing list: <matplotlib-devel@python.org>

[Gitter](https://gitter.im/matplotlib/matplotlib) is for coordinating
development and asking questions directly related to contributing to
matplotlib.

## Citing Matplotlib

If Matplotlib contributes to a project that leads to publication, please
acknowledge this by citing Matplotlib.

[A ready-made citation
entry](https://matplotlib.org/stable/users/project/citing.html) is
available.

### Research notice

Please note that this repository is participating in a study into
sustainability of open source projects. Data will be gathered about this
repository for approximately the next 12 months, starting from June
2021.

Data collected will include number of contributors, number of PRs, time
taken to close/merge these PRs, and issues closed.

For more information, please visit [the informational
page](https://sustainable-open-science-and-software.github.io/) or
download the [participant information
sheet](https://sustainable-open-science-and-software.github.io/assets/PIS_sustainable_software.pdf).

```


# pyproject.toml (the start)

```
[build-system]
build-backend = "setuptools.build_meta"
requires = [
    "certifi>=2020.06.20",
    "oldest-supported-numpy",
    "setuptools_scm>=7",
]

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest lib/matplotlib/tests/test_offsetbox.py -q`

## Scope
`lib/matplotlib/offsetbox.py`
`lib/matplotlib/tests/`

## Done when
`HPacker` with `align="bottom"` aligns child boxes by their bottom edges against the tallest child.
`HPacker` with `align="top"` aligns child boxes by their top edges against the tallest child.
(inferred) `HPacker` `center`/`baseline` behavior and `VPacker` alignment are unchanged.

## Approach
Fix the vertical offset mapping in `HPacker` inside `lib/matplotlib/offsetbox.py`: inspect `HPacker.get_extent_offsets` and the helper that converts `align` into child y-offsets, then make `top` and `bottom` map to the correct bottom-origin offsets. Candidate A: swap the `top`/`bottom` branches in the alignment helper, which is the smallest change but must be checked for shared use. Candidate B: invert only at the `HPacker` call site so other packers are unaffected, at the cost of a misleading shared helper. Candidate C: add a dedicated `HPacker` vertical-alignment helper if shared logic makes the fix too broad. Verify with a minimal `DrawingArea` reproduction and the offsetbox tests.
```

### `prompt.md`

````
[Bug]: `align` in `HPacker` is reversed
### Bug summary

For the `align` parameter in `HPacker`, the options `top` and `bottom` seems reversed

### Code for reproduction

```python
import matplotlib.pyplot as plt
from matplotlib.offsetbox import DrawingArea, HPacker, VPacker, AnchoredOffsetbox, TextArea
from matplotlib.patches import Rectangle

da1 = DrawingArea(10, 20)
rect1 = Rectangle((0, 0), 10, 20)
da1.add_artist(rect1)

da2 = DrawingArea(10, 30)
rect2 = Rectangle((0, 0), 10, 30)
da2.add_artist(rect2)

align = "bottom"

pack = HPacker(children=[da1, da2], pad=10, sep=10, align=align)
title = TextArea(f"align='{align}'")
pack = VPacker(children=[title, pack], sep=10, pad=10, align="center")

box = AnchoredOffsetbox(child=pack, loc="center")

_, ax = plt.subplots()
ax.add_artist(box)
```


### Actual outcome

![download](https://user-images.githubusercontent.com/23433306/200162888-702626bf-ad47-40e2-8751-7dffe91df85c.png)


### Expected outcome

![download](https://user-images.githubusercontent.com/23433306/200162908-e0e9dfd5-6f8b-4aac-975e-bb363d809c41.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.6.2

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
The change swaps only the `top`/`bottom` handling in `_get_aligned_offsets`; `left`, `right`, `center`, and `baseline` behavior is unchanged.
`HPacker(align="bottom")` now uses the bottom-edge offsets, and `HPacker(align="top")` uses the top-edge offsets, matching the Done when.
The added tests directly cover `_get_aligned_offsets` and verify `HPacker` top/bottom edge alignment.
The check passed: 279 passed, 1 skipped.
Only in-scope files were changed.
```

### `scope.txt`

```
scope: lib/matplotlib/offsetbox.py lib/matplotlib/tests
changed: lib/matplotlib/offsetbox.py +2 -2
changed: lib/matplotlib/tests/test_offsetbox.py +38 -2
```

### `task.md`

````
# Task

## Prompt

[Bug]: `align` in `HPacker` is reversed
### Bug summary

For the `align` parameter in `HPacker`, the options `top` and `bottom` seems reversed

### Code for reproduction

```python
import matplotlib.pyplot as plt
from matplotlib.offsetbox import DrawingArea, HPacker, VPacker, AnchoredOffsetbox, TextArea
from matplotlib.patches import Rectangle

da1 = DrawingArea(10, 20)
rect1 = Rectangle((0, 0), 10, 20)
da1.add_artist(rect1)

da2 = DrawingArea(10, 30)
rect2 = Rectangle((0, 0), 10, 30)
da2.add_artist(rect2)

align = "bottom"

pack = HPacker(children=[da1, da2], pad=10, sep=10, align=align)
title = TextArea(f"align='{align}'")
pack = VPacker(children=[title, pack], sep=10, pad=10, align="center")

box = AnchoredOffsetbox(child=pack, loc="center")

_, ax = plt.subplots()
ax.add_artist(box)
```


### Actual outcome

![download](https://user-images.githubusercontent.com/23433306/200162888-702626bf-ad47-40e2-8751-7dffe91df85c.png)


### Expected outcome

![download](https://user-images.githubusercontent.com/23433306/200162908-e0e9dfd5-6f8b-4aac-975e-bb363d809c41.png)


### Additional information

_No response_

### Operating system

_No response_

### Matplotlib Version

3.6.2

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

`python -m pytest lib/matplotlib/tests/test_offsetbox.py -q`

## Scope

`lib/matplotlib/offsetbox.py`
`lib/matplotlib/tests/`

## Done when

`HPacker` with `align="bottom"` aligns child boxes by their bottom edges against the tallest child.
`HPacker` with `align="top"` aligns child boxes by their top edges against the tallest child.
(inferred) `HPacker` `center`/`baseline` behavior and `VPacker` alignment are unchanged.
````

### `test-output.log`

```
check: python -m pytest lib/matplotlib/tests/test_offsetbox.py -q
..s..................................................................... [ 25%]
........................................................................ [ 51%]
........................................................................ [ 77%]
................................................................         [100%]
279 passed, 1 skipped in 3.52s
scope: lib/matplotlib/offsetbox.py lib/matplotlib/tests
changed: lib/matplotlib/offsetbox.py +2 -2
changed: lib/matplotlib/tests/test_offsetbox.py +38 -2
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
