class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :backup_node_id
      t.integer :scheduler_node_id
      t.integer :scheduler_job_id
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
