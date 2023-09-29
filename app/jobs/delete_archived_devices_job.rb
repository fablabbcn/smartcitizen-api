class DeleteArchivedDevicesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Device.all will only look in non-archived devices because of scope
    CheckupNotifyJob.perform_now("Delete archived devices")

    Device.unscoped.where(workflow_state: "archived").each do |device|
      if !device.archived_at || device.archived_at < 24.hours.ago
        CheckupNotifyJob.perform_now("deleting archived device #{device.id}")
        device.destroy!
      end
    end
  end
end
