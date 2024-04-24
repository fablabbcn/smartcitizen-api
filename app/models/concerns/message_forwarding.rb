module MessageForwarding

  extend ActiveSupport::Concern

  def forward_reading(device, reading)
    forwarder = MQTTForwarder.new(mqtt_client)
    forwarder.forward_reading(device.forwarding_token, device.id, reading) if device.forward_readings?
  end

  private

  def mqtt_client
    raise NotImplementedError
  end
end
