json.(device,
  :id,
  :name,
  :description,
  :status,
  :last_reading_at,
  :added_at,
  :updated_at
)

# json . device do
#   json.id device.id
#   json.name device.name
#   json.description device.description
#   json.status device.status
#   json.last_reading_at device.last_reading_at
#   json.added_at device.added_at.utc.iso8601
#   json.updated_at device.updated_at.utc.iso8601
# end


json.owner(
  device.owner, :id, :username, :first_name, :last_name, :avatar, :url, :joined_at, :location, :device_ids
)

json.data device.formatted_data

if device.kit
  json.kit device.kit, :id, :slug, :name, :description, :created_at, :updated_at
end
