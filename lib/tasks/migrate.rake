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
          user.old_data = old_user.to_json
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
      count = 0
      OldDevice.all.each do |old_device|
        device = Device.where(id: old_device.id).first_or_initialize.tap do |device|
          device.name = old_device.title
          device.description = old_device.description
          device.mac_address = old_device.macadress
          device.owner_id = old_device.user_id
          device.latitude = old_device.geo_lat
          device.longitude = old_device.geo_long
          device.created_at = old_device.created
          device.updated_at = old_device.modified
        end

        begin
          device.save!
          count+=1
        rescue Exception => e
          puts "#{device.id}>>>>>>> #{e.message} >> #{device.mac_address}"
        rescue ActiveRecord::RecordInvalid => e
          puts "#{device.id}>>>>>>> #{e.message} >> #{device.mac_address}"
          # failure_ids << device.id
        end
        puts count
      end

      # sleep(0.2) # sleep for geocoding rate limits
      # puts "FAILURES"
      # p failure_ids
      # end

    end


    task :bad_devices => :environment do
      # p OldDevice.select(:macadress).group(:macadress).having("count(*) > 1").count
      # failure_ids = []
      # OldDevice.where.not(macadress: ['',nil,'null']).where(id: [12, 31, 48, 56, 58, 63, 64, 66, 67, 72, 79, 91, 93, 99, 100, 101, 102, 103, 104, 105, 109, 112, 125, 127, 128, 133, 140, 151, 160, 175, 178, 181, 182, 183, 192, 193, 195, 197, 200, 203, 214, 215, 233, 234, 242, 243, 244, 251, 252, 253, 256, 258, 262, 265, 268, 272, 273, 276, 284, 286, 287, 298, 300, 305, 306, 307, 312, 313, 315, 318, 320, 326, 334, 338, 340, 344, 353, 355, 359, 366, 369, 386, 387, 388, 400, 401, 408, 409, 410, 414, 420, 421, 423, 429, 430, 438, 439, 441, 442, 444, 445, 468, 469, 470, 471, 472, 473, 474, 475, 484, 486, 487, 489, 491, 493, 494, 497, 505, 506, 509, 527, 530, 533, 535, 545, 546, 547, 548, 566, 579, 585, 602, 605, 614, 617, 622, 624, 630, 648, 649, 650, 651, 653, 654, 655, 656, 662, 663, 665, 666, 671, 676, 681, 682, 683, 684, 687, 707, 712, 713, 722, 726, 728, 730, 747, 767, 768, 777, 795, 799, 802, 804, 817, 818, 821, 823, 848, 854, 855, 860, 865, 867, 870, 871, 884, 892, 900, 903, 916, 917, 945, 969, 971, 972, 981, 982, 983, 986, 990, 1002, 1004, 1006, 1009, 1027, 1029, 1030, 1043, 1044, 1045, 1047, 1048, 1050, 1051, 1054, 1072, 1073, 1077, 1084, 1085, 1090, 1103, 1107, 1119, 1121, 1139, 1147, 1148, 1149, 1154, 1156, 1157, 1158, 1169, 1172, 1177, 1196, 1198, 1200, 1205, 1211, 1213, 1217, 1218, 1221, 1225, 1229, 1232, 1233, 1237, 1238, 1239, 1240, 1242, 1248, 1252, 1253, 1264, 1279, 1280, 1282, 1283, 1289, 1295, 1309, 1313, 1314, 1315, 1316, 1328, 1331, 1336, 1337, 1341, 1351, 1359, 1360, 1363, 1369, 1370, 1371, 1372, 1376, 1381, 1385, 1395, 1396, 1398, 1404, 1410, 1412, 1413, 1414, 1416, 1417, 1418, 1420, 1423, 1424, 1426, 1427, 1428, 1430, 1431, 1432, 1470, 1471, 1472, 1473, 1484, 1490, 1496, 1497, 1501, 1504, 1509, 1567, 1572, 1573, 1580, 1601, 1605, 1610, 1615, 1618, 1620, 1623, 1624, 1625, 1626, 1638, 1646, 1649, 1654, 1655, 1674, 1682, 1689, 1691, 1692, 1695, 1696, 1697, 1700, 1705, 1717, 1721, 1722, 1727, 1728, 1749, 1754, 1755, 1760, 1762, 1765, 1775, 1777, 1779, 1780, 1792, 1796, 1797, 1798, 1800, 1802, 1813, 1815, 1826, 1827, 1830, 1834, 1835, 1842, 1847, 1851, 1852, 1854, 1856, 1858, 1859, 1860, 1861, 1862, 1864, 1866, 1870, 1875, 1876, 1877, 1882, 1897, 1898, 1901, 1908, 1909, 1931, 1941, 1942, 1947, 1956, 1961, 1967, 1968, 1969, 1970, 1972, 1973, 1974, 1985, 1999, 2020, 2032, 2034, 2038, 2042, 2050, 2057, 2058, 2061, 2062, 2064, 2067, 2071, 2073, 2074, 2075, 2076, 2077, 2078, 2079, 2080, 2083, 2084, 2086, 2087, 2088, 2090, 2093, 2094, 2095, 2099, 2103, 2104, 2105, 2106, 2107, 2110, 2111, 2112, 2114, 2117, 2118, 2127, 2129, 2132, 2133, 2134, 2137, 2142, 2144, 2149, 2150, 2153, 2158, 2163, 2165, 2167, 2169, 2170, 2172, 2173, 2175, 2176, 2177, 2179, 2183, 2184, 2185, 2186, 2187, 2189, 2190, 2193, 2195, 2196, 2197, 2200, 2201, 2204, 2205, 2208, 2209, 2210, 2212, 2213, 2214, 2215, 2216, 2217, 2219, 2230, 2240, 2241, 2242, 2243, 2245, 2249, 2250, 2251, 2252, 2253, 2258, 2260, 2270, 2272, 2274, 2275, 2276, 2278, 2281, 2282, 2283, 2286, 2287, 2290, 2291, 2292, 2293, 2295, 2296, 2300, 2301, 2306, 2307, 2308, 2309, 2310, 2311, 2312, 2313, 2314, 2315, 2316, 2325, 2329, 2332, 2337, 2338, 2339, 2341, 2347, 2348, 2349, 2350, 2351, 2353, 2355, 2358, 2359, 2360, 2361, 2365, 2366, 2367, 2368, 2369, 2373, 2374, 2376, 2377, 2378, 2379, 2380, 2381, 2382, 2383, 2384, 2386, 2388]).each do |old_device|
    end

  end

end
