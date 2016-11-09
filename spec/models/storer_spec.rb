require 'rails_helper'

RSpec.describe Storer, type: :model do

	let(:sensor) { Sensor.first }
	let(:component) { Component.first }
	let(:device) { create(:device, device_token: 'aA1234', kit: Kit.find(3)) }

	let(:data) {
		{
			'recorded_at'=> '2016-06-08 10:30:00',
			'sensors'=> [{ 'id'=>12, 'value'=>21 }]
		}
	}

	let(:bad_data) {
		{
			'recorded_at'=> 'not time info here',
			'sensors'=> [{ 'id'=>12, 'value'=>21 }]
		}
	}

	let(:parsed_ts) { Time.parse(data['recorded_at']) }
	let(:ts) { parsed_ts.to_i * 1000 }

	let(:sensor_key) { device.find_sensor_key_by_id(sensor.id) } # 'temp'
	let(:normalized_value) { component.normalized_value((Float(data['sensors'][0]['value']))) }
	let(:calibrated_value) { component.calibrated_value(normalized_value)}

	let(:karios_data) { [{
		name: sensor_key,
		timestamp: ts,
		value: normalized_value,
		tags: {
			device_id: device.id,
			method: 'REST'
		} }]
	}
	# sql_data["#{sensor[:id]}_raw"] = sensor[:value]
	# sql_data[sensor[:id]] = sensor[:component].calibrated_value(sensor[:value])

	let(:sql_data) { { "" => parsed_ts, "#{sensor.id}_raw" => data['sensors'][0]['value'], sensor.id => calibrated_value } }
	let(:readings) { { sensor_key => [sensor.id, normalized_value, calibrated_value ] } }

	before(:all) do
		create(:kit, id: 3, name: 'SCK', description: "Board", slug: 'sck', sensor_map: '{"temp": 12}')
		create(:sensor, id:12, name:'HPP828E031', description: 'test')
		create(:component, id: 12, board: Kit.find(3), sensor: Sensor.find(12), equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')
	end

	before do
		allow(Rails.env).to receive(:production?).and_return(true)
		allow(Kairos).to receive(:http_post_to).with("/datapoints", anything) # stubbed request
	end

	context 'when receiving good data' do
		it 'stores data to karios & redis publish' do
			expect(Kairos).to receive(:http_post_to).with("/datapoints", karios_data)
			expect_any_instance_of(Storer).to receive(:redis_publish).with(readings, ts, true)

      Storer.new(device.id, data)
		end

    it 'updates device' do
      Storer.new(device.id, data)

      expect(device.reload.last_recorded_at).not_to eq(nil)
      expect(device.reload.state).to eq('has_published')
    end
	end

	context 'when receiveng bad data' do
		it 'does redis publish anyway and raise error' do
			expect(Kairos).not_to receive(:http_post_to).with("/datapoints", anything)
			expect(Redis.current).to receive(:publish).with('data-received', anything)

			expect{ Storer.new(device.id, bad_data) }.to raise_error(ArgumentError)
		end

    it 'does not update device' do
      expect{ Storer.new(device.id, bad_data) }.to raise_error(ArgumentError)

      expect(device.reload.last_recorded_at).to eq(nil)
      expect(device.reload.state).to eq('never_published')
    end
	end
end
