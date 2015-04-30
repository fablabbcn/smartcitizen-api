class KitSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :description, :sensors, :created_at, :updated_at#, :sensors
end
