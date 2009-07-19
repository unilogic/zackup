class AddLastSeenToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :last_seen, :datetime
  end

  def self.down
    remove_column :nodes, :last_seen
  end
end
