local_assigns[:with_owner] = true unless local_assigns.has_key?(:with_owner)
local_assigns[:with_data] = true unless local_assigns.has_key?(:with_data)
local_assigns[:with_postprocessing] = true unless local_assigns.has_key?(:with_postprocessing)
local_assigns[:with_location] = true unless local_assigns.has_key?(:with_location)
local_assigns[:slim_owner] = false unless local_assigns.has_key?(:slim_owner)

json.(
  device,
  :id,
  :uuid,
  :name,
  :description,
  :state,
  :system_tags,
  :user_tags,
  :is_private,
  :notify_low_battery,
  :notify_stopped_publishing,
  :last_reading_at,
  :created_at,
  :updated_at
)

authorized = current_user && (current_user.is_admin? || (device.owner_id && current_user.id == device.owner_id))

if authorized
  json.merge! device_token: device.device_token
else
  json.merge! device_token: '[FILTERED]'
end
json.merge!(postprocessing: device.postprocessing) if local_assigns[:with_postprocessing]
json.merge!(location: device.formatted_location) if local_assigns[:with_location]
json.merge!(hardware: device.hardware(authorized))

if local_assigns[:with_owner] && device.owner
  json.owner do
    json.id device.owner.id
    json.uuid device.owner.uuid
    json.username device.owner.username
    json.url device.owner.url

    unless local_assigns[:slim_owner]
      json.avatar device.owner.avatar
      json.profile_picture profile_picture_url(device.owner)
      json.location device.owner.location
      json.device_ids device.owner.cached_device_ids
    end
  end
end

json.data device.formatted_data if local_assigns[:with_data]


