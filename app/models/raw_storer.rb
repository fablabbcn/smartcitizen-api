class RawStorer

  KEYS = %w(bat co hum light nets no2 noise panel temp)

  NOISE1 = {5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
  NOISE11 = {0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110}

  attr_accessor :sensors

  def initialize data
    mac = data['mac'].downcase.strip
    device_id = Device.where(mac: mac_address).last.id

    # version is not always present
    # undefined method `split' for nil:NilClass
    identifier = data['version'].split('-').first

    ts = Time.parse(data['timestamp']).to_i * 1000

    _data = []
    data.select{ |k,v| KEYS.include?(k.to_s) }.each do |sensor, value|
      metric = "#{sensor}.raw"
      value = Float(value) rescue value
      puts "\t#{metric} #{ts} #{value} device_id=#{device_id} identifier=#{version}"
      _data.push({
        name: metric,
        timestamp: ts,
        value: value,
        tags: {
          device_id: device,
          identifier: identifier
        }
      })
    end

    Kairos.http_post_to("/datapoints", _data)

  end

end
