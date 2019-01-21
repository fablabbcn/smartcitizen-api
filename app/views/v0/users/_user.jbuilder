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

if user.profile_picture.attached?
  # TODO: Active Storage: dont manually splice the URLs together. Use Active Storage standard way for getting full URL
  json.profile_picture request.base_url + url_for(user.profile_picture)
  json.profile_picture2 request.base_url + url_for(user.profile_picture.variant(resize:"100x100"))
else
  # The angular frontend checks if this is empty.
  # If profile_picture is empty, it will use the avatar url
  # If the avatar is also empty, it will use default.svg
  # So it is better to leave this empty, for now, until stop the avatar property
  #json.profile_picture 'https://smartcitizen.s3.amazonaws.com/avatars/default.svg'
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
