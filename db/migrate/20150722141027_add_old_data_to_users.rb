class AddOldDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :old_data, :jsonb
  end
end
