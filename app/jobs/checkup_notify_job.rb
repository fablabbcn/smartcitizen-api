class CheckupNotifyJob < ActiveJob::Base
  queue_as :default

  def perform(errormsg)
    # Now we only log to our own file to debug
    checkups_log = Logger.new('log/checkups.log')
    checkups_log.level = Logger::ERROR
    checkups_log.error(errormsg)
    # TODO: send us warnings on email / slack / grafana?

  end
end
