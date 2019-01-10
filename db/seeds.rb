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

p '---- Seeding for development environment ----'

User.create(
  username: 'user1',
  email: 'email@example.com',
  password: 'password',
  country_code: Faker::Address.country_code,
  city: Faker::Address.city
)

#Kit.create(name: 'Making Sense WAAG #1', description: 'AQM sensor by WAAG', slug:'makingSenseSlug')
# Kits need to have a sensor_map
3.times do
  Kit.create(
    name: "Kit #{Faker::Educator.campus}",
    description: Faker::Lorem.sentence(5),
    slug: 'sck:1,1',
    sensor_map: {"temp": 12, "hum": 13, "light": 14}
  )
end

Measurement.create(
  [
    { name: 'air temperature',  description: 'How hot is the air', unit: 'C' },
    { name: 'air humidity',  description: 'How humit is the air', unit: '% Rel' },
    { name: 'light',  description: 'Lux is a measure', unit: 'lux' }
  ]
)

unless Sensor.exists?(12)
  Sensor.create(
    [
      {
        id: 12,
        name: 'My temp sensor',
        unit: 'temperature unit',
        measurement: Measurement.first,
        description: 'temp sens descript'
      },
      {
        id: 13,
        name: 'My hum sensor',
        unit: 'hum unit',
        measurement: Measurement.second,
        description: 'light sens descript'
      },
      {
        id: 14,
        name: 'My light sensor',
        unit: 'light unit',
        measurement: Measurement.third,
        description: 'light sens descript'
      }
    ]
  )
end

unless Sensor.exists?(14)
  Sensor.find(14).tag_sensors.create(
    [
      {
        name: 'environmental seed 1',
        description: 'environmental sensor tag'
      },
      {
        name: 'light seed',
        description: 'Light sensor tag'
      },
      {
        name: 'digital seed',
        description: 'Digital sensor tag'
      }
    ]
  )
end

#device has many sensors through components
#has_many :components, as: :board
5.times do
  Device.create(
    {
      owner: User.first,
      name: Faker::Address.city,
      city: Faker::Address.city,
      country_code: Faker::Address.country_code,
      description: Faker::Address.street_name,
      mac_address: Faker::Internet.mac_address,
      # reverse_geocode will FAIL if it receives a location at sea
      latitude: 42.385,
      longitude: 2.173,
      device_token: Faker::Crypto.sha1[0,6],
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

# Make the last Device an archived one?
Device.last.archive!

# belongs_to :board, polymorphic: true
# belongs_to :sensor
# Kit and Device have many Components, as: :board

Component.create(
  board: Kit.first, sensor: Sensor.find(12)
)
Component.create(
  board: Kit.first, sensor: Sensor.find(13)
)
Component.create(
  board: Kit.first, sensor: Sensor.find(14)
)
Component.create(
  board: Kit.second, sensor: Sensor.find(12)
)
Component.create(
  board: Kit.second, sensor: Sensor.find(13)
)
Component.create(
  board: Kit.second, sensor: Sensor.find(14)
)
Component.create(
  board: Kit.third, sensor: Sensor.find(12)
)
Component.create(
  board: Kit.third, sensor: Sensor.find(13)
)
Component.create(
  board: Kit.third, sensor: Sensor.find(14)
)


Tag.create(
  [
    { name: 'Amsterdam', description: 'SCK in Adam' },
    { name: 'Barcelona', description: 'SCK in Barcelona' },
    { name: 'Manchester', description: 'SCK in Manchester' }
  ]
)

begin
  DevicesTag.create(
    [
      { device: Device.first, tag: Tag.first },
      { device: Device.first, tag: Tag.second },
      { device: Device.second, tag: Tag.second }
    ]
  )
rescue
  p 'DevicesTags already created'
end

DeviceInventory.create(
  report: {"random_property":"random_result"},
)

Device.find(1).update_attributes(
  hardware_info: {
    "id": 1,
    "uuid": "7d45fead-defd-4482-bc6a-a1b711879e2d",
    "name": "Station Lab Unit 1",
    "description": "iSCAPE Station Lab test unit",
    "state": "has_published",
    "info": {
      "time":"2018-07-17T06:55:06Z",
      "hw_ver":"2.0",
      "id":"6C4C1AF4504E4B4B372E314AFF031619",
      "sam_ver":"0.3.0-ce87e64",
      "sam_bd":"2018-07-17T06:55:06Z",
      "esp_ver":"0.3.0-ce87e64",
      "esp_bd":"2018-07-17T06:55:06Z"
    }
  }
)
#ApiToken.create(
#  owner_id: User.first,
#  token: 'random token'
#)
p '---- Seeding complete! ----'
