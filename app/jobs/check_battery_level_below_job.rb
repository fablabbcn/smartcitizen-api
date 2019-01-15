class CheckBatteryLevelBelowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later

    devices = Device.where.not(data: nil)
    CheckupNotifyJob.perform_now("Check battery level on #{devices.count} devices..")

    devices.each do |device|
      if device.data["10"].present?
        # -1.0 means no battery connected
        if device.data["10"].to_i < 15 && device.data["10"].to_i > 1
          # TODO: Send email notification?
          #p "Email: #{device.owner.email} - device: #{device}"
          #
          # device.notify_stopped_publishing
          #
          # device.notify_low_battery
        end
      end
    end

  end
end
