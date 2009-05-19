class AddSettingsTable < ActiveRecord::Migration
  def self.up
    create_table :settings, :force => true do |t|
      t.text   :settings
      t.timestamps
    end
    Setting.new.save
  end

  def self.down
    drop_table :settings
  end
end
