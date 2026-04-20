module cuiqcharts

// AxisConfig controls the appearance and scale of a chart axis.
pub struct AxisConfig {
pub:
	name       string
	show       bool     = true
	axis_type  AxisType = .value
	// Range control (use has_min/has_max flags because V can't distinguish 0 from unset)
	min        f64
	max        f64
	has_min    bool
	has_max    bool
	log_base   f64    = 10
	// Label formatting
	format     string
	// Label display
	rotate     int    // label rotation in degrees (e.g. 45)
	interval   int    // tick interval; 0 = auto
	// Axis position override ('left' | 'right' | 'top' | 'bottom')
	position   string
	// Grid lines along this axis
	split_line bool   = true
}
