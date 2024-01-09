# Every Device has one or more sensors.

class Sensor < ActiveRecord::Base

  has_many :components
  has_many :devices, through: :components

  has_many :sensor_tags
  has_many :tag_sensors, through: :sensor_tags

  belongs_to :measurement, optional: :true

  attr_accessor :latest_reading

  has_ancestry
  validates_presence_of :name, :description#, :unit

  def self.ransackable_attributes(auth_object = nil)
    ["ancestry", "created_at", "description", "id", "measurement_id", "name", "unit", "updated_at", "uuid"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def tags
    tag_sensors.map(&:name)
  end

end
