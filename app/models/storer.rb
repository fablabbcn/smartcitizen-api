class Storer
  include DataParser::Storer
  include MessageForwarding

  def store device, readings
    readings_to_forward = []
    readings.sort_by {|a| a['recorded_at']}.reverse.each_with_index do |reading, index|
      begin
        parsed_reading = Storer.parse_reading(device, reading)
        kairos_publish(parsed_reading[:_data])
        readings_to_forward << parsed_reading[:sql_data]
        if index == 0
          update_device(device, parsed_reading[:parsed_ts], parsed_reading[:sql_data])
        end


      rescue Exception => e
        Sentry.capture_exception(e)
        raise e if Rails.env.test?
      end
    end
    forward_readings(device, readings_to_forward)
  end

  def update_device(device, parsed_ts, sql_data)
    return if parsed_ts <= Time.at(0)
    device.transaction do
      device.lock!
      if device.reload.last_reading_at.present?
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
  end

  def kairos_publish(reading_data)
    #Kairos.http_post_to("/datapoints", reading_data)
    #NOTE: If you want to use the Telnet port below, make sure it is open!
    Redis.current.publish('telnet_queue', reading_data.to_json)
  end
end
