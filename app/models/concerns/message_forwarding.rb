module MessageForwarding

  extend ActiveSupport::Concern

  def forward_reading(device, reading)
    if device.forward_readings?
      forwarder = MQTTForwarder.new(mqtt_client)
      payload = payload_for(device, reading)
      forwarder.forward_reading(device.forwarding_token, device.id, payload)
    end
  end

  def payload_for(device, reading)
    renderer.render(
      partial: "v0/devices/device",
      locals: {
        device: device.reload,
        current_user: nil,
        slim_owner: true
      }
    )
  end

  private

  def mqtt_client
    raise NotImplementedError
  end

  def renderer
    raise NotImplementedError
  end
end
