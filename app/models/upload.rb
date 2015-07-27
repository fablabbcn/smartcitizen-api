require 'digest'

class Upload < ActiveRecord::Base

  belongs_to :user

  before_create :generate_key

  def new_filename
    [created_at.to_i.to_s(32), original_filename].join('.')
  end

  def full_path
    "http://images.smartcitizen.me/s100/#{key}"
  end

  def self.uploaded _key
    upload = Upload.find_by(key: _key)
    upload.user.update_attribute(:avatar_url, upload.key)
  end

private

  def generate_key
    self.key = ['avatars', user.uuid[0..2], new_filename].join('/')
  end

end
