require 'geohash'

class Device < ActiveRecord::Base

  belongs_to :owner
  belongs_to :kit

  belongs_to :owner, class_name: 'User'
  validates_presence_of :owner, :mac_address, :name
  validates_format_of :mac_address, with: /\A([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\z/
  validates_uniqueness_of :mac_address

  reverse_geocoded_by :latitude, :longitude

  # these get overridden the device is a kit
  has_many :components, as: :board
  has_many :sensors, through: :components

  before_save :calculate_geohash

  def components
    kit ? kit.components : super
  end

  def sensors
    kit ? kit.sensors : super
  end

  def readings
    Reading.where(device_id: id)
  end

private

  def calculate_geohash
    # include ActiveModel::Dirty
    # if latitude.changed? or longitude.changed?
    self.geohash = GeoHash.encode(latitude, longitude)
  end

end
