class AddBacktraceToBadReadings < ActiveRecord::Migration
  def change
    add_column :bad_readings, :backtrace, :text
  end
end
