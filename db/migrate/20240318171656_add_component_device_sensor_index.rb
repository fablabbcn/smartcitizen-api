class AddComponentDeviceSensorIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :components, [:sensor_id]
    add_index :components, [:device_id, :sensor_id]
  end
end
