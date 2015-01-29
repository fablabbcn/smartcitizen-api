class Component < ActiveRecord::Base
  belongs_to :board, polymorphic: true
  belongs_to :sensor

  validates_presence_of :board, :sensor
  validates :sensor_id, :uniqueness => { :scope => [:board_id, :board_type] }
end
