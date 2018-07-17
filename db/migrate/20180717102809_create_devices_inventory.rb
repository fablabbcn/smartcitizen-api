class CreateDevicesInventory < ActiveRecord::Migration
  def change
    create_table :devices_inventory do |t|
      t.jsonb :report, null: false, default: '{}'
      t.datetime :created_at
    end
  end
end
