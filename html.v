module cuiqcharts

// html.v - Generates standalone HTML pages using Vega-Lite + vega-embed.
// Script tags point to the local cache (~/.cuiqviz/vega/) when available, CDN otherwise.

// render_html produces a complete, self-contained HTML page for a single chart.
pub fn render_html(c Chart) string {
	bg := bg_color(c.config.theme)
	tc := text_color(c.config.theme)
	spec_json := c.to_json()
	title := c.config.title

	sub_html := if c.config.subtitle.len > 0 {
		'<p class="subtitle">${c.config.subtitle}</p>'
	} else {
		''
	}

	return '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${title}</title>
${vega_script_tags()}
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { background: ${bg}; color: ${tc}; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 32px; }
h1 { font-size: 1.5rem; font-weight: 600; margin-bottom: 6px; color: ${tc}; }
p.subtitle { font-size: 0.875rem; opacity: 0.65; margin-bottom: 20px; }
#vis { display: inline-block; max-width: 100%; }
</style>
</head>
<body>
<h1>${title}</h1>
${sub_html}
<div id="vis"></div>
<script>
vegaEmbed("#vis", ${spec_json}, {actions: true, renderer: "svg"});
</script>
</body>
</html>'
}
