class AddForwardingUsernameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :forwarding_username, :string
    add_index :users, :forwarding_token
  end
end
