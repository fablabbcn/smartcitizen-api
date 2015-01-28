FactoryGirl.define do
  factory :api_token do
    association :owner, factory: :user
    token "662a0f34-5ec6-48f8-bdd3-09d1a03e5496"
  end

end
