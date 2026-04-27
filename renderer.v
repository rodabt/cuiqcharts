module cuiqcharts

// renderer.v - Generates Vega-Lite JSON spec objects from Chart structs.

const vl_schema = 'https://vega.github.io/schema/vega-lite/v5.json'

// ─── Color helpers ─────────────────────────────────────────────────────────────

fn color_palette(cs ColorScheme) []string {
	return match cs {
		// LA Times data visualization style — category range from latimes.json
		.latimes        { ['#ec8431','#829eb1','#c89d29','#3580b1','#adc839','#ab7fb4'] }
		// Paul Tol "Bright" — perceptually distinct, print-safe, widely used in scientific publishing
		.default_scheme { ['#4477AA','#EE6677','#228833','#CCBB44','#66CCEE','#AA3377','#BBBBBB'] }
		// Paul Tol "Muted" — lower saturation, better for filled areas and dense charts
		.pastel         { ['#88CCEE','#CC6677','#DDCC77','#117733','#332288','#AA4499','#44AA99','#999933','#882255','#661100'] }
		// Paul Tol "Dark" — high contrast for dark backgrounds or small marks
		.dark_scheme    { ['#222255','#225555','#225522','#666633','#663333','#555566','#000000'] }
		// Okabe-Ito — the gold standard for colorblind accessibility (Nature Methods recommended)
		.colorblind     { ['#E69F00','#56B4E9','#009E73','#F0E442','#0072B2','#D55E00','#CC79A7','#000000'] }
		// Paul Tol "Vibrant" — for line charts and scatter plots needing high contrast
		.vibrant        { ['#0077BB','#33BBEE','#009988','#EE7733','#CC3311','#EE3377','#BBBBBB'] }
		// Tableau 10 — industry standard, designed by data visualization researchers
		.tableau        { ['#4E79A7','#F28E2B','#E15759','#76B7B2','#59A14F','#EDC948','#B07AA1'] }
		// ColorBrewer "Set1" adapted — strong hues for categorical distinctions on maps and charts
		.material       { ['#E41A1C','#377EB8','#4DAF4A','#984EA3','#FF7F00','#A65628','#F781BF','#999999'] }
	}
}

fn vl_color_range(cs ColorScheme) string {
	colors := color_palette(cs)
	mut parts := []string{}
	for c in colors {
		parts << json_str(c)
	}
	return '[${parts.join(',')}]'
}

fn primary_color(cs ColorScheme) string {
	return color_palette(cs)[0]
}

fn text_color(t Theme) string {
	return match t {
		.dark  { '#E0E0E0' }
		.sepia { '#5c4033' }
		.light { '#333333' }
	}
}

fn bg_color(t Theme) string {
	return match t {
		.dark  { '#1e1e1e' }
		.sepia { '#f4eee8' }
		.light { '#ffffff' }
	}
}

fn grid_color(t Theme) string {
	return match t {
		.dark  { '#404040' }
		.sepia { '#d4c5b0' }
		.light { '#dedede' }
	}
}

// ─── JSON helpers ──────────────────────────────────────────────────────────────

fn json_str(s string) string {
	mut r := ''
	for c in s {
		match c {
			`"` { r += '\\"' }
			`\\` { r += '\\\\' }
			`\n` { r += '\\n' }
			`\r` { r += '\\r' }
			`\t` { r += '\\t' }
			else { r += c.ascii_str() }
		}
	}
	return '"${r}"'
}

fn f64_to_str(v f64) string {
	return '${v}'
}

// vl_title returns the Vega-Lite "title" JSON value.
// When a subtitle is present it uses the object form {"text":…,"subtitle":…}.
fn vl_title(cfg ChartConfig) string {
	if cfg.subtitle.len == 0 {
		return json_str(cfg.title)
	}
	return '{"text":${json_str(cfg.title)},"subtitle":${json_str(cfg.subtitle)}}'
}

// ─── Theme / config block ──────────────────────────────────────────────────────

fn vl_config(c ChartConfig) string {
	if c.colors == .latimes {
		return vl_config_latimes()
	}
	tc := json_str(text_color(c.theme))
	gc := json_str(grid_color(c.theme))
	bg := json_str(bg_color(c.theme))
	return '"background":${bg},"config":{'
		+ '"axis":{"labelColor":${tc},"titleColor":${tc},"labelAngle":0,"labelFontSize":11,"titleFontSize":11,"titleFontWeight":"normal","titlePadding":8,"grid":true,"gridColor":${gc},"gridOpacity":0.35},'
		+ '"axisX":{"domain":false,"ticks":false},'
		+ '"axisY":{"domain":false,"ticks":false,"tickCount":5},'
		+ '"legend":{"labelColor":${tc},"titleColor":${tc},"labelFontSize":11,"titleFontSize":11,"titleFontWeight":"normal","padding":6,"strokeColor":"transparent"},'
		+ '"title":{"color":${tc},"fontSize":14,"fontWeight":"normal","anchor":"start","offset":12},'
		+ '"bar":{"cornerRadiusTopLeft":2,"cornerRadiusTopRight":2},'
		+ '"line":{"strokeWidth":2},'
		+ '"point":{"size":35,"filled":true},'
		+ '"arc":{"stroke":"white","strokeWidth":1},'
		+ '"view":{"stroke":"transparent","padding":{"left":5,"right":5,"top":5,"bottom":5}}}'
}

fn vl_config_latimes() string {
	// Faithfully mirrors configs/latimes.json.
	// Key visual traits: horizontal Y-axis title (titleAngle:0, titleX/Y positioning),
	// fixed 45px Y-label extent, Benton Gothic fonts, square legend symbols.
	// No grid:false/domain:false overrides — let Vega-Lite defaults apply per scale type.
	return '"background":"#ffffff","config":{'
		+ '"axis":{"labelFont":"Benton Gothic, sans-serif","labelFontSize":11.5,"titleFont":"Benton Gothic Bold, sans-serif","titleFontSize":13,"titleFontWeight":"normal","grid":true,"gridColor":"#dedede","gridOpacity":1},'
		+ '"axisX":{"labelAngle":0,"labelPadding":4,"tickSize":3},'
		+ '"axisY":{"labelBaseline":"middle","maxExtent":45,"minExtent":45,"tickSize":2,"titleAlign":"left","titleAngle":0,"titleX":-45,"titleY":-11},'
		+ '"legend":{"labelFont":"Benton Gothic, sans-serif","labelFontSize":11.5,"titleFont":"Benton Gothic Bold, sans-serif","titleFontSize":13,"titleFontWeight":"normal","symbolType":"square"},'
		+ '"title":{"color":"#000000","font":"Benton Gothic Bold, sans-serif","fontSize":22,"fontWeight":"normal","anchor":"start"},'
		+ '"arc":{"fill":"#82c6df"},'
		+ '"area":{"fill":"#82c6df"},'
		+ '"line":{"stroke":"#82c6df","strokeWidth":2},'
		+ '"rect":{"fill":"#82c6df"},'
		+ '"symbol":{"fill":"#82c6df","size":30},'
		+ '"range":{"category":["#ec8431","#829eb1","#c89d29","#3580b1","#adc839","#ab7fb4"],"heatmap":["#fbf2c7","#f9e39c","#f8d36e","#f4bb6a","#e68a4f","#d15a40","#ab4232"]},'
		+ '"view":{"stroke":"transparent"}}'
}

