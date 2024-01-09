require 'rails_helper'

describe V0::ApplicationController do

  describe "format" do
    it "(JSON) returns ugly JSON, with JSON Mimetype" do
      json = api_get '/devices'
      #expect( response.body.to_s ).to_not eq( JSON.pretty_generate(json) )
      expect(response.header['Content-Type']).to include('application/json')
    end

    skip "(JSON) returns pretty JSON, with JSON Mimetype if ?pretty=true" do
      json = api_get '/v0/devices?pretty=true'
      expect( response.body.to_s ).to eq( JSON.pretty_generate(json) )
      expect(response.header['Content-Type']).to include('application/json')
    end

    skip "(JSON-P) returns JS Mimetype if callback param present" do
      # rails now handles this
      api_get '/v0/devices?callback=something'
      expect(response.header['Content-Type']).to include('text/javascript')
    end
  end

end
