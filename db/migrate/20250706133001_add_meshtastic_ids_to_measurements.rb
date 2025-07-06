class AddMeshtasticIdsToMeasurements < ActiveRecord::Migration[6.1]
  def change
    add_column :measurements, :meshtastic_id, :string, null: true
    add_index :measurements, :meshtastic_id, unique: true
    add_reference :measurements, :meshtastic_default_sensor, foreign_key: { to_table: :sensors }
  end
end
