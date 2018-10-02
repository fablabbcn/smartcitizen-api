FactoryBot.define do
  factory :measurement do
    sequence(:name) { |i| "Temperature #{i}" }
    description { "How hot something is" }
    unit { "C" }
  end
end