class Host < ActiveRecord::Base
  has_many :host_configs
  has_many :config_items, :through => :host_configs
  
  def disable
    status_config = self.find_host_config_by_name('status')
    status_config.value = 'disabled'
    status_config.save!
  end
  
  def enable
    status_config = self.find_host_config_by_name('status')
    status_config.value = 'enabled'
    status_config.save!
  end
  
  def ip_addr
    self.find_host_config_by_name('ip_addr').value
  end
  
  def hostname
    self.find_host_config_by_name('hostname').value
  end
  
  def status
    self.find_host_config_by_name('status').value
  end
  
  def find_host_config_by_name(name)
    config_item = ConfigItem.find_by_name(name)
    self.host_configs.find_by_config_item_id(config_item)
  end
end
