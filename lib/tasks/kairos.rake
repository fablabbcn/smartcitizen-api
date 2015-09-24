namespace :kairos do

  class Feed < MySQL
    def serialize d_id, d_kv
      _data = []
      %w(temp hum co no2 light noise bat panel nets geo_lat geo_long).each do |k|
        if hash[k.to_sym] and self[k]
          _data.push "put #{k} #{timestamp.to_i * 1000} #{Float(self[k]) rescue self[k]} device_id=#{d_id} identifier=#{d_kv}\n"
        end
      end
      _data
    end
  end

  desc "Imports Feeds"
  task :import => :environment do

    Parallel.each(LegacyDevice.all.pluck(:id)) do |id|
      device = LegacyDevice.find(id)
      hash = device.kit_version.to_s == '1.1' ? sck11 : sck1

      batch_size = 1000

      File.open("devices/#{device.id}.txt", 'w') do |f|
        count = Feed.where(device_id: device.id).count
        count = count/batch_size
        count += 1 if count%batch_size > 0
        last_id = 0
        puts "#{device.id} - #{count} ------------"
        while count > 0
          puts count
          ActiveRecord::Base.logger.silence do
            ids = Feed.where("device_id = ? and id > ?", device.id, last_id).limit(batch_size).ids
            Feed.find(ids).each { |feed| f.puts feed.serialize(device.id, device.kit_version.to_s) }
            last_id = ids.last
            count -= 1
          end
        end
      end
    end

  end

end
