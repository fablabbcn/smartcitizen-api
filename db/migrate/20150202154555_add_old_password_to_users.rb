class AddOldPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :old_password, :string
  end
end
