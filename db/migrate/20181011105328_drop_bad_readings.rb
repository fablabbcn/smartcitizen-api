class DropBadReadings < ActiveRecord::Migration
  def change
    drop_table :bad_readings
  end
end
