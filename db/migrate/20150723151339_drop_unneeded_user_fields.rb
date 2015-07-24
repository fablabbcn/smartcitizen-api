class DropUnneededUserFields < ActiveRecord::Migration
  def change
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :old_password, :string
    remove_column :users, :role, :string
    remove_column :users, :meta, :hstore
    rename_column :users, :avatar, :avatar_url
  end
end
