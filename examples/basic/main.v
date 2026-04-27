module main

import cuiqcharts

fn main() {
	// ── Bar — monthly revenue with target ref line and formatted axis ──────────
	mut bar_chart := cuiqcharts.bar(
		title:    'Monthly Revenue — Q4 2025'
		subtitle: 'Target: $200k/month'
		colors:   .latimes
		width:    900
		height:   450
		x_axis:   cuiqcharts.AxisConfig{ name: 'Month' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Revenue (USD)', format: ',.0f' }
		ref_lines: [
			cuiqcharts.RefLine{ axis: 'y', value: 200000.0, label: 'Monthly target', color: '#e53935', dash: .dashed },
		]
	)
	bar_chart.add_series(cuiqcharts.named_series('Revenue',
		['Oct', 'Nov', 'Dec'], [182000.0, 215000.0, 248000.0]))
	bar_chart.save('bar_chart.html') or { eprintln('Error: ${err}') }
	println('Saved bar_chart.html')

	// ── Grouped bar — revenue vs budget by region ──────────────────────────────
	mut grouped_bar := cuiqcharts.bar(
		title:  'Revenue vs Budget by Region — Q4 2025'
		colors: .latimes
		width:  900
		height: 450
		x_axis: cuiqcharts.AxisConfig{ name: 'Region' }
		y_axis: cuiqcharts.AxisConfig{ name: 'USD thousands' }
	)
	grouped_bar.add_series(cuiqcharts.named_series('Revenue',
		['APAC', 'EMEA', 'LATAM', 'North America'],
		[340.0, 410.0, 195.0, 620.0]))
	grouped_bar.add_series(cuiqcharts.named_series('Budget',
		['APAC', 'EMEA', 'LATAM', 'North America'],
		[300.0, 380.0, 220.0, 580.0]))
	grouped_bar.save('grouped_bar.html') or { eprintln('Error: ${err}') }
	println('Saved grouped_bar.html')

	// ── Line — multi-series with direct end-of-line labels (no legend) ─────────
	mut line_chart := cuiqcharts.line(
		title:         'Revenue, COGS, and OpEx — FY 2025'
		subtitle:      'Labels at series endpoints replace the legend'
		colors:        .default_scheme
		width:         900
		height:        450
		direct_labels: true
		x_axis:        cuiqcharts.AxisConfig{ name: 'Quarter' }
		y_axis:        cuiqcharts.AxisConfig{ name: 'USD thousands' }
	)
	line_chart.add_series(cuiqcharts.named_series('Revenue',
		['Q1', 'Q2', 'Q3', 'Q4'], [100.0, 120.0, 115.0, 140.0]))
	line_chart.add_series(cuiqcharts.named_series('COGS',
		['Q1', 'Q2', 'Q3', 'Q4'], [60.0, 68.0, 65.0, 80.0]))
	line_chart.add_series(cuiqcharts.named_series('OpEx',
		['Q1', 'Q2', 'Q3', 'Q4'], [25.0, 28.0, 26.0, 30.0]))
	line_chart.save('line_direct_labels.html') or { eprintln('Error: ${err}') }
	println('Saved line_direct_labels.html')

	// ── Line — single series with OLS trend line ───────────────────────────────
	mut trend_chart := cuiqcharts.line(
		title:      'Monthly Active Users — 2025'
		subtitle:   'OLS trend line shows underlying growth trajectory'
		colors:     .latimes
		width:      900
		height:     450
		trend_line: true
		x_axis:     cuiqcharts.AxisConfig{ name: 'Month' }
		y_axis:     cuiqcharts.AxisConfig{ name: 'MAU (thousands)' }
	)
	trend_chart.add_series(cuiqcharts.named_series('MAU',
		['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
		[42.0, 45.0, 43.0, 51.0, 58.0, 55.0, 62.0, 68.0, 65.0, 72.0, 78.0, 84.0]))
	trend_chart.save('line_trend.html') or { eprintln('Error: ${err}') }
	println('Saved line_trend.html')

	// ── Horizontal bar — browser market share ──────────────────────────────────
	mut share_chart := cuiqcharts.hbar(
		title:    'Browser Market Share — Desktop, Q4 2025'
		subtitle: 'Source: StatCounter Global Stats'
		colors:   .latimes
		width:    700
		height:   380
		x_axis:   cuiqcharts.AxisConfig{ name: 'Share (%)' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Browser' }
	)
	share_chart.add_series(cuiqcharts.named_series('Share',
		['Chrome', 'Safari', 'Edge', 'Firefox', 'Opera', 'Other'],
		[65.1, 19.2, 4.8, 3.9, 2.6, 4.4]))
	share_chart.save('market_share.html') or { eprintln('Error: ${err}') }
	println('Saved market_share.html')

	// ── Scatter — price elasticity with regression line, ref line, and zoom ────
	//
	// Demonstrates three features added in this release:
	//   trend_line: true  → Vega-Lite OLS regression across all SKUs
	//   zoom: true        → drag to zoom, scroll to pan, double-click to reset
	//   ref_lines         → horizontal rule at the minimum viable volume
	//   annotations       → label for the premium flagship outlier
	//
	// Each point is one SKU; x = retail price, y = units sold (thousands).
	// The downward-sloping regression confirms classic price-demand elasticity.
	mut scatter_chart := cuiqcharts.scatter(
		title:       'Price Elasticity of Demand — Consumer Electronics, Q4 2025'
		subtitle:    'Each point = one SKU  ·  regression = OLS across all categories  ·  drag to zoom'
		colors:      .colorblind
		width:       940
		height:      520
		zoom:        true
		trend_line:  true
		trend_color: 'rgba(170,30,30,0.7)'
		x_axis:      cuiqcharts.AxisConfig{ name: 'Retail Price (USD)' }
		y_axis:      cuiqcharts.AxisConfig{ name: 'Units Sold (thousands)' }
		ref_lines:   [
			cuiqcharts.RefLine{ axis: 'y', value: 50.0, label: 'Volume floor', color: '#388e3c', dash: .dashed },
		]
		annotations: [
			cuiqcharts.Annotation{ x: 1599.0, y: 14.0, text: 'Flagship laptop', color: '#555555', size: 11 },
		]
	)
	scatter_chart.add_series(cuiqcharts.xy_series('Smartphones', [
		[199.0, 142.0], [249.0, 128.0], [299.0, 116.0], [349.0, 103.0],
		[399.0,  89.0], [449.0,  75.0], [499.0,  63.0], [549.0,  57.0],
		[599.0,  51.0], [699.0,  42.0], [799.0,  36.0], [899.0,  28.0],
	]))
	scatter_chart.add_series(cuiqcharts.xy_series('Tablets', [
		[299.0, 89.0], [349.0, 78.0], [399.0, 69.0], [449.0, 61.0],
		[499.0, 54.0], [549.0, 48.0], [599.0, 44.0], [699.0, 37.0],
		[799.0, 30.0], [899.0, 24.0],
	]))
	scatter_chart.add_series(cuiqcharts.xy_series('Laptops', [
		[ 599.0, 62.0], [ 699.0, 55.0], [ 799.0, 48.0], [ 899.0, 41.0],
		[ 999.0, 35.0], [1099.0, 30.0], [1199.0, 26.0], [1299.0, 22.0],
		[1399.0, 18.0], [1499.0, 16.0], [1599.0, 14.0],
	]))
	scatter_chart.save('scatter_elasticity.html') or { eprintln('Error: ${err}') }
	println('Saved scatter_elasticity.html')

	// ── Area — cumulative user growth with zoom ────────────────────────────────
	mut area_chart := cuiqcharts.area(
		title:    'Cumulative Registered Users — 2025'
		subtitle: 'Drag to zoom into any time window'
		colors:   .latimes
		width:    900
		height:   420
		zoom:     true
		x_axis:   cuiqcharts.AxisConfig{ name: 'Month' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Users', format: ',.0f' }
	)
	area_chart.add_series(cuiqcharts.named_series('Registered Users',
		['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
		[12400.0, 18600.0, 27200.0, 38100.0, 51500.0, 67300.0,
		 84200.0, 103500.0, 124800.0, 148100.0, 173600.0, 201400.0]))
	area_chart.save('area_users.html') or { eprintln('Error: ${err}') }
	println('Saved area_users.html')

	// ── Histogram — API response time distribution ─────────────────────────────
	mut hist_chart := cuiqcharts.histogram(
		title:    'API Response Time Distribution'
		subtitle: 'p50 ≈ 48 ms  ·  p95 ≈ 92 ms  ·  n = 20 observations'
		colors:   .latimes
		width:    800
		height:   420
		bins:     12
		x_axis:   cuiqcharts.AxisConfig{ name: 'Latency (ms)' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Requests' }
	)
	hist_chart.add_series(cuiqcharts.new_series('Latency', [
		28.0, 32.0, 35.0, 38.0, 40.0, 42.0, 44.0, 45.0, 46.0, 47.0,
		48.0, 49.0, 51.0, 53.0, 55.0, 58.0, 62.0, 68.0, 78.0, 94.0,
	]))
	hist_chart.save('histogram_latency.html') or { eprintln('Error: ${err}') }
	println('Saved histogram_latency.html')

	// ── Heatmap — NPS by region and quarter ───────────────────────────────────
	mut heat_chart := cuiqcharts.heatmap(
		title:    'Net Promoter Score by Region and Quarter'
		subtitle: 'Darker = higher NPS (0–100 scale)'
		colors:   .latimes
		width:    700
		height:   360
		x_axis:   cuiqcharts.AxisConfig{ name: 'Quarter' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Region' }
	)
	heat_chart.add_series(cuiqcharts.named_series('APAC',          ['Q1','Q2','Q3','Q4'], [62.0, 65.0, 68.0, 71.0]))
	heat_chart.add_series(cuiqcharts.named_series('EMEA',          ['Q1','Q2','Q3','Q4'], [54.0, 58.0, 55.0, 61.0]))
	heat_chart.add_series(cuiqcharts.named_series('LATAM',         ['Q1','Q2','Q3','Q4'], [48.0, 52.0, 57.0, 60.0]))
	heat_chart.add_series(cuiqcharts.named_series('North America', ['Q1','Q2','Q3','Q4'], [71.0, 69.0, 73.0, 76.0]))
	heat_chart.save('heatmap_nps.html') or { eprintln('Error: ${err}') }
	println('Saved heatmap_nps.html')

	// ── Bar with error bars — A/B test conversion rates ───────────────────────
	mut errorbar_chart := cuiqcharts.bar_errorbar(
		title:    'A/B Test — Conversion Rate by Variant (95% CI)'
		subtitle: 'Error bars = 95% confidence interval; n ≈ 2 000 sessions per variant'
		colors:   .latimes
		width:    800
		height:   450
		x_axis:   cuiqcharts.AxisConfig{ name: 'Variant' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Conversion Rate (%)' }
	)
	errorbar_chart.add_series(cuiqcharts.error_series(
		'Conversion %',
		['Control', 'Variant A', 'Variant B', 'Variant C'],
		[3.2,  3.8,  4.6,  3.5],   // means
		[0.4,  0.5,  0.6,  0.4],   // ± CI half-width
		[],                          // symmetric
	))
	errorbar_chart.save('bar_errorbar.html') or { eprintln('Error: ${err}') }
	println('Saved bar_errorbar.html')

	// ── Rolling mean — daily signups with 7-day smoothing ─────────────────────
	mut rolling_chart := cuiqcharts.rolling_mean(
		title:          'Daily New Signups — April 2026'
		subtitle:       'Faint dots = raw daily count  ·  line = 7-day rolling average'
		colors:         .default_scheme
		width:          900
		height:         420
		rolling_window: 7
		x_axis:         cuiqcharts.AxisConfig{ name: 'Date' }
		y_axis:         cuiqcharts.AxisConfig{ name: 'Signups' }
	)
	rolling_chart.add_series(cuiqcharts.named_series('Signups',
		['Apr 1','Apr 2','Apr 3','Apr 4','Apr 5','Apr 6','Apr 7',
		 'Apr 8','Apr 9','Apr 10','Apr 11','Apr 12','Apr 13','Apr 14',
		 'Apr 15','Apr 16','Apr 17','Apr 18','Apr 19','Apr 20','Apr 21',
		 'Apr 22','Apr 23','Apr 24','Apr 25','Apr 26','Apr 27','Apr 28'],
		[312.0, 348.0, 295.0, 181.0, 165.0, 220.0, 356.0,
		 371.0, 389.0, 323.0, 195.0, 178.0, 241.0, 382.0,
		 410.0, 396.0, 423.0, 210.0, 189.0, 265.0, 404.0,
		 428.0, 411.0, 387.0, 225.0, 208.0, 282.0, 451.0]))
	rolling_chart.save('rolling_signups.html') or { eprintln('Error: ${err}') }
	println('Saved rolling_signups.html')

	// ── Line CI — quarterly revenue forecast with confidence band ─────────────
	// Q1–Q4 2024 and Q1–Q3 2025 = historical actuals (zero error band).
	// Q4 2025 and 2026 quarters = model forecast with widening prediction interval.
	mut forecast_chart := cuiqcharts.line_ci(
		title:    'Quarterly Revenue — Historical + Forecast'
		subtitle: 'Shaded band = 90% prediction interval; band widens further out'
		colors:   .latimes
		width:    900
		height:   450
		x_axis:   cuiqcharts.AxisConfig{ name: 'Quarter' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Revenue (USD millions)', format: ',.1f' }
	)
	forecast_chart.add_series(cuiqcharts.error_series(
		'Revenue',
		['Q1 24','Q2 24','Q3 24','Q4 24', 'Q1 25','Q2 25','Q3 25','Q4 25',
		 'Q1 26','Q2 26','Q3 26','Q4 26'],
		[4.2, 4.8, 4.5, 5.6,  5.9, 6.4, 6.1, 7.2,  7.8, 8.3, 8.0, 8.9],
		[0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.4,  0.7, 1.1, 1.5, 2.0],
		[],
	))
	forecast_chart.save('revenue_forecast.html') or { eprintln('Error: ${err}') }
	println('Saved revenue_forecast.html')

	// ── Waterfall — annual P&L bridge ─────────────────────────────────────────
	// "Begin" anchors to 0 (opening balance). "End" with amount=0 shows the final total.
	mut wfall_chart := cuiqcharts.waterfall(
		title:    'Annual P&L Bridge — FY 2025'
		subtitle: 'Green = gains  ·  Red = costs  ·  Grey = totals'
		colors:   .latimes
		width:    1000
		height:   450
		x_axis:   cuiqcharts.AxisConfig{ name: 'P&L Component' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'USD thousands', format: ',.0f' }
	)
	wfall_chart.add_series(cuiqcharts.named_series('',
		['Begin', 'Subscription', 'Services', 'COGS', 'S&M', 'R&D', 'G&A', 'Tax', 'End'],
		[800.0, 1240.0, 380.0, -620.0, -410.0, -290.0, -180.0, -95.0, 0.0]))
	wfall_chart.save('waterfall_pl.html') or { eprintln('Error: ${err}') }
	println('Saved waterfall_pl.html')

	// ── Funnel — e-commerce conversion ────────────────────────────────────────
	stages := ['Awareness', 'Interest', 'Consideration', 'Intent', 'Purchase']
	mut funnel_chart := cuiqcharts.funnel(
		title:    'E-commerce Conversion Funnel — November 2025'
		subtitle: 'Opaque = converted  ·  Faded = drop-off at each stage'
		labels:   cuiqcharts.LabelConfig{ show: true }
		colors:   .tableau
		width:    840
		height:   420
		x_axis:   cuiqcharts.AxisConfig{ name: 'Stage' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Visitors' }
	)
	funnel_chart.add_series(cuiqcharts.named_series('Converted', stages,
		[8500.0, 6200.0, 4100.0, 2800.0, 1900.0]))
	funnel_chart.add_series(cuiqcharts.named_series('Drop-off', stages,
		[1500.0, 2100.0, 2100.0, 1300.0, 900.0]))
	funnel_chart.save('funnel.html') or { eprintln('Error: ${err}') }
	println('Saved funnel.html')

	// ── Box plot — API response time by endpoint ───────────────────────────────
	mut box_chart := cuiqcharts.box_plot(
		title:    'API Response Time by Endpoint'
		subtitle: 'Box = IQR  ·  whiskers = min–max  ·  colorblind-safe palette'
		colors:   .colorblind
		width:    880
		height:   480
		x_axis:   cuiqcharts.AxisConfig{ name: 'Endpoint' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Response Time (ms)' }
	)
	box_chart.add_series(cuiqcharts.new_series('/api/users',    [22.0, 18.0, 25.0, 20.0, 17.0, 23.0, 21.0, 19.0, 24.0, 28.0]))
	box_chart.add_series(cuiqcharts.new_series('/api/orders',   [45.0, 38.0, 52.0, 48.0, 41.0, 55.0, 43.0, 50.0, 47.0, 61.0]))
	box_chart.add_series(cuiqcharts.new_series('/api/products', [31.0, 27.0, 35.0, 33.0, 29.0, 38.0, 32.0, 36.0, 30.0, 42.0]))
	box_chart.add_series(cuiqcharts.new_series('/api/search',   [88.0, 72.0, 105.0, 94.0, 81.0, 98.0, 76.0, 112.0, 85.0, 120.0]))
	box_chart.save('boxplot_latency.html') or { eprintln('Error: ${err}') }
	println('Saved boxplot_latency.html')

	// ── SPC — injection moulding part thickness ────────────────────────────────
	// Samples 18 and 24 approach/breach UCL (process drift visible in trend).
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
	ctrl_chart.save('spc_chart.html') or { eprintln('Error: ${err}') }
	println('Saved spc_chart.html')

	// ── Rolling average overlay — daily website sessions ───────────────────────
	mut traffic_chart := cuiqcharts.line(
		title:    'Daily Website Sessions — April 2026'
		subtitle: 'Raw daily count with 7-day rolling average overlay'
		colors:   .default_scheme
		width:    1000
		height:   420
		x_axis:   cuiqcharts.AxisConfig{ name: 'Date' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Sessions', format: ',.0f' }
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
	traffic_chart.save('traffic_rolling_avg.html') or { eprintln('Error: ${err}') }
	println('Saved traffic_rolling_avg.html')

	// ── Asymmetric error bars overlay — enzyme kinetics ───────────────────────
	mut dose_chart := cuiqcharts.line(
		title:    'Enzyme Activity vs Substrate Concentration'
		subtitle: 'Mean ± SEM  (n = 8 replicates per concentration)'
		colors:   .colorblind
		width:    850
		height:   450
		x_axis:   cuiqcharts.AxisConfig{ name: 'Substrate Concentration (mM)' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Activity (nmol/min/mg)' }
	)
	dose_conc   := ['0.5','1.0','2.0','4.0','8.0','16.0','32.0','64.0']
	dose_mean   := [12.3, 22.8, 38.4, 57.6, 74.1, 85.3, 91.7, 94.2]
	dose_sem_hi := [1.8,  2.4,  3.1,  3.8,  4.2,  3.9,  3.4,  2.9]
	dose_sem_lo := [1.5,  2.1,  2.8,  3.4,  3.9,  3.6,  3.1,  2.6]
	dose_chart.add_series(cuiqcharts.named_series('Activity', dose_conc, dose_mean))
	dose_chart.add_error_bars(cuiqcharts.ErrorBarsOverlay{
		series_name: 'Activity'
		plus:        dose_sem_hi
		minus:       dose_sem_lo
	})
	dose_chart.save('dose_response.html') or { eprintln('Error: ${err}') }
	println('Saved dose_response.html')

	// ── Area + control limits — API p95 latency monitoring ────────────────────
	mut latency_chart := cuiqcharts.area(
		title:    'API p95 Latency — 24-Hour Hourly View (UTC)'
		subtitle: 'Control limits derived from 30-day baseline; peak at business hours'
		colors:   .default_scheme
		width:    1000
		height:   400
		x_axis:   cuiqcharts.AxisConfig{ name: 'Hour (UTC)' }
		y_axis:   cuiqcharts.AxisConfig{ name: 'Latency (ms)' }
	)
	latency_hours := ['00','01','02','03','04','05','06','07','08','09','10','11',
	                  '12','13','14','15','16','17','18','19','20','21','22','23']
	latency_chart.add_series(cuiqcharts.named_series('p95', latency_hours, [
		42.0, 38.0, 35.0, 33.0, 34.0,  40.0,  68.0, 112.0, 145.0, 138.0, 131.0, 142.0,
		155.0, 148.0, 152.0, 144.0, 139.0, 143.0, 137.0, 118.0, 95.0, 74.0, 58.0, 48.0,
	]))
	latency_chart.set_control_limits(cuiqcharts.ControlLimitsOverlay{
		ucl: 160.0  cl: 95.0  lcl: 30.0
		ucl_label: 'UCL'  cl_label: 'Baseline'  lcl_label: 'LCL'
		cl_color: '#888888'
	})
	latency_chart.save('latency_control.html') or { eprintln('Error: ${err}') }
	println('Saved latency_control.html')
}
