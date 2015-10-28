FactoryGirl.define do
  factory :device do
    association :owner, factory: :user
    sequence("name") { |n| "device#{n}"}
    description "my device"
    mac_address { Faker::Internet.mac_address }
    latitude 41.3966908
    longitude 2.1921909
    elevation 100
  end

end
