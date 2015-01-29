require 'rails_helper'

RSpec.describe Reading, :type => :model do

  it "needs more specs"

  skip "should belong to device" do
    device = create(:device)
    expect(Reading.create(device_id: device.id, value: 10).device).to eq(device)
  end

end
