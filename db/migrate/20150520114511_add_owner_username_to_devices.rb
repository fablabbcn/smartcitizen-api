class AddOwnerUsernameToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :owner_username, :string
    Device.where.not(owner_id: nil).includes(:owner).each do |device|
      device.update_attribute(:owner_username, device.owner.username)
    end
  end
end
