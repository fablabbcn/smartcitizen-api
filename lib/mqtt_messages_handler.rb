class MqttMessagesHandler
  def self.handle(packet)
    if packet.topic.to_s.include?('readings')
      self.handle_readings(packet)
    else
      self.handle_hello(packet)
    end
  end

  # takes a packet and stores data
  def self.handle_readings(packet)
    device = Device.find_by(device_token: self.device_token(packet))

    raise 'device not found' if device.nil?

    self.data(packet).each do |reading|
      Storer.new(device.id, reading)
    end
  rescue Exception => e
    Rails.logger.error("Error storing device data")
    Rails.logger.error(e.message)
    Airbrake.notify(e, e.message + " - payload: " + packet.payload)
  end

  def self.handle_hello(packet)
    Redis.current.publish('token_received', {
      device_token: self.device_token(packet)
    }.to_json)
  end

  # takes a packet and returns 'device token' from topic
  def self.device_token(packet)
    packet.topic[/device\/sck\/(.*?)\//m, 1].to_s
  end

  # takes a packet and returns 'data' from payload
  def self.data(packet)
    JSON.parse(packet.payload)['data']
  end
end
