class UserSerializer < ActiveModel::Serializer
  attributes :username, :name

  has_many :devices
end
