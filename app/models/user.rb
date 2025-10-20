# Note the default_scope.

# Users are considered admin if user.role_mask >= 5. This was done to allow
# other levels such as 3 == moderator etc. rolify might be more suitable if
# a users needs different permissions for different classes or records, but it
# has been left simple for now.

class User < ActiveRecord::Base

  # Users are generally not deleted, they are archived. If you want to query
  # ALL users, remember to use User.unscoped.all, User.unscoped.find(id) etc.
  default_scope { with_active_state }

  include Workflow
  include ArchiveWorkflow
  include WorkflowActiverecord
  include CountryMethods

  include PgSearch::Model
  multisearchable :against => [:username, :city, :country_name], if: :active?

  extend FriendlyId
  friendly_id :username

  has_secure_password validations: false

  validates_acceptance_of :ts_and_cs, on: :create
  validates :password, presence: { on: :create }, length: { minimum: 5 }, confirmation: true, if: :password
  validates :username, format: { with: /\A@?[^@]+\z/ , if: :username }, length: { in: 3..30 }, presence: true, uniqueness: true
  validates :email, format: { with: /@/ }, uniqueness: true, presence: true
  validates :url, format: URI::regexp(%w(http https)), allow_nil: true, allow_blank: true, on: :create

  has_many :devices, foreign_key: 'owner_id', after_add: :update_cached_device_ids!, after_remove: :update_cached_device_ids!
  has_many :sensors, through: :devices
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :experiments, foreign_key: "owner_id"

  has_one_attached :profile_picture

  before_create :generate_legacy_api_key
  before_save :generate_forwarding_tokens


  attr_accessor :ts_and_cs

  def self.forwarding_subscription_authorized?(token, username)
    User.find_by_forwarding_token(token)&.forwarding_username == username
  end

  def self.ransackable_attributes(auth_object = nil)
    ["city", "country_code", "id", "username", "uuid", "created_at", "updated_at", ("role_mask" if auth_object == :admin)].compact
  end

  def self.ransackable_associations(auth_object = nil)
    ["devices", "sensors"]
  end

  def archive
    devices.map{ |d| d.archive! rescue nil }
  end

  def unarchive
    Device.unscoped.where(owner: self).map{ |d| d.unarchive! rescue nil }
  end

  def to_s
    username
  end

  def access_token
    Doorkeeper::AccessToken.find_or_initialize_by(application_id: 4, resource_owner_id: id)
  end

  def access_token!
    access_token.expires_in = 2.days.from_now
    access_token.save
    access_token
  end

  def to_email_s
    "#{username} <#{email}>"
  end

  def send_password_reset
    generate_token(:password_reset_token)
    save!
    if Rails.env.test?
      UserMailer.password_reset(id).deliver_now
    else
      UserMailer.password_reset(id).deliver_later
    end
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

  def is_admin_or_researcher?
    is_admin? || is_researcher?
  end

  def is_researcher?
    role == "researcher"
  end

  def is_admin?
    role == 'admin'
  end

  def role
    case role_mask
    when (2..4) then 'researcher'
    when (5..) then 'admin'
    else 'citizen'
    end
  end

  def location
    {
      city: city,
      country: country_name,
      country_code: country_code
    }
  end

  def update_cached_device_ids!(record)
    record.owner.update_all_device_ids! if record.owner
  end

  def update_all_device_ids!
    update_column(:cached_device_ids, device_ids.try(:sort))
  end

  def forward_device_readings?
    !!forwarding_token
  end

  def regenerate_forwarding_tokens!
    if is_admin_or_researcher?
      self.forwarding_token = SecureRandom.urlsafe_base64(12)
      self.forwarding_username = SecureRandom.urlsafe_base64(12)
    end
  end

  def time_zone
    preferred_time_zone && ActiveSupport::TimeZone[preferred_time_zone] || ActiveSupport::TimeZone["Etc/UTC"]
  end

  def all_devices_online?
    devices.all? { |d| d.online? }
  end

  def all_devices_offline?
    devices.all? { |d| !d.online? }
  end

  def online_device_count
    devices.filter { |d| d.online? }.length
  end
private

  def check_if_users_have_valid_email
    #recently_updated_users = User.where(updated_at: 14.hour.ago...Time.now)
    CheckupUserEmailBlankJob.perform_later()

  end

  def generate_legacy_api_key
    generate_token(:legacy_api_key, Digest::SHA1.hexdigest(SecureRandom.uuid) )
  end

  def generate_forwarding_tokens
    if is_admin_or_researcher? && forwarding_token.blank?
      regenerate_forwarding_tokens!
    end
  end

  def generate_token(column, token=SecureRandom.urlsafe_base64)
    begin
      self[column] = token
    end while User.exists?(column => self[column])
  end

end
