var Color = Color || {};

var specs = {
	title: {
		type: String,
		def: null
	},
	subtitle: {
		type: String,
		def: null
	},
	shadowSize: {
		type: Number,
		def: 4
	},
	defaultType: {
		type: String,
		def: 'lines',
		values: Object.keys(Flotr.graphTypes)
	},
	HtmlText: {
		type: Boolean,
		def: true
	},
	fontSize: {
		type: Number,
		def: 7.5
	},
	resolution: {
		type: Number,
		def: 1
	},
	legend: {
		_options: {
			title: "Legend",
			collapsed: true
		},
		show: {
			type: Boolean,
			def: true
		},
		noColumns: {
			type: Number,
			def: 1
		},
		labelFormatter: {
			type: Function,
			def: Prototype.K
		},
		labelBoxBorderColor: {
			type: Color,
			def: '#CCCCCC'
		},
		labelBoxWidth: {
			type: Number,
			def: 14
		},
		labelBoxHeight: {
			type: Number,
			def: 10
		},
		labelBoxMargin: {
			type: Number,
			def: 5
		},
		container: null,
		position: {
			type: String,
			def: 'nw',
			values: ['se', 'ne', 'sw', 'nw'],
			labels: ['Bottom right', 'Top right', 'Bottom left', 'Top left']
		},
		margin: {
			type: Number,
			def: 5
		},
		backgroundColor: {
			type: Color,
			def: null
		},
		backgroundOpacity: {
			type: Number,
			def: 0.85
		}
	},
	xaxis: {
		_options: {
			title: "x Axis",
			collapsed: true
		},
		ticks: null,
		showLabels: {
			type: Boolean,
			def: true
		},
		labelsAngle: {
			type: Number,
			def: 0
		},
		title: {
			type: String,
			def: null
		},
		titleAngle: {
			type: Number,
			def: 0
		},
		noTicks: {
			type: Number,
			def: 5
		},
		tickFormatter: {
			type: Function,
			def: Flotr.defaultTickFormatter
		},
		tickDecimals: {
			type: Number,
			def: null
		},
		min: {
			type: Number,
			def: null
		},
		max: {
			type: Number,
			def: null
		},
		autoscaleMargin: {
			type: Number,
			def: 0
		},
		color: {
			type: Color,
			def: null
		},
		mode: {
			type: String,
			def: 'normal',
			values: ['normal', 'time'],
			labels: ['Normal', 'Time']
		},
		timeFormat: {
			type: String,
			def: null
		}
	},
	x2axis: {
		_options: {
			title: "x2 Axis",
			collapsed: true
		},
		ticks: null,
		showLabels: {
			type: Boolean,
			def: true
		},
		labelsAngle: {
			type: Number,
			def: 0
		},
		title: {
			type: String,
			def: null
		},
		titleAngle: {
			type: Number,
			def: 0
		},
		noTicks: {
			type: Number,
			def: 5
		},
		tickFormatter: {
			type: Function,
			def: Flotr.defaultTickFormatter
		},
		tickDecimals: {
			type: Number,
			def: null
		},
		min: {
			type: Number,
			def: null
		},
		max: {
			type: Number,
			def: null
		},
		autoscaleMargin: {
			type: Number,
			def: 0
		},
		color: {
			type: Color,
			def: null
		},
		mode: {
			type: String,
			def: 'normal',
			values: ['normal', 'time'],
			labels: ['Normal', 'Time']
		},
		timeFormat: {
			type: String,
			def: null
		}
	},
	yaxis: {
		_options: {
			title: "y Axis",
			collapsed: true
		},
		ticks: null,
		showLabels: {
			type: Boolean,
			def: true
		},
		labelsAngle: {
			type: Number,
			def: 0
		},
		title: {
			type: String,
			def: null
		},
		titleAngle: {
			type: Number,
			def: 90
		},
		noTicks: {
			type: Number,
			def: 5
		},
		tickFormatter: {
			type: Function,
			def: Flotr.defaultTickFormatter
		},
		tickDecimals: {
			type: Number,
			def: null
		},
		min: {
			type: Number,
			def: null
		},
		max: {
			type: Number,
			def: null
		},
		autoscaleMargin: {
			type: Number,
			def: 0
		},
		color: {
			type: Color,
			def: null
		}
	},
	y2axis: {
		_options: {
			title: "y2 Axis",
			collapsed: true
		},
		ticks: null,
		showLabels: {
			type: Boolean,
			def: true
		},
		labelsAngle: {
			type: Number,
			def: 0
		},
		title: {
			type: String,
			def: null
		},
		titleAngle: {
			type: Number,
			def: 270
		},
		noTicks: {
			type: Number,
			def: 5
		},
		tickFormatter: {
			type: Function,
			def: Flotr.defaultTickFormatter
		},
		tickDecimals: {
			type: Number,
			def: null
		},
		min: {
			type: Number,
			def: null
		},
		max: {
			type: Number,
			def: null
		},
		autoscaleMargin: {
			type: Number,
			def: 0
		},
		color: {
			type: Color,
			def: null
		}
	},
	points: {
		_options: {
			title: "Points",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		radius: {
			type: Number,
			def: 3
		},
		lineWidth: {
			type: Number,
			def: 2
		},
		fill: {
			type: Boolean,
			def: true
		},
		fillColor: {
			type: Color,
			def: '#FFFFFF'
		},
		fillOpacity: {
			type: Number,
			def: 0.4
		}
	},
	lines: {
		_options: {
			title: "Line chart",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		lineWidth: {
			type: Number,
			def: 2
		},
		fill: {
			type: Boolean,
			def: false
		},
		fillColor: {
			type: Color,
			def: null
		},
		fillOpacity: {
			type: Number,
			def: 0.4
		}
	},
	bars: {
		_options: {
			title: "Bar chart",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		lineWidth: {
			type: Number,
			def: 2
		},
		barWidth: {
			type: Number,
			def: 1
		},
		fill: {
			type: Boolean,
			def: true
		},
		fillColor: {
			type: Color,
			def: null
		},
		fillOpacity: {
			type: Number,
			def: 0.4
		},
		horizontal: {
			type: Boolean,
			def: false
		},
		stacked: {
			type: Boolean,
			def: false
		},
		centered: {
			type: Boolean,
			def: true
		}
	},
	candles: {
		_options: {
			title: "Candle sticks",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		lineWidth: {
			type: Number,
			def: 1
		},
		wickLineWidth: {
			type: Number,
			def: 1
		},
		candleWidth: {
			type: Number,
			def: 0.6
		},
		fill: {
			type: Boolean,
			def: true
		},
		upFillColor: {
			type: Color,
			def: '#00A8F0'
		},
		downFillColor: {
			type: Color,
			def: '#CB4B4B'
		},
		fillOpacity: {
			type: Number,
			def: 0.5
		},
		barcharts: {
			type: Boolean,
			def: false
		}
	},
	pie: {
		_options: {
			title: "Pie chart",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		lineWidth: {
			type: Number,
			def: 1
		},
		fill: {
			type: Boolean,
			def: true
		},
		fillColor: {
			type: Color,
			def: null
		},
		fillOpacity: {
			type: Number,
			def: 0.6
		},
		explode: {
			type: Number,
			def: 6
		},
		sizeRatio: {
			type: Number,
			def: 0.6
		},
		startAngle: {
			type: Number,
			def: Math.PI / 4
		},
		labelFormatter: {
			type: Function,
			def: Flotr.defaultPieLabelFormatter
		}
		/*,
		 pie3D: {
		 type: Boolean,
		 def: false
		 },
		 pie3DviewAngle: {
		 type: Number,
		 def: (Math.PI / 2 * 0.8)
		 },
		 pie3DspliceThickness: {
		 type: Number,
		 def: 20
		 }*/
	},
	markers: {
		_options: {
			title: "Markers",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		lineWidth: {
			type: Number,
			def: 1
		},
		fill: {
			type: Boolean,
			def: false
		},
		fillColor: {
			type: Color,
			def: "#FFFFFF"
		},
		fillOpacity: {
			type: Number,
			def: 0.4
		},
		stroke: {
			type: Boolean,
			def: false
		},
		position: {
			type: String,
			def: 'ct',
			values: ['lt', 'ct', 'rt', 'lm', 'cm', 'rm', 'lb', 'cb', 'rb'],
			labels: ['Left top', 'Center top', 'Right top', 'Left middle', 'Center middle', 'Right middle', 'Left bottom', 'Center bottom', 'Right bottom']
		},
		labelFormatter: {
			type: Function,
			def: Flotr.defaultMarkerFormatter
		}
	},
	radar: {
		_options: {
			title: "Radar",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		lineWidth: {
			type: Number,
			def: 1
		},
		fill: {
			type: Boolean,
			def: true
		},
		fillOpacity: {
			type: Number,
			def: 0.4
		},
		radiusRatio: {
			type: Number,
			def: 0.9
		}
	},
	bubbles: {
		_options: {
			title: "Bubbles",
			collapsed: true,
			inherited: true
		},
		show: {
			type: Boolean,
			def: false
		},
		lineWidth: {
			type: Number,
			def: 2
		},
		fill: {
			type: Boolean,
			def: true
		},
		fillOpacity: {
			type: Number,
			def: 0.4
		},
		baseRadius: {
			type: Number,
			def: 2
		}
	},
	grid: {
		_options: {
			title: "Grid",
			collapsed: true
		},
		color: {
			type: Color,
			def: '#545454'
		},
		backgroundColor: {
			type: Color,
			def: null
		},
		tickColor: {
			type: Color,
			def: '#DDDDDD'
		},
		labelMargin: {
			type: Number,
			def: 3
		},
		verticalLines: {
			type: Boolean,
			def: true
		},
		horizontalLines: {
			type: Boolean,
			def: true
		},
		outlineWidth: {
			type: Number,
			def: 2
		},
		circular: {
			type: Boolean,
			def: false
		}
	},
	selection: {
		_options: {
			title: "Selection",
			collapsed: true
		},
		mode: {
			type: String,
			def: null,
			values: ['x', 'y', 'xy']
		},
		color: {
			type: Color,
			def: '#B6D9FF'
		},
		fps: {
			type: Number,
			def: 20
		}
	},
	crosshair: {
		_options: {
			title: "Crosshair",
			collapsed: true
		},
		mode: {
			type: String,
			def: null,
			values: ['x', 'y', 'xy']
		},
		color: {
			type: Color,
			def: '#FF0000'
		},
		hideCursor: {
			type: Boolean,
			def: true
		}
	},
	mouse: {
		_options: {
			title: "Mouse",
			collapsed: true,
			inherited: true
		},
		track: {
			type: Boolean,
			def: false
		},
		position: {
			type: String,
			def: 'se',
			values: ['se', 'ne', 'sw', 'nw'],
			labels: ['Bottom right', 'Top right', 'Bottom left', 'Top left']
		},
		relative: {
			type: Boolean,
			def: false
		},
		trackFormatter: {
			type: Function,
			def: Flotr.defaultTrackFormatter
		},
		margin: {
			type: Number,
			def: 5
		},
		lineColor: {
			type: Color,
			def: '#FF3F19'
		},
		trackDecimals: {
			type: Number,
			def: 1
		},
		sensibility: {
			type: Number,
			def: 2
		},
		radius: {
			type: Number,
			def: 3
		},
		fillColor: {
			type: Color,
			def: null
		},
		fillOpacity: {
			type: Number,
			def: 0.4
		}
	},
	spreadsheet: {
		_options: {
			title: "Spreadsheet",
			collapsed: true
		},
		show: {
			type: Boolean,
			def: false
		},
		tabGraphLabel: {
			type: String,
			def: 'Graph'
		},
		tabDataLabel: {
			type: String,
			def: 'Data'
		},
		toolbarDownload: {
			type: String,
			def: 'Download CSV'
		},
		toolbarSelectAll: {
			type: String,
			def: 'Select all'
		},
		csvFileSeparator: {
			type: String,
			def: ','
		},
		decimalSeparator: {
			type: String,
			def: '.'
		}
	}
};

var data = [{
	label: 'Serie 1',
	hide: false,
	id: 'serie-0',
  color: Flotr.defaultOptions.colors[0],
	data: [[0, 3.206, 3.474, 2.212, 2.698], [1, 2.698, 3.368, 2.59, 2.926], [2, 2.926, 3.328, 2.9, 3.258], [3, 3.258, 3.559, 2.802, 3.171], [4, 3.171, 4.14, 2.995, 3.473], [5, 3.473, 4.429, 3.268, 3.913], [6, 3.913, 4.745, 3.594, 3.905], [7, 3.905, 4.29, 3.273, 3.522], [8, 3.522, 3.732, 3.272, 3.62], [9, 3.62, 4.006, 2.888, 3.225], [10, 3.225, 3.774, 2.807, 3.182]]
}, {
	label: 'Serie 2',
	hide: false,
	id: 'serie-1',
  color: Flotr.defaultOptions.colors[1],
	data: [[0, 2.206, 4.047, 2.493, 4.023], [1, 4.023, 4.689, 3.058, 3.872], [2, 3.872, 4.371, 3.065, 3.924], [3, 3.924, 4.344, 3.042, 3.21], [4, 3.21, 3.741, 2.795, 2.855], [5, 2.855, 3.668, 2.807, 3.648], [6, 3.648, 3.713, 3.249, 3.308], [7, 3.308, 4.055, 2.389, 3.663], [8, 3.663, 4.392, 3.235, 3.592], [9, 3.592, 4.584, 2.857, 4.235], [10, 4.235, 5.128, 4.023, 4.138]]
}, {
	label: 'Serie 3',
	hide: false,
	id: 'serie-2',
  color: Flotr.defaultOptions.colors[2],
	data: [[0, 4.206, 3.266, 3.142, 3.146], [1, 3.146, 3.551, 2.524, 3.289], [2, 3.289, 4.288, 2.493, 2.999], [3, 2.999, 3.053, 2.211, 2.225], [4, 2.225, 2.418, 2.222, 2.242], [5, 2.242, 2.795, 1.388, 2.303], [6, 2.303, 2.846, 1.764, 2.731], [7, 2.731, 3.263, 2.098, 2.609], [8, 2.609, 2.917, 2.077, 2.735], [9, 2.735, 2.773, 2.152, 2.771], [10, 2.771, 2.849, 1.823, 2.335]]
}, {
	label: 'Serie 4',
	hide: false,
	id: 'serie-3',
  color: Flotr.defaultOptions.colors[3],
	data: [[0, 3.206, 3.96, 2.944, 3.77], [1, 3.77, 4.408, 3.215, 3.984], [2, 3.984, 4.466, 3.832, 4.1], [3, 4.1, 4.914, 4.073, 4.466], [4, 4.466, 4.498, 3.664, 3.862], [5, 3.862, 4.089, 3.599, 3.635], [6, 3.635, 4.331, 3.052, 4.051], [7, 4.051, 4.427, 3.503, 4.402], [8, 4.402, 4.477, 3.534, 3.753], [9, 3.753, 3.89, 2.996, 3.291], [10, 3.291, 3.679, 3.187, 3.255]]
}, {
	label: 'Serie 5',
	hide: false,
	id: 'serie-4',
  color: Flotr.defaultOptions.colors[4],
	data: [[0, 2.706, 4.177, 3.012, 4.084], [1, 4.084, 5.039, 3.831, 4.18], [2, 4.18, 4.688, 3.226, 3.399], [3, 3.399, 4.247, 2.644, 3.675], [4, 3.675, 4.377, 2.908, 3.705], [5, 3.705, 4.38, 2.916, 3.067], [6, 3.067, 3.528, 2.673, 3.007], [7, 3.007, 3.833, 2.68, 3.381], [8, 3.381, 3.529, 3.276, 3.446], [9, 3.446, 3.49, 3.403, 3.486], [10, 3.486, 3.663, 2.865, 3.594]]
}];

for (var i = 0; i < 5; i++) {
	var d = data[i].data;
	for (var j = 0; j < d.length; j++) {
		var l = d[j];
		for (var k = 0; k < l.length; k++) {
			l[k] = parseFloat(l[k].toFixed(3));
		}
	}
}
