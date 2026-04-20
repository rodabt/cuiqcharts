# Chart Labels Design

**Date:** 2026-04-19
**Status:** Approved

## Overview

Add an opt-in label system to cuiqcharts that renders value labels on bars, points, slices, and cells. Labels are off by default. When enabled, each chart type applies a smart format and position; all properties can be overridden via `LabelConfig`.

## API

### New types (`types.v`)

```v
pub enum LabelPos {
    auto    // chart-type smart default
    inside  // center of bar/segment/slice/cell
    outside // above bar, right of hbar, outside pie slice
    top
    bottom
    left
    right
}

pub struct LabelConfig {
pub:
    show     bool
    size     int    = 12
    color    string // empty = auto-contrast (white when inside, theme text color when outside)
    position LabelPos = .auto
}
```

### `ChartConfig` addition (`chart.v`)

```v
labels LabelConfig
```

### Usage example

```v
cuiqcharts.funnel(
    title:  'Conversion Funnel'
    colors: .tableau
    width:  800
    height: 400
    labels: cuiqcharts.LabelConfig{ show: true }
)

// With overrides:
labels: cuiqcharts.LabelConfig{ show: true, size: 14, color: '#ffffff', position: .inside }
```

## Smart defaults per chart type

| Chart type     | Position default        | Format                                  |
|----------------|-------------------------|-----------------------------------------|
| `bar`          | outside (above bar)     | `"1,234"`                               |
| `hbar`         | outside (right of bar)  | `"1,234"`                               |
| `funnel`       | inside (segment center) | `"1,234 (85%)"` — % of stage total     |
| `pie`          | inside                  | `"45%"`                                 |
| `line`         | top (above point)       | `"1,234"`                               |
| `scatter`      | top (above point)       | `"1,234"`                               |
| `area`         | top                     | `"1,234"`                               |
| `waterfall`    | inside                  | `"1,234"`                               |
| `heatmap`      | inside (cell center)    | `"0.80"`                                |
| `histogram`    | outside (above bin)     | `"42"` (count)                          |
| `bar_errorbar` | outside (above bar)     | `"1,234"`                               |
| `rolling_mean` | top                     | `"1,234"`                               |
| `line_ci`      | top                     | `"1,234"`                               |

**Auto color rule:** white (`#ffffff`) when resolved position is `inside`; theme text color otherwise.

## Implementation

### Layered Vega-Lite specs

Vega-Lite labels require a `layer` spec. When `labels.show` is false, renderers return the current flat single-mark spec unchanged. When true, the renderer wraps both the chart mark and a `text` mark into a `layer` array.

Structure:
```json
{
  "$schema": "...",
  "title": "...",
  "width": 800,
  "height": 400,
  "data": {"values": [...]},
  "layer": [
    { /* existing chart mark + encoding */ },
    { /* text mark + encoding */ }
  ],
  "background": "...",
  "config": { ... }
}
```

### Helper function (`renderer.v`)

Each renderer calls a per-chart-type helper that returns the text layer JSON string, or `""` when labels are off. The per-chart renderers remain clean — they check `labels.show` once and either emit the flat spec or the layered version.

### Chart-type mechanics

**bar / hbar / line / scatter / area / rolling_mean / line_ci / bar_errorbar:**
Text layer uses `"field":"y"` with `format(datum.y, ',')`. Position controlled via `dx`/`dy`, `align`, and `baseline` derived from resolved `LabelPos`.

**funnel (stacked bar):**
Two extra transforms in the text layer:
1. `joinaggregate` — computes `total_y` per `x` (stage total).
2. `calculate` — builds label string: `format(datum.y, ',') + ' (' + format(datum.y / datum.total_y, '.0%') + ')'`.
3. `stack` transform + midpoint `calculate` — computes `y_mid = (y0 + y1) / 2` so text centers within each stacked segment. Sort order matches the `"o"` order field used by the bar layer.

**pie:**
Text layer uses `"theta"` encoding. Position `inside` uses a `"radius"` value at ~60% of the outer radius; `outside` uses full radius + offset.

**heatmap:**
Text layer shares `"x"/"y"` encoding from the rect mark. No stacking transforms needed.

**histogram:**
Text layer uses `"aggregate":"count"` on the binned field to display bin counts above each bar.

**waterfall:**
Text layer uses `"field":"amount"` formatted as `format(datum.amount, ',')`, centered inside each bar segment.

## Files changed

- `types.v` — add `LabelPos` enum and `LabelConfig` struct
- `chart.v` — add `labels LabelConfig` field to `ChartConfig`
- `renderer.v` — add label layer helpers; update each renderer to emit layered spec when `labels.show`
- `vcharts_test.v` — add label tests for bar, funnel, pie, heatmap
