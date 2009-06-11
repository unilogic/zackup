class AddScheduleIdToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :schedule_id, :integer
  end

  def self.down
    remove_column :jobs, :schedule_id
  end
end