// vl_color_scale returns the Vega-Lite color scale JSON fragment for a color scheme.
// If series_color is non-empty, uses that fixed color instead.
fn vl_color_scale(cfg ChartConfig, series_color string) string {
	if series_color != '' {
		return json_str(series_color)
	}
	return '{"range":${vl_color_range(cfg.colors)}}'
}

// ─── Label helpers ─────────────────────────────────────────────────────────────

fn label_size(lc LabelConfig) int {
	return if lc.size > 0 { lc.size } else { 12 }
}

// label_color returns the effective label color.
// inside=true defaults to white; inside=false defaults to the theme text color.
fn label_color(cfg ChartConfig, inside bool) string {
	if cfg.labels.color != '' { return cfg.labels.color }
	return if inside { '#ffffff' } else { text_color(cfg.theme) }
}

// label_inside returns true when the resolved position is inside a bar/slice/cell.
fn label_inside(lc LabelConfig, default_inside bool) bool {
	return match lc.position {
		.auto    { default_inside }
		.inside  { true }
		else     { false }
	}
}

// ─── Legend ────────────────────────────────────────────────────────────────────

fn vl_legend(pos LegendPos) string {
	return match pos {
		.none   { 'null' }
		.top    { '{"orient":"top","direction":"horizontal","title":null}' }
		.bottom { '{"orient":"bottom","direction":"horizontal","title":null}' }
		.left   { '{"orient":"left","title":null}' }
		.right  { '{"orient":"right","title":null}' }
	}
}

// vl_fmt_axis appends a Vega-Lite "axis" format fragment for quantitative encodings.
// Usage: ',"y":{"field":"y","type":"quantitative",...${vl_fmt_axis(c.config.y_axis)}}'.
fn vl_fmt_axis(ac AxisConfig) string {
	if ac.format == '' { return '' }
	return ',"axis":{"format":${json_str(ac.format)}}'
}

// vl_zoom_params returns Vega-Lite params that enable brush-to-zoom / pan when zoom is set.
fn vl_zoom_params(cfg ChartConfig) string {
	if !cfg.zoom { return '' }
	return ',"params":[{"name":"grid","select":"interval","bind":"scales"}]'
}

// ─── Data serialization ────────────────────────────────────────────────────────

// series_to_xy_data flattens named series into [{x,y,s}] for bar/line/area/hbar.
fn series_to_xy_data(series []Series) string {
	mut rows := []string{}
	for s in series {
		for i, lbl in s.labels {
			if i >= s.data.len { break }
			rows << '{"x":${json_str(lbl)},"y":${f64_to_str(s.data[i])},"s":${json_str(s.name)}}'
		}
	}
	return '[${rows.join(',')}]'
}

// series_to_scatter_data flattens xy series into [{x,y,s}].
fn series_to_scatter_data(series []Series) string {
	mut rows := []string{}
	for s in series {
		for pt in s.xy {
			if pt.len < 2 { continue }
			rows << '{"x":${f64_to_str(pt[0])},"y":${f64_to_str(pt[1])},"s":${json_str(s.name)}}'
		}
	}
	return '[${rows.join(',')}]'
}

// series_to_pie_data flattens the first named series into [{x,y}].
fn series_to_pie_data(series []Series) string {
	if series.len == 0 { return '[]' }
	s := series[0]
	mut rows := []string{}
	for i, lbl in s.labels {
		if i >= s.data.len { break }
		rows << '{"x":${json_str(lbl)},"y":${f64_to_str(s.data[i])}}'
	}
	return '[${rows.join(',')}]'
}

// series_to_hist_data flattens the first raw series into [{v}].
fn series_to_hist_data(series []Series) string {
	if series.len == 0 { return '[]' }
	s := series[0]
	mut rows := []string{}
	for v in s.data {
		rows << '{"v":${f64_to_str(v)}}'
	}
	return '[${rows.join(',')}]'
}

// series_to_errorbar_data flattens named series into [{x,y,y_upper,y_lower,s}] for bar_errorbar / line_ci.
fn series_to_errorbar_data(series []Series) string {
	mut rows := []string{}
	for s in series {
		for i, lbl in s.labels {
			if i >= s.data.len { break }
			mean := s.data[i]
			ep := if i < s.error_plus.len { s.error_plus[i] } else { f64(0) }
			em := if s.error_minus.len > 0 && i < s.error_minus.len { s.error_minus[i] } else { ep }
			upper := mean + ep
			lower := mean - em
			rows << '{"x":${json_str(lbl)},"y":${f64_to_str(mean)},"y_upper":${f64_to_str(upper)},"y_lower":${f64_to_str(lower)},"s":${json_str(s.name)}}'
		}
	}
	return '[${rows.join(',')}]'
}

// series_to_waterfall_data converts the first named series into [{x,amount}] for waterfall charts.
fn series_to_waterfall_data(series []Series) string {
	if series.len == 0 { return '[]' }
	s := series[0]
	mut rows := []string{}
	for i, lbl in s.labels {
		if i >= s.data.len { break }
		rows << '{"x":${json_str(lbl)},"amount":${f64_to_str(s.data[i])}}'
	}
	return '[${rows.join(',')}]'
}

// series_to_heatmap_data converts named series into [{x,y,v}] where y = series name.
fn series_to_heatmap_data(series []Series) string {
	mut rows := []string{}
	for s in series {
		for i, lbl in s.labels {
			if i >= s.data.len { break }
			rows << '{"x":${json_str(lbl)},"y":${json_str(s.name)},"v":${f64_to_str(s.data[i])}}'
		}
	}
	return '[${rows.join(',')}]'
}

