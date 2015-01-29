class KitSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  # has_many :sensors
end
