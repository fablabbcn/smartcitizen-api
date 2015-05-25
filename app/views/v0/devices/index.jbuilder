json.array! @devices, partial: 'device', as: :device

# json.array! @devices do |device|
#   json.id device.id
#   json.name device.name
#   json.description device.description
#   json.status device.status
#   json.added_at device.added_at
#   json.last_reading_at device.last_reading_at
#   json.updated_at device.updated_at

#   json.kit_id device.kit_id

#   json.owner device.owner, :id, :username, :first_name, :last_name, :avatar, :url, :joined_at, :location, :device_ids
# end