// ─── Chart renderers ───────────────────────────────────────────────────────────

fn render_bar(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_xy_data(c.series)
	multi := c.series.len > 1
	color_enc := if multi {
		'"color":{"field":"s","type":"nominal","legend":${vl_legend(c.config.legend)},"scale":{"range":${vl_color_range(c.config.colors)}}}'
	} else {
		col := if c.series[0].color != '' { c.series[0].color } else { primary_color(c.config.colors) }
		'"color":{"value":${json_str(col)}}'
	}
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	y_fmt := vl_fmt_axis(c.config.y_axis)
	offset := if multi { ',"xOffset":{"field":"s","type":"nominal"}' } else { '' }
	enc := '{"x":{"field":"x","type":"nominal","title":${json_str(x_title)},"axis":{"labelAngle":0}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)}${y_fmt}}${offset},${color_enc}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	base := '{"mark":{"type":"bar","tooltip":true},"encoding":${enc}}'
	mut layers := [base]
	if c.config.labels.show {
		inside := label_inside(c.config.labels, false)
		lsize := label_size(c.config.labels)
		lcolor := label_color(c.config, inside)
		dy := if inside { '4' } else { '-8' }
		baseline := if inside { 'top' } else { 'bottom' }
		text_mark := '{"type":"text","dy":${dy},"align":"center","baseline":"${baseline}","fontSize":${lsize}}'
		text_enc := '{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"},"text":{"field":"y","type":"quantitative","format":","},"color":{"value":${json_str(lcolor)}}${offset}}'
		layers << '{"mark":${text_mark},"encoding":${text_enc}}'
	}
	layers << overlay_layers(c, 'x', 'nominal')
	zoom := vl_zoom_params(c.config)
	if layers.len == 1 {
		return '{${header}${zoom},"mark":{"type":"bar","tooltip":true},"encoding":${enc},${vl_config(c.config)}}'
	}
	return '{${header}${zoom},"layer":[${layers.join(',')}],${vl_config(c.config)}}'
}

fn render_hbar(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_xy_data(c.series)
	multi := c.series.len > 1
	color_enc := if multi {
		'"color":{"field":"s","type":"nominal","legend":${vl_legend(c.config.legend)},"scale":{"range":${vl_color_range(c.config.colors)}}}'
	} else {
		col := if c.series[0].color != '' { c.series[0].color } else { primary_color(c.config.colors) }
		'"color":{"value":${json_str(col)}}'
	}
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	x_fmt := vl_fmt_axis(c.config.x_axis)
	enc := '{"y":{"field":"x","type":"nominal","title":${json_str(y_title)},"sort":"-x"},"x":{"field":"y","type":"quantitative","title":${json_str(x_title)}${x_fmt}},${color_enc}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	zoom := vl_zoom_params(c.config)
	if !c.config.labels.show {
		return '{${header}${zoom},"mark":{"type":"bar","tooltip":true},"encoding":${enc},${vl_config(c.config)}}'
	}
	inside := label_inside(c.config.labels, false)
	lsize := label_size(c.config.labels)
	lcolor := label_color(c.config, inside)
	dx := if inside { '-4' } else { '5' }
	align := if inside { 'right' } else { 'left' }
	bar_layer := '{"mark":{"type":"bar","tooltip":true},"encoding":${enc}}'
	text_mark := '{"type":"text","dx":${dx},"align":"${align}","baseline":"middle","fontSize":${lsize}}'
	text_enc := '{"y":{"field":"x","type":"nominal","sort":"-x"},"x":{"field":"y","type":"quantitative"},"text":{"field":"y","type":"quantitative","format":","},"color":{"value":${json_str(lcolor)}}}'
	text_layer := '{"mark":${text_mark},"encoding":${text_enc}}'
	return '{${header}${zoom},"layer":[${bar_layer},${text_layer}],${vl_config(c.config)}}'
}

fn render_line(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_xy_data(c.series)
	multi := c.series.len > 1
	legend := if c.config.direct_labels { 'null' } else { vl_legend(c.config.legend) }
	color_enc := if multi {
		'"color":{"field":"s","type":"nominal","legend":${legend},"scale":{"range":${vl_color_range(c.config.colors)}}}'
	} else {
		col := if c.series[0].color != '' { c.series[0].color } else { primary_color(c.config.colors) }
		'"color":{"value":${json_str(col)}}'
	}
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	y_fmt := vl_fmt_axis(c.config.y_axis)
	enc := '{"x":{"field":"x","type":"nominal","title":${json_str(x_title)}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)}${y_fmt}},${color_enc}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	base := '{"mark":{"type":"line","point":true,"tooltip":true},"encoding":${enc}}'
	mut layers := [base]
	if c.config.labels.show {
		lsize := label_size(c.config.labels)
		lcolor := label_color(c.config, false)
		text_mark := '{"type":"text","dy":-10,"align":"center","baseline":"bottom","fontSize":${lsize}}'
		text_enc := '{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"},"text":{"field":"y","type":"quantitative","format":","},"color":{"value":${json_str(lcolor)}}}'
		layers << '{"mark":${text_mark},"encoding":${text_enc}}'
	}
	layers << overlay_layers(c, 'x', 'nominal')
	if c.config.direct_labels && multi {
		palette := color_palette(c.config.colors)
		for i, s in c.series {
			if s.labels.len == 0 { continue }
			col := if s.color != '' { s.color } else { palette[i % palette.len] }
			last_lbl := s.labels[s.labels.len - 1]
			f1 := '"filter":{"field":"x","equal":${json_str(last_lbl)}}'
			f2 := '"filter":{"field":"s","equal":${json_str(s.name)}}'
			tm := '{"type":"text","align":"left","dx":6,"baseline":"middle","fontSize":11}'
			te := '{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"},"text":{"value":${json_str(s.name)}},"color":{"value":${json_str(col)}}}'
			layers << '{"transform":[{${f1}},{${f2}}],"mark":${tm},"encoding":${te}}'
		}
	}
	zoom := vl_zoom_params(c.config)
	if layers.len == 1 {
		return '{${header}${zoom},"mark":{"type":"line","point":true,"tooltip":true},"encoding":${enc},${vl_config(c.config)}}'
	}
	return '{${header}${zoom},"layer":[${layers.join(',')}],${vl_config(c.config)}}'
}

