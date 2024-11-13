class MQTTForwarder
  def initialize(client)
    @client = client
    @prefix = prefix
    @suffix = suffix
  end

  def forward_readings(token, device_id, reading)
    topic = topic_path(token, device_id)
    client.publish(topic, reading)
  end

  private

  def topic_path(token, device_id)
    ["/forward", token, "device", device_id, "readings"].join("/")
  end

  attr_reader :client, :prefix, :suffix
end
