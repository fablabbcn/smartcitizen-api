class User < ActiveRecord::Base

  extend FriendlyId
  friendly_id :username

  has_secure_password
  validates_presence_of :first_name, :last_name, :email, :username
  validates_uniqueness_of :email, :username
  validates_length_of :username, in: 3..30, allow_nil: false, allow_blank: false

  has_many :devices, foreign_key: 'owner_id'
  has_many :api_tokens, foreign_key: 'owner_id'

  def api_token
    api_tokens.last
  end

  def name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def to_s
    name
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
