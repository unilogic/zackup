class AddLastFinishToSchedule < ActiveRecord::Migration
  def self.up
    add_column :schedules, :last_finish, :datetime
  end

  def self.down
    remove_column :schedules, :last_finish
  end
end
