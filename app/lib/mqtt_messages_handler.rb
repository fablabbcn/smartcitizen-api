class MqttMessagesHandler
  def self.handle_topic(topic, message)
    return if topic.nil?

    # The following do NOT need a device
    if topic.to_s.include?('inventory')
      DeviceInventory.create({ report: (message rescue nil) })
    elsif topic.to_s.include?('hello')
      orphan_device = OrphanDevice.find_by(device_token: device_token(topic))
      return if orphan_device.nil?

      handle_hello(orphan_device)
    end

    device = Device.find_by(device_token: device_token(topic))
    return if device.nil?

    if topic.to_s.include?('raw')
      handle_readings(device, parse_raw_readings(message))
    elsif topic.to_s.include?('readings')
      handle_readings(device, message)
    elsif topic.to_s.include?('info')
      device.update hardware_info: JSON.parse(message)
    end
  end

  # takes a packet and stores data
  def self.handle_readings(device, message)
    data = self.data(message)
    return if data.nil? or data&.empty?

    data.each do |reading|
      Storer.new(device, reading)
    end
  rescue Exception => e
    Sentry.capture_exception(e)
    #puts e.inspect
    #puts message
  end

  # takes a raw packet and converts into JSON
  def self.parse_raw_readings(message)
    clean_tm = message[1..-2].split(",")[0].gsub("t:", "").strip
    raw_readings = message[1..-2].split(",")[1..]

    reading = { 'data' => ['recorded_at' => clean_tm, 'sensors' => []] }

    raw_readings.each do |raw_read|
      raw_id = raw_read.split(":")[0].strip
      raw_value = raw_read.split(":")[1]&.strip
      reading['data'].first['sensors'] << { 'id' => raw_id, 'value' => raw_value }
    end

    JSON[reading]
  end

  def self.handle_hello(orphan_device)
    payload = {}
    orphan_device.update(device_handshake: true)
    payload[:onboarding_session] = orphan_device.onboarding_session
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
      begin
        JSON.parse(message)['data']
      rescue JSON::ParserError
        # Handle error
      end
    else
      raise "No data(message)"
    end
  end
end
