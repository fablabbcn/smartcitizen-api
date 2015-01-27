require 'rails_helper'

RSpec.describe Device, :type => :model do
  it { is_expected.to belong_to(:owner) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:owner) }
  it { is_expected.to validate_presence_of(:mac_address) }

  it "validates mac address" do
    expect( build_stubbed(:device, mac_address: 123) ).to be_invalid
  end
end
