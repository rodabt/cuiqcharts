module cuiqcharts

import os

fn test_bar_chart_json() {
	mut c := bar(title: 'Test Bar')
	c.add_series(named_series('Data', ['A', 'B', 'C'], [10.0, 20.0, 30.0]))
	json := c.to_json()
	assert json.contains('"type":"bar"'), 'bar mark type missing'
	assert json.contains('"A"'), 'category A missing'
	assert json.contains('Test Bar'), 'title missing'
	assert json.contains('vega.github.io/schema/vega-lite'), 'vega-lite schema missing'
}

fn test_multi_series_bar_json() {
	mut c := bar(title: 'Multi Bar')
	c.add_series(named_series('Revenue', ['Q1', 'Q2', 'Q3'], [100.0, 120.0, 140.0]))
	c.add_series(named_series('Costs', ['Q1', 'Q2', 'Q3'], [80.0, 90.0, 95.0]))
	json := c.to_json()
	assert json.contains('Revenue'), 'Revenue series missing'
	assert json.contains('Costs'), 'Costs series missing'
}

fn test_hbar_chart_json() {
	mut c := hbar(title: 'Test HBar')
	c.add_series(named_series('Sales', ['Eng', 'Sales', 'Mktg'], [450.0, 280.0, 190.0]))
	json := c.to_json()
	assert json.contains('"type":"bar"'), 'bar mark type missing'
	assert json.contains('vega.github.io/schema/vega-lite'), 'vega-lite schema missing'
	// hbar swaps x/y: the y encoding should use field x (category)
	assert json.contains('"y":{'), 'y encoding missing'
}

fn test_line_chart_json() {
	mut c := line(title: 'Test Line')
	c.add_series(named_series('Trend', ['Jan', 'Feb', 'Mar'], [100.0, 120.0, 90.0]))
	json := c.to_json()
	assert json.contains('"type":"line"'), 'line mark type missing'
}

fn test_multi_series_line_json() {
	mut c := line(title: 'Trends')
	c.add_series(named_series('Sales', ['Q1', 'Q2'], [100.0, 120.0]))
	c.add_series(named_series('Costs', ['Q1', 'Q2'], [80.0, 90.0]))
	json := c.to_json()
	assert json.contains('Sales'), 'Sales series missing'
	assert json.contains('Costs'), 'Costs series missing'
}

fn test_area_chart_json() {
	mut c := area(title: 'Test Area')
	c.add_series(named_series('Growth', ['Jan', 'Feb', 'Mar'], [50.0, 80.0, 110.0]))
	json := c.to_json()
	assert json.contains('"type":"area"'), 'area mark type missing'
}

fn test_pie_chart_json() {
	mut c := pie(title: 'Test Pie')
	c.add_series(named_series('Share', ['A', 'B', 'C'], [45.0, 30.0, 25.0]))
	json := c.to_json()
	assert json.contains('"type":"arc"'), 'arc mark type missing for pie'
	assert json.contains('"theta"'), 'theta encoding missing'
	assert json.contains('"A"'), 'label A missing'
}

fn test_scatter_chart_json() {
	mut c := scatter(title: 'Test Scatter')
	c.add_series(xy_series('Points', [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]))
	json := c.to_json()
	assert json.contains('"type":"point"'), 'point mark type missing'
	assert json.contains('1.0'), 'x value missing'
	assert json.contains('2.0'), 'y value missing'
}

fn test_histogram_json() {
	mut c := histogram(title: 'Test Histogram')
	c.add_series(new_series('Values', [1.0, 2.0, 3.0, 2.5, 1.5, 3.5, 4.0, 2.0, 1.0, 2.2]))
	json := c.to_json()
	assert json.contains('"type":"bar"'), 'bar mark type missing for histogram'
	assert json.contains('"bin"'), 'bin transform missing'
	assert json.contains('Count'), 'Count label missing'
}

