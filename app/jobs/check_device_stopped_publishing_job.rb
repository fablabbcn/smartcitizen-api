class CheckDeviceStoppedPublishingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    CheckupNotifyJob.perform_now("About to check devices stopped publishing within 10 minutes..")

    Device.where.not(last_recorded_at: nil).each do |d|
      if d.last_recorded_at < (10.minutes.ago)
        # TODO: Send email notification?
      end

    end

  end
end
