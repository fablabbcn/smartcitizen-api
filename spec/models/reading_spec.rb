require 'rails_helper'

RSpec.describe Reading, :type => :model do

  let(:device) { create(:device) }

  it "needs more specs"

  it "has recorded_month" do
    expect(create(:reading, recorded_at: "05/02/2015 19:30:00").recorded_month).to eq(201502)
  end

  skip "id has device_id:recorded_at:created_at"

  it "belongs to device" do
    device = create(:device)
    reading = Reading.new(device_id: device.id)
    expect(reading.device).to eq(device)
  end

  skip "updates latest_data on its device"

end
