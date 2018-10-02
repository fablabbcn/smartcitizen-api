FactoryBot.define do
  factory :orphan_device do
    name { "OrphanDeviceName" }
    description { "OrphanDeviceDescription" }
    kit_id { 1 }
    exposure { "indoor" }
    # same coordinates used for testing Device
    latitude { 41.3966908 }
    longitude { 2.1921909 }
    user_tags { "tag1,tag2" }
  end
end
