require 'rails_helper'

RSpec.describe DeleteArchivedDevicesJob, type: :job do
  describe "#perform_later" do
    ActiveJob::Base.queue_adapter = :test

    it "should have an enqueued job" do
      expect {
        DeleteArchivedDevicesJob.perform_later
      }.to have_enqueued_job
    end

    it "should delete all archived devices, archived_at at least 24 hours ago" do
      deviceNormal = create(:device, name: "dontDeleteMe", created_at: 6.weeks.ago, components: [create(:component)])
      deviceArchived = create(:device, name: "deleteMe", created_at: 1.month.ago, components: [create(:component)])
      deviceArchivedNullArchivedAt = create(:device, name: "dontdeleteMe", created_at: 1.month.ago, components: [create(:component)])
      deviceArchivedToday = create(:device, name: "dontDeleteMe", created_at: 2.months.ago, components: [create(:component)])
      deviceArchived.archive!
      deviceArchivedNullArchivedAt.archive!
      deviceArchivedNullArchivedAt.archived_at = nil # A data inconsistency preseent in production that causes the job to fail
      deviceArchivedNullArchivedAt.save!
      deviceArchivedToday.archive!
      deviceArchived.update!({archived_at: 2.days.ago})
      expect {
        DeleteArchivedDevicesJob.perform_now
      }.to change(Device.unscoped, :count).by(-1)
      expect(Device.unscoped).to include(deviceNormal)
      expect(Device.unscoped).not_to include(deviceArchived)
      expect(Device.unscoped).to include(deviceArchivedToday)
      expect(Device.unscoped).to include(deviceArchivedNullArchivedAt)
    end
  end
end
