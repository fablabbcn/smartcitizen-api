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
    # return 0.0 if (i == 0)
    # i = i/100.0
    # if v.to_s == "1.1"
    #   return 0.0 if (i < 50)
    #   return 1875.0 if (i >= 110)
    #   db = {0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110}
    # elsif v.to_s == "1.0"
    #   return 0.0 if (i < 45)
    #   return 2650.0 if (i >= 103)
    #   db = {0=>0,5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
    # end
    # return Mathematician.reverse_table_calibration(db, i)
  end

  def panel i, v
    return i/1000.0
  end

  def hum i, v
    # i = i/10.0
    # if v.to_s == "1.1"
    #   i = (i - 7) / (125.0 / 65536.0)
    # end
    return i
  end

  def temp i, v
    # i = i/10.0
    # if v.to_s == "1.1"
    #   i = (i + 53) / (175.72 / 65536.0)
    # end
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

      puts "\t#{metric} #{ts} #{value} device=#{device.id} identifier=#{identifier}"

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
