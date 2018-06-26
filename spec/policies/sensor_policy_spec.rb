require 'rails_helper'

describe SensorPolicy do
  subject { SensorPolicy.new(user, sensor) }

  let(:sensor) { FactoryBot.build(:sensor) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
    it { is_expected.to_not permitz(:destroy) }
  end

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
    it { is_expected.to_not permitz(:destroy) }
  end

  context "for an admin" do
    let(:user) { FactoryBot.create(:admin) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to permitz(:update) }
    it { is_expected.to permitz(:create) }
    it { is_expected.to permitz(:destroy) }
  end

end
