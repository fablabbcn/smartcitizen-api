class DeleteArchivedDevicesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Device.all will only look in non-archived devices because of scope
    CheckupNotifyJob.perform_now("About to delete archived devices")

    Device.unscoped.where(workflow_state: "archived").each do |device|
      if device.created_at < 24.hours.ago
        CheckupNotifyJob.perform_now("deleting archived device #{device.id}")
        device.destroy!
      end
    end
  end
end
