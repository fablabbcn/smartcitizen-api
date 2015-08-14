class LegacyDevice < MySQL

  self.table_name = 'devices'
  belongs_to :user, class_name: 'LegacyUser'

  KEYS = {
    '10': 'bat',
    '17': 'bat',
    '16': 'co',
    '9': 'co',
    '13': 'hum',
    '5': 'hum',
    '14': 'light',
    '6': 'light',
    '21': 'nets',
    '15': 'no2',
    '8': 'no2',
    '7': 'noise',
    '11': 'panel',
    '18': 'panel',
    '12': 'temp',
    '4': 'temp'
  }

  def as_json
    hash = {}
    cols = %w(id title description location city country exposure elevation title location geo_lat geo_long created last_insert_datetime)
    cols.map{ |c| hash[c] = self[c].to_s }

    if device = Device.find(id) and device.data
      hash['posts'] = {}
      hash['posts']['timestamp'] = device.data[''].to_s.gsub("T", " ").gsub("Z", " UTC")
      device.data.select{|d| Float(d) rescue false }.each do |key,value|
        # Rails.logger.info KEYS
        hash['posts'][KEYS[key.to_sym]] = value.to_s
      end
      hash['posts']['insert_datetime'] = device.last_recorded_at.to_s

    else
      hash['posts'] = false
    end
    # timestamp: "2013-04-24 16:01:56 UTC",
    # temp: 26.4,
    # hum: 36.9,
    # co: 130.45,
    # no2: 4.71,
    # light: 0,
    # noise: 60.01,
    # bat: 65.6,
    # panel: 0,
    # nets: 8,
    # insert_datetime: "2013-04-24 18:02:08 UTC"
    hash
  end

end
