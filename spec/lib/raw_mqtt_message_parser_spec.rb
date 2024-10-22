require 'rails_helper'

RSpec.describe RawMqttMessageParser do
  subject(:parser) {
    RawMqttMessageParser.new
  }

  it "parses empty messages" do
    message = "{}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: nil, sensors: [] }]})
  end

  it "parses messages with a timestamp" do
    message = "{t:2024-09-25T13:19:38Z}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [] }]})
  end

  it "parses messages with a timestamp and one postitive integer value" do
    message = "{t:2024-09-25T13:19:38Z,1:2}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "1", value: "2"}] }]})
  end

  it "parses messages with a timestamp and one negative integer value" do
    message = "{t:2024-09-25T13:19:38Z,2:-3}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "2", value: "-3"}] }]})
  end

  it "parses messages with a timestamp and one positive float value" do
    message = "{t:2024-09-25T13:19:38Z,10:3.12345}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "10", value: "3.12345"}] }]})
  end

  it "parses messages with a timestamp and one negative float value" do
    message = "{t:2024-09-25T13:19:38Z,100:-2000.12345}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}] }]})
  end

  it "parses messages with a timestamp and multiple values" do
    message = "{t:2024-09-25T13:19:38Z,100:-2000.12345,21:12345.23450}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}, { id: "21", value: "12345.23450"}] }]})
  end

  it "strips non-ascii characters from messages" do
    message = "{t:2024-09-25T13:19:38Z💣💣💣💣,100:-2000.12345,21:12345.23450}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}, { id: "21", value: "12345.23450"}] }]})
  end

  it "strips null vales from messages" do
    message = "{t:2024-09-25T13:19:38Z,100:-2000.12345,21:null}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}] }]})
  end

  it "raises an error if no valid message parsed" do
    message = "ceci n'est pas un message"
    expect {parser.parse(message)}.to raise_error(RuntimeError)
  end

  it "parses timestamps at any position in the packet" do
    message = "{100:-2000.12345,t:2024-09-25T13:19:38Z,21:12345.23450}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}, { id: "21", value: "12345.23450"}] }]})
  end

  it "parses messages with spaces between entries" do
    message = "{t:2024-09-25T13:19:38Z, 100 : -2000.12345, 21 : 12345.23450}"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}, { id: "21", value: "12345.23450"}] }]})
  end

  it "parses messages with leading spaces after the braces" do
    message = "{  t:2024-09-25T13:19:38Z,100:-2000.12345,21:12345.23450  }"
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}, { id: "21", value: "12345.23450"}] }]})
  end

  it "parses messages padded with whitespace" do
    message = "   {t:2024-09-25T13:19:38Z,100:-2000.12345,21:12345.23450}  "
    parsed = parser.parse(message)
    expect(parsed).to eq({ data: [ { recorded_at: "2024-09-25T13:19:38Z", sensors: [{id: "100", value: "-2000.12345"}, { id: "21", value: "12345.23450"}] }]})
  end
end
