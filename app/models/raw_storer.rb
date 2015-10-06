class RawStorer

  attr_accessor :sensors

  def bat i, v
    return i/10.0
  end

  def co i, v
    return i/1000.0
  end

  def light i, v
    return i/10.0
  end

  def nets i, v
    return i
  end

  def no2 i, v
    return i/1000.0
  end

  def noise i, v
    return i
  end

  def panel i, v
    return i/1000.0
  end

  def hum i, v
    if v.to_s == "1.0"
      i = i/10.0
    end
    return i
  end

  def temp i, v
    if v.to_s == "1.0"
      i = i/10.0
    end
    return i
  end

  def initialize data

    keys = %w(temp bat co hum light nets no2 noise panel)

    mac = data['mac'].downcase.strip
    device = Device.includes(:components).where(mac_address: mac).last

    # version is not always present
    # undefined method `split' for nil:NilClass
    identifier = data['version'].split('-').first

    parsed_ts = Time.parse(data['timestamp'])
    ts = parsed_ts.to_i * 1000

    _data = []
    sql_data = {"" => parsed_ts}

    # puts data.to_json

    data.select{ |k,v| keys.include?(k.to_s) }.each do |sensor, value|
      metric = sensor

      value = method(sensor).call( (Float(value) rescue value), device.kit_version)

      # puts "\t#{metric} #{ts} #{value} device=#{device.id} identifier=#{identifier}"

      metric_id = device.find_sensor_id_by_key(metric)
      component = device.components.detect{|c|c["sensor_id"] == metric_id} #find_component_by_sensor_id(metric_id)
      sql_data["#{metric_id}_raw"] = value
      sql_data[metric_id] = component.calibrated_value(value)

      _data.push({
        name: metric,
        timestamp: ts,
        value: value,
        tags: {
          device: device.id,
          identifier: identifier
        }
      })
    end

    Kairos.http_post_to("/datapoints", _data)

    if parsed_ts > (device.last_recorded_at || Time.at(0))
      Device.where(id: device.id).update_all(last_recorded_at: parsed_ts, data: sql_data) # update without touching updated_at
      LegacyDevice.find(device.id).update_column(:last_insert_datetime, Time.now.utc)
    end

  end

end
