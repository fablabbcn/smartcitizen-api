require 'socket'

namespace :socket do

  task :push => :environment do

    sock = TCPSocket.new(ENV['telnet_ip'], ENV['telnet_port'])

    class Feed < MySQL; end

    keys = %w(bat co hum light nets no2 noise panel temp)
    LegacyDevice.all.order(id: :asc).each do |device|
      kit_version = device.kit_version
      Feed.where(device_id: device.id).each do |feed|
        timestamp = feed.insert_datetime.to_i
        keys.each do |sensor_key|
          s = "put #{sensor_key} #{timestamp} #{Float(feed[sensor_key]) rescue feed[sensor_key]} device=#{device_id} identifier=#{kit_version}\n"
          sock.write s
          puts s
        end
      end
    end

    sock.close

  end

end
