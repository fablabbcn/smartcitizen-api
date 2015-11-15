require 'rails_helper'

describe V0::PasswordResetsController do

  let!(:user) { create(:user, username: 'homer', email: 'homer@simpson.com') }

  describe "POST /password_resets" do
    it "requires params" do
      api_post 'password_resets'
      expect(response.status).to eq(422)
      expect(response.body).to match('Please include parameter email, username or email_or_username')
    end
  end

  describe "POST /password_resets/:username" do

    it "can request reset password instructions" do
      api_post 'password_resets', { username: 'homer' }
      expect(response.status).to eq(200)
      expect(last_email.to).to eq([user.email])
      expect(last_email.subject).to eq('Password Reset Instructions')
    end

    it "cannot reset password instructions with invalid data" do
      api_post 'password_resets', { username: 'bart' }
      expect(response.status).to eq(404)
      expect(last_email).to be_nil
    end

    it "can request reset password instructions (email_or_username)" do
      api_post 'password_resets', { email_or_username: 'homer' }
      expect(response.status).to eq(200)
      expect(last_email.to).to eq([user.email])
      expect(last_email.subject).to eq('Password Reset Instructions')
    end

    it "cannot reset password instructions with invalid data (email_or_username)" do
      api_post 'password_resets', { email_or_username: 'bart' }
      expect(response.status).to eq(404)
      expect(last_email).to be_nil
    end
  end

  describe "POST /password_resets/:email" do

    it "can request reset password instructions" do
      api_post 'password_resets', { email: 'homer@simpson.com' }
      expect(response.status).to eq(200)
      expect(last_email.to).to eq([user.email])
      expect(last_email.subject).to eq('Password Reset Instructions')
    end

    it "cannot reset password instructions with invalid data" do
      api_post 'password_resets', { email: 'bart@simpson.com' }
      expect(response.status).to eq(404)
      expect(last_email).to be_nil
    end

    it "can request reset password instructions (email_or_username)" do
      api_post 'password_resets', { email_or_username: 'homer@simpson.com' }
      expect(response.status).to eq(200)
      expect(last_email.to).to eq([user.email])
      expect(last_email.subject).to eq('Password Reset Instructions')
    end

    it "cannot reset password instructions with invalid data (email_or_username)" do
      api_post 'password_resets', { email_or_username: 'bart@simpson.com' }
      expect(response.status).to eq(404)
      expect(last_email).to be_nil
    end

  end


  describe "GET /password_resets/<password_reset_token>" do
    before(:each) do
      user.send_password_reset
      user.reload
    end

    it "finds user by token" do
      api_get "password_resets/#{user.password_reset_token}"
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)["username"]).to eq(user.username)
    end

  end

  describe "PUT /password_resets/<password_reset_token>" do

    before(:each) do
      user.send_password_reset
      user.reload
    end

    it "can reset password with valid token" do
      expect(user.authenticate('newpass')).to be_falsey
      api_put "password_resets/#{user.password_reset_token}", { password: 'newpass' }
      expect(response.status).to eq(200)
      user.reload
      expect(user.authenticate('newpass')).to be_truthy
    end

    it "cannot reset password with invalid token" do
      api_put "password_resets/invalid", { password: 'newpass' }
      expect(response.status).to eq(404)
    end

    it "cannot reset password with empty password" do
      api_put "password_resets/#{user.password_reset_token}", { password: nil }
      expect(response.status).to eq(400)
    end

  end


end
