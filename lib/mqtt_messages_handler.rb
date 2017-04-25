class MqttMessagesHandler
  def self.handle(packet)
    handle_topic(packet.topic, packet.payload)
  end

  def self.handle_topic(topic, message)
    if topic.to_s.include?('readings')
      self.handle_readings(topic, message)
    else
      self.handle_hello(topic, message)
    end
  end

  # takes a packet and stores data
  def self.handle_readings(topic, message)
    device = Device.find_by(device_token: self.device_token(topic))
    raise 'device not found' if device.nil?

    data = self.data(message)
    data.each do |reading|
      Storer.new(device.id, reading)
    end
  rescue Exception => e
    Rails.logger.error(e.message)
    Rails.logger.error(message)
    Airbrake.notify(e, {payload: e.message + " - payload: " + message})
  end

  def self.handle_hello(topic, message)
    device_token = self.device_token(topic)
    Redis.current.publish('token-received', {
      device_token: device_token
    }.to_json)
  end

  # takes a packet and returns 'device token' from topic
  def self.device_token(topic)
    topic[/device\/sck\/(.*?)\//m, 1].to_s
  end

  # takes a packet and returns 'data' from payload
  def self.data(message)
    # TODO: what if message is empty?
    if message
      JSON.parse(message)['data']
    else
      raise "No data(message)"
    end
  end
end
