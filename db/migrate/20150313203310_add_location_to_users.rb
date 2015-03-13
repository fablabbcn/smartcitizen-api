class AddLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :city, :string
    add_column :users, :country_code, :string
  end
end
