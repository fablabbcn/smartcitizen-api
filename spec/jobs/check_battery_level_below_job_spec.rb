require 'rails_helper'

RSpec.describe CheckBatteryLevelBelowJob, type: :job do

  it 'should update notify_low_battery_timestamp and send email' do
    device = create(:device, notify_low_battery: true)

    time_before = device.notify_low_battery_timestamp
    device.update(data: { "10": '11'})

    expect(device.data["10"].to_i).to eq(11)

    CheckBatteryLevelBelowJob.perform_now

    device.reload
    expect(time_before).not_to eq(device.notify_low_battery_timestamp)
  end
end
