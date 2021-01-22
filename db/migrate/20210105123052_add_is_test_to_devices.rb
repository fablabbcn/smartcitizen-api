class AddIsTestToDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :is_test, :boolean, null: false, default: false
  end
end
