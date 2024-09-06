json.(user,
  :id,
  :uuid,
  :role,
  :username,
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
  json.merge! forwarding_token: user.forwarding_token
  json.merge! forwarding_username: user.forwarding_username
else
  json.merge! email: '[FILTERED]'
  json.merge! legacy_api_key: '[FILTERED]'
  json.merge! forwarding_token: '[FILTERED]'
  json.merge! forwarding_username: '[FILTERED]'
end

json.devices user.devices.filter { |d|
  !d.is_private? || authorized
}.map do |device|
  json.partial! "devices/device", device: device, with_data: false, with_owner: false, with_location: authorized
end
