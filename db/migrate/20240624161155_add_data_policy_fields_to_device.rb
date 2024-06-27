class AddDataPolicyFieldsToDevice < ActiveRecord::Migration[6.1]
  def change
    add_column :devices, :precise_location, :boolean, null: false, default: false
    add_column :devices, :enable_forwarding, :boolean, null: false, default: false
    # Existing devices have precise locations, despite the default for all new ones.
    execute "UPDATE devices SET precise_location = true"
  end
end
