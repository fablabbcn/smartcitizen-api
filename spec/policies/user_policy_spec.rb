require 'spec_helper'

describe UserPolicy do
  subject { UserPolicy.new(user, usermodel) }

  let(:usermodel) { FactoryGirl.create(:user) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show) }
    it { is_expected.to permitz(:create) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:destroy) }
    it { is_expected.to permitz(:request_password_reset) }
    it { is_expected.to_not permitz(:update_password) }
  end

  context "for a user" do
    let(:user) { usermodel }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:create) }
    it { is_expected.to permitz(:update) }
    it { is_expected.to permitz(:destroy) }
    it { is_expected.to_not permitz(:request_password_reset) }
    it { is_expected.to permitz(:update_password) }
  end

end
