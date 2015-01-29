require 'rails_helper'

RSpec.describe ApiToken, :type => :model do

  it { is_expected.to belong_to :owner }
  it { is_expected.to validate_presence_of :owner }

  it "should generate token" do
    user = create(:user)
    expect(ApiToken.create(owner: user).token).to be_present
  end

  it "has to_s" do
    expect(build_stubbed(:api_token, token: '123').to_s).to eq('123')
  end

end
