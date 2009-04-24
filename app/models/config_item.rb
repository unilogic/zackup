class ConfigItem < ActiveRecord::Base
  has_many :host_configs, :dependent => :destroy
  has_many :hosts, :through => :host_configs
  
  validates_uniqueness_of :name, :message => "Name is already being used."
  before_destroy :check_and_remove_deps
  
  def parent_name
    if self.parent_id
      item = ConfigItem.find(self.parent_id)
      if item
        return item.name
      end
    end
  end
  
  # Check for any config items with their parent_id set to us, and set it to nil
  def check_and_remove_deps
    items = ConfigItem.find_all_by_parent_id(self.id)
    items.each { |item| 
      item.update_attributes(:parent_id => nil)
    }
  end
end
