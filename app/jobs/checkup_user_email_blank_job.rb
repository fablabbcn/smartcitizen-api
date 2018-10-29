class CheckupUserEmailBlankJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

    User.all.each do |user|
      if user.email.blank?
        CheckupNotifyJob.perform_later("No email for user id #{user.id}")
      end
    end

  end
end
