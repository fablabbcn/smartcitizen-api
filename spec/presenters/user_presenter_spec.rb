require "rails_helper"
describe Presenters::UserPresenter do

  let(:user) {
    FactoryBot.create(:user)
  }

  let(:current_user) {
    FactoryBot.create(:user)
  }

  let(:device_1) {
    FactoryBot.create(:device)
  }

  let(:device_2) {
    FactoryBot.create(:device)
  }

  let(:device_1_presentation) {
    double(:device_1_presentation)
  }

  let(:device_2_presentation) {
    double(:device_2_presentation)
  }

  let(:user) {
    FactoryBot.create(:user, devices: [device_1, device_2])
  }

  let(:profile_picture_url) {
    double(:profile_picture_url)
  }

  let(:render_context) {
    double(:render_context).tap do |render_context|
      allow(render_context).to receive(:profile_picture_url).and_return(profile_picture_url)
    end
  }

  let(:options) {
    {}
  }

  let(:show_private_info) do
    false
  end

  let(:user_policy) {
    double(:user_policy).tap do |user_policy|
      allow(user_policy).to receive(:show_private_info?).and_return(show_private_info)
    end
  }

  before do
    allow(UserPolicy).to receive(:new).and_return(user_policy)
    allow(Presenters).to receive(:present).and_return([device_1_presentation, device_2_presentation])
  end

  subject(:presenter) { Presenters::UserPresenter.new(user, current_user, render_context, options) }

  it "exposes the id" do
    expect(presenter.as_json[:id]).to eq(user.id)
  end

  it "exposes the uuid" do
    expect(presenter.as_json[:uuid]).to eq(user.uuid)
  end

  it "exposes the role" do
    expect(presenter.as_json[:role]).to eq(user.role)
  end

  it "exposes the username" do
    expect(presenter.as_json[:username]).to eq(user.username)
  end

  it "gets the profile_picture_url from the render_context" do
    expect(presenter.as_json[:profile_picture]).to eq(profile_picture_url)
    expect(render_context).to have_received(:profile_picture_url).with(user)
  end

  it "exposes the location" do
    expect(presenter.as_json[:location]).to eq(user.location)
  end

  it "exposes the created_at date" do expect(presenter.as_json[:created_at]).to eq(user.created_at)
  end

  it "exposes the updated_at date" do
    expect(presenter.as_json[:updated_at]).to eq(user.updated_at)
  end

  context "when the current user is not authorized" do
    it "does not show the email" do
      expect(presenter.as_json[:email]).to eq(nil)
    end

    it "includes the email field in the unauthorized_fields collection" do
      expect(presenter.as_json[:unauthorized_fields]).to include(:email)
    end

    it "does not show the legacy API key" do
      expect(presenter.as_json[:legacy_api_key]).to eq(nil)
    end

    it "includes the legacy API key field in the unauthorized fields collection" do
      expect(presenter.as_json[:unauthorized_fields]).to include(:legacy_api_key)
    end
  end

  context "when the current user is authorized" do
    let(:show_private_info) { true }

    it "shows the email" do
      expect(presenter.as_json[:email]).to eq(user.email)
    end

    it "shows the legacy API key" do
      expect(presenter.as_json[:legacy_api_key]).to eq(user.legacy_api_key)
    end

    it "does not include any unauthorized fields" do
      expect(presenter.as_json).not_to include(:unauthorized_fields)
    end
  end

  context "by default" do
    it "includes presentations of the user's devices" do

      expect(presenter.as_json[:devices]).to eq([device_1_presentation, device_2_presentation])
      expect(Presenters).to have_received(:present).with([device_1, device_2], current_user, render_context, options)
    end
  end

  context "when the with_devices option is false" do
    let(:options) { { with_devices: false }}

    it "does not include devices" do
      expect(presenter.as_json[:devices]).to eq(nil)
    end
  end
end