fn test_heatmap_json() {
	mut c := heatmap(title: 'Test Heatmap')
	c.add_series(named_series('Row A', ['X', 'Y', 'Z'], [1.0, 2.0, 3.0]))
	c.add_series(named_series('Row B', ['X', 'Y', 'Z'], [4.0, 5.0, 6.0]))
	json := c.to_json()
	assert json.contains('"type":"rect"'), 'rect mark type missing for heatmap'
	assert json.contains('"v"'), 'value field missing'
}

fn test_themes() {
	mut c := bar(title: 'Dark', theme: .dark)
	c.add_series(named_series('D', ['A'], [1.0]))
	html := c.to_html()
	assert html.contains('#1e1e1e'), 'dark bg missing'

	mut c2 := bar(title: 'Sepia', theme: .sepia)
	c2.add_series(named_series('D', ['A'], [1.0]))
	html2 := c2.to_html()
	assert html2.contains('#f4eee8'), 'sepia bg missing'
}

fn test_color_schemes() {
	mut c := bar(title: 'Vibrant', colors: .vibrant)
	c.add_series(named_series('D', ['A'], [1.0]))
	json := c.to_json()
	assert json.contains('#0077BB'), 'vibrant color missing'
}

fn test_colorblind_palette() {
	mut c := bar(title: 'Colorblind', colors: .colorblind)
	c.add_series(named_series('D', ['A'], [1.0]))
	json := c.to_json()
	assert json.contains('#E69F00'), 'Okabe-Ito color missing'
}

fn test_tableau_palette() {
	mut c := line(title: 'Tableau', colors: .tableau)
	c.add_series(named_series('D', ['A'], [1.0]))
	json := c.to_json()
	assert json.contains('#4E79A7'), 'Tableau color missing'
}

fn test_to_html_structure() {
	mut c := bar(title: 'HTML Test', subtitle: 'Subtitle here')
	c.add_series(named_series('Data', ['X', 'Y'], [10.0, 20.0]))
	html := c.to_html()
	assert html.contains('<!DOCTYPE html>'), 'DOCTYPE missing'
	assert html.contains('vegaEmbed'), 'vegaEmbed call missing'
	assert html.contains('vega-embed'), 'vega-embed CDN missing'
	assert html.contains('HTML Test'), 'title missing'
	assert html.contains('Subtitle here'), 'subtitle missing'
	assert !html.contains('src="echarts'), 'echarts CDN reference must not be present'
}

fn test_empty_series_returns_empty_json() {
	c := bar(title: 'Empty')
	json := c.to_json()
	assert json == '{}', 'empty chart should return {}'
}

fn test_per_series_color() {
	mut c := bar(title: 'Custom Color')
	c.add_series(Series{
		name:   'Red Data'
		labels: ['A', 'B']
		data:   [10.0, 20.0]
		color:  '#FF0000'
	})
	json := c.to_json()
	assert json.contains('#FF0000'), 'custom series color missing'
}

fn test_vega_lite_schema() {
	mut c := line(title: 'Schema Check')
	c.add_series(named_series('D', ['A'], [1.0]))
	json := c.to_json()
	assert json.contains('vega.github.io/schema/vega-lite/v5.json'), 'vega-lite v5 schema missing'
}

fn test_csv_input() {
	csv_path := '/tmp/cuiqcharts_test.csv'
	os.write_file(csv_path, 'month,revenue,costs\nJan,120,80\nFeb,145,90\nMar,200,110\n') or { assert false, 'write failed'; return }
	series_list := series_from_csv(csv_path) or { assert false, 'CSV parse failed: ${err}'; return }
	assert series_list.len == 2, 'should have 2 series (revenue, costs)'
	assert series_list[0].name == 'revenue', 'first series should be revenue'
	assert series_list[0].labels == ['Jan', 'Feb', 'Mar'], 'labels wrong'
	assert series_list[0].data[0] == 120.0, 'first value wrong'
	assert series_list[1].name == 'costs', 'second series should be costs'
}

