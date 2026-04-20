module cuiqcharts

import os

// DashboardChart wraps a Chart with its grid span setting.
pub struct DashboardChart {
pub:
	chart Chart
	span  int = 1 // Number of grid columns this chart spans
}

// Dashboard holds multiple charts arranged in a responsive grid layout.
pub struct Dashboard {
pub mut:
	title    string
	subtitle string
	theme    Theme = .light
	columns  int   = 2
	gap_px   int   = 20
	charts   []DashboardChart
}

// new_dashboard creates a new dashboard with the given title.
pub fn new_dashboard(title string) Dashboard {
	return Dashboard{
		title: title
	}
}

// add_chart appends a chart to the dashboard.
// span controls how many grid columns the chart occupies (default 1).
pub fn (mut d Dashboard) add_chart(c Chart, span int) {
	d.charts << DashboardChart{
		chart: c
		span:  span
	}
}

// to_html returns a complete standalone HTML page with all charts.
pub fn (d Dashboard) to_html() string {
	return render_dashboard_html(d)
}

// save writes the dashboard HTML to the given file path.
pub fn (d Dashboard) save(path string) ! {
	os.write_file(path, d.to_html())!
}

fn render_dashboard_html(d Dashboard) string {
	bg := bg_color(d.theme)
	tc := text_color(d.theme)

	// Build chart containers and inline specs
	mut containers := ''
	mut spec_inits := ''
	for i, dc in d.charts {
		span_style := if dc.span > 1 { 'grid-column:span ${dc.span};' } else { '' }
		height := dc.chart.config.height
		spec_json := dc.chart.to_json()
		containers += '<div class="db-item" style="${span_style}">
  <div id="vc_${i}" style="width:100%;height:${height}px;"></div>
</div>\n'
		spec_inits += '  vegaEmbed("#vc_${i}", ${spec_json}, {actions: true, renderer: "svg"});\n'
	}

	sub_html := if d.subtitle.len > 0 { '<p class="subtitle">${d.subtitle}</p>' } else { '' }

	return '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${d.title}</title>
${vega_script_tags()}
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { background: ${bg}; color: ${tc}; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 32px; }
h1 { font-size: 1.75rem; font-weight: 700; margin-bottom: 6px; color: ${tc}; }
p.subtitle { font-size: 0.875rem; opacity: 0.65; margin-bottom: 24px; }
.db-grid { display: grid; grid-template-columns: repeat(${d.columns}, 1fr); gap: ${d.gap_px}px; }
.db-item { background: rgba(128,128,128,0.06); border-radius: 10px; padding: 16px; }
@media (max-width: 768px) { .db-grid { grid-template-columns: 1fr; } .db-item { grid-column: 1 !important; } }
</style>
</head>
<body>
<h1>${d.title}</h1>
${sub_html}
<div class="db-grid">
${containers}
</div>
<script>
${spec_inits}
</script>
</body>
</html>'
}
