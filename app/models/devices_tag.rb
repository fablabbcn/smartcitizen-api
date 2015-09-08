class DevicesTag < ActiveRecord::Base
  belongs_to :device
  belongs_to :tag
end