fn test_dashboard_html() {
	mut d := new_dashboard('Test Dashboard')
	d.subtitle = 'Test subtitle'
	mut c1 := bar(title: 'Chart 1')
	c1.add_series(named_series('D', ['A', 'B'], [10.0, 20.0]))
	mut c2 := pie(title: 'Chart 2')
	c2.add_series(named_series('S', ['X', 'Y'], [60.0, 40.0]))
	d.add_chart(c1, 1)
	d.add_chart(c2, 1)
	html := d.to_html()
	assert html.contains('Test Dashboard'), 'title missing'
	assert html.contains('Test subtitle'), 'subtitle missing'
	assert html.contains('db-grid'), 'grid missing'
	assert html.contains('vc_0'), 'chart 0 missing'
	assert html.contains('vc_1'), 'chart 1 missing'
	assert html.contains('vegaEmbed'), 'vegaEmbed missing'
	assert !html.contains('src="echarts'), 'echarts CDN reference must not be present'
}

// ─── Unsupported chart types return a valid spec stub ──────────────────────────

fn test_box_plot_unsupported() {
	mut c := box_plot(title: 'Test Box')
	c.add_series(new_series('Group A', [1.0, 2.0, 3.0, 4.0, 5.0]))
	json := c.to_json()
	assert json.contains('vega.github.io/schema/vega-lite'), 'should return valid stub spec'
}

fn test_candlestick_unsupported() {
	mut c := candlestick(title: 'Test OHLC')
	c.add_ohlc(OHLCSeries{
		name:   'AAPL'
		labels: ['Mon', 'Tue']
		open:   [100.0, 105.0]
		high:   [110.0, 112.0]
		low:    [98.0, 103.0]
		close:  [107.0, 104.0]
	})
	json := c.to_json()
	assert json.contains('vega.github.io/schema/vega-lite'), 'should return valid stub spec'
}

// ─── Fix: ref lines and annotations rendered ──────────────────────────────────

fn test_ref_line_rendered() {
	mut c := bar(title: 'RefLine',
		ref_lines: [RefLine{ axis: 'y', value: 100.0, label: 'Target', color: '#ff0000', dash: .dashed }])
	c.add_series(named_series('Sales', ['A', 'B'], [80.0, 120.0]))
	json := c.to_json()
	assert json.contains('"type":"rule"'), 'rule mark missing'
	assert json.contains('100'), 'ref line value missing'
	assert json.contains('Target'), 'ref line label missing'
}

fn test_annotation_rendered() {
	mut c := scatter(title: 'Annotated',
		annotations: [Annotation{ x: 2.0, y: 4.0, text: 'Peak', color: '#333333', size: 12 }])
	c.add_series(xy_series('D', [[1.0, 1.0], [2.0, 4.0]]))
	json := c.to_json()
	assert json.contains('"Peak"'), 'annotation text missing'
	assert json.contains('"type":"text"'), 'text mark missing for annotation'
}

// ─── Fix: trend line rendered ─────────────────────────────────────────────────

fn test_trend_line_scatter_uses_vl_regression() {
	mut c := scatter(title: 'Trend Scatter', trend_line: true)
	c.add_series(xy_series('D', [[1.0, 1.0], [2.0, 4.0], [3.0, 9.0]]))
	json := c.to_json()
	assert json.contains('"regression"'), 'Vega-Lite regression transform missing'
}

fn test_trend_line_nominal_uses_ols() {
	mut c := line(title: 'Trend Line', trend_line: true)
	c.add_series(named_series('D', ['Jan', 'Feb', 'Mar'], [10.0, 20.0, 30.0]))
	json := c.to_json()
	assert json.contains('"__trend"'), 'OLS trend data field missing'
	assert json.contains('"strokeDash"'), 'dashed trend line missing'
}

// ─── Fix: zoom params ─────────────────────────────────────────────────────────

