# Every Device has one or more sensors. A Kit is a blueprint/group of sensors.
# A Kit is not an SCK. There is a naming conflict with the frontend, please see
# app/models/kit.rb for more information.

class Sensor < ActiveRecord::Base

  has_many :components
  has_many :boards, through: :components
  has_many :kits, through: :components
  has_many :sensor_tags
  belongs_to :measurement

  attr_accessor :latest_reading

  has_ancestry
  validates_presence_of :name, :description#, :unit

  def tags
    sensor_tags.map(&:name)
  end

end
