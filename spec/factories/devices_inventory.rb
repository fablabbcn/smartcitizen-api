FactoryBot.define do
  factory :device_inventory do
    report { "{'random_property':'random_result'}" }
    created_at { "2015-10-07 17:22:01" }
  end
end
