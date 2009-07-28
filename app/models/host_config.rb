class HostConfig < ActiveRecord::Base
  belongs_to :host
  belongs_to :config_item
  
  validates_uniqueness_of :config_item_id, :scope => :host_id,:message => "This settings is already set for this host"
  
  def name
    item = self.config_item
    if item
      return item.name
    else
      return 'empty'
    end
  end
  
  def parent_name
    item = ConfigItem.find(self.config_item.parent_id)
    if item
      return item.name
    else
      return 'empty'
    end
  end
  
  def configurable?
    item = self.config_item
    if item
      return item.configurable
    else
      return nil
    end
  end
  
  def display_type
    item = self.config_item
    if item
      return item.display_type
    else
      return 'empty'
    end
  end
end
