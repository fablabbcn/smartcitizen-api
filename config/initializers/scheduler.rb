# config/initializers/scheduler.rb
require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton


# Only when NOT inside rake task or console
return if defined?(Rails::Console) || Rails.env.development? || Rails.env.test? || File.split($0).last == 'rake'


s.every '1m' do
  # debug
  #Rails.logger.info "hello, it's #{Time.now}"
  #Rails.logger.flush
end

s.every '1h' do
  CheckBatteryLevelBelowJob.perform_later
  CheckDeviceStoppedPublishingJob.perform_later
end

s.every '1d' do
  CheckupUserEmailBlankJob.perform_later
  DeleteArchivedDevicesJob.perform_later
  DeleteArchivedUsersJob.perform_later
  DeleteOrphanedDevicesJob.perform_later
end
