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

if current_user and current_user.profile_picture.attached?
  json.profile_picture Rails.application.routes.url_helpers.url_for(current_user.profile_picture)
  #json.merge! profile_picture: url_for(current_user.profile_picture.service_url)
else
  json.profile_picture ''
end

if current_user and (current_user.is_admin? or current_user == user)
  json.merge! email: user.email
  json.merge! legacy_api_key: user.legacy_api_key
else
  json.merge! email: '[FILTERED]'
  json.merge! legacy_api_key: '[FILTERED]'
end

json.devices user.devices do |device|
  json.id device.id
  json.uuid device.uuid
  if current_user and (current_user.is_admin? or (device.owner_id and current_user.id == device.owner_id))
    json.mac_address device.mac_address
  else
    json.mac_address '[FILTERED]'
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
