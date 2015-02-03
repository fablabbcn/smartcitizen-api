FactoryGirl.define do
  factory :device do
    association :owner, factory: :user
    sequence("name") { |n| "device#{n}"}
    description "my device"
    mac_address { Faker::Internet.mac_address }
    latitude 53.3069303
    longitude -3.7495789
  end

end
