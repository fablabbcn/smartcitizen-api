class ForwardingDestination < ActiveRecord::Base
  has_many :devices
  validates_uniqueness_of :name

  def self.ransackable_attributes(_auth_object = nil)
    ["name"]
  end
end
