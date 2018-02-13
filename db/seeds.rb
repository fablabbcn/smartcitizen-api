# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
  username: 'user1',
  email: 'email@example.com',
  password: 'password'
)

Kit.create(
  name: 'kit',
  description: 'my description'
)

Measurement.create(
  name: 'my measure',
  description: 'meas descr'
)

Sensor.create(
  name: 'sensor1',
  description: 'sens descript'
)

Tag.create(
  name: 'tag1',
  description: 'tag descript'
)

#ApiToken.create(
#  owner_id: User.first,
#  token: 'random token'
#)

#Component.create(
#  board_id: 
#)

#device has many sensors through components
Device.create(
  owner_id: User.first,
  name: 'device1',
  description: 'device descript',
  mac_address: 'macaddress',
  latitude: 1.1,
  longitude: 1.2,
  kit_id: Kit.first
)

DevicesTag.create(
  device: Device.first,
  tag: Tag.first
)
