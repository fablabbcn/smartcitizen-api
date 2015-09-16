class AddEquationToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :equation, :text
  end
end
