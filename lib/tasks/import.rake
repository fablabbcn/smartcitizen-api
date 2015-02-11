
require 'csv'

namespace :import do

  # id
  # user_id - includes nil
  # macadress - includes nil
  # kit_version - 1 / 1.1
    # firm_version - ["86", nil, "85", "90"]
  # title
  # description
    # location
    # city
    # country
    # exposure - ["outdoor", "indoor", ""]
    # position - "fixed"
    # elevation - [-2...986]
  # geo_lat
  # geo_long
# wifi_ssid - empty
# wifi_pwd - empty
# last_insert_datetime
# ro_co - 75000
# ro_no2 - 10000
# smart_cal - [nil, "1"]
# debug_push - ["1", nil]
# enclosure_type - [nil, "1"]

# created
# modified

# firmware_version
# ['22/23/2005' => '93', '21/23/2005' => '92']



# location
#   city
#   country

# meta
#   elevation
#   exposure
#   firmware_version
#   smart_cal
#   debug_push
#   enclosure_type


  desc "Imports devices.csv"
  task :devices => :environment do
    me = User.find_by!(username: 'john')

    CSV.foreach( Rails.root.join("csv/devices.csv").to_s, headers: true, quote_char: "`") do |line|
      if line['macadress'] =~ /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/
        Device.where(id: line['id']).first_or_initialize.tap do |device|

          # device.elevation = line['elevation'].try(:chomp)
          # device.exposure = line['exposure'].try(:chomp)
          device.firmware_version = line['firm_version'].try(:chomp)
          # device.smart_cal = line['smart_cal'].try(:chomp)
          # device.debug_push = line['debug_push'].try(:chomp)
          # device.enclosure_type = line['enclosure_type'].try(:chomp)

          # device.city = line['city'].try(:chomp)
          # device.country = line['country'].try(:chomp)

          # device.name = line['title'].try(:chomp)
          # device.mac_address = line['macadress'].try(:chomp)
          # device.description = line['description'].try(:chomp)

          # if line['kit_version'] == "1"
          #   device.kit_id = 2
          # elsif line['kit_version'] == "1.1"
          #   device.kit_id = 3
          # end
          # # if line['geo_lat']
          # device.latitude = line['geo_lat']
          # device.longitude = line['geo_long']
          # # end
          # begin
          #   device.owner = User.find(line['user_id'])
          # rescue ActiveRecord::RecordNotFound
          #   device.owner = me
          # end
          device.save(validate: false)
        end
      end
    end
  end

  # id
  # username - there is nil :(
  # password
# role - ["admin", "citizen", "partner", nil]
# city
# country - includes #file_links[C:\\XRdeta...,1,N]
# website
  # email
# email_verified - 0
# time_zone - ["Pacific/Tahiti", "UTC"]
# media_id
# api_key
# app - [nil, "0", "1"]

# created
# modified



# role
# meta
#   city
#   country
#   website
#   media_id
#   api_key
#   app

  desc "Imports users.csv"
  task :users => :environment do
    CSV.foreach( Rails.root.join("csv/users.csv").to_s, headers: true, quote_char: "`") do |line|
      user = User.find_or_initialize_by(id: line['id']) do |user|
        user.username = line['username'].try(:chomp)
        user.email = line['email'].try(:chomp).try(:downcase)
        user.old_password = line['password']

        user.role = line['role'].try(:chomp)
        user.website = line['website'].try(:chomp)
        user.media_id = line['media_id']
        user.api_key = line['api_key']
        user.app = line['app']
        user.city = line['city']
      end
      user.save(validate: false)
    end
  end

end


