class ChangeServicesToBooleansOnNode < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :services
    add_column :nodes, :backup_node, :boolean
    add_column :nodes, :scheduler_node, :boolean
  end

  def self.down
    remove_column :nodes, :backup_node
    remove_column :nodes, :scheduler_node
    add_column :nodes, :services, :string
  end
end
