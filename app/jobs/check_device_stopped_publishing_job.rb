class CheckDeviceStoppedPublishingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    CheckupNotifyJob.perform_now("Check devices stopped publishing within 10 minutes..")

    devices = Device.where("last_recorded_at < ?", 10.minutes.ago)
    CheckupNotifyJob.perform_now("Found #{devices.count} devices")
    devices.each do |d|
      # TODO: Send email notification?
      #p "#{d.id}"
    end

  end
end
