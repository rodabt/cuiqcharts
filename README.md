# cuiqcharts

A [V](https://vlang.io) library for generating interactive charts as standalone HTML files, powered by [Vega-Lite v5](https://vega.github.io/vega-lite/). Write a few lines of V, open a browser.

```v
import cuiqcharts

mut c := cuiqcharts.bar(
    title:  'Monthly Revenue — Q4 2025'
    colors: .latimes
    y_axis: cuiqcharts.AxisConfig{ name: 'USD', format: ',.0f' }
)
c.add_series(cuiqcharts.named_series('Revenue',
    ['Oct', 'Nov', 'Dec'], [182000.0, 215000.0, 248000.0]))
c.save('revenue.html')!
```

The output is a single self-contained HTML file with the Vega-Lite runtime embedded — no server, no build step, no external dependencies at view time.

---

## Installation

```sh
v install https://github.com/rodabt/cuiqcharts
```

The first `save()` call downloads and caches the Vega-Lite, Vega, and vega-embed JavaScript libraries to `~/.cuiqviz/vega/`. Every subsequent chart loads from disk — no network required.

---

## Chart types

| Factory             | Description                                 |
| ------------------- | ------------------------------------------- |
| `bar(cfg)`          | Vertical bar, grouped when multiple series  |
| `hbar(cfg)`         | Horizontal bar, sorted by value             |
| `line(cfg)`         | Line chart with optional point markers      |
| `area(cfg)`         | Filled area chart, stackable                |
| `scatter(cfg)`      | X/Y scatter plot                            |
| `pie(cfg)`          | Pie / donut chart                           |
| `histogram(cfg)`    | Auto-binned frequency histogram             |
| `heatmap(cfg)`      | Grid heatmap with sequential color scale    |
| `bar_errorbar(cfg)` | Bar chart with asymmetric error bars        |
| `line_ci(cfg)`      | Line chart with confidence interval band    |
| `rolling_mean(cfg)` | Raw points + configurable rolling average   |
| `waterfall(cfg)`    | Running-total bridge chart (P&L, cash flow) |
| `funnel(cfg)`       | Stacked conversion funnel                   |
| `box_plot(cfg)`     | Box-and-whisker with min–max whiskers       |

---

## Quick examples

### Grouped bar
```v
mut c := cuiqcharts.bar(title: 'Revenue vs Budget', colors: .latimes)
c.add_series(cuiqcharts.named_series('Revenue', ['APAC','EMEA','LATAM'], [340.0, 410.0, 195.0]))
c.add_series(cuiqcharts.named_series('Budget',  ['APAC','EMEA','LATAM'], [300.0, 380.0, 220.0]))
c.save('grouped.html')!
```

### Scatter with regression, zoom, and reference line
```v
mut c := cuiqcharts.scatter(
    title:       'Price Elasticity of Demand'
    colors:      .colorblind
    zoom:        true
    trend_line:  true
    trend_color: 'rgba(170,30,30,0.7)'
    x_axis:      cuiqcharts.AxisConfig{ name: 'Retail Price (USD)' }
    y_axis:      cuiqcharts.AxisConfig{ name: 'Units Sold (thousands)' }
    ref_lines:   [
        cuiqcharts.RefLine{ 
            axis: 'y', 
            value: 50.0, 
            label: 'Volume floor', 
            color: '#388e3c', 
            dash: .dashed }
    ]
)
c.add_series(cuiqcharts.xy_series('Smartphones', [[199.0,142.0],[299.0,116.0],[499.0,63.0]]))
c.save('scatter.html')!
```

### Line with direct end-of-line labels
```v
mut c := cuiqcharts.line(
    title:         'KPIs — FY 2025'
    colors:        .default_scheme
    direct_labels: true
)
c.add_series(cuiqcharts.named_series('Revenue', ['Q1','Q2','Q3','Q4'], [100.0,120.0,115.0,140.0]))
c.add_series(cuiqcharts.named_series('COGS',    ['Q1','Q2','Q3','Q4'], [60.0, 68.0, 65.0, 80.0]))
c.save('kpis.html')!
```

### SPC control chart
```v
mut c := cuiqcharts.line(title: 'Part Thickness — X̄ Chart', colors: .default_scheme)
c.add_series(cuiqcharts.named_series('X-bar', samples, measurements))
c.set_control_limits(cuiqcharts.ControlLimitsOverlay{
    ucl: 10.45  cl: 10.00  lcl: 9.55
    ucl_label: 'UCL = 10.45'  cl_label: 'CL = 10.00'  lcl_label: 'LCL = 9.55'
})
c.save('spc.html')!
```

### Dashboard
```v
mut d := cuiqcharts.new_dashboard('Q4 2025 Overview')
d.columns = 2
d.add_chart(revenue_chart, 1)
d.add_chart(scatter_chart, 1)
d.add_chart(waterfall_chart, 2)  // span both columns
d.save('dashboard.html')!
```

---

## Configuration

All chart factories accept a `ChartConfig` struct using named-field syntax:

```v
cuiqcharts.bar(
    title:    string           // chart title
    subtitle: string           // subtitle, rendered below the title
    theme:    .light | .dark | .sepia
    colors:   ColorScheme      // see below
    width:    int              // pixels (default 800)
    height:   int              // pixels (default 400)
    legend:   .top | .bottom | .left | .right | .none
    zoom:     bool             // drag to pan, scroll to zoom, double-click to reset
    x_axis:   AxisConfig
    y_axis:   AxisConfig
    labels:   LabelConfig      // show value labels on marks
    ref_lines:    []RefLine    // horizontal or vertical reference rules
    annotations:  []Annotation // text labels at fixed data coordinates
    trend_line:   bool         // OLS regression overlay
    trend_color:  string       // any CSS color
    direct_labels: bool        // end-of-line labels instead of legend (line, area)
)
```

### Color schemes

| Scheme            | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| `.latimes`        | LA Times data-viz style — warm oranges and blues (default) |
| `.default_scheme` | Paul Tol "Bright" — perceptually distinct, print-safe      |
| `.colorblind`     | Okabe-Ito 8-color — Nature Methods recommended             |
| `.vibrant`        | Paul Tol "Vibrant" — high contrast for lines and scatter   |
| `.pastel`         | Paul Tol "Muted" — lower saturation for filled areas       |
| `.dark_scheme`    | Paul Tol "Dark" — high contrast on dark backgrounds        |
| `.tableau`        | Tableau 10 (capped at 7) — industry standard               |
| `.material`       | ColorBrewer Set1 adapted — strong categorical hues         |

### Axis configuration

```v
cuiqcharts.AxisConfig{
    name:   'Revenue (USD)'   // axis title
    format: ',.0f'            // D3 format string
}
```

Common D3 format strings: `',.0f'` (thousands separator), `'.1%'` (percentage), `'.2s'` (SI prefix like 1.2M), `'$,.2f'` (currency).

### Reference lines and annotations

```v
// Horizontal rule at y = 200_000 with a label
ref_lines: [cuiqcharts.RefLine{
    axis:  'y'
    value: 200_000.0
    label: 'Annual target'
    color: '#e53935'
    dash:  .dashed   // .solid | .dashed | .dotted
}]

// Text label anchored to data coordinates (scatter / quantitative axes)
annotations: [cuiqcharts.Annotation{
    x:    1599.0
    y:    14.0
    text: 'Flagship model'
    color: '#555555'
    size:  11
}]
```

### Overlays

```v
// Rolling / running average
c.set_running_avg(cuiqcharts.RunningAvgOverlay{ window: 7, color: '#e15759', dash: .dashed })

// Asymmetric error bars on a named series
c.add_error_bars(cuiqcharts.ErrorBarsOverlay{
    series_name: 'Activity'
    plus:  [1.8, 2.4, 3.1]
    minus: [1.5, 2.1, 2.8]   // omit for symmetric
})

// Statistical process control limits
c.set_control_limits(cuiqcharts.ControlLimitsOverlay{
    ucl: 10.45  cl: 10.00  lcl: 9.55
})
```

---

## Series constructors

```v
// Named series — category labels + values (bar, line, area, heatmap, …)
cuiqcharts.named_series(name string, labels []string, data []f64) Series

// X/Y pairs (scatter)
cuiqcharts.xy_series(name string, xy [][]f64) Series

// Numeric values only (histogram, box_plot)
cuiqcharts.new_series(name string, data []f64) Series

// Values with error bounds (bar_errorbar, line_ci)
cuiqcharts.error_series(name string, labels []string,
    data []f64, error_plus []f64, error_minus []f64) Series
```

---

## Running the examples

```sh
make example-basic      # generates ~18 HTML charts in the current directory
make example-dashboard  # generates a multi-chart dashboard HTML
```

A full annotated walkthrough of every feature is in [TUTORIAL.md](TUTORIAL.md).

---

## Output

`chart.save(path)` writes a single HTML file. You can also get the pieces directly:

```v
spec_json := c.to_json()   // Vega-Lite JSON spec (for embedding in your own page)
html       := c.to_html()  // complete standalone HTML string
```

---

## License

MIT — see [LICENSE](LICENSE).
