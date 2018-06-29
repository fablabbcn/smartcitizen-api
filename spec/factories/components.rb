FactoryBot.define do
  factory :component do
    uuid { SecureRandom.uuid }
    association :board, factory: :kit
    association :sensor
  end

end
