require 'spec_helper'

describe ReadingPolicy do
  subject { ReadingPolicy.new(user, reading) }

  let(:reading) { FactoryGirl.create(:reading) }

  skip "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show)    }
    it { is_expected.to permitz(:create)  }
  end

end