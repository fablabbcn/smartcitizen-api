class KitSerializer < ActiveModel::Serializer
  attributes :slug, :name, :description
  # has_many :sensors
end
