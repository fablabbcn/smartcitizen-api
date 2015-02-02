class AddGeohashToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :geohash, :string
    add_index :devices, :geohash
  end
end
