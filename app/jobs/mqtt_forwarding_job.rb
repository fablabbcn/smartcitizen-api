class MQTTForwardingJob < ApplicationJob

  queue_as :mqtt_forward

  def perform(device_id, data)
    readings = data[:readings]
    device = Device.find(device_id)
    begin
      forwarder = MQTTForwarder.new(mqtt_client)
      payload = payload_for(device, readings)
      forwarder.forward_readings(device.forwarding_token, device.id, payload)
    ensure
      disconnect_mqtt!
    end
  end

  private

  def payload_for(device, readings)
    Presenters.present(device, device.owner, nil, readings: readings)
  end

  def mqtt_client
    @mqtt_client ||= MQTTClientFactory.create_client({
      clean_session: true, client_id: nil
    })
  end

  def disconnect_mqtt!
    @mqtt_client&.disconnect
  end
end

