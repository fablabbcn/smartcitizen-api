# This joins a device with its sensors.

class Component < ActiveRecord::Base
  belongs_to :device
  belongs_to :sensor

  validates_presence_of :device, :sensor

  # IMPORTANT: Validation of sensor/device uniqueness is done at the database level,
  # as this allows us to use the create_or_find_by! method to atomically upsert components
  # in the mqtt-task, avoiding component duplication due to race conditions.
  # For some reason, create_or_find_by! ONLY works when the database constraint is
  # the ONLY uniqueness constraint on those two values, so adding a rails validation here
  # causes an error. Leaving the validations here commented out by way of documentation.
  # See https://stackoverflow.com/questions/74566974/create-or-find-by-not-working-as-it-should-in-rails-6
  # validates :sensor_id, :uniqueness => { :scope => [:device_id] }
  # validates :key, :uniqueness => { :scope =>  [:device_id] }


  before_validation :set_key, on: :create

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

  def get_unique_key(default_key, other_keys)
    matching_keys = other_keys.select { |k| k =~ /^#{default_key}/ }
    ix = matching_keys.length
    ix == 0 ? default_key : "#{default_key}_#{ix}"
  end

  private

  def set_key
    if sensor && device && !key
      default_key = sensor.default_key
      other_component_keys = device.components.map(&:key)
      self.key = get_unique_key(default_key, other_component_keys)
    end
  end
end
