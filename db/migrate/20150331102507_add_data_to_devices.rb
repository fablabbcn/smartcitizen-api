class AddDataToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :data, :jsonb
  end
end
