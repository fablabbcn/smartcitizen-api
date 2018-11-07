require 'rails_helper'

RSpec.describe TagSensor, type: :model do

  let(:the_sensor) { build(:tag_sensor) }

  context 'SensorTag' do
    it "has a name and description from the factory" do
      expect( the_sensor.name ).to eq('TagSensor1')
      expect( the_sensor.description ).to eq('TagSensorDescription1')
    end

    it { is_expected.to validate_presence_of(:name) }
    it { should have_many(:sensors).through(:sensor_tags) }
  end
end
