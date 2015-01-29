class DeviceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :latitude, :longitude#, :latest_readings
  has_one :owner


  # def latest_readings
  #   Reading.select(:value).where(device_id: id).first
  # end
end
