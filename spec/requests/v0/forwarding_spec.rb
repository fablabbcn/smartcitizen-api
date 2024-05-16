require 'rails_helper'

describe V0::ForwardingController, type: :request do

  let(:user) {
    create(:user, role_mask: 5).tap do |user|
      user.regenerate_forwarding_tokens!
      user.save!
    end
  }

  let(:token) {
    user.forwarding_token
  }

  let(:username) {
    user.forwarding_username
  }

  let(:topic) {
    "/forward/#{token}/device/+/readings"
  }

  let(:params) {
    {
      topic: topic,
      username: username
    }
  }

  shared_examples_for "authorized" do
    it "authorizes the subscription" do
      r = api_get "/forward", params
      expect(response.status).to eq(200)
      expect(r["result"]).to eq("allow")
    end
  end

  shared_examples_for "not authorized" do
    it "does not authorize the subscription" do
      r = api_get "/forward", params
      expect(response.status).to eq(200)
      expect(r["result"]).to eq("deny")
    end
  end

  context "when the topic is a forwarding topic" do
    context "when the forwarding token matches a user" do
      context "when the username matches the user's forwarding_username" do
        it_behaves_like "authorized"
      end

      context "when the username does not match the user's forwarding_username" do
        let(:username) { "other_username" }
        it_behaves_like "not authorized"
      end
    end

    context "when the forwarding token does not match a user" do
        let(:token) { "other_token" }
        it_behaves_like "not authorized"
    end
  end

  context "when the topic is not a forwarding topic" do
    let(:topic) { "/some/other/topic" }
    it_behaves_like "not authorized"
  end

  context "when no username is supplied" do
    let(:username) { nil }
    it_behaves_like "not authorized"
  end

  context "when no topic is supplied" do
    let(:topic) { nil }
    it_behaves_like "not authorized"
  end
end
