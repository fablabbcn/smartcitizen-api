require 'rails_helper'

RSpec.describe SensorTag, type: :model do

  let(:the_sensor) { build(:sensor_tag) }

  context 'SensorTag' do
    it "has a name" do
      expect( the_sensor.name ).to eq('SensorTag1')
      expect( the_sensor.description ).to eq('SensorDescription1')
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to belong_to(:sensor) }
  end
end
