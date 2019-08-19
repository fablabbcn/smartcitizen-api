class AddIsPrivateToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :is_private, :boolean, default: false
  end
end
