require 'rails_helper'

describe ComponentPolicy do
  subject { ComponentPolicy.new(user, component) }

  let(:component) { FactoryGirl.build(:component) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show) }
  end

  context "for a user" do
    let(:user) { FactoryGirl.build(:user) }
    it { is_expected.to permitz(:show) }
  end

  context "for an admin" do
    let(:user) { FactoryGirl.build(:admin) }
    it { is_expected.to permitz(:show) }
  end

end
