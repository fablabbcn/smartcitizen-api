FactoryGirl.define do
  factory :component do
    association :board
    association :sensor
  end

end
