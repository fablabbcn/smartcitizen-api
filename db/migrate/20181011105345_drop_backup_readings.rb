class DropBackupReadings < ActiveRecord::Migration
  def change
    drop_table :backup_readings
  end
end
