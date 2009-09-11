function insertElement(object, title, name, container){
	var input;
	switch (object.type) {
		case String:
			if (!object.values) {
				input = new Element('input', {
					type: 'text',
					value: object.def
				});
			}
			else {
				input = new Element('select');
				$A(object.values).each(function(v, i){
					var o = new Element('option', {
						value: v,
						selected: object.def == v
					});
					o.innerHTML = (object.labels && object.labels[i]) || v;
					input.appendChild(o);
				});
			}
			break;
		case Function:
			input = new Element('textarea', {
				cols: 30,
				rows: 3
			}).update(object.def);
			break;
		case Number:
			input = new Element('input', {
				type: 'text',
				value: object.def,
				size: 2
			});
			break;
		case Color:
			input = new Element('input', {
				type: 'text',
				value: object.def,
				size: 8
			});
			break;
		case Boolean:
			input = new Element('input', {
				type: 'checkbox',
				checked: object.def
			});
			break;
	}
	input.name = name;
	input.disabled = "disabled";
	var activator = new Element('input', {
		type: 'checkbox',
		style: 'float: left;'
	}).observe('click', function(){
		input.disabled = !activator.checked;
		input.up('label')[activator.checked ? 'addClassName' : 'removeClassName']('active');
	});
	var line = new Element('div', {
		className: 'line removeable'
	}).insert(activator);
	var label = new Element('label').insert(new Element('span').insert(title)).insert(input);
	if (object.type == Color){
		new Control.ColorPicker(input);
    input.addClassName('colorpickerInput');
	}
	line.appendChild(label);
	container.appendChild(line);
}

function buildForm(specs, form, options){
  var o, key, opt;
	$H(specs).each(function(pair){
		o = pair.value;
		key = pair.key;
		
		if (Object.isUndefined(o.def)) {
			opt = o._options;
			
			if (opt.inherited || form.name == 'global') {
				var legend = new Element('legend').update('<a href="javascript:;">' + opt.title + '</a>'),
            fieldset = new Element('fieldset', {className:'removeable'}).insert(legend),
            container = new Element('span');
				
				fieldset.insert(container);
				form.insert(fieldset);
				legend.observe('click', function(){container.toggle()});
				
				if (opt.collapsed) container.hide();
        
				$H(o).each(function(pair){
					if (pair.value && pair.key != '_options') {
						insertElement(pair.value, pair.key, key + '-' + pair.key, container);
					}
				});
			}
		}
		else 
			if (form.name == 'global') {
				insertElement(o, key, key, form);
			}
	});
}

function input(){
  var options = {}, 
      series = [];
      
  eval($('input-code').select('textarea')[0].value);
  
  $$('.removeable').invoke('remove');
  
	buildForm(specs, $(document.forms.global), options);
	
	$(document.forms.global).getElements().each(function(e){
		e.observe('change', draw);
	});
  
  buildDataForms();
	
  new Control.Tabs('tabs');
  new Control.Tabs('tabs-io');
}

function draw(){
	var globalOptions = formToOptions($(document.forms.global)), series = [];
	
	data.each(function(serie){
		serie.lines = serie.points = serie.bars = serie.candles = serie.pie = serie.mouse = null;
		Object.extend(serie, formToOptions($(document.forms[serie.id + '-options'])));
		inputsToData($(document.forms[serie.id + '-data']), serie);
		inputsToSerie($(document.forms[serie.id + '-serie']), serie);
		
		if (!serie.hide) 
			series.push(serie);
	});
	
	var f = Flotr.draw($('container'), series, globalOptions);
	
	writeCode($('output-code'), series, globalOptions);
}

function writeCode(container, series, options){
	container.innerHTML = 'options = <span style="white-space: normal">' + Object.toJSON(options) + ';</span><br /><br />series = ' + Object.toJSON(series) + ';';
}

function getOptionValue(element){
	if (element.nodeName.match(/^textarea$/i)) {
		eval('window.__FlotrFunc = ' + element.value);
		window.__FlotrFunc._code = element.value;
		return window.__FlotrFunc;
	}
	else 
		if (element.nodeName.match(/^input$/i)) {
			if (element.type == 'text') {
				if (element.size == 2) 
					return element.value === '' ? null : parseFloat(element.value);
				else 
					return element.value;
			}
			else 
				if (element.type == 'checkbox') {
					return !!element.checked;
				}
		}
		else 
			if (element.nodeName.match(/^select$/i)) {
				return element.options[element.selectedIndex].value;
			}
}

function formToOptions(form){
	var options = {}, parts, value;
	form.getElements().each(function(e){
		if (!e.disabled && e.name) {
			parts = e.name.split('-');
			value = e.value;
			
			if (parts[1]) {
				options[parts[0]] = options[parts[0]] || {};
				options[parts[0]][parts[1]] = getOptionValue(e);
			}
			else {
				options[parts[0]] = getOptionValue(e);
			}
		}
	});
	return options;
}

