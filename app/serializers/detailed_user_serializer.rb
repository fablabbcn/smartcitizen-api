class DetailedUserSerializer < UserSerializer
  has_many :devices

  def attributes
    hash = super
    hash = hash.merge(updated_at: object.updated_at)
      .except(:device_ids)
    hash
  end
end
