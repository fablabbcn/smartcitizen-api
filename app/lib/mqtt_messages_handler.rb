class MqttMessagesHandler
  def self.handle(packet)
    topic = packet.topic
    message = packet.payload
    return if topic.nil?

    # handle_inventory is the only one that does NOT need a device
    if topic.to_s.include?('inventory')
      DeviceInventory.create({report: (message rescue nil)})
    end

    device = Device.find_by(device_token: self.device_token(topic))
    return if device.nil?

    if topic.to_s.include?('readings')
      self.handle_readings(device, message)
    elsif topic.to_s.include?('hello')
      self.handle_hello(device, message)
    elsif topic.to_s.include?('info')
      device.update hardware_info: JSON.parse(message)
    end
  end

  # takes a packet and stores data
  def self.handle_readings(device, message)
    data = self.data(message)
    data.each do |reading|
      Storer.new(device, reading)
    end
  rescue Exception => e
    Raven.capture_exception(e)
    #puts e.inspect
    #puts message
  end

  def self.handle_hello(device, message)
    payload = {}
    payload[:device_id] = device.id
    payload[:device_token] = device.device_token # TODO: remove after migration

    orphan_device = OrphanDevice.find_by(device_token: device.device_token)
    if orphan_device
      orphan_device.update(device_handshake: true)
      payload[:onboarding_session] = orphan_device.onboarding_session
    end

    Redis.current.publish('token-received', payload.to_json)
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
