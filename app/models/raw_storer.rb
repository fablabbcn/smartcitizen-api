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

  def initialize data, mac, version, ip

    success = true

    begin

      keys = %w(temp bat co hum light nets no2 noise panel)

      mac = mac.downcase.strip
      device = Device.unscoped.includes(:components).where(mac_address: mac).last

      # version is not always present
      # undefined method `split' for nil:NilClass
      identifier = version.split('-').first

      # temporary fix for device 1000008
      if identifier and (identifier == "1.1" or identifier == "1.0") # and !device.kit_id
        device.kit_version = identifier
        device.save validate: false
      end

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
            device_id: device.id,
            identifier: "sck#{identifier}"
          }
        })
      end

      Kairos.http_post_to("/datapoints", _data)

      if parsed_ts > (device.last_recorded_at || Time.at(0))
        device.update_column(:last_recorded_at, parsed_ts)
        device.update_column(:data, sql_data) # update without touching updated_at
        begin
          LegacyDevice.find(device.id).update_column(:last_insert_datetime, Time.now.utc)
        rescue
        end
      end

      $analytics.track("readings:create", device.id)

    rescue Exception => e

      success = false

      BadReading.create({
        data: (data rescue nil),
        remote_ip: (ip rescue nil),
        message: (e rescue nil),
        version: (version rescue nil),
        device_id: ((device.id if device) rescue nil),
        mac_address: (mac rescue nil),
        timestamp: (parsed_ts rescue nil),
        backtrace: (e.backtrace rescue nil)
      })
      # Airbrake.notify(e)

    end

    BackupReading.create(data: data, mac: mac, version: version, ip: ip, stored: success)

    if Rails.env.production? and device
      Pusher.trigger('add', 'success', {
        device_id: device.id,
        success: success
      })
    end

  end

end
