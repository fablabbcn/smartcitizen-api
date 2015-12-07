class Tag < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  # validates_format_of :name, with: /\A[A-Za-z]+\z/
  has_many :devices_tags, dependent: :destroy
  has_many :devices, through: :devices_tags

  extend FriendlyId
  friendly_id :name
end
