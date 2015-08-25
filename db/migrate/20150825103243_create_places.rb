class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :country_code
      t.string :country_name
      t.float :lat
      t.float :lng

      t.timestamps null: false
    end
    add_index :places, [:name, :country_code], unique: true
  end
end