fn render_area(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_xy_data(c.series)
	multi := c.series.len > 1
	legend := if c.config.direct_labels { 'null' } else { vl_legend(c.config.legend) }
	color_enc := if multi {
		'"color":{"field":"s","type":"nominal","legend":${legend},"scale":{"range":${vl_color_range(c.config.colors)}}}'
	} else {
		col := if c.series[0].color != '' { c.series[0].color } else { primary_color(c.config.colors) }
		'"color":{"value":${json_str(col)}}'
	}
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	y_fmt := vl_fmt_axis(c.config.y_axis)
	enc := '{"x":{"field":"x","type":"nominal","title":${json_str(x_title)}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)}${y_fmt}},${color_enc}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	base := '{"mark":{"type":"area","line":true,"point":false,"tooltip":true,"opacity":0.4},"encoding":${enc}}'
	mut layers := [base]
	if c.config.labels.show {
		lsize := label_size(c.config.labels)
		lcolor := label_color(c.config, false)
		text_mark := '{"type":"text","dy":-10,"align":"center","baseline":"bottom","fontSize":${lsize}}'
		text_enc := '{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"},"text":{"field":"y","type":"quantitative","format":","},"color":{"value":${json_str(lcolor)}}}'
		layers << '{"mark":${text_mark},"encoding":${text_enc}}'
	}
	layers << overlay_layers(c, 'x', 'nominal')
	if c.config.direct_labels && multi {
		palette := color_palette(c.config.colors)
		for i, s in c.series {
			if s.labels.len == 0 { continue }
			col := if s.color != '' { s.color } else { palette[i % palette.len] }
			last_lbl := s.labels[s.labels.len - 1]
			f1 := '"filter":{"field":"x","equal":${json_str(last_lbl)}}'
			f2 := '"filter":{"field":"s","equal":${json_str(s.name)}}'
			tm := '{"type":"text","align":"left","dx":6,"baseline":"middle","fontSize":11}'
			te := '{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"},"text":{"value":${json_str(s.name)}},"color":{"value":${json_str(col)}}}'
			layers << '{"transform":[{${f1}},{${f2}}],"mark":${tm},"encoding":${te}}'
		}
	}
	zoom := vl_zoom_params(c.config)
	if layers.len == 1 {
		return '{${header}${zoom},"mark":{"type":"area","line":true,"point":false,"tooltip":true,"opacity":0.6},"encoding":${enc},${vl_config(c.config)}}'
	}
	return '{${header}${zoom},"layer":[${layers.join(',')}],${vl_config(c.config)}}'
}

fn render_scatter(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_scatter_data(c.series)
	multi := c.series.len > 1
	color_enc := if multi {
		'"color":{"field":"s","type":"nominal","legend":${vl_legend(c.config.legend)},"scale":{"range":${vl_color_range(c.config.colors)}}}'
	} else {
		col := if c.series[0].color != '' { c.series[0].color } else { primary_color(c.config.colors) }
		'"color":{"value":${json_str(col)}}'
	}
	x_title := c.config.x_axis.name
	y_title := c.config.y_axis.name
	x_fmt := vl_fmt_axis(c.config.x_axis)
	y_fmt := vl_fmt_axis(c.config.y_axis)
	enc := '{"x":{"field":"x","type":"quantitative","title":${json_str(x_title)}${x_fmt}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)}${y_fmt}},${color_enc}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	base := '{"mark":{"type":"point","filled":true,"size":55,"opacity":0.75,"tooltip":true},"encoding":${enc}}'
	mut layers := [base]
	if c.config.labels.show {
		lsize := label_size(c.config.labels)
		lcolor := label_color(c.config, false)
		text_mark := '{"type":"text","dy":-10,"align":"center","baseline":"bottom","fontSize":${lsize}}'
		text_enc := '{"x":{"field":"x","type":"quantitative"},"y":{"field":"y","type":"quantitative"},"text":{"field":"y","type":"quantitative","format":","},"color":{"value":${json_str(lcolor)}}}'
		layers << '{"mark":${text_mark},"encoding":${text_enc}}'
	}
	layers << overlay_layers(c, 'x', 'quantitative')
	zoom := vl_zoom_params(c.config)
	if layers.len == 1 {
		return '{${header}${zoom},"mark":{"type":"point","filled":true,"size":55,"opacity":0.75,"tooltip":true},"encoding":${enc},${vl_config(c.config)}}'
	}
	// In a layered spec, bind:"scales" params must live inside the base unit-spec
	// layer, not at the compound view level. Vega-Lite cannot project a selection
	// onto x/y channels from a compound spec, so top-level params silently break zoom.
	if c.config.zoom {
		layers[0] = '{"params":[{"name":"grid","select":"interval","bind":"scales"}],"mark":{"type":"point","filled":true,"size":55,"opacity":0.75,"tooltip":true},"encoding":${enc}}'
	}
	return '{${header},"layer":[${layers.join(',')}],${vl_config(c.config)}}'
}

fn render_pie(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_pie_data(c.series)
	enc := '{"theta":{"field":"y","type":"quantitative"},"color":{"field":"x","type":"nominal","legend":${vl_legend(c.config.legend)},"scale":{"range":${vl_color_range(c.config.colors)}}}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	zoom := vl_zoom_params(c.config)
	if !c.config.labels.show {
		return '{${header}${zoom},"mark":{"type":"arc","tooltip":true},"encoding":${enc},${vl_config(c.config)}}'
	}
	lsize := label_size(c.config.labels)
	inside := label_inside(c.config.labels, true)
	lcolor := label_color(c.config, inside)
	r := if inside { c.config.height / 3 } else { c.config.height / 2 + 20 }
	calc_expr := "format(datum.y / datum.__total, '.0%')"
	pie_layer := '{"mark":{"type":"arc","tooltip":true},"encoding":${enc}}'
	text_mark := '{"type":"text","radius":${r},"fontSize":${lsize}}'
	text_transforms := '[{"window":[{"op":"sum","field":"y","as":"__total"}],"frame":[null,null]},{"calculate":${json_str(calc_expr)},"as":"__pct"}]'
	text_enc := '{"theta":{"field":"y","type":"quantitative","stack":true},"text":{"field":"__pct","type":"nominal"},"color":{"value":${json_str(lcolor)}}}'
	text_layer := '{"transform":${text_transforms},"mark":${text_mark},"encoding":${text_enc}}'
	return '{${header}${zoom},"layer":[${pie_layer},${text_layer}],${vl_config(c.config)}}'
}

