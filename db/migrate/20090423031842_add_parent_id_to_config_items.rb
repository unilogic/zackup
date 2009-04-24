class AddParentIdToConfigItems < ActiveRecord::Migration
  def self.up
    add_column :config_items, :parent_id, :integer
  end

  def self.down
    remove_column :config_items, :parent_id
  end
end
