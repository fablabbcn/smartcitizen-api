class DeleteArchivedDevicesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Device.all will only look in non-archived devices because of scope
    Device.unscoped.each do |device|
      if device.archived?
        p "---- I will delete device #{device.id}"
        CheckupNotifyJob.perform_later("deleting archived device #{device.id}")
        device.destroy!
      end
    end
  end
end
