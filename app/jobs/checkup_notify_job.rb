class CheckupNotifyJob < ApplicationJob
  queue_as :default

  def perform(msg)
    checkups_log = Logger.new('log/checkups.log', 2, 10.megabytes)
    checkups_log.info(msg)
    # TODO: send us warnings on email / slack / grafana?
  end
end
