class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.belongs_to :owner, index: true
      t.string :name
      t.text :description
      t.macaddr :mac_address
      t.float :latitude
      t.float :longitude
      t.timestamps null: false
    end
    add_foreign_key :devices, :users, column: :owner_id
  end
end

# DEVICE
#   owner_id
#   name
#   description
#   mac_address # add_column :devices, :mac_address, :macaddr
#   kit_version
#   firmware_version
#   elevation
#   latitude
#   longitude
#   address

# READING
#   device_id
