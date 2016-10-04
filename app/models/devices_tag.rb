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

# A Device can have many Tags, and a Tag can have many Devices.

class DevicesTag < ActiveRecord::Base
  belongs_to :device
  belongs_to :tag
end
