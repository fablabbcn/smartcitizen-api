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
    it "returns a list of searched objects" do
      api_get "/search?q=device"
      expect(response.status).to eq(200)
    end
  end

end
