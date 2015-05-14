class AddOldDataToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :old_data, :jsonb
  end
end
