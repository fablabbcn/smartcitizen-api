class RawStorer

  KEYS = %w(bat co hum light nets no2 noise panel temp)

  attr_accessor :sensors

  def initialize data

    mac = data['mac'].downcase.strip
    device = Device.where(mac_address: mac).last

    # version is not always present
    # undefined method `split' for nil:NilClass
    identifier = data['version'].split('-').first

    ts = Time.parse(data['timestamp']).to_i * 1000

    _data = []
    data.select{ |k,v| KEYS.include?(k.to_s) }.each do |sensor, value|
      metric = sensor
      value = Float(value) rescue value
      puts "\t#{metric} #{ts} #{value} device_id=#{device.id} identifier=#{identifier}"
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

    device.update_attributes(data: data, last_recorded_at: ts)

  end

end
