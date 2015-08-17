class LegacyDevice < MySQL

  self.table_name = 'devices'
  belongs_to :user, class_name: 'LegacyUser'

  attr_accessor :posts

  # should be moved to sck class
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
        hash['posts'][KEYS[key.to_sym]] = value
      end
      hash['posts']['insert_datetime'] = device.last_recorded_at.to_s
    else
      hash['posts'] = false
    end

    hash
  end

end
