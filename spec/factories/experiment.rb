FactoryBot.define do
  factory :experiment do
    sequence("name") { |n| "experiment#{n}"}
    description { "my experiment" }
    association :owner, factory: :user
    active { true }
    is_test { false }
  end
end
