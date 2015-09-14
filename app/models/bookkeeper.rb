class Bookkeeper

  KEYS = %w(bat co hum light nets no2 noise panel temp)

  NOISE1 = {5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
  NOISE11 = {0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110}

  attr_accessor :sensors

  def initialize data
    Rails.logger.info data
    version = data['version'].split('-').first
    device = Device.first.id#select(:id).all.sample#.where(mac_address: data['mac']).last
    timestamp = data['timestamp']
    @sensors = data.select{ |k,v| KEYS.include?(k.to_s) }

    # @sensors.each do |sensor, value|
    #   calibrate(sensor )
    #   # puts "\t#{sensor} #{Time.parse(timestamp).to_i * 1000} #{value} device=#{device}"
    # end

    calibrate('bat', ->x{x/10})
    calibrate('co', ->x{x/1000})
    calibrate('light', ->x{x/10})
    calibrate('nets' )
    calibrate('no2', ->x{x/1000})

    if version == "1.1"
      calibrate('noise', ->x{table_calibration(NOISE11, x)})
      calibrate('hum', ->x{(125.0 / 65536.0  * x) + 7})         # ->x{x/10}
      calibrate('panel')
      calibrate('temp', ->x{(175.72 / 65536.0 * x) - 53})       # ->x{x/10}
    else
      if version == "1.0"
        calibrate('noise', ->x{ table_calibration(NOISE1, x) })
      else # 0.0
        calibrate('noise' )
      end
      # 1.0 or 0.0
      calibrate('hum', ->x{x/10})
      calibrate('panel', ->x{x/1000})
      calibrate('temp', ->x{x/10})
    end

    _data = []
    @sensors.each do |sensor, value|
      ts = Time.parse(timestamp).to_i * 1000
      puts "\t#{sensor} #{ts} #{value} device=#{device}"
      _data.push({
        name: sensor,
        timestamp: ts,
        value: value,
        tags: {device: device.to_s}
      })
    end

    Kairos.http_post_to("/datapoints", _data)

  end

  def calibrate key, b = ->x{x}
    @sensors[key] = b.call @sensors[key].to_f
  end

private

  def table_calibration( arr, raw_value )
    raw_value = raw_value.to_f
    arr = arr.to_a.sort!
    for i in (0..arr.length-1)
      # Rails.logger.info ">>> RAW: #{raw_value}"
      # Rails.logger.info ">>> ARR[i]: #{arr[i]}"
      # Rails.logger.info ">>> ARR[i+1]: #{arr[i+1]}"
      if raw_value >= arr[i][0] && raw_value < arr[i+1][0]
        low, high = [arr[i], arr[i+1]]
        return linear_regression(raw_value,low[1],high[1],arr[i][0],high[0])
      end
    end
  end

  def linear_regression( valueInput, prevValueOutput, nextValueOutput, prevValueRef, nextValueRef )
    slope = ( nextValueOutput.to_f - prevValueOutput.to_f ) / ( nextValueRef.to_f - prevValueRef.to_f )
    result = slope.to_f * ( valueInput.to_f - prevValueRef.to_f ) + prevValueOutput.to_f
    return result
  end

end
