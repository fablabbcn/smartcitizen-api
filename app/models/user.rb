class User < ActiveRecord::Base

  include PgSearch
  multisearchable :against => [:first_name, :last_name, :username, :city]

  extend FriendlyId
  friendly_id :username

  has_secure_password validations: false
  validates :password, presence: { on: :create }, length: { minimum: 5, allow_blank: true }

  validates :username, :email, presence: true
  validates :username, uniqueness: true, if: :username?
  validates :email, format: { with: /@/ }, uniqueness: true, if: :email?

  validates :username, length: { in: 3..30 }, allow_nil: true

  validates :url, :avatar, format: URI::regexp(%w(http https)), allow_nil: true, allow_blank: true

  has_many :devices, foreign_key: 'owner_id'
  has_many :sensors, through: :devices
  has_many :api_tokens, foreign_key: 'owner_id'

  before_create :generate_legacy_api_key

  def access_token
    Doorkeeper::AccessToken.find_or_initialize_by(
          application_id: 4, resource_owner_id: id)
  end

  def access_token!
    access_token.expires_in = 2.days.from_now
    access_token.save
    access_token
  end

  def joined_at
    created_at
  end

  def api_token
    api_tokens.last
  end

  def country_name
    country ? country.to_s : nil
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

  def role
    role_mask < 5 ? 'citizen' : 'admin'
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

  def is_admin?
    role == 'admin'
  end

  def country
    Country[country_code] if country_code
  end

  def location
    {
      city: city,
      country: country.try(:name),
      country_code: country_code
    }
  end

private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def generate_legacy_api_key
    begin
      self.legacy_api_key = Digest::SHA1.hexdigest(SecureRandom.uuid)
    end while User.exists?(legacy_api_key: self.legacy_api_key)
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
