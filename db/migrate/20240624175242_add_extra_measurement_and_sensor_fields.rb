class AddExtraMeasurementAndSensorFields < ActiveRecord::Migration[6.1]
  def change
    add_column :measurements, :definition, :string
    add_column :sensors, :datasheet, :string
    add_column :sensors, :unit_definition, :string
  end
end
