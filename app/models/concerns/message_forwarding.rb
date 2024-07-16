module MessageForwarding

  extend ActiveSupport::Concern

  def forward_reading(device, reading)
    if device.forward_readings?
      MQTTForwardingJob.perform_later(device.id, reading)
    end
  end

end
