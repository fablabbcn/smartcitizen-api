module Presenters
  class ComponentPresenter < BasePresenter

    alias_method :component, :model

    def default_options
      { readings: nil }
    end

    def exposed_fields
      %i{key sensor last_reading_at latest_value previous_value readings}
    end

    def sensor
      present(component.sensor)
    end

    def latest_value
      data = component.device.data
      data[component.sensor_id.to_s] if data
    end

    def previous_value
      old_data = component.device.old_data
      old_data[component.sensor_id.to_s] if old_data
    end

    def readings
      readings = options[:readings]
      if readings
        readings.flat_map { |reading| format_reading(reading) }.compact
      end
    end

    private

    def format_reading(reading)
      # TODO sort out the mess of multiple reading formats used ini
      # DataParser, RawStorer, etc, etc.
      reading.data.map { |entry|
        timestamp = entry.timestamp
        value = entry.sensors&.find { |sensor|
          sensor["id"] == component.sensor_id
        }.dig("value")
        { timestamp: timestamp, value: value  } if value
      }.compact

    end
  end
end
