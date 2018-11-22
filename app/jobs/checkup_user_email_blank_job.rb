class CheckupUserEmailBlankJob < ApplicationJob
  queue_as :default

  def perform(*args)

    CheckupNotifyJob.perform_now("Check for blank emails ...")

    users = User.where(email: nil)
    CheckupNotifyJob.perform_now("No email for #{users.count} users. - ids: #{users.pluck(:id)}")

  end
end
