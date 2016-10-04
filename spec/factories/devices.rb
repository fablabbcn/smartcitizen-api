# == Schema Information
#
# Table name: devices
#
#  id                      :integer          not null, primary key
#  owner_id                :integer
#  name                    :string
#  description             :text
#  mac_address             :macaddr
#  latitude                :float
#  longitude               :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  kit_id                  :integer
#  latest_data             :hstore
#  geohash                 :string
#  last_recorded_at        :datetime
#  meta                    :jsonb
#  location                :jsonb
#  data                    :jsonb
#  old_data                :jsonb
#  owner_username          :string
#  uuid                    :uuid
#  migration_data          :jsonb
#  workflow_state          :string
#  csv_export_requested_at :datetime
#  old_mac_address         :macaddr
#  state                   :string
#

FactoryGirl.define do
  factory :device do
    uuid { SecureRandom.uuid }
    association :owner, factory: :user
    sequence("name") { |n| "device#{n}"}
    description "my device"
    mac_address { Faker::Internet.mac_address }
    latitude 41.3966908
    longitude 2.1921909
    elevation 100
  end

end
