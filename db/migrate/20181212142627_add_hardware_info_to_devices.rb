class AddHardwareInfoToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :hardware_info, :jsonb
  end
end
