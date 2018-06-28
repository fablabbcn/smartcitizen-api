require 'rails_helper'

RSpec.describe DeleteArchivedUsersJob, type: :job do
  describe "#perform_later" do
    ActiveJob::Base.queue_adapter = :test

    it "should have an enqueued job" do
      expect {
        DeleteArchivedUsersJob.perform_later
      }.to have_enqueued_job
    end

    it "should delete all archived users, created_at at least 72 hours ago" do
      userNormal = create(:user, username: "normalUser")
      userArchived = create(:user, username: "dontDeleteMe", workflow_state: "archived", created_at: 71.hours.ago)
      userArchived = create(:user, username: "deleteMe1", workflow_state: "archived", created_at: 73.hours.ago)
      userArchived = create(:user, username: "deleteMe2", workflow_state: "archived", created_at: 74.hours.ago)
      expect {
        DeleteArchivedUsersJob.perform_now
      }.to change(User.unscoped, :count).by(-2)
    end
  end

end
