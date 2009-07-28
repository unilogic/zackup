class AlterHostConfigValueToText < ActiveRecord::Migration
  def self.up
    change_column :host_configs, :value, :text
  end

  def self.down
    change_column :host_configs, :value, :string
  end
end
