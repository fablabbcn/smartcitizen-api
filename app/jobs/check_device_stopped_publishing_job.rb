class CheckDeviceStoppedPublishingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later

    devices = Device.where(notify_stopped_publishing: true).where("last_recorded_at < ?", 10.minutes.ago)
    CheckupNotifyJob.perform_now("Found #{devices.count} devices with enabled notification, who stopped publishing at least 10 minutes ago. Ids: #{device.pluck(:id)}")

    devices.each do |device|
      if device.notify_stopped_publishing_timestamp < 24.hours.ago
        device.update_attributes notify_stopped_publishing_timestamp: Time.now
        UserMailer.device_stopped_publishing(device.id).deliver_now
      end
    end

  end
end
