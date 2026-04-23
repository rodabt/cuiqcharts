# cuiqcharts Tutorial

cuiqcharts generates interactive Vega-Lite charts as standalone HTML files. A chart is built in three steps: create it with a factory function, add data series, then save or render it.

## Quickstart

```v
import cuiqcharts

fn main() {
    mut c := cuiqcharts.bar(title: 'Monthly Revenue')
    c.add_series(cuiqcharts.named_series('Revenue',
        ['Jan', 'Feb', 'Mar'],
        [120.0, 145.0, 200.0]))
    c.save('revenue.html')!
}
```

Open `revenue.html` in any browser. The chart is fully self-contained — no server required.

---

## Core concepts

### Factory functions

Every chart starts with a factory function that accepts a `ChartConfig`:

```v
cuiqcharts.bar(...)
cuiqcharts.line(...)
cuiqcharts.hbar(...)
cuiqcharts.scatter(...)
cuiqcharts.pie(...)
cuiqcharts.area(...)
cuiqcharts.histogram(...)
cuiqcharts.heatmap(...)
cuiqcharts.bar_errorbar(...)
cuiqcharts.line_ci(...)
cuiqcharts.rolling_mean(...)
cuiqcharts.waterfall(...)
cuiqcharts.funnel(...)
cuiqcharts.box_plot(...)
```

`ChartConfig` is a `@[params]` struct, so all fields are optional and named:

```v
mut c := cuiqcharts.line(
    title:  'Sales Trend'
    width:  900
    height: 400
    theme:  .dark
    colors: .tableau
)
```

### Series constructors

| Constructor | Use for |
|---|---|
| `named_series(name, labels, data)` | bar, line, area, hbar, pie, heatmap |
| `new_series(name, data)` | histogram, box_plot (raw values, no labels) |
| `xy_series(name, xy)` | scatter |
| `bubble_series(name, xy, sizes)` | bubble |
| `error_series(name, labels, data, plus, minus)` | bar_errorbar, line_ci |

### Output

```v
c.save('chart.html')!   // write standalone HTML file
html := c.to_html()     // get HTML as string
json := c.to_json()     // get raw Vega-Lite spec JSON
```

`save` attempts to cache the Vega/Vega-Lite/vegaEmbed scripts locally in `~/.cuiqviz/vega/` for offline use, then falls back to CDN.

---

## Chart types

### Bar chart

Vertical bars. Use `named_series`.

```v
mut c := cuiqcharts.bar(
    title:  'Q1 Revenue by Region'
    colors: .latimes
    x_axis: cuiqcharts.AxisConfig{ name: 'Region' }
    y_axis: cuiqcharts.AxisConfig{ name: 'USD thousands' }
)
c.add_series(cuiqcharts.named_series('Revenue',
    ['North', 'South', 'East', 'West'],
    [340.0, 280.0, 410.0, 195.0]))
c.save('bar.html')!
```

Multiple series creates a grouped bar chart:

```v
c.add_series(cuiqcharts.named_series('Budget',
    ['North', 'South', 'East', 'West'],
    [300.0, 300.0, 380.0, 220.0]))
```

### Horizontal bar chart

Same API as bar, but bars are horizontal. Preferred over pie for comparisons (length perception is more accurate than angle).

```v
mut c := cuiqcharts.hbar(
    title:  'Market Share'
    x_axis: cuiqcharts.AxisConfig{ name: 'Share (%)' }
    y_axis: cuiqcharts.AxisConfig{ name: 'Product' }
)
c.add_series(cuiqcharts.named_series('Share',
    ['Product A', 'Product B', 'Product C'],
    [45.0, 30.0, 25.0]))
c.save('hbar.html')!
```

### Line chart

```v
mut c := cuiqcharts.line(
    title:  'Sales vs Costs'
    x_axis: cuiqcharts.AxisConfig{ name: 'Quarter' }
    y_axis: cuiqcharts.AxisConfig{ name: 'USD thousands' }
)
c.add_series(cuiqcharts.named_series('Sales',
    ['Q1', 'Q2', 'Q3', 'Q4'], [100.0, 120.0, 115.0, 140.0]))
c.add_series(cuiqcharts.named_series('Costs',
    ['Q1', 'Q2', 'Q3', 'Q4'], [80.0, 90.0, 85.0, 95.0]))
c.save('line.html')!
```

