require 'digest'

class Upload < ActiveRecord::Base

  belongs_to :user

  # validates_presence_of :original_filename

  def key
    dir = user.uuid.split('-')[0]
    # Digest::SHA1.hexdigest [dir,original_filename].join('/')
    [dir,original_filename].join('/')
  end

  def full_path
    "http://images.smartcitizen.me/s100/#{key}"
  end

end
