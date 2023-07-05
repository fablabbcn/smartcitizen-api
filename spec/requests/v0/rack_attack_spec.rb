require "rails_helper"

describe "throttle" do
  before(:each) do
    # Prevent throttle
    Rails.cache.clear
    Rack::Attack.enabled = true
    Rack::Attack.reset!
  end

  let(:limit) { ENV.fetch("THROTTLE_LIMIT", 150).to_i } # Should be the same as limit: in init/rack_attack

  shared_examples_for "does not throttle requests" do
    it "does not change the request status" do
      expect((0..n_requests).map {
        get "/", params: {}, headers: { "REMOTE_ADDR" => "1.2.3.4", "Authorization" => authorization_header }.compact
        response.status
      }.uniq).not_to include(429)
    end
  end

  shared_examples_for "throttles requests" do
    it "changes the request status to 429" do
      expect((0..n_requests).map {
        get "/", params: {}, headers: { "REMOTE_ADDR" => "1.2.3.4", "Authorization" => authorization_header }.compact
        response.status
      }.uniq).to include(429)
    end
  end

  let(:username) { "testuser" }
  let(:password) { "password1234" }
  let(:user) { nil }

  let(:authorization_header) {
    if user
      ActionController::HttpAuthentication::Basic.encode_credentials(
        username,
        password
      )
    end
  }

  context "no user is logged in" do
    context "number of requests is lower than the limit" do
      let(:n_requests) { limit - 1 }
      it_should_behave_like "does not throttle requests"
    end

    context "number of requests is higher than the limit" do
      let(:n_requests) { limit + 10 }
      it_should_behave_like "throttles requests"
    end
  end

  context "a user with role 'citizen' is logged in" do
    let(:user) {
      FactoryBot.create(:user, username: username, password: password)
    }

    context "number of requests is lower than the limit" do
      let(:n_requests) { limit - 1 }
      it_should_behave_like "does not throttle requests"
    end

    context "number of requests is higher than the limit" do
      let(:n_requests) { limit + 10 }
      it_should_behave_like "throttles requests"
    end
  end

  context "a user with role 'researcher' is logged in" do
    let(:user) {
      FactoryBot.create(:researcher, username: username, password: password)
    }

    context "number of requests is lower than the limit" do
      let(:n_requests) { limit - 1 }
      it_should_behave_like "does not throttle requests"
    end

    context "number of requests is higher than the limit" do
      let(:n_requests) { limit + 10 }
      it_should_behave_like "does not throttle requests"
    end
  end

  context "a user with role 'admin' is logged in" do
    let(:user) {
      FactoryBot.create(:admin, username: username, password: password)
    }

    context "number of requests is lower than the limit" do
      let(:n_requests) { limit - 1 }
      it_should_behave_like "does not throttle requests"
    end

    context "number of requests is higher than the limit" do
      let(:n_requests) { limit + 10 }
      it_should_behave_like "does not throttle requests"
    end
  end
end
