module DataParser
  module Storer
    extend ActiveSupport::Concern

    included do
      private_class_method :sensor_reading, :data_hash
    end

    class_methods do
      def parse_reading(device, reading)
        parsed_ts = timestamp_parse(reading['recorded_at'])
        ts = parsed_ts.to_i * 1000

        _data = []
        sql_data = {"" => parsed_ts}

        reading['sensors'].each do |sensor_data|
          sensor = sensor_reading(device, sensor_data)

          # Skip current sensor, but keep ingesting other sensors
          next if sensor.nil?

          _data.push(data_hash(device, sensor, ts))

          sql_data["#{sensor[:id]}_raw"] = sensor[:value]
          sql_data[sensor[:id]] = sensor[:component].calibrated_value(sensor[:value])

          reading[sensor[:key]] = [sensor[:id], sensor[:value], sql_data[sensor[:id]]]
        end

        {
          _data: _data,
          sql_data: sql_data,
          readings: reading.except!('recorded_at', 'sensors'),
          parsed_ts: parsed_ts,
          ts: ts
        }
      end

      def timestamp_parse(timestamp)
        # TODO: What to do if timestamp is empty?
        if timestamp
          parsed_ts = Time.parse(timestamp)
          # TODO: render json instead of raise
          raise "Timestamp not within range" if parsed_ts > 1.day.from_now or parsed_ts < 3.years.ago
        else
          raise "No timestamp given"
        end

        parsed_ts
      end

      def sensor_reading(device, sensor)
        begin
          id = Integer(sensor['id'])
          key = device.find_sensor_key_by_id(id)
        rescue
          key = sensor['id']
          id = device.find_sensor_id_by_key(key)
        end
        component = device.components.detect{ |c| c["sensor_id"] == id }

        #raise "This component does not have sensor_id: #{id}" if component.nil?
        return nil if component.nil?

        value = component.normalized_value( (Float(sensor['value']) rescue sensor['value']) )
        {
          id: id,
          key: key,
          component: component,
          value: value
        }
      end

      def data_hash(device, sensor, ts)
        {
          name: sensor[:key],
          timestamp: ts,
          value: sensor[:value],
          tags: {
            device_id: device.id,
            method: 'REST'
          }
        }
      end
    end
  end

end
