class DeviceSerializer < ActiveModel::Serializer

  # cached
  # delegate :cache_key, to: :object

  attributes :id, :mac_address, :status, :owner, :name, :description, :tags, :created_at, :updated_at, :latest_reading

  def kit
    object.kit.slug if object.kit
  end

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
      data: object.latest_data
    }
  end

  def location
    {
      elevation: 1332,
      address: object.address,
      city: object.city,
      country: object.country,
      country_code: object.country_code,
      latitude: object.latitude,
      longitude: object.longitude,
      geohash: object.geohash
    }
  end

  def owner
    object.owner.username
  end

end
