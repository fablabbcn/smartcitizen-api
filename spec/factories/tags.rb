FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}"}
    description { "tag description" }
  end

end
