class AddKitIdToDevices < ActiveRecord::Migration
  def change
    add_reference :devices, :kit, index: true
    add_foreign_key :devices, :kits
  end
end
