class CreateSensorTags < ActiveRecord::Migration
  def change
    create_table :sensor_tags do |t|
      t.string :name
      t.string :description
      t.references :sensor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
