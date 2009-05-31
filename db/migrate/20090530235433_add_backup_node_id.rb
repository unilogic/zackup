class AddBackupNodeId < ActiveRecord::Migration
  def self.up
    add_column :schedules, :backup_node_id, :integer
  end

  def self.down
    remove_column :schedules, :backup_node_id
  end
end
