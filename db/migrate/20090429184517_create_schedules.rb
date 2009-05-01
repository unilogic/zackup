class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.integer :host_id, :null => false
      t.date :start_date, :null => false
      t.time :start_time, :null => false
      t.string :repeat, :null => false
      t.string :every, :null => false
      t.string :on
      t.time :stop
      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
