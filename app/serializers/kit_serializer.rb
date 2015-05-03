class KitSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :description, :created_at, :updated_at#, :sensors
  has_many :sensors
end
