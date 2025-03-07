require 'rails_helper'

RSpec.describe Sensor, :type => :model do

  it { is_expected.to belong_to(:measurement).without_validating_presence }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  # it { is_expected.to validate_presence_of(:unit) }

  it { is_expected.to have_many(:components) }

  it "has ancestry"

  pending "has a min and max expectation"

  describe "is_raw?" do
    context "when the sensor has the raw tag" do
      it "returns true" do
        sensor = create(:sensor)
        expect(sensor).to receive(:tags).and_return(["raw"])
        expect(sensor.is_raw?).to be(true)
      end
    end
    context "when the sensor does not have the raw tag" do
      it "returns false" do
        sensor = create(:sensor)
        expect(sensor).to receive(:tags).and_return(["other"])
        expect(sensor.is_raw?).to be(false)
      end
    end
  end

end
