class AddOldMacAddressToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :old_mac_address, :macaddr
  end
end
