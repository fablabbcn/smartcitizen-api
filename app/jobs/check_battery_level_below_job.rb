class CheckBatteryLevelBelowJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Do something later

    checkups_log = Logger.new('log/devicebattery.log')
    checkups_log.level = Logger::INFO
    checkups_log.info('----------')

    Device.all.each do |d|

      if d.data.present? && d.data["10"].present?
        # -1.0 means no battery connected
        if d.data["10"].to_i < 15 && d.data["10"].to_i > 1
          checkups_log.info(d.data["10"])
          # Send email notification
        end
      end

    end
  end
end
