require 'zlib'
require 'yaml'

class FileIndex < ActiveRecord::Base
  validates_presence_of :data, :snapname, :schedule_id, :host_id, :basepath
  
  def data_inflate
    YAML::load(Zlib::Inflate.inflate(self.data))
  end
  
  def get_dirs(path="", data)
     
  end
  
  def get_files(path="", data=self.data)
    
  end
  
  def get_content(path="", data_inflate=self.data_inflate)
    hash_arg = ""
    files = []
    dirs = []
    if path.length == 0
      hash_arg = "['#{self.snapname}']"
    else
      hash_arg = "['#{self.snapname}']"
      path.split('/').each do |path_part|
        if path_part.length > 0
          hash_arg << "['#{path_part}']"
        end
      end
    end
    path_contents = eval("data_inflate#{hash_arg}.keys")
    path_contents.each do |content|
      sub_content = eval("data_inflate#{hash_arg}['#{content}'].keys")
      if sub_content.length > 0
        dirs << content
      else
        files << content
      end
    end
    
    return [dirs, files]
  end
    
end
