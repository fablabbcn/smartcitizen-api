class Device < ActiveRecord::Base
  belongs_to :owner

  belongs_to :owner, class_name: 'User'
  validates_presence_of :owner, :mac_address
end
