require 'rails_helper'

describe V0::MeasurementsController do

  let(:application) { build :application }
  let(:user) { build :user }
  let(:admin) { create :admin }
  let(:token) { build :access_token, application: application, resource_owner_id: user.id }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }

  it "needs general user tests"

  describe "GET /measurement/<id>" do
    it "returns a measurement" do
      measurement = create(:measurement)
      j = api_get "measurements/#{measurement.id}"
      expect(j['id']).to eq(measurement.id)
      expect(response.status).to eq(200)
    end
  end

  describe "GET /measurements" do
    it "returns all the measurements" do
      first = create(:measurement)
      second = create(:measurement)
      j = api_get 'measurements'
      expect(j.length).to eq(2)
      expect(j.map{|m| m['id']}).to eq([first.id, second.id])
      expect(response.status).to eq(200)
      expect(response.headers.keys).to include('Total')
    end
  end

  describe "POST /measurements" do

    describe "admin" do

      it "creates a measurement" do
        j = api_post 'measurements', {
          name: 'new measurement',
          description: 'blah blah blah',
          unit: 'm',
          access_token: admin_token.token
        }
        expect(j['name']).to eq('new measurement')
        expect(response.status).to eq(201)
      end

      it "does not create a measurement with missing parameters" do
        j = api_post 'measurements', {
          name: 'Missing params',
          access_token: admin_token.token
        }
        expect(j['id']).to eq('unprocessable_entity')
        expect(response.status).to eq(422)
      end

    end

  end

  describe "PUT /measurements/:id" do

    let!(:measurement) { create :measurement }

    it "updates a measurement" do
      j = api_put "measurements/#{measurement.id}", { name: 'new name', access_token: admin_token.token }
      expect(j['name']).to eq('new name')
      expect(response.status).to eq(200)
    end

    it "does not update a measurement with invalid access_token" do
      j = api_put "measurements/#{measurement.id}", { name: 'new name', access_token: '123' }
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    it "does not update a measurement with missing access_token" do
      j = api_put "measurements/#{measurement.id}", { name: 'new name', access_token: nil }
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    it "does not update a measurement with empty parameters access_token" do
      j = api_put "measurements/#{measurement.id}", { name: nil, access_token: admin_token.token }
      expect(j['id']).to eq('unprocessable_entity')
      expect(response.status).to eq(422)
    end

  end

end
