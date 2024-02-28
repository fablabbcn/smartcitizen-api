class RemoveHardwareDescriptionOverrideFromDevices < ActiveRecord::Migration[6.1]
  def change
    remove_column :devices, :hardware_description_override, :string
  end
end
