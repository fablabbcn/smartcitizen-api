FactoryGirl.define do
  factory :user do
    uuid { SecureRandom.uuid }
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@bitsushi.com" }
    password "password1"
    url "http://www.yahoo.com"
  end

end
