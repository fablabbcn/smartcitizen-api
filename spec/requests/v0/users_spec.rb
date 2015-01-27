require 'rails_helper'

describe V0::UsersController do

  describe "GET /users" do
    it "returns all the users" do
      first = create(:user)
      second = create(:user)
      api_get 'users'
      expect(response.status).to eq(200)
    end
  end

  describe "GET /users/:id" do
    it "returns a user" do
      user = create(:user)
      api_get "users/#{user.id}"
      expect(response.status).to eq(200)
    end

    pending "returns 404 if user not found" do
      api_get 'users/1'
      expect(response.status).to eq(404)
    end
  end

  describe "PUT /users/:id" do

    let(:application) { create :application }
    let(:user) { create :user }
    let(:token) { create :access_token, application: application, resource_owner_id: user.id }

    it "updates a user" do
      api_put "users/#{user.id}", { user: { first_name: 'Bart' }, access_token: token.token }
      expect(response.status).to eq(204)
    end

    it "does not update a user with invalid access_token" do
      api_put "users/#{user.id}", { user: { first_name: 'Bart' }, access_token: '123' }
      expect(response.status).to eq(401)
    end

    it "does not update a user with missing access_token" do
      api_put "users/#{user.id}", { user: { first_name: 'Bart' }, access_token: nil }
      expect(response.status).to eq(401)
    end

    it "does not update a user with empty parameters access_token" do
      api_put "users/#{user.id}", { user: { first_name: nil }, access_token: token.token }
      expect(response.status).to eq(422)
    end

  end

  describe "POST /users" do

    it "creates a user" do
      api_post 'users', { user: {
          first_name: 'Homer',
          last_name: 'Simpson',
          username: 'homer',
          email: 'homer@springfieldnuclear.com',
          password: 'donuts'
        }
      }
      expect(response.status).to eq(201)
    end

    it "does not create a user with missing parameters" do
      api_post 'users', { user: {
          first_name: 'Homer'
        }
      }
      expect(response.status).to eq(422)
    end

  end

end
