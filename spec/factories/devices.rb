FactoryGirl.define do
  factory :device do
    association :owner, factory: :user
    sequence("name") { |n| "device#{n}"}
    description "my device"
    sequence(:mac_address) { |n| "#{n}1:23:45:67:89:ab" }
    latitude 53.3069303
    longitude -3.7495789
  end

end
