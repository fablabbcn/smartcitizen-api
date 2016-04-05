# Measurements are descriptions of what sensors do.
class Measurement < ActiveRecord::Base
  has_many :sensors
  validates_presence_of :name, :description
  validates_uniqueness_of :name
end
