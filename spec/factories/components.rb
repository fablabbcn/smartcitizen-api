FactoryBot.define do
  factory :component do
    uuid { SecureRandom.uuid }
    association :device
    association :sensor
  end

end
