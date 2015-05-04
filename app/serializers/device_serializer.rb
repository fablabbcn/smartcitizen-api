class DeviceSerializer < ActiveModel::Serializer

  # cached
  # delegate :cache_key, to: :object

  # delegate :current_user, :to => :scope
  attributes :id, :name, :description, :kit_id, :status, :added_at, :last_reading_at, :updated_at, :owner, :latitude, :longitude, :data

  def attributes
    hash = super
    # hash = hash.merge(kit: object.kit.slug) if object.kit
    if Pundit.policy(scope, object).update?
      hash = hash.merge(mac_address: object.mac_address)
    end
    hash
  end

  # def kit
  #   object.kit.slug if object.kit
  # end

  # def tags
  #   []
  # end

  def latest_reading
    {
      firmware: object.firmware,
      recorded_at: object.last_recorded_at,
      location: location,
      data: object.latest_data
    }
  end

  def location
    {
      ip: nil,
      exposure: object.exposure,
      elevation: object.elevation,
      latitude: object.latitude,
      longitude: object.longitude,
      geohash: object.geohash,
      city: object.city,
      country_code: object.country_code,
      country: object.country
    }
  end

  def owner
    object.owner.username
  end

end
