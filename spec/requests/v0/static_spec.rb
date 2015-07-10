require 'rails_helper'

describe V0::StaticController do

  describe "GET 404" do
    it "returns 404 error" do
      api_get '/404'
      expect(response.status).to eq(404)
      expect(response.body).to match("Endpoint not found")
    end
  end

  describe "GET /" do
    it "returns a list of routes" do
      api_get '/'
      expect(response.status).to eq(200)
    end
  end

  describe "search" do
    it "returns a list of searched objects" do
      api_get "/search?q=device"
      expect(response.status).to eq(200)
    end
  end

  describe "format" do

    it "(JSON) returns pretty JSON, with JSON Mimetype" do
      json = api_get '/v0/kits'
      expect( response.body.to_s ).to_not eq( JSON.pretty_generate(json) )
      expect(response.header['Content-Type']).to include('application/json')
    end

    it "(JSON) returns pretty JSON, with JSON Mimetype if ?pretty=true" do
      json = api_get '/v0/kits?pretty=true'
      expect( response.body.to_s ).to eq( JSON.pretty_generate(json) )
      expect(response.header['Content-Type']).to include('application/json')
    end

    it "(JSONP) returns JS Mimetype if callback param present" do
      api_get '/v0/kits?callback=something'
      expect(response.header['Content-Type']).to include('text/javascript')
    end
  end

end