Enable a least-squares trend line with `trend_line: true`.

### Area chart

Like line but filled. Good for cumulative values.

```v
mut c := cuiqcharts.area(
    title: 'Cumulative Users'
    y_axis: cuiqcharts.AxisConfig{ name: 'Total Users' }
)
c.add_series(cuiqcharts.named_series('Users',
    ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
    [1000.0, 1500.0, 2200.0, 3100.0, 4500.0]))
c.save('area.html')!
```

### Scatter chart

Pass XY coordinate pairs.

```v
mut c := cuiqcharts.scatter(
    title:  'Height vs Weight'
    colors: .colorblind
    x_axis: cuiqcharts.AxisConfig{ name: 'Height (cm)' }
    y_axis: cuiqcharts.AxisConfig{ name: 'Weight (kg)' }
)
c.add_series(cuiqcharts.xy_series('Group A', [
    [160.0, 55.0], [165.0, 60.0], [170.0, 65.0],
]))
c.add_series(cuiqcharts.xy_series('Group B', [
    [155.0, 50.0], [162.0, 58.0], [168.0, 63.0],
]))
c.save('scatter.html')!
```

### Pie chart

```v
mut c := cuiqcharts.pie(title: 'OS Market Share', colors: .pastel)
c.add_series(cuiqcharts.named_series('Share',
    ['Windows', 'macOS', 'Linux', 'Other'],
    [72.0, 15.0, 4.0, 9.0]))
c.save('pie.html')!
```

### Histogram

Pass raw numeric values; the library bins them automatically. Control bin count with `bins`:

```v
mut c := cuiqcharts.histogram(
    title: 'Score Distribution'
    bins:  15
    x_axis: cuiqcharts.AxisConfig{ name: 'Score' }
    y_axis: cuiqcharts.AxisConfig{ name: 'Count' }
)
c.add_series(cuiqcharts.new_series('Scores', [
    72.0, 85.0, 91.0, 67.0, 78.0, 84.0, 76.0, 93.0,
    61.0, 88.0, 74.0, 82.0, 79.0, 95.0, 70.0,
]))
c.save('histogram.html')!
```

### Heatmap

Each call to `add_series` defines one row. The series `name` becomes the Y label; `labels` are the X labels; `data` are the cell values.

```v
mut c := cuiqcharts.heatmap(
    title:  'Activity by Day and Hour'
    x_axis: cuiqcharts.AxisConfig{ name: 'Hour' }
    y_axis: cuiqcharts.AxisConfig{ name: 'Day' }
)
for day, values in {'Mon': [0.3, 0.8, 0.6], 'Tue': [0.5, 0.9, 0.7]} {
    c.add_series(cuiqcharts.named_series(day, ['9am', '12pm', '3pm'], values))
}
c.save('heatmap.html')!
```

### Bar with error bars

Use `error_series`. Pass `[]` for `minus` to use symmetric errors.

```v
mut c := cuiqcharts.bar_errorbar(
    title: 'Crop Yield by Variety (95% CI)'
    y_axis: cuiqcharts.AxisConfig{ name: 'Yield (bushels/acre)' }
)
c.add_series(cuiqcharts.error_series(
    'Yield',
    ['Variety A', 'Variety B', 'Variety C'],
    [33.9, 30.4, 38.9],  // means
    [3.8, 2.9, 4.7],     // upper error
    [],                   // empty = symmetric
))
c.save('errorbar.html')!
```

### Line with confidence band

```v
mut c := cuiqcharts.line_ci(
    title: 'Fuel Efficiency Over Time'
    y_axis: cuiqcharts.AxisConfig{ name: 'MPG' }
)
c.add_series(cuiqcharts.error_series(
    'Mean MPG',
    ['1978', '1979', '1980', '1981', '1982'],
    [24.4, 25.9, 33.7, 30.3, 31.7],
    [2.8, 2.4, 3.1, 2.6, 2.9],
    [],
))
c.save('line_ci.html')!
```

### Rolling mean chart

Renders the raw series as faint dots and overlays a rolling average line. Set `rolling_window` to control the window.

```v
mut c := cuiqcharts.rolling_mean(
    title:          'Daily Temperature'
    rolling_window: 7
    y_axis: cuiqcharts.AxisConfig{ name: 'Temperature (°C)' }
)
c.add_series(cuiqcharts.named_series('Temp',
    ['1','2','3','4','5','6','7','8','9','10'],
    [12.0, 14.0, 11.0, 16.0, 18.0, 15.0, 13.0, 17.0, 20.0, 19.0]))
c.save('rolling_mean.html')!
```

