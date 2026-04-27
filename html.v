module cuiqcharts

// html.v - Generates standalone HTML pages using Vega-Lite + vega-embed.
// Script tags point to the local cache (~/.cuiqviz/vega/) when available, CDN otherwise.

// render_html produces a complete, self-contained HTML page for a single chart.
// The chart title and subtitle are rendered as HTML elements above the chart container;
// the Vega-Lite spec itself is emitted without a title to avoid duplication.
pub fn render_html(c Chart) string {
	bg := bg_color(c.config.theme)
	tc := text_color(c.config.theme)
	// Suppress title inside the VL spec — render it as HTML instead.
	mut no_title := c
	no_title.config = ChartConfig{ ...c.config, title: '', subtitle: '' }
	spec_json := render_chart(no_title)

	title_html    := if c.config.title    != '' { '<div class="chart-title">${c.config.title}</div>\n' }    else { '' }
	subtitle_html := if c.config.subtitle != '' { '<div class="chart-subtitle">${c.config.subtitle}</div>\n' } else { '' }

	return '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${c.config.title}</title>
${vega_script_tags()}
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { background: ${bg}; color: ${tc}; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 32px; }
.chart-title { font-size: 22px; font-weight: 600; margin-bottom: 4px; }
.chart-subtitle { font-size: 14px; opacity: 0.7; margin-bottom: 12px; }
#vis { display: inline-block; max-width: 100%; }
</style>
</head>
<body>
${title_html}${subtitle_html}<div id="vis"></div>
<script>
vegaEmbed("#vis", ${spec_json}, {actions: true, renderer: "svg"});
</script>
</body>
</html>'
}
