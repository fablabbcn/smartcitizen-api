# config/initializers/scheduler.rb
require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton


unless defined?(Rails::Console) || File.split($0).last == 'rake'
  # Only when NOT inside rake task or console

  s.every '1m' do
    # debug
    #Rails.logger.info "hello, it's #{Time.now}"
    #Rails.logger.flush
  end

  s.every '15m' do
    CheckBatteryLevelBelowJob.perform_later
    CheckDeviceStoppedPublishingJob.perform_later
  end

  s.every '1d' do
    CheckupUserEmailBlankJob.perform_later
    DeleteArchivedDevicesJob.perform_later
    DeleteArchivedUsersJob.perform_later
  end

end
