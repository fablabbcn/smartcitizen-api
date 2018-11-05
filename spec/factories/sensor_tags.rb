FactoryBot.define do
  factory :sensor_tag do
    name { "SensorTag1" }
    description { "SensorDescription1" }
    sensor { Sensor.first }
  end
end
