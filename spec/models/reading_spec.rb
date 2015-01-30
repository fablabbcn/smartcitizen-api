require 'rails_helper'

RSpec.describe Reading, :type => :model do

  let(:device) { create(:device) }

  it "needs more specs"

  it "id should be device_id:recorded_at:created_at"

  it "should belong_to device" do
    reading = Reading.create(device_id: device.id, values: {'10': '12'})
    expect( reading.device ).to eq(device)
    expect( device.readings.first ).to eq(reading)
  end

  it "updates latest_data on its device" do
    data = { '1': '12.10', '2': '33.40' }.stringify_keys
    Reading.create(device: device, values: data)
    device.reload
    expect(device.latest_data).to eq(data)
  end

end
