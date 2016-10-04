# == Schema Information
#
# Table name: components
#
#  id               :integer          not null, primary key
#  board_id         :integer
#  board_type       :string
#  sensor_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :uuid
#  equation         :text
#  reverse_equation :text
#

# This joins a device with its sensors.

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
    equation ? eval( ['->x{',equation,'}'].join ).call(x) : x
  end

  def normalized_value x
    reverse_equation ? eval( ['->x{',reverse_equation,'}'].join ).call(x) : x
  end

end
