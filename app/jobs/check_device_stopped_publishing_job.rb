class CheckDeviceStoppedPublishingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later

    devices = Device.where(notify_stopped_publishing: true).where("last_recorded_at < ?", 60.minutes.ago)
    CheckupNotifyJob.perform_now("#{devices.count} devices with notification on: stopped_publishing at least an hour ago. Ids: #{devices.pluck(:id)}")

    devices.each do |device|
      if device.notify_stopped_publishing_timestamp < 24.hours.ago
        device.update notify_stopped_publishing_timestamp: Time.now
        UserMailer.device_stopped_publishing(device.id).deliver_now
      end
    end

  end
end
