class CreateDevicesInventory < ActiveRecord::Migration
  def change
  	drop_table :devices_inventory
    create_table :devices_inventory do |t|
      t.jsonb :report, default: '{}'
      t.datetime :created_at
    end
  end
end
