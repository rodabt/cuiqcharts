// cuiqcharts - Vega-Lite chart library for V
//
// Quick start:
//   import cuiqcharts
//
//   mut c := cuiqcharts.bar(title: 'Monthly Revenue', theme: .dark)
//   c.add_series(cuiqcharts.named_series('Revenue', ['Jan', 'Feb', 'Mar'], [120.0, 145.0, 200.0]))
//   c.save('report.html')!
//
// Chart factory functions: line, bar, hbar, scatter, pie, area, histogram, heatmap
// Series constructors:     named_series, new_series, xy_series
// Dashboard:               new_dashboard → add_chart → save
module cuiqcharts
