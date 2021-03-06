json.me do
  json.(@user,
    :id,
    :username,
    :city,
    :email,
    :location
  )

  json.merge! country: @user.country_name
  json.merge! website: nil
  json.merge! created: @user.created_at

  json.devices @user.devices, partial: 'v001/devices/device', as: :device

end

# "me": {
#   "id": "5",
#   "username": "Guillem",
#   "city": "Barcelona",
#   "country": "Spain",
#   "website": "",
#   "email": "g8i113m@gmail.com",
#   "created": "2013-04-23 00:34:13",
#   "devices": [
#     {
#       "id": "24",
#       "title": "Pral2a",
#       "description": "Test",
#       "location": "Barcelona",
#       "city": "Barcelona",
#       "country": "Spain",
#       "exposure": "outdoor",
#       "elevation": "100.0",
#       "geo_lat": "41.383180",
#       "geo_long": "2.157960",
#       "created": "2013-04-24 18:09:05",
#       "last_insert_datetime": "2013-05-16 11:44:56"
#     }
#   ]
# }