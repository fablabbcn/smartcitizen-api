class CreatePgReadings < ActiveRecord::Migration
  def change
    create_table :pg_readings do |t|
      t.belongs_to :device, index: true, foreign_key: true
      t.jsonb :data
      t.jsonb :raw_data
      t.datetime :recorded_at, index: true

      t.datetime :created_at
    end
  end
end
