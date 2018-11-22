class DeleteArchivedUsersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    CheckupNotifyJob.perform_now("Delete archived users")

    User.unscoped.where(workflow_state: "archived").each do |user|
      if user.created_at < 72.hours.ago
        CheckupNotifyJob.perform_now("deleting archived user #{user.id}")
        user.destroy!
      end
    end
  end
end
