class AddDeviceIdAndMacAddressToBadReadings < ActiveRecord::Migration
  def change
    add_column :bad_readings, :device_id, :integer
    add_column :bad_readings, :mac_address, :string
  end
end
