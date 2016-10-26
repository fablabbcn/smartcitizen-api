FactoryGirl.define do
  factory :orphan_device do
    name "MyString"
    description "MyText"
    kit_id 1
    exposure "MyString"
    latitude 1.5
    longitude 1
    user_tags "MyText"
    owner_username "MyString"
  end
end
