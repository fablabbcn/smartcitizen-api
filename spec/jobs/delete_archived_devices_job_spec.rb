require 'rails_helper'

RSpec.describe DeleteArchivedDevicesJob, type: :job do
  describe "#perform_later" do
    ActiveJob::Base.queue_adapter = :test

    it "should have an enqueued job" do
      expect {
        DeleteArchivedDevicesJob.perform_later
      }.to have_enqueued_job
    end

    it "should delete all archived devices, created_at at least 24 hours ago" do
      deviceNormal = create(:device, name: "dontDeleteMe")
      deviceArchived = create(:device, name: "deleteMe", workflow_state: "archived", created_at: 10.days.ago)
      deviceArchivedToday = create(:device, name: "dontDeleteMe", workflow_state: "archived")
      expect {
        DeleteArchivedDevicesJob.perform_now
      }.to change(Device.unscoped, :count).by(-1)
    end
  end
end
