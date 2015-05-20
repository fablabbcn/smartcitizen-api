json.(@device,
  :id,
  :name,
  :description,
  :status,
  :added_at,
  :last_reading_at,
  :updated_at
)

json.owner @device.owner, :id, :username, :first_name, :last_name, :avatar, :url, :joined_at, :location#, :devices

json.data @device.formatted_data

json.kit @device.kit, :id, :slug, :name, :description, :created_at, :updated_at
