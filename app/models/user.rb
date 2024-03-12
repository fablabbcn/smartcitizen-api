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

  validates :password, presence: { on: :create }, length: { minimum: 5, allow_blank: true }
  validates :username, :email, presence: true
  validates :username, uniqueness: true, if: :username?
  validates :username, length: { in: 3..30 }, allow_nil: true
  validates :email, format: { with: /@/ }, uniqueness: true
  validates :url, format: URI::regexp(%w(http https)), allow_nil: true, allow_blank: true, on: :create

  has_many :devices, foreign_key: 'owner_id', after_add: :update_cached_device_ids!, after_remove: :update_cached_device_ids!
  has_many :sensors, through: :devices
  has_many :uploads, dependent: :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_one_attached :profile_picture

  before_create :generate_legacy_api_key

  def self.ransackable_attributes(auth_object = nil)
    [ "city", "country_code", "id", "username", "uuid", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["devices", "sensors", "uploads"]
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

  def avatar
    avatar_url || "https://smartcitizen.s3.amazonaws.com/avatars/default.svg"
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

  def check_if_users_have_valid_email
    #recently_updated_users = User.where(updated_at: 14.hour.ago...Time.now)
    CheckupUserEmailBlankJob.perform_later()

  end

  def generate_legacy_api_key
    generate_token(:legacy_api_key, Digest::SHA1.hexdigest(SecureRandom.uuid) )
  end

  def generate_token(column, token=SecureRandom.urlsafe_base64)
    begin
      self[column] = token
    end while User.exists?(column => self[column])
  end

end
