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

authorized = current_user && current_user == user || current_user&.is_admin?

if authorized
  json.merge! email: user.email
  json.merge! legacy_api_key: user.legacy_api_key
else
  json.merge! email: '[FILTERED]'
  json.merge! legacy_api_key: '[FILTERED]'
end

json.devices user.devices.filter { |d|
  !d.is_private? || authorized
}.map do |device|
  json.partial! "devices/device", device: device, with_data: false, with_owner: false, with_location: authorized
end
