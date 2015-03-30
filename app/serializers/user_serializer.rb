class UserSerializer < ActiveModel::Serializer
  attributes :username, :device_ids, :country_code, :joined_at#, :updated_at :city
end
