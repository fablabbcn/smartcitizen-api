json.(device,
  :id,
  :uuid,
  :name,
  :description,
  :state,
  :hardware_info,
  :system_tags,
  :user_tags,
  :notify_low_battery,
  :notify_stopped_publishing,
  :last_reading_at,
  :added_at,
  :updated_at
)

if current_user and (current_user.is_admin? or (device.owner_id and current_user.id == device.owner_id))
  json.merge! mac_address: device.mac_address
else
  json.merge! mac_address: '[FILTERED]'
end

if device.owner
  json.owner do
    json.id device.owner.id
    json.uuid device.owner.uuid
    json.username device.owner.username
    json.avatar device.owner.avatar
    json.url device.owner.url
    json.joined_at device.owner.joined_at
    json.location device.owner.location
    json.device_ids device.owner.cached_device_ids
  end
else
  json.merge! owner: nil
end

json.data device.formatted_data

if device.kit
  json.kit device.kit, :id, :uuid, :slug, :name, :description, :created_at, :updated_at
else
  json.merge! kit: nil
end
