require 'digest'

class Upload < ActiveRecord::Base

  # validates_presence_of :original_filename

  def key
    dir, split, path = uuid.partition('-')
    [dir,path].join('/')
    # Digest::SHA1.hexdigest [created_at,original_filename].join('-')
  end

end
