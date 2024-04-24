class MQTTForwarder
  def initialize(client, prefix="forward/devices", suffix="readings")
    @client = client
    @prefix = prefix
    @suffix = suffix
  end

  def forward_reading(token, device_id, reading)
    topic = topic_path(token, device_id)
    client.publish(topic, reading)
  end

  private

  def topic_path(token, device_id)
    [prefix, token, device_id, suffix].join("/")
  end

  attr_reader :client, :prefix, :suffix
end
