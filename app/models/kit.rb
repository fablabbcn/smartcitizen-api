class Kit < ActiveRecord::Base

  extend FriendlyId
  friendly_id :slug

  has_many :devices
  has_many :components, as: :board
  has_many :sensors, through: :components
  validates_presence_of :name, :description

end
