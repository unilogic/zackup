class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :ip_address
      t.string :hostname
      t.string :description
      t.string :services
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
