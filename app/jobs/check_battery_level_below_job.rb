class CheckBatteryLevelBelowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later

    CheckupNotifyJob.perform_now("About to check battery level on devices..")

    devices = Device.where.not(data: nil)
    CheckupNotifyJob.perform_now("About to check battery level on #{devices.count} devices..")

    devices.each do |d|
      if d.data["10"].present?
        # -1.0 means no battery connected
        if d.data["10"].to_i < 15 && d.data["10"].to_i > 1
          # TODO: Send email notification?
          CheckupNotifyJob.perform_now("Owner: #{d.owner} - device: #{d}")
        end
      end
    end

  end
end
