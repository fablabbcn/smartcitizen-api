require_relative "validators/datetime_validator"

class Experiment < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_and_belongs_to_many :devices

  validates_presence_of :name, :owner
  validates_inclusion_of :is_test, in: [true, false]
  validates :starts_at_before_type_cast, datetime: true
  validates :ends_at_before_type_cast, datetime: true
  validate :cannot_add_private_devices_of_other_users
  validate :start_date_is_before_end_date

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "ends_at", "id", "is_test", "name", "owner_id", "starts_at", "status", "updated_at"]
  end

  def active
    active?
  end

  def active?
    (!starts_at || Time.now >= starts_at) && (!ends_at || Time.now <= ends_at)
  end

  def last_reading_at
    devices.map(&:last_reading_at).compact.max
  end

  def user_tags
    devices.flat_map(&:user_tags).compact.uniq
  end

  def all_measurements
    devices.flat_map(&:sensors).filter {|s| !s.is_raw? }.map(&:measurement).uniq
  end

  def components_for_measurement(measurement)
    devices.flat_map(&:components).filter {
      |c| c.measurement == measurement && !c.is_raw?
    }.uniq
  end

  def all_online?
    devices.all? { |d| d.online? }
  end

  def online_device_count
    devices.filter { |d| d.online? }.length
  end

  private

  def cannot_add_private_devices_of_other_users
    private_devices =  devices.select { |device| device.is_private? && device.owner != self.owner }
    if private_devices.any?
      ids = private_devices.map(&:id).join(", ")
      errors.add(:devices, "can't contain private devices owned by other users (ids: #{ids})")
    end
  end

  def start_date_is_before_end_date
    if starts_at && ends_at && ends_at < starts_at
      errors.add(:ends_at, "is before starts_at")
    end
  end
end
