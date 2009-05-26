class Node < ActiveRecord::Base
  has_many :backup_jobs, :class_name => "Job"
  has_many :scheduler_jobs, :class_name => "Job"
  
  serialize :services, Array
  
  validates_presence_of :hostname
  validates_presence_of :ip_address
  validates_presence_of :services
  
  def name
    self.hostname || self.ip_address
  end
end
