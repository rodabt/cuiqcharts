module cuiqcharts

// Series holds data for one data series in a chart.
pub struct Series {
pub:
	name   string
	data   []f64    // Raw numeric values (histogram, simple numeric, box_plot)
	labels []string // Category labels paired with data (bar, line, area, pie, hbar)
	xy     [][]f64  // X,Y coordinate pairs (scatter, bubble)
	// Statistical extensions
	error_plus  []f64 // Upper error bound per data point
	error_minus []f64 // Lower error bound; if empty, mirrors error_plus
	// Per-series styling overrides
	color       string      // Hex color, e.g. '#FF0000'; empty = use palette rotation
	dash_style  DashStyle   = .solid
	marker      MarkerShape = .circle
	marker_size int         = 6
	line_width  f64         = 2.0
	opacity     f64         = 1.0
	// Bubble chart: size dimension (parallel to xy)
	sizes []f64
	// Secondary Y axis index (0 = primary, 1 = secondary)
	y_axis_index int
}

// new_series creates a series from raw numeric values (histograms, box plots).
pub fn new_series(name string, data []f64) Series {
	return Series{
		name: name
		data: data
	}
}

// named_series creates a labeled series pairing labels with values.
// Used for bar, line, area, pie, hbar, and other categorical charts.
pub fn named_series(name string, labels []string, data []f64) Series {
	return Series{
		name:   name
		labels: labels
		data:   data
	}
}

// xy_series creates a series of X,Y coordinate pairs (scatter).
pub fn xy_series(name string, xy [][]f64) Series {
	return Series{
		name: name
		xy:   xy
	}
}

// bubble_series creates a scatter series with a third size dimension.
pub fn bubble_series(name string, xy [][]f64, sizes []f64) Series {
	return Series{
		name:  name
		xy:    xy
		sizes: sizes
	}
}

// error_series creates a labeled series with pre-computed asymmetric error bounds.
// Used for bar_errorbar and line_ci charts.
// error_minus may be empty, in which case error_plus is used symmetrically.
pub fn error_series(name string, labels []string, data []f64, error_plus []f64, error_minus []f64) Series {
	return Series{
		name:        name
		labels:      labels
		data:        data
		error_plus:  error_plus
		error_minus: error_minus
	}
}

// OHLCSeries holds open/high/low/close data for candlestick charts.
pub struct OHLCSeries {
pub:
	name   string
	labels []string // date or time labels
	open   []f64
	high   []f64
	low    []f64
	close  []f64
}
