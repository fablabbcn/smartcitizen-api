class CheckBatteryLevelBelowJob < ApplicationJob
  queue_as :default

  def perform(*args)

    # If user has allowed us to send him notifications
    devices = Device.where(notify_low_battery: true).where.not(data: nil)
    CheckupNotifyJob.perform_now("Check battery level on #{devices.count} devices..")

    devices.each do |device|
      #if device.notify_low_battery_timestamp < 1.day.ago
      if device.notify_low_battery_timestamp < 12.hours.ago
        # data["10"] is battery
        if device.data["10"].present?
          # -1.0 means no battery connected
          if device.data["10"].to_i < 15 && device.data["10"].to_i > 1
            #p "Sending email to: #{device.owner.email} - device: #{device}"

            device.update_attributes notify_low_battery_timestamp: Time.now

            UserMailer.device_battery_low(device.id).deliver_now
          end
        end
      end
    end

  end
end
