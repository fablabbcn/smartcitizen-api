# == Schema Information
#
# Table name: measurements
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  unit        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uuid        :uuid
#

# Measurements are descriptions of what sensors do.
class Measurement < ActiveRecord::Base
  has_many :sensors
  validates_presence_of :name, :description
  validates_uniqueness_of :name
end
