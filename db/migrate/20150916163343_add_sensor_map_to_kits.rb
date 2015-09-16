class AddSensorMapToKits < ActiveRecord::Migration
  def change
    add_column :kits, :sensor_map, :jsonb
  end
end
