class DropPlaces < ActiveRecord::Migration

  def up
    drop_table :places
  end

  def down
    create_table "places", force: :cascade do |t|
      t.string   "name"
      t.string   "country_code"
      t.string   "country_name"
      t.float    "lat"
      t.float    "lng"
      t.datetime "created_at",   null: false
      t.datetime "updated_at",   null: false
    end

    add_index "places", ["name", "country_code"], name: "index_places_on_name_and_country_code", unique: true, using: :btree
  end

end
