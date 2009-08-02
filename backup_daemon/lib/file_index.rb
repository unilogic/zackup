class FileIndex < ActiveRecord::Base
  validates_presence_of :data, :snapname, :schedule_id, :host_id
  
end