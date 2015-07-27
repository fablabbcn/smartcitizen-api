require 'digest'

class Upload < ActiveRecord::Base

  belongs_to :user

  def new_filename
    [created_at.to_i.to_s(32), original_filename].join('.')
  end

  def key
    dir = user.uuid[0..3]
    ['avatars', dir, new_filename].join('/')
  end

  def full_path
    "http://images.smartcitizen.me/s100/#{key}"
  end

end
