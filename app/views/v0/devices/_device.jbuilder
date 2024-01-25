with_owner = true unless local_assigns.has_key?(:with_owner)
with_data = true unless local_assigns.has_key?(:with_data)

json.(
  device,
  :id,
  :uuid,
  :name,
  :description,
  :state,
  :postprocessing,
  :system_tags,
  :user_tags,
  :is_private,
  :notify_low_battery,
  :notify_stopped_publishing,
  :last_reading_at,
  :hardware,
  :created_at,
  :updated_at
)

if current_user and (current_user.is_admin? or (device.owner_id and current_user.id == device.owner_id))
  json.merge! mac_address: device.mac_address
  json.merge! device_token: device.device_token
else
  json.merge! mac_address: '[FILTERED]'
  json.merge! device_token: '[FILTERED]'
end

if with_owner && device.owner
  json.owner do
    json.id device.owner.id
    json.uuid device.owner.uuid
    json.username device.owner.username
    json.avatar device.owner.avatar

    json.profile_picture profile_picture_url(device.owner)

    json.url device.owner.url
    json.location device.owner.location
    json.device_ids device.owner.cached_device_ids
  end
end

json.data device.formatted_data if with_data


