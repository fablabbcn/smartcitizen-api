class TagSensor < ActiveRecord::Base
  validates_presence_of :name

  has_many :sensor_tags
  has_many :sensors, through: :sensor_tags
end
