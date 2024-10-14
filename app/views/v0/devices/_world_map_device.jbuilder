json.(
  device,
  :id,
  :name,
  :description,
  :state,
  :system_tags,
  :user_tags,
  :last_reading_at,
)

json.merge!(location: device.formatted_location(true))
json.merge!(hardware: device.hardware(false))

