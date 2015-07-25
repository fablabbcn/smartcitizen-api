FactoryGirl.define do
  factory :component do
    association :board, factory: :kit
    association :sensor
  end

end
