class ReadingsHandler
  def self.timestamp_parse(timestamp)
    parsed_ts = Time.parse(timestamp)
    raise "timestamp error" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
    {
      parsed: parsed_ts,
      ts: parsed_ts.to_i * 1000
    }
  end

  def self.redis_publish(device, readings, ts, stored)
    return unless Rails.env.production? and device
    begin
      Redis.current.publish("data-received", {
        device_id: device.id,
        device: JSON.parse(device.to_json(only: [:id, :name, :location])),
        timestamp: ts,
        readings: readings,
        stored: stored,
        data: JSON.parse(ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: @device, current_user: nil}))
      }.to_json)
    rescue
    end
  end

  def self.update_device(device, parsed_ts, sql_data)
    return unless parsed_ts > (device.last_recorded_at || Time.at(0))
    device.update_columns(last_recorded_at: parsed_ts, data: sql_data, state: 'has_published')
  end
end
