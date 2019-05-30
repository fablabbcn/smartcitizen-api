require 'rails_helper'

RSpec.describe Storer, type: :model do
  before do
    DatabaseCleaner.clean_with(:truncation) # We were getting ActiveRecord::RecordNotUnique:
  end

  let(:kit){       build(:kit, id: 3, name: 'SCK', description: "Board", slug: 'sck', sensor_map: '{"temp": 12}')}
  let(:sensor){    build(:sensor, id:12, name:'HPP828E031', description: 'test')}
  let(:component){ create(:component, id: 12, board: kit, sensor: sensor, equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')}
  let(:device) {   create(:device, device_token: 'aA1234', kit: kit) }

  context 'when receiving good data' do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      allow(Kairos).to receive(:http_post_to).with("/datapoints", anything)

      # received data
      @data = {
        'recorded_at'=> '2018-06-08 10:30:00',
        'sensors'=> [{ 'id'=> sensor.id, 'value'=>21 }]
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
      # expect_any_instance_of(Storer).to receive(:ws_publish)

      Storer.new(device, @data)
    end

    skip 'updates device without touching updated_at' do
      updated_at = device.updated_at

      Storer.new(device, @data)

      expect(device.reload.updated_at).to eq(updated_at)

      expect(device.reload.data).not_to eq(nil)
      expect(device.reload.last_recorded_at).not_to eq(nil)
      expect(device.reload.state).to eq('has_published')

      expect(Storer).to receive(:ws_publish)
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
      expect{ Storer.new(device, @bad_data) }.to raise_error(ArgumentError)
    end

    it 'does not update device' do
      expect{ Storer.new(device, @bad_data) }.to raise_error(ArgumentError)

      expect(device.reload.last_recorded_at).to eq(nil)
      expect(device.reload.data).to eq(nil)
      expect(device.reload.state).to eq('never_published')
    end
  end
end
