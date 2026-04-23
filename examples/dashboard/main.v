module main

import cuiqcharts

fn main() {
	mut dash := cuiqcharts.new_dashboard('Q1 2026 Summary')
	dash.subtitle = 'cuiqcharts · Vega-Lite backend'
	dash.columns = 2
	dash.gap_px = 24

	mut bar_chart := cuiqcharts.bar(
		title:  'Monthly Revenue'
		colors: .vibrant
		width:  600
		height: 350
	)
	bar_chart.add_series(cuiqcharts.named_series('Revenue', ['Jan', 'Feb', 'Mar'],
		[120.0, 145.0, 200.0]))
	dash.add_chart(bar_chart, 1)

	mut line_chart := cuiqcharts.line(
		title:  'Sales vs Costs'
		theme:  .light
		colors: .latimes
		width:  600
		height: 350
	)
	line_chart.add_series(cuiqcharts.named_series('Sales', ['Q1', 'Q2', 'Q3', 'Q4'],
		[100.0, 120.0, 115.0, 140.0]))
	line_chart.add_series(cuiqcharts.named_series('Costs', ['Q1', 'Q2', 'Q3', 'Q4'],
		[80.0, 90.0, 85.0, 95.0]))
	dash.add_chart(line_chart, 1)

	mut pie_chart := cuiqcharts.pie(
		title:  'Market Share'
		colors: .pastel
		width:  500
		height: 350
	)
	pie_chart.add_series(cuiqcharts.named_series('Share',
		['Product A', 'Product B', 'Product C'], [45.0, 30.0, 25.0]))
	dash.add_chart(pie_chart, 1)

	mut scatter_chart := cuiqcharts.scatter(
		title:  'Height vs Weight'
		colors: .colorblind
		width:  500
		height: 350
	)
	scatter_chart.add_series(cuiqcharts.xy_series('Group A', [
		[160.0, 55.0], [165.0, 60.0], [170.0, 65.0], [175.0, 70.0],
	]))
	scatter_chart.add_series(cuiqcharts.xy_series('Group B', [
		[155.0, 50.0], [162.0, 58.0], [168.0, 63.0], [172.0, 68.0],
	]))
	dash.add_chart(scatter_chart, 1)

	dash.save('dashboard.html') or { eprintln('Error: ${err}') }
	println('Saved dashboard.html')
}
