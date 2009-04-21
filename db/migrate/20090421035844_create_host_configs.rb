class CreateHostConfigs < ActiveRecord::Migration
  def self.up
    create_table :host_configs do |t|
      t.integer :host_id, :null => false
      t.integer :config_item_id, :null => false
      t.string :value, :null => false
      t.timestamps
    end
    
    add_index :host_configs, [:host_id, :config_item_id], :unique => true
  end

  def self.down
    drop_table :host_configs
  end
end
