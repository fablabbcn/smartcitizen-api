require 'rails_helper'

describe V0::SensorsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  let(:admin) { create :admin }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }

  describe "GET /sensor/<id>" do
    it "returns a sensor" do
      sensor = create(:sensor)
      json = api_get "sensors/#{sensor.id}"
      expect(response.status).to eq(200)
      # expect(json.as_json).to eq(SensorSerializer.new(sensor).as_json)
    end
  end

  describe "GET /sensors" do
    it "returns all the sensors" do
      first = create(:sensor)
      second = create(:sensor)
      api_get 'sensors'
      expect(response.status).to eq(200)
    end
  end

  describe "POST /sensors" do

    it "creates a sensor" do
      api_post 'sensors', {
        name: 'new sensor',
        description: 'blah blah blah',
        unit: 'm',
        access_token: admin_token.token
      }
      expect(response.status).to eq(201)
    end

    it "does not create a sensor with missing parameters" do
      api_post 'sensors', {
        name: 'Missing params',
        access_token: admin_token.token
      }
      expect(response.status).to eq(422)
    end

  end

  describe "PUT /sensors/:id" do

    let!(:sensor) { create :sensor }

    it "updates a sensor" do
      api_put "sensors/#{sensor.id}", { name: 'new name', access_token: admin_token.token }
      expect(response.status).to eq(200)
    end

    it "does not update a sensor with invalid access_token" do
      api_put "sensors/#{sensor.id}", { name: 'new name', access_token: '123' }
      expect(response.status).to eq(403)
    end

    it "does not update a sensor with missing access_token" do
      api_put "sensors/#{sensor.id}", { name: 'new name', access_token: nil }
      expect(response.status).to eq(403)
    end

    it "does not update a sensor with empty parameters access_token" do
      api_put "sensors/#{sensor.id}", { name: nil, access_token: admin_token.token }
      expect(response.status).to eq(422)
    end

  end

end
