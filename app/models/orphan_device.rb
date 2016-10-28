class OrphanDevice < ActiveRecord::Base
  validates_uniqueness_of :device_token
  validate :device_token_persistance, on: :update

  after_create :generate_device_token

  TOKEN_ATTEMPTS = 10

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
