require 'rails_helper'

RSpec.describe DeleteArchivedDevicesJob, type: :job do
  describe "#perform_later" do
    ActiveJob::Base.queue_adapter = :test

    it "should have an enqueued job" do
      expect {
        DeleteArchivedDevicesJob.perform_later
      }.to have_enqueued_job
    end

    it "should delete all archived devices, archived_at at least 24 hours ago, or without an archived_at date" do
      deviceNormal = create(:device, name: "dontDeleteMe - not archived")
      deviceArchived = create(:device, name: "deleteMe")
      deviceArchivedToday = create(:device, name: "dontDeleteMe - archived today")
      deviceArchivedWithNullTime = create(:device, name: "deleteMe - null")
      deviceArchived.archive!
      deviceArchivedToday.archive!
      deviceArchivedWithNullTime.archive!
      deviceArchived.update!({archived_at: 2.days.ago})
      deviceArchivedWithNullTime.update!({archived_at: nil})
      expect {
        DeleteArchivedDevicesJob.perform_now
      }.to change(Device.unscoped, :count).by(-2)
      expect(Device.unscoped).to include(deviceNormal)
      expect(Device.unscoped).not_to include(deviceArchived)
      expect(Device.unscoped).to include(deviceArchivedToday)
      expect(Device.unscoped).not_to include(deviceArchivedWithNullTime)
    end
  end
end
