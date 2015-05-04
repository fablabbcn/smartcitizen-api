class UserSerializer < ActiveModel::Serializer

  attributes :id, :username, :first_name, :last_name, :avatar, :url, :location, :joined_at#, :device_ids

  has_many :devices

  def location
    {
      city: object.city,
      country_code: object.country_code,
      country: object.country_name
    }
  end

  def attributes
    hash = super
    if defined?(current_user) and Pundit.policy(current_user, object).update?
      hash = hash.merge(email: object.email)
      hash = hash.merge(api_key: "da39a3ee5e6b4b0d3255bfef95601890afd80709")
    end
    hash
  end

end
