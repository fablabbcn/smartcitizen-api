require 'rails_helper'

RSpec.describe DeleteOrphanedDevicesJob, type: :job do

  describe "#perform_later" do
    ActiveJob::Base.queue_adapter = :test

    it "should have an enqueued job" do
      expect {
        DeleteArchivedUsersJob.perform_later
      }.to have_enqueued_job
    end

    it "should delete all orphaned devices, older than 24 hours" do
      orp = create(:orphan_device, name: "dontDeleteMe", device_token: '123460', updated_at: 1.days.ago)
      orp = create(:orphan_device, name: "dontDeleteMe", device_token: '123457', updated_at: 8.days.ago)
      orp = create(:orphan_device, name: "dontDeleteMe", device_token: '123458', updated_at: 9.days.ago)

      expect(OrphanDevice.count).to eq 3

      expect {
        DeleteOrphanedDevicesJob.perform_now
      }.to change(OrphanDevice, :count).by(-2)

      expect(OrphanDevice.count).to eq 1
    end
  end

end
