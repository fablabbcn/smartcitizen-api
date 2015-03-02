class DeviceSerializer < ActiveModel::Serializer

  # cached
  # delegate :cache_key, to: :object

  attributes :id, :mac_address, :status, :owner, :name, :description, :created_at, :updated_at, :latest_reading # :tags,

  def kit
    object.kit.slug if object.kit
  end

  def tags
    []
  end

  def latest_reading
    {
      ip: nil,
      exposure: object.exposure,
      firmware: object.firmware,
      recorded_at: object.last_recorded_at,
      location: location,
      data: object.latest_data
    }
  end

  def location
    {
      elevation: object.elevation,
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
