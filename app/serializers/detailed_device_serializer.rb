class DetailedDeviceSerializer < DeviceSerializer

  # def kit
  #   KitSerializer.new(object.kit)
  # end

  attributes :id, :name, :description, :kit_id, :status, :added_at, :last_reading_at, :updated_at, :owner, :latitude, :longitude, :data

  def attributes
    hash = super
    if object.kit
      hash.delete(:kit_id)
      hash.delete(:latitude)
      hash.delete(:longitude)
      hash = hash.merge(kit: KitSerializer.new(object.kit))
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

    s['recorded_at'] = object.updated_at - 1.minute
    s['added_at'] = object.updated_at - 1.second
    s['calibrated_at'] = object.updated_at
    s['firmware'] = "[IGNORE]"
    s['location'] = location
    s['sensors'] = []

    object.sensors.order(:id).select(:id,:name,:description, :unit).each do |sensor|
      sa = sensor.attributes
      sa = sa.merge(
        value: (object.data ? object.data["#{sensor.id}"] : nil),
        raw_value: (object.data ? object.data["#{sensor.id}_raw"] : nil),
        prev_value: (object.old_data ? object.old_data["#{sensor.id}"] : nil),
        prev_raw_value: (object.old_data ? object.old_data["#{sensor.id}_raw"] : nil)
      )
      s['sensors'] << sa
    end

    return s
  end

end
