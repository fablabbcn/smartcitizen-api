require 'rails_helper'

describe V0::StaticController do

  describe "search" do

    it "can search by location" do
      liverpool = create(:device, city: "liverpool", latitude: 53.419906, longitude: -2.9108462)
      manchester = create(:device, city: "manchester", latitude: 53.4722454, longitude: -2.2235922)

      api_get "/search?q=manchester"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)[0]["id"]).to eq(manchester.id)
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
