class UserSerializer < ActiveModel::Serializer
  attributes :username, :device_ids, :city, :country_code, :joined_at#, :updated_at
end
