require 'securerandom'

class OrphanDevice < ActiveRecord::Base
  validates :device_token, presence: true, allow_nil: false
end
