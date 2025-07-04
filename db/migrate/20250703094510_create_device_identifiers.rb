class CreateDeviceIdentifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :device_identifiers do |t|
      t.references :device, null: false, foreign_key: true
      t.string :namespace, null: false
      t.string :identifier, null: false
      t.boolean :is_archived, null: false, default: false
      t.timestamps
    end

    add_index :device_identifiers, %i[is_archived namespace identifier], name: "index_devices_by_archived_ns_id"

    execute %(
      INSERT INTO device_identifiers
        (device_id, namespace, identifier, is_archived, created_at, updated_at)
        SELECT id, 'mac_address', mac_address, FALSE, NOW(), NOW()
        FROM devices
        WHERE mac_address IS NOT NULL
    )

    execute %(
      INSERT INTO device_identifiers
        (device_id, namespace, identifier, is_archived, created_at, updated_at)
        SELECT id, 'mac_address', old_mac_address, TRUE, NOW(), NOW()
        FROM devices
        WHERE old_mac_address IS NOT NULL
    )

    remove_column :devices, :mac_address
    remove_column :devices, :old_mac_address
  end

end
