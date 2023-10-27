class MqttMessagesHandler
  def self.handle_topic(topic, message)
    crumb = Sentry::Breadcrumb.new(
      category: "MqttMessagesHandler.handle_topic",
      message: "Handling topic #{topic}",
      data: { topic: topic, message: message.scrub }
    )
    Sentry.add_breadcrumb(crumb)

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
      handle_readings(device, parse_raw_readings(message, device.id))
    elsif topic.to_s.include?('readings')
      handle_readings(device, message)
    elsif topic.to_s.include?('info')
      json_message = JSON.parse(message)
      crumb = Sentry::Breadcrumb.new(
        category: "MqttMessagesHandler.handle_topic",
        message: "Parsing info message",
        data: {
          topic: topic,
          message: message.scrub,
          json: json_message,
          device_id: device.id
        }
      )
      Sentry.add_breadcrumb(crumb)
      device.update hardware_info: json_message
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
  def self.parse_raw_readings(message, device_id=nil)
    crumb = Sentry::Breadcrumb.new(
      category: "MqttMessagesHandler.parse_raw_readings",
      message: "Parsing raw readings",
      data: { message: message.scrub, device_id: device_id }
    )
    Sentry.add_breadcrumb(crumb)
    clean_tm = message[1..-2].split(",")[0].gsub("t:", "").strip
    raw_readings = message[1..-2].split(",")[1..]

    reading = { 'data' => ['recorded_at' => clean_tm, 'sensors' => []] }

    raw_readings.each do |raw_read|
      raw_id = raw_read.split(":")[0].strip
      raw_value = raw_read.split(":")[1]&.strip
      reading['data'].first['sensors'] << { 'id' => raw_id, 'value' => raw_value }
    end

    crumb = Sentry::Breadcrumb.new(
      category: "MqttMessagesHandler.parse_raw_readings",
      message: "Readings data constructed",
      data: { message: message.scrub, reading: reading, device_id: device_id }
    )
    Sentry.add_breadcrumb(crumb)

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
