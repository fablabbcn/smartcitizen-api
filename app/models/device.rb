require 'geohash'

class Device < ActiveRecord::Base

  belongs_to :owner
  belongs_to :kit

  belongs_to :owner, class_name: 'User'
  validates_presence_of :owner, :mac_address, :name

  validates :mac_address, uniqueness: true, format: { with: /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/ }, unless: Proc.new { |d| d.mac_address == 'unknown' }

  delegate :username, :to => :owner, :prefix => true
  include PgSearch
  multisearchable :against => [:name, :owner_username, :description, :city]#, associated_against: { owner: { first_name, :username }

  has_many :pg_readings

  # reverse_geocoded_by :latitude, :longitude
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.address = geo.address
      obj.city = geo.city
      obj.postal_code = geo.postal_code
      obj.state = geo.state
      obj.state_code = geo.state_code
      obj.country = geo.country
      obj.country_code = geo.country_code
    end
  end
  # after_validation :reverse_geocode

  # these get overridden the device is a kit
  has_many :components, as: :board
  has_many :sensors, through: :components

  before_save :calculate_geohash

  store_accessor :location,
    :address,
    :city,
    :postal_code,
    :state,
    :state_code,
    :country,
    :country_code

  store_accessor :meta,
    :elevation,
    :exposure,
    :firmware_version,
    :smart_cal,
    :debug_push,
    :enclosure_type

  # # after_initialize :init

  # def init
  #   self.name ||= "My SCK"
  # end

  def to_s
    name
  end

  def added_at
    created_at
  end

  def last_reading_at
    last_recorded_at
  end

  def firmware
    if firmware_version.present?
      "sck:#{firmware_version}"
    end
  end

  def components
    kit ? kit.components : super
  end

  def sensors
    kit ? kit.sensors : super
  end

  # def readings
  #   Reading.where(device_id: id)
  # end

  # def all_readings
  #   months = (created_at.to_date..updated_at.to_date).map{|d| "#{d.year}#{'%02i' % d.month.to_i}" }.uniq
  #   return readings.where(recorded_month: months)#.limit(100)
  # end

  def status
    if last_recorded_at.present?
      last_recorded_at > 10.minutes.ago ? 'online' : 'offline'
    else
      'new'
    end
  end

  # def add_reading options = {}
  #   recorded_at = Time.parse(options[:recorded_at])
  #   Reading.add(id, recorded_at, options[:values])
  #   update_attributes(latest_data: options[:values], last_recorded_at: recorded_at)
  # end

  def formatted_data
    s = {
      recorded_at: updated_at - 1.minute,
      added_at: updated_at - 1.second,
      calibrated_at: updated_at,
      firmware: "[IGNORE]",
      location: {
        ip: nil,
        exposure: exposure,
        elevation: elevation.try(:to_i) ,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        city: city,
        country_code: country_code,
        country: country
      },
      sensors: []
    }

    sensors.each do |sensor|
      sa = sensor.attributes
      sa = sa.merge(
        value: (data ? data["#{sensor.id}"] : nil),
        raw_value: (data ? data["#{sensor.id}_raw"] : nil),
        prev_value: (old_data ? old_data["#{sensor.id}"] : nil),
        prev_raw_value: (old_data ? old_data["#{sensor.id}_raw"] : nil)
      )
      s[:sensors] << sa
    end

    return s
  end

private

  def calculate_geohash
    # include ActiveModel::Dirty
    # if latitude.changed? or longitude.changed?
    if latitude.is_a?(Float) and longitude.is_a?(Float)
      self.geohash = GeoHash.encode(latitude, longitude)
    end
  end

end


# REDIS
# online_kits = [12,13,4,546,45,4564,46,75,68,97] - TTL 15 minutes? // last_recorded_at
# online? - online_kits.include?(id)
# offline? - !online_kits.include?(id)

# exposure - indoor / outdoor
# search by name, city & description
# date range - granulation hour/day/week/month/year/lifetime
# filter by:
#   online
#   offline
#   kit type
#   firmware version
#   ...
