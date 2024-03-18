class OrphanDevice < ActiveRecord::Base
  attr_readonly :onboarding_session, :device_token

  validates_uniqueness_of :device_token
  validates_uniqueness_of :onboarding_session

  validates_presence_of :device_token, allow_nil: false
  validates_presence_of :onboarding_session, allow_nil: false

  validates :exposure, inclusion: { in: %w(indoor outdoor) }, allow_nil: true

  after_initialize :generate_onbarding_session

  def device_attributes
    {
      name: name,
      description: description,
      user_tags: user_tags,
      exposure: exposure,
      latitude: latitude,
      longitude: longitude,
      device_token: device_token
    }
  end

  def generate_token!
    self.device_token = SecureRandom.alphanumeric(6).downcase
  end

  private

  def generate_onbarding_session
    self.onboarding_session = SecureRandom.uuid if new_record?
  end
end
