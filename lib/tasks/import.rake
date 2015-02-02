require 'csv'

namespace :import do

# id
# user_id
# macadress
# kit_version
# firm_version
# title
# description
# location
# city
# country
# exposure
# position
# elevation
# geo_lat
# geo_long
# wifi_ssid
# wifi_pwd
# created
# modified
# last_insert_datetime
# ro_co
# ro_no2
# smart_cal
# debug_push
# enclosure_type
  desc "Imports devices.csv"
  task :devices => :environment do
    Device.destroy_all
    me = User.find_by!(username: 'john')

    CSV.foreach( Rails.root.join("csv/devices.csv").to_s, headers: true, quote_char: "`") do |line|
      if line['macadress'] =~ /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/
        device = Device.find_or_initialize_by(id: line['id']) do |device|
          device.name = line['title'].try(:chomp)
          device.mac_address = line['macadress'].try(:chomp)
          device.description = line['description'].try(:chomp)
          # if line['geo_lat']
          device.latitude = line['geo_lat']
          device.longitude = line['geo_long']
          # end
          begin
            device.owner = User.find(line['user_id'])
          rescue ActiveRecord::RecordNotFound
            device.owner = me
          end
        end

        device.save(validate: false)
      end
    end
  end

# id
# username
# password
# role
# city
# country
# website
# email
# email_verified
# time_zone
# media_id
# created
# modified
# api_key
# app
  desc "Imports users.csv"
  task :users => :environment do
    CSV.foreach( Rails.root.join("csv/users.csv").to_s, headers: true, quote_char: "`") do |line|
      user = User.find_or_initialize_by(id: line['id']) do |user|
        user.username = line['username'].try(:chomp)
        user.email = line['email'].try(:chomp).try(:downcase)
        user.old_password = line['password']
      end
      user.save(validate: false)
    end
  end

end


