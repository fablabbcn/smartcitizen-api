class Storer

  def initialize device_id, reading

    device = Device.includes(:components).find(device_id)

    # identifier = version.split('-').first
    # device.set_version_if_required!(identifier)

    parsed_ts = Time.parse(reading['recorded_at'])
    raise "timestamp error" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
    ts = parsed_ts.to_i * 1000

    _data = []
    sql_data = {"" => parsed_ts}

    reading['sensors'].each do |sensor|
      sensor_id = sensor['id'].to_i

      component = device.components.detect{|c|c["sensor_id"] == sensor_id}
      metric = device.find_sensor_key_by_id( sensor_id )
      value = component.normalized_value( (Float(sensor['value']) rescue sensor['value']) )
      _data.push({
        name: metric,
        timestamp: ts,
        value: value,
        tags: {
          device_id: device.id,
          method: 'REST'
        }
      })

      sql_data["#{sensor_id}_raw"] = value
      sql_data[sensor_id] = component.calibrated_value(value)
    end

    Kairos.http_post_to("/datapoints", _data)
    Minuteman.add("rest_readings")

    if parsed_ts > (device.last_recorded_at || Time.at(0))
      device.update_columns(last_recorded_at: parsed_ts, data: sql_data, state: 'has_published')
    end

  end

end