fn render_histogram(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_hist_data(c.series)
	col := primary_color(c.config.colors)
	step := '"bin":{"maxbins":${c.config.bins}}'
	y_fmt := vl_fmt_axis(c.config.y_axis)
	enc := '{"x":{"field":"v","type":"quantitative",${step},"title":"Value"},"y":{"aggregate":"count","type":"quantitative","title":"Count"${y_fmt}}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	zoom := vl_zoom_params(c.config)
	if !c.config.labels.show {
		return '{${header}${zoom},"mark":{"type":"bar","tooltip":true,"color":${json_str(col)}},"encoding":${enc},${vl_config(c.config)}}'
	}
	lsize := label_size(c.config.labels)
	lcolor := label_color(c.config, false)
	bar_layer := '{"mark":{"type":"bar","tooltip":true,"color":${json_str(col)}},"encoding":${enc}}'
	text_mark := '{"type":"text","dy":-6,"align":"center","baseline":"bottom","fontSize":${lsize}}'
	text_enc := '{"x":{"field":"v","type":"quantitative",${step}},"y":{"aggregate":"count","type":"quantitative"},"text":{"aggregate":"count","type":"quantitative"},"color":{"value":${json_str(lcolor)}}}'
	text_layer := '{"mark":${text_mark},"encoding":${text_enc}}'
	return '{${header}${zoom},"layer":[${bar_layer},${text_layer}],${vl_config(c.config)}}'
}

fn render_heatmap(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_heatmap_data(c.series)
	// Sequential gradient: latimes uses its warm ramp; others use near-white → primary palette color.
	hi, lo := if c.config.colors == .latimes {
		'#ab4232', '#fbf2c7'
	} else {
		color_palette(c.config.colors)[0], '#f0f0f0'
	}
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	enc := '{"x":{"field":"x","type":"nominal","title":${json_str(x_title)}},"y":{"field":"y","type":"nominal","title":${json_str(y_title)}},"color":{"field":"v","type":"quantitative","scale":{"range":[${json_str(lo)},${json_str(hi)}]},"legend":{"title":"Value"}}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	zoom := vl_zoom_params(c.config)
	if !c.config.labels.show {
		return '{${header}${zoom},"mark":{"type":"rect","tooltip":true},"encoding":${enc},${vl_config(c.config)}}'
	}
	lsize := label_size(c.config.labels)
	lcolor := label_color(c.config, true)
	rect_layer := '{"mark":{"type":"rect","tooltip":true},"encoding":${enc}}'
	text_mark := '{"type":"text","align":"center","baseline":"middle","fontSize":${lsize}}'
	text_enc := '{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"nominal"},"text":{"field":"v","type":"quantitative","format":".2f"},"color":{"value":${json_str(lcolor)}}}'
	text_layer := '{"mark":${text_mark},"encoding":${text_enc}}'
	return '{${header}${zoom},"layer":[${rect_layer},${text_layer}],${vl_config(c.config)}}'
}

fn render_bar_errorbar(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_errorbar_data(c.series)
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	y_fmt := vl_fmt_axis(c.config.y_axis)
	// Build per-series layers: points first, then errorbars (so errorbars render on top)
	palette := color_palette(c.config.colors)
	mut all_layers := []string{}
	for i, s in c.series {
		col := if s.color != '' { s.color } else { palette[i % palette.len] }
		filter := '"filter":{"field":"s","equal":${json_str(s.name)}}'
		all_layers << '{"mark":{"type":"point","filled":true,"size":80},"transform":[{${filter}}],"encoding":{"x":{"field":"x","type":"nominal","title":${json_str(x_title)},"axis":{"labelAngle":0}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)}${y_fmt}},"color":{"value":${json_str(col)}}}}'
		all_layers << '{"mark":{"type":"errorbar"},"transform":[{${filter}}],"encoding":{"x":{"field":"x","type":"nominal"},"y":{"field":"y_lower","type":"quantitative","title":${json_str(y_title)}},"y2":{"field":"y_upper"},"color":{"value":${json_str(col)}}}}'
	}
	if c.config.labels.show {
		lsize := label_size(c.config.labels)
		lcolor := label_color(c.config, false)
		for i, s in c.series {
			col := if s.color != '' { s.color } else { palette[i % palette.len] }
			filter := '"filter":{"field":"s","equal":${json_str(s.name)}}'
			_ = col
			all_layers << '{"mark":{"type":"text","dy":-12,"align":"center","baseline":"bottom","fontSize":${lsize}},"transform":[{${filter}}],"encoding":{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"},"text":{"field":"y","type":"quantitative","format":","},"color":{"value":${json_str(lcolor)}}}}'
		}
	}
	zoom := vl_zoom_params(c.config)
	return '{"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}},"layer":[${all_layers.join(',')}]${zoom},${vl_config(c.config)}}'
}

fn render_rolling_mean(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_xy_data(c.series)
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	y_fmt := vl_fmt_axis(c.config.y_axis)
	win := c.config.rolling_window
	half := win / 2
	trend_col := primary_color(c.config.colors)
	raw_col := if c.series[0].color != '' { c.series[0].color } else { '#aaaaaa' }
	transform := '"transform":[{"window":[{"op":"mean","field":"y","as":"rolling_mean"}],"frame":[${-half},${half}]}]'
	raw_layer := '{"mark":{"type":"point","opacity":0.3,"size":30},"encoding":{"x":{"field":"x","type":"nominal","title":${json_str(x_title)}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)}${y_fmt}},"color":{"value":${json_str(raw_col)}}}}'
	mean_layer := '{${transform},"mark":{"type":"line","size":2},"encoding":{"x":{"field":"x","type":"nominal"},"y":{"field":"rolling_mean","type":"quantitative"${y_fmt}},"color":{"value":${json_str(trend_col)}}}}'
	mut rm_layers := [raw_layer, mean_layer]
	if c.config.labels.show {
		lsize := label_size(c.config.labels)
		lcolor := label_color(c.config, false)
		text_mark := '{"type":"text","dy":-10,"align":"center","baseline":"bottom","fontSize":${lsize}}'
		text_enc := '{"x":{"field":"x","type":"nominal"},"y":{"field":"rolling_mean","type":"quantitative"},"text":{"field":"rolling_mean","type":"quantitative","format":".1f"},"color":{"value":${json_str(lcolor)}}}'
		rm_layers << '{${transform},"mark":${text_mark},"encoding":${text_enc}}'
	}
	zoom := vl_zoom_params(c.config)
	return '{"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}},"layer":[${rm_layers.join(',')}]${zoom},${vl_config(c.config)}}'
}

