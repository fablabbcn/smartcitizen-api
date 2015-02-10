class AddLastRecordedAtToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :last_recorded_at, :timestamp
    add_index :devices, :last_recorded_at
  end
end
