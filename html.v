module cuiqcharts

// html.v - Generates standalone HTML pages using Vega-Lite + vega-embed.
// Script tags point to the local cache (~/.cuiqviz/vega/) when available, CDN otherwise.

// render_html produces a complete, self-contained HTML page for a single chart.
pub fn render_html(c Chart) string {
	bg := bg_color(c.config.theme)
	tc := text_color(c.config.theme)
	spec_json := c.to_json()

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
#vis { display: inline-block; max-width: 100%; }
</style>
</head>
<body>
<div id="vis"></div>
<script>
vegaEmbed("#vis", ${spec_json}, {actions: true, renderer: "svg"});
</script>
</body>
</html>'
}
