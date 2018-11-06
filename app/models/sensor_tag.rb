class SensorTag < ActiveRecord::Base
  belongs_to :sensor
  belongs_to :tag_sensor
end
