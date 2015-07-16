require 'digest'

class Upload < ActiveRecord::Base
  def key
    [created_at.to_i,original_filename].join('-')
  end
end
