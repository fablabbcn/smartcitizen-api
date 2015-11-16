require 'rails_helper'

describe V0::ErrorsController do

  describe "GET 404" do
    it "returns 404 error" do
      api_get '/404'
      expect(response.status).to eq(404)
      expect(response.body).to match("Endpoint not found")
    end
  end

end
