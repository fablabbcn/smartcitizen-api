json.(user,
  :id,
  :uuid,
  :role,
  :username,
  :first_name,
  :last_name,
  :avatar,
  :url,
  :location,
  :joined_at,
  :updated_at
)

if current_user and (current_user.is_admin? or current_user == user)
  json.merge! email: user.email
else
  json.merge! email: '[FILTERED]'
end

json.devices user.devices do |device|
  json.id device.id
  json.uuid device.uuid
  if current_user and (current_user.is_admin? or (device.owner_id and current_user.id == device.owner_id))
    json.mac_address device.mac_address
  else
    json.mac_address '[FILTERED]'
  end
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
