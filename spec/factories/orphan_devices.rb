FactoryGirl.define do
  factory :orphan_device do
    name "OrphanDeviceName"
    description "OrphanDeviceDescription"
    exposure "OrphanDeviceExposure"
    latitude 1.5
    longitude 1
    user_tags "tag1,tag2,tag3"

    before(:create) do
      3.times do
        create(:tag)
      end
    end
  end
end
