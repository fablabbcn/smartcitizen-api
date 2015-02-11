class KitSerializer < ActiveModel::Serializer
  attributes :slug, :name, :description, :created_at, :updated_at
end
