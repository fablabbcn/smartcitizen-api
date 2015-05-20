json.array! @devices do |device|
  json.id device.id
  json.name device.name
  json.description device.description
  json.status device.status
  json.added_at device.added_at
  json.last_reading_at device.last_reading_at
  json.updated_at device.updated_at
  json.owner device.owner
end