### Waterfall chart

The first label `'Begin'` anchors to zero and carries the opening balance. The last label `'End'` with amount `0.0` displays the cumulative total.

```v
mut c := cuiqcharts.waterfall(
    title:  'Annual P&L'
    y_axis: cuiqcharts.AxisConfig{ name: 'USD thousands' }
)
c.add_series(cuiqcharts.named_series('',
    ['Begin', 'Q1', 'Q2', 'Q3', 'Q4', 'End'],
    [500.0, 120.0, -40.0, 80.0, 150.0, 0.0]))
c.save('waterfall.html')!
```

### Funnel chart

Each series is a segment group (e.g. converted vs. dropped). Labels are the funnel stages.

```v
stages := ['Awareness', 'Interest', 'Consideration', 'Purchase']
mut c := cuiqcharts.funnel(
    title:  'Conversion Funnel'
    labels: cuiqcharts.LabelConfig{ show: true }
    colors: .tableau
)
c.add_series(cuiqcharts.named_series('Converted', stages, [8500.0, 6200.0, 4100.0, 1900.0]))
c.add_series(cuiqcharts.named_series('Drop-off',  stages, [1500.0, 2100.0, 2100.0, 2200.0]))
c.save('funnel.html')!
```

### Box plot

Pass raw values via `new_series`. Each series becomes one box.

```v
mut c := cuiqcharts.box_plot(
    title:  'Response by Treatment'
    colors: .colorblind
)
c.add_series(cuiqcharts.new_series('Placebo',   [22.0, 18.0, 25.0, 20.0, 23.0]))
c.add_series(cuiqcharts.new_series('Treatment', [44.0, 48.0, 41.0, 52.0, 46.0]))
c.save('box_plot.html')!
```

---

## Axis configuration

```v
cuiqcharts.AxisConfig{
    name:      'Revenue (USD)'   // axis label
    axis_type: .log_scale        // .value | .category | .log_scale | .time
    has_min:   true
    min:       0.0               // force axis to start at 0
    has_max:   true
    max:       1000.0
    format:    '.2f'             // number format string
    rotate:    45                // label rotation in degrees
}
```

Use `y2_axis` in `ChartConfig` to add a secondary Y axis, then set `y_axis_index: 1` on the series you want plotted against it.

---

## Themes and color schemes

### Themes

```v
theme: .light   // default — white background
theme: .dark    // dark background
theme: .sepia   // warm paper background
```

### Color schemes

```v
colors: .latimes      // LA Times palette (default)
colors: .default_scheme
colors: .pastel
colors: .dark_scheme
colors: .vibrant
colors: .colorblind   // Okabe-Ito 8-color accessible palette
colors: .material     // Material Design
colors: .tableau      // Tableau 10
```

---

## Overlays

Overlays are attached to an existing chart after creation.

### Rolling average overlay

Adds a smoothed line on top of any line or area chart without changing the chart type:

```v
c.set_running_avg(cuiqcharts.RunningAvgOverlay{
    window: 7
    label:  '7-day avg'
    color:  '#e15759'
    dash:   .dashed
})
```

### Statistical process control limits

```v
c.set_control_limits(cuiqcharts.ControlLimitsOverlay{
    ucl: 10.45  cl: 10.00  lcl: 9.55
    ucl_label: 'UCL = 10.45'
    cl_label:  'CL = 10.00'
    lcl_label: 'LCL = 9.55'
})
```

### Asymmetric error bars overlay

Attach to a named series on a line chart:

```v
c.add_error_bars(cuiqcharts.ErrorBarsOverlay{
    series_name: 'Activity'
    plus:        [1.8, 2.4, 3.1, 3.8]
    minus:       [1.5, 2.1, 2.8, 3.4]  // empty = symmetric
})
```

### Reference lines and annotations

```v
mut c := cuiqcharts.line(
    title:     'SLA Compliance'
    ref_lines: [
        cuiqcharts.RefLine{ axis: 'y', value: 200.0, label: 'SLA limit', color: '#e53935' },
    ]
    annotations: [
        cuiqcharts.Annotation{ x: 5.0, y: 210.0, text: 'Incident', color: '#e53935' },
    ]
)
```

