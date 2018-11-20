require 'rails_helper'

def to_ts(time)
  time.strftime("%Y-%m-%d %H:%M:%S")
end

RSpec.describe RawStorer, :type => :model do

  before(:all) do
    DatabaseCleaner.clean_with(:truncation) # We were getting ActiveRecord::RecordNotUnique:
    # yeah, this will be removed soon..

    Kit.create!(id: 2, name: 'SCK 1.0 - Ambient Board Goteo Board', description: "Goteo Board", slug: 'sck:1,0', sensor_map: {"co": 9, "bat": 10, "hum": 5, "no2": 8, "nets": 21, "temp": 4, "light": 6, "noise": 7, "panel": 11})
    Kit.create!(id: 3, name: 'SCK 1.1 - Ambient Board Kickstarter Board', description: "Kickstarter Board", slug: 'sck:1,1', sensor_map: {"co": 16, "bat": 17, "hum": 13, "no2": 15, "nets": 21, "temp": 12, "light": 14, "noise": 7, "panel": 18})

    Sensor.create!(id:3, name:'DHT22', description: 'test')
    Sensor.create!(id:4, name:'DHT22 - Temperature', description: 'test')
    Sensor.create!(id:5, name:'DHT22 - Humidity', description: 'test')
    Sensor.create!(id:6, name:'PVD-P8001', description: 'test')
    Sensor.create!(id:7, name:'POM-3044P-R', description: 'test')
    Sensor.create!(id:8, name:'MICS-2710', description: 'test')
    Sensor.create!(id:9, name:'MICS-5525', description: 'test')
    Sensor.create!(id:10, name:'Battery', description: 'test')
    Sensor.create!(id:11, name:'Solar Panel', description: 'test')
    Sensor.create!(id:12, name:'HPP828E031', description: 'test')
    Sensor.create!(id:13, name:'HPP828E031', description: 'test')
    Sensor.create!(id:14, name:'BH1730FVC', description: 'test')
    Sensor.create!(id:15, name:'MiCS-4514', description: 'test')
    Sensor.create!(id:16, name:'MiCS-4514', description: 'test')
    Sensor.create!(id:17, name:'Battery', description: 'test')
    Sensor.create!(id:18, name:'Solar Panel', description: 'test')
    Sensor.create!(id:19, name:'HPP828E031 (SHT21)', description: 'test')
    Sensor.create!(id:20, name:'MiCS4514', description: 'test')
    Sensor.create!(id:21, name:'Microchip RN-131', description: 'test')

    Component.create!(id: 4, board: Kit.find(2), sensor: Sensor.find(4), equation: 'x', reverse_equation: 'x/10.0')
    Component.create!(id: 5, board: Kit.find(2), sensor: Sensor.find(5), equation: 'x', reverse_equation: 'x/10.0')
    Component.create!(id: 6, board: Kit.find(2), sensor: Sensor.find(6), equation: 'x', reverse_equation: 'x/10.0')
    Component.create!(id: 7, board: Kit.find(2), sensor: Sensor.find(7), equation: 'Mathematician.table_calibration({0=>0,5=>45,10=>55,15=>63,20=>65,30=>67,40=>69,50=>70,60=>71,80=>72,90=>73,100=>74,130=>75,160=>76,190=>77,220=>78,260=>79,300=>80,350=>81,410=>82,450=>83,550=>84,600=>85,650=>86,750=>87,850=>88,950=>89,1100=>90,1250=>91,1375=>92,1500=>93,1650=>94,1800=>95,1900=>96,2000=>97,2125=>98,2250=>99,2300=>100,2400=>101,2525=>102,2650=>103},x)', reverse_equation: 'x')
    Component.create!(id: 8, board: Kit.find(2), sensor: Sensor.find(8), equation: 'x', reverse_equation: 'x/1000.0')
    Component.create!(id: 9, board: Kit.find(2), sensor: Sensor.find(9), equation: 'x', reverse_equation: 'x/1000.0')
    Component.create!(id: 10, board: Kit.find(2), sensor: Sensor.find(10), equation: 'x', reverse_equation: 'x/10.0')
    Component.create!(id: 11, board: Kit.find(2), sensor: Sensor.find(11), equation: 'x', reverse_equation: 'x/1000.0')
    #
    Component.create!(id: 12, board: Kit.find(3), sensor: Sensor.find(12), equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')
    Component.create!(id: 13, board: Kit.find(3), sensor: Sensor.find(13), equation: '(125.0 / 65536.0  * x) + 7', reverse_equation: 'x')
    Component.create!(id: 14, board: Kit.find(3), sensor: Sensor.find(14), equation: 'x', reverse_equation: 'x/10.0')
    Component.create!(id: 15, board: Kit.find(3), sensor: Sensor.find(7), equation: 'Mathematician.table_calibration({0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110},x)', reverse_equation: 'x')
    Component.create!(id: 16, board: Kit.find(3), sensor: Sensor.find(15), equation: 'x', reverse_equation: 'x/1000.0')
    Component.create!(id: 17, board: Kit.find(3), sensor: Sensor.find(16), equation: 'x', reverse_equation: 'x/1000.0')
    Component.create!(id: 18, board: Kit.find(3), sensor: Sensor.find(17), equation: 'x', reverse_equation: 'x/10.0')
    Component.create!(id: 19, board: Kit.find(3), sensor: Sensor.find(18), equation: 'x', reverse_equation: 'x/1000.0')
    Component.create!(id: 20, board: Kit.find(2), sensor: Sensor.find(21), equation: 'x', reverse_equation: 'x')
    Component.create!(id: 21, board: Kit.find(3), sensor: Sensor.find(21), equation: 'x', reverse_equation: 'x')
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  let(:json) {
    {"co": "118439", "bat": "1000", "hum": "21592", "no2": "260941", "nets": "17", "temp": "25768", "light": "509", "noise": "0", "panel": "0", "timestamp": to_ts(1.day.ago) }
  }

  let(:device) { create(:device, kit: Kit.last) }

  # RawStorer.new data, mac, version, ip

  it "will not be created with invalid past timestamp" do
    ts = { timestamp: to_ts(5.years.ago) }
    raw_storer = RawStorer.new( json.merge(ts), device.mac_address, "1.1-0.9.0-A", "127.0.0.1" )
  end

  it "will not be created with invalid future timestamp" do
    ts = { timestamp: to_ts(2.days.from_now) }
    raw_storer = RawStorer.new( json.merge(ts), device.mac_address, "1.1-0.9.0-A", "127.0.0.1" )
  end

  it "will not be created with invalid data" do
    expect(Kairos).to_not receive(:http_post_to)
    raw_storer = RawStorer.new( {}, device.mac_address, "1.1-0.9.0-A", "127.0.0.1" )
  end

  it "should return a correct sensor id number" do
    expect(device.find_sensor_id_by_key(:co)).to eq(16)
    expect(device.find_sensor_id_by_key(:bat)).to eq(17)
  end

  skip "will be created with valid data", :vcr do
    expect(Kairos).to receive(:http_post_to)
    raw_storer = RawStorer.new( json, device.mac_address, "1.1-0.9.0-A", "127.0.0.1" )
  end

end
