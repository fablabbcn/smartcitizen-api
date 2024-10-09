class UniqueIndexOnComponents < ActiveRecord::Migration[6.1]
  def up
    remove_index :components, [:device_id, :sensor_id]
    add_index :components, [:device_id, :sensor_id], unique: true
    execute %{
      ALTER TABLE components ADD CONSTRAINT unique_sensor_for_device UNIQUE (device_id, sensor_id)
    }
    execute %{
      ALTER TABLE components ADD CONSTRAINT unique_key_for_device UNIQUE (device_id, key)
    }
  end

  def down
    execute %{
      ALTER TABLE components DROP CONSTRAINT IF EXISTS unique_key_for_device
    }
    execute %{
      ALTER TABLE components DROP CONSTRAINT IF EXISTS unique_sensor_for_device
    }
    remove_index :components, [:device_id, :sensor_id], unique: true
    add_index :components, [:device_id, :sensor_id]
  end
end
