require 'find'
require 'zlib'
require 'yaml'

class CustomFind
  def self.find(path, basepath=Dir.pwd)
    Dir.chdir(basepath) do
      data = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
      Find.find(path) do |path|
        path_split = path.split('/')
        dest = ""
        path_split.each do |base|
          dest << '["' + base + '"]'
      
        end
        if File.directory?(path)
          eval("data#{dest} = {}")
        else
          eval("data#{dest} = nil")
        end
        
      end
      zdirs = Zlib::Deflate.deflate(YAML::dump(data), 9)
      return zdirs
    end
  end
end