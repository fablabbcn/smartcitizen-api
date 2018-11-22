class CheckDeviceStoppedPublishingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later

    devices = Device.where("last_recorded_at < ?", 10.minutes.ago)
    CheckupNotifyJob.perform_now("Found #{devices.count} devices, who stopped publishing within 10 minutes..")
    devices.each do |d|
      # TODO: Send email notification?
      #p "#{d.id}"
    end

  end
end
