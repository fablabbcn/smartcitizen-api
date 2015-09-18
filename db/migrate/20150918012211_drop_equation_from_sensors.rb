class DropEquationFromSensors < ActiveRecord::Migration
  def change
    remove_column :sensors, :equation, :text
  end
end
