class Storer
  include DataParser::Storer
  include MessageForwarding

  def initialize(mqtt_client, renderer)
    @mqtt_client = mqtt_client
    @renderer = renderer
  end

  def store device, reading, do_update = true
    begin
      parsed_reading = Storer.parse_reading(device, reading)
      kairos_publish(parsed_reading[:_data])

      if do_update
        update_device(device, parsed_reading[:parsed_ts], parsed_reading[:sql_data])
        ws_publish(device)
      end

      forward_reading(device, reading)

    rescue Exception => e
      Sentry.capture_exception(e)
      raise e if Rails.env.test?
    end

    raise e unless e.nil?
  end

  def update_device(device, parsed_ts, sql_data)
    return if parsed_ts <= Time.at(0)

    if device.last_reading_at.present?
      # Comparison errors if device.last_reading_at is nil (new devices).
      # Devices can post multiple readings, in a non-sorted order.
      # Do not update data with an older timestamp.
      return if parsed_ts < device.last_reading_at
    end

    sql_data = device.data.present? ? device.data.merge(sql_data) : sql_data
    device.update_columns(last_reading_at: parsed_ts, data: sql_data, state: 'has_published')
    sensor_ids = sql_data.select { |k, v| k.is_a?(Integer) }.keys.compact.uniq
    device.update_component_timestamps(parsed_ts, sensor_ids)
  end

  def kairos_publish(reading_data)
    #Kairos.http_post_to("/datapoints", reading_data)
    #NOTE: If you want to use the Telnet port below, make sure it is open!
    Redis.current.publish('telnet_queue', reading_data.to_json)
  end

  def ws_publish(device)
    return if Rails.env.test? or device.blank?
    begin
      Redis.current.publish("data-received", renderer.render( partial: "v0/devices/device", locals: {device: device, current_user: nil}))
    rescue
    end
  end

  private

  attr_reader :mqtt_client, :renderer

end
