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

p "---- Seeding for development environment ----"

User.create(
  username: "user1",
  email: "email@example.com",
  password: "password",
  country_code: Faker::Address.country_code,
  city: Faker::Address.city,
)

Measurement.create(
  [
    { name: "air temperature", description: "How hot is the air", unit: "C" },
    { name: "air humidity", description: "How humit is the air", unit: "% Rel" },
    { name: "light", description: "Lux is a measure", unit: "lux" },
  ]
)

unless Sensor.exists?(12)
  Sensor.create(
    [
      {
        id: 12,
        name: "My temp sensor",
        unit: "temperature unit",
        measurement: Measurement.first,
        description: "temp sens descript",
      },
      {
        id: 13,
        name: "My hum sensor",
        unit: "hum unit",
        measurement: Measurement.second,
        description: "light sens descript",
      },
      {
        id: 14,
        name: "My light sensor",
        unit: "light unit",
        measurement: Measurement.third,
        description: "light sens descript",
      },
    ]
  )
end

unless Sensor.exists?(14)
  Sensor.find(14).tag_sensors.create(
    [
      {
        name: "environmental seed 1",
        description: "environmental sensor tag",
      },
      {
        name: "light seed",
        description: "Light sensor tag",
      },
      {
        name: "digital seed",
        description: "Digital sensor tag",
      },
    ]
  )
end

10.times do
  device = Device.create(
    {
      owner: User.all.sample,
      name: Faker::Address.city,
      city: Faker::Address.city,
      country_code: Faker::Address.country_code,
      description: Faker::Address.street_name,
      mac_address: Faker::Internet.mac_address,
      # reverse_geocode will FAIL if it receives a location at sea
      latitude: 42.385,
      longitude: 2.173,
      device_token: Faker::Crypto.sha1[0, 6],
      is_private: [true, false].sample,
      notify_low_battery: [true, false].sample,
      notify_low_battery_timestamp: Time.now,
      notify_stopped_publishing: [true, false].sample,
      notify_stopped_publishing_timestamp: Time.now,
      data: {
        7 => 50,
        10 => rand(20), #battery level below 15 get emails
        12 => -0.629348144531249,
        13 => 131.992370605469,
        14 => 37.8,
        15 => 27.384,
        16 => 275.303,
        17 => 100,
      },
    }
  )

  Component.create(
    device: device, sensor: Sensor.find(12),
  )
  Component.create(
    device: device, sensor: Sensor.find(13),
  )
  Component.create(
    device: device, sensor: Sensor.find(14),
  )
  Component.create(
    device: device, sensor: Sensor.find(12),
  )
  Component.create(
    device: device, sensor: Sensor.find(13),
  )
  Component.create(
    device: device, sensor: Sensor.find(14),
  )
  Component.create(
    device: device, sensor: Sensor.find(12),
  )
  Component.create(
    device: device, sensor: Sensor.find(13),
  )
  Component.create(
    device: device, sensor: Sensor.find(14),
  )
end

# Make the last Device an archived one?
Device.last.archive!

Tag.create(
  [
    { name: "Amsterdam", description: "SCK in Adam" },
    { name: "Barcelona", description: "SCK in Barcelona" },
    { name: "Manchester", description: "SCK in Manchester" },
  ]
)

begin
  DevicesTag.create(
    [
      { device: Device.first, tag: Tag.first },
      { device: Device.first, tag: Tag.second },
      { device: Device.second, tag: Tag.second },
    ]
  )
rescue
  p "DevicesTags already created"
end

DeviceInventory.create(
  report: { "random_property": "random_result" },
)

d = Device.first
d.update!(
  hardware_info: {
    "id": 1,
    "uuid": "7d45fead-defd-4482-bc6a-a1b711879e2d",
    "name": "Station Lab Unit 1",
    "description": "iSCAPE Station Lab test unit",
    "state": "has_published",
    "info": {
      "time": "2018-07-17T06:55:06Z",
      "hw_ver": "2.0",
      "id": "6C4C1AF4504E4B4B372E314AFF031619",
      "sam_ver": "0.3.0-ce87e64",
      "sam_bd": "2018-07-17T06:55:06Z",
      "esp_ver": "0.3.0-ce87e64",
      "esp_bd": "2018-07-17T06:55:06Z",
    },
  },
)
#ApiToken.create(
#  owner_id: User.first,
#  token: 'random token'
#)
p "---- Seeding complete! ----"
