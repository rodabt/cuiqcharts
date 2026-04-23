module cuiqcharts

import os

// RefLine adds a horizontal or vertical reference line to a chart.
pub struct RefLine {
pub:
	axis  string     = 'y'    // 'x' or 'y'
	value f64
	label string
	color string     = '#888888'
	dash  DashStyle  = .dashed
}

// Annotation adds a text label at a coordinate position.
pub struct Annotation {
pub:
	x     f64
	y     f64
	text  string
	color string = '#333333'
	size  int    = 12
}

// TreeNode is used for treemap charts.
pub struct TreeNode {
pub:
	name     string
	value    f64
	children []TreeNode
}

// ChartConfig holds all configuration for a chart.
// Uses @[params] to allow named-parameter construction:
//   cuiqcharts.bar(title: 'Revenue', theme: .dark, colors: .vibrant)
@[params]
pub struct ChartConfig {
pub:
	title    string
	subtitle string
	theme    Theme       = .light
	colors   ColorScheme = .latimes
	width    int         = 800
	height   int         = 400
	legend   LegendPos   = .top
	grid     bool        = true
	x_axis   AxisConfig
	y_axis   AxisConfig
	y2_axis  AxisConfig // secondary Y axis
	// Histogram options
	bins     int  = 20
	density  bool // overlay normal distribution curve on histogram
	// Interaction
	zoom           bool           // enable dataZoom
	tooltip        TooltipTrigger = .axis
	tooltip_format string
	// Overlays
	ref_lines   []RefLine
	annotations []Annotation
	// Trend line (least-squares regression) for line/scatter
	trend_line  bool
	trend_color string = 'rgba(220,50,50,0.7)'
	// Rolling average window size (number of data points), used by rolling_mean charts
	rolling_window int = 30
	// Data labels shown on bars, points, slices, and cells
	labels LabelConfig
}

// Chart is the main chart object. Use factory functions to create one.
pub struct Chart {
pub mut:
	config        ChartConfig
	chart_type    ChartType
	series        []Series
	ohlc          OHLCSeries // for candlestick charts
	tree          []TreeNode // for treemap charts
	running_avg   ?RunningAvgOverlay
	control_limits ?ControlLimitsOverlay
	error_bars    []ErrorBarsOverlay
}

// ─── Factory functions ─────────────────────────────────────────────────────────

pub fn line(cfg ChartConfig) Chart        { return Chart{ config: cfg, chart_type: .line } }
pub fn bar(cfg ChartConfig) Chart         { return Chart{ config: cfg, chart_type: .bar } }
pub fn hbar(cfg ChartConfig) Chart        { return Chart{ config: cfg, chart_type: .hbar } }
pub fn scatter(cfg ChartConfig) Chart     { return Chart{ config: cfg, chart_type: .scatter } }
pub fn pie(cfg ChartConfig) Chart         { return Chart{ config: cfg, chart_type: .pie } }
pub fn area(cfg ChartConfig) Chart        { return Chart{ config: cfg, chart_type: .area } }
pub fn histogram(cfg ChartConfig) Chart   { return Chart{ config: cfg, chart_type: .histogram } }
pub fn heatmap(cfg ChartConfig) Chart     { return Chart{ config: cfg, chart_type: .heatmap } }
pub fn bar_errorbar(cfg ChartConfig) Chart { return Chart{ config: cfg, chart_type: .bar_errorbar } }
pub fn rolling_mean(cfg ChartConfig) Chart { return Chart{ config: cfg, chart_type: .rolling_mean } }
pub fn line_ci(cfg ChartConfig) Chart      { return Chart{ config: cfg, chart_type: .line_ci } }
pub fn waterfall(cfg ChartConfig) Chart    { return Chart{ config: cfg, chart_type: .waterfall } }
pub fn funnel(cfg ChartConfig) Chart       { return Chart{ config: cfg, chart_type: .funnel } }
pub fn box_plot(cfg ChartConfig) Chart     { return Chart{ config: cfg, chart_type: .box_plot } }
pub fn bubble(cfg ChartConfig) Chart       { return Chart{ config: cfg, chart_type: .bubble } }
pub fn candlestick(cfg ChartConfig) Chart  { return Chart{ config: cfg, chart_type: .candlestick } }
pub fn treemap(cfg ChartConfig) Chart      { return Chart{ config: cfg, chart_type: .treemap } }

// ─── Data methods ──────────────────────────────────────────────────────────────

// add_series appends a data series to the chart.
pub fn (mut c Chart) add_series(s Series) {
	c.series << s
}

pub fn (mut c Chart) set_running_avg(cfg RunningAvgOverlay) {
	c.running_avg = cfg
}

pub fn (mut c Chart) set_control_limits(cfg ControlLimitsOverlay) {
	c.control_limits = cfg
}

pub fn (mut c Chart) add_error_bars(cfg ErrorBarsOverlay) {
	c.error_bars << cfg
}

// add_ohlc sets the OHLC data for a candlestick chart.
pub fn (mut c Chart) add_ohlc(s OHLCSeries) {
	c.ohlc = s
}

// set_tree sets the hierarchical data for a treemap chart.
pub fn (mut c Chart) set_tree(nodes []TreeNode) {
	c.tree = nodes
}

// ─── Output methods ────────────────────────────────────────────────────────────

// to_json returns the Vega-Lite spec JSON string for this chart.
pub fn (c Chart) to_json() string {
	return render_chart(c)
}

// to_html returns a complete standalone HTML page with the chart embedded.
pub fn (c Chart) to_html() string {
	return render_html(c)
}

// save writes the standalone HTML page to the given file path.
// It attempts to populate the local Vega cache (~/.cuiqviz/vega/) before writing;
// if the download fails the chart is still saved using CDN script tags.
pub fn (c Chart) save(path string) ! {
	ensure_vega_cache() or {}
	os.write_file(path, c.to_html())!
}
