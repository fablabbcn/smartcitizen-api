class OrphanDevice < ActiveRecord::Base
  validates_uniqueness_of :device_token
  validates_uniqueness_of :onboarding_session

  validate :device_token_persistance, on: :update
  validates :exposure, inclusion: { in: %w(indoor outdoor) }, allow_nil: true

  after_create :generate_device_token

  TOKEN_ATTEMPTS = 10

  def device_attributes
    {
      name: name,
      description: description,
      kit_id: kit_id,
      user_tags: user_tags,
      exposure: exposure,
      latitude: latitude,
      longitude: longitude
    }
  end

  private

  def generate_device_token
    update(device_token: SecureRandom.hex(3), onboarding_session: SecureRandom.uuid)
  rescue ActiveRecord::RecordNotUnique => e
    @attempts = @attempts.to_i + 1
    retry if TOKEN_ATTEMPTS > @attempts
    raise e, 'Unique device_token assignment failed'
  end

  def device_token_persistance
    return if device_token_was.nil? || !device_token_changed?
    errors.add(:device_token,'cannot be changed')
  end

  def device_token_changed?
    device_token_was != device_token
  end
end
