require 'rails_helper'

describe V0::DevicesController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  describe "GET /devices" do
    it "returns all the devices" do
      first = create(:device)
      second = create(:device)
      api_get 'devices'
      expect(response.status).to eq(200)
    end
  end

  describe "GET /devices/:id" do
    it "returns a device" do
      device = create(:device)
      api_get "devices/#{device.id}"
      expect(response.status).to eq(200)
    end

    pending "returns 404 if device not found" do
      api_get 'devices/1'
      expect(response.status).to eq(404)
    end
  end

  describe "PUT /devices/:id" do

    let!(:device) { create :device, owner: user }

    it "updates a device" do
      api_put "devices/#{device.id}", { device: { name: 'new name' }, access_token: token.token }
      expect(response.status).to eq(204)
    end

    it "does not update a device with invalid access_token" do
      api_put "devices/#{device.id}", { device: { name: 'new name' }, access_token: '123' }
      expect(response.status).to eq(401)
    end

    it "does not update a device with missing access_token" do
      api_put "devices/#{device.id}", { device: { name: 'new name' }, access_token: nil }
      expect(response.status).to eq(401)
    end

    it "does not update a device with empty parameters access_token" do
      api_put "devices/#{device.id}", { device: { name: nil }, access_token: token.token }
      expect(response.status).to eq(422)
    end

  end

  describe "POST /devices" do

    it "creates a device" do
      api_post 'devices', {
        access_token: token.token,
        device: {
          name: 'my device',
          description: 'for checking stuff',
          mac_address: 'BD-B1-DE-13-67-31',
          latitude: 34.7890869,
          longitude: 91.2252749
        }
      }
      expect(response.status).to eq(201)
    end

    it "does not create a device with missing parameters" do
      api_post 'devices', {
        access_token: token.token,
        device: {
          first_name: 'Homer'
        }
      }
      expect(response.status).to eq(422)
    end

  end

end
