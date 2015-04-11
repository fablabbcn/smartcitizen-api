require 'rails_helper'

describe V0::MeController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  describe "current_user" do

    describe "OAuth 2.0" do
      it "valid credentials" do
        api_get "me", { access_token: token.token }
        expect(response.status).to eq(200)
      end

      it "invalid credentials" do
        r = api_get 'me', { access_token: 'moo' }
        expect(response.status).to eq(401)
        expect(r["errors"]).to eq("Invalid OAuth2 Params")
      end

      it "(empty) invalid credentials" do
        r = api_get 'me'
        expect(response.status).to eq(401)
        expect(r["errors"]).to eq("Authorization required")
      end
    end

    skip "username:password"
    skip "token authentication"

  end

  describe "GET /me" do
    it "returns current_user" do
      resp = api_get "me", { access_token: token.token }
      expect(resp["username"]).to eq(user.username)
    end

    it "returns 401 if not authorized" do
      api_get 'me'
      expect(response.status).to eq(401)
    end
  end

  describe "PUT /me" do

    it "updates current_user" do
      api_put "me", { first_name: 'Bart', access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not update a user with invalid access_token" do
      api_put "me", { first_name: 'Bart', access_token: '123' }
      expect(response.status).to eq(401)
    end

    it "does not update a user with missing access_token" do
      api_put "me", { first_name: 'Bart', access_token: nil }
      expect(response.status).to eq(401)
    end

    it "does not update a user with empty parameters access_token" do
      api_put "me", { first_name: nil, access_token: token.token }
      expect(response.status).to eq(422)
    end

  end

end
