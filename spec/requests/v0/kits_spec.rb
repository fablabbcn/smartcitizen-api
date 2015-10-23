require 'rails_helper'

describe V0::KitsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  describe "GET /kits" do
    it "returns all the kits" do
      first = create(:kit)
      second = create(:kit)
      json = api_get 'kits'

      expect(response.status).to eq(200)
      expect(json.length).to eq(2)
      expect(json[0]['id']).to eq(first.id)
      expect(json[0].keys).to eq(%w(id uuid slug name description created_at updated_at sensors))
    end
  end

  describe "GET /kits/:id" do
    it "returns a kit" do
      kit = create(:kit)
      api_get "kits/#{kit.id}"
      expect(response.status).to eq(200)
    end

    it "returns 404 if kit not found" do
      api_get 'kits/100'
      expect(response.status).to eq(404)
    end
  end

  describe "PUT /kits/:id" do

    let!(:kit) { create :kit }

    it "updates a kit" do
      api_put "kits/#{kit.id}", { name: 'new name', access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not update a kit with invalid access_token" do
      api_put "kits/#{kit.id}", { name: 'new name', access_token: '123' }
      expect(response.status).to eq(403)
    end

    it "does not update a kit with missing access_token" do
      api_put "kits/#{kit.id}", { name: 'new name', access_token: nil }
      expect(response.status).to eq(403)
    end

    it "does not update a kit with empty parameters access_token" do
      api_put "kits/#{kit.id}", { name: nil, access_token: token.token }
      expect(response.status).to eq(422)
    end

  end

end
