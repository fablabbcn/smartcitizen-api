class User < ActiveRecord::Base

  extend FriendlyId
  friendly_id :username

  has_secure_password
  validates_presence_of :email, :username, :first_name, :last_name
  validates_uniqueness_of :email, :username
  validates_length_of :username, in: 3..30, allow_nil: false, allow_blank: false

  has_many :devices, foreign_key: 'owner_id'
  has_many :sensors, through: :devices
  has_many :api_tokens, foreign_key: 'owner_id'

  def joined_at
    created_at
  end

  def api_token
    api_tokens.last
  end

  def name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def to_s
    name
  end

  def to_email_s
    "#{name} <#{email}>"
  end

  def send_password_reset
    generate_token(:password_reset_token)
    save!
    UserMailer.password_reset(self).deliver_now
  end

  def authenticate_with_legacy_support raw_password
    begin
      return authenticate(raw_password)
    rescue BCrypt::Errors::InvalidHash
      if old_password == Digest::SHA1.hexdigest([ENV['old_salt'], raw_password].join)
        self.password = raw_password
        save(validate: false)
        return self
      end
      return false
    end
  end

  def admin?
    false
  end

  def country
    Country[country_code] if country_code
  end

private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  # meta
  #   city
  #   country
  #   website
  #   timezone

  # city
  # country
  # website
  # timezone
  # media_id
  # app

end
