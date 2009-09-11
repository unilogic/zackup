// Gets the value from a group of radio buttons
function getV(nl) {
	var v = null;
	$A(nl).each(function(e) {
	  if (e.checked) {
	    v = e.value;
	      return;
	    }
	});
	return v;
}

window.addEvent('domready', function(){
	var view = $('code-view');
	if (view) {
		var code = $$('body script')[0].innerHTML.replace(/\n\t\t\t/g, '\n');
		if (view.outerHTML) 
			view.outerHTML = '<pre id="code-view"><code class="javascript">' + code + '</code></pre>';
		else 
			view.innerHTML = code;
	}
	
	$$('#wrapper h1')[0].innerHTML = $$('head title')[0].innerHTML;
});