require 'rails_helper'

describe MeasurementPolicy do
  subject { MeasurementPolicy.new(user, measurement) }

  let(:measurement) { FactoryBot.build(:measurement) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
  end

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to_not permitz(:update) }
    it { is_expected.to_not permitz(:create) }
  end

  context "for an admin" do
    let(:user) { FactoryBot.create(:admin) }
    it { is_expected.to permitz(:show) }
    it { is_expected.to permitz(:update) }
    it { is_expected.to permitz(:create) }
  end

end
