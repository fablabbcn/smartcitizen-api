class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :ancestry, index: true
      t.string :name
      t.text :description
      t.string :unit

      t.timestamps null: false
    end
  end
end
