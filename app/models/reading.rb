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

  after_create :calibrate

  validates_presence_of :device_id, :recorded_at, :raw_data
  validates :recorded_at, date: { after: Proc.new { 1.year.ago }, before: Proc.new { 1.day.from_now } }

  before_create { self.recorded_month = recorded_month }

  def recorded_month
    recorded_at.strftime("%Y%m")
  end

  def device
    Device.find(device_id)
  end

  def create_from_json mac_address, recorded_at, o
    @device = Device.find_by!(mac_address: mac_address)
    self.device_id = @device.id
    self.recorded_at = o.recorded_at
    self.recorded_month = recorded_at.month
    self.raw_data = o
    save!
  end

private

  def calibrate
    return if data.present?
    # if raw_data.smart_cal == 1 && h.hardware_version >= 11 && h.firmware_version >= 85 && h.firmware_param =~ /[AB]/
    #   self.data = SCK11.new( raw_data ).to_h
    # elsif h.hardware_version >= 10 && h.firmware_version >= 85 && h.firmware_param =~ /[AB]/
    #   self.data = SCK1.new( raw_data ).to_h
    # end
    h = SCK1.new( raw_data ).to_h
    self.data = h
    save!
    device.update_attribute(:latest_data, h)
  end

end
