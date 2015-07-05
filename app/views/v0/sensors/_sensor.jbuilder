json.(sensor,
  :id, :uuid, :parent_id, :name, :description, :unit, :created_at, :updated_at
  # :is_childless?,
)

if sensor.measurement
json.measurement(
  sensor.measurement, :id, :uuid, :name, :description
)
end

# json . sensor do
#   json.id sensor.id
#   json.parent_id sensor.parent_id
#   json.name sensor.name
#   json.description sensor.description
#   json.unit sensor.unit
#   json.created_at sensor.created_at.utc.iso8601
#   json.updated_at sensor.updated_at.utc.iso8601
# end