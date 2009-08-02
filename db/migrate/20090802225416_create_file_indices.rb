class CreateFileIndices < ActiveRecord::Migration
  def self.up
    create_table :file_indices do |t|
      t.string :snapname
      t.integer :schedule_id
      t.integer :host_id
      t.text :data
      t.timestamps
    end
  end

  def self.down
    drop_table :file_indices
  end
end
