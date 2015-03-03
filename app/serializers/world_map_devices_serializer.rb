class WorldMapDevicesSerializer < ActiveModel::Serializer

  attributes :name,
    :description, # a description of the kit
    :owner, # john
    :latitude, # 41.000
    :longitude, # 2.000
    :city, # london / manchester
    :country_code, # gb / es / fr
    :kit, # slug
    :state, # new / online / offline
    :exposure, # indoor / outdoor
    :latest_data # { sensor_id: value}

  def owner
    object.owner.username
  end

  def kit
    # object.kit.slug
  end

  def state
    rand() > 0.5 ? 'online' : 'offline'
  end

  def exposure
    rand() > 0.5 ? 'indoor' : 'outdoor'
  end

end
