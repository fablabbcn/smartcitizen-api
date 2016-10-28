FactoryGirl.define do
  factory :orphan_device do
    name "OrphanDeviceName"
    description "OrphanDeviceDescription"
    kit_id 1
    exposure "OrphanDeviceExposure"
    latitude 1.5
    longitude 1
    user_tags "tag,tag2,tag3"
  end
end
