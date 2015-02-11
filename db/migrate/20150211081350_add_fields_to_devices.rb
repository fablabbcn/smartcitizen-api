class AddFieldsToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :meta, :hstore
    add_column :devices, :location, :hstore
  end
end
