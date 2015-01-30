class AddLatestDataToDevices < ActiveRecord::Migration
  def up
    add_column :devices, :latest_data, :hstore
  end
end
