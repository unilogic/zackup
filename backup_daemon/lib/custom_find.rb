require 'find'
require 'zlib'
require 'yaml'

class CustomFind
  def self.find(path)
    data = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
    Find.find(path) do |path|
      path_split = path.split('/')
      dest = ""
      path_split.each do |base|
        dest << '["' + base + '"]'
      
      end
      eval("data#{dest}")
    end
    zdirs = Zlib::Deflate.deflate(YAML::dump(data), 9)
    return zdirs
  end
end