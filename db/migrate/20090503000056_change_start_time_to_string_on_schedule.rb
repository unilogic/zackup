class ChangeStartTimeToStringOnSchedule < ActiveRecord::Migration
  def self.up
    remove_column :schedules, :start_time
    add_column :schedules, :start_time, :string
  end

  def self.down
    remove_column :schedules, :start_time
    add_column :schedules, :start_time, :time
  end
end
