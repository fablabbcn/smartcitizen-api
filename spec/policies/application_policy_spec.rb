require 'spec_helper'

describe ApplicationPolicy do
  subject { ApplicationPolicy.new(user, Device.new) }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to_not permitz(:index)    }
    it { is_expected.to_not permitz(:new)    }
    it { is_expected.to_not permitz(:show)    }
    it { is_expected.to_not permitz(:edit)    }
    it { is_expected.to_not permitz(:create)  }
    it { is_expected.to_not permitz(:update)  }
    it { is_expected.to_not permitz(:destroy) }
  end

end