require 'rails_helper'

describe V0::StaticController do

  # def home
  describe "GET /" do
    it "returns a list of routes" do
      json = api_get '/'
      expect(response.status).to eq(200)
      expect(json.keys).to eq %w(
        current_user_url
        components_url
        devices_url
        kits_url
        measurements_url
        sensors_url
        users_url
        tags_url
      )
    end
  end

  # def search

  describe "search" do

    it "can search by location", :vcr do
      # liverpool = create(:device, city: "liverpool", latitude: 53.419906, longitude: -2.9108462)
      # manchester = create(:device, city: "manchester", latitude: 53.4722454, longitude: -2.2235922)
      j = api_get "/search?q=manchester"

      expect(response.status).to eq(200)
      expect(j[0]["city"]).to eq("Manchester")
    end

    it "can search by user's first_name" do
      marge = create(:user, username: 'marge')
      bart = create(:user, username: 'bart')

      api_get "/search?q=bart"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)[0]["id"]).to eq(bart.id)
    end

  end

end
