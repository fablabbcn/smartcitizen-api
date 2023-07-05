json.(user,
  :id,
  :uuid,
  :role,
  :username,
  :avatar,
  :profile_picture,
  :url,
  :location,
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
}.map do |device|
  json.partial! "devices/device", device: device, with_data: false, with_owner: false
  if current_user == user || current_user&.is_admin?
    json.merge!(
      location: device.location,
      latitude: device.latitude,
      longitude: device.longitude,
    )
  end
end
