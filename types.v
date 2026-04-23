module cuiqcharts

pub enum ChartType {
	line
	bar
	hbar
	scatter
	pie
	area
	histogram
	heatmap
	// Statistical / layered charts
	bar_errorbar  // bar chart with error bars
	rolling_mean  // line rolling average over raw scatter
	line_ci       // line chart with confidence interval band
	// Implemented chart types
	waterfall
	funnel
	// Unsupported in this release — kept for API compatibility
	box_plot
	bubble
	candlestick
	treemap
}

pub enum Theme {
	light
	dark
	sepia
}

pub enum ColorScheme {
	latimes        // LA Times data visualization style (default)
	default_scheme
	pastel
	dark_scheme
	vibrant
	// Data-science / accessible palettes
	colorblind // Okabe-Ito 8-color palette
	material   // Material Design
	tableau    // Tableau 10
}

pub enum LegendPos {
	top
	bottom
	left
	right
	none
}

pub enum AxisType {
	category  // categorical labels (default for X on bar/line)
	value     // continuous numeric (default for Y)
	log_scale // logarithmic scale
	time      // time/date axis
}

pub enum MarkerShape {
	circle
	rect
	triangle
	diamond
	pin
	arrow
	none
}

pub enum DashStyle {
	solid
	dashed
	dotted
}

pub enum TooltipTrigger {
	axis // hover over axis line (bar, line) — default
	item // hover over individual item (scatter, pie)
	none
}

pub struct RunningAvgOverlay {
pub:
	window int      = 7
	color  string           // empty = first palette color
	label  string   = 'Rolling Avg'
	dash   DashStyle = .solid
}

pub struct ControlLimitsOverlay {
pub:
	ucl       f64
	cl        f64
	lcl       f64
	ucl_color string = '#e53935'
	cl_color  string = '#1e88e5'
	lcl_color string = '#e53935'
	ucl_label string = 'UCL'
	cl_label  string = 'CL'
	lcl_label string = 'LCL'
}

pub struct ErrorBarsOverlay {
pub:
	series_name string
	plus        []f64
	minus       []f64 // empty = symmetric (reuses plus values)
}

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
	color    string // empty = auto-contrast: white inside, theme text color outside
	position LabelPos = .auto
}
