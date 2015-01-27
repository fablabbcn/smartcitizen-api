class DeviceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :latitude, :longitude
  has_one :owner
end
