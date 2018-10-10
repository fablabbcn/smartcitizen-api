class Storer
  include DataParser::Storer

  def initialize device, reading, do_update = true
    stored = true
    @device = device
    begin
      parsed_reading = Storer.parse_reading(@device, reading)

      #Kairos.http_post_to("/datapoints", parsed_reading[:_data])

      #NOTE: If you want to use the Telnet port below, make sure it is open!
      Redis.current.publish('telnet_queue', parsed_reading[:_data].to_json)

      update_device(parsed_reading[:parsed_ts], parsed_reading[:sql_data]) if do_update

      ts = parsed_reading[:ts]
      readings = parsed_reading[:readings]
    rescue Exception => e
      Raven.capture_exception(e)
      stored = false
    end

    redis_publish(readings, ts, stored)

    raise e unless e.nil?
  end

  def update_device(parsed_ts, sql_data)
    return unless parsed_ts > Time.at(0)
    # Next line fails if @device.last_recorded_at is nil
    #return if parsed_ts < @device.last_recorded_at
    sql_data = @device.data.present? ? @device.data.merge(sql_data) : sql_data
    @device.update_columns(last_recorded_at: parsed_ts, data: sql_data, state: 'has_published')
  end

  def redis_publish(readings, ts, stored)
    return unless Rails.env.production? and @device
    begin
      Redis.current.publish("data-received", {
        device_id: @device.id,
        device: JSON.parse(@device.to_json(only: [:id, :name, :location])),
        timestamp: ts,
        readings: readings,
        stored: stored,
        data: JSON.parse(ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: @device, current_user: nil}))
      }.to_json)
    rescue
    end
  end
end
