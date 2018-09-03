require 'rails_helper'
require 'fog-aws'

def kairos_query(key)
  {metrics:[{tags:{device_id:[device.id]},name: key}], cache_time: 0, start_absolute: 1262304000000}
end

describe DeviceArchive do
  before(:all) do
    create(:measurement, id: 1, name: 'temp')
    create(:measurement, id: 2, name: 'light')
    create(:measurement, id: 3, name: 'noise')
    create(:measurement, id: 4, name: 'NO2')
    create(:kit, id: 3, name: 'SCK', description: "Board", slug: 'sck', sensor_map: '{"noise": 7, "temp": 12, "light": 14, "no2": 15}')
    create(:sensor, id:12, name:'HPP828E031', description: 'test', measurement_id: 1, unit: 'ºC')
    create(:sensor, id:7, name:'POM-3044P-R', description: 'test', measurement_id: 2, unit: 'dB')
    create(:sensor, id:14, name:'BH1730FVC', description: 'test', measurement_id: 2, unit: 'KΩ')
    create(:sensor, id:15, name:'MiCS-4514', description: 'test', measurement_id: 4, unit: 'kOhm')
    create(:component, id: 12, board: Kit.find(3), sensor: Sensor.find(12), equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')
    create(:component, id: 14, board: Kit.find(3), sensor: Sensor.find(14), equation: 'x', reverse_equation: 'x/10.0')
    create(:component, id: 15, board: Kit.find(3), sensor: Sensor.find(7), equation: 'Mathematician.table_calibration({0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110},x)', reverse_equation: 'x')
    create(:component, id: 16, board: Kit.find(3), sensor: Sensor.find(15), equation: 'x', reverse_equation: 'x/1000.0')
  end

  let(:device) { create(:device, kit: Kit.find(3)) }

  let(:csv) {
    "timestamp,NO2 in kOhm (MiCS-4514),temp in ºC (HPP828E031),light in KΩ (BH1730FVC),light in dB (POM-3044P-R)\n"\
    "2013-04-03 06:00:00 UTC,1.0,-52.997318725585934,1.0,52.5\n"\
    "2013-04-19 06:00:00 UTC,2.0,-52.994637451171876,2.0,55.0\n"\
    "2013-04-23 06:00:00 UTC,3.0,-52.99195617675781,3.0,57.0\n"\
    "2013-04-30 06:00:00 UTC,4.0,-52.98927490234375,4.0,57.333333333333336\n"
  }

  let(:http_response) {
    RestClient::Response.new('{"queries":[{"results":[{"values":[[1364968800000,1.0],'\
      '[1366351200000,2.0],[1366696800000,3.0],[1367301600000,4.0]]}]}]}')
  }

  let(:fake_s3_connection) {
    Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => 'FakeKeyId',
      :aws_secret_access_key    => 'FakeAccessKey',
      :region                   => 'FakeRegion',
    })
  }

  let(:s3_file) { DeviceArchive.create(device.id) }

  let(:s3_file_content) { File.open(s3_file.body, 'r') { |f| f.read } }

  describe "#create_file" do
    before do
      Fog.mock!
      ENV['s3_bucket'] = 'testbuket'
      # create fake bucket
      fake_s3_connection.directories.create(key: 'testbuket')

      allow(DeviceArchive).to receive(:s3_connection).and_return(fake_s3_connection)
      allow(Time).to receive(:now).and_return(Time.now)
      allow(Kairos).to receive(:http_post_to).with("/datapoints/query",kairos_query(anything)).and_return(http_response)
    end

    it 'uploads csv device archive to s3' do
      expect(s3_file_content).to eq(csv)
      expect(s3_file.key).to eq("devices/#{device.id}/csv_archive.csv")
      expect(s3_file.content_disposition).to eq("attachment; filename=#{device.id}_#{(Time.now.to_f * 1000).to_i}.csv")
    end
  end

end
