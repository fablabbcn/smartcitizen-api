class User < ActiveRecord::Base

  has_secure_password
  validates_presence_of :first_name, :last_name, :email, :username
  validates_uniqueness_of :email, :username

  has_many :devices, foreign_key: 'owner_id'

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
