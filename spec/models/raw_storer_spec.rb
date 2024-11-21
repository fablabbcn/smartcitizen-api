require "rails_helper"

def to_ts(time)
  time.strftime("%Y-%m-%d %H:%M:%S")
end

RSpec.describe RawStorer, :type => :model do
  before(:each) do
    Sensor.create!(id: 7, name: "POM-3044P-R", description: "test", default_key: "noise", equation: "Mathematician.table_calibration({0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110},x)", reverse_equation: "x")
    Sensor.create!(id: 12, name: "HPP828E031", description: "test", default_key: "temp", equation: "(175.72 / 65536.0 * x) - 53", reverse_equation: "x")
    Sensor.create!(id: 13, name: "HPP828E031", description: "test", default_key: "hum", equation: "(125.0 / 65536.0  * x) + 7", reverse_equation: "x")
    Sensor.create!(id: 14, name: "BH1730FVC", description: "test", default_key: "light", equation: "x", reverse_equation: "x/10.0")
    Sensor.create!(id: 15, name: "MiCS-4514", description: "test", default_key: "no2", equation: "x", reverse_equation: "x/1000.0")
    Sensor.create!(id: 16, name: "MiCS-4514", description: "test", default_key: "co", equation: "x", reverse_equation: "x/1000.0")
    Sensor.create!(id: 17, name: "Battery", description: "test", default_key: "bat", equation: "x", reverse_equation: "x/10.0")
    Sensor.create!(id: 18, name: "Solar Panel", description: "test", default_key: "panel", equation: "x", reverse_equation: "x/1000.0")
    Sensor.create!(id: 21, name: "Microchip RN-131", description: "test", default_key: "nets", equation: "x", reverse_equation: "x")

    Component.create!(id: 12, device: device, sensor: Sensor.find(12))
    Component.create!(id: 13, device: device, sensor: Sensor.find(13))
    Component.create!(id: 14, device: device, sensor: Sensor.find(14))
    Component.create!(id: 15, device: device, sensor: Sensor.find(7))
    Component.create!(id: 16, device: device, sensor: Sensor.find(15))
    Component.create!(id: 17, device: device, sensor: Sensor.find(16))
    Component.create!(id: 18, device: device, sensor: Sensor.find(17))
    Component.create!(id: 19, device: device, sensor: Sensor.find(18))
    Component.create!(id: 21, device: device, sensor: Sensor.find(21))
  end

  subject(:storer) {
    RawStorer.new
  }

  let(:json) {
    { "co": "118439", "bat": "1000", "hum": "21592", "no2": "260941", "nets": "17", "temp": "25768", "light": "509", "noise": "0", "panel": "0", "timestamp": to_ts(1.day.ago) }
  }

  let(:device) { create(:device) }

  # RawStorer.new data, mac, version, ip

  it "will not be created with invalid past timestamp" do
    ts = { timestamp: to_ts(5.years.ago) }
    includes_proxy = double({ where: double({last: device.reload})})
    allow(Device).to receive(:includes).and_return(includes_proxy)
    expect(device).not_to receive(:update_component_timestamps)
    expect(Redis.current).not_to receive(:publish)
    expect {
      storer.store(json.merge(ts), device.mac_address, "1.1-0.9.0-A", "127.0.0.1", true)
    }.to raise_error
  end

  it "updates component last_reading_at" do
    includes_proxy = double({ where: double({last: device.reload})})
    allow(Device).to receive(:includes).and_return(includes_proxy)

    expect(device).to receive(:update_component_timestamps).with(
      Time.parse(json[:timestamp]),
      [16, 17, 13, 15, 21, 12, 14, 7, 18]
    )

    storer.store(json, device.mac_address, "1.1-0.9.0-A", "127.0.0.1", true)
  end

  it "will not be created with invalid future timestamp" do
    ts = { timestamp: to_ts(2.days.from_now) }
    includes_proxy = double({ where: double({last: device.reload})})
    allow(Device).to receive(:includes).and_return(includes_proxy)
    expect(device).not_to receive(:update_component_timestamps)
    expect(Redis.current).not_to receive(:publish)
    storer.store(json.merge(ts), device.mac_address, "1.1-0.9.0-A", "127.0.0.1")
  end

  it "will not be created with invalid data" do
    includes_proxy = double({ where: double({last: device.reload})})
    allow(Device).to receive(:includes).and_return(includes_proxy)
    expect(device).not_to receive(:update_component_timestamps)
    expect(Redis.current).not_to receive(:publish)
    storer.store({}, device.mac_address, "1.1-0.9.0-A", "127.0.0.1")
  end

  it "should return a correct sensor id number" do
    expect(device.reload.find_sensor_id_by_key(:co)).to eq(16)
    expect(device.reload.find_sensor_id_by_key(:bat)).to eq(17)
  end

  it "will be created with valid data" do
    expect(Redis.current).to receive(:publish)
    storer.store(json, device.mac_address, "1.1-0.9.0-A", "127.0.0.1", true)
  end

  context "when the device allows forwarding" do
    it "forwards the message" do
      allow_any_instance_of(Device).to receive(:forward_readings?).and_return(true)
      # TODO assert that the correct arguments are called after refactoring device representations
      expect(MQTTForwardingJob).to receive(:perform_later)
      storer.store(json, device.mac_address, "1.1-0.9.0-A", "127.0.0.1", true)
    end
  end

  context "when the device does not have allow forwarding" do
    it "does not forward the message" do
      allow_any_instance_of(Device).to receive(:forward_readings?).and_return(false)
      expect(MQTTForwardingJob).not_to receive(:perform_later)
      storer.store(json, device.mac_address, "1.1-0.9.0-A", "127.0.0.1", true)
    end
  end
end
