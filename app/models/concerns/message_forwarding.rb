module MessageForwarding

  extend ActiveSupport::Concern

  def forward_readings(device, readings)
    if device.forward_readings?
      MQTTForwardingJob.perform_later(device.id, readings)
    end
  end

end
