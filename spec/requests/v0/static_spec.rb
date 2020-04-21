require 'rails_helper'

describe V0::StaticController do

  # def home
  describe "GET /" do
    it "returns a list of routes" do
      json = api_get '/'
      expect(response.status).to eq(200)
      expect(json.keys).to eq %w(
        notice
        api_documentation_url
        current_user_url
        components_url
        devices_url
        kits_url
        measurements_url
        sensors_url
        users_url
        tags_url
        tags_sensors_url
        version_git
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

    it "handles searches without q parameter" do
      api_get "/search"
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).first[0]).to eq('Warning')
    end

    it "can search by user's first_name" do
      marge = create(:user, username: 'marge')
      bart = create(:user, username: 'bart')

      api_get "/search?q=bart"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)[0]["id"]).to eq(bart.id)
    end

    it "deletes PgSearch::Document if associated record is not found" do
      dev = create(:device, name: 'deleted')
      # delete record without callbacks
      dev.delete

      # PgSearch::Document present still
      expect(PgSearch.multisearch('deleted').includes(:searchable).first['content']).to include('deleted')

      j = api_get "/search?q=deleted" # does not raise NoMethodError

      expect(j.length).to eq(0) # device not included in results

      # out-of-sync PgSearch::Document has been removed
      expect(PgSearch.multisearch('deleted').includes(:searchable).length).to eq(0)
    end

  end

end
