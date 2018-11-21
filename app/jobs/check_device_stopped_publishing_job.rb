class CheckDeviceStoppedPublishingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    Device.all.each do |d|

      if d.last_recorded_at? && d.last_recorded_at < (10.minutes.ago)
        # TODO: Send email notification?
      end

    end

  end
end
