# encoding: UTF-8

if Gem::Specification::find_all_by_name('mysql').any?

  require 'active_record'

  class String
    def underscore
      self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

    def utf8ize
      self.encode!( 'UTF-8', invalid: :replace, undef: :replace )
      # detection = CharlockHolmes::EncodingDetector.detect(self)
      # puts detection[:encoding]
      # CharlockHolmes::Converter.convert self, detection[:encoding], 'UTF-8'
    end
  end

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

  # class PostgreSQL < ActiveRecord::Base
  #   self.abstract_class = true
  #   establish_connection(
  #     :adapter  => 'postgresql',
  #     :database => 'sc_final',
  #     :host     => 'localhost',
  #     :username => 'john',
  #     :password => nil
  #   )
  # end

  %w(User Device Feed Media).each do |model|
    # class New#{model} < PostgreSQL
    #   self.table_name = '#{model.underscore}s'
    # end
    eval %{
      class Old#{model} < MySQL
        self.table_name = '#{model.underscore}s'
      end
    }
  end

  class Usr < OldUser; end

  class Fd < OldFeed

    def serialize
      _data = []
      %w(temp hum co no2 light noise bat panel nets geo_lat geo_long).each do |k|
        _data.push({
          name: "d#{device_id}",
          timestamp: timestamp.to_i * 1000,
          value: self[k],
          tags: {"s":k}
        })
      end
      _data
    end

    def telnet
      _data = []
      %w(temp hum co no2 light noise bat panel nets).each do |k|
        _data.push "put d#{device_id} #{timestamp.to_i * 1000} #{self[k]} s=#{k}" if self[k]
      end
      _data.join("\n")
    end

  end

  class Dvice < OldDevice
    def ingest
      feeds = Fd.where(device_id: id).order(timestamp: :desc)
      puts "Device: #{id} / Feeds: ##{feeds.count}"
      feeds.find_in_batches(batch_size: 20000).with_index do |batch, i|
        File.open("devices/d#{id}-#{'%02d' % i}.txt", 'w') do |file|
          p [i, feeds.count/20000].join("/")
          batch.each { |f| file.puts f.telnet }
        end
      end
      # `sed -i .bk 's/}\\]\\[{/},{/g' d#{id}.json`
      # `rm d#{id}.json.bk`
      # `gzip d#{id}.json`
    end
  end

  namespace :migrate do
    desc "Imports old data"

    task :feeds => :environment do
      Dvice.order(id: :asc).each do |d|
        d.ingest
        sleep(0.1)
      end
    end

    task :avatars => :environment do
      User.order(id: :asc).each do |user|
        if OldMedia.where(ref: 'User', ref_id: user.id).exists?
          avatar = OldMedia.where(ref: 'User', ref_id: user.id).last
          if avatar.file.present?
            user.update_attribute(:avatar_url, "https://images.smartcitizen.me/s100/avatars/#{avatar.file.split('/').last}" )
          end
        end
      end
    end

    task :users => :environment do
      Usr.order(id: :asc).each do |old_user|
        user = User.where(id: old_user.id).first_or_initialize.tap do |user|
          # user.old_data = old_user.to_json
          user.username = old_user.username.present? ? old_user.username.try(:strip).try(:utf8ize) : nil
          user.city = old_user.city.present? ? old_user.city.try(:strip).try(:utf8ize).try(:titleize) : nil

          if old_user.country.present? && old_user.country.downcase.match(/catalunya|catalonia/)
            user.country_code = 'ES'
          else
            user.country_code = Country.find_country_by_name(old_user.country.try(:strip).try(:utf8ize)).try(:alpha2)
          end

          if old_user.website.try(:strip) =~ URI::DEFAULT_PARSER.regexp[:ABS_URI]
            user.url = old_user.website.try(:strip).try(:utf8ize)
          else
            user.url = nil
          end

          user.email = old_user.email.present? ? old_user.email.try(:strip).try(:utf8ize).try(:downcase) : nil
          user.created_at = old_user.created
          user.updated_at = old_user.modified

          if old_user.api_key && !User.where(legacy_api_key: old_user.api_key).exists?
            user.legacy_api_key = old_user.api_key
          end

        end
        begin
          user.save! validate: false
          p user.id
        rescue ActiveRecord::RecordInvalid => e
          puts [user.id, e.message].join(' >> ')
        rescue Exception => e
          puts e
        end
      end
    end

    task :devices => :environment do
      OldDevice.all.each do |old_device|
        device = Device.where(id: old_device.id).first_or_initialize.tap do |device|
          # device.old_data = old_device.to_json
          device.name = old_device.title.try(:strip).try(:utf8ize)
          device.description = old_device.description.try(:strip).try(:utf8ize)
          device.mac_address = old_device.macadress if (old_device.macadress && old_device.macadress.match(/\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/))
          device.owner_id = old_device.user_id
          device.latitude = old_device.geo_lat
          device.longitude = old_device.geo_long
          device.created_at = old_device.created
          device.updated_at = old_device.modified
        end

        begin
          device.save! validate: false
        rescue Exception => e
          puts "ERROR1 #{device.id}>>>>>>> #{e.message}"
        rescue ActiveRecord::RecordInvalid => e
          puts "ERROR2 #{device.id}>>>>>>> #{e.message}"
          # failure_ids << device.id
        end
      end

      # sleep(0.2) # sleep for geocoding rate limits
      # puts "FAILURES"
      # p failure_ids
      # end

    end
  end

end
