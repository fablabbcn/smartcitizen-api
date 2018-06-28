class DeleteArchivedUsersJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Do something later
    User.unscoped.each do |user|
      if user.archived?
        CheckupNotifyJob.perform_later("deleting archived user #{user.id}")
        user.destroy!
      end
    end
  end
end