function getDataInputs(data, n){
	n = n || 5;
	
	var i, str = '<div class="data-entry">', type = ['x', 'y', 'a', 'b', 'c'];
	for (i = 0; i < n; i++) {
		str += '<input type="text" size="2" value="' + (data ? (data[i] || 0) : '') + '" name="' + type[i] + '" class="level-' + i + '" ' + (i > 5 ? 'disabled="disabled"' : '') + '/>';
	}
	str += '<a href="javascript:;" onclick="$(this).up().remove()">-</a></div>';
	return str;
}

function inputsToData(form, serie){
	var i, data = {x: [], y: [], a: [], b: [], c: []};
	
	$H(data).each(function(pair){
		form.getInputs('text', pair.key).each(function(e){
			if (!e.disabled && e.value) {
				data[pair.key].push(parseFloat(e.value));
			}
		});
	});
	serie.data = [];
	for (i = 0; i < data.x.length; i++) {
		serie.data.push([data.x[i], data.y[i], data.a[i], data.b[i], data.c[i]]);
	}
}

function inputsToSerie(form, serie){
	serie.label = form.elements.label.value;
	serie.color = form.elements.color.value;
	serie.xaxis = form.elements.xaxis[0].checked ? 1 : 2;
	serie.yaxis = form.elements.yaxis[0].checked ? 1 : 2;
	serie.hide = !form.elements.show.checked;
}

function buildDataForms(){
  var i, k, a, values, entries, fieldsetData, fieldsetSerie, formData, formOptions, formSerie;
	data.each(function(serie){ 
		fieldsetData = new Element('fieldset').insert(new Element('legend').update('Data'));
		fieldsetSerie = new Element('fieldset').insert(new Element('legend').update('Options')); 
    
		formData = new Element('form', {
			name: serie.id + '-data'
		}).insert(fieldsetData);
    
    formOptions = new Element('form', {
			name: serie.id + '-options',
			style: 'clear: both;'
		});
    
    formSerie = new Element('form', {
			name: serie.id + '-serie',
			style: 'clear: both;',
			className: 'serie-options'
		}).insert(fieldsetSerie);
		
		$('configurator').insert(new Element('div', {
			id: serie.id,
      className: 'removeable'
		}).hide().insert(formSerie).insert(formData).insert(formOptions));
		
		serie.toJSON = function(){
			values = [];
			for (k in serie) {
				if (k != 'toJSON' && k != 'id' && k != 'hide' && this[k] !== null) {
					entries = [];
					if (Object.isArray(this[k])) {
						a = this[k];
						for (i = 0; i < a.length; i++) {
							entries.push(Object.toJSON(a[i]));
						}
						str = 'data:<br /> [' + entries.join(',<br />') + ']';
					}
					else {
						str = k + ': ' + Object.toJSON(this[k]);
					}
					values.push(str);
				}
			}
			return '<br />{' + values.join(', ') + '}<br />';
		}
		
		for (i = 0; i < serie.data.length; i++) {
			fieldsetData.insert(getDataInputs(serie.data[i]));
		}
		fieldsetSerie.insert('<div class="axis-select">' +
		'x Axis :' +
		'<label><input type="radio" value="1" name="xaxis" checked="checked" />bottom</label>' +
		'<label><input type="radio" value="2" name="xaxis" />top</label>' +
		'<br />y Axis :' +
		'<label><input type="radio" value="1" name="yaxis" checked="checked" />left</label>' +
		'<label><input type="radio" value="2" name="yaxis" />right</label></div>' +
		'<input type="text" value="' + serie.label + '" name="label" size="14" /> '+
		'<input type="text" value="' + serie.color + '" name="color" size="8" /><br />' +
		'<label><input type="checkbox" checked="checked" name="show" /> Show</label>');
		fieldsetData.insert('<a href="javascript:;" class="plus" onclick="$(this).insert({before: getDataInputs()})">+</a>');
		
    var colorField = fieldsetSerie.select('input[name=color]')[0];
		new Control.ColorPicker(colorField.addClassName('colorpickerInput'));
    
		buildForm(specs, formOptions);
    
		formOptions.getElements().each(function(e){
			e.observe('change', draw);
		});
		
		formSerie.getElements().each(function(e){
			e.observe('change', draw);
		});
		
		// Add the data tab
		$('tabs').insert('<li class="tab removeable"><a href="#' + serie.id + '">' + serie.label + '</a></li>');
	});
}

function main(){
	buildForm(specs, $(document.forms.global));
	
	$(document.forms.global).getElements().each(function(e){
		e.observe('change', draw);
	});
  
  buildDataForms();
	
	Event.observe(window, 'scroll', function(){
		$('fixed').style.marginTop = document.documentElement.scrollTop + 'px';
	});
	new Control.Tabs('tabs');
	new Control.Tabs('tabs-io');
	draw();
}

window.onload = main;
