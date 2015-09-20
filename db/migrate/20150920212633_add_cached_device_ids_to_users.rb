class AddCachedDeviceIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cached_device_ids, :integer, array: true
    User.reset_column_information

    User.unscoped.all.map(&:update_all_device_ids!)

  end
end
