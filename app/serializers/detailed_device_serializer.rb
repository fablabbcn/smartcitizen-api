class DetailedDeviceSerializer < DeviceSerializer

  def kit
    KitSerializer.new(object.kit)
  end

  def owner
    UserSerializer.new(object.owner)
  end

  def latest_reading
    {
      ip: nil,
      exposure: rand() > 0.5 ? 'indoor' : 'outdoor',
      firmware: 'sck:93',
      recorded_at: object.last_recorded_at,
      location: location,
      sensors: object.sensors.select(:id, :name, :description, :unit),
      latest_data: object.latest_data
    }
  end

end
