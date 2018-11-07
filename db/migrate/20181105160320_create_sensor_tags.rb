class CreateSensorTags < ActiveRecord::Migration
  def change
    create_table :tag_sensors do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end

    create_table :sensor_tags do |t|
      t.timestamps null: false
      t.belongs_to :sensor, index: true
      t.belongs_to :tag_sensor, index: true
    end

  end
end
