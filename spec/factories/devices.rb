FactoryBot.define do
  factory :device do
    uuid { SecureRandom.uuid }
    association :owner, factory: :user
    sequence("name") { |n| "device#{n}"}
    description { "my device" }
    mac_address { Faker::Internet.mac_address }
    latitude { 41.3966908 }
    longitude { 2.1921909 }
    elevation { 100 }
    hardware_info { { "id":47,"uuid":"7d45fead-defd-4482-bc6a-a1b711879e2d" } }
    postprocessing_info { { "a":3, "b":"test" } }
  end

end
