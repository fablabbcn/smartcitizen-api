class AddArchivedAtToDevices < ActiveRecord::Migration[6.0]
  def up
    add_column :devices, :archived_at, :datetime, null: true
    execute %{
      UPDATE devices
      SET archived_at = NOW()
      WHERE state = 'archived'
    }
  end

  def down
    remove_column :devices, :archived_at
  end
end
