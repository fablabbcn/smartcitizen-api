require 'spec_helper'

describe KitPolicy do
  subject { KitPolicy.new(user, kit) }

  let(:kit) { FactoryGirl.create(:kit) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show)    }
  end

end