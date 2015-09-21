class RawStorer

  KEYS = %w(bat co hum light nets no2 noise panel temp)

  attr_accessor :sensors

  def initialize data

    mac = data['mac'].downcase.strip
    device = Device.includes(:components).where(mac_address: mac).last

    # version is not always present
    # undefined method `split' for nil:NilClass
    identifier = data['version'].split('-').first

    parsed_ts = Time.parse(data['timestamp'])
    ts = parsed_ts.to_i * 1000

    _data = []
    sql_data = {"" => parsed_ts}

    data.select{ |k,v| KEYS.include?(k.to_s) }.each do |sensor, value|
      metric = sensor
      value = Float(value) rescue value
      puts "\t#{metric} #{ts} #{value} device_id=#{device.id} identifier=#{identifier}"

      metric_id = device.find_sensor_id_by_key(metric)
      component = device.components.detect{|c|c["sensor_id"] == metric_id} #find_component_by_sensor_id(metric_id)
      sql_data["#{metric_id}_raw"] = value
      sql_data[metric_id] = component.calibrated_value(value)

      _data.push({
        name: metric,
        timestamp: ts,
        value: value,
        tags: {
          device_id: device.id,
          identifier: identifier
        }
      })
    end

    Kairos.http_post_to("/datapoints", _data)

    if parsed_ts > (device.last_recorded_at || Time.at(0))
      device.update_attributes(last_recorded_at: parsed_ts, data: sql_data)
    end

  end

end
