require 'rails_helper'

describe V0::StaticController do

  describe "GET /" do
    it "returns a list of routes" do
      api_get '/'
      expect(response.status).to eq(200)
    end
  end

end
