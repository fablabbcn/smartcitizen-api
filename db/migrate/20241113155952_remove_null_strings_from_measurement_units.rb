class RemoveNullStringsFromMeasurementUnits < ActiveRecord::Migration[6.1]
  def up
    execute "UPDATE measurements SET unit = NULL WHERE unit = 'NULL'"
    execute "UPDATE sensors SET unit = NULL WHERE unit = 'NULL'"
  end

  def down; end
end
