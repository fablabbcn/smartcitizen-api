require 'rails_helper'

describe V0::UsersController do

  let(:application) { create :application }
  let(:other_user) { create :user }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  describe "GET /users/<username||id>" do

    let(:user) { create(:user) }

    it "returns a user by id" do
      api_get "users/#{user.id}"
      expect(response.status).to eq(200)
    end

    it "returns a user by username" do
      api_get "users/#{user.username}"
      expect(response.status).to eq(200)
    end

    it "returns not found if no user exists" do
      api_get "users/notauser"
      expect(response.status).to eq(404)
    end

  end

  describe "GET /users" do

    let(:first) { create(:user, username: "first") }
    let(:second) { create(:user, username: "second") }
    before(:each) do
      Timecop.freeze do
        first
        Timecop.travel(10.seconds)
        second
      end
    end

    it "returns all the users" do
      body = api_get 'users'
      expect(response.status).to eq(200)
      expect(body.map{|b| b['username']}).to eq([first.username,second.username])
    end

    it "can be ordered" do
      # body = api_get 'users?order=created_at&direction=desc'
      body = api_get 'users?q[s]=created_at desc'
      expect(body.map{|b| b['username']}).to eq([second.username,first.username])
    end

    it "has default asc order" do
      # body = api_get 'users?order=username'
      body = api_get 'users?q[s]=username asc'
      expect(body.map{|b| b['username']}).to eq([first.username,second.username])
    end
  end

  describe "POST /users" do

    it "creates a user and sends welcome email" do
      r = api_post 'users', {
        first_name: 'Homer',
        last_name: 'Simpson',
        username: 'homer',
        email: 'homer@springfieldnuclear.com',
        password: 'donuts'
      }
      expect(response.status).to eq(201)
      expect(last_email.to).to eq(["homer@springfieldnuclear.com"])
      expect(last_email.subject).to eq("Welcome to SmartCitizen")
    end

    it "does not create a user with missing parameters" do
      api_post 'users', {
        first_name: 'Homer'
      }
      expect(response.status).to eq(422)
    end

  end

  describe "PUT /users/<username>|<id>" do

    let(:user) { create(:user, first_name: 'Lisa') }

    it "updates user" do
      api_put "users/#{[user.username,user.id].sample}", { first_name: 'Bart', access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not update a user with invalid access_token" do
      api_put "users/#{[user.username,user.id].sample}", { first_name: 'Bart', access_token: '123' }
      expect(response.status).to eq(401)
    end

    it "does not update another user" do
      api_put "users/#{[other_user.username,other_user.id].sample}", { first_name: 'Bart', access_token: token.token }
      expect(response.status).to eq(403)
    end

    it "updates another user if admin" do
      user.update_attribute(:role_mask, 5)
      api_put "users/#{[other_user.username,other_user.id].sample}", { first_name: 'Bart', access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not update a user with missing access_token" do
      api_put "users/#{[user.username,user.id].sample}", { first_name: 'Bart', access_token: nil }
      expect(response.status).to eq(401)
    end

    it "does not update a user with empty parameters access_token" do
      api_put "users/#{[user.username,user.id].sample}", { username: nil, access_token: token.token }
      expect(response.status).to eq(422)
    end

  end

end
