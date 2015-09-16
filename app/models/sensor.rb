class Sensor < ActiveRecord::Base

  has_many :components
  has_many :boards, through: :components
  has_many :kits, through: :components
  belongs_to :measurement

  attr_accessor :latest_reading

  has_ancestry
  validates_presence_of :name, :description#, :unit

  def calibrated_value x
    return x unless equation
    # e.g. equation = "x/1000"
    # x = 3200
    # ->x{x/1000}
    # x = 32
    eval( ['->x{',equation,'}'].join ).call(x)
  end

end
