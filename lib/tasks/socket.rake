require 'socket'

def bat i, v
  return i
end

def co i, v
  return i
end

def light i, v
  return i
end

def nets i, v
  return i
end

def no2 i, v
  return i
end

def noise i, v
  if v == "1.1"
    db = {0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110}
  elsif v == "1.0"
    db = {5 => 45,10 => 55,15 => 63,20 => 65,30 => 67,40 => 69,50 => 70,60 => 71,80 => 72,90 => 73,100 => 74,130 => 75,160 => 76,190 => 77,220 => 78,260 => 79,300 => 80,350 => 81,410 => 82,450 => 83,550 => 84,600 => 85,650 => 86,750 => 87,850 => 88,950 => 89,1100 => 90,1250 => 91,1375 => 92,1500 => 93,1650 => 94,1800 => 95,1900 => 96,2000 => 97,2125 => 98,2250 => 99,2300 => 100,2400 => 101,2525 => 102,2650 => 103}
  end
  i = Mathematician.table_calibration( Hash[db.collect{|k,v| [v,k] }], i)
  return i
end

def panel i, v
  return i
end

def hum i, v
  if v.to_s == "1.1"
    i = ((i - 7) / (125.0 / 65536.0) / 10.0)
  end
  return i
end

def temp i, v
  if v.to_s == "1.1"
    i = ((i + 53) / (175.72 / 65536.0) / 10.0)
  end
  return i
end

namespace :socket do

  task :push => :environment do

    sock = TCPSocket.new(ENV['telnet_ip'], ENV['telnet_port'])

    class Feed < MySQL; end

    batch_size = 2000

    # keys = %w(bat co hum light nets no2 noise panel temp)
    keys = %w(hum temp)
    LegacyDevice.where(id: [2082]).order(id: :asc).each do |device|

      kit_version = device.kit_version
      device_id = device.id

      count = Feed.where(device_id: device.id).count
      count = count/batch_size
      count += 1 if count%batch_size > 0
      last_id = 0
      while count > 0
        puts "#{device.id} - #{count} ------------"
        ActiveRecord::Base.logger.silence do
          ids = Feed.where("device_id = ? and id > ?", device.id, last_id).limit(batch_size).ids

          Feed.find(ids).each do |feed|
            timestamp = feed.insert_datetime.to_i
            keys.each do |sensor_key|
              value = method(sensor_key).call( feed[sensor_key], kit_version)
              s = "put #{sensor_key} #{timestamp} #{Float(value) rescue value} device=#{device_id} identifier=#{kit_version}\n"
              sock.write s
            end
          end

          last_id = ids.last
        end
        count -= 1
      end

    end

    sock.close

  end

end
