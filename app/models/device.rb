# This is an SCK (referred to as a 'Kit' in the frontend).
# It's called Device and not Kit or SCK because it's expected that the platform
# will support different kinds of hardware in the future (phones, arduino etc).

require 'open-uri'
require 'geohash'

class Device < ActiveRecord::Base

  default_scope { with_active_state }

  include ActiveModel::Dirty
  include Workflow
  include WorkflowActiverecord
  include ArchiveWorkflow
  include PgSearch::Model
  include CountryMethods

  multisearchable :against => [:name, :description, :city, :country_name], if: :active?

  belongs_to :owner, class_name: 'User'

  has_many :devices_tags, dependent: :destroy
  has_many :tags, through: :devices_tags
  has_many :components, dependent: :destroy
  has_many :sensors, through: :components
  has_one :postprocessing, dependent: :destroy

  accepts_nested_attributes_for :postprocessing, update_only: true

  validates_presence_of :name
  validates_presence_of :owner, on: :create
  #validates_uniqueness_of :name, scope: :owner_id, on: :create

  validates_uniqueness_of :device_token, allow_nil: true

  validates_format_of :mac_address,
    with: /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/, allow_nil: true

  before_save :nullify_other_mac_addresses, if: :mac_address
  before_save :truncate_and_fuzz_location!, if: :location_changed?
  before_save :calculate_geohash
  after_validation :do_geocoding

  store_accessor :location,
    :address,
    :city,
    :postal_code,
    :state_name,
    :state_code,
    :country_code

  store_accessor :meta,
    :elevation,
    :exposure,
    :firmware_version,
    :smart_cal,
    :debug_push,
    :enclosure_type

  before_save :set_state

  reverse_geocoded_by :latitude, :longitude do |obj, results|
    # Nominatim has a quota of 1 req / second
    if geo = results.first
      obj.address = geo.address
      obj.city = geo.city
      obj.postal_code = geo.postal_code
      obj.state_name = geo.state
      obj.state_code = geo.state_code
      obj.country_code = geo.country_code
    end
  end

  scope :for_world_map, -> {
    where.not(latitude: nil).where.not(last_reading_at: nil).where(is_test: false).includes(:owner, :tags)
  }

  def self.ransackable_attributes(auth_object = nil)
    if auth_object == :admin
      # admin can ransack on every attribute
      self.authorizable_ransackable_attributes
    else
      ["id", "name", "description", "created_at", "updated_at", "last_reading_at", "state","geohash", "uuid", "kit_id"]
    end
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "components", "devices_tags", "owner",
      "pg_search_document" , "postprocessing", "sensors",
       "tags"
    ]
  end

  def sensor_keys
    sensor_map.keys
  end

  def sensor_map
    components.map { |c| [c.key, c.sensor.id]}.to_h
  end

  def find_or_create_component_by_sensor_id(sensor_id)
    return nil if sensor_id.nil? || !Sensor.exists?(id: sensor_id)
    components.find_or_create_by(sensor_id: sensor_id)
  end

  def find_or_create_component_by_sensor_key(sensor_key)
    return nil if sensor_key.nil?
    sensor = Sensor.find_by(default_key: sensor_key)
    return nil if sensor.nil?
    components.find_or_create_by(sensor_id: sensor.id)
  end

  def find_or_create_component_for_sensor_reading(reading)
    key_or_id = reading["id"]
    if key_or_id.is_a?(Integer) || key_or_id =~ /\d+/
      # It's an integer and therefore a sensor id
      find_or_create_component_by_sensor_id(key_or_id)
    else
      find_or_create_component_by_sensor_key(key_or_id)
    end
  end

  def find_component_by_sensor_id sensor_id
    components.where(sensor_id: sensor_id).first
  end

  def find_sensor_id_by_key sensor_key
    sensor_map[sensor_key.to_s] rescue nil
  end

  def find_sensor_key_by_id sensor_id
    sensor_map.invert[sensor_id] rescue nil
  end

  def user_tags
    tags.map(&:name)
  end

  def user_tags=(tag_names)
    self.tags = tag_names.split(",").map do |n|
      Tag.find_by!(name: n.strip)
    end
  end

  def owner_username
    owner.username if owner
  end

  def system_tags
    [
      exposure, # indoor / outdoor
      ('new' if created_at > 1.week.ago), # new
      ('test_device' if is_test?),
      ((last_reading_at.present? and last_reading_at > 60.minutes.ago) ? 'online' : 'offline') # state
    ].reject(&:blank?).sort
  end

  def to_s
    name
  end

  def archive
    update({mac_address: nil, old_mac_address: mac_address, archived_at: Time.now})
  end

  def unarchive
    updates = { archived_at: nil }
    unless Device.unscoped.where(mac_address: old_mac_address).exists?
      updates.merge!({mac_address: old_mac_address, old_mac_address: nil})
    end
    update(updates)
  end

  def firmware
    if firmware_version.present?
      "sck:#{firmware_version}"
    end
  end

  def status
    data.present? ? state : 'new'
  end

  def soft_state
    if data.present?
      'has_published'
    elsif mac_address.present? || device_token.present?
      'never_published'
    else
      'not_configured'
    end
  end

  def formatted_location
    {
      ip: nil,
      exposure: exposure,
      elevation: elevation.try(:to_i) ,
      latitude: latitude,
      longitude: longitude,
      geohash: geohash,
      city: city,
      country_code: country_code,
      country: country_name
    }
  end

  def formatted_data
    s = {
      sensors: []
    }

    components.sort_by {|c| c.sensor.name }.each do |component|
      sensor = component.sensor
      sa = sensor.attributes.except(*%w{key equation reverse_equation measurement_id})
      sa = sa.merge(
        measurement: sensor.measurement&.for_sensor_json,
        value: (data ? data["#{sensor.id}"] : nil),
        prev_value: (old_data ? old_data["#{sensor.id}"] : nil),
        last_reading_at: component.last_reading_at,
        tags: sensor.tags
      )
      s[:sensors] << sa
    end

    return s
  end

  def self.geocode_all_without_location
    Device.where(location: "{}").where.not(latitude: nil).each do |device|
      device.reverse_geocode
      device.save validate: false
      sleep(1)
    end
  end

  def remove_mac_address_for_newly_registered_device!
    update(old_mac_address: mac_address, mac_address: nil)
  end

  def update_component_timestamps(timestamp, sensor_ids)
    components.select {|c| sensor_ids.include?(c.sensor_id) }.each do |component|
      component.update_column(:last_reading_at, timestamp)
    end
  end

  def data_policy(authorized=false)
    {
      is_private: authorized ? is_private : "[FILTERED]",
      enable_forwarding: authorized ? enable_forwarding : "[FILTERED]",
      precise_location: authorized ? precise_location : "[FILTERED]"
    }
  end

  def hardware(authorized=false)
    {
      name: hardware_name,
      type: hardware_type,
      version: hardware_version,
      slug: hardware_slug,
      last_status_message: authorized ? hardware_info : "[FILTERED]",
    }
  end

  def hardware_name
    hardware_name_override || [hardware_version ? "SmartCitizen Kit" : "Unknown", hardware_version].compact.join(" ")
  end

  def hardware_type
    hardware_type_override || (hardware_version ? "SCK" : "Unknown")
  end

  def hardware_version
    hardware_version_override || hardware_info&.fetch('hw_ver', nil)
  end

  def hardware_slug
    hardware_slug_override || [hardware_type.downcase, hardware_version&.gsub(".", ",")].compact.join(":")
  end

  def forward_readings?
    enable_forwarding && owner.forward_device_readings?
  end

  def forwarding_token
    owner.forwarding_token
  end

  def truncate_and_fuzz_location!
    if latitude && longitude
      fuzz_decimal_places = 3
      total_decimal_places = 5
      lat_fuzz = self.precise_location ? 0.0 : (Random.rand * 1/10.0**fuzz_decimal_places)
      long_fuzz = self.precise_location ? 0.0 : (Random.rand * 1/10.0**fuzz_decimal_places)
      self.latitude = (self.latitude + lat_fuzz).truncate(total_decimal_places)
      self.longitude = (self.longitude + long_fuzz).truncate(total_decimal_places)
    end
  end

  private

    def set_state
      self.state = self.soft_state
    end

    def location_changed?
      latitude_changed? || longitude_changed? || precise_location_changed?
    end

    def calculate_geohash
      # include ActiveModel::Dirty
      # if latitude.changed? or longitude.changed?
      if latitude.is_a?(Float) and longitude.is_a?(Float)
        self.geohash = GeoHash.encode(latitude, longitude)
      end
    end

    def do_geocoding
      reverse_geocode if (latitude_changed? or longitude_changed?) or city.blank?
    end

    def nullify_other_mac_addresses
      if mac_address_changed?
        Device.unscoped.where(mac_address: mac_address).map(&:remove_mac_address_for_newly_registered_device!)
      end
    end

end
