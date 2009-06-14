class DropTypeAddOperationToJobs < ActiveRecord::Migration
  def self.up
    remove_column :jobs, :type
    add_column :jobs, :operation, :string
  end

  def self.down
    remove_column :jobs, :operation
    add_column :jobs, :type, :string
  end
end
