class DetailedUserSerializer < UserSerializer
  has_many :devices

  def attributes
    hash = super
    hash.delete(:device_ids)
    hash
  end
end
