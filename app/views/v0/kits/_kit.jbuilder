json.(kit,
  :id, :uuid, :slug, :name, :description, :created_at, :updated_at
)

# json . kit do
#   json.id kit.id
#   json.slug kit.slug
#   json.name kit.name
#   json.description kit.description
#   json.created_at kit.created_at.utc.iso8601
#   json.updated_at kit.updated_at.utc.iso8601
# end

json.sensors kit.sensors
