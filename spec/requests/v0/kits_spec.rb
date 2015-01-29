require 'rails_helper'

describe V0::KitsController do

  describe "GET /kits" do
    it "returns all the kits" do
      first = create(:kit)
      second = create(:kit)
      api_get 'kits'
      expect(response.status).to eq(200)
    end
  end

  describe "GET /kits/:id" do
    it "returns a kit" do
      kit = create(:kit)
      api_get "kits/#{kit.id}"
      expect(response.status).to eq(200)
    end

    pending "returns 404 if kit not found" do
      api_get 'kits/1'
      expect(response.status).to eq(404)
    end
  end

end
