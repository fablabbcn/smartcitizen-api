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

  class OldDevice < MySQL
    self.table_name = 'devices'
  end

  class Feed < MySQL

    # def serialize hash
    #   _data = []
    #   %w(temp hum co no2 light noise bat panel nets geo_lat geo_long).each do |k|
    #     if hash[k.to_sym] and self[k]
    #       _data.push({
    #         name: "d#{device_id}",
    #         timestamp: timestamp.to_i * 1000,
    #         value: self[k],
    #         tags: {"s": hash[k.to_sym] }
    #       })
    #     end
    #   end
    #   _data
    # end

    def serialize hash
      _data = []
      %w(temp hum co no2 light noise bat panel nets geo_lat geo_long).each do |k|
        if hash[k.to_sym] and self[k]
          _data.push "put d#{device_id} #{timestamp.to_i * 1000} #{self[k]}.0 s=#{hash[k.to_sym]}\n"
          # _data.push({
          #   name: "d#{device_id}",
          #   timestamp: timestamp.to_i * 1000,
          #   value: self[k],
          #   tags: {"s": hash[k.to_sym] }
          # })
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

      Parallel.each( OldDevice.all.pluck(:id) ) do |id|
        device = OldDevice.find(id)

        puts device.kit_version
        hash = device.kit_version.to_s == '1.1' ? sck11 : sck1

        File.open("devices/#{device.id}.txt", 'w') do |f|
          Feed.where(device_id: device.id).find_in_batches(batch_size: 1000).with_index do |feeds, batch|
            puts "#{device.id}(#{device.kit_version}) - #{batch}"
            feeds.each { |feed| f.puts feed.serialize(hash) }
          end
        end
      end

    end

  end

end


# ARE SENSORS THE SAME?
# STORING LAT/LNG
