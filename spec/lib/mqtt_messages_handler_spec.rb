require 'rails_helper'

RSpec.describe MqttMessagesHandler do
  let(:device) { create(:device, device_token: 'aA1234') }
  let(:orphan_device) { create(:orphan_device, device_token: 'xX9876') }
  let(:component) { build(:component, board: build(:kit), sensor: build(:sensor, id: 1)) }
  let(:device_inventory) { create(:device_inventory, report: '{"random_property": "random_result"}') }

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

    @invalid_packet = MQTT::Packet::Publish.new(
      topic: "device/sck/invalid_device_token/readings",
      payload: '{"data": [{"recorded_at": "2016-06-08 10:30:00","sensors": [{"id": 1,"value": 21}]}]}'
    )

    @inventory_packet = MQTT::Packet::Publish.new(
      topic: "device/sck/inventory",
      payload: '{"random_property":"random_result"}'
    )

    @hardware_info_packet = MQTT::Packet::Publish.new(
      topic: "device/sck/#{device.device_token}/info",
      payload: '{"id":48,"uuid":"7d45fead-defd-4482-bc6a-a1b711879e2d"}'
    )

    @hardware_info_packet_bad = MQTT::Packet::Publish.new(
      topic: "device/sck/BAD_TOPIC/info",
      payload: '{"id":32,"uuid":"7d45fead-defd-4482-bc6a-a1b711879e2d"}'
    )
  end

  describe '#device_token' do
    it 'returns device_token from topic' do
      expect(MqttMessagesHandler.device_token(@packet.topic)).to eq(device.device_token)
    end
  end

  describe '#data' do
    it 'returns parsed data from payload' do
      expect(MqttMessagesHandler.data(@packet.payload)).to match_array(@data)
    end
  end

  describe '#readings' do
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
    context 'valid reading packet' do
      it 'queues reading data in order to be stored' do
        # model/storer.rb is not using Kairos, but Redis -> Telnet
        #expect(Kairos).to receive(:http_post_to).with("/datapoints", @data_array)
        #expect(Storer).to receive(:initialize).with('a', 'b')
        expect(Redis.current).to receive(:publish).with(
          'telnet_queue', [{
            name: nil,
            timestamp: 1465374600000,
            value: 21.0,
            tags: {
              device_id: device.id,
              method: 'REST'
            }
          }].to_json
        )
        MqttMessagesHandler.handle_topic(@packet.topic, @packet.payload)
      end

      it 'does not queue when there is no data' do
        expect(Redis.current).not_to receive(:publish).with(
          'telnet_queue', [{
            name: nil,
            timestamp: 1465374600000,
            value: 21.0,
            tags: {
              device_id: device.id,
              method: 'REST'
            }
          }].to_json
        )
        MqttMessagesHandler.handle_topic(@packet.topic, @hardware_info_packet.payload)
      end

    end

    context 'invalid packet' do
      it 'it notifies Raven' do
        allow(Raven).to receive(:capture_exception)
        expect(Kairos).not_to receive(:http_post_to)
        MqttMessagesHandler.handle_topic(@invalid_packet.topic, @invalid_packet.payload)
        #expect(Raven).to have_received(:capture_exception).with(RuntimeError)
      end
    end
  end

  describe '#handle_hello' do
    it 'logs device_token has been received' do
      expect(orphan_device.device_handshake).to be false
      expect(Redis.current).to receive(:publish).with(
        'token-received', {
          onboarding_session: orphan_device.onboarding_session
        }.to_json
      )
      MqttMessagesHandler.handle_topic(
        "device/sck/#{orphan_device.device_token}/hello",
        'content ignored by MqttMessagesHandler\#hello'
      )
      expect(orphan_device.reload.device_handshake).to be true
    end
  end

  describe '#inventory' do
    it 'logs inventory has been received' do
      expect(DeviceInventory.count).to eq(0)
      # This creates a new device_inventory item
      expect(@inventory_packet.payload).to eq((device_inventory.report.to_json))
      expect(DeviceInventory.count).to eq(1)
      MqttMessagesHandler.handle_topic(@inventory_packet.topic, @inventory_packet.payload)
      expect(DeviceInventory.last.report["random_property"]).to eq('random_result')
      expect(DeviceInventory.count).to eq(2)
    end

    it 'does not log inventory with an incorrect / nil topic' do
      expect(DeviceInventory.count).to eq(0)
      MqttMessagesHandler.handle_topic('invenxxx','{"random_property":"random_result2"}')
      MqttMessagesHandler.handle_topic(nil,'{"random_property":"random_result2"}')
      expect(DeviceInventory.count).to eq(0)
    end
  end

  describe '#hardware_info' do
    it 'hardware info has been received and id changed from 47 -> 48' do
      expect(device.hardware_info["id"]).to eq(47)
      MqttMessagesHandler.handle_topic(@hardware_info_packet.topic, @hardware_info_packet.payload)
      device.reload
      expect(device.hardware_info["id"]).to eq(48)
      expect(@hardware_info_packet.payload).to eq((device.hardware_info.to_json))
    end

    it 'does not handle bad topic' do
      expect(device.hardware_info["id"]).to eq(47)
      MqttMessagesHandler.handle_topic(@hardware_info_packet_bad.topic, @hardware_info_packet_bad.payload)
      device.reload
      expect(device.hardware_info["id"]).to eq(47)
      expect(@hardware_info_packet_bad.payload).to_not eq((device.hardware_info.to_json))
    end
  end
end
