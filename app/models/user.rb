class User < ActiveRecord::Base

  include PgSearch
  multisearchable :against => [:username, :city, :country_name]

  extend FriendlyId
  friendly_id :username

  has_secure_password validations: false
  validates :password, presence: { on: :create }, length: { minimum: 5, allow_blank: true }

  validates :username, :email, presence: true
  validates :username, uniqueness: true, if: :username?
  validates :email, format: { with: /@/ }, uniqueness: true, if: :email?

  validates :username, length: { in: 3..30 }, allow_nil: true

  validates :url, format: URI::regexp(%w(http https)), allow_nil: true, allow_blank: true

  has_many :devices, foreign_key: 'owner_id', after_add: :update_cached_device_ids!, after_remove: :update_cached_device_ids!
  has_many :sensors, through: :devices
  has_many :api_tokens, foreign_key: 'owner_id'

  has_many :uploads

  validate :banned_username
  def banned_username
    if username.present? and (Smartcitizen::Application.config.banned_words & username.split.map(&:downcase).map(&:strip)).any?
      errors.add(:username, "is reserved")
    end
  end

  before_create { generate_token(:legacy_api_key, Digest::SHA1.hexdigest(SecureRandom.uuid) ) }


  def to_s
    username
  end

  def access_token
    Doorkeeper::AccessToken.find_or_initialize_by(application_id: 4, resource_owner_id: id)
  end

  def avatar
    avatar_url || "http://smartcitizen.s3.amazonaws.com/avatars/default.svg"
  end

  # def avatar=_avatar
  #   self.avatar_url = "http://images.smartcitizen.me/s100/avatars/#{_avatar}"
  # end

  # def avatar
  #   avatar_url
  # end

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

  def to_email_s
    "#{username} <#{email}>"
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
      if old_data && old_data['password'] == Digest::SHA1.hexdigest([ENV['old_salt'], raw_password].join)
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

  def role
    role_mask < 5 ? 'citizen' : 'admin'
  end

  def country
    ISO3166::Country[country_code] if country_code
  end

  def location
    {
      city: city,
      country: country.try(:name),
      country_code: country_code
    }
  end

  def update_cached_device_ids!(record)
    record.owner.update_all_device_ids! if record.owner
  end

  def update_all_device_ids!
    update_column(:cached_device_ids, device_ids.try(:sort))
  end

private

  def generate_token(column, token=SecureRandom.urlsafe_base64)
    begin
      self[column] = token
    end while User.exists?(column => self[column])
  end

end
