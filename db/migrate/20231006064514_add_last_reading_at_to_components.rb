class AddLastReadingAtToComponents < ActiveRecord::Migration[6.1]
  def change
    add_column :components, :last_reading_at, :datetime
    execute %{
      UPDATE components
      SET last_reading_at = devices.last_reading_at
      FROM devices
      WHERE components.device_id = devices.id
    }
  end
end
