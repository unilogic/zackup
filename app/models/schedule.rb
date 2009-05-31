class Schedule < ActiveRecord::Base
  belongs_to :host
  belongs_to :backup_node, :class_name => 'Node'
end
