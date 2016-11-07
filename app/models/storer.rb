class Storer

  def initialize device_id, reading
    begin
      @device = Device.includes(:components).find(device_id)

      parsed_ts = parse_timestamp(reading['recorded_at'])
      ts = parsed_ts.to_int * 1000

      @_data = []
      @sql_data = {"" => parsed_ts}

      reading['sensors'].each do |sensor|
        sensor_data = sensor_data_hash(sensor)

        append_data(sensor_data, ts)
        append_sql_data(sensor_data)

        reading[sensor_data[:key]] = [sensor_data[:id], sensor_data[:value], @sql_data[sensor_data[:id]]]
      end

      Kairos.http_post_to("/datapoints", _data)
      Minuteman.add("rest_readings")

      update_device(parsed_ts)

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

  def sensor_data_hash(sensor)
    begin
      sensor_id = Integer(sensor['id'])
      sensor_key = device.find_sensor_key_by_id(sensor_id)
    rescue
      sensor_key = sensor['id']
      sensor_id = device.find_sensor_id_by_key(sensor_key)
    end
    component = @device.components.detect{|c|c["sensor_id"] == sensor_id}
    value = component.normalized_value( (Float(sensor['value']) rescue sensor['value']) )

    {
      id: sensor_id,
      key: sensor_key,
      component: component,
      value: component.normalized_value( (Float(sensor['value']) rescue sensor['value']) )
    }
  end

  def append_data(sensor, ts)
    @_data.push({
      name: sensor[:key],
      timestamp: ts,
      value: sensor[:value],
      tags: {
        device_id: @device.id,
        method: 'REST'
      }
    })
  end

  def append_sql_data(sensor)
    @sql_data["#{sensor[:id]}_raw"] = value
    @sql_data[sensor[:id]] = sensor[:component].calibrated_value(sensor[:value])
  end

  def update_device(parsed_ts)
    if parsed_ts > (device.last_recorded_at || Time.at(0))
      device.update_columns(last_recorded_at: parsed_ts, data: @sql_data, state: 'has_published')
    end
  end

  def redis_publish(readings, ts, stored = true)
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
