class PopulateDeviceArchivedAtColumn < ActiveRecord::Migration[6.0]
  def change
    execute %{
      UPDATE devices
      SET archived_at = NOW()
      WHERE workflow_state = 'archived'
    }
  end
end
