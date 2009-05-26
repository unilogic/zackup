class AddHostIdAndTypeToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :type, :string
    add_column :jobs, :host_id, :integer 
  end

  def self.down
    remove_column :jobs, :type
    remove_column :jobs, :host_id
  end
end
