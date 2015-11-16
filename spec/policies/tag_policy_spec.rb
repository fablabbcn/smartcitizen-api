require 'rails_helper'

describe TagPolicy do
  subject { TagPolicy.new(user, tag) }

  let(:tag) { FactoryGirl.create(:tag) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
    it { is_expected.to_not permitz(:destroy) }
  end

  context "for a user" do
    let(:user) { FactoryGirl.create(:user) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
    it { is_expected.to_not permitz(:destroy) }
  end

  context "for an admin" do
    let(:user) { FactoryGirl.create(:admin) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to permitz(:update) }
    it { is_expected.to permitz(:create) }
    it { is_expected.to permitz(:destroy) }
  end

end
