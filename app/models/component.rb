# This joins a device with its sensors.

class Component < ActiveRecord::Base
  belongs_to :device
  belongs_to :sensor

  validates_presence_of :device, :sensor
  validates :sensor_id, :uniqueness => { :scope => [:device_id] }

  delegate :equation, :reverse_equation, to: :sensor

  # Accepts a raw sensor reading and uses its equation to process and return
  # a calibrated version
  # Params:
  # +x+:: raw sensor value
  def calibrated_value x
    equation ? eval( ['->x{',equation,'}'].join ).call(x) : x
  end

  def normalized_value x
    reverse_equation ? eval( ['->x{',reverse_equation,'}'].join ).call(x) : x
  end

end
