# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

unless Rails.env.development?
  puts "No seeds for mode: #{Rails.env}"
  exit
end

p '------ Seeding for development environment ------'

User.create(
  username: 'user1',
  email: 'email@example.com',
  password: 'password'
)

Kit.create(
  name: Faker::Educator.campus,
  description: Faker::Lorem.sentence(5)
)

Measurement.create(
  [
    { name: 'air temperature',  description: 'How hot is the air' },
    { name: 'light',  description: 'Lux is a measure' }
  ]
)

Sensor.create(
  name: 'sensor1',
  description: 'sens descript'
)

Tag.create(
  [
    { name: 'Amsterdam', description: 'SCK in Adam' },
    { name: 'Manchester', description: 'SCK in Manchester' }
  ]
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
  owner: User.first,
  name: 'device2',
  description: 'device descript',
  #mac_address: 'macaddress',
#  latitude: 1.1,
#  longitude: 1.2,
  kit: Kit.first
)

#DevicesTag.create(
#  device: Device.first,
#  tag: Tag.first
#)
