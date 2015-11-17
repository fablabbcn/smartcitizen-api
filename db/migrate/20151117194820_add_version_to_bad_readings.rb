class AddVersionToBadReadings < ActiveRecord::Migration
  def change
    add_column :bad_readings, :version, :string
  end
end
