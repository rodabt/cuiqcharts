module main

import cuiqcharts

fn main() {
	// ── Bar chart ──────────────────────────────────────────────────────────────
	mut bar_chart := cuiqcharts.bar(
		title:  'Monthly Revenue'
		colors: .latimes
		width:  900
		height: 450
		x_axis: cuiqcharts.AxisConfig{ name: 'Month' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Revenue (USD thousands)' }
	)
	bar_chart.add_series(cuiqcharts.named_series('Revenue', ['Jan', 'Feb', 'Mar'],
		[120.0, 145.0, 200.0]))
	bar_chart.save('bar_chart.html') or { eprintln('Error saving bar_chart: ${err}') }
	println('Saved bar_chart.html')

	// ── Multi-series line chart ────────────────────────────────────────────────
	mut line_chart := cuiqcharts.line(
		title:  'Sales vs Costs'
		colors: .latimes
		width:  900
		height: 450
		x_axis: cuiqcharts.AxisConfig{ name: 'Quarter' }
		y_axis: cuiqcharts.AxisConfig{ name: 'USD thousands' }
	)
	line_chart.add_series(cuiqcharts.named_series('Sales', ['Q1', 'Q2', 'Q3', 'Q4'],
		[100.0, 120.0, 115.0, 140.0]))
	line_chart.add_series(cuiqcharts.named_series('Costs', ['Q1', 'Q2', 'Q3', 'Q4'],
		[80.0, 90.0, 85.0, 95.0]))
	line_chart.save('line_chart.html') or { eprintln('Error saving line_chart: ${err}') }
	println('Saved line_chart.html')

	// ── Market share — hbar preferred over pie (Cleveland: length > angle perception) ──
	mut share_chart := cuiqcharts.hbar(
		title:  'Market Share by Product'
		colors: .latimes
		width:  600
		height: 300
		x_axis: cuiqcharts.AxisConfig{ name: 'Share (%)' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Product' }
	)
	share_chart.add_series(cuiqcharts.named_series('Share',
		['Product A', 'Product B', 'Product C'], [45.0, 30.0, 25.0]))
	share_chart.save('market_share.html') or { eprintln('Error saving market_share: ${err}') }
	println('Saved market_share.html')

	// ── Scatter chart ──────────────────────────────────────────────────────────
	mut scatter_chart := cuiqcharts.scatter(
		title:  'Height vs Weight'
		colors: .colorblind
		width:  700
		height: 500
		x_axis: cuiqcharts.AxisConfig{ name: 'Height (cm)' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Weight (kg)' }
	)
	scatter_chart.add_series(cuiqcharts.xy_series('Group A', [
		[160.0, 55.0], [165.0, 60.0], [170.0, 65.0], [175.0, 70.0], [180.0, 80.0],
	]))
	scatter_chart.add_series(cuiqcharts.xy_series('Group B', [
		[155.0, 50.0], [162.0, 58.0], [168.0, 63.0], [172.0, 68.0],
	]))
	scatter_chart.save('scatter_chart.html') or { eprintln('Error saving scatter_chart: ${err}') }
	println('Saved scatter_chart.html')

	// ── Horizontal bar ─────────────────────────────────────────────────────────
	mut hbar_chart := cuiqcharts.hbar(
		title:  'Cost by Department'
		colors: .latimes
		width:  700
		height: 400
		x_axis: cuiqcharts.AxisConfig{ name: 'Budget (USD thousands)' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Department' }
	)
	hbar_chart.add_series(cuiqcharts.named_series('Budget',
		['Engineering', 'Sales', 'Marketing', 'Operations'],
		[450.0, 280.0, 190.0, 320.0]))
	hbar_chart.save('hbar_chart.html') or { eprintln('Error saving hbar_chart: ${err}') }
	println('Saved hbar_chart.html')

	// ── Area chart ─────────────────────────────────────────────────────────────
	mut area_chart := cuiqcharts.area(
		title:  'Cumulative User Growth'
		colors: .latimes
		width:  900
		height: 400
		x_axis: cuiqcharts.AxisConfig{ name: 'Month' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Total Users' }
	)
	area_chart.add_series(cuiqcharts.named_series('Users', ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
		[1000.0, 1500.0, 2200.0, 3100.0, 4500.0]))
	area_chart.save('area_chart.html') or { eprintln('Error saving area_chart: ${err}') }
	println('Saved area_chart.html')

	// ── Histogram ──────────────────────────────────────────────────────────────
	mut hist_chart := cuiqcharts.histogram(
		title:  'Score Distribution'
		colors: .latimes
		width:  800
		height: 450
		x_axis: cuiqcharts.AxisConfig{ name: 'Score' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Count' }
	)
	hist_chart.add_series(cuiqcharts.new_series('Scores', [
		72.0, 85.0, 91.0, 67.0, 78.0, 84.0, 76.0, 93.0, 61.0, 88.0,
		74.0, 82.0, 79.0, 95.0, 70.0, 83.0, 77.0, 89.0, 65.0, 92.0,
	]))
	hist_chart.save('histogram.html') or { eprintln('Error saving histogram: ${err}') }
	println('Saved histogram.html')

	// ── Heatmap — sequential palette (light → dark) for quantitative cells ────
	mut heat_chart := cuiqcharts.heatmap(
		title:  'Activity Heatmap'
		colors: .latimes
		width:  700
		height: 400
		x_axis: cuiqcharts.AxisConfig{ name: 'Time' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Day' }
	)
	heat_chart.add_series(cuiqcharts.named_series('Mon', ['9am', '12pm', '3pm', '6pm'],
		[0.3, 0.8, 0.6, 0.4]))
	heat_chart.add_series(cuiqcharts.named_series('Tue', ['9am', '12pm', '3pm', '6pm'],
		[0.5, 0.9, 0.7, 0.2]))
	heat_chart.add_series(cuiqcharts.named_series('Wed', ['9am', '12pm', '3pm', '6pm'],
		[0.4, 0.7, 0.8, 0.5]))
	heat_chart.save('heatmap.html') or { eprintln('Error saving heatmap: ${err}') }
	println('Saved heatmap.html')

	// ── Bar chart with error bars ──────────────────────────────────────────────
	mut errorbar_chart := cuiqcharts.bar_errorbar(
		title:  'Crop Yield by Variety (with 95% CI)'
		colors: .tableau
		width:  700
		height: 450
		x_axis: cuiqcharts.AxisConfig{ name: 'Variety' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Yield (bushels/acre)' }
	)
	errorbar_chart.add_series(cuiqcharts.error_series(
		'Yield',
		['Gopher', 'Manchuria', 'No. 457', 'No. 462', 'Peatland', 'Svansota', 'Trebi', 'Velvet', 'Wisconsin No. 38'],
		[16.865, 30.967, 33.967, 30.450, 34.533, 16.865, 39.567, 33.967, 38.917],
		[3.2, 4.1, 3.8, 2.9, 4.5, 3.2, 5.1, 3.8, 4.7],
		[],
	))
	errorbar_chart.save('bar_errorbar.html') or { eprintln('Error saving bar_errorbar: ${err}') }
	println('Saved bar_errorbar.html')

	// ── Rolling average over raw values ───────────────────────────────────────
	mut rolling_chart := cuiqcharts.rolling_mean(
		title:          'Daily Temperature with 7-Day Rolling Average'
		colors:         .default_scheme
		width:          900
		height:         400
		rolling_window: 7
		x_axis:         cuiqcharts.AxisConfig{ name: 'Day' }
		y_axis:         cuiqcharts.AxisConfig{ name: 'Temperature (°C)' }
	)
	rolling_chart.add_series(cuiqcharts.named_series('Temperature',
		['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15',
		 '16','17','18','19','20','21','22','23','24','25','26','27','28'],
		[12.0, 14.0, 11.0, 16.0, 18.0, 15.0, 13.0, 17.0, 20.0, 19.0, 22.0, 21.0,
		 18.0, 16.0, 19.0, 23.0, 25.0, 24.0, 22.0, 20.0, 18.0, 21.0, 23.0, 26.0,
		 28.0, 27.0, 25.0, 24.0]))
	rolling_chart.save('rolling_mean.html') or { eprintln('Error saving rolling_mean: ${err}') }
	println('Saved rolling_mean.html')

	// ── Line chart with confidence interval band ───────────────────────────────
	mut ci_chart := cuiqcharts.line_ci(
		title:  'Fuel Efficiency Over Time (with Confidence Band)'
		colors: .latimes
		width:  800
		height: 400
		x_axis: cuiqcharts.AxisConfig{ name: 'Year' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Miles per Gallon' }
	)
	ci_chart.add_series(cuiqcharts.error_series(
		'Mean MPG',
		['1970', '1971', '1972', '1973', '1974', '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982'],
		[17.7, 21.1, 18.7, 17.1, 22.7, 20.2, 21.6, 23.4, 24.4, 25.9, 33.7, 30.3, 31.7],
		[2.1, 1.8, 2.3, 1.9, 2.5, 2.0, 1.7, 2.2, 2.8, 2.4, 3.1, 2.6, 2.9],
		[],
	))
	ci_chart.save('line_ci.html') or { eprintln('Error saving line_ci: ${err}') }
	println('Saved line_ci.html')

	// ── Waterfall chart ────────────────────────────────────────────────────────
	// "Begin" and "End" are Total bars: they anchor to y=0 and span the running sum.
	// Begin carries the opening balance; End amount=0 displays the final cumulative total.
	mut wfall_chart := cuiqcharts.waterfall(
		title:  'Annual Profit & Loss'
		colors: .latimes
		width:  900
		height: 450
		x_axis: cuiqcharts.AxisConfig{ name: 'Period' }
		y_axis: cuiqcharts.AxisConfig{ name: 'USD thousands' }
	)
	wfall_chart.add_series(cuiqcharts.named_series('',
		['Begin', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
		 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'End'],
		[500.0, 120.0, -40.0, 80.0, -20.0, 150.0, -60.0, 90.0, 30.0, -50.0, 110.0, -30.0, 70.0, 0.0]))
	wfall_chart.save('waterfall.html') or { eprintln('Error saving waterfall: ${err}') }
	println('Saved waterfall.html')

	// ── Amplitude funnel chart ─────────────────────────────────────────────────
	mut funnel_chart := cuiqcharts.funnel(
		title:  'Conversion Funnel'
		labels: cuiqcharts.LabelConfig{ show: true }
		colors: .tableau
		width:  800
		height: 400
		x_axis: cuiqcharts.AxisConfig{ name: 'Stage' }
		y_axis: cuiqcharts.AxisConfig{ name: 'Users' }
	)
	stages := ['Awareness', 'Interest', 'Consideration', 'Intent', 'Purchase']
	funnel_chart.add_series(cuiqcharts.named_series('Converted', stages,
		[8500.0, 6200.0, 4100.0, 2800.0, 1900.0]))
	funnel_chart.add_series(cuiqcharts.named_series('Drop-off', stages,
		[1500.0, 2100.0, 2100.0, 1300.0, 900.0]))
	funnel_chart.save('funnel.html') or { eprintln('Error saving funnel: ${err}') }
	println('Saved funnel.html')

	// ── Box plot — clinical trial results across treatment arms ───────────────
	mut box_chart := cuiqcharts.box_plot(
		title:    'Patient Response by Treatment Arm'
		subtitle: 'Phase III Trial — Primary Endpoint Score'
		colors:   .colorblind
		width:    800
		height:   500
		x_axis:   cuiqcharts.AxisConfig{ name: 'Treatment' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Response Score' }
	)
	box_chart.add_series(cuiqcharts.new_series('Placebo', [
		22.0, 18.0, 25.0, 20.0, 17.0, 23.0, 21.0, 19.0, 24.0, 16.0,
		26.0, 20.0, 22.0, 18.0, 21.0, 19.0, 23.0, 20.0, 17.0, 25.0,
	]))
	box_chart.add_series(cuiqcharts.new_series('Low Dose', [
		31.0, 28.0, 35.0, 33.0, 29.0, 37.0, 32.0, 30.0, 36.0, 34.0,
		28.0, 33.0, 31.0, 38.0, 30.0, 35.0, 32.0, 29.0, 36.0, 34.0,
	]))
	box_chart.add_series(cuiqcharts.new_series('High Dose', [
		44.0, 48.0, 41.0, 52.0, 46.0, 50.0, 43.0, 49.0, 55.0, 47.0,
		42.0, 51.0, 45.0, 53.0, 48.0, 40.0, 57.0, 46.0, 44.0, 50.0,
	]))
	box_chart.add_series(cuiqcharts.new_series('Combo', [
		58.0, 62.0, 55.0, 67.0, 60.0, 64.0, 59.0, 63.0, 70.0, 57.0,
		61.0, 66.0, 54.0, 68.0, 62.0, 56.0, 65.0, 61.0, 59.0, 63.0,
	]))
	box_chart.save('box_plot.html') or { eprintln('Error saving box_plot: ${err}') }
	println('Saved box_plot.html')

	// ── SPC control chart — injection moulding part thickness ─────────────────
	// Samples 18 and 24 approach/breach the UCL (process drift).
	mut ctrl_chart := cuiqcharts.line(
		title:    'Part Thickness — Injection Moulding Process'
		subtitle: 'X-bar chart  |  UCL = 10.45 mm  |  CL = 10.00 mm  |  LCL = 9.55 mm'
		colors:   .default_scheme
		width:    1000
		height:   450
		x_axis:   cuiqcharts.AxisConfig{ name: 'Sample #' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Thickness (mm)' }
	)
	ctrl_samples := ['1','2','3','4','5','6','7','8','9','10',
	                 '11','12','13','14','15','16','17','18','19','20',
	                 '21','22','23','24','25','26','27','28','29','30']
	ctrl_chart.add_series(cuiqcharts.named_series('X-bar', ctrl_samples, [
		9.98, 10.12, 9.87, 10.05, 9.93, 10.21, 9.76, 10.08, 9.95, 10.15,
		9.89, 10.03, 9.82, 10.18, 9.91, 10.07, 9.85, 10.41, 9.97, 10.11,
		9.88, 10.23, 9.79, 10.43, 9.96, 10.09, 9.84, 10.14, 9.92, 10.06,
	]))
	ctrl_chart.set_control_limits(cuiqcharts.ControlLimitsOverlay{
		ucl: 10.45  cl: 10.00  lcl: 9.55
		ucl_label: 'UCL = 10.45'
		cl_label:  'CL = 10.00'
		lcl_label: 'LCL = 9.55'
	})
	ctrl_chart.save('control_chart.html') or { eprintln('Error saving control_chart: ${err}') }
	println('Saved control_chart.html')

	// ── Daily website traffic with 7-day rolling average overlay ─────────────
	mut traffic_chart := cuiqcharts.line(
		title:    'Daily Website Sessions — April 2026'
		subtitle: 'Raw daily count with 7-day rolling average'
		colors:   .default_scheme
		width:    1000
		height:   420
		x_axis:   cuiqcharts.AxisConfig{ name: 'Date' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Sessions' }
	)
	traffic_days := [
		'Apr 1','Apr 2','Apr 3','Apr 4','Apr 5','Apr 6','Apr 7',
		'Apr 8','Apr 9','Apr 10','Apr 11','Apr 12','Apr 13','Apr 14',
		'Apr 15','Apr 16','Apr 17','Apr 18','Apr 19','Apr 20','Apr 21',
		'Apr 22','Apr 23','Apr 24','Apr 25','Apr 26','Apr 27','Apr 28',
		'Apr 29','Apr 30',
	]
	traffic_chart.add_series(cuiqcharts.named_series('Sessions', traffic_days, [
		4120.0, 4380.0, 3950.0, 2810.0, 2650.0, 3200.0, 4560.0,
		4710.0, 4890.0, 4230.0, 2950.0, 2780.0, 3410.0, 4820.0,
		5100.0, 4960.0, 5230.0, 3100.0, 2890.0, 3650.0, 5040.0,
		5280.0, 5110.0, 4870.0, 3250.0, 3080.0, 3820.0, 5310.0,
		5490.0, 5620.0,
	]))
	traffic_chart.set_running_avg(cuiqcharts.RunningAvgOverlay{
		window: 7
		label:  '7-day avg'
		color:  '#e15759'
		dash:   .dashed
	})
	traffic_chart.save('rolling_avg_overlay.html') or { eprintln('Error saving rolling_avg_overlay: ${err}') }
	println('Saved rolling_avg_overlay.html')

	// ── Dose-response curve with asymmetric error bars overlay ────────────────
	mut dose_chart := cuiqcharts.line(
		title:    'Enzyme Activity vs Substrate Concentration'
		subtitle: 'Mean ± SEM  (n = 8 replicates per concentration)'
		colors:   .colorblind
		width:    850
		height:   450
		x_axis:   cuiqcharts.AxisConfig{ name: 'Substrate (mM)' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Activity (nmol/min/mg)' }
	)
	dose_conc   := ['0.5', '1.0', '2.0', '4.0', '8.0', '16.0', '32.0', '64.0']
	dose_mean   := [12.3, 22.8, 38.4, 57.6, 74.1, 85.3, 91.7, 94.2]
	dose_sem_hi := [1.8, 2.4, 3.1, 3.8, 4.2, 3.9, 3.4, 2.9]
	dose_sem_lo := [1.5, 2.1, 2.8, 3.4, 3.9, 3.6, 3.1, 2.6]
	dose_chart.add_series(cuiqcharts.named_series('Activity', dose_conc, dose_mean))
	dose_chart.add_error_bars(cuiqcharts.ErrorBarsOverlay{
		series_name: 'Activity'
		plus:        dose_sem_hi
		minus:       dose_sem_lo
	})
	dose_chart.save('error_bars_overlay.html') or { eprintln('Error saving error_bars_overlay: ${err}') }
	println('Saved error_bars_overlay.html')

	// ── Area chart with control limits — server latency monitoring ────────────
	mut latency_chart := cuiqcharts.area(
		title:    'API Latency — p95 Response Time'
		subtitle: 'Control limits based on 30-day baseline'
		colors:   .default_scheme
		width:    1000
		height:   400
		x_axis:   cuiqcharts.AxisConfig{ name: 'Hour (UTC)' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Latency (ms)' }
	)
	latency_hours := ['00','01','02','03','04','05','06','07','08','09','10','11',
	                  '12','13','14','15','16','17','18','19','20','21','22','23']
	latency_chart.add_series(cuiqcharts.named_series('p95', latency_hours, [
		42.0, 38.0, 35.0, 33.0, 34.0, 40.0, 68.0, 112.0, 145.0, 138.0, 131.0, 142.0,
		155.0, 148.0, 152.0, 144.0, 139.0, 143.0, 137.0, 118.0, 95.0, 74.0, 58.0, 48.0,
	]))
	latency_chart.set_control_limits(cuiqcharts.ControlLimitsOverlay{
		ucl: 160.0  cl: 95.0  lcl: 30.0
		ucl_label: 'UCL'  cl_label: 'Baseline'  lcl_label: 'LCL'
		cl_color:  '#888888'
	})
	latency_chart.save('latency_control.html') or { eprintln('Error saving latency_control: ${err}') }
	println('Saved latency_control.html')
}
