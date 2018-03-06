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
  password: 'password',
  country_code: Faker::Address.country_code,
  city: Faker::Address.city
)

Kit.create(name: 'Making Sense WAAG #1', description: 'AQM sensor by WAAG')
3.times do
  Kit.create(
    name: Faker::Educator.campus,
    description: Faker::Lorem.sentence(5)
  )
end

Measurement.create(
  [
    { name: 'air temperature',  description: 'How hot is the air', unit: 'C' },
    { name: 'light',  description: 'Lux is a measure', unit: 'lux' }
  ]
)

Sensor.create(
  [
    {
      name: 'My temp sensor',
      unit: 'temperature unit',
      measurement: Measurement.first,
      description: 'temp sens descript'
    },
    {
      name: 'My light sensor',
      unit: 'light unit',
      measurement: Measurement.second,
      description: 'light sens descript'
    }
  ]
)

#TODO: belongs_to :board, polymorphic: true
Component.create(
  # TODO: Is this correct? Is Kit a board?
  board: Kit.first,
  sensor: Sensor.first,
  #board_type:
)

#device has many sensors through components
#has_many :components, as: :board
4.times do
  Device.create(
    {
      owner: User.first,
      name: Faker::Address.city,
      description: Faker::Address.street_name,
      mac_address: Faker::Internet.mac_address,
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      device_token: Faker::Crypto.sha1,
      kit: Kit.all.sample
    }
  )
end

Tag.create(
  [
    { name: 'Amsterdam', description: 'SCK in Adam' },
    { name: 'Barcelona', description: 'SCK in Barcelona' },
    { name: 'Manchester', description: 'SCK in Manchester' }
  ]
)

DevicesTag.create(
  [
    { device: Device.first, tag: Tag.first },
    { device: Device.first, tag: Tag.second },
    { device: Device.second, tag: Tag.second }
  ]
)

#ApiToken.create(
#  owner_id: User.first,
#  token: 'random token'
#)

