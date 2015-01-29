require 'rails_helper'

RSpec.describe Device, :type => :model do

  it { is_expected.to belong_to(:owner) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:owner) }
  it { is_expected.to validate_presence_of(:mac_address) }

  skip { is_expected.to validate_uniqueness_of(:mac_address) }

  let(:device) { create(:device) }

  skip "sensor_ids test"

  it "validates mac address" do
    expect( build_stubbed(:device, mac_address: 123) ).to be_invalid
  end

  skip "has readings, in latest first order" do
    reading1 = Reading.create(device_id: device.id, value: 20)
    sleep(0.001) # needed for cassandra timeuuid
    reading2 = Reading.create(device_id: device.id, value: 30)
    expect(device.readings).to eq([reading1, reading2])
  end

  context "with kit" do
    it "has the kit's sensors"
    it "has the kit's components"
  end

  context "without kit" do
    it "has its own sensors"
    it "has its own components"
  end

end
