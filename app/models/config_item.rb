class ConfigItem < ActiveRecord::Base
  has_many :host_configs, :dependent => :destroy
  has_many :hosts, :through => :host_configs
  
  validates_uniqueness_of :name, :message => "Name is already being used."
  
end
