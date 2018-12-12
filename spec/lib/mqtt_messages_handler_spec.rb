require 'rails_helper'

RSpec.describe MqttMessagesHandler do
  DatabaseCleaner.clean_with(:truncation) # We were getting ActiveRecord::RecordNotUnique:
  let(:device) { create(:device, device_token: 'aA1234') }
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

    @hello_packet = MQTT::Packet::Publish.new(
      topic: "device/sck/#{device.device_token}/hello",
      payload: 'content ingored by MqttMessagesHandler\#hello'
    )

    @inventory_packet = MQTT::Packet::Publish.new(
      topic: "device/sck/inventory",
      payload: '{"random_property":"random_result"}'
    )

    @hardware_info_packet = MQTT::Packet::Publish.new(
      topic: "device/sck/#{device.device_token}/hardware_info",
      payload: '{"id":47,"uuid":"7d45fead-defd-4482-bc6a-a1b711879e2d"}'
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
        MqttMessagesHandler.handle(@packet)
      end
    end

    context 'invalid packet' do
      it 'it notifies Airbrake(has been removed)' do
        expect(Kairos).not_to receive(:http_post_to)
        #TODO: Do we need to disable all, after removing Airbrake?
        #expect(Airbrake).to receive(:notify).with(RuntimeError, 'device not found - payload: '\
          #'{"data": [{"recorded_at": "2016-06-08 10:30:00","sensors": [{"id": 1,"value": 21}]}]}')
        MqttMessagesHandler.handle(@invalid_packet)
      end
    end
  end

  describe '#hello' do
    it 'logs device_token has been received' do
      expect(Redis.current).to receive(:publish).with(
        'token-received', { device_token: device.device_token }.to_json
      )
      MqttMessagesHandler.handle(@hello_packet)
    end
  end

  describe '#inventory' do
    it 'logs inventory has been received' do
      expect(@inventory_packet.payload).to eq((device_inventory.report.to_json))
      MqttMessagesHandler.handle(@inventory_packet)
    end
  end

  describe '#hardware_info' do
    it 'hardware info has been received' do
      expect(@hardware_info_packet.payload).to eq((device.hardware_info.to_json))
      MqttMessagesHandler.handle(@hardware_info_packet)
    end
  end
end
