class FurtherKitsRefactorChanges < ActiveRecord::Migration[6.1]
  def change
    rename_column :devices, :last_recorded_at, :last_reading_at
    add_column :components, :location, :integer, default: 1
    connection.execute(%{
      UPDATE components
      SET location=1
      WHERE location IS NULL
    })
    change_column_null :components, :location, false
  end
end
