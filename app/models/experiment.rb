class Experiment < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_and_belongs_to_many :devices

  validates_presence_of :name, :owner
  validates_inclusion_of :is_test, in: [true, false]

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "ends_at", "id", "is_test", "name", "owner_id", "starts_at", "status", "updated_at"]
  end
end
