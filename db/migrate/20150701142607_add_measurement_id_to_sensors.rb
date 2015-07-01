class AddMeasurementIdToSensors < ActiveRecord::Migration
  def change
    add_reference :sensors, :measurement, index: true, foreign_key: true
  end
end
