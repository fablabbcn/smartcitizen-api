class OrphanDevice < ActiveRecord::Base
  attr_readonly :onboarding_session, :device_token

  validates_uniqueness_of :device_token
  validates_uniqueness_of :onboarding_session

  validate :device_token, presence: true, allow_nil: false
  validates :exposure, inclusion: { in: %w(indoor outdoor) }, allow_nil: true

  before_create :generate_device_token
  after_initialize :generate_onbarding_session

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

  def generate_device_token
    self.device_token = SecureRandom.hex(3)
  end

  private

  def generate_onbarding_session
    self.onboarding_session = SecureRandom.uuid if new_record?
  end
end
