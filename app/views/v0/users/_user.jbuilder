json.(user,
  :id,
  :username,
  :first_name,
  :last_name,
  :avatar,
  :url,
  :location,
  :joined_at,
  :updated_at
)

# json. user do
#   json.id user.id
#   json.username user.username
#   json.first_name user.first_name
#   json.last_name user.last_name
#   json.avatar user.avatar
#   json.url user.url
#   json.location user.location
#   json.joined_at user.joined_at.utc.iso8601
#   json.updated_at user.updated_at.utc.iso8601
# end

  json.devices user.devices do |device|
    json.id device.id
    json.name device.name
    json.description device.description
    json.latitude device.latitude
    json.longitude device.longitude
    json.kit_id device.kit_id
    json.status device.status
    json.last_reading_at device.last_reading_at
    json.added_at device.added_at.utc.iso8601
    json.updated_at device.updated_at.utc.iso8601
  end