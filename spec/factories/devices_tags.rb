FactoryBot.define do
  factory :devices_tag do
    association :device
    association :tag
  end

end
