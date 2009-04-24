class Host < ActiveRecord::Base
  has_many :host_configs, :dependent => :destroy
  has_many :config_items, :through => :host_configs
  
  def disable
    status_config = self.find_host_config_by_name('status')
    unless status_config
      host_config = HostConfig.create(:host => self, :config_item => ConfigItem.find_by_name('status'), :value => 'disabled')
    else
      status_config.value = 'disabled'
      status_config.save!
    end
  end
  
  def enable
    status_config = self.find_host_config_by_name('status')
    unless status_config
      host_config = HostConfig.create(:host => self, :config_item => ConfigItem.find_by_name('status'), :value => 'enabled')
    else
      status_config.value = 'enabled'
      status_config.save!
    end
  end
  
  def ip_addr
    item = self.find_host_config_by_name('ip_addr')
    if item
      return item.value
    end
  end
  
  def hostname
    item = self.find_host_config_by_name('hostname') 
    if item
      return item.value
    end   
  end
  
  def status
    item = self.find_host_config_by_name('status')
    if item
      return item.value
    end
  end
  
  def find_host_config_by_name(name)
    config_item = ConfigItem.find_by_name(name)
    self.host_configs.find_by_config_item_id(config_item)
  end
  
  def find_host_configs_not_configurable
    host_configs = self.host_configs
    
    configurables = []
    host_configs.each { |config|
      if config.configurable? == true
        configurables.push(config)
      end
    }
    return configurables
  end
  
end
