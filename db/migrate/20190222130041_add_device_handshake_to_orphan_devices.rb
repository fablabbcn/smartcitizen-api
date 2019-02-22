class AddDeviceHandshakeToOrphanDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :orphan_devices, :device_handshake, :boolean, default: false
  end
end
