class CheckupNotifyJob < ApplicationJob
  queue_as :default

  def perform(errormsg)
    checkups_log = Logger.new('log/checkup.log')
    checkups_log.level = Logger::ERROR
    checkups_log.error(errormsg)
    # TODO: send us warnings on email / slack / grafana?
  end
end
