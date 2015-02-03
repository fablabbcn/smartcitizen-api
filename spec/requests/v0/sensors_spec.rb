require 'rails_helper'

describe V0::SensorsController do

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
        unit: 'm'
      }
      expect(response.status).to eq(201)
    end

    it "does not create a sensor with missing parameters" do
      api_post 'sensors', {
        name: 'Missing params'
      }
      expect(response.status).to eq(422)
    end

  end

end
