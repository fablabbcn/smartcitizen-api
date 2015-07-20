require 'rails_helper'

describe V0::ReadingsController do

  let(:device) { create(:device) }

  describe "GET devices/:id/k_readings" do
    skip "returns readings" do
      b = api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}"
      expect(response.status).to eq(200)
      puts b
    end
  end

  describe "GET /add" do
    it "returns time" do
      Timecop.freeze(Time.utc(2015,02,01,20,00,05)) do
        get "/add"
        expect(response.body).to eq("UTC:2015,2,1,20,00,05#")
      end
    end
  end

  describe "has legacy push support" do

    `curl –silent -v -X PUT -H 'Host: sc.dev' \
    -H 'User-Agent: SmartCitizen' \
    -H 'X-SmartCitizenMacADDR: 00:00:00:00:00:00' \
    -H 'X-SmartCitizenVersion: 1.1-0.8.5-A' \
    -H 'X-SmartCitizenData: [{"temp":"29090.6","hum":"6815.74","light":"30000","bat":"786","panel":"0","co":"112500","no2":"200000","noise":"2","nets":"10","timestamp":"2013-10-28 1:34:26"}]' \
    sc.dev/add >/dev/null 2>/dev/null`

    # reading = Reading.first
    # expect(reading.temp).to eq(29090.6)
    # expect(reading.hum).to eq(6815.74)
    # expect(reading.light).to eq(30000)
    # expect(reading.bat).to eq(786)
    # expect(reading.panel).to eq(0)
    # expect(reading.co).to eq(112500)
    # expect(reading.no2).to eq(200000)
    # expect(reading.noise).to eq(2)
    # expect(reading.nets).to eq(10)
    # expect(reading.recorded_at).to eq('2013-10-28 1:34:26')
  end

end
