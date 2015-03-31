class UserSerializer < ActiveModel::Serializer
  attributes :username, :device_ids, :country_code, :city, :joined_at#, :updated_at
end
