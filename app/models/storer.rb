class Storer
  include DataParser::Storer

  def initialize device, reading, do_update = true
    @device = device
    begin
      parsed_reading = Storer.parse_reading(@device, reading)

      kairos_publish(parsed_reading[:_data])

      update_device(parsed_reading[:parsed_ts], parsed_reading[:sql_data]) if do_update

    rescue Exception => e
      Sentry.capture_exception(e)
    end

    raise e unless e.nil?
  end

  def update_device(parsed_ts, sql_data)
    return if parsed_ts <= Time.at(0)

    if @device.last_recorded_at.present?
      # Comparison errors if @device.last_recorded_at is nil (new devices).
      # Devices can post multiple readings, in a non-sorted order.
      # Do not update data with an older timestamp.
      return if parsed_ts < @device.last_recorded_at
    end

    sql_data = @device.data.present? ? @device.data.merge(sql_data) : sql_data
    @device.update_columns(last_recorded_at: parsed_ts, data: sql_data, state: 'has_published')
    ws_publish()
  end

  def kairos_publish(reading_data)
    #Kairos.http_post_to("/datapoints", reading_data)
    #NOTE: If you want to use the Telnet port below, make sure it is open!
    Redis.current.publish('telnet_queue', reading_data.to_json)
  end

  def ws_publish()
    return if Rails.env.test? or @device.blank?
    begin
      Redis.current.publish("data-received", ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: @device, current_user: nil}))
    rescue
    end
  end
end
