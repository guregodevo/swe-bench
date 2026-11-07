# Survey: wrong legend values for large ranges (ScalarFormatter offset dropped)

Paths named or shown by the issue first, then the sibling code paths that format legend/tick values the same way.

- `seaborn/_core/scales.py:ContinuousBase._setup` — builds the legend entries for a continuous semantic scale by calling `axis.major.formatter.format_ticks(locs)` and storing only the returned label strings, so the `ScalarFormatter` offset (e.g. `1e6`) is never captured or shown in the legend (the exact lines the issue points at, 377-382).
- `seaborn/_core/scales.py:Continuous._get_formatter` — creates the default `ScalarFormatter()` used for continuous scales when no `like`/`base`/`unit` formatter is given, which is the formatter whose offset is dropped by `_setup`.
- `seaborn/_core/scales.py:Scale._get_scale` — installs that formatter on the internal matplotlib scale via `axis.set_major_formatter(major_formatter)`, so the same formatter instance is used for both axis ticks and legend labels.
- `seaborn/_core/scales.py:PseudoAxis.set_major_formatter` — attaches the formatter to the pseudo-axis used for non-coordinate (color/size/etc.) scales, giving the formatter the axis/view interval it needs to compute an offset.
- `seaborn/_core/scales.py:PseudoAxis.get_view_interval` — supplies the view interval that `ScalarFormatter` uses to decide whether to apply an offset, which is why the issue notes the behaviour depends on `axes.formatter.useoffset` / `offset_threshold`.
- `seaborn/_core/plot.py:Plot.plot` — public entry point for the `so.Plot(...).add(so.Dot())` example; compiles the spec and triggers legend construction.
- `seaborn/_core/plot.py:Plotter._plot` — orchestration that calls `_setup_scales` (where `ContinuousBase._setup` builds `_legend`) and then `_make_legend`.
- `seaborn/_core/plot.py:Plotter._setup_scales` — calls `scale._setup(...)` for each variable, including the `pointsize`/`color` semantic scales whose `_legend` labels are wrong.
- `seaborn/_core/plot.py:Plotter._update_legend_contents` — reads `scales[var]._legend` and passes its already-formatted labels straight to the legend, so the missing offset propagates to the rendered legend.
- `seaborn/_core/plot.py:Plotter._make_legend` — builds the matplotlib `Legend` with those labels and the variable name as title, with no place to put a formatter offset.
- `seaborn/_core/properties.py:Property.default_scale` — infers `Continuous()` for numeric variables such as `body_mass_mg`, selecting the `ScalarFormatter` path that loses the offset.
- `seaborn/_core/properties.py:Color.infer_scale` — returns `Continuous(...)` for numeric color mappings, another route into the same `ContinuousBase._setup` legend formatting.
- `seaborn/_marks/dot.py:DotBase._legend_artist` — creates the legend handle for each value; it receives only the value, not the formatter offset, so it cannot compensate for the missing offset.
- `seaborn/_marks/base.py:Mark._legend_artist` — base no-op legend-artist hook used by marks that do not draw legend entries, part of the same legend pipeline.

## Siblings: the older relational interface doing the same formatting

- `seaborn/utils.py:locator_to_legend_entries` — the older-interface equivalent of the `_setup` legend formatting: builds a `ScalarFormatter` (or `LogFormatter`), calls `set_locs`/`formatter(x)`, and returns only the label strings, dropping the offset in exactly the same way.
- `seaborn/relational.py:_RelationalPlotter.add_legend_data` — uses `locator_to_legend_entries` for brief numeric `hue` and `size` legends, so `scatterplot`/`lineplot` legends show the same offset-less values.
- `seaborn/relational.py:_ScatterPlotter.plot` — the `scatterplot` drawing path that calls `add_legend_data` and then `ax.legend(title=self.legend_title)`, reproducing the issue via `scatterplot`.
- `seaborn/relational.py:_LinePlotter.plot` — the `lineplot` sibling that calls the same `add_legend_data` legend construction.
- `seaborn/relational.py:scatterplot` — public API named in the issue as a second reproduction; wires data into `_ScatterPlotter` and its legend path.
- `seaborn/relational.py:lineplot` — public sibling API sharing `_RelationalPlotter.add_legend_data`.
- `seaborn/relational.py:relplot` — figure-level wrapper that dispatches to `scatterplot`/`lineplot`, inheriting the same legend formatting.

## Siblings: categorical and old-core legend/label formatting

- `seaborn/categorical.py:_CategoricalPlotterNew.plot_strips` — calls `add_legend_data` and `ax.legend(title=self.legend_title)` for strip plots, the categorical counterpart of the same legend construction.
- `seaborn/categorical.py:_CategoricalPlotterNew.plot_swarms` — swarm-plot sibling with the identical `add_legend_data`/`ax.legend` sequence.
- `seaborn/categorical.py:_CategoricalPlotter.add_legend_data` — older categorical plotter's dummy-patch legend builder, a parallel legend path that also carries only preformatted labels.
- `seaborn/_oldcore.py:VectorPlotter.scale_categorical` — applies a user `formatter` callable to categorical values before plotting/legend creation, the old-core label-formatting sibling of the scale formatter path.
