class AddDataToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :data, :string 
  end

  def self.down
    remove_column :jobs, :data
  end
end
