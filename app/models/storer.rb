class Storer

  def initialize device_id, reading
    stored = true
    begin
      device = Device.includes(:components).find(device_id)

      parsed_ts = ReadingsHandler.timestamp_parse(reading['recorded_at'])
      ts = parsed_ts.to_i * 1000

      _data = []
      sql_data = {"" => parsed_ts}

      reading['sensors'].each do |sensor_data|
        sensor = SensorReader.new(device, sensor_data)

        _data.push(sensor.data_hash(ts))

        sql_data["#{sensor.id}_raw"] = sensor.value
        sql_data[sensor.id] = sensor.component.calibrated_value(sensor.value)

        reading[sensor.key] = [sensor.id, sensor.value, sql_data[sensor.id]]
      end

      Kairos.http_post_to("/datapoints", _data)
      Minuteman.add("rest_readings")

      ReadingsHandler.update_device(device, parsed_ts, sql_data)

    rescue Exception => e
      stored = false
    end

    ReadingsHandler.redis_publish(device, reading, ts, stored)

    raise e unless e.nil?
  end
end
