class AddPreferredTimeZoneToUser < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :preferred_time_zone, :string, default: "Etc/UTC", null: false
    execute "UPDATE users SET preferred_time_zone='Etc/UTC'"
  end

  def down
    remove_column :users, :preferred_time_zone
  end
end
