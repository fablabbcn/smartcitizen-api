# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uuid        :uuid
#

# Tags can be assigned to multiple Devices. They are currently managed solely by
# admins, this is likely to change.

class Tag < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  # validates_format_of :name, with: /\A[A-Za-z]+\z/
  has_many :devices_tags, dependent: :destroy
  has_many :devices, through: :devices_tags

  extend FriendlyId
  friendly_id :name
end
