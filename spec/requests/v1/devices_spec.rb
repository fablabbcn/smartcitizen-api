
require 'rails_helper'

describe V0::DevicesController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:device) { create(:device) }
  let(:admin) { create :admin }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }

  describe "GET /devices" do

    it "can be filered"

    it "is paginated"

    it "returns all the devices" do
      first = create(:device)
      second = create(:device)
      json = api_get 'devices', version: 1
      expect(response.status).to eq(200)
      expect(json.length).to eq(2)
      # expect(json[0]['name']).to eq(first.name)
      # expect(json[1]['name']).to eq(second.name)
      expect(json[0].keys).to eq(%w(id uuid name description state system_tags user_tags last_reading_at created_at updated_at notify device_token postprocessing location data_policy hardware owner data experiment_ids))
    end

    describe "when not logged in" do
      it 'does not show private devices' do
        device = create(:device, owner: user, is_private: false)
        device1 = create(:device, owner: user, is_private: true)
        device2 = create(:device, owner: user, is_private: true)
        expect(Device.count).to eq(3)

        j = api_get "devices/", version: 1
        expect(response.status).to eq(200)
        expect(j.count).to eq(1)
        expect(j[0]['id']).to eq(device.id)
      end
    end

    describe "when logged in as a normal user" do
      it 'shows the user his devices, even though they are private' do
        device1 = create(:device, owner: user, is_private: false)
        device2 = create(:device, owner: user, is_private: true)
        device3 = create(:device, owner: user2, is_private: true)
        expect(Device.count).to eq(3)

        j = api_get "devices/", { access_token: token.token }, 1
        expect(response.status).to eq(200)
        expect(j.count).to eq(2)
        expect(j[0]['id']).to be_in([device1.id, device2.id])
      end
    end

    describe "with near" do

      let!(:barcelona) { create(:device) }
      let!(:paris) { create(:device, latitude: 48.8582606, longitude: 2.2923184) }
      let!(:manchester) { create(:device, latitude: 53.4630589, longitude: -2.2935288) }
      let!(:cape_town) { create(:device, latitude: -33.9080317, longitude: 18.4154827) }

      let!(:london_coordinates) { "51.5286416,-0.1015987" }

      it "returns devices order with default distance" do
        json = api_get "devices?near=#{london_coordinates}", version: 1

        # puts Geocoder::Calculations.distance_between( london_coordinates.split(','), [barcelona.latitude, barcelona.longitude])
        # puts Geocoder::Calculations.distance_between( london_coordinates.split(','), [paris.latitude, paris.longitude])
        # puts Geocoder::Calculations.distance_between( london_coordinates.split(','), [manchester.latitude, manchester.longitude])

        expect(response.status).to eq(200)
        expect(json.map{|j| j['id']}).to eq([manchester, paris, barcelona].map(&:id))
      end

      it "returns devices order with custom distance" do
        json = api_get "devices?near=#{london_coordinates}&within=1000000", version: 1
        expect(response.status).to eq(200)
        expect(json.map{|j| j['id']}).to eq([manchester, paris, barcelona, cape_town].map(&:id))
      end

      it "fails for invalid near" do
        json = api_get "devices?near=13", version: 1
        expect(response.status).to eq(400)
      end

      it "allows searching by id" do
        json = api_get "devices?q[id_eq]=1", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by name" do
        json = api_get "devices?q[name_eq]=Name", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by description" do
        json = api_get "devices?q[description_eq]=Desc", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by created_at" do
        json = api_get "devices?q[created_at_lt]=2023-09-26", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by updated_at" do
        json = api_get "devices?q[updated_at_lt]=2023-09-26", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by last_reading_at" do
        json = api_get "devices?q[last_reading_at_lt]=2023-09-26", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by state" do
        json = api_get "devices?q[state_eq]=state", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by geohash" do
        json = api_get "devices?q[geohash_eq]=geohash", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by uuid" do
        json = api_get "devices?q[uuid_eq]=uuid", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by owner id" do
        json = api_get "devices?q[owner_id_eq]=1", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by owner username" do
        json = api_get "devices?q[owner_username_eq]=test", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by tag name" do
        json = api_get "devices?q[tags_name_eq]=test", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by presence of postprocessing" do
        json = api_get "devices?q[postprocessing_id_not_null]=1", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by postprocessing id" do
        json = api_get "devices?q[postprocessing_id_eq]=1", version: 1
        expect(response.status).to eq(200)
      end

      it "allows searching by mac address by admins" do
        json = api_get "devices?q[mac_address_eq]=00:00:00:00:00:00&access_token=#{admin_token.token}", version: 1
        expect(response.status).to eq(200)
      end

      it "does not allow searching by mac address by non-admins" do
        json = api_get "devices?q[mac_address_eq]=00:00:00:00:00:00", version: 1
        expect(response.status).to eq(400)
        expect(json["status"]).to eq(400)
      end

      it "does not allow searching on disallowed parameters" do
        json = api_get "devices?q[disallowed_eq]=1", version: 1
        expect(response.status).to eq(400)
        expect(json["status"]).to eq(400)
      end
    end
  end

  describe "GET /devices/:id" do

    it "returns a device" do
      j = api_get "devices/#{device.id}", version: 1
      expect(j['id']).to eq(device.id)
      expect(response.status).to eq(200)
    end

    it "returns 404 if device not found" do
      j = api_get 'devices/100', version: 1
      expect(j['id']).to eq('record_not_found')
      expect(response.status).to eq(404)
    end

    it 'does not show a private device' do
      device = create(:device, owner: user, is_private: true)
      j = api_get "devices/#{device.id}", version: 1
      expect(j['id']).to eq("forbidden")
      expect(response.status).to eq(403)
    end

    it 'shows a non_private device' do
      device = create(:device, owner: user, is_private: false)
      j = api_get "devices/#{device.id}", version: 1
      expect(j['id']).to eq(device.id)
      expect(response.status).to eq(200)
    end
  end

  describe "states" do

    before(:each) do
      @not_configured = create(:device, mac_address: nil)
      @never_published = create(:device, mac_address: '2a:f3:e6:d9:76:84')
      @has_published = create(:device, mac_address: '2a:f3:e6:d9:76:86', data: {'a': 'b'})
    end

    %w(not_configured never_published has_published).each do |state|
      it "filters by q[state_eq] #{state}" do
        json = api_get "devices?q[state_eq]=#{state}", version: 1
        expect(response.status).to eq(200)
        expect(json.map{|j| j['id']}).to eq([ instance_variable_get("@#{state}") ].map(&:id))
      end
    end

  end
end
