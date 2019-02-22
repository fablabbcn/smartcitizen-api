class MqttMessagesHandler
  def self.handle(packet)
    handle_topic(packet.topic, packet.payload)
  end

  def self.handle_topic(topic, message)
    if topic.to_s.include?('readings')
      self.handle_readings(topic, message)
    elsif topic.to_s.include?('hello')
      self.handle_hello(topic, message)
    elsif topic.to_s.include?('info')
      self.handle_hardware_info(topic, message)
    else
      self.handle_inventory(topic, message)
    end
  end

  # takes a packet and stores data
  def self.handle_readings(topic, message)
    device = Device.find_by(device_token: self.device_token(topic))
    raise "device not found #{topic}" if device.nil?

    data = self.data(message)
    data.each do |reading|
      Storer.new(device, reading)
    end
  rescue Exception => e
    Rails.logger.error(e.message)
    Rails.logger.error(message)
    #Airbrake.notify(e, {payload: e.message + " - payload: " + message})
  end

  def self.handle_hello(topic, message)
    payload = {}
    device_token = self.device_token(topic)

    return if device_token.blank?

    device = Device.find_by(device_token: device_token)
    if device.present?
      payload[:device_id] = device.id
    end

    payload[:device_token] = device_token # TODO: remove after migration

    orphan_device = OrphanDevice.find_by(device_token: device_token)
    if orphan_device
      orphan_device.update(device_handshake: true)
      payload[:onboarding_session] = orphan_device.onboarding_session
    end

    Redis.current.publish('token-received', payload.to_json)
  end

  def self.handle_hardware_info(topic, message)
    device_token = self.device_token(topic)
    dev = Device.where(device_token: device_token).first
    dev.update_attributes hardware_info: JSON.parse(message)
  end

  def self.handle_inventory(topic, message)
    DeviceInventory.create({report: (message rescue nil)})
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
