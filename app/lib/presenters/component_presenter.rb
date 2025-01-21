module Presenters
  class ComponentPresenter < BasePresenter

    alias_method :component, :model

    def default_options
      { readings: nil }
    end

    def exposed_fields
      %i{sensor last_reading_at latest_value previous_value readings}
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
        readings.map { |reading| format_reading(reading) }.compact
      end
    end

    private

    def format_reading(reading)
      timestamp = reading[""]
      value = reading[component.sensor_id.to_s]
      { timestamp: timestamp, value: value } if value
    end
  end
end
