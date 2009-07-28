class AlterJobDataToText < ActiveRecord::Migration
  def self.up
    change_column :jobs, :data, :text
  end

  def self.down
    change_column :jobs, :data, :string
  end
end
