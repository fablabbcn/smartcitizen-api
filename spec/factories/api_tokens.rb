FactoryGirl.define do
  factory :api_token do
    association :owner, factory: :user
  end

end
