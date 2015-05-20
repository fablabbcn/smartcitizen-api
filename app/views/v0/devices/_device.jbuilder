json.(device,
  :id,
  :name,
  :description,
  :status,
  :last_reading_at,
  :added_at,
  :updated_at
)

json.owner device.owner, :id, :username, :first_name, :last_name, :avatar, :url, :joined_at, :location, :device_ids

json.data device.formatted_data

if device.kit
  json.kit device.kit, :id, :slug, :name, :description, :created_at, :updated_at
end
