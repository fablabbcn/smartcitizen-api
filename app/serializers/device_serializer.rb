class DeviceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :latitude, :longitude, :owner
end
