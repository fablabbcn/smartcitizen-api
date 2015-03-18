require 'spec_helper'

describe DevicePolicy do
  subject { DevicePolicy.new(user, device) }

  let(:device) { FactoryGirl.create(:device) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show)    }
    it { is_expected.to_not permitz(:create)  }
    it { is_expected.to_not permitz(:update)  }
    it { is_expected.to_not permitz(:destroy) }
  end

  context "for a device owner" do

    let(:user) { FactoryGirl.create(:user) }
    let(:device) { FactoryGirl.create(:device, owner: user) }

    it { is_expected.to permitz(:show)    }
    it { is_expected.to permitz(:create)  }
    it { is_expected.to permitz(:update)  }
    it { is_expected.to_not permitz(:destroy) }
  end

  skip "for an admin" do
    it { is_expected.to permitz(:show)    }
    it { is_expected.to permitz(:create)  }
    it { is_expected.to permitz(:update)  }
    it { is_expected.to permitz(:destroy) }
  end

end