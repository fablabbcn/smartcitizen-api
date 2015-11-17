require 'rails_helper'

describe V0::UploadsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }

  describe "/POST" do

    it "creates an upload" do
      j = api_post "avatars",
        access_token: token.token,
        original_filename: "test.jpg"
      expect(response.status).to eq(200)
      user.reload
      expect(j['policy']).to_not be_blank
      expect(j['signature']).to_not be_blank
      expect(j['key']).to eq(user.uploads.last.key)
    end

    it "requires original_filename" do
      j = api_post "avatars",
        access_token: token.token
      expect(response.status).to eq(400)
    end

    it "requires access_token" do
      j = api_post "avatars",
        original_filename: "test.jpg"
      expect(response.status).to eq(401)
    end

  end

  describe "amazon s3 callback" do

    let(:upload) { create(:upload, user: user) }

    it "responds to uploaded" do
      # i know this doesn't belong here, but needed to check
      expect(user.avatar_url).to be_blank
      j = api_post "avatars/uploaded", key: upload.key
      user.reload
      expect(user.avatar_url).to eq(upload.full_path)
      expect(response.status).to eq(200)
    end

    it "requires key" do
      j = api_post "avatars/uploaded"
      expect(j['id']).to eq('parameter_missing')
      expect(response.status).to eq(400)
    end

  end

end
