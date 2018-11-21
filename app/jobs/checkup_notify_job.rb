class CheckupNotifyJob < ApplicationJob
  queue_as :default

  def perform(errormsg)
    # TODO: send us warnings on email / slack / grafana?
  end
end
