local_assigns[:never_authorized] = false unless local_assigns.has_key?(:never_authorized)

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


authorized = !local_assigns[:never_authorized] && (current_user && (current_user.is_admin? || (device.owner_id && current_user.id == device.owner_id)))

json.merge!(location: device.formatted_location(true))
json.merge!(hardware: device.hardware(authorized))

if device.owner
  json.owner do
    json.id device.owner.id
    json.username device.owner.username
    json.url device.owner.url
  end
end


