class AddWorldMapIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :devices, [:workflow_state, :is_test, :last_reading_at, :latitude], name: "world_map_request"
  end
end
