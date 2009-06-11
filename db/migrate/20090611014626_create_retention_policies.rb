class CreateRetentionPolicies < ActiveRecord::Migration
  def self.up
    create_table :retention_policies do |t|
      t.integer :schedule_id
      t.integer :keep_min_time
      t.text :min_time_type
      t.integer :keep_max_time
      t.text :max_time_type
      t.integer :keep_max_versions
      t.integer :keep_min_versions
      t.timestamps
    end
  end

  def self.down
    drop_table :retention_policies
  end
end
