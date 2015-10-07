class DropPgReadings < ActiveRecord::Migration
  def change
    drop_table :pg_readings
  end
end
