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

  validates_presence_of :device_id, :recorded_at#, :raw_data
  validates :recorded_at, date: { after: Proc.new { 1.year.ago }, before: Proc.new { 1.day.from_now } }

  before_create :set_recorded_month
  after_create :calibrate

  def device
    Device.find(device_id)
  end

  def self.create_from_api mac, version, o, ip
    @device = Device.select(:id).find_by!(mac_address: mac)
    o = JSON.parse(o)[0]
    Reading.create!({
      device_id: @device.id,
      recorded_at: extract_datetime(o['timestamp']),
      raw_data: o.merge({versions: version, ip: ip})
    })
  end

private

  def set_recorded_month
    self.recorded_month = recorded_at.strftime("%Y%m")
  end

  def calibrate
    Calibrator.new(self) if raw_data.present? and data.blank?
  end

  def extract_datetime
    begin
      Time.parse(o['timestamp'])
    rescue
      Time.at(o['timestamp'])
    end
  end

end
