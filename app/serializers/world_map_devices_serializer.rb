class WorldMapDevicesSerializer < ActiveModel::Serializer
  attributes :name, :latitude, :longitude, :state, :exposure

  def state
    rand() > 0.5 ? 'online' : 'offline'
  end

  def exposure
    rand() > 0.5 ? 'indoor' : 'outdoor'
  end

end
