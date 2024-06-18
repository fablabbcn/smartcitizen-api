require 'rails_helper'

describe V0::ReadingsController do
  let(:user) { build(:user) }
  let(:device) { create(:device, owner: user, components: [component]) }
  let(:measurement) { build(:measurement) }
  let(:sensor) { build(:sensor, measurement: measurement) }
  let(:component) { build(:component, sensor: sensor)  }

  let(:application) { build :application }
  let(:token) { build :access_token, application: application, resource_owner_id: user.id }

  let(:general_user) { build(:user) }
  let(:general_token) { build :access_token, application: application, resource_owner_id: general_user.id }

  describe "GET devices/:id/readings" do

    before do
      allow(Kairos).to receive(:query).and_return({})
    end

    %w(sensor_id rollup).each do |param|
      it "requires #{param}" do
        api_get "devices/#{device.id}/readings"
        expect(response.body).to match(/missing or the value is empty:(.+)#{param}/)
      end
    end

    it "returns readings" do
      b = api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}&rollup=avg"
      expect(response.status).to eq(200)
      # puts b
    end


    it "allows from dates in unix epoch format" do
      api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}&rollup=avg&from=123456"
      expect(response.status).to eq(200)
    end

    it "allows from dates in ISO format" do
      api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}&rollup=avg&from=2020-04-04T00:00:00Z"
      expect(response.status).to eq(200)
    end

    it "rejects from dates in unrecognised format" do
      api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}&rollup=avg&from=2020-15"
      expect(response.status).to eq(400)
      expect(response.body).to match("The from parameter must be an ISO8601 format datetime or an integer number of seconds since the start of the UNIX epoch.")
    end

    it "allows to dates in unix epoch format" do
      api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}&rollup=avg&to=123456"
      expect(response.status).to eq(200)
    end

    it "allows to dates in ISO format" do
      api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}&rollup=avg&to=2020-04-04T00:00:00Z"
      expect(response.status).to eq(200)
    end

    it "rejects to dates in unrecognised format" do
      api_get "devices/#{device.id}/readings?sensor_id=#{device.sensors.first.id}&rollup=avg&to=2020-15"
      expect(response.status).to eq(400)
      expect(response.body).to match("The to parameter must be an ISO8601 format datetime or an integer number of seconds since the start of the UNIX epoch.")
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

  describe "csv_archive" do

    # TODO: missing a valid VCR recording to replay test
    # This test broke after commit
    # https://github.com/fablabbcn/smartcitizen/commit/e58e997538d555fec8ab99d9d7fc59b68cabe3f9
    skip "sends email to authenticated owner of kit", :vcr do
      j = api_get "devices/#{device.id}/readings/csv_archive?access_token=#{token.token}"
      expect(last_email.to).to eq([user.email])
      expect(j['id']).to eq('ok')
      expect(j['message']).to include('added to queue')
      expect(response.status).to eq(200)
    end

    it "doesn't send email to guest" do
      j = api_get "devices/#{device.id}/readings/csv_archive"
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    skip "doesn't send email to user that isn't kit owner" do
      j = api_get "devices/#{device.id}/readings/csv_archive?access_token=#{general_token.token}"
      expect(j['id']).to eq('not_authorized')
      expect(response.status).to eq(403)
    end

    it "is a rate limited request"

    it "always sends email to admin"

  end

  describe "has legacy push support" do

    # `curl –silent -v -X PUT -H 'Host: sc.dev' \
    # -H 'User-Agent: SmartCitizen' \
    # -H 'X-SmartCitizenMacADDR: 00:00:00:00:00:00' \
    # -H 'X-SmartCitizenVersion: 1.1-0.8.5-A' \
    # -H 'X-SmartCitizenData: [{"temp":"29090.6","hum":"6815.74","light":"30000","bat":"786","panel":"0","co":"112500","no2":"200000","noise":"2","nets":"10","timestamp":"2013-10-28 1:34:26"}]' \
    # sc.dev/add >/dev/null 2>/dev/null`

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
