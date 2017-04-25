# Like app/models/kairos.rb, this class needs to be refactored and moved into
# /lib or /app/workers. It is called asynchronously by sidekiq and is used to
# ingest raw data posted by Devices into Kairos and Postgres (backup purposes).

class RawStorer

  def initialize data, mac, version, ip

    success = true

    begin

      readings = {}

      mac = mac.downcase.strip
      device = Device.includes(:components).where(mac_address: mac).last

      identifier = version.split('-').first

      device.set_version_if_required!(identifier)

      ts = data['timestamp'] || data[:timestamp]
      parsed_ts = Time.parse(ts)
      raise "timestamp error (raw)" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
      ts = parsed_ts.to_i * 1000

      _data = []
      sql_data = {"" => parsed_ts}

      data.select{ |k,v| device.sensor_keys.include?(k.to_s) }.each do |sensor, value|
        metric = sensor

        metric_id = device.find_sensor_id_by_key(metric)
        component = device.components.detect{|c|c["sensor_id"] == metric_id} #find_component_by_sensor_id(metric_id)

        value = component.normalized_value( (Float(value) rescue value) )
        # puts "\t#{metric} #{ts} #{value} device=#{device.id} identifier=#{identifier}"

        sql_data["#{metric_id}_raw"] = value
        sql_data[metric_id] = component.calibrated_value(value)

        _data.push({
          name: metric,
          timestamp: ts,
          value: value,
          tags: {
            device_id: device.id,
            identifier: "sck#{identifier}"
          }
        })

        readings[sensor] = [metric_id, value, sql_data[metric_id]]
      end

      Kairos.http_post_to("/datapoints", _data)

      if parsed_ts > (device.last_recorded_at || Time.at(0))
        # update without touching updated_at
        device.update_columns(last_recorded_at: parsed_ts, data: sql_data, state: 'has_published')
        begin
          LegacyDevice.find(device.id).update_column(:last_insert_datetime, Time.now.utc)
        rescue
        end
      end

      Minuteman.add("good_readings")

    rescue Exception => e

      success = false

      BadReading.create({
        data: (data rescue nil),
        remote_ip: (ip rescue nil),
        message: (e rescue nil),
        version: (version rescue nil),
        device_id: ((device.id if device) rescue nil),
        mac_address: (mac rescue nil),
        timestamp: (parsed_ts rescue nil),
        backtrace: (e.backtrace rescue nil)
      })

      Minuteman.add("bad_readings")

    end

    BackupReading.create(data: data, mac: mac, version: version, ip: ip, stored: success)

    if Rails.env.production? and device
      begin
        Redis.current.publish("data-received", {
          device_id: device.id,
          device: JSON.parse(device.to_json(only: [:id, :name, :location])),
          timestamp: ts,
          readings: readings,
          stored: success,
          data: JSON.parse(ActionController::Base.new.view_context.render( partial: "v0/devices/device", locals: {device: device, current_user: nil}))
        }.to_json)
      rescue
      end
    end

  end

end
