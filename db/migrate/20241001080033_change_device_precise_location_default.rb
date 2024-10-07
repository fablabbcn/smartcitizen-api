class ChangeDevicePreciseLocationDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :devices, :precise_location, from: false, to: true
  end
end
