# == Schema Information
#
# Table name: bad_readings
#
#  id          :integer          not null, primary key
#  tags        :integer
#  remote_ip   :string
#  data        :jsonb            not null
#  created_at  :datetime         not null
#  message     :string
#  device_id   :integer
#  mac_address :string
#  version     :string
#  timestamp   :string
#  backtrace   :text
#

FactoryGirl.define do
  factory :bad_reading do
    tags 1
source_ip "MyString"
data ""
created_at "2015-10-07 17:22:01"
  end

end
