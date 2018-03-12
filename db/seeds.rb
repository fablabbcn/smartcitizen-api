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

Kit.create(name: 'Making Sense WAAG #1', description: 'AQM sensor by WAAG', slug:'makingSenseSlug')
3.times do
  Kit.create(
    name: Faker::Educator.campus,
    description: Faker::Lorem.sentence(5),
    slug: 'sck:1,1',
    sensor_map: '{"noise": 7, "temp": 12, "light": 14, "no2": 15}'
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
      data: {
        7  => 50,
        12 => -0.629348144531249,
        13 => 131.992370605469,
        14 => 37.8,
        15 => 27.384,
        16 => 275.303,
        17 => 100
      },
      kit: Kit.all.sample
    }
  )
end

# belongs_to :board, polymorphic: true
# belongs_to :sensor
# Kit and Device have many Components, as: :board
Component.create( board: Kit.first, sensor: Sensor.first)
Component.create( board: Device.first, sensor: Sensor.first)
Component.create( board: Device.second, sensor: Sensor.second)

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

