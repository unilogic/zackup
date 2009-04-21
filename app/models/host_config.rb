class HostConfig < ActiveRecord::Base
  belongs_to :host
  belongs_to :config_item
  
  validates_uniqueness_of :host_id, :scope => :config_item_id, :message => "This settings is already set for this host"
  
  def name
    self.config_item.name
  end

end
