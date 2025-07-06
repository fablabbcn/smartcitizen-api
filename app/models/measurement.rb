# Measurements are descriptions of what sensors do.
class Measurement < ActiveRecord::Base
  has_many :sensors
  belongs_to :meshtastic_default_sensor, class_name: "Sensor", optional: true

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_uniqueness_of :meshtastic_id, allow_nil: true

  def for_sensor_json
    attributes.except(*%w{created_at updated_at})
  end
end
