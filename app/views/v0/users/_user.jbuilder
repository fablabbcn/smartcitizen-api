json.(user,
  :id,
  :uuid,
  :role,
  :username,
  :avatar,
  :profile_picture,
  :url,
  :location,
  :joined_at,
  :updated_at
)

json.profile_picture profile_picture_url(user)

if current_user and (current_user.is_admin? or current_user == user)
  json.merge! email: user.email
  json.merge! legacy_api_key: user.legacy_api_key
else
  json.merge! email: '[FILTERED]'
  json.merge! legacy_api_key: '[FILTERED]'
end

json.devices user.devices.filter { |d|
  !d.is_private? || current_user == user || current_user&.is_admin?
} do |device|
  json.id device.id
  json.uuid device.uuid
  json.is_private device.is_private

  if current_user and (current_user.is_admin? or (device.owner_id and current_user.id == device.owner_id))
    json.mac_address device.mac_address
  else
    json.mac_address '[FILTERED]'
    if device.is_private?
      next
    end
  end

  json.name device.name.present? ? device.name : nil
  json.description device.description.present? ? device.description : nil
  json.location device.location
  json.latitude device.latitude
  json.longitude device.longitude
  json.kit_id device.kit_id
  json.state device.state
  json.system_tags device.system_tags
  json.last_reading_at device.last_reading_at
  json.added_at device.added_at.utc.iso8601
  json.updated_at device.updated_at.utc.iso8601
end
