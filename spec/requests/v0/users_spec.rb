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
