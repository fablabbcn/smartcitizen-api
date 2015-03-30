require 'rails_helper'

describe V0::UsersController do

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
      body = api_get 'users?order=created_at&direction=desc'
      expect(body.map{|b| b['username']}).to eq([second.username,first.username])
    end

    it "has default asc order" do
      body = api_get 'users?order=username'
      expect(body.map{|b| b['username']}).to eq([first.username,second.username])
    end
  end

  describe "POST /users" do

    it "creates a user and sends welcome email" do
      api_post 'users', {
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

end
