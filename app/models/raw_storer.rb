# Like app/models/kairos.rb, this class needs to be refactored and moved into
# /lib or /app/workers. It is called asynchronously by sidekiq and is used to
# ingest raw data posted by Devices into Kairos and Postgres (backup purposes).

class RawStorer
  include MessageForwarding

  def store data, mac, version, ip, raise_errors=false
    success = true

    begin

      readings = {}

      mac = mac.downcase.strip
      device = Device.includes(:components).where(mac_address: mac).last

      identifier = version.split('-').first

      ts = data['timestamp'] || data[:timestamp]
      parsed_ts = Time.parse(ts)
      raise "timestamp error (raw)" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
      ts = parsed_ts.to_i * 1000

      _data = []
      sql_data = {"" => parsed_ts}

      data.select{ |k,v| device.sensor_keys.include?(k.to_s) }.each do |sensor, value|
        metric = sensor

        metric_id = device.find_sensor_id_by_key(metric)

        component = device.find_or_create_component_by_sensor_id(metric_id)
        next if component.nil?

        value = component.normalized_value( (Float(value) rescue value) )
        # puts "\t#{metric} #{ts} #{value} device=#{device.id} identifier=#{identifier}"

        sql_data["#{metric_id}_raw"] = value
        sql_data[metric_id] = component.calibrated_value(value)

        _data.push({
          name: metric,
          timestamp: ts,
          value: value,
          tags: {
            device_id: device.id,
            identifier: "sck#{identifier}"
          }
        })

        readings[sensor] = [metric_id, value, sql_data[metric_id]]
      end

      #Kairos.http_post_to("/datapoints", _data)
      Redis.current.publish('telnet_queue', _data.to_json)
      sensor_ids = sql_data.select {|k, v| k.is_a?(Integer) }.keys.compact.uniq
      device.update_component_timestamps(parsed_ts, sensor_ids)

      if parsed_ts > (device.last_reading_at || Time.at(0))
        # update without touching updated_at
        device.update_columns(last_reading_at: parsed_ts, data: sql_data, state: 'has_published')
      end

      forward_reading(device, sql_data)
    rescue Exception => e

      success = false
      raise e if raise_errors
    end

    if !Rails.env.test? and device
      begin
        Redis.current.publish("data-received", renderer.render( partial: "v0/devices/device", locals: {device: @device, current_user: nil}))
      rescue
      end
    end
  end
end
