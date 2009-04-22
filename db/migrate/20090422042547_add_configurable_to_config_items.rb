class AddConfigurableToConfigItems < ActiveRecord::Migration
  def self.up
    add_column :config_items, :configurable, :boolean
  end

  def self.down
    remove_column :config_items, :configurable
  end
end
