# Statistical Charts & Overlays Design

**Date:** 2026-04-20
**Status:** Approved

## Overview

Two additions:
1. **Box plot** — implement the existing `box_plot` stub as a standalone chart type.
2. **Overlay system** — composable overlays (running average, control limits, error bars) that can be layered on top of any existing chart type via dedicated methods.

Also: change the global x-axis label angle default from `-30` to `0` (straight labels).

---

## 1. Box Plot (standalone)

Uses Vega-Lite's native `boxplot` composite mark, which computes quartiles automatically from raw values.

### API

```v
mut c := cuiqcharts.box_plot(
    title:  'Score Distribution by Group'
    colors: .vibrant
    width:  700
    height: 450
)
c.add_series(cuiqcharts.new_series('Group A', [72.0, 85.0, 91.0, 67.0, 78.0]))
c.add_series(cuiqcharts.new_series('Group B', [61.0, 88.0, 74.0, 82.0, 79.0]))
```

Each series becomes one box. Multi-series renders side-by-side boxes, colored by series name using the configured color scheme. Uses `new_series` (raw values, no labels) — the series name becomes the x-axis category.

### Data shape

Requires a dedicated `series_to_boxplot_data` serializer — each data value becomes its own row: `{"x": series_name, "y": value, "s": series_name}`. Vega-Lite's `boxplot` mark aggregates over `y` grouped by `x`. This differs from `series_to_xy_data` which zips labels with values 1:1.

### Vega-Lite spec

```json
{
  "mark": {"type": "boxplot", "extent": "min-max", "tooltip": true},
  "encoding": {
    "x": {"field": "x", "type": "nominal"},
    "y": {"field": "y", "type": "quantitative"},
    "color": {"field": "s", "type": "nominal", "scale": {...}}
  }
}
```

---

## 2. Overlay System

### New types (`types.v`)

```v
pub struct RunningAvgOverlay {
pub:
    window int       = 7
    color  string         // empty = first palette color
    label  string    = 'Rolling Avg'
    dash   DashStyle = .solid
}

pub struct ControlLimitsOverlay {
pub:
    ucl       f64
    cl        f64
    lcl       f64
    ucl_color string = '#e53935'
    cl_color  string = '#1e88e5'
    lcl_color string = '#e53935'
    ucl_label string = 'UCL'
    cl_label  string = 'CL'
    lcl_label string = 'LCL'
}

pub struct ErrorBarsOverlay {
pub:
    series_name string  // must match a series name added via add_series()
    plus        []f64
    minus       []f64   // empty = symmetric (reuses plus values)
}
```

### New `Chart` fields (`chart.v`)

```v
pub mut:
    running_avg    ?RunningAvgOverlay
    control_limits ?ControlLimitsOverlay
    error_bars     []ErrorBarsOverlay
```

### New methods (`chart.v`)

```v
pub fn (mut c Chart) set_running_avg(cfg RunningAvgOverlay)
pub fn (mut c Chart) set_control_limits(cfg ControlLimitsOverlay)
pub fn (mut c Chart) add_error_bars(cfg ErrorBarsOverlay)
```

### Usage example

```v
mut c := cuiqcharts.line(title: 'Process Control')
c.add_series(cuiqcharts.named_series('Output', labels, values))
c.set_control_limits(cuiqcharts.ControlLimitsOverlay{ ucl: 75.0, cl: 50.0, lcl: 25.0 })
c.set_running_avg(cuiqcharts.RunningAvgOverlay{ window: 7 })
c.add_error_bars(cuiqcharts.ErrorBarsOverlay{
    series_name: 'Output'
    plus: [2.1, 1.8, 2.3]
    minus: []
})
```

---

## 3. Rendering

### Flat → layer conversion

Any renderer whose chart has one or more overlays set must emit a Vega-Lite `layer` spec. The base chart mark becomes `layer[0]`; overlays append additional layers. This is the same pattern used by the label system.

A helper `chart_has_overlays(c Chart) bool` checks if any overlay is set, so renderers can branch cleanly.

Overlays are supported on all chart types that use `x`/`y` field data (bar, hbar, line, area, scatter, rolling_mean, line_ci, bar_errorbar, waterfall, funnel). Box plot, pie, histogram, and heatmap do not support overlays (their data shapes are incompatible).

### Running average overlay

```json
{
  "transform": [{"window": [{"op": "mean", "field": "y", "as": "__ravg"}], "frame": [-half, half]}],
  "mark": {"type": "line", "interpolate": "monotone", "strokeDash": [...], "color": "...", "size": 2},
  "encoding": {
    "x": {"field": "x", "type": "nominal"},
    "y": {"field": "__ravg", "type": "quantitative"}
  }
}
```

`half = window / 2`. Color defaults to `primary_color(cfg.colors)`. `DashStyle` maps to Vega-Lite `strokeDash` the same way existing dash styles work.

### Control limits overlay

Six layers total: three `rule` mark layers (UCL, CL, LCL) + three `text` mark layers for labels at the right edge.

Vega-Lite `rule` with `datum` encoding draws constant horizontal lines without needing extra data rows:

```json
{
  "mark": {"type": "rule", "color": "#e53935", "strokeDash": [6, 3]},
  "encoding": {"y": {"datum": 75.0, "type": "quantitative"}}
}
```

Label layers use `"x": {"aggregate": "max", "field": "x"}` to anchor text at the rightmost x position.

### Error bars overlay

The renderer:
1. Looks up the matched series by `series_name` in `c.series`.
2. Rebuilds the data rows for that series with added `__upper` and `__lower` fields: `upper = y + plus[i]`, `lower = y - (minus[i] if minus.len > 0 else plus[i])`.
3. Adds an `errorbar` mark layer filtered to that series.

```json
{
  "mark": {"type": "errorbar"},
  "transform": [{"filter": {"field": "s", "equal": "Output"}}],
  "encoding": {
    "x": {"field": "x", "type": "nominal"},
    "y": {"field": "__lower", "type": "quantitative"},
    "y2": {"field": "__upper"}
  }
}
```

Since the error data is embedded directly in the data rows, no separate data source is needed. The data serialization for overlay-bearing charts uses an extended row format that includes `__upper`/`__lower` for series that have error bars attached.

---

## 4. X-label angle fix

Change `"labelAngle":-30` → `"labelAngle":0` in `renderer.v`. Two occurrences:
- `render_bar` (line ~236)
- `render_bar_errorbar` (line ~434)

---

## Files changed

- `types.v` — add `RunningAvgOverlay`, `ControlLimitsOverlay`, `ErrorBarsOverlay` structs
- `chart.v` — add overlay fields to `Chart` struct; add `set_running_avg`, `set_control_limits`, `add_error_bars` methods
- `renderer.v` — implement `render_box_plot`; add overlay layer injection helpers; fix x-label angle; update `render_chart` dispatcher
- `vcharts_test.v` — tests for box plot, each overlay type, and combinations
- `examples/basic/main.v` — add examples for box plot and overlays
