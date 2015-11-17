# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151117194820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "api_tokens", force: :cascade do |t|
    t.integer  "owner_id",   null: false
    t.string   "token",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "api_tokens", ["owner_id", "token"], name: "index_api_tokens_on_owner_id_and_token", unique: true, using: :btree
  add_index "api_tokens", ["owner_id"], name: "index_api_tokens_on_owner_id", using: :btree

  create_table "bad_readings", force: :cascade do |t|
    t.integer  "tags"
    t.string   "remote_ip"
    t.jsonb    "data"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "message"
    t.integer  "device_id"
    t.string   "mac_address"
    t.string   "version"
  end

  create_table "components", force: :cascade do |t|
    t.integer  "board_id"
    t.string   "board_type"
    t.integer  "sensor_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.uuid     "uuid",       default: "uuid_generate_v4()"
    t.text     "equation"
  end

  add_index "components", ["board_type", "board_id"], name: "index_components_on_board_type_and_board_id", using: :btree
  add_index "components", ["sensor_id"], name: "index_components_on_sensor_id", using: :btree

  create_table "devices", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.text     "description"
    t.macaddr  "mac_address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "kit_id"
    t.hstore   "latest_data"
    t.string   "geohash"
    t.datetime "last_recorded_at"
    t.jsonb    "data"
    t.jsonb    "old_data"
    t.string   "owner_username"
    t.uuid     "uuid",                    default: "uuid_generate_v4()"
    t.jsonb    "migration_data"
    t.string   "workflow_state"
    t.datetime "csv_export_requested_at"
    t.jsonb    "meta"
    t.jsonb    "location"
  end

  add_index "devices", ["geohash"], name: "index_devices_on_geohash", using: :btree
  add_index "devices", ["kit_id"], name: "index_devices_on_kit_id", using: :btree
  add_index "devices", ["last_recorded_at"], name: "index_devices_on_last_recorded_at", using: :btree
  add_index "devices", ["owner_id"], name: "index_devices_on_owner_id", using: :btree
  add_index "devices", ["workflow_state"], name: "index_devices_on_workflow_state", using: :btree

  create_table "devices_tags", force: :cascade do |t|
    t.integer  "device_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "devices_tags", ["device_id", "tag_id"], name: "index_devices_tags_on_device_id_and_tag_id", unique: true, using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "kits", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "slug"
    t.uuid     "uuid",        default: "uuid_generate_v4()"
    t.jsonb    "sensor_map"
  end

  add_index "kits", ["slug"], name: "index_kits_on_slug", using: :btree

  create_table "measurements", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "unit"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.uuid     "uuid",        default: "uuid_generate_v4()"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

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

  create_table "sensors", force: :cascade do |t|
    t.string   "ancestry"
    t.string   "name"
    t.text     "description"
    t.string   "unit"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "measurement_id"
    t.uuid     "uuid",           default: "uuid_generate_v4()"
  end

  add_index "sensors", ["ancestry"], name: "index_sensors_on_ancestry", using: :btree
  add_index "sensors", ["measurement_id"], name: "index_sensors_on_measurement_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.uuid     "uuid",        default: "uuid_generate_v4()"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "uploads", force: :cascade do |t|
    t.string   "type"
    t.string   "original_filename"
    t.jsonb    "metadata"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.uuid     "uuid",              default: "uuid_generate_v4()"
    t.integer  "user_id"
    t.string   "key"
  end

  add_index "uploads", ["type"], name: "index_uploads_on_type", using: :btree
  add_index "uploads", ["user_id"], name: "index_uploads_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "password_reset_token"
    t.string   "city"
    t.string   "country_code"
    t.string   "url"
    t.string   "avatar_url"
    t.integer  "role_mask",            default: 0,                    null: false
    t.uuid     "uuid",                 default: "uuid_generate_v4()"
    t.jsonb    "old_data"
    t.string   "legacy_api_key"
    t.integer  "cached_device_ids",                                                array: true
  end

  add_foreign_key "api_tokens", "users", column: "owner_id"
  add_foreign_key "components", "sensors"
  add_foreign_key "devices", "kits"
  add_foreign_key "devices_tags", "devices"
  add_foreign_key "devices_tags", "tags"
  add_foreign_key "sensors", "measurements"
  add_foreign_key "uploads", "users"
end
