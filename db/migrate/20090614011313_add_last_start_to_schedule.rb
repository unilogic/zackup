class AddLastStartToSchedule < ActiveRecord::Migration
  def self.up
    add_column :schedules, :last_start, :datetime
  end

  def self.down
    remove_column :schedules, :last_start
  end
end
