class Measurement < ActiveRecord::Base
  has_many :sensors
  validates_presence_of :name, :description, :unit
  validates_uniqueness_of :name
end
