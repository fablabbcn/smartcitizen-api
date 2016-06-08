class Storer

  def initialize device_id, reading

    # Reading.create(
    #   kit_id: kit,
    #   recorded_at: Time.now,
    #   sensors: [{id:1,value:2}]
    # )

    device = Device.includes(:components).find(device_id)

    # identifier = version.split('-').first
    # device.set_version_if_required!(identifier)

    parsed_ts = Time.parse(reading['recorded_at'])
    raise "timestamp error" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
    ts = parsed_ts.to_i * 1000

    _data = []

    reading['sensors'].each do |sensor|
      component = device.components.detect{|c|c["sensor_id"] == sensor['id'].to_i}
      metric = device.find_sensor_key_by_id( sensor['id'].to_i )
      value = component.normalized_value( (Float(value) rescue value) )
      _data.push({
        name: metric,
        timestamp: ts,
        value: value,
        tags: {
          device_id: device.id,
          method: 'REST'
        }
      })
    end

    Kairos.http_post_to("/datapoints", _data)

    Minuteman.add("rest_readings")

  end

end
