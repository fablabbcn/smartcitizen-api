class Component < ActiveRecord::Base
  belongs_to :board, polymorphic: true
  belongs_to :sensor

  validates_presence_of :board, :sensor
  validates :sensor_id, :uniqueness => { :scope => [:board_id, :board_type] }

  # Accepts a raw sensor reading and uses its equation to process and return
  # a calibrated version
  # Params:
  # +x+:: raw sensor value
  def calibrated_value x
    return x unless equation
    eval( ['->x{',equation,'}'].join ).call(x)
  end

end
