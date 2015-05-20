json.(user,
  :id,
  :username,
  :first_name,
  :last_name,
  :avatar,
  :url,
  # location
  :joined_at,
  :updated_at
)

json.devices user.devices do |device|
  json.id device.id
  json.name device.name
  json.description device.description
  json.latitude device.latitude
  json.longitude device.longitude
  json.kit_id device.kit_id
  json.status device.status
  json.last_reading_at device.last_reading_at
  json.added_at device.added_at
  json.updated_at device.updated_at
end
