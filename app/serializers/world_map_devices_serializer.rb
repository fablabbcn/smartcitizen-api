class WorldMapDevicesSerializer < ActiveModel::Serializer

  attributes :id,
    :name,
    :description, # a description of the kit
    :owner_id, # 1
    :owner_username, # john
    :latitude, # 41.000
    :longitude, # 2.000
    :city, # london / manchester
    :country_code, # gb / es / fr
    :kit_id, # slug
    :status, # new / online / offline
    :exposure, # indoor / outdoor
    :data, # { sensor_id: value}
    :added_at

  def status
    if object.data
      object.updated_at > 10.minutes.ago ? 'online' : 'offline'
    else
      'new'
    end
  end

  def owner_username
    object.owner.username
  end

  def data
    if h = object.data
      h['recorded_at'] = object.updated_at
      h['calibrated_at'] = object.updated_at
      h['added_at'] = object.updated_at
      h.delete_if{|k,v| k.empty? }
    else
      h = nil
    end
    return h
  end

  # def kit
  #   object.kit
  # end

end
