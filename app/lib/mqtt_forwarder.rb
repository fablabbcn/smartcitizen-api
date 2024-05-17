class MQTTForwarder
  def initialize(client = nil, renderer=nil)
    @client = client
    @renderer = renderer || ActionController::Base.new.view_context
  end

  def forward_reading(device, reading)
    token = device.forwarding_token
    device_id = device.id
    topic = topic_path(token, device_id)
    payload = payload_for(device, reading)
    with_client do |client|
      client.publish(topic, payload)
    end
  end

  private

  attr_reader :renderer

  def with_client(&block)
    if @client
      block.call(@client)
    else
      MQTTClientFactory.create_client({clean_session: true, client_id: nil }) do |client|
        block.call(client)
      end
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

  def topic_path(token, device_id)
    ["/forward", token, "device", device_id, "readings"].join("/")
  end
end
