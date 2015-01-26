FactoryGirl.define do
  factory :user do
    first_name "John"
    last_name "Rees"
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@bitsushi.com" }
    password "password1"
  end

end
