FactoryBot.define do
  factory :user do
    uuid { SecureRandom.uuid }
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@bitsushi.com" }
    password { "password1" }
    url { "http://www.yahoo.com" }
    role_mask { 0 }

    factory :admin do
      role_mask { 5 }
    end

    factory :researcher do
      role_mask { 2 }
    end
  end
end
