class WorldMapDevicesSerializer < ActiveModel::Serializer

  attributes :id,
    :name,
    :description, # a description of the kit
    :owner, # john
    :latitude, # 41.000
    :longitude, # 2.000
    :city, # london / manchester
    :country_code, # gb / es / fr
    :kit, # slug
    :status, # new / online / offline
    :exposure # indoor / outdoor
    # :data # { sensor_id: value}

  def owner
    object.owner.username
  end

  def kit
    # object.kit.slug
  end

end
