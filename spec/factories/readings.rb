FactoryGirl.define do
  factory :reading do
    device_id { FactoryGirl.create(:device).id }
    recorded_month { Time.now.month }
    recorded_at { Time.now }
  end

end


# CREATE TABLE readings (
#   device_id int,
#   recorded_month int,
#   recorded_at timestamp,
#   raw_data map<text, text>,
#   data map<text, text>,
#   PRIMARY KEY ((device_id, recorded_month), recorded_at)
# ) WITH CLUSTERING ORDER BY (recorded_at DESC);