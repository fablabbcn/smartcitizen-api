require 'open-uri'
require 'csv'

namespace :airports do

  desc "Import Cities"
  task :import => :environment do
    data = open("https://gist.github.com/johnrees/f9ce46faf790a8dc812e/raw/8e4426925e27e243837e09761a360643913560c5/airports.csv")
    CSV.foreach(data, headers: true).each do |row|
      if (row['type'] == "large_airport" || row['type'] == "medium_airport")
        begin
          Place.create(name: row['municipality'], country_code: row['iso_country'], lat: row['latitude_deg'], lng: row['longitude_deg'], country_name: Country[row['iso_country']].data['names'].first )
        rescue
        end
      end
    end
  end

end