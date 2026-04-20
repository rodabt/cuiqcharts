module cuiqcharts

import os
import strconv

// input.v - Data loading helpers for CSV and JSON files.
// No external dependencies — uses V's built-in os and strconv.

// series_from_csv reads a CSV file and returns one Series per data column.
// The first row is treated as a header. The first column becomes the labels.
// All remaining columns become separate named series.
//
// Example CSV:
//   month,revenue,costs
//   Jan,120,80
//   Feb,145,90
//
// Returns: [Series{name:"revenue",labels:["Jan","Feb"],...}, Series{name:"costs",...}]
pub fn series_from_csv(path string) ![]Series {
	raw := os.read_file(path) or { return error('cannot read file: ${path}') }
	lines := raw.split_into_lines().filter(it.trim_space().len > 0)
	if lines.len < 2 {
		return error('CSV file must have a header row and at least one data row')
	}

	headers := lines[0].split(',').map(it.trim_space())
	if headers.len < 2 {
		return error('CSV must have at least 2 columns (labels + 1 data column)')
	}

	mut labels := []string{}
	mut data_cols := [][]f64{len: headers.len - 1, init: []f64{}}

	for row_idx := 1; row_idx < lines.len; row_idx++ {
		cells := lines[row_idx].split(',').map(it.trim_space())
		labels << if cells.len > 0 { cells[0] } else { '' }
		for col_i := 1; col_i < headers.len; col_i++ {
			cell := if col_i < cells.len { cells[col_i] } else { '0' }
			val := strconv.atof64(cell) or { 0.0 }
			data_cols[col_i - 1] << val
		}
	}

	mut result := []Series{}
	for col_i, col_name in headers[1..] {
		result << Series{
			name:   col_name
			labels: labels
			data:   data_cols[col_i]
		}
	}
	return result
}

// series_from_json reads a JSON array of objects and extracts one series.
// label_key is the field used for category labels, value_key for numeric values.
//
// Example JSON:
//   [{"month":"Jan","revenue":120},{"month":"Feb","revenue":145}]
//
// series_from_json('data.json', 'month', 'revenue')
// → Series{name:"revenue", labels:["Jan","Feb"], data:[120,145]}
pub fn series_from_json(path string, label_key string, value_key string) !Series {
	raw := os.read_file(path) or { return error('cannot read file: ${path}') }
	content := raw.trim_space()

	if !content.starts_with('[') {
		return error('JSON file must contain a top-level array')
	}

	mut labels := []string{}
	mut data := []f64{}

	inner := content.trim_string_left('[').trim_string_right(']')
	objects := inner.split('},{').map(it.trim('{').trim('}').trim_space())

	for obj in objects {
		mut label_val := ''
		mut num_val := 0.0
		pairs := obj.split('",')
		for raw_pair in pairs {
			pair := raw_pair.trim_space()
			colon := pair.index_u8(`:`)
			if colon < 0 { continue }
			raw_key := pair[..colon].trim('"').trim_space()
			raw_val := pair[colon + 1..].trim_space()
			if raw_key == label_key {
				label_val = raw_val.trim('"')
			} else if raw_key == value_key {
				num_val = strconv.atof64(raw_val.trim('"')) or { 0.0 }
			}
		}
		if label_val.len > 0 {
			labels << label_val
			data << num_val
		}
	}

	if labels.len == 0 {
		return error('no records found for key "${label_key}" in ${path}')
	}

	return Series{
		name:   value_key
		labels: labels
		data:   data
	}
}
