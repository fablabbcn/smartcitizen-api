class SensorSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :unit

  def has_parent
    object.ancestry.present?
  end

  # def tags
  #   if object.id == 1
  #     ['no2', 'gas']
  #   else
  #     ['power']
  #   end
  # end

end
