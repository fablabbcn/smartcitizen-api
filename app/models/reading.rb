# CREATE TABLE readings (
#   device_id int,
#   recorded_month int,
#   recorded_at timestamp,
#   raw_data map<text, text>,
#   data map<text, text>,
#   PRIMARY KEY ((device_id, recorded_month), recorded_at)
# ) WITH CLUSTERING ORDER BY (recorded_at DESC);

class Reading

  include Cequel::Record
  key :device_id, :int
  key :recorded_month, :int, partition: true
  key :recorded_at, :timestamp, order: :desc, index: true
  map :raw_data, :text, :text
  map :data, :text, :text

  validates_presence_of :device_id, :recorded_at, :raw_data
  validates :recorded_at, date: { after: Proc.new { 1.year.ago }, before: Proc.new { 1.day.from_now } }

  after_create :calibrate

  # Should be getter/setter
  before_create { self.recorded_month = recorded_month }

  def recorded_month
    recorded_at.strftime("%Y%m")
  end

  def device
    Device.find(device_id)
  end

  # REFACTOR
  def self.create_from_api mac, version, o, ip
    @device = Device.select(:id).find_by!(mac_address: mac)

    datetime = begin
      Time.parse(o['timestamp'])
    rescue
      Time.at(o['timestamp'])
    end

    Reading.create!({
      device_id: @device.id,
      recorded_at: datetime,
      raw_data: o.merge({versions: version, ip: ip})
    })
  end

private

  # REFACTOR ALL OF THIS NASTY MESS!

  def calibrate # I should be run asynchronously, i.e. added to a job queue
    return if data.present?

    # if ( is_numeric( $timestamp ) )
    #   $timestamp="FROM_UNIXTIME($timestamp)";
    # else
    #   $timestamp="'$timestamp'"

    h = OpenStruct.new(self.raw_data)

    return unless h.versions

    split = h.versions.split('-').map{|a| a.gsub('.','') }
    h.firmware_version = split[1].to_i
    h.hardware_version = split[0].to_i
    h.firmware_param = split[2]


    if (h.hardware_version && h.hardware_version >= 11) &&
      (h.firmware_version && h.firmware_version >= 85) &&
      (h.firmware_param && h.firmware_param =~ /[AB]/)
      # (h.smart_cal && h.smart_cal == 1) &&
      Rails.logger.info(">> SCK11")
      _data = SCK11.new( raw_data ).to_h

    elsif (h.hardware_version && h.hardware_version >= 10) &&
      (h.firmware_version && h.firmware_version >= 85) &&
      (h.firmware_param && h.firmware_param =~ /[AB]/)
      Rails.logger.info(">> SCK1")
      _data = SCK1.new( raw_data ).to_h

    else
      # raise Smartcitizen::UnknownDevice.new h.to_s
    end

    if _data
      self.data = _data
      device.update_attribute(:latest_data, h.to_h)

      Rails.logger.info("NEWWWW")
      Rails.logger.info(_data)

    else
      Rails.logger.info(h)
      Rails.logger.info(">> NO MATCH")
    end

  end

end
