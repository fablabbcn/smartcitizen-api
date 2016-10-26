class AddDeviceTokenToOrphanDevices < ActiveRecord::Migration
  def change
    add_column :orphan_devices, :device_token, :string
  end
end
