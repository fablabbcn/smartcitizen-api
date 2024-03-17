require 'rails_helper'

describe V0::UsersController do

  let(:application) { create :application }
  let(:other_user) { create :user }
  let(:token) {
    create :access_token,
    application: application,
    resource_owner_id: user.id
  }

  # show
  describe "GET /users/<username||id>" do
    let!(:user) { create :user, username: 'testguy' }

    it "returns a user by id" do
      j = api_get "users/#{user.id}"
      expect(j['username']).to eq('testguy')
      expect(response.status).to eq(200)
    end

    it "returns a user by username" do
      j = api_get "users/testguy"
      expect(j['username']).to eq('testguy')
      expect(response.status).to eq(200)
    end

    it "returns not found if no user exists" do
      j = api_get "users/notauser"
      expect(j['id']).to eq('record_not_found')
      expect(response.status).to eq(404)
    end

    it "has filtered email address" do
      j = api_get "users/testguy"
      expect(j['email']).to eq('[FILTERED]')
    end

    it "exposes email address for an admin" do
      j = api_get "users/testguy?access_token=#{token.token}"
      expect(j['email']).to eq(user.email)
    end

    describe "device privacy" do
      before do
        @private_device = create(:device, owner: user, is_private: true)
        @public_device = create(:device, owner: user, is_private: false)
      end

      context "when the request is not authenticated" do
        it "only returns public devices" do
          j = api_get "users/testguy"
          expect(j["devices"].map { |d| d["id"] }).to include(@public_device.id)
          expect(j["devices"].map { |d| d["id"] }).not_to include(@private_device.id)
        end

        it "does not include the device locations" do
          j = api_get "users/testguy"
          expect(j["devices"].map { |d| d["location"]}.compact).to be_empty
        end
      end

      context "when the request is authenticated as the user being requested" do
        it "returns all devices" do
          j = api_get "users/testguy?access_token=#{token.token}"
          expect(j["devices"].map { |d| d["id"] }).to include(@public_device.id)
          expect(j["devices"].map { |d| d["id"] }).to include(@private_device.id)
        end

        it "includes the device locations" do
          j = api_get "users/testguy?access_token=#{token.token}"
          expect(j["devices"].map { |d| d["location"]}.compact).not_to be_empty
        end
      end

      context "when the request is authenticated as a different citizen user" do
        let(:requesting_token) {
          requesting_user = create :user
          create :access_token,
            application: application,
            resource_owner_id: requesting_user.id
        }

        it "only returns public devices" do
          j = api_get "users/testguy?access_token=#{requesting_token.token}"
          expect(j["devices"].map { |d| d["id"] }).to include(@public_device.id)
          expect(j["devices"].map { |d| d["id"] }).not_to include(@private_device.id)
        end

        it "does not include the device locations" do
          j = api_get "users/testguy?access_token=#{requesting_token.token}"
          expect(j["devices"].map { |d| d["location"]}.compact).to be_empty
        end
      end

      context "when the request is authenticated as a different researcher user" do
        let(:requesting_token) {
          requesting_user = create :user, role_mask: 3
          create :access_token,
            application: application,
            resource_owner_id: requesting_user.id
        }

        it "only returns public devices" do
          j = api_get "users/testguy?access_token=#{requesting_token.token}"
          expect(j["devices"].map { |d| d["id"] }).to include(@public_device.id)
          expect(j["devices"].map { |d| d["id"] }).not_to include(@private_device.id)
        end

        it "does not include the device locations" do
          j = api_get "users/testguy?access_token=#{requesting_token.token}"
          expect(j["devices"].map { |d| d["location"]}.compact).to be_empty
        end
      end

      context "when the request is authenticated as a different admin user" do
        let(:requesting_token) {
          requesting_user = create :user, role_mask: 5
          create :access_token,
            application: application,
            resource_owner_id: requesting_user.id
        }

        it "returns all devices" do
          j = api_get "users/testguy?access_token=#{requesting_token.token}"
          expect(j["devices"].map { |d| d["id"] }).to include(@public_device.id)
          expect(j["devices"].map { |d| d["id"] }).to include(@private_device.id)
        end

        it "includes the device locations" do
          j = api_get "users/testguy?access_token=#{requesting_token.token}"
          expect(j["devices"].map { |d| d["location"]}.compact).not_to be_empty
        end
      end
    end
  end

  # index
  describe "GET /users" do

    let(:first) { create(:user, username: "firstguy") }
    let(:second) { create(:user, username: "secondguy") }
    let(:another) { create(:user, username: "anotherguy") }

    describe "ordering" do

      before(:each) do
        User.unscoped.destroy_all # needed because database_cleaner doesn't do unscoped
        Timecop.freeze do
          first # touch record
          Timecop.travel(1.second) # force ordering
          second # touch record
        end
      end

      it "returns all the users" do
        j = api_get 'users'
        expect(j.map{|b| b['username']}).to eq(%w(firstguy secondguy))
        expect(response.status).to eq(200)
      end

      it "can be ordered by created_at" do
        j = api_get 'users?q[s]=created_at desc'
        expect(j.map{|b| b['username']}).to eq(%w(secondguy firstguy))
      end

      it "can be ordered by username" do
        another # touch record
        j = api_get 'users?q[s]=username asc'
        expect(
          j.map{|b| b['username']}
        ).to eq(%w(anotherguy firstguy secondguy))
      end

    end

    describe "pagination" do
      before(:each) do
        30.times { create(:user) }
      end

      it "has default 25 per page limit" do
        get "/v0/users"
        j = JSON.parse(response.body)
        expect(response.headers['Total']).to eq('30')
        expect(response.headers['Per-Page']).to eq('25')
        expect(j.length).to eq(25)
      end

      it "has a second page" do
        get "/v0/users?page=2"
        j = JSON.parse(response.body)
        expect(response.headers['Total']).to eq('30')
        expect(response.headers['Per-Page']).to eq('25')
        expect(j.length).to eq(5)
      end

      it "can change the per page limit" do
        get "/v0/users?per_page=4"
        j = JSON.parse(response.body)
        expect(response.headers['Total']).to eq('30')
        expect(response.headers['Per-Page']).to eq('4')
        expect(j.length).to eq(4)
      end
    end

    describe "smoke tests for ransack" do
      it "does not allow searching by first name" do
        json = api_get "users?q[first_name_eq]=Tim"
        expect(response.status).to eq(400)
        expect(json["status"]).to eq(400)
      end

      it "allows searching by city" do
        json = api_get "users?q[city_eq]=Barcelona"
        expect(response.status).to eq(200)
      end

      it "allows searching by country code" do
        json = api_get "users?q[country_code_eq]=es"
        expect(response.status).to eq(200)
      end

      it "allows searching by id" do
        json = api_get "users?q[id_eq]=1"
        expect(response.status).to eq(200)
      end

      it "allows searching by username" do
        json = api_get "users?q[username_eq]=mistertim"
        expect(response.status).to eq(200)
      end

      it "allows searching by uuid" do
        json = api_get "users?q[uuid_eq]=1"
        expect(response.status).to eq(200)
      end

      it "allows searching by created_at" do
        json = api_get "users?q[created_at_eq]=1"
        expect(response.status).to eq(200)
      end

      it "allows searching by updated_at" do
        json = api_get "users?q[updated_at_eq]=1"
        expect(response.status).to eq(200)
      end

      it "does not allow searching on disallowed parameters" do
        json = api_get "users?q[disallowed_eq]=1"
        expect(response.status).to eq(400)
        expect(json["status"]).to eq(400)
      end
    end
  end

  describe "POST /users" do

    it "creates a user and sends welcome email" do
      j = api_post 'users', {
        username: 'homer',
        email: 'homer@springfieldnuclear.com',
        password: 'donuts'
      }
      expect(j['username']).to eq('homer')
      expect(response.status).to eq(201)
      expect(last_email.to).to eq(["homer@springfieldnuclear.com"])
      expect(last_email.subject).to eq("Welcome to SmartCitizen")
    end

    it "does not create a user with missing parameters" do
      j = api_post 'users', {
        username: 'Homer'
      }
      expect(j['id']).to eq('unprocessable_entity')
      expect(response.status).to eq(422)
    end

  end

  describe "PUT /users/<username>|<id>" do

    let(:user) { create(:user, username: 'lisasimpson', country_code: "GB") }

    it "updates user" do
      j = api_put "users/#{[user.username,user.id].sample}", {
        username: 'bart', access_token: token.token
      }
      expect(j['username']).to eq('bart')
      expect(response.status).to eq(200)
    end

    it "updates user country code" do
      j = api_put "users/#{[user.username,user.id].sample}", {
        country_code: 'ES', access_token: token.token
      }
      expect(j['location']['country_code']).to eq('ES')
      expect(j['location']['country']).to eq('Spain')
      expect(response.status).to eq(200)
      expect(user.reload.country_code).to eq('ES')
    end

    it "does not update a user with invalid access_token" do
      j = api_put "users/#{[user.username,user.id].sample}", {
        username: 'bart', access_token: '123'
      }
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    it "does not update another user" do
      j = api_put "users/#{[other_user.username,other_user.id].sample}", {
        username: 'Bart', access_token: token.token
      }
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    it "updates another user if admin" do
      user.update_attribute(:role_mask, 5)
      j = api_put "users/#{[other_user.username,other_user.id].sample}", {
        username: 'bart', access_token: token.token
      }
      expect(j['username']).to eq('bart')
      expect(response.status).to eq(200)
    end

    it "does not update a user with missing access_token" do
      j = api_put "users/#{[user.username,user.id].sample}", {
        username: 'bart', access_token: nil
      }
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    it "does not update a user with empty parameters access_token" do
      j = api_put "users/#{[user.username,user.id].sample}", {
        username: nil, access_token: token.token
      }
      expect(j['id']).to eq('unprocessable_entity')
      expect(response.status).to eq(422)
    end

  end



  describe "DELETE /users/:id" do

    let!(:user) { create :user }

    it "deletes a user" do
      api_delete "users/#{user.id}", { access_token: token.token }
      expect(response.status).to eq(200)
    end

    it "does not delete a user with invalid access_token" do
      api_delete "users/#{user.id}", { access_token: '123' }
      expect(response.status).to eq(403)
    end

    it "does not delete a user with missing access_token" do
      api_delete "users/#{user.id}"
      expect(response.status).to eq(403)
    end

  end

end