fn render_line_ci(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_errorbar_data(c.series)
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	y_fmt := vl_fmt_axis(c.config.y_axis)
	palette := color_palette(c.config.colors)
	mut layers := []string{}
	for i, s in c.series {
		col := if s.color != '' { s.color } else { palette[i % palette.len] }
		filter := '"filter":{"field":"s","equal":${json_str(s.name)}}'
		band := '{"mark":{"type":"errorband","opacity":0.2},"transform":[{${filter}}],"encoding":{"x":{"field":"x","type":"nominal","title":${json_str(x_title)}},"y":{"field":"y_lower","type":"quantitative","title":${json_str(y_title)}${y_fmt}},"y2":{"field":"y_upper"},"color":{"value":${json_str(col)}}}}'
		line := '{"mark":{"type":"line","point":true},"transform":[{${filter}}],"encoding":{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"${y_fmt}},"color":{"value":${json_str(col)}}}}'
		layers << band
		layers << line
	}
	if c.config.labels.show {
		lsize := label_size(c.config.labels)
		lcolor := label_color(c.config, false)
		for i, s in c.series {
			col := if s.color != '' { s.color } else { palette[i % palette.len] }
			filter := '"filter":{"field":"s","equal":${json_str(s.name)}}'
			_ = col
			layers << '{"mark":{"type":"text","dy":-10,"align":"center","baseline":"bottom","fontSize":${lsize}},"transform":[{${filter}}],"encoding":{"x":{"field":"x","type":"nominal"},"y":{"field":"y","type":"quantitative"},"text":{"field":"y","type":"quantitative","format":".1f"},"color":{"value":${json_str(lcolor)}}}}'
		}
	}
	zoom := vl_zoom_params(c.config)
	return '{"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}},"layer":[${layers.join(',')}]${zoom},${vl_config(c.config)}}'
}

fn render_waterfall(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_waterfall_data(c.series)
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { 'Value' }
	// Determine first/last labels for total bar coloring
	s := c.series[0]
	// Use raw label values (single-quoted in Vega expression) to avoid double-quote JSON conflicts
	first_lbl := if s.labels.len > 0 { s.labels[0] } else { '' }
	last_lbl  := if s.labels.len > 0 { s.labels[s.labels.len - 1] } else { '' }
	// Window transforms compute cumulative sum and previous sum
	transforms := '[{"window":[{"op":"sum","field":"amount","as":"sum"}],"frame":[null,0]},' +
		'{"window":[{"op":"lead","field":"x","as":"next_x"}],"frame":[0,1]},' +
		'{"calculate":"datum.sum - datum.amount","as":"previous_sum"},' +
		'{"calculate":"(datum.x === \'${first_lbl}\' || datum.x === \'${last_lbl}\') ? \\"Total\\" : datum.amount > 0 ? \\"Gain\\" : \\"Loss\\"","as":"indicator"},' +
		// Total bars (first/last) anchor to baseline 0 so they span the full running sum.
		'{"calculate":"datum.indicator === \\"Total\\" ? 0 : datum.previous_sum","as":"bar_start"},' +
		'{"calculate":"(datum.bar_start + datum.sum) / 2","as":"text_mid"},' +
		'{"calculate":"datum.indicator === \\"Total\\" ? datum.sum : datum.amount","as":"display_val"}]'
	// Bar layer: Total bars span 0→sum; Gain/Loss bars span bar_start→sum.
	bar_layer := '{"mark":{"type":"bar","width":{"band":0.6},"cornerRadiusTopLeft":0,"cornerRadiusTopRight":0},"encoding":{"x":{"field":"x","type":"ordinal","title":${json_str(x_title)},"sort":null},"y":{"field":"bar_start","type":"quantitative","title":${json_str(y_title)}},"y2":{"field":"sum"},"color":{"field":"indicator","type":"nominal","scale":{"domain":["Total","Gain","Loss"],"range":["#b0bec5","#66bb6a","#ef5350"]},"legend":{"title":""}}}}'
	// Rule layer: horizontal connectors between consecutive bars
	rule_layer := '{"mark":{"type":"rule","color":"#444444","xOffset":{"band":0.8},"x2Offset":{"band":-0.8}},"encoding":{"x":{"field":"x","type":"ordinal","sort":null},"x2":{"field":"next_x"},"y":{"field":"sum","type":"quantitative"}}}'
	// Text layer: show amounts on bars (always visible; LabelConfig tunes style)
	wl_size := if c.config.labels.show { label_size(c.config.labels) } else { 11 }
	text_layer := '{"mark":{"type":"text","dy":0,"align":"center","baseline":"middle","fontSize":${wl_size}},"encoding":{"x":{"field":"x","type":"ordinal","sort":null},"y":{"field":"text_mid","type":"quantitative"},"text":{"field":"display_val","type":"quantitative","format":".0f"},"color":{"value":"#ffffff"}}}'
	zoom := vl_zoom_params(c.config)
	return '{"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}},"transform":${transforms},"layer":[${bar_layer},${rule_layer},${text_layer}]${zoom},${vl_config(c.config)}}'
}

