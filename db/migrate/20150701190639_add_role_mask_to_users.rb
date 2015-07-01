class AddRoleMaskToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role_mask, :integer, default: 0, null: false
  end
end
