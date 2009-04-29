class AddDisplayTypeToConfigItem < ActiveRecord::Migration
  def self.up
    add_column :config_items, :display_type, :string 
  end

  def self.down
    remove_column :config_items, :display_type
  end
end
