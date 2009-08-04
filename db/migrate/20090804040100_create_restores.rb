class CreateRestores < ActiveRecord::Migration
  def self.up
    create_table :restores do |t|
      t.string :name
      t.text :data
      t.integer :user_id
      t.integer :host_id
      t.timestamps
    end
  end

  def self.down
    drop_table :restores
  end
end
