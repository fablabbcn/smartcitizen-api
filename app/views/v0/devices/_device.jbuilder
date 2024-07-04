local_assigns[:with_owner] = true unless local_assigns.has_key?(:with_owner)
local_assigns[:with_data] = true unless local_assigns.has_key?(:with_data)
local_assigns[:with_postprocessing] = true unless local_assigns.has_key?(:with_postprocessing)
local_assigns[:with_location] = true unless local_assigns.has_key?(:with_location)
local_assigns[:slim_owner] = false unless local_assigns.has_key?(:slim_owner)
local_assigns[:never_authorized] = false unless local_assigns.has_key?(:never_authorized)

json.(
  device,
  :id,
  :uuid,
  :name,
  :description,
  :state,
  :system_tags,
  :user_tags,
  :last_reading_at,
  :created_at,
  :updated_at
)

  json.merge!(notify: {
    stopped_publishing: device.notify_stopped_publishing,
    low_battery: device.notify_low_battery
  })

authorized = !local_assigns[:never_authorized] && (current_user && (current_user.is_admin? || (device.owner_id && current_user.id == device.owner_id)))

if authorized
  json.merge! device_token: device.device_token
  json.merge! mac_address: device.mac_address if device.mac_address
else
  json.merge! device_token: '[FILTERED]'
end
json.merge!(postprocessing: device.postprocessing) if local_assigns[:with_postprocessing]
json.merge!(location: device.formatted_location) if local_assigns[:with_location]
json.merge!(data_policy: device.data_policy(authorized))
json.merge!(hardware: device.hardware(authorized))

if local_assigns[:with_owner] && device.owner
  json.owner do
    json.id device.owner.id
    json.uuid device.owner.uuid
    json.username device.owner.username
    json.url device.owner.url

    unless local_assigns[:slim_owner]
      json.profile_picture profile_picture_url(device.owner)
      json.location device.owner.location
      json.device_ids device.owner.cached_device_ids
    end
  end
end

json.data device.formatted_data if local_assigns[:with_data]


