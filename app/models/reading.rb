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
    @device = Device.select(:id).where(mac_address: mac).last
    o = JSON.parse(o)[0]
    Reading.create!({
      device_id: @device.id,
      recorded_at: extract_datetime(o['timestamp']),
      raw_data: o.merge({versions: version, ip: ip})
    })
  end

  def as_json(options={})
    {
      recorded_month: recorded_month,
      recorded_at: recorded_at,
      raw_data: raw_data,
      data: data
    }
  end

private

  def set_recorded_month
    self.recorded_month = recorded_at.strftime("%Y%m")
  end

  def calibrate
    Calibrator.new(self) if raw_data.present? and data.blank?
  end

  def self.extract_datetime timestamp
    begin
      Time.parse(timestamp)
    rescue
      Time.at(timestamp)
    end
  end

end
