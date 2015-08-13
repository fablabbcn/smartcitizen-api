class AddMigrationDataToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :migration_data, :jsonb
  end
end
