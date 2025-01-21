class MqttMessagesHandler

  def handle_topic(topic, message, retry_on_nil_device=true)
    return if topic.nil?
    message = message.encode("US-ASCII", invalid: :replace, undef: :replace, replace: "")
    log_message_to_sentry(topic, message)
    handshake_device(topic)

    if topic.to_s.include?('inventory')
      handle_inventory(message)
      return true
    else
      device = find_device_for_topic(topic, message, retry_on_nil_device)
      return nil if device.nil?
      with_device_error_handling(device, topic, message) do
        if topic.to_s.include?('raw')
          handle_readings(device, parse_raw_readings(message))
        elsif topic.to_s.include?('readings')
          handle_readings(device, message)
        elsif topic.to_s.include?('info')
          handle_info(device, message)
        else
          true
        end
      end
    end
  end

  private

  def handle_inventory(message)
    DeviceInventory.create({ report: (message rescue nil) })
    return true
  end

  def handle_readings(device, message)
    parsed = JSON.parse(message) if message
    data = parsed["data"] if parsed
    return nil if data.nil? or data&.empty?
    storer.store(device, data)
    return true
  rescue Exception => e
    Sentry.capture_exception(e)
    raise e if Rails.env.test?
  end

  def handle_info(device, message)
    json_message = JSON.parse(message)
    device.update_column(:hardware_info, json_message)
    return true
  end

  def parse_raw_readings(message)
    JSON[raw_readings_parser.parse(message)]
  end

  def handshake_device(topic)
    orphan_device = OrphanDevice.find_by(device_token: device_token(topic))
    return if orphan_device.nil?
    orphan_device.update!(device_handshake: true)
    Redis.current.publish('token-received',  {
      onboarding_session: orphan_device.onboarding_session
    }.to_json)
  end

  def log_message_to_sentry(topic, message)
    Sentry.set_tags('mqtt-topic': topic)
    crumb = Sentry::Breadcrumb.new(
      category: "MqttMessagesHandler.handle_topic",
      message: "Handling topic #{topic}",
      data: { topic: topic, message: message }
    )
    Sentry.add_breadcrumb(crumb)
  end

  def find_device_for_topic(topic, message, retry_on_nil_device)
    device = Device.find_by(device_token: device_token(topic))
    handle_nil_device(topic, message, retry_on_nil_device) if device.nil?
    return device
  end

  def handle_nil_device(topic, message, retry_on_nil_device)
    orphan_device = OrphanDevice.find_by_device_token(device_token(topic))
    if topic.to_s.include?("info") && !topic.to_s.include?("bridge") && orphan_device
      RetryMQTTMessageJob.perform_later(topic, message) if retry_on_nil_device
    end
  end

  def with_device_error_handling(device, topic, message, reraise=true, &block)
    begin
      block.call
    rescue Exception => e
      hardware_info = device.hardware_info
      Sentry.set_tags({
        "device-id": device.id,
        "device-hardware-version": hardware_info&.[]("hw_ver"),
        "device-esp-version": hardware_info&.[]("esp_ver"),
        "device-sam-version": hardware_info&.[]("sam_ver"),
      })
      Sentry.capture_exception(e)
      last_error = device.ingest_errors.order(created_at: :desc).first
      ingest_error = device.ingest_errors.create({
        topic: topic,
        message: message,
        error_class: e.class.name,
        error_message: e.message,
        error_trace: e.full_message
      })
      if send_device_error_warnings && (!last_error || last_error.created_at < device_error_warning_threshold)
        UserMailer.device_ingest_errors(device.id).deliver_later
      end
      raise e if reraise
    end
  end

  def send_device_error_warnings
    ENV.fetch("SEND_DEVICE_ERROR_WARNINGS", false)
  end

  def device_error_warning_threshold
    ENV.fetch("DEVICE_ERROR_WARNING_THRESHOLD_HOURS", "6").to_i.hours.ago
  end

  def device_token(topic)
    device_token = topic[/device\/sck\/(.*?)\//m, 1].to_s
  end

  def storer
    @storer ||= Storer.new
  end

  def raw_readings_parser
    @raw_readings_parser ||= RawMqttMessageParser.new
  end
end
