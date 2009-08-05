class AddFieldsToRestore < ActiveRecord::Migration
  def self.up
    add_column :restores, :schedule_id, :integer
    add_column :restores, :status, :string
    add_column :restores, :links, :string
    add_column :restores, :job_id, :integer
  end

  def self.down
    remove_column :restores, :schedule_id
    remove_column :restores, :status
    remove_column :restores, :links
    remove_column :restores, :job_id
  end
end
