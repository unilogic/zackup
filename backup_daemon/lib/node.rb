class Node < ActiveRecord::Base
  has_many :backup_jobs, :class_name => "Job", :foreign_key => "backup_node_id"
end