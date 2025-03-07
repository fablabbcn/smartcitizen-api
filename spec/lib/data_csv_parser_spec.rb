require "rails_helper"
require "csv"

RSpec.describe DataCSVParser do
  let(:csv_data) {
    File.read(
      "#{File.dirname(__FILE__)}/../fixtures/fake_device_data.csv"
    )
  }

  let(:data_rows) {
    CSV.parse(csv_data)[4..-1]
  }

  let(:sensor_ids) {
    CSV.parse(csv_data)[3][1..-1]
  }

  subject(:parser) { DataCSVParser.new }

  it "parses a record for each data row which has data" do
    parsed = parser.parse(csv_data)
    expect(parsed.length).to eq(data_rows.length - 1)
  end

  it "parses the timestamp from the first column" do
    parsed = parser.parse(csv_data)
    parsed_timestamps = parsed.map {|row| row[:recorded_at]}
    expect(parsed_timestamps).to eq(data_rows[0..-2].map {|row| row[0]})
  end

  it "parses sensor ids from the third row" do
    parsed = parser.parse(csv_data)
    parsed_sensor_ids = parsed.flat_map { |row| row[:sensors].map { |s| s[:id] }}.to_set
    raw_sensor_ids = sensor_ids.map(&:to_i).to_set
    expect(parsed_sensor_ids).to eq(raw_sensor_ids)
  end

  it "parses values from the data columns" do
    parsed = parser.parse(csv_data)
    parsed_values = parsed.map { |row| row[:sensors].map { |s| s[:value] }}
    raw_values = data_rows.map { |r| r[1..-1].filter {|v| v != "null"}.map(&:to_f) }.filter { |r| r.any? }
    expect(parsed_values).to eq(raw_values)
  end

  it "does not include null values from rows which contain more than one sensor" do
    parsed = parser.parse(csv_data)
    expect(parsed[-1][:sensors].length).to eq(1)
  end

  it "does not include rows with only null values" do
    parsed = parser.parse(csv_data)
    parsed_timestamps = parsed.map {|row| row[:recorded_at]}
    expect(parsed_timestamps).not_to include(data_rows[-1][0])
  end
end
