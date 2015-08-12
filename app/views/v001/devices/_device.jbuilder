json.(device,
  :id,
  :description,
  :city,
  :country,
  :exposure
)

json.merge! elevation: device.elevation.try(:to_f)
json.merge! title: device.name
json.merge! location: device.city
json.merge! geo_lat: device.latitude
json.merge! geo_lng: device.longitude
json.merge! created: device.created_at
json.merge! last_insert_datetime: device.updated_at


# last_insert_datetime

# {
#   "devices": [
#       {
#         "id": "24",
#         "title": "Pral2a",
#         "description": "Test",
#         "location": "Barcelona",
#         "city": "Barcelona",
#         "country": "Spain",
#         "exposure": "outdoor",
#         "elevation": "100.0",
#         "geo_lat": "41.383180",
#         "geo_long": "2.157960",
#         "created": "2013-04-24 18:09:05",
#         "last_insert_datetime": "2013-05-16 11:44:56"
#       }
#     ]
# }