# == Schema Information
#
# Table name: devices_tags
#
#  id         :integer          not null, primary key
#  device_id  :integer
#  tag_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :devices_tag do
    association :device
    association :tag
  end

end
