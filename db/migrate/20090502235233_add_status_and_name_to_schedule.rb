class AddStatusAndNameToSchedule < ActiveRecord::Migration
  def self.up
    add_column :schedules, :name, :string 
    add_column :schedules, :status, :string
  end

  def self.down
    remove_column :schedules, :name
    remove_column :schedules, :status
  end
end
