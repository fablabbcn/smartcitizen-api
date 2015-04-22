class DetailedDeviceSerializer < DeviceSerializer

  def kit
    KitSerializer.new(object.kit)
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
