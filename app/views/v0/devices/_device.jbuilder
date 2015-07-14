json.(device,
  :id,
  :uuid,
  :name,
  :description,
  :status,
  :last_reading_at,
  :added_at,
  :updated_at
)
if current_user and (current_user.is_admin? or (device.owner_id and current_user.id == device.owner_id))
  json.merge! mac_address: device.mac_address
else
  json.merge! mac_address: '[FILTERED]'
end

# TO REMOVE
json. device do
  json.notice ">>> THIS OBJECT WILL BE DEPRECATED, USE THE ROOT PARAMETERS <<<"
  json.id device.id
  json.name device.name
  json.description device.description
  json.status device.status
  json.last_reading_at device.last_reading_at
  json.added_at device.added_at.utc.iso8601
  json.updated_at device.updated_at.utc.iso8601
  if current_user and (current_user.is_admin? or (device.owner_id and current_user.id == device.owner_id))
    json.mac_address device.mac_address
  else
    json.mac_address '[FILTERED]'
  end
end

if device.owner
  json.owner(
    device.owner, :uuid, :id, :username, :first_name, :last_name, :avatar, :url, :joined_at, :location, :device_ids
  )
end

json.data device.formatted_data

if device.kit
  json.kit device.kit, :id, :uuid, :slug, :name, :description, :created_at, :updated_at
end
