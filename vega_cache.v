module cuiqcharts

import os
import net.http

const vega_cache_dir = os.join_path(os.home_dir(), '.cuiqviz', 'vega')

struct VegaLib {
	filename string
	url      string
}

const vega_libs = [
	VegaLib{'vega-5.min.js',       'https://cdn.jsdelivr.net/npm/vega@5/build/vega.min.js'},
	VegaLib{'vega-lite-5.min.js',  'https://cdn.jsdelivr.net/npm/vega-lite@5/build/vega-lite.min.js'},
	VegaLib{'vega-embed-6.min.js', 'https://cdn.jsdelivr.net/npm/vega-embed@6/build/vega-embed.min.js'},
]

// ensure_vega_cache downloads any missing Vega library files to ~/.cuiqviz/vega/.
pub fn ensure_vega_cache() ! {
	os.mkdir_all(vega_cache_dir)!
	for lib in vega_libs {
		path := os.join_path(vega_cache_dir, lib.filename)
		if os.exists(path) { continue }
		resp := http.get(lib.url)!
		os.write_file(path, resp.body)!
	}
}

// vega_script_tags returns inline <script> blocks from the local cache when available,
// falling back to CDN <script src="..."> tags otherwise.
// Inline embedding avoids all file:// cross-origin restrictions (including WSL).
pub fn vega_script_tags() string {
	mut blocks := []string{}
	for lib in vega_libs {
		path := os.join_path(vega_cache_dir, lib.filename)
		if !os.exists(path) {
			// At least one file is missing — fall back to CDN for all three.
			return '<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>'
		}
		js := os.read_file(path) or { return cdn_fallback() }
		blocks << '<script>${js}</script>'
	}
	return blocks.join('\n')
}

fn cdn_fallback() string {
	return '<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>'
}
