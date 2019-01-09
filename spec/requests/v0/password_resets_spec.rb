require 'rails_helper'

describe V0::PasswordResetsController do

  let!(:user) { create(:user, username: 'homer', email: 'homer@simpson.com') }

  # create
  describe "POST /password_resets" do
    it "requires params" do
      j = api_post 'password_resets'
      expect(j['id']).to eq('unprocessable_entity')
      expect(response.status).to eq(422)
      expect(response.body).to match('Please include parameter email, username or email_or_username')
    end

    items = [
      {
        key: 'email',
        valid: 'homer@simpson.com',
        invalid: 'bart@simpson.com'
      },
      {
        key: 'username',
        valid: 'homer',
        invalid: 'bart'
      },
      # case insensitive
      {
        key: 'email',
        valid: 'HOmEr@sIMPSON.com',
        invalid: 'homer @simpson.com'
      },
      {
        key: 'username',
        valid: 'homER',
        invalid: 'ho mer'
      }
    ]

    items.each do |item|

      describe "(using #{item[:key]})" do

        describe "with valid data" do

          it "can request reset password instructions" do
            j = api_post 'password_resets', { item[:key] => item[:valid] }
            expect(j['message']).to eq('Password Reset Instructions Delivered')
            expect(response.status).to eq(200)
            expect(last_email.to).to eq([user.email])
            expect(last_email.subject).to eq('Password Reset Instructions')
          end

          it "can request reset password instructions (email_or_username)" do
            j = api_post 'password_resets', { email_or_username: item[:valid] }
            expect(j['message']).to eq('Password Reset Instructions Delivered')
            expect(response.status).to eq(200)
            expect(last_email.to).to eq([user.email])
            expect(last_email.subject).to eq('Password Reset Instructions')
          end

        end

        describe "with invalid data" do

          it "cannot reset password instructions" do
            j = api_post 'password_resets', { item[:key] => item[:invalid] }
            expect(j['id']).to eq('record_not_found')
            expect(response.status).to eq(404)
            expect(last_email).to be_nil
          end

          it "cannot reset password instructions (email_or_username)" do
            j = api_post 'password_resets', { email_or_username: item[:invalid] }
            expect(j['id']).to eq('record_not_found')
            expect(response.status).to eq(404)
            expect(last_email).to be_nil
          end

        end

      end

    end

  end

  # show
  describe "GET /password_resets/<password_reset_token>" do
    before(:each) do
      user.send_password_reset
      user.reload
    end

    it "finds user by token" do
      j = api_get "password_resets/#{user.password_reset_token}"
      expect(response.status).to eq(200)
      expect(j["username"]).to eq(user.username)
    end

    it "with invalid token" do
      j = api_get "password_resets/2424323a"
      expect(response.status).to eq(404)
      expect(j["id"]).to eq('record_not_found')
    end

  end

  # update
  describe "PUT /password_resets/<password_reset_token>" do

    before(:each) do
      user.send_password_reset
      user.reload
    end

    it "can reset password with valid token" do
      expect(user.authenticate('newpass')).to be_falsey
      j = api_put "password_resets/#{user.password_reset_token}", { password: 'newpass' }
      expect(j["username"]).to eq(user.username)
      expect(response.status).to eq(200)

      # i know this doesn't belong here, but wanted to test it
      user.reload
      expect(user.password_reset_token).to be_nil
      expect(user.authenticate('newpass')).to be_truthy
    end

    # Skip because this endpoint does not work, it was returning:
    # {"id"=>"not_found", "message"=>"Endpoint not found", "errors"=>nil, "url"=>nil}
    # but now we have disabled the routes.rb match (catch all), for Active Storage to work properly
    skip "requires a token" do
      j = api_put "password_resets", { password: 'newpass' }
      expect(j["id"]).to eq('not_found')
      expect(response.status).to eq(404)
    end

    it "cannot reset password with invalid token" do
      j = api_put "password_resets/invalid", { password: 'newpass' }
      expect(j["id"]).to eq('record_not_found')
      expect(response.status).to eq(404)
    end

    it "cannot reset password with empty password" do
      j = api_put "password_resets/#{user.password_reset_token}", { password: nil }
      expect(j["id"]).to eq('parameter_missing')
      expect(response.status).to eq(400)
    end

    it "requires valid password" do
      j = api_put "password_resets/#{user.password_reset_token}", { password: 'bad' }
      expect(j["errors"]['password'].to_s).to include('too short')
      expect(j["id"]).to eq('unprocessable_entity')
      expect(response.status).to eq(422)
    end

  end


end
