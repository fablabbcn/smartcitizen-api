class DetailedDeviceSerializer < ActiveModel::Serializer

  # cached
  # delegate :cache_key, to: :object

  attributes :id, :mac_address, :status, :owner, :name, :description, :tags, :kit, :created_at, :updated_at, :latest_reading
  has_one :kit

  def tags
    []
  end

  def latest_reading
    {
      ip: nil,
      exposure: rand() > 0.5 ? 'indoor' : 'outdoor',
      firmware: 'sck:93',
      recorded_at: object.last_recorded_at,
      location: location,
      sensors: object.sensors.select(:id, :name, :description, :unit)
    }
  end

  def location
    {
      elevation: 1332,
      city: 'Barcelona',
      country: 'Spain',
      country_code: 'ES',
      latitude: object.latitude,
      longitude: object.longitude,
      geohash: object.geohash
    }
  end

  def owner
    object.owner.username
  end

end
