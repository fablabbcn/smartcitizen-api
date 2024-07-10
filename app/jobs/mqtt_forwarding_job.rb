class MQTTForwardingJob < ApplicationJob

  queue_as :mqtt_forward

  def perform(device_id, reading)
    begin
      device = Device.find(device_id)
      forwarder = MQTTForwarder.new(mqtt_client)
      payload = payload_for(device, reading)
      forwarder.forward_reading(device.forwarding_token, device.id, payload)
    ensure
      disconnect_mqtt!
    end
  end

  private

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

  def mqtt_client
    @mqtt_client ||= MQTTClientFactory.create_client({
      clean_session: true, client_id: nil
    })
  end

  def renderer
    @renderer ||= ActionController::Base.new.view_context
  end

  def disconnect_mqtt!
    @mqtt_client&.disconnect
  end
end

