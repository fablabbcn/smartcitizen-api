class User < ActiveRecord::Base

  include PgSearch
  multisearchable :against => [:username, :city, :country_name]

  extend FriendlyId
  friendly_id :username

  has_secure_password validations: false

  validates :password, presence: { on: :create }, length: { minimum: 5, allow_blank: true }
  validates :username, :email, presence: true
  validates :username, uniqueness: true, if: :username?
  validates :username, length: { in: 3..30 }, allow_nil: true
  validate :check_for_banned_username
  validates :email, format: { with: /@/ }, uniqueness: true, if: :email?
  validates :url, format: URI::regexp(%w(http https)), allow_nil: true, allow_blank: true, on: :create

  has_many :devices, foreign_key: 'owner_id', after_add: :update_cached_device_ids!, after_remove: :update_cached_device_ids!
  has_many :sensors, through: :devices
  has_many :api_tokens, foreign_key: 'owner_id'
  has_many :uploads

  before_create :generate_legacy_api_key

  def to_s
    username
  end

  def access_token
    Doorkeeper::AccessToken.find_or_initialize_by(application_id: 4, resource_owner_id: id)
  end

  def avatar
    avatar_url || "https://smartcitizen.s3.amazonaws.com/avatars/default.svg"
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

  def country
    ISO3166::Country[country_code] if country_code
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
    ENV['redis'] ? UserMailer.delay.password_reset(id) : UserMailer.password_reset(id).deliver_now
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

  def self.check_bad_avatar_urls
    User.where.not(avatar_url: nil).each do |user|
      unless `curl -I #{user.avatar_url} 2>/dev/null | head -n 1`.split(' ')[1] == "200"
        puts [user.id, user.avatar_url].join(' - ')
      end
    end
  end

private

  def generate_legacy_api_key
    generate_token(:legacy_api_key, Digest::SHA1.hexdigest(SecureRandom.uuid) )
  end

  def generate_token(column, token=SecureRandom.urlsafe_base64)
    begin
      self[column] = token
    end while User.exists?(column => self[column])
  end

  def check_for_banned_username
    if username.present? and (Smartcitizen::Application.config.banned_words & username.split.map(&:downcase).map(&:strip)).any?
      errors.add(:username, "is reserved")
    end
  end

end
