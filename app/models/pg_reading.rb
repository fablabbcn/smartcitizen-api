class PgReading < ActiveRecord::Base
  belongs_to :device
  attr_accessor :sensor_4

end
