class Node < ActiveRecord::Base
  has_many :backup_jobs, :class_name => "Job"
  has_many :scheduler_jobs, :class_name => "Job"
  has_many :schedules, :foreign_key => "backup_node_id"
  validates_presence_of :hostname
  validates_presence_of :ip_address
  
  def name
    self.hostname || self.ip_address
  end
  
  def services
    if self.backup_node && self.scheduler_node
      "Backup, Scheduler"
    elsif self.backup_node
      "Backup"
    elsif self.scheduler_node
      "Scheduler"
    end
  end
end