---

## Data labels

Show value labels directly on bars, slices, or points:

```v
mut c := cuiqcharts.bar(
    title:  'Revenue'
    labels: cuiqcharts.LabelConfig{
        show:     true
        size:     11
        position: .outside  // .auto | .inside | .outside | .top | .bottom
    }
)
```

---

## Per-series styling

Override color, line style, and marker per series:

```v
c.add_series(cuiqcharts.Series{
    name:        'Forecast'
    labels:      ['Q1', 'Q2', 'Q3', 'Q4']
    data:        [110.0, 125.0, 120.0, 145.0]
    color:       '#9467bd'
    dash_style:  .dashed
    marker:      .diamond
    marker_size: 8
    opacity:     0.8
})
```

---

## Dashboard

Arrange multiple charts in a responsive grid:

```v
mut dash := cuiqcharts.new_dashboard('Q1 2026 Summary')
dash.subtitle = 'Internal metrics'
dash.columns  = 2
dash.gap_px   = 24

mut bar_chart := cuiqcharts.bar(title: 'Revenue', width: 600, height: 350)
bar_chart.add_series(cuiqcharts.named_series('Rev', ['Jan', 'Feb', 'Mar'], [120.0, 145.0, 200.0]))
dash.add_chart(bar_chart, 1)   // span=1: occupy one column

mut wide_chart := cuiqcharts.line(title: 'Traffic', width: 1200, height: 350)
wide_chart.add_series(cuiqcharts.named_series('Sessions', ['Jan', 'Feb', 'Mar'], [4000.0, 5200.0, 4800.0]))
dash.add_chart(wide_chart, 2)  // span=2: stretch across both columns

dash.save('dashboard.html')!
```

---

## Complete example: SPC control chart

This combines a line chart, control limits, and axis labels for a statistical process control scenario.

```v
import cuiqcharts

fn main() {
    mut c := cuiqcharts.line(
        title:    'Part Thickness — Injection Moulding'
        subtitle: 'X-bar chart | UCL=10.45 | CL=10.00 | LCL=9.55'
        colors:   .default_scheme
        width:    1000
        height:   450
        x_axis:   cuiqcharts.AxisConfig{ name: 'Sample #' }
        y_axis:   cuiqcharts.AxisConfig{ name: 'Thickness (mm)', has_min: true, min: 9.0 }
    )

    samples := ['1','2','3','4','5','6','7','8','9','10']
    values  := [9.98, 10.12, 9.87, 10.05, 9.93, 10.21, 9.76, 10.41, 9.97, 10.43]

    c.add_series(cuiqcharts.named_series('X-bar', samples, values))
    c.set_control_limits(cuiqcharts.ControlLimitsOverlay{
        ucl: 10.45  cl: 10.00  lcl: 9.55
    })
    c.save('spc.html')!
}
```

---

## Complete example: multi-panel dashboard

```v
import cuiqcharts

fn main() {
    mut dash := cuiqcharts.new_dashboard('Operations Dashboard')
    dash.columns = 2

    // Revenue bar
    mut rev := cuiqcharts.bar(title: 'Monthly Revenue', width: 600, height: 300, colors: .latimes)
    rev.add_series(cuiqcharts.named_series('Revenue',
        ['Jan', 'Feb', 'Mar', 'Apr'], [320.0, 410.0, 390.0, 480.0]))
    dash.add_chart(rev, 1)

    // Trend line
    mut trend := cuiqcharts.line(title: 'Sessions', width: 600, height: 300, trend_line: true)
    trend.add_series(cuiqcharts.named_series('Daily',
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], [4200.0, 5100.0, 4800.0, 5400.0, 6100.0]))
    dash.add_chart(trend, 1)

    // Wide histogram spanning both columns
    mut hist := cuiqcharts.histogram(title: 'Latency Distribution (ms)', width: 1200, height: 280)
    hist.add_series(cuiqcharts.new_series('p95', [
        42.0, 38.0, 55.0, 61.0, 48.0, 72.0, 38.0, 45.0, 53.0, 68.0,
        41.0, 49.0, 58.0, 39.0, 44.0, 62.0, 51.0, 47.0, 57.0, 43.0,
    ]))
    dash.add_chart(hist, 2)

    dash.save('ops_dashboard.html')!
    println('Saved ops_dashboard.html')
}
```
