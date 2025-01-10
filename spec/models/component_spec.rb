require 'rails_helper'

RSpec.describe Component, :type => :model do
  it { is_expected.to belong_to(:device) }
  it { is_expected.to belong_to(:sensor) }
  it { is_expected.to validate_presence_of(:device) }
  it { is_expected.to validate_presence_of(:sensor) }

  let(:component) {
    create(:component, device: create(:device), sensor: create(:sensor))
  }

  it "validates uniqueness of board to sensor" do
    component = create(:component, device: create(:device), sensor: create(:sensor))
    expect{ create(:component, device: component.device, sensor: component.sensor) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe "creating a unique sensor key" do
    describe "when the given key is not in the list of existing keys" do
      it "uses the key as is" do
        generated_key = component.get_unique_key("key", ["other"])
        expect(generated_key).to eq("key")
      end
    end

    describe "when the given key is in the list of existing keys" do
      it "adds an incremeting number to the key" do
        generated_key = component.get_unique_key("key", ["key", "other", "key_1"])
        expect(generated_key).to eq("key_2")
      end
    end
  end

  describe "measurement_name" do
    it "delegates to the sensor's measurement" do
      component.sensor.measurement = create(:measurement)
      expect(component.sensor.measurement).to receive(:name).and_return("measurement name")
      expect(component.measurement_name).to eq("measurement name")
    end
  end

  describe "measurement_description" do
    it "delegates to the sensor's description" do
      component.sensor.measurement = create(:measurement)
      expect(component.sensor.measurement).to receive(:description).and_return("measurement description")
      expect(component.measurement_description).to eq("measurement description")
    end
  end

  describe "value_unit" do
    it "delegates to the sensor" do
      expect(component.sensor).to receive(:unit).and_return("unit")
      expect(component.value_unit).to eq("unit")
    end
  end

  describe "latest_value" do
    it "gets the corresponding value for the sensor from the device" do
      component.device.data = { component.sensor.id.to_s => 123 }
      expect(component.latest_value).to eq(123)
    end
  end

  describe "previous_value" do
    it "gets the corresponding old value for the sensor from the device" do
      component.device.old_data = { component.sensor.id.to_s => 124 }
      expect(component.previous_value).to eq(124)
    end
  end

  describe "is_raw?" do
    describe "when the sensor has the 'raw' tag" do
      it "returns true" do
        expect(component.sensor).to receive(:tags).and_return(["raw"])
        expect(component.is_raw?).to be(true)
      end
    end

    describe "when the sensor does not have the 'raw' tag" do
      it "returns false" do
        expect(component.sensor).to receive(:tags).and_return(["other"])
        expect(component.is_raw?).to be(false)
      end
    end
  end

  describe "trend" do
    context "when the latest_value is greater than the previous value" do
      it "returns +1" do
        component.device.data = { component.sensor.id.to_s => 123 }
        component.device.old_data = { component.sensor.id.to_s => 120 }
        expect(component.trend).to eq(1)
      end
    end

    context "when the latest_value is equal to the previous value" do
      it "returns 0" do
        component.device.data = { component.sensor.id.to_s => 123 }
        component.device.old_data = { component.sensor.id.to_s => 123 }
        expect(component.trend).to eq(0)
      end
    end

    context "when the latest_value is less than the previous value" do
      it "returns -1" do
        component.device.data = { component.sensor.id.to_s => 123 }
        component.device.old_data = { component.sensor.id.to_s => 130 }
        expect(component.trend).to eq(-1)
      end
    end
  end
end
