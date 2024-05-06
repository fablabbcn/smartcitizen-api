class MqttMessagesHandler

  def initialize(mqtt_client)
    @mqtt_client = mqtt_client
  end

  def handle_topic(topic, message, retry_on_nil_device=true)
    Sentry.set_tags('mqtt-topic': topic)

    crumb = Sentry::Breadcrumb.new(
      category: "MqttMessagesHandler.handle_topic",
      message: "Handling topic #{topic}",
      data: { topic: topic, message: message.encode("UTF-8", invalid: :replace, undef: :replace) }
    )
    Sentry.add_breadcrumb(crumb)

    return if topic.nil?

    handshake_device(topic)

    # The following do NOT need a device
    if topic.to_s.include?('inventory')
      DeviceInventory.create({ report: (message rescue nil) })
      return true
    end

    device = Device.find_by(device_token: device_token(topic))
    if device.nil?
      handle_nil_device(topic, message, retry_on_nil_device)
      return nil
    end

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
          message: message.encode("UTF-8", invalid: :replace, undef: :replace),
          json: json_message,
          device_id: device.id
        }
      )
      Sentry.add_breadcrumb(crumb)
      device.update_column(:hardware_info, json_message)
    end
    return true
  end

  def handle_nil_device(topic, message, retry_on_nil_device)
    if !topic.to_s.include?("inventory")
      retry_later(topic, message) if retry_on_nil_device
    end
  end

  def retry_later(topic, message)
    RetryMQTTMessageJob.perform_later(topic, message)
  end

  # takes a packet and stores data
  def handle_readings(device, message)
    data = self.data(message)
    return if data.nil? or data&.empty?

    data.each do |reading|
      storer.store(device, reading)
    end
  rescue Exception => e
    Sentry.capture_exception(e)
    raise e if Rails.env.test?
    #puts e.inspect
    #puts message
  end

  # takes a raw packet and converts into JSON
  def parse_raw_readings(message, device_id=nil)
    crumb = Sentry::Breadcrumb.new(
      category: "MqttMessagesHandler.parse_raw_readings",
      message: "Parsing raw readings",
      data: { message: message.encode("UTF-8", invalid: :replace, undef: :replace), device_id: device_id }
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
      data: { message: message.encode("UTF-8", invalid: :replace, undef: :replace), reading: reading, device_id: device_id }
    )
    Sentry.add_breadcrumb(crumb)

    JSON[reading]
  end

  def handshake_device(topic)
    orphan_device = OrphanDevice.find_by(device_token: device_token(topic))
    return if orphan_device.nil?
    orphan_device.update!(device_handshake: true)
    Redis.current.publish('token-received',  {
      onboarding_session: orphan_device.onboarding_session
    }.to_json)
  end

  # takes a packet and returns 'device token' from topic
  def device_token(topic)
    topic[/device\/sck\/(.*?)\//m, 1].to_s
  end

  # takes a packet and returns 'data' from payload
  def data(message)
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


  private

  attr_reader :mqtt_client


  def storer
    @storer ||= Storer.new(mqtt_client, ActionController::Base.new.view_context)
  end
end