fn test_zoom_params_emitted() {
	mut c := line(title: 'Zoom', zoom: true)
	c.add_series(named_series('D', ['A', 'B'], [1.0, 2.0]))
	json := c.to_json()
	assert json.contains('"params"'), 'zoom params missing'
	assert json.contains('"bind":"scales"'), 'zoom bind:scales missing'
}

fn test_no_zoom_params_by_default() {
	mut c := line(title: 'No Zoom')
	c.add_series(named_series('D', ['A', 'B'], [1.0, 2.0]))
	json := c.to_json()
	assert !json.contains('"bind":"scales"'), 'zoom should not appear when zoom:false'
}

// ─── Fix: axis number format ──────────────────────────────────────────────────

fn test_y_axis_format_applied() {
	mut c := bar(title: 'Formatted', y_axis: AxisConfig{ name: 'Revenue', format: ',.0f' })
	c.add_series(named_series('Rev', ['Q1'], [1200000.0]))
	json := c.to_json()
	assert json.contains('"format":",.0f"'), 'y axis format missing from spec'
}

fn test_x_axis_format_applied_hbar() {
	mut c := hbar(title: 'HBar Fmt', x_axis: AxisConfig{ name: 'Value', format: '.2s' })
	c.add_series(named_series('D', ['A', 'B'], [1000.0, 2000.0]))
	json := c.to_json()
	assert json.contains('"format":".2s"'), 'x axis format missing in hbar'
}

// ─── Fix: HTML title as HTML div, not in VL spec ─────────────────────────────

fn test_html_title_in_div_not_in_spec() {
	mut c := bar(title: 'My Chart', subtitle: 'Q3 Results')
	c.add_series(named_series('D', ['A'], [1.0]))
	html := c.to_html()
	assert html.contains('<div class="chart-title">My Chart</div>'), 'title div missing'
	assert html.contains('<div class="chart-subtitle">Q3 Results</div>'), 'subtitle div missing'
	// JSON spec itself should still carry the title (for standalone use)
	json := c.to_json()
	assert json.contains('My Chart'), 'title should remain in standalone JSON'
}

// ─── Fix: direct labels on line charts ───────────────────────────────────────

fn test_direct_labels_suppresses_legend() {
	mut c := line(title: 'Direct', direct_labels: true)
	c.add_series(named_series('Sales', ['Q1', 'Q2'], [100.0, 120.0]))
	c.add_series(named_series('Costs', ['Q1', 'Q2'], [80.0, 90.0]))
	json := c.to_json()
	assert json.contains('"legend":null'), 'legend should be null with direct_labels'
	assert json.contains('"value":"Sales"'), 'direct label for Sales missing'
	assert json.contains('"value":"Costs"'), 'direct label for Costs missing'
}

// ─── Fix: scatter axis title defaults removed ─────────────────────────────────

fn test_scatter_no_default_axis_titles() {
	mut c := scatter(title: 'Scatter')
	c.add_series(xy_series('D', [[1.0, 2.0], [3.0, 4.0]]))
	json := c.to_json()
	assert !json.contains('"title":"x"'), 'scatter must not default x title to "x"'
	assert !json.contains('"title":"y"'), 'scatter must not default y title to "y"'
}

// ─── Fix: Tableau palette capped at 7 colors ──────────────────────────────────

fn test_tableau_capped_at_7_colors() {
	// Multi-series triggers vl_color_range which embeds all palette colors in the spec
	mut c := line(title: 'Tableau 7', colors: .tableau)
	c.add_series(named_series('A', ['X'], [1.0]))
	c.add_series(named_series('B', ['X'], [2.0]))
	json := c.to_json()
	assert json.contains('#4E79A7'), 'first tableau color present'
	assert json.contains('#B07AA1'), '7th tableau color present'
	assert !json.contains('#FF9DA7'), '8th tableau color must not appear'
	assert !json.contains('#9C755F'), '9th tableau color must not appear'
	assert !json.contains('#BAB0AC'), '10th tableau color must not appear'
}
