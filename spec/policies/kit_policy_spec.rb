require 'rails_helper'

describe KitPolicy do
  subject { KitPolicy.new(user, kit) }

  let(:kit) { FactoryGirl.create(:kit) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
  end

  context "for a user" do
    let(:user) { FactoryGirl.create(:user) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
  end

  context "for an admin" do
    let(:user) { FactoryGirl.create(:admin) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to permitz(:update) }
    it { is_expected.to permitz(:create) }
  end

end
