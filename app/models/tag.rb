class Tag < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  # validates_format_of :name, with: /\A[A-Za-z]+\z/
  has_and_belongs_to_many :devices
end
