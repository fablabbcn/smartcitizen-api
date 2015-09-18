class Component < ActiveRecord::Base
  belongs_to :board, polymorphic: true
  belongs_to :sensor

  validates_presence_of :board, :sensor
  validates :sensor_id, :uniqueness => { :scope => [:board_id, :board_type] }

  def calibrated_value x
    return x unless equation
    # e.g. equation = "x/1000"
    # x = 3200
    # ->x{x/1000}
    # x = 32
    eval( ['->x{',equation,'}'].join ).call(x)
  end

end
