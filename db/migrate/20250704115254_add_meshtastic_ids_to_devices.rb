class AddMeshtasticIdsToDevices < ActiveRecord::Migration[6.1]
  def change
    add_column :devices, :meshtastic_id, :string, null: true
    add_index :devices, :meshtastic_id, unique: true
  end
end
