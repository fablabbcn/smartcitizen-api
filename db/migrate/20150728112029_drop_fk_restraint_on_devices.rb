class DropFkRestraintOnDevices < ActiveRecord::Migration
  def change
    remove_foreign_key :devices, column: :owner_id
  end
end
