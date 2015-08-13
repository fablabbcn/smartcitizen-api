class LegacyDevice < MySQL

  self.table_name = 'devices'
  belongs_to :user, class_name: 'LegacyUser'

  def self.lightning
    # Device.connection.select_all(select(%w(id title description city country exposure elevation geo_lat)).order(:id).arel, nil, all.bind_values).each do |attrs|
    #   attrs.values.each do |hash|
    #     begin
    #       hash = Oj.load(hash)
    #       d = {}
    #       d['id'] = hash['id'].try(:to_s)
    #       d['title'] = hash['title'].try(:to_s)
    #       # d['username'] = hash['username'].try(:to_s)
    #       d['description'] = hash['description'].to_s#.encode("ISO-8859-1")
    #       d['city'] = hash['city'].try(:to_s)
    #       d['country'] = hash['country'].try(:to_s)
    #       d['exposure'] = hash['exposure'].try(:to_s)
    #       d['elevation'] = hash['elevation'].try(:to_s)
    #       d['geo_lat'] = hash['geo_lat']#.split('.').each_with_index.map{|n,i| n }
    #       d['geo_long'] = hash['geo_long']#.split('.').each_with_index.map{|n,i| n }
    #       d['created'] = hash['created'].gsub('T', ' ').gsub('Z', ' UTC')
    #       d['last_insert_datetime'] = hash['modified'].gsub('T', ' ').gsub('Z', ' UTC')
    #       ds << d
    #     rescue NoMethodError
    #     end
    #   end
    # end
  end

  def self.lightning
    # ds = []
    # Device.connection.select_all(select(%w(migration_data)).order(:id).arel, nil, all.bind_values).each do |attrs|
    #   attrs.values.each do |hash|
    #     begin
    #       hash = Oj.load(hash)
    #       d = {}
    #       d['id'] = hash['id'].try(:to_s)
    #       d['title'] = hash['title'].try(:to_s)
    #       # d['username'] = hash['username'].try(:to_s)
    #       d['description'] = hash['description'].to_s#.encode("ISO-8859-1")
    #       d['city'] = hash['city'].try(:to_s)
    #       d['country'] = hash['country'].try(:to_s)
    #       d['exposure'] = hash['exposure'].try(:to_s)
    #       d['elevation'] = hash['elevation'].try(:to_s)
    #       d['geo_lat'] = hash['geo_lat']#.split('.').each_with_index.map{|n,i| n }
    #       d['geo_long'] = hash['geo_long']#.split('.').each_with_index.map{|n,i| n }
    #       d['created'] = hash['created'].gsub('T', ' ').gsub('Z', ' UTC')
    #       d['last_insert_datetime'] = hash['modified'].gsub('T', ' ').gsub('Z', ' UTC')
    #       ds << d
    #     rescue NoMethodError
    #     end
    #   end
    # end
    # ds
  end

  def serialize
    {
      id: id,
      description: description,
      city: city,
      country: country,
      exposure: exposure,
      elevation: elevation,
      title: title,
      username: user.try(:username),
      location: location,
      geo_lat: geo_lat,
      geo_long: geo_long,
      created: created,
      last_insert_datetime: modified
    }
  end

end
