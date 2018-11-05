class SensorTag < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :sensor
end
