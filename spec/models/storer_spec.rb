require 'rails_helper'

RSpec.describe Storer, type: :model do
  let(:sensor){    build(:sensor, id:12, name:'HPP828E031', description: 'test', equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')}
  let(:device) {   create(:device, device_token: 'aA1234') }
  let(:component){ create(:component, id: 12, device: device, sensor: sensor) }

  subject(:storer) {
    Storer.new
  }

  context 'when receiving good data' do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      allow(Kairos).to receive(:http_post_to).with("/datapoints", anything)

      # received data
      @data = {
        'recorded_at'=> '2018-06-08 10:30:00',
        'sensors'=> [{ 'id'=> sensor.id, 'value'=>21 }]
      }

      # TODO get rid of this fucked-up intermediate representation
      @sql_data = {
        "" => Time.parse(@data["recorded_at"]),
        "#{sensor.id}_raw" => 21,
        sensor.id => component.calibrated_value(21)
      }

      sensor_key = device.find_sensor_key_by_id(sensor.id)
      normalized_value = component.normalized_value((Float(@data['sensors'][0]['value'])))
      calibrated_value = component.calibrated_value(normalized_value)

      # expected data
      @ts = Time.parse(@data['recorded_at']).to_i * 1000
      @karios_data = [
        {
          name: sensor_key, # 'temp'
          timestamp: @ts,
          value: normalized_value,
          tags: {
            device_id: device.id,
            method: 'REST'
          }
        }
      ]
      @readings = { sensor_key => [ sensor.id, normalized_value, calibrated_value ] }
    end

    it 'stores data to device' do
      # model/storer.rb is not using Kairos, but Redis -> Telnet
      # expect(Kairos).to receive(:http_post_to).with("/datapoints", @karios_data)
      expect do
        storer.store(device, [@data])
      end.not_to raise_error
    end

    it "updates the component last_reading_at timestamp for each of the provided sensors" do
       expect(device).to receive(:update_component_timestamps).with(
        Time.parse(@data['recorded_at']),
        [sensor.id]
      )
      storer.store(device, [@data])
    end

    skip 'updates device without touching updated_at' do
      updated_at = device.updated_at

      storer.store(device, [@data])

      expect(device.reload.updated_at).to eq(updated_at)

      expect(device.reload.data).not_to eq(nil)
      expect(device.reload.last_reading_at).not_to eq(nil)
      expect(device.reload.state).to eq('has_published')

    end

    context "when the device allows forwarding" do

      let(:device_json) {
        double(:device_json)
      }

      it "forwards the readings for the device, ensuring reading keys are passed as strings" do
        allow(device).to receive(:forward_readings?).and_return(true)
        expect(MQTTForwardingJob).to receive(:perform_later).with(device.id, readings: [@sql_data.stringify_keys])
        storer.store(device, [@data])
      end
    end

    context "when the device does not allow forwarding" do
      it "does not forward the message" do
        allow(device).to receive(:forward_readings?).and_return(false)
        expect(MQTTForwardingJob).not_to receive(:perform_later)
        storer.store(device, [@data])
      end
    end
  end

  context 'when receiving bad data' do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)

      @bad_data = {
        'recorded_at'=> 'not time info here',
        'sensors'=> [{ 'id'=>12, 'value'=>21 }]
      }
    end

    it 'does raise error' do
      expect(Kairos).not_to receive(:http_post_to).with("/datapoints", anything)
      expect{ storer.store(device, [@bad_data]) }.to raise_error(ArgumentError)
    end

    it 'does not update device' do
      expect{ storer.store(device, [@bad_data]) }.to raise_error(ArgumentError)

      expect(device.reload.last_reading_at).to eq(nil)
      expect(device.reload.data).to eq(nil)
      expect(device.reload.state).to eq('never_published')
    end
  end
end
