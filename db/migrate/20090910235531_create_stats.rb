class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.integer :schedule_id
      t.integer :node_id
      t.string :disk_used
      t.string :disk_avail
      t.string :cpu_load_avg
    end
  end

  def self.down
    drop_table :stats
  end
end
