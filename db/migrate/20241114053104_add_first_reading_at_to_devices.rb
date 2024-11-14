class AddFirstReadingAtToDevices < ActiveRecord::Migration[6.1]
  def change
    add_column :devices, :first_reading_at, :timestamp
  end
end
