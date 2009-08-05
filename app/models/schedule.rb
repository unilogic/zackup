class Schedule < ActiveRecord::Base
  belongs_to :host
  belongs_to :backup_node, :class_name => 'Node'
  has_one :retention_policy, :dependent => :destroy
  has_many :jobs, :dependent => :destroy
  has_many :restores, :dependent => :destroy
  
end
