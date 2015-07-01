require 'rails_helper'

describe V0::MeasurementsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  describe "GET /measurement/<id>" do
    it "returns a measurement" do
      measurement = create(:measurement)
      json = api_get "measurements/#{measurement.id}"
      expect(response.status).to eq(200)
      # expect(json.as_json).to eq(MeasurementSerializer.new(measurement).as_json)
    end
  end

  describe "GET /measurements" do
    it "returns all the measurements" do
      first = create(:measurement)
      second = create(:measurement)
      api_get 'measurements'
      expect(response.status).to eq(200)
    end
  end

  describe "POST /measurements" do

    it "creates a measurement" do
      api_post 'measurements', {
        name: 'new measurement',
        description: 'blah blah blah',
        unit: 'm',
        access_token: token.token
      }
      expect(response.status).to eq(201)
    end

    it "does not create a measurement with missing parameters" do
      api_post 'measurements', {
        name: 'Missing params',
        access_token: token.token
      }
      expect(response.status).to eq(422)
    end

  end

  describe "PUT /measurements/:id" do

    let!(:measurement) { create :measurement }

    it "updates a measurement" do
      api_put "measurements/#{measurement.id}", { name: 'new name', access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not update a measurement with invalid access_token" do
      api_put "measurements/#{measurement.id}", { name: 'new name', access_token: '123' }
      expect(response.status).to eq(403)
    end

    it "does not update a measurement with missing access_token" do
      api_put "measurements/#{measurement.id}", { name: 'new name', access_token: nil }
      expect(response.status).to eq(403)
    end

    it "does not update a measurement with empty parameters access_token" do
      api_put "measurements/#{measurement.id}", { name: nil, access_token: token.token }
      expect(response.status).to eq(422)
    end

  end

end