fn render_funnel(c Chart) string {
	if c.series.len == 0 { return '{}' }
	// Build data with "o" order field: converted series (index 0) = 0, drop-offs = 1+
	// so Vega-Lite stacks converted at the bottom and drop-offs above.
	mut rows := []string{}
	for si, s in c.series {
		for i, lbl in s.labels {
			if i >= s.data.len { break }
			rows << '{"x":${json_str(lbl)},"y":${f64_to_str(s.data[i])},"s":${json_str(s.name)},"o":${si}}'
		}
	}
	data := '[${rows.join(',')}]'
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { 'Stage' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { 'Count' }
	converted_name := c.series[0].name
	opacity_enc := '"opacity":{"condition":{"test":"datum.s === \'${converted_name}\'","value":1.0},"value":0.3}'
	color_enc := '"color":{"field":"s","type":"nominal","legend":${vl_legend(c.config.legend)},"scale":{"range":${vl_color_range(c.config.colors)}}}'
	order_enc := '"order":{"field":"o","type":"quantitative"}'
	bar_enc := '{"x":{"field":"x","type":"ordinal","title":${json_str(x_title)},"sort":null,"axis":{"labelAngle":0}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)},"stack":"zero"},${color_enc},${opacity_enc},${order_enc}}'
	header := '"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}'
	zoom := vl_zoom_params(c.config)
	if !c.config.labels.show {
		return '{${header}${zoom},"mark":{"type":"bar","tooltip":true},"encoding":${bar_enc},${vl_config(c.config)}}'
	}
	lsize := label_size(c.config.labels)
	lcolor := label_color(c.config, true)
	bar_layer := '{"mark":{"type":"bar","tooltip":true},"encoding":${bar_enc}}'
	// Stack transform computes y0/y1 segment boundaries (matching bar sort order),
	// midpoint centers the label, joinaggregate provides the stage total for %.
	calc_label := "format(datum.y, ',') + ' (' + format(datum.y / datum.__total, '.0%') + ')'"
	transforms := '[' +
		'{"joinaggregate":[{"op":"sum","field":"y","as":"__total"}],"groupby":["x"]},' +
		'{"stack":"y","groupby":["x"],"sort":[{"field":"o","order":"ascending"}],"as":["__y0","__y1"],"offset":"zero"},' +
		'{"calculate":"(datum.__y0 + datum.__y1) / 2","as":"__ymid"},' +
		'{"calculate":${json_str(calc_label)},"as":"__label"}' +
		']'
	text_mark := '{"type":"text","align":"center","baseline":"middle","fontSize":${lsize}}'
	text_enc := '{"x":{"field":"x","type":"ordinal","sort":null},"y":{"field":"__ymid","type":"quantitative"},"text":{"field":"__label","type":"nominal"},"color":{"value":${json_str(lcolor)}}}'
	text_layer := '{"transform":${transforms},"mark":${text_mark},"encoding":${text_enc}}'
	return '{${header}${zoom},"layer":[${bar_layer},${text_layer}],${vl_config(c.config)}}'
}

// ─── Box plot ──────────────────────────────────────────────────────────────────

// series_to_boxplot_data emits one row per value: {x: series_name, y: value, s: series_name}.
// Vega-Lite's boxplot mark then aggregates over y grouped by x.
fn series_to_boxplot_data(series []Series) string {
	mut rows := []string{}
	for s in series {
		for v in s.data {
			rows << '{"x":${json_str(s.name)},"y":${f64_to_str(v)},"s":${json_str(s.name)}}'
		}
	}
	return '[${rows.join(',')}]'
}

fn render_box_plot(c Chart) string {
	if c.series.len == 0 { return '{}' }
	data := series_to_boxplot_data(c.series)
	x_title := if c.config.x_axis.name != '' { c.config.x_axis.name } else { '' }
	y_title := if c.config.y_axis.name != '' { c.config.y_axis.name } else { '' }
	y_fmt := vl_fmt_axis(c.config.y_axis)
	multi := c.series.len > 1
	color_enc := if multi {
		'"color":{"field":"s","type":"nominal","legend":${vl_legend(c.config.legend)},"scale":{"range":${vl_color_range(c.config.colors)}}}'
	} else {
		col := primary_color(c.config.colors)
		'"color":{"value":${json_str(col)}}'
	}
	zoom := vl_zoom_params(c.config)
	return '{"\$schema":${json_str(vl_schema)},"title":${vl_title(c.config)},"width":${c.config.width},"height":${c.config.height},"data":{"values":${data}}${zoom},"mark":{"type":"boxplot","extent":"min-max","tooltip":true},"encoding":{"x":{"field":"x","type":"nominal","title":${json_str(x_title)}},"y":{"field":"y","type":"quantitative","title":${json_str(y_title)}${y_fmt}},${color_enc}},${vl_config(c.config)}}'
}

// ─── Overlay helpers ───────────────────────────────────────────────────────────

fn vl_dash(d DashStyle) string {
	return match d {
		.solid  { '[]' }
		.dashed { '[6,3]' }
		.dotted { '[2,3]' }
	}
}

// ols_trend_nominal computes one OLS trend line per series and returns layer JSON strings.
// Used when x is nominal — Vega-Lite's regression transform requires a quantitative x field.
fn ols_trend_nominal(c Chart, x_field string, color_json string) []string {
	mut trend_layers := []string{}
	for s in c.series {
		n := s.data.len
		n_labels := if s.labels.len < n { s.labels.len } else { n }
		if n_labels < 2 { continue }
		nf := f64(n_labels)
		mut sum_x := 0.0
		mut sum_y := 0.0
		mut sum_xx := 0.0
		mut sum_xy := 0.0
		for i in 0..n_labels {
			xi := f64(i)
			yi := s.data[i]
			sum_x += xi
			sum_y += yi
			sum_xx += xi * xi
			sum_xy += xi * yi
		}
		denom := nf * sum_xx - sum_x * sum_x
		if denom == 0.0 { continue }
		slope := (nf * sum_xy - sum_x * sum_y) / denom
		intercept := (sum_y - slope * sum_x) / nf
		mut rows := []string{}
		for i in 0..n_labels {
			pred := intercept + slope * f64(i)
			rows << '{"${x_field}":${json_str(s.labels[i])},"__trend":${f64_to_str(pred)}}'
		}
		data := '[${rows.join(',')}]'
		trend_layers << '{"data":{"values":${data}},"mark":{"type":"line","color":${color_json},"strokeDash":[4,4],"size":2},"encoding":{"x":{"field":"${x_field}","type":"nominal"},"y":{"field":"__trend","type":"quantitative"}}}'
	}
	return trend_layers
}

// overlay_layers returns Vega-Lite layer JSON strings for any overlays set on c.
// x_field and x_type are the field name and type used by the base chart's x encoding.
fn overlay_layers(c Chart, x_field string, x_type string) []string {
	mut layers := []string{}

	// Running average
	if ra := c.running_avg {
		col := if ra.color != '' { ra.color } else { primary_color(c.config.colors) }
		half := ra.window / 2
		transform := '[{"window":[{"op":"mean","field":"y","as":"__ravg"}],"frame":[${-half},${half}]}]'
		mark := '{"type":"line","color":${json_str(col)},"strokeDash":${vl_dash(ra.dash)},"size":2}'
		enc := '{"x":{"field":"${x_field}","type":"${x_type}"},"y":{"field":"__ravg","type":"quantitative"}}'
		layers << '{"transform":${transform},"mark":${mark},"encoding":${enc}}'
	}

	// Control limits — three rule layers + three label layers (UCL, CL, LCL)
	if cl := c.control_limits {
		cl_vals   := [cl.ucl,       cl.cl,       cl.lcl      ]
		cl_colors := [cl.ucl_color, cl.cl_color, cl.lcl_color]
		cl_labels := [cl.ucl_label, cl.cl_label, cl.lcl_label]
		for i in 0..3 {
			val := cl_vals[i]
			col := cl_colors[i]
			lbl := cl_labels[i]
			layers << '{"mark":{"type":"rule","color":${json_str(col)},"strokeDash":[6,3]},"encoding":{"y":{"datum":${f64_to_str(val)},"type":"quantitative"}}}'
			layers << '{"mark":{"type":"text","align":"right","dx":-4,"dy":-6,"fontSize":11,"color":${json_str(col)}},"encoding":{"x":{"aggregate":"max","field":"${x_field}","type":"${x_type}"},"y":{"datum":${f64_to_str(val)},"type":"quantitative"},"text":{"value":${json_str(lbl)}}}}'
		}
	}

	// Error bars — one errorbar layer per ErrorBarsOverlay
	for eb in c.error_bars {
		mut s_idx := -1
		for i, s in c.series {
			if s.name == eb.series_name { s_idx = i; break }
		}
		if s_idx < 0 { continue }
		s := c.series[s_idx]
		mut eb_rows := []string{}
		for i, lbl in s.labels {
			if i >= s.data.len { break }
			yv    := s.data[i]
			ep    := if i < eb.plus.len  { eb.plus[i]  } else { f64(0) }
			em    := if eb.minus.len > 0 && i < eb.minus.len { eb.minus[i] } else { ep }
			upper := yv + ep
			lower := yv - em
			eb_rows << '{"${x_field}":${json_str(lbl)},"__upper":${f64_to_str(upper)},"__lower":${f64_to_str(lower)}}'
		}
		eb_data := '[${eb_rows.join(',')}]'
		enc := '{"x":{"field":"${x_field}","type":"${x_type}"},"y":{"field":"__lower","type":"quantitative"},"y2":{"field":"__upper"}}'
		layers << '{"data":{"values":${eb_data}},"mark":{"type":"errorbar","ticks":true},"encoding":${enc}}'
	}

	// Reference lines — horizontal (y-axis) or vertical (x-axis) rules with optional labels
	for rl in c.config.ref_lines {
		col := json_str(rl.color)
		dash := vl_dash(rl.dash)
		if rl.axis == 'x' {
			layers << '{"mark":{"type":"rule","color":${col},"strokeDash":${dash}},"encoding":{"x":{"datum":${f64_to_str(rl.value)},"type":"quantitative"}}}'
			if rl.label != '' {
				layers << '{"mark":{"type":"text","align":"left","dx":4,"dy":-8,"fontSize":11,"color":${col}},"encoding":{"x":{"datum":${f64_to_str(rl.value)},"type":"quantitative"},"y":{"aggregate":"max","field":"y","type":"quantitative"},"text":{"value":${json_str(rl.label)}}}}'
			}
		} else {
			layers << '{"mark":{"type":"rule","color":${col},"strokeDash":${dash}},"encoding":{"y":{"datum":${f64_to_str(rl.value)},"type":"quantitative"}}}'
			if rl.label != '' {
				layers << '{"mark":{"type":"text","align":"right","dx":-4,"dy":-6,"fontSize":11,"color":${col}},"encoding":{"x":{"aggregate":"max","field":"${x_field}","type":"${x_type}"},"y":{"datum":${f64_to_str(rl.value)},"type":"quantitative"},"text":{"value":${json_str(rl.label)}}}}'
			}
		}
	}

	// Annotations — text labels positioned at fixed (x, y) data coordinates
	for ann in c.config.annotations {
		col := json_str(ann.color)
		layers << '{"mark":{"type":"text","align":"center","baseline":"bottom","fontSize":${ann.size},"color":${col}},"encoding":{"x":{"datum":${f64_to_str(ann.x)},"type":"quantitative"},"y":{"datum":${f64_to_str(ann.y)},"type":"quantitative"},"text":{"value":${json_str(ann.text)}}}}'
	}

	// Trend line (least-squares regression)
	if c.config.trend_line {
		col := json_str(c.config.trend_color)
		if x_type == 'quantitative' {
			layers << '{"transform":[{"regression":"y","on":"x"}],"mark":{"type":"line","color":${col},"strokeDash":[4,4],"size":2},"encoding":{"x":{"field":"x","type":"quantitative"},"y":{"field":"y","type":"quantitative"}}}'
		} else {
			layers << ols_trend_nominal(c, x_field, col)
		}
	}

	return layers
}

// inject_overlays wraps a flat spec into a layer spec when overlays are present.
// base_layer is the existing mark+encoding JSON object (without outer braces as a layer).
// header is the top-level fields (schema, title, width, height, data).
fn inject_overlays(c Chart, header string, base_layer string, x_field string, x_type string) string {
	extra := overlay_layers(c, x_field, x_type)
	if extra.len == 0 {
		return ''  // signal: no overlays, caller should use flat spec
	}
	mut all := [base_layer]
	all << extra
	return '{${header},"layer":[${all.join(',')}],${vl_config(c.config)}}'
}

// ─── unsupported ───────────────────────────────────────────────────────────────

// unsupported returns a placeholder spec for chart types not yet implemented.
fn unsupported_chart(ct ChartType) string {
	name := ct.str()
	return '{"\$schema":${json_str(vl_schema)},"title":${json_str('Chart type ${name} is not supported in cuiqcharts')},"width":400,"height":200,"data":{"values":[]},"mark":"point","encoding":{}}'
}

// ─── Dispatcher ────────────────────────────────────────────────────────────────

pub fn render_chart(c Chart) string {
	return match c.chart_type {
		.bar          { render_bar(c) }
		.hbar         { render_hbar(c) }
		.line         { render_line(c) }
		.area         { render_area(c) }
		.scatter      { render_scatter(c) }
		.pie          { render_pie(c) }
		.histogram    { render_histogram(c) }
		.heatmap      { render_heatmap(c) }
		.bar_errorbar { render_bar_errorbar(c) }
		.rolling_mean { render_rolling_mean(c) }
		.line_ci      { render_line_ci(c) }
		.waterfall    { render_waterfall(c) }
		.funnel       { render_funnel(c) }
		.box_plot     { render_box_plot(c) }
		else          { unsupported_chart(c.chart_type) }
	}
}
