# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_05_05_081245) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "adminpack"
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", id: :serial, force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "token"], name: "index_api_tokens_on_owner_id_and_token", unique: true
    t.index ["owner_id"], name: "index_api_tokens_on_owner_id"
  end

  create_table "components", id: :serial, force: :cascade do |t|
    t.integer "sensor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.integer "device_id", null: false
    t.string "key"
    t.integer "bus", default: 1, null: false
    t.datetime "last_reading_at"
    t.index ["device_id", "key"], name: "unique_key_for_device", unique: true
    t.index ["device_id", "sensor_id"], name: "index_components_on_device_id_and_sensor_id", unique: true
    t.index ["device_id", "sensor_id"], name: "unique_sensor_for_device", unique: true
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.integer "owner_id"
    t.string "name"
    t.text "description"
    t.macaddr "mac_address"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.hstore "latest_data"
    t.string "geohash"
    t.datetime "last_reading_at"
    t.jsonb "meta"
    t.jsonb "location"
    t.jsonb "data"
    t.jsonb "old_data"
    t.string "owner_username"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.jsonb "migration_data"
    t.string "workflow_state"
    t.datetime "csv_export_requested_at"
    t.macaddr "old_mac_address"
    t.string "state"
    t.string "device_token"
    t.jsonb "hardware_info"
    t.datetime "notify_stopped_publishing_timestamp", default: "2019-01-21 16:07:41"
    t.datetime "notify_low_battery_timestamp", default: "2019-01-21 16:07:41"
    t.boolean "notify_low_battery", default: false
    t.boolean "notify_stopped_publishing", default: false
    t.boolean "is_private", default: false
    t.boolean "is_test", default: false, null: false
    t.datetime "archived_at"
    t.string "hardware_type_override"
    t.string "hardware_name_override"
    t.string "hardware_version_override"
    t.string "hardware_slug_override"
    t.boolean "precise_location", default: true, null: false
    t.boolean "enable_forwarding", default: false, null: false
    t.index ["device_token"], name: "index_devices_on_device_token", unique: true
    t.index ["geohash"], name: "index_devices_on_geohash"
    t.index ["last_reading_at"], name: "index_devices_on_last_reading_at"
    t.index ["owner_id"], name: "index_devices_on_owner_id"
    t.index ["state"], name: "index_devices_on_state"
    t.index ["workflow_state", "is_test", "last_reading_at", "latitude"], name: "world_map_request"
    t.index ["workflow_state"], name: "index_devices_on_workflow_state"
  end

  create_table "devices_experiments", id: false, force: :cascade do |t|
    t.bigint "device_id"
    t.bigint "experiment_id"
    t.index ["device_id"], name: "index_devices_experiments_on_device_id"
    t.index ["experiment_id"], name: "index_devices_experiments_on_experiment_id"
  end

  create_table "devices_inventory", id: :serial, force: :cascade do |t|
    t.jsonb "report", default: {}
    t.datetime "created_at"
  end

  create_table "devices_tags", id: :serial, force: :cascade do |t|
    t.integer "device_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id", "tag_id"], name: "index_devices_tags_on_device_id_and_tag_id", unique: true
  end

  create_table "experiments", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.bigint "owner_id"
    t.boolean "is_test", default: false, null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_id"], name: "index_experiments_on_owner_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "ingest_errors", force: :cascade do |t|
    t.bigint "device_id", null: false
    t.text "topic"
    t.text "message"
    t.text "error_class"
    t.text "error_message"
    t.text "error_trace"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["device_id"], name: "index_ingest_errors_on_device_id"
  end

  create_table "measurements", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "definition"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "orphan_devices", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "exposure"
    t.float "latitude"
    t.float "longitude"
    t.text "user_tags"
    t.string "device_token", null: false
    t.string "onboarding_session"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "device_handshake", default: false
    t.index ["device_token"], name: "index_orphan_devices_on_device_token", unique: true
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "searchable_id"
    t.string "searchable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "postprocessings", force: :cascade do |t|
    t.string "blueprint_url"
    t.string "hardware_url"
    t.bigint "device_id", null: false
    t.jsonb "forwarding_params"
    t.jsonb "meta"
    t.datetime "latest_postprocessing"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["device_id"], name: "index_postprocessings_on_device_id"
  end

  create_table "sensor_tags", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sensor_id"
    t.integer "tag_sensor_id"
    t.index ["sensor_id"], name: "index_sensor_tags_on_sensor_id"
    t.index ["tag_sensor_id"], name: "index_sensor_tags_on_tag_sensor_id"
  end

  create_table "sensors", id: :serial, force: :cascade do |t|
    t.string "ancestry"
    t.string "name"
    t.text "description"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "measurement_id"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "default_key"
    t.string "equation"
    t.string "reverse_equation"
    t.string "datasheet"
    t.string "unit_definition"
    t.index ["ancestry"], name: "index_sensors_on_ancestry"
    t.index ["measurement_id"], name: "index_sensors_on_measurement_id"
  end

  create_table "tag_sensors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "uploads", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "original_filename"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.integer "user_id"
    t.string "key"
    t.index ["type"], name: "index_uploads_on_type"
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_reset_token"
    t.string "city"
    t.string "country_code"
    t.string "url"
    t.string "avatar_url"
    t.integer "role_mask", default: 0, null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "legacy_api_key", null: false
    t.jsonb "old_data"
    t.integer "cached_device_ids", array: true
    t.string "workflow_state"
    t.string "forwarding_token"
    t.string "forwarding_username"
    t.index ["forwarding_token"], name: "index_users_on_forwarding_token"
    t.index ["legacy_api_key"], name: "index_users_on_legacy_api_key", unique: true
    t.index ["workflow_state"], name: "index_users_on_workflow_state"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users", column: "owner_id"
  add_foreign_key "components", "devices"
  add_foreign_key "components", "sensors"
  add_foreign_key "devices_experiments", "devices"
  add_foreign_key "devices_experiments", "experiments"
  add_foreign_key "devices_tags", "devices"
  add_foreign_key "devices_tags", "tags"
  add_foreign_key "experiments", "users", column: "owner_id"
  add_foreign_key "ingest_errors", "devices"
  add_foreign_key "postprocessings", "devices"
  add_foreign_key "sensors", "measurements"
  add_foreign_key "uploads", "users"
end
