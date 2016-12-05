require 'rails_helper'

def kairos_query(key)
  {metrics:[{tags:{device_id:[device.id]},name: key}], cache_time: 0, start_absolute: 1262304000000}
end

describe DeviceArchive do
  before(:all) do
    create(:measurement, id: 1, name: 'temp')
    create(:measurement, id: 2, name: 'light')
    create(:kit, id: 3, name: 'SCK', description: "Board", slug: 'sck', sensor_map: '{"temp": 12, "light": 14}')
    create(:sensor, id:12, name:'HPP828E031', description: 'test', measurement_id: 1)
    create(:sensor, id:14, name:'BH1730FVC', description: 'test', measurement_id: 2)
    create(:component, id: 12, board: Kit.find(3), sensor: Sensor.find(12), equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')
    create(:component, id: 14, board: Kit.find(3), sensor: Sensor.find(14), equation: 'x', reverse_equation: 'x/10.0')
  end

  let(:device) { create(:device, kit: Kit.find(3)) }

  let(:csv) {
    "timestamp,temp in KΩ (HPP828E031),light in KΩ (BH1730FVC)\n"\
    "2013-04-03 06:00:00 UTC,-52.997318725585934,1.0\n"\
    "2013-04-19 06:00:00 UTC,-52.997318725585934,1.0"
  }

  let(:http_response) {
    RestClient::Response.new('{"queries":[{"results":[{"values":[[1364968800000,1.0],[1366351200000,1.0]]}]}]}')
  }

  describe "#generate_csv" do
    before do
      allow(Kairos).to receive(:http_post_to).with("/datapoints/query",kairos_query('temp')).and_return(http_response)
      allow(Kairos).to receive(:http_post_to).with("/datapoints/query",kairos_query('light')).and_return(http_response)
    end

    it "correctly generates device archive csv" do
      expect(DeviceArchive.generate_csv(device.id)).to eq(csv)
    end
  end

end
