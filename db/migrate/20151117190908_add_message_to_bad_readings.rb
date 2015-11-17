class AddMessageToBadReadings < ActiveRecord::Migration
  def change
    add_column :bad_readings, :message, :string
  end
end
