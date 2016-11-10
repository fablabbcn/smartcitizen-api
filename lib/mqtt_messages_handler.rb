class MqttMessagesHandler
  def self.read(packet)
    if packet.topic.to_s.include?('readings')
      self.readings(packet)
    else
      self.hello(packet)
    end
  end

  # takes a packet and stores data
  def self.readings(packet)
    device = Device.find_by(device_token: self.device_token(packet))

    raise 'device not found' if device.nil?

    self.data(packet).each do |reading|
      Storer.new(device.id, reading)
    end
  rescue Exception => e
    Airbrake.notify(e)
  end

  def self.hello(packet)
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
