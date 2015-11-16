require 'rails_helper'

describe PasswordResetPolicy do
  subject { PasswordResetPolicy.new(user, password_reset) }

  let(:password_reset) { FactoryGirl.create(:user, password_reset_token: '12345') }

  context "for a visitor" do
    let(:user) { nil }
    it { is_expected.to permitz(:show)  }
    it { is_expected.to_not permitz(:create)  }
    it { is_expected.to_not permitz(:update)  }
  end

  context "for a general user" do
    let(:user) { FactoryGirl.create(:user) }
    it { is_expected.to permitz(:show)  }
    it { is_expected.to permitz(:create)  }
    it { is_expected.to_not permitz(:update)  }
  end

  context "for the requesting user" do
    let(:user) { password_reset }
    it { is_expected.to permitz(:show)  }
    it { is_expected.to permitz(:create)  }
    it { is_expected.to permitz(:update)  }
  end

end
