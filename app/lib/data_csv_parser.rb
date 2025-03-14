require "csv"
class DataCSVParser

  def parse(string)
    csv = CSV.parse(string)
    sensor_ids = csv[3][1..].map(&:to_i)
    reading_rows = csv[4..-1]
    reading_rows.map { |row|
      recorded_at = row.shift
      sensors = row.zip(sensor_ids).flat_map { |value, sensor_id|
        if value != "null"
          {
            id: sensor_id.to_i,
            value: value.to_f
          }
        end
      }.compact
      if sensors.any?
        { recorded_at: recorded_at, sensors: sensors }
      end
    }.compact
  end
end
