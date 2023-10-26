class Postprocessing < ApplicationRecord
  belongs_to :device

  def self.ransackable_attributes(auth_object = nil)
    ["blueprint_url", "created_at", "device_id", "forwarding_params", "hardware_url", "id", "latest_postprocessing", "meta", "updated_at"]
  end

  def self_ransackable_associations(auth_object = nil)
    []
  end
end
