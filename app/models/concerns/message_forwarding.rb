module MessageForwarding

  extend ActiveSupport::Concern

  def forward_reading(device, reading)
    forwarder.forward_reading(device, reading) if device.forward_readings?
  end

  private

  def forwarder
    @mqtt_forwarder ||= MQTTForwarder.new
  end
end
