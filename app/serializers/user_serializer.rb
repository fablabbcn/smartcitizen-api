class UserSerializer < ActiveModel::Serializer
  attributes :username, :device_ids, :created_at, :updated_at
end
