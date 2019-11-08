require 'rails_helper'

describe V0::SensorsController do

  let(:application) { build :application }
  let(:user) { build :user }
  let(:token) { build :access_token, application: application, resource_owner_id: user.id }

  let(:admin) { create :admin }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }
  let(:sensor1) { build :sensor}

  describe "GET /sensor/<id>" do
    it "returns a sensor" do
      json = api_get "sensors/#{sensor1.id}"
      expect(response.status).to eq(200)
    end
  end

  describe "GET /sensors" do
    it "returns all the sensors" do
      first = create(:sensor, name: 'testing sensor')
      second = create(:sensor)
      j = api_get 'sensors'
      expect(j.length).to eq(2)
      expect(j[0]['name']).to eq('testing sensor')
      expect(response.status).to eq(200)
    end
  end

  describe "POST /sensors" do

    it "creates a sensor" do
      j = api_post 'sensors', {
        name: 'new sensor',
        description: 'blah blah blah',
        unit: 'm',
        access_token: admin_token.token
      }
      expect(j['name']).to eq('new sensor')
      expect(response.status).to eq(201)
    end

    it "does not create a sensor with missing parameters" do
      j = api_post 'sensors', {
        name: 'Missing params',
        access_token: admin_token.token
      }
      expect(j['id']).to eq('unprocessable_entity')
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
