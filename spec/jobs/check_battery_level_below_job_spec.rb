require 'rails_helper'

RSpec.describe CheckBatteryLevelBelowJob, type: :job do

  it 'should update notify_low_battery_timestamp and send email' do
    device = create(:device, notify_low_battery: true, updated_at: "2023-01-01 00:00:00")
    updated_at_before = device.updated_at
    time_before = device.notify_low_battery_timestamp
    device.update_columns(data: { "10": '11'})

    expect(device.data["10"].to_i).to eq(11)

    CheckBatteryLevelBelowJob.perform_now

    device.reload
    expect(time_before).not_to eq(device.notify_low_battery_timestamp)
    expect(device.updated_at).to eq(updated_at_before)
  end
end
