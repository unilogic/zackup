require 'zlib'
require 'yaml'

class FileIndex < ActiveRecord::Base
  validates_presence_of :data, :snapname, :schedule_id, :host_id, :basepath
  
  def data
    YAML::load(Zlib::Inflate.inflate(self.data))
  end
  
  def get_dirs(path=".", data=self.data)
     
  end
  
  def get_files(path=".")
    
  end
  
  def get_content(path=".")
      [get_dirs(path), get_files(path)]
  end
    
end
