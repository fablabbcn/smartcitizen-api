class Storer

  def initialize device_id, reading
    stored = false

    begin

      device = Device.includes(:components).find(device_id)

      # identifier = version.split('-').first
      # device.set_version_if_required!(identifier)

      parsed_ts = Time.parse(reading['recorded_at'])
      raise "timestamp error" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
      ts = parsed_ts.to_i * 1000

      _data = []
      sql_data = {"" => parsed_ts}

      reading['sensors'].each do |sensor|

        begin
          sensor_id = Integer(sensor['id'])
          sensor_key = device.find_sensor_key_by_id(sensor_id)
        rescue
          sensor_key = sensor['id']
          sensor_id = device.find_sensor_id_by_key(sensor_key)
        end

        component = device.components.detect{|c|c["sensor_id"] == sensor_id}
        value = component.normalized_value( (Float(sensor['value']) rescue sensor['value']) )

        _data.push({
          name: sensor_key,
          timestamp: ts,
          value: value,
          tags: {
            device_id: device.id,
            method: 'REST'
          }
        })

        sql_data["#{sensor_id}_raw"] = value
        sql_data[sensor_id] = component.calibrated_value(value)

        reading[sensor_key] = [sensor_id, value, sql_data[sensor_id]]
      end

      Kairos.http_post_to("/datapoints", _data)
      Minuteman.add("rest_readings")

      if parsed_ts > (device.last_recorded_at || Time.at(0))
        device.update_columns(last_recorded_at: parsed_ts, data: sql_data, state: 'has_published')
      end

    rescue
      stored = false
    end

    if Rails.env.production? and device
      begin
        Redis.current.publish("data-received", {
          device_id: device.id,
          device: JSON.parse(device.to_json(only: [:id, :name, :location])),
          timestamp: ts,
          readings: reading.except!('recorded_at', 'sensors'),
          stored: stored
          data: JSON.parse(ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: device, current_user: nil}))
        }.to_json)
      rescue
      end
    end

  end

end
