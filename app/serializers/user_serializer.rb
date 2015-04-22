class UserSerializer < ActiveModel::Serializer
  attributes :username, :first_name, :last_name, :avatar, :location, :device_ids, :joined_at#, :updated_at

  def location
    {
      city: object.city,
      country_code: object.country_code
    }
  end

end
