class DeviceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :latitude, :longitude, :geohash, :latest_data, :owner
  has_one :kit
  has_many :sensors

  def owner
    object.owner.username
  end

end
