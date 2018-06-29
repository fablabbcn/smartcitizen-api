FactoryBot.define do

  factory :upload do
    type "Avatar"
    association :user
    original_filename "testing.jpg"
  end

end
