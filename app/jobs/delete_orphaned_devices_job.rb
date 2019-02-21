class DeleteOrphanedDevicesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    CheckupNotifyJob.perform_now("Delete old orphan devices")

    OrphanDevice.all.each do |device|
      if device.updated_at < 7.days.ago
        CheckupNotifyJob.perform_now("deleting old orphan device #{device.id}")
        device.destroy!
      end
    end
  end
end
