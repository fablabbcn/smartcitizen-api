FactoryBot.define do
  factory :sensor do
    name { "MiCS-2710" }
    description { "Metaloxide gas sensor" }
    unit { "KΩ" }
    default_key { "key_#{SecureRandom.alphanumeric(4)}"}
  end
end