require 'rails_helper'

RSpec.describe Storer, type: :model do
	let(:data) {
		[{
			"recorded_at": "2016-06-08 10:30:00",
			"sensors": [{
				"id"=>1,
				"value"=>21
				}]
		}]
	}

	let(:device) { create(:device, device_token: 'aA1234', kit: create(:kit)) }

	before do
		allow(Rails.env).to receive(:production?).and_return(true)
	end

	it 'publishes readings using redis' do
		expect(Redis.current).to receive(:publish).with('data-received', anything)
		Storer.new(device.id, data)
	end
end
