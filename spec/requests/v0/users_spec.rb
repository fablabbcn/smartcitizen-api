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
