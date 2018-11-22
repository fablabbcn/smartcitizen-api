class CheckupNotifyJob < ApplicationJob
  queue_as :default

  def perform(msg)
    checkups_log = Logger.new('log/checkups.log')
    checkups_log.info(msg)
    # TODO: send us warnings on email / slack / grafana?
  end
end
