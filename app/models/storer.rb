class Storer

  def initialize device_id, reading
    stored = true
    begin
      @device = Device.includes(:components).find(device_id)

      parsed_ts = parse_timestamp(reading['recorded_at'])
      ts = parsed_ts.to_i * 1000

      _data = []
      sql_data = {"" => parsed_ts}

      reading['sensors'].each do |sensor_data|
        sensor = SensorReader.new(@device, sensor_data)

        _data.push(sensor.data_hash(ts))

        sql_data["#{sensor.id}_raw"] = sensor.value
        sql_data[sensor.id] = sensor.component.calibrated_value(sensor.value)

        reading[sensor.key] = [sensor.id, sensor.value, sql_data[sensor.id]]
      end

      Kairos.http_post_to("/datapoints", _data)
      Minuteman.add("rest_readings")

      update_device(parsed_ts, sql_data)

    rescue Exception => e
      stored = false
    end

    redis_publish(reading.except!('recorded_at', 'sensors'), ts, stored)

    raise e unless e.nil?
  end

  private

  def parse_timestamp(timestamp)
    parsed_ts = Time.parse(timestamp)
    raise "timestamp error" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
    parsed_ts
  end

  def update_device(parsed_ts, sql_data)
    if parsed_ts > (@device.last_recorded_at || Time.at(0))
      @device.update_columns(last_recorded_at: parsed_ts, data: sql_data, state: 'has_published')
    end
  end

  def redis_publish(readings, ts, stored)
    return unless Rails.env.production? and @device
    begin
      Redis.current.publish("data-received", {
        device_id: @device.id,
        device: JSON.parse(@device.to_json(only: [:id, :name, :location])),
        timestamp: ts,
        readings: readings,
        stored: stored,
        data: JSON.parse(ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: @device, current_user: nil}))
      }.to_json)
    rescue
    end
  end
end
