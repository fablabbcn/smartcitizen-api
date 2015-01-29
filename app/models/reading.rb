class Reading

  include Cequel::Record

  key :id, :timeuuid, auto: true
  map :values, :text, :text
  column :device_id, :int, index: true
  column :recorded_at, :timestamp

  def device
    Device.find(device_id)
  end

end

# DEVICE
# name
# description
# owner_id
# kit_version
# sensor_ids: [12,3,34,45,46,7]

# SENSOR
# name
# description
# units
# type

# READING
# device_id:recorded_at
# values
#   [
#     12: 39.0
#     12: 99.0
#     12: 12.30
#     18: 15.90
#   ]
