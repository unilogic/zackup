class AddFinishedAtToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :finished_at, :datetime
  end

  def self.down
    remove_column :jobs, :finished_at
  end
end
