# encoding: UTF-8

if Gem::Specification::find_all_by_name('mysql').any?
  require 'parallel'
  require 'active_record'

  class MySQL < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(
      :adapter  => 'mysql',
      :database => ENV['mysql_database'],
      :host     => ENV['mysql_host'],
      :username => ENV['mysql_username'],
      :password => ENV['mysql_password']
    )
  end

  class Feed < MySQL
    def serialize hash
      _data = []
      %w(temp hum co no2 light noise bat panel nets geo_lat geo_long).each do |k|
        if hash[k.to_sym] and self[k]
          _data.push "put d#{device_id} #{timestamp.to_i * 1000} #{self[k]}.0 s=#{hash[k.to_sym]}\n"
        end
      end
      _data
    end
  end

  namespace :getfeeds do
    desc "Imports Feeds"

    task :import => :environment do

      sck1 = {
        noise: 7,
        light: 6,
        panel: 11,
        co: 9,
        bat: 10,
        hum: 5,
        no2: 8,
        nets: 21,
        temp: 4
      }

      sck11 = {
        noise: 7,
        light: 14,
        panel: 18,
        co: 16,
        bat: 17,
        hum: 13,
        no2: 15,
        nets: 21,
        temp: 12
      }

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
              Feed.find(ids).each { |feed| f.puts feed.serialize(hash) }
              last_id = ids.last
              count -= 1
            end
          end
        end
      end


          # Feed.where(device_id: device.id).find_in_batches(batch_size: 1000).with_index do |feeds, batch|
          #   puts "#{device.id}(#{device.kit_version}) - #{batch}"
          #   feeds.each { |feed| f.puts feed.serialize(hash) }
          # end

      # Parallel.each( OldDevice.all.pluck(:id) ) do |id|
      #   device = OldDevice.find(id)
      #   puts device.kit_version
      #   hash = device.kit_version.to_s == '1.1' ? sck11 : sck1

      #   File.open("devices/#{device.id}.txt", 'w') do |f|
      #     Feed.where(device_id: device.id).find_in_batches(batch_size: 1000).with_index do |feeds, batch|
      #       puts "#{device.id}(#{device.kit_version}) - #{batch}"
      #       feeds.each { |feed| f.puts feed.serialize(hash) }
      #     end
      #   end
      # end

    end

  end

end


# ARE SENSORS THE SAME?
# STORING LAT/LNG
