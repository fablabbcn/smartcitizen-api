require 'rails_helper'

describe V0::StaticController do

  describe "GET /" do
    it "returns a list of routes" do
      api_get '/'
      expect(response.status).to eq(200)
    end
  end

  describe "format" do

    it "(JSON) returns pretty JSON, with JSON Mimetype" do
      json = api_get '/'
      expect( response.body.to_s ).to eq( JSON.pretty_generate(json) )
      expect(response.header['Content-Type']).to include('application/json')
    end

    it "(JSONP) returns JS Mimetype if callback param present" do
      api_get '/?callback=something'
      expect(response.header['Content-Type']).to include('text/javascript')
    end
  end

end
