class Component < ActiveRecord::Base
  belongs_to :board, polymorphic: true
  belongs_to :sensor

  validates_presence_of :board, :sensor
  validates_uniqueness_of :board_id, scope: :sensor_id
end
