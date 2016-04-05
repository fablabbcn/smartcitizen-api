# A Device can have many Tags, and a Tag can have many Devices.

class DevicesTag < ActiveRecord::Base
  belongs_to :device
  belongs_to :tag
end
