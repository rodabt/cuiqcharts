# vframes + cuiqcharts Integration

This document shows how to use [vframes](https://github.com/rodabt/vframes) as a data transformation layer before rendering charts with cuiqcharts. The pattern mirrors the pandas+matplotlib relationship: vframes handles loading, aggregation, and reshaping; cuiqcharts handles rendering.

## The bridge

`df.to_dict()!` materializes a vframes DataFrame as `[]map[string]json2.Any`. Two helper functions convert any column to the slice types cuiqcharts expects:

```v
import x.json2

fn col_strings(rows []map[string]json2.Any, col string) []string {
    return rows.map((it[col] or { json2.Any('') }).str())
}

fn col_f64(rows []map[string]json2.Any, col string) []f64 {
    return rows.map((it[col] or { json2.Any(0.0) }).f64())
}
```

These two functions are all you need. Everything below uses only them.

---

## Use case 1 — CSV/Parquet → grouped bar chart

```v
import vframes
import cuiqcharts

fn main() {
    mut ctx := vframes.init()!
    defer { ctx.close() }

    df := ctx.read_auto('sales.csv')!

    summary := df.group_by(['region'], {
        'total_sales': 'sum(sales)',
    })!
    sorted := summary.sort_values(['total_sales'], ascending: false)!

    rows   := sorted.to_dict()!
    labels := col_strings(rows, 'region')
    values := col_f64(rows, 'total_sales')

    mut c := cuiqcharts.bar(title: 'Revenue by Region', colors: .latimes)
    c.add_series(cuiqcharts.named_series('Sales', labels, values))
    c.save('by_region.html')!
}
```

---

## Use case 2 — Pivot table → heatmap

`pivot()` reshapes long data to wide format. Each resulting column becomes one heatmap row.

```v
// df has columns: month, product, revenue
pivoted := df.pivot(index: 'month', columns: 'product', values: 'revenue')!
rows := pivoted.to_dict()!
cols := pivoted.columns()!          // e.g. ['month', 'Laptop', 'Monitor', 'Tablet']
product_cols := cols.filter(it != 'month')
x_labels := col_strings(rows, 'month')

mut c := cuiqcharts.heatmap(
    title:  'Revenue by Month × Product'
    x_axis: cuiqcharts.AxisConfig{ name: 'Month' }
    y_axis: cuiqcharts.AxisConfig{ name: 'Product' }
)
for product in product_cols {
    c.add_series(cuiqcharts.named_series(product, x_labels, col_f64(rows, product)))
}
c.save('heatmap.html')!
```

---

## Use case 3 — Rolling window → line chart

`rolling()` returns a single-column DataFrame named `<col>_<func>` (e.g. `value_mean`). Use it alongside the original to plot both the raw series and the smoothed line.

```v
raw_df  := ctx.read_auto('metrics.csv')!
rolled  := raw_df.rolling('value', 'mean', window: 14)!

raw_rows    := raw_df.to_dict()!
smooth_rows := rolled.to_dict()!
labels      := col_strings(raw_rows, 'date')

mut c := cuiqcharts.line(title: '14-day Rolling Revenue')
c.add_series(cuiqcharts.named_series('Daily',      labels, col_f64(raw_rows,    'value')))
c.add_series(cuiqcharts.named_series('14-day avg', labels, col_f64(smooth_rows, 'value_mean')))
c.save('rolling.html')!
```

---

## Use case 4 — `pct_change()` → bar chart

```v
monthly := df.sort_values(['month'])!
changes := monthly.pct_change()!

rows   := changes.to_dict()!
labels := col_strings(rows, 'month')
pct    := col_f64(rows, 'revenue')   // first row will be 0 (no prior period)

mut c := cuiqcharts.bar(
    title:  'Month-over-Month Revenue Change (%)'
    y_axis: cuiqcharts.AxisConfig{ name: '% change' }
)
c.add_series(cuiqcharts.named_series('MoM', labels, pct))
c.save('mom.html')!
```

`cumsum()` combined with `waterfall` is equally natural for showing running cumulative impact across periods.

---

## Use case 5 — `melt()` → multi-series line chart

Long-format data (one row per observation) is the natural output of `melt()`. Loop over distinct values to build one series per group.

```v
// wide_df has columns: date, product_a, product_b, product_c
long := wide_df.melt(
    id_vars:    ['date']
    value_vars: ['product_a', 'product_b', 'product_c']
    var_name:   'product'
    value_name: 'revenue'
)!

product_rows := long.query('distinct product')!.to_dict()!

mut c := cuiqcharts.line(title: 'Revenue by Product')
for p_row in product_rows {
    product   := p_row['product']!.str()
    series_df := long.query("product = '${product}'")!.sort_values(['date'])!
    rows      := series_df.to_dict()!
    c.add_series(cuiqcharts.named_series(product,
        col_strings(rows, 'date'), col_f64(rows, 'revenue')))
}
c.save('multi_line.html')!
```

---

## Use case 6 — `group_by` + stddev → bar with error bars

```v
agg_df := df.group_by(['treatment'], {
    'mean_score': 'avg(score)',
    'std_score':  'stddev(score)',
})!

rows   := agg_df.to_dict()!
labels := col_strings(rows, 'treatment')
means  := col_f64(rows, 'mean_score')
stds   := col_f64(rows, 'std_score')

mut c := cuiqcharts.bar_errorbar(title: 'Score by Treatment (mean ± 1σ)')
c.add_series(cuiqcharts.error_series('Score', labels, means, stds, []))
c.save('errorbar.html')!
```

---

## Use case 7 — `value_counts()` → funnel or pie

```v
counts := df.subset(['stage'])!.value_counts()!
rows   := counts.to_dict()!
labels := col_strings(rows, 'stage')
values := col_f64(rows, 'count')

mut c := cuiqcharts.funnel(
    title:  'Stage Distribution'
    colors: .tableau
    labels: cuiqcharts.LabelConfig{ show: true }
)
c.add_series(cuiqcharts.named_series('Count', labels, values))
c.save('funnel.html')!
```

---

## Use case 8 — `sample()` → histogram

```v
sample_df := df.sample(frac: 0.1)!
rows      := sample_df.to_dict()!
values    := col_f64(rows, 'response_time_ms')

mut c := cuiqcharts.histogram(title: 'Latency Sample (10%)', bins: 20)
c.add_series(cuiqcharts.new_series('p95', values))
c.save('latency_hist.html')!
```

---

## Reference

| vframes operation | cuiqcharts target | bridge |
|---|---|---|
| `group_by` | bar, hbar | `col_strings` + `col_f64` → `named_series` |
| `pivot` | heatmap | loop result columns → one `named_series` per row |
| `rolling` | line | `col_f64` on `<col>_<func>` column |
| `pct_change` / `diff` | bar, waterfall | `col_f64` → `named_series` |
| `cumsum` | area, waterfall | `col_f64` → `named_series` |
| `melt` + query loop | multi-series line/bar | one series per distinct value |
| `group_by` + `stddev` | bar_errorbar, line_ci | two `col_f64` calls |
| `value_counts` | funnel, pie | `col_strings` + `col_f64` |
| `sample` + raw values | histogram, box_plot | `col_f64` → `new_series` |

## Performance note

`to_dict()` dumps the full DataFrame result into memory. Always aggregate in vframes first — keep the data chart-sized (tens to low hundreds of rows) before calling `to_dict()`. For large datasets, let DuckDB do the heavy lifting and only materialize the final summary.
