class AddForwardingTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :forwarding_token, :string
  end
end
