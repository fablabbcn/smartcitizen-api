class DeviceSerializer < ActiveModel::Serializer

  attributes :id, :name, :description, :latitude, :longitude, :geohash, :latest_data, :owner
  has_one :kit

  def owner
    object.owner.username
  end

  def cache_key
    time = Time.new
    time-time.sec-time.min%6*60
  end

end
