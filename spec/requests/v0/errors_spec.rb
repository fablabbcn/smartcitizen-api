require 'rails_helper'

describe V0::ErrorsController do

  describe "GET 404" do
    it "returns 404 error" do
      j = api_get '/404'
      expect(j['id']).to eq('not_found')
      expect(response.status).to eq(404)
      expect(response.body).to match("Endpoint not found")
    end
  end

  skip "raises 500 error" do
    j = api_get '/test_error'
    expect(j['id']).to eq('internal_server_error')
    expect(response.status).to eq(500)
  end

end
