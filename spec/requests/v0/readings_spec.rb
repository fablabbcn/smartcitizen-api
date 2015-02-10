require 'rails_helper'

describe V0::ReadingsController do

  pending "GET /readings" do
    it "returns all readings" do
      api_get 'readings'
      expect(response.status).to eq(200)
    end
  end

  describe "GET /add" do

    it "returns time" do
      Timecop.freeze(Time.utc(2015,02,01,20,00,05)) do
        get "/add"
        expect(response.body).to eq("UTC:2015,2,1,20,00,05#")
      end
    end

  end

end
