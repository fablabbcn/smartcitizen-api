require 'rails_helper'

describe V0::MeController, type: :request do

  let(:application) { create :application }
  let(:user) { create :user, username: 'barney', password: '1234567' }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  before(:each) do
    # Prevent throttle
    Rails.cache.clear
  end

  describe "current_user" do

    describe "OAuth 2.0" do
      it "valid credentials" do
        j = api_get "me", { access_token: token.token }
        expect(j['username']).to eq('barney')
        expect(response.status).to eq(200)
      end

      it "invalid credentials" do
        r = api_get 'me', { access_token: 'moo' }
        expect(response.status).to eq(401)
        expect(r["id"]).to eq("unauthorized")
        expect(r["message"]).to eq("Invalid OAuth2 Params")
      end

      it "(empty) invalid credentials" do
        r = api_get 'me'
        expect(response.status).to eq(401)
        expect(r["id"]).to eq("unauthorized")
        expect(r["message"]).to eq("Authorization required")
      end
    end

    describe "username:password" do
      it "valid credentials" do
        get '/me', params: {}, headers: {HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(user.username, '1234567')}
        expect(response.status).to eq(200)
      end

      it "invalid credentials" do
        get '/me', params: {}, headers: {HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(user.username, '123')}
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)["message"]).to eq("Invalid Username/Password Combination")
      end

      it "(empty) invalid credentials" do
        get '/me', params: {}, headers: {HTTP_AUTHORIZATION: ""}
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)["message"]).to eq("Authorization required")
      end
    end

  end

  describe "GET /me" do
    it "returns current_user" do
      j = api_get "me", { access_token: token.token }
      expect(j["username"]).to eq('barney')
      expect(response.status).to eq(200)
    end

    it "returns 401 if not authorized" do
      j = api_get 'me'
      expect(j['id']).to eq('unauthorized')
      expect(response.status).to eq(401)
    end
  end

  describe "PUT /me" do

    it "updates current_user" do
      j = api_put "me", { username: 'krusty', access_token: token.token }
      expect(j['username']).to eq('krusty')
      expect(response.status).to eq(200)
    end

    it "does not update a user with invalid access_token" do
      j = api_put "me", { username: 'krusty', access_token: '123' }
      expect(j['id']).to eq('unauthorized')
      expect(response.status).to eq(401)
    end

    it "does not update a user with missing access_token" do
      j = api_put "me", { username: 'krusty', access_token: nil }
      expect(j['id']).to eq('unauthorized')
      expect(response.status).to eq(401)
    end

    it "does not update a user with empty parameters access_token" do
      j = api_put "me", { username: nil, access_token: token.token }
      expect(j['id']).to eq('unprocessable_entity')
      expect(response.status).to eq(422)
    end

  end


  describe "DELETE /me" do

    it "deletes current_user" do
      api_delete "me", { access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not delete current_user with invalid access_token" do
      api_delete "me", { access_token: '123' }
      expect(response.status).to eq(401)
    end

    it "does not delete current_user with missing access_token" do
      api_delete "me"
      expect(response.status).to eq(401)
    end

  end
end
