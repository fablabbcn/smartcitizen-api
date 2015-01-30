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

  it "can be initialized with existing token" do
    expect(create(:api_token, token: '1234').token).to eq('1234')
  end

  it "validates_uniqueness_of token" do
    create(:api_token, token: '459873478')
    expect(build_stubbed(:api_token, token: '459873478')).to be_invalid
  end

end
