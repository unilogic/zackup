class CreateConfigItems < ActiveRecord::Migration
  def self.up
    create_table :config_items do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :config_items
  end
end
