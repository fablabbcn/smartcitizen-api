class DetailedDeviceSerializer < DeviceSerializer

  # def kit
  #   KitSerializer.new(object.kit)
  # end

  def attributes
    hash = super
    if object.kit
      hash.delete(:kit_id)
      hash = hash.merge(kit: KitSerializer.new(object.kit))
      # hash = hash.remove(:kit_id)
      if Pundit.policy(current_user, object).update?
        hash = hash.merge(mac_address: object.mac_address)
      end
    end
    hash
  end

  def owner
    UserSerializer.new(object.owner)
  end

  def data
    s = {}

    s['recorded_at'] = Time.current.utc
    s['added_at'] = Time.current.utc
    s['calibrated_at'] = Time.current.utc
    s['firmware'] = nil
    s['location'] = location
    s['sensors'] = []

    object.sensors.order(:id).select(:id,:name,:description, :unit).each do |sensor|
      if object.data
        s['sensors'] << sensor.attributes.merge(
          value: object.data["#{sensor.id}"],
          raw_value: object.data["#{sensor.id}_raw"]
        )
      end
    end

    return s
  end

end
