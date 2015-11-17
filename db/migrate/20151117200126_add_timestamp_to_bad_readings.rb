class AddTimestampToBadReadings < ActiveRecord::Migration
  def change
    add_column :bad_readings, :timestamp, :string
  end
end
