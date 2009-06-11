class AddStartedAtToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :start_at, :datetime
  end

  def self.down
    remove_column :jobs, :start_at
  end
end
