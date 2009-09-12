class Hash

  # Merges self with another hash, recursively.
  #
  # This code was lovingly stolen from some random gem:
  # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  #
  # Thanks to whoever made it.

  def deep_merge(hash)
    target = dup

    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end

      target[key] = hash[key]
    end
    target
  end
end

class Chartr::Chart
  attr_accessor :data, :options

  # Initialize the chart with the options listed here:
  # http://solutoire.com/flotr/docs/options/
  def initialize(params = {})
    @options ||= {}
    @options = @options.deep_merge(params)
    @data = []
  end

  def options_to_json(options)
    options_to_json = options.to_json.gsub(/(\"tickFormatter\":)(\")(.+)(\")/,"\\1\\3")
  end
  
  def output(canvasname)
    return "Flotr.draw($('#{canvasname}'), #{@data.to_json}, #{@options.to_json});"
  end
  
  def output_select(canvasname)
    return "document.observe('dom:loaded', function(){
    		      var options = #{options_to_json(@options)};
          		function drawGraph(opts){
          			var o = Object.extend(Object.clone(options), opts || {});
          			return Flotr.draw(
          				$('#{canvasname}'), 
          				#{@data.to_json},
          				o
          			);
          		}	

          		var f = drawGraph();			

          		$('#{canvasname}').observe('flotr:select', function(evt){

          			var area = evt.memo[0];

          			f = drawGraph({
          				xaxis: {min:area.x1, max:area.x2, mode:'time', labelsAngle:45},
          				yaxis: {min:area.y1, max:area.y2}
          			});
          		});

          		$('#{canvasname}-reset-btn').observe('click', function(){drawGraph()});
          	});
        	"
  end
end
