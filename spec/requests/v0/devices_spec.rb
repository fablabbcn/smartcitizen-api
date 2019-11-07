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
      json = api_get 'devices'
      expect(response.status).to eq(200)
      expect(json.length).to eq(2)
      # expect(json[0]['name']).to eq(first.name)
      # expect(json[1]['name']).to eq(second.name)
      expect(json[0].keys).to eq(%w(id uuid name description state
        hardware_info system_tags user_tags is_private notify_low_battery notify_stopped_publishing last_reading_at added_at updated_at mac_address owner data kit))
    end

    describe "when not logged in" do
      it 'does not show private devices' do
        device = create(:device, owner: user, is_private: false)
        device1 = create(:device, owner: user, is_private: true)
        device2 = create(:device, owner: user, is_private: true)
        expect(Device.count).to eq(3)

        j = api_get "devices/"
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

        j = api_get "devices/", { access_token: token.token }
        expect(response.status).to eq(200)
        expect(j.count).to eq(2)
        expect(j[0]['id']).to be_in([device1.id, device2.id])
      end
    end

    describe "when logged in as an admin" do
      it 'allows admin to see ALL devices' do
        device1 = create(:device, owner: user, is_private: false)
        device2 = create(:device, owner: user, is_private: true)
        device3 = create(:device, owner: user2, is_private: true)
        expect(Device.count).to eq(3)

        j = api_get "devices/", {access_token: admin_token.token}
        expect(response.status).to eq(200)
        expect(j.count).to eq(3)
        expect(j[0]['id']).to be_in([device1.id, device2.id, device3.id])
      end
    end

    describe "world map" do
      it "returns all devices" do
        first = create(:device, data: { "": Time.now })
        second = create(:device, data: { "": Time.now })
        json = api_get "devices/world_map"
        expect(response.status).to eq(200)
        #expect(json.map{|j| j['id']}).to eq([first, second].map(&:id))
      end

      skip "needs more specs"
    end

    describe "with near" do

      let!(:barcelona) { create(:device) }
      let!(:paris) { create(:device, latitude: 48.8582606, longitude: 2.2923184) }
      let!(:manchester) { create(:device, latitude: 53.4630589, longitude: -2.2935288) }
      let!(:cape_town) { create(:device, latitude: -33.9080317, longitude: 18.4154827) }

      let!(:london_coordinates) { "51.5286416,-0.1015987" }

      it "returns devices order with default distance" do
        json = api_get "devices?near=#{london_coordinates}"

        # puts Geocoder::Calculations.distance_between( london_coordinates.split(','), [barcelona.latitude, barcelona.longitude])
        # puts Geocoder::Calculations.distance_between( london_coordinates.split(','), [paris.latitude, paris.longitude])
        # puts Geocoder::Calculations.distance_between( london_coordinates.split(','), [manchester.latitude, manchester.longitude])

        expect(response.status).to eq(200)
        expect(json.map{|j| j['id']}).to eq([manchester, paris, barcelona].map(&:id))
      end

      it "returns devices order with custom distance" do
        json = api_get "devices?near=#{london_coordinates}&within=1000000"
        expect(response.status).to eq(200)
        expect(json.map{|j| j['id']}).to eq([manchester, paris, barcelona, cape_town].map(&:id))
      end

      it "fails for invalid near" do
        json = api_get "devices?near=13"
        expect(response.status).to eq(400)
      end

    end
  end

  describe "GET /devices/:id" do

    it "returns a device" do
      j = api_get "devices/#{device.id}"
      expect(j['id']).to eq(device.id)
      expect(response.status).to eq(200)
    end

    it "returns 404 if device not found" do
      j = api_get 'devices/100'
      expect(j['id']).to eq('record_not_found')
      expect(response.status).to eq(404)
    end

    it 'does not show a private device' do
      device = create(:device, owner: user, is_private: true)
      j = api_get "devices/#{device.id}"
      expect(j['id']).to eq("forbidden")
      expect(response.status).to eq(403)
    end

    it 'shows a non_private device' do
      device = create(:device, owner: user, is_private: false)
      j = api_get "devices/#{device.id}"
      expect(j['id']).to eq(device.id)
      expect(response.status).to eq(200)
    end


    describe "mac_address" do

      it "filters mac address from guests" do
        j = api_get "devices/#{device.id}"
        expect(j['mac_address']).to eq('[FILTERED]')
      end

      it "filters mac address from users" do
        j = api_get "devices/#{device.id}?access_token=#{token.token}"
        expect(j['mac_address']).to eq('[FILTERED]')
      end

      it "exposes mac address to device owner" do
        device = create(:device, owner: user)
        j = api_get "devices/#{device.id}?access_token=#{token.token}"
        expect(j['mac_address']).to eq(device.mac_address)
      end

      it "exposes mac address to admin" do
        j = api_get "devices/#{device.id}?access_token=#{admin_token.token}"
        expect(j['mac_address']).to eq(device.mac_address)
      end

    end

  end

  describe "PUT /devices/:id" do

    let!(:device) { create :device, owner: user }

    it "cannot update a device is_private attribute" do
      api_put "devices/#{device.id}", { is_private: true, access_token: token.token }
      expect(response.status).to eq(200)
      expect(Device.find(device.id).is_private).to eq(false)
    end

    it "can update a device is_private attribute when user has role" do
      user.update role_mask: 3
      api_put "devices/#{device.id}", { is_private: true, access_token: token.token }
      expect(response.status).to eq(200)
      expect(Device.find(device.id).is_private).to eq(true)
    end

    it "updates a device" do
      api_put "devices/#{device.id}", { name: 'new name', access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not update a device with invalid access_token" do
      api_put "devices/#{device.id}", { name: 'new name', access_token: '123' }
      expect(response.status).to eq(403)
    end

    it "does not update a device with missing access_token" do
      api_put "devices/#{device.id}", { name: 'new name', access_token: nil }
      expect(response.status).to eq(403)
    end

    it "will update a device with empty parameters access_token" do
      api_put "devices/#{device.id}", { name: nil, access_token: token.token }
      expect(response.status).to eq(200)
    end

  end

  describe "POST /devices" do
    it "creates a device" do
      api_post 'devices', {
        access_token: token.token,
        name: 'my device',
        description: 'for checking stuff',
        mac_address: 'BD-B1-DE-13-67-31',
        latitude: 41.3966908,
        longitude: 2.1921909
      }
      expect(response.status).to eq(201)
    end

    it "does not create a device with missing parameters" do
      api_post 'devices', {
        name: nil,
        access_token: token.token
      }
      expect(response.status).to eq(422)
    end

    it "does not create a device with invalid access_token" do
      api_post "devices", { device: { name: 'test' }, access_token: '123' }
      expect(response.status).to eq(401)
    end

    it "does not create a device with missing access_token" do
      api_post "devices", { device: { name: 'test' }, access_token: nil }
      expect(response.status).to eq(401)
    end

    # it "does not create a device with empty parameters access_token" do
    #   api_post "devices", { device: { name: nil }, access_token: token.token }
    #   expect(response.status).to eq(422)
    # end
  end

  describe "DELETE /devices/:id" do

    let!(:device) { create :device, owner: user }

    it "deletes a device" do
      api_delete "devices/#{device.id}", { access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not delete a device with invalid access_token" do
      api_delete "devices/#{device.id}", { access_token: '123' }
      expect(response.status).to eq(403)
    end

    it "does not delete a device with missing access_token" do
      api_delete "devices/#{device.id}"
      expect(response.status).to eq(403)
    end

  end

  describe "states" do

    before(:each) do
      @not_configured = create(:device, mac_address: nil)
      @never_published = create(:device, mac_address: '2a:f3:e6:d9:76:84')
      @has_published = create(:device, mac_address: '2a:f3:e6:d9:76:86', data: {'a': 'b'})
    end

    after(:each) do
      DatabaseCleaner.clean_with(:truncation)
    end

    %w(not_configured never_published has_published).each do |state|
      it "filters by q[state_eq] #{state}" do
        json = api_get "devices?q[state_eq]=#{state}"
        expect(response.status).to eq(200)
        expect(json.map{|j| j['id']}).to eq([ instance_variable_get("@#{state}") ].map(&:id))
      end
    end

  end
end
