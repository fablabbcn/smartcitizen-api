require 'rails_helper'

RSpec.describe MqttHandler::ReadingsPacket do
  let(:device) { create(:device, device_token: 'aA1234') }
  let(:component) { create(:component, board: create(:kit), sensor: create(:sensor, id: 1)) }

  before do
    device.components << component

    @data = [{
      "recorded_at"=>"2016-06-08 10:30:00",
      "sensors"=>[{
        "id"=>1,
        "value"=>21
      }]
    }]

    @packet = MQTT::Packet::Publish.new(
      topic: "device/sck/#{device.device_token}/readings",
      payload: '{"data": [{"recorded_at": "2016-06-08 10:30:00","sensors": [{"id": 1,"value": 21}]}]}'
    )
  end

  describe '#device_token' do
    it 'returns device_token from topic' do
      expect(MqttHandler::ReadingsPacket.device_token(@packet)).to eq(device.device_token)
    end
  end

  describe '#data' do
    it 'returns parsed data from payload' do
      expect(MqttHandler::ReadingsPacket.data(@packet)).to match_array(@data)
    end
  end

  describe '#store' do
    before do
      # storer data processing
      value = component.normalized_value((Float(@data[0]['sensors'][0]['value'])))
      @data_array = [{
        name: device.find_sensor_key_by_id(1),
        timestamp: Time.parse(@data[0]['recorded_at']).to_i * 1000,
        value: value,
        tags: {
          device_id: device.id,
          method: 'REST'
        }
      }]
    end
    it 'stores data from packet to correct device' do
      expect(Kairos).to receive(:http_post_to).with("/datapoints", @data_array)
      MqttHandler::ReadingsPacket.store(@packet)
    end
  end
end
