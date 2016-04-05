# There is a naming conflict between frontend and backend. Here, a Kit is
# a template for Device, that includes all of its sensors. Instead of every
# Device having 9 sensors, a Device has_one Kit, and that Kit has 9 sensors.
# Doing this means 1000 SCKs == 1000 Devices, 1 Kit, 9 components and 9 sensors.
# Without Kit it would require 1000 Devices, 9000 components and 9 sensors.

 # See device.rb for more information regarding the name conflict.

class Kit < ActiveRecord::Base

  extend FriendlyId
  friendly_id :slug

  has_many :devices
  has_many :components, as: :board
  has_many :sensors, through: :components
  validates_presence_of :name, :description

end
